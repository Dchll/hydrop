# Hydrop 源码理解与答辩 PPT 取材笔记

## 资料定位

- 当前仓库未发现 `初稿-基于Flutter的跨平台高速文件传输系统设计与实现.docx` 原文件，也未在 `/Users/admin-and/Developer/HyyFlutter` 下定位到同名 docx。
- `docs/docx_2.md` 标注来源为 `/Users/admin-and/Downloads/韩义勇毕业设计 2.docx`，内容覆盖摘要、正文 1-7 章、参考文献与附录代码清单，可作为论文初稿/维护稿内容来源。
- `docs/docx.md` 与 `docs/docx_2.md` 结构一致，可作为对照；PPT 内容以维护稿与当前源码交叉校验。
- 当前源码在论文提交后有改进：保留设备页/设置页两个一级入口，新增或完善了传输页源码、传输暂停/取消、自动恢复、通知进度、黑白灰直角 UI 等能力；答辩中应明确“论文描述以提交稿为基础，演示程序以当前源码为准”。

## 程序整体定位

Hydrop 是基于 Flutter 的跨平台局域网高速文件传输系统，面向手机、平板、电脑之间在同一局域网内的直连传输。系统目标是减少云盘外网中转、蓝牙低速和厂商生态限制，形成“设备发现 -> 选择设备 -> 文本/文件发送 -> 进度反馈 -> 本地持久化”的闭环。

## 分层架构

源码采用 `presentation / application / data / core` 分层：

- `presentation`：Flutter 页面与组件，主要页面包括 `HomePage`、`ChatPage`、`SettingsPage`，源码中也存在 `TransfersPage`；页面通过 Riverpod provider 消费状态，不直接访问 Drift、Socket 或 Dio。
- `application`：编排业务状态与用户动作，包括 `AppRuntime`、`DiscoveryController`、`TransferServerController`、`SpeedTestRunner`、`ChatPageController`、`FileTransferCoordinator`、`TransferProgressStore`、二维码连接控制器等。
- `data/local`：Drift + DAO + Repository，维护设备、地址、连接会话、消息、附件、设置、本机资料、统计等表。
- `data/remote`：外部能力和基础设施，包括 Dio、UDP/TCP Socket、网络地址枚举、附件存储、断点续传元数据等。
- `core`：协议常量、主题、国际化格式化、设备 ID、日志与反馈工具。

## 运行时闭环

- `main.dart` 使用 `ProviderScope` 启动 Riverpod，并接入 `TalkerRiverpodObserver`。
- `MainApp` 监听应用生命周期，前台恢复时调用 `AppRuntime.resumeNetwork()` 启动发现与 TCP server，进入后台时停止连续广播并启动低频维护窗口。
- `AppRuntime` 同时负责通知权限申请、发现服务、传输服务、未完成传输恢复。
- 设置由 `settingsProvider` 驱动，`appThemeModeProvider` 与 `appLocaleProvider` 将本地设置转为 `MaterialApp` 可消费的主题和语言。

## 设备发现

- UDP 广播端口为 `39175`，TCP 传输端口为 `39176`。
- 发现 payload 类型为 `hydrop.discovery.hello`，协议版本为 1，包含设备 ID、显示名、TCP 端口、能力列表、nonce、地址列表、网关/子网/广播地址等。
- `LocalNetworkAddressService` 基于 `NetworkInterface.list()` 和 `network_info_plus` 枚举本机地址，过滤回环、链路本地、虚拟网卡，按 IPv4 优先排序，并为 Wi-Fi 场景补齐广播地址。
- `DiscoveryBroadcastService` 多网卡广播，`DiscoverySocketService` 监听 UDP 包。
- `DiscoveryController` 过滤本机设备、nonce 去重、保存设备与地址、每 3 秒做 TTL 扫描，超过 12 秒未刷新则标记不可达；发现后按冷却间隔触发 `SpeedTestRunner` 做轻量测速。

## 通信与传输协议

- TCP 使用 `FrameCodec`，帧格式为 4 字节 header 长度 + 4 字节 body 长度 + JSON header + binary body。
- Header 上限 16KB，Body 上限 1MB；文件传输分片大小为 1MB，最大文件大小为 16GB，并发传输上限为 2。
- frame 类型包括 `speedProbe`、`textMessage`、`heartbeat`、`fileOffer`、`fileChunk`、`fileComplete` 以及对应 ACK 和 error。
- 文本消息流程：先在本地创建 pending 消息，选取最佳地址并建立 TCP，发送 `textMessage`，收到 ACK 后更新为 sent，失败则标记 failed。
- 文件传输流程：`ChatPageController` 通过 `file_picker` 选择文件，`FileTransferCoordinator` 创建附件记录，发送 offer/chunk/complete，更新进度、校验 SHA-256，并支持暂停、取消、失败、自动恢复。

## 本地持久化

当前 `AppDataBase.schemaVersion` 为 1，包含 8 张表：

- `DeviceItems`：设备展示名、设备 ID、连接状态、平均速度、最近连接/断开/传输/错误。
- `DeviceAddressItems`：设备多地址历史、IP 版本、端口、网卡、网关、子网、广播地址、可达性、延迟和测速结果。
- `ConnectionSessionItems`：连接会话、地址绑定、协议版本、心跳、断开和错误信息。
- `MessageItems`：远端设备、文本内容、方向、类型、发送状态、本地/远端消息 ID、错误、已读时间。
- `MessageAttachmentItems`：附件保存状态、路径、下载进度、附件 ID、文件名、MIME、总字节、已传字节、SHA-256、缩略图、传输状态。
- `SettingItems`、`MineItems`、`PointItems`：设置、本机资料与统计/点位数据。

## UI 与视觉

- 当前程序 UI 规范为黑白灰、直角、2px 内部分割线、高密度、工具化，不依赖大面积彩色或阴影。
- 浅色：背景 `#FFFFFF`，主文字 `#0D0D0D`，边框浅灰，强调色 `#0169CC`。
- 深色：背景 `#181818`，面板 `#141414`，主文字 `#FFFFFF`，边框深灰，强调色 `#0169CC`。
- 字体使用 `MiSans`。
- 响应式窗口等级：compact `<600`、medium `600-839`、expanded `840-1199`、large `>=1200`。
- 手机端底部导航，桌面端左侧导航；设备页在桌面端左侧设备列表 + 右侧聊天内容，移动端点击设备进入聊天页。
- PPT 可采用“毛玻璃 + 黑白灰 + 蓝色微光”的高质量答辩风格，但需要保留程序的直角/分割线/工具感特征，避免紫色科技模板。

## 答辩叙事建议

30 分钟问辩中建议正式汇报 18-20 分钟，程序演示 6-8 分钟，预留 2-4 分钟缓冲与过渡；如果院系要求 30 分钟全部展示，可控制 PPT 讲解 20-22 分钟，演示 6 分钟，最后总结 2 分钟。十几页 PPT 建议 14 页左右。

建议主线：

1. 课题背景：跨设备传输痛点与局域网直连价值。
2. 系统目标：跨平台、高速、无需外网、状态可解释。
3. 总体架构：Flutter + Riverpod + Drift + UDP/TCP。
4. 设备发现：多网卡 UDP 广播、TTL、测速、二维码补充。
5. 传输协议：FrameCodec、文本消息、文件分片、ACK、校验。
6. 持久化与恢复：设备记忆、消息/附件表、断点续传、自动恢复。
7. 跨平台 UI：响应式布局、手机/桌面差异、黑白灰设计系统。
8. 测试与结果：功能测试、单元测试、Widget 测试、稳定性分析。
9. 演示页：预留运行截图和现场演示提示。
10. 总结展望：加密、更多平台权限适配、传输调度优化。

## 需要预留的截图位置

- 首页/设备发现页：展示附近设备、在线状态、速度和最近消息。
- 聊天页：展示文本消息、附件卡片、图片/视频/文件消息。
- 传输进度/通知：展示进度条、速度、暂停/取消、失败状态或系统通知。
- 设置页/二维码连接：展示设备 ID、局域网地址、二维码连接、主题语言设置。
- 架构或协议页可使用 SVG 自绘图，不强依赖截图。
