# 链宇经营一体门户 · Design Contract (frozen)

## 0. 技术栈与交付
- pure-static SPA：`index.html` + `styles.css` + `js/*.js`，hash 路由，无构建、无外部 CDN（图表用自研 SVG）。
- 目录：`/workspace/lianyu-portal/`；页面模块只写 `js/page-*.js`。

## 1. 风格基调
企业级后台（business），完全复刻现有四套系统（Element Plus 2.x + 链宇蓝）。禁止：紫色渐变、玻璃拟态、超大圆角、装饰性插画、emoji。

## 2. Tokens
```
--ly-primary:#1d4ed8  --ly-primary-dark:#1e3a8a  --ly-primary-light:#3b82f6
--ly-sidebar:#1e3a5f  --ly-sidebar-hover:#2d4a7c
--ly-header:#fff      --ly-content:#f5f7fa      --ly-border:#dcdfe6  --ly-border-light:#ebeef5
--ly-text:#303133     --ly-text-regular:#606266 --ly-text-secondary:#909399
--ly-success:#67c23a  --ly-warning:#e6a23c      --ly-danger:#f56c6c
--ly-radius:4px       --ly-radius-lg:8px
```
字体：`'Helvetica Neue',Helvetica,'PingFang SC','Hiragino Sans GB','Microsoft YaHei',Arial,sans-serif`；正文 14px，辅助 13/12px，页面标题 20px，卡片标题 16px。
侧边栏 220px（收起 64px），logo 区 52px，顶栏 52px，内容区 padding 14px，菜单项 48px（子项 44px，圆角 6px，margin 2px 8px），选中态 `linear-gradient(90deg,#3b82f6,#1d4ed8)`。
表格行高 48px，表头 48px，表头底色 #fafafa；按钮高 32px，输入框 32px。

## 3. 布局骨架（已由 shell 渲染，页面不得重写）
`#app > .ly-layout > .ly-sidebar + .ly-main > .ly-header + .ly-tabs + .ly-content > #page`
页面只输出 `.ly-page` 内部内容。

## 4. 页面标准结构
```html
<div class="page-head">
  <div><div class="page-title">标题</div><div class="page-sub">副标题</div></div>
  <div class="page-actions"><button class="btn">…</button></div>
</div>
<div class="filter-bar">…</div>
<div class="panel"><div class="panel-head"><h3>…</h3><div>…</div></div><div class="panel-body">…</div></div>
```
列表页 = 页头 + 筛选条 + 表格面板 + 分页；详情页 = 页头 + 概览条 + 标签页 + 面板组。

## 5. 组件类名（只能用这些）
- 按钮 `.btn` `.btn--primary` `.btn--success` `.btn--warning` `.btn--danger` `.btn--text` `.btn--sm` `.btn--lg`；图标按钮 `.btn-icon`
- 表单 `.field` `.field-label` `.input` `.select` `.textarea` `.checkbox` `.radio-group` `.switch` `.search-box`
- 表格 `.table-wrap > table.table`（`thead th`/`tbody td`）、行操作 `.link-btn` `.link-btn--danger`
- 标签 `.tag` `.tag--primary/success/warning/danger/info`；状态点 `.dot`
- 卡片 `.panel` `.panel-head` `.panel-body` `.panel--flat`；KPI `.kpi-grid` `.kpi` `.kpi-label` `.kpi-value` `.kpi-foot` `.kpi-trend.up/.down`
- 标签页 `.tabs` `.tabs__item.is-active` `.tab-panel`
- 弹窗 `.modal-mask/.modal` `.drawer-mask/.drawer`（由 LY API 生成，勿手写）
- 进度 `.progress` `.progress__bar`；步骤 `.steps` `.steps__item`；时间线 `.timeline`
- 描述列表 `.desc-grid` `.desc-item` `.desc-label` `.desc-value`
- 图表 `.chart` `.chart-legend` `.legend-dot`
- 提示 `.alert` `.alert--warning/.info/.danger`；空态 `.empty`
- 分页 `.pager`；工具条 `.toolbar`；分割 `.divider`；数字 `.num` `.money` `.text-muted`

## 6. 路由与页面清单（20）
| route | 页面 | 主责节点 |
|---|---|---|
| /home | 经营工作台 | N1–N12 总览 |
| /customer | 客户主数据（含合并弹窗、详情抽屉） | N1 |
| /opportunity | 商机管理（看板+列表） | N1 |
| /contract | 合同台账 | N2 |
| /contract/detail | 合同详情（行/里程碑/付款条件/变更版本） | N2 |
| /project | 项目列表 | N3 |
| /project/detail | 项目驾驶舱（9 个标签页） | N3–N12 |
| /wbs | 阶段与 WBS / 交付里程碑 | N4 |
| /budget | 项目预算与审批 | N5 |
| /resource | 资源池（技能/可用工时/匹配/人员配置） | N6 |
| /timesheet | 工时填报与审批 | N7 |
| /settlement | 结算管理 | N8 |
| /invoice | 开票管理 | N9 |
| /receivable | 回款与应收 | N10 |
| /cost | 成本归集 | N11 |
| /profit | 项目利润 | N12 |
| /analysis | 经营分析 | N12 |
| /approval | 审批中心 | B-07 |
| /integration | 主数据融合 | B-01…B-15 |
| /login | 登录（standalone） | — |

## 7. API（LY 命名空间，全部已实现）
`LY.register(route,{title,crumb,render,standalone})`、`LY.go(route)`、`LY.icon(name,size)`、`LY.tpl(str)`(无)、
`LY.money(n)`(千分位2位)、`LY.wan(n)`(“860.0 万”)、`LY.num(n)`、`LY.pct(n)`、`LY.esc(s)`、
`LY.tag(text,type)`、`LY.statusTag(enum)`、`LY.toast(msg,type)`、`LY.openDrawer({title,width,body,footer,onMount})`、`LY.closeDrawer()`、
`LY.openModal({title,width,body,footer,onMount})`、`LY.closeModal()`、`LY.confirm({title,content,okText,onOk})`、
`LY.chart.bar(el,{categories,series,stacked,horizontal,height})`、`LY.chart.line(el,{categories,series,height,area})`、
`LY.chart.donut(el,{data,centerLabel,centerValue,height})`、`LY.chart.progressRing(el,{value,label})`、
`LY.state`（可变状态：timesheets/approvals/settlements/invoices…）、`LY.MOCK`。
图表 series: `{name,data,color}`；颜色顺序 `#1d4ed8 #3b82f6 #67c23a #e6a23c #f56c6c #909399`。

## 8. Mock 主数据（唯一事实源，字段名不得改）
- 当前用户：陈立（PM，工号 LY20180312，角色 项目经理）
- 主客户 CUS-0001 华润数科集团；主合同 CT-2026-0087（含税 8,600,000，税率 6%）；主项目 PJ-2026-0021（华润数科数字化中台建设，PM 陈立，进度 62%）
- 其余客户 CUS-0002 中海物业、CUS-0003 国网信通、CUS-0004 招商蛇口、CUS-0005 京东方、CUS-0006 中国邮政
- 项目编码 PJ-2026-00xx；任务编码 T-03xx；结算单 SO-202610-xx；发票 INV-2026-0xxx；收款 RCP-2026-0xxx
- 枚举中文：合同 DRAFT 草稿/UNSIGNED 待签约/SIGNED 已签约/IN_PROGRESS 执行中/COMPLETED 已完成/TERMINATED 已终止；项目 PREPARING 准备中/IN_PROGRESS 进行中/PAUSED 暂停/COMPLETED 已完成/CANCELLED 已取消；任务 NOT_STARTED 未开始/IN_PROGRESS 进行中/COMPLETED 已完成/BLOCKED 阻塞/CANCELLED 已取消；工时 DRAFT 草稿/PENDING 待审批/APPROVED 已通过/REJECTED 已驳回/LOCKED 已锁定；结算 DRAFT 草稿/PENDING 待确认/CONFIRMED 已确认/SETTLED 已结算/CANCELLED 已取消；发票 DRAFT 草稿/ISSUED 已开具/VOID 已作废/RED_FLUSH 已红冲；回款 UNPAID 未回款/PARTIAL 部分回款/PAID 已回款/OVERDUE 已逾期；工时类型 CUSTOMER_PROJECT 客户项目/INTERNAL_RND 内部研发/INTERNAL_ADMIN 内部管理/TRAINING 培训/LEAVE 请假/IDLE 闲置/OTHER 其他。

## 9. 交互约定
- 所有按钮必须有反馈：`LY.toast` 或打开弹窗；不得出现死链接。
- 行点击进入详情用 `LY.go()`；操作列使用 `link-btn`。
- 筛选为前端过滤 mock 数组，输入即筛（或点查询）；分页前端切片。
- 项目详情子标签通过 `LY.go('/project/detail?id=…&tab=budget')` 切换。
- 数字右对齐、金额两位小数；空值显示 `-`。
