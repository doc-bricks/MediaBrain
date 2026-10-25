// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Portuguese (`pt`).
class AppLocalizationsPt extends AppLocalizations {
  AppLocalizationsPt([String locale = 'pt']) : super(locale);

  @override
  String get appTitle => 'MediaBrain';

  @override
  String get navLibrary => 'Biblioteca';

  @override
  String get navScan => 'Analisar';

  @override
  String get navMore => 'Mais';

  @override
  String get screenLibrary => 'Biblioteca';

  @override
  String get fabAdd => 'Adicionar';

  @override
  String get searchHint => 'Pesquisar (título, artista, canal …)';

  @override
  String get filterAll => 'Todos';

  @override
  String get filterFavorites => '⭐ Favoritos';

  @override
  String get emptyNoMatch => 'Não há resultados para os filtros selecionados.';

  @override
  String get emptyNoItems =>
      'Ainda está vazio.\nToque no separador Analisar para detetar automaticamente as aplicações multimédia.';

  @override
  String get screenScan => 'Analisar';

  @override
  String get scanDescription =>
      'Procura aplicações multimédia instaladas (streaming, música, podcasts, documentos) e adiciona-as à biblioteca. Com o acesso aos dados de utilização ativado, também obtém o tempo real de utilização.';

  @override
  String get btnAppScan => 'Análise de aplicações (utilização agregada)';

  @override
  String get bgScanTitle => 'Análise em segundo plano';

  @override
  String get bgScanNow => 'Executar uma vez em segundo plano agora';

  @override
  String get bgScanNowSubtitle =>
      'Envia uma tarefa única para o Android. O resultado aparece após 1–2 minutos.';

  @override
  String get bgScanQueued =>
      'Análise em segundo plano na fila — resultado visível em cerca de 1 min';

  @override
  String get scanAndroidOnly => 'A análise só está disponível no Android.';

  @override
  String get scanPermissionMissing =>
      'Falta o acesso aos dados de utilização. Ative-o nas definições do sistema para o MediaBrain:\n\nDefinições → Aplicações → Acesso especial a aplicações → Acesso aos dados de utilização → MediaBrain.';

  @override
  String get detectedTitle => '📡 O que é detetado?';

  @override
  String get detectedApps =>
      'Netflix · Disney+ · Prime Video · Apple TV · YouTube · Twitch · Spotify · Apple Music · YouTube Music · Tidal · Amazon Music · Audible · Kindle · Pocket Casts · Google Podcasts · Adobe Acrobat · Google Docs · Notion · Obsidian e mais.';

  @override
  String get appScanTitle => '🔍 Análise de aplicações';

  @override
  String get appScanDescription =>
      'Análise de aplicações: uma entrada por aplicação multimédia com a utilização total dos últimos dias (através das estatísticas de utilização do Android).';

  @override
  String get neverText => 'nunca';

  @override
  String get screenSettings => 'Definições';

  @override
  String get sectionDataStatus => 'Estado dos dados';

  @override
  String get sectionFileSync => 'Sincronização de ficheiros';

  @override
  String get sectionServerSync => 'Sincronização do servidor (Mac Studio)';

  @override
  String get sectionActions => 'Ações';

  @override
  String get settingsTotalEntries => 'Total de entradas';

  @override
  String get settingsLastScan => 'Última análise';

  @override
  String get exportTitle => 'Exportar através de Partilhar';

  @override
  String get exportSubtitle =>
      'JSON por e-mail, OneDrive ou Telegram para si …';

  @override
  String get importTitle => 'Escolher ficheiro de importação';

  @override
  String get importSubtitle => 'Substitui os dados locais';

  @override
  String get noServerConfigured => 'Nenhum servidor configurado';

  @override
  String get actionPush => 'Enviar';

  @override
  String get actionPull => 'Obter';

  @override
  String get refreshData => 'Atualizar dados';

  @override
  String get deleteAllData => 'Eliminar todos os dados da biblioteca';

  @override
  String get deleteAllTitle => 'Eliminar todos os dados da biblioteca?';

  @override
  String get deleteAllContent =>
      'Remove todas as entradas do MediaBrain local.';

  @override
  String get cancel => 'Cancelar';

  @override
  String get delete => 'Eliminar';

  @override
  String get save => 'Guardar';

  @override
  String get libraryCleared => 'Biblioteca limpa.';

  @override
  String get cancelled => 'Cancelado.';

  @override
  String get serverConfigTitle => 'Configurar sincronização do servidor';

  @override
  String get fieldServerUrl => 'URL do servidor';

  @override
  String get fieldServerUrlHint => 'por exemplo, macstudvonlukas:8082';

  @override
  String get fieldBearerToken => 'Token Bearer';

  @override
  String get aboutTitle => 'MediaBrain Mobile';

  @override
  String get aboutSubtitle =>
      'Aplicação Flutter autónoma. Deteta aplicações multimédia instaladas, regista entradas manuais e sincroniza através de ficheiro ou servidor.';

  @override
  String get detailDescription => 'Descrição';

  @override
  String get detailDetails => 'Detalhes';

  @override
  String get detailTags => 'Etiquetas';

  @override
  String get fieldArtist => 'Artista';

  @override
  String get fieldAlbum => 'Álbum';

  @override
  String get fieldChannel => 'Canal';

  @override
  String get fieldSeasonEpisodeLabel => 'Temporada/episódio';

  @override
  String get fieldLength => 'Duração';

  @override
  String get fieldLastOpened => 'Última abertura';

  @override
  String get fieldUsage => 'Utilização';

  @override
  String get fieldProviderId => 'ID do fornecedor';

  @override
  String get fieldLocalPath => 'Caminho local';

  @override
  String get openPlayStore => 'Abrir na Play Store';

  @override
  String get openBrowser => 'Abrir no navegador';

  @override
  String get linkError => 'Não foi possível abrir a ligação.';

  @override
  String get dialogTitleNew => 'Nova entrada';

  @override
  String get dialogTitleEdit => 'Editar entrada';

  @override
  String get fieldTitle => 'Título';

  @override
  String get categoryLabel => 'Categoria';

  @override
  String get fieldArtistOptional => 'Artista / realizador (opcional)';

  @override
  String get fieldAlbumOptional => 'Álbum / série (opcional)';

  @override
  String get fieldChannelOptional => 'Canal / origem (opcional)';

  @override
  String get fieldDescriptionOptional => 'Descrição (opcional)';

  @override
  String get fieldTags => 'Etiquetas (separadas por vírgulas)';

  @override
  String get fieldTagsHint => 'por exemplo, documentário, fim de semana';

  @override
  String get markAsFavorite => 'Marcar como favorito';

  @override
  String error(String msg) {
    return 'Erro: $msg';
  }

  @override
  String foregroundMinutesLabel(int minutes) {
    return 'Total: $minutes min';
  }

  @override
  String bgScanSubtitle(int hours) {
    return 'Analisar a cada ~$hours h, mesmo quando a aplicação está fechada.';
  }

  @override
  String lastRun(String time) {
    return 'Última execução: $time';
  }

  @override
  String scanResult(int matched, int persisted) {
    return 'Análise de aplicações: $matched aplicações multimédia encontradas, $persisted entradas adicionadas.';
  }

  @override
  String exportResult(String msg) {
    return 'Exportação: $msg';
  }

  @override
  String importResult(String msg) {
    return 'Importação: $msg';
  }

  @override
  String pushPullStatus(String push, String pull) {
    return 'Envio: $push · Obtenção: $pull';
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
  String get navPlaylists => 'Listas de reprodução';

  @override
  String get screenPlaylists => 'Listas de reprodução e coleções';

  @override
  String get playlistTypeManual => 'Manual';

  @override
  String get playlistTypeSmart => 'Inteligente (filtro dinâmico)';

  @override
  String get dialogNewPlaylist => 'Nova lista de reprodução';

  @override
  String get dialogEditPlaylist => 'Editar lista de reprodução';

  @override
  String get fieldPlaylistName => 'Nome da lista de reprodução';

  @override
  String get fieldPlaylistDescription => 'Descrição (opcional)';

  @override
  String get fieldPlaylistType => 'Tipo de lista de reprodução';

  @override
  String get smartFilterCriteria => 'Critérios do filtro inteligente';

  @override
  String get smartFilterCategory => 'Categoria';

  @override
  String get smartFilterTag => 'Etiqueta / palavra-chave';

  @override
  String get smartFilterFavoritesOnly => 'Apenas favoritos';

  @override
  String get smartFilterMinMinutes => 'Tempo mínimo de utilização (min)';

  @override
  String get smartFilterSearch => 'Termo de pesquisa';

  @override
  String get emptyPlaylists =>
      'Ainda não foram criadas listas de reprodução.\nCrie coleções manuais ou listas inteligentes dinâmicas.';

  @override
  String get emptyPlaylistItems =>
      'Esta lista de reprodução ainda não contém conteúdos multimédia.';

  @override
  String get deletePlaylistTitle => 'Eliminar lista de reprodução?';

  @override
  String get deletePlaylistContent =>
      'Tem a certeza de que pretende eliminar esta lista de reprodução? Os conteúdos nela incluídos permanecerão na biblioteca.';

  @override
  String get addToPlaylist => 'Adicionar à lista de reprodução';

  @override
  String get removeFromPlaylist => 'Remover da lista de reprodução';

  @override
  String get addedToPlaylist => 'Adicionado à lista de reprodução.';

  @override
  String get removedFromPlaylist => 'Removido da lista de reprodução.';

  @override
  String get filterByTag => 'Filtrar por etiqueta';

  @override
  String get allTags => 'Todas as etiquetas';

  @override
  String get addTag => 'Adicionar etiqueta';

  @override
  String get removeTag => 'Remover etiqueta';

  @override
  String get noPlaylistsFound =>
      'Não existem listas de reprodução disponíveis.';

  @override
  String playlistItemCount(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count itens',
      one: '$count item',
    );
    return '$_temp0';
  }

  @override
  String tagCount(String tag, int count) {
    return '#$tag ($count)';
  }
}
