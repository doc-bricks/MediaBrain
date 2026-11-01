// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Hindi (`hi`).
class AppLocalizationsHi extends AppLocalizations {
  AppLocalizationsHi([String locale = 'hi']) : super(locale);

  @override
  String get appTitle => 'MediaBrain';

  @override
  String get navLibrary => 'लाइब्रेरी';

  @override
  String get navScan => 'स्कैन';

  @override
  String get navMore => 'और';

  @override
  String get screenLibrary => 'लाइब्रेरी';

  @override
  String get fabAdd => 'जोड़ें';

  @override
  String get searchHint => 'खोजें (शीर्षक, कलाकार, चैनल …)';

  @override
  String get filterAll => 'सभी';

  @override
  String get filterFavorites => '⭐ पसंदीदा';

  @override
  String get emptyNoMatch => 'आपके फ़िल्टर से कोई परिणाम नहीं मिला।';

  @override
  String get emptyNoItems =>
      'अभी खाली है।\nअपने मीडिया ऐप अपने-आप पहचानने के लिए स्कैन टैब पर टैप करें।';

  @override
  String get screenScan => 'स्कैन';

  @override
  String get scanDescription =>
      'इंस्टॉल किए गए मीडिया ऐप (स्ट्रीमिंग, संगीत, पॉडकास्ट, दस्तावेज़) खोजता है और उन्हें आपकी लाइब्रेरी में जोड़ता है। उपयोग डेटा की अनुमति चालू होने पर वास्तविक उपयोग समय भी मिलता है।';

  @override
  String get btnAppScan => 'ऐप स्कैन (कुल उपयोग)';

  @override
  String get bgScanTitle => 'बैकग्राउंड स्कैन';

  @override
  String get bgScanNow => 'अभी एक बार बैकग्राउंड में चलाएँ';

  @override
  String get bgScanNowSubtitle =>
      'Android को एक बार चलने वाला टास्क भेजता है। परिणाम 1–2 मिनट बाद दिखेगा।';

  @override
  String get bgScanQueued =>
      'बैकग्राउंड स्कैन कतार में है — परिणाम लगभग 1 मिनट में दिखेगा';

  @override
  String get scanAndroidOnly => 'स्कैन केवल Android पर उपलब्ध है।';

  @override
  String get scanPermissionMissing =>
      'उपयोग डेटा की अनुमति नहीं है। MediaBrain के लिए सिस्टम सेटिंग में इसे चालू करें:\n\nसेटिंग → ऐप्स → विशेष ऐप एक्सेस → उपयोग डेटा एक्सेस → MediaBrain।';

  @override
  String get detectedTitle => '📡 क्या पहचाना जाता है?';

  @override
  String get detectedApps =>
      'Netflix · Disney+ · Prime Video · Apple TV · YouTube · Twitch · Spotify · Apple Music · YouTube Music · Tidal · Amazon Music · Audible · Kindle · Pocket Casts · Google Podcasts · Adobe Acrobat · Google Docs · Notion · Obsidian और अन्य।';

  @override
  String get appScanTitle => '🔍 ऐप स्कैन';

  @override
  String get appScanDescription =>
      'ऐप स्कैन: हर मीडिया ऐप के लिए एक प्रविष्टि, जिसमें पिछले दिनों का कुल उपयोग दिखता है (Android उपयोग आँकड़ों से)।';

  @override
  String get neverText => 'कभी नहीं';

  @override
  String get screenSettings => 'सेटिंग्स';

  @override
  String get sectionDataStatus => 'डेटा स्थिति';

  @override
  String get sectionFileSync => 'फ़ाइल सिंक';

  @override
  String get sectionServerSync => 'सर्वर सिंक (Mac Studio)';

  @override
  String get sectionActions => 'कार्रवाइयाँ';

  @override
  String get settingsTotalEntries => 'कुल प्रविष्टियाँ';

  @override
  String get settingsLastScan => 'अंतिम स्कैन';

  @override
  String get exportTitle => 'शेयर के ज़रिए निर्यात';

  @override
  String get exportSubtitle =>
      'ईमेल, OneDrive या Telegram से खुद को JSON भेजें …';

  @override
  String get importTitle => 'आयात फ़ाइल चुनें';

  @override
  String get importSubtitle => 'स्थानीय डेटा को बदल देता है';

  @override
  String get noServerConfigured => 'कोई सर्वर कॉन्फ़िगर नहीं है';

  @override
  String get actionPush => 'पुश';

  @override
  String get actionPull => 'पुल';

  @override
  String get refreshData => 'डेटा रीफ़्रेश करें';

  @override
  String get deleteAllData => 'लाइब्रेरी का सारा डेटा हटाएँ';

  @override
  String get deleteAllTitle => 'लाइब्रेरी का सारा डेटा हटाएँ?';

  @override
  String get deleteAllContent =>
      'स्थानीय MediaBrain से सभी प्रविष्टियाँ हटाता है।';

  @override
  String get cancel => 'रद्द करें';

  @override
  String get delete => 'हटाएँ';

  @override
  String get save => 'सहेजें';

  @override
  String get libraryCleared => 'लाइब्रेरी साफ़ कर दी गई।';

  @override
  String get cancelled => 'रद्द किया गया।';

  @override
  String get serverConfigTitle => 'सर्वर सिंक कॉन्फ़िगर करें';

  @override
  String get fieldServerUrl => 'सर्वर URL';

  @override
  String get fieldServerUrlHint => 'जैसे, macstudvonlukas:8082';

  @override
  String get fieldBearerToken => 'Bearer टोकन';

  @override
  String get aboutTitle => 'MediaBrain Mobile';

  @override
  String get aboutSubtitle =>
      'स्वतंत्र Flutter ऐप। इंस्टॉल किए गए मीडिया ऐप पहचानता है, मैन्युअल प्रविष्टियाँ रखता है और फ़ाइल या सर्वर से सिंक करता है।';

  @override
  String get detailDescription => 'विवरण';

  @override
  String get detailDetails => 'जानकारी';

  @override
  String get detailTags => 'टैग';

  @override
  String get fieldArtist => 'कलाकार';

  @override
  String get fieldAlbum => 'एल्बम';

  @override
  String get fieldChannel => 'चैनल';

  @override
  String get fieldSeasonEpisodeLabel => 'सीज़न/एपिसोड';

  @override
  String get fieldLength => 'अवधि';

  @override
  String get fieldLastOpened => 'अंतिम बार खोला गया';

  @override
  String get fieldUsage => 'उपयोग';

  @override
  String get fieldProviderId => 'प्रदाता ID';

  @override
  String get fieldLocalPath => 'स्थानीय पथ';

  @override
  String get openPlayStore => 'Play Store में खोलें';

  @override
  String get openBrowser => 'ब्राउज़र में खोलें';

  @override
  String get linkError => 'लिंक नहीं खुल सका।';

  @override
  String get dialogTitleNew => 'नई प्रविष्टि';

  @override
  String get dialogTitleEdit => 'प्रविष्टि संपादित करें';

  @override
  String get fieldTitle => 'शीर्षक';

  @override
  String get categoryLabel => 'श्रेणी';

  @override
  String get fieldArtistOptional => 'कलाकार / निर्देशक (वैकल्पिक)';

  @override
  String get fieldAlbumOptional => 'एल्बम / सीरीज़ (वैकल्पिक)';

  @override
  String get fieldChannelOptional => 'चैनल / स्रोत (वैकल्पिक)';

  @override
  String get fieldDescriptionOptional => 'विवरण (वैकल्पिक)';

  @override
  String get fieldTags => 'टैग (अल्पविराम से अलग)';

  @override
  String get fieldTagsHint => 'जैसे, वृत्तचित्र, सप्ताहांत';

  @override
  String get markAsFavorite => 'पसंदीदा के रूप में चिह्नित करें';

  @override
  String error(String msg) {
    return 'त्रुटि: $msg';
  }

  @override
  String foregroundMinutesLabel(int minutes) {
    return 'कुल $minutes मिनट';
  }

  @override
  String bgScanSubtitle(int hours) {
    return 'ऐप बंद होने पर भी हर ~$hours घंटे में स्कैन करें।';
  }

  @override
  String lastRun(String time) {
    return 'अंतिम बार चला: $time';
  }

  @override
  String scanResult(int matched, int persisted) {
    return 'ऐप स्कैन: $matched मीडिया ऐप मिले, $persisted प्रविष्टियाँ जोड़ी गईं।';
  }

  @override
  String exportResult(String msg) {
    return 'निर्यात: $msg';
  }

  @override
  String importResult(String msg) {
    return 'आयात: $msg';
  }

  @override
  String pushPullStatus(String push, String pull) {
    return 'पुश: $push · पुल: $pull';
  }

  @override
  String seasonEpisode(int s, int e) {
    return 'S$s E$e';
  }

  @override
  String usageMinutes(int n) {
    return '$n मिनट';
  }

  @override
  String get navPlaylists => 'प्लेलिस्ट';

  @override
  String get screenPlaylists => 'प्लेलिस्ट और संग्रह';

  @override
  String get playlistTypeManual => 'मैन्युअल';

  @override
  String get playlistTypeSmart => 'स्मार्ट (डायनेमिक फ़िल्टर)';

  @override
  String get dialogNewPlaylist => 'नई प्लेलिस्ट';

  @override
  String get dialogEditPlaylist => 'प्लेलिस्ट संपादित करें';

  @override
  String get fieldPlaylistName => 'प्लेलिस्ट का नाम';

  @override
  String get fieldPlaylistDescription => 'विवरण (वैकल्पिक)';

  @override
  String get fieldPlaylistType => 'प्लेलिस्ट का प्रकार';

  @override
  String get smartFilterCriteria => 'स्मार्ट फ़िल्टर मानदंड';

  @override
  String get smartFilterCategory => 'श्रेणी';

  @override
  String get smartFilterTag => 'टैग / कीवर्ड';

  @override
  String get smartFilterFavoritesOnly => 'केवल पसंदीदा';

  @override
  String get smartFilterMinMinutes => 'न्यूनतम उपयोग समय (मिनट)';

  @override
  String get smartFilterSearch => 'खोज शब्द';

  @override
  String get emptyPlaylists =>
      'अभी कोई प्लेलिस्ट नहीं बनाई गई है।\nमैन्युअल संग्रह या डायनेमिक स्मार्ट प्लेलिस्ट बनाएँ।';

  @override
  String get emptyPlaylistItems => 'इस प्लेलिस्ट में अभी कोई मीडिया नहीं है।';

  @override
  String get deletePlaylistTitle => 'प्लेलिस्ट हटाएँ?';

  @override
  String get deletePlaylistContent =>
      'क्या आप वाकई यह प्लेलिस्ट हटाना चाहते हैं? इसमें मौजूद मीडिया आपकी लाइब्रेरी में रहेगा।';

  @override
  String get addToPlaylist => 'प्लेलिस्ट में जोड़ें';

  @override
  String get removeFromPlaylist => 'प्लेलिस्ट से हटाएँ';

  @override
  String get addedToPlaylist => 'प्लेलिस्ट में जोड़ा गया।';

  @override
  String get removedFromPlaylist => 'प्लेलिस्ट से हटाया गया।';

  @override
  String get filterByTag => 'टैग फ़िल्टर';

  @override
  String get allTags => 'सभी टैग';

  @override
  String get addTag => 'टैग जोड़ें';

  @override
  String get removeTag => 'टैग हटाएँ';

  @override
  String get noPlaylistsFound => 'कोई प्लेलिस्ट उपलब्ध नहीं है।';

  @override
  String playlistItemCount(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count आइटम',
      one: '$count आइटम',
    );
    return '$_temp0';
  }

  @override
  String tagCount(String tag, int count) {
    return '#$tag ($count)';
  }
}
