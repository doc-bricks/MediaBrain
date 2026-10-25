<!-- worldset: {"translated_from_sha256": "1cb001dfda5d5445b4e02c5c1e6761d0c745a53ab12a6a3d2168ccba11482535", "translator": "gpt-6-luna", "original_source_commit": "381af978ab857ac069ab2e272659ddda429e9993"} -->
<img src="assets/banner.png" width="100%" alt="MediaBrain 横幅">

# MediaBrain

[![版本：2.1.0](https://img.shields.io/badge/version-2.1.0-orange.svg)](version.py)
[![许可证：MIT](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)
[![Python 3.10+](https://img.shields.io/badge/python-3.10+-blue.svg)](https://www.python.org/)
[![平台：Windows](https://img.shields.io/badge/platform-Windows-lightgrey.svg)]()
[![离线优先：是](https://img.shields.io/badge/offline--first-yes-brightgreen.svg)]()
[![测试：274 项通过](https://img.shields.io/badge/tests-274%20passed-brightgreen.svg)]()
[![doc-bricks](https://img.shields.io/badge/doc--bricks-ecosystem-blue.svg)](https://github.com/doc-bricks)
[![open-bricks](https://img.shields.io/badge/open--bricks-umbrella-purple.svg)](https://github.com/open-bricks)
[![LLM 上下文](https://img.shields.io/badge/LLM--Context-llms.txt-blue.svg)](llms.txt)

> **MediaBrain 是一款基于 PySide6 的本地优先媒体库管理器，用于整理个人视频、音乐、播放列表以及流媒体观看记录。**

> [!NOTE]
> **AI / 智能体上下文**：仓库架构、文件索引、搜索短语和系统边界的机器可读资料见 [llms.txt](llms.txt)。

[English](README.md) | [Deutsch](README_de.md) | [Español](README_es.md) | **简体中文** | [日本語](README_ja.md) | [Русский](README_ru.md) | [Français](README_fr.md) | [हिन्दी](README_hi.md) | [العربية](README_ar.md) | [বাংলা](README_bn.md) | [Português](README_pt.md) | [隐私政策](PRIVACY_POLICY.md) | [贡献指南](CONTRIBUTING.md) | [更新日志](CHANGELOG.md)

![MediaBrain 主窗口](README/screenshots/main.png)

## 文档语言

| 语言 | 文档 |
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

此列表仅说明 README 文档版本，不代表应用运行时支持的语言。

Flutter 应用提供德语、英语、西班牙语、简体中文、日语、俄语、法语、印地语、阿拉伯语、孟加拉语和葡萄牙语的本地化界面消息。桌面版和 CLI 的本地化仍需单独完成；目标设备上的视觉布局验收尚未完成。

## 从这里开始

| 需求 | 前往 |
|---|---|
| 运行桌面应用 | `python MediaBrain.py` |
| 查看 Flutter 移动端版本 | `flutter_port/README.md` |
| 了解隐私边界 | [PRIVACY_POLICY.md](PRIVACY_POLICY.md) |
| 了解架构 | [ARCH.md](ARCH.md) |
| 查看计划中的工作 | [ROADMAP.md](ROADMAP.md) |
| 获取机器可读的上下文 | [llms.txt](llms.txt) |

## 为什么选择 MediaBrain

MediaBrain 面向希望在一个本地位置管理自己观看、收藏、标记、拉黑或整理的媒体内容的人，内容来自各类服务和本地文件。它不是托管式流媒体服务，也不会把私人媒体库上传到云账户。

- 使用本地 SQLite 保存媒体条目、收藏、标签、黑名单项目和播放列表
- 基于 PySide6 的桌面界面，包含仪表板、媒体库、搜索、统计、设置和高对比度主题
- 支持 Netflix、YouTube、Spotify、Disney+、Prime Video、Apple TV+、Twitch 和本地文件的服务提供方层
- 手动播放列表和基于 QueryBuilder 规则生成的智能播放列表
- 可选的元数据查询：使用用户配置的 TMDb/OMDb 密钥或 MusicBrainz 公共数据
- 无遥测、无跟踪，也不会自动同步到云端

## 搜索上下文

此仓库是以下项目和短语对应的规范 GitHub 地址：

- `doc-bricks MediaBrain`
- `MediaBrain media library manager`
- `private SQLite media library manager`
- `local-first PySide6 media manager`
- `PySide6 smart playlist media manager`
- `offline media hub with smart playlists`
- `desktop media history tracker`
- `privacy-first media history desktop app`

“MediaBrain”这个名称也被媒体分析公司、AI 媒体实验室和通用媒体规划工具使用。此仓库专指 `doc-bricks/MediaBrain` 这个本地优先桌面媒体库管理器，并非云端广告分析平台、多媒体研究实验室或 AI 媒体生成器。

## 架构

```text
Core Layer        Database, MediaManager, BlacklistManager, TagManager, PlaylistManager
Query Layer       QueryBuilder for advanced filters and smart playlists
Provider Layer    Netflix, YouTube, Spotify, Disney+, Prime, AppleTV+, Twitch, Local
Background Layer  FileIndexer, WindowWatcher
GUI Layer         Dashboard, Libraries, Favorites, Blacklist, Playlists, Search, Stats, Settings
```

完整架构图：[ARCH.md](ARCH.md)

## 生态系统与相关工具

MediaBrain 是 [`doc-bricks`](https://github.com/doc-bricks) 文档与效率工具套件的一部分，隶属于 [`open-bricks`](https://github.com/open-bricks) 体系：

| 工具 | 重点方向 | 仓库 |
|---|---|---|
| **MediaBrain** | 本地优先的媒体历史、智能播放列表和媒体库管理 | [doc-bricks/MediaBrain](https://github.com/doc-bricks/MediaBrain) |
| **CleanMarkdown** | 排版规范化、Markdown 清理和 PDF 导出 | [doc-bricks/CleanMarkdown](https://github.com/doc-bricks/CleanMarkdown) |
| **PDFtoPDFocr** | 可搜索 PDF 的 OCR 流程和元数据提取 | [doc-bricks/PDFtoPDFocr](https://github.com/doc-bricks/PDFtoPDFocr) |
| **llm-note** | 用于个人或智能体撰写笔记的本地 SQLite 与纯文本笔记本 | [doc-bricks/llm-note](https://github.com/doc-bricks/llm-note) |
| **LaunchBoards** | 可视化启动器、应用整理器和工作台仪表板 | [file-bricks/LaunchBoards](https://github.com/file-bricks/LaunchBoards) |
| **ProFiler** | 注重隐私的文件分析器、检查工具和重复项查找器 | [file-bricks/ProFiler](https://github.com/file-bricks/ProFiler) |
| **KnowledgeDigest** | 离线知识库和文档压缩工具 | [file-bricks/KnowledgeDigest](https://github.com/file-bricks/KnowledgeDigest) |
| **WinStorePackager** | MSIX 打包、Store 清单暂存和资源生成器 | [file-bricks/WinStorePackager](https://github.com/file-bricks/WinStorePackager) |
| **DevCenter** | 多仓库开发者仪表板、CI 监控器和工作区管理器 | [dev-bricks/DevCenter](https://github.com/dev-bricks/DevCenter) |
| **open-bricks** | 汇集所有桌面应用和 CLI 工具的统一门户 | [open-bricks/open-bricks](https://github.com/open-bricks/open-bricks) |

## 安装

系统要求：

- Python 3.10 或更高版本
- 支持 Qt/PySide6 的 Windows、Linux 或 macOS

```bash
pip install -r requirements.txt
```

首次启动时，MediaBrain 会在本地创建 `settings.json`。公开模板位于 [settings.example.json](settings.example.json)。个人设置、数据库、日志和构建产物通过 `.gitignore` 排除。

## 使用

```bash
python MediaBrain.py
```

只读命令行访问（不会写入数据库）：

```bash
python cli.py list
python cli.py search "title"
python cli.py --db /path/to/media_brain.db types
```

CLI 会隐藏已列入黑名单的条目。设置 `MEDIABRAIN_DB` 或使用 `--db` 可显式选择数据库。

Windows 双击启动器：

```bat
START.bat
```

可通过以下命令构建轻量级 Windows 启动器：

```bat
build_exe.bat
```

## 测试

```bash
python -m pytest tests/ -q
```

测试套件覆盖数据库管理器、元数据、标签、QueryBuilder、播放列表，以及在 offscreen 模式下运行的播放列表 GUI 行为。

专门的源平台冒烟测试会检查 Unicode 路径、配置、JSON 交换、操作系统文件打开器，以及 offscreen 窗口/托盘生命周期：

```bash
python -m pytest tests/source_platform_smoke.py -q
```

GitHub Actions 会在 Ubuntu 和 macOS 上运行这项范围明确的冒烟测试。它验证源码和 offscreen GUI 契约，不代表原生打包、桌面会话中的托盘功能，或在任一平台上的人工验收。

## 隐私

MediaBrain 将使用数据保存在本地 SQLite 数据库和配置文件中。它没有遥测，也不会自动同步到云端。可选的元数据请求仅使用用户配置的 TMDb/OMDb API 密钥或 MusicBrainz 公共数据。详情见：[PRIVACY_POLICY.md](PRIVACY_POLICY.md)。

## 许可证

采用 MIT 许可证，见 [LICENSE](LICENSE)。直接的第三方运行时和开发依赖项许可证列于 [THIRD_PARTY_LICENSES.txt](THIRD_PARTY_LICENSES.txt)。GUI 使用的 PySide6 受 LGPL 条款约束。

## 责任限制

本项目免费提供，并按“现状”提供，不提供任何保证、维护承诺或适用性保证。使用风险由你自行承担。
