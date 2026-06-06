const pptxgen = require('/Users/admin-and/.cache/codex-runtimes/codex-primary-runtime/dependencies/node/node_modules/pptxgenjs');

const pptx = new pptxgen();
pptx.layout = 'LAYOUT_WIDE';
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
pptx.defineLayout({ name: 'LAYOUT_WIDE', width: 13.333, height: 7.5 });
pptx.margin = 0;

const out = process.argv[2] || 'outputs/hydrop_defense_10page/hydrop_defense_10page.pptx';
const logo = '/Users/admin-and/Downloads/LNTU_Logo.png';

const C = {
  bg: 'F7F9FC',
  panel: 'FFFFFF',
  panelTint: 'F3F8FF',
  primary: '0169CC',
  text: '0D0D0D',
  muted: '5F6368',
  border: 'D0D6DE',
  dark: '0F1728',
  blueSoft: 'DCEEFF',
  blueLine: 'B8D7FB',
  success: 'EAF5EA',
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
    x: 9.9, y: -0.7, w: 3.9, h: 3.9,
    fill: { color: 'E8F2FF', transparency: 8 },
    line: { color: 'E8F2FF', transparency: 100 },
  });
  slide.addShape(pptx.ShapeType.ellipse, {
    x: -0.7, y: 5.9, w: 2.7, h: 2.7,
    fill: { color: 'FFFFFF', transparency: 18 },
    line: { color: 'FFFFFF', transparency: 100 },
  });
  for (let x = 1.25; x < 12.75; x += 1.35) {
    slide.addShape(pptx.ShapeType.line, {
      x, y: 0, w: 0, h: 7.5,
      line: { color: C.border, transparency: 88, width: 0.45 },
    });
  }
}

function addLogo(slide) {
  slide.addShape(pptx.ShapeType.roundRect, {
    x: 10.66, y: 0.24, w: 2.55, h: 0.55,
    rectRadius: 0.07,
    fill: { color: C.dark, transparency: 0 },
    line: { color: C.dark, transparency: 100 },
  });
  slide.addImage({ path: logo, x: 10.82, y: 0.33, w: 2.22, h: 0.46 });
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
    margin: opts.margin ?? 0.05,
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
    margin: opts.margin ?? 0.08,
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
    rectRadius: opts.radius || 0.12,
    fill: { color: opts.fill || C.panel, transparency: opts.transparency ?? 4 },
    line: { color: opts.line || C.border, width: opts.width || 1.15 },
  });
}

function darkPill(slide, label, x, y, w, h = 0.52, fill = C.dark) {
  slide.addShape(pptx.ShapeType.roundRect, {
    x, y, w, h,
    rectRadius: 0.08,
    fill: { color: fill },
    line: { color: fill, transparency: 100 },
  });
  addTextBox(slide, label, x + 0.08, y + 0.05, w - 0.16, h - 0.1, {
    fontSize: 24,
    bold: true,
    color: 'FFFFFF',
    align: 'center',
  });
}

function sectionHeader(slide, title, subtitle) {
  addBg(slide);
  addLogo(slide);
  addTextBox(slide, title, 0.62, 0.55, 9.4, 0.48, {
    fontFace: TITLE_FONT,
    fontSize: 32,
    bold: true,
  });
  if (subtitle) {
    addTextBox(slide, subtitle, 0.62, 1.08, 9.55, 0.36, {
      fontSize: 24,
      color: C.muted,
    });
  }
  slide.addShape(pptx.ShapeType.line, {
    x: 0.62, y: 6.42, w: 12.1, h: 0,
    line: { color: C.border, width: 1.2 },
  });
}

function infoCard(slide, title, lines, x, y, w, h, opts = {}) {
  panel(slide, x, y, w, h, {
    fill: opts.tint ? C.panelTint : C.panel,
    line: opts.tint ? C.blueLine : C.border,
  });
  addTextBox(slide, title, x + 0.25, y + 0.22, w - 0.5, 0.38, {
    fontSize: 24,
    bold: true,
    align: opts.titleAlign || 'left',
  });
  addParagraph(slide, lines, x + 0.25, y + 0.72, w - 0.5, h - 0.92, {
    fontSize: 24,
    color: opts.bodyColor || C.muted,
    align: opts.bodyAlign || 'left',
    valign: 'top',
    margin: 0.04,
  });
}

function flowArrow(slide, x1, y1, x2, y2) {
  slide.addShape(pptx.ShapeType.line, {
    x: x1, y: y1, w: x2 - x1, h: y2 - y1,
    line: { color: C.primary, width: 2.1, beginArrowType: 'none', endArrowType: 'triangle' },
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
    if (slide.texts.length > 18) {
      problems.push(`[${slide.name}] too many text boxes: ${slide.texts.length}`);
    }
    for (let i = 0; i < slide.texts.length; i += 1) {
      const a = slide.texts[i];
      if (a.fontSize < 24) {
        problems.push(`[${slide.name}] font smaller than 24: ${a.fontSize} -> ${a.text}`);
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
  panel(slide, 0.78, 1.0, 11.82, 5.42, { fill: C.panel, line: C.border, transparency: 6, radius: 0.18 });
  slide.addShape(pptx.ShapeType.rect, {
    x: 1.3, y: 1.74, w: 0.1, h: 3.0,
    fill: { color: C.primary }, line: { color: C.primary, transparency: 100 },
  });
  addTextBox(slide, '基于 Flutter 的跨平台高速文件传输系统设计与实现', 1.68, 2.02, 8.35, 2.15, {
    fontFace: TITLE_FONT,
    fontSize: 34,
    bold: true,
    valign: 'mid',
    margin: 0,
    fit: 'shrink',
  });
  slide.addShape(pptx.ShapeType.line, {
    x: 1.68, y: 4.72, w: 5.65, h: 0,
    line: { color: C.primary, width: 2.6 },
  });
  addParagraph(slide, ['答辩人：韩义勇', '指导教师：__________'], 1.68, 5.05, 4.3, 0.95, {
    fontSize: 24,
    margin: 0,
    paraSpaceAfterPt: 10,
  });
}

// 02 background
{
  const slide = pptx.addSlide();
  beginSlideCheck('slide2');
  sectionHeader(slide, '选题背景：跨设备传输仍不够直接', '现有方式各有局限，局域网直传更贴近日常协同场景。');
  infoCard(slide, '云盘中转', ['先上传再下载', '速度受上行带宽影响', '文件经过外部服务器'], 0.78, 1.78, 3.55, 2.72);
  infoCard(slide, '蓝牙近传', ['不依赖网络', '距离和速度受限', '大文件体验一般'], 4.67, 1.78, 3.55, 2.72, { tint: true });
  infoCard(slide, '厂商互传', ['体验通常较好', '依赖同一生态', '跨品牌兼容不足'], 8.56, 1.78, 3.55, 2.72);
  panel(slide, 1.62, 5.12, 10.05, 0.92, { fill: C.dark, line: C.dark, transparency: 0 });
  addParagraph(slide, ['研究机会：同一局域网内自动发现设备，直接完成文本与文件传输。'], 1.95, 5.33, 9.4, 0.45, {
    fontSize: 24,
    bold: true,
    color: 'FFFFFF',
    align: 'center',
    margin: 0,
  });
}

// 03 goals
{
  const slide = pptx.addSlide();
  beginSlideCheck('slide3');
  sectionHeader(slide, '系统目标：从“能传”到“可用”', 'Hydrop 不只是 Socket Demo，而是可发现、可交互、可恢复的跨平台应用。');
  panel(slide, 1.05, 1.72, 11.18, 1.1, { fill: C.dark, line: C.dark, transparency: 0 });
  addParagraph(slide, ['设备即联系人：先选择设备，再发送文本和附件'], 1.35, 2.0, 10.58, 0.42, {
    fontSize: 26,
    bold: true,
    color: 'FFFFFF',
    align: 'center',
    margin: 0,
  });
  infoCard(slide, '跨平台', ['Flutter 一套代码', '覆盖移动端和桌面端'], 1.05, 3.18, 5.35, 1.68);
  infoCard(slide, '高速直连', ['局域网内 TCP 传输', '减少外网中转'], 6.88, 3.18, 5.35, 1.68, { tint: true });
  infoCard(slide, '状态可解释', ['消息状态清晰', '进度、速度、错误可见'], 1.05, 5.0, 5.35, 1.08);
  infoCard(slide, '数据可恢复', ['设备、消息、附件落库', '中断任务可继续处理'], 6.88, 5.0, 5.35, 1.08, { tint: true });
}

// 04 architecture
{
  const slide = pptx.addSlide();
  beginSlideCheck('slide4');
  sectionHeader(slide, '总体架构：页面不直接碰网络和数据库', '分层的目标是降低 UI 和传输逻辑之间的耦合。');
  const rows = [
    ['Presentation', '页面渲染与用户操作'],
    ['Application', '运行时编排与传输控制'],
    ['Data', '仓库、DAO、Drift 数据库'],
    ['Remote / Platform', 'UDP、TCP、文件系统、通知'],
  ];
  rows.forEach((row, index) => {
    const y = 1.58 + index * 1.16;
    panel(slide, 1.02, y, 11.16, 0.8, {
      fill: index === 1 ? C.panelTint : C.panel,
      line: index === 1 ? C.blueLine : C.border,
    });
    addTextBox(slide, row[0], 1.38, y + 0.18, 2.72, 0.28, {
      fontSize: 24,
      bold: true,
    });
    addTextBox(slide, row[1], 4.45, y + 0.18, 7.15, 0.28, {
      fontSize: 24,
      color: C.muted,
    });
    if (index < rows.length - 1) flowArrow(slide, 6.6, y + 0.84, 6.6, y + 1.12);
  });
  darkPill(slide, '核心原则：页面只表达意图，底层能力放到控制器、仓库和服务中。', 1.68, 6.0, 9.85, 0.5);
}

// 05 discovery
{
  const slide = pptx.addSlide();
  beginSlideCheck('slide5');
  sectionHeader(slide, '亮点一：UDP 自动发现 + 二维码补充', '自动发现降低手动输入 IP 的门槛，二维码作为补充入口。');
  const steps = [
    ['枚举网卡', '地址枚举服务'],
    ['UDP 广播', '39175 发现报文'],
    ['去重入库', 'nonce + 自设备过滤'],
    ['在线维护', '12 秒 TTL'],
  ];
  steps.forEach((step, index) => {
    const col = index % 2;
    const row = Math.floor(index / 2);
    const x = 0.92 + col * 3.4;
    const y = 1.86 + row * 1.52;
    panel(slide, x, y, 3.0, 1.18, {
      fill: index === 1 || index === 2 ? C.panelTint : C.panel,
      line: index === 1 || index === 2 ? C.blueLine : C.border,
    });
    addParagraph(slide, [step[0], step[1]], x + 0.18, y + 0.18, 2.62, 0.72, {
      fontSize: 24,
      bold: true,
      align: 'center',
      paraSpaceAfterPt: 8,
    });
  });
  flowArrow(slide, 4.02, 2.45, 4.52, 2.45);
  flowArrow(slide, 4.02, 3.97, 4.52, 3.97);
  infoCard(slide, '发现 payload', ['deviceId、displayName、tcpPort', 'capabilities、addresses、nonce'], 7.08, 1.86, 5.36, 1.78);
  infoCard(slide, '二维码补充路径', ['广播受限时扫码配对', '只传连接元数据'], 7.08, 3.84, 5.36, 1.78, { tint: true });
}

// 06 protocol
{
  const slide = pptx.addSlide();
  beginSlideCheck('slide6');
  sectionHeader(slide, '亮点二：TCP FrameCodec 解决字节流边界', 'TCP 负责可靠传输，FrameCodec 负责统一业务帧结构。');
  const parts = [
    ['4B', 'header'],
    ['4B', 'body'],
    ['JSON', '元数据'],
    ['Binary', '文件分片'],
  ];
  parts.forEach((part, index) => {
    const x = 0.95 + index * 3.05;
    panel(slide, x, 1.86, 2.55, 1.22, {
      fill: index < 2 ? C.dark : C.panelTint,
      line: index < 2 ? C.dark : C.blueLine,
      transparency: 0,
    });
    addParagraph(slide, [part[0], part[1]], x + 0.15, 2.1, 2.25, 0.7, {
      fontSize: 24,
      bold: true,
      color: index < 2 ? 'FFFFFF' : C.text,
      align: 'center',
      paraSpaceAfterPt: 4,
    });
  });
  ['offer', 'chunk', 'complete', 'ACK'].forEach((label, index) => {
    const x = 1.14 + index * 2.98;
    darkPill(slide, label, x, 4.22, 2.12, 0.58, index === 3 ? C.primary : C.dark);
    if (index < 3) flowArrow(slide, x + 2.12, 4.5, x + 2.8, 4.5);
  });
  panel(slide, 2.02, 5.56, 9.3, 0.6, { fill: C.panel, line: C.primary });
  addTextBox(slide, '关键参数：TCP 39176 · 分片传输 · SHA-256 校验 · 有限并发', 2.22, 5.72, 8.9, 0.3, {
    fontSize: 24,
    bold: true,
    align: 'center',
  });
}

// 07 persistence
{
  const slide = pptx.addSlide();
  beginSlideCheck('slide7');
  sectionHeader(slide, '亮点三：Drift 持久化让状态可恢复', '设备、会话、消息和附件进入同一套本地数据模型。');
  panel(slide, 0.92, 1.62, 3.2, 3.78, { fill: C.dark, line: C.dark, transparency: 0 });
  addParagraph(slide, ['AppDataBase', 'Drift / SQLite', '本地状态唯一来源'], 1.18, 2.08, 2.7, 1.95, {
    fontSize: 24,
    bold: true,
    color: 'FFFFFF',
    align: 'center',
    paraSpaceAfterPt: 12,
  });
  const items = [
    ['Device', '在线状态'],
    ['Address', '多地址测速'],
    ['Session', '连接会话'],
    ['Message', '文本状态'],
    ['Attachment', '进度与校验'],
  ];
  items.forEach((item, index) => {
    const col = index % 2;
    const row = Math.floor(index / 2);
    const x = 4.86 + col * 3.56;
    const y = 1.55 + row * 1.36;
    panel(slide, x, y, 3.02, 0.95, {
      fill: index === 4 ? C.panelTint : C.panel,
      line: index === 4 ? C.blueLine : C.border,
    });
    addParagraph(slide, [item[0], item[1]], x + 0.18, y + 0.12, 2.66, 0.62, {
      fontSize: 24,
      bold: true,
      align: 'left',
      paraSpaceAfterPt: 6,
      color: item[0] === 'Attachment' ? C.primary : C.text,
    });
  });
  panel(slide, 4.86, 5.67, 6.58, 0.58, { fill: C.panel, line: C.primary });
  addTextBox(slide, '价值：失败、暂停、重启后仍能回到可解释状态。', 5.12, 5.82, 6.0, 0.28, {
    fontSize: 24,
    bold: true,
    align: 'center',
  });
}

// 08 UI
{
  const slide = pptx.addSlide();
  beginSlideCheck('slide8');
  sectionHeader(slide, '亮点四：同一套 Flutter UI 适配手机与桌面', '布局随宽度变化，但功能入口和使用逻辑保持一致。');
  panel(slide, 0.84, 1.58, 5.3, 4.5, { fill: C.panel, line: C.border });
  slide.addShape(pptx.ShapeType.roundRect, {
    x: 2.48, y: 2.05, w: 1.4, h: 2.6,
    rectRadius: 0.15,
    fill: { color: C.dark },
    line: { color: C.dark, transparency: 100 },
  });
  ['FFFFFF', 'F3F8FF', 'FFFFFF'].forEach((color, index) => {
    slide.addShape(pptx.ShapeType.roundRect, {
      x: 2.72, y: 2.46 + index * 0.56, w: 0.92, h: 0.3,
      rectRadius: 0.04,
      fill: { color },
      line: { color, transparency: 100 },
    });
  });
  addParagraph(slide, ['移动端：单栏布局', '设备列表进入聊天页'], 1.35, 5.08, 4.28, 0.66, {
    fontSize: 24,
    bold: true,
    align: 'center',
    paraSpaceAfterPt: 8,
  });
  panel(slide, 6.86, 1.58, 5.3, 4.5, { fill: C.panelTint, line: C.blueLine });
  slide.addShape(pptx.ShapeType.roundRect, {
    x: 7.56, y: 2.22, w: 3.92, h: 2.08,
    rectRadius: 0.08,
    fill: { color: C.dark },
    line: { color: C.dark, transparency: 100 },
  });
  slide.addShape(pptx.ShapeType.rect, {
    x: 7.76, y: 2.5, w: 0.58, h: 1.5,
    fill: { color: C.panelTint }, line: { color: C.panelTint },
  });
  slide.addShape(pptx.ShapeType.rect, {
    x: 8.56, y: 2.5, w: 1.04, h: 1.5,
    fill: { color: C.panel }, line: { color: C.panel },
  });
  slide.addShape(pptx.ShapeType.rect, {
    x: 9.82, y: 2.5, w: 1.26, h: 1.5,
    fill: { color: C.panelTint }, line: { color: C.panelTint },
  });
  addParagraph(slide, ['桌面端：导航 + 列表 + 会话', '同页处理更多信息'], 7.1, 5.08, 4.8, 0.66, {
    fontSize: 24,
    bold: true,
    align: 'center',
    paraSpaceAfterPt: 8,
  });
}

// 09 innovation
{
  const slide = pptx.addSlide();
  beginSlideCheck('slide9');
  sectionHeader(slide, '核心创新点：不是“传一下文件”这么简单', '重点不是功能堆叠，而是把连接、传输和状态做成完整闭环。');
  infoCard(slide, '不是手填 IP', ['UDP 自动发现', '多网卡地址处理', '降低连接门槛'], 0.76, 1.72, 3.72, 3.18);
  infoCard(slide, '不是裸 Socket', ['FrameCodec 分帧', 'offer / chunk / ACK', '语义清晰可扩展'], 4.66, 1.72, 3.72, 3.18, { tint: true });
  infoCard(slide, '不是临时状态', ['消息与附件先落库', '支持暂停、取消、恢复', '失败原因可回看'], 8.56, 1.72, 3.72, 3.18);
  darkPill(slide, '一句话：从“能传”提升到“可发现、可恢复、可扩展”。', 2.38, 5.74, 8.58, 0.54);
}

// 10 conclusion
{
  const slide = pptx.addSlide();
  beginSlideCheck('slide10');
  sectionHeader(slide, '总结与展望', 'Hydrop 已形成局域网文件传输应用的核心闭环。');
  panel(slide, 0.94, 1.62, 5.56, 4.02, { fill: C.panel, line: C.border });
  addParagraph(slide, [
    '已完成',
    '1. 响应式跨平台界面',
    '2. UDP 发现与二维码配对',
    '3. TCP 文本和文件传输',
    '4. Drift 持久化恢复',
  ], 1.28, 1.98, 4.9, 3.16, {
    fontSize: 24,
    bold: true,
    paraSpaceAfterPt: 8,
  });
  panel(slide, 6.98, 1.62, 5.4, 4.02, { fill: C.panelTint, line: C.blueLine });
  addParagraph(slide, [
    '后续工作',
    '1. 完善身份校验与加密',
    '2. 优化断点续传和调度',
    '3. 增强后台策略适配',
    '4. 补充真实多设备场景',
  ], 7.34, 1.98, 4.76, 3.16, {
    fontSize: 24,
    bold: true,
    paraSpaceAfterPt: 8,
  });
  panel(slide, 2.34, 6.02, 8.96, 0.56, { fill: C.dark, line: C.dark, transparency: 0 });
  addTextBox(slide, '谢谢各位老师，请批评指正', 3.78, 6.16, 6.06, 0.3, {
    fontSize: 26,
    bold: true,
    color: 'FFFFFF',
    align: 'center',
  });
}

(async () => {
  verifySlides();
  await pptx.writeFile({ fileName: out });
})();
