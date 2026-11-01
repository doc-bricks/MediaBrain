#!/usr/bin/env python3
# -*- coding: utf-8 -*-
# SPDX-License-Identifier: MIT
"""
cli.py — offizielle, rein lesende MediaBrain-Kommandozeile

Liest media_brain.db direkt via sqlite3 (kein PySide6-Import, kein core.py-Import
wegen config/logger-Abhaengigkeiten). Reiner Lesezugriff.

Verwendung:
  python cli.py --lang de list [--type TYPE] [--limit N]
  python cli.py --lang fr search <suchbegriff> [--type TYPE]
  python cli.py --lang ar favs [--type TYPE]
  python cli.py --lang pt recent [--limit N]
  python cli.py --lang hi show <id_oder_titel>
  python cli.py --lang bn types
  python cli.py --db /pfad/media_brain.db --lang es list

Typen entsprechen den gespeicherten Daten; kanonisch sind movie, series, music,
clip, podcast, audiobook und document. Legacy-Daten können weitere Werte enthalten.

Umgebungsvariablen:
  MEDIABRAIN_DB    Pfad zur media_brain.db
  MEDIABRAIN_LANG  Sprache für die CLI (de, en, es, zh, ja, ru, fr, hi, ar, bn, pt)
"""
from __future__ import annotations

import argparse
import os
import sqlite3
import sys
from contextlib import contextmanager
from pathlib import Path
from typing import Iterator, Sequence

from translator import SUPPORTED_LANGUAGES, TranslationSystem

# ---------------------------------------------------------------------------
# DB-Suche
# ---------------------------------------------------------------------------

_APP_DIR = Path(__file__).resolve().parent
_DEFAULT_TRANSLATOR = TranslationSystem('de', app_dir=_APP_DIR, auto_register_missing=False)


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


def _tr(translator: TranslationSystem | None) -> TranslationSystem:
    return translator if translator is not None else _DEFAULT_TRANSLATOR


def _open(db_path: Path, translator: TranslationSystem | None = None) -> sqlite3.Connection:
    tr = _tr(translator)
    if not db_path.exists():
        print(tr.t("[FEHLER] Datenbank nicht gefunden: {db_path}", db_path=db_path), file=sys.stderr)
        sys.exit(1)
    uri = db_path.expanduser().resolve().as_uri() + "?mode=ro"
    conn = sqlite3.connect(uri, uri=True)
    conn.row_factory = sqlite3.Row
    return conn


# ---------------------------------------------------------------------------
# Hilfsfunktionen
# ---------------------------------------------------------------------------

def _fmt_item(
    r: sqlite3.Row,
    verbose: bool = False,
    translator: TranslationSystem | None = None,
) -> str:
    tr = _tr(translator)
    fav = " ★" if r["is_favorite"] else ""
    typ = r["type"] or ""
    src = r["source"] or ""
    title = r["title"] or tr.t("(kein Titel)")
    line = f"[{r['id']}] {title}{fav}  [{typ}/{src}]"
    if verbose:
        if r["artist"]:
            line += f"\n    {tr.t('Künstler:')} {r['artist']}"
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

def cmd_list(
    conn: sqlite3.Connection,
    args: argparse.Namespace,
    translator: TranslationSystem | None = None,
) -> int:
    tr = _tr(translator)
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
        print(tr.t("Keine Einträge gefunden."))
        return 0
    for r in rows:
        print(_fmt_item(r, translator=tr))
    print(f"\n{tr.t('{count} Einträge (max. {limit})', count=len(rows), limit=limit)}")
    return 0


def cmd_search(
    conn: sqlite3.Connection,
    args: argparse.Namespace,
    translator: TranslationSystem | None = None,
) -> int:
    tr = _tr(translator)
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
        print(tr.t("Keine Treffer für '{term}'.", term=term))
        return 0
    for r in rows:
        print(_fmt_item(r, translator=tr))
    print(f"\n{tr.t('{count} Treffer', count=len(rows))}")
    return 0


def cmd_favs(
    conn: sqlite3.Connection,
    args: argparse.Namespace,
    translator: TranslationSystem | None = None,
) -> int:
    tr = _tr(translator)
    query = "SELECT * FROM media_items WHERE is_favorite = 1 AND blacklist_flag = 0"
    params: list = []
    if args.type:
        query += " AND type = ?"
        params.append(args.type)
    query += " ORDER BY title"
    rows = conn.execute(query, params).fetchall()
    if not rows:
        print(tr.t("Keine Favoriten."))
        return 0
    for r in rows:
        print(_fmt_item(r, translator=tr))
    print(f"\n{tr.t('{count} Favoriten', count=len(rows))}")
    return 0


def cmd_recent(
    conn: sqlite3.Connection,
    args: argparse.Namespace,
    translator: TranslationSystem | None = None,
) -> int:
    tr = _tr(translator)
    limit = getattr(args, "limit", 20) or 20
    rows = conn.execute(
        """SELECT * FROM media_items
           WHERE blacklist_flag = 0 AND last_opened_at IS NOT NULL
           ORDER BY last_opened_at DESC
           LIMIT ?""",
        (int(limit),),
    ).fetchall()
    if not rows:
        print(tr.t("Noch keine geöffneten Medien."))
        return 0
    for r in rows:
        opened = (r["last_opened_at"] or "")[:16]
        dur = _seconds_to_hms(r["length_seconds"])
        line = f"  {opened}  {_fmt_item(r, translator=tr)}"
        if dur:
            line += f"  [{dur}]"
        print(line)
    print(f"\n{tr.t('{count} zuletzt geöffnet', count=len(rows))}")
    return 0


def cmd_show(
    conn: sqlite3.Connection,
    args: argparse.Namespace,
    translator: TranslationSystem | None = None,
) -> int:
    tr = _tr(translator)
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
        print(tr.t("Kein Eintrag für '{term}'.", term=term))
        return 1
    for r in rows:
        print(f"{tr.t('ID:'):<14}{r['id']}")
        print(f"{tr.t('Titel:'):<14}{r['title']}")
        print(f"{tr.t('Typ:'):<14}{r['type']}")
        print(f"{tr.t('Quelle:'):<14}{r['source']}")
        dur = _seconds_to_hms(r["length_seconds"])
        if dur:
            print(f"{tr.t('Dauer:'):<14}{dur}")
        print(f"{tr.t('Favorit:'):<14}{tr.t('ja') if r['is_favorite'] else tr.t('nein')}")
        print(f"{tr.t('Zuletzt offen:')} {(r['last_opened_at'] or '—')[:16]}")
        if r["artist"]:
            print(f"{tr.t('Künstler:'):<14}{r['artist']}")
        if r["channel"]:
            print(f"{tr.t('Kanal:'):<14}{r['channel']}")
        if r["description"]:
            print(f"{tr.t('Beschreibung:'):<14}{r['description'][:200]}")
        print()
    return 0


def cmd_types(conn: sqlite3.Connection, translator: TranslationSystem | None = None) -> int:
    tr = _tr(translator)
    rows = conn.execute(
        "SELECT type, COUNT(*) as cnt FROM media_items WHERE blacklist_flag = 0 GROUP BY type ORDER BY cnt DESC"
    ).fetchall()
    if not rows:
        print(tr.t("Keine Medientypen gefunden."))
        return 0
    for r in rows:
        print(f"  {r['type']:<20} {tr.t('{count} Einträge', count=r['cnt'])}")
    return 0


# ---------------------------------------------------------------------------
# Argument-Parser
# ---------------------------------------------------------------------------

@contextmanager
def _argparse_locale(translator: TranslationSystem) -> Iterator[None]:
    original = argparse._
    argparse._ = translator.t
    try:
        yield
    finally:
        argparse._ = original


def _build_parser(
    translator: TranslationSystem | None = None,
    default_lang: str | None = None,
) -> argparse.ArgumentParser:
    tr = _tr(translator)
    lang = default_lang or tr.get_language()
    with _argparse_locale(tr):
        p = argparse.ArgumentParser(
            prog="mediabrain-cli",
            description=tr.t("MediaBrain — rein lesende Kommandozeile"),
        )
        p.add_argument("--db", metavar=tr.t("PFAD"), help=tr.t("Pfad zur media_brain.db"))
        p.add_argument(
            "--lang",
            choices=SUPPORTED_LANGUAGES,
            default=lang,
            metavar="LANG",
            help=tr.t("Sprache für die CLI"),
        )

        sub = p.add_subparsers(dest="cmd", required=True)

        def add_subcommand_language(parser: argparse.ArgumentParser) -> None:
            parser.add_argument(
                "--lang",
                choices=SUPPORTED_LANGUAGES,
                default=argparse.SUPPRESS,
                metavar="LANG",
                help=tr.t("Sprache für die CLI"),
            )

        ls = sub.add_parser("list", help=tr.t("Medien auflisten"))
        add_subcommand_language(ls)
        ls.add_argument("--type", help=tr.t("Filter: Medientyp"))
        ls.add_argument("--limit", type=int, default=50, metavar="N")

        se = sub.add_parser("search", help=tr.t("Medien suchen"))
        add_subcommand_language(se)
        se.add_argument("query", help=tr.t("Suchbegriff"))
        se.add_argument("--type", help=tr.t("Filter: Medientyp"))

        fv = sub.add_parser("favs", help=tr.t("Favoriten"))
        add_subcommand_language(fv)
        fv.add_argument("--type", help=tr.t("Filter: Medientyp"))

        rc = sub.add_parser("recent", help=tr.t("Zuletzt geoeffnet"))
        add_subcommand_language(rc)
        rc.add_argument("--limit", type=int, default=20, metavar="N")

        sh = sub.add_parser("show", help=tr.t("Details zu einem Medium"))
        add_subcommand_language(sh)
        sh.add_argument("id_or_title", help=tr.t("ID oder Titel (Teilstring)"))

        ty = sub.add_parser("types", help=tr.t("Alle Medientypen mit Anzahl"))
        add_subcommand_language(ty)

        return p


def _normalize_language(raw: str | None) -> str:
    if not raw:
        return "de"
    normalized = raw.strip().replace("_", "-").split("-", maxsplit=1)[0].lower()
    return normalized if normalized in SUPPORTED_LANGUAGES else "de"


def _requested_language(argv: Sequence[str]) -> str:
    explicit: str | None = None
    for index, arg in enumerate(argv):
        if arg == "--lang" and index + 1 < len(argv):
            explicit = argv[index + 1]
        elif arg.startswith("--lang="):
            explicit = arg.split("=", maxsplit=1)[1]
    if explicit is None:
        explicit = os.environ.get("MEDIABRAIN_LANG")
    return _normalize_language(explicit)


def _configure_console_utf8() -> None:
    for stream in (sys.stdout, sys.stderr):
        reconfigure = getattr(stream, "reconfigure", None)
        if callable(reconfigure):
            try:
                reconfigure(encoding="utf-8")
            except (OSError, ValueError):
                pass


# ---------------------------------------------------------------------------
# Main
# ---------------------------------------------------------------------------

def main(argv: Sequence[str] | None = None) -> int:
    _configure_console_utf8()
    args_in = list(sys.argv[1:] if argv is None else argv)
    lang = _requested_language(args_in)
    tr = TranslationSystem(lang, app_dir=_APP_DIR, auto_register_missing=False)
    with _argparse_locale(tr):
        parser = _build_parser(tr, default_lang=lang)
        args = parser.parse_args(args_in)
    db_path = _find_db(args.db)
    conn = _open(db_path, tr)
    try:
        if args.cmd == "list":
            return cmd_list(conn, args, tr)
        elif args.cmd == "search":
            return cmd_search(conn, args, tr)
        elif args.cmd == "favs":
            return cmd_favs(conn, args, tr)
        elif args.cmd == "recent":
            return cmd_recent(conn, args, tr)
        elif args.cmd == "show":
            return cmd_show(conn, args, tr)
        elif args.cmd == "types":
            return cmd_types(conn, tr)
    finally:
        conn.close()
    return 0


if __name__ == "__main__":
    sys.exit(main())
