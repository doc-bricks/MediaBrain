# -*- mode: python ; coding: utf-8 -*-
"""PyInstaller spec file for MediaBrain.

Build:
    pyinstaller MediaBrain.spec

Output:
    dist/MediaBrain/MediaBrain.exe (onedir mode for faster startup)
"""

import os
import sys

block_cipher = None

a = Analysis(
    ['MediaBrain.py'],
    pathex=[],
    binaries=[],
    datas=[
        ('locales', 'locales'),
        ('MediaBrain.ico', '.') if os.path.exists('MediaBrain.ico') else ('', ''),
        ('assets', 'assets') if os.path.exists('assets') else ('', ''),
    ],
    hiddenimports=[
        'sqlite3',
        'PySide6.QtWidgets',
        'PySide6.QtCore',
        'PySide6.QtGui',
        'requests',
    ],
    hookspath=[],
    hooksconfig={},
    runtime_hooks=[],
    excludes=[
        'tkinter', 'matplotlib', 'numpy', 'pandas',
        'PIL', 'cv2', 'scipy',
    ],
    win_no_prefer_redirects=False,
    win_private_assemblies=False,
    cipher=block_cipher,
    noarchive=False,
)

# Filter leere Eintraege
a.datas = [(d, s, t) for d, s, t in a.datas if s]

pyz = PYZ(a.pure, a.zipped_data, cipher=block_cipher)

exe = EXE(
    pyz,
    a.scripts,
    [],
    exclude_binaries=True,
    name='MediaBrain',
    debug=False,
    bootloader_ignore_signals=False,
    strip=False,
    upx=False,
    console=False,
    disable_windowed_traceback=False,
    argv_emulation=False,
    target_arch=None,
    codesign_identity=None,
    entitlements_file=None,
    icon='MediaBrain.ico' if os.path.exists('MediaBrain.ico') else None,
)

coll = COLLECT(
    exe,
    a.binaries,
    a.zipfiles,
    a.datas,
    strip=False,
    upx=False,
    upx_exclude=[],
    name='MediaBrain',
)
