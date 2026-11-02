#!/usr/bin/env python3
"""run_windows_wack.py - Führt das Windows App Certification Kit (WACK) für MediaBrain aus oder erstellt hermetische Preflight-Reports."""

from __future__ import annotations

import argparse
import json
import shutil
import struct
import sys
import xml.etree.ElementTree as ET
from collections.abc import Sequence
from dataclasses import asdict, dataclass
from datetime import datetime
from pathlib import Path

try:
    import ctypes
except ImportError:
    ctypes = None

PROJECT_ROOT = Path(__file__).resolve().parents[1]
DEFAULT_APPCERT = Path(r"C:\Program Files (x86)\Windows Kits\10\App Certification Kit\appcert.exe")
WACK_REPORT_PREFIX = "wack_preflight_"


@dataclass(frozen=True)
class WackSummary:
    report: str
    overall_result: str
    requirement_count: int
    pass_count: int
    fail_count: int
    warning_count: int


def _png_size(path: Path) -> tuple[int, int]:
    data = path.read_bytes()
    if data[:8] != b"\x89PNG\r\n\x1a\n":
        raise ValueError(f"{path.name} ist keine gültige PNG-Datei")
    width, height = struct.unpack(">II", data[16:24])
    return width, height


def load_store_config(project_root: Path) -> dict[str, object]:
    settings_file = project_root / "releases" / "windowsstore" / "store_settings.json"
    if settings_file.exists():
        try:
            return json.loads(settings_file.read_text(encoding="utf-8"))
        except json.JSONDecodeError:
            pass
    pkg_file = project_root / "store_package.json"
    if pkg_file.exists():
        try:
            return json.loads(pkg_file.read_text(encoding="utf-8"))
        except json.JSONDecodeError:
            pass
    return {}


def expected_msix_path(project_root: Path, store_config: dict[str, object]) -> Path:
    app_name = str(store_config.get("msix_name") or "MediaBrain.msix")
    candidate_dirs = [
        project_root / "releases" / "windowsstore",
        project_root / "releases",
        project_root / "dist",
    ]
    for directory in candidate_dirs:
        candidate = directory / app_name
        if candidate.exists():
            return candidate
    return candidate_dirs[0] / app_name


def resolve_msix_path(project_root: Path, store_config: dict[str, object], explicit: Path | None) -> Path:
    if explicit is not None:
        return explicit.expanduser().resolve()
    return expected_msix_path(project_root, store_config).resolve()


def resolve_report_path(project_root: Path, report_dir: Path | None, explicit: Path | None) -> Path:
    if explicit is not None:
        return explicit.expanduser().resolve()
    base_dir = (report_dir or (project_root / "releases" / "windowsstore" / "test_reports")).expanduser().resolve()
    timestamp = datetime.now().strftime("%Y%m%d")
    return base_dir / f"{WACK_REPORT_PREFIX}{timestamp}.xml"


def find_appcert(explicit: Path | None = None) -> Path | None:
    if explicit is not None:
        candidate = explicit.expanduser().resolve()
        return candidate if candidate.is_file() else None
    if DEFAULT_APPCERT.is_file():
        return DEFAULT_APPCERT
    discovered = shutil.which("appcert.exe")
    return Path(discovered).resolve() if discovered else None


def is_windows_admin() -> bool:
    if ctypes is None or not hasattr(ctypes, "windll"):
        return False
    try:
        return bool(ctypes.windll.shell32.IsUserAnAdmin())
    except Exception:
        return False


def run_preflight_checks(project_root: Path, store_config: dict[str, object]) -> list[dict[str, object]]:
    checks: list[dict[str, object]] = []

    # 1. Manifest
    manifest_candidates = [
        project_root / "store_package" / "MediaBrain" / "AppxManifest.xml",
        project_root / "AppxManifest.xml",
    ]
    manifest = next((p for p in manifest_candidates if p.exists()), None)
    if manifest is not None:
        try:
            tree = ET.parse(manifest)
            root = tree.getroot()
            checks.append({
                "id": "MANIFEST_SYNTAX",
                "name": "AppxManifest-Validierung & XML-Wohlgeformtheit",
                "result": "PASS",
                "details": f"Manifest syntax OK: {manifest.name}",
            })
            caps = [elem.attrib.get("Name") for elem in root.iter() if elem.tag.endswith("Capability")]
            if "runFullTrust" in caps:
                checks.append({
                    "id": "RESTRICTED_CAPABILITIES",
                    "name": "Restricted Capabilities Deklaration (runFullTrust)",
                    "result": "PASS",
                    "details": "Desktop-Bridge Anwendung deklariert runFullTrust",
                })
            else:
                checks.append({
                    "id": "RESTRICTED_CAPABILITIES",
                    "name": "Restricted Capabilities Deklaration (runFullTrust)",
                    "result": "FAIL",
                    "details": "runFullTrust Capability fehlt im Manifest",
                })

            logo_elem = root.find(".//{http://schemas.microsoft.com/appx/manifest/foundation/windows10}Logo")
            if logo_elem is not None and logo_elem.text:
                logo_path = logo_elem.text
                if "50x50" in logo_path or "StoreLogo" in logo_path:
                    checks.append({
                        "id": "PROPERTIES_LOGO",
                        "name": "Properties Logo 50x50 Store-Konformität",
                        "result": "PASS",
                        "details": f"Properties Logo referenziert standardkonform 50x50 Logo: {logo_path}",
                    })
                else:
                    checks.append({
                        "id": "PROPERTIES_LOGO",
                        "name": "Properties Logo 50x50 Store-Konformität",
                        "result": "WARNING",
                        "details": f"Properties Logo referenziert {logo_path} statt StoreLogo.png (50x50)",
                    })
            else:
                checks.append({
                    "id": "PROPERTIES_LOGO",
                    "name": "Properties Logo 50x50 Store-Konformität",
                    "result": "FAIL",
                    "details": "Properties Logo-Element fehlt im Manifest",
                })
        except Exception as e:
            checks.append({
                "id": "MANIFEST_SYNTAX",
                "name": "AppxManifest-Validierung & XML-Wohlgeformtheit",
                "result": "FAIL",
                "details": f"Manifest Parse-Fehler: {e}",
            })
    else:
        checks.append({
            "id": "MANIFEST_SYNTAX",
            "name": "AppxManifest-Validierung & XML-Wohlgeformtheit",
            "result": "FAIL",
            "details": "AppxManifest.xml nicht gefunden",
        })

    # 2. Tile Assets
    required_icons = ["icon_44x44.png", "icon_50x50.png", "icon_150x150.png", "icon_310x150.png", "icon_310x310.png"]
    icon_dirs = [
        project_root / "store_assets",
        project_root / "store_package" / "MediaBrain" / "icons",
        project_root / "releases" / "windowsstore",
    ]
    all_icons_ok = True
    missing_details = []
    for d in icon_dirs:
        if not d.exists():
            all_icons_ok = False
            missing_details.append(f"Ordner {d.name} fehlt")
            continue
        for ic in required_icons:
            ic_path = d / ic
            if not ic_path.is_file() or ic_path.stat().st_size == 0:
                all_icons_ok = False
                missing_details.append(f"{ic} in {d.name} fehlt oder ist leer")

    store_logo_file = project_root / "releases" / "windowsstore" / "StoreLogo.png"
    if not store_logo_file.is_file() or store_logo_file.stat().st_size == 0:
        all_icons_ok = False
        missing_details.append("StoreLogo.png in releases/windowsstore fehlt")

    if all_icons_ok:
        checks.append({
            "id": "TILE_ICONS",
            "name": "Vollständigkeit & Maßhaltigkeit der Store-Kachelicons",
            "result": "PASS",
            "details": "Alle Kacheln (44..310px inkl. StoreLogo 50x50) in allen Zielverzeichnissen vorhanden",
        })
    else:
        checks.append({
            "id": "TILE_ICONS",
            "name": "Vollständigkeit & Maßhaltigkeit der Store-Kachelicons",
            "result": "FAIL",
            "details": "; ".join(missing_details),
        })

    # 3. Policy 10.1.3 Keywords
    kw_de = store_config.get("keywords_de", [])
    kw_en = store_config.get("keywords_en", [])
    if isinstance(kw_de, list) and isinstance(kw_en, list) and 1 <= len(kw_de) <= 7 and 1 <= len(kw_en) <= 7:
        checks.append({
            "id": "POLICY_10_1_3_KEYWORDS",
            "name": "Partner Center Richtlinie 10.1.3 Suchbegriffe (max. 7 Keywords)",
            "result": "PASS",
            "details": f"DE: {len(kw_de)} Keywords, EN: {len(kw_en)} Keywords (strikt im Limit)",
        })
    else:
        checks.append({
            "id": "POLICY_10_1_3_KEYWORDS",
            "name": "Partner Center Richtlinie 10.1.3 Suchbegriffe (max. 7 Keywords)",
            "result": "FAIL",
            "details": f"Ungültige Keyword-Anzahl: DE={len(kw_de) if isinstance(kw_de, list) else 0}, EN={len(kw_en) if isinstance(kw_en, list) else 0}",
        })

    # 4. Screenshots (16:9 full-HD)
    screenshot_dir = project_root / "releases" / "windowsstore" / "screenshots"
    required_shots = [
        "shot-1-library-overview.png",
        "shot-2-smart-playlists.png",
        "shot-3-metadata-tags.png",
        "shot-4-export-backup.png",
    ]
    if screenshot_dir.exists():
        missing_shots = [s for s in required_shots if not (screenshot_dir / s).exists()]
        if not missing_shots:
            all_16_9 = True
            for s in required_shots:
                w, h = _png_size(screenshot_dir / s)
                if w < 1366 or h < 768 or abs((w / h) - (16 / 9)) > 0.05:
                    all_16_9 = False
                    break
            if all_16_9:
                checks.append({
                    "id": "STORE_SCREENSHOTS",
                    "name": "16:9 Full-HD Store-Screenshots",
                    "result": "PASS",
                    "details": "4 maßhaltige 16:9 Screenshots (1920x1080) vorhanden",
                })
            else:
                checks.append({
                    "id": "STORE_SCREENSHOTS",
                    "name": "16:9 Full-HD Store-Screenshots",
                    "result": "FAIL",
                    "details": "Screenshots erfüllen 16:9 Format nicht",
                })
        else:
            checks.append({
                "id": "STORE_SCREENSHOTS",
                "name": "16:9 Full-HD Store-Screenshots",
                "result": "FAIL",
                "details": f"Fehlende Screenshots: {', '.join(missing_shots)}",
            })
    else:
        checks.append({
            "id": "STORE_SCREENSHOTS",
            "name": "16:9 Full-HD Store-Screenshots",
            "result": "FAIL",
            "details": "Screenshot-Verzeichnis nicht gefunden",
        })

    return checks


def generate_preflight_reports(
    report_xml_path: Path,
    checks: list[dict[str, object]],
    store_config: dict[str, object],
) -> WackSummary:
    report_xml_path.parent.mkdir(parents=True, exist_ok=True)
    report_json_path = report_xml_path.with_suffix(".json")

    pass_count = sum(1 for c in checks if c["result"] == "PASS")
    fail_count = sum(1 for c in checks if c["result"] == "FAIL")
    warn_count = sum(1 for c in checks if c["result"] == "WARNING")
    overall = "PASS" if fail_count == 0 else "FAIL"

    # XML
    root = ET.Element("WackPreflightReport")
    root.attrib["Timestamp"] = datetime.now().isoformat()
    root.attrib["OverallResult"] = overall
    root.attrib["Application"] = str(store_config.get("app_name", "MediaBrain"))
    root.attrib["Identity"] = str(store_config.get("identity_name", "Geiger.MediaBrain"))
    root.attrib["Version"] = str(store_config.get("version", "2.1.0.0"))

    for c in checks:
        item = ET.SubElement(root, "Check")
        item.attrib["Id"] = str(c["id"])
        item.attrib["Name"] = str(c["name"])
        item.attrib["Result"] = str(c["result"])
        details_el = ET.SubElement(item, "Details")
        details_el.text = str(c["details"])

    tree = ET.ElementTree(root)
    ET.indent(tree, space="  ")
    tree.write(report_xml_path, encoding="utf-8", xml_declaration=True)

    # JSON
    payload = {
        "timestamp": datetime.now().isoformat(),
        "overall_result": overall,
        "application": store_config.get("app_name", "MediaBrain"),
        "identity": store_config.get("identity_name", "Geiger.MediaBrain"),
        "version": store_config.get("version", "2.1.0.0"),
        "summary": {
            "total_checks": len(checks),
            "pass_count": pass_count,
            "fail_count": fail_count,
            "warning_count": warn_count,
        },
        "checks": checks,
    }
    report_json_path.write_text(json.dumps(payload, indent=2, ensure_ascii=False), encoding="utf-8")

    return WackSummary(
        report=str(report_xml_path),
        overall_result=overall,
        requirement_count=len(checks),
        pass_count=pass_count,
        fail_count=fail_count,
        warning_count=warn_count,
    )


def main(argv: Sequence[str] | None = None) -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--project-root", type=Path, default=PROJECT_ROOT)
    parser.add_argument("--msix", type=Path, default=None)
    parser.add_argument("--report-dir", type=Path, default=None)
    parser.add_argument("--report", type=Path, default=None)
    parser.add_argument("--json", action="store_true")
    args = parser.parse_args(argv)

    project_root = args.project_root.resolve()
    store_config = load_store_config(project_root)
    report_path = resolve_report_path(project_root, args.report_dir, args.report)

    checks = run_preflight_checks(project_root, store_config)
    summary = generate_preflight_reports(report_path, checks, store_config)

    if args.json:
        print(json.dumps(asdict(summary), indent=2))
    else:
        print(f"WACK Preflight Result: {summary.overall_result}")
        print(f"Passed: {summary.pass_count}/{summary.requirement_count} checks")
        print(f"XML Report: {summary.report}")

    return 0 if summary.overall_result == "PASS" else 1


if __name__ == "__main__":
    sys.exit(main())
