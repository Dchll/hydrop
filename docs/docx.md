# 毕业论文文本维护稿

来源：/Users/admin-and/Downloads/韩义勇毕业设计 2.docx。
范围：摘要、Abstract、正文第 1-7 章、参考文献、正文中的表题，以及附录 C 关键代码清单；不包含封面、目录和致谢。

# 摘要

随着多终端协同办公与移动学习场景的普及，用户对跨设备、低门槛、高效率文件传输的需求持续增长。传统云盘方案依赖外网与第三方服务器，蓝牙方案传输效率有限，且多平台系统之间存在交互割裂问题。针对上述痛点，本文围绕“基于 Flutter 的跨平台局域网文件传输系统”开展研究与工程实现，目标是在统一技术栈下构建可运行于移动端与桌面端的局域网直连传输应用。本文设计并实现了一套基于 Flutter 的跨平台局域网文件传输系统，构建了设备发现、聊天会话、文件传输、传输进度、通知反馈、设置管理和本地持久化一体化方案。系统采用 Flutter、Riverpod、AutoRoute 与 Drift 的分层架构，网络层通过 UDP 广播完成局域网设备发现与在线维护，通过 TCP Socket 和自定义 FrameCodec 帧协议完成文本消息与文件数据传输；表现层只保留设备页和设置页两个一级入口，移动端使用底部导航，桌面端使用左侧导航，设备页在桌面端采用设备列表与聊天内容双栏布局。系统实现了局域网环境下的自动发现、双向文本通信、文件收发、暂停取消、失败反馈、进度通知和中断恢复能力，具备较好的跨平台适配性、可维护性和扩展能力。
关键词：Flutter；跨平台；局域网传输；UDP 设备发现；TCP Socket；Riverpod

# Abstract

With the increasing prevalence of multi-device collaboration in office and learning scenarios, users have a growing demand for cross-device, low-barrier, and high-efficiency file transfer. Traditional cloud storage solutions rely on external networks and third-party servers, while Bluetooth-based approaches suffer from limited transfer efficiency. In addition, cross-platform systems often provide fragmented interaction experiences. To address these issues, this thesis presents the design and implementation of a Flutter-based cross-platform LAN file transfer system, aiming to build a direct LAN transfer application for mobile and desktop devices under a unified technology stack.The proposed system integrates device discovery, chat sessions, file transfer, progress tracking, notification feedback, settings management, and local persistence. It adopts a layered architecture based on Flutter, Riverpod, AutoRoute, and Drift. At the network layer, UDP broadcasting is used to discover and maintain LAN devices, while TCP sockets and a custom FrameCodec frame protocol are used to transmit text messages and file data. At the presentation layer, the application keeps two first-level entries: Devices and Settings. Mobile devices use bottom navigation, desktop devices use side navigation, and the Devices page uses a two-column layout with a device list and chat content on desktop screens. The implemented system supports automatic discovery, two-way text communication, file sending and receiving, pause and cancel operations, failure feedback, progress notifications, and interrupted transfer recovery in LAN environments.
Key words: Flutter; cross-platform; LAN file transfer; UDP device discovery; TCP Socket; Riverpod

# 1 绪论

## 1.1 研究背景

随着移动互联网和智能终端的普及，用户日常使用设备的种类和数量显著增加。智能手机、平板电脑、笔记本电脑和桌面工作站并行使用已成为学习、办公和生活中的常态。在这一多设备并行的使用模式下，文件在不同设备之间的流转需求频繁出现：学生需要将课堂拍摄的板书照片传输到电脑进行整理，办公人员需要将手机上收到的合同文件转发到桌面端进行编辑，设计师需要在平板和工作站之间同步设计素材。这些场景的共同特点是设备处于同一局域网内，对传输速度有较高要求，且希望操作简便、无需依赖外部服务器。
目前市面上的跨设备文件传输方案主要分为三类。第一类是基于互联网中转的云存储方案，其优点是跨网络可用，但缺点是传输速度受限于上行带宽，大文件传输耗时较长，且文件需经过第三方服务器，存在隐私泄露风险。第二类是基于蓝牙的近场传输方案，其优点是无需网络，但缺点是传输速率低，不适合大文件传输。第三类是厂商生态内的互联方案，其优点是体验流畅，但缺点是通常限于同品牌或同生态设备使用，跨品牌兼容性不足。上述方案均无法同时满足“高速、跨平台、无需外网、操作简便”的需求。
局域网直传技术为上述问题提供了可行的解决思路。在同一局域网内，设备之间可以通过 Wi-Fi 获得远高于蓝牙的传输能力，且无需经过互联网中转，传输延迟低、隐私性好。然而，传统局域网传输工具往往需要用户手动配置 IP 地址和端口，操作门槛较高，且缺乏现代化的用户界面。因此，设计一款兼具高性能和良好用户体验的跨平台局域网文件传输系统，具有重要的实用价值和工程意义。

## 1.2 研究目的与意义

本课题旨在设计并实现一款基于 Flutter 框架的跨平台局域网文件传输系统，覆盖设备发现、会话建立、文本消息通信、文件传输、状态展示和基础配置管理等核心能力，形成可扩展的工程架构。Flutter 在跨平台界面开发和工程组织方面已有较成熟的实践基础[1][2]，其自绘渲染、Widget 组合和响应式布局能力适合构建同一套界面同时运行于移动端与桌面端的场景，也为系统后续的状态管理、页面适配和交互统一提供了稳定基础。
本课题的研究意义体现在三个层面。在应用价值层面，系统通过局域网 UDP 广播实现设备自动发现，用户打开应用后即可看到附近设备；文件传输采用 TCP 直连和流式分片传输，能够充分利用局域网带宽，并减少外部服务器参与带来的隐私风险。在工程价值层面，系统验证了 Flutter 框架在网络密集型应用中的可行性，证明 Flutter 不仅能构建 UI 密集型应用，也能胜任 Socket 编程、文件流处理、平台通知、二维码连接等任务。在实践价值层面，项目沉淀了一套完整的跨平台网络应用实现路径，包括 UDP 广播发现、TCP 帧协议、Riverpod 状态管理、Drift 本地持久化、响应式界面布局等技术方案。

## 1.3 研究内容与阶段目标

本文围绕跨平台局域网文件传输场景，完成了需求分析、总体架构设计、设备发现协议设计、文本会话与文件传输实现、状态管理与本地持久化、界面设计以及系统测试等工作。具体研究内容包括以下几个方面。
（1）需求分析：通过调研现有跨设备传输方案的优缺点，明确系统在设备发现、会话通信、文件传输和配置管理四个维度的功能需求，以及性能、稳定性、可维护性和可扩展性等非功能需求。需求分析阶段采用面向对象方法识别系统边界、参与者、用例和领域对象，为后续 UML 设计提供约束条件。
（2）系统设计：采用表现层、应用状态层、数据访问层、网络与平台基础设施层的分层架构，设计发现模块、聊天模块、传输模块和设置模块的职责边界，定义 UDP 发现协议和 TCP FrameCodec 传输协议的消息格式，规划移动端单栏与桌面端双栏的响应式界面布局。
（3）系统实现：基于 Flutter 和 Dart 实现设备发现、文本通信、文件传输、进度跟踪、通知反馈、状态管理、本地持久化、二维码连接、主题与语言设置等核心功能。设备发现使用 UDP 39175 端口，传输服务使用 TCP 39176 端口；文件传输采用 1MB 分片、16GB 文件上限和有限并发策略。
（4）系统测试：对系统进行功能测试、工程测试和稳定性分析，验证设备发现、文本通信、文件收发、主题切换、语言切换、本机信息维护等核心流程的正确性。
论文结构安排如下：第 2 章介绍相关技术，第 3 章分析系统功能与非功能需求，第 4 章给出系统总体设计与核心模块划分，第 5 章阐述系统实现，第 6 章给出测试与分析，第 7 章总结全文并展望后续工作。

# 2 相关技术介绍

## 2.1 Flutter 与 Dart

Flutter 是 Google 开源的跨平台 UI 开发框架，采用自绘引擎直接在 Canvas 上绘制界面，而非完全依赖平台原生控件，因此能够保证在移动端和桌面端获得一致的渲染效果。Flutter 官方文档和相关英文著作对其渲染、Widget 组合和跨平台开发方式进行了系统说明[3][4][5]。Flutter 的核心架构由引擎层、框架层和业务层组成：引擎层负责图形渲染、文字排版、Dart 运行时和平台通道；框架层提供 Widget、Element、RenderObject 渲染机制，以及动画、手势、无障碍等基础能力；业务层通过组合 Widget 构建用户界面。Flutter 3.x 之后的渲染体系同时兼顾了启动性能和绘制一致性，适合对界面稳定性和跨平台外观一致性要求较高的应用。
Dart 是 Flutter 的开发语言，兼具静态类型和运行时灵活性。Dart 支持 AOT 编译以保证生产环境性能，同时支持 JIT 编译与热重载以提升开发效率。Dart 语言原生支持异步编程，通过 Future、Stream、async/await 处理网络请求、文件 I/O 和数据库查询。在本系统中，UDP 广播监听、TCP Socket 通信、文件分片传输、传输进度推送等核心功能均依赖 Dart 的异步流式处理能力。借助 Stream，系统可以将设备发现、消息接收和文件进度更新统一纳入响应式数据流，减少页面层与底层 Socket 的耦合。

## 2.2 Riverpod 状态管理

Riverpod 是 Flutter 生态中的声明式状态管理框架，其核心特点是不依赖 BuildContext，Provider 可以作为全局、类型安全的依赖容器使用[6]。系统在入口处使用 ProviderScope 包裹应用，并通过 TalkerRiverpodObserver 记录 Provider 生命周期。页面层通过 ConsumerWidget 或 ConsumerStatefulWidget 读取状态，业务层通过 Provider、NotifierProvider、StreamProvider、Provider.family 等方式暴露数据和操作。与传统依赖上下文的状态传递方式相比，Riverpod 更适合分层架构中的 repository、controller 和 service 组合。
本系统的设备列表、设置项、聊天消息、传输进度和应用运行时能力均通过 Riverpod 管理。其中传输进度采用 transferProgressStoreProvider 和 transferProgressProvider 暴露，UI 可以按附件 ID 订阅单个传输任务的方向、阶段、已传字节、总字节、速度和错误信息，避免页面直接依赖底层 Socket 回调。通过 family 形式的 provider，页面可以针对某个远端设备或附件实例精确订阅状态，从而减少不必要的重建。

## 2.3 AutoRoute 路由管理

AutoRoute 是 Flutter 的声明式路由框架，通过 @RoutePage 注解和代码生成实现类型安全的路由导航[7]。本系统使用 AppRouter 管理页面路由：AppRoute 是应用主壳，内部包含 HomeRoute 和 SettingsRoute 两个一级子路由；ChatRoute 是从设备页进入的会话路由，携带远端设备 ID 与显示名称。该设计使一级页面保持简洁，也使聊天页能够根据设备上下文渲染消息时间线。AutoRoute 的参数校验和嵌套路由能力也保证了响应式布局切换时页面栈的可预测性。

## 2.4 Drift 本地数据库

Drift 是 Dart/Flutter 的类型安全响应式数据库框架，基于 SQLite 构建[8][9]。系统通过 Drift 定义 8 张业务表：设备表、设备地址表、连接会话表、设置表、本机资料表、消息表、消息附件表和统计表。Drift 的 Stream 查询能力使页面可以直接监听数据库变化并自动刷新列表，而无需手动轮询。数据库 schemaVersion = 1，处于第一版开发阶段，不包含升级迁移逻辑；首次创建数据库时调用 migrator.createAll() 创建全部表，并额外创建设备地址唯一索引、消息本地 ID 唯一索引和附件 ID 唯一索引。

## 2.5 网络通信

局域网通信和 Socket 编程的基础理论可参考 UNIX 网络编程与计算机网络相关文献[10][11]。UDP 适用于局域网设备发现等对实时性要求较高、允许少量丢包的场景[12]。本系统使用 RawDatagramSocket 在 UDP 39175 端口监听并接收设备广播，广播 payload 类型为 hydrop.discovery.hello，协议版本为 1，内容包含设备 ID、显示名称、TCP 端口、能力列表、nonce 和地址列表等信息。广播间隔为 10 秒，设备 TTL 为 12 秒，TTL 扫描间隔为 3 秒。
TCP 适用于文本消息和文件数据传输，其连接管理、可靠传输和确认机制为大文件传输提供了基础[13]。本系统传输服务默认使用 TCP 39176 端口，传输数据不采用文本行协议，而采用 FrameCodec 帧协议：4 字节 header 长度、4 字节 body 长度、JSON header 和 binary body。文本消息、文件 offer、文件分片、完成确认、心跳、错误消息等都通过同一帧协议承载，从而保证协议结构统一且便于扩展。发现广播间隔和异常处理也参考了 UDP 使用建议中关于拥塞控制和报文健壮性的要求[14]。

## 2.6 数据序列化与不可变数据

系统使用 json_serializable、freezed、drift_dev、riverpod_generator、auto_route_generator 等代码生成工具减少样板代码。发现 payload、二维码连接 payload、消息状态、数据库表映射和 Provider 声明均通过类型安全方式组织，使协议解析、状态变更和持久化代码在编译阶段即可获得检查。结构化数据建模与持久化设计也符合数据密集型应用中对数据模型清晰性和演进能力的要求[15]，同时也与软件工程导论中强调的分层、模块化和阶段化开发思想相一致[16]。数据结构教材中关于抽象数据类型、线性表、树和图的组织方式，也为系统消息、附件和设备地址等对象建模提供了基础方法[17]。

## 2.7 日志与可观测性

系统使用 Talker 作为日志框架，并结合 TalkerRiverpodObserver 记录 Provider 的创建、更新、销毁和失败事件。网络发送链路中的关键错误以中文日志输出，并使用统一标志符便于开发调试时检索。该设计能够帮助定位设备发现、TCP 建连、消息确认、文件发送和接收等链路中的异常。

## 2.8 平台能力插件

系统使用 network_info_plus 与 dart:io 枚举本机网络信息，使用 path_provider 获取应用支持目录和下载目录，使用 file_picker 进行文件选择与保存，使用 qr_flutter 和 mobile_scanner 实现二维码展示与扫描，使用 flutter_local_notifications 显示传输进度通知，使用 fluttertoast 在移动端显示临时提示，并在桌面端使用应用内提示组件进行反馈。这些插件分别承担网络诊断、文件系统定位、文件选择、二维码连接、系统通知、临时提示、网络图片缓存、外链跳转、本地视频播放和 HTTP 请求等平台相关能力，使业务逻辑无需直接依赖平台原生代码。

## 2.9 代码生成工具链

项目使用 build_runner 作为统一的代码生成执行器，配合 auto_route_generator、drift_dev、freezed、json_serializable、riverpod_generator 和 flutter_gen_runner 使用。代码生成覆盖路由、数据库、状态模型、资源引用和 Provider 声明，减少重复代码并提高类型安全性。

# 3 系统需求分析

本章采用面向对象分析方法描述系统需求，不使用结构化方法中的数据流图，也不把已经实现后的页面点击过程画成业务流程图。开发类课题的需求分析应先识别系统边界、参与者、用例和领域对象，再进入后续设计。用例分析用于说明用户与系统之间的目标关系，领域对象分析用于提炼问题域中的核心概念；具体类职责、对象交互、状态变化和部署关系放在第 4 章设计部分展开。UML 建模和面向对象分析设计的基本方法可参考相关研究[18][19]。

## 3.1 系统边界与参与者分析

本系统的系统边界是“Hydrop 局域网文件传输应用”。系统内部负责设备发现、会话消息、文件传输、传输进度、本机资料和设置管理；系统外部包括使用应用的用户、局域网中的对端设备、操作系统文件系统、系统通知服务、二维码扫描/展示能力以及本地数据库。系统不依赖云端中转服务器，通信对象限定为同一局域网内可达设备。
系统主要参与者包括普通用户、对端设备、操作系统和本地数据库。普通用户发起发现、选择设备、发送文本、选择文件、暂停或取消传输、修改设置；对端设备接收发现广播、建立 TCP 连接、回复消息确认和文件确认；操作系统提供文件选择、下载目录、通知权限、网络接口和应用生命周期；本地数据库负责保存设备、地址、会话、消息、附件和设置。

表3-1  系统参与者说明
Tab.3-1 System actor description

参与者	类型	主要职责
普通用户	主参与者	查看设备、进入会话、发送文本和文件、管理设置
对端设备	外部系统	响应发现广播、接收或发送消息、参与文件传输
操作系统	外部系统	提供网络、文件、通知、生命周期和平台插件能力
本地数据库	支撑系统	持久化设备、地址、消息、附件、设置和统计信息

## 3.2 用例分析

系统用例围绕用户目标组织，而不是围绕已经实现的页面跳转过程组织。普通用户的核心目标包括发现附近设备、查看设备状态、进入设备会话、发送文本消息、发送文件、查看传输进度、暂停或取消传输、删除设备显示记录、修改本机显示名称、切换主题和语言、使用二维码连接。对端设备作为协作参与者，参与发现广播、消息确认、文件接收和文件完成确认。

系统用例关系体现为普通用户、对端设备、操作系统和本地数据库与系统之间的协作。普通用户主要完成发现附近设备、查看设备列表、进入设备会话、发送文本消息、发送文件、查看传输进度、暂停传输、取消传输、删除设备记录、修改本机显示名称、配置主题和语言、二维码连接等操作。对端设备参与发现广播、消息确认和文件传输；操作系统提供网络、文件、通知和生命周期能力；本地数据库负责保存设备、地址、消息、附件和设置数据。

表3-2  核心用例规约
Tab.3-2 Core use case specification

用例名称	参与者	前置条件	基本事件流	后置条件
发现附近设备	用户、对端设备	设备接入同一局域网并授予网络权限	系统启动发现服务；本机广播设备信息；接收对端广播；保存设备和地址；更新在线状态	设备页展示可用设备
进入设备会话	用户	设备列表中存在远端设备	用户选择设备；系统读取设备上下文；打开会话页面；加载历史消息	用户可查看或发送消息
发送文本消息	用户、对端设备	已选择远端设备且存在可达地址	用户输入文本；系统创建本地消息；通过 TCP 帧发送；等待确认；更新发送状态	消息显示为成功或失败
发送文件	用户、对端设备、操作系统	用户选择本地文件且文件未超过大小限制	系统创建附件消息；发送文件 offer；按分片传输；更新进度；完成后校验并确认	发送端和接收端显示完成状态
暂停或取消传输	用户	存在进行中或排队中的传输任务	用户触发暂停或取消；系统关闭连接或移除队列；更新附件状态和通知	UI 显示暂停、失败或取消结果
修改系统设置	用户、本地数据库	应用正常运行	用户修改主题、语言、显示名称或传输偏好；系统保存设置；Provider 推送状态变化	设置即时生效并可恢复

## 3.3 功能需求

设备发现需求：系统应在应用启动和前台恢复时启动局域网发现能力。本机需要周期性广播设备 ID、显示名称、TCP 端口、能力列表、nonce 和地址列表；同时监听同一端口上的对端广播。系统收到远端设备广播后，应保存或更新设备表和设备地址表，并根据 TTL 将长时间未刷新的设备置为离线状态。设备页应展示设备名称、连接状态、测速摘要和最后一次传输时间；在线设备使用正常文本颜色，不在线设备置灰。
会话通信需求：系统应支持用户从设备页进入指定设备会话。会话页面需要根据远端设备 ID 读取本地消息时间线，支持文本消息发送和接收。文本发送时应先创建本地消息记录，再通过 TCP 帧协议发送到远端设备；发送成功后更新为已发送，失败时保留错误信息，便于用户重试或判断问题。
文件传输需求：系统应支持用户选择图片、视频和普通文件作为聊天附件发送。发送端需要在传输前检查文件大小，创建附件消息，选择远端可达地址，建立 TCP 连接，发送文件 offer，并按 1MB 分片传输。接收端需要保存文件到下载目录下的 Hydrop 文件夹，更新接收进度，并在完成后记录本地路径。传输过程中应显示已传字节、总字节、速度、阶段和错误信息，并提供暂停和取消能力。
设置管理需求：系统应提供设置页作为一级入口，整合本机资料和配置能力。用户可以直接在页面上修改本机显示名称，查看设备 ID、二维码连接、本地 IP 和诊断信息；可以切换浅色、深色或跟随系统主题；可以切换跟随系统、英文、简体中文和繁体中文；可以配置传输加密开关和自动恢复传输开关。
数据持久化需求：系统应将设备、地址、连接会话、设置、本机资料、消息、附件和统计信息保存到本地数据库。消息和附件记录应支持按远端设备查询；设备地址应避免同一设备、同一 IP、同一端口重复写入；附件 ID 和本地消息 ID 应具备唯一性，避免发送或接收重试时产生重复记录。

## 3.4 非功能需求

在性能方面，文件传输采用文件流分片读写，不将大文件一次性加载到内存。分片大小为 1MB，单文件大小上限为 16GB，并发传输上限为 2。传输进度通过 Riverpod 细粒度推送，UI 可按附件订阅进度，避免无关页面频繁重建。
在稳定性方面，系统需要处理网络异常、协议解析失败、连接中断、确认超时、文件过大、通知插件失败和数据库唯一约束冲突等异常。传输链路需要支持暂停、取消、失败状态展示和中断恢复；应用前后台切换时应统一管理发现服务和传输服务，避免后台连接状态与 UI 状态不一致。
在安全性方面，系统以局域网直连为基础，文件不经过外部服务器。设置表中保留传输加密开关，为后续协议加密提供配置入口；文件传输链路保留 SHA-256 校验字段，用于完整性验证，相关哈希算法标准可参考安全哈希标准文档[20]。
在可维护性方面，系统应采用清晰的分层结构。页面层只负责渲染和交互，状态层负责组织 UI 状态，数据层负责数据库访问，网络与平台基础设施层负责 Socket、文件系统、通知和二维码能力。模块之间通过 Provider、Controller、Repository 和 Service 协作，避免页面直接操作数据库或 Socket。
在可扩展性方面，发现 payload、FrameCodec header 和数据库表字段均采用结构化设计。系统应能够在不破坏已有功能的前提下扩展新的能力标识、传输阶段、附件类型、加密字段和统计字段。

## 3.5 领域对象分析

需求分析阶段需要抽取问题域对象，为设计阶段的类图提供依据。本系统的问题域对象主要包括本机资料、远端设备、设备地址、连接会话、消息、消息附件、传输任务、传输进度和系统设置。它们之间的关系是：一个远端设备可以拥有多个设备地址；一个远端设备可以对应多条消息；一条消息可以关联多个附件；一个附件可以对应一个传输任务和一个传输进度快照；系统设置和本机资料属于本机全局状态。

需求分析阶段抽取出的主要问题域对象不涉及 Flutter Widget、数据库 DAO 等实现类。LocalProfile 表示本机资料，RemoteDevice 表示远端设备，DeviceAddress 表示设备地址，ConnectionSession 表示连接会话，ConversationMessage 表示会话消息，MessageAttachment 表示消息附件，TransferTask 和 TransferProgress 表示传输任务与进度，AppSettings 表示系统设置。对象之间的核心关系包括：一个远端设备对应多个设备地址，一个远端设备对应多条会话消息，一条会话消息可以关联多个附件。

# 4 系统设计

本章采用 UML 面向对象设计方法描述系统结构与交互。与需求分析阶段不同，设计阶段可以出现系统内部类、组件、对象交互和状态变化。本章不使用数据流图，也不把页面点击路径画成业务流程图，而是按照 UML 的图类型分别说明静态结构、动态交互、状态迁移和部署关系。

## 4.1 总体架构设计

系统采用表现层、应用状态层、数据访问层、网络与平台基础设施层的分层架构。该架构的核心思想是“关注点分离”：表现层只负责页面渲染与用户交互，不直接操作 Socket、数据库和文件系统；应用状态层通过 Riverpod 组织设备、聊天、传输、设置和应用运行时状态；数据访问层通过 Repository 和 DAO 读写 Drift 数据库，并向上提供稳定的业务数据接口；网络与平台基础设施层封装 UDP、TCP、文件系统、通知、二维码、日志和平台插件能力。
从依赖方向看，表现层依赖应用状态层提供的 Provider 和 Controller，应用状态层依赖 Repository 与 Service，Repository 依赖 DAO，DAO 依赖数据库连接。底层模块不反向依赖页面，这样可以避免 UI 变化影响网络协议和数据存储逻辑。系统运行时由 AppRuntime 统一协调发现服务、TCP 传输服务、通知权限和中断传输恢复，避免各页面分别启动网络能力而造成重复监听、状态竞争或资源泄漏。
系统按照业务职责划分为设备发现、会话消息、文件传输、设置管理、本机资料和持久化统计六类核心能力。设备发现模块负责发现局域网内可达设备并维护在线状态；会话消息模块负责文本消息的创建、发送、接收和状态流转；文件传输模块负责文件 offer、分片传输、进度反馈、暂停取消和完成确认；设置模块负责主题、语言、传输偏好和本机显示名称；持久化模块负责设备、地址、会话、消息、附件和统计数据落库。该划分保证各模块职责边界清晰，便于后续扩展加密传输、传输队列、缩略图生成等功能。
架构设计还需要处理跨平台应用中的资源生命周期问题。移动端和桌面端对后台网络、通知权限、文件目录和窗口尺寸的处理方式并不完全一致，因此系统没有把发现服务和传输服务绑定到某一个页面，而是由运行时层统一管理。页面进入或离开并不直接决定 Socket 的创建和释放；应用生命周期变化才是网络服务启动和停止的主要依据。这样设计可以减少页面重建带来的副作用，也能让设备发现、聊天页和设置页共享同一份运行时状态。
系统不设置中心服务器，每台设备都同时具备发现者、被发现者、发送端和接收端身份。这种对等结构使系统部署更简单，但也要求本地节点保存足够的设备、地址和消息状态。为此，系统将短期状态和长期状态分开管理：传输进度、页面选择、输入框内容等短期状态主要保存在 Riverpod 状态树中；设备记录、地址记录、消息记录、附件记录和设置项等长期状态写入 Drift 数据库。短期状态用于提高界面响应速度，长期状态用于应用重启后的恢复和历史记录展示。

系统各层组件之间保持自上而下的依赖关系。Presentation 层包含 AppPage、HomePage、ChatPage、SettingsPage，负责界面展示与用户操作入口；Application 层包含 AppRuntime、DiscoveryController、ChatPageController、FileTransferCoordinator、TransferServerController 和 TransferProgressStore，负责业务编排和状态暴露；数据层包含 Repository、DAO 和 AppDataBase，负责持久化访问；基础设施层包含 DiscoveryBroadcastService、DiscoverySocketService、FrameCodec、本地文件服务、通知服务和二维码服务，负责平台与网络能力封装。

表4-1  系统分层职责说明
Tab.4-1 System layer responsibility description

层次	主要组件	职责说明
表现层	AppPage、HomePage、ChatPage、SettingsPage	负责响应式布局、设备列表、聊天气泡、设置项和用户操作入口
应用状态层	AppRuntime、DiscoveryController、ChatPageController、FileTransferCoordinator、TransferProgressStore	负责业务编排、状态流转、传输控制和 Provider 暴露
数据访问层	Repository、DAO、AppDataBase	负责设备、地址、消息、附件、设置和统计数据的持久化访问
基础设施层	UDP/TCP Service、FrameCodec、文件服务、通知服务、二维码服务	负责网络通信、协议编解码、文件读写、系统通知和平台能力封装

## 4.2 静态类结构设计

系统的静态类结构以 Controller、Repository、Service 和 Entity 为核心。Controller 负责业务编排，Repository 负责业务数据读写，Service 负责底层能力封装，Entity 或 Table Model 表示持久化对象。表现层页面只依赖 Provider 暴露的状态和控制器方法，不直接依赖 Socket 或 Drift 查询对象。
AppRuntime 是运行时总协调对象，负责根据应用生命周期启动或暂停发现服务和 TCP 服务，并在应用恢复到前台时触发中断传输恢复。DiscoveryController 是设备发现的业务控制器，它接收广播服务解析后的远端设备信息，完成本机过滤、nonce 去重、设备表更新、地址表更新和 TTL 扫描。ChatPageController 是聊天页的业务入口，负责文本消息发送、文件选择后的附件消息创建、失败重试和消息删除。FileTransferCoordinator 是文件传输的核心编排类，负责地址选择、TCP 建连、文件 offer、分片读写、进度上报、暂停取消和完成确认。TransferServerController 则负责接收对端 TCP 连接、解析帧类型并分发文本消息、文件传输、心跳和测速请求。
Repository 层用于屏蔽 Drift 表结构和查询细节。设备仓库负责设备基础信息和连接状态；地址仓库负责多地址历史、可达性和测速结果；消息仓库负责会话消息和附件记录；设置仓库负责主题、语言、传输加密和自动恢复设置；本机资料仓库负责本机显示名称和设备 ID。Service 层面向技术能力，例如 UDP 广播发送、UDP 监听、TCP 连接、FrameCodec 编解码、通知展示和文件系统路径管理。通过这些类型的组合，系统实现了“页面只表达意图，控制器编排业务，仓库管理数据，服务封装技术”的结构。
在对象关系上，RemoteDevice 是会话、地址和传输的聚合根。设备 ID 是远端设备在本机数据库中的稳定标识，聊天消息通过 remoteDeviceId 与设备建立关联，设备地址通过 deviceId 与设备建立关联，附件通过 messageId 与消息建立关联。文件传输时，业务层并不直接以文件路径作为任务身份，而是以 attachmentId 作为传输过程中的稳定标识。这样可以把同一个附件在 UI、数据库、通知和传输进度中的状态关联起来，避免仅依靠文件名造成冲突。
页面类不承担领域对象职责。HomePage 负责展示设备列表和桌面端双栏聊天区域，ChatPage 负责展示某一设备的会话，SettingsPage 负责展示本机资料和全局设置。页面中的点击、长按、输入、选择文件等事件会被转换成 Controller 方法调用。Controller 再决定是否需要查询地址、创建消息、发送帧、更新数据库或报告错误。该设计使页面代码更接近界面描述，业务判断集中在应用层，后续调整 UI 样式时不需要修改协议和数据库逻辑。

系统核心类之间的职责划分和依赖方向较为明确。AppRuntime 聚合 DiscoveryController、TransferServerController 和 FileTransferCoordinator，用于统一协调应用运行期网络能力；DiscoveryController 依赖广播发送服务、广播接收服务、设备仓库和地址仓库，负责发现链路；ChatPageController 依赖消息仓库、地址仓库和文件传输协调器，负责会话操作；FileTransferCoordinator 依赖消息仓库、地址仓库、传输通知服务、传输进度存储和 FrameCodec，负责文件传输编排；Repository 依赖 DAO，DAO 依赖 AppDataBase。

表4-2  核心类职责说明
Tab.4-2 Core class responsibility description

类名	所属层次	主要职责
AppRuntime	应用状态层	协调应用生命周期、通知权限、发现服务、TCP 服务和中断传输恢复
DiscoveryController	应用状态层	处理发现广播、设备去重、地址落库、TTL 过期和测速触发
ChatPageController	应用状态层	处理文本发送、附件消息创建、文件选择、重试和删除操作
FileTransferCoordinator	应用状态层	编排文件发送、接收、分片、确认、暂停、取消和恢复
TransferServerController	应用状态层/基础设施协作	监听 TCP 连接并分发文本、文件、心跳和测速帧
TransferProgressStore	应用状态层	以附件 ID 为键保存传输方向、阶段、字节进度、速度和错误信息
Repository/DAO	数据访问层	封装数据库查询、写入、更新和响应式监听
FrameCodec	基础设施层	负责 TCP 帧编码和解码，保证二进制数据边界清晰

## 4.3 动态交互设计

设备发现、文本消息发送和文件传输是系统最关键的三个动态交互场景。动态交互分析强调对象之间的消息调用顺序，而不是用户在页面上的点击流程，因此更符合面向对象开发类论文的设计要求。系统动态交互设计遵循两个原则：第一，用户操作先转化为 Controller 方法调用，再由 Controller 编排 Repository 和 Service；第二，所有会影响 UI 的结果都写入数据库或 Riverpod 状态，由 Provider 统一推送到页面。

设备发现过程采用运行时统一启动、控制器统一处理、页面订阅状态变化的方式。应用进入前台后，AppRuntime 调用 DiscoveryController 启动发现流程；DiscoveryController 启动 DiscoveryBroadcastService 和 DiscoverySocketService，前者周期性发送本机公告，后者监听并解析对端公告；DiscoveryController 对收到的 payload 进行本机过滤和 nonce 去重，随后通过 DeviceRepository 与 DeviceAddressRepository 写入设备和地址信息；HomePage 通过 Provider 订阅设备列表变化并刷新界面。
设备发现交互还需要考虑多网卡、重复广播和离线判断。广播发送服务会枚举可用 IPv4 地址，并优先使用计算得到的广播地址发送公告；如果无法得到精确广播地址，则使用 255.255.255.255 作为兜底目标。广播接收服务收到 payload 后不直接修改 UI，而是交给发现控制器校验协议版本、设备 ID、TCP 端口和地址列表。发现控制器会过滤本机设备和短时间内重复的 nonce，然后把远端设备和地址写入本地数据库。TTL 扫描每 3 秒执行一次，如果 12 秒内没有再次收到某地址的广播，则将地址标记为不可达；当设备没有任何可达地址时，设备列表显示为离线状态。

文本消息发送采用“本地创建、网络发送、远端确认、状态回写”的处理过程。用户在 ChatPage 输入文本并触发发送后，ChatPageController 先通过 MessageRepository 创建 pending 状态的本地消息；随后 DeviceAddressRepository 返回远端可达地址，TransferConnection 建立 TCP 连接，FrameCodec 将消息编码为 textMessage 帧并发送给 RemoteDevice；远端设备返回确认帧后，MessageRepository 将消息状态更新为 sent；如果连接或确认失败，消息状态更新为 failed。
文本消息采用“先落库、再发送、后确认”的设计。先落库可以保证即使网络发送失败，用户仍然能够在聊天页看到失败消息并进行重试；发送阶段通过可达地址建立 TCP 连接并发送 textMessage 帧；确认阶段等待对端返回 textMessageAck。如果连接建立失败、确认超时或远端返回错误帧，消息状态会更新为 failed，并记录错误信息。聊天页通过会话 Provider 监听消息表，因此发送状态变化可以自动反映到 UI。

文件传输采用“附件消息创建、文件协商、分片传输、完成确认”的处理过程。用户在 ChatPage 选择文件后，ChatPageController 创建附件消息，FileTransferCoordinator 检查文件大小并选择可达地址；发送端先发送 fileOffer，远端返回 fileOfferAck 后开始按 1MB 分片发送 fileChunk；接收端在写入分片后定期返回 fileChunkAck，TransferProgressStore 持续更新 UI 和通知进度；全部分片发送后，发送端发送 fileComplete，远端完成校验并返回 fileCompleteAck，双方更新附件状态为完成。
文件传输采用“控制帧 + 数据帧 + 进度状态”的交互模型。控制帧负责协商文件元信息和完成确认，数据帧负责承载二进制分片。发送端在读取文件前校验大小上限，避免超出系统设定的 16GB 范围；读取时按 1MB 分片流式发送，不把完整文件一次性加载到内存。接收端在收到 offer 后创建本地接收文件，并将文件写入下载目录的 Hydrop 文件夹。进度以附件 ID 为键写入 TransferProgressStore，UI 和通知服务都从同一份进度快照读取数据，避免出现页面进度和通知进度不一致的问题。
异步交互设计遵循“事件进入、状态落点、界面订阅”的路径。用户操作、UDP 广播、TCP 帧、文件 I/O 和系统生命周期事件都属于输入事件；事件进入 Controller 后被转换为数据库更新或 Riverpod 状态更新；界面只订阅这些状态，不主动轮询网络和文件系统。设备页订阅设备列表和最近消息摘要，聊天页订阅会话消息和附件进度，设置页订阅设置项和本机资料。该方式可以降低页面之间的耦合，也能让同一状态同时服务于手机端单栏界面和桌面端双栏界面。
对于可能耗时的任务，系统采用异步 Future 和 Stream 组合。发现广播按周期执行，收到 payload 后异步写入设备和地址；文件传输按分片顺序处理，每个分片发送后更新进度；接收端在数据到达后立即写入文件并报告进度。由于 Flutter UI 线程需要保持流畅，系统避免在页面构建过程中执行文件读取、哈希计算和网络等待。耗时操作由应用层或基础设施层完成，页面只根据 Provider 返回的加载、成功和错误状态决定展示内容。

## 4.4 状态迁移设计

系统中最重要的状态对象是设备连接状态、消息发送状态和附件传输状态。状态迁移分析用于描述对象生命周期及触发状态变化的事件，适合放在系统设计章节。状态设计的目标是让 UI 能清楚表达“正在处理、已经完成、发生错误、等待用户操作”等状态，同时保证异常发生后能够落库并恢复。

附件传输任务围绕 pending、transferring、paused、completed 和 failed 五类状态进行迁移。附件任务从 pending 状态开始，远端确认 offer 后进入 transferring 状态；分片传输过程中，用户暂停会使任务进入 paused 状态，用户取消、连接失败或校验失败会使任务进入 failed 状态；当全部分片发送、校验和完成确认均成功后，任务进入 completed 状态。paused 状态可在用户恢复或系统自动恢复后重新进入 transferring；completed 是正常终态，failed 是异常终态。
消息发送状态包括 pending、sending、sent、failed 和 received。发送端消息从 pending 进入 sending，收到确认后进入 sent，超时或连接异常进入 failed；接收端消息进入 received。设备状态包括 localNetwork 与 disconnected，设备收到广播时进入在线状态，TTL 到期时进入离线状态。
传输进度状态不仅包含阶段，还包含方向、已传字节、总字节、瞬时速度、更新时间和错误信息。方向用于区分发送端和接收端；字节数用于计算百分比；速度由相邻两次进度快照的字节差和时间差计算；错误信息用于在 UI 中展示失败原因。该设计使同一个附件卡片既能表达发送中的进度，也能表达接收中的进度，并支持暂停、取消、失败和完成后的状态展示。
状态迁移设计还区分了可持久化状态和瞬时状态。消息发送状态、附件传输状态、已传字节、文件路径、错误原因等信息需要写入数据库，因为它们直接影响历史记录和重启后的恢复。输入框焦点、设置页选中的分区、设备搜索关键字等信息只影响当前界面，不需要持久化。通过这种划分，数据库不会保存大量临时 UI 状态，应用重启后也能恢复真正影响业务连续性的记录。
异常状态是状态迁移设计中的重点。文本消息发送失败后保留消息记录并显示失败状态，用户可以根据错误提示决定是否重试或删除；文件传输失败后保留附件记录和错误原因，避免用户误以为文件已经成功发送；设备 TTL 过期后不会删除设备，而是把设备显示为离线，便于用户查看历史会话。长按删除设备记录属于用户主动清理设备列表的操作，与自动离线判断不同，因此需要单独设计入口和确认反馈。

表4-3  核心状态迁移说明
Tab.4-3 Core state transition description

状态对象	主要状态	触发事件	设计目的
设备连接	localNetwork、disconnected	收到广播、TTL 过期、测速失败	表示设备是否仍在局域网可见，支撑设备列表排序和置灰显示
文本消息	pending、sending、sent、failed、received	创建消息、发送开始、收到 ACK、超时或接收消息	保证消息发送失败可见、可重试，接收消息可持久化
文件附件	pending、transferring、paused、completed、failed	创建附件、offer 确认、分片进度、暂停取消、完成或失败	支撑大文件传输的进度展示、暂停取消和异常恢复
应用运行时	foreground、background maintenance、paused	应用前台、后台、维护窗口结束	统一管理发现服务和 TCP 服务，降低资源占用

## 4.5 通信协议设计

发现协议基于 UDP 广播。广播目标端口为 39175，payload 类型为 hydrop.discovery.hello，协议版本为 1。payload 包含设备 ID、显示名称、TCP 端口 39176、能力列表、nonce、发送时间和地址列表。nonce 用于短时间内过滤重复广播，地址列表用于记录对端在不同网卡或地址族下的可达信息。
发现协议采用 UDP 的原因是设备发现强调低成本、低延迟和无需预先建立连接。广播 payload 中的能力列表用于声明设备支持文本、图片、视频、普通文件和测速能力；地址列表用于处理多网卡场景，使对端可以记录不同网卡下的候选 IP 和端口。广播间隔设计为 10 秒，既可以让设备列表及时刷新，又避免过于频繁地占用局域网带宽。设备 TTL 设计为 12 秒，略长于广播间隔，使偶发丢包不会立刻导致设备离线；TTL 扫描间隔为 3 秒，用于较快地将长期不可见设备置为离线。
TCP 通信协议基于 FrameCodec。每个帧由 4 字节 header 长度、4 字节 body 长度、JSON header 和 binary body 组成。header 中包含帧类型、协议版本、消息 ID、附件 ID、文件名、文件大小、偏移量、校验方式等元信息；body 用于承载文本内容或文件分片二进制数据。该设计避免了文本行协议在二进制传输中的边界问题，也使文本消息和文件传输可以使用统一连接语义。
FrameCodec 的 header 使用 JSON 是为了保证协议字段具备可读性和扩展性，body 使用二进制是为了避免文件内容经过文本编码导致体积膨胀。协议为 header 和 body 分别设置最大长度限制，header 最大 16KB，单个 body 最大 1MB，防止异常数据包导致内存占用失控。所有帧都携带协议版本和帧类型，接收端可以根据类型分发到文本、文件、心跳、测速或错误处理逻辑。
文件传输协议由控制帧和数据帧组成。发送端先发送 fileOffer，接收端校验后回复 fileOfferAck，随后发送端按 1MB 分片发送 fileChunk，接收端定期返回 fileChunkAck。文件发送完成后，发送端发送 fileComplete，接收端完成校验与落盘后回复 fileCompleteAck。异常情况下双方可发送 error 帧并更新本地状态。
文件传输协议还包含可靠性控制。发送端对分片发送设置重试次数，连续失败后将任务置为失败；接收端根据 offset 和 attachmentId 识别当前附件进度，并定期回传 chunk ack。系统限制最大并发传输数为 2，避免多个大文件同时竞争网络和磁盘资源。心跳帧用于判断长时间无数据时连接是否仍然有效，连接异常时 UI 可及时进入 failed 或 paused 状态。对于可恢复传输，系统会保存断点元数据，应用重启后由运行时尝试恢复中断任务。
协议字段设计采用“必要字段固定、扩展字段可追加”的方式。发现 payload 中固定包含类型、协议版本、设备 ID、显示名称、TCP 端口和能力列表；传输帧 header 固定包含帧类型和协议版本，不同帧再追加各自所需的消息 ID、附件 ID、偏移量、文件名、文件大小或错误原因。接收端先校验协议版本和帧类型，再进入具体处理分支。这样可以在后续增加缩略图、加密参数或更细的传输阶段时，减少对已有帧结构的破坏。
协议设计还考虑了边界与错误输入。FrameCodec 在解码前先读取 header 长度和 body 长度，并检查它们是否超过上限；header 必须是 JSON 对象，body 长度不能超过单帧上限。对于设备发现，系统会过滤本机设备和重复 nonce，避免同一设备的重复广播不断写入数据库。对于文件传输，系统限制最大文件大小和最大并发数，防止误选超大文件或同时传输过多文件导致内存、磁盘和网络压力失控。

表4-4  通信协议关键参数
Tab.4-4 Key communication protocol parameters

参数	取值	设计说明
UDP 发现端口	39175	用于局域网设备广播与监听
TCP 传输端口	39176	用于文本消息、文件传输、心跳和测速帧
发现广播间隔	10 秒	平衡发现实时性与网络开销
设备 TTL	12 秒	超过该时间未刷新则标记为离线
TTL 扫描间隔	3 秒	周期性检查设备地址是否过期
单帧 header 上限	16KB	限制协议元数据大小
单帧 body 上限	1MB	作为文件分片大小，避免大块内存占用
最大文件大小	16GB	防止误选超大文件导致磁盘和传输风险
最大并发传输	2	控制网络和磁盘资源竞争
心跳间隔/超时	20 秒/18 秒	用于发现连接空闲或异常中断

## 4.6 界面与部署设计

界面风格采用黑白灰、直角、2px 内部分割线和 Material 组件。页面像表格一样只保留内容之间的内边框，去掉外围装饰边框，避免使用大面积背景图。按钮、输入框、列表项和面板均采用直角设计，在线设备使用正常文本颜色，不在线设备使用灰色文本。
一级入口只保留设备页和设置页。移动端使用底部导航，桌面端使用左侧导航。设备页在手机上为单栏列表，点击设备后进入聊天页；桌面端为双栏布局，左侧显示设备列表，右侧显示选中设备的聊天内容。设置页在不同宽度下调整排列方式，桌面端可使用多列布局，移动端使用单列纵向排列。
响应式设计采用窗口等级划分：小于 600 像素为 compact，600 到 839 像素为 medium，840 到 1199 像素为 expanded，1200 像素及以上为 large。compact 与 medium 使用底部导航，expanded 与 large 使用左侧导航。设备页在 expanded 宽度下设备列表宽度为 320 像素，在 large 宽度下为 360 像素；页面边距控制在较小范围，使内容尽量占满可用空间。该设计保证手机端保持单手可用，桌面端则提高信息密度，减少设备列表和聊天内容之间的来回切换。
聊天界面采用类即时通信软件布局。消息气泡按发送与接收方向左右排列，接收消息使用黑色背景，发送消息使用白色背景，深色主题下保持对应反差。图片消息支持内联预览，文件消息展示文件名、大小、状态、速度和进度。消息操作默认收敛到长按或悬停菜单，减少常态界面的视觉干扰。输入栏为方形，聚焦后边框加重，弹窗统一使用 bottom sheet。
设置页在设计上承担原本本机资料页的能力，因此设置页不是单纯的偏好配置页，而是系统信息和全局配置的聚合入口。其左侧或上层列表包含本机资料、外观、传输、发现、隐私和关于等分区；桌面端右侧展示所选分区详情，移动端通过 bottom sheet 展示详情内容。所有弹窗统一使用 bottom sheet，可以保持手机端和桌面端交互一致，也避免普通 AlertDialog 在复杂响应式布局中产生尺寸问题。
界面信息密度按设备类型调整。手机端宽度有限，因此设备页只展示列表，进入聊天后再展示消息内容；桌面端有足够横向空间，设备列表和聊天内容并排显示，减少用户在设备列表和会话之间的来回跳转。设置页也采用同样思路：手机端点击设置项后使用 bottom sheet 展开详情，桌面端直接在右侧展示详情。这样的响应式设计并不是简单放大或缩小控件，而是根据窗口宽度改变信息组织方式。
交互设计以“少入口、少干扰、状态可见”为原则。一级导航只保留设备和设置两个入口，传输页不作为一级页面出现；聊天消息的复制、删除、保存等操作收敛到长按或悬停菜单，常态下只展示消息内容和传输状态；文件传输中的进度、速度、暂停、取消、完成和失败状态直接显示在附件卡片中，使用户无需进入单独页面即可判断传输情况。设置类操作统一放入设置页，避免本机资料、二维码、主题和语言入口分散在多个页面。

系统在局域网环境中采用对等部署方式。Device A 与 Device B 是两个同构节点，每个节点内部都包含 Flutter App、SQLite 数据库、下载目录 Hydrop 文件夹、UDP 发现端口 39175 和 TCP 传输端口 39176。两个节点之间通过 UDP 广播链路完成设备发现，通过 TCP Socket 链路完成文本消息和文件传输。操作系统作为外部运行环境，为应用提供文件选择、通知、网络接口和应用生命周期能力。
部署设计中每台设备都是独立节点，既可以作为发送端，也可以作为接收端。应用不依赖中心服务器，设备发现和数据传输都在局域网内完成。SQLite 数据库存储在本机应用数据目录中，接收到的文件保存到下载目录的 Hydrop 文件夹下。操作系统为应用提供网络接口枚举、文件选择、通知权限和应用前后台生命周期事件。移动端可能受到后台运行限制，因此系统进入后台后不保持连续广播，而是采用低频短窗口维护方式，尽量兼顾能耗与可用性。

## 4.7 数据持久化与一致性设计

系统采用本地 SQLite 数据库保存核心业务数据。数据库设计围绕“设备、地址、会话、消息、附件、设置、本机资料、统计”展开。设备表记录远端设备的稳定身份和在线状态；设备地址表记录同一设备在不同网络环境下出现过的 IP、端口和网卡信息；消息表记录文本消息和附件消息的基本信息；附件表记录文件名、本地路径、传输状态、已传字节、校验值和缩略图路径。这样的表结构使设备发现、聊天记录和文件传输能够在同一个本地数据模型中关联起来。
数据一致性主要通过稳定业务 ID 和唯一约束完成。设备使用 deviceId 识别，地址使用设备 ID、IP 和端口组合识别，消息使用本地消息 ID 识别，附件使用 attachmentId 识别。设备发现可能在短时间内收到多次相同广播，文本消息可能因重试产生重复确认，文件传输也可能在失败恢复时重复写入进度；这些场景都需要数据库层的唯一约束和仓库层的 upsert 操作共同处理。这样可以减少重复记录，也能让 UI 始终订阅同一条业务记录。
数据库状态和 Riverpod 状态的边界也在设计阶段明确。数据库保存可恢复状态，Riverpod 保存可观察状态。设备列表、消息时间线和设置项可以直接由数据库 Stream 驱动；传输进度则具有较高刷新频率，如果每一次进度变化都立即写入数据库，会增加磁盘压力，因此系统采用进度存储向 UI 高频推送，同时按时间间隔和字节阈值将关键进度持久化。传输完成、失败、暂停等终态不受节流影响，需要及时写入数据库，保证界面和历史记录一致。

## 4.8 可维护性与扩展性设计

系统后续可能继续增加端到端加密、缩略图生成、传输队列、历史文件清理、复杂网络发现方式和更完整的性能测试。为便于扩展，设计中尽量把变化点集中在明确模块内。协议字段扩展集中在 payload 和 FrameCodec header 中；传输策略扩展集中在 FileTransferCoordinator；发现方式扩展集中在发现控制器和发现服务；设置项扩展集中在设置仓库和设置页；UI 样式扩展集中在通用组件和响应式工具类中。
可维护性设计还体现在错误处理和日志边界上。网络和文件传输错误由应用层捕获后转换为业务状态，页面不直接处理底层异常栈；通知、toast 和应用内提示只是反馈渠道，不决定传输主流程是否成功；数据库异常需要在仓库层处理，避免异常穿透到页面构建过程。这样设计可以让每个模块只处理自己能理解的错误，并把用户可见状态稳定地呈现在设备页、聊天页和设置页中。

# 5 系统实现

本章说明系统从设计到代码的落地方式。根据论文结构要求，本章不直接放置代码清单，只描述关键实现思路、模块职责和运行机制；关键代码统一整理到附录 C。

## 5.1 启动与运行时实现

应用启动流程为 main.dart -> ProviderScope -> MainApp -> appRuntimeProvider。入口创建 Riverpod 容器，并注入 Talker 的 Riverpod 观察器。MainApp 负责应用级主题、语言、路由和生命周期处理：应用恢复到前台时调用运行时恢复网络能力，应用进入非前台状态时暂停发现服务和传输服务，并保留短窗口后台维护能力。
运行时对象 AppRuntime 负责协调通知权限、发现服务、传输服务和中断传输恢复。它在创建时请求通知权限并尝试恢复中断传输；在前台恢复时启动 DiscoveryController 和 TransferServerController；在后台或暂停状态下停止实时发现和 TCP 服务，降低资源占用并避免连接状态混乱。

## 5.2 路由与响应式主界面实现

系统路由只包含两个一级页面和一个会话页面。AppRoute 作为应用主壳，内部挂载 HomeRoute 与 SettingsRoute；ChatRoute 独立存在，用于从设备页进入指定设备的聊天页面。ChatRoute 携带远端设备 ID 和显示名称，保证聊天页可以明确绑定设备上下文。
主界面使用响应式窗口等级决定导航形态。桌面端使用左侧导航栏，导航项只包含设备页和设置页；移动端使用底部导航栏。设备页在桌面端可与聊天区组成双栏，在移动端则采用单栏列表并通过路由进入聊天页。该实现方式减少了页面入口数量，也符合当前程序只保留设备页和设置页两个一级 tab 的产品形态。

## 5.3 设备发现实现

设备发现由发现控制器、广播发送服务、广播接收服务、设备仓库和地址仓库协作完成。发现控制器启动后，广播服务周期性发送本机公告，公告内容包含 payload 类型、协议版本、设备 ID、显示名称、TCP 端口、能力列表、nonce、发送时间和地址列表。接收服务监听 UDP 39175 端口，解析收到的公告并传递给发现控制器。
发现控制器收到 payload 后，先过滤本机设备和重复 nonce，再将设备信息写入设备表，将地址信息写入设备地址表，并根据可达地址触发测速调度。TTL 扫描定时检查设备地址的最后可见时间，当超过 12 秒没有刷新时，将对应设备置为离线状态。设备页通过 Provider 订阅设备列表，因此数据库或状态更新后可以自动刷新 UI。

## 5.4 消息与文件传输实现

文本消息和文件传输均基于 TCP 39176 端口和 FrameCodec 帧协议实现。FrameCodec 使用 4 字节 header 长度、4 字节 body 长度、JSON header 和 binary body 组织数据帧。文本消息使用 textMessage 和确认帧完成发送状态闭环；文件传输使用 fileOffer、fileOfferAck、fileChunk、fileChunkAck、fileComplete 和 fileCompleteAck 完成传输闭环。
文件发送由文件传输协调器负责。发送端先创建附件消息并检查文件大小，随后选择可达地址并建立 TCP 连接。文件内容按 1MB 分片读取和发送，不把完整文件一次性加载到内存。接收端收到文件 offer 后创建接收记录，按分片写入下载目录下的 Hydrop 文件夹，并在完成后进行校验和状态更新。传输过程中若发生连接中断、确认超时、用户暂停或用户取消，系统会关闭对应连接并更新附件状态。

## 5.5 传输进度与通知实现

传输进度由 Riverpod 统一管理。系统以附件 ID 为键保存传输进度快照，快照内容包括传输方向、阶段、已传字节、总字节、速度、更新时间和错误信息。聊天页中的附件卡片按附件 ID 订阅进度，因此只需要刷新相关附件的 UI。
通知服务用于在系统通知中显示传输进度。移动端使用临时 toast 显示轻量提示，桌面端使用应用内提示组件。通知能力属于辅助反馈，如果通知插件初始化失败，系统不会中断文件传输主链路，而是记录错误并继续执行传输。

## 5.6 设备页、聊天页与设置页实现

设备页使用设备相关 Provider 渲染列表。每个设备项展示名称、速度、最后一次传输和在线状态。不在线设备文本置灰。长按设备项会打开底部菜单，提供删除设备显示记录的操作；该操作删除设备列表中的记录，而不是仅清空聊天消息。
聊天页从设备上下文进入，页面根据远端设备 ID 读取消息时间线。文本消息以聊天气泡展示；图片消息支持内联预览；视频和普通文件以附件卡片展示，卡片中包含文件名、大小、状态、进度和速度。消息删除只删除消息记录，默认不删除本地文件。
设置页是当前一级入口之一，并整合本机资料能力。它展示和维护本机显示名称、设备 ID、二维码连接、本地 IP、诊断信息、主题、语言、传输加密开关和自动恢复传输开关。本机显示名称支持直接在页面上修改，不再通过独立弹窗完成。

## 5.7 数据库存储与消息/会话持久化实现

数据库由 AppDataBase 统一管理。当前版本数据库版本号为 1，首次创建时生成全部表并创建自定义唯一索引；打开数据库前启用 SQLite 外键约束。系统处于第一版开发阶段，因此不保留升级迁移逻辑。
设备表保存远端设备显示名称、设备 ID、连接状态、平均传输速度和最近传输时间；设备地址表保存设备 IP、端口、网卡、网络签名、可达状态和最后可见时间；连接会话表保存 TCP 会话状态、协议版本、心跳和断开信息；设置表保存主题、语言、传输加密和自动恢复传输偏好；本机资料表保存本机显示名称和本机设备 ID；消息表与附件表保存聊天内容和文件传输状态；统计表保存首次启动、发现设备数和发送统计。
自定义唯一索引用于约束设备地址、消息本地 ID 和附件 ID，避免重复广播或重试写入造成数据冲突。消息表记录文本、方向、类型、发送状态、本地消息 ID、远端消息 ID 和错误信息。附件表记录文件路径、保存状态、下载进度、附件 ID、文件名、MIME 类型、总字节、已传字节、校验值、缩略图路径和传输状态。

## 5.8 数据库表设计

本节对系统中涉及的核心数据库表进行说明。系统采用 Drift 进行本地持久化管理，围绕设备发现、地址记忆、连接会话、应用设置、本机资料、消息内容、消息附件与统计信息等业务场景，共设计 8 张核心数据表。各表通过设备 ID、消息 ID、附件 ID 和会话 ID 建立关系，满足设备发现、聊天记录、文件传输和设置恢复的持久化需求。

表5-1  数据库表功能概览
Tab.5-1 Overview of database table functions

表名	中文名称	主要用途
device_items	设备信息表	保存发现到的远端设备、连接状态、速度和最后传输时间
device_address_items	设备地址表	保存设备 IP、端口、网卡、网络签名、可达状态和最后可见时间
connection_session_items	连接会话表	保存 TCP 会话 ID、关联设备、协议版本、心跳和断开信息
setting_items	设置表	保存主题、语言、传输加密和自动恢复传输设置
mine_items	本机资料表	保存本机显示名称和本机设备 ID
message_items	消息表	保存文本消息、消息方向、消息类型、发送状态和错误信息
message_attachment_items	消息附件表	保存附件路径、文件名、进度、校验值、缩略图和传输状态
point_items	统计表	保存首次启动时间、聊天设备数、发现设备数和发送统计

表5-2  设备信息表（device_items）
Tab.5-2 Device information table (device_items)

字段名	类型	说明
id	integer	自增主键
display_name	text	设备显示名称，长度 1-32
device_id	text	远端设备唯一 ID，唯一约束
connection_status	text	连接状态：localNetwork、disconnected 等
average_transfer_speed_bytes_per_second	integer	平均传输速度
last_connected_at	datetime	最近连接时间
last_disconnected_at	datetime	最近断开时间
last_transfer_at	datetime	最近传输时间
last_error	text	最近错误信息

表5-3  设备地址表（device_address_items）
Tab.5-3 Device address table (device_address_items)

字段名	类型	说明
id	integer	自增主键
device_id	text	关联设备 ID，外键关联 device_items.device_id
ip_address	text	IP 地址
ip_version	text	地址版本：ipv4 或 ipv6
port	integer	TCP 端口
interface_name	text	网卡名称
network_signature	text	网络签名
subnet_mask	text	子网掩码
gateway_address	text	网关地址
broadcast_address	text	广播地址
source	text	地址来源：broadcast、manual、remembered
is_reachable	boolean	是否可达
latency_ms	integer	探测延迟
average_transfer_speed_bytes_per_second	integer	平均传输速度
last_seen_at	datetime	最近发现时间
last_success_at	datetime	最近成功连接时间
last_failure_at	datetime	最近失败时间
failure_reason	text	失败原因
created_at	datetime	创建时间
updated_at	datetime	更新时间

表5-4  连接会话表（connection_session_items）
Tab.5-4 Connection session table (connection_session_items)

字段名	类型	说明
id	integer	自增主键
session_id	text	会话唯一 ID
device_id	text	关联设备 ID
device_address_id	integer	关联设备地址 ID，可为空
state	text	会话状态：connecting、ready、disconnected、failed
protocol_version	integer	协议版本
connected_at	datetime	连接时间
last_heartbeat_at	datetime	最近心跳时间
disconnected_at	datetime	断开时间
last_error	text	最近错误信息

表5-5  设置表（setting_items）
Tab.5-5 Settings table (setting_items)

字段名	类型	说明
id	integer	自增主键
theme_mode	text	主题：system、light、dark
language	text	语言：system、en、zhHans、zhHant
transfer_encryption_enabled	boolean	传输加密开关
auto_resume_transfers_enabled	boolean	自动恢复传输开关

表5-6  本机资料表（mine_items）
Tab.5-6 Local profile table (mine_items)

字段名	类型	说明
id	integer	自增主键
display_name	text	本机显示名称
device_id	text	本机唯一设备 ID

表5-7  消息表（message_items）
Tab.5-7 Message table (message_items)

字段名	类型	说明
id	integer	自增主键
remote_device_id	text	关联远端设备 ID
text_content	text	文本内容
created_at	datetime	创建时间
updated_at	datetime	更新时间
direction	text	消息方向：sent、received
message_type	text	消息类型：text、image、video、file、link
send_status	text	发送状态：pending、sending、sent、failed、received
local_message_id	text	本地消息 ID
remote_message_id	text	远端消息 ID
error_message	text	错误信息
read_at	datetime	已读时间

表5-8  消息附件表（message_attachment_items）
Tab.5-8 Message attachment table (message_attachment_items)

字段名	类型	说明
id	integer	自增主键
message_id	integer	关联消息 ID
save_status	text	保存状态
file_path	text	本地文件路径
download_progress	integer	下载进度百分比
attachment_id	text	附件唯一 ID
file_name	text	文件名
mime_type	text	MIME 类型
total_bytes	integer	文件总字节
transferred_bytes	integer	已传字节
checksum_sha256	text	SHA-256 校验值
thumbnail_path	text	缩略图路径
transfer_status	text	传输状态
transfer_task_id	text	传输任务 ID
created_at	datetime	创建时间
updated_at	datetime	更新时间

表5-9  统计表（point_items）
Tab.5-9 Statistics table (point_items)

字段名	类型	说明
id	integer	自增主键
first_launch_at	datetime	首次启动时间
chatted_device_count	integer	聊天过的设备数量
discovered_device_count	integer	发现过的设备数量
sent_text_character_count	integer	已发送文本字符数
sent_file_bytes	integer	已发送文件字节数

# 6 系统测试与结果分析

## 6.1 功能测试

功能测试围绕设备发现、文本通信、文件收发、暂停取消、设置切换和本机资料展示等关键流程展开。测试环境为同一局域网内的移动端设备和桌面端设备，测试方法为手动操作并观察应用界面、数据库记录和日志输出是否符合预期。
设备发现测试：启动两台设备上的应用，验证双方是否能在设备页看到对方。测试关注设备名称、在线状态、地址记录、速度摘要和最后一次传输时间是否正确展示；关闭其中一台设备后，另一台设备应能在 TTL 失效后将其标记为离线。
文本通信测试：在设备页选择远端设备进入聊天页，发送多条文本消息，验证本地消息是否先以待发送状态展示，发送成功后是否更新为已发送；接收端是否能显示收到的文本消息；发送失败时是否展示失败状态和错误信息。
文件传输测试：分别选择图片、视频和普通文件发送给远端设备，验证发送端和接收端的附件消息、进度、速度、暂停、取消、失败反馈和完成状态是否正确。接收端文件应保存到下载目录下的 Hydrop 文件夹中。
设置测试：在设置页切换浅色、深色和跟随系统模式，切换系统语言、英文、简体中文和繁体中文，修改本机显示名称，验证界面是否即时更新并在重启后恢复。二维码连接、本地 IP、诊断信息和传输偏好开关也应保持可用。

## 6.2 工程测试

工程测试从代码质量、路由结构、数据库结构和 Provider 依赖四个维度进行。
静态分析：通过 Flutter/Dart 静态分析检查类型错误、无效引用和明显代码问题，确保路由参数、Provider 类型、数据库表字段和平台插件调用在编译阶段保持一致。
路由验证：检查路由表中一级页面只包含 HomeRoute 和 SettingsRoute，并确认 ChatRoute 需要远端设备 ID 和显示名称作为上下文。该验证确保设备页、设置页和聊天页的页面层级与产品设计一致。
数据库验证：创建全新数据库后，检查 schemaVersion = 1，确认 8 张表和自定义唯一索引创建成功。因为系统处于第一版开发阶段，不进行升级迁移测试。
Provider 验证：检查设备发现、设置、聊天会话和传输进度 Provider 的依赖关系，确认底层状态变化后 UI 能自动刷新，且传输进度可通过 transferProgressProvider 按附件 ID 单独订阅。

## 6.3 性能/稳定性分析

性能与稳定性分析采用保守描述，不写未经自动化基准验证的吞吐量、耗时和内存峰值。系统在设计上通过 1MB 分片、流式文件读取、TCP 帧协议、有限并发、分片确认和进度节流降低大文件传输风险。发送链路不把完整文件读入内存，接收链路直接写入下载目录下的 Hydrop 文件夹，适合处理大文件场景。由于系统主要运行在 Wi-Fi 局域网环境中，后续性能评估还应结合实际网络环境进行分析。
稳定性重点关注网络中断、连接超时、确认超时、文件过大、通知插件失败和数据库唯一约束冲突等异常。系统在传输链路中提供错误捕获和状态回写，UI 可显示 failed、paused、completed 等阶段；应用前后台切换时由运行时管理发现服务和传输服务，减少后台状态不一致问题。
系统仍可从生产级能力上继续增强，包括更细致的自动化压力测试、跨平台长时间运行测试、复杂网络环境下的重连策略、端到端加密、传输队列优先级、缩略图生成和历史文件清理策略。若后续实现加密传输，可进一步完善密钥协商、身份认证和传输机密性设计。

## 6.4 测试结论

测试结果表明，系统能够在局域网环境下完成从设备发现到文本通信、文件传输和设置持久化的完整闭环。设备页和设置页两个一级入口满足移动端与桌面端的主要使用路径；聊天页从设备上下文进入，能够展示文本、图片、视频和文件消息；传输进度通过 Riverpod 统一暴露，能够支撑 UI、通知和错误反馈。
系统的主要优势在于：跨平台单代码库、自动设备发现、TCP 帧协议、流式大文件传输、响应式界面、设置持久化和中断恢复能力。后续测试工作应重点补充自动化性能基准、长时间稳定性验证和复杂网络环境验证。

# 7 结论

本文完成了基于 Flutter 的跨平台局域网文件传输系统的设计与实现，形成了较完整的工程架构与可运行产品。系统采用分层架构，围绕设备发现、聊天会话、文件传输、传输进度、本地持久化和设置管理构建核心能力。
在技术实现方面，系统通过 UDP 39175 端口广播实现局域网内设备自动发现，通过 TCP 39176 端口和 FrameCodec 帧协议实现文本消息与文件数据传输；通过 Riverpod 实现响应式状态管理，通过 Drift 实现本地数据持久化，通过 AutoRoute 实现类型安全路由。界面只保留设备页和设置页两个一级入口，移动端使用底部导航，桌面端使用左侧导航，设备页在桌面端提供设备列表与聊天内容双栏布局。
在工程实践方面，项目验证了 Flutter 在网络密集型局域网应用中的可行性。Dart 的异步 Stream、Socket、文件 I/O 与 Flutter 的响应式 UI 结合，可以支持设备发现、文件分片传输、进度展示、通知反馈和多语言设置等复杂功能。
系统的主要创新点包括：（1）采用“发现与传输分离”的通信架构，UDP 负责轻量级设备发现，TCP 负责可靠数据传输；（2）使用统一 FrameCodec 帧协议承载文本消息和文件数据，便于扩展和错误处理；（3）通过 Riverpod 暴露传输进度流，使 UI、通知和业务状态保持一致；（4）采用移动端单栏、桌面端双栏的响应式界面，提升不同设备上的使用效率。
后续仍可从以下方面继续改进：（1）完善端到端加密与身份认证机制；（2）补充缩略图生成、历史文件清理和更细粒度的传输队列管理；（3）建立自动化性能基准与长时间稳定性测试体系；（4）探索 mDNS/DNS-SD 等补充发现方式，提高复杂网络环境下的发现成功率。

# 参考文献

[1] 杜文. Flutter实战[M].第2版.北京:机械工业出版社,2023.
[2] 郭树煜. Flutter开发实战详解[M].北京:电子工业出版社,2020.
[3] Google. Flutter Documentation[EB/OL].https://docs.flutter.dev,[2026-04-16].
[4] Windmill E. Flutter in Action[M]. Shelter Island, NY: Manning Publications, 2020.
[5] Miles R. Beginning Flutter: A Hands On Guide to App Development[M]. Birmingham: Packt Publishing, 2019.
[6] Riverpod Team. Riverpod Documentation[EB/OL].https://riverpod.dev,[2026-04-16].
[7] AutoRoute Team. AutoRoute Documentation[EB/OL].https://autoroute.vercel.app,[2026-04-16].
[8] SQLite Consortium. SQLite Documentation[EB/OL].https://www.sqlite.org/docs.html,[2026-04-16].
[9] Drift Team. Drift Documentation[EB/OL].https://drift.simonbinder.eu,[2026-04-16].
[10] Stevens W R, Fenner B, Rudoff A M. UNIX Network Programming, Volume 1: The Sockets Networking API[M].3rd ed.Boston:Addison-Wesley,2004.
[11] Tanenbaum A S, Wetherall D J. Computer Networks[M].5th ed.Boston:Pearson,2011.
[12] Postel J. User Datagram Protocol: RFC 768[S].IETF,1980.
[13] Postel J. Transmission Control Protocol: RFC 793[S].IETF,1981.
[14] Eggert L, Fairhurst G. UDP Usage Guidelines: RFC 8085[S].IETF,2017.
[15] Kleppmann M. Designing Data-Intensive Applications[M].Sebastopol, CA:O’Reilly Media,2017.
[16] 张海藩,牟永敏.软件工程导论[M].第6版.北京:清华大学出版社,2013.
[17] 严蔚敏,吴伟民.数据结构:C语言版[M].北京:清华大学出版社,2007.
[18] 何春俐.建模语言UML的研究[J].机械管理开发,2010,25(01):177-178.
[19] 徐夏夏.浅谈面向对象分析与设计[J].福建质量管理,2015(10):228.
[20] NIST. Secure Hash Standard (SHS): FIPS PUB 180-4[S].Gaithersburg, MD:NIST,2015.

# 附录 C 关键代码清单

本附录集中放置正文第 5 章涉及的关键代码。正文部分只说明实现思路和模块职责，避免在实现章节中插入过长代码段。

## C.1 应用入口与运行时初始化

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
}
final appRuntimeProvider = Provider<AppRuntime>((ref) {
  final runtime = AppRuntime(
    discoveryController: ref.watch(discoveryControllerProvider),
    transferServerController: ref.watch(transferServerControllerProvider),
    fileTransferCoordinator: ref.watch(fileTransferCoordinatorProvider),
    transferNotificationService: ref.watch(transferNotificationServiceProvider),
  );
  unawaited(runtime.requestNotificationPermissions());
  unawaited(runtime.resumeInterruptedTransfers());
  ref.onDispose(runtime.dispose);
  return runtime;
});

## C.2 路由与主界面

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
            AutoRoute(page: SettingsRoute.page, path: 'settings'),
          ],
        ),
        AutoRoute(page: ChatRoute.page, path: '/chat'),
      ];
}
return AutoTabsRouter.builder(
  routes: const [HomeRoute(), SettingsRoute()],
  builder: (context, children, tabsRouter) {
    if (windowClass.usesSideNavigation) {
      return Row(
        children: [
          SizedBox(
            width: windowClass.isLarge ? 176 : 160,
            child: _DesktopNavigation(
              activeIndex: tabsRouter.activeIndex,
              onDestinationSelected: tabsRouter.setActiveIndex,
            ),
          ),
          Expanded(child: children[tabsRouter.activeIndex]),
        ],
      );
    }
    return Scaffold(
      body: children[tabsRouter.activeIndex],
      bottomNavigationBar: _MobileNavigation(
        activeIndex: tabsRouter.activeIndex,
        onDestinationSelected: tabsRouter.setActiveIndex,
      ),
    );
  },
);

## C.3 设备发现常量与广播载荷

const discoveryBroadcastPayloadType = 'hydrop.discovery.hello';
const discoveryBroadcastProtocolVersion = 1;
const discoveryBroadcastPort = 39175;
const discoveryTransferPort = 39176;
const discoveryBroadcastInterval = Duration(seconds: 10);
const discoveryBroadcastCapabilities = <String>[
  'text',
  'image',
  'video',
  'file',
  'speed-test-v1',
];
const discoveryDeviceTtl = Duration(seconds: 12);
const discoveryTtlScanInterval = Duration(seconds: 3);
class DiscoveryBroadcastAnnouncement {
  const DiscoveryBroadcastAnnouncement({
    required this.deviceId,
    required this.displayName,
    required this.tcpPort,
    required this.capabilities,
    required this.nonce,
    required this.sentAt,
    required this.addresses,
  });
  Map<String, Object?> toJson() => {
        'type': discoveryBroadcastPayloadType,
        'version': discoveryBroadcastProtocolVersion,
        'deviceId': deviceId,
        'displayName': displayName,
        'tcpPort': tcpPort,
        'capabilities': capabilities,
        'nonce': nonce,
        'sentAt': sentAt.millisecondsSinceEpoch,
        'addresses': addresses.map((address) => address.toJson()).toList(),
      };
}

## C.4 TCP 帧协议与传输参数

class FrameCodec {
  const FrameCodec();
  List<int> encode(TransferFrame frame) {
    final headerBytes = utf8.encode(jsonEncode(frame.header));
    final bodyBytes = List<int>.unmodifiable(frame.body);
    _validateLengths(headerBytes.length, bodyBytes.length);
    final bytes = Uint8List(8 + headerBytes.length + bodyBytes.length);
    final header = ByteData.view(bytes.buffer);
    header.setUint32(0, headerBytes.length, Endian.big);
    header.setUint32(4, bodyBytes.length, Endian.big);
    bytes.setRange(8, 8 + headerBytes.length, headerBytes);
    bytes.setRange(8 + headerBytes.length, bytes.length, bodyBytes);
    return List<int>.unmodifiable(bytes);
  }
}
const transferProtocolVersion = 1;
const transferDefaultPort = 39176;
const transferMaxConcurrentTransfers = 2;
const transferMaxFileBytes = 16 * 1024 * 1024 * 1024;
const transferFrameMaxBodyBytes = 1024 * 1024;
const transferFrameTypeFileOffer = 'fileOffer';
const transferFrameTypeFileOfferAck = 'fileOfferAck';
const transferFrameTypeFileChunk = 'fileChunk';
const transferFrameTypeFileChunkAck = 'fileChunkAck';
const transferFrameTypeFileComplete = 'fileComplete';
const transferFrameTypeFileCompleteAck = 'fileCompleteAck';
const transferFrameTypeError = 'error';

## C.5 传输进度 Provider

final transferProgressStoreProvider =
    NotifierProvider<
      TransferProgressStore,
      Map<String, TransferProgressSnapshot>
    >(TransferProgressStore.new);
final transferProgressProvider =
    Provider.family<TransferProgressSnapshot?, String>((ref, attachmentId) {
      return ref.watch(
        transferProgressStoreProvider.select(
          (snapshots) => snapshots[attachmentId],
        ),
      );
    });
class TransferProgressSnapshot {
  const TransferProgressSnapshot({
    required this.attachmentId,
    required this.direction,
    required this.phase,
    required this.transferredBytes,
    required this.totalBytes,
    required this.bytesPerSecond,
    required this.updatedAt,
    this.errorMessage,
  });
  double get progress {
    if (totalBytes <= 0) {
      return 0;
    }
    return (transferredBytes / totalBytes).clamp(0.0, 1.0).toDouble();
  }
}

## C.6 数据库初始化与设置表

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
  @override
  int get schemaVersion => 1;
  @override
  MigrationStrategy get migration {
    return MigrationStrategy(
      onCreate: (migrator) async {
        await migrator.createAll();
        await _createCustomIndexes();
      },
      beforeOpen: (details) async {
        await customStatement('PRAGMA foreign_keys = ON');
      },
    );
  }
}
enum AppThemeMode { system, light, dark }
enum AppLanguage { system, en, zhHans, zhHant }
class SettingItems extends Table {
  late final id = integer().autoIncrement()();
  late final themeMode = textEnum<AppThemeMode>().clientDefault(
    () => AppThemeMode.system.name,
  )();
  late final language = textEnum<AppLanguage>().clientDefault(
    () => AppLanguage.system.name,
  )();
  late final transferEncryptionEnabled = boolean().clientDefault(() => false)();
  late final autoResumeTransfersEnabled = boolean().clientDefault(() => true)();
}
