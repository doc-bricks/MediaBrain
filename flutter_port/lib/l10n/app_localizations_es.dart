// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get appTitle => 'MediaBrain';

  @override
  String get navLibrary => 'Biblioteca';

  @override
  String get navScan => 'Escanear';

  @override
  String get navMore => 'Más';

  @override
  String get screenLibrary => 'Biblioteca';

  @override
  String get fabAdd => 'Añadir';

  @override
  String get searchHint => 'Buscar (título, artista, canal …)';

  @override
  String get filterAll => 'Todo';

  @override
  String get filterFavorites => '⭐ Favoritos';

  @override
  String get emptyNoMatch => 'No hay resultados para tus filtros.';

  @override
  String get emptyNoItems =>
      'Aún está vacío.\nPulsa la pestaña Escanear para detectar automáticamente tus aplicaciones multimedia.';

  @override
  String get screenScan => 'Escanear';

  @override
  String get scanDescription =>
      'Busca aplicaciones multimedia instaladas (streaming, música, pódcasts y documentos) y las añade a tu biblioteca. Si permites el acceso a los datos de uso, también obtendrás el tiempo de uso real.';

  @override
  String get btnAppScan => 'Escaneo de aplicaciones (uso agregado)';

  @override
  String get bgScanTitle => 'Escaneo en segundo plano';

  @override
  String get bgScanNow => 'Ejecutar ahora una vez en segundo plano';

  @override
  String get bgScanNowSubtitle =>
      'Envía una tarea puntual a Android. El resultado aparecerá después de 1–2 minutos.';

  @override
  String get bgScanQueued =>
      'Escaneo en cola — el resultado estará visible en ~1 min';

  @override
  String get scanAndroidOnly => 'El escaneo solo está disponible en Android.';

  @override
  String get scanPermissionMissing =>
      'Falta el acceso a los datos de uso. Actívalo en los ajustes del sistema para MediaBrain:\n\nAjustes → Aplicaciones → Acceso especial a aplicaciones → Acceso a datos de uso → MediaBrain.';

  @override
  String get detectedTitle => '📡 ¿Qué se detecta?';

  @override
  String get detectedApps =>
      'Netflix · Disney+ · Prime Video · Apple TV · YouTube · Twitch · Spotify · Apple Music · YouTube Music · Tidal · Amazon Music · Audible · Kindle · Pocket Casts · Google Podcasts · Adobe Acrobat · Google Docs · Notion · Obsidian y más.';

  @override
  String get appScanTitle => '🔍 Escaneo de aplicaciones';

  @override
  String get appScanDescription =>
      'Escaneo de aplicaciones: una entrada por aplicación multimedia con el uso total de los últimos días (mediante las estadísticas de uso de Android).';

  @override
  String get neverText => 'Nunca';

  @override
  String get screenSettings => 'Ajustes';

  @override
  String get sectionDataStatus => 'Estado de datos';

  @override
  String get sectionFileSync => 'Sincronización de archivos';

  @override
  String get sectionServerSync => 'Sincronización del servidor (Mac Studio)';

  @override
  String get sectionActions => 'Acciones';

  @override
  String get settingsTotalEntries => 'Total de entradas';

  @override
  String get settingsLastScan => 'Último escaneo';

  @override
  String get exportTitle => 'Exportar mediante Compartir';

  @override
  String get exportSubtitle =>
      'JSON por correo, OneDrive o Telegram a ti mismo …';

  @override
  String get importTitle => 'Elegir archivo de importación';

  @override
  String get importSubtitle => 'Sobrescribe los datos locales';

  @override
  String get noServerConfigured => 'No hay servidor configurado';

  @override
  String get actionPush => 'Enviar';

  @override
  String get actionPull => 'Recibir';

  @override
  String get refreshData => 'Actualizar datos';

  @override
  String get deleteAllData => 'Eliminar todos los datos de la biblioteca';

  @override
  String get deleteAllTitle => '¿Eliminar todos los datos de la biblioteca?';

  @override
  String get deleteAllContent =>
      'Elimina todas las entradas del MediaBrain local.';

  @override
  String get cancel => 'Cancelar';

  @override
  String get delete => 'Eliminar';

  @override
  String get save => 'Guardar';

  @override
  String get libraryCleared => 'Biblioteca vaciada.';

  @override
  String get cancelled => 'Cancelado.';

  @override
  String get serverConfigTitle => 'Configurar sincronización del servidor';

  @override
  String get fieldServerUrl => 'URL del servidor';

  @override
  String get fieldServerUrlHint => 'p. ej., macstudvonlukas:8082';

  @override
  String get fieldBearerToken => 'Token de portador';

  @override
  String get aboutTitle => 'MediaBrain Mobile';

  @override
  String get aboutSubtitle =>
      'Aplicación Flutter independiente. Detecta aplicaciones multimedia instaladas, registra entradas manuales y sincroniza mediante archivo o servidor.';

  @override
  String get detailDescription => 'Descripción';

  @override
  String get detailDetails => 'Detalles';

  @override
  String get detailTags => 'Etiquetas';

  @override
  String get fieldArtist => 'Artista';

  @override
  String get fieldAlbum => 'Álbum';

  @override
  String get fieldChannel => 'Canal';

  @override
  String get fieldSeasonEpisodeLabel => 'Temporada/Episodio';

  @override
  String get fieldLength => 'Duración';

  @override
  String get fieldLastOpened => 'Última apertura';

  @override
  String get fieldUsage => 'Uso';

  @override
  String get fieldProviderId => 'ID del proveedor';

  @override
  String get fieldLocalPath => 'Ruta local';

  @override
  String get openPlayStore => 'Abrir en Play Store';

  @override
  String get openBrowser => 'Abrir en el navegador';

  @override
  String get linkError => 'No se pudo abrir el enlace.';

  @override
  String get dialogTitleNew => 'Nueva entrada';

  @override
  String get dialogTitleEdit => 'Editar entrada';

  @override
  String get fieldTitle => 'Título';

  @override
  String get categoryLabel => 'Categoría';

  @override
  String get fieldArtistOptional => 'Artista / director (opcional)';

  @override
  String get fieldAlbumOptional => 'Álbum / serie (opcional)';

  @override
  String get fieldChannelOptional => 'Canal / fuente (opcional)';

  @override
  String get fieldDescriptionOptional => 'Descripción (opcional)';

  @override
  String get fieldTags => 'Etiquetas (separadas por comas)';

  @override
  String get fieldTagsHint => 'p. ej., Documental, fin de semana';

  @override
  String get markAsFavorite => 'Marcar como favorito';

  @override
  String error(String msg) {
    return 'Error: $msg';
  }

  @override
  String foregroundMinutesLabel(int minutes) {
    return 'Total: $minutes min';
  }

  @override
  String bgScanSubtitle(int hours) {
    return 'Escanear cada ~$hours h, incluso cuando la aplicación esté cerrada.';
  }

  @override
  String lastRun(String time) {
    return 'Última ejecución: $time';
  }

  @override
  String scanResult(int matched, int persisted) {
    return 'Escaneo de aplicaciones: se encontraron $matched aplicaciones multimedia y se añadieron $persisted entradas.';
  }

  @override
  String exportResult(String msg) {
    return 'Exportación: $msg';
  }

  @override
  String importResult(String msg) {
    return 'Importación: $msg';
  }

  @override
  String pushPullStatus(String push, String pull) {
    return 'Enviar: $push · Recibir: $pull';
  }

  @override
  String seasonEpisode(int s, int e) {
    return 'T$s E$e';
  }

  @override
  String usageMinutes(int n) {
    return '$n minutos';
  }

  @override
  String get navPlaylists => 'Listas de reproducción';

  @override
  String get screenPlaylists => 'Listas y colecciones';

  @override
  String get playlistTypeManual => 'Manual';

  @override
  String get playlistTypeSmart => 'Inteligente (filtro dinámico)';

  @override
  String get dialogNewPlaylist => 'Nueva lista de reproducción';

  @override
  String get dialogEditPlaylist => 'Editar lista de reproducción';

  @override
  String get fieldPlaylistName => 'Nombre de la lista de reproducción';

  @override
  String get fieldPlaylistDescription => 'Descripción (opcional)';

  @override
  String get fieldPlaylistType => 'Tipo de lista de reproducción';

  @override
  String get smartFilterCriteria => 'Criterios de filtro inteligente';

  @override
  String get smartFilterCategory => 'Categoría';

  @override
  String get smartFilterTag => 'Etiqueta / palabra clave';

  @override
  String get smartFilterFavoritesOnly => 'Solo favoritos';

  @override
  String get smartFilterMinMinutes => 'Tiempo mínimo de uso (min)';

  @override
  String get smartFilterSearch => 'Término de búsqueda';

  @override
  String get emptyPlaylists =>
      'Todavía no hay listas de reproducción.\nCrea colecciones manuales o listas inteligentes dinámicas.';

  @override
  String get emptyPlaylistItems =>
      'Esta lista todavía no contiene contenido multimedia.';

  @override
  String get deletePlaylistTitle => '¿Eliminar lista de reproducción?';

  @override
  String get deletePlaylistContent =>
      '¿De verdad quieres eliminar esta lista de reproducción? Los medios incluidos permanecerán en tu biblioteca.';

  @override
  String get addToPlaylist => 'Añadir a la lista de reproducción';

  @override
  String get removeFromPlaylist => 'Quitar de la lista de reproducción';

  @override
  String get addedToPlaylist => 'Añadido a la lista de reproducción.';

  @override
  String get removedFromPlaylist => 'Quitado de la lista de reproducción.';

  @override
  String get filterByTag => 'Filtro de etiquetas';

  @override
  String get allTags => 'Todas las etiquetas';

  @override
  String get addTag => 'Añadir etiqueta';

  @override
  String get removeTag => 'Quitar etiqueta';

  @override
  String get noPlaylistsFound => 'No hay listas de reproducción disponibles.';

  @override
  String playlistItemCount(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count elementos',
      one: '$count elemento',
    );
    return '$_temp0';
  }

  @override
  String tagCount(String tag, int count) {
    return '#$tag ($count)';
  }
}
