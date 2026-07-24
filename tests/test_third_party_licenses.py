from __future__ import annotations

from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]


def test_license_inventory_covers_direct_manifests() -> None:
    inventory = (ROOT / "THIRD_PARTY_LICENSES.txt").read_text(encoding="utf-8")
    requirements = (ROOT / "requirements.txt").read_text(encoding="utf-8")

    for package_name in ["PySide6", "requests", "beautifulsoup4", "pytest", "pytest-cov", "black", "mypy"]:
        assert package_name in requirements
        assert package_name in inventory


def test_license_inventory_has_no_web_companion_scope() -> None:
    """Der Web/PWA-Companion wurde am 2026-07-23 zurueckgezogen (kein Nutzer-Usecase).

    Das Lizenzinventar darf ihn daher nicht mehr als ausgelieferten Strang fuehren.
    """
    inventory = (ROOT / "THIRD_PARTY_LICENSES.txt").read_text(encoding="utf-8")

    assert "web_companion" not in inventory
    assert not (ROOT / "web_companion").exists()


def test_release_docs_link_license_inventory() -> None:
    inventory = (ROOT / "THIRD_PARTY_LICENSES.txt").read_text(encoding="utf-8")
    readme_en = (ROOT / "README.md").read_text(encoding="utf-8")
    readme_de = (ROOT / "README_de.md").read_text(encoding="utf-8")
    changelog = (ROOT / "CHANGELOG.md").read_text(encoding="utf-8")

    assert "not a full transitive SBOM" in inventory
    assert "THIRD_PARTY_LICENSES.txt" in readme_en
    assert "THIRD_PARTY_LICENSES.txt" in readme_de
    assert "THIRD_PARTY_LICENSES.txt" in changelog
