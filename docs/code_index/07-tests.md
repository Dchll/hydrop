# 测试代码在验证什么

项目 Agent 规范默认禁用执行测试命令；本页只说明测试代码覆盖的语义。

## application 测试

`test/application/discovery/discovery_controller_test.dart` 验证发现控制器的业务编排：收到合法 UDP payload 后会保存设备和地址；payload 没有地址时使用 UDP 源地址兜底；TTL 扫描会把过期广播地址标记不可达，并在没有可达地址时把设备标记离线。测试通过 fake timer/socket/repository 控制异步行为。

## core 测试

`test/core/theme/app_theme_test.dart` 验证浅色/深色主题使用生成颜色，并验证持久化主题枚举到 Flutter `ThemeMode` 的映射。

`test/core/utils/device_identity_test.dart` 验证设备 ID 哈希函数对同一 seed 是确定性的，并拒绝空 seed。

## data 布局和 repository 测试

`test/data/data_layout_test.dart` 验证 `lib/data` 只暴露 `local` 和 `remote` 两个顶层目录，防止数据层重新分散。

repository 测试使用内存数据库和 provider override，验证设备、地址、连接会话、消息 repository 的真实 Drift 读写语义：upsert、排序、状态更新、消息和附件组合、可恢复传输、会话状态等。

`test/data/repository/bing_wallpaper_repository_test.dart` 验证 Dio provider baseUrl、壁纸本地缓存命中、下载、删除旧壁纸、异常响应等行为。

## remote service 测试

`discovery_broadcast_service_test.dart` 验证广播 payload 序列化所有本机地址，并且按 IPv4 broadcast source 建 socket 和定时发送。

`discovery_payload_codec_test.dart` 验证合法 discovery hello payload 能带出网络元数据，非法 payload 不抛异常而是返回 null。

`discovery_socket_service_test.dart` 验证 UDP datagram 能被解码并回调 payload event。

`local_network_address_service_test.dart` 验证本机地址过滤、去重、Wi-Fi 元数据合并、广播地址推导、只选择 IPv4 广播源和 fallback 源。

## presentation widget 测试

`test/presentation/widgets/image_widget_test.dart` 验证 `ImageWidget` 对网络、data URI、asset、file path、空 URL 和错误态的选择逻辑。

`hd_container_test.dart`、`hd_glass_components_test.dart` 验证共享容器和兼容别名可以正常构建。

`glass_page_usage_test.dart` 验证页面使用项目共享视觉组件，避免主视觉骨架回退到临时实现。
