<!-- worldset: {"translated_from_sha256": "c68d3298c39a37020989bae5d7410a91fa166d01a3120ebc3f91bb37a42bee89", "translator": "gpt-6-luna", "original_source_commit": "381af978ab857ac069ab2e272659ddda429e9993"} -->
<img src="assets/banner.png" width="100%" alt="لافتة MediaBrain">

# MediaBrain

[![الإصدار: 2.1.0](https://img.shields.io/badge/version-2.1.0-orange.svg)](version.py)
[![الترخيص: MIT](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)
[![Python 3.10+](https://img.shields.io/badge/python-3.10+-blue.svg)](https://www.python.org/)
[![المنصة: Windows](https://img.shields.io/badge/platform-Windows-lightgrey.svg)]()
[![الأولوية للعمل دون اتصال: نعم](https://img.shields.io/badge/offline--first-yes-brightgreen.svg)]()
[![الاختبارات: اجتاز 274](https://img.shields.io/badge/tests-274%20passed-brightgreen.svg)]()
[![doc-bricks](https://img.shields.io/badge/doc--bricks-ecosystem-blue.svg)](https://github.com/doc-bricks)
[![open-bricks](https://img.shields.io/badge/open--bricks-umbrella-purple.svg)](https://github.com/open-bricks)
[![سياق LLM](https://img.shields.io/badge/LLM--Context-llms.txt-blue.svg)](llms.txt)

> **MediaBrain هو مدير مكتبة وسائط مبني على PySide6 يعطي الأولوية للتخزين المحلي، لإدارة الفيديو والموسيقى وقوائم التشغيل وسجل المشاهدة عبر خدمات البث.**

> [!NOTE]
> **سياق الذكاء الاصطناعي والوكلاء**: تتوفر في [llms.txt](llms.txt) معلومات مقروءة آليًا عن بنية المستودع وفهارس الملفات وعبارات البحث وحدود النظام.

[English](README.md) | [Deutsch](README_de.md) | [Español](README_es.md) | [简体中文](README_zh.md) | [日本語](README_ja.md) | [Русский](README_ru.md) | [Français](README_fr.md) | [हिन्दी](README_hi.md) | **العربية** | [বাংলা](README_bn.md) | [Português](README_pt.md) | [الخصوصية](PRIVACY_POLICY.md) | [المساهمة](CONTRIBUTING.md) | [سجل التغييرات](CHANGELOG.md)

![النافذة الرئيسية لـ MediaBrain](README/screenshots/main.png)

## لغات التوثيق

| اللغة | المستند |
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

تعرض هذه القائمة إصدارات README الموثقة فقط، ولا تصف اللغات التي يدعمها التطبيق أثناء التشغيل.

## ابدأ من هنا

| ما تحتاج إليه | انتقل إلى |
|---|---|
| تشغيل تطبيق سطح المكتب | `python MediaBrain.py` |
| الاطلاع على إصدار Flutter للأجهزة المحمولة | `flutter_port/README.md` |
| معرفة حدود الخصوصية | [PRIVACY_POLICY.md](PRIVACY_POLICY.md) |
| فهم البنية | [ARCH.md](ARCH.md) |
| مراجعة الأعمال المخطط لها | [ROADMAP.md](ROADMAP.md) |
| الحصول على سياق مقروء آليًا | [llms.txt](llms.txt) |

## لماذا MediaBrain

صُمم MediaBrain لمن يريد مكانًا محليًا واحدًا لإدارة الوسائط التي يشاهدها أو يجمعها أو يضع لها وسومًا أو يضيفها إلى القائمة السوداء أو ينظمها عبر الخدمات والملفات المحلية. ليس خدمة بث مستضافة، ولا يرفع مكتبة خاصة إلى حساب سحابي.

- تخزين SQLite محلي لعناصر الوسائط والمفضلة والوسوم وعناصر القائمة السوداء وقوائم التشغيل
- واجهة سطح مكتب PySide6 تضم لوحة معلومات ومكتبات وبحثًا وإحصاءات وإعدادات وسمات عالية التباين
- طبقة مزودين لـ Netflix وYouTube وSpotify وDisney+ وPrime Video وApple TV+ وTwitch والملفات المحلية
- قوائم تشغيل يدوية وذكية تستند إلى قواعد QueryBuilder
- بحث اختياري عن البيانات الوصفية باستخدام مفاتيح TMDb/OMDb التي يهيئها المستخدم أو بيانات MusicBrainz العامة
- لا قياس عن بُعد ولا تتبّع ولا مزامنة سحابية تلقائية

## سياق البحث

هذا المستودع هو الموطن الرسمي على GitHub لما يلي:

- `doc-bricks MediaBrain`
- `MediaBrain media library manager`
- `private SQLite media library manager`
- `local-first PySide6 media manager`
- `PySide6 smart playlist media manager`
- `offline media hub with smart playlists`
- `desktop media history tracker`
- `privacy-first media history desktop app`

يتطابق اسم «MediaBrain» مع أسماء شركات لتحليلات الوسائط ومختبرات ذكاء اصطناعي للوسائط وأدوات عامة لتخطيط الوسائط. يخص هذا المستودع تحديدًا مكتبة الوسائط المكتبية ذات الأولوية للتخزين المحلي `doc-bricks/MediaBrain`، وليس منصة تحليلات إعلانية سحابية أو مختبر أبحاث متعددة الوسائط أو مولّدًا للوسائط بالذكاء الاصطناعي.

## البنية

```text
Core Layer        Database, MediaManager, BlacklistManager, TagManager, PlaylistManager
Query Layer       QueryBuilder for advanced filters and smart playlists
Provider Layer    Netflix, YouTube, Spotify, Disney+, Prime, AppleTV+, Twitch, Local
Background Layer  FileIndexer, WindowWatcher
GUI Layer         Dashboard, Libraries, Favorites, Blacklist, Playlists, Search, Stats, Settings
```

المخطط الكامل: [ARCH.md](ARCH.md)

## المنظومة والأدوات المرتبطة

يندرج MediaBrain ضمن حزمة الوثائق والإنتاجية [`doc-bricks`](https://github.com/doc-bricks) تحت المظلة [`open-bricks`](https://github.com/open-bricks):

| الأداة | المجال | المستودع |
|---|---|---|
| **MediaBrain** | سجل وسائط محلي وقوائم تشغيل ذكية وإدارة مكتبة الوسائط | [doc-bricks/MediaBrain](https://github.com/doc-bricks/MediaBrain) |
| **CleanMarkdown** | توحيد الطباعة وتنظيف Markdown وتصدير PDF | [doc-bricks/CleanMarkdown](https://github.com/doc-bricks/CleanMarkdown) |
| **PDFtoPDFocr** | مسار OCR لملفات PDF القابلة للبحث واستخراج البيانات الوصفية | [doc-bricks/PDFtoPDFocr](https://github.com/doc-bricks/PDFtoPDFocr) |
| **llm-note** | دفتر ملاحظات محلي باستخدام SQLite والنص العادي لملاحظات شخصية أو مكتوبة بواسطة وكلاء | [doc-bricks/llm-note](https://github.com/doc-bricks/llm-note) |
| **LaunchBoards** | مشغّل مرئي ومنظّم للتطبيقات ولوحة عمل | [file-bricks/LaunchBoards](https://github.com/file-bricks/LaunchBoards) |
| **ProFiler** | محلل وفاحص ملفات يركز على الخصوصية ويكشف الملفات المكررة | [file-bricks/ProFiler](https://github.com/file-bricks/ProFiler) |
| **KnowledgeDigest** | قاعدة معرفة دون اتصال وأداة لضغط التوثيق | [file-bricks/KnowledgeDigest](https://github.com/file-bricks/KnowledgeDigest) |
| **WinStorePackager** | تعبئة MSIX وتجهيز بيانات Store الوصفية وإنشاء الأصول | [file-bricks/WinStorePackager](https://github.com/file-bricks/WinStorePackager) |
| **DevCenter** | لوحة مطورين متعددة المستودعات ومراقب CI ومدير لمساحات العمل | [dev-bricks/DevCenter](https://github.com/dev-bricks/DevCenter) |
| **open-bricks** | بوابة موحدة لتطبيقات سطح المكتب وأدوات CLI | [open-bricks/open-bricks](https://github.com/open-bricks/open-bricks) |

## التثبيت

المتطلبات:

- Python 3.10 أو أحدث
- Windows أو Linux أو macOS مع دعم Qt/PySide6

```bash
pip install -r requirements.txt
```

عند التشغيل لأول مرة، ينشئ MediaBrain ملف `settings.json` محليًا. القالب العام هو [settings.example.json](settings.example.json). تُستبعد الإعدادات الشخصية وقواعد البيانات والسجلات ومخرجات البناء عبر `.gitignore`.

## الاستخدام

```bash
python MediaBrain.py
```

استخدام سطر الأوامر للقراءة فقط (لا يكتب مطلقًا في قاعدة البيانات):

```bash
python cli.py list
python cli.py search "title"
python cli.py --db /path/to/media_brain.db types
```

تخفي CLI العناصر المدرجة في القائمة السوداء. عيّن `MEDIABRAIN_DB` أو استخدم `--db` لاختيار قاعدة بيانات صراحةً.

مشغّل Windows بالنقر المزدوج:

```bat
START.bat
```

يمكن إنشاء مشغّل Windows خفيف باستخدام:

```bat
build_exe.bat
```

## الاختبارات

```bash
python -m pytest tests/ -q
```

تغطي مجموعة الاختبارات مديري قواعد البيانات والبيانات الوصفية والوسوم وQueryBuilder وقوائم التشغيل وسلوك واجهة قوائم التشغيل في وضع offscreen.

يفحص اختبار smoke مخصص لمنصة المصدر مسارات Unicode والإعدادات وتبادل JSON وفتّاح الملفات في نظام التشغيل ودورة حياة النافذة/علبة النظام في وضع offscreen:

```bash
python -m pytest tests/source_platform_smoke.py -q
```

تشغّل GitHub Actions هذا الاختبار المحدود على Ubuntu وmacOS. وهو يتحقق من عقد الشيفرة المصدرية وواجهة GUI في وضع offscreen؛ ولا يثبت التغليف الأصلي أو عمل علبة النظام ضمن جلسة سطح المكتب أو القبول اليدوي على أي من المنصتين.

## الخصوصية

يخزن MediaBrain بيانات الاستخدام محليًا في قواعد SQLite وملفات الإعدادات. لا يحتوي على قياس عن بُعد ولا على مزامنة سحابية تلقائية. لا تستخدم طلبات البيانات الوصفية الاختيارية سوى مفاتيح API لـ TMDb/OMDb يهيئها المستخدم أو بيانات MusicBrainz العامة. التفاصيل: [PRIVACY_POLICY.md](PRIVACY_POLICY.md).

## الترخيص

الترخيص MIT، راجع [LICENSE](LICENSE). تُدرج تراخيص تبعيات الطرف الثالث المباشرة لوقت التشغيل والتطوير في [THIRD_PARTY_LICENSES.txt](THIRD_PARTY_LICENSES.txt). وتخضع PySide6 المستخدمة في GUI لشروط LGPL.

## المسؤولية

يُقدَّم هذا المشروع مجانًا «كما هو»، من دون أي ضمان أو تعهّد بالصيانة أو ضمان للملاءمة لغرض معيّن. استخدمه على مسؤوليتك الخاصة.
