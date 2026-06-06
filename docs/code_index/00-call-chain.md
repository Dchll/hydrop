# 启动与主调用链

## 应用启动链路

```text
lib/main.dart
  -> runApp(ProviderScope)
  -> MainApp
  -> appRuntimeProvider / appThemeModeProvider / appLocaleProvider
  -> MaterialApp.router
  -> AppRouter
  -> AppPage
  -> HomePage / SettingsPage / ChatPage
  -> application controller/provider
  -> repository/provider
  -> Drift / Dio / UDP / TCP / filesystem / platform APIs
```

`main()` 做的事情很少：创建 `ProviderScope`，接入 `TalkerRiverpodObserver` 观察 provider 生命周期，然后启动 `MainApp`。这样做的目的，是把全局依赖统一放到 Riverpod 容器中，便于各层通过 provider 注入，而不是在页面里手动 new 服务。

`MainApp` 是运行时边界。它监听 Flutter 生命周期，前台恢复时调用 `AppRuntime.resumeNetwork()`，非前台时调用 `AppRuntime.pauseNetwork()`。它还读取设置表转换出的 `ThemeMode` 和 `Locale`，再交给 `MaterialApp.router`。因此主题、语言、网络生命周期都从同一个应用入口被驱动。

`AppRouter` 定义 AutoRoute 路由：`/app` 是主 Shell，包含首页和设置页；`/chat` 是会话页。`AppPage` 根据窗口宽度决定使用侧边导航还是底部导航，把首页与设置页放进 `AutoTabsRouter`。

## 设备发现链路

```text
MainApp watches appRuntimeProvider
  -> AppRuntime.resumeNetwork()
  -> DiscoveryController.start()
  -> MineRepository.ensureMineProfile()
  -> DiscoverySocketService.start() 监听 UDP
  -> DiscoveryBroadcastService.start() 定时广播
  -> DiscoveryController._handlePayload()
  -> DeviceRepository.saveDiscoveredDevice()
  -> DeviceAddressRepository.saveAddresses()
  -> SpeedTestRunner.refreshDevice()
  -> HomePage 通过 homeDeviceListProvider 展示设备
```

发现逻辑先确保本机资料存在，再启动 UDP 接收和广播。广播 payload 里包含设备 ID、展示名、TCP 端口、能力列表和本机地址。收到别人的 payload 后，controller 会过滤本机设备与重复 nonce，把设备写入 `DeviceItems`，把地址写入 `DeviceAddressItems`，再按冷却间隔触发测速。

TTL 扫描由 `DiscoveryController` 内部定时器完成：超过 `discoveryDeviceTtl` 没有刷新的广播地址会被标记不可达；如果该设备没有其他可达地址，设备状态会写成 disconnected。这个设计让首页只读数据库流，不需要自己判断超时。

## 二维码手动配对链路

```text
MinePage
  -> mineOverviewProvider
  -> ConnectionQrPayload.localDevice().encode()
  -> ConnectionQrActions 显示 QR / 扫码
  -> ConnectionQrController.saveScannedPayload()
  -> codec.decode()
  -> DeviceRepository.saveDiscoveredDevice()
  -> DeviceAddressRepository.saveAddresses()
  -> SpeedTestRunner.refreshDevice()
```

二维码是 UDP 发现以外的手动配对入口。payload 用短 key 压缩：类型、版本、设备 ID、名称、TCP 端口和最多 4 个 IPv4 地址。扫描成功后会先验证协议类型、版本、端口和字符串长度，再拒绝本机二维码，最后把远端设备与地址写入本地，并触发测速。

## 文本消息发送链路

```text
ChatPage._sendText()
  -> ChatPageController.sendText()
  -> MessageRepository.createOutgoingTextMessage() 本地 pending
  -> MessageRepository.markMessageSending()
  -> MineRepository.getMineProfile()
  -> DeviceAddressRepository.listAddressesForDevice()
  -> TransferSocketService.connect()
  -> TransferFrame(type=textMessage)
  -> TransferServerController._handleTextMessage()
  -> MessageRepository.saveReceivedMessage()
  -> TransferFrame(type=textMessageAck)
  -> MessageRepository.markMessageSent()/markMessageFailed()
```

文本发送采用“先落库、再发送、按 ACK 更新状态”的方式。这样即使 TCP 失败，聊天页仍能看到失败记录。发送方用最佳地址建立 TCP，发送 `textMessage` frame，并等待同 requestId 的 ACK。接收方保存消息后回 ACK，发送方拿到 ACK 后把状态改为 sent；超时或异常则把本地消息改为 failed。

## 文件传输链路

```text
ChatPage._pickFile()
  -> ChatPageController.pickAndCreateFileMessage()
  -> FileTransferCoordinator.sendFileToAddress()
  -> _prepareOutgoingFile() 创建消息与附件记录
  -> endpoint queue + concurrency limiter
  -> fileOffer / fileOfferAck
  -> fileChunk / fileChunkAck
  -> fileComplete / fileCompleteAck
  -> progressStore + MessageRepository.updateAttachmentTransfer()
  -> TransferNotificationService
```

文件传输通过同一套 TCP frame 完成，核心是 offer、chunk、complete 三段。发送前先创建本地 file message 和 attachment，随后进入按 endpoint 分组的队列；队列复用同一连接，并通过全局并发限制避免同时跑过多传输。

接收方收到 `fileOffer` 后决定保存路径，结合断点续传元数据计算 `resumeFromByte`，回 `fileOfferAck`。发送方从该 offset 开始分片读取文件，每个分片发送 `fileChunk`，接收方顺序写入文件、记录 checkpoint、更新进度，并按阈值回 `fileChunkAck`。发送完后双方用 sha256 校验；校验通过后附件状态写为 saved，否则失败并清理损坏文件。

## 传输恢复与暂停取消链路

```text
AppRuntime.resumeInterruptedTransfers()
  -> FileTransferCoordinator.resumeInterruptedTransfers()
  -> MessageRepository.listRecoverableOutgoingTransfers()
  -> DeviceAddressRepository.listAddressesForDevice()
  -> queue outgoing transfer

Chat/Transfers pause/cancel
  -> TransferActionController
  -> FileTransferCoordinator.pauseTransfer()/cancelTransfer()
  -> close connection / remove queue / update DB / progress / notification
```

自动恢复只在设置允许时执行。它查找发送方向、文件消息、传输中状态、带 attachmentId 和 filePath 的记录；如果源文件还在，就按设备地址重新排队。暂停不会把任务标为永久失败，而是保留进度并把附件状态回到 pending；取消会把状态置 failed，并根据方向清理连接、队列、元数据和通知。

## 页面消费链路

首页、聊天页、传输页、我的页和设置页都只读 provider。页面只保留搜索框、选中项、分页数、输入框等临时 UI 状态；需要刷新、发送、保存、暂停、删除、扫码时，通过 controller/provider 调用 application 或 repository。这个边界使页面不会直接操作 Drift、Socket、Dio 或文件系统。
