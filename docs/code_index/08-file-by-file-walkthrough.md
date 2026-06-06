# 逐文件语义地图

本页按目录列出每个文件负责什么、怎么做。生成文件按生成来源和消费方式说明。

## lib 根目录与路由

- `lib/main.dart`：应用进程入口；创建 Riverpod 容器和 Talker provider 观察器，再启动 `MainApp`。
- `lib/app.dart`：应用运行时入口；监听生命周期，驱动网络暂停/恢复，读取设置派生主题和语言，并挂载 AutoRoute。
- `lib/routes/app_router.dart`：手写路由配置；定义主壳、首页、设置页和聊天页路径。
- `lib/routes/app_router.gr.dart`：AutoRoute 生成路由类；把页面参数和路由信息转成可导航对象。

## lib/core

- `lib/core/constants/connection_qr_constants.dart`：二维码协议常量；约束 payload 类型、版本和地址数量。
- `lib/core/constants/discovery_constants.dart`：UDP 发现常量；定义端口、间隔、后台窗口、能力列表、TTL 和失败原因。
- `lib/core/constants/transfer_constants.dart`：TCP/文件传输常量；定义协议版本、frame 类型、超时、分片大小、ACK、并发、重试和断点续传参数。
- `lib/core/feedback/transient_feedback.dart`：跨平台短提示；移动端用 toast，其他平台用 SnackBar。
- `lib/core/locale/app_locale.dart`：设置语言到 Flutter Locale 的转换。
- `lib/core/localization/localized_formatters.dart`：字节、速率、时间、方向和状态的本地化格式化入口。
- `lib/core/theme/app_theme.dart`：明暗主题和持久化主题枚举映射；统一黑白灰、0 圆角和控件样式。
- `lib/core/utils/device_identity/device_identity.dart`：稳定设备 ID 哈希生成；对 seed 加命名空间后 sha256 截断。
- `lib/core/utils/talker/talker.dart`：全局 Talker 日志实例。

## lib/application

- `lib/application/app/app_runtime.dart`：应用生命周期编排；统一启动/停止发现、TCP server、传输恢复和通知权限。
- `lib/application/home/home_page_state.dart`：首页设备列表状态；合并设备、最新消息、未读数，并提供刷新/删除设备动作。
- `lib/application/mine/mine_page_state.dart`：我的页状态；确保本机 profile，枚举本机地址，生成二维码 payload。
- `lib/application/mine/connection_qr_payload.dart`：二维码 payload 编解码；使用短 key JSON 并严格校验扫码数据。
- `lib/application/mine/connection_qr_controller.dart`：扫码保存逻辑；拒绝本机码，保存远端设备/地址并触发测速。
- `lib/application/discovery/discovery_broadcast_state.dart`：空占位文件；当前没有业务声明。
- `lib/application/discovery/discovery_controller.dart`：设备发现控制器；启动 UDP 收发、处理 payload、写设备地址、做 TTL 和测速调度。
- `lib/application/connection/speed_test_runner.dart`：连接测速；通过 speedProbe frame 测延迟和吞吐并更新地址健康。
- `lib/application/connection/transfer_server_controller.dart`：TCP 入站服务；处理测速、文本、心跳和文件传输 frame，并维护连接会话状态。
- `lib/application/chat/chat_page_state.dart`：聊天动作控制器；发送文本、选择文件、后台文件发送、附件保存、暂停/取消、删除和已读。
- `lib/application/chat/chat_search_state.dart`：聊天搜索状态；为每个会话保存搜索开关、query 和选中结果索引。
- `lib/application/transfer/file_transfer_coordinator.dart`：文件传输状态机；处理发送/接收/队列/分片/ACK/校验/暂停/取消/恢复/通知。
- `lib/application/transfer/transfer_progress_state.dart`：内存实时传输进度；按 attachmentId 保存方向、阶段、进度、速率和错误。
- `lib/application/transfer/attachment_action_controller.dart`：附件另存为；校验源文件并通过 FilePicker 复制到目标路径。
- `lib/application/transfer/transfer_action_controller.dart`：传输动作薄封装；把 UI pause/cancel 转发给 coordinator。
- `lib/application/transfer/transfer_notification_service.dart`：传输通知；按平台初始化插件，节流展示进度，完成/失败后取消通知。

## lib/data/local

- `lib/data/local/database.dart`：Drift 数据库声明；注册表/DAO、创建自定义唯一索引、开启外键。
- `lib/data/local/database.g.dart`：Drift 数据库生成实现；提供 typed table、row、companion 和查询管理器。
- `lib/data/local/database_providers.dart`：数据库 provider；keepAlive 持有并在 dispose 时关闭。
- `lib/data/local/database_providers.g.dart`：Riverpod 生成 provider。
- `lib/data/local/model/device/device.dart`：设备和设备地址表；保存设备状态、多地址、测速、TTL 和网络元数据。
- `lib/data/local/model/message/message.dart`：消息和附件表；保存文本/文件、发送状态、附件进度、校验和传输任务。
- `lib/data/local/model/connection/connection_session.dart`：连接会话表；保存 TCP session、状态、心跳和错误。
- `lib/data/local/model/mine/mine.dart`：本机资料表；保存展示名和设备 ID。
- `lib/data/local/model/point/point.dart`：统计表；保存启动时间和使用计数。
- `lib/data/local/model/setting/setting.dart`：设置表；保存主题、语言、加密和自动恢复开关。
- `lib/data/local/dao/dao_providers.dart` 与 `.g.dart`：DAO provider；从数据库实例取各 DAO。
- `lib/data/local/dao/device_dao.dart` 与 `.g.dart`：设备 DAO；排序列表、upsert、速度/状态更新、删除。
- `lib/data/local/dao/device_address_dao.dart` 与 `.g.dart`：地址 DAO；地址 upsert、批量保存、TTL 过期、健康状态更新。
- `lib/data/local/dao/connection_session_dao.dart` 与 `.g.dart`：连接会话 DAO；按 sessionId upsert 和更新状态。
- `lib/data/local/dao/message_dao.dart` 与 `.g.dart`：消息 DAO；会话/文件消息 join、最新消息、未读、可恢复任务、插入消息附件和删除。
- `lib/data/local/dao/mine_dao.dart` 与 `.g.dart`：本机资料 DAO；读取、监听和保存唯一 profile。
- `lib/data/local/dao/point_dao.dart` 与 `.g.dart`：统计 DAO；确保统计行并累加计数。
- `lib/data/local/dao/setting_dao.dart` 与 `.g.dart`：设置 DAO；确保默认设置并更新各设置项。
- `lib/data/local/repository/device_repository.dart` 与 `.g.dart`：设备 repository；把 row 转快照并提供设备业务 API。
- `lib/data/local/repository/device_address_repository.dart` 与 `.g.dart`：地址 repository；排序地址并提供保存、过期、健康更新。
- `lib/data/local/repository/connection_session_repository.dart` 与 `.g.dart`：会话 repository；保存/更新/列出连接会话。
- `lib/data/local/repository/message_repository.dart` 与 `.g.dart`：消息 repository；创建/保存/更新/删除消息和附件，并暴露会话流。
- `lib/data/local/repository/mine_repository.dart` 与 `.g.dart`：本机 profile repository；生成和确保稳定设备 ID。
- `lib/data/local/repository/point_repository.dart` 与 `.g.dart`：统计 repository；封装统计流和计数累加。
- `lib/data/local/repository/setting_repository.dart` 与 `.g.dart`：设置 repository；封装设置流和 setter。

## lib/data/remote

- `lib/data/remote/dio_provider.dart` 与 `.g.dart`：Dio family provider；按 baseUrl 创建 HTTP client。
- `lib/data/remote/repository/bing_wallpaper_repository.dart` 与 `.g.dart`：每日一图 repository；请求元数据、下载 4K 图片、缓存到 Downloads 并删除旧图。
- `lib/data/remote/service/attachment_storage.dart`：接收附件保存；选择 Downloads/ApplicationSupport，清洗文件名并生成不冲突路径。
- `lib/data/remote/service/discovery_broadcast_service.dart`：UDP 广播发送；按本机 IPv4 源地址建 socket，定时发送 discovery hello。
- `lib/data/remote/service/discovery_payload_codec.dart`：UDP payload 解码；验证协议、字段和地址元数据。
- `lib/data/remote/service/discovery_socket_service.dart`：UDP 广播接收；把 datagram 解码为 payload event。
- `lib/data/remote/service/frame_codec.dart`：TCP frame 编解码；用 8 字节长度头 + JSON header + body 处理粘包/拆包。
- `lib/data/remote/service/local_network_address_service.dart`：本机地址枚举；过滤虚拟/无效地址，合并 Wi-Fi 元数据，生成广播源。
- `lib/data/remote/service/transfer_resume_metadata_store.dart`：断点续传元数据；保存 checkpoint、恢复前校验文件并截断损坏尾部。
- `lib/data/remote/service/transfer_socket_service.dart`：TCP socket 抽象；提供 client/server、frame 连接、串行写入和关闭。

## lib/presentation

- `lib/presentation/pages/app/app_page.dart`：主壳页面；按窗口宽度选择侧边导航或底部导航。
- `lib/presentation/pages/home/home_page.dart`：设备首页；展示设备、搜索、刷新、扫码、删除，宽屏内嵌聊天。
- `lib/presentation/pages/chat/chat_page.dart`：聊天页；展示会话、搜索、发送文本/附件、消息操作、预览、链接确认。
- `lib/presentation/pages/chat/widgets/chat_message_widgets.dart`：消息 UI 组件；渲染时间线、气泡、附件、进度、composer 和空状态。
- `lib/presentation/pages/chat/widgets/chat_image_viewer.dart`：图片/视频预览；支持多图翻页缩放和本地视频播放。
- `lib/presentation/pages/mine/mine_page.dart`：我的页；展示 profile、二维码、本机地址和诊断，支持修改展示名。
- `lib/presentation/pages/settings/settings_page.dart`：设置页；主题、语言、传输开关、本机/网络/about 信息。
- `lib/presentation/pages/transfers/transfers_page.dart`：传输页；文件消息列表、过滤、搜索、详情、暂停/取消/另存为。
- `lib/presentation/widgets/connection_qr_actions.dart`：二维码展示和扫码动作；封装 QR bottom sheet、scanner 和错误提示。
- `lib/presentation/widgets/hd_components.dart`：页面 Scaffold、Header、Panel、Dock 等共享容器。
- `lib/presentation/widgets/hd_container.dart`：基础容器；按主题 surface 渲染统一区域。
- `lib/presentation/widgets/hd_floating_components.dart`：浮动 AppBar、IconButton、搜索框组件。
- `lib/presentation/widgets/hd_glass_components.dart`：旧 glass 命名兼容导出。
- `lib/presentation/widgets/hydrop_adaptive.dart`：响应式断点和布局参数。
- `lib/presentation/widgets/image_widget.dart`：自动识别网络、data URI、文件和 asset 的图片组件。
- `lib/presentation/widgets/image_widget_file_provider_io.dart`：IO 平台 file/file:// 图片 provider。
- `lib/presentation/widgets/image_widget_file_provider_stub.dart`：非 IO 平台文件图片兜底。

## lib/gen 与 lib/l10n

- `lib/gen/assets.gen.dart`、`colors.gen.dart`、`fonts.gen.dart`：FlutterGen 资源访问代码。
- `lib/gen/l10n/app_localizations*.dart`：gen-l10n 输出；提供本地化 API 和具体语言字符串。
- `lib/l10n/app_en.arb`、`app_zh.arb`、`app_zh_Hant.arb`：用户可见文案源文件。

## test

- `test/application/discovery/discovery_controller_test.dart`：验证发现 controller 保存设备地址、fallback 源地址和 TTL 过期。
- `test/core/theme/app_theme_test.dart`：验证主题色和主题模式映射。
- `test/core/utils/device_identity_test.dart`：验证设备 ID 哈希稳定性和空 seed 校验。
- `test/data/data_layout_test.dart`：验证 data 顶层目录边界。
- `test/data/remote/service/*_test.dart`：验证发现广播、payload、socket、本机地址枚举。
- `test/data/repository/*_test.dart`：验证 repository + 内存数据库读写语义。
- `test/presentation/widgets/*_test.dart`：验证共享 UI 组件和 ImageWidget 行为。
- `test/presentation/pages/glass_page_usage_test.dart`：验证页面继续使用共享视觉组件。


## 生成文件完整路径补充

这些文件由 Drift、Riverpod、AutoRoute、FlutterGen 或 gen-l10n 生成；语义见上方对应源文件说明，维护方式是修改源文件后重新生成。

- `lib/data/local/database.g.dart`：Drift 数据库完整生成实现。
- `lib/data/local/database_providers.g.dart`：数据库 Riverpod provider 生成实现。
- `lib/data/local/dao/connection_session_dao.g.dart`：连接会话 DAO Drift mixin。
- `lib/data/local/dao/dao_providers.g.dart`：DAO provider 生成实现。
- `lib/data/local/dao/device_address_dao.g.dart`：设备地址 DAO Drift mixin。
- `lib/data/local/dao/device_dao.g.dart`：设备 DAO Drift mixin。
- `lib/data/local/dao/message_dao.g.dart`：消息 DAO Drift mixin。
- `lib/data/local/dao/mine_dao.g.dart`：本机资料 DAO Drift mixin。
- `lib/data/local/dao/point_dao.g.dart`：统计 DAO Drift mixin。
- `lib/data/local/dao/setting_dao.g.dart`：设置 DAO Drift mixin。
- `lib/data/local/repository/connection_session_repository.g.dart`：连接会话 repository provider 生成实现。
- `lib/data/local/repository/device_address_repository.g.dart`：设备地址 repository provider 生成实现。
- `lib/data/local/repository/device_repository.g.dart`：设备 repository provider 生成实现。
- `lib/data/local/repository/message_repository.g.dart`：消息 repository provider 生成实现。
- `lib/data/local/repository/mine_repository.g.dart`：本机资料 repository provider 生成实现。
- `lib/data/local/repository/point_repository.g.dart`：统计 repository provider 生成实现。
- `lib/data/local/repository/setting_repository.g.dart`：设置 repository provider 生成实现。
- `lib/data/remote/dio_provider.g.dart`：Dio family provider 生成实现。
- `lib/data/remote/repository/bing_wallpaper_repository.g.dart`：壁纸相关 provider 生成实现。
- `lib/routes/app_router.gr.dart`：AutoRoute route class 生成实现。
- `lib/gen/assets.gen.dart`：FlutterGen asset 访问代码。
- `lib/gen/colors.gen.dart`：FlutterGen color 访问代码。
- `lib/gen/fonts.gen.dart`：FlutterGen font 访问代码。
- `lib/gen/l10n/app_localizations.dart`：gen-l10n 抽象 API、delegate 和 lookup。
- `lib/gen/l10n/app_localizations_en.dart`：英文文案实现。
- `lib/gen/l10n/app_localizations_zh.dart`：中文文案实现。

## 测试文件完整路径补充

- `test/application/discovery/discovery_controller_test.dart`：发现控制器业务编排测试。
- `test/core/theme/app_theme_test.dart`：主题与主题模式映射测试。
- `test/core/utils/device_identity_test.dart`：设备 ID 哈希测试。
- `test/data/data_layout_test.dart`：data 目录边界测试。
- `test/data/remote/service/discovery_broadcast_service_test.dart`：UDP 广播服务测试。
- `test/data/remote/service/discovery_payload_codec_test.dart`：发现 payload 解码测试。
- `test/data/remote/service/discovery_socket_service_test.dart`：UDP 接收服务测试。
- `test/data/remote/service/local_network_address_service_test.dart`：本机地址枚举测试。
- `test/data/repository/bing_wallpaper_repository_test.dart`：每日一图 HTTP 与缓存测试。
- `test/data/repository/connection_session_repository_test.dart`：连接会话 repository 测试。
- `test/data/repository/device_address_repository_test.dart`：设备地址 repository 测试。
- `test/data/repository/device_repository_test.dart`：设备 repository 测试。
- `test/data/repository/message_repository_test.dart`：消息 repository 测试。
- `test/presentation/pages/glass_page_usage_test.dart`：页面共享视觉组件使用测试。
- `test/presentation/widgets/hd_container_test.dart`：基础容器构建测试。
- `test/presentation/widgets/hd_glass_components_test.dart`：glass 兼容别名测试。
- `test/presentation/widgets/image_widget_test.dart`：图片类型自动识别测试。
