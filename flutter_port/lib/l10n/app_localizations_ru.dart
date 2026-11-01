// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Russian (`ru`).
class AppLocalizationsRu extends AppLocalizations {
  AppLocalizationsRu([String locale = 'ru']) : super(locale);

  @override
  String get appTitle => 'MediaBrain';

  @override
  String get navLibrary => 'Библиотека';

  @override
  String get navScan => 'Сканирование';

  @override
  String get navMore => 'Ещё';

  @override
  String get screenLibrary => 'Библиотека';

  @override
  String get fabAdd => 'Добавить';

  @override
  String get searchHint => 'Поиск (название, исполнитель, канал …)';

  @override
  String get filterAll => 'Все';

  @override
  String get filterFavorites => '⭐ Избранное';

  @override
  String get emptyNoMatch => 'По заданным фильтрам ничего не найдено.';

  @override
  String get emptyNoItems =>
      'Пока пусто.\nНажмите вкладку «Сканирование», чтобы автоматически обнаружить медиаприложения.';

  @override
  String get screenScan => 'Сканирование';

  @override
  String get scanDescription =>
      'Ищет установленные медиаприложения (стриминг, музыка, подкасты, документы) и добавляет их в библиотеку. При включённом доступе к данным об использовании также будет доступно фактическое время использования.';

  @override
  String get btnAppScan => 'Сканирование приложений (сводное использование)';

  @override
  String get bgScanTitle => 'Фоновое сканирование';

  @override
  String get bgScanNow => 'Запустить один раз в фоне';

  @override
  String get bgScanNowSubtitle =>
      'Отправляет разовое задание в Android. Результат появится через 1–2 минуты.';

  @override
  String get bgScanQueued =>
      'Фоновое сканирование поставлено в очередь — результат будет примерно через минуту';

  @override
  String get scanAndroidOnly => 'Сканирование доступно только в Android.';

  @override
  String get scanPermissionMissing =>
      'Нет доступа к данным об использовании. Включите его в системных настройках MediaBrain:\n\nНастройки → Приложения → Специальный доступ приложений → Доступ к данным об использовании → MediaBrain.';

  @override
  String get detectedTitle => '📡 Что обнаруживается?';

  @override
  String get detectedApps =>
      'Netflix · Disney+ · Prime Video · Apple TV · YouTube · Twitch · Spotify · Apple Music · YouTube Music · Tidal · Amazon Music · Audible · Kindle · Pocket Casts · Google Podcasts · Adobe Acrobat · Google Docs · Notion · Obsidian и другие.';

  @override
  String get appScanTitle => '🔍 Сканирование приложений';

  @override
  String get appScanDescription =>
      'Сканирование приложений: отдельная запись для каждого медиаприложения с общим временем использования за последние дни (по статистике использования Android).';

  @override
  String get neverText => 'никогда';

  @override
  String get screenSettings => 'Настройки';

  @override
  String get sectionDataStatus => 'Состояние данных';

  @override
  String get sectionFileSync => 'Синхронизация файлов';

  @override
  String get sectionServerSync => 'Синхронизация с сервером (Mac Studio)';

  @override
  String get sectionActions => 'Действия';

  @override
  String get settingsTotalEntries => 'Всего записей';

  @override
  String get settingsLastScan => 'Последнее сканирование';

  @override
  String get exportTitle => 'Экспорт через «Поделиться»';

  @override
  String get exportSubtitle =>
      'Отправить JSON себе по почте, через OneDrive или Telegram …';

  @override
  String get importTitle => 'Выбрать файл для импорта';

  @override
  String get importSubtitle => 'Перезаписывает локальные данные';

  @override
  String get noServerConfigured => 'Сервер не настроен';

  @override
  String get actionPush => 'Отправить';

  @override
  String get actionPull => 'Получить';

  @override
  String get refreshData => 'Обновить данные';

  @override
  String get deleteAllData => 'Удалить все данные библиотеки';

  @override
  String get deleteAllTitle => 'Удалить все данные библиотеки?';

  @override
  String get deleteAllContent => 'Удаляет все записи из локального MediaBrain.';

  @override
  String get cancel => 'Отмена';

  @override
  String get delete => 'Удалить';

  @override
  String get save => 'Сохранить';

  @override
  String get libraryCleared => 'Библиотека очищена.';

  @override
  String get cancelled => 'Отменено.';

  @override
  String get serverConfigTitle => 'Настроить синхронизацию с сервером';

  @override
  String get fieldServerUrl => 'URL сервера';

  @override
  String get fieldServerUrlHint => 'например, macstudvonlukas:8082';

  @override
  String get fieldBearerToken => 'Токен Bearer';

  @override
  String get aboutTitle => 'MediaBrain Mobile';

  @override
  String get aboutSubtitle =>
      'Автономное приложение Flutter. Обнаруживает установленные медиаприложения, учитывает записи, добавленные вручную, и синхронизирует данные через файл или сервер.';

  @override
  String get detailDescription => 'Описание';

  @override
  String get detailDetails => 'Сведения';

  @override
  String get detailTags => 'Теги';

  @override
  String get fieldArtist => 'Исполнитель';

  @override
  String get fieldAlbum => 'Альбом';

  @override
  String get fieldChannel => 'Канал';

  @override
  String get fieldSeasonEpisodeLabel => 'Сезон/серия';

  @override
  String get fieldLength => 'Длительность';

  @override
  String get fieldLastOpened => 'Последнее открытие';

  @override
  String get fieldUsage => 'Использование';

  @override
  String get fieldProviderId => 'ID провайдера';

  @override
  String get fieldLocalPath => 'Локальный путь';

  @override
  String get openPlayStore => 'Открыть в Play Store';

  @override
  String get openBrowser => 'Открыть в браузере';

  @override
  String get linkError => 'Не удалось открыть ссылку.';

  @override
  String get dialogTitleNew => 'Новая запись';

  @override
  String get dialogTitleEdit => 'Изменить запись';

  @override
  String get fieldTitle => 'Название';

  @override
  String get categoryLabel => 'Категория';

  @override
  String get fieldArtistOptional => 'Исполнитель / режиссёр (необязательно)';

  @override
  String get fieldAlbumOptional => 'Альбом / сериал (необязательно)';

  @override
  String get fieldChannelOptional => 'Канал / источник (необязательно)';

  @override
  String get fieldDescriptionOptional => 'Описание (необязательно)';

  @override
  String get fieldTags => 'Теги (через запятую)';

  @override
  String get fieldTagsHint => 'например, документальный фильм, выходные';

  @override
  String get markAsFavorite => 'Добавить в избранное';

  @override
  String error(String msg) {
    return 'Ошибка: $msg';
  }

  @override
  String foregroundMinutesLabel(int minutes) {
    return 'Всего: $minutes мин';
  }

  @override
  String bgScanSubtitle(int hours) {
    return 'Сканировать каждые ~$hours ч, даже если приложение закрыто.';
  }

  @override
  String lastRun(String time) {
    return 'Последний запуск: $time';
  }

  @override
  String scanResult(int matched, int persisted) {
    return 'Сканирование приложений: найдено медиаприложений — $matched, добавлено записей — $persisted.';
  }

  @override
  String exportResult(String msg) {
    return 'Экспорт: $msg';
  }

  @override
  String importResult(String msg) {
    return 'Импорт: $msg';
  }

  @override
  String pushPullStatus(String push, String pull) {
    return 'Отправка: $push · Получение: $pull';
  }

  @override
  String seasonEpisode(int s, int e) {
    return 'S$s E$e';
  }

  @override
  String usageMinutes(int n) {
    return '$n мин';
  }

  @override
  String get navPlaylists => 'Плейлисты';

  @override
  String get screenPlaylists => 'Плейлисты и коллекции';

  @override
  String get playlistTypeManual => 'Вручную';

  @override
  String get playlistTypeSmart => 'Умный (динамический фильтр)';

  @override
  String get dialogNewPlaylist => 'Новый плейлист';

  @override
  String get dialogEditPlaylist => 'Изменить плейлист';

  @override
  String get fieldPlaylistName => 'Название плейлиста';

  @override
  String get fieldPlaylistDescription => 'Описание (необязательно)';

  @override
  String get fieldPlaylistType => 'Тип плейлиста';

  @override
  String get smartFilterCriteria => 'Условия умного фильтра';

  @override
  String get smartFilterCategory => 'Категория';

  @override
  String get smartFilterTag => 'Тег / ключевое слово';

  @override
  String get smartFilterFavoritesOnly => 'Только избранное';

  @override
  String get smartFilterMinMinutes => 'Минимальное время использования (мин)';

  @override
  String get smartFilterSearch => 'Поисковый запрос';

  @override
  String get emptyPlaylists =>
      'Плейлисты ещё не созданы.\nСоздайте ручные коллекции или динамические умные плейлисты.';

  @override
  String get emptyPlaylistItems => 'В этом плейлисте пока нет медиа.';

  @override
  String get deletePlaylistTitle => 'Удалить плейлист?';

  @override
  String get deletePlaylistContent =>
      'Действительно удалить этот плейлист? Медиа останутся в библиотеке.';

  @override
  String get addToPlaylist => 'Добавить в плейлист';

  @override
  String get removeFromPlaylist => 'Удалить из плейлиста';

  @override
  String get addedToPlaylist => 'Добавлено в плейлист.';

  @override
  String get removedFromPlaylist => 'Удалено из плейлиста.';

  @override
  String get filterByTag => 'Фильтр по тегам';

  @override
  String get allTags => 'Все теги';

  @override
  String get addTag => 'Добавить тег';

  @override
  String get removeTag => 'Удалить тег';

  @override
  String get noPlaylistsFound => 'Нет доступных плейлистов.';

  @override
  String playlistItemCount(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count элемента',
      many: '$count элементов',
      few: '$count элемента',
      one: '$count элемент',
    );
    return '$_temp0';
  }

  @override
  String tagCount(String tag, int count) {
    return '#$tag ($count)';
  }
}
