# data/remote 网络与文件服务层

remote 层封装外部世界：HTTP、UDP、TCP、平台网络接口、下载目录、应用支持目录。它不直接依赖页面，主要被 application 层和 repository provider 使用。

## HTTP 与每日一图

`dio_provider.dart` 根据 baseUrl 创建 Dio，设置连接/接收超时和 JSON 响应类型，并在 provider dispose 时关闭。

`bing_wallpaper_repository.dart` 通过 UAPI `/api/v1/image/bing-daily` 获取 4K Bing 壁纸元数据，再下载图片字节。`BingWallpaperStorage` 把图片保存到系统 Downloads 下的 `bing_wallpaper` 目录，文件名包含日期和 4K 标记。读取流程会先检查本地文件是否可用，不可用才下载；下载后再检查一次，最后删除同目录下其他 `bing_*.jpg`，保证只保留当前背景图。

## UDP 设备发现服务

`DiscoveryBroadcastService` 负责发送广播。它先从 `LocalNetworkAddressService.listBroadcastSources()` 得到所有 IPv4 广播源地址，为每个源地址打开 UDP socket。启动后立即广播一次，再每 10 秒广播一次。广播内容由 `DiscoveryBroadcastAnnouncement` 组装，包括设备 ID、显示名、协议版本、TCP 端口、能力列表、nonce、发送时间和本机地址列表。

`DiscoverySocketService` 负责接收广播。它绑定 UDP 发现端口，把 RawDatagramSocket 的 read 事件转换成 `DiscoveryDatagram` 流，再用 `DiscoveryPayloadCodec` 解码；只有合法 payload 才通过 `onPayload` 回调交给 application 层。

`DiscoveryPayloadCodec` 是发现协议的防线。它验证 JSON 类型、payload type、协议版本、设备 ID、显示名、端口、地址数组、地址版本、能力列表、nonce 和 sentAt。非法包直接返回 null，不向上抛异常，保证 UDP 监听不会被坏包打断。

## 本机网络地址枚举

`LocalNetworkAddressService` 组合两个来源：`NetworkInterface.list()` 提供所有网卡地址，`network_info_plus` 提供 Wi-Fi IP、子网掩码、网关、广播地址和 Wi-Fi 名称。实现过程：

1. 过滤 loopback、link-local、multicast、空地址和常见虚拟网卡前缀（lo、awdl、utun、bridge、vmnet、docker 等）。
2. 用 `interfaceName|address` 去重。
3. 判断地址是否与 Wi-Fi 元数据匹配，匹配时附加子网、网关、广播地址。
4. 推导 networkSignature，用网关/子网或广播/子网表示同一网络。
5. 排序时 IPv4 优先，再按网卡名和地址排序。

`listBroadcastSources()` 只保留 IPv4。没有可用源地址时返回 `0.0.0.0 -> 255.255.255.255` fallback，保证发现服务仍能 best-effort 发送。

## TCP frame 编解码

`FrameCodec` 定义 TCP 上的二进制 frame 格式：前 8 字节分别是 header JSON 长度和 body 长度，后面跟 header JSON bytes 和 body bytes。编码前会检查 header/body 长度上限；解码时用 `_FrameBuffer` 累积任意分片到来的 socket bytes，只有完整 frame 到齐才 yield `TransferFrame`。

这种格式让文本消息、测速、心跳、文件 offer/chunk/complete 都复用同一个 TCP 连接和同一个解析器。header 放小 JSON 控制信息，body 放文本或文件分片。

## TCP Socket 服务

`TransferSocketService` 提供两个入口：`connect(host, port)` 返回 `TransferConnection`，`startServer(port, onConnection)` 返回 `TransferServer`。底层 `_IoTransferDuplexSocket` 包装 Dart `Socket`，暴露远端地址、远端端口、字节流、串行写入和关闭。

写入使用 `_writeQueue` 串行化，避免多个异步 sendFrame 同时写 socket 导致数据交错。server 用 `ServerSocket.bind(InternetAddress.anyIPv4, shared: true)` 监听，并给每个客户端设置 `tcpNoDelay` 后包装成 `TransferConnection`。

## 附件保存与断点续传元数据

`AttachmentStorage` 为接收文件准备目标文件。它优先使用 Downloads，不可用时使用应用支持目录；文件放在 `Hydrop` 子目录。文件名会过滤非法字符、控制字符和 `..`，空文件名兜底为 `attachment.bin`。如果同名文件已存在，会追加 `(1)`、`(2)` 等后缀。

`TransferResumeMetadataStore` 保存断点续传 checkpoint JSON。接收文件时每 8MB 记录一个 sha256 checkpoint；恢复时会验证文件长度、总大小、segmentBytes 和每个 checkpoint 的 hash。发现文件长度与有效 checkpoint 不一致时会截断到最后一个有效位置；文件完整、元数据不匹配或校验失败时会清理元数据并从 0 开始。

`TransferSegmentCheckpointBuilder` 在接收 chunk 时累积 bytes，达到 segment 大小时生成 checkpoint。这样恢复时不需要重新 hash 整个大文件，只要验证分段即可。
