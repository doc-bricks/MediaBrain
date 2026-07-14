from __future__ import annotations

import json
from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]


def test_license_inventory_covers_direct_manifests() -> None:
    inventory = (ROOT / "THIRD_PARTY_LICENSES.txt").read_text(encoding="utf-8")
    requirements = (ROOT / "requirements.txt").read_text(encoding="utf-8")
    package = json.loads((ROOT / "web_companion" / "package.json").read_text(encoding="utf-8"))

    for package_name in ["PySide6", "requests", "beautifulsoup4", "pytest", "pytest-cov", "black", "mypy"]:
        assert package_name in requirements
        assert package_name in inventory

    direct_web_deps = set(package["dependencies"]) | set(package["devDependencies"])
    missing = sorted(dep for dep in direct_web_deps if dep not in inventory)
    assert missing == []


def test_release_docs_link_license_inventory() -> None:
    inventory = (ROOT / "THIRD_PARTY_LICENSES.txt").read_text(encoding="utf-8")
    readme_en = (ROOT / "README.md").read_text(encoding="utf-8")
    readme_de = (ROOT / "README_de.md").read_text(encoding="utf-8")
    changelog = (ROOT / "CHANGELOG.md").read_text(encoding="utf-8")

    assert "not a full transitive SBOM" in inventory
    assert "THIRD_PARTY_LICENSES.txt" in readme_en
    assert "THIRD_PARTY_LICENSES.txt" in readme_de
    assert "THIRD_PARTY_LICENSES.txt" in changelog
