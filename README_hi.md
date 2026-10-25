<!-- worldset: {"translated_from_sha256": "c68d3298c39a37020989bae5d7410a91fa166d01a3120ebc3f91bb37a42bee89", "translator": "gpt-6-luna", "original_source_commit": "381af978ab857ac069ab2e272659ddda429e9993"} -->
<img src="assets/banner.png" width="100%" alt="MediaBrain बैनर">

# MediaBrain

[![संस्करण: 2.1.0](https://img.shields.io/badge/version-2.1.0-orange.svg)](version.py)
[![लाइसेंस: MIT](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)
[![Python 3.10+](https://img.shields.io/badge/python-3.10+-blue.svg)](https://www.python.org/)
[![प्लेटफ़ॉर्म: Windows](https://img.shields.io/badge/platform-Windows-lightgrey.svg)]()
[![ऑफ़लाइन उपयोग प्राथमिक: हाँ](https://img.shields.io/badge/offline--first-yes-brightgreen.svg)]()
[![परीक्षण: 274 सफल](https://img.shields.io/badge/tests-274%20passed-brightgreen.svg)]()
[![doc-bricks](https://img.shields.io/badge/doc--bricks-ecosystem-blue.svg)](https://github.com/doc-bricks)
[![open-bricks](https://img.shields.io/badge/open--bricks-umbrella-purple.svg)](https://github.com/open-bricks)
[![LLM संदर्भ](https://img.shields.io/badge/LLM--Context-llms.txt-blue.svg)](llms.txt)

> **MediaBrain PySide6 पर आधारित मीडिया लाइब्रेरी मैनेजर है, जो डेटा को पहले स्थानीय रूप से रखने को प्राथमिकता देता है और व्यक्तिगत वीडियो, संगीत, प्लेलिस्ट तथा स्ट्रीमिंग सेवाओं के देखने के इतिहास को व्यवस्थित करता है।**

> [!NOTE]
> **AI / एजेंट संदर्भ**: रिपॉज़िटरी की संरचना, फ़ाइल इंडेक्स, खोज वाक्यांश और सिस्टम की सीमाओं की मशीन-पठनीय जानकारी [llms.txt](llms.txt) में उपलब्ध है।

[English](README.md) | [Deutsch](README_de.md) | [Español](README_es.md) | [简体中文](README_zh.md) | [日本語](README_ja.md) | [Русский](README_ru.md) | [Français](README_fr.md) | **हिन्दी** | [العربية](README_ar.md) | [বাংলা](README_bn.md) | [Português](README_pt.md) | [गोपनीयता](PRIVACY_POLICY.md) | [योगदान](CONTRIBUTING.md) | [बदलाव सूची](CHANGELOG.md)

![MediaBrain की मुख्य विंडो](README/screenshots/main.png)

## दस्तावेज़ की भाषाएँ

| भाषा | दस्तावेज़ |
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

यह सूची केवल README के दस्तावेज़ी भाषा संस्करण दिखाती है। यह ऐप के रनटाइम भाषा समर्थन का दावा नहीं करती।

## यहाँ से शुरू करें

| आवश्यकता | यहाँ जाएँ |
|---|---|
| डेस्कटॉप ऐप चलाएँ | `python MediaBrain.py` |
| Flutter मोबाइल संस्करण देखें | `flutter_port/README.md` |
| गोपनीयता की सीमाएँ देखें | [PRIVACY_POLICY.md](PRIVACY_POLICY.md) |
| आर्किटेक्चर समझें | [ARCH.md](ARCH.md) |
| नियोजित काम देखें | [ROADMAP.md](ROADMAP.md) |
| मशीन-पठनीय संदर्भ पाएँ | [llms.txt](llms.txt) |

## MediaBrain क्यों

MediaBrain उन लोगों के लिए है जो अलग-अलग सेवाओं और स्थानीय फ़ाइलों में मौजूद अपने देखे, संग्रहित, टैग किए, ब्लैकलिस्ट में डाले या व्यवस्थित किए गए मीडिया को एक स्थानीय जगह पर रखना चाहते हैं। यह होस्टेड स्ट्रीमिंग सेवा नहीं है और यह निजी लाइब्रेरी को किसी क्लाउड खाते पर अपलोड नहीं करता।

- मीडिया प्रविष्टियों, पसंदीदा वस्तुओं, टैग, ब्लैकलिस्ट आइटम और प्लेलिस्ट के लिए स्थानीय SQLite स्टोरेज
- डैशबोर्ड, लाइब्रेरी, खोज, आँकड़े, सेटिंग और उच्च-कंट्रास्ट थीम वाला PySide6 डेस्कटॉप UI
- Netflix, YouTube, Spotify, Disney+, Prime Video, Apple TV+, Twitch और स्थानीय फ़ाइलों के लिए प्रदाता परत
- मैन्युअल प्लेलिस्ट और QueryBuilder नियमों पर आधारित स्मार्ट प्लेलिस्ट
- उपयोगकर्ता द्वारा कॉन्फ़िगर की गई TMDb/OMDb कुंजियों या सार्वजनिक MusicBrainz डेटा से वैकल्पिक मेटाडेटा खोज
- कोई टेलीमेट्री, ट्रैकिंग या स्वचालित क्लाउड सिंक नहीं

## खोज संदर्भ

यह रिपॉज़िटरी निम्नलिखित के लिए आधिकारिक GitHub स्थान है:

- `doc-bricks MediaBrain`
- `MediaBrain media library manager`
- `private SQLite media library manager`
- `local-first PySide6 media manager`
- `PySide6 smart playlist media manager`
- `offline media hub with smart playlists`
- `desktop media history tracker`
- `privacy-first media history desktop app`

“MediaBrain” नाम मीडिया एनालिटिक्स कंपनियों, AI मीडिया लैब और सामान्य मीडिया-प्लानिंग टूल के नामों से मिलता-जुलता है। यह रिपॉज़िटरी विशेष रूप से स्थानीय प्राथमिकता वाले डेस्कटॉप मीडिया लाइब्रेरी `doc-bricks/MediaBrain` के लिए है; यह क्लाउड विज्ञापन-एनालिटिक्स प्लेटफ़ॉर्म, मल्टीमीडिया शोध लैब या AI मीडिया जनरेटर नहीं है।

## आर्किटेक्चर

```text
Core Layer        Database, MediaManager, BlacklistManager, TagManager, PlaylistManager
Query Layer       QueryBuilder for advanced filters and smart playlists
Provider Layer    Netflix, YouTube, Spotify, Disney+, Prime, AppleTV+, Twitch, Local
Background Layer  FileIndexer, WindowWatcher
GUI Layer         Dashboard, Libraries, Favorites, Blacklist, Playlists, Search, Stats, Settings
```

पूरा आरेख: [ARCH.md](ARCH.md)

## इकोसिस्टम और संबंधित टूल

MediaBrain [`doc-bricks`](https://github.com/doc-bricks) के दस्तावेज़ और उत्पादकता टूल-संग्रह का हिस्सा है, जो [`open-bricks`](https://github.com/open-bricks) के अंतर्गत आता है:

| टूल | उद्देश्य | रिपॉज़िटरी |
|---|---|---|
| **MediaBrain** | स्थानीय मीडिया इतिहास, स्मार्ट प्लेलिस्ट और लाइब्रेरी प्रबंधन | [doc-bricks/MediaBrain](https://github.com/doc-bricks/MediaBrain) |
| **CleanMarkdown** | टाइपोग्राफी सामान्यीकरण, Markdown सफ़ाई और PDF निर्यात | [doc-bricks/CleanMarkdown](https://github.com/doc-bricks/CleanMarkdown) |
| **PDFtoPDFocr** | खोज योग्य PDF के लिए OCR पाइपलाइन और मेटाडेटा निष्कर्षण | [doc-bricks/PDFtoPDFocr](https://github.com/doc-bricks/PDFtoPDFocr) |
| **llm-note** | व्यक्तिगत या एजेंट द्वारा लिखे नोट्स के लिए स्थानीय SQLite और साधारण-पाठ नोटबुक | [doc-bricks/llm-note](https://github.com/doc-bricks/llm-note) |
| **LaunchBoards** | दृश्य लॉन्चर, ऐप आयोजक और वर्कस्टेशन डैशबोर्ड | [file-bricks/LaunchBoards](https://github.com/file-bricks/LaunchBoards) |
| **ProFiler** | गोपनीयता-केंद्रित फ़ाइल विश्लेषक, निरीक्षक और डुप्लिकेट खोजक | [file-bricks/ProFiler](https://github.com/file-bricks/ProFiler) |
| **KnowledgeDigest** | ऑफ़लाइन ज्ञान आधार और दस्तावेज़ संपीड़क | [file-bricks/KnowledgeDigest](https://github.com/file-bricks/KnowledgeDigest) |
| **WinStorePackager** | MSIX पैकेजिंग, Store मेनिफ़ेस्ट तैयारी और एसेट जनरेटर | [file-bricks/WinStorePackager](https://github.com/file-bricks/WinStorePackager) |
| **DevCenter** | बहु-रिपॉज़िटरी डेवलपर डैशबोर्ड, CI मॉनिटर और वर्कस्पेस मैनेजर | [dev-bricks/DevCenter](https://github.com/dev-bricks/DevCenter) |
| **open-bricks** | सभी डेस्कटॉप और CLI टूल का एकीकृत पोर्टल | [open-bricks/open-bricks](https://github.com/open-bricks/open-bricks) |

## इंस्टॉलेशन

आवश्यकताएँ:

- Python 3.10 या नया संस्करण
- Qt/PySide6 समर्थन वाला Windows, Linux या macOS

```bash
pip install -r requirements.txt
```

पहली बार चलने पर MediaBrain स्थानीय रूप से `settings.json` बनाता है। सार्वजनिक टेम्पलेट [settings.example.json](settings.example.json) है। व्यक्तिगत सेटिंग, डेटाबेस, लॉग और बिल्ड आर्टिफ़ैक्ट `.gitignore` के ज़रिए बाहर रखे जाते हैं।

## उपयोग

```bash
python MediaBrain.py
```

केवल पढ़ने के लिए कमांड-लाइन पहुँच (डेटाबेस में कभी लिखता नहीं):

```bash
python cli.py list
python cli.py search "title"
python cli.py --db /path/to/media_brain.db types
```

CLI ब्लैकलिस्ट किए गए आइटम छिपाता है। डेटाबेस स्पष्ट रूप से चुनने के लिए `MEDIABRAIN_DB` सेट करें या `--db` का उपयोग करें।

Windows पर डबल-क्लिक लॉन्चर:

```bat
START.bat
```

हल्का Windows लॉन्चर इस कमांड से बनाया जा सकता है:

```bat
build_exe.bat
```

## परीक्षण

```bash
python -m pytest tests/ -q
```

टेस्ट सूट डेटाबेस मैनेजर, मेटाडेटा, टैग, QueryBuilder, प्लेलिस्ट और offscreen मोड में प्लेलिस्ट GUI व्यवहार को कवर करता है।

समर्पित source-platform smoke test Unicode पथ, कॉन्फ़िगरेशन, JSON आदान-प्रदान, ऑपरेटिंग सिस्टम के फ़ाइल ओपनर और offscreen विंडो/ट्रे जीवनचक्र की जाँच करता है:

```bash
python -m pytest tests/source_platform_smoke.py -q
```

GitHub Actions यह सीमित smoke test Ubuntu और macOS पर चलाता है। यह सोर्स और offscreen GUI अनुबंध की जाँच है; यह नेटिव पैकेजिंग, डेस्कटॉप सत्र में ट्रे व्यवहार या किसी भी प्लेटफ़ॉर्म पर मैन्युअल स्वीकृति का प्रमाण नहीं है।

## गोपनीयता

MediaBrain उपयोग डेटा को स्थानीय SQLite डेटाबेस और कॉन्फ़िगरेशन फ़ाइलों में रखता है। इसमें टेलीमेट्री या स्वचालित क्लाउड सिंक नहीं है। वैकल्पिक मेटाडेटा अनुरोध केवल उपयोगकर्ता द्वारा कॉन्फ़िगर की गई TMDb/OMDb API कुंजियों या सार्वजनिक MusicBrainz डेटा का उपयोग करते हैं। विवरण: [PRIVACY_POLICY.md](PRIVACY_POLICY.md)।

## लाइसेंस

MIT लाइसेंस; [LICENSE](LICENSE) देखें। सीधे उपयोग की जाने वाली तृतीय-पक्ष रनटाइम और डेवलपमेंट निर्भरताओं के लाइसेंस [THIRD_PARTY_LICENSES.txt](THIRD_PARTY_LICENSES.txt) में सूचीबद्ध हैं। GUI का PySide6 LGPL की शर्तों के अधीन है।

## दायित्व

यह परियोजना निःशुल्क और “जैसी है” वैसी ही प्रदान की जाती है; इसकी कोई वारंटी, रखरखाव की गारंटी या किसी विशेष उद्देश्य के लिए उपयुक्तता की गारंटी नहीं है। इसका उपयोग अपने जोखिम पर करें।
