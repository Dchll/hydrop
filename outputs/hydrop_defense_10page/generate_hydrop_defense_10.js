const pptxgen = require('/Users/admin-and/.cache/codex-runtimes/codex-primary-runtime/dependencies/node/node_modules/pptxgenjs');

const pptx = new pptxgen();
pptx.author = 'Codex';
pptx.subject = 'Hydrop undergraduate defense';
pptx.title = '基于 Flutter 的跨平台高速文件传输系统设计与实现';
pptx.company = 'LNTU';
pptx.lang = 'zh-CN';
pptx.theme = {
  headFontFace: 'Microsoft YaHei',
  bodyFontFace: 'Microsoft YaHei',
  lang: 'zh-CN',
};

const W = 10;
const H = 8;
const LAYOUT_NAME = 'LAYOUT_NATIVE_5_4';
pptx.defineLayout({ name: LAYOUT_NAME, width: W, height: H });
pptx.layout = LAYOUT_NAME;
pptx.margin = 0;

const out = process.argv[2] || 'outputs/hydrop_defense_10page/Hydrop本科毕设答辩_5比4版.pptx';
const logo = '/Users/admin-and/Downloads/LNTU_Logo.png';

const C = {
  bg: 'F6F8FC',
  panel: 'FFFFFF',
  panelSoft: 'F7FAFF',
  tint: 'EAF3FF',
  primary: '0A69D8',
  primarySoft: 'CFE5FF',
  text: '111827',
  muted: '5B6470',
  border: 'D8E0EA',
  dark: '111827',
  darkSoft: '1F2937',
};

const FONT = 'Microsoft YaHei';
const TITLE_FONT = 'Microsoft YaHei';
const slideChecks = [];
let currentSlideCheck = null;

function beginSlideCheck(name) {
  currentSlideCheck = { name, texts: [] };
  slideChecks.push(currentSlideCheck);
}

function flattenRuns(value) {
  if (Array.isArray(value)) {
    return value.map((item) => {
      if (typeof item === 'string') return item;
      if (item && typeof item === 'object' && 'text' in item) return String(item.text);
      return String(item ?? '');
    }).join(' ');
  }
  if (typeof value === 'string') return value;
  if (value && typeof value === 'object' && 'text' in value) return String(value.text);
  return String(value ?? '');
}

function addBg(slide) {
  slide.background = { color: C.bg };
  slide.addShape(pptx.ShapeType.ellipse, {
    x: 7.35, y: -0.6, w: 2.95, h: 2.95,
    fill: { color: 'E9F1FF', transparency: 15 },
    line: { color: 'E9F1FF', transparency: 100 },
  });
  slide.addShape(pptx.ShapeType.ellipse, {
    x: -0.45, y: 6.35, w: 1.9, h: 1.9,
    fill: { color: 'FFFFFF', transparency: 18 },
    line: { color: 'FFFFFF', transparency: 100 },
  });
  slide.addShape(pptx.ShapeType.ellipse, {
    x: 8.45, y: 5.85, w: 1.35, h: 1.35,
    fill: { color: 'F0F6FF', transparency: 30 },
    line: { color: 'F0F6FF', transparency: 100 },
  });
  for (let x = 0.85; x < 9.5; x += 1.0) {
    slide.addShape(pptx.ShapeType.line, {
      x, y: 0, w: 0, h: H,
      line: { color: C.border, transparency: 90, width: 0.35 },
    });
  }
}

function addLogo(slide) {
  slide.addShape(pptx.ShapeType.roundRect, {
    x: 7.68, y: 0.22, w: 1.98, h: 0.52,
    rectRadius: 0.06,
    fill: { color: C.dark, transparency: 0 },
    line: { color: C.dark, transparency: 100 },
  });
  slide.addImage({
    path: logo,
    x: 7.84,
    y: 0.31,
    w: 1.66,
    h: 0.34,
  });
}

function registerText(value, x, y, w, h, fontSize) {
  if (!currentSlideCheck) return;
  currentSlideCheck.texts.push({
    text: flattenRuns(value),
    x,
    y,
    w,
    h,
    fontSize,
  });
}

function addTextBox(slide, value, x, y, w, h, opts = {}) {
  const fontSize = opts.fontSize || 24;
  registerText(value, x, y, w, h, fontSize);
  slide.addText(value, {
    x, y, w, h,
    fontFace: opts.fontFace || FONT,
    fontSize,
    color: opts.color || C.text,
    bold: Boolean(opts.bold),
    margin: opts.margin ?? 0.04,
    valign: opts.valign || 'mid',
    align: opts.align || 'left',
    paraSpaceAfterPt: 0,
    breakLine: false,
    fit: opts.fit || 'shrink',
  });
}

function addParagraph(slide, lines, x, y, w, h, opts = {}) {
  const value = lines.join('\n');
  registerText(value, x, y, w, h, opts.fontSize || 24);
  slide.addText(value, {
    x, y, w, h,
    fontFace: opts.fontFace || FONT,
    fontSize: opts.fontSize || 24,
    color: opts.color || C.text,
    bold: Boolean(opts.bold),
    margin: opts.margin ?? 0.04,
    valign: opts.valign || 'top',
    align: opts.align || 'left',
    paraSpaceAfterPt: opts.paraSpaceAfterPt ?? 2,
    breakLine: true,
    fit: opts.fit || 'shrink',
  });
}

function panel(slide, x, y, w, h, opts = {}) {
  slide.addShape(pptx.ShapeType.roundRect, {
    x, y, w, h,
    rectRadius: opts.radius || 0.1,
    fill: { color: opts.fill || C.panel, transparency: opts.transparency ?? 2 },
    line: { color: opts.line || C.border, width: opts.width || 1.0 },
  });
}

function header(slide, title, subtitle) {
  addBg(slide);
  addLogo(slide);
  addTextBox(slide, title, 0.62, 0.52, 6.9, 0.42, {
    fontFace: TITLE_FONT,
    fontSize: 28,
    bold: true,
  });
  addTextBox(slide, subtitle, 0.62, 1.02, 7.1, 0.24, {
    fontSize: 22,
    color: C.muted,
  });
  slide.addShape(pptx.ShapeType.line, {
    x: 0.62, y: 6.82, w: 8.78, h: 0,
    line: { color: C.border, width: 1.0 },
  });
}

function stackedCard(slide, title, lines, x, y, w, h, opts = {}) {
  panel(slide, x, y, w, h, {
    fill: opts.tint ? C.panelSoft : C.panel,
    line: opts.tint ? C.primarySoft : C.border,
  });
  addParagraph(slide, [title, ...lines], x + 0.22, y + 0.16, w - 0.44, h - 0.22, {
    fontSize: opts.fontSize || 19,
    bold: true,
    color: opts.color || C.text,
    paraSpaceAfterPt: opts.paraSpaceAfterPt ?? 2,
  });
}

function horizontalBar(slide, left, right, x, y, w, h, opts = {}) {
  panel(slide, x, y, w, h, {
    fill: opts.tint ? C.panelSoft : C.panel,
    line: opts.tint ? C.primarySoft : C.border,
  });
  addTextBox(slide, left, x + 0.22, y + 0.16, 2.35, 0.34, {
    fontSize: 20,
    bold: true,
    color: opts.leftColor || C.text,
  });
  addTextBox(slide, right, x + 2.72, y + 0.16, w - 2.98, 0.34, {
    fontSize: 20,
    color: opts.rightColor || C.muted,
    bold: Boolean(opts.rightBold),
  });
}

function verifySlides() {
  const problems = [];
  const intersects = (a, b) => (
    a.x < b.x + b.w &&
    a.x + a.w > b.x &&
    a.y < b.y + b.h &&
    a.y + a.h > b.y
  );

  for (const slide of slideChecks) {
    if (slide.texts.length > 14) {
      problems.push(`[${slide.name}] too many text boxes: ${slide.texts.length}`);
    }
    for (let i = 0; i < slide.texts.length; i += 1) {
      const a = slide.texts[i];
      const lineCount = Math.max(1, String(a.text).split('\n').length);
      const minHeight = lineCount === 1 ? 0.24 : (0.2 * lineCount + 0.1);
      if (a.fontSize < 18) {
        problems.push(`[${slide.name}] font smaller than 18: ${a.fontSize} -> ${a.text}`);
      }
      if (a.h < minHeight) {
        problems.push(`[${slide.name}] text box too short: h=${a.h} need>=${minHeight.toFixed(2)} -> ${a.text}`);
      }
      for (let j = i + 1; j < slide.texts.length; j += 1) {
        const b = slide.texts[j];
        if (intersects(a, b)) {
          problems.push(`[${slide.name}] overlapping text boxes: "${a.text}" <-> "${b.text}"`);
        }
      }
    }
  }

  if (problems.length > 0) {
    throw new Error(`Slide layout verification failed:\n${problems.join('\n')}`);
  }
}

// 01 cover
{
  const slide = pptx.addSlide();
  beginSlideCheck('slide1');
  addBg(slide);
  addLogo(slide);
  panel(slide, 0.72, 1.12, 8.58, 5.0, { fill: C.panel, line: C.border, transparency: 6, radius: 0.16 });
  slide.addShape(pptx.ShapeType.rect, {
    x: 1.12, y: 1.82, w: 0.1, h: 2.72,
    fill: { color: C.primary }, line: { color: C.primary, transparency: 100 },
  });
  addTextBox(slide, '基于 Flutter 的跨平台高速文件传输系统设计与实现', 1.56, 2.12, 6.78, 1.66, {
    fontFace: TITLE_FONT,
    fontSize: 30,
    bold: true,
    valign: 'mid',
    fit: 'shrink',
    margin: 0,
  });
  slide.addShape(pptx.ShapeType.line, {
    x: 1.56, y: 4.86, w: 4.6, h: 0,
    line: { color: C.primary, width: 2.2 },
  });
  addParagraph(slide, ['答辩人：韩义勇', '指导教师：__________'], 1.56, 5.22, 3.82, 0.82, {
    fontSize: 22,
    paraSpaceAfterPt: 10,
    margin: 0,
  });
}

// 02 background
{
  const slide = pptx.addSlide();
  beginSlideCheck('slide2');
  header(slide, '选题背景：跨设备传输仍不够直接', '现有方式各有局限，局域网直传更贴近日常协同场景。');
  stackedCard(slide, '云盘中转', ['先上传再下载', '速度受上行带宽影响', '文件经过外部服务器'], 0.82, 1.56, 8.52, 1.7);
  stackedCard(slide, '蓝牙近传', ['不依赖网络', '距离和速度受限', '大文件体验一般'], 0.82, 3.38, 8.52, 1.7, { tint: true });
  stackedCard(slide, '厂商互传', ['体验通常较好', '依赖同一生态', '跨品牌兼容不足'], 0.82, 5.2, 8.52, 1.7);
  panel(slide, 0.82, 7.14, 8.52, 0.54, { fill: C.dark, line: C.dark, transparency: 0 });
  addTextBox(slide, '研究机会：同一局域网内自动发现设备，直接完成文本与文件传输。', 1.08, 7.26, 8.0, 0.3, {
    fontSize: 22,
    bold: true,
    color: 'FFFFFF',
    align: 'center',
  });
}

// 03 goals
{
  const slide = pptx.addSlide();
  beginSlideCheck('slide3');
  header(slide, '系统目标：从“能传”到“可用”', 'Hydrop 不只是 Socket Demo，而是可发现、可交互、可恢复的跨平台应用。');
  panel(slide, 0.82, 1.7, 8.52, 0.9, { fill: C.dark, line: C.dark, transparency: 0 });
  addTextBox(slide, '设备即联系人：先选择设备，再发送文本和附件', 1.08, 1.94, 8.0, 0.34, {
    fontSize: 22,
    bold: true,
    color: 'FFFFFF',
    align: 'center',
  });
  stackedCard(slide, '跨平台', ['Flutter 一套代码', '覆盖移动端和桌面端'], 0.82, 2.86, 4.05, 1.46);
  stackedCard(slide, '高速直连', ['局域网内 TCP 传输', '减少外网中转'], 5.29, 2.86, 4.05, 1.46, { tint: true });
  stackedCard(slide, '状态可解释', ['消息状态清晰', '进度、速度、错误可见'], 0.82, 4.7, 4.05, 1.46);
  stackedCard(slide, '数据可恢复', ['设备、消息、附件落库', '中断任务可继续处理'], 5.29, 4.7, 4.05, 1.46, { tint: true });
}

// 04 architecture
{
  const slide = pptx.addSlide();
  beginSlideCheck('slide4');
  header(slide, '总体架构：页面不直接碰网络和数据库', '分层的目标是降低 UI 和传输逻辑之间的耦合。');
  horizontalBar(slide, 'Presentation', '页面渲染与用户操作', 0.82, 1.82, 8.52, 0.72);
  horizontalBar(slide, 'Application', '运行时编排与传输控制', 0.82, 2.82, 8.52, 0.72, { tint: true, leftColor: C.primary });
  horizontalBar(slide, 'Data', '仓库、DAO、Drift 数据库', 0.82, 3.82, 8.52, 0.72);
  horizontalBar(slide, 'Remote / Platform', 'UDP、TCP、文件系统、通知', 0.82, 4.82, 8.52, 0.72);
  panel(slide, 0.82, 5.98, 8.52, 0.62, { fill: C.dark, line: C.dark, transparency: 0 });
  addTextBox(slide, '核心原则：页面只表达意图，底层能力放到控制器、仓库和服务中。', 1.06, 6.12, 8.04, 0.3, {
    fontSize: 22,
    bold: true,
    color: 'FFFFFF',
    align: 'center',
  });
}

// 05 discovery
{
  const slide = pptx.addSlide();
  beginSlideCheck('slide5');
  header(slide, '亮点一：UDP 自动发现 + 二维码补充', '自动发现降低手动输入 IP 的门槛，二维码作为补充入口。');
  horizontalBar(slide, '步骤 1', '枚举网卡与可用地址', 0.82, 1.72, 4.08, 0.72);
  horizontalBar(slide, '步骤 2', 'UDP 39175 周期广播', 0.82, 2.62, 4.08, 0.72, { tint: true, leftColor: C.primary });
  horizontalBar(slide, '步骤 3', 'nonce 去重与自设备过滤', 0.82, 3.52, 4.08, 0.72);
  horizontalBar(slide, '步骤 4', 'TTL 维护在线状态', 0.82, 4.42, 4.08, 0.72, { tint: true, leftColor: C.primary });
  stackedCard(slide, '发现 payload', ['deviceId、displayName、tcpPort', 'capabilities、addresses、nonce'], 5.24, 1.82, 4.1, 1.78, {
    tint: true,
  });
  stackedCard(slide, '二维码补充路径', ['广播受限时扫码配对', '只承载连接元数据'], 5.24, 4.08, 4.1, 1.48);
}

// 06 protocol
{
  const slide = pptx.addSlide();
  beginSlideCheck('slide6');
  header(slide, '亮点二：TCP FrameCodec 解决字节流边界', 'TCP 负责可靠传输，FrameCodec 负责统一业务帧结构。');
  horizontalBar(slide, '4B', 'header 长度', 0.82, 1.76, 8.52, 0.68, { tint: true, leftColor: C.primary });
  horizontalBar(slide, '4B', 'body 长度', 0.82, 2.62, 8.52, 0.68);
  horizontalBar(slide, 'JSON', '帧类型与元数据', 0.82, 3.48, 8.52, 0.68, { tint: true, leftColor: C.primary });
  horizontalBar(slide, 'Binary', '文本或文件分片', 0.82, 4.34, 8.52, 0.68);
  panel(slide, 0.82, 5.42, 8.52, 0.62, { fill: C.dark, line: C.dark, transparency: 0 });
  addTextBox(slide, '业务流程：offer  ->  chunk  ->  complete  ->  ACK', 1.08, 5.56, 8.0, 0.3, {
    fontSize: 22,
    bold: true,
    color: 'FFFFFF',
    align: 'center',
  });
  panel(slide, 0.82, 6.14, 8.52, 0.56, { fill: C.panelSoft, line: C.primarySoft });
  addTextBox(slide, '关键参数：TCP 39176 · 分片传输 · SHA-256 校验 · 有限并发', 1.04, 6.26, 8.08, 0.3, {
    fontSize: 22,
    bold: true,
    align: 'center',
  });
}

// 07 persistence
{
  const slide = pptx.addSlide();
  beginSlideCheck('slide7');
  header(slide, '亮点三：Drift 持久化让状态可恢复', '设备、会话、消息和附件进入同一套本地数据模型。');
  stackedCard(slide, 'AppDataBase', ['Drift / SQLite', '本地状态唯一来源'], 0.82, 1.8, 3.0, 2.18, {
    tint: true,
  });
  horizontalBar(slide, 'Device', '设备与在线状态', 4.16, 1.9, 5.18, 0.72);
  horizontalBar(slide, 'Address', '多地址与测速', 4.16, 2.88, 5.18, 0.72, { tint: true, leftColor: C.primary });
  horizontalBar(slide, 'Session', '连接会话', 4.16, 3.86, 5.18, 0.72);
  horizontalBar(slide, 'Message / Attachment', '消息、进度与校验', 4.16, 4.84, 5.18, 0.72, { tint: true, leftColor: C.primary });
  panel(slide, 0.82, 6.04, 8.52, 0.62, { fill: C.dark, line: C.dark, transparency: 0 });
  addTextBox(slide, '价值：失败、暂停、重启后仍能回到可解释状态。', 1.06, 6.18, 8.04, 0.3, {
    fontSize: 22,
    bold: true,
    color: 'FFFFFF',
    align: 'center',
  });
}

// 08 UI
{
  const slide = pptx.addSlide();
  beginSlideCheck('slide8');
  header(slide, '亮点四：同一套 Flutter UI 适配手机与桌面', '布局随宽度变化，但功能入口和使用逻辑保持一致。');
  panel(slide, 0.82, 1.78, 3.9, 4.6, { fill: C.panel, line: C.border });
  slide.addShape(pptx.ShapeType.roundRect, {
    x: 2.08, y: 2.2, w: 1.24, h: 2.38,
    rectRadius: 0.14,
    fill: { color: C.darkSoft },
    line: { color: C.darkSoft, transparency: 100 },
  });
  ['FFFFFF', 'F1F6FF', 'FFFFFF'].forEach((color, index) => {
    slide.addShape(pptx.ShapeType.roundRect, {
      x: 2.3, y: 2.58 + index * 0.54, w: 0.8, h: 0.28,
      rectRadius: 0.04,
      fill: { color },
      line: { color, transparency: 100 },
    });
  });
  addParagraph(slide, ['移动端：单栏布局', '设备列表进入聊天页'], 1.18, 5.12, 3.2, 0.82, {
    fontSize: 22,
    bold: true,
    align: 'center',
  });
  panel(slide, 5.16, 1.78, 4.18, 4.6, { fill: C.panelSoft, line: C.primarySoft });
  slide.addShape(pptx.ShapeType.roundRect, {
    x: 5.72, y: 2.34, w: 3.06, h: 1.82,
    rectRadius: 0.08,
    fill: { color: C.darkSoft },
    line: { color: C.darkSoft, transparency: 100 },
  });
  slide.addShape(pptx.ShapeType.rect, {
    x: 5.9, y: 2.6, w: 0.46, h: 1.28,
    fill: { color: C.panelSoft }, line: { color: C.panelSoft },
  });
  slide.addShape(pptx.ShapeType.rect, {
    x: 6.56, y: 2.6, w: 0.82, h: 1.28,
    fill: { color: C.panel }, line: { color: C.panel },
  });
  slide.addShape(pptx.ShapeType.rect, {
    x: 7.58, y: 2.6, w: 1.0, h: 1.28,
    fill: { color: C.panelSoft }, line: { color: C.panelSoft },
  });
  addParagraph(slide, ['桌面端：导航 + 列表 + 会话', '同页处理更多信息'], 5.54, 5.12, 3.42, 0.82, {
    fontSize: 22,
    bold: true,
    align: 'center',
  });
}

// 09 innovation
{
  const slide = pptx.addSlide();
  beginSlideCheck('slide9');
  header(slide, '核心创新点：不是“传一下文件”这么简单', '重点不是功能堆叠，而是把连接、传输和状态做成完整闭环。');
  stackedCard(slide, '不是手填 IP', ['UDP 自动发现', '多网卡地址处理', '降低连接门槛'], 0.82, 1.56, 8.52, 1.7);
  stackedCard(slide, '不是裸 Socket', ['FrameCodec 分帧', 'offer / chunk / ACK', '语义清晰可扩展'], 0.82, 3.38, 8.52, 1.7, { tint: true });
  stackedCard(slide, '不是临时状态', ['消息与附件先落库', '支持暂停、取消、恢复', '失败原因可回看'], 0.82, 5.2, 8.52, 1.7);
  panel(slide, 1.2, 7.14, 7.76, 0.54, { fill: C.dark, line: C.dark, transparency: 0 });
  addTextBox(slide, '一句话：从“能传”提升到“可发现、可恢复、可扩展”。', 1.44, 7.26, 7.28, 0.3, {
    fontSize: 22,
    bold: true,
    color: 'FFFFFF',
    align: 'center',
  });
}

// 10 conclusion
{
  const slide = pptx.addSlide();
  beginSlideCheck('slide10');
  header(slide, '总结与展望', 'Hydrop 已形成局域网文件传输应用的核心闭环。');
  stackedCard(slide, '已完成', ['1. 响应式跨平台界面', '2. UDP 发现与二维码配对', '3. TCP 文本和文件传输', '4. Drift 持久化恢复'], 0.82, 1.78, 4.06, 4.32);
  stackedCard(slide, '后续工作', ['1. 完善身份校验与加密', '2. 优化断点续传和调度', '3. 增强后台策略适配', '4. 补充真实多设备场景'], 5.28, 1.78, 4.06, 4.32, { tint: true });
  panel(slide, 1.54, 6.18, 7.08, 0.62, { fill: C.dark, line: C.dark, transparency: 0 });
  addTextBox(slide, '谢谢各位老师，请批评指正', 1.82, 6.32, 6.52, 0.3, {
    fontSize: 24,
    bold: true,
    color: 'FFFFFF',
    align: 'center',
  });
}

(async () => {
  verifySlides();
  await pptx.writeFile({ fileName: out });
})();
