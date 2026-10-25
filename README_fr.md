<!-- worldset: {"translated_from_sha256": "c68d3298c39a37020989bae5d7410a91fa166d01a3120ebc3f91bb37a42bee89", "translator": "gpt-6-luna", "original_source_commit": "381af978ab857ac069ab2e272659ddda429e9993"} -->
<img src="assets/banner.png" width="100%" alt="Bannière MediaBrain">

# MediaBrain

[![Version : 2.1.0](https://img.shields.io/badge/version-2.1.0-orange.svg)](version.py)
[![Licence : MIT](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)
[![Python 3.10+](https://img.shields.io/badge/python-3.10+-blue.svg)](https://www.python.org/)
[![Plateforme : Windows](https://img.shields.io/badge/platform-Windows-lightgrey.svg)]()
[![Priorité au fonctionnement hors ligne : oui](https://img.shields.io/badge/offline--first-yes-brightgreen.svg)]()
[![Tests : 274 réussis](https://img.shields.io/badge/tests-274%20passed-brightgreen.svg)]()
[![doc-bricks](https://img.shields.io/badge/doc--bricks-ecosystem-blue.svg)](https://github.com/doc-bricks)
[![open-bricks](https://img.shields.io/badge/open--bricks-umbrella-purple.svg)](https://github.com/open-bricks)
[![Contexte LLM](https://img.shields.io/badge/LLM--Context-llms.txt-blue.svg)](llms.txt)

> **MediaBrain est un gestionnaire de médiathèque PySide6 privilégiant le stockage local, conçu pour gérer des vidéos, de la musique, des playlists personnelles et l’historique de visionnage sur les services de streaming.**

> [!NOTE]
> **Contexte pour les IA et les agents** : l’architecture du dépôt, les index de fichiers, les expressions de recherche et les limites du système sont décrits dans [llms.txt](llms.txt) sous une forme lisible par machine.

[English](README.md) | [Deutsch](README_de.md) | [Español](README_es.md) | [简体中文](README_zh.md) | [日本語](README_ja.md) | [Русский](README_ru.md) | **Français** | [हिन्दी](README_hi.md) | [العربية](README_ar.md) | [বাংলা](README_bn.md) | [Português](README_pt.md) | [Confidentialité](PRIVACY_POLICY.md) | [Contribuer](CONTRIBUTING.md) | [Historique des modifications](CHANGELOG.md)

![Fenêtre principale de MediaBrain](README/screenshots/main.png)

## Langues de la documentation

| Langue | Document |
|---|---|
| English | [README.md](README.md) |
| Deutsch | [README_de.md](README_de.md) |
| Español | [README_es.md](README_es.md) |
| 简体中文 | [README_zh.md](README_zh.md) |
| 日本語 | [README_ja.md](README_ja.md) |
| Русский | [README_ru.md](README_ru.md) |
| Français | [README_fr.md](README_fr.md) |
| हिन्दी | [README_hi.md](README_hi.md) |
| العربية | [README_ar.md](README_ar.md) |
| বাংলা | [README_bn.md](README_bn.md) |
| Português | [README_pt.md](README_pt.md) |

Cette liste présente uniquement les versions documentaires du README. Elle ne décrit pas les langues prises en charge par l’application à l’exécution.

## Pour commencer

| Besoin | Voir |
|---|---|
| Lancer l’application de bureau | `python MediaBrain.py` |
| Consulter la version mobile Flutter | `flutter_port/README.md` |
| Vérifier les limites en matière de confidentialité | [PRIVACY_POLICY.md](PRIVACY_POLICY.md) |
| Comprendre l’architecture | [ARCH.md](ARCH.md) |
| Consulter les travaux prévus | [ROADMAP.md](ROADMAP.md) |
| Obtenir le contexte lisible par machine | [llms.txt](llms.txt) |

## Pourquoi MediaBrain

MediaBrain s’adresse aux personnes qui souhaitent réunir en un seul endroit local les médias qu’elles regardent, collectionnent, étiquettent, mettent sur liste noire ou organisent, à partir de services et de fichiers locaux. Ce n’est pas un service de streaming hébergé et l’application ne téléverse pas de médiathèque privée vers un compte cloud.

- Stockage SQLite local des médias, favoris, étiquettes, éléments de liste noire et playlists
- Interface de bureau PySide6 avec tableau de bord, bibliothèques, recherche, statistiques, paramètres et thèmes à contraste élevé
- Couche de fournisseurs pour Netflix, YouTube, Spotify, Disney+, Prime Video, Apple TV+, Twitch et les fichiers locaux
- Playlists manuelles et playlists intelligentes fondées sur les règles de QueryBuilder
- Recherche facultative de métadonnées à l’aide de clés TMDb/OMDb configurées par l’utilisateur ou de données publiques MusicBrainz
- Aucune télémétrie, aucun suivi et aucune synchronisation automatique avec le cloud

## Contexte de recherche

Ce dépôt est le référentiel GitHub canonique pour :

- `doc-bricks MediaBrain`
- `MediaBrain media library manager`
- `private SQLite media library manager`
- `local-first PySide6 media manager`
- `PySide6 smart playlist media manager`
- `offline media hub with smart playlists`
- `desktop media history tracker`
- `privacy-first media history desktop app`

Le nom « MediaBrain » est également utilisé par des entreprises d’analyse média, des laboratoires d’IA appliquée aux médias et des outils génériques de planification média. Ce dépôt concerne précisément la médiathèque de bureau locale `doc-bricks/MediaBrain`, et non une plateforme d’analyse publicitaire dans le cloud, un laboratoire de recherche multimédia ou un générateur de médias par IA.

## Architecture

```text
Core Layer        Database, MediaManager, BlacklistManager, TagManager, PlaylistManager
Query Layer       QueryBuilder for advanced filters and smart playlists
Provider Layer    Netflix, YouTube, Spotify, Disney+, Prime, AppleTV+, Twitch, Local
Background Layer  FileIndexer, WindowWatcher
GUI Layer         Dashboard, Libraries, Favorites, Blacklist, Playlists, Search, Stats, Settings
```

Schéma complet : [ARCH.md](ARCH.md)

## Écosystème et outils associés

MediaBrain fait partie de la suite documentaire et de productivité [`doc-bricks`](https://github.com/doc-bricks), sous l’égide de [`open-bricks`](https://github.com/open-bricks) :

| Outil | Domaine | Dépôt |
|---|---|---|
| **MediaBrain** | Historique média local, playlists intelligentes et gestion de médiathèque | [doc-bricks/MediaBrain](https://github.com/doc-bricks/MediaBrain) |
| **CleanMarkdown** | Normalisation typographique, nettoyage Markdown et export PDF | [doc-bricks/CleanMarkdown](https://github.com/doc-bricks/CleanMarkdown) |
| **PDFtoPDFocr** | Pipeline OCR pour PDF consultables et extraction de métadonnées | [doc-bricks/PDFtoPDFocr](https://github.com/doc-bricks/PDFtoPDFocr) |
| **llm-note** | Bloc-notes local SQLite et texte brut pour notes personnelles ou rédigées par des agents | [doc-bricks/llm-note](https://github.com/doc-bricks/llm-note) |
| **LaunchBoards** | Lanceur visuel, organisateur d’applications et tableau de bord de poste de travail | [file-bricks/LaunchBoards](https://github.com/file-bricks/LaunchBoards) |
| **ProFiler** | Analyseur et inspecteur de fichiers axé sur la confidentialité, avec détection des doublons | [file-bricks/ProFiler](https://github.com/file-bricks/ProFiler) |
| **KnowledgeDigest** | Base de connaissances hors ligne et compresseur de documentation | [file-bricks/KnowledgeDigest](https://github.com/file-bricks/KnowledgeDigest) |
| **WinStorePackager** | Empaquetage MSIX, préparation des manifestes Store et générateur de ressources | [file-bricks/WinStorePackager](https://github.com/file-bricks/WinStorePackager) |
| **DevCenter** | Tableau de bord développeur multi-dépôts, moniteur CI et gestionnaire d’espaces de travail | [dev-bricks/DevCenter](https://github.com/dev-bricks/DevCenter) |
| **open-bricks** | Portail unifié pour les applications de bureau et outils CLI | [open-bricks/open-bricks](https://github.com/open-bricks/open-bricks) |

## Installation

Prérequis :

- Python 3.10 ou version ultérieure
- Windows, Linux ou macOS avec prise en charge de Qt/PySide6

```bash
pip install -r requirements.txt
```

Au premier lancement, MediaBrain crée localement `settings.json`. Le modèle public est [settings.example.json](settings.example.json). Les paramètres personnels, bases de données, journaux et artefacts de compilation sont exclus via `.gitignore`.

## Utilisation

```bash
python MediaBrain.py
```

Accès en lecture seule en ligne de commande (aucune écriture dans la base de données) :

```bash
python cli.py list
python cli.py search "title"
python cli.py --db /path/to/media_brain.db types
```

La CLI masque les éléments figurant sur la liste noire. Définissez `MEDIABRAIN_DB` ou utilisez `--db` pour sélectionner explicitement une base de données.

Lanceur Windows à double-clic :

```bat
START.bat
```

Un lanceur Windows léger peut être créé avec :

```bat
build_exe.bat
```

## Tests

```bash
python -m pytest tests/ -q
```

La suite de tests couvre les gestionnaires de base de données, les métadonnées, les étiquettes, QueryBuilder, les playlists et le comportement de l’interface des playlists en mode offscreen.

Le test smoke dédié à la plateforme source vérifie les chemins Unicode, la configuration, l’échange JSON, l’ouvreur de fichiers du système d’exploitation et le cycle de vie de la fenêtre et de la zone de notification en mode offscreen :

```bash
python -m pytest tests/source_platform_smoke.py -q
```

GitHub Actions exécute ce test smoke ciblé sur Ubuntu et macOS. Il vérifie le contrat du code source et de l’interface en mode offscreen ; il ne prouve ni l’empaquetage natif, ni le fonctionnement de la zone de notification dans une session de bureau, ni l’acceptation manuelle sur l’une ou l’autre plateforme.

## Confidentialité

MediaBrain stocke les données d’utilisation localement dans des bases SQLite et des fichiers de configuration. Il n’y a ni télémétrie ni synchronisation automatique avec le cloud. Les requêtes facultatives de métadonnées utilisent uniquement des clés API TMDb/OMDb configurées par l’utilisateur ou des données publiques MusicBrainz. Détails : [PRIVACY_POLICY.md](PRIVACY_POLICY.md).

## Licence

Licence MIT, voir [LICENSE](LICENSE). Les licences des dépendances directes tierces d’exécution et de développement sont répertoriées dans [THIRD_PARTY_LICENSES.txt](THIRD_PARTY_LICENSES.txt). L’interface graphique utilise PySide6, soumis aux conditions de la LGPL.

## Responsabilité

Ce projet est fourni gratuitement et « en l’état », sans garantie, engagement de maintenance ni garantie d’adéquation à un usage particulier. Utilisez-le à vos risques.
