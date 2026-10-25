// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Arabic (`ar`).
class AppLocalizationsAr extends AppLocalizations {
  AppLocalizationsAr([String locale = 'ar']) : super(locale);

  @override
  String get appTitle => 'MediaBrain';

  @override
  String get navLibrary => 'المكتبة';

  @override
  String get navScan => 'فحص';

  @override
  String get navMore => 'المزيد';

  @override
  String get screenLibrary => 'المكتبة';

  @override
  String get fabAdd => 'إضافة';

  @override
  String get searchHint => 'بحث (العنوان، الفنان، القناة …)';

  @override
  String get filterAll => 'الكل';

  @override
  String get filterFavorites => '⭐ المفضلة';

  @override
  String get emptyNoMatch => 'لا توجد نتائج تطابق عوامل التصفية.';

  @override
  String get emptyNoItems =>
      'لا توجد عناصر بعد.\nاضغط علامة تبويب الفحص لاكتشاف تطبيقات الوسائط تلقائيًا.';

  @override
  String get screenScan => 'فحص';

  @override
  String get scanDescription =>
      'يبحث عن تطبيقات الوسائط المثبتة (البث والموسيقى والبودكاست والمستندات) ويضيفها إلى مكتبتك. عند تفعيل الوصول إلى بيانات الاستخدام، ستحصل أيضًا على مدة الاستخدام الفعلية.';

  @override
  String get btnAppScan => 'فحص التطبيقات (إجمالي الاستخدام)';

  @override
  String get bgScanTitle => 'الفحص في الخلفية';

  @override
  String get bgScanNow => 'التشغيل مرة واحدة في الخلفية الآن';

  @override
  String get bgScanNowSubtitle =>
      'يرسل مهمة لمرة واحدة إلى Android. ستظهر النتيجة بعد دقيقة أو دقيقتين.';

  @override
  String get bgScanQueued =>
      'وُضع الفحص في الخلفية في قائمة الانتظار — ستظهر النتيجة خلال دقيقة تقريبًا';

  @override
  String get scanAndroidOnly => 'الفحص متاح على Android فقط.';

  @override
  String get scanPermissionMissing =>
      'إذن الوصول إلى بيانات الاستخدام غير متاح. فعّله في إعدادات النظام لتطبيق MediaBrain:\n\nالإعدادات → التطبيقات → الوصول الخاص للتطبيقات → الوصول إلى بيانات الاستخدام → MediaBrain.';

  @override
  String get detectedTitle => '📡 ما الذي يتم اكتشافه؟';

  @override
  String get detectedApps =>
      'Netflix · Disney+ · Prime Video · Apple TV · YouTube · Twitch · Spotify · Apple Music · YouTube Music · Tidal · Amazon Music · Audible · Kindle · Pocket Casts · Google Podcasts · Adobe Acrobat · Google Docs · Notion · Obsidian وغيرها.';

  @override
  String get appScanTitle => '🔍 فحص التطبيقات';

  @override
  String get appScanDescription =>
      'فحص التطبيقات: سجل واحد لكل تطبيق وسائط مع إجمالي الاستخدام خلال الأيام الماضية (وفق إحصاءات استخدام Android).';

  @override
  String get neverText => 'أبدًا';

  @override
  String get screenSettings => 'الإعدادات';

  @override
  String get sectionDataStatus => 'حالة البيانات';

  @override
  String get sectionFileSync => 'مزامنة الملفات';

  @override
  String get sectionServerSync => 'مزامنة الخادم (Mac Studio)';

  @override
  String get sectionActions => 'الإجراءات';

  @override
  String get settingsTotalEntries => 'إجمالي السجلات';

  @override
  String get settingsLastScan => 'آخر فحص';

  @override
  String get exportTitle => 'تصدير عبر المشاركة';

  @override
  String get exportSubtitle =>
      'إرسال JSON إلى نفسك عبر البريد أو OneDrive أو Telegram …';

  @override
  String get importTitle => 'اختيار ملف للاستيراد';

  @override
  String get importSubtitle => 'يستبدل البيانات المحلية';

  @override
  String get noServerConfigured => 'لا يوجد خادم مهيأ';

  @override
  String get actionPush => 'إرسال';

  @override
  String get actionPull => 'استقبال';

  @override
  String get refreshData => 'تحديث البيانات';

  @override
  String get deleteAllData => 'حذف جميع بيانات المكتبة';

  @override
  String get deleteAllTitle => 'حذف جميع بيانات المكتبة؟';

  @override
  String get deleteAllContent => 'يحذف جميع السجلات من MediaBrain المحلي.';

  @override
  String get cancel => 'إلغاء';

  @override
  String get delete => 'حذف';

  @override
  String get save => 'حفظ';

  @override
  String get libraryCleared => 'تم إفراغ المكتبة.';

  @override
  String get cancelled => 'تم الإلغاء.';

  @override
  String get serverConfigTitle => 'تهيئة مزامنة الخادم';

  @override
  String get fieldServerUrl => 'عنوان الخادم';

  @override
  String get fieldServerUrlHint => 'مثال: macstudvonlukas:8082';

  @override
  String get fieldBearerToken => 'رمز Bearer';

  @override
  String get aboutTitle => 'MediaBrain Mobile';

  @override
  String get aboutSubtitle =>
      'تطبيق Flutter مستقل. يكتشف تطبيقات الوسائط المثبتة، ويتتبع الإدخالات اليدوية، ويزامن عبر ملف أو خادم.';

  @override
  String get detailDescription => 'الوصف';

  @override
  String get detailDetails => 'التفاصيل';

  @override
  String get detailTags => 'الوسوم';

  @override
  String get fieldArtist => 'الفنان';

  @override
  String get fieldAlbum => 'الألبوم';

  @override
  String get fieldChannel => 'القناة';

  @override
  String get fieldSeasonEpisodeLabel => 'الموسم/الحلقة';

  @override
  String get fieldLength => 'المدة';

  @override
  String get fieldLastOpened => 'آخر فتح';

  @override
  String get fieldUsage => 'الاستخدام';

  @override
  String get fieldProviderId => 'معرّف المزوّد';

  @override
  String get fieldLocalPath => 'المسار المحلي';

  @override
  String get openPlayStore => 'فتح في Play Store';

  @override
  String get openBrowser => 'فتح في المتصفح';

  @override
  String get linkError => 'تعذر فتح الرابط.';

  @override
  String get dialogTitleNew => 'إدخال جديد';

  @override
  String get dialogTitleEdit => 'تعديل الإدخال';

  @override
  String get fieldTitle => 'العنوان';

  @override
  String get categoryLabel => 'الفئة';

  @override
  String get fieldArtistOptional => 'الفنان / المخرج (اختياري)';

  @override
  String get fieldAlbumOptional => 'الألبوم / المسلسل (اختياري)';

  @override
  String get fieldChannelOptional => 'القناة / المصدر (اختياري)';

  @override
  String get fieldDescriptionOptional => 'الوصف (اختياري)';

  @override
  String get fieldTags => 'الوسوم (مفصولة بفواصل)';

  @override
  String get fieldTagsHint => 'مثال: وثائقي، عطلة نهاية الأسبوع';

  @override
  String get markAsFavorite => 'وضع علامة في المفضلة';

  @override
  String error(String msg) {
    return 'خطأ: $msg';
  }

  @override
  String foregroundMinutesLabel(int minutes) {
    return 'الإجمالي $minutes دقيقة';
  }

  @override
  String bgScanSubtitle(int hours) {
    return 'افحص كل نحو $hours ساعات، حتى عندما يكون التطبيق مغلقًا.';
  }

  @override
  String lastRun(String time) {
    return 'آخر تشغيل: $time';
  }

  @override
  String scanResult(int matched, int persisted) {
    return 'فحص التطبيقات: تم العثور على $matched من تطبيقات الوسائط وإضافة $persisted من السجلات.';
  }

  @override
  String exportResult(String msg) {
    return 'تصدير: $msg';
  }

  @override
  String importResult(String msg) {
    return 'استيراد: $msg';
  }

  @override
  String pushPullStatus(String push, String pull) {
    return 'إرسال: $push · استقبال: $pull';
  }

  @override
  String seasonEpisode(int s, int e) {
    return 'الموسم $s الحلقة $e';
  }

  @override
  String usageMinutes(int n) {
    return '$n دقيقة';
  }

  @override
  String get navPlaylists => 'قوائم التشغيل';

  @override
  String get screenPlaylists => 'قوائم التشغيل والمجموعات';

  @override
  String get playlistTypeManual => 'يدوية';

  @override
  String get playlistTypeSmart => 'ذكية (تصفية ديناميكية)';

  @override
  String get dialogNewPlaylist => 'قائمة تشغيل جديدة';

  @override
  String get dialogEditPlaylist => 'تعديل قائمة التشغيل';

  @override
  String get fieldPlaylistName => 'اسم قائمة التشغيل';

  @override
  String get fieldPlaylistDescription => 'الوصف (اختياري)';

  @override
  String get fieldPlaylistType => 'نوع قائمة التشغيل';

  @override
  String get smartFilterCriteria => 'معايير التصفية الذكية';

  @override
  String get smartFilterCategory => 'الفئة';

  @override
  String get smartFilterTag => 'وسم / كلمة مفتاحية';

  @override
  String get smartFilterFavoritesOnly => 'المفضلة فقط';

  @override
  String get smartFilterMinMinutes => 'الحد الأدنى لوقت الاستخدام (دقيقة)';

  @override
  String get smartFilterSearch => 'مصطلح البحث';

  @override
  String get emptyPlaylists =>
      'لم تُنشأ قوائم تشغيل بعد.\nأنشئ مجموعات يدوية أو قوائم تشغيل ذكية ديناميكية.';

  @override
  String get emptyPlaylistItems => 'لا تحتوي قائمة التشغيل هذه على وسائط بعد.';

  @override
  String get deletePlaylistTitle => 'حذف قائمة التشغيل؟';

  @override
  String get deletePlaylistContent =>
      'هل تريد حقًا حذف قائمة التشغيل هذه؟ ستبقى عناصر الوسائط فيها في مكتبتك.';

  @override
  String get addToPlaylist => 'إضافة إلى قائمة التشغيل';

  @override
  String get removeFromPlaylist => 'إزالة من قائمة التشغيل';

  @override
  String get addedToPlaylist => 'تمت الإضافة إلى قائمة التشغيل.';

  @override
  String get removedFromPlaylist => 'تمت الإزالة من قائمة التشغيل.';

  @override
  String get filterByTag => 'تصفية حسب الوسم';

  @override
  String get allTags => 'كل الوسوم';

  @override
  String get addTag => 'إضافة وسم';

  @override
  String get removeTag => 'إزالة الوسم';

  @override
  String get noPlaylistsFound => 'لا توجد قوائم تشغيل متاحة.';

  @override
  String playlistItemCount(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count عنصر',
      many: '$count عنصرًا',
      few: '$count عناصر',
      two: '$count عنصران',
      one: '$count عنصر',
      zero: '$count عنصر',
    );
    return '$_temp0';
  }

  @override
  String tagCount(String tag, int count) {
    return '#$tag ($count)';
  }
}
