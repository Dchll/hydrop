# Hydrop 本科毕设答辩 - Design Spec

> Human-readable design narrative — rationale, audience, style, color choices, content outline. Read once by downstream roles for context.
>
> Machine-readable execution contract: `spec_lock.md` (color / typography / icon / image short form). Executor re-reads `spec_lock.md` before every SVG page to resist context-compression drift. Keep both in sync; on divergence, `spec_lock.md` wins.

## I. Project Information

| Item | Value |
| ---- | ----- |
| **Project Name** | Hydrop 本科毕设答辩 |
| **Canvas Format** | PPT 16:9 (1280x720) |
| **Page Count** | 14 pages |
| **Design Style** | General Versatile + academic defense glassmorphism / restrained technical workstation |
| **Target Audience** | 本科毕业设计答辩委员会老师 |
| **Use Case** | 30 分钟问辩中的 18-20 分钟正式汇报 + 6-8 分钟程序演示 |
| **Created Date** | 2026-05-30 |

---

## II. Canvas Specification

| Property | Value |
| -------- | ----- |
| **Format** | PPT 16:9 |
| **Dimensions** | 1280x720 |
| **viewBox** | `0 0 1280 720` |
| **Margins** | left/right 56px, top 44px, bottom 38px |
| **Content Area** | 1168x638 |

---

## III. Visual Theme

### Theme Style

- **Style**: 毛玻璃科技答辩风，吸收 Hydrop 当前黑白灰、直角、2px 分割线和工具化界面语言。
- **Theme**: 全套亮色背景，局部仅用浅蓝或深灰小面积强调，不再使用整页深底。
- **Tone**: 克制、工程化、可信、适合本科毕设答辩；不使用紫色科技模板，不使用过度赛博风。

### Color Scheme

| Role | HEX | Purpose |
| ---- | --- | ------- |
| **Background** | `#F7F9FC` | 全局亮色背景，保证投影环境下文字稳定可读 |
| **Secondary bg** | `#FFFFFF` | 主要内容面板、截图占位框和信息卡片 |
| **Primary** | `#0169CC` | 关键路径、协议端口、数字、高亮线 |
| **Accent** | `#0D0D0D` | 浅色页标题、主线框、重点结论 |
| **Secondary accent** | `#E8F2FF` | 蓝色玻璃辉光、浅蓝状态背景 |
| **Body text** | `#0D0D0D` | 正文 |
| **Body text inverse** | `#FFFFFF` | 深色页正文 |
| **Secondary text** | `#5F6368` | 注释、脚注、说明文字 |
| **Border** | `#D0D0D0` | 2px 分割线和面板边界 |
| **Muted border** | `#E2E2E2` | 弱分割线、占位框辅助线 |

### Visual Motifs

- 亮色玻璃面板：白色或浅蓝色半透明面板 + 2px 边框 + 轻微高光，保证答辩投影环境下的清晰度。
- 网格底纹：低对比横纵线，暗示工程结构和协议帧。
- 蓝色数据线：用于设备发现、TCP、ACK、文件分片等关键流向。
- 截图占位：大面积留白 + 玻璃边框 + 标注“程序截图待放置”，后续可替换真实运行截图。

---

## IV. Typography

### Font Plan

| Role | Font Stack | Rationale |
| ---- | ---------- | --------- |
| **Default / Body** | `"Microsoft YaHei", "PingFang SC", Arial, sans-serif` | PPT 安全、中文答辩可读性高，兼顾 macOS 预览 |
| **Title** | `SimHei, "Microsoft YaHei", sans-serif` | 标题更稳定、更有答辩感，避免过细字体投影发虚 |
| **Code / Protocol** | `Consolas, "Courier New", monospace` | 用于端口、frame type、路径、代码片段 |
| **Emphasis** | `SimHei, "Microsoft YaHei", sans-serif` | 关键结论、数字和页内小标题 |

### Size Ramp

| Purpose | Size | Weight |
| ------- | ---- | ------ |
| Cover title | 72px | 900 |
| Section / hero statement | 48px | 800 |
| Page title | 36px | 800 |
| Subtitle | 24px | 700 |
| Body content | 20px | 400-600 |
| Annotation / caption | 14px | 400 |
| Page number / footnote | 12px | 400 |
| Code / protocol label | 16px | 500 |

---

## V. Layout Principles

### Page Structure

- **Header area**: 44-92px; page title, section eyebrow, page number.
- **Content area**: main 540-610px; diagrams, screenshot placeholders, key points.
- **Footer area**: 24-38px; source note, demonstration cue, short takeaway.

### Layout Pattern Library

| Pattern | Suitable Pages |
| ------- | -------------- |
| Single column centered | Cover, summary, conclusion |
| Asymmetric split 4:6 / 3:7 | 背景痛点、程序截图页、论文差异页 |
| Three/four column cards | 功能目标、测试结果、实现亮点 |
| Center-radiating | 总体架构页 |
| Top-bottom protocol strip | TCP FrameCodec 与文件传输页 |
| Timeline / pipeline | 设备发现、运行时闭环、演示流程 |
| Full-bleed light hero | 封面、演示入口、结束页 |

### Spacing Specification

| Element | Current Project |
| ------- | --------------- |
| Safe margin from canvas edge | 56px |
| Content block gap | 24-36px |
| Icon-text gap | 10-14px |
| Glass panel padding | 22-30px |
| Card gap | 18-26px |
| Card border radius | 0-18px; 外形尽量直角，少量玻璃高光可用 12px |
| Divider width | 2px |

---

## VI. Icon Usage Specification

### Source

- **Built-in icon library**: `tabler-outline`
- **Stroke width**: `2`
- **Usage method**: SVG placeholder `<use data-icon="tabler-outline/icon-name" .../>`
- **Rule**: 全 deck 只使用 `tabler-outline`，不混用其他风格库；品牌图标不需要。

### Recommended Icon List

| Purpose | Icon Path | Page |
| ------- | --------- | ---- |
| 课题/答辩 | `tabler-outline/presentation-analytics` | P01, P14 |
| 跨设备 | `tabler-outline/devices-check` | P02, P03 |
| 局域网/Wi-Fi | `tabler-outline/wifi-2` | P02, P06 |
| 架构 | `tabler-outline/route-square` | P05 |
| 数据库 | `tabler-outline/database-cog` | P08 |
| TCP server | `tabler-outline/server-cog` | P07 |
| 消息 | `tabler-outline/message-2-check` | P07, P10 |
| 文件传输 | `tabler-outline/arrows-transfer-up-down` | P07, P10, P12 |
| 设置 | `tabler-outline/settings-cog` | P09, P12 |
| 二维码 | `tabler-outline/qrcode` | P06, P12 |
| 测试 | `tabler-outline/test-pipe` | P11 |
| 代码/协议 | `tabler-outline/code-dots` | P07, P10 |
| 安全/隐私 | `tabler-outline/shield-check` | P02, P14 |
| 搜索/发现 | `tabler-outline/search` | P06 |
| 外链/扩展 | `tabler-outline/link-plus` | P14 |

---

## VII. Visualization Reference List (if needed)

No external chart template is locked. Executor will hand-draw all visualizations from content:

| Page | Visualization | Usage |
| ---- | ------------- | ----- |
| P05 | Four-layer architecture diagram | Presentation -> Application -> Data -> Remote/Platform |
| P06 | Discovery sequence / LAN map | UDP broadcast, TTL, speed probe, QR fallback |
| P07 | TCP frame and file chunk pipeline | Header/body frame + offer/chunk/complete/ACK |
| P08 | Local persistence relationship map | Device, address, session, message, attachment |
| P11 | Test result cards | Functional, repository, widget, protocol and stability checks |

Runners-up considered: not applicable because no `templates/charts/` file is used; structural diagrams are simpler to draw directly and can stay aligned with source-code names.

---

## VIII. Image Resource List (if needed)

| Filename | Dimensions | Ratio | Purpose | Layout pattern | Acquire Via | Status | Reference | text_policy | page_role |
| -------- | ---------- | ----- | ------- | -------------- | ----------- | ------ | --------- | ----------- | --------- |
| screenshot_devices.png | 900x560 | 16:10 | 首页设备发现、在线状态、速度和最后消息截图占位 | #6 image left text right + #29 two-stop scrim | placeholder | Placeholder | 后续替换真实程序截图 | | evidence |
| screenshot_chat.png | 900x560 | 16:10 | 聊天页文本、图片/视频/文件附件卡片截图占位 | #6 image left text right + #29 two-stop scrim | placeholder | Placeholder | 后续替换真实程序截图 | | evidence |
| screenshot_transfer.png | 900x560 | 16:10 | 传输进度、暂停/取消、通知或失败状态截图占位 | #7 image right text left + #29 two-stop scrim | placeholder | Placeholder | 后续替换真实程序截图 | | evidence |
| screenshot_settings_qr.png | 900x560 | 16:10 | 设置页、本机信息、局域网地址和二维码连接截图占位 | #7 image right text left + #29 two-stop scrim | placeholder | Placeholder | 后续替换真实程序截图 | | evidence |

---

## IX. Content Outline

| Page | Title | Key Message | Main Content | Rhythm |
| ---- | ----- | ----------- | ------------ | ------ |
| P01 | 基于 Flutter 的跨平台高速文件传输系统设计与实现 | Hydrop 完成局域网内设备发现、会话通信、文件传输和状态反馈闭环 | 题目、姓名/专业/指导教师占位、Hydrop 关键词 | anchor |
| P02 | 研究背景：跨设备传输仍不够直接 | 云盘、蓝牙、厂商互传各有局限，局域网直传能减少中转和门槛 | 痛点三列 + 局域网直连价值 | dense |
| P03 | 系统目标与最终成果 | 不是 Socket Demo，而是跨平台可运行的文件传输应用 | 跨平台、高速直连、状态可解释、本地持久化四项目标 | dense |
| P04 | 需求边界：围绕“设备即联系人”组织功能 | 用户先选择设备，再在聊天式入口中发送文本和附件 | 功能需求、非功能需求、演示闭环 | dense |
| P05 | 总体架构：四层解耦 | UI 不直接操作 Drift、Socket 或平台 API，业务编排放在 application 层 | Presentation/Application/Data/Core + remote/local 边界图 | breathing |
| P06 | 设备发现：UDP 广播 + 多网卡地址 + 二维码补充 | 自动发现优先，二维码作为受限网络下的手动配对路径 | 39175 UDP、payload 字段、TTL、测速、QR | dense |
| P07 | 高速传输协议：TCP FrameCodec + 分片 ACK | TCP 保可靠，FrameCodec 解决字节流边界，应用层表达传输语义 | 8 字节长度头、JSON header、binary body、fileOffer/fileChunk/fileComplete | dense |
| P08 | 本地持久化：设备、地址、会话、消息、附件 | Drift 数据库让发现、消息和传输状态可恢复、可查询 | 8 张表的关系与关键字段 | dense |
| P09 | 跨平台界面：同一代码适配手机与桌面 | 移动端单栏，桌面端导航 + 设备列表 + 聊天内容双栏 | 响应式窗口等级、黑白灰直角 UI、主题和语言 | dense |
| P10 | 核心实现亮点 | 运行时、发现、消息、文件、进度通知形成完整工程链路 | 五个实现亮点卡片，带源码类名 | dense |
| P11 | 测试与结果分析 | 通过功能、协议、仓库和组件测试验证主要链路 | 测试类型、结果、稳定性分析、限制 | dense |
| P12 | 程序运行截图与演示路线 | 用 6-8 分钟展示真实程序流程 | 四个截图占位 + 演示顺序 | breathing |
| P13 | 论文提交后程序改进 | 当前源码比论文维护稿更进一步，答辩需主动说明差异 | 传输页/暂停取消/自动恢复/通知/UI 规范等差异 | dense |
| P14 | 总结与展望 | Hydrop 已实现局域网传输闭环，后续可增强加密、调度和平台适配 | 贡献总结、限制、后续工作、致谢 | anchor |

---

## X. Speaker Notes Guidance

- 总时长建议：PPT 讲解 18-20 分钟，程序演示 6-8 分钟，最后预留 2-4 分钟。
- P01-P04 控制在 4-5 分钟，讲清问题、目标和需求边界。
- P05-P08 是技术核心，控制在 8-9 分钟，重点说明分层、发现、FrameCodec、数据库持久化。
- P09-P11 控制在 4-5 分钟，讲 UI、工程实现与测试结果。
- P12 进入演示，P13 主动解释论文与程序差异，P14 总结。
- 每页 speaker note 以答辩口吻书写，避免照读论文；突出“我为什么这样设计”和“源码中如何落地”。

---

## XI. Technical Constraints

- SVG viewBox must be `0 0 1280 720`.
- Use only colors, fonts and icons listed in `spec_lock.md`.
- Avoid `<style>`, external CSS, `foreignObject`, animation tags, script tags and unsupported SVG features.
- Every page should use top-level `<g id="...">` groups for PPTX animation/export.
- Screenshot slots remain placeholders unless real image files are later placed in `images/` and the SVGs are updated.
- Diagrams should cite source-code names directly where useful, such as `AppRuntime`, `DiscoveryController`, `FrameCodec`, `FileTransferCoordinator`, `AppDataBase`.
