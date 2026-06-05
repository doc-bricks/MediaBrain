"""
Regression tests for BlacklistView.refresh() in gui.py.

Bug: In BlacklistView.refresh(), the variable `expiry` is only assigned in
the `if item.blacklisted_at:` branch. In the `else` branch only `expired`
is set. When the first blacklisted item has blacklisted_at = NULL,
`expiry` is undefined and the call to _create_blacklist_widget(item, expired, expiry)
raises NameError: name 'expiry' is not defined.

list_blacklisted() queries WHERE blacklist_flag = 1 without filtering for
blacklisted_at IS NOT NULL, so NULL values can reach the loop.
"""

import os
import sys
import tempfile
import unittest
from pathlib import Path

os.environ.setdefault("QT_QPA_PLATFORM", "offscreen")

sys.path.insert(0, str(Path(__file__).parent.parent))

from PySide6.QtWidgets import QApplication

from core import Database, MediaManager, BlacklistManager

_app = QApplication.instance() or QApplication(sys.argv)


class TestBlacklistViewRefreshNullDate(unittest.TestCase):
    """Regression: NameError when first blacklisted item has blacklisted_at = NULL."""

    def setUp(self):
        self.db_fd, self.db_path = tempfile.mkstemp(suffix=".db")
        self.db = Database(self.db_path)
        self.media_manager = MediaManager(self.db)
        self.blacklist_manager = BlacklistManager(self.db)

        self.media_id = self.db.execute(
            "INSERT INTO media_items (title, type, source, provider_id) "
            "VALUES ('Test', 'movie', 'local', 'test-1')"
        ).lastrowid

        # Blacklist item without blacklisted_at (simulates missing date)
        self.db.execute(
            "UPDATE media_items SET blacklist_flag = 1, procedure_code = 1 WHERE id = ?",
            (self.media_id,),
        )

    def tearDown(self):
        import os as _os
        self.db.close()
        _os.close(self.db_fd)
        _os.unlink(self.db_path)

    def test_refresh_does_not_crash_when_blacklisted_at_is_null(self):
        """refresh() must not raise NameError when blacklisted_at is NULL.

        Without the fix, `expiry` is never assigned in the else-branch.
        _create_blacklist_widget(item, expired, expiry) then raises
        NameError: name 'expiry' is not defined.
        """
        from gui import BlacklistView

        view = BlacklistView(self.media_manager, self.blacklist_manager)
        try:
            view.refresh()
        except NameError as e:
            self.fail(f"refresh() raised NameError: {e}")
        finally:
            view.close()
            view.deleteLater()
            _app.processEvents()


if __name__ == "__main__":
    unittest.main()
