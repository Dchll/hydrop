# 入口、路由、core 基础设施

## 启动入口

`lib/main.dart` 只做应用启动和 provider 观察器安装。`ProviderScope` 把整个应用放入 Riverpod 容器，`TalkerRiverpodObserver` 记录 provider 添加、更新、释放和失败事件。代码没有在 `main()` 中初始化数据库或网络，而是让 `MainApp` 和 provider 懒加载触发，这符合当前项目把副作用放进 provider/controller 的方向。

`lib/app.dart` 的 `MainApp` 做三件事：

- 维护 `AppRouter` 实例，并交给 `MaterialApp.router`。
- 监听生命周期，前台恢复网络发现和 TCP server，非前台停止连续网络服务并启用后台短窗口维护。
- 从 `settingsProvider` 派生主题和语言，应用 `AppTheme.light()` / `AppTheme.dark()` 与生成的本地化 delegate。

## 路由

`lib/routes/app_router.dart` 使用 AutoRoute 定义路由树：`AppRoute` 是主壳，子路由是 `HomeRoute` 和 `SettingsRoute`；`ChatRoute` 是独立页面。`lib/routes/app_router.gr.dart` 是 AutoRoute 生成文件，负责把页面构造函数参数、path 和 route info 转换成可导航对象。业务变更只应改 `app_router.dart` 和页面注解，不手改生成文件。

## 主题

`lib/core/theme/app_theme.dart` 提供完整的明暗主题。实现方式是先构建 `ColorScheme`，再统一配置 Scaffold、AppBar、Card、Input、Button、BottomSheet、NavigationBar、NavigationRail。主题强调黑白灰、0 圆角和 2px 边框；页面通过 `Theme.of(context).colorScheme` 消费这些语义色。

`AppThemeModeX.materialThemeMode` 把持久化枚举 `AppThemeMode.system/light/dark` 转换为 Flutter 的 `ThemeMode`，由 `appThemeModeProvider` 使用。

## 本地化与格式化

`lib/core/locale/app_locale.dart` 把 `AppLanguage` 转换为 `Locale?`，其中 system 返回 null 让系统语言生效，中文简体、繁体和英文返回明确 locale。

`lib/core/localization/localized_formatters.dart` 收敛页面常用格式化：字节、字节进度、速率、日期时间、收发方向、附件传输状态、消息发送状态、保存状态。这样页面不需要自己拼接 KB/MB/GB、pending/sent/failed 等用户可见字符串。

## 常量与协议参数

`connection_qr_constants.dart` 定义二维码 payload 类型、协议版本和地址数量上限。`discovery_constants.dart` 定义 UDP 发现 payload 类型、版本、广播端口、TCP 广告端口、广播间隔、后台维护窗口、能力列表、fallback 广播地址、TTL 和 TTL 扫描间隔。`transfer_constants.dart` 定义 TCP 协议版本、默认端口、超时、心跳、并发数、最大文件大小、frame 大小上限、frame type、测速参数、分片大小、ACK 窗口、重试策略和断点续传 checkpoint 大小。

这些常量是协议的公共契约。发现、测速、聊天、文件传输、断点续传都引用它们，避免同一个魔法字符串或超时值散落到不同文件。

## 反馈、设备 ID 与日志

`TransientFeedback.show()` 在 Android/iOS 上优先使用 `Fluttertoast`，其他平台使用 `SnackBar`。这让页面只传入 `BuildContext + message`，不用关心平台差异。

`deriveHydropDeviceId()` 对稳定 seed 加命名空间后做 sha256，并截取前 32 位生成 `hydrop_` 前缀 ID。它避免保存原始硬件标识，同时保证同一 seed 可重复得到同一设备 ID。

`lib/core/utils/talker/talker.dart` 暴露全局 `Talker`。业务代码通过它记录网络、传输、发送、通知等关键事件；Riverpod 生命周期也接入同一日志系统。
