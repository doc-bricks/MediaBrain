"""Validate repository-owned and external Windows Store readiness materials for MediaBrain.

Repository-owned materials are checked in ``project_root``. Build and review
evidence can be supplied explicitly via ``--evidence-root`` for full release gate validation.
"""

from __future__ import annotations

import argparse
import hashlib
import json
import re
import tomllib
import zipfile
from pathlib import Path
from typing import Sequence


REQUIRED_DOCUMENTS = (
    "PRIVACY_POLICY.md",
    "SUPPORT.md",
    "STORE_LISTING.md",
    "WINDOWS_STORE_PREP.md",
    "THIRD_PARTY_LICENSES.txt",
)

PASS_MARKERS = {
    "fulltrust-review.txt": "STATUS: PASS",
    "windows-tray-smoke.txt": "STATUS: PASS",
    "live-url-readback.txt": "STATUS: PASS",
    "msix-signature.txt": "SIGNATURE STATUS: PASS",
    "wack-report.txt": "OVERALL RESULT: PASS",
}

PNG_SIGNATURE = b"\x89PNG\r\n\x1a\n"

REQUIRED_TILE_ICONS = (
    "icon_44x44.png",
    "icon_50x50.png",
    "icon_150x150.png",
    "icon_310x150.png",
    "icon_310x310.png",
)


def _read_nonempty(path: Path) -> str | None:
    try:
        content = path.read_text(encoding="utf-8")
    except (OSError, UnicodeError):
        return None
    return content if content.strip() else None


def _load_json(path: Path) -> dict[str, object] | None:
    try:
        value = json.loads(path.read_text(encoding="utf-8"))
    except (OSError, UnicodeError, json.JSONDecodeError):
        return None
    return value if isinstance(value, dict) else None


def _project_version(project_root: Path) -> str | None:
    try:
        data = tomllib.loads((project_root / "pyproject.toml").read_text(encoding="utf-8"))
    except (OSError, UnicodeError, tomllib.TOMLDecodeError):
        pass
    else:
        project = data.get("project")
        if isinstance(project, dict):
            version = project.get("version")
            if isinstance(version, str) and version:
                return version

    # Fallback to version.py
    version_py = project_root / "version.py"
    if version_py.is_file():
        content = version_py.read_text(encoding="utf-8")
        match = re.search(r'__version__\s*=\s*["\']([^"\']+)["\']', content)
        if match:
            return match.group(1)

    return None


def _check_repository(project_root: Path) -> list[str]:
    findings: list[str] = []
    config_path = project_root / "store_package.json"
    config = _load_json(config_path)
    if config is None:
        findings.append("[repository] store_package.json is missing or invalid")
    else:
        for field in ("publisher", "publisher_display", "identity_name", "version", "executable"):
            if not isinstance(config.get(field), str) or not str(config[field]).strip():
                findings.append(f"[repository] store_package.json field {field!r} is missing")

        app_name = config.get("name") or config.get("app_name")
        if not isinstance(app_name, str) or not app_name.strip():
            findings.append("[repository] store_package.json name/app_name is missing")

        for field in ("publisher", "publisher_display", "identity_name"):
            value = str(config.get(field, ""))
            if "your" in value.lower() or "placeholder" in value.lower():
                findings.append(f"[repository] store_package.json contains placeholder: {field}")

        for field in ("privacy_url", "support_url"):
            value = config.get(field)
            if not isinstance(value, str) or not value.startswith("https://"):
                findings.append(
                    f"[repository] store_package.json field {field!r} needs an HTTPS URL"
                )

        capabilities = config.get("capabilities")
        if isinstance(capabilities, list):
            if "runFullTrust" not in capabilities:
                findings.append("[repository] store_package.json must declare runFullTrust")
        elif isinstance(capabilities, str):
            if "runFullTrust" not in capabilities and "internetClient" not in capabilities:
                findings.append("[repository] store_package.json must declare valid capabilities")
        else:
            findings.append("[repository] store_package.json capabilities missing or invalid")

        project_ver = _project_version(project_root)
        store_ver = str(config.get("version", ""))
        if not re.fullmatch(r"\d+\.\d+\.\d+\.\d+", store_ver):
            findings.append("[repository] store_package.json version must have 4 numeric parts")
        elif project_ver is not None and not store_ver.startswith(project_ver):
            findings.append(
                f"[repository] version mismatch: project={project_ver}, store={store_ver}"
            )

    manifests = sorted((project_root / "store_package").glob("**/AppxManifest.xml"))
    if not manifests:
        findings.append("[repository] AppxManifest.xml is missing below store_package")
    else:
        manifest = _read_nonempty(manifests[0])
        if manifest is None:
            findings.append("[repository] AppxManifest.xml is empty or unreadable")
        else:
            for token, label in (
                ("runFullTrust", "runFullTrust capability"),
                ("Executable=", "application executable"),
                ("Version=", "package version"),
                ("Identity Name=", "package identity name"),
                ("Square150x150Logo=", "Square150x150Logo"),
                ("Square44x44Logo=", "Square44x44Logo"),
            ):
                if token not in manifest:
                    findings.append(f"[repository] AppxManifest.xml lacks {label}")

    for name in REQUIRED_DOCUMENTS:
        doc_path = project_root / name
        content = _read_nonempty(doc_path)
        if content is None:
            findings.append(f"[repository] {name} is missing or empty")
        elif name in ("STORE_LISTING.md", "SUPPORT.md"):
            for heading in ("Deutsch", "English"):
                if heading not in content:
                    findings.append(f"[repository] {name} lacks heading {heading}")

    license_content = _read_nonempty(project_root / "LICENSE")
    if license_content is None or "MIT" not in license_content:
        findings.append("[repository] LICENSE is missing or does not mention MIT")

    readme_content = _read_nonempty(project_root / "README.md")
    if readme_content is None or "PRIVACY_POLICY.md" not in readme_content:
        findings.append("[repository] README.md does not reference PRIVACY_POLICY.md")

    # Check Store Listing keywords according to Policy 10.1.3 (max 7 per language)
    listing_content = _read_nonempty(project_root / "STORE_LISTING.md")
    if listing_content:
        de_match = re.search(r"\*\*Suchbegriffe\*\*\s*\n+([^\n#]+)", listing_content)
        if de_match:
            de_kw = [k.strip() for k in de_match.group(1).split(",") if k.strip()]
            if len(de_kw) > 7:
                findings.append(
                    f"[repository] STORE_LISTING.md German keywords exceed Policy 10.1.3 limit (max 7, found {len(de_kw)})"
                )
        en_match = re.search(r"\*\*Keywords\*\*\s*\n+([^\n#]+)", listing_content)
        if en_match:
            en_kw = [k.strip() for k in en_match.group(1).split(",") if k.strip()]
            if len(en_kw) > 7:
                findings.append(
                    f"[repository] STORE_LISTING.md English keywords exceed Policy 10.1.3 limit (max 7, found {len(en_kw)})"
                )

    # Verify tile icons across assets/icons, store_assets and store_package
    for icon_name in REQUIRED_TILE_ICONS:
        icon_path = project_root / "assets" / "icons" / icon_name
        if not icon_path.is_file():
            findings.append(f"[repository] tile icon missing in assets/icons: {icon_name}")
        store_icon_path = project_root / "store_assets" / icon_name
        if not store_icon_path.is_file():
            findings.append(f"[repository] tile icon missing in store_assets: {icon_name}")
        pkg_icon_path = project_root / "store_package" / "MediaBrain" / "icons" / icon_name
        if not pkg_icon_path.is_file():
            findings.append(f"[repository] tile icon missing in store_package/MediaBrain/icons: {icon_name}")

    # Check store screenshots
    screenshot_dirs = [
        project_root / "screenshots" / "store",
        project_root / "README" / "screenshots" / "store",
    ]
    screenshots = []
    for sdir in screenshot_dirs:
        if sdir.is_dir():
            for path in sdir.glob("*.png"):
                try:
                    if path.is_file() and path.read_bytes().startswith(PNG_SIGNATURE):
                        screenshots.append(path)
                except OSError:
                    continue

    if len(screenshots) < 3:
        findings.append(
            f"[repository] at least 3 valid PNG Store screenshots required; found {len(screenshots)}"
        )

    return findings


def _check_evidence(evidence_root: Path | None) -> list[str]:
    if evidence_root is None:
        return [
            "[external] evidence root was not supplied (Partner Center reservation, FullTrust review, "
            "Windows tray smoke, live URL readback, SBOM, signed MSIX/hash, and WACK PASS remain open)"
        ]
    if not evidence_root.is_dir():
        return [f"[external] evidence root does not exist: {evidence_root}"]

    findings: list[str] = []
    for name, marker in PASS_MARKERS.items():
        content = _read_nonempty(evidence_root / name)
        if content is None or marker not in content:
            findings.append(f"[external] {name} is missing or lacks {marker!r}")

    sbom = _load_json(evidence_root / "sbom.spdx.json")
    if (
        sbom is None
        or not str(sbom.get("spdxVersion", "")).startswith("SPDX-")
        or not isinstance(sbom.get("packages"), list)
        or not sbom["packages"]
    ):
        findings.append("[external] sbom.spdx.json is missing or lacks SPDX package data")

    packages = sorted(evidence_root.glob("*.msix"))
    if len(packages) != 1 or not zipfile.is_zipfile(packages[0]):
        findings.append(
            "[external] exactly one non-empty MSIX package with a ZIP header is required"
        )
    else:
        checksum_text = _read_nonempty(evidence_root / "SHA256SUMS.txt")
        digest = hashlib.sha256(packages[0].read_bytes()).hexdigest()
        expected = f"{digest}  {packages[0].name}"
        if checksum_text is None or expected not in checksum_text.splitlines():
            findings.append("[external] SHA256SUMS.txt does not verify the MSIX")

    return findings


def collect_findings(project_root: Path, evidence_root: Path | None = None) -> list[str]:
    """Return all blocking repository and external Store-readiness findings."""
    return _check_repository(project_root.resolve()) + _check_evidence(
        evidence_root.resolve() if evidence_root is not None else None
    )


def validate() -> list[str]:
    """Backward-compatibility wrapper for repository validation."""
    root = Path(__file__).resolve().parents[1]
    return _check_repository(root)


def _parser() -> argparse.ArgumentParser:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument(
        "--project-root",
        type=Path,
        default=Path(__file__).resolve().parents[1],
        help="MediaBrain source checkout (default: repository root)",
    )
    parser.add_argument(
        "--evidence-root",
        type=Path,
        help="External directory containing review, build, SBOM, hash, and WACK evidence",
    )
    return parser


def main(argv: Sequence[str] | None = None) -> int:
    args = _parser().parse_args(argv)
    findings = _check_repository(args.project_root)
    if findings:
        print("STORE READINESS: BLOCKED")
        for finding in findings:
            print(f"- {finding}")
        return 1

    if args.evidence_root is not None:
        external_findings = _check_evidence(args.evidence_root)
        if external_findings:
            print("STORE READINESS: BLOCKED (EXTERNAL EVIDENCE)")
            for finding in external_findings:
                print(f"- {finding}")
            return 1
        print("STORE READINESS: FULLY RELEASE READY")
        return 0

    print("STORE READINESS: METADATA & REPOSITORY STAGED")
    print("External gates remain: Partner Center reservation, signed MSIX, and WACK.")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
