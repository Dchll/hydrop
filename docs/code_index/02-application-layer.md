# application 应用编排层

application 层位于页面和数据/网络服务之间。它不直接渲染 UI，也不保存数据库表结构；它负责把“用户动作”和“应用生命周期”翻译成 repository/service 调用，并维护短期状态、错误流转和后台任务。

## 应用运行时：`application/app/app_runtime.dart`

`appRuntimeProvider` 组装 `DiscoveryController`、`TransferServerController`、`FileTransferCoordinator` 和 `TransferNotificationService`。创建时会请求通知权限并尝试恢复中断的传输，销毁时停止后台维护定时器。

`AppRuntime.resumeNetwork()` 前台恢复时启动发现和 TCP server，并恢复可续传任务。`pauseNetwork()` 非前台时停止连续发现和 TCP server，然后启动后台维护定时器。后台维护每隔 `discoveryBackgroundMaintenanceInterval` 打开一个短窗口：启动发现和 server，窗口结束后再停止。这样实现“后台 best-effort”，避免应用非前台时持续占用网络资源。

`appThemeModeProvider` 和 `appLocaleProvider` 从设置流中派生 Flutter 可直接消费的主题模式和 Locale，UI 不需要直接判断数据库枚举。

## 首页状态：`application/home/home_page_state.dart`

首页的 provider 把底层数据整理成页面模型：

- `homeDeviceListProvider` 监听设备 repository，并把 `DeviceSnapshot` 映射为 `HomeDeviceListItem`。
- `homeLastMessageByDeviceProvider` 监听每台设备最近一条消息，把消息方向和文本/附件转换成首页摘要。
- `homeUnreadCountByDeviceProvider` 监听未读计数。
- `homePageControllerProvider` 暴露刷新发现、删除设备和添加调试设备动作。

`HomeDeviceListItem` 负责把设备状态和测速值变成人类可读 label，包括在线/离线、速度、首字母、最近传输时间。`HomePageController.deleteDevice()` 会先清空会话再删除设备，避免 UI 只删设备导致孤立消息。

## 我的页与二维码：`application/mine/*`

`mineOverviewProvider` 负责组装我的页所需的完整状态：确保本机 profile 存在、读取本机网络地址、生成二维码 payload。默认展示名来自 `Platform.localHostname`，为空时使用操作系统和 CPU 数兜底。

`MinePageController.updateDisplayName()` 校验空字符串，确保 profile 存在后保存新的展示名，并 invalidate overview 刷新页面。

`ConnectionQrPayload` 把本机信息编码为紧凑 JSON。它只保留 IPv4 地址并限制数量，降低二维码扫描难度。`ConnectionQrPayloadCodec.decode()` 严格验证类型、版本、端口、字符串长度和地址版本，任何异常都返回 null。

`ConnectionQrController.saveScannedPayload()` 是扫码后的业务入口。它解析 payload，确保本机 profile 存在，拒绝扫描自己的码，然后保存远端设备与地址，并异步触发测速。`connectionQrScanSupportedProvider` 按平台禁用 Windows/Linux/Fuchsia 扫码入口。

## 发现控制器：`application/discovery/discovery_controller.dart`

`DiscoveryController` 协调三类能力：本机 profile、UDP 发送/接收、数据库回写。`start()` 只保留一个 `_startFuture`，防止重复启动；`restart()` 先 stop 再 start。

启动时先确保本机 profile，再 best-effort 启动 UDP 接收和广播。收到 payload 后：

1. 忽略本机设备 ID。
2. 用 `deviceId:nonce` 做重复包过滤，并只保留 128 个 nonce。
3. 写入设备主表，状态为 localNetwork。
4. 把 payload 地址或 UDP 源地址 fallback 转成 `DeviceAddressUpsert`。
5. 写入地址表，并按冷却时间触发 `SpeedTestRunner.refreshDevice()`。

TTL 扫描通过可注入的 timer factory 实现，测试可以替换定时器。它把超时广播地址标记为不可达，并在没有其他可达地址时把设备置为 disconnected。

## 连接测速：`application/connection/speed_test_runner.dart`

`SpeedTestRunner` 读取设备地址，最多取前三个候选地址测速。每个地址会建立 TCP 连接，先用空/小 payload 测 RTT，再做多轮吞吐探测，取中位数作为速度。成功时更新地址健康状态和设备平均速度；失败时把地址标记不可达并写入 `speed_test_failed`。

测速通过 `speedProbe` / `speedProbeAck` frame 实现，复用 TCP frame 协议，不额外引入 HTTP 或其他协议。

## TCP server 与文本接收：`application/connection/transfer_server_controller.dart`

`TransferServerController` 启动默认 TCP 端口，管理所有入站连接、frame 订阅、心跳超时、连接到设备 ID 的映射和会话记录。

每个连接收到 frame 后进入 per-connection 队列，保证同一连接上的 frame 按顺序处理；前一个 frame 出错不会阻塞后续 frame。frame type 分发如下：

- `speedProbe`：立即回 ACK，用于测速。
- `textMessage`：校验 sender、requestId、messageId、body，保存设备与消息，然后回 `textMessageAck`。
- `heartbeat`：记录连接方并回 `heartbeatAck`。
- `heartbeatAck`：只记录连接方和心跳。
- 其他 frame：交给 `FileTransferCoordinator.handleIncomingFrame()` 处理文件传输。

连接关闭或心跳超时时，会关闭连接、取消订阅、停止 timer、通知文件传输协调器，并把设备和连接会话写为 disconnected。

## 聊天控制器：`application/chat/chat_page_state.dart`

`ChatPageController.sendText()` 是文本发送主流程：校验空文本、创建本地 pending 消息、标记 sending、读取本机 profile、选择最佳地址、建立 TCP、发送 textMessage frame、等待 ACK，最后标记 sent 或 failed。

`pickAndCreateFileMessage()` 负责从 FilePicker 选择文件/图片/视频，推断大小和 MIME。如果本机 profile 或远端地址不存在，它仍会创建本地失败记录，方便用户在聊天中看到原因；如果条件满足，就把文件发送放到后台任务，立即返回 queued。

控制器还把保存附件、暂停/取消传输、删除消息、清空会话、标记已读等页面动作转发给对应 controller 或 repository。它的职责是“页面动作聚合器”，不是 UI 组件。

`chat_search_state.dart` 用 family Notifier 为每个远端设备维护独立搜索状态。它只存 `isSearching/query/selectedIndex`，并提供 toggle、updateQuery、previous、next。

## 文件传输协调器：`application/transfer/file_transfer_coordinator.dart`

`FileTransferCoordinator` 是文件传输的核心状态机。它同时处理发送、接收、暂停、取消、恢复、进度、通知和断点续传。

发送侧实现方式：

1. `_prepareOutgoingFile()` 创建本地 file message 和 attachment，校验最大文件大小，生成 attachmentId/transferTaskId。
2. `sendFileToAddress()` 把任务按 `host:port` 加入队列。
3. `_TransferQueueLimiter` 限制全局并发，队列 worker 尽量复用同一个 TCP 连接。
4. `_sendPreparedFile()` 发送 fileOffer，读取对端 `resumeFromByte`，从 offset 继续发送 chunk。
5. `_OutgoingChunkAckTracker` 监听 chunk ACK，用滑动窗口限制未确认字节数，并把 ACK 进度写回数据库和进度 store。
6. 发送完后计算 sha256，发送 fileComplete，等待对端完成 ACK，再把附件和消息标记为完成。

接收侧实现方式：

1. `handleIncomingFrame()` 只接管 fileOffer/fileChunk/fileComplete。
2. `_handleFileOffer()` 校验元数据，准备下载文件路径，根据本地 checkpoint 计算可恢复 offset，保存或更新 attachment，再回 offerAck。
3. `_handleFileChunk()` 严格检查 offset、length 和顺序，重复 chunk 会直接回 ACK，越界或跳洞会失败；正常 chunk 写入文件、更新 checkpoint、进度、通知，并按阈值 ACK。
4. `_handleFileComplete()` 关闭文件、检查字节数和 sha256，成功后标记 saved、清理 resume metadata、发送 completeAck；失败则记录 failed 并在校验失败时删除损坏文件。

暂停和取消的差异：暂停会记录当前进度并把状态放回 pending，便于后续恢复；取消会把 attachment 和 message 标为 failed，并关闭连接、移出队列、清理通知和缓存。

`resumeInterruptedTransfers()` 从 repository 查找可恢复的发送任务，验证源文件存在，选择设备可用地址，把传输恢复任务重新入队。

## 进度、附件动作和通知

`transfer_progress_state.dart` 是内存进度 store。它按 attachmentId 存 `TransferProgressSnapshot`，记录方向、阶段、已传字节、总字节、速率、更新时间和错误。速率用两次 progress 的字节差与时间差计算。

`attachment_action_controller.dart` 提供“另存为”：校验 attachment 有本地文件，打开保存对话框，必要时创建目标目录并复制文件。

`transfer_action_controller.dart` 是 UI 到 `FileTransferCoordinator` 的薄适配层，只暴露 pause/cancel。

`transfer_notification_service.dart` 负责传输通知。它只在 Android/iOS/macOS 启用，初始化插件、请求权限、按 500ms 节流展示进度，完成或失败后延迟取消通知。它根据设置里的语言生成通知本地化文本；插件未注册或平台通道异常时会禁用本轮通知并记录日志。
