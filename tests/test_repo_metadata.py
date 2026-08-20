"""Tests for repository metadata, version parity, badges, and documentation consistency."""

import json
import re
import xml.etree.ElementTree as ET
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent


def test_version_parity_across_manifests_and_docs():
    """Verify version in version.py matches pyproject.toml, store_package.json, AppxManifest.xml, and docs."""
    from version import __version__

    assert __version__ == "2.1.0"

    # pyproject.toml
    pyproject_text = (ROOT / "pyproject.toml").read_text(encoding="utf-8")
    assert f'version = "{__version__}"' in pyproject_text

    # store_package.json
    store_pkg = json.loads((ROOT / "store_package.json").read_text(encoding="utf-8"))
    assert store_pkg["version"].startswith(__version__)

    # AppxManifest.xml
    manifest_path = ROOT / "store_package" / "MediaBrain" / "AppxManifest.xml"
    assert manifest_path.exists()
    tree = ET.parse(manifest_path)
    identity = tree.getroot().find("{http://schemas.microsoft.com/appx/manifest/foundation/windows10}Identity")
    assert identity is not None
    assert identity.get("Version", "").startswith(__version__)

    # README.md and README_de.md
    readme_en = (ROOT / "README.md").read_text(encoding="utf-8")
    readme_de = (ROOT / "README_de.md").read_text(encoding="utf-8")
    assert f"version-{__version__}" in readme_en or f"Version-{__version__}" in readme_en
    assert f"version-{__version__}" in readme_de or f"Version-{__version__}" in readme_de


def test_badges_and_ecosystem_parity():
    """Verify badges in README.md and README_de.md contain expected URLs and links."""
    readme_en = (ROOT / "README.md").read_text(encoding="utf-8")
    readme_de = (ROOT / "README_de.md").read_text(encoding="utf-8")

    for doc in (readme_en, readme_de):
        assert "doc--bricks" in doc and ("ecosystem" in doc or "%C3%96kosystem" in doc or "Ökosystem" in doc)
        assert "open--bricks" in doc and ("umbrella" in doc or "Dachprojekt" in doc)
        assert "https://github.com/doc-bricks" in doc
        assert "https://github.com/open-bricks" in doc
        assert "llms.txt" in doc


def test_llms_txt_structure_and_parity():
    """Verify llms.txt is up to date with repository structure and search phrases."""
    llms_txt = (ROOT / "llms.txt").read_text(encoding="utf-8")

    assert "https://github.com/doc-bricks/MediaBrain" in llms_txt
    assert "Last-checked: 2026-08-20" in llms_txt
    assert "PySide6" in llms_txt
    assert "SQLite" in llms_txt
    assert "Boundaries" in llms_txt
