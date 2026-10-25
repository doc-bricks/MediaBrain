<img src="assets/banner.png" width="100%" alt="Banner de MediaBrain">

# MediaBrain

[![Versión: 2.1.0](https://img.shields.io/badge/version-2.1.0-orange.svg)](version.py)
[![Licencia: MIT](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)
[![Python 3.10+](https://img.shields.io/badge/python-3.10+-blue.svg)](https://www.python.org/)
[![Plataforma: Windows](https://img.shields.io/badge/platform-Windows-lightgrey.svg)]()
[![Prioridad sin conexión: sí](https://img.shields.io/badge/offline--first-yes-brightgreen.svg)]()
[![Pruebas: 274 aprobadas](https://img.shields.io/badge/tests-274%20passed-brightgreen.svg)]()
[![doc-bricks](https://img.shields.io/badge/doc--bricks-ecosystem-blue.svg)](https://github.com/doc-bricks)
[![open-bricks](https://img.shields.io/badge/open--bricks-umbrella-purple.svg)](https://github.com/open-bricks)
[![Contexto LLM](https://img.shields.io/badge/LLM--Context-llms.txt-blue.svg)](llms.txt)

> **MediaBrain es un gestor de bibliotecas multimedia basado en PySide6 que prioriza el almacenamiento local y permite organizar colecciones personales de vídeo y música, listas de reproducción e historial de visualización en servicios de streaming.**

> [!NOTE]
> **Contexto para IA y agentes**: La arquitectura del repositorio, los índices de archivos, las frases de búsqueda y los límites del sistema están documentados en [llms.txt](llms.txt).

[English](README.md) | [Deutsch](README_de.md) | **Español** | [Privacidad](PRIVACY_POLICY.md) | [Contribuir](CONTRIBUTING.md) | [Registro de cambios](CHANGELOG.md)

![Ventana principal de MediaBrain](README/screenshots/main.png)

## Idiomas de la documentación

| Idioma | Documento |
|---|---|
| Inglés | [README.md](README.md) |
| Alemán | [README_de.md](README_de.md) |
| Español | [README_es.md](README_es.md) |

Esta lista se refiere únicamente a las versiones documentales del README.

## Primeros pasos

| Necesidad | Ir a |
|---|---|
| Ejecutar la aplicación de escritorio | `python MediaBrain.py` |
| Consultar la versión móvil de Flutter | `flutter_port/README.md` |
| Revisar los límites de privacidad | [`PRIVACY_POLICY.md`](PRIVACY_POLICY.md) |
| Entender la arquitectura | [`ARCH.md`](ARCH.md) |
| Consultar el trabajo planificado | [`ROADMAP.md`](ROADMAP.md) |
| Obtener el contexto legible por máquinas | [`llms.txt`](llms.txt) |

## Por qué MediaBrain

MediaBrain está pensado para quienes quieren tener en un mismo lugar local los medios que ven, recopilan, etiquetan, bloquean u organizan entre servicios y archivos locales. No es un servicio de streaming alojado y no sube una biblioteca privada a una cuenta en la nube.

- Almacenamiento SQLite local para entradas multimedia, favoritos, etiquetas, elementos de la lista de bloqueo y listas de reproducción
- Interfaz de escritorio PySide6 con panel, bibliotecas, búsqueda, estadísticas, ajustes y temas de alto contraste
- Capa de proveedores para Netflix, YouTube, Spotify, Disney+, Prime Video, Apple TV+, Twitch y archivos locales
- Listas de reproducción manuales e inteligentes basadas en reglas de QueryBuilder
- Consulta opcional de metadatos mediante claves de API TMDb/OMDb configuradas por el usuario o datos públicos de MusicBrainz
- Sin telemetría, seguimiento ni sincronización automática con la nube

## Contexto de búsqueda

Este repositorio es el hogar canónico en GitHub para:

- `doc-bricks MediaBrain`
- `MediaBrain media library manager`
- `private SQLite media library manager`
- `local-first PySide6 media manager`
- `PySide6 smart playlist media manager`
- `offline media hub with smart playlists`
- `desktop media history tracker`
- `privacy-first media history desktop app`

El nombre “MediaBrain” coincide con empresas de análisis de medios, laboratorios de IA aplicada a medios y herramientas genéricas de planificación de medios. Este repositorio corresponde específicamente al gestor local de bibliotecas multimedia de escritorio `doc-bricks/MediaBrain`; no es una plataforma de analítica publicitaria en la nube, un laboratorio de investigación multimedia ni un generador de medios con IA.

## Arquitectura

```text
Core Layer        Database, MediaManager, BlacklistManager, TagManager, PlaylistManager
Query Layer       QueryBuilder for advanced filters and smart playlists
Provider Layer    Netflix, YouTube, Spotify, Disney+, Prime, AppleTV+, Twitch, Local
Background Layer  FileIndexer, WindowWatcher
GUI Layer         Dashboard, Libraries, Favorites, Blacklist, Playlists, Search, Stats, Settings
```

Diagrama completo: [`ARCH.md`](ARCH.md)

## Ecosistema y herramientas relacionadas

MediaBrain forma parte del conjunto de productividad y documentación de [doc-bricks](https://github.com/doc-bricks), bajo el paraguas de [open-bricks](https://github.com/open-bricks):

| Herramienta | Enfoque | Repositorio |
|---|---|---|
| **MediaBrain** | Historial multimedia local, listas inteligentes y gestión de bibliotecas | [doc-bricks/MediaBrain](https://github.com/doc-bricks/MediaBrain) |
| **CleanMarkdown** | Normalizador tipográfico, limpiador de Markdown y exportador de PDF | [doc-bricks/CleanMarkdown](https://github.com/doc-bricks/CleanMarkdown) |
| **PDFtoPDFocr** | Flujo de OCR para PDF con búsqueda de texto y extracción de metadatos | [doc-bricks/PDFtoPDFocr](https://github.com/doc-bricks/PDFtoPDFocr) |
| **llm-note** | Cuaderno local SQLite y de texto plano para notas personales o escritas por agentes | [doc-bricks/llm-note](https://github.com/doc-bricks/llm-note) |
| **LaunchBoards** | Lanzador visual, organizador de aplicaciones y panel de trabajo | [file-bricks/LaunchBoards](https://github.com/file-bricks/LaunchBoards) |
| **ProFiler** | Analizador de archivos centrado en la privacidad, inspector y buscador de duplicados | [file-bricks/ProFiler](https://github.com/file-bricks/ProFiler) |
| **KnowledgeDigest** | Base de conocimiento sin conexión y compresor de documentación | [file-bricks/KnowledgeDigest](https://github.com/file-bricks/KnowledgeDigest) |
| **WinStorePackager** | Empaquetado MSIX, preparación de manifiestos de Store y generador de recursos | [file-bricks/WinStorePackager](https://github.com/file-bricks/WinStorePackager) |
| **DevCenter** | Panel para varios repositorios, monitor de CI y gestor de espacios de trabajo | [dev-bricks/DevCenter](https://github.com/dev-bricks/DevCenter) |
| **open-bricks** | Portal general para aplicaciones de escritorio y herramientas CLI | [open-bricks/open-bricks](https://github.com/open-bricks/open-bricks) |

## Instalación

Requisitos:

- Python 3.10 o posterior
- Windows, Linux o macOS con compatibilidad con Qt/PySide6

```bash
pip install -r requirements.txt
```

Al iniciarse por primera vez, MediaBrain crea `settings.json` localmente. La plantilla pública es [`settings.example.json`](settings.example.json). La configuración personal, las bases de datos, los registros y los artefactos de compilación se excluyen mediante `.gitignore`.

## Uso

```bash
python MediaBrain.py
```

Acceso de solo lectura a la línea de comandos (nunca escribe en la base de datos):

```bash
python cli.py list
python cli.py search "title"
python cli.py --db /path/to/media_brain.db types
```

La CLI oculta las entradas incluidas en la lista de bloqueo. Establece `MEDIABRAIN_DB` o usa `--db` para seleccionar explícitamente una base de datos.

Lanzador de Windows con doble clic:

```bat
START.bat
```

Para crear un lanzador ligero de Windows:

```bat
build_exe.bat
```

## Pruebas

```bash
python -m pytest tests/ -q
```

La suite de pruebas cubre los gestores de bases de datos, metadatos, etiquetas, QueryBuilder, listas de reproducción e interfaz de listas de reproducción en modo offscreen.

La prueba específica de plataforma de origen comprueba rutas Unicode, configuración, intercambio JSON, el abridor de archivos del sistema operativo y el ciclo de vida de la ventana y la bandeja en modo offscreen:

```bash
python -m pytest tests/source_platform_smoke.py -q
```

GitHub Actions ejecuta esta prueba acotada en Ubuntu y macOS. Es un contrato para el código fuente y la interfaz gráfica en modo offscreen; no demuestra el empaquetado nativo, el funcionamiento de la bandeja en una sesión de escritorio ni la aceptación manual en ninguna de las dos plataformas.

## Privacidad

MediaBrain guarda los datos de uso localmente en bases de datos SQLite y archivos de configuración. No tiene telemetría ni sincronización automática con la nube. Las solicitudes opcionales de metadatos usan únicamente claves de API TMDb/OMDb configuradas por el usuario o datos públicos de MusicBrainz. Detalles: [`PRIVACY_POLICY.md`](PRIVACY_POLICY.md).

## Licencia

MIT; consulta [`LICENSE`](LICENSE). Las licencias de las dependencias directas de ejecución y desarrollo están inventariadas en [`THIRD_PARTY_LICENSES.txt`](THIRD_PARTY_LICENSES.txt). La interfaz usa PySide6 bajo los términos de LGPL.

## Responsabilidad

Este proyecto se ofrece gratuitamente y “tal cual”, sin garantía, compromiso de mantenimiento ni garantía de idoneidad para un propósito determinado. Úsalo bajo tu propia responsabilidad.
