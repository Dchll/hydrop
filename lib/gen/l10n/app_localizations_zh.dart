// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Chinese (`zh`).
class AppLocalizationsZh extends AppLocalizations {
  AppLocalizationsZh([String locale = 'zh']) : super(locale);

  @override
  String get appTitle => 'Hydrop';

  @override
  String get navDevices => '设备';

  @override
  String get navTransfers => '传输';

  @override
  String get navMine => '我的';

  @override
  String get navSettings => '设置';

  @override
  String get settingsTitle => '设置';

  @override
  String get settingsSubtitle => '外观、传输行为和应用信息';

  @override
  String get settingsUnableToLoad => '无法加载设置';

  @override
  String get settingsAppearance => '外观';

  @override
  String get settingsAppearanceSubtitle => '主题、语言和视觉密度';

  @override
  String get settingsTransfer => '传输';

  @override
  String get settingsTransferSubtitle => '加密与可续传文件任务';

  @override
  String get settingsDiscovery => '发现';

  @override
  String get settingsDiscoverySubtitle => '附近设备发现行为';

  @override
  String get settingsPrivacy => '隐私';

  @override
  String get settingsPrivacySubtitle => '本地优先的数据处理';

  @override
  String get settingsDangerZone => '危险操作';

  @override
  String get resetDatabaseTitle => '重置 Drift 数据库';

  @override
  String get resetDatabaseSubtitle => '清除本地所有数据库内容并重新初始化，用于修复升级后可能出现的数据库问题';

  @override
  String get resetDatabaseConfirmTitle => '确认重置数据库';

  @override
  String get resetDatabaseConfirmMessage =>
      '这会删除本地所有设备、消息、传输记录和设置，并重新初始化数据库。此操作无法撤销。';

  @override
  String get resetDatabaseAction => '重置数据库';

  @override
  String get resetDatabaseDone => '数据库已重置并重新初始化。';

  @override
  String get settingsAbout => '关于';

  @override
  String get settingsAboutSubtitle => '版本和项目信息';

  @override
  String get themeModeTitle => '主题模式';

  @override
  String get themeModeSubtitle => '选择跟随系统、浅色或深色外观';

  @override
  String get themeSystem => '系统';

  @override
  String get themeLight => '浅色';

  @override
  String get themeDark => '深色';

  @override
  String get languageTitle => '语言';

  @override
  String get languageSubtitle => '选择界面显示语言';

  @override
  String get languageSystem => '系统';

  @override
  String get languageEn => 'English';

  @override
  String get languageZhHans => '简体中文';

  @override
  String get languageZhHant => '繁體中文';

  @override
  String get interfaceTitle => '界面';

  @override
  String get interfaceValue => '方形控件、2px 边框、黑白灰配色';

  @override
  String get transferEncryption => '传输加密';

  @override
  String get transferEncryptionSubtitle => '保存传输控制器使用的偏好设置';

  @override
  String get autoResumeTransfers => '自动续传';

  @override
  String get autoResumeTransfersSubtitle => '尽可能重试并继续中断的文件传输';

  @override
  String get autoReceiveFilesByDefault => '新设备默认自动接收';

  @override
  String get autoReceiveFilesForDevice => '自动接收此设备的文件';

  @override
  String get nearbyDevices => '附近设备';

  @override
  String savedOrDiscoveredDevices(int count) {
    return '$count 台已保存或已发现设备';
  }

  @override
  String get loadingDeviceDiscoveryState => '正在加载设备发现状态';

  @override
  String get localAddresses => '本地地址';

  @override
  String networkAddressesAvailable(int count) {
    return '$count 个可用网络地址';
  }

  @override
  String get loadingLocalNetworkAddresses => '正在加载本地网络地址';

  @override
  String get qrPairing => '二维码配对';

  @override
  String get qrPairingValue => '在我的或设备页展示并扫描连接二维码';

  @override
  String get storage => '存储';

  @override
  String get storageValue => '设备、消息和传输记录均保存在本地';

  @override
  String get localIdentity => '本机身份';

  @override
  String deviceIdValue(String deviceId) {
    return '设备 ID $deviceId';
  }

  @override
  String get loadingLocalIdentity => '正在加载本机身份';

  @override
  String get network => '网络';

  @override
  String get networkValue => '传输会连接已发现的局域网设备';

  @override
  String get appLabel => '应用';

  @override
  String get versionLabel => '版本';

  @override
  String get uiLabel => '界面';

  @override
  String get uiValue => 'Material 黑白灰桌面/移动端界面';

  @override
  String get devicesTitle => '设备';

  @override
  String get homeUnableToLoadDevices => '无法加载设备';

  @override
  String get noNearbyDevices => '没有附近设备';

  @override
  String get noMatchingDevices => '没有匹配设备';

  @override
  String deviceCountSummary(int count, int total) {
    return '$count / $total 台设备';
  }

  @override
  String get refreshDevicesTooltip => '刷新设备';

  @override
  String get scanQr => '扫描二维码';

  @override
  String get searchDevices => '搜索设备';

  @override
  String get notConnected => '未连接';

  @override
  String get selectSettingSectionHint => '请选择左侧设置项';

  @override
  String get noDevices => '没有设备';

  @override
  String get refreshDiscoveryOrScanQr => '刷新发现或扫描二维码。';

  @override
  String get tryDifferentDeviceSearch => '尝试其他名称、ID、状态或速度。';

  @override
  String get refresh => '刷新';

  @override
  String get clearSearch => '清除搜索';

  @override
  String get noMessagesYet => '暂无消息';

  @override
  String get wallpaperOffline => '壁纸离线';

  @override
  String get dailyWallpaperFallback => '每日壁纸备用';

  @override
  String get dailyWallpaperReady => '每日壁纸已就绪';

  @override
  String get mineTitle => '我的';

  @override
  String get mineSubtitle => '本机设备、二维码连接和网络诊断';

  @override
  String get refreshLocalInfo => '刷新本机信息';

  @override
  String get unableToLoadLocalDeviceInfo => '无法加载本机设备信息';

  @override
  String get deviceProfile => '设备资料';

  @override
  String get displayName => '显示名称';

  @override
  String get displayNameSaved => '显示名称已保存。';

  @override
  String get hostName => '主机名';

  @override
  String get transferSettings => '传输设置';

  @override
  String get autoResumeTransferDescription => '重连后从上次接收的位置继续中断的文件传输。';

  @override
  String get localNetwork => '本地网络';

  @override
  String get noLocalNetworkAddresses => '当前没有可用的本地网络地址。';

  @override
  String get diagnostics => '诊断';

  @override
  String get qrPayload => '二维码内容';

  @override
  String characterCount(int count) {
    return '$count 个字符';
  }

  @override
  String get addressCount => '地址数量';

  @override
  String get tcpServer => 'TCP 服务';

  @override
  String get tcpServerManaged => '由应用运行时管理';

  @override
  String get qrConnection => '二维码连接';

  @override
  String get qrConnectionDescription => '展示你的二维码或扫描对方二维码以保存设备地址。';

  @override
  String get myQr => '我的二维码';

  @override
  String copyLabel(String label) {
    return '复制 $label';
  }

  @override
  String copiedLabel(String label) {
    return '已复制 $label';
  }

  @override
  String get copyAddress => '复制地址';

  @override
  String get copiedAddress => '已复制地址';

  @override
  String get myConnectionQr => '我的连接二维码';

  @override
  String get closeQr => '关闭二维码';

  @override
  String qrAddressSummary(String displayName, int count) {
    return '$displayName · $count 个地址';
  }

  @override
  String get qrPayloadDescription => '二维码包含设备 ID、TCP 端口和本地网络地址。';

  @override
  String get qrScanningUnsupported =>
      '二维码扫描支持 Android、iOS、macOS 和 Web，暂不支持 Windows。';

  @override
  String qrSavedDevice(String displayName, int count) {
    return '已保存 $displayName，包含 $count 个地址。';
  }

  @override
  String get scanPeerQr => '扫描对方二维码';

  @override
  String get closeScanner => '关闭扫描';

  @override
  String get scanPeerQrHint => '将摄像头对准另一台 Hydrop 设备的二维码。';

  @override
  String get unableToSaveQr => '无法保存此二维码。';

  @override
  String get chatNoActive => '没有当前聊天';

  @override
  String get chatNoActiveMessage => '从左侧设备列表选择一台设备打开会话。';

  @override
  String deviceIdPrefix(String deviceId) {
    return '设备 ID：$deviceId';
  }

  @override
  String get backToDevices => '返回设备';

  @override
  String get close => '关闭';

  @override
  String get closeSearch => '关闭搜索';

  @override
  String get searchMessages => '搜索消息';

  @override
  String get deviceInfo => '设备信息';

  @override
  String get clearConversation => '清空会话';

  @override
  String get searchConversation => '搜索此会话';

  @override
  String searchResultCounter(int current, int total) {
    return '$current / $total';
  }

  @override
  String get previousResult => '上一个结果';

  @override
  String get nextResult => '下一个结果';

  @override
  String get noMatchingMessages => '没有匹配消息';

  @override
  String get emptyConversationMessage => '发送消息或附加文件以开始这条传输记录。';

  @override
  String get tryDifferentSearchTerm => '尝试其他搜索词。';

  @override
  String get unableToLoadConversation => '无法加载此会话';

  @override
  String messageSavedLocally(String message) {
    return '消息已保存到本地：$message';
  }

  @override
  String unableToSendMessage(String error) {
    return '无法发送消息：$error';
  }

  @override
  String get fileSent => '文件已发送。';

  @override
  String get fileSendingStarted => '文件传输已开始。';

  @override
  String fileSavedLocally(String message) {
    return '文件已保存到本地：$message';
  }

  @override
  String unableToAttachFile(String error) {
    return '无法附加文件：$error';
  }

  @override
  String get attachmentFile => '文件';

  @override
  String get attachmentImage => '图片';

  @override
  String get attachmentVideo => '视频';

  @override
  String get chooseFileToSend => '选择要发送的文件';

  @override
  String get chooseImageToSend => '选择要发送的图片';

  @override
  String get chooseVideoToSend => '选择要发送的视频';

  @override
  String get sendAnyLocalFile => '发送任意本地文件';

  @override
  String get sendImageWithPreview => '发送带预览的图片';

  @override
  String get sendVideoWithPreview => '发送带播放预览的视频';

  @override
  String savedTo(String path) {
    return '已保存到 $path';
  }

  @override
  String unableToSaveAttachment(String error) {
    return '无法保存附件：$error';
  }

  @override
  String get copiedMessage => '已复制消息';

  @override
  String get messageResent => '消息已重发。';

  @override
  String retrySavedLocally(String message) {
    return '重试已保存到本地：$message';
  }

  @override
  String unableToRetryMessage(String error) {
    return '无法重试消息：$error';
  }

  @override
  String get deleteMessage => '删除消息';

  @override
  String get deleteMessageDescription => '这只会删除消息记录，本地文件会保留在当前设备上。';

  @override
  String get delete => '删除';

  @override
  String get messageDeleted => '消息已删除。';

  @override
  String get clearConversationDescription => '这会删除此设备的本地会话记录。';

  @override
  String get deleteDevice => '删除设备';

  @override
  String deleteDeviceDescription(String displayName) {
    return '从设备列表移除 $displayName。';
  }

  @override
  String get deviceDeleted => '设备已删除。';

  @override
  String get clear => '清空';

  @override
  String get conversationCleared => '会话已清空。';

  @override
  String get openLink => '打开链接';

  @override
  String get open => '打开';

  @override
  String get unableToOpenLinkCopied => '无法打开链接，已改为复制。';

  @override
  String get cancel => '取消';

  @override
  String actionFailed(String error) {
    return '操作失败：$error';
  }

  @override
  String get addresses => '地址';

  @override
  String get noSavedAddress => '此设备没有已保存地址。';

  @override
  String get reachable => '可连接';

  @override
  String get unreachable => '不可连接';

  @override
  String get copy => '复制';

  @override
  String get copied => '已复制';

  @override
  String get loadOlderMessages => '加载更早消息';

  @override
  String get copyMessage => '复制消息';

  @override
  String get retryMessage => '重试消息';

  @override
  String get lastMessageYou => '你';

  @override
  String get lastMessagePeer => '对方';

  @override
  String lastMessageSentFile(String actor, String fileName) {
    return '$actor 发送了 $fileName';
  }

  @override
  String get fileAttachment => '文件附件';

  @override
  String get saveAttachmentDialogTitle => '保存附件';

  @override
  String get save => '保存';

  @override
  String get status => '状态';

  @override
  String get progress => '进度';

  @override
  String get mimeType => 'MIME 类型';

  @override
  String get localPath => '本地路径';

  @override
  String get attachmentId => '附件 ID';

  @override
  String get taskId => '任务 ID';

  @override
  String get sha256Label => 'SHA-256';

  @override
  String get noLocalVideoFile => '没有可用的本地视频文件。';

  @override
  String unableToPreviewVideo(String error) {
    return '无法预览视频：$error';
  }

  @override
  String get pause => '暂停';

  @override
  String get transferPaused => '传输已暂停。';

  @override
  String get resumeTransfer => '继续传输';

  @override
  String get transferResumed => '传输已继续。';

  @override
  String get cancelTransfer => '取消传输';

  @override
  String cancelTransferDescription(String fileName) {
    return '停止传输 $fileName，并将其标记为已取消。';
  }

  @override
  String get transferCancelled => '传输已取消。';

  @override
  String get play => '播放';

  @override
  String get attachFile => '附加文件';

  @override
  String get insertEmoji => '插入表情';

  @override
  String get messageOrAttachFile => '消息或附加文件';

  @override
  String get jumpToLatest => '最新消息';

  @override
  String get transfersTitle => '传输';

  @override
  String get transfersSubtitle => '文件队列和传输历史';

  @override
  String get refreshTransfers => '刷新传输';

  @override
  String get unableToLoadTransfers => '无法加载传输';

  @override
  String get filterAll => '全部';

  @override
  String get filterActive => '进行中';

  @override
  String get filterDone => '完成';

  @override
  String get filterFailed => '失败';

  @override
  String get noTransfers => '暂无传输';

  @override
  String get noMatchingTransfers => '没有匹配传输';

  @override
  String get noTransfersMessage => '发送或接收文件后会显示在此队列。';

  @override
  String get noMatchingTransfersMessage => '尝试其他搜索词或状态筛选。';

  @override
  String get searchTransfers => '搜索传输';

  @override
  String get selectTransfer => '选择传输';

  @override
  String get selectTransferMessage => '打开任务以查看文件、状态和路径。';

  @override
  String get direction => '方向';

  @override
  String get device => '设备';

  @override
  String get message => '消息';

  @override
  String get saveStatus => '保存状态';

  @override
  String get updated => '更新时间';

  @override
  String unableToSave(String error) {
    return '无法保存：$error';
  }

  @override
  String get directionOutgoing => '发出';

  @override
  String get directionIncoming => '收到';

  @override
  String get statusPending => '等待中';

  @override
  String get statusWaitingForReceiver => '等待对方接收';

  @override
  String get statusTransferring => '传输中';

  @override
  String get statusDone => '完成';

  @override
  String get statusFailed => '失败';

  @override
  String get statusSending => '发送中';

  @override
  String get statusSent => '已发送';

  @override
  String get statusReceived => '已接收';

  @override
  String get statusSaving => '保存中';

  @override
  String get statusSaved => '已保存';

  @override
  String get byteUnitB => 'B';

  @override
  String get byteUnitKb => 'KB';

  @override
  String get byteUnitMb => 'MB';

  @override
  String get byteUnitGb => 'GB';

  @override
  String get byteUnitTb => 'TB';

  @override
  String byteProgress(String transferred, String total) {
    return '$transferred / $total';
  }

  @override
  String attachmentStatusProgress(String status, String progress) {
    return '$status · $progress';
  }

  @override
  String transferRowMeta(String direction, String deviceId) {
    return '$direction · $deviceId';
  }

  @override
  String transferProgressUpdated(String progress, String updated) {
    return '$progress · $updated';
  }

  @override
  String transferProgressSpeed(String progress, String speed) {
    return '$progress · $speed';
  }

  @override
  String get speed => '速度';

  @override
  String get averageSpeed => '平均速度';

  @override
  String get elapsedTime => '耗时';

  @override
  String get remainingTime => '剩余时间';

  @override
  String durationSeconds(int seconds) {
    return '$seconds秒';
  }

  @override
  String durationMinutesSeconds(int minutes, int seconds) {
    return '$minutes分 $seconds秒';
  }

  @override
  String durationHoursMinutes(int hours, int minutes) {
    return '$hours时 $minutes分';
  }

  @override
  String transferSpeedAndRemaining(String speed, String remaining) {
    return '$speed · 剩余 $remaining';
  }

  @override
  String transferCompletedSummary(String size, String speed, String duration) {
    return '$size · 平均 $speed · $duration';
  }

  @override
  String get lastError => '最后错误';

  @override
  String get todayLabel => '今天';

  @override
  String get yesterdayLabel => '昨天';

  @override
  String get transferNotificationSendingTitle => '正在发送文件';

  @override
  String get transferNotificationReceivingTitle => '正在接收文件';

  @override
  String get transferNotificationSentTitle => '文件已发送';

  @override
  String get transferNotificationReceivedTitle => '文件已接收';

  @override
  String get transferNotificationFailedTitle => '传输失败';

  @override
  String transferNotificationProgress(String fileName, String progress) {
    return '$fileName · $progress';
  }

  @override
  String transferNotificationFailed(String fileName) {
    return '$fileName 无法完成传输。';
  }
}

/// The translations for Chinese, using the Han script (`zh_Hant`).
class AppLocalizationsZhHant extends AppLocalizationsZh {
  AppLocalizationsZhHant() : super('zh_Hant');

  @override
  String get appTitle => 'Hydrop';

  @override
  String get navDevices => '裝置';

  @override
  String get navTransfers => '傳輸';

  @override
  String get navMine => '我的';

  @override
  String get navSettings => '設定';

  @override
  String get settingsTitle => '設定';

  @override
  String get settingsSubtitle => '外觀、傳輸行為和應用資訊';

  @override
  String get settingsUnableToLoad => '無法載入設定';

  @override
  String get settingsAppearance => '外觀';

  @override
  String get settingsAppearanceSubtitle => '主題、語言和視覺密度';

  @override
  String get settingsTransfer => '傳輸';

  @override
  String get settingsTransferSubtitle => '加密與可續傳檔案任務';

  @override
  String get settingsDiscovery => '探索';

  @override
  String get settingsDiscoverySubtitle => '附近裝置探索行為';

  @override
  String get settingsPrivacy => '隱私';

  @override
  String get settingsPrivacySubtitle => '本地優先的資料處理';

  @override
  String get settingsDangerZone => '危險操作';

  @override
  String get resetDatabaseTitle => '重置 Drift 資料庫';

  @override
  String get resetDatabaseSubtitle => '清除本地所有資料庫內容並重新初始化，用於修復升級後可能出現的資料庫問題';

  @override
  String get resetDatabaseConfirmTitle => '確認重置資料庫';

  @override
  String get resetDatabaseConfirmMessage =>
      '這會刪除本地所有裝置、訊息、傳輸記錄和設定，並重新初始化資料庫。此操作無法撤銷。';

  @override
  String get resetDatabaseAction => '重置資料庫';

  @override
  String get resetDatabaseDone => '資料庫已重置並重新初始化。';

  @override
  String get settingsAbout => '關於';

  @override
  String get settingsAboutSubtitle => '版本和專案資訊';

  @override
  String get themeModeTitle => '主題模式';

  @override
  String get themeModeSubtitle => '選擇跟隨系統、淺色或深色外觀';

  @override
  String get themeSystem => '系統';

  @override
  String get themeLight => '淺色';

  @override
  String get themeDark => '深色';

  @override
  String get languageTitle => '語言';

  @override
  String get languageSubtitle => '選擇介面顯示語言';

  @override
  String get languageSystem => '系統';

  @override
  String get languageEn => 'English';

  @override
  String get languageZhHans => '简体中文';

  @override
  String get languageZhHant => '繁體中文';

  @override
  String get interfaceTitle => '介面';

  @override
  String get interfaceValue => '方形控制項、2px 邊框、黑白灰配色';

  @override
  String get transferEncryption => '傳輸加密';

  @override
  String get transferEncryptionSubtitle => '保存傳輸控制器使用的偏好設定';

  @override
  String get autoResumeTransfers => '自動續傳';

  @override
  String get autoResumeTransfersSubtitle => '盡可能重試並繼續中斷的檔案傳輸';

  @override
  String get autoReceiveFilesByDefault => '新裝置預設自動接收';

  @override
  String get autoReceiveFilesForDevice => '自動接收此裝置的檔案';

  @override
  String get nearbyDevices => '附近裝置';

  @override
  String savedOrDiscoveredDevices(int count) {
    return '$count 台已保存或已探索裝置';
  }

  @override
  String get loadingDeviceDiscoveryState => '正在載入裝置探索狀態';

  @override
  String get localAddresses => '本地位址';

  @override
  String networkAddressesAvailable(int count) {
    return '$count 個可用網路位址';
  }

  @override
  String get loadingLocalNetworkAddresses => '正在載入本地網路位址';

  @override
  String get qrPairing => 'QR 碼配對';

  @override
  String get qrPairingValue => '在我的或裝置頁展示並掃描連線 QR 碼';

  @override
  String get storage => '儲存';

  @override
  String get storageValue => '裝置、訊息和傳輸記錄均保存在本地';

  @override
  String get localIdentity => '本機身分';

  @override
  String deviceIdValue(String deviceId) {
    return '裝置 ID $deviceId';
  }

  @override
  String get loadingLocalIdentity => '正在載入本機身分';

  @override
  String get network => '網路';

  @override
  String get networkValue => '傳輸會連接已探索的區域網路裝置';

  @override
  String get appLabel => '應用';

  @override
  String get versionLabel => '版本';

  @override
  String get uiLabel => '介面';

  @override
  String get uiValue => 'Material 黑白灰桌面/行動端介面';

  @override
  String get devicesTitle => '裝置';

  @override
  String get homeUnableToLoadDevices => '無法載入裝置';

  @override
  String get noNearbyDevices => '沒有附近裝置';

  @override
  String get noMatchingDevices => '沒有符合的裝置';

  @override
  String deviceCountSummary(int count, int total) {
    return '$count / $total 台裝置';
  }

  @override
  String get refreshDevicesTooltip => '重新整理裝置';

  @override
  String get scanQr => '掃描 QR 碼';

  @override
  String get searchDevices => '搜尋裝置';

  @override
  String get notConnected => '未連接';

  @override
  String get selectSettingSectionHint => '請選擇左側設定項';

  @override
  String get noDevices => '沒有裝置';

  @override
  String get refreshDiscoveryOrScanQr => '重新整理探索或掃描 QR 碼。';

  @override
  String get tryDifferentDeviceSearch => '嘗試其他名稱、ID、狀態或速度。';

  @override
  String get refresh => '重新整理';

  @override
  String get clearSearch => '清除搜尋';

  @override
  String get noMessagesYet => '暫無訊息';

  @override
  String get wallpaperOffline => '桌布離線';

  @override
  String get dailyWallpaperFallback => '每日桌布備用';

  @override
  String get dailyWallpaperReady => '每日桌布已就緒';

  @override
  String get mineTitle => '我的';

  @override
  String get mineSubtitle => '本機裝置、QR 碼連線和網路診斷';

  @override
  String get refreshLocalInfo => '重新整理本機資訊';

  @override
  String get unableToLoadLocalDeviceInfo => '無法載入本機裝置資訊';

  @override
  String get deviceProfile => '裝置資料';

  @override
  String get displayName => '顯示名稱';

  @override
  String get displayNameSaved => '顯示名稱已保存。';

  @override
  String get hostName => '主機名稱';

  @override
  String get transferSettings => '傳輸設定';

  @override
  String get autoResumeTransferDescription => '重新連線後從上次接收的位置繼續中斷的檔案傳輸。';

  @override
  String get localNetwork => '本地網路';

  @override
  String get noLocalNetworkAddresses => '目前沒有可用的本地網路位址。';

  @override
  String get diagnostics => '診斷';

  @override
  String get qrPayload => 'QR 碼內容';

  @override
  String characterCount(int count) {
    return '$count 個字元';
  }

  @override
  String get addressCount => '位址數量';

  @override
  String get tcpServer => 'TCP 服務';

  @override
  String get tcpServerManaged => '由應用執行階段管理';

  @override
  String get qrConnection => 'QR 碼連線';

  @override
  String get qrConnectionDescription => '展示你的 QR 碼或掃描對方 QR 碼以保存裝置位址。';

  @override
  String get myQr => '我的 QR 碼';

  @override
  String copyLabel(String label) {
    return '複製 $label';
  }

  @override
  String copiedLabel(String label) {
    return '已複製 $label';
  }

  @override
  String get copyAddress => '複製位址';

  @override
  String get copiedAddress => '已複製位址';

  @override
  String get myConnectionQr => '我的連線 QR 碼';

  @override
  String get closeQr => '關閉 QR 碼';

  @override
  String qrAddressSummary(String displayName, int count) {
    return '$displayName · $count 個位址';
  }

  @override
  String get qrPayloadDescription => 'QR 碼包含裝置 ID、TCP 連接埠和本地網路位址。';

  @override
  String get qrScanningUnsupported =>
      'QR 碼掃描支援 Android、iOS、macOS 和 Web，暫不支援 Windows。';

  @override
  String qrSavedDevice(String displayName, int count) {
    return '已保存 $displayName，包含 $count 個位址。';
  }

  @override
  String get scanPeerQr => '掃描對方 QR 碼';

  @override
  String get closeScanner => '關閉掃描';

  @override
  String get scanPeerQrHint => '將相機對準另一台 Hydrop 裝置的 QR 碼。';

  @override
  String get unableToSaveQr => '無法保存此 QR 碼。';

  @override
  String get chatNoActive => '沒有目前聊天';

  @override
  String get chatNoActiveMessage => '從左側裝置列表選擇一台裝置開啟對話。';

  @override
  String deviceIdPrefix(String deviceId) {
    return '裝置 ID：$deviceId';
  }

  @override
  String get backToDevices => '返回裝置';

  @override
  String get close => '關閉';

  @override
  String get closeSearch => '關閉搜尋';

  @override
  String get searchMessages => '搜尋訊息';

  @override
  String get deviceInfo => '裝置資訊';

  @override
  String get clearConversation => '清空對話';

  @override
  String get searchConversation => '搜尋此對話';

  @override
  String searchResultCounter(int current, int total) {
    return '$current / $total';
  }

  @override
  String get previousResult => '上一個結果';

  @override
  String get nextResult => '下一個結果';

  @override
  String get noMatchingMessages => '沒有符合的訊息';

  @override
  String get emptyConversationMessage => '傳送訊息或附加檔案以開始這條傳輸記錄。';

  @override
  String get tryDifferentSearchTerm => '嘗試其他搜尋詞。';

  @override
  String get unableToLoadConversation => '無法載入此對話';

  @override
  String messageSavedLocally(String message) {
    return '訊息已保存到本地：$message';
  }

  @override
  String unableToSendMessage(String error) {
    return '無法傳送訊息：$error';
  }

  @override
  String get fileSent => '檔案已傳送。';

  @override
  String get fileSendingStarted => '檔案傳輸已開始。';

  @override
  String fileSavedLocally(String message) {
    return '檔案已保存到本地：$message';
  }

  @override
  String unableToAttachFile(String error) {
    return '無法附加檔案：$error';
  }

  @override
  String get attachmentFile => '檔案';

  @override
  String get attachmentImage => '圖片';

  @override
  String get attachmentVideo => '影片';

  @override
  String get chooseFileToSend => '選擇要傳送的檔案';

  @override
  String get chooseImageToSend => '選擇要傳送的圖片';

  @override
  String get chooseVideoToSend => '選擇要傳送的影片';

  @override
  String get sendAnyLocalFile => '傳送任意本地檔案';

  @override
  String get sendImageWithPreview => '傳送帶預覽的圖片';

  @override
  String get sendVideoWithPreview => '傳送帶播放預覽的影片';

  @override
  String savedTo(String path) {
    return '已保存到 $path';
  }

  @override
  String unableToSaveAttachment(String error) {
    return '無法保存附件：$error';
  }

  @override
  String get copiedMessage => '已複製訊息';

  @override
  String get messageResent => '訊息已重傳。';

  @override
  String retrySavedLocally(String message) {
    return '重試已保存到本地：$message';
  }

  @override
  String unableToRetryMessage(String error) {
    return '無法重試訊息：$error';
  }

  @override
  String get deleteMessage => '刪除訊息';

  @override
  String get deleteMessageDescription => '這只會刪除訊息記錄，本地檔案會保留在目前裝置上。';

  @override
  String get delete => '刪除';

  @override
  String get messageDeleted => '訊息已刪除。';

  @override
  String get clearConversationDescription => '這會刪除此裝置的本地對話記錄。';

  @override
  String get deleteDevice => '刪除裝置';

  @override
  String deleteDeviceDescription(String displayName) {
    return '從裝置列表移除 $displayName。';
  }

  @override
  String get deviceDeleted => '裝置已刪除。';

  @override
  String get clear => '清空';

  @override
  String get conversationCleared => '對話已清空。';

  @override
  String get openLink => '開啟連結';

  @override
  String get open => '開啟';

  @override
  String get unableToOpenLinkCopied => '無法開啟連結，已改為複製。';

  @override
  String get cancel => '取消';

  @override
  String actionFailed(String error) {
    return '操作失敗：$error';
  }

  @override
  String get addresses => '位址';

  @override
  String get noSavedAddress => '此裝置沒有已保存位址。';

  @override
  String get reachable => '可連線';

  @override
  String get unreachable => '不可連線';

  @override
  String get copy => '複製';

  @override
  String get copied => '已複製';

  @override
  String get loadOlderMessages => '載入更早訊息';

  @override
  String get copyMessage => '複製訊息';

  @override
  String get retryMessage => '重試訊息';

  @override
  String get lastMessageYou => '你';

  @override
  String get lastMessagePeer => '對方';

  @override
  String lastMessageSentFile(String actor, String fileName) {
    return '$actor 傳送了 $fileName';
  }

  @override
  String get fileAttachment => '檔案附件';

  @override
  String get saveAttachmentDialogTitle => '保存附件';

  @override
  String get save => '保存';

  @override
  String get status => '狀態';

  @override
  String get progress => '進度';

  @override
  String get mimeType => 'MIME 類型';

  @override
  String get localPath => '本地路徑';

  @override
  String get attachmentId => '附件 ID';

  @override
  String get taskId => '任務 ID';

  @override
  String get sha256Label => 'SHA-256';

  @override
  String get noLocalVideoFile => '沒有可用的本地影片檔案。';

  @override
  String unableToPreviewVideo(String error) {
    return '無法預覽影片：$error';
  }

  @override
  String get pause => '暫停';

  @override
  String get transferPaused => '傳輸已暫停。';

  @override
  String get resumeTransfer => '繼續傳輸';

  @override
  String get transferResumed => '傳輸已繼續。';

  @override
  String get cancelTransfer => '取消傳輸';

  @override
  String cancelTransferDescription(String fileName) {
    return '停止傳輸 $fileName，並將其標記為已取消。';
  }

  @override
  String get transferCancelled => '傳輸已取消。';

  @override
  String get play => '播放';

  @override
  String get attachFile => '附加檔案';

  @override
  String get insertEmoji => '插入表情';

  @override
  String get messageOrAttachFile => '訊息或附加檔案';

  @override
  String get jumpToLatest => '最新訊息';

  @override
  String get transfersTitle => '傳輸';

  @override
  String get transfersSubtitle => '檔案佇列和傳輸歷史';

  @override
  String get refreshTransfers => '重新整理傳輸';

  @override
  String get unableToLoadTransfers => '無法載入傳輸';

  @override
  String get filterAll => '全部';

  @override
  String get filterActive => '進行中';

  @override
  String get filterDone => '完成';

  @override
  String get filterFailed => '失敗';

  @override
  String get noTransfers => '暫無傳輸';

  @override
  String get noMatchingTransfers => '沒有符合的傳輸';

  @override
  String get noTransfersMessage => '傳送或接收檔案後會顯示在此佇列。';

  @override
  String get noMatchingTransfersMessage => '嘗試其他搜尋詞或狀態篩選。';

  @override
  String get searchTransfers => '搜尋傳輸';

  @override
  String get selectTransfer => '選擇傳輸';

  @override
  String get selectTransferMessage => '開啟任務以查看檔案、狀態和路徑。';

  @override
  String get direction => '方向';

  @override
  String get device => '裝置';

  @override
  String get message => '訊息';

  @override
  String get saveStatus => '保存狀態';

  @override
  String get updated => '更新時間';

  @override
  String unableToSave(String error) {
    return '無法保存：$error';
  }

  @override
  String get directionOutgoing => '發出';

  @override
  String get directionIncoming => '收到';

  @override
  String get statusPending => '等待中';

  @override
  String get statusWaitingForReceiver => '等待對方接收';

  @override
  String get statusTransferring => '傳輸中';

  @override
  String get statusDone => '完成';

  @override
  String get statusFailed => '失敗';

  @override
  String get statusSending => '傳送中';

  @override
  String get statusSent => '已傳送';

  @override
  String get statusReceived => '已接收';

  @override
  String get statusSaving => '保存中';

  @override
  String get statusSaved => '已保存';

  @override
  String get byteUnitB => 'B';

  @override
  String get byteUnitKb => 'KB';

  @override
  String get byteUnitMb => 'MB';

  @override
  String get byteUnitGb => 'GB';

  @override
  String get byteUnitTb => 'TB';

  @override
  String byteProgress(String transferred, String total) {
    return '$transferred / $total';
  }

  @override
  String attachmentStatusProgress(String status, String progress) {
    return '$status · $progress';
  }

  @override
  String transferRowMeta(String direction, String deviceId) {
    return '$direction · $deviceId';
  }

  @override
  String transferProgressUpdated(String progress, String updated) {
    return '$progress · $updated';
  }

  @override
  String transferProgressSpeed(String progress, String speed) {
    return '$progress · $speed';
  }

  @override
  String get speed => '速度';

  @override
  String get averageSpeed => '平均速度';

  @override
  String get elapsedTime => '耗時';

  @override
  String get remainingTime => '剩餘時間';

  @override
  String durationSeconds(int seconds) {
    return '$seconds秒';
  }

  @override
  String durationMinutesSeconds(int minutes, int seconds) {
    return '$minutes分 $seconds秒';
  }

  @override
  String durationHoursMinutes(int hours, int minutes) {
    return '$hours時 $minutes分';
  }

  @override
  String transferSpeedAndRemaining(String speed, String remaining) {
    return '$speed · 剩餘 $remaining';
  }

  @override
  String transferCompletedSummary(String size, String speed, String duration) {
    return '$size · 平均 $speed · $duration';
  }

  @override
  String get lastError => '最後錯誤';

  @override
  String get todayLabel => '今天';

  @override
  String get yesterdayLabel => '昨天';

  @override
  String get transferNotificationSendingTitle => '正在傳送檔案';

  @override
  String get transferNotificationReceivingTitle => '正在接收檔案';

  @override
  String get transferNotificationSentTitle => '檔案已傳送';

  @override
  String get transferNotificationReceivedTitle => '檔案已接收';

  @override
  String get transferNotificationFailedTitle => '傳輸失敗';

  @override
  String transferNotificationProgress(String fileName, String progress) {
    return '$fileName · $progress';
  }

  @override
  String transferNotificationFailed(String fileName) {
    return '$fileName 無法完成傳輸。';
  }
}
