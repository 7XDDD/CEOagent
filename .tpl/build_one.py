# -*- coding: utf-8 -*-
"""链宇技术 · 业务链路与核心数据（讨论稿）—— 官方模板视觉体系"""
from pptx import Presentation
from pptx.util import Inches, Pt
from pptx.dml.color import RGBColor
from pptx.enum.text import PP_ALIGN, MSO_ANCHOR, MSO_AUTO_SIZE
from pptx.enum.shapes import MSO_SHAPE, MSO_CONNECTOR
from pptx.enum.dml import MSO_LINE
from pptx.oxml.ns import qn
from lxml import etree

W, H = 13.333, 7.5
M = 0.85
CW = W - 2 * M

NAVY    = RGBColor(0x09, 0x31, 0x94)
BLUE    = RGBColor(0x15, 0x7C, 0xEF)
RED     = RGBColor(0xF0, 0x24, 0x2B)
BLACK   = RGBColor(0x00, 0x00, 0x00)
GRAY    = RGBColor(0x52, 0x53, 0x54)
LIGHT   = RGBColor(0xF7, 0xF9, 0xFB)
WHITE   = RGBColor(0xFF, 0xFF, 0xFF)
HAIR    = RGBColor(0xE3, 0xE9, 0xF4)
HEAD_BG = RGBColor(0xDE, 0xE9, 0xFB)
PANEL   = RGBColor(0xEF, 0xF4, 0xFC)
BORDER  = RGBColor(0xBF, 0xD3, 0xEE)
MUTED   = RGBColor(0x8A, 0x93, 0xA3)
DARK1   = RGBColor(0x1A, 0x27, 0x46)
DARK2   = RGBColor(0x12, 0x30, 0x6C)
SUBTXT  = RGBColor(0xC9, 0xD3, 0xE4)
FONT = "微软雅黑"

prs = Presentation()
prs.slide_width = Inches(W)
prs.slide_height = Inches(H)
BLANK = prs.slide_layouts[6]
LOGO_W = ".tpl/logo_white.png"
LOGO_N = ".tpl/logo_navy.png"


# ------------------------------------------------------------------ helpers
def style_run(r, size=9, color=BLACK, bold=False, spc=None):
    f = r.font
    f.size = Pt(size)
    f.bold = bold
    f.color.rgb = color
    f.name = "Arial"
    rPr = r._r.get_or_add_rPr()
    ea = etree.SubElement(rPr, qn('a:ea'))
    ea.set('typeface', FONT)
    if spc is not None:
        rPr.set('spc', str(spc))


def txt(slide, x, y, w, h, text, size=9, color=BLACK, bold=False,
        align=PP_ALIGN.LEFT, anchor=MSO_ANCHOR.TOP, spacing=1.25, spc=None):
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


def line(slide, x1, y1, x2, y2, color=HAIR, lw=0.75, alpha=None, dash=None):
    ln = slide.shapes.add_connector(MSO_CONNECTOR.STRAIGHT, Inches(x1), Inches(y1),
                                    Inches(x2), Inches(y2))
    ln.shadow.inherit = False
    _strip(ln)
    ln.line.color.rgb = color
    ln.line.width = Pt(lw)
    if dash:
        ln.line.dash_style = dash
    if alpha is not None:
        sf = ln.line._get_or_add_ln().find(qn('a:solidFill'))
        if sf is not None:
            a = etree.SubElement(sf[0], qn('a:alpha'))
            a.set('val', str(int(alpha * 1000)))
    return ln


def arrow(slide, x1, y1, x2, y2, color=BLUE, lw=1.1, dash=None, head=True):
    ln = line(slide, x1, y1, x2, y2, color, lw, dash=dash)
    if head:
        lnel = ln.line._get_or_add_ln()
        tail = etree.SubElement(lnel, qn('a:tailEnd'))
        tail.set('type', 'triangle')
        tail.set('w', 'sm')
        tail.set('len', 'sm')
    return ln


def logo(slide, dark=True, h=0.34):
    slide.shapes.add_picture(LOGO_W if dark else LOGO_N, Inches(12.02), Inches(0.30), height=Inches(h))


def dark_bg(slide):
    r = rect(slide, 0, 0, W, H)
    r.fill.gradient()
    r.fill.gradient_angle = 135
    st = r.fill.gradient_stops
    st[0].color.rgb = DARK1
    st[0].position = 0.0
    st[1].color.rgb = DARK2
    st[1].position = 1.0
    rect(slide, 4.4, 1.4, 9.0, 6.6, fill=RGBColor(0x2E, 0x5D, 0xBB), shape=MSO_SHAPE.OVAL, alpha=6)
    sq = [(2.05, 0.85, 0.52, 3), (3.05, 0.85, 0.52, 3), (4.05, 1.45, 0.52, 3),
          (5.05, 0.25, 0.52, 3), (6.05, 1.45, 0.52, 4), (7.05, 0.85, 0.52, 4),
          (8.05, 0.85, 0.52, 3), (9.05, 0.25, 0.52, 3), (3.55, 2.35, 0.52, 2),
          (4.55, 2.85, 0.52, 3), (9.55, 1.55, 0.52, 2), (10.55, 0.85, 0.52, 2),
          (5.55, 2.15, 0.52, 3), (8.55, 2.15, 0.52, 2), (6.55, 0.25, 0.52, 4)]
    for x, y, s_, a in sq:
        rect(slide, x, y, s_, s_, fill=WHITE, alpha=a)
    for cx_, rot in ((11.70, 17), (14.10, -17)):
        b = rect(slide, cx_ - 0.43, 0.55, 0.86, 8.0, fill=WHITE, alpha=2.4)
        b.rotation = rot
    for y in (1.35, 2.55, 3.75):
        line(slide, 0.45, y, 12.9, y, WHITE, 0.5, alpha=8)


def light_bg(slide):
    rect(slide, 0, 0, W, H, fill=LIGHT)
    rect(slide, 10.1, 4.4, 5.6, 5.6, fill=RGBColor(0xE9, 0xF1, 0xFD), shape=MSO_SHAPE.OVAL, alpha=45)
    for w_, h_, a in [(3.2, 3.2, 20), (5.0, 5.0, 14), (6.8, 6.8, 9)]:
        rect(slide, -2.2 - w_ / 2, 8.2 - h_ / 2, w_, h_, fill=None,
             line=RGBColor(0x9E, 0xBC, 0xE8), lw=0.5, shape=MSO_SHAPE.OVAL, alpha=a)
    rect(slide, 0, 6.9, W, 0.6, fill=RGBColor(0xEC, 0xF3, 0xFD), alpha=40)


def chrome(slide, title, page, sub=None):
    light_bg(slide)
    rect(slide, 0.55, 0.44, 0.09, 0.13, fill=RED, radius=0.5)
    rect(slide, 0.55, 0.57, 0.09, 0.21, fill=NAVY, radius=0.5)
    txt(slide, 0.78, 0.38, 10.8, 0.42, title, 22, BLACK, True, spacing=1.0)
    if sub:
        txt(slide, M, 1.02, CW, 0.28, sub, 9.8, GRAY, spacing=1.2)
    logo(slide, dark=False)
    line(slide, 0.55, 7.02, 12.78, 7.02, HAIR, 0.5)
    txt(slide, 0.55, 7.09, 5.0, 0.22, "链宇技术©2026 商业机密", 8, MUTED, spc=20)
    txt(slide, 11.78, 7.09, 1.0, 0.22, f"{page}", 8, MUTED, align=PP_ALIGN.RIGHT)


def section(num, title, subtitle, page):
    s = prs.slides.add_slide(BLANK)
    dark_bg(s)
    logo(s, dark=True)
    txt(s, 0, 2.02, W, 0.24, f"SECTION {num}", 9, RGBColor(0x8F, 0xA9, 0xD6), True,
        align=PP_ALIGN.CENTER, spc=240)
    line(s, 4.32, 2.36, 9.0, 2.36, WHITE, 0.6, alpha=22)
    txt(s, 0, 2.56, W, 0.62, title, 30, WHITE, True, align=PP_ALIGN.CENTER, spacing=1.1)
    line(s, 4.32, 3.34, 9.0, 3.34, WHITE, 0.6, alpha=22)
    txt(s, 0, 3.52, W, 0.3, subtitle, 11, SUBTXT, align=PP_ALIGN.CENTER, spacing=1.2)
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


def node(slide, x, y, w, h, code, name, master, discuss=False):
    rect(slide, x, y, w, h, fill=WHITE, line=BORDER, lw=0.8, radius=0.07)
    txt(slide, x + 0.12, y + 0.08, 0.42, 0.2, code, 7.2, BLUE, True, spc=20)
    txt(slide, x + 0.5, y + 0.06, w - 0.72, 0.26, name, 8.6, BLACK, True, spacing=1.0)
    txt(slide, x + 0.12, y + 0.38, w - 0.2, 0.3, master, 6.6, NAVY, spacing=1.15)
    if discuss:
        rect(slide, x + w - 0.18, y + 0.09, 0.09, 0.09, fill=RED, shape=MSO_SHAPE.OVAL)


# ================================================================== 单页：核心数据
s = prs.slides.add_slide(BLANK)
light_bg(s)
rect(s, 0.55, 0.44, 0.09, 0.13, fill=RED, radius=0.5)
rect(s, 0.55, 0.57, 0.09, 0.21, fill=NAVY, radius=0.5)
txt(s, 0.78, 0.38, 10.8, 0.42, "四个系统，十八个数据模块", 22, BLACK, True, spacing=1.0)
txt(s, M, 1.02, CW, 0.28, "功能都在，只是各管一段——数据、单据与缺口，一张图看全。", 9.8, GRAY)
logo(s, dark=False)
line(s, 0.55, 7.02, 12.78, 7.02, HAIR, 0.5)
txt(s, 0.55, 7.09, 5.0, 0.22, "链宇技术©2026 商业机密", 8, MUTED, spc=20)

CW4 = 2.77
GAP = 0.18
systems = [
    ("HR", "人力资源", "07", RGBColor(0x5B, 0x84, 0xD2),
     ["员工", "组织", "劳动合同", "考勤", "审批", "薪资", "招聘"],
     "员工档案、考勤单、薪资单",
     "员工与项目成员两套 ID；成本单价无生效期",
     "员工号 · 组织编码"),
    ("CRM", "客户系统", "03", BLUE,
     ["售前商机", "客户", "合同"],
     "商机、合同、收款计划",
     "合同与项目只能靠合同号文本关联",
     "客户号 · 合同号"),
    ("PMT", "项目管理", "04", NAVY,
     ["项目基础信息", "项目计划", "执行状态", "工时"],
     "项目、任务、工时、结算单",
     "工时只到项目不到任务；结算与财务脱钩",
     "项目号 · 任务号"),
]

for i, (code, name, cnt, col, mods, docs, gap, key) in enumerate(systems):
    x = M + i * (CW4 + GAP)
    rect(s, x, 1.45, CW4, 4.85, fill=WHITE, line=BORDER, lw=0.8, radius=0.04)
    rect(s, x, 1.45, CW4, 0.62, fill=col, radius=0.05)
    txt(s, x + 0.2, 1.54, 1.0, 0.2, code, 7.2, WHITE, True, spc=100)
    txt(s, x + 0.2, 1.74, CW4 - 0.9, 0.26, name, 10.5, WHITE, True, spacing=1.0)
    txt(s, x + CW4 - 0.62, 1.64, 0.42, 0.3, cnt, 14, WHITE, True, align=PP_ALIGN.RIGHT)
    txt(s, x + CW4 - 0.62, 1.94, 0.42, 0.18, "模块", 6.2, WHITE, align=PP_ALIGN.RIGHT)

    # 模块区
    rect(s, x + 0.15, 2.16, CW4 - 0.3, 1.58, fill=RGBColor(0xF7, 0xFA, 0xFE), line=None, radius=0.05)
    txt(s, x + 0.28, 2.24, 1.6, 0.18, "数据模块", 6.6, MUTED, spc=60)
    for j, m in enumerate(mods):
        cx = x + 0.27 + (j % 2) * 1.155
        cy = 2.44 + (j // 2) * 0.3
        rect(s, cx, cy, 1.075, 0.24, fill=WHITE, line=BORDER, lw=0.6, radius=0.18)
        txt(s, cx, cy + 0.05, 1.075, 0.16, m, 7.0, NAVY, align=PP_ALIGN.CENTER, spacing=1.0)

    txt(s, x + 0.2, 3.9, 1.6, 0.18, "主要单据", 6.6, MUTED, spc=60)
    txt(s, x + 0.2, 4.08, CW4 - 0.38, 0.4, docs, 7.8, NAVY, spacing=1.35)
    txt(s, x + 0.2, 4.62, 1.6, 0.18, "缺口", 6.6, RED, True, spc=60)
    txt(s, x + 0.2, 4.8, CW4 - 0.38, 0.7, gap, 7.6, RED, spacing=1.4)
    line(s, x + 0.2, 5.82, x + CW4 - 0.2, 5.82, HAIR, 0.6)
    txt(s, x + 0.2, 5.92, CW4 - 0.36, 0.3, "关键主键：" + key, 7.2, NAVY, spacing=1.2)

# 财务
x = M + 3 * (CW4 + GAP)
col = RGBColor(0x0E, 0x4B, 0xA8)
rect(s, x, 1.45, CW4, 4.85, fill=WHITE, line=BORDER, lw=0.8, radius=0.04)
rect(s, x, 1.45, CW4, 0.62, fill=col, radius=0.05)
txt(s, x + 0.2, 1.54, 1.0, 0.2, "FIN", 7.2, WHITE, True, spc=100)
txt(s, x + 0.2, 1.74, CW4 - 0.9, 0.26, "财务系统", 10.5, WHITE, True, spacing=1.0)
txt(s, x + CW4 - 0.62, 1.64, 0.42, 0.3, "04", 14, WHITE, True, align=PP_ALIGN.RIGHT)
txt(s, x + CW4 - 0.62, 1.94, 0.42, 0.18, "模块", 6.2, WHITE, align=PP_ALIGN.RIGHT)

rect(s, x + 0.15, 2.16, CW4 - 0.3, 1.58, fill=RGBColor(0xF7, 0xFA, 0xFE), line=None, radius=0.05)
txt(s, x + 0.28, 2.24, 1.6, 0.18, "数据模块", 6.6, MUTED, spc=60)
rect(s, x + 0.27, 2.44, 2.23, 0.24, fill=WHITE, line=BORDER, lw=0.6, radius=0.18)
txt(s, x + 0.27, 2.49, 2.23, 0.16, "预算  ·  6 类", 7.0, NAVY, align=PP_ALIGN.CENTER)
txt(s, x + 0.3, 2.74, 2.18, 0.3, "合同 · 收入 · 税费 · 回款 · 利润 · 现金流", 6.6, MUTED, spacing=1.3)
for k, m in enumerate(["现金流收支", "成本科目", "税费"]):
    cx = x + 0.27 + (k % 2) * 1.155
    cy = 3.12 + (k // 2) * 0.3
    rect(s, cx, cy, 1.075, 0.24, fill=WHITE, line=BORDER, lw=0.6, radius=0.18)
    txt(s, cx, cy + 0.05, 1.075, 0.16, m, 7.0, NAVY, align=PP_ALIGN.CENTER, spacing=1.0)

txt(s, x + 0.2, 3.9, 1.6, 0.18, "主要单据", 6.6, MUTED, spc=60)
txt(s, x + 0.2, 4.08, CW4 - 0.38, 0.4, "预算表、凭证、收支表", 7.8, NAVY, spacing=1.35)
txt(s, x + 0.2, 4.62, 1.6, 0.18, "缺口", 6.6, RED, True, spc=60)
txt(s, x + 0.2, 4.8, CW4 - 0.38, 0.7, "结算—开票—回款靠 Excel 勾稽；预算与执行两套口径", 7.6, RED, spacing=1.4)
line(s, x + 0.2, 5.82, x + CW4 - 0.2, 5.82, HAIR, 0.6)
txt(s, x + 0.2, 5.92, CW4 - 0.36, 0.3, "关键主键：发票号 · 科目 · 期间", 7.2, NAVY, spacing=1.2)

txt(s, M, 6.5, CW, 0.24,
    "合计 18 个模块；预算按合同、收入、税费、回款、利润、现金流六类拆分，统一在财务口径下管理。",
    8.2, MUTED)

out = "/workspace/链宇技术-核心数据-四个系统十八个模块.pptx"
prs.save(out)
print("saved", out, len(prs.slides._sldIdLst))
