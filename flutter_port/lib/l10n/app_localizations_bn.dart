// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Bengali Bangla (`bn`).
class AppLocalizationsBn extends AppLocalizations {
  AppLocalizationsBn([String locale = 'bn']) : super(locale);

  @override
  String get appTitle => 'MediaBrain';

  @override
  String get navLibrary => 'লাইব্রেরি';

  @override
  String get navScan => 'স্ক্যান';

  @override
  String get navMore => 'আরও';

  @override
  String get screenLibrary => 'লাইব্রেরি';

  @override
  String get fabAdd => 'যোগ করুন';

  @override
  String get searchHint => 'খুঁজুন (শিরোনাম, শিল্পী, চ্যানেল …)';

  @override
  String get filterAll => 'সব';

  @override
  String get filterFavorites => '⭐ পছন্দের';

  @override
  String get emptyNoMatch =>
      'আপনার ফিল্টারের সঙ্গে মেলে এমন কিছু পাওয়া যায়নি।';

  @override
  String get emptyNoItems =>
      'এখনও খালি।\nমিডিয়া অ্যাপ স্বয়ংক্রিয়ভাবে শনাক্ত করতে স্ক্যান ট্যাবে ট্যাপ করুন।';

  @override
  String get screenScan => 'স্ক্যান';

  @override
  String get scanDescription =>
      'ইনস্টল করা মিডিয়া অ্যাপ (স্ট্রিমিং, সংগীত, পডকাস্ট, নথি) খুঁজে সেগুলো লাইব্রেরিতে যোগ করে। ব্যবহার-ডেটা অ্যাক্সেস চালু থাকলে প্রকৃত ব্যবহারের সময়ও পাওয়া যাবে।';

  @override
  String get btnAppScan => 'অ্যাপ স্ক্যান (সমষ্টিগত ব্যবহার)';

  @override
  String get bgScanTitle => 'ব্যাকগ্রাউন্ড স্ক্যান';

  @override
  String get bgScanNow => 'এখন একবার ব্যাকগ্রাউন্ডে চালান';

  @override
  String get bgScanNowSubtitle =>
      'Android-এ একবারের জন্য একটি কাজ পাঠায়। ১–২ মিনিট পরে ফলাফল দেখা যাবে।';

  @override
  String get bgScanQueued =>
      'ব্যাকগ্রাউন্ড স্ক্যান সারিতে আছে — প্রায় ১ মিনিটে ফলাফল দেখা যাবে';

  @override
  String get scanAndroidOnly => 'স্ক্যান শুধু Android-এ উপলভ্য।';

  @override
  String get scanPermissionMissing =>
      'ব্যবহার-ডেটা অ্যাক্সেস নেই। MediaBrain-এর জন্য সিস্টেম সেটিংসে এটি চালু করুন:\n\nসেটিংস → অ্যাপস → বিশেষ অ্যাপ অ্যাক্সেস → ব্যবহার-ডেটা অ্যাক্সেস → MediaBrain।';

  @override
  String get detectedTitle => '📡 কী শনাক্ত হয়?';

  @override
  String get detectedApps =>
      'Netflix · Disney+ · Prime Video · Apple TV · YouTube · Twitch · Spotify · Apple Music · YouTube Music · Tidal · Amazon Music · Audible · Kindle · Pocket Casts · Google Podcasts · Adobe Acrobat · Google Docs · Notion · Obsidian এবং আরও।';

  @override
  String get appScanTitle => '🔍 অ্যাপ স্ক্যান';

  @override
  String get appScanDescription =>
      'অ্যাপ স্ক্যান: প্রতিটি মিডিয়া অ্যাপের জন্য একটি এন্ট্রি, যেখানে সাম্প্রতিক দিনগুলোর মোট ব্যবহার দেখানো হয় (Android ব্যবহারের পরিসংখ্যান থেকে)।';

  @override
  String get neverText => 'কখনও নয়';

  @override
  String get screenSettings => 'সেটিংস';

  @override
  String get sectionDataStatus => 'ডেটার অবস্থা';

  @override
  String get sectionFileSync => 'ফাইল সিঙ্ক';

  @override
  String get sectionServerSync => 'সার্ভার সিঙ্ক (Mac Studio)';

  @override
  String get sectionActions => 'কাজ';

  @override
  String get settingsTotalEntries => 'মোট এন্ট্রি';

  @override
  String get settingsLastScan => 'শেষ স্ক্যান';

  @override
  String get exportTitle => 'শেয়ার দিয়ে রপ্তানি';

  @override
  String get exportSubtitle =>
      'ইমেল, OneDrive বা Telegram দিয়ে নিজের কাছে JSON পাঠান …';

  @override
  String get importTitle => 'আমদানি ফাইল বেছে নিন';

  @override
  String get importSubtitle => 'স্থানীয় ডেটা মুছে প্রতিস্থাপন করে';

  @override
  String get noServerConfigured => 'কোনো সার্ভার কনফিগার করা নেই';

  @override
  String get actionPush => 'পুশ';

  @override
  String get actionPull => 'পুল';

  @override
  String get refreshData => 'ডেটা রিফ্রেশ করুন';

  @override
  String get deleteAllData => 'লাইব্রেরির সব ডেটা মুছুন';

  @override
  String get deleteAllTitle => 'লাইব্রেরির সব ডেটা মুছবেন?';

  @override
  String get deleteAllContent =>
      'স্থানীয় MediaBrain থেকে সব এন্ট্রি সরিয়ে দেয়।';

  @override
  String get cancel => 'বাতিল';

  @override
  String get delete => 'মুছুন';

  @override
  String get save => 'সংরক্ষণ';

  @override
  String get libraryCleared => 'লাইব্রেরি খালি করা হয়েছে।';

  @override
  String get cancelled => 'বাতিল হয়েছে।';

  @override
  String get serverConfigTitle => 'সার্ভার সিঙ্ক কনফিগার করুন';

  @override
  String get fieldServerUrl => 'সার্ভার URL';

  @override
  String get fieldServerUrlHint => 'যেমন: macstudvonlukas:8082';

  @override
  String get fieldBearerToken => 'Bearer টোকেন';

  @override
  String get aboutTitle => 'MediaBrain Mobile';

  @override
  String get aboutSubtitle =>
      'স্বতন্ত্র Flutter অ্যাপ। ইনস্টল করা মিডিয়া অ্যাপ শনাক্ত করে, হাতে যোগ করা এন্ট্রি রাখে এবং ফাইল বা সার্ভারের মাধ্যমে সিঙ্ক করে।';

  @override
  String get detailDescription => 'বিবরণ';

  @override
  String get detailDetails => 'বিস্তারিত';

  @override
  String get detailTags => 'ট্যাগ';

  @override
  String get fieldArtist => 'শিল্পী';

  @override
  String get fieldAlbum => 'অ্যালবাম';

  @override
  String get fieldChannel => 'চ্যানেল';

  @override
  String get fieldSeasonEpisodeLabel => 'সিজন/পর্ব';

  @override
  String get fieldLength => 'সময়কাল';

  @override
  String get fieldLastOpened => 'শেষ খোলা';

  @override
  String get fieldUsage => 'ব্যবহার';

  @override
  String get fieldProviderId => 'প্রোভাইডার ID';

  @override
  String get fieldLocalPath => 'স্থানীয় পথ';

  @override
  String get openPlayStore => 'Play Store-এ খুলুন';

  @override
  String get openBrowser => 'ব্রাউজারে খুলুন';

  @override
  String get linkError => 'লিংক খোলা যায়নি।';

  @override
  String get dialogTitleNew => 'নতুন এন্ট্রি';

  @override
  String get dialogTitleEdit => 'এন্ট্রি সম্পাদনা করুন';

  @override
  String get fieldTitle => 'শিরোনাম';

  @override
  String get categoryLabel => 'বিভাগ';

  @override
  String get fieldArtistOptional => 'শিল্পী / পরিচালক (ঐচ্ছিক)';

  @override
  String get fieldAlbumOptional => 'অ্যালবাম / সিরিজ (ঐচ্ছিক)';

  @override
  String get fieldChannelOptional => 'চ্যানেল / উৎস (ঐচ্ছিক)';

  @override
  String get fieldDescriptionOptional => 'বিবরণ (ঐচ্ছিক)';

  @override
  String get fieldTags => 'ট্যাগ (কমা দিয়ে আলাদা)';

  @override
  String get fieldTagsHint => 'যেমন: প্রামাণ্যচিত্র, ছুটির দিন';

  @override
  String get markAsFavorite => 'পছন্দের হিসেবে চিহ্নিত করুন';

  @override
  String error(String msg) {
    return 'ত্রুটি: $msg';
  }

  @override
  String foregroundMinutesLabel(int minutes) {
    return 'মোট $minutes মিনিট';
  }

  @override
  String bgScanSubtitle(int hours) {
    return 'অ্যাপ বন্ধ থাকলেও প্রতি ~$hours ঘণ্টায় স্ক্যান করুন।';
  }

  @override
  String lastRun(String time) {
    return 'শেষ চালানো: $time';
  }

  @override
  String scanResult(int matched, int persisted) {
    return 'অ্যাপ স্ক্যান: $matchedটি মিডিয়া অ্যাপ পাওয়া গেছে, $persistedটি এন্ট্রি যোগ হয়েছে।';
  }

  @override
  String exportResult(String msg) {
    return 'রপ্তানি: $msg';
  }

  @override
  String importResult(String msg) {
    return 'আমদানি: $msg';
  }

  @override
  String pushPullStatus(String push, String pull) {
    return 'পুশ: $push · পুল: $pull';
  }

  @override
  String seasonEpisode(int s, int e) {
    return 'S$s E$e';
  }

  @override
  String usageMinutes(int n) {
    return '$n মিনিট';
  }

  @override
  String get navPlaylists => 'প্লেলিস্ট';

  @override
  String get screenPlaylists => 'প্লেলিস্ট ও সংগ্রহ';

  @override
  String get playlistTypeManual => 'ম্যানুয়াল';

  @override
  String get playlistTypeSmart => 'স্মার্ট (ডায়নামিক ফিল্টার)';

  @override
  String get dialogNewPlaylist => 'নতুন প্লেলিস্ট';

  @override
  String get dialogEditPlaylist => 'প্লেলিস্ট সম্পাদনা করুন';

  @override
  String get fieldPlaylistName => 'প্লেলিস্টের নাম';

  @override
  String get fieldPlaylistDescription => 'বিবরণ (ঐচ্ছিক)';

  @override
  String get fieldPlaylistType => 'প্লেলিস্টের ধরন';

  @override
  String get smartFilterCriteria => 'স্মার্ট ফিল্টারের মানদণ্ড';

  @override
  String get smartFilterCategory => 'বিভাগ';

  @override
  String get smartFilterTag => 'ট্যাগ / কীওয়ার্ড';

  @override
  String get smartFilterFavoritesOnly => 'শুধু পছন্দের';

  @override
  String get smartFilterMinMinutes => 'সর্বনিম্ন ব্যবহারের সময় (মিনিট)';

  @override
  String get smartFilterSearch => 'অনুসন্ধানের শব্দ';

  @override
  String get emptyPlaylists =>
      'এখনও কোনো প্লেলিস্ট তৈরি হয়নি।\nম্যানুয়াল সংগ্রহ বা ডায়নামিক স্মার্ট প্লেলিস্ট তৈরি করুন।';

  @override
  String get emptyPlaylistItems => 'এই প্লেলিস্টে এখনও কোনো মিডিয়া নেই।';

  @override
  String get deletePlaylistTitle => 'প্লেলিস্ট মুছবেন?';

  @override
  String get deletePlaylistContent =>
      'আপনি কি সত্যিই এই প্লেলিস্টটি মুছতে চান? এর মিডিয়া লাইব্রেরিতে থেকে যাবে।';

  @override
  String get addToPlaylist => 'প্লেলিস্টে যোগ করুন';

  @override
  String get removeFromPlaylist => 'প্লেলিস্ট থেকে সরান';

  @override
  String get addedToPlaylist => 'প্লেলিস্টে যোগ করা হয়েছে।';

  @override
  String get removedFromPlaylist => 'প্লেলিস্ট থেকে সরানো হয়েছে।';

  @override
  String get filterByTag => 'ট্যাগ ফিল্টার';

  @override
  String get allTags => 'সব ট্যাগ';

  @override
  String get addTag => 'ট্যাগ যোগ করুন';

  @override
  String get removeTag => 'ট্যাগ সরান';

  @override
  String get noPlaylistsFound => 'কোনো প্লেলিস্ট নেই।';

  @override
  String playlistItemCount(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$countটি আইটেম',
      one: '$countটি আইটেম',
    );
    return '$_temp0';
  }

  @override
  String tagCount(String tag, int count) {
    return '#$tag ($count)';
  }
}
