# -*- coding: utf-8 -*-
"""Regressionstests Bugfix-Library-Transfer Batch #25 — REL-PUB_MediaBrain.

D1: QMenu() ohne Parent ist GC-Risiko — muss QMenu(self) sein.
U2: json.load/json.loads ohne JSONDecodeError-Handler.
"""

import py_compile
import unittest
from pathlib import Path

PROJ = Path(__file__).parent.parent


class TestD1QMenuParent(unittest.TestCase):
    def test_no_bare_qmenu_in_gui(self):
        src = (PROJ / "gui.py").read_text(encoding="utf-8")
        self.assertNotIn("tray_menu = QMenu()", src,
                         "tray_menu = QMenu() ohne Parent ist GC-Risiko")


class TestU2JsonDecodeError(unittest.TestCase):
    def test_config_read_json_has_handler(self):
        src = (PROJ / "config.py").read_text(encoding="utf-8")
        self.assertIn("json.JSONDecodeError", src,
                      "_read_json in config.py braucht JSONDecodeError-Handler")

    def test_manage_translations_has_handler(self):
        src = (PROJ / "manage_translations.py").read_text(encoding="utf-8")
        self.assertIn("json.JSONDecodeError", src,
                      "json.load in manage_translations.py braucht JSONDecodeError-Handler")

    def test_metadata_v2_cache_get_has_handler(self):
        src = (PROJ / "metadata_v2.py").read_text(encoding="utf-8")
        self.assertGreaterEqual(src.count("json.JSONDecodeError"), 2,
                                "metadata_v2.py json.loads in get() braucht eigenen JSONDecodeError-Handler")


class TestSyntaxValidity(unittest.TestCase):
    def test_syntax_valid(self):
        for name in ("gui.py", "config.py", "manage_translations.py", "metadata_v2.py"):
            py_compile.compile(str(PROJ / name), doraise=True)


if __name__ == "__main__":
    unittest.main()
