<!-- worldset: {"translated_from_sha256": "1cb001dfda5d5445b4e02c5c1e6761d0c745a53ab12a6a3d2168ccba11482535", "translator": "gpt-6-luna", "original_source_commit": "381af978ab857ac069ab2e272659ddda429e9993"} -->
<img src="assets/banner.png" width="100%" alt="Faixa do MediaBrain">

# MediaBrain

[![Versão: 2.1.0](https://img.shields.io/badge/version-2.1.0-orange.svg)](version.py)
[![Licença: MIT](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)
[![Python 3.10+](https://img.shields.io/badge/python-3.10+-blue.svg)](https://www.python.org/)
[![Plataforma: Windows](https://img.shields.io/badge/platform-Windows-lightgrey.svg)]()
[![Prioridade ao funcionamento offline: sim](https://img.shields.io/badge/offline--first-yes-brightgreen.svg)]()
[![Testes: 274 aprovados](https://img.shields.io/badge/tests-274%20passed-brightgreen.svg)]()
[![doc-bricks](https://img.shields.io/badge/doc--bricks-ecosystem-blue.svg)](https://github.com/doc-bricks)
[![open-bricks](https://img.shields.io/badge/open--bricks-umbrella-purple.svg)](https://github.com/open-bricks)
[![Contexto LLM](https://img.shields.io/badge/LLM--Context-llms.txt-blue.svg)](llms.txt)

> **MediaBrain é um gestor de biblioteca multimédia baseado em PySide6 que privilegia o armazenamento local e ajuda a organizar vídeos, música, listas de reprodução pessoais e o histórico de visualização em serviços de streaming.**

> [!NOTE]
> **Contexto para IA e agentes**: a arquitetura do repositório, os índices de ficheiros, as expressões de pesquisa e os limites do sistema estão descritos em formato legível por máquina em [llms.txt](llms.txt).

[English](README.md) | [Deutsch](README_de.md) | [Español](README_es.md) | [简体中文](README_zh.md) | [日本語](README_ja.md) | [Русский](README_ru.md) | [Français](README_fr.md) | [हिन्दी](README_hi.md) | [العربية](README_ar.md) | [বাংলা](README_bn.md) | **Português** | [Privacidade](PRIVACY_POLICY.md) | [Contribuir](CONTRIBUTING.md) | [Registo de alterações](CHANGELOG.md)

![Janela principal do MediaBrain](README/screenshots/main.png)

## Idiomas da documentação

| Idioma | Documento |
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

Esta lista apresenta apenas as versões documentais do README. Não descreve os idiomas suportados pela aplicação em execução.

O aplicativo Flutter oferece mensagens de interface localizadas em alemão, inglês, espanhol, chinês simplificado, japonês, russo, francês, hindi, árabe, bengali e português. A localização da versão para desktop e da CLI continua separada; a validação visual nos dispositivos de destino ainda está pendente.

## Comece aqui

| Necessidade | Consulte |
|---|---|
| Executar a aplicação de ambiente de trabalho | `python MediaBrain.py` |
| Consultar a versão móvel Flutter | `flutter_port/README.md` |
| Verificar os limites de privacidade | [PRIVACY_POLICY.md](PRIVACY_POLICY.md) |
| Compreender a arquitetura | [ARCH.md](ARCH.md) |
| Consultar o trabalho planeado | [ROADMAP.md](ROADMAP.md) |
| Obter contexto legível por máquina | [llms.txt](llms.txt) |

## Porquê o MediaBrain

O MediaBrain destina-se a quem pretende manter num único local os conteúdos multimédia que vê, coleciona, etiqueta, coloca na lista de bloqueio ou organiza, entre serviços e ficheiros locais. Não é um serviço de streaming alojado e não carrega uma biblioteca privada para uma conta na nuvem.

- Armazenamento SQLite local para entradas multimédia, favoritos, etiquetas, itens da lista de bloqueio e listas de reprodução
- Interface de ambiente de trabalho PySide6 com painel, bibliotecas, pesquisa, estatísticas, definições e temas de alto contraste
- Camada de fornecedores para Netflix, YouTube, Spotify, Disney+, Prime Video, Apple TV+, Twitch e ficheiros locais
- Listas de reprodução manuais e inteligentes baseadas em regras do QueryBuilder
- Pesquisa opcional de metadados através de chaves TMDb/OMDb configuradas pelo utilizador ou dados públicos do MusicBrainz
- Sem telemetria, sem rastreio e sem sincronização automática com a nuvem

## Contexto de pesquisa

Este repositório é o endereço canónico no GitHub para:

- `doc-bricks MediaBrain`
- `MediaBrain media library manager`
- `private SQLite media library manager`
- `local-first PySide6 media manager`
- `PySide6 smart playlist media manager`
- `offline media hub with smart playlists`
- `desktop media history tracker`
- `privacy-first media history desktop app`

O nome “MediaBrain” também é usado por empresas de análise de media, laboratórios de IA para media e ferramentas genéricas de planeamento de media. Este repositório refere-se especificamente à biblioteca multimédia de ambiente de trabalho com prioridade local `doc-bricks/MediaBrain`, e não a uma plataforma de análise publicitária na nuvem, a um laboratório de investigação multimédia ou a um gerador de media com IA.

## Arquitetura

```text
Core Layer        Database, MediaManager, BlacklistManager, TagManager, PlaylistManager
Query Layer       QueryBuilder for advanced filters and smart playlists
Provider Layer    Netflix, YouTube, Spotify, Disney+, Prime, AppleTV+, Twitch, Local
Background Layer  FileIndexer, WindowWatcher
GUI Layer         Dashboard, Libraries, Favorites, Blacklist, Playlists, Search, Stats, Settings
```

Diagrama completo: [ARCH.md](ARCH.md)

## Ecossistema e ferramentas relacionadas

O MediaBrain faz parte do conjunto de documentação e produtividade [`doc-bricks`](https://github.com/doc-bricks), sob a alçada de [`open-bricks`](https://github.com/open-bricks):

| Ferramenta | Foco | Repositório |
|---|---|---|
| **MediaBrain** | Histórico multimédia local, listas inteligentes e gestão de biblioteca | [doc-bricks/MediaBrain](https://github.com/doc-bricks/MediaBrain) |
| **CleanMarkdown** | Normalização tipográfica, limpeza de Markdown e exportação para PDF | [doc-bricks/CleanMarkdown](https://github.com/doc-bricks/CleanMarkdown) |
| **PDFtoPDFocr** | Fluxo OCR para PDFs pesquisáveis e extração de metadados | [doc-bricks/PDFtoPDFocr](https://github.com/doc-bricks/PDFtoPDFocr) |
| **llm-note** | Bloco de notas local SQLite e texto simples para notas pessoais ou criadas por agentes | [doc-bricks/llm-note](https://github.com/doc-bricks/llm-note) |
| **LaunchBoards** | Lançador visual, organizador de aplicações e painel de trabalho | [file-bricks/LaunchBoards](https://github.com/file-bricks/LaunchBoards) |
| **ProFiler** | Analisador e inspetor de ficheiros com foco na privacidade e deteção de duplicados | [file-bricks/ProFiler](https://github.com/file-bricks/ProFiler) |
| **KnowledgeDigest** | Base de conhecimento offline e compressor de documentação | [file-bricks/KnowledgeDigest](https://github.com/file-bricks/KnowledgeDigest) |
| **WinStorePackager** | Empacotamento MSIX, preparação de manifestos Store e gerador de recursos | [file-bricks/WinStorePackager](https://github.com/file-bricks/WinStorePackager) |
| **DevCenter** | Painel de desenvolvimento multi-repositório, monitor de CI e gestor de áreas de trabalho | [dev-bricks/DevCenter](https://github.com/dev-bricks/DevCenter) |
| **open-bricks** | Portal unificado para aplicações de ambiente de trabalho e ferramentas CLI | [open-bricks/open-bricks](https://github.com/open-bricks/open-bricks) |

## Instalação

Requisitos:

- Python 3.10 ou superior
- Windows, Linux ou macOS com suporte para Qt/PySide6

```bash
pip install -r requirements.txt
```

No primeiro arranque, o MediaBrain cria localmente `settings.json`. O modelo público é [settings.example.json](settings.example.json). As definições pessoais, bases de dados, registos e artefactos de compilação são excluídos através de `.gitignore`.

## Utilização

```bash
python MediaBrain.py
```

Acesso de linha de comandos apenas de leitura (nunca escreve na base de dados):

```bash
python cli.py list
python cli.py search "title"
python cli.py --db /path/to/media_brain.db types
```

A CLI oculta as entradas que estão na lista de bloqueio. Defina `MEDIABRAIN_DB` ou use `--db` para selecionar explicitamente uma base de dados.

Lançador do Windows por duplo clique:

```bat
START.bat
```

É possível criar um lançador leve para Windows com:

```bat
build_exe.bat
```

## Testes

```bash
python -m pytest tests/ -q
```

A suite de testes abrange os gestores de bases de dados, metadados, etiquetas, QueryBuilder, listas de reprodução e o comportamento da interface gráfica das listas em modo offscreen.

O teste smoke dedicado à plataforma de origem verifica caminhos Unicode, configuração, troca de JSON, o programa de abertura de ficheiros do sistema operativo e o ciclo de vida da janela e do tabuleiro do sistema em modo offscreen:

```bash
python -m pytest tests/source_platform_smoke.py -q
```

O GitHub Actions executa este teste smoke específico no Ubuntu e no macOS. É um contrato do código-fonte e da interface em modo offscreen; não comprova o empacotamento nativo, o funcionamento do tabuleiro numa sessão de ambiente de trabalho nem a aceitação manual em qualquer uma das plataformas.

## Privacidade

O MediaBrain guarda dados de utilização localmente em bases de dados SQLite e ficheiros de configuração. Não tem telemetria nem sincronização automática com a nuvem. Os pedidos opcionais de metadados usam apenas chaves de API TMDb/OMDb configuradas pelo utilizador ou dados públicos do MusicBrainz. Detalhes: [PRIVACY_POLICY.md](PRIVACY_POLICY.md).

## Licença

Licença MIT; consulte [LICENSE](LICENSE). As licenças das dependências diretas de terceiros para execução e desenvolvimento estão inventariadas em [THIRD_PARTY_LICENSES.txt](THIRD_PARTY_LICENSES.txt). A interface gráfica usa PySide6 ao abrigo dos termos da LGPL.

## Responsabilidade

Este projeto é fornecido gratuitamente e “tal como está”, sem garantia, compromisso de manutenção nem garantia de adequação a uma finalidade específica. Utilize-o por sua conta e risco.
