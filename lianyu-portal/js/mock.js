/* ================= 链宇经营一体门户 · Mock 数据（唯一事实源） ================= */
window.LY = window.LY || {};

LY.MOCK = (function () {
  const user = { id: 'E1001', name: '陈立', initial: '陈', no: 'LY20180312', role: '项目经理', dept: '项目管理部 / 交付中心', org: '交付中心' };

  const orgs = [
    { id: 'O01', name: '链宇数字科技', parent: null, type: '法人', manager: '赵总', headcount: 268 },
    { id: 'O02', name: '交付中心', parent: 'O01', type: '成本中心', manager: '王海', headcount: 96 },
    { id: 'O03', name: '技术中心', parent: 'O01', type: '成本中心', manager: '张伟', headcount: 84 },
    { id: 'O04', name: '产品与设计中心', parent: 'O01', type: '成本中心', manager: '孙悦', headcount: 32 },
    { id: 'O05', name: '质量中心', parent: 'O01', type: '成本中心', manager: '赵敏', headcount: 28 },
    { id: 'O06', name: '职能中心', parent: 'O01', type: '管理部门', manager: '刘芳', headcount: 28 }
  ];

  const customers = [
    { id: 'CUS-0001', name: '华润数科集团', short: '华润数科', taxNo: '91440300MA5F8K2X1B', industry: '科技/数字化', region: '深圳', owner: '陈立', ownerId: 'E1001', level: 'A', partyType: ['客户', '付款单位'], status: '合作中', org: '交付中心', parent: null, contractAmount: 8600000, receivable: 1200000, overdue: 0, margin: 0.238, projects: 2, source: 'CRM', legacy: 'CRM_C_100238', createDate: '2023-06-12', creditLimit: 12000000, creditUsed: 5668900 },
    { id: 'CUS-0002', name: '中海物业管理有限公司', short: '中海物业', taxNo: '91440300192451376T', industry: '物业服务', region: '深圳', owner: '周涛', ownerId: 'E1006', level: 'A', partyType: ['客户'], status: '合作中', org: '交付中心', parent: null, contractAmount: 3200000, receivable: 218000, overdue: 218000, margin: 0.165, projects: 2, source: 'PMT', legacy: 'PMT_CUS_0086', createDate: '2024-03-08', creditLimit: 4000000, creditUsed: 2860000 },
    { id: 'CUS-0003', name: '国网信通产业集团', short: '国网信通', taxNo: '91110108710926463M', industry: '能源信息化', region: '北京', owner: '王强', ownerId: 'E1004', level: 'A', partyType: ['客户'], status: '合作中', org: '技术中心', parent: null, contractAmount: 5400000, receivable: 96000, overdue: 96000, margin: 0.214, projects: 1, source: 'FS', legacy: 'FS_AR_20118', createDate: '2024-11-20', creditLimit: 6000000, creditUsed: 4820000 },
    { id: 'CUS-0004', name: '招商蛇口数字城市科技有限公司', short: '招商蛇口', taxNo: '91440300MA5D8T7L2C', industry: '地产科技', region: '深圳', owner: '李娜', ownerId: 'E1003', level: 'B', partyType: ['客户'], status: '合作中', org: '交付中心', parent: null, contractAmount: 2800000, receivable: 0, overdue: 0, margin: 0.261, projects: 1, source: 'CRM', legacy: 'CRM_C_100415', createDate: '2025-02-14', creditLimit: 3000000, creditUsed: 0 },
    { id: 'CUS-0005', name: '京东方科技集团股份有限公司', short: '京东方', taxNo: '91110000600016633F', industry: '智能制造', region: '北京', owner: '陈立', ownerId: 'E1001', level: 'B', partyType: ['客户', '供应商'], status: '合作中', org: '交付中心', parent: null, contractAmount: 4600000, receivable: 0, overdue: 0, margin: 0.259, projects: 1, source: 'PMT', legacy: 'PMT_CUS_0031', createDate: '2024-07-02', creditLimit: 5000000, creditUsed: 0 },
    { id: 'CUS-0006', name: '中国邮政集团有限公司', short: '中国邮政', taxNo: '91110000100014793D', industry: '物流邮政', region: '北京', owner: '张伟', ownerId: 'E1002', level: 'B', partyType: ['客户'], status: '已签约待启动', org: '技术中心', parent: null, contractAmount: 6200000, receivable: 0, overdue: 0, margin: null, projects: 1, source: 'CRM', legacy: 'CRM_C_100502', createDate: '2026-08-18', creditLimit: 8000000, creditUsed: 0 },
    { id: 'CUS-0007', name: '华润数科（深圳）信息技术有限公司', short: '华润数科深圳', taxNo: '91440300MA5F8K2X1B', industry: '科技/数字化', region: '深圳', owner: '陈立', ownerId: 'E1001', level: 'C', partyType: ['客户'], status: '待合并', org: '交付中心', parent: null, contractAmount: 0, receivable: 0, overdue: 0, margin: null, projects: 0, source: 'CRM', legacy: 'CRM_C_100731', createDate: '2026-09-27', creditLimit: 0, creditUsed: 0, duplicateOf: 'CUS-0001', duplicateRate: 0.92 }
  ];

  const contacts = [
    { id: 'CT01', customerId: 'CUS-0001', name: '李建华', title: '数字化中心总经理', mobile: '138****6721', email: 'lijh@crland-dt.com', primary: true, decision: true },
    { id: 'CT02', customerId: 'CUS-0001', name: '王思远', title: '项目经理', mobile: '139****2088', email: 'wangsy@crland-dt.com', primary: false, decision: false },
    { id: 'CT03', customerId: 'CUS-0001', name: '刘倩', title: '采购经理', mobile: '135****9012', email: 'liuq@crland-dt.com', primary: false, decision: false }
  ];

  const opportunities = [
    { id: 'OPP-2026-018', name: '华润数科数字化中台二期', customerId: 'CUS-0001', customer: '华润数科', amount: 8600000, stage: '商务谈判', probability: 70, expectSign: '2026-12-15', owner: '陈立', ownerId: 'E1001', source: '老客户复购', created: '2026-08-04', nextAction: '12-05 提交最终报价与技术方案', contractId: null },
    { id: 'OPP-2026-021', name: '中海物业智慧社区三期', customerId: 'CUS-0002', customer: '中海物业', amount: 3400000, stage: '方案阶段', probability: 50, expectSign: '2027-01-20', owner: '周涛', ownerId: 'E1006', source: '客户拜访', created: '2026-09-12', nextAction: '11-18 现场方案汇报', contractId: null },
    { id: 'OPP-2026-016', name: '国网信通数据资产运营平台', customerId: 'CUS-0003', customer: '国网信通', amount: 5600000, stage: '需求确认', probability: 40, expectSign: '2027-02-10', owner: '王强', ownerId: 'E1004', source: '渠道推荐', created: '2026-10-02', nextAction: '11-22 需求调研 kickoff', contractId: null },
    { id: 'OPP-2026-024', name: '招商蛇口 AI 智能客服', customerId: 'CUS-0004', customer: '招商蛇口', amount: 2200000, stage: '初步接触', probability: 20, expectSign: '2027-03-05', owner: '李娜', ownerId: 'E1003', source: '市场活动', created: '2026-10-18', nextAction: '11-25 首轮需求沟通', contractId: null },
    { id: 'OPP-2026-011', name: '京东方供应链协同二期', customerId: 'CUS-0005', customer: '京东方', amount: 4800000, stage: '商务谈判', probability: 80, expectSign: '2026-11-30', owner: '陈立', ownerId: 'E1001', source: '老客户复购', created: '2026-06-21', nextAction: '11-15 合同条款终审', contractId: null },
    { id: 'OPP-2026-009', name: '中国邮政客户数据平台', customerId: 'CUS-0006', customer: '中国邮政', amount: 6200000, stage: '已签约', probability: 100, expectSign: '2026-08-18', owner: '张伟', ownerId: 'E1002', source: '公开招标', created: '2026-03-10', nextAction: '立项审批中', contractId: 'CT-2026-0074' }
  ];

  const follows = [
    { id: 'F01', oppId: 'OPP-2026-018', time: '2026-11-06 15:20', owner: '陈立', type: '现场拜访', content: '与数字化中心李总确认二期范围：新增数据治理与 AI 指标分析，预算上限 900 万。', planStatus: '已完成' },
    { id: 'F02', oppId: 'OPP-2026-018', time: '2026-11-12 10:00', owner: '陈立', type: '方案汇报', content: '提交二期技术方案与报价，需财务同步输出付款条件建议。', planStatus: '计划中' },
    { id: 'F03', oppId: 'OPP-2026-011', time: '2026-11-04 09:40', owner: '陈立', type: '电话沟通', content: '京东方采购确认合同条款无异议，预计 11-15 完成用印。', planStatus: '已完成' }
  ];

  const contractMilestones = [
    { id: 'CM1', contractId: 'CT-2026-0087', code: 'M1', name: '预付款', type: '预付款', ratio: 0.3, amount: 2580000, planInvoice: '2026-04-10', actualInvoice: '2026-04-12', planPay: '2026-05-10', actualPay: '2026-04-28', invoiceStatus: 'ISSUED', payStatus: 'PAID' },
    { id: 'CM2', contractId: 'CT-2026-0087', code: 'M2', name: '蓝图确认款', type: '进度款', ratio: 0.2, amount: 1720000, planInvoice: '2026-06-15', actualInvoice: '2026-06-18', planPay: '2026-07-15', actualPay: '2026-07-20', invoiceStatus: 'ISSUED', payStatus: 'PAID' },
    { id: 'CM3', contractId: 'CT-2026-0087', code: 'M3', name: '上线验收款', type: '验收款', ratio: 0.4, amount: 3440000, planInvoice: '2026-11-30', actualInvoice: '2026-10-25', planPay: '2026-12-30', actualPay: null, invoiceStatus: 'PARTIAL', payStatus: 'UNPAID' },
    { id: 'CM4', contractId: 'CT-2026-0087', code: 'M4', name: '质保金', type: '质保金', ratio: 0.1, amount: 860000, planInvoice: '2027-03-31', actualInvoice: null, planPay: '2027-04-30', actualPay: null, invoiceStatus: 'NONE', payStatus: 'UNPAID' }
  ];

  const contractLines = [
    { no: 1, name: '数据中台基础平台', type: '软件', qty: 1, unit: '套', price: 3200000, amount: 3200000, settle: '按里程碑' },
    { no: 2, name: '业务中台模块（6 个）', type: '软件', qty: 6, unit: '个', price: 500000, amount: 3000000, settle: '按里程碑' },
    { no: 3, name: '数据治理与集成服务', type: '服务', qty: 1, unit: '项', price: 1600000, amount: 1600000, settle: '按人天结算' },
    { no: 4, name: '实施、培训与质保', type: '服务', qty: 1, unit: '项', price: 800000, amount: 800000, settle: '按里程碑' }
  ];

  const contractChanges = [
    { id: 'CC-01', type: '补充协议', title: '新增数据治理范围（3 个源系统）', amount: 320000, date: '2026-07-14', status: '已签署', owner: '陈立' },
    { id: 'CC-02', type: '变更申请', title: '上线日期顺延至 2027-01-15（客户机房改造）', amount: 0, date: '2026-11-05', status: '审批中', owner: '陈立' }
  ];

  const contracts = [
    { id: 'CT-2026-0087', name: '华润数科数字化中台建设服务合同', customerId: 'CUS-0001', customer: '华润数科', excl: 8113207.55, taxRate: 0.06, tax: 486792.45, incl: 8600000, signDate: '2026-03-18', start: '2026-03-25', end: '2026-12-31', status: 'IN_PROGRESS', type: '主合同', owner: '陈立', org: '交付中心', productLine: '数据中台', received: 4468900, invoiced: 5668900, projects: 1 },
    { id: 'CT-2026-0052', name: '中海物业智慧园区一期建设合同', customerId: 'CUS-0002', customer: '中海物业', excl: 3018867.92, taxRate: 0.06, tax: 181132.08, incl: 3200000, signDate: '2026-01-22', start: '2026-02-01', end: '2026-11-30', status: 'IN_PROGRESS', type: '主合同', owner: '周涛', org: '交付中心', productLine: '智慧园区', received: 2560000, invoiced: 2860000, projects: 2 },
    { id: 'CT-2026-0061', name: '国网信通数据资产平台开发合同', customerId: 'CUS-0003', customer: '国网信通', excl: 5094339.62, taxRate: 0.06, tax: 305660.38, incl: 5400000, signDate: '2026-04-09', start: '2026-04-15', end: '2027-04-15', status: 'IN_PROGRESS', type: '主合同', owner: '王强', org: '技术中心', productLine: '数据资产', received: 2700000, invoiced: 3240000, projects: 1 },
    { id: 'CT-2026-0033', name: '招商蛇口营销数字化服务合同', customerId: 'CUS-0004', customer: '招商蛇口', excl: 2641509.43, taxRate: 0.06, tax: 158490.57, incl: 2800000, signDate: '2025-12-18', start: '2026-01-05', end: '2026-08-31', status: 'COMPLETED', type: '主合同', owner: '李娜', org: '交付中心', productLine: '营销数字化', received: 2800000, invoiced: 2800000, projects: 1 },
    { id: 'CT-2025-0118', name: '京东方供应链协同平台合同', customerId: 'CUS-0005', customer: '京东方', excl: 4339622.64, taxRate: 0.06, tax: 260377.36, incl: 4600000, signDate: '2025-09-26', start: '2025-10-08', end: '2026-09-30', status: 'COMPLETED', type: '主合同', owner: '陈立', org: '交付中心', productLine: '供应链', received: 4600000, invoiced: 4600000, projects: 1 },
    { id: 'CT-2026-0074', name: '中国邮政客户数据平台建设合同', customerId: 'CUS-0006', customer: '中国邮政', excl: 5849056.60, taxRate: 0.06, tax: 350943.40, incl: 6200000, signDate: '2026-08-18', start: '2026-12-01', end: '2027-11-30', status: 'SIGNED', type: '主合同', owner: '张伟', org: '技术中心', productLine: '客户数据', received: 0, invoiced: 0, projects: 1 },
    { id: 'CT-2026-0088', name: '华润数科数字化中台二期框架协议', customerId: 'CUS-0001', customer: '华润数科', excl: 8113207.55, taxRate: 0.06, tax: 486792.45, incl: 8600000, signDate: null, start: '2027-01-01', end: '2027-12-31', status: 'UNSIGNED', type: '框架协议', owner: '陈立', org: '交付中心', productLine: '数据中台', received: 0, invoiced: 0, projects: 0 }
  ];

  const phases = [
    { id: 'PH1', code: 'P1', name: '启动与蓝图', start: '2026-03-25', end: '2026-04-30', status: 'COMPLETED', percent: 100, owner: '郑洁' },
    { id: 'PH2', code: 'P2', name: '架构与设计', start: '2026-05-01', end: '2026-06-15', status: 'COMPLETED', percent: 100, owner: '张伟' },
    { id: 'PH3', code: 'P3', name: '开发实现', start: '2026-06-01', end: '2026-09-30', status: 'IN_PROGRESS', percent: 92, owner: '王强' },
    { id: 'PH4', code: 'P4', name: '测试与上线', start: '2026-09-15', end: '2026-11-30', status: 'IN_PROGRESS', percent: 45, owner: '赵敏' },
    { id: 'PH5', code: 'P5', name: '验收与质保', start: '2026-12-01', end: '2027-03-31', status: 'NOT_STARTED', percent: 0, owner: '陈立' }
  ];

  const tasks = [
    { id: 'T-0301', phase: 'PH1', parent: null, code: '1.1', name: '项目启动会', assignee: '陈立', assigneeId: 'E1001', start: '2026-03-25', end: '2026-03-26', planned: 16, actual: 16, status: 'COMPLETED', percent: 100, milestone: 'PM1' },
    { id: 'T-0302', phase: 'PH1', parent: null, code: '1.2', name: '业务现状调研', assignee: '郑洁', assigneeId: 'E1009', start: '2026-03-27', end: '2026-04-15', planned: 240, actual: 252, status: 'COMPLETED', percent: 100, milestone: null },
    { id: 'T-0303', phase: 'PH1', parent: null, code: '1.3', name: '蓝图方案编制', assignee: '郑洁', assigneeId: 'E1009', start: '2026-04-01', end: '2026-04-25', planned: 320, actual: 336, status: 'COMPLETED', percent: 100, milestone: 'PM1' },
    { id: 'T-0304', phase: 'PH1', parent: null, code: '1.4', name: '蓝图评审与签认', assignee: '陈立', assigneeId: 'E1001', start: '2026-04-26', end: '2026-04-30', planned: 40, actual: 38, status: 'COMPLETED', percent: 100, milestone: 'PM1' },
    { id: 'T-0305', phase: 'PH2', parent: null, code: '2.1', name: '总体架构设计', assignee: '张伟', assigneeId: 'E1002', start: '2026-05-01', end: '2026-05-25', planned: 200, actual: 210, status: 'COMPLETED', percent: 100, milestone: 'PM2' },
    { id: 'T-0306', phase: 'PH2', parent: null, code: '2.2', name: '数据模型设计', assignee: '吴磊', assigneeId: 'E1008', start: '2026-05-10', end: '2026-06-05', planned: 160, actual: 168, status: 'COMPLETED', percent: 100, milestone: 'PM2' },
    { id: 'T-0307', phase: 'PH2', parent: null, code: '2.3', name: 'UI 设计规范与原型', assignee: '孙悦', assigneeId: 'E1007', start: '2026-05-05', end: '2026-06-10', planned: 180, actual: 172, status: 'COMPLETED', percent: 100, milestone: null },
    { id: 'T-0308', phase: 'PH3', parent: null, code: '3.1', name: '中台基础服务开发', assignee: '王强', assigneeId: 'E1004', start: '2026-06-01', end: '2026-08-10', planned: 1600, actual: 1690, status: 'COMPLETED', percent: 100, milestone: null },
    { id: 'T-0309', phase: 'PH3', parent: null, code: '3.2', name: '业务中台模块开发', assignee: '王强', assigneeId: 'E1004', start: '2026-06-15', end: '2026-09-30', planned: 2400, actual: 2530, status: 'IN_PROGRESS', percent: 90, milestone: 'PM3' },
    { id: 'T-0310', phase: 'PH3', parent: null, code: '3.3', name: '前端应用开发', assignee: '李娜', assigneeId: 'E1003', start: '2026-06-20', end: '2026-09-25', planned: 1500, actual: 1580, status: 'IN_PROGRESS', percent: 92, milestone: 'PM3' },
    { id: 'T-0311', phase: 'PH3', parent: null, code: '3.4', name: '数据集成与治理', assignee: '吴磊', assigneeId: 'E1008', start: '2026-07-01', end: '2026-10-20', planned: 900, actual: 940, status: 'IN_PROGRESS', percent: 88, milestone: null },
    { id: 'T-0312', phase: 'PH3', parent: null, code: '3.5', name: '第三方接口联调', assignee: '张伟', assigneeId: 'E1002', start: '2026-09-01', end: '2026-11-15', planned: 640, actual: 600, status: 'IN_PROGRESS', percent: 85, milestone: null },
    { id: 'T-0313', phase: 'PH4', parent: null, code: '4.1', name: '集成测试', assignee: '赵敏', assigneeId: 'E1005', start: '2026-09-15', end: '2026-10-31', planned: 480, actual: 260, status: 'IN_PROGRESS', percent: 55, milestone: 'PM3' },
    { id: 'T-0314', phase: 'PH4', parent: null, code: '4.2', name: 'UAT 验收测试', assignee: '周涛', assigneeId: 'E1006', start: '2026-10-15', end: '2026-11-25', planned: 360, actual: 120, status: 'IN_PROGRESS', percent: 30, milestone: 'PM3' },
    { id: 'T-0315', phase: 'PH4', parent: null, code: '4.3', name: '性能与安全测试', assignee: '张伟', assigneeId: 'E1002', start: '2026-10-20', end: '2026-11-20', planned: 240, actual: 180, status: 'IN_PROGRESS', percent: 60, milestone: null },
    { id: 'T-0316', phase: 'PH4', parent: null, code: '4.4', name: '上线部署与割接', assignee: '王强', assigneeId: 'E1004', start: '2026-11-20', end: '2026-12-10', planned: 200, actual: 60, status: 'NOT_STARTED', percent: 25, milestone: 'PM4' },
    { id: 'T-0317', phase: 'PH5', parent: null, code: '5.1', name: '验收文档与移交', assignee: '陈立', assigneeId: 'E1001', start: '2026-12-01', end: '2026-12-20', planned: 160, actual: 0, status: 'NOT_STARTED', percent: 0, milestone: 'PM4' },
    { id: 'T-0318', phase: 'PH5', parent: null, code: '5.2', name: '质保期运维支持', assignee: '周涛', assigneeId: 'E1006', start: '2026-12-21', end: '2027-03-31', planned: 320, actual: 0, status: 'NOT_STARTED', percent: 0, milestone: 'PM5' }
  ];

  const projectMilestones = [
    { id: 'PM1', code: 'D1', name: '蓝图方案签认', type: '交付验收', plan: '2026-04-28', actual: '2026-04-28', status: 'COMPLETED', contractMilestone: 'CM2', doc: '华润数科数字化中台蓝图方案V1.0.pdf', owner: '郑洁' },
    { id: 'PM2', code: 'D2', name: '技术架构方案确认', type: '交付验收', plan: '2026-06-12', actual: '2026-06-10', status: 'COMPLETED', contractMilestone: 'CM2', doc: '技术架构说明书V2.1.pdf', owner: '张伟' },
    { id: 'PM3', code: 'D3', name: '核心模块 UAT 通过', type: '交付验收', plan: '2026-11-25', actual: null, status: 'IN_PROGRESS', contractMilestone: 'CM3', doc: 'UAT测试报告（进行中）.docx', owner: '赵敏' },
    { id: 'PM4', code: 'D4', name: '系统上线验收', type: '交付验收', plan: '2026-12-10', actual: null, status: 'NOT_STARTED', contractMilestone: 'CM3', doc: null, owner: '陈立' },
    { id: 'PM5', code: 'D5', name: '质保期满确认', type: '质保', plan: '2027-03-25', actual: null, status: 'NOT_STARTED', contractMilestone: 'CM4', doc: null, owner: '周涛' }
  ];

  const employees = [
    { id: 'E1001', name: '陈立', role: '项目经理', dept: '项目管理部', level: 'P7', costDay: 2400, billDay: 3600, available: 160, allocated: 120, utilization: 0.92, skills: ['项目管理', '数据中台', '交付管理'], avatar: '陈' },
    { id: 'E1002', name: '张伟', role: '架构师', dept: '技术中心', level: 'P7', costDay: 2600, billDay: 4000, available: 168, allocated: 140, utilization: 0.89, skills: ['Java', '微服务', '云原生', '架构设计'], avatar: '张' },
    { id: 'E1003', name: '李娜', role: '前端工程师', dept: '技术中心', level: 'P5', costDay: 1800, billDay: 2600, available: 168, allocated: 150, utilization: 0.92, skills: ['Vue', 'React', '可视化'], avatar: '李' },
    { id: 'E1004', name: '王强', role: '后端工程师', dept: '技术中心', level: 'P6', costDay: 2200, billDay: 3200, available: 168, allocated: 156, utilization: 0.95, skills: ['Java', 'Spring Cloud', 'MySQL'], avatar: '王' },
    { id: 'E1005', name: '赵敏', role: '测试工程师', dept: '质量中心', level: 'P5', costDay: 1600, billDay: 2300, available: 168, allocated: 120, utilization: 0.78, skills: ['自动化测试', '性能测试'], avatar: '赵' },
    { id: 'E1006', name: '周涛', role: '实施顾问', dept: '交付中心', level: 'P6', costDay: 2000, billDay: 3000, available: 168, allocated: 144, utilization: 0.88, skills: ['实施交付', '客户培训', '智慧园区'], avatar: '周' },
    { id: 'E1007', name: '孙悦', role: 'UI 设计师', dept: '产品与设计中心', level: 'P5', costDay: 1700, billDay: 2400, available: 168, allocated: 126, utilization: 0.80, skills: ['UI设计', '交互设计', '设计规范'], avatar: '孙' },
    { id: 'E1008', name: '吴磊', role: '数据工程师', dept: '技术中心', level: 'P6', costDay: 2100, billDay: 3100, available: 168, allocated: 168, utilization: 1.0, skills: ['数据治理', 'ETL', 'Flink'], avatar: '吴' },
    { id: 'E1009', name: '郑洁', role: '业务分析师', dept: '交付中心', level: 'P6', costDay: 1900, billDay: 2800, available: 168, allocated: 132, utilization: 0.82, skills: ['需求分析', '业务建模'], avatar: '郑' },
    { id: 'E1010', name: '林峰', role: '后端工程师', dept: '技术中心', level: 'P4', costDay: 1500, billDay: 2200, available: 168, allocated: 96, utilization: 0.62, skills: ['Java', 'Redis', 'Kafka'], avatar: '林' },
    { id: 'E1011', name: '何静', role: '测试工程师', dept: '质量中心', level: 'P4', costDay: 1400, billDay: 2000, available: 168, allocated: 112, utilization: 0.70, skills: ['功能测试', '接口测试'], avatar: '何' },
    { id: 'E1012', name: '徐凯', role: '数据工程师', dept: '技术中心', level: 'P4', costDay: 1600, billDay: 2400, available: 168, allocated: 84, utilization: 0.55, skills: ['SQL', '数据仓库', 'ETL'], avatar: '徐' }
  ];

  const skills = [
    { code: 'SK01', name: '架构设计', category: '技术' }, { code: 'SK02', name: 'Java', category: '技术' },
    { code: 'SK03', name: '微服务', category: '技术' }, { code: 'SK04', name: '云原生', category: '技术' },
    { code: 'SK05', name: 'Vue', category: '技术' }, { code: 'SK06', name: '数据治理', category: '数据' },
    { code: 'SK07', name: 'ETL', category: '数据' }, { code: 'SK08', name: '性能测试', category: '质量' },
    { code: 'SK09', name: '项目管理', category: '管理' }, { code: 'SK10', name: '需求分析', category: '业务' },
    { code: 'SK11', name: '实施交付', category: '交付' }, { code: 'SK12', name: 'UI设计', category: '设计' }
  ];

  const employeeSkills = [
    { employeeId: 'E1002', skill: '架构设计', level: 5, years: 9, certified: true, primary: true },
    { employeeId: 'E1002', skill: 'Java', level: 5, years: 11, certified: true, primary: false },
    { employeeId: 'E1002', skill: '微服务', level: 4, years: 7, certified: true, primary: false },
    { employeeId: 'E1004', skill: 'Java', level: 4, years: 6, certified: false, primary: true },
    { employeeId: 'E1004', skill: '微服务', level: 4, years: 5, certified: false, primary: false },
    { employeeId: 'E1003', skill: 'Vue', level: 5, years: 6, certified: false, primary: true },
    { employeeId: 'E1008', skill: '数据治理', level: 4, years: 5, certified: true, primary: true },
    { employeeId: 'E1008', skill: 'ETL', level: 4, years: 6, certified: false, primary: false },
    { employeeId: 'E1010', skill: 'Java', level: 3, years: 3, certified: false, primary: true },
    { employeeId: 'E1012', skill: 'ETL', level: 3, years: 3, certified: false, primary: true }
  ];

  const members = [
    { id: 'M01', projectId: 'PJ-2026-0021', employeeId: 'E1001', name: '陈立', role: '项目经理', nature: 'SETTLE', planned: 960, costDay: 2400, billDay: 3600, start: '2026-03-25', end: '2026-12-31', ratio: 0.5, status: '有效' },
    { id: 'M02', projectId: 'PJ-2026-0021', employeeId: 'E1002', name: '张伟', role: '架构师', nature: 'SETTLE', planned: 1440, costDay: 2600, billDay: 4000, start: '2026-03-25', end: '2026-12-31', ratio: 0.6, status: '有效' },
    { id: 'M03', projectId: 'PJ-2026-0021', employeeId: 'E1003', name: '李娜', role: '前端工程师', nature: 'SETTLE', planned: 1600, costDay: 1800, billDay: 2600, start: '2026-05-06', end: '2026-11-30', ratio: 0.8, status: '有效' },
    { id: 'M04', projectId: 'PJ-2026-0021', employeeId: 'E1004', name: '王强', role: '后端工程师', nature: 'SETTLE', planned: 1760, costDay: 2200, billDay: 3200, start: '2026-04-01', end: '2026-12-15', ratio: 0.9, status: '有效' },
    { id: 'M05', projectId: 'PJ-2026-0021', employeeId: 'E1005', name: '赵敏', role: '测试工程师', nature: 'SETTLE', planned: 1200, costDay: 1600, billDay: 2300, start: '2026-08-01', end: '2026-12-10', ratio: 0.6, status: '有效' },
    { id: 'M06', projectId: 'PJ-2026-0021', employeeId: 'E1006', name: '周涛', role: '实施顾问', nature: 'SETTLE', planned: 1280, costDay: 2000, billDay: 3000, start: '2026-03-25', end: '2027-03-31', ratio: 0.7, status: '有效' },
    { id: 'M07', projectId: 'PJ-2026-0021', employeeId: 'E1007', name: '孙悦', role: 'UI 设计师', nature: 'SETTLE', planned: 640, costDay: 1700, billDay: 2400, start: '2026-05-05', end: '2026-07-31', ratio: 0.4, status: '已离场' },
    { id: 'M08', projectId: 'PJ-2026-0021', employeeId: 'E1008', name: '吴磊', role: '数据工程师', nature: 'SETTLE', planned: 800, costDay: 2100, billDay: 3100, start: '2026-05-10', end: '2026-10-31', ratio: 0.5, status: '已离场' },
    { id: 'M09', projectId: 'PJ-2026-0021', employeeId: 'E1009', name: '郑洁', role: '业务分析师', nature: 'NON_SETTLE', planned: 720, costDay: 1900, billDay: 0, start: '2026-03-25', end: '2026-07-31', ratio: 0.4, status: '已离场' }
  ];

  const budgetLines = [
    { subject: '人力成本', phase: 'P1 启动与蓝图', phaseId: 'PH1', hours: 1800, amount: 620000 },
    { subject: '人力成本', phase: 'P2 架构与设计', phaseId: 'PH2', hours: 2400, amount: 860000 },
    { subject: '人力成本', phase: 'P3 开发实现', phaseId: 'PH3', hours: 5600, amount: 1980000 },
    { subject: '人力成本', phase: 'P4 测试与上线', phaseId: 'PH4', hours: 2200, amount: 700000 },
    { subject: '人力成本', phase: 'P5 验收与质保', phaseId: 'PH5', hours: 800, amount: 160000 },
    { subject: '采购成本', phase: 'P3 开发实现', phaseId: 'PH3', hours: 0, amount: 1120000 },
    { subject: '差旅费用', phase: '全过程', phaseId: null, hours: 0, amount: 380000 },
    { subject: '其他费用', phase: '全过程', phaseId: null, hours: 0, amount: 420000 }
  ];

  const projects = [
    { id: 'PJ-2026-0021', name: '华润数科数字化中台建设', customerId: 'CUS-0001', customer: '华润数科', contractId: 'CT-2026-0087', pm: '陈立', pmId: 'E1001', org: '交付中心', status: 'IN_PROGRESS', percent: 62, start: '2026-03-25', end: '2026-12-31', contractAmount: 8600000, budget: 6240000, actual: 4076000, eac: 6120000, margin: 0.246, health: '正常', risk: '工期紧张', members: 9, tasks: 18 },
    { id: 'PJ-2026-0014', name: '中海物业智慧园区一期', customerId: 'CUS-0002', customer: '中海物业', contractId: 'CT-2026-0052', pm: '周涛', pmId: 'E1006', org: '交付中心', status: 'IN_PROGRESS', percent: 48, start: '2026-02-01', end: '2026-11-30', contractAmount: 3200000, budget: 2380000, actual: 1780000, eac: 2520000, margin: 0.165, health: '风险', risk: '成本超支 5.9%', members: 6, tasks: 14 },
    { id: 'PJ-2026-0018', name: '国网信通数据资产平台', customerId: 'CUS-0003', customer: '国网信通', contractId: 'CT-2026-0061', pm: '王强', pmId: 'E1004', org: '技术中心', status: 'IN_PROGRESS', percent: 35, start: '2026-04-15', end: '2027-04-15', contractAmount: 5400000, budget: 4120000, actual: 1920000, eac: 4050000, margin: 0.205, health: '正常', risk: '无', members: 8, tasks: 16 },
    { id: 'PJ-2026-0016', name: '招商蛇口营销数字化', customerId: 'CUS-0004', customer: '招商蛇口', contractId: 'CT-2026-0033', pm: '李娜', pmId: 'E1003', org: '交付中心', status: 'COMPLETED', percent: 100, start: '2026-01-05', end: '2026-08-31', contractAmount: 2800000, budget: 2150000, actual: 2080000, eac: 2080000, margin: 0.213, health: '正常', risk: '无', members: 5, tasks: 11 },
    { id: 'PJ-2026-0009', name: '京东方供应链协同', customerId: 'CUS-0005', customer: '京东方', contractId: 'CT-2025-0118', pm: '陈立', pmId: 'E1001', org: '交付中心', status: 'COMPLETED', percent: 100, start: '2025-10-08', end: '2026-09-30', contractAmount: 4600000, budget: 3580000, actual: 3410000, eac: 3410000, margin: 0.214, health: '正常', risk: '无', members: 7, tasks: 15 },
    { id: 'PJ-2026-0023', name: '中国邮政客户数据平台', customerId: 'CUS-0006', customer: '中国邮政', contractId: 'CT-2026-0074', pm: '张伟', pmId: 'E1002', org: '技术中心', status: 'PREPARING', percent: 5, start: '2026-12-01', end: '2027-11-30', contractAmount: 6200000, budget: 4760000, actual: 0, eac: 4760000, margin: 0.186, health: '待立项', risk: '立项审批中', members: 3, tasks: 6 },
    { id: 'PJ-2026-0011', name: '中海物业能耗监测', customerId: 'CUS-0002', customer: '中海物业', contractId: 'CT-2026-0052', pm: '周涛', pmId: 'E1006', org: '交付中心', status: 'PAUSED', percent: 40, start: '2026-03-01', end: '2026-12-31', contractAmount: 1600000, budget: 1280000, actual: 1020000, eac: 1410000, margin: 0.066, health: '预警', risk: '客户需求变更，暂停 21 天', members: 4, tasks: 9 },
    { id: 'PJ-2025-0042', name: '华润数科数据治理咨询', customerId: 'CUS-0001', customer: '华润数科', contractId: 'CT-2025-0101', pm: '郑洁', pmId: 'E1009', org: '交付中心', status: 'COMPLETED', percent: 100, start: '2025-05-06', end: '2025-12-20', contractAmount: 1800000, budget: 1320000, actual: 1260000, eac: 1260000, margin: 0.258, health: '正常', risk: '无', members: 4, tasks: 10 }
  ];

  const weekDays = [
    { key: 'mon', label: '11-02 周一', date: '2026-11-02' },
    { key: 'tue', label: '11-03 周二', date: '2026-11-03' },
    { key: 'wed', label: '11-04 周三', date: '2026-11-04' },
    { key: 'thu', label: '11-05 周四', date: '2026-11-05' },
    { key: 'fri', label: '11-06 周五', date: '2026-11-06' },
    { key: 'sat', label: '11-07 周六', date: '2026-11-07' },
    { key: 'sun', label: '11-08 周日', date: '2026-11-08' }
  ];

  const timesheetItems = [
    { id: 'TSI01', date: '2026-11-02', day: 'mon', projectId: 'PJ-2026-0021', taskId: 'T-0312', hours: 8, workType: 'CUSTOMER_PROJECT', billable: true, costCenter: '技术中心', content: '第三方接口联调：CRM 客户主数据同步' },
    { id: 'TSI02', date: '2026-11-03', day: 'tue', projectId: 'PJ-2026-0021', taskId: 'T-0312', hours: 8, workType: 'CUSTOMER_PROJECT', billable: true, costCenter: '技术中心', content: '接口联调与异常重试机制' },
    { id: 'TSI03', date: '2026-11-04', day: 'wed', projectId: 'PJ-2026-0021', taskId: 'T-0315', hours: 6, workType: 'CUSTOMER_PROJECT', billable: true, costCenter: '技术中心', content: '性能压测脚本调试' },
    { id: 'TSI04', date: '2026-11-04', day: 'wed', projectId: 'PJ-2026-0021', taskId: 'T-0320', hours: 2, workType: 'INTERNAL_ADMIN', billable: false, costCenter: '技术中心', content: '内部技术评审会' },
    { id: 'TSI05', date: '2026-11-05', day: 'thu', projectId: 'PJ-2026-0021', taskId: 'T-0312', hours: 8, workType: 'CUSTOMER_PROJECT', billable: true, costCenter: '技术中心', content: '接口联调：支付中心对接' },
    { id: 'TSI06', date: '2026-11-06', day: 'fri', projectId: 'PJ-2026-0021', taskId: 'T-0308', hours: 4, workType: 'CUSTOMER_PROJECT', billable: true, costCenter: '技术中心', content: '基础服务缺陷修复' },
    { id: 'TSI07', date: '2026-11-06', day: 'fri', projectId: 'PJ-2026-0021', taskId: 'T-0321', hours: 4, workType: 'TRAINING', billable: false, costCenter: '技术中心', content: '云原生架构内部培训' }
  ];

  const timesheets = [
    { id: 'TS-2026-W45-001', no: 'TS-202645-001', employee: '张伟', employeeId: 'E1002', project: '华润数科数字化中台建设', projectId: 'PJ-2026-0021', week: '2026-W45', total: 40, status: 'DRAFT', locked: false, submitTime: null, billable: 30 },
    { id: 'TS-2026-W45-002', no: 'TS-202645-002', employee: '郑洁', employeeId: 'E1009', project: '华润数科数字化中台建设', projectId: 'PJ-2026-0021', week: '2026-W45', total: 38, status: 'PENDING', locked: false, submitTime: '2026-11-09 09:12', billable: 32 },
    { id: 'TS-2026-W45-003', no: 'TS-202645-003', employee: '李娜', employeeId: 'E1003', project: '华润数科数字化中台建设', projectId: 'PJ-2026-0021', week: '2026-W45', total: 42, status: 'PENDING', locked: false, submitTime: '2026-11-09 09:40', billable: 36 },
    { id: 'TS-2026-W44-001', no: 'TS-202644-001', employee: '张伟', employeeId: 'E1002', project: '华润数科数字化中台建设', projectId: 'PJ-2026-0021', week: '2026-W44', total: 40, status: 'LOCKED', locked: true, submitTime: '2026-11-02 08:55', billable: 32 },
    { id: 'TS-2026-W45-004', no: 'TS-202645-004', employee: '王强', employeeId: 'E1004', project: '华润数科数字化中台建设', projectId: 'PJ-2026-0021', week: '2026-W45', total: 44, status: 'PENDING', locked: false, submitTime: '2026-11-09 10:05', billable: 40 }
  ];

  const settlementBatches = [
    { id: 'STB-202610-CUST-01', no: 'STB-202610-CUST-01', type: 'CUSTOMER', month: '2026-10', customer: '华润数科', customerId: 'CUS-0001', project: '华润数科数字化中台建设', projectId: 'PJ-2026-0021', contract: 'CT-2026-0087', start: '2026-10-01', end: '2026-10-31', days: 52, amount: 168900, status: 'CONFIRMED', orders: 4, invoiced: 168900, owner: '刘芳', created: '2026-11-01' },
    { id: 'STB-202610-CUST-02', no: 'STB-202610-CUST-02', type: 'CUSTOMER', month: '2026-10', customer: '中海物业', customerId: 'CUS-0002', project: '中海物业智慧园区一期', projectId: 'PJ-2026-0014', contract: 'CT-2026-0052', start: '2026-10-01', end: '2026-10-31', days: 148, amount: 486500, status: 'PENDING', orders: 6, invoiced: 0, owner: '刘芳', created: '2026-11-01' },
    { id: 'STB-202610-CUST-03', no: 'STB-202610-CUST-03', type: 'CUSTOMER', month: '2026-10', customer: '国网信通', customerId: 'CUS-0003', project: '国网信通数据资产平台', projectId: 'PJ-2026-0018', contract: 'CT-2026-0061', start: '2026-10-01', end: '2026-10-31', days: 120, amount: 402000, status: 'DRAFT', orders: 5, invoiced: 0, owner: '王强', created: '2026-11-02' },
    { id: 'STB-202609-CUST-04', no: 'STB-202609-CUST-04', type: 'CUSTOMER', month: '2026-09', customer: '招商蛇口', customerId: 'CUS-0004', project: '招商蛇口营销数字化', projectId: 'PJ-2026-0016', contract: 'CT-2026-0033', start: '2026-09-01', end: '2026-09-30', days: 70, amount: 229000, status: 'SETTLED', orders: 3, invoiced: 229000, owner: '刘芳', created: '2026-10-02' },
    { id: 'STB-202610-SUP-01', no: 'STB-202610-SUP-01', type: 'SUPPLIER', month: '2026-10', customer: '云启数据服务有限公司', customerId: null, project: '华润数科数字化中台建设', projectId: 'PJ-2026-0021', contract: 'CT-2026-0087', start: '2026-10-01', end: '2026-10-31', days: 0, amount: 180000, status: 'CONFIRMED', orders: 1, invoiced: 0, owner: '刘芳', created: '2026-11-01' }
  ];

  const settlementOrders = [
    { id: 'SO-202610-01', batchId: 'STB-202610-CUST-01', employee: '张伟', employeeId: 'E1002', role: '架构师', nature: 'SETTLE', days: 20, price: 4000, amount: 80000, month: '2026-10', status: 'CONFIRMED', invoiceId: 'INV-2026-0231' },
    { id: 'SO-202610-02', batchId: 'STB-202610-CUST-01', employee: '李娜', employeeId: 'E1003', role: '前端工程师', nature: 'SETTLE', days: 15, price: 2600, amount: 39000, month: '2026-10', status: 'CONFIRMED', invoiceId: 'INV-2026-0231' },
    { id: 'SO-202610-03', batchId: 'STB-202610-CUST-01', employee: '王强', employeeId: 'E1004', role: '后端工程师', nature: 'SETTLE', days: 12, price: 3200, amount: 38400, month: '2026-10', status: 'CONFIRMED', invoiceId: 'INV-2026-0231' },
    { id: 'SO-202610-04', batchId: 'STB-202610-CUST-01', employee: '赵敏', employeeId: 'E1005', role: '测试工程师', nature: 'SETTLE', days: 5, price: 2300, amount: 11500, month: '2026-10', status: 'CONFIRMED', invoiceId: 'INV-2026-0231' }
  ];

  const settlements = settlementBatches;
  const settlementItems = [];

  const invoices = [
    { id: 'INV-2026-0189', no: 'INV-2026-0189', customer: '华润数科', customerId: 'CUS-0001', contract: 'CT-2026-0087', project: '华润数科数字化中台建设', projectId: 'PJ-2026-0021', type: '数电专票', date: '2026-04-12', excl: 2433962.26, rate: 0.06, tax: 146037.74, incl: 2580000, status: 'ISSUED', source: '里程碑', milestone: 'M1 预付款', settlement: null, received: 2580000, redFlushOf: null },
    { id: 'INV-2026-0212', no: 'INV-2026-0212', customer: '华润数科', customerId: 'CUS-0001', contract: 'CT-2026-0087', project: '华润数科数字化中台建设', projectId: 'PJ-2026-0021', type: '数电专票', date: '2026-06-18', excl: 1622641.51, rate: 0.06, tax: 97358.49, incl: 1720000, status: 'ISSUED', source: '里程碑', milestone: 'M2 蓝图确认款', settlement: null, received: 1720000, redFlushOf: null },
    { id: 'INV-2026-0231', no: 'INV-2026-0231', customer: '华润数科', customerId: 'CUS-0001', contract: 'CT-2026-0087', project: '华润数科数字化中台建设', projectId: 'PJ-2026-0021', type: '数电专票', date: '2026-10-28', excl: 159339.62, rate: 0.06, tax: 9560.38, incl: 168900, status: 'ISSUED', source: '结算单', milestone: null, settlement: 'STB-202610-CUST-01', received: 168900, redFlushOf: null },
    { id: 'INV-2026-0245', no: 'INV-2026-0245', customer: '华润数科', customerId: 'CUS-0001', contract: 'CT-2026-0087', project: '华润数科数字化中台建设', projectId: 'PJ-2026-0021', type: '数电专票', date: '2026-10-25', excl: 1132075.47, rate: 0.06, tax: 67924.53, incl: 1200000, status: 'ISSUED', source: '里程碑', milestone: 'M3 上线验收款（部分）', settlement: null, received: 0, redFlushOf: null },
    { id: 'INV-2026-0166', no: 'INV-2026-0166', customer: '中海物业', customerId: 'CUS-0002', contract: 'CT-2026-0052', project: '中海物业智慧园区一期', projectId: 'PJ-2026-0014', type: '数电专票', date: '2026-03-30', excl: 169811.32, rate: 0.06, tax: 10188.68, incl: 180000, status: 'RED_FLUSH', source: '里程碑', milestone: 'M2 进度款', settlement: null, received: 0, redFlushOf: 'INV-2026-0142' },
    { id: 'INV-2026-0258', no: 'INV-2026-0258', customer: '国网信通', customerId: 'CUS-0003', contract: 'CT-2026-0061', project: '国网信通数据资产平台', projectId: 'PJ-2026-0018', type: '数电专票', date: '2026-10-08', excl: 95094.34, rate: 0.06, tax: 5705.66, incl: 100800, status: 'ISSUED', source: '里程碑', milestone: 'M2 进度款', settlement: null, received: 4800, redFlushOf: null },
    { id: 'INV-2026-0261', no: 'INV-2026-0261', customer: '中海物业', customerId: 'CUS-0002', contract: 'CT-2026-0052', project: '中海物业智慧园区一期', projectId: 'PJ-2026-0014', type: '数电专票', date: '2026-09-22', excl: 205660.38, rate: 0.06, tax: 12339.62, incl: 218000, status: 'ISSUED', source: '里程碑', milestone: 'M3 验收款', settlement: null, received: 0, redFlushOf: null },
    { id: 'INV-2026-0219', no: 'INV-2026-0219', customer: '华润数科', customerId: 'CUS-0001', contract: 'CT-2026-0087', project: '华润数科数字化中台建设', projectId: 'PJ-2026-0021', type: '数电普票', date: '2026-08-05', excl: 42452.83, rate: 0.06, tax: 2547.17, incl: 45000, status: 'VOID', source: '其他', milestone: null, settlement: null, received: 0, redFlushOf: null }
  ];

  const receipts = [
    { id: 'RCP-2026-0126', no: 'RCP-2026-0126', customer: '华润数科', customerId: 'CUS-0001', contract: 'CT-2026-0087', project: '华润数科数字化中台建设', date: '2026-04-28', amount: 2580000, method: '银行转账', bank: '招商银行深圳分行', status: '已核销', writeOff: 2580000, invoice: 'INV-2026-0189', milestone: 'M1 预付款' },
    { id: 'RCP-2026-0158', no: 'RCP-2026-0158', customer: '华润数科', customerId: 'CUS-0001', contract: 'CT-2026-0087', project: '华润数科数字化中台建设', date: '2026-07-20', amount: 1720000, method: '银行转账', bank: '招商银行深圳分行', status: '已核销', writeOff: 1720000, invoice: 'INV-2026-0212', milestone: 'M2 蓝图确认款' },
    { id: 'RCP-2026-0203', no: 'RCP-2026-0203', customer: '华润数科', customerId: 'CUS-0001', contract: 'CT-2026-0087', project: '华润数科数字化中台建设', date: '2026-10-18', amount: 168900, method: '银行转账', bank: '中国银行深圳科技园支行', status: '已核销', writeOff: 168900, invoice: 'INV-2026-0231', milestone: null },
    { id: 'RCP-2026-0198', no: 'RCP-2026-0198', customer: '国网信通', customerId: 'CUS-0003', contract: 'CT-2026-0061', project: '国网信通数据资产平台', date: '2026-10-12', amount: 4800, method: '银行转账', bank: '工商银行北京分行', status: '部分核销', writeOff: 4800, invoice: 'INV-2026-0258', milestone: 'M2 进度款' },
    { id: 'RCP-2026-0187', no: 'RCP-2026-0187', customer: '招商蛇口', customerId: 'CUS-0004', contract: 'CT-2026-0033', project: '招商蛇口营销数字化', date: '2026-09-05', amount: 980000, method: '银行转账', bank: '建设银行深圳分行', status: '已核销', writeOff: 980000, invoice: null, milestone: 'M4 尾款' }
  ];

  const arBalances = [
    { invoice: 'INV-2026-0245', customer: '华润数科', contract: 'CT-2026-0087', project: '华润数科数字化中台建设', amount: 1200000, writeOff: 0, balance: 1200000, due: '2026-12-30', overdueDays: 0, status: '未到期' },
    { invoice: 'INV-2026-0261', customer: '中海物业', contract: 'CT-2026-0052', project: '中海物业智慧园区一期', amount: 218000, writeOff: 0, balance: 218000, due: '2026-10-23', overdueDays: 18, status: '已逾期' },
    { invoice: 'INV-2026-0258', customer: '国网信通', contract: 'CT-2026-0061', project: '国网信通数据资产平台', amount: 100800, writeOff: 4800, balance: 96000, due: '2026-09-25', overdueDays: 46, status: '已逾期' }
  ];

  const expenses = [
    { id: 'EXP-202610-01', type: '差旅费', applicant: '周涛', project: '华润数科数字化中台建设', projectId: 'PJ-2026-0021', task: 'T-0314', costCenter: '交付中心', payee: '员工报销', date: '2026-10-18', amount: 12860, tax: 364, status: 'APPROVED', invoiceNo: '客运电子发票 3 张' },
    { id: 'EXP-202610-02', type: '采购支出', applicant: '王强', project: '华润数科数字化中台建设', projectId: 'PJ-2026-0021', task: 'T-0308', costCenter: '技术中心', payee: '阿里云计算有限公司', date: '2026-10-09', amount: 86000, tax: 4870, status: 'APPROVED', invoiceNo: '数电专票 25440000' },
    { id: 'EXP-202610-03', type: '外包服务', applicant: '陈立', project: '华润数科数字化中台建设', projectId: 'PJ-2026-0021', task: 'T-0311', costCenter: '交付中心', payee: '云启数据服务有限公司', date: '2026-10-25', amount: 180000, tax: 10189, status: 'APPROVED', invoiceNo: '数电专票 25440121' },
    { id: 'EXP-202610-04', type: '会议费', applicant: '陈立', project: '华润数科数字化中台建设', projectId: 'PJ-2026-0021', task: null, costCenter: '交付中心', payee: '深圳湾万丽酒店', date: '2026-10-30', amount: 3200, tax: 181, status: 'SUBMITTED', invoiceNo: '数电普票 25440233' },
    { id: 'EXP-202610-05', type: '培训费', applicant: '赵敏', project: '华润数科数字化中台建设', projectId: 'PJ-2026-0021', task: 'T-0321', costCenter: '质量中心', payee: '中国软件评测中心', date: '2026-10-15', amount: 8600, tax: 487, status: 'PAID', invoiceNo: '数电专票 25439871' },
    { id: 'EXP-202610-06', type: '差旅费', applicant: '郑洁', project: '华润数科数字化中台建设', projectId: 'PJ-2026-0021', task: 'T-0314', costCenter: '交付中心', payee: '员工报销', date: '2026-11-02', amount: 6400, tax: 172, status: 'DRAFT', invoiceNo: '待上传' }
  ];

  const laborCosts = [
    { employeeId: 'E1001', name: '陈立', dept: '交付中心', base: 38000, social: 8360, fund: 4560, bonus: 6000, benefit: 1200, recruit: 380, training: 420, total: 58920, standard: 168, available: 160, hourly: 368.25 },
    { employeeId: 'E1002', name: '张伟', dept: '技术中心', base: 42000, social: 9240, fund: 5040, bonus: 8000, benefit: 1500, recruit: 420, training: 500, total: 66700, standard: 168, available: 168, hourly: 396.94 },
    { employeeId: 'E1003', name: '李娜', dept: '技术中心', base: 26000, social: 5720, fund: 3120, bonus: 3000, benefit: 900, recruit: 260, training: 280, total: 39280, standard: 168, available: 168, hourly: 233.81 },
    { employeeId: 'E1004', name: '王强', dept: '技术中心', base: 32000, social: 7040, fund: 3840, bonus: 4000, benefit: 1100, recruit: 320, training: 340, total: 48640, standard: 168, available: 168, hourly: 289.52 },
    { employeeId: 'E1005', name: '赵敏', dept: '质量中心', base: 22000, social: 4840, fund: 2640, bonus: 2000, benefit: 800, recruit: 220, training: 260, total: 32760, standard: 168, available: 168, hourly: 194.99 },
    { employeeId: 'E1006', name: '周涛', dept: '交付中心', base: 28000, social: 6160, fund: 3360, bonus: 3000, benefit: 1000, recruit: 280, training: 300, total: 42100, standard: 168, available: 168, hourly: 250.59 },
    { employeeId: 'E1007', name: '孙悦', dept: '产品与设计中心', base: 24000, social: 5280, fund: 2880, bonus: 2000, benefit: 800, recruit: 240, training: 260, total: 35460, standard: 168, available: 168, hourly: 211.07 },
    { employeeId: 'E1008', name: '吴磊', dept: '技术中心', base: 30000, social: 6600, fund: 3600, bonus: 3500, benefit: 1000, recruit: 300, training: 320, total: 45320, standard: 168, available: 168, hourly: 269.76 },
    { employeeId: 'E1009', name: '郑洁', dept: '交付中心', base: 27000, social: 5940, fund: 3240, bonus: 3000, benefit: 900, recruit: 270, training: 290, total: 40640, standard: 168, available: 168, hourly: 241.90 }
  ];

  const laborAllocations = [
    { employeeId: 'E1002', name: '张伟', hours: 168, cost: 66700, project: '华润数科数字化中台建设', projectId: 'PJ-2026-0021', task: 'T-0315', workType: 'CUSTOMER_PROJECT', costCenter: '技术中心', method: '按工时分摊' },
    { employeeId: 'E1004', name: '王强', hours: 168, cost: 48640, project: '华润数科数字化中台建设', projectId: 'PJ-2026-0021', task: 'T-0309', workType: 'CUSTOMER_PROJECT', costCenter: '技术中心', method: '按工时分摊' },
    { employeeId: 'E1003', name: '李娜', hours: 160, cost: 37410, project: '华润数科数字化中台建设', projectId: 'PJ-2026-0021', task: 'T-0310', workType: 'CUSTOMER_PROJECT', costCenter: '技术中心', method: '按工时分摊' },
    { employeeId: 'E1005', name: '赵敏', hours: 150, cost: 29250, project: '华润数科数字化中台建设', projectId: 'PJ-2026-0021', task: 'T-0313', workType: 'CUSTOMER_PROJECT', costCenter: '质量中心', method: '按工时分摊' },
    { employeeId: 'E1006', name: '周涛', hours: 152, cost: 38090, project: '华润数科数字化中台建设', projectId: 'PJ-2026-0021', task: 'T-0314', workType: 'CUSTOMER_PROJECT', costCenter: '交付中心', method: '按工时分摊' },
    { employeeId: 'E1001', name: '陈立', hours: 88, cost: 32400, project: '华润数科数字化中台建设', projectId: 'PJ-2026-0021', task: null, workType: 'INTERNAL_ADMIN', costCenter: '交付中心', method: '按工时分摊' },
    { employeeId: 'E1007', name: '孙悦', hours: 0, cost: 0, project: '内部研发（设计中台）', projectId: null, task: null, workType: 'INTERNAL_RND', costCenter: '产品与设计中心', method: '按工时分摊' }
  ];

  const costActuals = [
    { subject: '人力成本', type: '人力', budget: 4320000, actual: 2986000, forecast: 4460000, color: '#1d4ed8' },
    { subject: '采购/外包', type: '外包', budget: 1120000, actual: 780000, forecast: 1120000, color: '#3b82f6' },
    { subject: '差旅费用', type: '费用', budget: 380000, actual: 214000, forecast: 340000, color: '#67c23a' },
    { subject: '其他费用', type: '费用', budget: 420000, actual: 96000, forecast: 200000, color: '#e6a23c' }
  ];

  const forecast = { version: 'F2026-10-V2', period: '2026-10', percent: 62, revenue: 8113207.55, costToDate: 4076000, etc: 2044000, eac: 6120000, forecastRevenue: 8113207.55, forecastProfit: 1993207.55, forecastMargin: 0.2456, method: 'EFFORT（工时进度法）', lastUpdate: '2026-11-01 18:20' };

  const approvals = [
    { id: 'AP-2026-1021', type: '立项审批', biz: 'PJ-2026-0023', title: '中国邮政客户数据平台 · 项目立项', applicant: '张伟', applicantId: 'E1002', dept: '技术中心', submitTime: '2026-11-06 14:22', status: 'PENDING', currentNode: 'PMO 审核', amount: 6200000, hours: 0, urgent: true },
    { id: 'AP-2026-1022', type: '预算审批', biz: 'PJ-2026-0021', title: '华润数科数字化中台 · 项目预算 V2.0', applicant: '陈立', applicantId: 'E1001', dept: '交付中心', submitTime: '2026-11-05 09:40', status: 'PENDING', currentNode: '财务审核', amount: 6240000, hours: 12800, urgent: false },
    { id: 'AP-2026-1023', type: '工时审批', biz: 'TS-2026-W45-002', title: '郑洁 · 2026-W45 工时单（38h）', applicant: '郑洁', applicantId: 'E1009', dept: '交付中心', submitTime: '2026-11-09 09:12', status: 'PENDING', currentNode: '项目经理审批', amount: 0, hours: 38, urgent: false },
    { id: 'AP-2026-1024', type: '费用报销', biz: 'EXP-202610-04', title: '项目会议费 · 深圳湾万丽酒店', applicant: '陈立', applicantId: 'E1001', dept: '交付中心', submitTime: '2026-11-03 17:05', status: 'PENDING', currentNode: '部门负责人审批', amount: 3200, hours: 0, urgent: false },
    { id: 'AP-2026-1025', type: '合同变更', biz: 'CT-2026-0087', title: '补充协议二 · 上线日期顺延至 2027-01-15', applicant: '陈立', applicantId: 'E1001', dept: '交付中心', submitTime: '2026-11-05 16:30', status: 'PENDING', currentNode: '法务审核', amount: 0, hours: 0, urgent: true },
    { id: 'AP-2026-1018', type: '工时审批', biz: 'TS-2026-W44-002', title: '李娜 · 2026-W44 工时单（40h）', applicant: '李娜', applicantId: 'E1003', dept: '技术中心', submitTime: '2026-11-02 09:00', status: 'APPROVED', currentNode: '已完成', amount: 0, hours: 40, urgent: false },
    { id: 'AP-2026-1015', type: '费用报销', biz: 'EXP-202609-18', title: '项目差旅费 · 北京往返', applicant: '周涛', applicantId: 'E1006', dept: '交付中心', submitTime: '2026-10-28 10:15', status: 'APPROVED', currentNode: '已完成', amount: 8420, hours: 0, urgent: false },
    { id: 'AP-2026-1009', type: '预算审批', biz: 'PJ-2026-0018', title: '国网信通数据资产平台 · 项目预算 V1.0', applicant: '王强', applicantId: 'E1004', dept: '技术中心', submitTime: '2026-10-15 11:20', status: 'APPROVED', currentNode: '已完成', amount: 4120000, hours: 9600, urgent: false }
  ];

  const approvalNodes = {
    'AP-2026-1022': [
      { name: '项目经理提交', approver: '陈立', status: 'DONE', time: '2026-11-05 09:40', opinion: '预算 V2.0，按阶段/任务重编，人工预算按成本单价×工时。' },
      { name: '部门负责人审批', approver: '王海', status: 'DONE', time: '2026-11-05 15:12', opinion: '同意，注意 11-12 月外包成本控制。' },
      { name: '财务审核', approver: '刘芳', status: 'CURRENT', time: null, opinion: null },
      { name: 'COO 审批', approver: '赵总', status: 'WAIT', time: null, opinion: null }
    ],
    'AP-2026-1021': [
      { name: '申请人提交', approver: '张伟', status: 'DONE', time: '2026-11-06 14:22', opinion: '合同已签，申请立项并启动资源准备。' },
      { name: 'PMO 审核', approver: '陈静', status: 'CURRENT', time: null, opinion: null },
      { name: 'COO 审批', approver: '赵总', status: 'WAIT', time: null, opinion: null }
    ]
  };

  const integration = [
    { code: 'CRM', name: '客户关系系统', desc: '客户 / 联系人 / 商机 / 跟进', tables: 34, apis: 286, status: '已同步', last: '2026-11-10 09:42', percent: 100, color: '#1d4ed8', module: '客户与商机' },
    { code: 'PMT', name: '项目管理系统', desc: '项目 / 工时 / 结算 / 结算单', tables: 58, apis: 412, status: '已同步', last: '2026-11-10 09:40', percent: 100, color: '#3b82f6', module: '项目与交付' },
    { code: 'HR', name: '人力资源系统', desc: '员工 / 组织 / 薪酬 / 考勤', tables: 61, apis: 298, status: '同步中', last: '2026-11-10 09:35', percent: 87, color: '#67c23a', module: '资源与成本' },
    { code: 'FS', name: '财务预算系统', desc: '预算 / 应收 / 利润报表', tables: 20, apis: 168, status: '已同步', last: '2026-11-10 09:38', percent: 100, color: '#e6a23c', module: '结算与利润' }
  ];

  const legacyMapping = [
    { source: 'CRM', table: 'crm_customer', target: 'md_customer', rows: 4826, matched: 4826, rule: 'customer_code → customer_code', dup: 2 },
    { source: 'PMT', table: 'pmt_project', target: 'md_project', rows: 1240, matched: 1240, rule: 'project_code → project_code', dup: 0 },
    { source: 'PMT', table: 'pmt_timesheet_item', target: 'fin_timesheet_item', rows: 386420, matched: 386420, rule: 'id → legacy_id', dup: 0 },
    { source: 'HR', table: 'hr_employee', target: 'md_employee', rows: 268, matched: 265, rule: 'employee_no → employee_no', dup: 3 },
    { source: 'FS', table: 'fs_budget_line', target: 'fin_budget_line', rows: 12840, matched: 12790, rule: 'budget_code → budget_code', dup: 0 },
    { source: 'CRM', table: 'crm_contract', target: 'md_contract', rows: 1972, matched: 1968, rule: 'contract_no → legacy_contract_no', dup: 4 }
  ];

  const severityList = [
    { level: 'danger', title: '中海物业智慧园区一期 · 成本超支', desc: 'EAC 252.0 万 > 预算 238.0 万，超支 5.9%，毛利率降至 16.5%', action: '查看项目', route: '/project/detail?id=PJ-2026-0014' },
    { level: 'danger', title: '应收账款逾期 31.4 万', desc: '中海物业 21.8 万逾期 18 天；国网信通 9.6 万逾期 46 天', action: '去催收', route: '/receivable' },
    { level: 'warning', title: '华润数科中台 · 关键路径延期风险', desc: 'T-0313 集成测试完成 55%，距 UAT 里程碑仅 15 天', action: '查看 WBS', route: '/wbs' },
    { level: 'warning', title: '吴磊 11 月利用率 100%', desc: '已分配 168h，无可用余量，新需求需调整资源', action: '资源池', route: '/resource' }
  ];

  const todos = [
    { type: '预算审批', title: '华润数科数字化中台 · 项目预算 V2.0', meta: '陈立 提交 · 财务审核', amount: '624.0 万', status: '待处理', route: '/approval' },
    { type: '合同变更', title: '补充协议二 · 上线日期顺延', meta: '陈立 提交 · 法务审核', amount: '-', status: '待处理', route: '/approval' },
    { type: '工时审批', title: '郑洁 · 2026-W45 工时单', meta: '38 小时 · 可计费 32h', amount: '38h', status: '待处理', route: '/timesheet' },
    { type: '费用报销', title: '项目会议费 · 深圳湾万丽酒店', meta: '陈立 提交', amount: '¥3,200', status: '待处理', route: '/approval' },
    { type: '应收催收', title: '中海物业 INV-2026-0261 逾期 18 天', meta: '¥218,000 · 已发第二次催款函', amount: '21.8 万', status: '跟进中', route: '/receivable' }
  ];

  const monthly = [
    { month: '2026-03', revenue: 0, cost: 96000 },
    { month: '2026-04', revenue: 2433962.26, cost: 412000 },
    { month: '2026-05', revenue: 0, cost: 486000 },
    { month: '2026-06', revenue: 1622641.51, cost: 528000 },
    { month: '2026-07', revenue: 0, cost: 502000 },
    { month: '2026-08', revenue: 0, cost: 546000 },
    { month: '2026-09', revenue: 0, cost: 588000 },
    { month: '2026-10', revenue: 1291415.09, cost: 918000 }
  ];

  /* ---------- 派生计算 ---------- */
  const sum = (arr, f) => arr.reduce((a, b) => a + (f ? f(b) : b), 0);
  const issued = invoices.filter(i => i.status === 'ISSUED');
  const revenue = sum(issued, i => i.excl);
  const cost = sum(costActuals, c => c.actual);
  const budget = sum(costActuals, c => c.budget);
  const fcast = sum(costActuals, c => c.forecast);
  const octSettle = sum(settlementBatches.filter(b => b.month === '2026-10' && b.type === 'CUSTOMER'), b => b.amount);

  const projInvoices = issued.filter(i => i.projectId === 'PJ-2026-0021');
  const projRevenue = sum(projInvoices, i => i.excl);
  const projIncl = sum(projInvoices, i => i.incl);

  const summary = {
    revenue: revenue,
    revenueIncl: sum(issued, i => i.incl),
    cost: cost,
    budget: budget,
    eac: fcast,
    etc: fcast - cost,
    profit: revenue - cost,
    margin: (revenue - cost) / revenue,
    budgetMargin: (8113207.55 - budget) / 8113207.55,
    forecastProfit: 8113207.55 - fcast,
    forecastMargin: (8113207.55 - fcast) / 8113207.55,
    ar: sum(arBalances, a => a.balance),
    overdue: sum(arBalances.filter(a => a.overdueDays > 0), a => a.balance),
    octSettle: octSettle,
    budgetHours: sum(budgetLines, l => l.hours),
    project: {
      revenue: projRevenue, incl: projIncl, cost: cost, budget: budget, eac: fcast,
      etc: fcast - cost, profit: projRevenue - cost, margin: (projRevenue - cost) / projRevenue,
      budgetMargin: (8113207.55 - budget) / 8113207.55,
      forecastProfit: 8113207.55 - fcast, forecastMargin: (8113207.55 - fcast) / 8113207.55,
      contract: 8113207.55
    }
  };

  return {
    user, orgs, customers, contacts, opportunities, follows,
    contracts, contractLines, contractMilestones, contractChanges,
    projects, phases, tasks, projectMilestones, budgetLines,
    employees, skills, employeeSkills, members,
    weekDays, timesheetItems, timesheets,
    settlements, settlementBatches, settlementOrders, settlementItems,
    invoices, receipts, arBalances,
    expenses, laborCosts, laborAllocations, costActuals, forecast,
    approvals, approvalNodes, integration, legacyMapping, severityList, todos, monthly,
    summary
  };
})();
