# -*- coding: utf-8 -*-
"""链宇技术 · 主数据与业务链路整合方案 —— 按官方模板（深色封面 + 浅色内容）重建"""
from pptx import Presentation
from pptx.util import Inches, Pt
from pptx.dml.color import RGBColor
from pptx.enum.text import PP_ALIGN, MSO_ANCHOR, MSO_AUTO_SIZE
from pptx.enum.shapes import MSO_SHAPE, MSO_CONNECTOR
from pptx.oxml.ns import qn
from lxml import etree

W, H = 13.333, 7.5
M = 0.85
CW = W - 2 * M

# 模板色板（取自模板“色板主题颜色”页）
NAVY    = RGBColor(0x09, 0x31, 0x94)   # 主色
BLUE    = RGBColor(0x15, 0x7C, 0xEF)   # 色块
RED     = RGBColor(0xF0, 0x24, 0x2B)   # 辅助色
BLACK   = RGBColor(0x00, 0x00, 0x00)   # 正文
GRAY    = RGBColor(0x52, 0x53, 0x54)   # 副标题
LIGHT   = RGBColor(0xF7, 0xF9, 0xFB)   # 浅色背景
WHITE   = RGBColor(0xFF, 0xFF, 0xFF)
HAIR    = RGBColor(0xE3, 0xE9, 0xF4)
HEAD_BG = RGBColor(0xDE, 0xE9, 0xFB)
PANEL   = RGBColor(0xEF, 0xF4, 0xFC)
BORDER  = RGBColor(0xBF, 0xD3, 0xEE)
MUTED   = RGBColor(0x8A, 0x93, 0xA3)
DARK1   = RGBColor(0x1A, 0x27, 0x46)
DARK2   = RGBColor(0x12, 0x30, 0x6C)
SUBTXT  = RGBColor(0xC9, 0xD3, 0xE4)

CN = "微软雅黑"
EN = "Arial"

prs = Presentation()
prs.slide_width = Inches(W)
prs.slide_height = Inches(H)
BLANK = prs.slide_layouts[6]
LOGO_W = ".tpl/logo_white.png"
LOGO_N = ".tpl/logo_navy.png"
GHOST = ".tpl/mark_ghost.png"


# ------------------------------------------------------------------ helpers
def style_run(r, size=10, color=BLACK, bold=False, spc=None):
    f = r.font
    f.size = Pt(size)
    f.bold = bold
    f.color.rgb = color
    f.name = EN                      # 英文/数字 Arial
    rPr = r._r.get_or_add_rPr()
    ea = etree.SubElement(rPr, qn('a:ea'))
    ea.set('typeface', CN)           # 中文 微软雅黑
    if spc is not None:
        rPr.set('spc', str(spc))


def txt(slide, x, y, w, h, text, size=10, color=BLACK, bold=False,
        align=PP_ALIGN.LEFT, anchor=MSO_ANCHOR.TOP, spacing=1.25,
        spc=None, space_after=0):
    tb = slide.shapes.add_textbox(Inches(x), Inches(y), Inches(w), Inches(h))
    tf = tb.text_frame
    tf.word_wrap = True
    tf.margin_left = tf.margin_right = tf.margin_top = tf.margin_bottom = 0
    tf.vertical_anchor = anchor
    tf.auto_size = MSO_AUTO_SIZE.NONE
    for i, ln in enumerate(text.split("\n")):
        p = tf.paragraphs[0] if i == 0 else tf.add_paragraph()
        p.alignment = align
        p.line_spacing = spacing
        p.space_after = Pt(space_after)
        r = p.add_run()
        r.text = ln
        style_run(r, size, color, bold, spc)
    return tb


def _strip(sp):
    st = sp._element.find(qn('p:style'))
    if st is not None:
        sp._element.remove(st)


def rect(slide, x, y, w, h, fill=None, line=None, lw=0.75,
         shape=MSO_SHAPE.RECTANGLE, radius=None, alpha=None):
    if radius is not None:
        shape = MSO_SHAPE.ROUNDED_RECTANGLE
    sp = slide.shapes.add_shape(shape, Inches(x), Inches(y), Inches(w), Inches(h))
    sp.shadow.inherit = False
    _strip(sp)
    if radius is not None:
        try:
            sp.adjustments[0] = radius
        except Exception:
            pass
    if fill is None:
        sp.fill.background()
    else:
        sp.fill.solid()
        sp.fill.fore_color.rgb = fill
        if alpha is not None:
            sf = sp.fill._xPr.find(qn('a:solidFill'))
            a = etree.SubElement(sf[0], qn('a:alpha'))
            a.set('val', str(int(alpha * 1000)))
    if line is None:
        sp.line.fill.background()
    else:
        sp.line.color.rgb = line
        sp.line.width = Pt(lw)
    tf = sp.text_frame
    tf.word_wrap = True
    tf.margin_left = tf.margin_right = tf.margin_top = tf.margin_bottom = 0
    return sp


def line(slide, x1, y1, x2, y2, color=HAIR, lw=0.75, alpha=None):
    ln = slide.shapes.add_connector(MSO_CONNECTOR.STRAIGHT, Inches(x1), Inches(y1),
                                    Inches(x2), Inches(y2))
    ln.shadow.inherit = False
    _strip(ln)
    ln.line.color.rgb = color
    ln.line.width = Pt(lw)
    if alpha is not None:
        sf = ln.line._get_or_add_ln().find(qn('a:solidFill'))
        if sf is not None:
            a = etree.SubElement(sf[0], qn('a:alpha'))
            a.set('val', str(int(alpha * 1000)))
    return ln


def logo(slide, dark=True, h=0.34):
    path = LOGO_W if dark else LOGO_N
    slide.shapes.add_picture(path, Inches(12.02), Inches(0.30), height=Inches(h))


# ------------------------------------------------------------------ backgrounds
def dark_bg(slide):
    r = rect(slide, 0, 0, W, H)
    r.fill.gradient()
    r.fill.gradient_angle = 135
    st = r.fill.gradient_stops
    st[0].color.rgb = DARK1
    st[0].position = 0.0
    st[1].color.rgb = DARK2
    st[1].position = 1.0
    # glow
    g = rect(slide, 4.4, 1.4, 9.0, 6.6, fill=RGBColor(0x2E, 0x5D, 0xBB),
             shape=MSO_SHAPE.OVAL, alpha=6)
    # square grid motif
    sq = [(2.05, 0.85, 0.52, 3), (3.05, 0.85, 0.52, 3), (4.05, 1.45, 0.52, 3),
          (5.05, 0.25, 0.52, 3), (6.05, 1.45, 0.52, 4), (7.05, 0.85, 0.52, 4),
          (8.05, 0.85, 0.52, 3), (9.05, 0.25, 0.52, 3), (3.55, 2.35, 0.52, 2),
          (4.55, 2.85, 0.52, 3), (9.55, 1.55, 0.52, 2), (10.55, 0.85, 0.52, 2),
          (5.55, 2.15, 0.52, 3), (8.55, 2.15, 0.52, 2), (6.55, 0.25, 0.52, 4)]
    for x, y, s_, a in sq:
        rect(slide, x, y, s_, s_, fill=WHITE, alpha=a)
    # giant ghost mark (vector, avoids raster alpha issues)
    for cx_, rot in ((11.70, 17), (14.10, -17)):
        b = rect(slide, cx_ - 0.43, 0.55, 0.86, 8.0, fill=WHITE, alpha=2.4)
        b.rotation = rot
    # thin rules
    for y in (1.35, 2.55, 3.75):
        line(slide, 0.45, y, 12.9, y, WHITE, 0.5, alpha=8)


def light_bg(slide):
    rect(slide, 0, 0, W, H, fill=LIGHT)
    # pale circle right
    rect(slide, 10.1, 4.4, 5.6, 5.6, fill=RGBColor(0xE9, 0xF1, 0xFD),
         shape=MSO_SHAPE.OVAL, alpha=45)
    # thin globe arcs bottom-left
    for w_, h_, a in [(3.2, 3.2, 20), (5.0, 5.0, 14), (6.8, 6.8, 9)]:
        rect(slide, -2.2 - w_ / 2, 8.2 - h_ / 2, w_, h_, fill=None,
             line=RGBColor(0x9E, 0xBC, 0xE8), lw=0.5, shape=MSO_SHAPE.OVAL, alpha=a)
    # bottom wash
    rect(slide, 0, 6.9, W, 0.6, fill=RGBColor(0xEC, 0xF3, 0xFD), alpha=40)


def chrome(slide, title, page):
    light_bg(slide)
    rect(slide, 0.55, 0.44, 0.09, 0.13, fill=RED, radius=0.5)
    rect(slide, 0.55, 0.57, 0.09, 0.21, fill=NAVY, radius=0.5)
    txt(slide, 0.78, 0.38, 10.6, 0.42, title, 22, BLACK, True, spacing=1.0)
    logo(slide, dark=False)
    line(slide, 0.55, 7.02, 12.78, 7.02, HAIR, 0.5)
    txt(slide, 0.55, 7.09, 5.0, 0.22, "链宇技术©2026 商业机密", 8, MUTED, spc=20)
    txt(slide, 11.78, 7.09, 1.0, 0.22, f"{page}", 8, MUTED, align=PP_ALIGN.RIGHT)


def section(num, title, subtitle, page):
    s = prs.slides.add_slide(BLANK)
    dark_bg(s)
    logo(s, dark=True)
    txt(s, 0, 2.02, W, 0.24, f"SECTION {num}", 9, RGBColor(0x8F, 0xA9, 0xD6),
        True, align=PP_ALIGN.CENTER, spc=240)
    line(s, 4.32, 2.36, 9.0, 2.36, WHITE, 0.6, alpha=22)
    txt(s, 0, 2.56, W, 0.62, title, 30, WHITE, True, align=PP_ALIGN.CENTER, spacing=1.1)
    line(s, 4.32, 3.34, 9.0, 3.34, WHITE, 0.6, alpha=22)
    txt(s, 0, 3.52, W, 0.3, subtitle, 11, SUBTXT, align=PP_ALIGN.CENTER, spacing=1.2)
    # wireframe globe
    cx, cy = 6.67, 10.35
    for h_ in (6.5, 8.4, 10.3):
        rect(s, cx - h_ / 2, cy - h_ / 2, h_, h_, fill=None,
             line=RGBColor(0x5B, 0x84, 0xD2), lw=0.6, shape=MSO_SHAPE.OVAL, alpha=38)
    for w_ in (2.4, 4.6, 7.0):
        rect(s, cx - w_ / 2, cy - 5.15, w_, 10.3, fill=None,
             line=RGBColor(0x5B, 0x84, 0xD2), lw=0.6, shape=MSO_SHAPE.OVAL, alpha=30)
    for y in (5.15, 6.15):
        line(s, 0.4, y, 12.93, y, WHITE, 0.5, alpha=7)
    return s


# ------------------------------------------------------------------ 01 cover
s = prs.slides.add_slide(BLANK)
dark_bg(s)
logo(s, dark=True)
txt(s, 1.0, 2.28, 8.6, 0.3, "链宇技术  /  2026 内部方案", 10, SUBTXT, spc=120)
txt(s, 0.98, 2.62, 9.0, 1.7, "从签约到利润，\n一条链路跑通", 36, WHITE, True, spacing=1.28)
line(s, 1.02, 4.44, 3.3, 4.44, RGBColor(0x5B, 0x84, 0xD2), 1.2)
txt(s, 1.0, 4.62, 8.4, 0.7,
    "四套系统、十二个节点、二十四项主数据；先把数据变唯一，再把链路闭成环。",
    12, SUBTXT, spacing=1.5)
txt(s, 1.0, 6.05, 8.0, 0.6, "汇报方：链宇技术（Lianyu Technology）\n2026 年 11 月  |  内部绝密",
    9, RGBColor(0xA9, 0xB9, 0xD6), spacing=1.6)

# ------------------------------------------------------------------ 02 目录
s = prs.slides.add_slide(BLANK)
dark_bg(s)
logo(s, dark=True)
txt(s, 1.05, 0.92, 3.2, 0.5, "目录", 30, WHITE, True, spacing=1.0)
txt(s, 1.05, 1.44, 3.2, 0.3, "CONTENTS", 15, RGBColor(0x8F, 0xA9, 0xD6), spc=180)
# stacked ellipses
for i, (col, al) in enumerate([(RGBColor(0x2B, 0x4F, 0xA5), 80), (RGBColor(0x2F, 0x5C, 0xC0), 62), (RGBColor(0x3A, 0x6E, 0xE0), 45)]):
    rect(s, 1.35, 3.42 + i * 0.62, 3.05, 0.92, fill=col, shape=MSO_SHAPE.OVAL, alpha=al)
items = [("01", "主数据：判定口径与清单"), ("02", "业务链路：阶段、交接物与场景"),
         ("03", "系统断点：四套系统为何算不出利润"), ("04", "下一步：整合打底，重建收口")]
y = 1.72
for i, (n, t) in enumerate(items):
    rect(s, 7.15, y + 0.12, 0.18, 0.18, fill=None, line=RGBColor(0x7F, 0xA3, 0xE0), lw=1.0,
         shape=MSO_SHAPE.DIAMOND)
    txt(s, 7.58, y + 0.02, 3.6, 0.3, t, 13, WHITE, spacing=1.15)
    txt(s, 11.55, y + 0.02, 0.9, 0.3, n, 11, RGBColor(0x8F, 0xA9, 0xD6), align=PP_ALIGN.RIGHT)
    line(s, 7.1, y + 0.72, 12.45, y + 0.72, WHITE, 0.5, alpha=14)
    y += 1.16

# ------------------------------------------------------------------ 03 section 01
section("01", "主数据", "先定义“什么算主数据”，再决定整合什么、治理什么。", 3)

# ------------------------------------------------------------------ 04 判定口径
s = prs.slides.add_slide(BLANK)
chrome(s, "四条同时满足，才叫主数据", 4)
txt(s, M, 1.02, CW, 0.3, "口径不清，治理就会变成全库搬家。", 10, GRAY)
crit = [
    ("01", "被 2 个及以上业务环节引用", "不是某个模块的私有表；至少两个阶段读它、写它，才有统一的价值。"),
    ("02", "有稳定、可对外的业务编码", "人能读、能写在合同和发票上；编码不随系统、不随组织架构变化。"),
    ("03", "生命周期长于单据", "客户还在、合同执行完，主数据仍然存在；单据可以归档，主数据不能。"),
    ("04", "变更需要审批或备案", "不能谁都能改；有变更流程，才有唯一版本和可追溯的历史。"),
]
y = 1.52
line(s, M, y, W - M, y, HEAD_BG, 1.2)
for n, t, d in crit:
    txt(s, M, y + 0.2, 0.6, 0.26, n, 9.5, BLUE, True)
    txt(s, M + 0.62, y + 0.17, 3.9, 0.3, t, 12, BLACK, True, spacing=1.05)
    txt(s, M + 4.55, y + 0.19, 7.1, 0.55, d, 9.5, GRAY, spacing=1.5)
    y += 1.04
    line(s, M, y - 0.02, W - M, y - 0.02, HAIR, 0.6)
# callout
rect(s, M, 5.92, CW, 0.62, fill=NAVY, radius=0.08)
txt(s, M + 0.28, 6.06, CW - 0.5, 0.34,
    "判定结果：四条同时满足 → 进入 24 项主数据清单；缺任何一条 → 留在业务表，只做规范，不做统一。",
    10, WHITE, spacing=1.2)

# ------------------------------------------------------------------ 05 24 项
s = prs.slides.add_slide(BLANK)
chrome(s, "24 项主数据，五个业务域", 5)
txt(s, M, 1.02, CW, 0.3, "按“谁产生、谁引用、谁负责”划域，每项只有一个写入口。", 10, GRAY)

domains = [
    ("组织与人员", "07", ["法人主体", "组织 / 成本中心", "岗位职级", "员工", "自然人", "技能字典", "员工技能"],
     "一套组织树、一套员工号"),
    ("客户与合同", "04", ["客户", "客户联系人", "合同", "合同收款里程碑"],
     "客户号、合同号对外可用"),
    ("项目与交付", "04", ["项目", "项目阶段", "任务 / WBS", "交付里程碑"],
     "项目号贯穿全链，不回填"),
    ("资源与预算", "06", ["项目预算", "项目成员", "成员期间", "成本单价", "结算单价", "工作日历"],
     "单价带生效期，不覆盖历史"),
    ("财务与核算", "03", ["财年", "会计期间", "统一科目"],
     "科目对齐财务，期间不跨"),
]
cw_ = (CW - 4 * 0.18) / 5
for i, (name, cnt, items, note) in enumerate(domains):
    x = M + i * (cw_ + 0.18)
    rect(s, x, 1.5, cw_, 4.92, fill=WHITE, line=BORDER, lw=0.8, radius=0.04)
    rect(s, x + 0.06, 1.5, cw_ - 0.12, 0.05, fill=NAVY, radius=0.5)
    txt(s, x + 0.2, 1.72, cw_ - 0.4, 0.26, name, 10.5, BLACK, True, spacing=1.0)
    txt(s, x + 0.2, 2.06, 0.7, 0.4, cnt, 20, NAVY, True, spacing=1.0)
    txt(s, x + 0.62, 2.2, 1.0, 0.24, "项", 8, MUTED)
    line(s, x + 0.2, 2.62, x + cw_ - 0.2, 2.62, HAIR, 0.7)
    for j, it in enumerate(items):
        yy = 2.78 + j * 0.46
        txt(s, x + 0.2, yy, 0.16, 0.22, "·", 10, BLUE, True)
        txt(s, x + 0.34, yy, cw_ - 0.5, 0.26, it, 8.8, GRAY, spacing=1.0)
    line(s, x + 0.2, 5.92, x + cw_ - 0.2, 5.92, HAIR, 0.6)
    txt(s, x + 0.2, 6.02, cw_ - 0.35, 0.3, note, 7.5, MUTED, spacing=1.2)
txt(s, M, 6.58, CW, 0.24,
    "其余为业务单据（合同行、工时、结算单、发票）或派生视图（项目利润、应收余额），不纳入主数据治理。",
    8.5, MUTED)

# ------------------------------------------------------------------ 06 section 02
section("02", "业务链路", "五个阶段、十二个节点，每个阶段只交一件东西。", 6)

# ------------------------------------------------------------------ 07 链路总览
s = prs.slides.add_slide(BLANK)
chrome(s, "一条主线，五个阶段，十二个节点", 7)
txt(s, M, 1.02, CW, 0.3, "主键逐段传递：不允许断点，也不允许回填。", 10, GRAY)

stages = [
    ("A", "签约", ["客户 / 商机", "合同签订"], "→ 合同签订交接单"),
    ("B", "立项与计划", ["立项 / 项目", "阶段 · 任务 · 里程碑", "项目预算"], "→ 立项交接单 · 项目计划包"),
    ("C", "资源与执行", ["人员配置", "工时填报 · 审批 · 锁定"], "→ 资源需求单 · 成员期间"),
    ("D", "结算与收款", ["结算", "开票", "回款 / 应收"], "→ 结算单 · 发票 · 核销单"),
    ("E", "成本与利润", ["成本归集", "项目利润 / 经营分析"], "→ 成本归集包 · 经营分析包"),
]
colw = (CW - 4 * 0.16) / 5
for i, (k, name, nodes, hand) in enumerate(stages):
    x = M + i * (colw + 0.16)
    rect(s, x, 1.5, colw, 3.42, fill=PANEL, line=None, radius=0.04)
    rect(s, x + 0.18, 1.66, 0.4, 0.4, fill=NAVY, radius=0.16)
    txt(s, x + 0.18, 1.74, 0.4, 0.24, k, 9, WHITE, True, align=PP_ALIGN.CENTER)
    txt(s, x + 0.68, 1.72, colw - 0.8, 0.3, name, 11, NAVY, True, spacing=1.0)
    for j, n in enumerate(nodes):
        yy = 2.24 + j * 0.58
        b = rect(s, x + 0.18, yy, colw - 0.36, 0.48, fill=WHITE, line=BORDER, lw=0.7, radius=0.1)
        tf = b.text_frame
        tf.vertical_anchor = MSO_ANCHOR.MIDDLE
        p = tf.paragraphs[0]
        p.alignment = PP_ALIGN.CENTER
        r = p.add_run()
        r.text = n
        style_run(r, 8.6, GRAY)
    line(s, x + 0.18, 4.3, x + colw - 0.18, 4.3, RGBColor(0xD3, 0xE0, 0xF2), 0.6)
    txt(s, x + 0.18, 4.42, colw - 0.32, 0.4, hand, 7.4, BLUE, spacing=1.2)

# key chain
rect(s, M, 5.12, CW, 1.18, fill=PANEL, radius=0.04)
txt(s, M + 0.25, 5.26, 3.0, 0.22, "主键主线  /  KEY CHAIN", 8, BLUE, True, spc=100)
txt(s, M + 0.25, 5.58, CW - 0.5, 0.55,
    "customer_id → contract_id → project_id → task_id → employee_id → timesheet_item_id\n→ settlement_order_id → invoice_id → receipt_id → period_id / subject_id → 项目利润",
    8.2, GRAY, spacing=1.45)

# ------------------------------------------------------------------ 08 交接物
s = prs.slides.add_slide(BLANK)
chrome(s, "每个阶段只交一件东西", 8)
txt(s, M, 1.02, CW, 0.3, "交接物 = 主键 + 责任人 + 验收标准。", 10, GRAY)

cols = [(M, 0.45, "阶段"), (M + 0.55, 2.3, "交接物"), (M + 3.1, 3.0, "传递主键"), (M + 6.85, 4.5, "业务含义")]
rect(s, M, 1.5, CW, 0.44, fill=HEAD_BG, radius=0.03)
for x, w, t in cols:
    txt(s, x, 1.59, w, 0.26, t, 8.5, NAVY, True, spc=60)

rows = [
    ("A", "签约", "合同签订交接单", "customer_id、opportunity_id",
     "客户与商机转合同；收款里程碑按预付、到货、验收、质保拆开"),
    ("B", "立项与计划", "立项交接单 → 项目计划包", "contract_id、milestone_id、project_id",
     "合同转项目；拆阶段、WBS、交付里程碑，合同额拆四类预算"),
    ("C", "资源与执行", "资源需求单 → 成员 / 期间", "task_id、budget_hours、member_id",
     "按任务和预算工时配人；按周按任务填工时，审批后锁定不可改"),
    ("D", "结算与收款", "结算交接单 → 开票 → 回款核销单", "timesheet_item_id、settlement_order_id、invoice_id",
     "可结算工时转结算单；结算或里程碑转发票；收款按发票核销"),
    ("E", "成本与利润", "成本归集包 → 经营分析包", "全部主键（项目 / 组织 / 客户）",
     "工时与结算转成本；用 EAC 倒推利润与毛利率，三维度复盘"),
]
y = 1.94
for i, (k, name, hand, keys, mean) in enumerate(rows):
    if i % 2 == 0:
        rect(s, M, y, CW, 0.86, fill=RGBColor(0xFB, 0xFC, 0xFE))
    txt(s, M, y + 0.31, 0.36, 0.24, k, 9, BLUE, True)
    txt(s, M + 0.48, y + 0.28, 1.0, 0.3, name, 9.8, BLACK, True, spacing=1.0)
    txt(s, M + 2.25, y + 0.29, 2.7, 0.5, hand, 9.2, GRAY, spacing=1.3)
    txt(s, M + 5.0, y + 0.3, 2.9, 0.5, keys, 8, NAVY, spacing=1.3)
    txt(s, M + 8.05, y + 0.28, 3.55, 0.5, mean, 8.8, GRAY, spacing=1.3)
    line(s, M, y + 0.9, W - M, y + 0.9, HAIR, 0.6)
    y += 0.86

# ------------------------------------------------------------------ 09 场景
s = prs.slides.add_slide(BLANK)
chrome(s, "五个场景，定义系统的边界", 9)
txt(s, M, 1.02, CW, 0.3, "每个场景写清“谁在什么时候、用什么单据、产生什么数据”。", 10, GRAY)

scenes = [
    ("A", "签约", "销售建客户档案、推商机；赢单后转合同，按预付、到货、验收、质保拆收款里程碑。"),
    ("B", "立项与计划", "合同转项目、指定项目经理；交付范围拆成阶段、任务（WBS）与交付里程碑，合同额拆四类预算。"),
    ("C", "资源与执行", "按任务与预算工时配人，记录进场 / 离场、投入比例、成本与结算单价；按周填工时，审批后锁定。"),
    ("D", "结算与收款", "锁定且可结算的工时转结算单；结算单或合同里程碑转发票；客户付款后按发票核销，形成应收与逾期。"),
    ("E", "成本与利润", "工时按人月成本分摊人工成本，费用与采购按项目归集；用 EAC 倒推利润与毛利率，按项目 / 组织 / 客户复盘。"),
]
tw = (CW - 2 * 0.24) / 3
for i, (k, name, desc) in enumerate(scenes[:3]):
    x = M + i * (tw + 0.24)
    rect(s, x, 1.5, tw, 2.12, fill=WHITE, line=BORDER, lw=0.8, radius=0.04)
    rect(s, x, 1.5, 0.06, 2.12, fill=NAVY)
    txt(s, x + 0.28, 1.68, 0.35, 0.24, k, 9.5, BLUE, True)
    txt(s, x + 0.62, 1.66, tw - 0.8, 0.3, name, 11.5, BLACK, True, spacing=1.0)
    txt(s, x + 0.28, 2.08, tw - 0.5, 1.4, desc, 8.8, GRAY, spacing=1.5)
bw = (CW - 0.24) / 2
for i, (k, name, desc) in enumerate(scenes[3:]):
    x = M + i * (bw + 0.24)
    rect(s, x, 3.86, bw, 2.12, fill=WHITE, line=BORDER, lw=0.8, radius=0.04)
    rect(s, x, 3.86, 0.06, 2.12, fill=NAVY)
    txt(s, x + 0.28, 4.04, 0.35, 0.24, k, 9.5, BLUE, True)
    txt(s, x + 0.62, 4.02, bw - 0.8, 0.3, name, 11.5, BLACK, True, spacing=1.0)
    txt(s, x + 0.28, 4.44, bw - 0.5, 1.4, desc, 8.8, GRAY, spacing=1.5)
txt(s, M, 6.3, CW, 0.24, "场景边界一旦写清，系统就不会长歪；边界不清，需求就会无限扩张。", 8.5, MUTED)

# ------------------------------------------------------------------ 10 section 03
section("03", "断点与下一步", "先看清哪里断，再决定怎么补、按什么顺序补。", 10)

# ------------------------------------------------------------------ 11 断点
s = prs.slides.add_slide(BLANK)
chrome(s, "四套系统，六个断点", 11)
txt(s, M, 1.02, CW, 0.3, "断点不在功能，而在主键与口径——每一处都让利润算不出来。", 10, GRAY)

cols = [(M, 0.4, "#"), (M + 0.46, 2.2, "断点"), (M + 2.85, 3.9, "断在哪"),
        (M + 6.95, 2.25, "影响"), (M + 9.35, 2.2, "补法")]
rect(s, M, 1.5, CW, 0.42, fill=HEAD_BG, radius=0.03)
for x, w, t in cols:
    txt(s, x, 1.58, w, 0.24, t, 8.5, NAVY, True, spc=60)

bps = [
    ("01", "合同与项目脱钩", "CRM 合同与 PMT 项目靠合同号文本关联；子合同、变更无版本。", "收入有合同、成本有项目，两边对不上", "合同-项目关联表 + 唯一编码"),
    ("02", "人员两套 ID", "HR 员工与 PMT 成员各一套编号；调岗、离职后历史归属漂移。", "人工成本摊到错的人、错的项目", "员工主数据唯一，成员期间留痕"),
    ("03", "工时到不了任务", "PMT 有 WBS，HR 工时只填到项目，任务维度对不上。", "任务级成本缺失，大项目算不准", "工时明细强制 task_id"),
    ("04", "单价两套口径", "成本单价在 HR，结算单价在 PMT 与财务，各算各的。", "人工成本与结算金额长期有差异", "成本 / 结算单价统一建模"),
    ("05", "结算—开票—回款断链", "结算单在 PMT，发票与回款在财务，勾稽靠 Excel。", "应收余额与逾期不可信", "结算 → 发票 → 核销单向引用"),
    ("06", "主数据多源", "客户、组织、科目四套系统各存一份，编码规则不一。", "报表口径打架，谁都不敢签字", "24 项主数据收口 md_*"),
]
y = 1.94
for i, (n, t, where, impact, fix) in enumerate(bps):
    if i % 2 == 0:
        rect(s, M, y, CW, 0.74, fill=RGBColor(0xFB, 0xFC, 0xFE))
    txt(s, M, y + 0.26, 0.4, 0.24, n, 8.5, BLUE, True)
    txt(s, M + 0.46, y + 0.21, 2.25, 0.4, t, 9.8, BLACK, True, spacing=1.1)
    txt(s, M + 2.85, y + 0.23, 3.95, 0.5, where, 8.5, GRAY, spacing=1.3)
    txt(s, M + 6.95, y + 0.23, 2.3, 0.5, impact, 8.5, RED, spacing=1.3)
    txt(s, M + 9.35, y + 0.23, 2.2, 0.5, fix, 8.2, NAVY, spacing=1.3)
    line(s, M, y + 0.78, W - M, y + 0.78, HAIR, 0.6)
    y += 0.74

# ------------------------------------------------------------------ 12 模式
s = prs.slides.add_slide(BLANK)
chrome(s, "纯整合与纯重建，都不该单独选", 12)
txt(s, M, 1.02, CW, 0.3, "一个只解决“通”，一个只解决“终局”；而 CEO 要的是“算得准”。", 10, GRAY)

opts = [
    ("纯整合", False, ["系统能通、接口能跑", "主数据仍多源，利润算不出", "只解决“通”"]),
    ("纯重建", False, ["目标模型一步到位", "业务中断、周期与迁移不可控", "只解决“终局”"]),
    ("整合打底 + 重建收口", True, ["先拿主数据唯一性与断点清单", "两段式投入，阶段验收", "推荐：先准，再快"]),
]
cw3 = (CW - 2 * 0.22) / 3
for i, (name, hi, vals) in enumerate(opts):
    x = M + i * (cw3 + 0.22)
    if hi:
        rect(s, x, 1.5, cw3, 4.12, fill=NAVY, radius=0.04)
        rect(s, x + 0.22, 1.66, 0.62, 0.22, fill=RED, radius=0.3)
        txt(s, x + 0.22, 1.69, 0.62, 0.18, "推荐", 7, WHITE, True, align=PP_ALIGN.CENTER)
        txt(s, x + 0.22, 1.98, cw3 - 0.4, 0.4, name, 13, WHITE, True, spacing=1.1)
    else:
        rect(s, x, 1.5, cw3, 4.12, fill=WHITE, line=BORDER, lw=0.9, radius=0.04)
        txt(s, x + 0.22, 1.66, cw3 - 0.4, 0.4, name, 13, BLACK, True, spacing=1.1)
    line(s, x + 0.22, 2.5, x + cw3 - 0.22, 2.5, WHITE if hi else HAIR, 0.8,
         alpha=30 if hi else None)
    labels = ["解决什么", "代价", "结论"]
    for j, lab in enumerate(labels):
        yy = 2.68 + j * 0.92
        txt(s, x + 0.22, yy, 1.0, 0.2, lab, 7.5,
            RGBColor(0x9D, 0xB6, 0xE2) if hi else MUTED, spc=40)
        txt(s, x + 0.22, yy + 0.22, cw3 - 0.42, 0.55, vals[j], 9.2,
            WHITE if hi else GRAY, spacing=1.35)
line(s, M, 5.78, W - M, 5.78, HAIR, 0.8)
txt(s, M, 5.9, 1.2, 0.24, "判断", 8.5, BLUE, True, spc=80)
txt(s, M + 1.2, 5.88, CW - 1.2, 0.4,
    "纯整合交付不了 CEO 要的“项目利润”，纯重建承受不了业务中断——用整合换确定性，用重建换终局。",
    9.8, BLACK, spacing=1.3)
txt(s, M, 6.55, CW, 0.24, "说明：两种路径不是先后替代关系，而是同一目标下的两段交付。", 8, MUTED)

# ------------------------------------------------------------------ 13 路径
s = prs.slides.add_slide(BLANK)
chrome(s, "整合打底，重建收口", 13)
txt(s, M, 1.02, CW, 0.3, "目的不是永久保留四套系统，而是用最低成本拿到主数据唯一性和真实断点清单。", 10, GRAY)

steps = [
    ("01", "盘底", "四套系统的表清单、数据量、编码冲突、重复率、空值率、金额单位、状态枚举、比例口径。", "产出：系统现状底表"),
    ("02", "主数据", "24 项主数据落地；旧表视图化；写入口统一收口到 md_*；旧 ID 存入 md_id_mapping。", "产出：唯一主数据 + 映射表"),
    ("03", "试点", "1 个客户、1 个合同、1 个项目、2–3 名员工、2 周工时、1 个结算批次、1 张发票、1 笔回款，跑通 A→E。", "产出：端到端可追溯样例"),
]
sw = (CW - 2 * 0.5) / 3
line(s, M, 1.62, W - M, 1.62, HEAD_BG, 1.2)
for i, (n, t, d, out) in enumerate(steps):
    x = M + i * (sw + 0.5)
    rect(s, x, 1.56, 0.12, 0.12, fill=NAVY)
    txt(s, x + 0.22, 1.76, 0.6, 0.26, n, 9, BLUE, True, spc=40)
    txt(s, x, 1.98, sw - 0.2, 0.32, t, 15, BLACK, True, spacing=1.0)
    txt(s, x, 2.42, sw - 0.2, 1.1, d, 9.2, GRAY, spacing=1.55)
    txt(s, x, 3.58, sw - 0.2, 0.24, out, 8.2, NAVY, spc=20)

rect(s, M, 4.28, CW, 2.05, fill=PANEL, radius=0.04)
txt(s, M + 0.3, 4.42, 3.2, 0.24, "退出标准  /  EXIT CRITERIA", 8, BLUE, True, spc=120)
metrics = [("99.5%", "主数据唯一率 ≥"), ("100%", "试点链路可追溯"), ("0.5%", "合同·里程碑·结算·开票·回款金额差异 ≤")]
for i, (num, lab) in enumerate(metrics):
    x = M + 0.3 + i * 3.85
    txt(s, x, 4.78, 2.6, 0.55, num, 25, NAVY, True, spacing=1.0)
    txt(s, x, 5.44, 3.5, 0.4, lab, 9, GRAY, spacing=1.3)
    if i:
        line(s, x - 0.35, 4.76, x - 0.35, 5.72, RGBColor(0xCF, 0xDD, 0xF1), 0.7)
txt(s, M + 0.3, 5.92, CW - 0.6, 0.24,
    "三项同时达标，才进入第二阶段（按链路重建）；未达标只做补数，不扩范围。", 8.5, MUTED)

# ------------------------------------------------------------------ 14 closing
s = prs.slides.add_slide(BLANK)
dark_bg(s)
logo(s, dark=True)
txt(s, 1.0, 2.5, 8.0, 0.5, "谢谢关注", 34, WHITE, True, spacing=1.0)
txt(s, 1.0, 3.22, 8.6, 0.4, "先让数据唯一，再让链路闭环。", 18, RGBColor(0xBF, 0xCE, 0xE8), spacing=1.2)
line(s, 1.02, 3.9, 3.0, 3.9, RGBColor(0x5B, 0x84, 0xD2), 1.2)
txt(s, 1.0, 4.1, 8.0, 0.7, "24 项主数据  ·  12 个节点  ·  5 个阶段\n一条链路，从签约走到项目利润。",
    10.5, SUBTXT, spacing=1.7)
txt(s, 1.0, 6.02, 10.0, 0.5,
    "服务热线  0755-86569152      www.iscmtech.com", 9, RGBColor(0xA9, 0xB9, 0xD6), spc=30)
txt(s, 1.0, 6.5, 10.0, 0.3, "链宇技术  ·  2026 内部方案  ·  请勿外传", 8, RGBColor(0x7E, 0x92, 0xB8), spc=40)

out = "/workspace/链宇技术-主数据与业务链路整合方案-模板版.pptx"
prs.save(out)
print("saved", out, len(prs.slides._sldIdLst))
