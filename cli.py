#!/usr/bin/env python3
# -*- coding: utf-8 -*-
# SPDX-License-Identifier: MIT
"""
cli.py — offizielle, rein lesende MediaBrain-Kommandozeile

Liest media_brain.db direkt via sqlite3 (kein PySide6-Import, kein core.py-Import
wegen config/logger-Abhaengigkeiten). Reiner Lesezugriff.

Verwendung:
  python cli.py list [--type TYPE] [--limit N]
  python cli.py search <suchbegriff> [--type TYPE]
  python cli.py favs [--type TYPE]
  python cli.py recent [--limit N]
  python cli.py show <id_oder_titel>
  python cli.py types
  python cli.py --db /pfad/media_brain.db list

Typen entsprechen den gespeicherten Daten; kanonisch sind movie, series, music,\nclip, podcast, audiobook und document. Legacy-Daten können weitere Werte enthalten.

Umgebungsvariablen:
  MEDIABRAIN_DB   Pfad zur media_brain.db
"""
from __future__ import annotations

import argparse
import os
import sqlite3
import sys
from pathlib import Path

# ---------------------------------------------------------------------------
# DB-Suche
# ---------------------------------------------------------------------------

_APP_DIR = Path(__file__).resolve().parent


def _find_db(override: str | None = None) -> Path:
    if override:
        return Path(override).expanduser().resolve()
    env = os.environ.get("MEDIABRAIN_DB")
    if env:
        return Path(env).expanduser().resolve()
    default = _APP_DIR / "media_brain.db"
    if default.exists():
        return default
    appdata = os.environ.get("APPDATA")
    if appdata:
        candidate = Path(appdata) / "MediaBrain" / "media_brain.db"
        if candidate.exists():
            return candidate
    return default


def _open(db_path: Path) -> sqlite3.Connection:
    if not db_path.exists():
        print(f"[FEHLER] Datenbank nicht gefunden: {db_path}", file=sys.stderr)
        sys.exit(1)
    uri = db_path.expanduser().resolve().as_uri() + "?mode=ro"
    conn = sqlite3.connect(uri, uri=True)
    conn.row_factory = sqlite3.Row
    return conn


# ---------------------------------------------------------------------------
# Hilfsfunktionen
# ---------------------------------------------------------------------------

def _fmt_item(r: sqlite3.Row, verbose: bool = False) -> str:
    fav = " ★" if r["is_favorite"] else ""
    typ = r["type"] or ""
    src = r["source"] or ""
    title = r["title"] or "(kein Titel)"
    line = f"[{r['id']}] {title}{fav}  [{typ}/{src}]"
    if verbose:
        if r["artist"]:
            line += f"\n    Künstler: {r['artist']}"
        if r["description"]:
            desc = r["description"][:120].replace("\n", " ")
            line += f"\n    {desc}"
    return line


def _seconds_to_hms(s: int | None) -> str:
    if s is None:
        return ""
    h, rem = divmod(int(s), 3600)
    m, sec = divmod(rem, 60)
    if h:
        return f"{h}:{m:02d}:{sec:02d}"
    return f"{m}:{sec:02d}"


# ---------------------------------------------------------------------------
# Befehle
# ---------------------------------------------------------------------------

def cmd_list(conn: sqlite3.Connection, args: argparse.Namespace) -> int:
    query = "SELECT * FROM media_items WHERE blacklist_flag = 0"
    params: list = []
    if args.type:
        query += " AND type = ?"
        params.append(args.type)
    query += " ORDER BY title"
    limit = getattr(args, "limit", 50) or 50
    query += f" LIMIT {int(limit)}"
    rows = conn.execute(query, params).fetchall()
    if not rows:
        print("Keine Einträge gefunden.")
        return 0
    for r in rows:
        print(_fmt_item(r))
    print(f"\n{len(rows)} Einträge (max. {limit})")
    return 0


def cmd_search(conn: sqlite3.Connection, args: argparse.Namespace) -> int:
    term = args.query
    query = """SELECT * FROM media_items
               WHERE blacklist_flag = 0
                 AND (title LIKE ? OR description LIKE ? OR artist LIKE ? OR channel LIKE ?)"""
    params = [f"%{term}%"] * 4
    if args.type:
        query += " AND type = ?"
        params.append(args.type)
    query += " ORDER BY title LIMIT 100"
    rows = conn.execute(query, params).fetchall()
    if not rows:
        print(f"Keine Treffer für '{term}'.")
        return 0
    for r in rows:
        print(_fmt_item(r))
    print(f"\n{len(rows)} Treffer")
    return 0


def cmd_favs(conn: sqlite3.Connection, args: argparse.Namespace) -> int:
    query = "SELECT * FROM media_items WHERE is_favorite = 1 AND blacklist_flag = 0"
    params: list = []
    if args.type:
        query += " AND type = ?"
        params.append(args.type)
    query += " ORDER BY title"
    rows = conn.execute(query, params).fetchall()
    if not rows:
        print("Keine Favoriten.")
        return 0
    for r in rows:
        print(_fmt_item(r))
    print(f"\n{len(rows)} Favoriten")
    return 0


def cmd_recent(conn: sqlite3.Connection, args: argparse.Namespace) -> int:
    limit = getattr(args, "limit", 20) or 20
    rows = conn.execute(
        """SELECT * FROM media_items
           WHERE blacklist_flag = 0 AND last_opened_at IS NOT NULL
           ORDER BY last_opened_at DESC
           LIMIT ?""",
        (int(limit),),
    ).fetchall()
    if not rows:
        print("Noch keine geöffneten Medien.")
        return 0
    for r in rows:
        opened = (r["last_opened_at"] or "")[:16]
        dur = _seconds_to_hms(r["length_seconds"])
        line = f"  {opened}  {_fmt_item(r)}"
        if dur:
            line += f"  [{dur}]"
        print(line)
    print(f"\n{len(rows)} zuletzt geöffnet")
    return 0


def cmd_show(conn: sqlite3.Connection, args: argparse.Namespace) -> int:
    term = args.id_or_title
    if term.isdigit():
        rows = conn.execute(
            "SELECT * FROM media_items WHERE id = ? AND blacklist_flag = 0", (int(term),)
        ).fetchall()
    else:
        rows = conn.execute(
            "SELECT * FROM media_items WHERE title LIKE ? AND blacklist_flag = 0",
            (f"%{term}%",),
        ).fetchall()
    if not rows:
        print(f"Kein Eintrag für '{term}'.")
        return 1
    for r in rows:
        print(f"ID:           {r['id']}")
        print(f"Titel:        {r['title']}")
        print(f"Typ:          {r['type']}")
        print(f"Quelle:       {r['source']}")
        dur = _seconds_to_hms(r["length_seconds"])
        if dur:
            print(f"Dauer:        {dur}")
        print(f"Favorit:      {'ja' if r['is_favorite'] else 'nein'}")
        print(f"Zuletzt offen: {(r['last_opened_at'] or '—')[:16]}")
        if r["artist"]:
            print(f"Künstler:     {r['artist']}")
        if r["channel"]:
            print(f"Kanal:        {r['channel']}")
        if r["description"]:
            print(f"Beschreibung: {r['description'][:200]}")
        print()
    return 0


def cmd_types(conn: sqlite3.Connection) -> int:
    rows = conn.execute(
        "SELECT type, COUNT(*) as cnt FROM media_items WHERE blacklist_flag = 0 GROUP BY type ORDER BY cnt DESC"
    ).fetchall()
    if not rows:
        print("Keine Medientypen gefunden.")
        return 0
    for r in rows:
        print(f"  {r['type']:<20} {r['cnt']} Einträge")
    return 0


# ---------------------------------------------------------------------------
# Argument-Parser
# ---------------------------------------------------------------------------

def _build_parser() -> argparse.ArgumentParser:
    p = argparse.ArgumentParser(
        prog="mediabrain-cli",
        description="MediaBrain — rein lesende Kommandozeile",
    )
    p.add_argument("--db", metavar="PFAD", help="Pfad zur media_brain.db")

    sub = p.add_subparsers(dest="cmd", required=True)

    ls = sub.add_parser("list", help="Medien auflisten")
    ls.add_argument("--type", help="Filter: Medientyp")
    ls.add_argument("--limit", type=int, default=50, metavar="N")

    se = sub.add_parser("search", help="Medien suchen")
    se.add_argument("query", help="Suchbegriff")
    se.add_argument("--type", help="Filter: Medientyp")

    fv = sub.add_parser("favs", help="Favoriten")
    fv.add_argument("--type", help="Filter: Medientyp")

    rc = sub.add_parser("recent", help="Zuletzt geoeffnet")
    rc.add_argument("--limit", type=int, default=20, metavar="N")

    sh = sub.add_parser("show", help="Details zu einem Medium")
    sh.add_argument("id_or_title", help="ID oder Titel (Teilstring)")

    sub.add_parser("types", help="Alle Medientypen mit Anzahl")

    return p


# ---------------------------------------------------------------------------
# Main
# ---------------------------------------------------------------------------

def main() -> int:
    parser = _build_parser()
    args = parser.parse_args()
    db_path = _find_db(args.db)
    conn = _open(db_path)
    try:
        if args.cmd == "list":
            return cmd_list(conn, args)
        elif args.cmd == "search":
            return cmd_search(conn, args)
        elif args.cmd == "favs":
            return cmd_favs(conn, args)
        elif args.cmd == "recent":
            return cmd_recent(conn, args)
        elif args.cmd == "show":
            return cmd_show(conn, args)
        elif args.cmd == "types":
            return cmd_types(conn)
    finally:
        conn.close()
    return 0


if __name__ == "__main__":
    sys.exit(main())
