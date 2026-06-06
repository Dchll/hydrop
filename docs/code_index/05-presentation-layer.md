# presentation 展示层

展示层只负责 UI 结构、交互入口和临时页面状态。它通过 provider/controller 消费 application 层，不直接访问 Socket、Dio、Drift DAO。

## 应用壳：`pages/app/app_page.dart`

`AppPage` 是主页面 shell。它使用 `HydropAdaptiveBuilder` 判断窗口等级：expanded/large 使用左侧桌面导航，compact/medium 使用底部 NavigationBar。`AutoTabsRouter` 管理首页与设置页两个 tab。桌面和移动导航都只负责 activeIndex 与 tab 切换，不包含业务数据。

## 首页：`pages/home/home_page.dart`

首页展示设备列表并在宽屏下内嵌聊天页。页面本地状态只有选中设备、搜索框和查询字符串。数据来自 `homeDeviceListProvider`、`homeLastMessageByDeviceProvider`、`homeUnreadCountByDeviceProvider`。

实现方式：

- `_HomeContent` 合并设备、最近消息和未读数，按搜索词过滤设备。
- compact/medium 下点击设备 push `ChatRoute`；expanded/large 下只更新选中设备并在右侧显示 `ChatPage`。
- `_DevicePane` 显示顶部操作栏、刷新按钮、扫码按钮、搜索框和设备列表。
- 设备长按弹出菜单，可删除设备；删除通过 `homePageControllerProvider.deleteDevice()` 清空会话并删设备。
- 扫码通过 `scanConnectionQr()`，成功后选中设备并刷新列表。

## 聊天页：`pages/chat/chat_page.dart`

聊天页负责消息时间线、搜索、发送、附件选择、消息操作和附件预览。它本地维护输入框、搜索框、发送中状态、选文件状态和分页条数。会话数据来自 `conversationProvider(remoteDeviceId)`，动作通过 `chatPageControllerProvider(remoteDeviceId)`。

文本发送时页面只取输入框内容并调用 controller；controller 返回 queued/failed/delivered 后，页面显示短提示。附件发送先弹出文件/图片/视频选择模式，再交给 controller 处理 FilePicker 和传输任务。

消息操作 bottom sheet 支持复制文本、失败文本重试、打开链接、保存附件、暂停/取消传输和删除消息。链接打开前会弹确认，避免直接跳外部浏览器。会话加载时会调用 `markConversationRead()` 标记收到的未读消息。

`chat_search_state.dart` 为每个 remoteDeviceId 管理搜索状态，聊天页根据 query 找匹配消息，并高亮当前 selectedIndex。

## 聊天消息组件

`chat_message_widgets.dart` 负责消息列表和气泡渲染。`ChatMessageTimeline` 处理空状态、加载更早消息入口、滚动列表和搜索高亮。消息气泡根据方向决定左右布局，根据消息类型展示文本、附件、图片缩略图、视频占位、进度条、状态和错误。

附件状态会合并 `transferProgressProvider(attachmentId)` 的内存进度，使 UI 可以显示比数据库持久化更细的实时进度。组件还提供 `EmptyChatPanel`、`ChatComposer`、状态组件和链接识别渲染等。

`chat_image_viewer.dart` 提供全屏图片和视频预览。图片用 PageView + InteractiveViewer 支持多图翻页和缩放；视频用 `VideoPlayerController.file` 播放本地文件，提供错误态、保存和关闭按钮。

## 我的页：`pages/mine/mine_page.dart`

我的页展示本机 profile、二维码、地址列表和诊断信息。它读取 `mineOverviewProvider`，显示展示名、主机名、设备 ID、本机连接二维码、可用地址、payload 长度、地址数和 TCP server 状态。展示名修改通过 `minePageControllerProvider.updateDisplayName()`。

二维码相关 UI 复用 `connection_qr_actions.dart`：显示二维码时用 `qr_flutter`；扫码时打开 scanner 页面，scanner 使用 `mobile_scanner`，扫描到条码后停止相机并调用 `ConnectionQrController.saveScannedPayload()`。

## 设置页：`pages/settings/settings_page.dart`

设置页读取 `settingsProvider` 和 `mineOverviewProvider`，组织主题、语言、传输开关、本机信息、网络信息和关于信息。主题和语言写入 `SettingRepository`，传输加密与自动恢复也写入设置表。

实现上它把设置项拆成 block、row、choice tile、switch tile、info value 等小组件；所有用户文案来自 ARB 本地化，状态变化后通过 `TransientFeedback` 提示。

## 传输页：`pages/transfers/transfers_page.dart`

传输页读取 `fileMessagesProvider`，把所有文件消息扁平化为 `_TransferItem`。用户可以按 all/active/completed/failed 过滤，也可以搜索文件名、设备 ID、方向和状态。宽屏显示列表 + 详情，窄屏点击后弹出详情 bottom sheet。

`_TransferItem.withProgress()` 把数据库附件状态和内存进度合并，计算 progress、状态 label、字节进度、速率、是否能暂停/取消。暂停和取消通过 `TransferActionController`，另存为通过 `AttachmentActionController`。

## 共享组件

`hd_components.dart`、`hd_container.dart`、`hd_floating_components.dart` 提供项目统一视觉容器：页面 Scaffold、Header、Panel、Dock、FloatingAppBar、FloatingIconButton、SearchField 等。它们都使用主题色，保持 0 圆角和项目黑白灰风格。

`hd_glass_components.dart` 是兼容导出，把旧的 glass 命名映射到当前 Hd 组件，避免调用方大面积改名。

`hydrop_adaptive.dart` 定义窗口等级和布局参数。600、840、1200 是布局断点；compact/medium 用底部导航，expanded/large 用侧边导航；页面 padding 和列表宽度都从这里取。

`image_widget.dart` 是通用图片入口：空 URL 显示占位；data URI 解码为 MemoryImage；`http/https` 和 `//` 用 CachedNetworkImage；file path 和 file:// 用平台文件 provider；asset 和 asset:// 用 ExactAssetImage；不支持的类型显示错误占位并可点击重试。IO 和非 IO 平台通过条件导入区分文件图片支持。
