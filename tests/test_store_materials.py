from __future__ import annotations

import json
import struct
import subprocess
import sys
from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]


def test_store_package_has_complete_non_placeholder_metadata() -> None:
    config = json.loads((ROOT / "store_package.json").read_text(encoding="utf-8"))

    assert config["app_name"] == "MediaBrain"
    assert config["publisher"].startswith("CN=")
    assert config["identity_name"] == "Geiger.MediaBrain"
    assert config["version"] == "2.0.0.0"
    assert config["executable"] == "MediaBrain.exe"
    assert config["capabilities"] == "internetClient"
    assert config["category"] == "Entertainment"
    assert config["privacy_url"].startswith("https://")
    assert config["support_url"].startswith("https://")
    assert "Your" not in " ".join(config.values())


def test_store_listing_and_support_are_bilingual_and_privacy_aligned() -> None:
    listing = (ROOT / "STORE_LISTING.md").read_text(encoding="utf-8")
    support = (ROOT / "SUPPORT.md").read_text(encoding="utf-8")

    assert "## Deutsch" in listing
    assert "## English" in listing
    assert "keine Telemetrie" in listing
    assert "no telemetry" in listing
    assert "## Deutsch" in support
    assert "## English" in support
    assert "SECURITY.md" in support


def test_store_readiness_preflight_reports_metadata_ready() -> None:
    result = subprocess.run(
        [sys.executable, "scripts/check_store_readiness.py"],
        cwd=ROOT,
        check=False,
        capture_output=True,
        text=True,
    )

    assert result.returncode == 0, result.stdout + result.stderr
    assert "STORE READINESS: MATERIALS READY" in result.stdout
    assert "Partner Center reservation" in result.stdout


def test_store_screenshot_generator_creates_redacted_complete_set(tmp_path: Path) -> None:
    output_dir = tmp_path / "screenshots"
    result = subprocess.run(
        [sys.executable, "scripts/generate_store_screenshots.py", "--output", str(output_dir)],
        cwd=ROOT,
        check=False,
        capture_output=True,
        text=True,
    )

    assert result.returncode == 0, result.stdout + result.stderr
    for filename in ("overview.png", "library.png", "favorites.png", "statistics.png"):
        header = (output_dir / filename).read_bytes()[:24]
        assert header[:8] == b"\x89PNG\r\n\x1a\n"
        assert struct.unpack(">II", header[16:24]) == (1366, 768)
