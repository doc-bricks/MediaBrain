// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class AppLocalizationsFr extends AppLocalizations {
  AppLocalizationsFr([String locale = 'fr']) : super(locale);

  @override
  String get appTitle => 'MediaBrain';

  @override
  String get navLibrary => 'Bibliothèque';

  @override
  String get navScan => 'Scanner';

  @override
  String get navMore => 'Plus';

  @override
  String get screenLibrary => 'Bibliothèque';

  @override
  String get fabAdd => 'Ajouter';

  @override
  String get searchHint => 'Rechercher (titre, artiste, chaîne …)';

  @override
  String get filterAll => 'Tout';

  @override
  String get filterFavorites => '⭐ Favoris';

  @override
  String get emptyNoMatch => 'Aucun résultat ne correspond à vos filtres.';

  @override
  String get emptyNoItems =>
      'Encore vide.\nTouchez l’onglet Scanner pour détecter automatiquement vos applications multimédias.';

  @override
  String get screenScan => 'Scanner';

  @override
  String get scanDescription =>
      'Recherche les applications multimédias installées (streaming, musique, podcasts, documents) et les ajoute à votre bibliothèque. Si l’accès aux données d’utilisation est activé, le temps d’utilisation réel est également disponible.';

  @override
  String get btnAppScan => 'Analyse des applications (utilisation agrégée)';

  @override
  String get bgScanTitle => 'Analyse en arrière-plan';

  @override
  String get bgScanNow => 'Lancer une fois en arrière-plan maintenant';

  @override
  String get bgScanNowSubtitle =>
      'Envoie une tâche ponctuelle à Android. Le résultat apparaît après 1 à 2 minutes.';

  @override
  String get bgScanQueued =>
      'Analyse en arrière-plan en attente — résultat visible dans environ 1 min';

  @override
  String get scanAndroidOnly =>
      'L’analyse est uniquement disponible sur Android.';

  @override
  String get scanPermissionMissing =>
      'Accès aux données d’utilisation manquant. Activez-le dans les paramètres système de MediaBrain :\n\nParamètres → Applications → Accès spécial aux applications → Accès aux données d’utilisation → MediaBrain.';

  @override
  String get detectedTitle => '📡 Éléments détectés';

  @override
  String get detectedApps =>
      'Netflix · Disney+ · Prime Video · Apple TV · YouTube · Twitch · Spotify · Apple Music · YouTube Music · Tidal · Amazon Music · Audible · Kindle · Pocket Casts · Google Podcasts · Adobe Acrobat · Google Docs · Notion · Obsidian et plus encore.';

  @override
  String get appScanTitle => '🔍 Analyse des applications';

  @override
  String get appScanDescription =>
      'Analyse des applications : une entrée par application multimédia, avec l’utilisation totale des derniers jours (via les statistiques d’utilisation Android).';

  @override
  String get neverText => 'jamais';

  @override
  String get screenSettings => 'Paramètres';

  @override
  String get sectionDataStatus => 'État des données';

  @override
  String get sectionFileSync => 'Synchronisation des fichiers';

  @override
  String get sectionServerSync => 'Synchronisation serveur (Mac Studio)';

  @override
  String get sectionActions => 'Actions';

  @override
  String get settingsTotalEntries => 'Nombre total d’entrées';

  @override
  String get settingsLastScan => 'Dernière analyse';

  @override
  String get exportTitle => 'Exporter via Partager';

  @override
  String get exportSubtitle =>
      'JSON par e-mail, OneDrive ou Telegram à vous-même …';

  @override
  String get importTitle => 'Choisir le fichier à importer';

  @override
  String get importSubtitle => 'Remplace les données locales';

  @override
  String get noServerConfigured => 'Aucun serveur configuré';

  @override
  String get actionPush => 'Envoyer';

  @override
  String get actionPull => 'Récupérer';

  @override
  String get refreshData => 'Actualiser les données';

  @override
  String get deleteAllData => 'Supprimer toutes les données de la bibliothèque';

  @override
  String get deleteAllTitle =>
      'Supprimer toutes les données de la bibliothèque ?';

  @override
  String get deleteAllContent =>
      'Supprime toutes les entrées du MediaBrain local.';

  @override
  String get cancel => 'Annuler';

  @override
  String get delete => 'Supprimer';

  @override
  String get save => 'Enregistrer';

  @override
  String get libraryCleared => 'Bibliothèque vidée.';

  @override
  String get cancelled => 'Annulé.';

  @override
  String get serverConfigTitle => 'Configurer la synchronisation du serveur';

  @override
  String get fieldServerUrl => 'URL du serveur';

  @override
  String get fieldServerUrlHint => 'p. ex. macstudvonlukas:8082';

  @override
  String get fieldBearerToken => 'Jeton Bearer';

  @override
  String get aboutTitle => 'MediaBrain Mobile';

  @override
  String get aboutSubtitle =>
      'Application Flutter autonome. Détecte les applications multimédias installées, suit les entrées manuelles et synchronise par fichier ou serveur.';

  @override
  String get detailDescription => 'Description';

  @override
  String get detailDetails => 'Détails';

  @override
  String get detailTags => 'Tags';

  @override
  String get fieldArtist => 'Artiste';

  @override
  String get fieldAlbum => 'Album';

  @override
  String get fieldChannel => 'Chaîne';

  @override
  String get fieldSeasonEpisodeLabel => 'Saison/épisode';

  @override
  String get fieldLength => 'Durée';

  @override
  String get fieldLastOpened => 'Dernière ouverture';

  @override
  String get fieldUsage => 'Utilisation';

  @override
  String get fieldProviderId => 'ID du fournisseur';

  @override
  String get fieldLocalPath => 'Chemin local';

  @override
  String get openPlayStore => 'Ouvrir dans le Play Store';

  @override
  String get openBrowser => 'Ouvrir dans le navigateur';

  @override
  String get linkError => 'Impossible d’ouvrir le lien.';

  @override
  String get dialogTitleNew => 'Nouvelle entrée';

  @override
  String get dialogTitleEdit => 'Modifier l’entrée';

  @override
  String get fieldTitle => 'Titre';

  @override
  String get categoryLabel => 'Catégorie';

  @override
  String get fieldArtistOptional => 'Artiste / réalisateur (facultatif)';

  @override
  String get fieldAlbumOptional => 'Album / série (facultatif)';

  @override
  String get fieldChannelOptional => 'Chaîne / source (facultatif)';

  @override
  String get fieldDescriptionOptional => 'Description (facultatif)';

  @override
  String get fieldTags => 'Tags (séparés par des virgules)';

  @override
  String get fieldTagsHint => 'p. ex. documentaire, week-end';

  @override
  String get markAsFavorite => 'Ajouter aux favoris';

  @override
  String error(String msg) {
    return 'Erreur : $msg';
  }

  @override
  String foregroundMinutesLabel(int minutes) {
    return '$minutes min au total';
  }

  @override
  String bgScanSubtitle(int hours) {
    return 'Analyser toutes les ~$hours h, même lorsque l’application est fermée.';
  }

  @override
  String lastRun(String time) {
    return 'Dernière exécution : $time';
  }

  @override
  String scanResult(int matched, int persisted) {
    return 'Analyse des applications : $matched applications multimédias détectées, $persisted entrées ajoutées.';
  }

  @override
  String exportResult(String msg) {
    return 'Export : $msg';
  }

  @override
  String importResult(String msg) {
    return 'Import : $msg';
  }

  @override
  String pushPullStatus(String push, String pull) {
    return 'Envoi : $push · Récupération : $pull';
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
  String get screenPlaylists => 'Playlists et collections';

  @override
  String get playlistTypeManual => 'Manuelle';

  @override
  String get playlistTypeSmart => 'Intelligente (filtre dynamique)';

  @override
  String get dialogNewPlaylist => 'Nouvelle playlist';

  @override
  String get dialogEditPlaylist => 'Modifier la playlist';

  @override
  String get fieldPlaylistName => 'Nom de la playlist';

  @override
  String get fieldPlaylistDescription => 'Description (facultative)';

  @override
  String get fieldPlaylistType => 'Type de playlist';

  @override
  String get smartFilterCriteria => 'Critères du filtre intelligent';

  @override
  String get smartFilterCategory => 'Catégorie';

  @override
  String get smartFilterTag => 'Tag / mot-clé';

  @override
  String get smartFilterFavoritesOnly => 'Favoris uniquement';

  @override
  String get smartFilterMinMinutes => 'Durée minimale d’utilisation (min)';

  @override
  String get smartFilterSearch => 'Terme de recherche';

  @override
  String get emptyPlaylists =>
      'Aucune playlist créée pour le moment.\nCréez des collections manuelles ou des playlists intelligentes dynamiques.';

  @override
  String get emptyPlaylistItems =>
      'Cette playlist ne contient encore aucun média.';

  @override
  String get deletePlaylistTitle => 'Supprimer la playlist ?';

  @override
  String get deletePlaylistContent =>
      'Voulez-vous vraiment supprimer cette playlist ? Les médias qu’elle contient resteront dans votre bibliothèque.';

  @override
  String get addToPlaylist => 'Ajouter à la playlist';

  @override
  String get removeFromPlaylist => 'Retirer de la playlist';

  @override
  String get addedToPlaylist => 'Ajouté à la playlist.';

  @override
  String get removedFromPlaylist => 'Retiré de la playlist.';

  @override
  String get filterByTag => 'Filtrer par tag';

  @override
  String get allTags => 'Tous les tags';

  @override
  String get addTag => 'Ajouter un tag';

  @override
  String get removeTag => 'Supprimer le tag';

  @override
  String get noPlaylistsFound => 'Aucune playlist disponible.';

  @override
  String playlistItemCount(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count éléments',
      one: '$count élément',
    );
    return '$_temp0';
  }

  @override
  String tagCount(String tag, int count) {
    return '#$tag ($count)';
  }
}
