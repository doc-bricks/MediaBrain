<!-- worldset: {"translated_from_sha256": "0b04db88ca639d0f9eec7ec88b93d8c526c38c4b6e4dde6d4929df578ec5f980", "translator": "gpt-6-luna", "original_source_commit": "381af978ab857ac069ab2e272659ddda429e9993"} -->
<img src="assets/banner.png" width="100%" alt="MediaBrain バナー">

# MediaBrain

[![バージョン: 2.1.0](https://img.shields.io/badge/version-2.1.0-orange.svg)](version.py)
[![ライセンス: MIT](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)
[![Python 3.10+](https://img.shields.io/badge/python-3.10+-blue.svg)](https://www.python.org/)
[![プラットフォーム: Windows](https://img.shields.io/badge/platform-Windows-lightgrey.svg)]()
[![オフライン優先: はい](https://img.shields.io/badge/offline--first-yes-brightgreen.svg)]()
[![テスト: 274 件成功](https://img.shields.io/badge/tests-274%20passed-brightgreen.svg)]()
[![doc-bricks](https://img.shields.io/badge/doc--bricks-ecosystem-blue.svg)](https://github.com/doc-bricks)
[![open-bricks](https://img.shields.io/badge/open--bricks-umbrella-purple.svg)](https://github.com/open-bricks)
[![LLM コンテキスト](https://img.shields.io/badge/LLM--Context-llms.txt-blue.svg)](llms.txt)

> **MediaBrain は、個人の動画・音楽、プレイリスト、ストリーミング視聴履歴を管理する、PySide6 製のローカル優先メディアライブラリ管理ツールです。**

> [!NOTE]
> **AI / エージェント向けコンテキスト**: リポジトリのアーキテクチャ、ファイル索引、検索フレーズ、システム境界の機械可読情報は [llms.txt](llms.txt) を参照してください。

[English](README.md) | [Deutsch](README_de.md) | [Español](README_es.md) | [简体中文](README_zh.md) | **日本語** | [Русский](README_ru.md) | [Français](README_fr.md) | [हिन्दी](README_hi.md) | [العربية](README_ar.md) | [বাংলা](README_bn.md) | [Português](README_pt.md) | [プライバシー](PRIVACY_POLICY.md) | [コントリビューション](CONTRIBUTING.md) | [変更履歴](CHANGELOG.md)

![MediaBrain のメインウィンドウ](README/screenshots/main.png)

## ドキュメントの言語

| 言語 | ドキュメント |
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

この一覧は README の文書版のみを示します。アプリの実行時の言語対応を示すものではありません。

MediaBrain の Flutter アプリ、デスクトップ GUI、Python CLI は、ドイツ語、英語、スペイン語、簡体字中国語、日本語、ロシア語、フランス語、ヒンディー語、アラビア語、ベンガル語、ポルトガル語に対応しています。デスクトップアプリでは「設定 → 言語」で選択します。選択は保存され、MediaBrain を再起動すると反映されます。環境変数 `MEDIABRAIN_LANG` は保存済みの選択を上書きし、CLI では `--lang <code>` も使用できます。Windows のネイティブファイルダイアログのウィンドウ枠は、Windows 側のローカライズに従います。

## まずはこちら

| 内容 | 移動先 |
|---|---|
| デスクトップアプリを起動する | `python MediaBrain.py` |
| Flutter モバイル版を確認する | `flutter_port/README.md` |
| プライバシーの境界を確認する | [PRIVACY_POLICY.md](PRIVACY_POLICY.md) |
| アーキテクチャを確認する | [ARCH.md](ARCH.md) |
| 計画中の作業を確認する | [ROADMAP.md](ROADMAP.md) |
| 機械可読コンテキストを取得する | [llms.txt](llms.txt) |

## MediaBrain を選ぶ理由

MediaBrain は、各種サービスやローカルファイルにある、視聴、収集、タグ付け、ブラックリスト登録、整理したメディアを一か所で管理したい人向けです。ホスト型ストリーミングサービスではなく、個人のライブラリをクラウドアカウントへアップロードすることもありません。

- メディア項目、お気に入り、タグ、ブラックリスト項目、プレイリストをローカルの SQLite に保存
- ダッシュボード、ライブラリ、検索、統計、設定、高コントラストテーマを備えた PySide6 デスクトップ UI
- Netflix、YouTube、Spotify、Disney+、Prime Video、Apple TV+、Twitch、ローカルファイル向けのプロバイダー層
- 手動プレイリストと、QueryBuilder のルールに基づくスマートプレイリスト
- ユーザーが設定した TMDb/OMDb キーまたは MusicBrainz の公開データを使った、任意のメタデータ検索
- テレメトリー、トラッキング、自動クラウド同期なし

## 検索コンテキスト

このリポジトリは、次の名称や検索フレーズに対応する GitHub 上の正式な場所です。

- `doc-bricks MediaBrain`
- `MediaBrain media library manager`
- `private SQLite media library manager`
- `local-first PySide6 media manager`
- `PySide6 smart playlist media manager`
- `offline media hub with smart playlists`
- `desktop media history tracker`
- `privacy-first media history desktop app`

「MediaBrain」という名前は、メディア分析企業、AI メディア研究所、汎用のメディア企画ツールでも使われています。このリポジトリが扱うのは、ローカル優先のデスクトップメディアライブラリ `doc-bricks/MediaBrain` です。クラウド広告分析プラットフォーム、マルチメディア研究所、AI メディア生成ツールではありません。

## アーキテクチャ

```text
Core Layer        Database, MediaManager, BlacklistManager, TagManager, PlaylistManager
Query Layer       QueryBuilder for advanced filters and smart playlists
Provider Layer    Netflix, YouTube, Spotify, Disney+, Prime, AppleTV+, Twitch, Local
Background Layer  FileIndexer, WindowWatcher
GUI Layer         Dashboard, Libraries, Favorites, Blacklist, Playlists, Search, Stats, Settings
```

全体図: [ARCH.md](ARCH.md)

## エコシステムと関連ツール

MediaBrain は [`doc-bricks`](https://github.com/doc-bricks) のドキュメント・生産性ツール群の一部であり、[`open-bricks`](https://github.com/open-bricks) の傘下にあります。

| ツール | 主な用途 | リポジトリ |
|---|---|---|
| **MediaBrain** | ローカル優先のメディア履歴、スマートプレイリスト、ライブラリ管理 | [doc-bricks/MediaBrain](https://github.com/doc-bricks/MediaBrain) |
| **CleanMarkdown** | タイポグラフィの正規化、Markdown の整理、PDF エクスポート | [doc-bricks/CleanMarkdown](https://github.com/doc-bricks/CleanMarkdown) |
| **PDFtoPDFocr** | 検索可能な PDF を作る OCR パイプラインとメタデータ抽出 | [doc-bricks/PDFtoPDFocr](https://github.com/doc-bricks/PDFtoPDFocr) |
| **llm-note** | 個人またはエージェントが作成したメモ用のローカル SQLite・プレーンテキストノート | [doc-bricks/llm-note](https://github.com/doc-bricks/llm-note) |
| **LaunchBoards** | ビジュアルランチャー、アプリ整理、ワークステーション用ダッシュボード | [file-bricks/LaunchBoards](https://github.com/file-bricks/LaunchBoards) |
| **ProFiler** | プライバシーを重視したファイル分析・検査・重複検出ツール | [file-bricks/ProFiler](https://github.com/file-bricks/ProFiler) |
| **KnowledgeDigest** | オフライン知識ベースとドキュメント圧縮ツール | [file-bricks/KnowledgeDigest](https://github.com/file-bricks/KnowledgeDigest) |
| **WinStorePackager** | MSIX パッケージング、Store マニフェストの準備、アセット生成 | [file-bricks/WinStorePackager](https://github.com/file-bricks/WinStorePackager) |
| **DevCenter** | 複数リポジトリ向け開発者ダッシュボード、CI モニター、ワークスペース管理 | [dev-bricks/DevCenter](https://github.com/dev-bricks/DevCenter) |
| **open-bricks** | デスクトップアプリと CLI ツールをまとめる統合ポータル | [open-bricks/open-bricks](https://github.com/open-bricks/open-bricks) |

## インストール

必要条件:

- Python 3.10 以降
- Qt/PySide6 に対応した Windows、Linux、macOS

```bash
pip install -r requirements.txt
```

初回起動時に MediaBrain は `settings.json` をローカルに作成します。公開テンプレートは [settings.example.json](settings.example.json) です。個人設定、データベース、ログ、ビルド成果物は `.gitignore` により除外されます。

## 使い方

```bash
python MediaBrain.py
```

読み取り専用のコマンドラインアクセス（データベースには書き込みません）:

```bash
python cli.py list
python cli.py search "title"
python cli.py --db /path/to/media_brain.db types
```

CLI はブラックリスト登録済みの項目を表示しません。`MEDIABRAIN_DB` を設定するか、`--db` を使ってデータベースを明示的に選択してください。

Windows のダブルクリック用ランチャー:

```bat
START.bat
```

軽量な Windows ランチャーは次のコマンドでビルドできます:

```bat
build_exe.bat
```

## テスト

```bash
python -m pytest tests/ -q
```

テストスイートでは、データベースマネージャー、メタデータ、タグ、QueryBuilder、プレイリスト、および offscreen モードでのプレイリスト GUI の動作を確認します。

専用のソースプラットフォーム用スモークテストでは、Unicode パス、設定、JSON 交換、OS のファイルオープナー、offscreen ウィンドウとトレイのライフサイクルを確認します:

```bash
python -m pytest tests/source_platform_smoke.py -q
```

GitHub Actions は、この範囲を絞ったスモークテストを Ubuntu と macOS で実行します。これはソースと offscreen GUI の契約を確認するものであり、ネイティブパッケージ、デスクトップセッションでのトレイ、いずれかのプラットフォームでの手動受け入れを証明するものではありません。

## プライバシー

MediaBrain は利用データをローカルの SQLite データベースと設定ファイルに保存します。テレメトリーはなく、自動クラウド同期もありません。任意のメタデータ要求には、ユーザーが設定した TMDb/OMDb API キーまたは MusicBrainz の公開データのみを使います。詳細: [PRIVACY_POLICY.md](PRIVACY_POLICY.md)。

## ライセンス

MIT ライセンスです。詳細は [LICENSE](LICENSE) を参照してください。直接依存するサードパーティ製ランタイム・開発依存関係のライセンスは [THIRD_PARTY_LICENSES.txt](THIRD_PARTY_LICENSES.txt) に記載されています。GUI が使用する PySide6 には LGPL の条件が適用されます。

## 免責事項

本プロジェクトは無料で「現状有姿」で提供され、保証、保守の保証、または特定目的への適合性の保証はありません。ご自身の責任でご利用ください。
