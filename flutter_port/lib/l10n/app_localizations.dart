import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_bn.dart';
import 'app_localizations_de.dart';
import 'app_localizations_en.dart';
import 'app_localizations_es.dart';
import 'app_localizations_fr.dart';
import 'app_localizations_hi.dart';
import 'app_localizations_ja.dart';
import 'app_localizations_pt.dart';
import 'app_localizations_ru.dart';
import 'app_localizations_zh.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('de'),
    Locale('ar'),
    Locale('bn'),
    Locale('en'),
    Locale('es'),
    Locale('fr'),
    Locale('hi'),
    Locale('ja'),
    Locale('pt'),
    Locale('ru'),
    Locale('zh'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'MediaBrain'**
  String get appTitle;

  /// No description provided for @navLibrary.
  ///
  /// In en, this message translates to:
  /// **'Library'**
  String get navLibrary;

  /// No description provided for @navScan.
  ///
  /// In en, this message translates to:
  /// **'Scan'**
  String get navScan;

  /// No description provided for @navMore.
  ///
  /// In en, this message translates to:
  /// **'More'**
  String get navMore;

  /// No description provided for @screenLibrary.
  ///
  /// In en, this message translates to:
  /// **'Library'**
  String get screenLibrary;

  /// No description provided for @fabAdd.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get fabAdd;

  /// No description provided for @searchHint.
  ///
  /// In en, this message translates to:
  /// **'Search (Title, Artist, Channel …)'**
  String get searchHint;

  /// No description provided for @filterAll.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get filterAll;

  /// No description provided for @filterFavorites.
  ///
  /// In en, this message translates to:
  /// **'⭐ Favorites'**
  String get filterFavorites;

  /// No description provided for @emptyNoMatch.
  ///
  /// In en, this message translates to:
  /// **'No results for your filters.'**
  String get emptyNoMatch;

  /// No description provided for @emptyNoItems.
  ///
  /// In en, this message translates to:
  /// **'Empty yet.\nTap the \"Scan\" tab to automatically detect your media apps.'**
  String get emptyNoItems;

  /// No description provided for @screenScan.
  ///
  /// In en, this message translates to:
  /// **'Scan'**
  String get screenScan;

  /// No description provided for @scanDescription.
  ///
  /// In en, this message translates to:
  /// **'Searches for installed media apps (streaming, music, podcasts, documents) and adds them as entries to your library. With enabled usage data access you additionally get the actual usage time.'**
  String get scanDescription;

  /// No description provided for @btnAppScan.
  ///
  /// In en, this message translates to:
  /// **'App Scan (Aggregate Usage)'**
  String get btnAppScan;

  /// No description provided for @bgScanTitle.
  ///
  /// In en, this message translates to:
  /// **'Background Scan'**
  String get bgScanTitle;

  /// No description provided for @bgScanNow.
  ///
  /// In en, this message translates to:
  /// **'Run once in background now'**
  String get bgScanNow;

  /// No description provided for @bgScanNowSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Sends a one-off task to Android. Result appears after 1–2 minutes.'**
  String get bgScanNowSubtitle;

  /// No description provided for @bgScanQueued.
  ///
  /// In en, this message translates to:
  /// **'Background scan queued — result visible in ~1 min'**
  String get bgScanQueued;

  /// No description provided for @scanAndroidOnly.
  ///
  /// In en, this message translates to:
  /// **'Scan is only available on Android.'**
  String get scanAndroidOnly;

  /// No description provided for @scanPermissionMissing.
  ///
  /// In en, this message translates to:
  /// **'Usage data access missing. Please enable in system settings for MediaBrain:\n\nSettings → Apps → Special app access → Usage data access → MediaBrain.'**
  String get scanPermissionMissing;

  /// No description provided for @detectedTitle.
  ///
  /// In en, this message translates to:
  /// **'📡 What is detected?'**
  String get detectedTitle;

  /// No description provided for @detectedApps.
  ///
  /// In en, this message translates to:
  /// **'Netflix · Disney+ · Prime Video · Apple TV · YouTube · Twitch · Spotify · Apple Music · YouTube Music · Tidal · Amazon Music · Audible · Kindle · Pocket Casts · Google Podcasts · Adobe Acrobat · Google Docs · Notion · Obsidian and more.'**
  String get detectedApps;

  /// No description provided for @appScanTitle.
  ///
  /// In en, this message translates to:
  /// **'🔍 App Scan'**
  String get appScanTitle;

  /// No description provided for @appScanDescription.
  ///
  /// In en, this message translates to:
  /// **'App Scan: one entry per media app with total usage over the last days (via Android usage stats).'**
  String get appScanDescription;

  /// No description provided for @neverText.
  ///
  /// In en, this message translates to:
  /// **'never'**
  String get neverText;

  /// No description provided for @screenSettings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get screenSettings;

  /// No description provided for @sectionDataStatus.
  ///
  /// In en, this message translates to:
  /// **'Data Status'**
  String get sectionDataStatus;

  /// No description provided for @sectionFileSync.
  ///
  /// In en, this message translates to:
  /// **'File Sync'**
  String get sectionFileSync;

  /// No description provided for @sectionServerSync.
  ///
  /// In en, this message translates to:
  /// **'Server Sync (Mac Studio)'**
  String get sectionServerSync;

  /// No description provided for @sectionActions.
  ///
  /// In en, this message translates to:
  /// **'Actions'**
  String get sectionActions;

  /// No description provided for @settingsTotalEntries.
  ///
  /// In en, this message translates to:
  /// **'Total Entries'**
  String get settingsTotalEntries;

  /// No description provided for @settingsLastScan.
  ///
  /// In en, this message translates to:
  /// **'Last Scan'**
  String get settingsLastScan;

  /// No description provided for @exportTitle.
  ///
  /// In en, this message translates to:
  /// **'Export via Share'**
  String get exportTitle;

  /// No description provided for @exportSubtitle.
  ///
  /// In en, this message translates to:
  /// **'JSON via Mail, OneDrive, Telegram to yourself …'**
  String get exportSubtitle;

  /// No description provided for @importTitle.
  ///
  /// In en, this message translates to:
  /// **'Choose Import File'**
  String get importTitle;

  /// No description provided for @importSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Overwrites local data'**
  String get importSubtitle;

  /// No description provided for @noServerConfigured.
  ///
  /// In en, this message translates to:
  /// **'No server configured'**
  String get noServerConfigured;

  /// No description provided for @actionPush.
  ///
  /// In en, this message translates to:
  /// **'Push'**
  String get actionPush;

  /// No description provided for @actionPull.
  ///
  /// In en, this message translates to:
  /// **'Pull'**
  String get actionPull;

  /// No description provided for @refreshData.
  ///
  /// In en, this message translates to:
  /// **'Refresh data'**
  String get refreshData;

  /// No description provided for @deleteAllData.
  ///
  /// In en, this message translates to:
  /// **'Delete all library data'**
  String get deleteAllData;

  /// No description provided for @deleteAllTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete all library data?'**
  String get deleteAllTitle;

  /// No description provided for @deleteAllContent.
  ///
  /// In en, this message translates to:
  /// **'Removes all entries from the local MediaBrain.'**
  String get deleteAllContent;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @libraryCleared.
  ///
  /// In en, this message translates to:
  /// **'Library cleared.'**
  String get libraryCleared;

  /// No description provided for @cancelled.
  ///
  /// In en, this message translates to:
  /// **'Cancelled.'**
  String get cancelled;

  /// No description provided for @serverConfigTitle.
  ///
  /// In en, this message translates to:
  /// **'Configure Server Sync'**
  String get serverConfigTitle;

  /// No description provided for @fieldServerUrl.
  ///
  /// In en, this message translates to:
  /// **'Server URL'**
  String get fieldServerUrl;

  /// No description provided for @fieldServerUrlHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. macstudvonlukas:8082'**
  String get fieldServerUrlHint;

  /// No description provided for @fieldBearerToken.
  ///
  /// In en, this message translates to:
  /// **'Bearer Token'**
  String get fieldBearerToken;

  /// No description provided for @aboutTitle.
  ///
  /// In en, this message translates to:
  /// **'MediaBrain Mobile'**
  String get aboutTitle;

  /// No description provided for @aboutSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Standalone Flutter app. Detects installed media apps, tracks manual entries and syncs via file or server.'**
  String get aboutSubtitle;

  /// No description provided for @detailDescription.
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get detailDescription;

  /// No description provided for @detailDetails.
  ///
  /// In en, this message translates to:
  /// **'Details'**
  String get detailDetails;

  /// No description provided for @detailTags.
  ///
  /// In en, this message translates to:
  /// **'Tags'**
  String get detailTags;

  /// No description provided for @fieldArtist.
  ///
  /// In en, this message translates to:
  /// **'Artist'**
  String get fieldArtist;

  /// No description provided for @fieldAlbum.
  ///
  /// In en, this message translates to:
  /// **'Album'**
  String get fieldAlbum;

  /// No description provided for @fieldChannel.
  ///
  /// In en, this message translates to:
  /// **'Channel'**
  String get fieldChannel;

  /// No description provided for @fieldSeasonEpisodeLabel.
  ///
  /// In en, this message translates to:
  /// **'Season/Episode'**
  String get fieldSeasonEpisodeLabel;

  /// No description provided for @fieldLength.
  ///
  /// In en, this message translates to:
  /// **'Length'**
  String get fieldLength;

  /// No description provided for @fieldLastOpened.
  ///
  /// In en, this message translates to:
  /// **'Last opened'**
  String get fieldLastOpened;

  /// No description provided for @fieldUsage.
  ///
  /// In en, this message translates to:
  /// **'Usage'**
  String get fieldUsage;

  /// No description provided for @fieldProviderId.
  ///
  /// In en, this message translates to:
  /// **'Provider ID'**
  String get fieldProviderId;

  /// No description provided for @fieldLocalPath.
  ///
  /// In en, this message translates to:
  /// **'Local Path'**
  String get fieldLocalPath;

  /// No description provided for @openPlayStore.
  ///
  /// In en, this message translates to:
  /// **'Open in Play Store'**
  String get openPlayStore;

  /// No description provided for @openBrowser.
  ///
  /// In en, this message translates to:
  /// **'Open in Browser'**
  String get openBrowser;

  /// No description provided for @linkError.
  ///
  /// In en, this message translates to:
  /// **'Link could not be opened.'**
  String get linkError;

  /// No description provided for @dialogTitleNew.
  ///
  /// In en, this message translates to:
  /// **'New Entry'**
  String get dialogTitleNew;

  /// No description provided for @dialogTitleEdit.
  ///
  /// In en, this message translates to:
  /// **'Edit Entry'**
  String get dialogTitleEdit;

  /// No description provided for @fieldTitle.
  ///
  /// In en, this message translates to:
  /// **'Title'**
  String get fieldTitle;

  /// No description provided for @categoryLabel.
  ///
  /// In en, this message translates to:
  /// **'Category'**
  String get categoryLabel;

  /// No description provided for @fieldArtistOptional.
  ///
  /// In en, this message translates to:
  /// **'Artist / Director (optional)'**
  String get fieldArtistOptional;

  /// No description provided for @fieldAlbumOptional.
  ///
  /// In en, this message translates to:
  /// **'Album / Series (optional)'**
  String get fieldAlbumOptional;

  /// No description provided for @fieldChannelOptional.
  ///
  /// In en, this message translates to:
  /// **'Channel / Source (optional)'**
  String get fieldChannelOptional;

  /// No description provided for @fieldDescriptionOptional.
  ///
  /// In en, this message translates to:
  /// **'Description (optional)'**
  String get fieldDescriptionOptional;

  /// No description provided for @fieldTags.
  ///
  /// In en, this message translates to:
  /// **'Tags (comma-separated)'**
  String get fieldTags;

  /// No description provided for @fieldTagsHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. Documentary, Weekend'**
  String get fieldTagsHint;

  /// No description provided for @markAsFavorite.
  ///
  /// In en, this message translates to:
  /// **'Mark as favorite'**
  String get markAsFavorite;

  /// No description provided for @error.
  ///
  /// In en, this message translates to:
  /// **'Error: {msg}'**
  String error(String msg);

  /// No description provided for @foregroundMinutesLabel.
  ///
  /// In en, this message translates to:
  /// **'{minutes} min total'**
  String foregroundMinutesLabel(int minutes);

  /// No description provided for @bgScanSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Scan every ~{hours} h, even when the app is closed.'**
  String bgScanSubtitle(int hours);

  /// No description provided for @lastRun.
  ///
  /// In en, this message translates to:
  /// **'Last run: {time}'**
  String lastRun(String time);

  /// No description provided for @scanResult.
  ///
  /// In en, this message translates to:
  /// **'App scan: {matched} media apps found, {persisted} entries added.'**
  String scanResult(int matched, int persisted);

  /// No description provided for @exportResult.
  ///
  /// In en, this message translates to:
  /// **'Export: {msg}'**
  String exportResult(String msg);

  /// No description provided for @importResult.
  ///
  /// In en, this message translates to:
  /// **'Import: {msg}'**
  String importResult(String msg);

  /// No description provided for @pushPullStatus.
  ///
  /// In en, this message translates to:
  /// **'Push: {push} · Pull: {pull}'**
  String pushPullStatus(String push, String pull);

  /// No description provided for @seasonEpisode.
  ///
  /// In en, this message translates to:
  /// **'S{s} E{e}'**
  String seasonEpisode(int s, int e);

  /// No description provided for @usageMinutes.
  ///
  /// In en, this message translates to:
  /// **'{n} minutes'**
  String usageMinutes(int n);

  /// No description provided for @navPlaylists.
  ///
  /// In en, this message translates to:
  /// **'Playlists'**
  String get navPlaylists;

  /// No description provided for @screenPlaylists.
  ///
  /// In en, this message translates to:
  /// **'Playlists & Collections'**
  String get screenPlaylists;

  /// No description provided for @playlistTypeManual.
  ///
  /// In en, this message translates to:
  /// **'Manual'**
  String get playlistTypeManual;

  /// No description provided for @playlistTypeSmart.
  ///
  /// In en, this message translates to:
  /// **'Smart (Dynamic Filter)'**
  String get playlistTypeSmart;

  /// No description provided for @dialogNewPlaylist.
  ///
  /// In en, this message translates to:
  /// **'New Playlist'**
  String get dialogNewPlaylist;

  /// No description provided for @dialogEditPlaylist.
  ///
  /// In en, this message translates to:
  /// **'Edit Playlist'**
  String get dialogEditPlaylist;

  /// No description provided for @fieldPlaylistName.
  ///
  /// In en, this message translates to:
  /// **'Playlist Name'**
  String get fieldPlaylistName;

  /// No description provided for @fieldPlaylistDescription.
  ///
  /// In en, this message translates to:
  /// **'Description (optional)'**
  String get fieldPlaylistDescription;

  /// No description provided for @fieldPlaylistType.
  ///
  /// In en, this message translates to:
  /// **'Playlist Type'**
  String get fieldPlaylistType;

  /// No description provided for @smartFilterCriteria.
  ///
  /// In en, this message translates to:
  /// **'Smart Filter Criteria'**
  String get smartFilterCriteria;

  /// No description provided for @smartFilterCategory.
  ///
  /// In en, this message translates to:
  /// **'Category'**
  String get smartFilterCategory;

  /// No description provided for @smartFilterTag.
  ///
  /// In en, this message translates to:
  /// **'Tag / Keyword'**
  String get smartFilterTag;

  /// No description provided for @smartFilterFavoritesOnly.
  ///
  /// In en, this message translates to:
  /// **'Favorites only'**
  String get smartFilterFavoritesOnly;

  /// No description provided for @smartFilterMinMinutes.
  ///
  /// In en, this message translates to:
  /// **'Minimum usage time (min)'**
  String get smartFilterMinMinutes;

  /// No description provided for @smartFilterSearch.
  ///
  /// In en, this message translates to:
  /// **'Search term'**
  String get smartFilterSearch;

  /// No description provided for @emptyPlaylists.
  ///
  /// In en, this message translates to:
  /// **'No playlists created yet.\nCreate manual collections or dynamic smart playlists.'**
  String get emptyPlaylists;

  /// No description provided for @emptyPlaylistItems.
  ///
  /// In en, this message translates to:
  /// **'This playlist does not contain any media yet.'**
  String get emptyPlaylistItems;

  /// No description provided for @deletePlaylistTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete playlist?'**
  String get deletePlaylistTitle;

  /// No description provided for @deletePlaylistContent.
  ///
  /// In en, this message translates to:
  /// **'Do you really want to delete this playlist? The media items will remain in your library.'**
  String get deletePlaylistContent;

  /// No description provided for @addToPlaylist.
  ///
  /// In en, this message translates to:
  /// **'Add to playlist'**
  String get addToPlaylist;

  /// No description provided for @removeFromPlaylist.
  ///
  /// In en, this message translates to:
  /// **'Remove from playlist'**
  String get removeFromPlaylist;

  /// No description provided for @addedToPlaylist.
  ///
  /// In en, this message translates to:
  /// **'Added to playlist.'**
  String get addedToPlaylist;

  /// No description provided for @removedFromPlaylist.
  ///
  /// In en, this message translates to:
  /// **'Removed from playlist.'**
  String get removedFromPlaylist;

  /// No description provided for @filterByTag.
  ///
  /// In en, this message translates to:
  /// **'Tag Filter'**
  String get filterByTag;

  /// No description provided for @allTags.
  ///
  /// In en, this message translates to:
  /// **'All Tags'**
  String get allTags;

  /// No description provided for @addTag.
  ///
  /// In en, this message translates to:
  /// **'Add tag'**
  String get addTag;

  /// No description provided for @removeTag.
  ///
  /// In en, this message translates to:
  /// **'Remove tag'**
  String get removeTag;

  /// No description provided for @noPlaylistsFound.
  ///
  /// In en, this message translates to:
  /// **'No playlists available.'**
  String get noPlaylistsFound;

  /// Number of items in a playlist.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, one {{count} item} other {{count} items}}'**
  String playlistItemCount(num count);

  /// Tag and number of matching entries.
  ///
  /// In en, this message translates to:
  /// **'#{tag} ({count})'**
  String tagCount(String tag, int count);
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>[
    'ar',
    'bn',
    'de',
    'en',
    'es',
    'fr',
    'hi',
    'ja',
    'pt',
    'ru',
    'zh',
  ].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar':
      return AppLocalizationsAr();
    case 'bn':
      return AppLocalizationsBn();
    case 'de':
      return AppLocalizationsDe();
    case 'en':
      return AppLocalizationsEn();
    case 'es':
      return AppLocalizationsEs();
    case 'fr':
      return AppLocalizationsFr();
    case 'hi':
      return AppLocalizationsHi();
    case 'ja':
      return AppLocalizationsJa();
    case 'pt':
      return AppLocalizationsPt();
    case 'ru':
      return AppLocalizationsRu();
    case 'zh':
      return AppLocalizationsZh();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
