// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Chinese (`zh`).
class AppLocalizationsZh extends AppLocalizations {
  AppLocalizationsZh([String locale = 'zh']) : super(locale);

  @override
  String get appTitle => 'MediaBrain';

  @override
  String get navLibrary => '媒体库';

  @override
  String get navScan => '扫描';

  @override
  String get navMore => '更多';

  @override
  String get screenLibrary => '媒体库';

  @override
  String get fabAdd => '添加';

  @override
  String get searchHint => '搜索（标题、艺术家、频道……）';

  @override
  String get filterAll => '全部';

  @override
  String get filterFavorites => '⭐ 收藏';

  @override
  String get emptyNoMatch => '没有符合筛选条件的结果。';

  @override
  String get emptyNoItems => '内容为空。\n点击“扫描”标签页，自动检测媒体应用。';

  @override
  String get screenScan => '扫描';

  @override
  String get scanDescription =>
      '搜索已安装的媒体应用（流媒体、音乐、播客、文档），并将其添加到媒体库。启用使用数据访问权限后，还可以获取实际使用时长。';

  @override
  String get btnAppScan => '应用扫描（汇总使用情况）';

  @override
  String get bgScanTitle => '后台扫描';

  @override
  String get bgScanNow => '立即在后台运行一次';

  @override
  String get bgScanNowSubtitle => '向 Android 发送一次性任务。结果将在 1–2 分钟后显示。';

  @override
  String get bgScanQueued => '后台扫描已排队 — 约 1 分钟后可查看结果';

  @override
  String get scanAndroidOnly => '扫描仅适用于 Android。';

  @override
  String get scanPermissionMissing =>
      '缺少使用数据访问权限。请在 MediaBrain 的系统设置中启用：\n\n设置 → 应用 → 特殊应用访问权限 → 使用情况访问权限 → MediaBrain。';

  @override
  String get detectedTitle => '📡 可以检测什么？';

  @override
  String get detectedApps =>
      'Netflix · Disney+ · Prime Video · Apple TV · YouTube · Twitch · Spotify · Apple Music · YouTube Music · Tidal · Amazon Music · Audible · Kindle · Pocket Casts · Google Podcasts · Adobe Acrobat · Google Docs · Notion · Obsidian 等。';

  @override
  String get appScanTitle => '🔍 应用扫描';

  @override
  String get appScanDescription =>
      '应用扫描：每个媒体应用生成一个条目，显示最近几天的总使用情况（通过 Android 使用情况统计）。';

  @override
  String get neverText => '从不';

  @override
  String get screenSettings => '设置';

  @override
  String get sectionDataStatus => '数据状态';

  @override
  String get sectionFileSync => '文件同步';

  @override
  String get sectionServerSync => '服务器同步（Mac Studio）';

  @override
  String get sectionActions => '操作';

  @override
  String get settingsTotalEntries => '条目总数';

  @override
  String get settingsLastScan => '上次扫描';

  @override
  String get exportTitle => '通过分享导出';

  @override
  String get exportSubtitle => '通过邮件、OneDrive、Telegram 将 JSON 发给自己 …';

  @override
  String get importTitle => '选择导入文件';

  @override
  String get importSubtitle => '覆盖本地数据';

  @override
  String get noServerConfigured => '未配置服务器';

  @override
  String get actionPush => '推送';

  @override
  String get actionPull => '拉取';

  @override
  String get refreshData => '刷新数据';

  @override
  String get deleteAllData => '删除媒体库中的所有数据';

  @override
  String get deleteAllTitle => '删除媒体库中的所有数据？';

  @override
  String get deleteAllContent => '从本地 MediaBrain 中删除所有条目。';

  @override
  String get cancel => '取消';

  @override
  String get delete => '删除';

  @override
  String get save => '保存';

  @override
  String get libraryCleared => '媒体库已清空。';

  @override
  String get cancelled => '已取消。';

  @override
  String get serverConfigTitle => '配置服务器同步';

  @override
  String get fieldServerUrl => '服务器 URL';

  @override
  String get fieldServerUrlHint => '例如：macstudvonlukas:8082';

  @override
  String get fieldBearerToken => 'Bearer 令牌';

  @override
  String get aboutTitle => 'MediaBrain Mobile';

  @override
  String get aboutSubtitle =>
      '独立的 Flutter 应用。检测已安装的媒体应用、记录手动添加的条目，并通过文件或服务器同步。';

  @override
  String get detailDescription => '描述';

  @override
  String get detailDetails => '详情';

  @override
  String get detailTags => '标签';

  @override
  String get fieldArtist => '艺术家';

  @override
  String get fieldAlbum => '专辑';

  @override
  String get fieldChannel => '频道';

  @override
  String get fieldSeasonEpisodeLabel => '季/集';

  @override
  String get fieldLength => '时长';

  @override
  String get fieldLastOpened => '上次打开';

  @override
  String get fieldUsage => '使用情况';

  @override
  String get fieldProviderId => '提供方 ID';

  @override
  String get fieldLocalPath => '本地路径';

  @override
  String get openPlayStore => '在 Play 商店中打开';

  @override
  String get openBrowser => '在浏览器中打开';

  @override
  String get linkError => '无法打开链接。';

  @override
  String get dialogTitleNew => '新建条目';

  @override
  String get dialogTitleEdit => '编辑条目';

  @override
  String get fieldTitle => '标题';

  @override
  String get categoryLabel => '类别';

  @override
  String get fieldArtistOptional => '艺术家 / 导演（可选）';

  @override
  String get fieldAlbumOptional => '专辑 / 系列（可选）';

  @override
  String get fieldChannelOptional => '频道 / 来源（可选）';

  @override
  String get fieldDescriptionOptional => '描述（可选）';

  @override
  String get fieldTags => '标签（用逗号分隔）';

  @override
  String get fieldTagsHint => '例如：纪录片、周末';

  @override
  String get markAsFavorite => '标记为收藏';

  @override
  String error(String msg) {
    return '错误：$msg';
  }

  @override
  String foregroundMinutesLabel(int minutes) {
    return '共 $minutes 分钟';
  }

  @override
  String bgScanSubtitle(int hours) {
    return '每隔约 $hours 小时扫描一次，即使应用已关闭也会扫描。';
  }

  @override
  String lastRun(String time) {
    return '上次运行：$time';
  }

  @override
  String scanResult(int matched, int persisted) {
    return '应用扫描：发现 $matched 个媒体应用，添加了 $persisted 个条目。';
  }

  @override
  String exportResult(String msg) {
    return '导出：$msg';
  }

  @override
  String importResult(String msg) {
    return '导入：$msg';
  }

  @override
  String pushPullStatus(String push, String pull) {
    return '推送：$push · 拉取：$pull';
  }

  @override
  String seasonEpisode(int s, int e) {
    return '第 $s 季 第 $e 集';
  }

  @override
  String usageMinutes(int n) {
    return '$n 分钟';
  }

  @override
  String get navPlaylists => '播放列表';

  @override
  String get screenPlaylists => '播放列表与收藏集';

  @override
  String get playlistTypeManual => '手动';

  @override
  String get playlistTypeSmart => '智能（动态筛选）';

  @override
  String get dialogNewPlaylist => '新建播放列表';

  @override
  String get dialogEditPlaylist => '编辑播放列表';

  @override
  String get fieldPlaylistName => '播放列表名称';

  @override
  String get fieldPlaylistDescription => '描述（可选）';

  @override
  String get fieldPlaylistType => '播放列表类型';

  @override
  String get smartFilterCriteria => '智能筛选条件';

  @override
  String get smartFilterCategory => '类别';

  @override
  String get smartFilterTag => '标签 / 关键词';

  @override
  String get smartFilterFavoritesOnly => '仅收藏';

  @override
  String get smartFilterMinMinutes => '最短使用时长（分钟）';

  @override
  String get smartFilterSearch => '搜索词';

  @override
  String get emptyPlaylists => '尚未创建播放列表。\n创建手动收藏集或动态智能播放列表。';

  @override
  String get emptyPlaylistItems => '此播放列表中还没有媒体内容。';

  @override
  String get deletePlaylistTitle => '删除播放列表？';

  @override
  String get deletePlaylistContent => '确定要删除此播放列表吗？其中的媒体项目仍会保留在媒体库中。';

  @override
  String get addToPlaylist => '添加到播放列表';

  @override
  String get removeFromPlaylist => '从播放列表移除';

  @override
  String get addedToPlaylist => '已添加到播放列表。';

  @override
  String get removedFromPlaylist => '已从播放列表移除。';

  @override
  String get filterByTag => '按标签筛选';

  @override
  String get allTags => '所有标签';

  @override
  String get addTag => '添加标签';

  @override
  String get removeTag => '移除标签';

  @override
  String get noPlaylistsFound => '没有可用的播放列表。';

  @override
  String playlistItemCount(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count 个项目',
    );
    return '$_temp0';
  }

  @override
  String tagCount(String tag, int count) {
    return '#$tag ($count)';
  }
}
