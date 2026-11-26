# ================================================================== 01 cover
s = prs.slides.add_slide(BLANK)
dark_bg(s)
logo(s, dark=True)
txt(s, 1.0, 2.10, 8.6, 0.3, "链宇技术  /  2026 内部讨论稿", 10, SUBTXT, spc=120)
txt(s, 0.98, 2.44, 9.4, 1.7, "一条链路，一套数据", 36, WHITE, True, spacing=1.28)
line(s, 1.02, 3.62, 3.1, 3.62, RGBColor(0x5B, 0x84, 0xD2), 1.2)
txt(s, 1.0, 3.82, 8.8, 0.7,
    "基于 CRM、PMT、HR、财务四套系统已有功能的业务链路梳理，\n以及四个系统各自负责的 18 个数据模块。",
    12, SUBTXT, spacing=1.55)
txt(s, 1.0, 5.95, 8.6, 0.6, "汇报方：链宇技术（Lianyu Technology）\n2026 年 11 月  |  内部绝密", 9,
    RGBColor(0xA9, 0xB9, 0xD6), spacing=1.6)

# ================================================================== 02 目录（菜单式）
s = prs.slides.add_slide(BLANK)
r = rect(s, 0, 0, W, H)
r.fill.gradient()
r.fill.gradient_angle = 120
st = r.fill.gradient_stops
st[0].color.rgb = RGBColor(0x0A, 0x2E, 0x7A)
st[0].position = 0.0
st[1].color.rgb = RGBColor(0x0C, 0x3C, 0x97)
st[1].position = 1.0
for cx_, rot in ((11.80, 17), (14.20, -17)):
    b = rect(s, cx_ - 0.43, 0.55, 0.86, 8.0, fill=WHITE, alpha=2.2)
    b.rotation = rot
logo(s, dark=True)
txt(s, 0.95, 0.82, 4.0, 0.5, "目录", 32, WHITE, True, spacing=1.0)
txt(s, 0.97, 1.40, 4.0, 0.26, "CONTENTS", 13, RGBColor(0x8F, 0xA9, 0xD6), spc=220)

items = [
    ("系统现状", "CURRENT STATE", "四套系统各管一段，数据靠人搬", "04"),
    ("核心数据", "CORE DATA", "哪些数据必须唯一，谁来负责", "08"),
    ("业务链路", "BUSINESS CHAIN", "数据怎么在链路上流动", "12"),
    ("未来规划", "ROADMAP", "从梳理到智能体，分三步走", "15"),
]
y0 = 1.98
for i, (name, en, desc, pg) in enumerate(items):
    y = y0 + i * 1.06
    for k in range(3):
        rect(s, 1.0, y + 0.04 + k * 0.06, 0.34, 0.15, fill=None, line=WHITE, lw=1.0,
             shape=MSO_SHAPE.DIAMOND)
    txt(s, 1.58, y, 3.4, 0.36, name, 18, WHITE, True, spacing=1.0)
    txt(s, 6.55, y + 0.02, 2.6, 0.2, en, 7.2, RGBColor(0x8F, 0xA9, 0xD6), True, spc=160)
    txt(s, 6.55, y + 0.26, 4.6, 0.24, desc, 8.8, RGBColor(0xC9, 0xD3, 0xE4))
    txt(s, 11.75, y + 0.04, 0.7, 0.3, pg, 11, RGBColor(0x8F, 0xA9, 0xD6), align=PP_ALIGN.RIGHT)
    line(s, 1.0, y + 0.86, 12.45, y + 0.86, WHITE, 0.6, alpha=14)

txt(s, 1.0, 6.55, 8.0, 0.24, "链宇技术  ·  2026 内部讨论稿", 8, RGBColor(0x7E, 0x92, 0xB8), spc=80)

# ================================================================== 03 section 01
section("01", "系统现状", "四套系统各管一段，先看清哪里接不上。", 3)

# ================================================================== 04 四套系统
s = prs.slides.add_slide(BLANK)
chrome(s, "四套系统，各管一段", 4, "功能都在，只是各自为政：同一件事，四个系统各记一遍")
sys_cards = [
    ("CRM", "客户系统", BLUE, ["客户档案、商机推进", "合同签订、收款里程碑"], "合同、收款计划",
     "合同与项目只能用合同号文本关联"),
    ("PMT", "项目系统", NAVY, ["立项、WBS、预算", "派工、工时、结算"], "项目、任务、工时、结算单",
     "工时只到项目不到任务；结算与财务脱钩"),
    ("HR", "人力资源", RGBColor(0x5B, 0x84, 0xD2), ["组织岗位、员工技能", "工作日历、成本单价"], "员工档案、调薪、日历",
     "员工与项目成员两套 ID；单价无生效期"),
    ("FIN", "财务系统", RGBColor(0x0E, 0x4B, 0xA8), ["开票、回款、应收", "成本归集、科目期间"], "发票、回款单、凭证",
     "结算—开票—回款靠 Excel 勾稽"),
]
cw4 = (CW - 3 * 0.16) / 4
for i, (code, name, col, scope, docs, gap) in enumerate(sys_cards):
    x = M + i * (cw4 + 0.16)
    rect(s, x, 1.5, cw4, 4.28, fill=WHITE, line=BORDER, lw=0.8, radius=0.04)
    rect(s, x, 1.5, cw4, 0.62, fill=col, radius=0.05)
    txt(s, x + 0.22, 1.6, 0.8, 0.22, code, 7.5, WHITE, True, spc=80)
    txt(s, x + 0.22, 1.82, cw4 - 0.4, 0.24, name, 10.5, WHITE, True, spacing=1.0)
    txt(s, x + 0.22, 2.28, cw4 - 0.4, 0.2, "管什么", 7, MUTED, spc=80)
    for j, it in enumerate(scope):
        txt(s, x + 0.22, 2.5 + j * 0.3, cw4 - 0.42, 0.26, "· " + it, 8.2, GRAY, spacing=1.1)
    txt(s, x + 0.22, 3.2, cw4 - 0.4, 0.2, "主要单据", 7, MUTED, spc=80)
    txt(s, x + 0.22, 3.42, cw4 - 0.42, 0.5, docs, 8.2, NAVY, spacing=1.3)
    line(s, x + 0.22, 3.98, x + cw4 - 0.22, 3.98, HAIR, 0.6)
    txt(s, x + 0.22, 4.08, cw4 - 0.4, 0.2, "现状缺口", 7, RED, True, spc=80)
    txt(s, x + 0.22, 4.3, cw4 - 0.42, 0.9, gap, 8, RED, spacing=1.4)
txt(s, M, 6.05, CW, 0.3, "四套系统都很好用，但它们之间没有一条共同的主键——所以每跨一次系统，就要人工对一次。",
    9.2, NAVY, True)

# ================================================================== 05 现状代价
s = prs.slides.add_slide(BLANK)
chrome(s, "数据本来就在，只是每次都要重新找一遍", 5, "站在用数据的人这边看：不是谁做得不好，是数据还没有一条统一的线")
pains = [
    ("每月汇报", "开四个系统、导四份表，同一个项目在四个文件里各有一个版本。",
     "希望：一次取数，按项目自动汇总，口径不用再问人。"),
    ("每次对账", "结算、开票、回款三张表人工勾稽，差异只能逐条回查。",
     "希望：三张单子互相引用，差异自动定位到单号。"),
    ("换人接手", "口径靠人记：算不算外包、含不含税，换个人就换个数。",
     "希望：口径写在系统里，谁算都是同一个结果。"),
    ("新人上手", "四套系统四套字段名，没人带就只能试错。",
     "希望：一套业务语言，字段名对着业务动作走。"),
]
cw_ = (CW - 0.24) / 2
for i, (t, now, hope) in enumerate(pains):
    col, row = i % 2, i // 2
    x = M + col * (cw_ + 0.24)
    y = 1.55 + row * 2.18
    rect(s, x, y, cw_, 1.98, fill=WHITE, line=BORDER, lw=0.8, radius=0.04)
    rect(s, x, y, 0.05, 1.98, fill=RED if i % 2 == 0 else BLUE)
    txt(s, x + 0.26, y + 0.18, 2.6, 0.26, t, 11.5, BLACK, True, spacing=1.0)
    txt(s, x + 0.26, y + 0.56, cw_ - 0.5, 0.62, now, 9, GRAY, spacing=1.5)
    line(s, x + 0.26, y + 1.2, x + cw_ - 0.28, y + 1.2, HAIR, 0.6)
    txt(s, x + 0.26, y + 1.3, cw_ - 0.5, 0.5, hope, 9, BLUE, spacing=1.45)
txt(s, M, 6.32, CW, 0.3, "这些重复动作，本质是同一个问题：同一条业务，被四套系统各记了一遍。", 9.5, NAVY, True)

# ================================================================== 06 六个断点
s = prs.slides.add_slide(BLANK)
chrome(s, "六个断点，让利润算不出来", 6, "断点不在功能，而在主键与口径——每一处都要人工补一次")
cols = [(M, 0.4, "#"), (M + 0.46, 2.2, "断点"), (M + 2.85, 3.9, "断在哪"),
        (M + 6.95, 2.25, "影响"), (M + 9.35, 2.2, "补法")]
rect(s, M, 1.5, CW, 0.42, fill=HEAD_BG, radius=0.03)
for x, w, t in cols:
    txt(s, x, 1.58, w, 0.24, t, 8.5, NAVY, True, spc=60)
bps = [
    ("01", "合同与项目脱钩", "CRM 合同与 PMT 项目靠合同号文本关联；子合同、变更无版本。", "收入有合同、成本有项目，两边对不上", "合同-项目关联表 + 唯一编码"),
    ("02", "人员两套 ID", "HR 员工与 PMT 成员各一套编号；调岗、离职后历史归属漂移。", "人工成本摊到错的人、错的项目", "员工主数据唯一，成员期间留痕"),
    ("03", "工时到不了任务", "PMT 有 WBS，HR 工时只填到项目，任务维度对不上。", "任务级成本缺失，大项目算不准", "工时明细强制 task_id"),
    ("04", "单价两套口径", "成本单价在 HR，结算单价在 PMT 与财务，各算各的。", "人工成本与结算金额长期有差异", "单价统一建模，带生效期"),
    ("05", "结算—开票—回款断链", "结算单在 PMT，发票与回款在财务，勾稽靠 Excel。", "应收余额与逾期不可信", "结算 → 发票 → 核销单向引用"),
    ("06", "主数据多源", "客户、组织、科目四套系统各存一份，编码规则不一。", "报表口径打架，谁都不敢签字", "24 项核心数据收口"),
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

# ================================================================== 07 section 02
section("02", "核心数据", "哪些数据必须唯一，谁来负责。", 7)

# ================================================================== 08 判断逻辑
s = prs.slides.add_slide(BLANK)
chrome(s, "四条同时满足，才进核心数据清单", 8, "不是所有表都值得统一；口径不清，治理就会变成全库搬家")
crit = [
    ("01", "被 2 个及以上环节引用", "不是某个模块的私有表；至少两个阶段读它、写它，才有统一的价值。"),
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
    y += 1.08
    line(s, M, y - 0.02, W - M, y - 0.02, HAIR, 0.6)
rect(s, M, 5.96, CW, 0.62, fill=NAVY, radius=0.08)
txt(s, M + 0.28, 6.10, CW - 0.5, 0.34,
    "结果：18 个模块进入清单，每个模块只有一个主系统；其余留在业务表，只做字段规范。", 10, WHITE, spacing=1.2)

# ================================================================== 09 按系统划域
s = prs.slides.add_slide(BLANK)
chrome(s, "四个系统，十八个数据模块", 9, "核心数据分布在四套系统里；每个模块只有一个主系统，跨系统靠主键关联")

cards = [
    ("HR", "人力资源", "07", RGBColor(0x5B, 0x84, 0xD2), 2.72,
     ["员工", "组织", "劳动合同", "考勤", "审批", "薪资", "招聘"], "员工号 · 组织编码", None),
    ("CRM", "客户系统", "03", BLUE, 2.42,
     ["售前商机", "客户", "合同"], "客户号 · 合同号",
     "边界：只到合同为止；合同之后由项目管理接手，CRM 不重复建项目。"),
    ("PMT", "项目管理", "04", NAVY, 2.62,
     ["项目基础信息", "项目计划", "执行状态", "工时"], "项目号 · 任务号",
     "边界：到工时与结算申请为止；开票、回款、成本在财务。"),
]
x = M
for code, name, cnt, col, w_, mods, key, note in cards:
    rect(s, x, 1.48, w_, 4.85, fill=WHITE, line=BORDER, lw=0.8, radius=0.04)
    rect(s, x, 1.48, w_, 0.66, fill=col, radius=0.05)
    txt(s, x + 0.2, 1.58, 1.0, 0.2, code, 7.2, WHITE, True, spc=100)
    txt(s, x + 0.2, 1.78, w_ - 0.9, 0.26, name, 10.5, WHITE, True, spacing=1.0)
    txt(s, x + w_ - 0.62, 1.68, 0.42, 0.3, cnt, 14, WHITE, True, align=PP_ALIGN.RIGHT)
    txt(s, x + w_ - 0.62, 1.98, 0.42, 0.18, "模块", 6.2, WHITE, align=PP_ALIGN.RIGHT)
    step = min(0.64, 3.2 / len(mods))
    for j, m in enumerate(mods):
        yy = 2.34 + j * step
        rect(s, x + 0.2, yy + 0.09, 0.07, 0.07, fill=BLUE)
        txt(s, x + 0.36, yy, w_ - 0.5, 0.26, m, 9.2, GRAY, spacing=1.0)
    if note:
        txt(s, x + 0.2, 4.62, w_ - 0.38, 0.7, note, 7.4, MUTED, spacing=1.4)
    line(s, x + 0.2, 5.78, x + w_ - 0.2, 5.78, HAIR, 0.6)
    txt(s, x + 0.2, 5.9, w_ - 0.36, 0.3, "关键主键：" + key, 7.4, NAVY, spacing=1.2)
    x += w_ + 0.18

# 财务
fx, fw = x, 3.33
rect(s, fx, 1.48, fw, 4.85, fill=WHITE, line=BORDER, lw=0.8, radius=0.04)
rect(s, fx, 1.48, fw, 0.66, fill=RGBColor(0x0E, 0x4B, 0xA8), radius=0.05)
txt(s, fx + 0.2, 1.58, 1.0, 0.2, "FIN", 7.2, WHITE, True, spc=100)
txt(s, fx + 0.2, 1.78, fw - 0.9, 0.26, "财务系统", 10.5, WHITE, True, spacing=1.0)
txt(s, fx + fw - 0.62, 1.68, 0.42, 0.3, "04", 14, WHITE, True, align=PP_ALIGN.RIGHT)
txt(s, fx + fw - 0.62, 1.98, 0.42, 0.18, "模块", 6.2, WHITE, align=PP_ALIGN.RIGHT)

txt(s, fx + 0.2, 2.32, 1.2, 0.22, "预算", 9.2, BLACK, True, spacing=1.0)
txt(s, fx + fw - 1.0, 2.34, 0.8, 0.18, "6 类", 6.8, MUTED, align=PP_ALIGN.RIGHT)
budgets = ["合同预算", "收入预算", "税费预算", "回款预算", "利润预算", "现金流预算"]
bw_ = (fw - 0.4 - 0.06) / 2
for k, b in enumerate(budgets):
    bx = fx + 0.2 + (k % 2) * (bw_ + 0.06)
    by = 2.58 + (k // 2) * 0.3
    rect(s, bx, by, bw_, 0.25, fill=PANEL, radius=0.08)
    txt(s, bx, by + 0.055, bw_, 0.16, b, 7.2, NAVY, align=PP_ALIGN.CENTER, spacing=1.0)

for j, m in enumerate(["现金流收支", "成本科目", "税费"]):
    yy = 3.62 + j * 0.46
    rect(s, fx + 0.2, yy + 0.09, 0.07, 0.07, fill=BLUE)
    txt(s, fx + 0.36, yy, fw - 0.5, 0.26, m, 9.2, GRAY, spacing=1.0)
line(s, fx + 0.2, 5.78, fx + fw - 0.2, 5.78, HAIR, 0.6)
txt(s, fx + 0.2, 5.9, fw - 0.36, 0.3, "关键主键：发票号 · 科目 · 期间", 7.4, NAVY, spacing=1.2)

txt(s, M, 6.48, CW, 0.24,
    "合计 18 个模块；预算按合同、收入、税费、回款、利润、现金流六类拆分，统一在财务口径下管理。",
    8.2, MUTED)

# ================================================================== 10 Owner
s = prs.slides.add_slide(BLANK)
chrome(s, "每项数据只有一个 Owner", 10, "部门负责“产生与维护”，系统负责“唯一与留痕”，管理层负责“口径审批”")
cols = [(M, 0.45, "#"), (M + 0.5, 1.55, "部门"), (M + 2.2, 4.0, "负责的数据"),
        (M + 6.35, 2.75, "录入时点"), (M + 9.25, 2.3, "唯一性要求")]
rect(s, M, 1.5, CW, 0.44, fill=HEAD_BG, radius=0.03)
for x, w, t in cols:
    txt(s, x, 1.59, w, 0.26, t, 8.2, NAVY, True, spc=60)
dept = [
    ("01", "销售", "客户、联系人、商机、合同、收款里程碑", "签约前 / 合同变更时", "客户号、合同号对外唯一"),
    ("02", "交付（PMO）", "项目、阶段、任务、交付里程碑、项目预算", "立项、计划变更、验收", "项目号贯穿全链，不回填"),
    ("03", "HR", "组织、岗位、员工、技能、日历、成本单价", "入离职、调岗、年度调价", "员工号唯一，单价带生效期"),
    ("04", "财务", "开票信息、发票、回款、应收、科目、期间", "开票、收款、月结", "发票号唯一，期间不可跨"),
    ("05", "管理层", "指标口径、审批规则、权限矩阵", "季度评审 / 口径变更", "口径变更留版本与审批"),
]
y = 1.94
for i, row in enumerate(dept):
    if i % 2 == 0:
        rect(s, M, y, CW, 0.82, fill=RGBColor(0xFB, 0xFC, 0xFE))
    txt(s, M, y + 0.3, 0.4, 0.24, row[0], 8.2, BLUE, True)
    txt(s, M + 0.5, y + 0.26, 1.6, 0.3, row[1], 9.8, BLACK, True, spacing=1.0)
    txt(s, M + 2.2, y + 0.26, 4.0, 0.5, row[2], 8.5, GRAY, spacing=1.3)
    txt(s, M + 6.35, y + 0.26, 2.7, 0.5, row[3], 8.3, GRAY, spacing=1.3)
    txt(s, M + 9.25, y + 0.26, 2.35, 0.5, row[4], 8.3, NAVY, spacing=1.3)
    line(s, M, y + 0.84, W - M, y + 0.84, HAIR, 0.6)
    y += 0.82
txt(s, M, 6.3, CW, 0.24, "跨部门争议只有一种解法：回到“谁产生、谁维护、谁审批”，而不是谁的系统里能改。", 8.5, MUTED)

# ================================================================== 11 section 03
section("03", "业务链路", "把四套系统的信息连成一条线，先看清，再优化。", 11)

# ================================================================== 12 信息链路
s = prs.slides.add_slide(BLANK)
chrome(s, "信息链路：按系统分区，从客户走到利润", 12,
       "只画信息与主数据，不画成本公式；带红点的节点需与各位老师确认实施方式")

def band(y, h, code, name, cnt, color):
    rect(s, M, y, CW, h, fill=RGBColor(0xF3, 0xF7, 0xFD), line=RGBColor(0xE1, 0xE9, 0xF6), lw=0.7, radius=0.03)
    rect(s, M, y, 0.05, h, fill=color)
    rect(s, M + 0.18, y + 0.14, 0.5, 0.22, fill=color, radius=0.3)
    txt(s, M + 0.18, y + 0.17, 0.5, 0.16, code, 6.3, WHITE, True, align=PP_ALIGN.CENTER, spc=20)
    txt(s, M + 0.78, y + 0.1, 1.6, 0.28, name, 9.8, BLACK, True, spacing=1.0)
    txt(s, M + 0.78, y + 0.42, 1.6, 0.2, cnt, 7, MUTED)

band(1.45, 0.92, "CRM", "客户系统", "2 节点", BLUE)
node(s, 2.78, 1.56, 2.0, 0.7, "N1", "客户 / 商机", "客户 · 客户联系人")
node(s, 5.06, 1.56, 2.0, 0.7, "N2", "合同签订", "合同 · 收款里程碑")
arrow(s, 4.78, 1.91, 5.04, 1.91)
txt(s, 7.45, 1.66, 4.5, 0.44, "客户与合同在这里建档；合同号对外唯一，是整条链路的起点。", 8.2, MUTED, spacing=1.4)

band(2.45, 2.0, "PMT", "项目系统", "6 节点", NAVY)
node(s, 5.06, 2.56, 2.0, 0.78, "N3", "立项 / 项目", "项目 · 项目类型")
node(s, 7.34, 2.56, 2.0, 0.78, "N4", "阶段 / 任务 / 里程碑", "阶段 · WBS · 交付里程碑")
node(s, 9.62, 2.56, 2.0, 0.78, "N5", "项目预算", "预算 · 预算科目")
node(s, 9.62, 3.56, 2.0, 0.78, "N6", "人员配置", "员工 · 技能 · 成员期间")
node(s, 7.34, 3.56, 2.0, 0.78, "N7", "工时填报 / 审批 / 锁定", "工时明细 · 工作日历", discuss=True)
node(s, 5.06, 3.56, 2.0, 0.78, "N8", "结算", "结算单 · 结算单价")
arrow(s, 6.06, 2.26, 6.06, 2.54)
arrow(s, 7.06, 2.95, 7.32, 2.95)
arrow(s, 9.34, 2.95, 9.60, 2.95)
arrow(s, 10.62, 3.34, 10.62, 3.54)
arrow(s, 9.62, 3.95, 9.36, 3.95)
arrow(s, 7.34, 3.95, 7.08, 3.95)
txt(s, 2.72, 3.16, 2.1, 0.9, "项目执行的主战场：\n立项、计划、预算、\n派工、工时、结算", 8.2, MUTED, spacing=1.5)

band(4.55, 1.62, "FIN", "财务系统", "4 节点", RGBColor(0x0E, 0x4B, 0xA8))
node(s, 5.06, 4.68, 2.0, 0.62, "N9", "开票", "发票 · 开票信息")
node(s, 7.34, 4.68, 2.0, 0.62, "N10", "回款 / 应收", "回款单 · 应收余额")
node(s, 5.06, 5.44, 2.0, 0.62, "N11", "成本归集", "成本单价 · 科目 · 期间", discuss=True)
node(s, 9.62, 4.68, 2.0, 1.38, "N12", "利润 / 经营分析", "派生：项目利润视图\n收入线 × 成本线 在此汇合")
arrow(s, 6.06, 4.34, 6.06, 4.66)
arrow(s, 7.06, 4.99, 7.32, 4.99)
arrow(s, 9.34, 4.99, 9.60, 4.99)
arrow(s, 7.06, 5.75, 9.60, 5.75)
txt(s, 2.72, 4.76, 2.15, 0.55, "开票触发：合同里程碑\n或结算单", 7.6, MUTED, spacing=1.4)
txt(s, 2.72, 5.46, 2.15, 0.55, "成本归集：取工时与\n结算数据", 7.6, MUTED, spacing=1.4)

band(6.25, 0.55, "HR", "数据底座", "支撑 N6 · N7 · N11", RGBColor(0x5B, 0x84, 0xD2))
txt(s, 2.72, 6.36, 9.6, 0.22, "组织与岗位    ·    员工与技能    ·    工作日历    ·    成本单价    ·    工时规则",
    8.2, NAVY, spacing=1.0)
arrow(s, 6.06, 6.23, 6.06, 6.08, color=RGBColor(0x5B, 0x84, 0xD2), lw=0.9, dash=MSO_LINE.DASH)
txt(s, 0.85, 6.85, 5.2, 0.16, "实线：信息流转    虚线：底座供给", 7.2, MUTED)
txt(s, 5.6, 6.85, 6.9, 0.16,
    "● 红点：待与各位老师讨论的节点（N7、N11）    节点编号沿用链路 1", 7.2, MUTED)

# ================================================================== 13 数据链路
s = prs.slides.add_slide(BLANK)
chrome(s, "数据链路：动作产生单据，单据引用主数据", 13, "与信息链路一一对应：五个业务对象，四层数据")
cols = [("业务动作", "谁在系统里做什么", 2.95), ("数据对象", "留下哪张单 / 哪条记录", 3.15),
        ("引用主数据", "统一到哪个编码", 3.0), ("形成指标", "最后能回答什么", 2.23)]
xs = []
for i, (t, d, w_) in enumerate(cols):
    x = M if i == 0 else xs[-1] + cols[i - 1][2] + 0.1
    xs.append(x)
    rect(s, x, 1.45, w_, 0.62, fill=HEAD_BG if i < 2 else PANEL, radius=0.03)
    txt(s, x + 0.14, 1.53, w_ - 0.2, 0.24, t, 9.2, NAVY, True, spacing=1.0)
    txt(s, x + 0.14, 1.78, w_ - 0.2, 0.2, d, 6.8, MUTED)
    if i < 3:
        txt(s, x + w_ + 0.005, 1.63, 0.09, 0.2, "›", 10, BLUE, True, align=PP_ALIGN.CENTER)
rows = [
    ("客户与合同", "建档、推商机、签合同", "合同、收款里程碑", "客户、合同", "合同额、回款率"),
    ("项目与计划", "立项、拆任务、编预算", "项目、任务、预算", "项目、阶段、WBS", "预算执行率"),
    ("人员与工时", "配人、填报、审批锁定", "成员、工时明细", "员工、技能、日历", "人均产值、投入率"),
    ("结算与收款", "结算、开票、收款核销", "结算单、发票、回款单", "结算单价、开票信息", "应收、逾期"),
    ("成本与利润", "归集成本、复盘利润", "成本归集单", "成本单价、科目、期间", "项目毛利、EAC"),
]
y = 2.18
for i, row in enumerate(rows):
    if i % 2 == 0:
        rect(s, M, y - 0.02, CW, 0.78, fill=RGBColor(0xFB, 0xFC, 0xFE))
    obj, act, doc, md, kpi = row
    txt(s, xs[0] + 0.14, y + 0.04, cols[0][2] - 0.24, 0.24, obj, 9.2, BLACK, True, spacing=1.0)
    txt(s, xs[0] + 0.14, y + 0.3, cols[0][2] - 0.24, 0.38, act, 7.6, GRAY, spacing=1.25)
    for j, val in ((1, doc), (2, md), (3, kpi)):
        txt(s, xs[j] + 0.14, y + 0.08, cols[j][2] - 0.24, 0.55, val, 8.6,
            NAVY if j == 3 else GRAY, spacing=1.35)
    line(s, M, y + 0.76, W - M, y + 0.76, HAIR, 0.6)
    y += 0.78
rect(s, M, 6.18, CW, 0.62, fill=PANEL, radius=0.04)
txt(s, M + 0.24, 6.32, CW - 0.5, 0.3,
    "口径：一行一条线——动作产生单据，单据必须引用主数据，主数据汇总成指标；任何一层断掉，指标就不可信。",
    8.8, NAVY, spacing=1.2)

# ================================================================== 14 section 04
section("04", "未来规划", "从梳理到智能体，分三步走。", 14)

# ================================================================== 15 未来规划（时间轴）
s = prs.slides.add_slide(BLANK)
chrome(s, "未来规划", 15, "短期打底，中期联通，长期智能：每一阶段验收通过，再进入下一阶段")

X0, X1 = M, W - M
MW = (X1 - X0) / 12
AX = 4.38

for i in range(13):
    xx = X0 + i * MW
    line(s, xx, 1.9, xx, 6.25, RGBColor(0xDF, 0xE7, 0xF3), 0.5, dash=MSO_LINE.DASH)

line(s, X0, AX, X1 - 0.18, AX, RGBColor(0x8A, 0x93, 0xA3), 1.0)
arrow(s, X1 - 0.3, AX, X1, AX, color=RGBColor(0x8A, 0x93, 0xA3), lw=1.0)

for i in range(12):
    cx = X0 + (i + 0.5) * MW
    bx = X0 + i * MW
    line(s, bx, AX - 0.04, bx, AX + 0.04, RGBColor(0x8A, 0x93, 0xA3), 0.6)
    if (i + 1) % 2 == 1:
        txt(s, cx - 0.25, AX - 0.24, 0.5, 0.16, f"{i+1}月", 6.8, MUTED, align=PP_ALIGN.CENTER)
    else:
        txt(s, cx - 0.25, AX + 0.08, 0.5, 0.16, f"{i+1}月", 6.8, MUTED, align=PP_ALIGN.CENTER)

groups = [
    ("短期", 0, 3, "第 1–3 月", NAVY),
    ("中期", 3, 6, "第 4–6 月", BLUE),
    ("长期", 6, 12, "第 7–12 月", RGBColor(0x5B, 0x84, 0xD2)),
]
for name, a, b, span_txt, col in groups:
    xa, xb = X0 + a * MW, X0 + b * MW
    line(s, xa, 1.72, xb - 0.04, 1.72, col, 1.0)
    line(s, xa, 1.67, xa, 1.77, col, 1.0)
    line(s, xb - 0.04, 1.67, xb - 0.04, 1.77, col, 1.0)
    txt(s, xa + 0.04, 1.47, 3.0, 0.2, f"{name}  ·  {span_txt}", 7.4, col, True, spc=40)

phases = [
    ("01", "梳理数据与 Owner", 0, 2, 2.30, NAVY,
     "定 18 个模块的核心数据、责任人与编码规则。", "验收：清单签字，口径唯一"),
    ("02", "落到系统，各自跑顺", 1, 3, 3.40, NAVY,
     "四套系统补齐字段与校验，先做到单系统闭环。", "验收：单月结账不靠手工补"),
    ("03", "数据联通", 3, 6, 5.06, BLUE,
     "统一主键与映射表，打通合同到回款。", "验收：一条链路可追溯"),
    ("04", "CEO 智能体", 6, 12, 6.06, RGBColor(0x5B, 0x84, 0xD2),
     "在联通数据上做问答、预警与预测。", "验收：经营问题当天有答案"),
]
for num, name, a, b, by, col, desc, acc in phases:
    xb = X0 + a * MW
    xe = X0 + b * MW
    rect(s, xb, by, xe - xb, 0.06, fill=col)
    rect(s, xb - 0.055, by - 0.025, 0.11, 0.11, fill=col, shape=MSO_SHAPE.OVAL)
    txt(s, xb, by - 0.31, 0.34, 0.2, num, 7.4, col, True)
    txt(s, xb + 0.32, by - 0.35, 3.6, 0.26, name, 10.5, BLACK, True, spacing=1.0)
    w_ = min(max(xe - xb + 1.2, 2.6), X1 - xb - 0.05)
    txt(s, xb, by + 0.14, w_, 0.24, desc, 7.8, GRAY, spacing=1.3)
    txt(s, xb, by + 0.38, w_, 0.2, acc, 7.2, col, spacing=1.3)

txt(s, M, 6.62, CW, 0.24,
    "以 12 个月为窗口；上一阶段验收未过，不进入下一阶段。核心数据唯一率 ≥ 99.5% 才允许谈联通。",
    8, MUTED)

# ================================================================== 16 closing
s = prs.slides.add_slide(BLANK)
dark_bg(s)
logo(s, dark=True)
txt(s, 1.0, 2.5, 8.0, 0.5, "谢谢关注", 34, WHITE, True, spacing=1.0)
txt(s, 1.0, 3.22, 8.8, 0.4, "先对齐链路，再谈改造。", 18, RGBColor(0xBF, 0xCE, 0xE8), spacing=1.2)
line(s, 1.02, 3.9, 3.0, 3.9, RGBColor(0x5B, 0x84, 0xD2), 1.2)
txt(s, 1.0, 4.1, 8.4, 0.7, "12 个节点  ·  18 个数据模块  ·  四个系统\n一条链路，从签约走到项目利润。",
    10.5, SUBTXT, spacing=1.7)
txt(s, 1.0, 6.02, 10.0, 0.5, "服务热线  0755-86569152      www.iscmtech.com", 9,
    RGBColor(0xA9, 0xB9, 0xD6), spc=30)
txt(s, 1.0, 6.5, 10.0, 0.3, "链宇技术  ·  2026 内部讨论稿  ·  请勿外传", 8,
    RGBColor(0x7E, 0x92, 0xB8), spc=40)

out = "/workspace/链宇技术-业务链路与核心数据-大纲版.pptx"
prs.save(out)
print("saved", out, len(prs.slides._sldIdLst))
