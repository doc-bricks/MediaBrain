from __future__ import annotations

import json
import subprocess
import sys
from pathlib import Path
import xml.etree.ElementTree as ET


ROOT = Path(__file__).resolve().parents[1]
EXPECTED_LANGUAGES = ("de-DE", "en-US", "es-ES", "zh-CN", "ja-JP", "ru-RU")
BANNED_TRADEMARKS = {"windows", "microsoft", "google", "apple", "netflix", "spotify", "youtube", "adobe"}


def test_store_package_has_complete_non_placeholder_metadata() -> None:
    config = json.loads((ROOT / "store_package.json").read_text(encoding="utf-8"))

    assert config.get("name") == "MediaBrain" or config.get("app_name") == "MediaBrain"
    assert config["publisher"].startswith("CN=")
    assert config["identity_name"] == "Geiger.MediaBrain"
    assert config["version"] == "2.1.0.0"
    assert config["executable"] == "MediaBrain.exe"
    assert "runFullTrust" in config["capabilities"]
    assert config["category"] == "Entertainment"
    assert config["privacy_url"].startswith("https://")
    assert config["support_url"].startswith("https://")

    # Flatten config values to string for placeholder checks
    values_str = " ".join(str(v) for v in config.values())
    assert "your" not in values_str.lower()
    assert "placeholder" not in values_str.lower()

    # Tier-2 6-Sprachen-Harmonisierung nach Policy P-006
    languages = config.get("languages", [])
    for lang in EXPECTED_LANGUAGES:
        assert lang in languages, f"Missing language {lang} in store_package.json"

    for code in ("de", "en", "es", "zh", "ja", "ru"):
        desc_key = f"description_{code}"
        assert desc_key in config, f"Missing {desc_key} in store_package.json"
        assert 1 <= len(config[desc_key]) <= 100, f"{desc_key} length out of bounds (1..100): {len(config[desc_key])}"

        kw_key = f"keywords_{code}"
        assert kw_key in config, f"Missing {kw_key} in store_package.json"
        kws = config[kw_key]
        assert len(kws) == 7, f"{kw_key} must contain exactly 7 keywords (found {len(kws)})"
        for kw in kws:
            assert 1 <= len(kw) <= 30, f"Keyword '{kw}' in {kw_key} exceeds 30 chars ({len(kw)})"
            assert kw.lower() not in BANNED_TRADEMARKS, f"Keyword '{kw}' violates trademark policy"


def test_store_manifest_is_valid_xml_and_has_required_elements() -> None:
    manifest_path = ROOT / "store_package" / "MediaBrain" / "AppxManifest.xml"
    assert manifest_path.is_file(), "AppxManifest.xml must exist in store_package/MediaBrain/"

    tree = ET.parse(manifest_path)
    root = tree.getroot()

    # Check namespace
    assert "foundation/windows10" in root.tag

    # Check Identity
    identity = root.find("{http://schemas.microsoft.com/appx/manifest/foundation/windows10}Identity")
    assert identity is not None
    assert identity.get("Name") == "Geiger.MediaBrain"
    assert identity.get("Publisher") == "CN=52596601-BAB4-4F3F-B182-E8F3F273B202"
    assert identity.get("Version") == "2.1.0.0"

    # Check Capabilities
    manifest_text = manifest_path.read_text(encoding="utf-8")
    assert "runFullTrust" in manifest_text
    assert "MediaBrain.exe" in manifest_text

    # Check Tier-2 6 language resources
    for res_code in ("de-de", "en-us", "es-es", "zh-cn", "ja-jp", "ru-ru"):
        assert f'Language="{res_code}"' in manifest_text, f"AppxManifest lacks resource {res_code}"


def test_store_listing_and_support_are_multilingual_and_privacy_aligned() -> None:
    listing = (ROOT / "STORE_LISTING.md").read_text(encoding="utf-8")
    support = (ROOT / "SUPPORT.md").read_text(encoding="utf-8")

    for heading in ("## Deutsch", "## English", "## Español", "## 简体中文", "## 日本語", "## Русский"):
        assert heading in listing, f"STORE_LISTING.md lacks heading {heading}"

    assert "keine Telemetrie" in listing or "kein Tracking" in listing
    assert "no telemetry" in listing or "no tracking" in listing
    assert "## Deutsch" in support
    assert "## English" in support
    assert "SECURITY.md" in support


def test_store_readiness_reports_repository_staged() -> None:
    result = subprocess.run(
        [sys.executable, "scripts/check_store_readiness.py"],
        cwd=ROOT,
        check=False,
        capture_output=True,
        text=True,
    )

    assert result.returncode == 0, result.stdout + result.stderr
    assert "STORE READINESS: METADATA & REPOSITORY STAGED" in result.stdout
    assert "Partner Center reservation" in result.stdout


def test_store_listing_keywords_adhere_to_policy_10_1_3() -> None:
    listing = (ROOT / "STORE_LISTING.md").read_text(encoding="utf-8")

    import re
    de_match = re.search(r"\*\*Suchbegriffe\*\*\s*\n+([^\n#]+)", listing)
    assert de_match is not None, "German keywords section missing"
    de_keywords = [k.strip() for k in de_match.group(1).split(",") if k.strip()]
    assert 1 <= len(de_keywords) <= 7, f"German keywords must be 1-7 (found {len(de_keywords)})"

    en_match = re.search(r"\*\*Keywords\*\*\s*\n+([^\n#]+)", listing)
    assert en_match is not None, "English keywords section missing"
    en_keywords = [k.strip() for k in en_match.group(1).split(",") if k.strip()]
    assert 1 <= len(en_keywords) <= 7, f"English keywords must be 1-7 (found {len(en_keywords)})"

    es_match = re.search(r"\*\*Palabras clave\*\*\s*\n+([^\n#]+)", listing)
    assert es_match is not None, "Spanish keywords section missing"
    es_keywords = [k.strip() for k in es_match.group(1).split(",") if k.strip()]
    assert 1 <= len(es_keywords) <= 7, f"Spanish keywords must be 1-7 (found {len(es_keywords)})"

    zh_match = re.search(r"\*\*搜索关键词\*\*\s*\n+([^\n#]+)", listing)
    assert zh_match is not None, "Chinese keywords section missing"
    zh_keywords = [k.strip() for k in zh_match.group(1).split(",") if k.strip()]
    assert 1 <= len(zh_keywords) <= 7, f"Chinese keywords must be 1-7 (found {len(zh_keywords)})"

    ja_match = re.search(r"\*\*検索キーワード\*\*\s*\n+([^\n#]+)", listing)
    assert ja_match is not None, "Japanese keywords section missing"
    ja_keywords = [k.strip() for k in ja_match.group(1).split(",") if k.strip()]
    assert 1 <= len(ja_keywords) <= 7, f"Japanese keywords must be 1-7 (found {len(ja_keywords)})"

    ru_match = re.search(r"\*\*Ключевые слова\*\*\s*\n+([^\n#]+)", listing)
    assert ru_match is not None, "Russian keywords section missing"
    ru_keywords = [k.strip() for k in ru_match.group(1).split(",") if k.strip()]
    assert 1 <= len(ru_keywords) <= 7, f"Russian keywords must be 1-7 (found {len(ru_keywords)})"


def test_windows_store_prep_matches_metadata_and_policy() -> None:
    prep_path = ROOT / "WINDOWS_STORE_PREP.md"
    assert prep_path.is_file(), "WINDOWS_STORE_PREP.md must exist"
    prep_text = prep_path.read_text(encoding="utf-8")

    config = json.loads((ROOT / "store_package.json").read_text(encoding="utf-8"))
    assert config["identity_name"] in prep_text
    assert config["publisher"] in prep_text
    assert config["version"] in prep_text
    assert "Policy 10.1.3" in prep_text
    assert "WACK" in prep_text


def test_tile_icons_present_in_all_store_locations() -> None:
    required_icons = (
        "icon_44x44.png",
        "icon_50x50.png",
        "icon_150x150.png",
        "icon_310x150.png",
        "icon_310x310.png",
        "StoreLogo.png",
    )
    for loc in (
        ROOT / "assets" / "icons",
        ROOT / "store_assets",
        ROOT / "store_package" / "MediaBrain" / "icons",
        ROOT / "releases" / "windowsstore",
    ):
        assert loc.is_dir(), f"Icon folder {loc} must exist"
        for icon_name in required_icons:
            icon_file = loc / icon_name
            assert icon_file.is_file(), f"Icon {icon_name} missing in {loc}"
            assert icon_file.stat().st_size > 0, f"Icon {icon_name} in {loc} is empty"


def test_multilingual_character_integrity_in_store_materials() -> None:
    listing = (ROOT / "STORE_LISTING.md").read_text(encoding="utf-8")
    prep = (ROOT / "WINDOWS_STORE_PREP.md").read_text(encoding="utf-8")
    pkg = (ROOT / "store_package.json").read_text(encoding="utf-8")

    # German umlauts
    assert any(c in listing for c in "äöüÄÖÜß")
    assert any(c in prep for c in "äöüÄÖÜß")
    assert any(c in pkg for c in "äöüÄÖÜß")

    # Spanish accents / inverted characters
    assert any(c in listing for c in "áéíóúñÁÉÍÓÚÑ")
    assert any(c in pkg for c in "áéíóúñÁÉÍÓÚÑ")

    # Chinese characters
    assert any("一" <= c <= "鿿" for c in listing)
    assert any("一" <= c <= "鿿" for c in pkg)

    # Japanese kana
    assert any("぀" <= c <= "ヿ" for c in listing)
    assert any("぀" <= c <= "ヿ" for c in pkg)

    # Russian Cyrillic
    assert any("Ѐ" <= c <= "ӿ" for c in listing)
    assert any("Ѐ" <= c <= "ӿ" for c in pkg)


def test_windows_store_staging_completeness() -> None:
    staging = ROOT / "releases" / "windowsstore"
    assert staging.is_dir(), "releases/windowsstore must exist"
    assert (staging / "store_settings.json").is_file()
    assert (staging / "BUILD.md").is_file()
    assert (staging / "WACK_PROTOCOL.md").is_file()
    assert (staging / "StoreLogo.png").is_file()

    # All 6 store listings in staging
    for code in ("de", "en", "es", "zh", "ja", "ru"):
        lf = staging / f"store_listing_{code}.md"
        assert lf.is_file(), f"Staging file store_listing_{code}.md missing"
        assert lf.stat().st_size >= 100, f"Staging file store_listing_{code}.md too small"

    # Store settings has 6 descriptions and 6 keywords
    settings = json.loads((staging / "store_settings.json").read_text(encoding="utf-8"))
    for code in ("de", "en", "es", "zh", "ja", "ru"):
        assert f"description_{code}" in settings
        assert f"keywords_{code}" in settings
        assert len(settings[f"keywords_{code}"]) == 7

    shots_dir = staging / "screenshots"
    assert shots_dir.is_dir()
    expected_shots = [
        "shot-1-library-overview.png",
        "shot-2-smart-playlists.png",
        "shot-3-metadata-tags.png",
        "shot-4-export-backup.png",
    ]
    for s in expected_shots:
        assert (shots_dir / s).is_file(), f"Screenshot {s} missing in staging"


def test_run_windows_wack_preflight_passes() -> None:
    wack_script = ROOT / "scripts" / "run_windows_wack.py"
    assert wack_script.is_file(), "run_windows_wack.py must exist"

    result = subprocess.run(
        [sys.executable, str(wack_script), "--json"],
        cwd=ROOT,
        check=False,
        capture_output=True,
        text=True,
    )
    assert result.returncode == 0, result.stdout + result.stderr
    data = json.loads(result.stdout)
    assert data["overall_result"] == "PASS"
    assert data["fail_count"] == 0
    assert data["pass_count"] >= 6
