"""Validate the repository-owned, pre-submission Store materials."""

from __future__ import annotations

import json
import re
import sys
import struct
from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]
CONFIG_PATH = ROOT / "store_package.json"
SCREENSHOT_DIR = ROOT / "screenshots" / "store"
EXPECTED_SCREENSHOTS = ("overview.png", "library.png", "favorites.png", "statistics.png")
EXPECTED_SCREENSHOT_SIZE = (1366, 768)
REQUIRED_CONFIG_FIELDS = {
    "app_name",
    "publisher",
    "publisher_display",
    "identity_name",
    "version",
    "description",
    "executable",
    "capabilities",
    "category",
    "age_rating",
    "privacy_url",
    "support_url",
}


def _read(path: Path) -> str:
    return path.read_text(encoding="utf-8")


def _png_size(path: Path) -> tuple[int, int] | None:
    try:
        header = path.read_bytes()[:24]
    except OSError:
        return None
    if header[:8] != b"\x89PNG\r\n\x1a\n" or header[12:16] != b"IHDR":
        return None
    return struct.unpack(">II", header[16:24])


def validate() -> list[str]:
    findings: list[str] = []
    if not CONFIG_PATH.is_file():
        return ["store_package.json fehlt."]

    try:
        config = json.loads(_read(CONFIG_PATH))
    except json.JSONDecodeError as exc:
        return [f"store_package.json ist kein valides JSON: {exc.msg}."]

    for field in sorted(REQUIRED_CONFIG_FIELDS):
        if not isinstance(config.get(field), str) or not config[field].strip():
            findings.append(f"Konfigurationsfeld fehlt oder ist leer: {field}.")

    for field in ("publisher", "publisher_display", "identity_name"):
        value = str(config.get(field, ""))
        if "your" in value.lower() or "placeholder" in value.lower():
            findings.append(f"Konfigurationsfeld enthält einen Platzhalter: {field}.")

    if not re.fullmatch(r"\d+\.\d+\.\d+\.\d+", str(config.get("version", ""))):
        findings.append("Store-Version muss vier numerische Teile enthalten.")

    for field in ("privacy_url", "support_url"):
        if not str(config.get(field, "")).startswith("https://"):
            findings.append(f"Konfigurationsfeld braucht eine HTTPS-URL: {field}.")

    for filename in ("STORE_LISTING.md", "SUPPORT.md"):
        path = ROOT / filename
        if not path.is_file():
            findings.append(f"Store-Dokument fehlt: {filename}.")
            continue
        text = _read(path)
        for heading in ("Deutsch", "English"):
            if heading not in text:
                findings.append(f"{filename} enthält keinen Abschnitt {heading}.")

    if "MIT" not in _read(ROOT / "LICENSE"):
        findings.append("LICENSE enthält keinen MIT-Hinweis.")
    if "PRIVACY_POLICY.md" not in _read(ROOT / "README.md"):
        findings.append("README.md verweist nicht auf PRIVACY_POLICY.md.")

    for filename in EXPECTED_SCREENSHOTS:
        path = SCREENSHOT_DIR / filename
        size = _png_size(path)
        if size is None:
            findings.append(f"Store-Screenshot fehlt oder ist kein PNG: {path.relative_to(ROOT)}.")
        elif size != EXPECTED_SCREENSHOT_SIZE:
            findings.append(
                f"Store-Screenshot hat nicht die erwartete Größe {EXPECTED_SCREENSHOT_SIZE}: "
                f"{path.relative_to(ROOT)} ({size})."
            )

    return findings


def main() -> int:
    findings = validate()
    if findings:
        print("STORE READINESS: BLOCKED")
        for finding in findings:
            print(f"- {finding}")
        return 1
    print("STORE READINESS: MATERIALS READY")
    print("External gates remain: Partner Center reservation, signed MSIX, WACK.")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
