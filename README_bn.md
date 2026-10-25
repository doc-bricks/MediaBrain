<!-- worldset: {"translated_from_sha256": "c68d3298c39a37020989bae5d7410a91fa166d01a3120ebc3f91bb37a42bee89", "translator": "gpt-6-luna", "original_source_commit": "381af978ab857ac069ab2e272659ddda429e9993"} -->
<img src="assets/banner.png" width="100%" alt="MediaBrain ব্যানার">

# MediaBrain

[![সংস্করণ: 2.1.0](https://img.shields.io/badge/version-2.1.0-orange.svg)](version.py)
[![লাইসেন্স: MIT](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)
[![Python 3.10+](https://img.shields.io/badge/python-3.10+-blue.svg)](https://www.python.org/)
[![প্ল্যাটফর্ম: Windows](https://img.shields.io/badge/platform-Windows-lightgrey.svg)]()
[![অফলাইনে ব্যবহার অগ্রাধিকার: হ্যাঁ](https://img.shields.io/badge/offline--first-yes-brightgreen.svg)]()
[![পরীক্ষা: 274টি সফল](https://img.shields.io/badge/tests-274%20passed-brightgreen.svg)]()
[![doc-bricks](https://img.shields.io/badge/doc--bricks-ecosystem-blue.svg)](https://github.com/doc-bricks)
[![open-bricks](https://img.shields.io/badge/open--bricks-umbrella-purple.svg)](https://github.com/open-bricks)
[![LLM প্রসঙ্গ](https://img.shields.io/badge/LLM--Context-llms.txt-blue.svg)](llms.txt)

> **MediaBrain হলো PySide6-ভিত্তিক একটি মিডিয়া লাইব্রেরি ম্যানেজার, যা স্থানীয়ভাবে তথ্য রাখাকে অগ্রাধিকার দেয় এবং ব্যক্তিগত ভিডিও, সংগীত, প্লেলিস্ট ও স্ট্রিমিং-সেবায় দেখার ইতিহাস পরিচালনা করে।**

> [!NOTE]
> **AI / এজেন্ট প্রসঙ্গ**: রিপোজিটরির আর্কিটেকচার, ফাইল সূচি, অনুসন্ধানের বাক্যাংশ এবং সিস্টেমের সীমারেখার মেশিন-পাঠযোগ্য তথ্য [llms.txt](llms.txt)-এ রয়েছে।

[English](README.md) | [Deutsch](README_de.md) | [Español](README_es.md) | [简体中文](README_zh.md) | [日本語](README_ja.md) | [Русский](README_ru.md) | [Français](README_fr.md) | [हिन्दी](README_hi.md) | [العربية](README_ar.md) | **বাংলা** | [Português](README_pt.md) | [গোপনীয়তা](PRIVACY_POLICY.md) | [অবদান](CONTRIBUTING.md) | [পরিবর্তনের তালিকা](CHANGELOG.md)

![MediaBrain-এর প্রধান উইন্ডো](README/screenshots/main.png)

## নথির ভাষা

| ভাষা | নথি |
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

এই তালিকায় শুধু README নথির ভাষাগত সংস্করণগুলো আছে। এটি অ্যাপের রানটাইমে কোন ভাষা সমর্থিত, তা জানায় না।

## এখান থেকে শুরু করুন

| প্রয়োজন | দেখুন |
|---|---|
| ডেস্কটপ অ্যাপ চালান | `python MediaBrain.py` |
| Flutter মোবাইল সংস্করণ দেখুন | `flutter_port/README.md` |
| গোপনীয়তার সীমারেখা দেখুন | [PRIVACY_POLICY.md](PRIVACY_POLICY.md) |
| আর্কিটেকচার বুঝুন | [ARCH.md](ARCH.md) |
| পরিকল্পিত কাজ দেখুন | [ROADMAP.md](ROADMAP.md) |
| মেশিন-পাঠযোগ্য প্রসঙ্গ নিন | [llms.txt](llms.txt) |

## MediaBrain কেন

যাঁরা বিভিন্ন সেবা ও স্থানীয় ফাইলে থাকা দেখা, সংগ্রহ করা, ট্যাগ দেওয়া, ব্ল্যাকলিস্টে রাখা বা গুছিয়ে রাখা মিডিয়া একটিমাত্র স্থানীয় জায়গায় রাখতে চান, তাঁদের জন্য MediaBrain। এটি কোনো হোস্ট করা স্ট্রিমিং সেবা নয় এবং ব্যক্তিগত লাইব্রেরি কোনো ক্লাউড অ্যাকাউন্টে আপলোড করে না।

- মিডিয়া এন্ট্রি, পছন্দের তালিকা, ট্যাগ, ব্ল্যাকলিস্ট আইটেম ও প্লেলিস্টের জন্য স্থানীয় SQLite স্টোরেজ
- ড্যাশবোর্ড, লাইব্রেরি, অনুসন্ধান, পরিসংখ্যান, সেটিংস ও উচ্চ-কনট্রাস্ট থিমসহ PySide6 ডেস্কটপ UI
- Netflix, YouTube, Spotify, Disney+, Prime Video, Apple TV+, Twitch এবং স্থানীয় ফাইলের জন্য প্রোভাইডার স্তর
- হাতে তৈরি প্লেলিস্ট এবং QueryBuilder নিয়মভিত্তিক স্মার্ট প্লেলিস্ট
- ব্যবহারকারীর কনফিগার করা TMDb/OMDb কী বা MusicBrainz-এর উন্মুক্ত তথ্য দিয়ে ঐচ্ছিক মেটাডেটা অনুসন্ধান
- কোনো টেলিমেট্রি নেই, ট্র্যাকিং নেই, স্বয়ংক্রিয় ক্লাউড সিঙ্ক নেই

## অনুসন্ধানের প্রসঙ্গ

এই রিপোজিটরিটি নিচের নাম ও অনুসন্ধান-শব্দগুলোর জন্য নির্দিষ্ট GitHub ঠিকানা:

- `doc-bricks MediaBrain`
- `MediaBrain media library manager`
- `private SQLite media library manager`
- `local-first PySide6 media manager`
- `PySide6 smart playlist media manager`
- `offline media hub with smart playlists`
- `desktop media history tracker`
- `privacy-first media history desktop app`

“MediaBrain” নামটি মিডিয়া অ্যানালিটিক্স কোম্পানি, AI মিডিয়া ল্যাব এবং সাধারণ মিডিয়া-পরিকল্পনা টুলের সঙ্গেও মিলে যেতে পারে। এই রিপোজিটরিটি বিশেষভাবে স্থানীয় অগ্রাধিকারভিত্তিক ডেস্কটপ মিডিয়া লাইব্রেরি `doc-bricks/MediaBrain` নিয়ে; এটি ক্লাউড বিজ্ঞাপন-অ্যানালিটিক্স প্ল্যাটফর্ম, মাল্টিমিডিয়া গবেষণাগার বা AI মিডিয়া জেনারেটর নয়।

## আর্কিটেকচার

```text
Core Layer        Database, MediaManager, BlacklistManager, TagManager, PlaylistManager
Query Layer       QueryBuilder for advanced filters and smart playlists
Provider Layer    Netflix, YouTube, Spotify, Disney+, Prime, AppleTV+, Twitch, Local
Background Layer  FileIndexer, WindowWatcher
GUI Layer         Dashboard, Libraries, Favorites, Blacklist, Playlists, Search, Stats, Settings
```

সম্পূর্ণ চিত্র: [ARCH.md](ARCH.md)

## ইকোসিস্টেম ও সংশ্লিষ্ট টুল

MediaBrain [`doc-bricks`](https://github.com/doc-bricks)-এর নথি ও উৎপাদনশীলতা টুলসমষ্টির অংশ, যা [`open-bricks`](https://github.com/open-bricks)-এর অধীনে রয়েছে:

| টুল | কাজ | রিপোজিটরি |
|---|---|---|
| **MediaBrain** | স্থানীয় মিডিয়া ইতিহাস, স্মার্ট প্লেলিস্ট ও লাইব্রেরি ব্যবস্থাপনা | [doc-bricks/MediaBrain](https://github.com/doc-bricks/MediaBrain) |
| **CleanMarkdown** | টাইপোগ্রাফি স্বাভাবিকীকরণ, Markdown পরিষ্কার ও PDF রপ্তানি | [doc-bricks/CleanMarkdown](https://github.com/doc-bricks/CleanMarkdown) |
| **PDFtoPDFocr** | অনুসন্ধানযোগ্য PDF-এর OCR প্রক্রিয়া ও মেটাডেটা নিষ্কাশন | [doc-bricks/PDFtoPDFocr](https://github.com/doc-bricks/PDFtoPDFocr) |
| **llm-note** | ব্যক্তিগত বা এজেন্ট-লিখিত নোটের জন্য স্থানীয় SQLite ও সাধারণ-টেক্সট নোটবুক | [doc-bricks/llm-note](https://github.com/doc-bricks/llm-note) |
| **LaunchBoards** | ভিজ্যুয়াল লঞ্চার, অ্যাপ সংগঠক ও ওয়ার্কস্টেশন ড্যাশবোর্ড | [file-bricks/LaunchBoards](https://github.com/file-bricks/LaunchBoards) |
| **ProFiler** | গোপনীয়তা-কেন্দ্রিক ফাইল বিশ্লেষক, পরিদর্শক ও ডুপ্লিকেট শনাক্তকারী | [file-bricks/ProFiler](https://github.com/file-bricks/ProFiler) |
| **KnowledgeDigest** | অফলাইন জ্ঞানভাণ্ডার ও নথি সংকোচক | [file-bricks/KnowledgeDigest](https://github.com/file-bricks/KnowledgeDigest) |
| **WinStorePackager** | MSIX প্যাকেজিং, Store ম্যানিফেস্ট প্রস্তুতি ও অ্যাসেট জেনারেটর | [file-bricks/WinStorePackager](https://github.com/file-bricks/WinStorePackager) |
| **DevCenter** | বহু-রিপোজিটরি ডেভেলপার ড্যাশবোর্ড, CI মনিটর ও ওয়ার্কস্পেস ম্যানেজার | [dev-bricks/DevCenter](https://github.com/dev-bricks/DevCenter) |
| **open-bricks** | সব ডেস্কটপ ও CLI টুলের সমন্বিত পোর্টাল | [open-bricks/open-bricks](https://github.com/open-bricks/open-bricks) |

## ইনস্টলেশন

প্রয়োজনীয়তা:

- Python 3.10 বা নতুন
- Qt/PySide6 সমর্থিত Windows, Linux বা macOS

```bash
pip install -r requirements.txt
```

প্রথমবার চালালে MediaBrain স্থানীয়ভাবে `settings.json` তৈরি করে। সর্বজনীন টেমপ্লেট [settings.example.json](settings.example.json)। ব্যক্তিগত সেটিংস, ডেটাবেস, লগ ও বিল্ড আর্টিফ্যাক্ট `.gitignore` দিয়ে বাদ রাখা হয়।

## ব্যবহার

```bash
python MediaBrain.py
```

শুধু-পড়ার কমান্ড-লাইন ব্যবহার (ডেটাবেসে কখনও লেখে না):

```bash
python cli.py list
python cli.py search "title"
python cli.py --db /path/to/media_brain.db types
```

CLI ব্ল্যাকলিস্টে থাকা এন্ট্রি আড়াল করে। নির্দিষ্টভাবে ডেটাবেস বেছে নিতে `MEDIABRAIN_DB` সেট করুন বা `--db` ব্যবহার করুন।

Windows-এ ডাবল-ক্লিক লঞ্চার:

```bat
START.bat
```

হালকা Windows লঞ্চার তৈরি করা যায় এভাবে:

```bat
build_exe.bat
```

## পরীক্ষা

```bash
python -m pytest tests/ -q
```

টেস্ট স্যুটে ডেটাবেস ম্যানেজার, মেটাডেটা, ট্যাগ, QueryBuilder, প্লেলিস্ট এবং offscreen মোডে প্লেলিস্ট GUI-এর আচরণ অন্তর্ভুক্ত।

নির্দিষ্ট source-platform smoke test Unicode পাথ, কনফিগারেশন, JSON বিনিময়, অপারেটিং সিস্টেমের ফাইল ওপেনার এবং offscreen উইন্ডো/ট্রে জীবনচক্র পরীক্ষা করে:

```bash
python -m pytest tests/source_platform_smoke.py -q
```

GitHub Actions Ubuntu ও macOS-এ এই সীমিত smoke test চালায়। এটি সোর্স ও offscreen GUI চুক্তির পরীক্ষা; এটি নেটিভ প্যাকেজিং, ডেস্কটপ সেশনে ট্রে কাজ করা বা কোনো প্ল্যাটফর্মে হাতে করা গ্রহণযোগ্যতার প্রমাণ নয়।

## গোপনীয়তা

MediaBrain ব্যবহারের তথ্য স্থানীয় SQLite ডেটাবেস ও কনফিগারেশন ফাইলে রাখে। এতে টেলিমেট্রি বা স্বয়ংক্রিয় ক্লাউড সিঙ্ক নেই। ঐচ্ছিক মেটাডেটা অনুরোধে কেবল ব্যবহারকারীর কনফিগার করা TMDb/OMDb API কী বা MusicBrainz-এর উন্মুক্ত তথ্য ব্যবহৃত হয়। বিস্তারিত: [PRIVACY_POLICY.md](PRIVACY_POLICY.md)।

## লাইসেন্স

MIT লাইসেন্স; [LICENSE](LICENSE) দেখুন। সরাসরি ব্যবহৃত তৃতীয়-পক্ষের রানটাইম ও ডেভেলপমেন্ট নির্ভরতাগুলোর লাইসেন্স [THIRD_PARTY_LICENSES.txt](THIRD_PARTY_LICENSES.txt)-এ তালিকাভুক্ত। GUI-তে ব্যবহৃত PySide6 LGPL শর্তের অধীন।

## দায়বদ্ধতা

এই প্রকল্প বিনামূল্যে “যেমন আছে” তেমনভাবেই দেওয়া হয়; কোনো ওয়ারেন্টি, রক্ষণাবেক্ষণের নিশ্চয়তা বা নির্দিষ্ট উদ্দেশ্যে উপযোগিতার নিশ্চয়তা নেই। নিজের ঝুঁকিতে ব্যবহার করুন।
