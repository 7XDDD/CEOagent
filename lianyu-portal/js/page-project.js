/* ================= 项目：列表 / 驾驶舱 / WBS / 预算 ================= */
(function () {
  const LY = window.LY, M = LY.MOCK;
  const { icon, wan, money, pct, num, esc, tag, statusTag } = LY;
  const chart = (el, type, opt) => { if (!el) return; LY.chart[type](el, opt); LY.watchChart(el, type, opt); };
  const proj = id => M.projects.find(p => p.id === id) || M.projects[0];

  /* ---------------- 项目列表 ---------------- */
  LY.register('/project', {
    title: '项目列表', crumb: ['项目交付', '项目列表'],
    render(root) {
      const state = { kw: '', customer: '', status: '', health: '', page: 1, size: 8 };
      const draw = () => {
        let list = M.projects.filter(p =>
          (!state.kw || p.name.includes(state.kw) || p.id.includes(state.kw)) &&
          (!state.customer || p.customer === state.customer) &&
          (!state.status || p.status === state.status) &&
          (!state.health || p.health === state.health));
        const total = list.length;
        const rows = list.slice((state.page - 1) * state.size, state.page * state.size);
        root.querySelector('#pjtBody').innerHTML = rows.length ? rows.map(p => `
          <tr data-id="${p.id}" style="cursor:pointer">
            <td><div class="strong">${esc(p.name)}</div><span class="sub">${p.id} · ${esc(p.contractId || '-')}</span></td>
            <td>${esc(p.customer)}</td>
            <td><div class="user-cell"><span class="avatar-sm">${p.pm.slice(0, 1)}</span><span class="user-cell__n">${esc(p.pm)}</span></div></td>
            <td>${statusTag('project', p.status)}</td>
            <td><div class="progress-row"><div class="progress"><div class="progress__bar ${p.percent >= 80 ? 'progress__bar--success' : p.percent < 30 ? 'progress__bar--warning' : ''}" style="width:${p.percent}%"></div></div><span>${p.percent}%</span></div></td>
            <td class="num">${wan(p.contractAmount)}</td>
            <td class="num">${wan(p.actual)}<span class="sub">预算 ${wan(p.budget)}</span></td>
            <td class="num ${p.margin < 0.2 ? 'text-danger' : ''}">${pct(p.margin)}<span class="sub">EAC ${wan(p.eac)}</span></td>
            <td class="center">${statusTag('health', p.health)}</td>
            <td class="center"><button class="link-btn" data-open="${p.id}">驾驶舱</button><button class="link-btn" data-wbs="${p.id}">WBS</button></td>
          </tr>`).join('') : `<tr><td colspan="10"><div class="empty">${icon('folder', 40)}没有符合条件的项目</div></td></tr>`;
        root.querySelector('#pjtTotal').textContent = `共 ${total} 个项目`;
        root.querySelector('#pjtPager').innerHTML = pagerHtml(total, state.page, state.size);
        root.querySelectorAll('#pjtBody tr[data-id]').forEach(tr => {
          tr.addEventListener('click', e => {
            if (e.target.closest('[data-wbs]')) { LY.go('/wbs?id=' + e.target.closest('[data-wbs]').dataset.wbs); return; }
            LY.go('/project/detail?id=' + tr.dataset.id);
          });
        });
        root.querySelectorAll('#pjtPager .pager__btn[data-p]').forEach(b => b.addEventListener('click', () => { state.page = +b.dataset.p; draw(); }));
      };
      root.innerHTML = `
      <div class="page-head">
        <div class="page-head__l"><div class="page-title">项目列表</div><div class="page-sub">统一项目主数据（PMT 主数据 · CRM/FS 只读）· 共 ${M.projects.length} 个 · 在执行 24 个</div></div>
        <div class="page-actions">
          <button class="btn" id="pjtExport">${icon('download', 14)}导出</button>
          <button class="btn btn--primary" id="pjtNew">${icon('plus', 14)}合同转立项</button>
        </div>
      </div>
      <div class="filter-bar">
        <div class="field"><span class="field-label">项目</span><input class="input" id="fKw" placeholder="项目名称 / 编码" style="width:190px"></div>
        <div class="field"><span class="field-label">客户</span><select class="select" id="fCus" style="width:140px"><option value="">全部</option>${[...new Set(M.projects.map(p => p.customer))].map(c => `<option>${c}</option>`).join('')}</select></div>
        <div class="field"><span class="field-label">项目状态</span><select class="select" id="fStatus" style="width:120px"><option value="">全部</option><option value="PREPARING">准备中</option><option value="IN_PROGRESS">进行中</option><option value="PAUSED">已暂停</option><option value="COMPLETED">已完成</option></select></div>
        <div class="field"><span class="field-label">健康度</span><select class="select" id="fHealth" style="width:110px"><option value="">全部</option><option>正常</option><option>风险</option><option>预警</option><option>待立项</option></select></div>
        <div class="field"><button class="btn btn--primary" id="fSearch">${icon('search', 14)}查询</button><button class="btn" id="fReset">重置</button></div>
      </div>
      <div class="panel">
        <div class="panel-head"><h3>${icon('layers', 16)}项目台账</h3><div class="toolbar__r"><span class="mini" id="pjtTotal"></span></div></div>
        <div class="panel-body panel-body--flush">
          <div class="table-wrap"><table class="table">
            <thead><tr><th>项目名称 / 编码</th><th>客户</th><th>项目经理</th><th>状态</th><th style="width:140px">进度</th><th class="num">合同额</th><th class="num">实际成本</th><th class="num">预计毛利率</th><th class="center">健康度</th><th class="center">操作</th></tr></thead>
            <tbody id="pjtBody"></tbody>
          </table></div>
        </div>
        <div class="panel-foot"><span class="mini">成本含人工分摊（按工时分摊）、费用与外包；EAC 取最新预测版本 F2026-10-V2</span><div class="pager" id="pjtPager"></div></div>
      </div>`;
      const bind = () => {
        state.kw = root.querySelector('#fKw').value.trim();
        state.customer = root.querySelector('#fCus').value;
        state.status = root.querySelector('#fStatus').value;
        state.health = root.querySelector('#fHealth').value;
        state.page = 1; draw();
      };
      root.querySelector('#fSearch').addEventListener('click', bind);
      root.querySelector('#fKw').addEventListener('keyup', e => { if (e.key === 'Enter') bind(); });
      root.querySelector('#fReset').addEventListener('click', () => {
        root.querySelector('#fKw').value = ''; root.querySelector('#fCus').value = '';
        root.querySelector('#fStatus').value = ''; root.querySelector('#fHealth').value = ''; bind();
      });
      root.querySelector('#pjtExport').addEventListener('click', () => LY.toast('项目台账已导出（xlsx）', 'info'));
      root.querySelector('#pjtNew').addEventListener('click', () => {
        LY.openModal({
          title: '合同转立项', width: 680,
          body: `<div class="alert">${icon('info', 15)}<span>立项将自动带入合同客户、合同金额与交付周期，并触发「立项审批」流程（PMO → COO）。</span></div>
          <div class="form-grid" style="margin-top:14px">
            <div class="form-item"><label>来源合同 <span class="text-danger">*</span></label><select class="select"><option>CT-2026-0074 中国邮政客户数据平台建设合同</option><option>CT-2026-0088 华润数科数字化中台二期框架协议</option></select></div>
            <div class="form-item"><label>项目名称 <span class="text-danger">*</span></label><input class="input" value="中国邮政客户数据平台实施项目"></div>
            <div class="form-item"><label>项目经理 <span class="text-danger">*</span></label><select class="select"><option>张伟</option><option>陈立</option><option>王强</option></select></div>
            <div class="form-item"><label>归属组织</label><input class="input" value="技术中心" readonly></div>
            <div class="form-item"><label>计划开始</label><input class="input" type="date" value="2026-12-01"></div>
            <div class="form-item"><label>计划结束</label><input class="input" type="date" value="2027-11-30"></div>
            <div class="form-item" style="grid-column:1/-1"><label>合同金额（自动带入）</label><input class="input" value="¥6,200,000.00" readonly></div>
          </div>`,
          footer: `<button class="btn" data-close>取消</button><button class="btn btn--primary" id="okPj">提交立项审批</button>`,
          onMount(m) { m.querySelector('#okPj').addEventListener('click', () => { LY.closeModal(); LY.toast('立项申请已提交，审批单号 AP-2026-1026'); }); }
        });
      });
      draw();
    }
  });

  function pagerHtml(total, page, size) {
    const pages = Math.max(1, Math.ceil(total / size));
    let html = '';
    for (let i = 1; i <= pages; i++) html += `<button class="pager__btn ${i === page ? 'is-active' : ''}" data-p="${i}">${i}</button>`;
    return `<span class="total">共 ${total} 条</span><button class="pager__btn" data-p="${page - 1}" ${page <= 1 ? 'disabled' : ''}>上一页</button>${html}<button class="pager__btn" data-p="${page + 1}" ${page >= pages ? 'disabled' : ''}>下一页</button>`;
  }
  LY.pagerHtml = pagerHtml;

  /* ---------------- 项目驾驶舱 ---------------- */
  const TABS = [
    { key: 'overview', name: '概览', icon: 'home' },
    { key: 'wbs', name: '阶段与WBS', icon: 'list' },
    { key: 'milestone', name: '交付里程碑', icon: 'flag' },
    { key: 'budget', name: '预算', icon: 'coins' },
    { key: 'members', name: '成员', icon: 'users' },
    { key: 'timesheet', name: '工时', icon: 'clock' },
    { key: 'settlement', name: '结算', icon: 'receipt' },
    { key: 'cost', name: '成本', icon: 'chart' },
    { key: 'pnl', name: '利润', icon: 'trend' }
  ];

  LY.register('/project/detail', {
    title: '项目驾驶舱',
    titleFor: q => proj(q.id).name,
    crumb: ['项目交付', '项目列表', '项目驾驶舱'],
    render(root, query) {
      const p = proj(query.id);
      const tab = query.tab || 'overview';
      const goTab = k => LY.go(`/project/detail?id=${p.id}&tab=${k}`);

      root.innerHTML = `
      <div class="page-head">
        <div class="page-head__l">
          <div class="page-title">${esc(p.name)} ${statusTag('project', p.status)} ${statusTag('health', p.health)}</div>
          <div class="page-sub">${p.id} · 客户：${esc(p.customer)} · 主合同：${esc(p.contractId)} · PM：${esc(p.pm)} · ${p.start} ~ ${p.end}</div>
        </div>
        <div class="page-actions">
          <button class="btn" id="pdReport">${icon('download', 14)}项目报告</button>
          <button class="btn" id="pdEdit">${icon('edit', 14)}编辑</button>
          <button class="btn btn--primary" id="pdApproval">${icon('send', 14)}提交审批</button>
        </div>
      </div>

      <div class="kpi-grid">
        <div class="kpi"><div class="kpi-label">合同金额（含税）</div><div class="kpi-value">${(p.contractAmount / 10000).toFixed(0)}<small>万</small></div><div class="kpi-foot">不含税 ${wan(p.contractAmount / 1.06)}</div></div>
        <div class="kpi"><div class="kpi-label">项目预算</div><div class="kpi-value">${(p.budget / 10000).toFixed(1)}<small>万</small></div><div class="kpi-foot">预算工时 12,800h · V2.0</div></div>
        <div class="kpi kpi--warning"><div class="kpi-label">实际成本（AC）</div><div class="kpi-value">${(p.actual / 10000).toFixed(1)}<small>万</small></div><div class="kpi-foot">占预算 ${pct(p.actual / p.budget)}</div></div>
        <div class="kpi kpi--info"><div class="kpi-label">预计总成本（EAC）</div><div class="kpi-value">${(p.eac / 10000).toFixed(1)}<small>万</small></div><div class="kpi-foot">ETC ${wan(p.eac - p.actual)} · 低于预算 ${wan(p.budget - p.eac)}</div></div>
        <div class="kpi kpi--success"><div class="kpi-label">预计毛利率</div><div class="kpi-value">${pct(p.margin)}</div><div class="kpi-foot">预算口径 23.1% · 目标 28%</div></div>
        <div class="kpi"><div class="kpi-label">完工进度</div><div class="kpi-value">${p.percent}<small>%</small></div><div class="kpi-foot">按工时进度法（EFFORT）</div></div>
      </div>

      <div class="panel" style="padding:0">
        <div class="tabs">
          ${TABS.map(t => `<div class="tabs__item ${t.key === tab ? 'is-active' : ''}" data-tab="${t.key}">${t.name}</div>`).join('')}
        </div>
        <div class="panel-body" id="pdTab" style="padding:14px"></div>
      </div>`;

      root.querySelectorAll('[data-tab]').forEach(el => el.addEventListener('click', () => goTab(el.dataset.tab)));
      root.querySelector('#pdReport').addEventListener('click', () => LY.toast('项目经营报告已生成（PDF）', 'info'));
      root.querySelector('#pdEdit').addEventListener('click', () => LY.toast('已进入编辑模式（原型演示）', 'info'));
      root.querySelector('#pdApproval').addEventListener('click', () => LY.openModal({
        title: '提交审批', width: 480,
        body: `<div class="form-item"><label>审批类型</label><select class="select"><option>项目预算 V2.1 变更</option><option>项目立项</option><option>项目结项</option></select></div>
        <div class="form-item"><label>审批说明</label><textarea class="textarea" placeholder="请说明变更原因与影响"></textarea></div>
        <div class="alert alert--warning">${icon('alert', 15)}<span>提交后将进入「部门负责人 → 财务 → COO」审批流。</span></div>`,
        footer: `<button class="btn" data-close>取消</button><button class="btn btn--primary" id="okPd">提交</button>`,
        onMount(m) { m.querySelector('#okPd').addEventListener('click', () => { LY.closeModal(); LY.toast('已提交审批，单号 AP-2026-1027'); }); }
      }));

      const host = root.querySelector('#pdTab');
      host.innerHTML = renderTab(p, tab);
      mountTab(host, p, tab);
    }
  });

  function renderTab(p, tab) {
    if (tab === 'overview') {
      return `<div class="grid grid--1-2">
        <div style="display:flex;flex-direction:column;gap:12px">
          <div class="panel panel--flat"><div class="panel-head"><h3>项目基本信息</h3></div><div class="panel-body" style="padding-top:4px">
            <div class="desc-grid desc-grid--2">
              <div class="desc-item"><span class="desc-label">项目编码</span><span class="desc-value mono">${p.id}</span></div>
              <div class="desc-item"><span class="desc-label">客户</span><span class="desc-value">${esc(p.customer)}</span></div>
              <div class="desc-item"><span class="desc-label">主合同</span><span class="desc-value"><a class="text-primary" href="#/contract/detail?id=${p.contractId}" style="cursor:pointer">${esc(p.contractId)}</a></span></div>
              <div class="desc-item"><span class="desc-label">项目经理</span><span class="desc-value">${esc(p.pm)}</span></div>
              <div class="desc-item"><span class="desc-label">归属组织</span><span class="desc-value">${esc(p.org)}</span></div>
              <div class="desc-item"><span class="desc-label">产品线</span><span class="desc-value">数据中台</span></div>
              <div class="desc-item"><span class="desc-label">计划周期</span><span class="desc-value">${p.start} ~ ${p.end}</span></div>
              <div class="desc-item"><span class="desc-label">合同工期</span><span class="desc-value">281 天（剩余 51 天）</span></div>
              <div class="desc-item full"><span class="desc-label">风险说明</span><span class="desc-value text-warning">${esc(p.risk)}；集成测试较计划滞后 8 天，需关注 UAT 里程碑。</span></div>
            </div>
          </div></div>
          <div class="panel panel--flat"><div class="panel-head"><h3>交付里程碑</h3><button class="link-btn" onclick="LY.go('/project/detail?id=${p.id}&tab=milestone')">全部</button></div><div class="panel-body" style="padding-top:8px">
            <div class="timeline">
              ${M.projectMilestones.map(ms => `<div class="timeline__item ${ms.status === 'COMPLETED' ? 'is-done' : ms.status === 'IN_PROGRESS' ? 'is-current' : ''}">
                <div class="timeline__title">${esc(ms.name)} ${ms.status === 'IN_PROGRESS' ? tag('进行中', 'primary') : ms.status === 'COMPLETED' ? tag('已达成', 'success') : tag('未开始', 'info')}</div>
                <div class="timeline__meta">计划 ${ms.plan}${ms.actual ? ' · 实际 ' + ms.actual : ''} · 负责人 ${esc(ms.owner)}</div>
              </div>`).join('')}
            </div>
          </div></div>
        </div>
        <div style="display:flex;flex-direction:column;gap:12px">
          <div class="panel panel--flat"><div class="panel-head"><h3>成本构成（实际）</h3><span class="mini">AC ${wan(p.actual)}</span></div><div class="panel-body"><div id="pdCostDonut"></div></div></div>
          <div class="panel panel--flat"><div class="panel-head"><h3>预算执行</h3><span class="mini">预算 ${wan(p.budget)}</span></div><div class="panel-body">
            ${M.costActuals.map(c => `<div style="margin-bottom:12px">
              <div style="display:flex;justify-content:space-between;font-size:12px;margin-bottom:5px"><span>${c.subject}</span><span><b class="num">${wan(c.actual)}</b> <span class="text-muted">/ ${wan(c.budget)}</span></span></div>
              <div class="progress"><div class="progress__bar ${c.actual / c.budget > 0.85 ? 'progress__bar--warning' : ''}" style="width:${Math.min(c.actual / c.budget * 100, 100)}%"></div></div>
            </div>`).join('')}
          </div></div>
        </div>
      </div>`;
    }
    if (tab === 'wbs') {
      return `<div class="toolbar" style="margin-bottom:10px"><div class="toolbar__l">
          <span class="mini">5 个阶段 · 18 个任务 · 计划 9,956h / 实际 9,152h</span></div>
        <div class="toolbar__r"><button class="btn btn--sm" onclick="LY.go('/wbs?id=${p.id}')">${icon('external', 13)}打开甘特图</button><button class="btn btn--sm btn--primary" id="addTask">${icon('plus', 13)}新增任务</button></div></div>
        <div class="table-wrap"><table class="table table--compact">
          <thead><tr><th style="width:70px">WBS</th><th>任务名称</th><th>阶段</th><th>负责人</th><th class="num">计划工时</th><th class="num">实际工时</th><th class="num">偏差</th><th style="width:130px">进度</th><th>状态</th></tr></thead>
          <tbody>${M.tasks.map(t => {
            const ph = M.phases.find(x => x.id === t.phase);
            const gap = t.actual - t.planned;
            return `<tr><td class="mono">${t.code}</td><td class="strong">${esc(t.name)}</td><td class="text-muted">${ph ? ph.name : '-'}</td><td>${esc(t.assignee)}</td>
              <td class="num">${num(t.planned)}</td><td class="num">${num(t.actual)}</td>
              <td class="num ${gap > 0 ? 'text-danger' : 'text-success'}">${gap > 0 ? '+' : ''}${num(gap)}</td>
              <td><div class="progress-row"><div class="progress"><div class="progress__bar ${t.percent === 100 ? 'progress__bar--success' : ''}" style="width:${t.percent}%"></div></div><span>${t.percent}%</span></div></td>
              <td>${statusTag('task', t.status)}</td></tr>`;
          }).join('')}</tbody>
        </table></div>`;
    }
    if (tab === 'milestone') {
      return `<div class="alert">${icon('info', 15)}<span>「交付里程碑」= 事（验收/交付物），与合同「收款里程碑」= 钱 分表管理，可建立可选关联。</span></div>
      <div class="table-wrap"><table class="table">
        <thead><tr><th>编码</th><th>交付里程碑</th><th>类型</th><th>计划日期</th><th>实际日期</th><th>关联收款里程碑</th><th>交付物</th><th>负责人</th><th>状态</th><th class="center">操作</th></tr></thead>
        <tbody>${M.projectMilestones.map(ms => `<tr>
          <td class="mono">${ms.code}</td><td class="strong">${esc(ms.name)}</td><td>${tag(ms.type, 'info')}</td><td>${ms.plan}</td><td>${ms.actual || '-'}</td>
          <td>${ms.contractMilestone ? tag(ms.contractMilestone, 'primary') : '-'}</td>
          <td>${ms.doc ? `<a class="link-btn" style="padding:0" onclick="LY.toast('预览附件：${esc(ms.doc)}','info')">${esc(ms.doc)}</a>` : '<span class="text-muted">待上传</span>'}</td>
          <td>${esc(ms.owner)}</td><td>${ms.status === 'COMPLETED' ? tag('已达成', 'success') : ms.status === 'IN_PROGRESS' ? tag('进行中', 'primary') : tag('未开始', 'info')}</td>
          <td class="center"><button class="link-btn" onclick="LY.toast('已打开交付物上传','info')">上传交付物</button></td></tr>`).join('')}</tbody>
      </table></div>`;
    }
    if (tab === 'budget') {
      const total = M.budgetLines.reduce((a, b) => a + b.amount, 0);
      const hours = M.budgetLines.reduce((a, b) => a + b.hours, 0);
      return `<div class="grid grid--4" style="margin-bottom:12px">
        <div class="kpi"><div class="kpi-label">预算版本</div><div class="kpi-value" style="font-size:18px">V2.0</div><div class="kpi-foot">${tag('已审批', 'success')} 2026-10-28</div></div>
        <div class="kpi"><div class="kpi-label">预算总额</div><div class="kpi-value">${(total / 10000).toFixed(0)}<small>万</small></div><div class="kpi-foot">含税合同额 860 万</div></div>
        <div class="kpi"><div class="kpi-label">预算工时</div><div class="kpi-value">${num(hours)}<small>h</small></div><div class="kpi-foot">人工单价均值 ¥337.5/h</div></div>
        <div class="kpi kpi--warning"><div class="kpi-label">年度预算占用</div><div class="kpi-value">18.3<small>%</small></div><div class="kpi-foot">年度预算 3,410 万 · 软校验通过</div></div>
      </div>
      <div class="toolbar" style="margin-bottom:8px"><div class="toolbar__l"><b style="font-size:14px">预算明细（按阶段 / 科目）</b></div>
        <div class="toolbar__r"><button class="btn btn--sm" id="bpExport">导出</button><button class="btn btn--sm btn--primary" id="bpSubmit">提交预算审批</button></div></div>
      <div class="table-wrap"><table class="table table--compact">
        <thead><tr><th>科目</th><th>阶段</th><th class="num">预算工时</th><th class="num">预算金额</th><th class="num">占比</th><th class="num">已发生</th><th class="num">执行率</th><th>年度预算约束</th></tr></thead>
        <tbody>${M.budgetLines.map(l => {
          const actual = l.subject === '人力成本' ? 2986000 * (l.amount / 4320000) : l.subject === '采购成本' ? 780000 : l.subject === '差旅费用' ? 214000 : 96000;
          return `<tr><td class="strong">${l.subject}</td><td>${l.phase}</td><td class="num">${l.hours ? num(l.hours) : '-'}</td><td class="num">${money(l.amount)}</td>
            <td class="num">${pct(l.amount / total)}</td><td class="num">${money(actual)}</td><td class="num ${actual / l.amount > 0.85 ? 'text-warning' : ''}">${pct(actual / l.amount)}</td>
            <td><span class="tag tag--success">未超限</span></td></tr>`;
        }).join('')}
        <tr class="row-total"><td colspan="2">合计</td><td class="num">${num(hours)}</td><td class="num">${money(total)}</td><td class="num">100.0%</td><td class="num">${money(4076000)}</td><td class="num">65.3%</td><td></td></tr>
        </tbody></table></div>
      <div class="alert alert--warning" style="margin-top:12px">${icon('alert', 15)}<span><b>人工预算校验：</b>预算工时 12,800h × 平均成本单价 ¥337.5/h = ¥4,320,000，与人力成本预算一致。</span></div>`;
    }
    if (tab === 'members') {
      const totalPlanned = M.members.reduce((a, b) => a + b.planned, 0);
      return `<div class="toolbar" style="margin-bottom:10px"><div class="toolbar__l"><span class="mini">9 名成员 · 计划投入 ${num(totalPlanned)}h · 可结算 8 人</span></div>
        <div class="toolbar__r"><button class="btn btn--sm" onclick="LY.go('/resource')">${icon('users', 13)}资源匹配</button><button class="btn btn--sm btn--primary" id="addMember">${icon('plus', 13)}添加成员</button></div></div>
      <div class="table-wrap"><table class="table">
        <thead><tr><th>成员</th><th>项目角色</th><th>工时性质</th><th>投入期间</th><th class="num">投入比例</th><th class="num">计划工时</th><th class="num">成本单价/天</th><th class="num">结算单价/天</th><th>状态</th><th class="center">操作</th></tr></thead>
        <tbody>${M.members.map(m => `<tr>
          <td><div class="user-cell"><span class="avatar-sm">${m.name.slice(0, 1)}</span><div><div class="user-cell__n">${esc(m.name)}</div><div class="user-cell__d">${m.employeeId}</div></div></div></td>
          <td>${esc(m.role)}</td><td>${statusTag('nature', m.nature)}</td><td class="text-muted" style="font-size:12px">${m.start} ~ ${m.end}</td>
          <td class="num">${(m.ratio * 100).toFixed(0)}%</td><td class="num">${num(m.planned)}</td><td class="num">${money(m.costDay)}</td><td class="num">${m.billDay ? money(m.billDay) : '-'}</td>
          <td>${m.status === '有效' ? tag('有效', 'success') : tag('已离场', 'info')}</td>
          <td class="center"><button class="link-btn" onclick="LY.toast('成员期间配置（原型演示）','info')">期间</button></td></tr>`).join('')}</tbody>
      </table></div>
      <div class="alert" style="margin-top:12px">${icon('info', 15)}<span>只有 <b>work_nature = SETTLE</b> 的成员工时才可进入结算；投入比例合计按人校验 ≤ 100%。</span></div>`;
    }
    if (tab === 'timesheet') {
      const total = M.timesheetItems.reduce((a, b) => a + b.hours, 0);
      const bill = M.timesheetItems.filter(i => i.billable).reduce((a, b) => a + b.hours, 0);
      return `<div class="grid grid--4" style="margin-bottom:12px">
        <div class="kpi"><div class="kpi-label">本周总工时</div><div class="kpi-value">${total}<small>h</small></div><div class="kpi-foot">可用 40h · 产能 100%</div></div>
        <div class="kpi kpi--success"><div class="kpi-label">可计费工时</div><div class="kpi-value">${bill}<small>h</small></div><div class="kpi-foot">可计费占比 ${pct(bill / total)}</div></div>
        <div class="kpi kpi--info"><div class="kpi-label">内部工时</div><div class="kpi-value">${total - bill}<small>h</small></div><div class="kpi-foot">内部管理 / 培训</div></div>
        <div class="kpi"><div class="kpi-label">工时状态</div><div class="kpi-value" style="font-size:18px">草稿</div><div class="kpi-foot">提交后进入 PM 审批</div></div>
      </div>
      <div class="table-wrap"><table class="table table--compact">
        <thead><tr><th>日期</th><th>项目 / 任务</th><th>工时类型</th><th>成本中心</th><th class="num">工时</th><th>可计费</th><th>工作内容</th></tr></thead>
        <tbody>${M.timesheetItems.map(i => {
          const t = M.tasks.find(x => x.id === i.taskId);
          return `<tr><td>${i.date}</td><td><div class="strong" style="font-size:13px">${t ? esc(t.name) : '内部事务'}</div><span class="sub">${i.taskId}</span></td>
            <td>${statusTag('workType', i.workType)}</td><td>${esc(i.costCenter)}</td><td class="num">${i.hours}</td>
            <td>${i.billable ? tag('是', 'success') : tag('否', 'info')}</td><td class="text-muted" style="font-size:12px">${esc(i.content)}</td></tr>`;
        }).join('')}</tbody></table></div>`;
    }
    if (tab === 'settlement') {
      const orders = M.settlementOrders;
      return `<div class="table-wrap"><table class="table">
        <thead><tr><th>结算单号</th><th>成员</th><th>角色</th><th class="num">结算天数</th><th class="num">结算单价</th><th class="num">结算金额</th><th>状态</th><th>关联发票</th></tr></thead>
        <tbody>${orders.map(o => `<tr><td class="mono">${o.id}</td><td>${esc(o.employee)}</td><td>${esc(o.role)}</td><td class="num">${o.days}</td><td class="num">${money(o.price)}</td><td class="num strong">${money(o.amount)}</td>
          <td>${statusTag('settlement', o.status)}</td><td>${o.invoiceId ? tag(o.invoiceId, 'primary') : '<span class="text-muted">-</span>'}</td></tr>`).join('')}
          <tr class="row-total"><td colspan="5">合计</td><td class="num">${money(orders.reduce((a, b) => a + b.amount, 0))}</td><td colspan="2"></td></tr>
        </tbody></table></div>
      <div class="alert" style="margin-top:12px">${icon('info', 15)}<span>结算资格：工时已锁定 + 未结算 + 成员 SETTLE；金额 = 结算天数 × 结算单价（md_billing_rate）。</span></div>`;
    }
    if (tab === 'cost') {
      return `<div class="grid grid--2" style="margin-bottom:12px">
        <div class="panel panel--flat"><div class="panel-head"><h3>成本归集（按科目）</h3><span class="mini">AC ${wan(p.actual)}</span></div><div class="panel-body"><div id="pdCostBar"></div></div></div>
        <div class="panel panel--flat"><div class="panel-head"><h3>EAC / ETC 预测</h3><span class="mini">${M.forecast.version}</span></div><div class="panel-body">
          <div class="desc-grid desc-grid--2">
            <div class="desc-item"><span class="desc-label">已发生成本</span><span class="desc-value money">${money(p.actual)}</span></div>
            <div class="desc-item"><span class="desc-label">ETC</span><span class="desc-value money">${money(p.eac - p.actual)}</span></div>
            <div class="desc-item"><span class="desc-label">EAC</span><span class="desc-value money">${money(p.eac)}</span></div>
            <div class="desc-item"><span class="desc-label">预算</span><span class="desc-value money">${money(p.budget)}</span></div>
            <div class="desc-item"><span class="desc-label">完工百分比</span><span class="desc-value">${p.percent}%（工时法）</span></div>
            <div class="desc-item"><span class="desc-label">预测方法</span><span class="desc-value">${M.forecast.method}</span></div>
          </div>
          <div class="alert ${p.eac > p.budget ? 'alert--danger' : 'alert--success'}" style="margin-top:10px">${icon(p.eac > p.budget ? 'alert' : 'check-circle', 15)}<span>EAC ${money(p.eac)} ${p.eac > p.budget ? '高于' : '低于'}预算 ${money(Math.abs(p.budget - p.eac))}，预计毛利率 ${pct(p.margin)}。</span></div>
        </div></div>
      </div>
      <div class="table-wrap"><table class="table table--compact">
        <thead><tr><th>成本科目</th><th>类型</th><th class="num">预算</th><th class="num">实际</th><th class="num">预测(EAC)</th><th class="num">预算偏差</th><th class="num">预测偏差</th></tr></thead>
        <tbody>${M.costActuals.map(c => `<tr><td class="strong">${c.subject}</td><td>${c.type}</td><td class="num">${money(c.budget)}</td><td class="num">${money(c.actual)}</td><td class="num">${money(c.forecast)}</td>
          <td class="num ${c.actual > c.budget ? 'text-danger' : 'text-success'}">${money(c.actual - c.budget)}</td>
          <td class="num ${c.forecast > c.budget ? 'text-danger' : 'text-success'}">${money(c.forecast - c.budget)}</td></tr>`).join('')}
          <tr class="row-total"><td colspan="2">合计</td><td class="num">${money(p.budget)}</td><td class="num">${money(p.actual)}</td><td class="num">${money(p.eac)}</td><td class="num">${money(p.actual - p.budget)}</td><td class="num">${money(p.eac - p.budget)}</td></tr></tbody>
      </table></div>`;
    }
    // pnl
    const ps = M.summary.project;
    return `<div class="grid grid--1-2">
      <div class="panel panel--flat"><div class="panel-head"><h3>项目 P&amp;L</h3><span class="mini">开票口径</span></div><div class="panel-body" style="padding-top:6px">
        <table class="table table--compact">
          <tbody>
            <tr><td>合同收入（不含税）</td><td class="num strong">${money(ps.contract)}</td></tr>
            <tr><td>已确认收入</td><td class="num strong">${money(ps.revenue)}</td></tr>
            <tr><td style="padding-left:24px" class="text-muted">— 人力成本</td><td class="num">${money(2986000)}</td></tr>
            <tr><td style="padding-left:24px" class="text-muted">— 采购 / 外包</td><td class="num">${money(780000)}</td></tr>
            <tr><td style="padding-left:24px" class="text-muted">— 差旅费用</td><td class="num">${money(214000)}</td></tr>
            <tr><td style="padding-left:24px" class="text-muted">— 其他费用</td><td class="num">${money(96000)}</td></tr>
            <tr class="row-total"><td>项目毛利</td><td class="num">${money(ps.profit)}</td></tr>
            <tr><td>项目毛利率</td><td class="num text-success strong">${pct(ps.margin)}</td></tr>
            <tr><td>预计总收入（EAC 口径）</td><td class="num">${money(ps.contract)}</td></tr>
            <tr><td>预计总成本（EAC）</td><td class="num">${money(ps.eac)}</td></tr>
            <tr class="row-total"><td>预计毛利</td><td class="num">${money(ps.forecastProfit)}</td></tr>
            <tr><td>预计毛利率</td><td class="num strong">${pct(ps.forecastMargin)}</td></tr>
          </tbody></table>
      </div></div>
      <div class="panel panel--flat"><div class="panel-head"><h3>三算对比（预算 / 实际 / 预测）</h3><span class="mini">单位：万元</span></div><div class="panel-body"><div id="pdThree"></div></div></div>
    </div>`;
  }

  function mountTab(host, p, tab) {
    if (tab === 'overview') {
      chart(host.querySelector('#pdCostDonut'), 'donut', {
        data: M.costActuals.map(c => ({ name: c.subject, value: c.actual, color: c.color })),
        centerValue: (p.actual / 10000).toFixed(0) + '万', centerLabel: '实际成本', height: 200, thickness: 20, legend: true
      });
    }
    if (tab === 'cost') {
      chart(host.querySelector('#pdCostBar'), 'bar', {
        categories: M.costActuals.map(c => c.subject.replace('采购/外包', '外包')),
        series: [
          { name: '预算', data: M.costActuals.map(c => c.budget), color: '#c7d7f7' },
          { name: '实际', data: M.costActuals.map(c => c.actual), color: '#1d4ed8' },
          { name: '预测 EAC', data: M.costActuals.map(c => c.forecast), color: '#e6a23c' }
        ], height: 220, fmt: v => LY.wan(v)
      });
    }
    if (tab === 'pnl') {
      chart(host.querySelector('#pdThree'), 'bar', {
        categories: ['人力', '外包', '差旅', '其他'],
        series: [
          { name: '预算', data: [4320000, 1120000, 380000, 420000], color: '#c7d7f7' },
          { name: '实际', data: [2986000, 780000, 214000, 96000], color: '#1d4ed8' },
          { name: '预测', data: [4460000, 1120000, 340000, 200000], color: '#e6a23c' }
        ], height: 260, fmt: v => LY.wan(v)
      });
    }
    const addTaskBtn = host.querySelector('#addTask');
    if (addTaskBtn) addTaskBtn.addEventListener('click', () => LY.toast('新增任务已打开（原型演示）', 'info'));
    const addMemberBtn = host.querySelector('#addMember');
    if (addMemberBtn) addMemberBtn.addEventListener('click', () => LY.toast('请从资源池选择成员并配置期间', 'info'));
    const bp = host.querySelector('#bpSubmit');
    if (bp) bp.addEventListener('click', () => LY.openModal({
      title: '提交预算审批', width: 520,
      body: `<div class="alert">${icon('info', 15)}<span>预算 V2.0 合计 ¥6,240,000，将进入「部门负责人 → 财务 → COO」审批流。</span></div>
      <div class="form-item" style="margin-top:14px"><label>审批说明</label><textarea class="textarea">按阶段/任务重编预算，人工预算按成本单价×工时计算。</textarea></div>`,
      footer: `<button class="btn" data-close>取消</button><button class="btn btn--primary" onclick="LY.closeModal();LY.toast('预算审批已提交，单号 AP-2026-1022')">提交审批</button>`
    }));
    const be = host.querySelector('#bpExport');
    if (be) be.addEventListener('click', () => LY.toast('预算明细已导出', 'info'));
  }

  /* ---------------- WBS 与甘特 ---------------- */
  LY.register('/wbs', {
    title: '阶段与 WBS', crumb: ['项目交付', '阶段与 WBS'],
    render(root, query) {
      const p = proj(query.id);
      const months = ['3月', '4月', '5月', '6月', '7月', '8月', '9月', '10月', '11月', '12月', '1月', '2月', '3月'];
      const startAll = new Date('2026-03-01').getTime(), endAll = new Date('2027-03-31').getTime();
      const left = d => Math.max(0, (new Date(d).getTime() - startAll) / (endAll - startAll) * 100);
      const width = (a, b) => Math.max(1.5, (new Date(b).getTime() - new Date(a).getTime()) / (endAll - startAll) * 100);

      const rows = [];
      M.phases.forEach(ph => {
        rows.push(`<div class="gantt-row" style="background:#fafbfc">
          <div class="gantt-label" style="font-weight:600;color:var(--ly-text)">${icon('layers', 13)}${esc(ph.name)}</div>
          <div class="gantt-track"><div class="gantt-bar" style="left:${left(ph.start)}%;width:${width(ph.start, ph.end)}%;background:#dbe7fb;color:#1e3a8a">${ph.percent}%</div></div>
        </div>`);
        M.tasks.filter(t => t.phase === ph.id).forEach(t => {
          rows.push(`<div class="gantt-row">
            <div class="gantt-label" style="padding-left:26px"><span class="mono" style="color:#909399">${t.code}</span>${esc(t.name)}</div>
            <div class="gantt-track"><div class="gantt-bar ${t.status === 'COMPLETED' ? 'gantt-bar--done' : t.actual > t.planned ? 'gantt-bar--warn' : ''}" style="left:${left(t.start)}%;width:${width(t.start, t.end)}%" title="${esc(t.name)}">${t.percent}%</div></div>
          </div>`);
        });
      });
      root.innerHTML = `
      <div class="page-head">
        <div class="page-head__l"><div class="page-title">阶段与 WBS · 交付里程碑</div><div class="page-sub">${esc(p.name)} · ${p.id} · 5 个阶段 / 18 个任务 · 计划工时 9,956h</div></div>
        <div class="page-actions">
          <select class="select" id="wbsProj" style="width:250px">${M.projects.map(x => `<option value="${x.id}" ${x.id === p.id ? 'selected' : ''}>${esc(x.name)}</option>`).join('')}</select>
          <button class="btn" id="wbsExport">${icon('download', 14)}导出 WBS</button>
          <button class="btn btn--primary" id="wbsAdd">${icon('plus', 14)}新增任务</button>
        </div>
      </div>
      <div class="kpi-grid">
        <div class="kpi"><div class="kpi-label">阶段数</div><div class="kpi-value">5</div><div class="kpi-foot">2 个已完成 · 2 个进行中</div></div>
        <div class="kpi"><div class="kpi-label">任务数</div><div class="kpi-value">18</div><div class="kpi-foot">已完成 7 · 进行中 6 · 未开始 5</div></div>
        <div class="kpi"><div class="kpi-label">计划工时</div><div class="kpi-value">9,956<small>h</small></div><div class="kpi-foot">占预算工时 77.8%</div></div>
        <div class="kpi kpi--warning"><div class="kpi-label">实际工时</div><div class="kpi-value">9,152<small>h</small></div><div class="kpi-foot">较计划 -804h · 已完成任务超支 386h</div></div>
        <div class="kpi"><div class="kpi-label">交付里程碑</div><div class="kpi-value">5</div><div class="kpi-foot">已达成 2 · 进行中 1</div></div>
        <div class="kpi kpi--danger"><div class="kpi-label">关键路径风险</div><div class="kpi-value" style="font-size:18px">UAT 滞后</div><div class="kpi-foot">T-0313 完成 55%</div></div>
      </div>
      <div class="panel">
        <div class="panel-head"><h3>${icon('calendar', 16)}项目甘特图 <span class="sub">2026-03 ~ 2027-03</span></h3>
          <div class="legend-line"><span><i class="legend-dot" style="background:#bfd3fb"></i>进行中</span><span><i class="legend-dot" style="background:#c8e9b7"></i>已完成</span><span><i class="legend-dot" style="background:#f8ddb5"></i>工时超计划</span></div>
        </div>
        <div class="panel-body panel-body--flush" style="padding:12px">
          <div class="gantt"><div class="gantt-inner">
            <div class="gantt-head"><div class="gantt-label">阶段 / 任务</div><div class="gantt-months">${months.map(m => `<span>${m}</span>`).join('')}</div></div>
            ${rows.join('')}
          </div></div>
        </div>
      </div>
      <div class="grid grid--2">
        <div class="panel"><div class="panel-head"><h3>${icon('list', 16)}任务明细</h3><span class="mini">WBS 树形结构</span></div><div class="panel-body panel-body--flush">
          <div class="table-wrap"><table class="table table--compact">
            <thead><tr><th>WBS</th><th>任务</th><th>负责人</th><th class="num">计划</th><th class="num">实际</th><th>状态</th></tr></thead>
            <tbody>${M.tasks.map(t => `<tr><td class="mono">${t.code}</td><td>${esc(t.name)}</td><td>${esc(t.assignee)}</td><td class="num">${t.planned}h</td><td class="num ${t.actual > t.planned ? 'text-danger' : ''}">${t.actual}h</td><td>${statusTag('task', t.status)}</td></tr>`).join('')}</tbody>
          </table></div>
        </div></div>
        <div class="panel"><div class="panel-head"><h3>${icon('flag', 16)}交付里程碑与交付物</h3></div><div class="panel-body">
          ${M.projectMilestones.map(ms => `<div style="display:flex;gap:10px;padding:10px 0;border-bottom:1px dashed #f0f2f5">
            <div style="color:${ms.status === 'COMPLETED' ? 'var(--ly-success)' : ms.status === 'IN_PROGRESS' ? 'var(--ly-primary)' : '#c0c4cc'};margin-top:1px">${icon(ms.status === 'COMPLETED' ? 'check-circle' : 'flag', 16)}</div>
            <div style="flex:1"><div style="font-size:13px;font-weight:500">${esc(ms.name)} <span class="mini">· ${ms.plan}</span></div>
              <div class="mini" style="margin-top:2px">${ms.doc ? esc(ms.doc) : '暂无交付物'} · ${esc(ms.owner)}</div></div>
            <div>${ms.status === 'COMPLETED' ? tag('已达成', 'success') : ms.status === 'IN_PROGRESS' ? tag('进行中', 'primary') : tag('未开始', 'info')}</div>
          </div>`).join('')}
        </div></div>
      </div>`;
      root.querySelector('#wbsExport').addEventListener('click', () => LY.toast('WBS 与甘特图已导出（xlsx）', 'info'));
      root.querySelector('#wbsProj').addEventListener('change', e => LY.go('/wbs?id=' + e.target.value));
      root.querySelector('#wbsAdd').addEventListener('click', () => LY.openModal({
        title: '新增 WBS 任务', width: 620,
        body: `<div class="form-grid">
          <div class="form-item"><label>所属阶段</label><select class="select">${M.phases.map(ph => `<option>${ph.name}</option>`).join('')}</select></div>
          <div class="form-item"><label>任务名称 <span class="text-danger">*</span></label><input class="input" placeholder="请输入任务名称"></div>
          <div class="form-item"><label>负责人</label><select class="select">${M.employees.map(e => `<option>${e.name} · ${e.role}</option>`).join('')}</select></div>
          <div class="form-item"><label>计划工时（h）</label><input class="input" placeholder="0"></div>
          <div class="form-item"><label>计划开始</label><input class="input" type="date"></div>
          <div class="form-item"><label>计划结束</label><input class="input" type="date"></div>
          <div class="form-item" style="grid-column:1/-1"><label>关联交付里程碑</label><select class="select"><option>不关联</option>${M.projectMilestones.map(m => `<option>${m.name}</option>`).join('')}</select></div>
        </div>`,
        footer: `<button class="btn" data-close>取消</button><button class="btn btn--primary" onclick="LY.closeModal();LY.toast('任务已创建，并同步至 WBS 与工时填报任务池')">创建</button>`
      }));
    }
  });

  /* ---------------- 项目预算 ---------------- */
  LY.register('/budget', {
    title: '项目预算', crumb: ['项目交付', '项目预算'],
    render(root, query) {
      const p = proj(query.id);
      const total = M.budgetLines.reduce((a, b) => a + b.amount, 0);
      const hours = M.budgetLines.reduce((a, b) => a + b.hours, 0);
      root.innerHTML = `
      <div class="page-head">
        <div class="page-head__l"><div class="page-title">项目预算与审批</div><div class="page-sub">统一预算口径：人力 + 采购 + 费用 + 外包 · 按阶段/任务/期间 · 版本 V2.0</div></div>
        <div class="page-actions">
          <select class="select" id="bgtProj" style="width:250px">${M.projects.map(x => `<option value="${x.id}" ${x.id === p.id ? 'selected' : ''}>${esc(x.name)}</option>`).join('')}</select>
          <button class="btn" id="bgtNewVer">${icon('copy', 14)}新建版本</button>
          <button class="btn btn--primary" id="bgtApprove">${icon('send', 14)}提交审批</button>
        </div>
      </div>
      <div class="grid grid--4">
        <div class="kpi"><div class="kpi-label">预算总额</div><div class="kpi-value">${(total / 10000).toFixed(0)}<small>万</small></div><div class="kpi-foot">V2.0 · 已审批</div></div>
        <div class="kpi"><div class="kpi-label">人力预算</div><div class="kpi-value">432.0<small>万</small></div><div class="kpi-foot">${num(hours)}h × ¥337.5/h</div></div>
        <div class="kpi kpi--warning"><div class="kpi-label">已发生成本</div><div class="kpi-value">407.6<small>万</small></div><div class="kpi-foot">执行率 65.3%</div></div>
        <div class="kpi kpi--success"><div class="kpi-label">剩余预算</div><div class="kpi-value">216.4<small>万</small></div><div class="kpi-foot">EAC 612.0 万 · 结余 12.0 万</div></div>
      </div>
      <div class="grid grid--2-1">
        <div class="panel">
          <div class="panel-head"><h3>${icon('coins', 16)}预算明细（按阶段 / 科目）</h3>
            <div class="toolbar__r"><button class="btn btn--sm" id="bgtAdd">${icon('plus', 13)}新增行</button><button class="btn btn--sm" id="bgtExport">${icon('download', 13)}导出</button></div></div>
          <div class="panel-body panel-body--flush">
            <div class="table-wrap"><table class="table table--compact">
              <thead><tr><th>科目</th><th>阶段</th><th class="num">预算工时</th><th class="num">预算金额</th><th class="num">占比</th><th class="num">已发生</th><th class="num">执行率</th></tr></thead>
              <tbody>${M.budgetLines.map(l => {
                const actual = l.subject === '人力成本' ? 2986000 * (l.amount / 4320000) : l.subject === '采购成本' ? 780000 : l.subject === '差旅费用' ? 214000 : 96000;
                return `<tr><td class="strong">${l.subject}</td><td>${l.phase}</td><td class="num">${l.hours ? num(l.hours) : '-'}</td><td class="num">${money(l.amount)}</td>
                  <td class="num">${pct(l.amount / total)}</td><td class="num">${money(actual)}</td>
                  <td class="num ${actual / l.amount > 0.85 ? 'text-warning' : ''}">${pct(actual / l.amount)}</td></tr>`;
              }).join('')}
              <tr class="row-total"><td colspan="2">合计</td><td class="num">${num(hours)}</td><td class="num">${money(total)}</td><td class="num">100.0%</td><td class="num">${money(4076000)}</td><td class="num">65.3%</td></tr>
              </tbody></table></div>
          </div>
          <div class="panel-foot"><span class="mini">行合计 = 头合计；预算工时与 WBS 计划工时软校验</span><span class="tag tag--success">校验通过</span></div>
        </div>
        <div style="display:flex;flex-direction:column;gap:12px">
          <div class="panel"><div class="panel-head"><h3>${icon('check-circle', 16)}审批进度</h3></div><div class="panel-body">
            <div class="timeline">
              <div class="timeline__item is-done"><div class="timeline__title">项目经理提交</div><div class="timeline__meta">陈立 · 2026-11-05 09:40</div></div>
              <div class="timeline__item is-done"><div class="timeline__title">部门负责人审批</div><div class="timeline__meta">王海 · 2026-11-05 15:12 · 同意</div></div>
              <div class="timeline__item is-current"><div class="timeline__title">财务审核 ${tag('进行中', 'primary')}</div><div class="timeline__meta">刘芳 · 待处理</div></div>
              <div class="timeline__item"><div class="timeline__title">COO 审批</div><div class="timeline__meta">赵总 · 等待中</div></div>
            </div>
            <button class="btn btn--primary" style="width:100%;margin-top:8px" onclick="LY.toast('已提醒审批人：刘芳','info')">催办</button>
          </div></div>
          <div class="panel"><div class="panel-head"><h3>${icon('shield', 16)}年度预算约束</h3></div><div class="panel-body">
            <div class="desc-grid desc-grid--2">
              <div class="desc-item"><span class="desc-label">年度预算</span><span class="desc-value money">34,100,000.00</span></div>
              <div class="desc-item"><span class="desc-label">已占用</span><span class="desc-value money">6,240,000.00</span></div>
              <div class="desc-item"><span class="desc-label">占用比例</span><span class="desc-value">18.3%</span></div>
              <div class="desc-item"><span class="desc-label">口径</span><span class="desc-value">FS 年度预算 · 软校验</span></div>
            </div>
            <div class="alert alert--success" style="margin-top:10px">${icon('check-circle', 15)}<span>项目预算未超年度预算，无需额外说明。</span></div>
          </div></div>
        </div>
      </div>
      <div class="panel">
        <div class="panel-head"><h3>${icon('chart', 16)}人工预算测算</h3><span class="mini">预算工时 × 成本单价（md_cost_rate）</span></div>
        <div class="panel-body">
          <div class="table-wrap"><table class="table table--compact">
            <thead><tr><th>角色</th><th class="num">预算工时</th><th class="num">成本单价/天</th><th class="num">小时成本</th><th class="num">人工预算</th><th>来源</th></tr></thead>
            <tbody>${[
              ['项目经理', 960, 2400], ['架构师', 1440, 2600], ['前端工程师', 1600, 1800],
              ['后端工程师', 1760, 2200], ['测试工程师', 1200, 1600], ['实施顾问', 1280, 2000]
            ].map(([r, h, c]) => `<tr><td class="strong">${r}</td><td class="num">${num(h)}</td><td class="num">${money(c)}</td><td class="num">${money(c / 8)}</td><td class="num strong">${money(h * c / 8)}</td><td class="text-muted">md_cost_rate（2026 年度）</td></tr>`).join('')}
              <tr class="row-total"><td>合计</td><td class="num">8,240</td><td class="num">-</td><td class="num">-</td><td class="num">2,605,000.00</td><td>剩余工时待分配</td></tr>
            </tbody></table></div>
        </div>
      </div>`;
      root.querySelector('#bgtNewVer').addEventListener('click', () => LY.toast('已创建预算版本 V2.1（草稿），可复制 V2.0 明细', 'info'));
      root.querySelector('#bgtAdd').addEventListener('click', () => LY.toast('已新增预算行，请选择科目与阶段', 'info'));
      root.querySelector('#bgtExport').addEventListener('click', () => LY.toast('预算明细已导出（xlsx）', 'info'));
      root.querySelector('#bgtProj').addEventListener('change', e => LY.go('/budget?id=' + e.target.value));
      root.querySelector('#bgtApprove').addEventListener('click', () => LY.toast('预算审批已提交，单号 AP-2026-1022'));
    }
  });
})();
