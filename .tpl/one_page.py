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
