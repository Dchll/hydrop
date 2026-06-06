# data/local 本地数据层

本地数据层是应用状态的 Single Source of Truth。页面不直接读写 Drift；application 层通过 Repository 调用，Repository 再通过 DAO 访问数据库。

## 数据库：`data/local/database.dart`

`AppDataBase` 注册 8 张表和 7 个 DAO：设备、设备地址、连接会话、设置、本机资料、消息、附件、统计。`schemaVersion` 当前为 1。创建数据库时先 `createAll()`，再创建三个自定义唯一索引：

- `device_address_items_identity_unique`：同一设备同一 IP/端口只保留一条地址记录。
- `message_items_local_message_id_unique`：本地消息 ID 非空时唯一。
- `message_attachment_items_attachment_id_unique`：附件 ID 非空时唯一。

`beforeOpen` 开启 SQLite foreign keys，保证设备删除时级联删除地址、消息、会话等依赖记录。

`database_providers.dart` 用 keepAlive Riverpod provider 持有数据库实例，并在 provider dispose 时关闭数据库。

## 表模型

`device.dart` 定义设备主表和地址表。设备主表记录展示名、设备 ID、连接状态、平均速度、最近连接/断开/传输和错误。地址表记录一个设备的多地址历史，包括 IP 版本、端口、网卡、网关、广播地址、来源、可达性、延迟、速度和 TTL 时间。

`message.dart` 定义消息和附件。消息有方向、类型、发送状态、本地/远端消息 ID、错误和已读时间；附件有保存状态、文件路径、进度、attachmentId、文件名、MIME、总字节、已传字节、校验值、缩略图、传输状态和任务 ID。

`connection_session.dart` 记录 TCP 会话状态，包括 sessionId、设备、绑定地址、协议版本、连接时间、心跳时间、断开时间和错误。

`setting.dart` 保存主题模式、语言、是否启用传输加密、是否自动恢复传输。`mine.dart` 保存本机展示名和设备 ID。`point.dart` 保存统计计数。

## DAO 层

DAO 做 SQL、join、事务和数据库行级操作。

`DeviceDao` 负责设备列表排序、设备 upsert、更新速度、更新连接状态和删除设备。排序把 localNetwork 在线设备排前，再按速度、名称、ID 排。

`DeviceAddressDao` 负责地址查询、地址 upsert、批量 upsert、TTL 过期和健康状态更新。upsert 通过事务先查 `deviceId + ipAddress + port`，存在则更新网络元数据和健康字段，不存在则插入。

`ConnectionSessionDao` 负责按 sessionId upsert 会话、更新状态、分页列出会话。它让 TCP server 可以反复保存同一个入站 session 的状态变化。

`MessageDao` 是最复杂的 DAO。它用 join 把消息和附件组合成 `MessageWithAttachmentRows`，提供会话流、文件消息流、每台设备最新消息、未读计数、可恢复发送任务查询、按 attachmentId 查询附件/消息。插入消息时在事务中同时插入附件，并把 transferStatus 映射到旧的 saveStatus/downloadProgress。删除单条消息或清空会话时会返回附件文件路径，供 repository 可选清理本地文件。

`MineDao` 保存/读取/监听唯一一条本机资料。`SettingDao` 保存/读取/监听唯一一条设置，首次读取时插入默认值。`PointDao` 保存/读取统计并提供递增方法。`dao_providers.dart` 把数据库上的 DAO 暴露为 keepAlive provider。

## Repository 层

Repository 做业务口径和快照模型，隐藏 Drift row/Companion。

`DeviceRepository` 把 `DeviceItem` 转成 `DeviceSnapshot`，暴露设备列表流、发现设备保存、速度更新、连接状态更新、删除设备、markConnected 和 markDisconnected。

`DeviceAddressRepository` 把地址行转成 `DeviceAddressSnapshot`，并在 repository 内按可达性、速度、延迟、lastSeen 排序。应用层只要取第一条就是当前最优地址。

`ConnectionSessionRepository` 把会话行转成 `ConnectionSessionSnapshot`，提供保存、更新、分页查询。

`MessageRepository` 提供聊天和文件传输使用的完整业务 API：监听会话、监听文件消息、监听每设备最新消息、未读计数、创建发送文本、保存接收文本、创建本地文件消息、创建发送文件消息、保存接收文件 offer、更新附件进度/状态、标记消息 sent/sending/failed、删除消息、清空会话、标记会话已读。它还生成本地 msg/attachment ID，并可在删除时 best-effort 清理本地文件。

`MineRepository` 确保本机 profile 存在，使用 `deriveHydropDeviceId(stableSeed)` 生成稳定设备 ID。`SettingRepository` 暴露设置流和四个设置项的 setter。`PointRepository` 暴露统计流和计数累加。

## 调用链位置

- 设备发现、二维码配对、TCP 接收会调用 `DeviceRepository` 和 `DeviceAddressRepository` 写设备与地址。
- 首页通过 `homeDeviceListProvider` 读 `DeviceRepository.watchDevices()`。
- 聊天页通过 `conversationProvider` 读 `MessageRepository.watchConversation()`。
- 文本/文件发送先通过 `MessageRepository` 创建本地记录，再通过 TCP 发送，最后再更新状态。
- 传输页通过 `fileMessagesProvider` 读取所有文件消息，并合并内存进度展示。
- 设置页通过 `settingsProvider` 读写设置；App 入口通过设置派生主题和语言。
