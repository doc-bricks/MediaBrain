// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'MediaBrain';

  @override
  String get navLibrary => 'Library';

  @override
  String get navScan => 'Scan';

  @override
  String get navMore => 'More';

  @override
  String get screenLibrary => 'Library';

  @override
  String get fabAdd => 'Add';

  @override
  String get searchHint => 'Search (Title, Artist, Channel …)';

  @override
  String get filterAll => 'All';

  @override
  String get filterFavorites => '⭐ Favorites';

  @override
  String get emptyNoMatch => 'No results for your filters.';

  @override
  String get emptyNoItems =>
      'Empty yet.\nTap the \"Scan\" tab to automatically detect your media apps.';

  @override
  String get screenScan => 'Scan';

  @override
  String get scanDescription =>
      'Searches for installed media apps (streaming, music, podcasts, documents) and adds them as entries to your library. With enabled usage data access you additionally get the actual usage time.';

  @override
  String get btnAppScan => 'App Scan (Aggregate Usage)';

  @override
  String get bgScanTitle => 'Background Scan';

  @override
  String get bgScanNow => 'Run once in background now';

  @override
  String get bgScanNowSubtitle =>
      'Sends a one-off task to Android. Result appears after 1–2 minutes.';

  @override
  String get bgScanQueued =>
      'Background scan queued — result visible in ~1 min';

  @override
  String get scanAndroidOnly => 'Scan is only available on Android.';

  @override
  String get scanPermissionMissing =>
      'Usage data access missing. Please enable in system settings for MediaBrain:\n\nSettings → Apps → Special app access → Usage data access → MediaBrain.';

  @override
  String get detectedTitle => '📡 What is detected?';

  @override
  String get detectedApps =>
      'Netflix · Disney+ · Prime Video · Apple TV · YouTube · Twitch · Spotify · Apple Music · YouTube Music · Tidal · Amazon Music · Audible · Kindle · Pocket Casts · Google Podcasts · Adobe Acrobat · Google Docs · Notion · Obsidian and more.';

  @override
  String get appScanTitle => '🔍 App Scan';

  @override
  String get appScanDescription =>
      'App Scan: one entry per media app with total usage over the last days (via Android usage stats).';

  @override
  String get neverText => 'never';

  @override
  String get screenSettings => 'Settings';

  @override
  String get sectionDataStatus => 'Data Status';

  @override
  String get sectionFileSync => 'File Sync';

  @override
  String get sectionServerSync => 'Server Sync (Mac Studio)';

  @override
  String get sectionActions => 'Actions';

  @override
  String get settingsTotalEntries => 'Total Entries';

  @override
  String get settingsLastScan => 'Last Scan';

  @override
  String get exportTitle => 'Export via Share';

  @override
  String get exportSubtitle =>
      'JSON via Mail, OneDrive, Telegram to yourself …';

  @override
  String get importTitle => 'Choose Import File';

  @override
  String get importSubtitle => 'Overwrites local data';

  @override
  String get noServerConfigured => 'No server configured';

  @override
  String get actionPush => 'Push';

  @override
  String get actionPull => 'Pull';

  @override
  String get refreshData => 'Refresh data';

  @override
  String get deleteAllData => 'Delete all library data';

  @override
  String get deleteAllTitle => 'Delete all library data?';

  @override
  String get deleteAllContent =>
      'Removes all entries from the local MediaBrain.';

  @override
  String get cancel => 'Cancel';

  @override
  String get delete => 'Delete';

  @override
  String get save => 'Save';

  @override
  String get libraryCleared => 'Library cleared.';

  @override
  String get cancelled => 'Cancelled.';

  @override
  String get serverConfigTitle => 'Configure Server Sync';

  @override
  String get fieldServerUrl => 'Server URL';

  @override
  String get fieldServerUrlHint => 'e.g. macstudvonlukas:8082';

  @override
  String get fieldBearerToken => 'Bearer Token';

  @override
  String get aboutTitle => 'MediaBrain Mobile';

  @override
  String get aboutSubtitle =>
      'Standalone Flutter app. Detects installed media apps, tracks manual entries and syncs via file or server.';

  @override
  String get detailDescription => 'Description';

  @override
  String get detailDetails => 'Details';

  @override
  String get detailTags => 'Tags';

  @override
  String get fieldArtist => 'Artist';

  @override
  String get fieldAlbum => 'Album';

  @override
  String get fieldChannel => 'Channel';

  @override
  String get fieldSeasonEpisodeLabel => 'Season/Episode';

  @override
  String get fieldLength => 'Length';

  @override
  String get fieldLastOpened => 'Last opened';

  @override
  String get fieldUsage => 'Usage';

  @override
  String get fieldProviderId => 'Provider ID';

  @override
  String get fieldLocalPath => 'Local Path';

  @override
  String get openPlayStore => 'Open in Play Store';

  @override
  String get openBrowser => 'Open in Browser';

  @override
  String get linkError => 'Link could not be opened.';

  @override
  String get dialogTitleNew => 'New Entry';

  @override
  String get dialogTitleEdit => 'Edit Entry';

  @override
  String get fieldTitle => 'Title';

  @override
  String get categoryLabel => 'Category';

  @override
  String get fieldArtistOptional => 'Artist / Director (optional)';

  @override
  String get fieldAlbumOptional => 'Album / Series (optional)';

  @override
  String get fieldChannelOptional => 'Channel / Source (optional)';

  @override
  String get fieldDescriptionOptional => 'Description (optional)';

  @override
  String get fieldTags => 'Tags (comma-separated)';

  @override
  String get fieldTagsHint => 'e.g. Documentary, Weekend';

  @override
  String get markAsFavorite => 'Mark as favorite';

  @override
  String error(String msg) {
    return 'Error: $msg';
  }

  @override
  String foregroundMinutesLabel(int minutes) {
    return '$minutes min total';
  }

  @override
  String bgScanSubtitle(int hours) {
    return 'Scan every ~$hours h, even when the app is closed.';
  }

  @override
  String lastRun(String time) {
    return 'Last run: $time';
  }

  @override
  String scanResult(int matched, int persisted) {
    return 'App scan: $matched media apps found, $persisted entries added.';
  }

  @override
  String exportResult(String msg) {
    return 'Export: $msg';
  }

  @override
  String importResult(String msg) {
    return 'Import: $msg';
  }

  @override
  String pushPullStatus(String push, String pull) {
    return 'Push: $push · Pull: $pull';
  }

  @override
  String seasonEpisode(int s, int e) {
    return 'S$s E$e';
  }

  @override
  String usageMinutes(int n) {
    return '$n minutes';
  }

  @override
  String get navPlaylists => 'Playlists';

  @override
  String get screenPlaylists => 'Playlists & Collections';

  @override
  String get playlistTypeManual => 'Manual';

  @override
  String get playlistTypeSmart => 'Smart (Dynamic Filter)';

  @override
  String get dialogNewPlaylist => 'New Playlist';

  @override
  String get dialogEditPlaylist => 'Edit Playlist';

  @override
  String get fieldPlaylistName => 'Playlist Name';

  @override
  String get fieldPlaylistDescription => 'Description (optional)';

  @override
  String get fieldPlaylistType => 'Playlist Type';

  @override
  String get smartFilterCriteria => 'Smart Filter Criteria';

  @override
  String get smartFilterCategory => 'Category';

  @override
  String get smartFilterTag => 'Tag / Keyword';

  @override
  String get smartFilterFavoritesOnly => 'Favorites only';

  @override
  String get smartFilterMinMinutes => 'Minimum usage time (min)';

  @override
  String get smartFilterSearch => 'Search term';

  @override
  String get emptyPlaylists =>
      'No playlists created yet.\nCreate manual collections or dynamic smart playlists.';

  @override
  String get emptyPlaylistItems =>
      'This playlist does not contain any media yet.';

  @override
  String get deletePlaylistTitle => 'Delete playlist?';

  @override
  String get deletePlaylistContent =>
      'Do you really want to delete this playlist? The media items will remain in your library.';

  @override
  String get addToPlaylist => 'Add to playlist';

  @override
  String get removeFromPlaylist => 'Remove from playlist';

  @override
  String get addedToPlaylist => 'Added to playlist.';

  @override
  String get removedFromPlaylist => 'Removed from playlist.';

  @override
  String get filterByTag => 'Tag Filter';

  @override
  String get allTags => 'All Tags';

  @override
  String get addTag => 'Add tag';

  @override
  String get removeTag => 'Remove tag';

  @override
  String get noPlaylistsFound => 'No playlists available.';

  @override
  String playlistItemCount(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count items',
      one: '$count item',
    );
    return '$_temp0';
  }

  @override
  String tagCount(String tag, int count) {
    return '#$tag ($count)';
  }
}
