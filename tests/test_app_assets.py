from __future__ import annotations

from pathlib import Path
from PIL import Image


ROOT = Path(__file__).resolve().parents[1]
ASSETS = ROOT / "assets"
ICONS = ASSETS / "icons"
STORE_PKG_ICONS = ROOT / "store_package" / "MediaBrain" / "icons"
SCREENSHOTS_STORE = ROOT / "screenshots" / "store"
README_SCREENSHOTS_STORE = ROOT / "README" / "screenshots" / "store"


def test_master_app_icon_properties() -> None:
    icon_png = ASSETS / "icon.png"
    assert icon_png.is_file(), "Master icon.png must exist in assets/"

    with Image.open(icon_png) as img:
        assert img.format == "PNG"
        assert img.size == (512, 512)
        assert img.mode in ("RGB", "RGBA")


def test_multi_resolution_ico_files() -> None:
    for ico_name in ("MediaBrain.ico", "assets/app_icon.ico", "assets/icon.ico"):
        ico_path = ROOT / ico_name
        assert ico_path.is_file(), f"{ico_name} must exist"

        with Image.open(ico_path) as img:
            assert img.format == "ICO"
            # Verify that icon contains multiple standard sizes
            sizes = getattr(img, "ico", None)
            if sizes:
                width_list = [entry.width for entry in sizes.entry]
                assert 256 in width_list
                assert 128 in width_list
                assert 64 in width_list
                assert 32 in width_list
                assert 16 in width_list


def test_store_tile_icons_exist_in_assets_and_package() -> None:
    expected_sizes = {
        "icon_44x44.png": (44, 44),
        "icon_50x50.png": (50, 50),
        "icon_150x150.png": (150, 150),
        "icon_310x150.png": (310, 150),
        "icon_310x310.png": (310, 310),
    }

    for dir_path in (ICONS, STORE_PKG_ICONS):
        assert dir_path.is_dir(), f"{dir_path} must exist"
        for icon_name, expected_size in expected_sizes.items():
            icon_file = dir_path / icon_name
            assert icon_file.is_file(), f"{icon_name} must exist in {dir_path}"
            with Image.open(icon_file) as img:
                assert img.format == "PNG"
                assert img.size == expected_size


def test_store_screenshots_exist_and_are_valid() -> None:
    expected_shots = [
        "shot-1-library-overview.png",
        "shot-2-smart-playlists.png",
        "shot-3-metadata-tags.png",
        "shot-4-export-backup.png",
    ]

    for sdir in (SCREENSHOTS_STORE, README_SCREENSHOTS_STORE):
        assert sdir.is_dir(), f"{sdir} must exist"
        for shot_name in expected_shots:
            shot_path = sdir / shot_name
            assert shot_path.is_file(), f"{shot_name} must exist in {sdir}"
            with Image.open(shot_path) as img:
                assert img.format == "PNG"
                assert img.size == (1920, 1080)
                assert img.mode in ("RGB", "RGBA")
