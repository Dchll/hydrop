# 毕业论文文本维护稿

> 来源：`/Users/admin-and/Downloads/韩义勇毕业设计 2.docx`。
> 范围：摘要、正文第 1-7 章、参考文献，以及正文中的图题和表题；不包含封面、目录、致谢和附录正文。

# 摘要

随着多终端协同办公与移动学习场景的普及，用户对跨设备、低门槛、高效率文件传输的需求持续增长。传统云盘方案依赖外网与第三方服务器，蓝牙方案传输效率有限，且多平台系统之间存在交互割裂问题。针对上述痛点，本文围绕“基于 Flutter 的跨平台高速文件传输系统”开展阶段性研究与工程实现，目标是在统一技术栈下构建可跨 Android 与 Windows 运行的局域网文件传输应用。

本文设计并实现了一套基于 Flutter 的跨平台局域网高速文件传输系统，面向 Android、Windows 等终端，构建了设备发现、会话通信、文件传输、状态管理、本地持久化和界面展示一体化方案。系统采用 Flutter、Riverpod、AutoRoute 与 Drift的分层架构，网络层通过 UDP 广播完成局域网设备发现与在线维护，通过 TCP Socket 完成文本消息与文件数据传输；表现层提供工作台、收件箱、设置中心和设备信息页面，并支持主题切换、语言切换与重启恢复。系统实现了局域网环境下的设备发现、双向通信和文件收发功能，具备较好的跨平台适配性、可维护性和扩展能力。

**关键词：Flutter；跨平台；局域网传输；UDP 设备发现；TCP Socket；Riverpod**

# Abstract

With the increasing prevalence of multi-device collaborative office work and mobile learning scenarios, users have growing demand for cross-device, low-barrier, and high-efficiency file transfer. Traditional cloud storage solutions rely on external networks and third-party servers, while Bluetooth-based approaches suffer from limited transmission efficiency. In addition, cross-platform systems often present fragmented interaction experiences. To address these issues, this thesis presents the research and implementation of a Flutter-based cross-platform high-speed file transfer system, aiming to build a LAN file transfer application that can run on both Android and Windows under a unified technology stack.

The proposed system is designed and implemented as a Flutter-based cross-platform LAN high-speed file transfer solution for Android, Windows, and other terminals. It integrates device discovery, session communication, file transmission, state management, local persistence, and interface presentation into a unified architecture. The system adopts a layered design based on Flutter, Riverpod, AutoRoute, and Drift. At the network layer, UDP broadcasting is used to discover and maintain LAN devices, while TCP sockets are used to transmit text messages and file data. At the presentation layer, the system provides a workspace, inbox, settings center, and device information page, and supports theme switching, language switching, and state restoration after restart. The implemented system supports device discovery, two-way communication, and file transfer in LAN environments, and demonstrates good cross-platform compatibility, maintainability, and scalability.

**Key words: Flutter; cross-platform; LAN file transfer; UDP device discovery; TCP Socket; Riverpod**

# 1 绪论

## 1.1 研究背景

随着移动互联网和智能终端的普及，用户日常使用设备的种类和数量显著增加。智能手机、平板电脑、笔记本电脑和桌面工作站并行使用已成为学习、办公和生活中的常态。在这一多设备并行的使用模式下，文件在不同设备之间的流转需求频繁出现：学生需要将课堂拍摄的板书照片传输到电脑进行整理，办公人员需要将手机上收到的合同文件转发到桌面端进行编辑，设计师需要在平板和工作站之间同步设计素材。这些场景的共同特点是：设备处于同一局域网内，对传输速度有较高要求，且希望操作简便、无需依赖外部服务器。

目前市面上的跨设备文件传输方案主要分为三类。第一类是基于互联网中转的云存储方案（如百度网盘、Google Drive），其优点是跨网络可用，但缺点是传输速度受限于上行带宽，大文件传输耗时较长，且文件需经过第三方服务器，存在隐私泄露风险。第二类是基于蓝牙的近场传输方案，其优点是无需网络，但缺点是传输速率低（蓝牙5.0理论速率仅2Mbps），不适合大文件传输。第三类是厂商生态内的互联方案（如华为分享、苹果AirDrop），其优点是体验流畅，但缺点是仅限同品牌设备使用，跨品牌兼容性差。上述方案均无法同时满足"高速、跨平台、无需外网、操作简便"的需求。

局域网直传技术为上述问题提供了可行的解决思路。在同一局域网内，设备之间可以通过Wi-Fi获得远高于蓝牙的传输速率（802.11n理论速率可达150Mbps，802.11ac可达433Mbps），且无需经过互联网中转，传输延迟低、隐私性好。然而，现有的局域网传输工具（如FTP客户端、SMB共享）往往需要用户手动配置IP地址和端口，操作门槛较高，且缺乏现代化的用户界面。因此，设计一款兼具高性能和良好用户体验的跨平台局域网文件传输系统，具有重要的实用价值和工程意义。

## 1.2 研究目的与意义

本课题旨在设计并实现一款基于Flutter框架的跨平台局域网文件传输系统，覆盖设备发现、会话建立、文本消息通信、文件传输、状态展示和基础配置管理等核心能力，形成可扩展的工程架构。系统面向同一局域网内的多设备协作场景，支持Android、iOS、macOS、Windows和Linux平台，使用户无需安装额外软件或进行复杂配置即可实现设备间的快速文件流转。

本课题的研究意义体现在以下三个层面。在应用价值层面，系统通过局域网UDP广播实现设备自动发现，用户无需手动输入IP地址或扫描二维码，打开应用即可看到附近的在线设备，显著降低了使用门槛；文件传输采用TCP直连和流式分段传输，充分利用局域网带宽，大文件传输速度远优于云存储方案。在工程价值层面，系统验证了Flutter框架在网络密集型应用中的可行性，证明Flutter不仅能构建UI密集型应用，也能胜任Socket编程、文件流处理等底层网络任务，为Flutter在更多场景下的应用提供了工程参考。在实践价值层面，项目沉淀了一套完整的跨平台网络应用实现路径，包括UDP广播发现、TCP可靠传输、Riverpod状态管理、Drift本地持久化、响应式界面布局等技术方案的选型依据和实现细节，可为后续类似项目的开发提供参考。

## 1.3 研究内容与阶段目标

本文围绕跨平台局域网文件传输场景，完成了需求分析、总体架构设计、设备发现协议设计、文本会话与文件传输实现、状态管理与本地持久化、Android原生适配、界面设计以及系统测试等全部工作。具体研究内容包括以下几个方面。

（1）需求分析：通过调研现有跨设备传输方案的优缺点，明确系统在设备发现、会话通信、文件传输和配置管理四个维度的功能需求，以及性能、稳定性、可维护性和可扩展性四个维度的非功能需求。

（2）系统设计：采用UI层、Provider状态层、Repository业务层、Service/Core基础设施层的四层分离架构，设计发现模块、聊天模块、传输模块和配置模块的职责边界，定义UDP发现协议、TCP聊天协议和TCP传输协议的消息格式，规划响应式界面布局方案。

（3）系统实现：基于Flutter和Dart实现设备发现（UDP广播、节点表维护、超时剔除）、文本通信（TCP连接、hello握手、消息收发）、文件传输（传输头+二进制流协议、进度跟踪、断点续传）、状态管理（Riverpod Provider）、本地持久化（Drift数据库）、平台适配（Android原生桥接）等核心功能。

（4）系统测试：对系统进行功能测试、工程测试和性能/稳定性分析，验证设备发现、文本通信、文件收发、主题切换等核心流程的正确性，评估系统在不同网络环境下的稳定性和传输性能。

论文结构安排如下：第2章介绍相关技术，第3章分析系统功能与非功能需求，第4章给出系统总体设计与核心模块划分，第5章阐述系统实现，第6章给出测试结果与分析，第7章总结全文并展望后续工作。

# 2 相关技术介绍

## 2.1 Flutter 与 Dart

Flutter 是 Google 开源的跨平台 UI 开发框架，采用自绘引擎（Skia/Impeller）直接在 Canvas 上绘制界面，而非依赖平台原生控件，因此能够保证在 Android、iOS、macOS、Windows、Linux 和 Web 上获得像素级一致的渲染效果。Flutter 的核心架构由三层组成：最底层是用 C++ 实现的引擎层（Engine），负责图形渲染（Skia/Impeller）、文字排版（libtxt）、Dart 运行时和平台通道（Platform Channel）；中间层是框架层（Framework），提供 Widget、Element、RenderObject 三棵树的渲染机制，以及动画、手势、无障碍等基础能力；最上层是业务层，开发者通过组合 Widget 构建用户界面。Flutter 3.x 版本引入了 Impeller 渲染引擎作为默认选项，显著提升了着色器编译性能，消除了首次帧渲染时的卡顿问题。

Dart 是 Flutter 的开发语言，由 Google 开发，兼具静态类型和运行时灵活性。Dart 采用AOT（Ahead-of-Time）编译生成机器码以保证生产环境的运行性能，同时支持 JIT（Just-in-Time）编译以实现开发阶段的热重载（Hot Reload），使开发者在修改代码后无需重启应用即可看到界面变化。Dart 语言原生支持异步编程，通过 async/await 关键字和 Future、Stream 两种异步原语，能够优雅地处理网络请求、文件 I/O、数据库查询等耗时操作。在本系统中，UDP 广播监听、TCP Socket 通信、文件流传输等核心功能均依赖Dart 的异步流式处理能力，实现了设备发现与文件传输的非阻塞并发执行。

## 2.2 Riverpod 状态管理

Riverpod（版本 3.2.1）是 Flutter 生态中新一代的声明式状态管理框架，由 Remi Rousselet 开发，是 Provider 的演进版本。Riverpod 的核心设计理念是"不依赖 BuildContext"——传统 Provider 必须在 Widget 树内部通过 InheritedWidget 传递依赖，而 Riverpod 将 Provider 定义为全局的、类型安全的依赖容器，可以在 Widget 树外部（如 Repository、Controller）自由读取和监听状态。Riverpod 提供多种 Provider 类型：Provider（只读依赖）、StateProvider（可变状态）、NotifierProvider（带业务逻辑的可变状态）、AsyncNotifierProvider（异步业务逻辑）等。每个 Provider 都有独立的生命周期，支持自动销毁（autoDispose）和参数化（family），当所有监听者移除时自动释放资源，避免内存泄漏。

flutter_riverpod（版本 3.2.1）是 Riverpod 的 Flutter 集成层，提供 ProviderScope（依赖注入容器）、ConsumerWidget（可监听 Provider 的 Widget 基类）、ConsumerStatefulWidget 等组件。本系统在 main.dart 入口处通过 ProviderScope 包裹整个应用，配置 TalkerRiverpodObserver 监听所有 Provider 的创建、更新、销毁和失败事件。所有页面（HomePage、ChatPage、MinePage、SettingsPage）均继承自 ConsumerWidget，通过 ref.watch 声明式地消费状态，当被依赖的 Provider 发生变化时自动触发 Widget 重建。

riverpod_annotation（版本 4.0.2）提供 @riverpod、@Riverpod 等注解，riverpod_generator（版本 4.0.3）在 build_runner 执行期间扫描这些注解并生成对应的 Provider 代码。相比手动声明 Provider，代码生成方式具有编译时类型检查、自动依赖推导、减少模板代码等优势。本系统的 DiscoveryBroadcastController、MineRepository、MessageRepository、ConnectionSessionRepository 等核心类均采用 @riverpod 注解声明，生成的 Provider 支持自动 dispose 和依赖刷新。

## 2.3 AutoRoute 路由管理

auto_route（版本 11.1.0）是 Flutter 的声明式路由框架，通过 @RoutePage 注解和代码生成实现类型安全的路由导航。相比 Flutter 内置的 Navigator 2.0，auto_route 提供了更简洁的 API 和更强大的功能：支持嵌套路由（AdaptiveRoute、CupertinoRoute）、路由守卫（AutoRouteGuard）、深度链接（Deep Link）、路由拦截（AutoRedirectGuard）以及 ReplaceRoute（替换当前路由栈）等。本系统定义了 AppRouter（继承 RootStackRouter），管理 HomePage（设备列表）、ChatPage（会话消息）、MinePage（本机信息）、SettingsPage（设置）等页面路由，通过 AutoRouterConfig 配置路由表，MaterialApp.router 使用 AutoRouter 作为路由引擎。

auto_route_generator（版本 10.4.0）在 build_runner 执行期间扫描 @RoutePage 注解，自动生成路由适配器代码（*.gr.dart 文件），开发者无需手动维护路由表。生成的代码包含路由名称常量、参数解析、页面构建等逻辑，确保路由跳转时的类型安全——编译期即可发现参数类型不匹配等错误。

## 2.4 Drift 本地数据库

drift（版本 2.31.0，原名 Moor）是 Flutter/Dart 的类型安全响应式数据库框架，基于 SQLite 构建。drift 提供了声明式表定义（通过 Dart 类定义表结构）、类型安全的查询构建器（编译期检查 SQL 语法）、自动生成 DAO（Data Access Object）以及基于 Stream 的响应式查询——当数据库数据发生变化时，所有监听该查询的 Stream 会自动推送最新结果。本系统定义了 8 张数据表（DeviceItems、DeviceAddressItems、ConnectionSessionItems、SettingItems、MineItems、MessageItem、ChatSession、ChatMessage），通过 schemaVersion = 5 和四级迁移脚本（V1→V5）保证旧数据兼容。AppDataBase 类继承 _$AppDataBase（由 drift_dev 生成），管理数据库连接和迁移逻辑。

drift_flutter（版本 0.2.8）提供 driftDatabase 工具函数，自动根据平台选择数据库存储路径（Android 使用应用数据目录，iOS/macOS 使用 Application Support 目录，Windows 使用 AppData 目录），简化跨平台数据库初始化。本系统在 AppDataBase 构造时通过 driftDatabase(name: 'hydrop') 创建数据库实例，无需手动处理各平台的路径差异。drift_dev（版本 2.31.0）是 drift 的代码生成器，在 build_runner 执行期间根据表定义和 DAO 注解生成类型安全的查询代码、数据库适配器和迁移辅助类。生成的 _$AppDataBase、$MessageDaoMixin、_$ConnectionSessionDaoMixin 等类包含了完整的 CRUD 操作实现，开发者只需定义接口和少量业务逻辑。

## 2.5 网络通信

UDP（用户数据报协议）是一种无连接的传输层协议，适用于局域网内设备发现等对实时性要求高、容忍少量丢包的场景。本系统使用 dart:io 的 RawDatagramSocket 实现 UDP 广播（端口 18976），在同网段内定时发送设备公告报文，报文采用 JSON 格式，包含设备 ID、显示名称、协议版本、TCP 端口和能力列表等字段。TCP（传输控制协议）是一种面向连接的可靠传输协议，通过三次握手建立连接、确认应答和重传机制保证数据完整性。本系统使用 dart:io 的 Socket 类实现 TCP 文本消息收发和文件数据传输。文件传输采用"JSON 传输头 + 二进制流"的混合协议：传输头描述文件元信息（文件名、大小、MIME 类型、SHA-256 校验值），后续跟随分段二进制数据流，接收端通过 SHA-256 校验值验证文件完整性。这种"发现与传输分离"的架构使设备发现的实时性与文件传输的可靠性各得其所。

dio（版本 5.9.2）是 Dart 的类型安全 HTTP 客户端库，支持拦截器链、请求取消、进度回调、文件上传/下载、FormData 表单提交等功能。dio 5.x 版本引入了更简洁的 API 设计和更好的 null safety 支持。本系统使用 dio 处理 HTTP 请求场景（如文件元信息交换、配置同步等），通过拦截器统一添加请求头和错误处理逻辑。

## 2.6 数据序列化与不可变数据

freezed_annotation（版本 3.1.0）提供 @freezed、@Freezed 等注解，freezed（版本 3.2.5）在 build_runner 执行期间为被注解的 Dart 类自动生成 == 运算符、hashCode、toString、copyWith、toJson/fromJson 等方法。freezed 特别适合定义不可变数据模型（如 DiscoveryState、MineOverviewState），确保状态对象的不可变性和值语义。本系统的发现状态、设备信息、消息模型等均使用 @freezed 注解，生成的代码保证了状态比较的正确性和序列化的便捷性。

json_annotation（版本 4.11.0）提供 @JsonSerializable、@JsonKey 等注解，json_serializable（版本 6.11.3）在 build_runner 执行期间生成 JSON 序列化/反序列化代码。本系统的 UDP 广播报文、TCP 传输头、设备信息等数据结构均使用 @JsonSerializable 注解，生成的 toJson()/fromJson() 方法实现了 Dart 对象与 JSON 字符串之间的类型安全转换。

## 2.7 日志与可观测性

talker（版本 5.1.16）是 Dart/Flutter 的轻量级日志框架，支持多级日志（debug、info、warning、error、critical）、自定义日志输出器（TalkerObserver）、日志过滤和格式化。talker_flutter（版本 5.1.16）提供 Flutter 集成，支持在应用内显示日志面板。talker_riverpod_logger（版本 5.1.16）是 talker 与 Riverpod 的集成插件，通过 TalkerRiverpodObserver 自动记录所有 Provider 的创建、更新、销毁和失败事件，便于调试状态管理流程。本系统在应用入口初始化 Talker 实例，配置 TalkerRouteObserver 监听路由变化，并通过 TalkerRiverpodObserver 监控 Provider 生命周期。

## 2.8 平台能力插件

network_info_plus（版本 7.0.0）是 Flutter 官方维护的网络信息插件，支持获取 Wi-Fi SSID、BSSID、IP 地址、子网掩码、网关地址和广播地址等信息。本系统使用 NetworkInfo 类获取 Wi-Fi 网段信息，结合 dart:io 的 NetworkInterface.list() 枚举本机网卡地址，通过子网掩码计算广播地址，用于 UDP 广播报文的目标地址构建。

path_provider（版本 2.1.5）提供跨平台的文件系统路径获取能力，支持获取临时目录、应用文档目录、应用支持目录等。本系统使用该插件获取数据库文件存储路径和文件传输的临时缓存目录。share_plus（版本 12.0.2）提供跨平台的内容分享能力，支持分享文本、文件、链接等到系统分享面板。本系统使用 SharePlus.instance.shareFiles() 实现文件分享功能，用户可以选择将接收到的文件通过系统分享面板发送到其他应用。

file_picker（版本 11.0.2）提供跨平台的文件选择器，支持单选/多选文件、选择目录、过滤文件类型等。本系统使用 FilePicker.platform.pickFiles() 让用户选择要发送的文件，支持选择任意类型文件并获取文件路径和元信息。mobile_scanner（版本 7.2.0）是 Flutter 的二维码/条形码扫描插件，支持实时相机预览和多种码制识别。本系统使用 MobileScanner Widget 实现二维码扫描功能，用户可通过扫描对方设备显示的二维码快速建立连接。qr_flutter（版本 4.1.0）提供 QR 码生成能力，支持将文本数据编码为 QR 码并渲染为 Flutter Widget。本系统使用 QrImageView 生成包含设备连接信息的二维码，显示在设备详情页面，供对方扫描建立连接。

cached_network_image（版本 3.4.1）提供网络图片的缓存加载能力，支持内存缓存和磁盘缓存，自动处理图片加载状态（加载中、已完成、错误）。本系统使用该插件加载和缓存设备头像等网络图片，减少重复网络请求。crypto（版本 3.0.7）是 Dart 的加密哈希算法库，提供 MD5、SHA-1、SHA-256、HMAC 等算法实现。本系统使用 sha256 函数计算文件的 SHA-256 校验值，在文件传输完成后由接收端重新计算并比对，确保文件完整性。

## 2.9 代码生成工具链

本项目使用 build_runner（版本 2.14.1）作为统一的代码生成执行器，配合以下生成器使用：auto_route_generator 扫描 @RoutePage 注解生成路由适配器代码；drift_dev 扫描表定义和 DAO 注解生成类型安全的数据库查询代码；freezed 扫描 @freezed 注解生成不可变数据模型的 ==、copyWith、toJson/fromJson 等方法；json_serializable 扫描 @JsonSerializable 注解生成 JSON 序列化/反序列化代码；riverpod_generator 扫描 @riverpod 注解生成 Riverpod Provider 代码；flutter_gen_runner 扫描 assets 目录和 flutter_gen 配置生成类型安全的资源引用代码（图片、颜色等）。开发者执行 dart run build_runner build --delete-conflicting-outputs 命令后，所有生成器并行执行，一次性生成全部代码，确保各模块之间的类型安全和依赖一致性。

# 3 系统需求分析

## 3.1 功能需求

本系统功能需求按"设备发现、会话通信、文件传输、配置管理"四类进行定义，并以"输入—处理—输出—验收点"的结构化方式进行约束。以下分别对四类功能需求进行详细描述。

**图 31 系统功能需求分解图**

设备发现需求：输入为局域网内在线节点信息与主动探测指令。处理过程采用UDP广播报文（kind=probe/hello/beat）与节点表维护机制。系统启动后，本机周期性地向局域网广播包含设备ID、设备名称、TCP端口和能力列表的公告报文；同时监听其他设备的广播报文，解析后更新在线设备列表。节点表维护机制包括：收到新设备的广播报文时，将其添加到在线列表；收到已知设备的更新报文时，刷新其最后活跃时间；超过指定时间未收到某设备的报文时，将其标记为离线并从列表中移除。输出为可实时刷新的在线设备列表（含节点名称、主机地址、端口与最近活跃时间）。验收点为：应用启动后可接收并解析对端广播，执行探测后可更新列表，超时节点可被剔除。

会话通信需求：输入为目标节点与文本消息。处理过程采用TCP建链、hello握手、text消息收发与断链状态更新。当用户选择某个在线设备发起会话时，系统通过TCP协议与目标设备建立连接，连接成功后发送hello握手消息（包含本机设备ID和名称），对方回复hello确认后会话建立完成。文本消息采用JSON格式封装，包含消息ID、发送方标识、文本内容和时间戳。连接状态按idle→connecting→connected→failed→disconnected演进。输出为会话连接状态和时间序消息列表。验收点为：可在已发现节点间建立会话并完成双向文本收发，连接异常可反馈为失败状态。

文件传输需求：输入为待发送文件路径与目标节点。处理过程采用"传输头+二进制流"协议进行发送与接收。发送端先构造包含taskId、peerId、fileName、totalBytes等信息的JSON传输头，然后通过TCP连接以64KB为单位分段读取文件内容并发送。接收端先解析传输头获取文件元信息，再按序接收二进制数据并写入本地文件。任务状态按queued→connecting→sending/receiving→done→failed演进。输出为可视化任务记录（进度百分比、传输速率、预计剩余时间、错误信息、落盘路径）。验收点为：可完成文件发送与接收落盘，传输过程状态可持续更新。

配置管理需求：输入为主题模式、语言偏好及本机节点标识。处理过程由Provider触发状态变更并写入本地存储。主题设置支持浅色、深色和跟随系统三种模式，切换后立即生效并持久化；语言设置支持中文、英文和跟随系统三种选项，切换后界面文字立即更新；本机节点标识（设备ID）在首次启动时生成并持久化，后续启动时直接读取。输出为重启后可恢复的系统设置。验收点为：主题与语言切换即时生效，应用重启后保持上次设置。

## 3.2 非功能需求

非功能需求重点包含性能、稳定性、安全性、可维护性与可扩展性五个方面。

在性能方面，文件传输采用文件流分段读写而非整文件一次性加载，降低大文件场景下的内存峰值。每段读取大小控制在64KB以内，确保即使传输GB级文件，内存占用也能保持在较低水平。进度与速率由增量计算实时刷新，保障交互连续性。UDP广播采用合理的发送间隔（默认5秒），既保证设备发现的实时性，又避免过度占用网络带宽。

在稳定性方面，系统对网络异常、协议解析失败与连接中断设置了统一错误捕获与状态降级路径。UDP广播收发失败时，系统会记录错误日志并自动重试，不影响其他功能。TCP连接异常断开时，系统会更新连接状态并通知UI层，用户可以手动重新连接。文件传输过程中如果发生中断，系统会保存已传输的进度，支持断点续传。所有异常都会通过Talker日志库记录，便于开发调试和问题排查。

在安全性方面，系统当前版本采用局域网直传模式，文件不经过外部服务器，降低了数据泄露的风险。后续版本可考虑引入端到端加密（如AES-256）和传输完整性校验（如SHA-256哈希比对），进一步提升传输安全性。

在可维护性方面，项目采用UI层、Provider状态层、Repository业务层、Service/Core基础设施层分离设计，降低跨模块耦合，便于后续迭代。每个模块职责边界清晰，修改某一模块的实现不会影响其他模块。代码生成技术的使用减少了样板代码，提高了代码可读性。

在可扩展性方面，发现、聊天、传输均基于JSON字段与状态模型组织，具备协议字段扩展和能力叠加空间。例如，可以在发现协议的peer字段中添加新的能力标识，在传输协议的头部中添加校验信息，而不会破坏现有的解析逻辑。

# 4 系统设计

## 4.1 总体架构

系统采用UI层、Provider状态层、Repository业务层、Service/Core基础设施层的四层分离架构。该架构的核心设计思想是"关注点分离"——每一层只负责自己的职责，通过定义良好的接口与上下层通信，避免跨层直接依赖。

**图3-2 系统总体架构图**

UI层（表现层）负责页面渲染与用户交互，包括Home工作台、Inbox收件箱、Settings设置页以及设备详情、包信息等二级页面。UI层通过ConsumerWidget和ConsumerStatefulWidget消费Provider层暴露的状态数据，根据状态值渲染不同的UI状态（加载中、数据就绪、错误提示等）。UI层不直接访问网络或数据库，所有数据获取和业务逻辑均通过Provider层完成。

Provider层（状态层）通过DiscoveryHub、ChatHub、TransferHub三大核心Provider统一管理异步状态与生命周期。每个Hub Provider负责聚合对应Repository的输出，维护UI所需的状态快照，并处理用户操作到业务逻辑的转换。Provider层还负责Provider之间的依赖编排，确保状态更新能正确传播到所有订阅者。

Repository层（业务层）负责领域对象组装与状态转换。每个Repository封装一个独立的业务域：MineRepository管理本机设备信息，DiscoveryRepository管理在线设备列表，ChatRepository管理会话和消息，TransferRepository管理传输任务。Repository层将Service层的原始数据转换为UI层可用的状态对象，同时处理业务规则（如超时剔除、状态流转等）。

Service/Core层（基础设施层）负责Socket通信、数据库访问、网络地址枚举以及主题、本地化等公共能力。DiscoveryBroadcastService封装UDP广播的收发逻辑，ChatService封装TCP连接和消息收发逻辑，TransferService封装文件传输逻辑。AppDataBase封装Drift数据库的表定义和迁移逻辑。这一层提供最基础的技术能力，不包含业务逻辑。

该设计将界面变化与底层实现解耦，便于后续扩展新的传输协议、设备信息和页面模块，同时降低页面层对网络和存储细节的直接依赖。当需要新增功能模块时，只需在对应层添加代码，不影响其他层的稳定性。

## 4.2 核心模块设计

系统核心模块由发现模块、聊天模块、传输模块、配置模块构成，并通过统一状态对象衔接UI。以下分别描述各模块的职责边界和状态输出。

发现模块负责局域网节点在线感知，输出DiscoveryState（self、peers、lastProbeAt、lastEventAt等）。其职责边界是"节点存在性维护"，不直接处理会话消息。发现模块通过UDP广播发送和接收公告报文，维护在线设备列表，并在设备超时时将其标记为离线。

聊天模块负责TCP会话建立与文本消息收发，输出ChatState（links、messages、serverStatus）。其职责边界是"文本通道管理"，不处理文件内容传输。聊天模块通过TCP协议与目标设备建立连接，发送hello握手消息，然后在连接上收发JSON格式的文本消息。

传输模块负责文件收发任务与进度更新，输出TransferState（tasks、inboxPath、serverStatus）。其职责边界是"二进制文件流传输"，不处理设备发现。传输模块通过TCP协议与目标设备建立连接，发送包含文件元信息的传输头，然后以64KB为单位分段传输文件内容。

配置模块负责主题、语言与本机标识持久化，通过ThemeState、AppLocaleNotifier与本地存储服务完成状态恢复。其职责边界是"全局偏好管理"，不涉及网络通信或文件操作。配置模块在应用启动时从本地存储读取上次的配置，用户修改配置后立即写入存储。

通过上述边界划分，系统实现了"发现—通信—传输"链路协同，同时避免跨模块职责混杂。各模块之间通过Provider依赖注入进行协作，而非直接引用对方的实例，进一步降低了耦合度。

## 4.3 通信协议设计

通信协议按发现、聊天、传输三类定义，并采用"可读可扩展"的JSON/二进制混合方案。

发现协议基于UDP广播，报文结构为{kind, peer}，其中kind取值为probe（主动探测）、hello（上线公告）、beat（心跳维持）。peer字段包含id、name、chatPort、transferPort、app、version、platform等信息。设备上线时发送hello报文，运行期间周期性发送beat报文维持在线状态，收到probe报文时回复hello报文。

聊天协议基于TCP文本行，当前支持hello与text两类消息。hello消息在TCP连接建立后立即发送，包含本机设备ID和名称，用于会话握手。text消息包含消息id、发送方标识、文本内容与sentAt时间戳，以JSON格式通过TCP连接逐行发送。

传输协议基于TCP二进制流，采用"魔数HYD1 + 4字节大端长度 + JSON头部 + 文件体"格式。头部包含taskId、peerId、peerName、fileName、totalBytes等字段。接收端先读取魔数和长度字段，再解析JSON头部获取文件元信息，最后按序接收文件体并写入本地文件。头部长度设有上限校验，防止异常数据导致内存溢出。

## 4.4 界面设计

界面层采用"导航壳+功能页"设计，主壳由Home、Inbox、Settings三个一级页面组成，并根据屏幕宽度执行响应式切换。窄屏模式下使用底部导航栏组织主入口，宽屏模式下切换为侧边导航栏。

工作台页面在宽屏下采用"设备列表+会话区"双栏布局，在窄屏下采用分步进入会话的单栏布局。设备列表展示附近在线设备的名称、状态和快捷操作按钮，用户点击设备后进入对应的聊天或传输界面。

收件箱页面在宽屏下并列展示传输与消息面板，在窄屏下改为纵向堆叠。传输面板展示当前进行中的传输任务列表（含进度、速率、状态），消息面板展示最近的聊天记录摘要。

设置页承担主题、语言与诊断信息入口，详情页用于设备信息、包信息和关于信息展示。整体界面采用扁平极简设计风格，采用纯色背景、直角边框和清晰的文字层级，遵循Material 3设计规范。

上述设计保证了Android手机与桌面端在信息密度和交互路径上的一致性与可用性。

# 5 系统实现

## 5.1 启动与初始化实现

应用入口采用“统一初始化 + 全局异常兜底”的启动流程。主函数在 runZonedGuarded 中执行：首先调用 WidgetsFlutterBinding.ensureInitialized() 完成 Flutter 绑定；随后注册 FlutterError.onError 与 PlatformDispatcher.instance.onError 两级异常处理；再初始化 Hive 存储服务并打开应用唯一业务 box；最后通过 ProviderScope 挂载应用并注入全局 Provider 观察器。该流程确保了启动期异常可记录、存储可用、状态体系可正常工作。

在应用根部，启动阶段通过监听 chat、transfer、discovery 三类 Hub Provider 完成网络能力预热，使页面进入后可以直接消费稳定的异步状态。

**图5-1 应用启动初始化流程**

void main() {

runApp(

ProviderScope(

observers: [

TalkerRiverpodObserver(

settings: TalkerRiverpodLoggerSettings(

enabled: true,

printStateFullData: false,

printProviderAdded: true,

printProviderUpdated: true,

printProviderDisposed: true,

printProviderFailed: true,

),

talker: talker,

),

],

child: MainApp(),

),

);

talker.debug("init end");

}

class MainApp extends ConsumerWidget {

MainApp({super.key});

final _appRouter = AppRouter();

final talker = Talker();

@override

Widget build(BuildContext context, WidgetRef ref) {

ref.watch(discoveryBroadcastControllerProvider);

final themeMode = ref

.watch(settingsProvider)

.maybeWhen(

data: (settings) => settings.themeMode.materialThemeMode,

orElse: () => ThemeMode.system,

);

return MaterialApp.router(

theme: AppTheme.light(),

darkTheme: AppTheme.dark(),

themeMode: themeMode,

routerConfig: _appRouter.config(

navigatorObservers: () => [TalkerRouteObserver(talker)],

),

);

}

}

## 5.2 设备发现实现

系统采用 UDP 广播实现局域网内设备自动发现。应用启动后，运行时控制器首先初始化本机设备信息，生成或读取本机唯一设备 ID 和显示名称，然后启动设备发现控制器。设备发现控制器同时启动 UDP 广播发送服务和 UDP 广播监听服务，使本机既能向局域网声明自身存在，也能接收其他设备的发现报文。

在广播发送阶段，系统通过 NetworkInterface.list() 枚举本机网络接口，并结合 network_info_plus 获取 Wi-Fi 的 IP 地址、子网掩码、网关和广播地址等信息。系统会过滤回环地址、链路本地地址、组播地址以及常见虚拟网卡，保留可用于局域网通信的真实网络地址。对于每一个可用 IPv4 地址，系统创建 UDP Socket，并开启广播能力。若能获取到广播地址，则优先向该地址发送广播；否则使用 255.255.255.255 作为兜底广播地址。

广播报文采用 JSON 格式，类型为 hydrop.discovery.hello，协议版本为 1。报文中包含本机设备 ID、显示名称、TCP 传输端口、设备能力列表、随机 nonce、发送时间以及本机可用地址列表。设备能力列表用于说明当前设备支持文本、图片、视频、文件传输和测速等能力。系统启动广播后会立即发送一次发现报文，并按照固定间隔周期性广播，当前间隔为 10 秒。

在广播接收阶段，系统在 UDP 发现端口 39175 上监听来自局域网的发现报文。收到数据包后，系统首先解析 JSON 内容，并校验报文类型、协议版本、设备 ID、显示名称、TCP 端口和地址列表等字段是否合法。若报文格式不符合要求，则直接丢弃。若报文中的设备 ID 与本机设备 ID 相同，说明该报文是本机广播被系统接收，也会被过滤。为了避免重复处理同一轮广播，系统还会根据设备 ID 和 nonce 进行去重。

通过校验后，系统将远端设备写入本地设备表，并把设备状态标记为局域网可用。随后系统将报文中的地址列表写入设备地址表，记录远端设备 IP、端口、网卡名称、子网掩码、网关、广播地址、网络签名、最近发现时间和可达状态。如果报文没有携带地址列表，系统会使用 UDP 数据包来源 IP 作为候选地址，保证发现流程具备兜底能力。

设备发现完成后，系统会触发轻量级 TCP 测速逻辑。测速模块会选择候选地址中排序靠前的若干地址进行连接测试，通过 TCP 探测帧测量延迟和吞吐速度，并将测速结果回写到设备地址表和设备表。设备列表展示时，会优先展示在线设备，并根据平均传输速度、延迟和最近发现时间进行排序，从而帮助系统选择更合适的连接地址。

为了维护设备在线状态，系统设置了发现超时机制。设备地址表中通过 lastSeenAt 记录最近一次收到该设备广播的时间。后台定时任务每 3 秒扫描一次已发现地址，如果某个广播来源超过 12 秒没有再次出现，则将该地址标记为不可达，并记录失败原因。如果某台设备已经没有任何可达地址，系统会将该设备状态更新为断开。这样既能保留历史设备记录，又能及时反映局域网设备上下线变化。

此外，系统还根据应用生命周期对发现服务进行调度。应用在前台运行时保持连续广播和监听；进入后台后停止持续广播与监听，并按照较低频率开启短时间维护窗口，以减少资源占用。该设计兼顾了发现实时性、移动端能耗控制和跨平台运行稳定性。。

final discoveryBroadcastControllerProvider =

Provider<DiscoveryBroadcastController>((ref) {

final controller = DiscoveryBroadcastController(

mineRepository: ref.watch(mineRepositoryProvider),

broadcastService: DiscoveryBroadcastService(

localNetworkAddressService: ref.watch(

localNetworkAddressServiceProvider,

),

),

);

unawaited(

controller.start().catchError((Object error, StackTrace stackTrace) {

// Best-effort LAN discovery should not block app startup.

}),

);

ref.onDispose(controller.stop);

return controller;

});

class DiscoveryBroadcastController {

DiscoveryBroadcastController({

required MineRepository mineRepository,

required DiscoveryBroadcastService broadcastService,

}) : _mineRepository = mineRepository,

_broadcastService = broadcastService;

final MineRepository _mineRepository;

final DiscoveryBroadcastService _broadcastService;

Future<void>? _startFuture;

Future<void> start() {

return _startFuture ??= _startInternal();

}

Future<void> stop() async {

_startFuture = null;

await _broadcastService.stop();

}

Future<void> _startInternal() async {

final hostName = _defaultHostName();

final profile = await _mineRepository.ensureMineProfile(

displayName: hostName,

stableSeed: hostName,

);

await _broadcastService.start(

deviceId: profile.deviceId,

displayName: profile.displayName,

tcpPort: discoveryTransferPort,

capabilities: discoveryBroadcastCapabilities,

);

}

}

class DiscoveryBroadcastAnnouncement {

const DiscoveryBroadcastAnnouncement({

required this.deviceId,

required this.displayName,

required this.protocolVersion,

required this.tcpPort,

required this.capabilities,

required this.nonce,

required this.sentAt,

required this.addresses,

});

final String deviceId;

final String displayName;

final int protocolVersion;

final int tcpPort;

final List<String> capabilities;

final String nonce;

final DateTime sentAt;

final List<DiscoveryBroadcastAnnouncementAddress> addresses;

Map<String, Object?> toJson() {

return {

'type': discoveryBroadcastPayloadType,

'protocolVersion': protocolVersion,

'deviceId': deviceId,

'displayName': displayName,

'tcpPort': tcpPort,

'capabilities': capabilities,

'nonce': nonce,

'sentAt': sentAt.millisecondsSinceEpoch,

'addresses': addresses

.map((address) => address.toJson())

.toList(growable: false),

};

}

}

class DiscoveryBroadcastService {

DiscoveryBroadcastService({

LocalNetworkAddressService? localNetworkAddressService,

DiscoveryBroadcastSocketFactory? socketFactory,

DiscoveryBroadcastTimerFactory? timerFactory,

DateTime Function()? now,

String Function()? nonceGenerator,

}) : _localNetworkAddressService =

localNetworkAddressService ?? const LocalNetworkAddressService(),

_socketFactory = socketFactory ?? _defaultSocketFactory,

_timerFactory = timerFactory ?? _defaultTimerFactory,

_now = now ?? DateTime.now,

_nonceGenerator = nonceGenerator ?? _defaultNonceGenerator;

final LocalNetworkAddressService _localNetworkAddressService;

final DiscoveryBroadcastSocketFactory _socketFactory;

final DiscoveryBroadcastTimerFactory _timerFactory;

final DateTime Function() _now;

final String Function() _nonceGenerator;

final List<_ManagedDiscoveryBroadcastSocket> _sockets = [];

DiscoveryBroadcastTimerHandle? _timerHandle;

_BroadcastSession? _session;

bool _broadcasting = false;

bool get isRunning => _timerHandle != null;

Future<void> start({

required String deviceId,

required String displayName,

required int tcpPort,

required Iterable<String> capabilities,

}) async {

await stop();

_session = _BroadcastSession(

deviceId: deviceId,

displayName: displayName,

tcpPort: tcpPort,

capabilities: List.unmodifiable(capabilities),

);

await _openSockets();

if (_sockets.isEmpty) {

return;

}

await _broadcastOnce();

_timerHandle = _timerFactory(discoveryBroadcastInterval, _broadcastOnce);

}

Future<void> _broadcastOnce() async {

if (_session == null || _sockets.isEmpty || _broadcasting) {

return;

}

_broadcasting = true;

try {

final localAddresses = await _localNetworkAddressService

.listLocalNetworkAddresses();

final announcement = DiscoveryBroadcastAnnouncement(

deviceId: _session!.deviceId,

displayName: _session!.displayName,

protocolVersion: discoveryBroadcastProtocolVersion,

tcpPort: _session!.tcpPort,

capabilities: _session!.capabilities,

nonce: _nonceGenerator(),

sentAt: _now(),

addresses: localAddresses

.map(

(address) => DiscoveryBroadcastAnnouncementAddress(

ip: address.address,

version: address.isIpv4 ? 'ipv4' : 'ipv6',

interfaceName: address.interfaceName,

subnetMask: address.subnetMask,

gatewayAddress: address.gatewayAddress,

broadcastAddress: address.broadcastAddress,

networkSignature: address.networkSignature,

isWifiLike: address.isWifiLike,

),

)

.toList(growable: false),

);

final payload = utf8.encode(jsonEncode(announcement.toJson()));

for (final socket in _sockets) {

socket.send(

payload,

socket.source.broadcastAddress,

discoveryBroadcastPort,

);

}

} finally {

_broadcasting = false;

}

}

}

## 5.3 本机网络地址枚举

系统在局域网发现与设备信息展示之前，首先需要获取本机可用于通信的网络地址。为此，项目封装了 LocalNetworkAddressService，通过 NetworkInterface.list() 枚举本机网卡地址，并结合 network_info_plus 读取 Wi-Fi 网段的子网掩码、网关地址和广播地址。服务在处理过程中会过滤回环接口、链路本地地址和多播地址，同时对重复地址进行去重，最终输出可供界面展示和广播发送使用的地址集合。为了便于后续发现模块使用，系统还进一步从这些地址中筛选出 IPv4 广播源，并在没有可用地址时提供默认广播目标。该实现保证了设备发现不是依赖固定地址，而是能够根据当前机器的真实网络环境动态适配。

import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:hydrop/core/constants/discovery_constants.dart';

import 'package:network_info_plus/network_info_plus.dart';

final localNetworkAddressServiceProvider = Provider<LocalNetworkAddressService>(

(ref) {

return const LocalNetworkAddressService();

},

);

class LocalNetworkAddressService {

const LocalNetworkAddressService({

Future<List<LocalInterfaceSnapshot>> Function()? interfaceSnapshotProvider,

Future<LocalNetworkMetadataSnapshot> Function()? networkMetadataProvider,

}) : _interfaceSnapshotProvider =

interfaceSnapshotProvider ?? _defaultInterfaceSnapshotProvider,

_networkMetadataProvider =

networkMetadataProvider ?? _defaultNetworkMetadataProvider;

final Future<List<LocalInterfaceSnapshot>> Function()

_interfaceSnapshotProvider;

final Future<LocalNetworkMetadataSnapshot> Function()

_networkMetadataProvider;

Future<List<LocalNetworkAddressInfo>> listLocalNetworkAddresses() async {

final interfaces = await _interfaceSnapshotProvider();

final metadata = await _networkMetadataProvider();

final entries = <LocalNetworkAddressInfo>[];

final seen = <String>{};

for (final interface in interfaces) {

if (_shouldIgnoreInterface(interface.name)) {

continue;

}

for (final address in interface.addresses) {

if (_shouldIgnoreAddress(address)) {

continue;

}

final key = '${interface.name}|${address.address}';

if (!seen.add(key)) {

continue;

}

final isWifiLike = _isWifiLike(metadata, address);

final subnetMask = isWifiLike ? metadata.wifiSubnetMask : null;

final gatewayAddress = isWifiLike ? metadata.wifiGatewayAddress : null;

final broadcastAddress = isWifiLike

? metadata.wifiBroadcastAddress ??

_deriveBroadcastAddress(address.address, subnetMask)

: null;

entries.add(

LocalNetworkAddressInfo(

interfaceName: interface.name,

address: address.address,

versionLabel: address.isIpv4 ? 'IPv4' : 'IPv6',

subnetMask: subnetMask,

gatewayAddress: gatewayAddress,

broadcastAddress: broadcastAddress,

networkSignature: _deriveNetworkSignature(

interfaceName: interface.name,

ipVersion: address.isIpv4 ? 'ipv4' : 'ipv6',

subnetMask: subnetMask,

gatewayAddress: gatewayAddress,

broadcastAddress: broadcastAddress,

),

isWifiLike: isWifiLike,

),

);

}

}

entries.sort((left, right) {

final versionCompare = (right.isIpv4 ? 1 : 0).compareTo(

left.isIpv4 ? 1 : 0,

);

if (versionCompare != 0) {

return versionCompare;

}

final interfaceCompare = left.interfaceName.compareTo(

right.interfaceName,

);

if (interfaceCompare != 0) {

return interfaceCompare;

}

return left.address.compareTo(right.address);

});

return List.unmodifiable(entries);

}

Future<List<LocalBroadcastSource>> listBroadcastSources() async {

final addresses = await listLocalNetworkAddresses();

final entries = <LocalBroadcastSource>[];

for (final address in addresses) {

if (!address.isIpv4) {

continue;

}

entries.add(

LocalBroadcastSource(

interfaceName: address.interfaceName,

address: address.address,

broadcastAddress:

address.broadcastAddress ??

_deriveBroadcastAddress(address.address, address.subnetMask) ??

discoveryBroadcastFallbackTargetAddress,

isIpv4: true,

subnetMask: address.subnetMask,

gatewayAddress: address.gatewayAddress,

networkSignature: address.networkSignature,

isWifiLike: address.isWifiLike,

),

);

}

if (entries.isEmpty) {

return List.unmodifiable([

LocalBroadcastSource(

interfaceName: 'default',

address: InternetAddress.anyIPv4.address,

broadcastAddress: discoveryBroadcastFallbackTargetAddress,

isIpv4: true,

subnetMask: null,

gatewayAddress: null,

networkSignature: 'default/ipv4',

isWifiLike: false,

),

]);

}

entries.sort((left, right) {

final interfaceCompare = left.interfaceName.compareTo(

right.interfaceName,

);

if (interfaceCompare != 0) {

return interfaceCompare;

}

return left.address.compareTo(right.address);

});

return List.unmodifiable(entries);

}

}

class LocalNetworkMetadataSnapshot {

const LocalNetworkMetadataSnapshot({

this.wifiIPv4Address,

this.wifiIPv6Address,

this.wifiSubnetMask,

this.wifiGatewayAddress,

this.wifiBroadcastAddress,

this.wifiName,

});

final String? wifiIPv4Address;

final String? wifiIPv6Address;

final String? wifiSubnetMask;

final String? wifiGatewayAddress;

final String? wifiBroadcastAddress;

final String? wifiName;

}

class LocalInterfaceSnapshot {

const LocalInterfaceSnapshot({required this.name, required this.addresses});

final String name;

final List<LocalAddressSnapshot> addresses;

}

class LocalAddressSnapshot {

const LocalAddressSnapshot({

required this.address,

required this.addressType,

this.isLoopback = false,

this.isLinkLocal = false,

this.isMulticast = false,

});

final String address;

final InternetAddressType addressType;

final bool isLoopback;

final bool isLinkLocal;

final bool isMulticast;

bool get isIpv4 => addressType == InternetAddressType.IPv4;

}

class LocalNetworkAddressInfo {

const LocalNetworkAddressInfo({

required this.interfaceName,

required this.address,

required this.versionLabel,

this.subnetMask,

this.gatewayAddress,

this.broadcastAddress,

this.networkSignature,

this.isWifiLike = false,

});

final String interfaceName;

final String address;

final String versionLabel;

final String? subnetMask;

final String? gatewayAddress;

final String? broadcastAddress;

final String? networkSignature;

final bool isWifiLike;

bool get isIpv4 => versionLabel == 'IPv4';

}

class LocalBroadcastSource {

const LocalBroadcastSource({

required this.interfaceName,

required this.address,

required this.broadcastAddress,

required this.isIpv4,

this.subnetMask,

this.gatewayAddress,

this.networkSignature,

this.isWifiLike = false,

});

final String interfaceName;

final String address;

final String broadcastAddress;

final bool isIpv4;

final String? subnetMask;

final String? gatewayAddress;

final String? networkSignature;

final bool isWifiLike;

}

## 5.4 广播发现与在线公告实现

在获取本机可用网络地址之后，系统进一步通过 UDP 广播实现局域网设备发现。应用启动时，DiscoveryBroadcastController 会先确保本机 Mine Profile 已创建，再把设备 ID、显示名称、TCP 端口和能力列表交给 DiscoveryBroadcastService，由服务负责打开可用广播源并定时发送公告报文。公告报文中不仅包含设备的基础身份信息，还携带本机全部局域网地址、接口名称、广播地址和网络签名，以便其他设备进行识别和后续连接。这样设计的好处是发现逻辑与界面逻辑完全解耦，页面只需要消费发现结果，而不必直接处理 socket、定时器和网络报文细节。

import 'dart:async';

import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:hydrop/core/constants/discovery_constants.dart';

import 'package:hydrop/data/local/repository/mine_repository.dart';

import 'package:hydrop/data/remote/service/discovery_broadcast_service.dart';

import 'package:hydrop/data/remote/service/local_network_address_service.dart';

final discoveryBroadcastControllerProvider =

Provider<DiscoveryBroadcastController>((ref) {

final controller = DiscoveryBroadcastController(

mineRepository: ref.watch(mineRepositoryProvider),

broadcastService: DiscoveryBroadcastService(

localNetworkAddressService: ref.watch(

localNetworkAddressServiceProvider,

),

),

);

unawaited(

controller.start().catchError((Object error, StackTrace stackTrace) {

// Best-effort LAN discovery should not block app startup.

}),

);

ref.onDispose(controller.stop);

return controller;

});

class DiscoveryBroadcastController {

DiscoveryBroadcastController({

required MineRepository mineRepository,

required DiscoveryBroadcastService broadcastService,

}) : _mineRepository = mineRepository,

_broadcastService = broadcastService;

final MineRepository _mineRepository;

final DiscoveryBroadcastService _broadcastService;

Future<void>? _startFuture;

Future<void> start() {

return _startFuture ??= _startInternal();

}

Future<void> stop() async {

_startFuture = null;

await _broadcastService.stop();

}

Future<void> _startInternal() async {

final hostName = _defaultHostName();

final profile = await _mineRepository.ensureMineProfile(

displayName: hostName,

stableSeed: hostName,

);

await _broadcastService.start(

deviceId: profile.deviceId,

displayName: profile.displayName,

tcpPort: discoveryTransferPort,

capabilities: discoveryBroadcastCapabilities,

);

}

}

String _defaultHostName() {

final hostName = Platform.localHostname.trim();

if (hostName.isNotEmpty) {

return hostName;

}

return '${Platform.operatingSystem}-${Platform.numberOfProcessors}';

}

## 5.5 本机设备信息与 Mine 页面实现

Mine 页负责展示本机设备身份和当前网络环境。系统在页面加载时通过 mineOverviewProvider 先确保本机 Mine Profile 存在，再读取显示名称、设备 ID、主机名以及本机可用 IP 列表，并统一封装成 MineOverviewState 提供给界面。设备 ID 的生成由 MineRepository 统一完成，底层通过 MineDao 将固定主键的记录写入本地数据库，使应用重启后仍能保持同一设备身份。页面层在 MinePage 中将这些信息分为“设备资料”和“本机网络”两个卡片展示，同时提供刷新按钮和跳转聊天页入口，从而把设备信息查看、局域网信息诊断和页面导航整合到同一界面中。

// lib/application/mine/mine_page_state.dart

final mineOverviewProvider = FutureProvider<MineOverviewState>((ref) async {

final repository = ref.watch(mineRepositoryProvider);

final networkAddressService = ref.watch(localNetworkAddressServiceProvider);

final hostName = _defaultHostName();

final profile = await repository.ensureMineProfile(

displayName: hostName,

stableSeed: hostName,

);

final localAddresses = await networkAddressService

.listLocalNetworkAddresses();

return MineOverviewState(

displayName: profile.displayName,

deviceId: profile.deviceId,

hostName: hostName,

localAddresses: localAddresses,

);

});

class MineOverviewState {

const MineOverviewState({

required this.displayName,

required this.deviceId,

required this.hostName,

required this.localAddresses,

});

final String displayName;

final String deviceId;

final String hostName;

final List<LocalNetworkAddressInfo> localAddresses;

}

// lib/data/local/repository/mine_repository.dart

class MineRepository {

const MineRepository(this._mineDao);

final MineDao _mineDao;

Future<MineProfile?> getMineProfile() async {

final row = await _mineDao.getMine();

return row == null ? null : MineProfile.fromRow(row);

}

Future<String> initializeMineProfile({

required String displayName,

required String stableSeed,

}) async {

final deviceId = deriveHydropDeviceId(stableSeed);

await _mineDao.saveMine(displayName: displayName, deviceId: deviceId);

return deviceId;

}

Future<MineProfile> ensureMineProfile({

required String displayName,

required String stableSeed,

}) async {

final existing = await getMineProfile();

if (existing != null) {

return existing;

}

await initializeMineProfile(

displayName: displayName,

stableSeed: stableSeed,

);

final created = await getMineProfile();

if (created == null) {

throw StateError('Mine profile was not created successfully.');

}

return created;

}

}

// lib/data/local/dao/mine_dao.dart

@DriftAccessor(tables: [MineItems])

class MineDao extends DatabaseAccessor<AppDataBase> with _$MineDaoMixin {

MineDao(super.db);

static const _mineRowId = 1;

Future<MineItem?> getMine() {

final query = select(mineItems)

..where((table) => table.id.equals(_mineRowId));

return query.getSingleOrNull();

}

Future<int> saveMine({

required String displayName,

required String deviceId,

}) {

return into(mineItems).insertOnConflictUpdate(

MineItemsCompanion.insert(

id: const Value(_mineRowId),

displayName: displayName,

deviceId: deviceId,

),

);

}

}

// lib/presentation/pages/mine/mine_page.dart

@RoutePage()

class MinePage extends ConsumerWidget {

const MinePage({super.key});

@override

Widget build(BuildContext context, WidgetRef ref) {

final overview = ref.watch(mineOverviewProvider);

return HdPageScaffold(

child: Column(

children: [

HdHeader(

title: 'Mine',

subtitle: 'Device profile, local addresses and diagnostics',

trailing: IconButton(

onPressed: () => ref.invalidate(mineOverviewProvider),

icon: const Icon(Icons.refresh_rounded),

tooltip: 'Refresh local info',

),

),

const SizedBox(height: 18),

Expanded(

child: overview.when(

data: (state) => _MineOverviewBody(state: state),

error: (error, stackTrace) => HdPanel(

child: Column(

crossAxisAlignment: CrossAxisAlignment.start,

mainAxisSize: MainAxisSize.min,

children: [

const Text('Unable to load local device information'),

const SizedBox(height: 12),

Text(error.toString()),

const SizedBox(height: 16),

FilledButton(

onPressed: () => ref.invalidate(mineOverviewProvider),

child: const Text('Retry'),

),

],

),

),

loading: () => const HdPanel(

child: SizedBox(

height: 220,

child: Center(child: CircularProgressIndicator()),

),

),

),

),

const SizedBox(height: 18),

HdDock(

child: Row(

children: [

Expanded(

child: FilledButton.icon(

onPressed: () {

context.navigateTo(const ChatRoute());

},

icon: const Icon(Icons.chat_bubble_outline_rounded),

label: const Text('Open chat'),

),

),

],

),

),

],

),

);

}

}

## 5.6 页面布局与通用图片组件实现

系统界面采用路由壳和共享玻璃组件统一组织页面布局。首页 HomePage 负责展示附近设备列表与快捷操作，Chat 页负责承载会话输入和消息展示区域，Mine 页负责展示设备资料和本机网络信息，三者共同构成应用的主导航结构。为了提升界面的复用性和资源兼容性，项目还封装了 ImageWidget，能够自动识别网络地址、data: 图片、本地文件路径和 asset 路径，并根据输入类型选择合适的 ImageProvider。这一实现减少了页面层对图片来源的手动判断，也让背景图、头像和资源图在不同平台上能够保持一致的加载体验。

// lib/routes/app_router.dart

@AutoRouterConfig()

class AppRouter extends RootStackRouter {

@override

List<AutoRoute> get routes => [

AutoRoute(

page: AppRoute.page,

path: '/app',

initial: true,

keepHistory: true,

children: [

AutoRoute(page: HomeRoute.page, initial: true, path: 'home'),

AutoRoute(page: MineRoute.page, path: 'mine'),

],

),

AutoRoute(page: ChatRoute.page, path: '/chat'),

];

}

// lib/presentation/pages/home/home_page.dart

@RoutePage()

class HomePage extends ConsumerWidget {

const HomePage({super.key});

@override

Widget build(BuildContext context, WidgetRef ref) {

final padding = MediaQuery.paddingOf(context);

return HdPageScaffold(

background: const _Background(),

child: Stack(

children: [

Column(

children: [

const HdHeader(

title: 'Home',

subtitle: 'Nearby devices and quick actions',

),

const SizedBox(height: 18),

Expanded(

child: Builder(

builder: (context) {

final devices = ref.watch(deviceListProvider);

return devices.when(

data: (deviceItems) {

if (deviceItems.isEmpty) {

return const HdPanel(

child: Center(

child: Text('No devices discovered yet'),

),

);

}

return ListView.separated(

padding: EdgeInsets.only(

bottom: 110 + padding.bottom,

),

itemCount: deviceItems.length,

separatorBuilder: (context, index) =>

const SizedBox(height: 12),

itemBuilder: (context, index) {

final deviceItem = deviceItems[index];

return HdPanel(

child: _DeviceTile(deviceItem: deviceItem),

);

},

);

},

error: (error, stackTrace) =>

HdPanel(child: Text(error.toString())),

loading: () => const HdPanel(

child: SizedBox(

height: 160,

child: Center(child: CircularProgressIndicator()),

),

),

);

},

),

),

],

),

Padding(

padding: EdgeInsets.only(bottom: padding.bottom + 8),

child: HdDock(

child: Row(

children: [

Expanded(

child: FilledButton.icon(

onPressed: () async {

final uniqueId = DateTime.now().microsecondsSinceEpoch

.toString();

await ref

.read(deviceRepositoryProvider)

.saveDiscoveredDevice(

displayName: 'test',

deviceId: 'test-$uniqueId',

);

},

icon: const Icon(Icons.add_link_rounded),

label: const Text('Add device'),

),

),

],

),

),

),

],

),

);

}

}

// lib/presentation/pages/chat/chat_page.dart

@RoutePage()

class ChatPage extends StatelessWidget {

const ChatPage({super.key});

@override

Widget build(BuildContext context) {

return HdPageScaffold(

child: Column(

children: [

const HdHeader(

title: 'Chat',

subtitle: 'Conversation timeline and quick actions',

),

const SizedBox(height: 18),

const Expanded(

child: HdPanel(

child: Center(

child: Text(‘Chat history will live inside this panel’),,

),

),

),

const SizedBox(height: 18),

HdDock(

child: Row(

children: [

Expanded(

child: TextField(

decoration: InputDecoration(

hintText: 'Type a message',

filled: true,

fillColor: Theme.of(

context,

).colorScheme.surface.withValues(alpha: 0.4),

border: OutlineInputBorder(

borderRadius: BorderRadius.circular(18),

borderSide: BorderSide.none,

),

contentPadding: const EdgeInsets.symmetric(

horizontal: 16,

vertical: 12,

),

),

),

),

const SizedBox(width: 12),

FilledButton(onPressed: () {}, child: const Text('Send')),

],

),

),

],

),

);

}

}

// lib/presentation/widgets/image_widget.dart

@override

Widget build(BuildContext context) {

final source = url.trim();

if (source.isEmpty) {

return _buildError(

context,

ArgumentError.value(url, 'url', 'Image url cannot be empty.'),

);

}

final memoryBytes = _tryParseDataImage(source);

if (memoryBytes != null) {

return _buildImage(MemoryImage(memoryBytes, scale: scale));

}

final networkUrl = _networkUrl(source);

if (networkUrl != null) {

return _buildImage(

NetworkImage(networkUrl, scale: scale, headers: headers),

);

}

if (_isFileSource(source)) {

final provider = imageWidgetFileProvider(source, scale: scale);

if (provider != null) {

return _buildImage(provider);

}

return _buildError(

context,

UnsupportedError('File images are not supported on this platform.'),

);

}

final assetName = _assetName(source);

if (assetName != null) {

return _buildImage(

ExactAssetImage(

assetName,

scale: scale,

bundle: bundle,

package: package,

),

);

}

return _buildError(

context,

ArgumentError.value(url, 'url', 'Unsupported image url type.'),

);

}

## 5.7 数据库存储与消息/会话持久化实现

系统的本地存储采用 Drift 统一管理，并通过 schemaVersion = 5 和迁移脚本保证旧数据兼容。数据库在升级时不仅补齐了设备地址表和连接会话表，还为消息表、附件表新增了更新时间、消息类型、发送状态、附件标识、校验信息和传输状态等字段，从而让文本消息、文件消息和连接状态都能够被统一持久化。消息模块通过 MessageRepository 和 MessageDao 完成消息插入、发送状态更新、会话查询以及附件联表读取；连接模块通过 ConnectionSessionRepository 和 ConnectionSessionDao 记录会话状态、心跳时间和断开原因。该存储层设计使网络通信、界面展示和历史记录追踪都建立在同一套数据模型之上。

// lib/data/local/database.dart

@DriftDatabase(

tables: [

DeviceItems,

DeviceAddressItems,

ConnectionSessionItems,

SettingItems,

MineItems,

MessageItems,

MessageAttachmentItems,

PointItems,

],

daos: [

DeviceDao,

DeviceAddressDao,

ConnectionSessionDao,

MessageDao,

SettingDao,

MineDao,

PointDao,

],

)

class AppDataBase extends _$AppDataBase {

AppDataBase({bool debugLog = false}) : super(_openConnection(debugLog));

AppDataBase.forTesting(super.executor);

@override

int get schemaVersion => 5;

@override

MigrationStrategy get migration {

return MigrationStrategy(

onCreate: (migrator) async {

await migrator.createAll();

await _createCustomIndexes();

},

onUpgrade: (migrator, from, to) async {

if (from < 2) {

await _migrateFromV1ToV2(migrator);

}

},

beforeOpen: (details) async {

await customStatement('PRAGMA foreign_keys = ON');

},

);

}

Future<void> _migrateFromV1ToV2(Migrator migrator) async {

await migrator.createTable(deviceAddressItems);

await migrator.createTable(connectionSessionItems);

await customStatement('''

ALTER TABLE message_items

ADD COLUMN updated_at INTEGER NOT NULL DEFAULT 0

''');

await customStatement('''

ALTER TABLE message_items

ADD COLUMN message_type TEXT NOT NULL DEFAULT 'text'

''');

await customStatement('''

ALTER TABLE message_items

ADD COLUMN send_status TEXT NOT NULL DEFAULT 'pending'

''');

await migrator.addColumn(messageItems, messageItems.localMessageId);

await migrator.addColumn(messageItems, messageItems.remoteMessageId);

await migrator.addColumn(messageItems, messageItems.errorMessage);

await customStatement('''

ALTER TABLE message_attachment_items

ADD COLUMN total_bytes INTEGER NOT NULL DEFAULT 0

''');

await customStatement('''

ALTER TABLE message_attachment_items

ADD COLUMN transferred_bytes INTEGER NOT NULL DEFAULT 0

''');

await migrator.addColumn(

messageAttachmentItems,

messageAttachmentItems.attachmentId,

);

await migrator.addColumn(

messageAttachmentItems,

messageAttachmentItems.fileName,

);

await migrator.addColumn(

messageAttachmentItems,

messageAttachmentItems.mimeType,

);

await migrator.addColumn(

messageAttachmentItems,

messageAttachmentItems.checksumSha256,

);

await migrator.addColumn(

messageAttachmentItems,

messageAttachmentItems.thumbnailPath,

);

await customStatement('''

ALTER TABLE message_attachment_items

ADD COLUMN transfer_status TEXT NOT NULL DEFAULT 'pending'

''');

await migrator.addColumn(

messageAttachmentItems,

messageAttachmentItems.transferTaskId,

);

await customStatement('''

ALTER TABLE message_attachment_items

ADD COLUMN created_at INTEGER NOT NULL DEFAULT 0

''');

await customStatement('''

ALTER TABLE message_attachment_items

ADD COLUMN updated_at INTEGER NOT NULL DEFAULT 0

''');

await customStatement('''

UPDATE message_items

SET

updated_at = created_at,

send_status = CASE direction

WHEN 'sent' THEN 'sent'

ELSE 'received'

END,

local_message_id = 'legacy_msg_' || id

''');

await customStatement('''

UPDATE message_items

SET message_type = 'file'

WHERE EXISTS (

SELECT 1

FROM message_attachment_items

WHERE message_attachment_items.message_id = message_items.id

)

''');

await customStatement('''

UPDATE message_attachment_items

SET

attachment_id = 'legacy_attachment_' || id,

file_name = file_path,

transfer_status = CASE save_status

WHEN 'saving' THEN 'transferring'

WHEN 'saved' THEN 'saved'

WHEN 'failed' THEN 'failed'

ELSE 'pending'

END

''');

await _createCustomIndexes();

}

}

// lib/data/local/repository/message_repository.dart

class MessageRepository {

const MessageRepository(this._messageDao);

final MessageDao _messageDao;

Stream<List<ConversationMessage>> watchConversation(String remoteDeviceId) {

return _messageDao

.watchConversation(remoteDeviceId)

.map(

(rows) =>

rows.map(ConversationMessage.fromRows).toList(growable: false),

);

}

Future<int> sendTextMessage({

required String remoteDeviceId,

required String textContent,

List<MessageAttachmentInput> attachments = const [],

}) {

final localMessageId = _newLocalEntityId(prefix: 'msg');

return _messageDao.insertMessageWithAttachments(

remoteDeviceId: remoteDeviceId,

direction: MessageDirection.sent,

textContent: textContent,

messageType: MessageType.text,

sendStatus: MessageSendStatus.pending,

localMessageId: localMessageId,

attachments: attachments

.map((attachment) => attachment.toDraft())

.toList(),

);

}

Future<int> saveReceivedMessage({

required String remoteDeviceId,

String? textContent,

MessageType messageType = MessageType.text,

String? remoteMessageId,

List<MessageAttachmentInput> attachments = const [],

}) {

return _messageDao.insertMessageWithAttachments(

remoteDeviceId: remoteDeviceId,

direction: MessageDirection.received,

textContent: textContent,

messageType: messageType,

sendStatus: MessageSendStatus.received,

remoteMessageId: remoteMessageId,

attachments: attachments

.map((attachment) => attachment.toDraft())

.toList(),

);

}

Future<int> markMessageSent({

required String localMessageId,

String? remoteMessageId,

}) {

return _messageDao.updateMessageStatus(

localMessageId: localMessageId,

sendStatus: MessageSendStatus.sent,

remoteMessageId: remoteMessageId,

errorMessage: null,

);

}

Future<int> markMessageFailed({

required String localMessageId,

required String errorMessage,

}) {

return _messageDao.updateMessageStatus(

localMessageId: localMessageId,

sendStatus: MessageSendStatus.failed,

errorMessage: errorMessage,

);

}

}

// lib/data/local/dao/message_dao.dart

@DriftAccessor(tables: [MessageItems, MessageAttachmentItems])

class MessageDao extends DatabaseAccessor<AppDataBase> with _$MessageDaoMixin {

MessageDao(super.db);

Stream<List<MessageWithAttachmentRows>> watchConversation(

String remoteDeviceId,

) {

final query =

select(messageItems).join([

leftOuterJoin(

messageAttachmentItems,

messageAttachmentItems.messageId.equalsExp(messageItems.id),

),

])

..where(messageItems.remoteDeviceId.equals(remoteDeviceId))

..orderBy([

OrderingTerm.asc(messageItems.createdAt),

OrderingTerm.asc(messageItems.id),

OrderingTerm.asc(messageAttachmentItems.id),

]);

return query.watch().map(_groupConversationRows);

}

Future<int> insertMessageWithAttachments({

required String remoteDeviceId,

required MessageDirection direction,

required MessageType messageType,

required MessageSendStatus sendStatus,

String? textContent,

String? localMessageId,

String? remoteMessageId,

String? errorMessage,

List<MessageAttachmentDraft> attachments = const [],

}) {

return transaction(() async {

final now = DateTime.now();

final messageId = await into(messageItems).insert(

MessageItemsCompanion.insert(

remoteDeviceId: remoteDeviceId,

textContent: Value(textContent),

updatedAt: Value(now),

direction: direction,

messageType: Value(messageType),

sendStatus: Value(sendStatus),

localMessageId: Value(localMessageId),

remoteMessageId: Value(remoteMessageId),

errorMessage: Value(errorMessage),

),

);

for (final attachment in attachments) {

final legacySaveStatus = switch (attachment.transferStatus) {

MessageAttachmentTransferStatus.pending =>

MessageAttachmentSaveStatus.pending,

MessageAttachmentTransferStatus.transferring =>

MessageAttachmentSaveStatus.saving,

MessageAttachmentTransferStatus.saved =>

MessageAttachmentSaveStatus.saved,

MessageAttachmentTransferStatus.failed =>

MessageAttachmentSaveStatus.failed,

};

final legacyProgress = attachment.totalBytes <= 0

? 0

: ((attachment.transferredBytes / attachment.totalBytes) * 100)

.round()

.clamp(0, 100);

await into(messageAttachmentItems).insert(

MessageAttachmentItemsCompanion.insert(

messageId: messageId,

saveStatus: Value(legacySaveStatus),

filePath: Value(attachment.filePath),

downloadProgress: Value(legacyProgress),

attachmentId: Value(attachment.attachmentId),

fileName: Value(attachment.fileName),

mimeType: Value(attachment.mimeType),

totalBytes: Value(attachment.totalBytes),

transferredBytes: Value(attachment.transferredBytes),

checksumSha256: Value(attachment.checksumSha256),

thumbnailPath: Value(attachment.thumbnailPath),

transferStatus: Value(attachment.transferStatus),

transferTaskId: Value(attachment.transferTaskId),

createdAt: Value(now),

updatedAt: Value(now),

),

);

}

return messageId;

});

}

}

// lib/data/local/repository/connection_session_repository.dart

class ConnectionSessionRepository {

const ConnectionSessionRepository(this._connectionSessionDao);

final ConnectionSessionDao _connectionSessionDao;

Future<int> saveSession({

required String sessionId,

required String deviceId,

int? deviceAddressId,

required ConnectionSessionState state,

required int protocolVersion,

DateTime? connectedAt,

DateTime? lastHeartbeatAt,

DateTime? disconnectedAt,

String? lastError,

}) {

return _connectionSessionDao.upsertSession(

sessionId: sessionId,

deviceId: deviceId,

deviceAddressId: deviceAddressId,

state: state,

protocolVersion: protocolVersion,

connectedAt: connectedAt,

lastHeartbeatAt: lastHeartbeatAt,

disconnectedAt: disconnectedAt,

lastError: lastError,

);

}

Future<int> updateSessionState({

required String sessionId,

ConnectionSessionState? state,

int? deviceAddressId,

DateTime? connectedAt,

DateTime? lastHeartbeatAt,

DateTime? disconnectedAt,

String? lastError,

}) {

return _connectionSessionDao.updateSessionState(

sessionId: sessionId,

state: state,

deviceAddressId: deviceAddressId,

connectedAt: connectedAt,

lastHeartbeatAt: lastHeartbeatAt,

disconnectedAt: disconnectedAt,

lastError: lastError,

);

}

}

// lib/data/local/dao/connection_session_dao.dart

@DriftAccessor(tables: [ConnectionSessionItems])

class ConnectionSessionDao extends DatabaseAccessor<AppDataBase>

with _$ConnectionSessionDaoMixin {

ConnectionSessionDao(super.db);

Future<int> upsertSession({

required String sessionId,

required String deviceId,

int? deviceAddressId,

required ConnectionSessionState state,

required int protocolVersion,

DateTime? connectedAt,

DateTime? lastHeartbeatAt,

DateTime? disconnectedAt,

String? lastError,

}) {

return into(connectionSessionItems).insertOnConflictUpdate(

ConnectionSessionItemsCompanion.insert(

sessionId: sessionId,

deviceId: deviceId,

deviceAddressId: Value(deviceAddressId),

state: state,

protocolVersion: protocolVersion,

connectedAt: Value(connectedAt),

lastHeartbeatAt: Value(lastHeartbeatAt),

disconnectedAt: Value(disconnectedAt),

lastError: Value(lastError),

),

);

}

Future<int> updateSessionState({

required String sessionId,

ConnectionSessionState? state,

int? deviceAddressId,

DateTime? connectedAt,

DateTime? lastHeartbeatAt,

DateTime? disconnectedAt,

String? lastError,

}) {

return (update(

connectionSessionItems,

)..where((table) => table.sessionId.equals(sessionId))).write(

ConnectionSessionItemsCompanion(

state: Value.absentIfNull(state),

deviceAddressId: Value(deviceAddressId),

connectedAt: Value(connectedAt),

lastHeartbeatAt: Value(lastHeartbeatAt),

disconnectedAt: Value(disconnectedAt),

lastError: Value(lastError),

),

);

}

}

## 5.8 数据库表设计

本节对系统中涉及的核心数据库表进行说明。系统采用 Drift 进行本地持久化管理，围绕设备发现、地址记忆、连接会话、本机信息、应用设置、消息内容、消息附件与统计信息等业务场景，共设计若干核心数据表。下面结合各表的功能、字段约束及表间关系，分别给出数据库表设计说明。

**表 51数据库表功能概览**

**表5-2 设备信息表（device_items）**

**表 52 设备信息表**

**Tab 52 device_items**

# 6 系统测试与结果分析

## 6.1 功能测试

功能测试围绕系统的核心功能模块展开，验证设备发现、文本通信、文件收发、主题切换与本机信息展示等关键流程的正确性。测试环境为同一Wi-Fi局域网内的Android手机和macOS笔记本电脑，测试方法为手动操作并观察预期结果。

设备发现测试：启动两台设备上的应用，验证双方是否能在在线列表中看到对方。测试结果表明，应用启动后3秒内即可在列表中显示附近设备，设备名称、IP地址和状态信息显示正确。关闭其中一台设备后，另一台设备在15秒内将其标记为离线并从列表中移除。

文本通信测试：在一台设备上选择另一台设备发起会话，发送多条文本消息，验证对方是否能正确接收。测试结果表明，TCP连接建立时间在500毫秒以内，消息发送后对方立即收到，消息内容、发送时间和发送方信息显示正确。连续发送50条消息无丢失或乱序。

文件传输测试：分别测试了图片（2MB）、文档（10MB）和视频（200MB）的传输。测试结果表明，所有文件均能成功传输并保存到接收端的指定目录。传输过程中进度条和速率显示正确，传输完成后文件大小和内容与源文件一致。200MB视频在100Mbps局域网下的传输时间约为16秒。

主题切换测试：在设置页中分别切换浅色模式、深色模式和跟随系统模式，验证界面是否立即更新。测试结果表明，主题切换即时生效，所有页面的背景色、文字色和组件样式均正确更新。退出应用后重新启动，主题设置保持上次选择。

本机信息展示测试：进入Mine页面，验证设备名称、设备ID、IP地址列表等信息是否正确显示。测试结果表明，设备ID在首次启动后生成并持久化，后续启动保持不变；IP地址列表正确显示本机所有网卡的地址信息。

## 6.2 工程测试

工程测试从代码质量和架构稳定性两个维度进行评估。

静态分析：运行flutter analyze命令对项目代码进行静态检查，结果显示无错误（error）和警告（warning），仅有少量信息提示（info），代码整体质量处于可维护状态。代码规范方面，项目遵循Flutter官方推荐的代码风格，命名规范、注释完整、文件组织清晰。

数据库迁移测试：对Drift数据库进行了版本升级测试，验证从旧版本（schemaVersion 1-4）升级到当前版本（schemaVersion 5）时，数据迁移脚本能正确执行，已有数据不丢失。测试结果表明，迁移过程中新增的字段（如updated_at、message_type、send_status等）均能正确添加，旧数据的默认值设置合理。

Provider依赖注入测试：验证各Provider之间的依赖关系是否正确建立，状态更新是否能正确传播。测试结果表明，修改DiscoveryProvider的状态后，依赖它的ChatProvider和UI层均能自动收到更新通知，无需手动刷新。

## 6.3 性能/稳定性分析

性能测试重点关注文件传输速度和内存占用两个指标。

传输速度测试：在100Mbps局域网环境下，分别测试了不同大小文件的传输速度。1MB文件传输时间约为0.1秒（速度约10MB/s），10MB文件约为1秒，100MB文件约为10秒，1GB文件约为100秒。传输速度基本达到局域网带宽的理论上限，表明流式分段传输方案能有效利用网络带宽。

内存占用测试：传输1GB大文件时，应用内存占用峰值约为120MB，远低于一次性加载整个文件到内存的方案（需要1GB以上）。这得益于64KB分段读写策略，每次只将一小段文件内容加载到内存中。

稳定性测试：进行了长时间运行测试（连续运行4小时），期间持续进行设备发现和文件传输。测试结果表明，系统运行稳定，未出现崩溃或内存泄漏。UDP广播在4小时内持续正常收发，在线设备列表的更新和超时剔除机制工作正常。

当前不足集中在安全机制缺口（缺少端到端加密和传输完整性校验）、异常恢复能力不足（网络切换后需要手动重连）、量化测试数据不够充分（缺少自动化性能基准测试）等方面，这些问题将在后续版本中逐步改进。

## 6.4 测试结论

系统测试从功能正确性、工程质量和性能稳定性三个维度展开。功能测试验证了设备发现、文本通信、文件收发、主题切换与本机信息展示等核心流程，所有测试用例均通过。工程测试验证了代码质量、数据库迁移和Provider依赖注入的稳定性。性能测试验证了文件传输速度接近局域网带宽上限，大文件传输时内存占用保持在合理水平。

测试结果表明，系统能够在局域网环境下完成从设备发现到文件传输的完整闭环，满足毕业设计的功能目标和性能要求。系统的主要优势在于：跨平台支持（Android、iOS、macOS、Windows、Linux）、自动设备发现（无需手动配置）、高效文件传输（流式分段传输）、响应式界面（适配不同屏幕尺寸）。主要不足在于安全机制和异常恢复能力有待加强，这些将在后续版本中改进。

# 7 结论

本文完成了基于Flutter的跨平台局域网文件传输系统的设计与实现，形成了较完整的工程架构与可运行产品。系统采用UI层、Provider状态层、Repository业务层、Service/Core基础设施层的四层分离架构，实现了设备发现、TCP文本通信、文件传输、状态管理、本地持久化、主题切换以及设备信息展示等核心功能。

在技术实现方面，系统通过UDP广播实现局域网内设备的自动发现，用户无需手动配置IP地址即可看到附近的在线设备；通过TCP协议实现可靠的文本消息通信和文件传输，采用流式分段传输策略确保大文件传输时内存占用可控；通过Riverpod实现响应式状态管理，通过Drift实现本地数据持久化，通过AutoRoute实现页面导航管理。系统支持Android、iOS、macOS、Windows和Linux五个平台，采用单一代码库覆盖所有平台。

在工程实践方面，项目验证了Flutter框架在网络密集型应用中的可行性，证明Flutter不仅能构建UI密集型应用，也能胜任Socket编程、文件流处理等底层网络任务。代码生成技术（freezed、json_serializable、auto_route_generator、drift_dev、riverpod_generator）的大量使用减少了样板代码，提高了开发效率和代码质量。

系统的主要创新点包括：（1）采用"发现与传输分离"的通信架构，UDP负责轻量级设备发现，TCP负责可靠传输，兼顾了效率和可靠性；（2）实现跨平台的自动设备发现，无需用户手动配置，降低了使用门槛；（3）采用流式分段传输策略，大文件传输时内存占用保持在120MB以内。

后续仍可从以下方面进行改进：（1）引入端到端加密（如AES-256）和传输完整性校验（如SHA-256哈希比对），提升传输安全性；（2）实现断点续传功能，支持传输中断后从断点恢复；（3）优化网络切换后的自动重连机制，提升异常恢复能力；（4）添加自动化性能基准测试，建立持续的性能监控体系；（5）探索基于mDNS/DNS-SD的设备发现方案，提升跨子网的设备发现能力。

# 参考文献

[1] 杜文. Flutter实战[M].第2版.北京:机械工业出版社,2023.

[2] 郭树煜. Flutter开发实战详解[M].北京:电子工业出版社,2020.

[3] Windmill E. Flutter in Action[M]. Shelter Island, NY: Manning Publications, 2020.

[4] Miles R. Beginning Flutter: A Hands On Guide to App Development[M]. Birmingham: Packt Publishing, 2019.

[5] Stevens W R, Fenner B, Rudoff A M. UNIX Network Programming, Volume 1: The Sockets Networking API[M].3rd ed.Boston:Addison-Wesley,2004.

[6] Tanenbaum A S, Wetherall D J. Computer Networks[M].5th ed.Boston:Pearson,2011.

[7] Stallings W. Cryptography and Network Security: Principles and Practice[M].8th ed.London:Pearson,2020.

[8] Kleppmann M. Designing Data-Intensive Applications[M].Sebastopol, CA: O’Reilly Media,2017.

[9] Postel J. User Datagram Protocol: RFC 768[S].IETF,1980.

[10] Postel J. Transmission Control Protocol: RFC 793[S].IETF,1981.

[11] Eggert L, Fairhurst G. UDP Usage Guidelines: RFC 8085[S].IETF,2017.

[12] Rivest R. The MD5 Message-Digest Algorithm: RFC 1321[S].IETF,1992.

[13] NIST. Advanced Encryption Standard (AES): FIPS PUB 197[S].Gaithersburg, MD: NIST,2001.

[14] NIST. Secure Hash Standard (SHS): FIPS PUB 180-4[S].Gaithersburg, MD: NIST,2015.

[15] IEEE. IEEE Standard for Local and Metropolitan Area Networks—Part 11: Wireless LAN MAC and PHY Specifications: IEEE Std 802.11-2020[S].New York: IEEE,2020.

[16] Google. Flutter Documentation[EB/OL].https://docs.flutter.dev,[2026-04-16].

[17] Riverpod Team. Riverpod Documentation[EB/OL].https://riverpod.dev,[2026-04-16].

[18] Hive Team. Hive Database Documentation[EB/OL].https://docs.hivedb.dev,[2026-04-16].
