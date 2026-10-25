// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for German (`de`).
class AppLocalizationsDe extends AppLocalizations {
  AppLocalizationsDe([String locale = 'de']) : super(locale);

  @override
  String get appTitle => 'MediaBrain';

  @override
  String get navLibrary => 'Bibliothek';

  @override
  String get navScan => 'Scan';

  @override
  String get navMore => 'Mehr';

  @override
  String get screenLibrary => 'Bibliothek';

  @override
  String get fabAdd => 'Eintrag';

  @override
  String get searchHint => 'Suchen (Titel, Künstler, Kanal …)';

  @override
  String get filterAll => 'Alle';

  @override
  String get filterFavorites => '⭐ Favoriten';

  @override
  String get emptyNoMatch => 'Keine Treffer für deine Filter.';

  @override
  String get emptyNoItems =>
      'Noch leer.\nTippe auf den \"Scan\"-Tab, um deine Medien-Apps automatisch zu erfassen.';

  @override
  String get screenScan => 'Scan';

  @override
  String get scanDescription =>
      'Sucht installierte Medien-Apps (Streaming, Musik, Podcasts, Dokumente) und schreibt sie als Einträge in deine Bibliothek. Mit aktiviertem Nutzungsdatenzugriff bekommst du zusätzlich die tatsächliche Nutzungszeit.';

  @override
  String get btnAppScan => 'App-Scan (Aggregat-Nutzung)';

  @override
  String get bgScanTitle => 'Hintergrund-Scan';

  @override
  String get bgScanNow => 'Jetzt einmal im Hintergrund laufen lassen';

  @override
  String get bgScanNowSubtitle =>
      'Sendet einen One-Off-Task an Android. Resultat erscheint nach 1–2 Minuten.';

  @override
  String get bgScanQueued =>
      'Hintergrund-Scan in der Warteschlange — Resultat in ~1 min sichtbar';

  @override
  String get scanAndroidOnly => 'Scan ist nur unter Android verfügbar.';

  @override
  String get scanPermissionMissing =>
      'Nutzungsdatenzugriff fehlt. Bitte in den System-Einstellungen für MediaBrain aktivieren:\n\nEinstellungen → Apps → Spezieller App-Zugriff → Nutzungsdatenzugriff → MediaBrain.';

  @override
  String get detectedTitle => '📡 Was wird erkannt?';

  @override
  String get detectedApps =>
      'Netflix · Disney+ · Prime Video · Apple TV · YouTube · Twitch · Spotify · Apple Music · YouTube Music · Tidal · Amazon Music · Audible · Kindle · Pocket Casts · Google Podcasts · Adobe Acrobat · Google Docs · Notion · Obsidian und weitere.';

  @override
  String get appScanTitle => '🔍 App-Scan';

  @override
  String get appScanDescription =>
      'App-Scan: ein Eintrag pro Medien-App mit Gesamt-Nutzung der letzten Tage (über Android-Nutzungsdaten).';

  @override
  String get neverText => 'nie';

  @override
  String get screenSettings => 'Einstellungen';

  @override
  String get sectionDataStatus => 'Datenstand';

  @override
  String get sectionFileSync => 'Datei-Sync';

  @override
  String get sectionServerSync => 'Server-Sync (Mac Studio)';

  @override
  String get sectionActions => 'Aktionen';

  @override
  String get settingsTotalEntries => 'Gesamt-Einträge';

  @override
  String get settingsLastScan => 'Letzter Scan';

  @override
  String get exportTitle => 'Export per Share';

  @override
  String get exportSubtitle =>
      'JSON über Mail, OneDrive, Telegram an dich selbst …';

  @override
  String get importTitle => 'Import-Datei wählen';

  @override
  String get importSubtitle => 'Überschreibt den lokalen Stand';

  @override
  String get noServerConfigured => 'Kein Server konfiguriert';

  @override
  String get actionPush => 'Push';

  @override
  String get actionPull => 'Pull';

  @override
  String get refreshData => 'Datenstand aktualisieren';

  @override
  String get deleteAllData => 'Alle Bibliotheks-Daten löschen';

  @override
  String get deleteAllTitle => 'Alle Bibliotheks-Daten löschen?';

  @override
  String get deleteAllContent =>
      'Entfernt alle Einträge aus dem lokalen MediaBrain.';

  @override
  String get cancel => 'Abbrechen';

  @override
  String get delete => 'Löschen';

  @override
  String get save => 'Speichern';

  @override
  String get libraryCleared => 'Bibliothek gelöscht.';

  @override
  String get cancelled => 'Abgebrochen.';

  @override
  String get serverConfigTitle => 'Server-Sync konfigurieren';

  @override
  String get fieldServerUrl => 'Server-URL';

  @override
  String get fieldServerUrlHint => 'z.B. macstudvonlukas:8082';

  @override
  String get fieldBearerToken => 'Bearer-Token';

  @override
  String get aboutTitle => 'MediaBrain Mobile';

  @override
  String get aboutSubtitle =>
      'Standalone Flutter-App. Erkennt installierte Medien-Apps, führt manuelle Einträge und synchronisiert per Datei oder Server.';

  @override
  String get detailDescription => 'Beschreibung';

  @override
  String get detailDetails => 'Details';

  @override
  String get detailTags => 'Tags';

  @override
  String get fieldArtist => 'Künstler';

  @override
  String get fieldAlbum => 'Album';

  @override
  String get fieldChannel => 'Kanal';

  @override
  String get fieldSeasonEpisodeLabel => 'Staffel/Folge';

  @override
  String get fieldLength => 'Länge';

  @override
  String get fieldLastOpened => 'Zuletzt geöffnet';

  @override
  String get fieldUsage => 'Nutzung';

  @override
  String get fieldProviderId => 'Provider-ID';

  @override
  String get fieldLocalPath => 'Lokaler Pfad';

  @override
  String get openPlayStore => 'Im Play Store öffnen';

  @override
  String get openBrowser => 'Im Browser öffnen';

  @override
  String get linkError => 'Link konnte nicht geöffnet werden.';

  @override
  String get dialogTitleNew => 'Neuer Eintrag';

  @override
  String get dialogTitleEdit => 'Eintrag bearbeiten';

  @override
  String get fieldTitle => 'Titel';

  @override
  String get categoryLabel => 'Kategorie';

  @override
  String get fieldArtistOptional => 'Künstler / Regie (optional)';

  @override
  String get fieldAlbumOptional => 'Album / Serie (optional)';

  @override
  String get fieldChannelOptional => 'Kanal / Quelle (optional)';

  @override
  String get fieldDescriptionOptional => 'Beschreibung (optional)';

  @override
  String get fieldTags => 'Tags (Komma-getrennt)';

  @override
  String get fieldTagsHint => 'z.B. Dokumentation, Wochenende';

  @override
  String get markAsFavorite => 'Als Favorit markieren';

  @override
  String error(String msg) {
    return 'Fehler: $msg';
  }

  @override
  String foregroundMinutesLabel(int minutes) {
    return '$minutes Min insgesamt';
  }

  @override
  String bgScanSubtitle(int hours) {
    return 'Alle ~$hours h scannen, auch wenn die App geschlossen ist.';
  }

  @override
  String lastRun(String time) {
    return 'Letzter Lauf: $time';
  }

  @override
  String scanResult(int matched, int persisted) {
    return 'Apps-Scan: $matched Medien-Apps gefunden, $persisted Einträge übernommen.';
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
    return '$n Minuten';
  }

  @override
  String get navPlaylists => 'Playlists';

  @override
  String get screenPlaylists => 'Playlists & Sammlungen';

  @override
  String get playlistTypeManual => 'Manuell';

  @override
  String get playlistTypeSmart => 'Smart (Dynamischer Filter)';

  @override
  String get dialogNewPlaylist => 'Neue Playlist';

  @override
  String get dialogEditPlaylist => 'Playlist bearbeiten';

  @override
  String get fieldPlaylistName => 'Name der Playlist';

  @override
  String get fieldPlaylistDescription => 'Beschreibung (optional)';

  @override
  String get fieldPlaylistType => 'Playlist-Typ';

  @override
  String get smartFilterCriteria => 'Smarte Filterkriterien';

  @override
  String get smartFilterCategory => 'Kategorie';

  @override
  String get smartFilterTag => 'Tag / Stichwort';

  @override
  String get smartFilterFavoritesOnly => 'Nur Favoriten';

  @override
  String get smartFilterMinMinutes => 'Minimale Nutzungszeit (Min.)';

  @override
  String get smartFilterSearch => 'Suchbegriff';

  @override
  String get emptyPlaylists =>
      'Noch keine Playlists angelegt.\nErstelle manuelle Sammlungen oder dynamische Smart-Playlists.';

  @override
  String get emptyPlaylistItems => 'Diese Playlist enthält noch keine Medien.';

  @override
  String get deletePlaylistTitle => 'Playlist löschen?';

  @override
  String get deletePlaylistContent =>
      'Möchtest du diese Playlist wirklich löschen? Die enthaltenen Medien bleiben in der Bibliothek erhalten.';

  @override
  String get addToPlaylist => 'Zu Playlist hinzufügen';

  @override
  String get removeFromPlaylist => 'Aus Playlist entfernen';

  @override
  String get addedToPlaylist => 'Zur Playlist hinzugefügt.';

  @override
  String get removedFromPlaylist => 'Aus Playlist entfernt.';

  @override
  String get filterByTag => 'Tag-Filter';

  @override
  String get allTags => 'Alle Tags';

  @override
  String get addTag => 'Tag hinzufügen';

  @override
  String get removeTag => 'Tag entfernen';

  @override
  String get noPlaylistsFound => 'Keine Playlists vorhanden.';

  @override
  String playlistItemCount(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Einträge',
      one: '$count Eintrag',
    );
    return '$_temp0';
  }

  @override
  String tagCount(String tag, int count) {
    return '#$tag ($count)';
  }
}
