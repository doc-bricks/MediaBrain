
import logging

from config import DATA_DIR

# Logs liegen im beschreibbaren Datenordner (im gebauten Programm %LOCALAPPDATA%\MediaBrain),
# nie im Programmordner: unter MSIX (WindowsApps) ist der schreibgeschützt (BZ-MB-01).
LOG_DIR = DATA_DIR / "logs"
LOG_FILE = LOG_DIR / "mediabrain.log"

def setup_logger(name="MediaBrain"):
    logger = logging.getLogger(name)
    logger.setLevel(logging.DEBUG)

    # Verhindern, dass Handler mehrfach hinzugefügt werden (Singleton-ish)
    if logger.handlers:
        return logger

    # Formatter
    formatter = logging.Formatter('%(asctime)s - %(name)s - %(levelname)s - %(message)s')

    # File Handler; ein nicht beschreibbarer Log-Ordner darf den Programmstart nicht verhindern
    try:
        LOG_DIR.mkdir(parents=True, exist_ok=True)
        file_handler = logging.FileHandler(LOG_FILE, encoding="utf-8")
    except OSError:
        file_handler = None
    if file_handler is not None:
        file_handler.setLevel(logging.DEBUG)
        file_handler.setFormatter(formatter)
        logger.addHandler(file_handler)

    # Console Handler
    console_handler = logging.StreamHandler()
    console_handler.setLevel(logging.INFO)
    console_handler.setFormatter(formatter)
    logger.addHandler(console_handler)

    return logger

# Globale Instanz für einfachen Zugriff
logger = setup_logger()
