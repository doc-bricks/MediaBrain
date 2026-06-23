import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

abstract class AppLocalizations {
  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates = [
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
  ];

  static const List<Locale> supportedLocales = [
    Locale('de'),
    Locale('en'),
  ];

  String get appTitle;
  String get navLibrary;
  String get navScan;
  String get navMore;
  String get screenLibrary;
  String get fabAdd;
  String get searchHint;
  String get filterAll;
  String get filterFavorites;
  String get emptyNoMatch;
  String get emptyNoItems;
  String get screenScan;
  String get scanDescription;
  String get btnAppScan;
  String get bgScanTitle;
  String get bgScanNow;
  String get bgScanNowSubtitle;
  String get bgScanQueued;
  String get scanAndroidOnly;
  String get scanPermissionMissing;
  String get detectedTitle;
  String get detectedApps;
  String get appScanTitle;
  String get appScanDescription;
  String get neverText;
  String get screenSettings;
  String get sectionDataStatus;
  String get sectionFileSync;
  String get sectionServerSync;
  String get sectionActions;
  String get settingsTotalEntries;
  String get settingsLastScan;
  String get exportTitle;
  String get exportSubtitle;
  String get importTitle;
  String get importSubtitle;
  String get noServerConfigured;
  String get actionPush;
  String get actionPull;
  String get refreshData;
  String get deleteAllData;
  String get deleteAllTitle;
  String get deleteAllContent;
  String get cancel;
  String get delete;
  String get save;
  String get libraryCleared;
  String get cancelled;
  String get serverConfigTitle;
  String get fieldServerUrl;
  String get fieldServerUrlHint;
  String get fieldBearerToken;
  String get aboutTitle;
  String get aboutSubtitle;
  String get detailDescription;
  String get detailDetails;
  String get detailTags;
  String get fieldArtist;
  String get fieldAlbum;
  String get fieldChannel;
  String get fieldSeasonEpisodeLabel;
  String get fieldLength;
  String get fieldLastOpened;
  String get fieldUsage;
  String get fieldProviderId;
  String get fieldLocalPath;
  String get openPlayStore;
  String get openBrowser;
  String get linkError;
  String get dialogTitleNew;
  String get dialogTitleEdit;
  String get fieldTitle;
  String get categoryLabel;
  String get fieldArtistOptional;
  String get fieldAlbumOptional;
  String get fieldChannelOptional;
  String get fieldDescriptionOptional;
  String get fieldTags;
  String get fieldTagsHint;
  String get markAsFavorite;

  String error(String msg);
  String foregroundMinutesLabel(int minutes);
  String bgScanSubtitle(int hours);
  String lastRun(String time);
  String scanResult(int matched, int persisted);
  String exportResult(String msg);
  String importResult(String msg);
  String pushPullStatus(String push, String pull);
  String seasonEpisode(int s, int e);
  String usageMinutes(int n);
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) =>
      ['de', 'en'].contains(locale.languageCode);

  @override
  Future<AppLocalizations> load(Locale locale) {
    final AppLocalizations loc = locale.languageCode == 'en'
        ? _AppLocalizationsEn()
        : _AppLocalizationsDe();
    return SynchronousFuture<AppLocalizations>(loc);
  }

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

class _AppLocalizationsDe extends AppLocalizations {
  @override String get appTitle => 'MediaBrain';
  @override String get navLibrary => 'Bibliothek';
  @override String get navScan => 'Scan';
  @override String get navMore => 'Mehr';
  @override String get screenLibrary => 'Bibliothek';
  @override String get fabAdd => 'Eintrag';
  @override String get searchHint => 'Suchen (Titel, Künstler, Kanal …)';
  @override String get filterAll => 'Alle';
  @override String get filterFavorites => '⭐ Favoriten';
  @override String get emptyNoMatch => 'Keine Treffer für deine Filter.';
  @override String get emptyNoItems =>
      'Noch leer.\nTippe auf den "Scan"-Tab, um deine Medien-Apps automatisch zu erfassen.';
  @override String get screenScan => 'Scan';
  @override String get scanDescription =>
      'Sucht installierte Medien-Apps (Streaming, Musik, Podcasts, '
      'Dokumente) und schreibt sie als Einträge in deine Bibliothek. '
      'Mit aktiviertem Nutzungsdatenzugriff bekommst du zusätzlich die '
      'tatsächliche Nutzungszeit.';
  @override String get btnAppScan => 'App-Scan (Aggregat-Nutzung)';
  @override String get bgScanTitle => 'Hintergrund-Scan';
  @override String get bgScanNow => 'Jetzt einmal im Hintergrund laufen lassen';
  @override String get bgScanNowSubtitle =>
      'Sendet einen One-Off-Task an Android. Resultat erscheint nach 1–2 Minuten.';
  @override String get bgScanQueued =>
      'Hintergrund-Scan in der Warteschlange — Resultat in ~1 min sichtbar';
  @override String get scanAndroidOnly => 'Scan ist nur unter Android verfügbar.';
  @override String get scanPermissionMissing =>
      'Nutzungsdatenzugriff fehlt. Bitte in den System-Einstellungen für MediaBrain aktivieren:\n\n'
      'Einstellungen → Apps → Spezieller App-Zugriff → Nutzungsdatenzugriff → MediaBrain.';
  @override String get detectedTitle => '📡 Was wird erkannt?';
  @override String get detectedApps =>
      'Netflix · Disney+ · Prime Video · Apple TV · YouTube · Twitch · '
      'Spotify · Apple Music · YouTube Music · Tidal · Amazon Music · '
      'Audible · Kindle · Pocket Casts · Google Podcasts · '
      'Adobe Acrobat · Google Docs · Notion · Obsidian und weitere.';
  @override String get appScanTitle => '🔍 App-Scan';
  @override String get appScanDescription =>
      'App-Scan: ein Eintrag pro Medien-App mit Gesamt-Nutzung '
      'der letzten Tage (über Android-Nutzungsdaten).';
  @override String get neverText => 'nie';
  @override String get screenSettings => 'Einstellungen';
  @override String get sectionDataStatus => 'Datenstand';
  @override String get sectionFileSync => 'Datei-Sync';
  @override String get sectionServerSync => 'Server-Sync (Mac Studio)';
  @override String get sectionActions => 'Aktionen';
  @override String get settingsTotalEntries => 'Gesamt-Einträge';
  @override String get settingsLastScan => 'Letzter Scan';
  @override String get exportTitle => 'Export per Share';
  @override String get exportSubtitle =>
      'JSON über Mail, OneDrive, Telegram an dich selbst …';
  @override String get importTitle => 'Import-Datei wählen';
  @override String get importSubtitle => 'Überschreibt den lokalen Stand';
  @override String get noServerConfigured => 'Kein Server konfiguriert';
  @override String get actionPush => 'Push';
  @override String get actionPull => 'Pull';
  @override String get refreshData => 'Datenstand aktualisieren';
  @override String get deleteAllData => 'Alle Bibliotheks-Daten löschen';
  @override String get deleteAllTitle => 'Alle Bibliotheks-Daten löschen?';
  @override String get deleteAllContent =>
      'Entfernt alle Einträge aus dem lokalen MediaBrain.';
  @override String get cancel => 'Abbrechen';
  @override String get delete => 'Löschen';
  @override String get save => 'Speichern';
  @override String get libraryCleared => 'Bibliothek gelöscht.';
  @override String get cancelled => 'Abgebrochen.';
  @override String get serverConfigTitle => 'Server-Sync konfigurieren';
  @override String get fieldServerUrl => 'Server-URL';
  @override String get fieldServerUrlHint => 'z.B. macstudvonlukas:8082';
  @override String get fieldBearerToken => 'Bearer-Token';
  @override String get aboutTitle => 'MediaBrain Mobile';
  @override String get aboutSubtitle =>
      'Standalone Flutter-App. Erkennt installierte Medien-Apps, '
      'führt manuelle Einträge und synchronisiert per Datei oder Server.';
  @override String get detailDescription => 'Beschreibung';
  @override String get detailDetails => 'Details';
  @override String get detailTags => 'Tags';
  @override String get fieldArtist => 'Künstler';
  @override String get fieldAlbum => 'Album';
  @override String get fieldChannel => 'Kanal';
  @override String get fieldSeasonEpisodeLabel => 'Staffel/Folge';
  @override String get fieldLength => 'Länge';
  @override String get fieldLastOpened => 'Zuletzt geöffnet';
  @override String get fieldUsage => 'Nutzung';
  @override String get fieldProviderId => 'Provider-ID';
  @override String get fieldLocalPath => 'Lokaler Pfad';
  @override String get openPlayStore => 'Im Play Store öffnen';
  @override String get openBrowser => 'Im Browser öffnen';
  @override String get linkError => 'Link konnte nicht geöffnet werden.';
  @override String get dialogTitleNew => 'Neuer Eintrag';
  @override String get dialogTitleEdit => 'Eintrag bearbeiten';
  @override String get fieldTitle => 'Titel';
  @override String get categoryLabel => 'Kategorie';
  @override String get fieldArtistOptional => 'Künstler / Regie (optional)';
  @override String get fieldAlbumOptional => 'Album / Serie (optional)';
  @override String get fieldChannelOptional => 'Kanal / Quelle (optional)';
  @override String get fieldDescriptionOptional => 'Beschreibung (optional)';
  @override String get fieldTags => 'Tags (Komma-getrennt)';
  @override String get fieldTagsHint => 'z.B. Dokumentation, Wochenende';
  @override String get markAsFavorite => 'Als Favorit markieren';

  @override String error(String msg) => 'Fehler: $msg';
  @override String foregroundMinutesLabel(int minutes) => '$minutes Min insgesamt';
  @override String bgScanSubtitle(int hours) =>
      'Alle ~$hours h scannen, auch wenn die App geschlossen ist.';
  @override String lastRun(String time) => 'Letzter Lauf: $time';
  @override String scanResult(int matched, int persisted) =>
      'Apps-Scan: $matched Medien-Apps gefunden, $persisted Einträge übernommen.';
  @override String exportResult(String msg) => 'Export: $msg';
  @override String importResult(String msg) => 'Import: $msg';
  @override String pushPullStatus(String push, String pull) =>
      'Push: $push · Pull: $pull';
  @override String seasonEpisode(int s, int e) => 'S$s E$e';
  @override String usageMinutes(int n) => '$n ${n == 1 ? 'Minute' : 'Minuten'}';
}

class _AppLocalizationsEn extends AppLocalizations {
  @override String get appTitle => 'MediaBrain';
  @override String get navLibrary => 'Library';
  @override String get navScan => 'Scan';
  @override String get navMore => 'More';
  @override String get screenLibrary => 'Library';
  @override String get fabAdd => 'Add';
  @override String get searchHint => 'Search (Title, Artist, Channel …)';
  @override String get filterAll => 'All';
  @override String get filterFavorites => '⭐ Favorites';
  @override String get emptyNoMatch => 'No results for your filters.';
  @override String get emptyNoItems =>
      'Empty yet.\nTap the "Scan" tab to automatically detect your media apps.';
  @override String get screenScan => 'Scan';
  @override String get scanDescription =>
      'Searches for installed media apps (streaming, music, podcasts, '
      'documents) and adds them as entries to your library. '
      'With enabled usage data access you additionally get the actual usage time.';
  @override String get btnAppScan => 'App Scan (Aggregate Usage)';
  @override String get bgScanTitle => 'Background Scan';
  @override String get bgScanNow => 'Run once in background now';
  @override String get bgScanNowSubtitle =>
      'Sends a one-off task to Android. Result appears after 1–2 minutes.';
  @override String get bgScanQueued =>
      'Background scan queued — result visible in ~1 min';
  @override String get scanAndroidOnly => 'Scan is only available on Android.';
  @override String get scanPermissionMissing =>
      'Usage data access missing. Please enable in system settings for MediaBrain:\n\n'
      'Settings → Apps → Special app access → Usage data access → MediaBrain.';
  @override String get detectedTitle => '📡 What is detected?';
  @override String get detectedApps =>
      'Netflix · Disney+ · Prime Video · Apple TV · YouTube · Twitch · '
      'Spotify · Apple Music · YouTube Music · Tidal · Amazon Music · '
      'Audible · Kindle · Pocket Casts · Google Podcasts · '
      'Adobe Acrobat · Google Docs · Notion · Obsidian and more.';
  @override String get appScanTitle => '🔍 App Scan';
  @override String get appScanDescription =>
      'App Scan: one entry per media app with total usage '
      'over the last days (via Android usage stats).';
  @override String get neverText => 'never';
  @override String get screenSettings => 'Settings';
  @override String get sectionDataStatus => 'Data Status';
  @override String get sectionFileSync => 'File Sync';
  @override String get sectionServerSync => 'Server Sync (Mac Studio)';
  @override String get sectionActions => 'Actions';
  @override String get settingsTotalEntries => 'Total Entries';
  @override String get settingsLastScan => 'Last Scan';
  @override String get exportTitle => 'Export via Share';
  @override String get exportSubtitle =>
      'JSON via Mail, OneDrive, Telegram to yourself …';
  @override String get importTitle => 'Choose Import File';
  @override String get importSubtitle => 'Overwrites local data';
  @override String get noServerConfigured => 'No server configured';
  @override String get actionPush => 'Push';
  @override String get actionPull => 'Pull';
  @override String get refreshData => 'Refresh data';
  @override String get deleteAllData => 'Delete all library data';
  @override String get deleteAllTitle => 'Delete all library data?';
  @override String get deleteAllContent =>
      'Removes all entries from the local MediaBrain.';
  @override String get cancel => 'Cancel';
  @override String get delete => 'Delete';
  @override String get save => 'Save';
  @override String get libraryCleared => 'Library cleared.';
  @override String get cancelled => 'Cancelled.';
  @override String get serverConfigTitle => 'Configure Server Sync';
  @override String get fieldServerUrl => 'Server URL';
  @override String get fieldServerUrlHint => 'e.g. macstudvonlukas:8082';
  @override String get fieldBearerToken => 'Bearer Token';
  @override String get aboutTitle => 'MediaBrain Mobile';
  @override String get aboutSubtitle =>
      'Standalone Flutter app. Detects installed media apps, '
      'tracks manual entries and syncs via file or server.';
  @override String get detailDescription => 'Description';
  @override String get detailDetails => 'Details';
  @override String get detailTags => 'Tags';
  @override String get fieldArtist => 'Artist';
  @override String get fieldAlbum => 'Album';
  @override String get fieldChannel => 'Channel';
  @override String get fieldSeasonEpisodeLabel => 'Season/Episode';
  @override String get fieldLength => 'Length';
  @override String get fieldLastOpened => 'Last opened';
  @override String get fieldUsage => 'Usage';
  @override String get fieldProviderId => 'Provider ID';
  @override String get fieldLocalPath => 'Local Path';
  @override String get openPlayStore => 'Open in Play Store';
  @override String get openBrowser => 'Open in Browser';
  @override String get linkError => 'Link could not be opened.';
  @override String get dialogTitleNew => 'New Entry';
  @override String get dialogTitleEdit => 'Edit Entry';
  @override String get fieldTitle => 'Title';
  @override String get categoryLabel => 'Category';
  @override String get fieldArtistOptional => 'Artist / Director (optional)';
  @override String get fieldAlbumOptional => 'Album / Series (optional)';
  @override String get fieldChannelOptional => 'Channel / Source (optional)';
  @override String get fieldDescriptionOptional => 'Description (optional)';
  @override String get fieldTags => 'Tags (comma-separated)';
  @override String get fieldTagsHint => 'e.g. Documentary, Weekend';
  @override String get markAsFavorite => 'Mark as favorite';

  @override String error(String msg) => 'Error: $msg';
  @override String foregroundMinutesLabel(int minutes) => '$minutes min total';
  @override String bgScanSubtitle(int hours) =>
      'Scan every ~$hours h, even when the app is closed.';
  @override String lastRun(String time) => 'Last run: $time';
  @override String scanResult(int matched, int persisted) =>
      'App scan: $matched media apps found, $persisted entries added.';
  @override String exportResult(String msg) => 'Export: $msg';
  @override String importResult(String msg) => 'Import: $msg';
  @override String pushPullStatus(String push, String pull) =>
      'Push: $push · Pull: $pull';
  @override String seasonEpisode(int s, int e) => 'S$s E$e';
  @override String usageMinutes(int n) => '$n ${n == 1 ? 'minute' : 'minutes'}';
}
