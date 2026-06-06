# 代码语义走读文档

本目录不是声明索引，而是按 Hydrop 的运行调用链解释代码：每一层负责什么、怎么做、向上游提供什么、依赖下游哪些能力。阅读顺序从启动入口开始，再到应用编排、数据层、网络协议、展示层、生成代码和测试。

## 建议阅读顺序

1. [启动与主调用链](00-call-chain.md)：从 `main()` 到页面、provider、repository、socket/database 的完整路径。
2. [入口、路由、core 基础设施](01-entry-core-routes.md)：应用启动、主题、本地化、反馈、常量和工具。
3. [application 应用编排层](02-application-layer.md)：发现、连接、聊天、文件传输、通知和页面状态如何被编排。
4. [data/local 本地数据层](03-data-local-layer.md)：Drift 表、DAO、Repository 和数据库生命周期。
5. [data/remote 网络与文件服务层](04-data-remote-layer.md)：Dio、UDP 发现、TCP frame、附件保存、断点续传元数据。
6. [presentation 展示层](05-presentation-layer.md)：页面和共享组件如何消费 application/provider 状态。
7. [生成代码、本地化和资源](06-generated-l10n-assets.md)：生成文件在项目中的作用，以及为什么不手改。
8. [测试代码在验证什么](07-tests.md)：每组测试覆盖的业务语义。
9. [逐文件语义地图](08-file-by-file-walkthrough.md)：按项目目录列出每个文件负责的事情和实现方式。

## 代码整体边界

- `presentation` 只负责渲染、交互入口和临时 UI 状态；真正的发现、连接、发送、保存、暂停等动作交给 application controller。
- `application` 是调用链中间层，把页面动作转换为 repository/service 调用，并处理生命周期、后台维护、进度、通知和错误流转。
- `data/local` 以 Drift 数据库为 Single Source of Truth，DAO 做 SQL/事务，Repository 做快照模型和业务口径。
- `data/remote` 封装 HTTP、UDP、TCP、文件系统和平台网络信息，不直接让页面访问。
- `core` 存放协议常量、主题、本地化格式化、短提示、设备 ID 哈希和日志入口。

## 覆盖说明

本次走读覆盖 `lib/`、`lib/gen/`、`lib/l10n/` 和 `test/` 下的 Dart/ARB 代码。生成文件按“由谁生成、提供什么 API、被谁消费”解释；手写文件按“做什么、怎么做、调用链位置”解释。
