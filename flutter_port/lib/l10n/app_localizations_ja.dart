// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Japanese (`ja`).
class AppLocalizationsJa extends AppLocalizations {
  AppLocalizationsJa([String locale = 'ja']) : super(locale);

  @override
  String get appTitle => 'MediaBrain';

  @override
  String get navLibrary => 'ライブラリ';

  @override
  String get navScan => 'スキャン';

  @override
  String get navMore => 'その他';

  @override
  String get screenLibrary => 'ライブラリ';

  @override
  String get fabAdd => '追加';

  @override
  String get searchHint => '検索（タイトル、アーティスト、チャンネル…）';

  @override
  String get filterAll => 'すべて';

  @override
  String get filterFavorites => '⭐ お気に入り';

  @override
  String get emptyNoMatch => '指定したフィルターに一致する結果はありません。';

  @override
  String get emptyNoItems => 'まだ空です。\n「スキャン」タブをタップすると、メディアアプリを自動検出します。';

  @override
  String get screenScan => 'スキャン';

  @override
  String get scanDescription =>
      'インストール済みのメディアアプリ（ストリーミング、音楽、ポッドキャスト、ドキュメント）を検索し、ライブラリに項目として追加します。使用状況データへのアクセスを有効にすると、実際の使用時間も取得できます。';

  @override
  String get btnAppScan => 'アプリスキャン（集計使用量）';

  @override
  String get bgScanTitle => 'バックグラウンドスキャン';

  @override
  String get bgScanNow => '今すぐバックグラウンドで1回実行';

  @override
  String get bgScanNowSubtitle => 'Android に単発タスクを送信します。結果は1～2分後に表示されます。';

  @override
  String get bgScanQueued => 'バックグラウンドスキャンをキューに追加しました — 約1分後に結果を確認できます';

  @override
  String get scanAndroidOnly => 'スキャンは Android でのみ利用できます。';

  @override
  String get scanPermissionMissing =>
      '使用状況データへのアクセスがありません。MediaBrain のシステム設定で有効にしてください：\n\n設定 → アプリ → 特別なアプリアクセス → 使用状況へのアクセス → MediaBrain。';

  @override
  String get detectedTitle => '📡 検出されるもの';

  @override
  String get detectedApps =>
      'Netflix · Disney+ · Prime Video · Apple TV · YouTube · Twitch · Spotify · Apple Music · YouTube Music · Tidal · Amazon Music · Audible · Kindle · Pocket Casts · Google Podcasts · Adobe Acrobat · Google Docs · Notion · Obsidian など。';

  @override
  String get appScanTitle => '🔍 アプリスキャン';

  @override
  String get appScanDescription =>
      'アプリスキャン：メディアアプリごとに1件作成し、直近数日間の合計使用量を表示します（Android の使用状況統計を利用）。';

  @override
  String get neverText => '一度もない';

  @override
  String get screenSettings => '設定';

  @override
  String get sectionDataStatus => 'データの状態';

  @override
  String get sectionFileSync => 'ファイル同期';

  @override
  String get sectionServerSync => 'サーバー同期（Mac Studio）';

  @override
  String get sectionActions => '操作';

  @override
  String get settingsTotalEntries => '登録数';

  @override
  String get settingsLastScan => '最終スキャン';

  @override
  String get exportTitle => '共有からエクスポート';

  @override
  String get exportSubtitle => 'メール、OneDrive、Telegram で自分宛てに JSON を送信 …';

  @override
  String get importTitle => 'インポートするファイルを選択';

  @override
  String get importSubtitle => 'ローカルデータを上書きします';

  @override
  String get noServerConfigured => 'サーバーが設定されていません';

  @override
  String get actionPush => '送信';

  @override
  String get actionPull => '取得';

  @override
  String get refreshData => 'データを更新';

  @override
  String get deleteAllData => 'ライブラリのデータをすべて削除';

  @override
  String get deleteAllTitle => 'ライブラリのデータをすべて削除しますか？';

  @override
  String get deleteAllContent => 'ローカル MediaBrain のすべての項目を削除します。';

  @override
  String get cancel => 'キャンセル';

  @override
  String get delete => '削除';

  @override
  String get save => '保存';

  @override
  String get libraryCleared => 'ライブラリを消去しました。';

  @override
  String get cancelled => 'キャンセルしました。';

  @override
  String get serverConfigTitle => 'サーバー同期を設定';

  @override
  String get fieldServerUrl => 'サーバー URL';

  @override
  String get fieldServerUrlHint => '例: macstudvonlukas:8082';

  @override
  String get fieldBearerToken => 'Bearer トークン';

  @override
  String get aboutTitle => 'MediaBrain Mobile';

  @override
  String get aboutSubtitle =>
      '単体で動作する Flutter アプリです。インストール済みのメディアアプリを検出し、手動項目を記録して、ファイルまたはサーバー経由で同期します。';

  @override
  String get detailDescription => '説明';

  @override
  String get detailDetails => '詳細';

  @override
  String get detailTags => 'タグ';

  @override
  String get fieldArtist => 'アーティスト';

  @override
  String get fieldAlbum => 'アルバム';

  @override
  String get fieldChannel => 'チャンネル';

  @override
  String get fieldSeasonEpisodeLabel => 'シーズン/エピソード';

  @override
  String get fieldLength => '長さ';

  @override
  String get fieldLastOpened => '最終オープン';

  @override
  String get fieldUsage => '使用状況';

  @override
  String get fieldProviderId => 'プロバイダー ID';

  @override
  String get fieldLocalPath => 'ローカルパス';

  @override
  String get openPlayStore => 'Play ストアで開く';

  @override
  String get openBrowser => 'ブラウザーで開く';

  @override
  String get linkError => 'リンクを開けませんでした。';

  @override
  String get dialogTitleNew => '新しい項目';

  @override
  String get dialogTitleEdit => '項目を編集';

  @override
  String get fieldTitle => 'タイトル';

  @override
  String get categoryLabel => 'カテゴリ';

  @override
  String get fieldArtistOptional => 'アーティスト / 監督（任意）';

  @override
  String get fieldAlbumOptional => 'アルバム / シリーズ（任意）';

  @override
  String get fieldChannelOptional => 'チャンネル / ソース（任意）';

  @override
  String get fieldDescriptionOptional => '説明（任意）';

  @override
  String get fieldTags => 'タグ（カンマ区切り）';

  @override
  String get fieldTagsHint => '例: ドキュメンタリー、週末';

  @override
  String get markAsFavorite => 'お気に入りにする';

  @override
  String error(String msg) {
    return 'エラー: $msg';
  }

  @override
  String foregroundMinutesLabel(int minutes) {
    return '合計 $minutes 分';
  }

  @override
  String bgScanSubtitle(int hours) {
    return 'アプリが閉じていても、約 $hours 時間ごとにスキャンします。';
  }

  @override
  String lastRun(String time) {
    return '最終実行: $time';
  }

  @override
  String scanResult(int matched, int persisted) {
    return 'アプリスキャン: メディアアプリを $matched 件検出し、$persisted 件の項目を追加しました。';
  }

  @override
  String exportResult(String msg) {
    return 'エクスポート: $msg';
  }

  @override
  String importResult(String msg) {
    return 'インポート: $msg';
  }

  @override
  String pushPullStatus(String push, String pull) {
    return '送信: $push · 取得: $pull';
  }

  @override
  String seasonEpisode(int s, int e) {
    return 'シーズン$s エピソード$e';
  }

  @override
  String usageMinutes(int n) {
    return '$n 分';
  }

  @override
  String get navPlaylists => 'プレイリスト';

  @override
  String get screenPlaylists => 'プレイリストとコレクション';

  @override
  String get playlistTypeManual => '手動';

  @override
  String get playlistTypeSmart => 'スマート（動的フィルター）';

  @override
  String get dialogNewPlaylist => '新しいプレイリスト';

  @override
  String get dialogEditPlaylist => 'プレイリストを編集';

  @override
  String get fieldPlaylistName => 'プレイリスト名';

  @override
  String get fieldPlaylistDescription => '説明（任意）';

  @override
  String get fieldPlaylistType => 'プレイリストの種類';

  @override
  String get smartFilterCriteria => 'スマートフィルターの条件';

  @override
  String get smartFilterCategory => 'カテゴリ';

  @override
  String get smartFilterTag => 'タグ / キーワード';

  @override
  String get smartFilterFavoritesOnly => 'お気に入りのみ';

  @override
  String get smartFilterMinMinutes => '最小使用時間（分）';

  @override
  String get smartFilterSearch => '検索語';

  @override
  String get emptyPlaylists =>
      'プレイリストはまだありません。\n手動コレクションまたは動的なスマートプレイリストを作成してください。';

  @override
  String get emptyPlaylistItems => 'このプレイリストにはまだメディアがありません。';

  @override
  String get deletePlaylistTitle => 'プレイリストを削除しますか？';

  @override
  String get deletePlaylistContent => 'このプレイリストを本当に削除しますか？含まれるメディアはライブラリに残ります。';

  @override
  String get addToPlaylist => 'プレイリストに追加';

  @override
  String get removeFromPlaylist => 'プレイリストから削除';

  @override
  String get addedToPlaylist => 'プレイリストに追加しました。';

  @override
  String get removedFromPlaylist => 'プレイリストから削除しました。';

  @override
  String get filterByTag => 'タグで絞り込む';

  @override
  String get allTags => 'すべてのタグ';

  @override
  String get addTag => 'タグを追加';

  @override
  String get removeTag => 'タグを削除';

  @override
  String get noPlaylistsFound => '利用できるプレイリストはありません。';

  @override
  String playlistItemCount(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count 件',
    );
    return '$_temp0';
  }

  @override
  String tagCount(String tag, int count) {
    return '#$tag ($count)';
  }
}
