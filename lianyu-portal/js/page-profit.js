/* ================= 成本归集 / 项目利润 / 经营分析 ================= */
(function () {
  const LY = window.LY, M = LY.MOCK;
  const { icon, wan, money, pct, num, esc, tag, statusTag } = LY;
  const chart = (el, type, opt) => { if (!el) return; LY.chart[type](el, opt); LY.watchChart(el, type, opt); };
  const proj = id => M.projects.find(p => p.id === id) || M.projects[0];
  const octExpense = M.expenses.filter(e => ['APPROVED', 'PAID'].includes(e.status)).reduce((a, b) => a + b.amount, 0);
  const laborTotal = M.laborCosts.reduce((a, b) => a + b.total, 0);
  const allocTotal = M.laborAllocations.reduce((a, b) => a + b.cost, 0);
  const allocHours = M.laborAllocations.reduce((a, b) => a + b.hours, 0);

  /* ---------------- N11 成本归集 ---------------- */
  LY.register('/cost', {
    title: '成本归集', crumb: ['成本与利润', '成本归集'],
    render(root) {
      root.innerHTML = `
      <div class="page-head">
        <div class="page-head__l"><div class="page-title">成本归集 <span class="tag tag--primary">N11</span></div>
          <div class="page-sub">完整用工成本 · 按工时分摊 · 费用/采购分摊 · 成本自动生成 · EAC/ETC</div></div>
        <div class="page-actions">
          <select class="select" id="costPeriod" style="width:130px"><option>2026-10</option><option>2026-09</option><option>2026-08</option></select>
          <button class="btn" id="costRefresh">${icon('refresh', 14)}重新归集</button>
          <button class="btn btn--primary" id="costRun">${icon('activity', 14)}执行成本计算</button>
        </div>
      </div>
      <div class="kpi-grid">
        <div class="kpi"><div class="kpi-label">月度完整用工成本</div><div class="kpi-value">${wan(laborTotal)}</div><div class="kpi-foot">9 人 · 含社保/公积金/福利/分摊</div></div>
        <div class="kpi kpi--success"><div class="kpi-label">已分摊到项目</div><div class="kpi-value">${wan(allocTotal)}</div><div class="kpi-foot">分摊工时 ${num(allocHours)}h</div></div>
        <div class="kpi kpi--info"><div class="kpi-label">内部工时成本</div><div class="kpi-value">${wan(laborTotal - allocTotal)}</div><div class="kpi-foot">内部研发 / 管理 / 培训</div></div>
        <div class="kpi kpi--warning"><div class="kpi-label">费用与采购（已审批）</div><div class="kpi-value">${wan(octExpense)}</div><div class="kpi-foot">6 笔 · 含外包 18.0 万</div></div>
        <div class="kpi"><div class="kpi-label">项目实际成本（累计）</div><div class="kpi-value">407.6<small>万</small></div><div class="kpi-foot">预算执行率 65.3%</div></div>
        <div class="kpi kpi--danger"><div class="kpi-label">EAC / ETC</div><div class="kpi-value" style="font-size:19px">612.0 / 204.4<small>万</small></div><div class="kpi-foot">预测版本 F2026-10-V2</div></div>
      </div>
      <div class="panel" style="padding:0">
        <div class="tabs">
          <div class="tabs__item is-active" data-ctab="labor">完整用工成本</div>
          <div class="tabs__item" data-ctab="alloc">人力成本分摊</div>
          <div class="tabs__item" data-ctab="expense">费用 / 采购分摊</div>
          <div class="tabs__item" data-ctab="actual">成本实际</div>
          <div class="tabs__item" data-ctab="eac">EAC / ETC 预测</div>
        </div>
        <div class="panel-body" id="costTab"></div>
      </div>`;

      const tabs = {
        labor: () => `<div class="alert" style="margin-bottom:12px">${icon('info', 15)}<span>完整用工成本 = 基本工资 + 公司社保 + 公司公积金 + 奖金 + 福利 + 招聘分摊 + 培训分摊 + 其他；小时成本 = 月度成本 ÷ 可用工时。</span></div>
          <div class="table-wrap"><table class="table table--compact">
            <thead><tr><th>员工</th><th>组织</th><th class="num">基本工资</th><th class="num">公司社保</th><th class="num">公积金</th><th class="num">奖金</th><th class="num">福利</th><th class="num">招聘分摊</th><th class="num">培训分摊</th><th class="num">完整成本</th><th class="num">可用工时</th><th class="num">小时成本</th></tr></thead>
            <tbody>${M.laborCosts.map(l => `<tr>
              <td><div class="user-cell"><span class="avatar-sm">${l.name.slice(0, 1)}</span><span class="user-cell__n">${esc(l.name)}</span></div></td>
              <td class="text-muted">${esc(l.dept)}</td><td class="num">${money(l.base)}</td><td class="num">${money(l.social)}</td><td class="num">${money(l.fund)}</td>
              <td class="num">${money(l.bonus)}</td><td class="num">${money(l.benefit)}</td><td class="num">${money(l.recruit)}</td><td class="num">${money(l.training)}</td>
              <td class="num strong">${money(l.total)}</td><td class="num">${l.available}</td><td class="num">${money(l.hourly)}</td></tr>`).join('')}
              <tr class="row-total"><td colspan="9">合计</td><td class="num">${money(laborTotal)}</td><td class="num">1,504</td><td class="num">-</td></tr>
            </tbody></table></div>`,
        alloc: () => `<div class="alert" style="margin-bottom:12px">${icon('info', 15)}<span>分摊规则：按工时明细占比分摊月度完整用工成本；<b>分摊工时合计必须等于工时明细合计</b>（月度对账）。</span></div>
          <div class="grid grid--4" style="margin-bottom:12px">
            <div class="kpi"><div class="kpi-label">分摊工时</div><div class="kpi-value">${num(allocHours)}<small>h</small></div><div class="kpi-foot">对账差异 0h</div></div>
            <div class="kpi"><div class="kpi-label">分摊成本</div><div class="kpi-value">${wan(allocTotal)}</div><div class="kpi-foot">项目人工成本</div></div>
            <div class="kpi"><div class="kpi-label">平均小时成本</div><div class="kpi-value">${money(allocTotal / allocHours)}</div><div class="kpi-foot">可用工时口径</div></div>
            <div class="kpi"><div class="kpi-label">对账状态</div><div class="kpi-value" style="font-size:18px">已平衡</div><div class="kpi-foot">${tag('通过', 'success')} 2026-11-01</div></div>
          </div>
          <div class="table-wrap"><table class="table table--compact">
            <thead><tr><th>员工</th><th>归属项目</th><th>任务</th><th>工时类型</th><th>成本中心</th><th class="num">分摊工时</th><th class="num">分摊成本</th><th>分摊方式</th></tr></thead>
            <tbody>${M.laborAllocations.map(a => `<tr><td class="strong">${esc(a.name)}</td><td>${esc(a.project)}</td><td class="mono">${a.task || '-'}</td>
              <td>${statusTag('workType', a.workType)}</td><td>${esc(a.costCenter)}</td><td class="num">${a.hours}</td><td class="num strong">${money(a.cost)}</td><td class="text-muted">${esc(a.method)}</td></tr>`).join('')}
              <tr class="row-total"><td colspan="5">合计</td><td class="num">${num(allocHours)}</td><td class="num">${money(allocTotal)}</td><td></td></tr>
            </tbody></table></div>`,
        expense: () => `<div class="table-wrap"><table class="table">
            <thead><tr><th>费用单号</th><th>类型</th><th>申请人</th><th>收款方</th><th>归属项目 / 任务</th><th>成本中心</th><th class="num">金额（含税）</th><th class="num">税额</th><th>状态</th><th class="center">操作</th></tr></thead>
            <tbody>${M.expenses.map(e => `<tr><td class="mono">${e.id}</td><td>${tag(e.type, 'info')}</td><td>${esc(e.applicant)}</td><td>${esc(e.payee)}</td>
              <td>${esc(e.project)}<span class="sub">${e.task || '项目级'}</span></td><td>${esc(e.costCenter)}</td><td class="num strong">${money(e.amount)}</td><td class="num">${money(e.tax)}</td>
              <td>${statusTag('expense', e.status)}</td><td class="center"><button class="link-btn" onclick="LY.toast('费用分摊比例：项目 100%','info')">分摊</button></td></tr>`).join('')}
            </tbody></table></div>
          <div class="alert" style="margin-top:12px">${icon('info', 15)}<span>费用分摊：可直接归属项目的费用按 100% 归集；共享费用（如培训、招聘）按人天/人数分摊到项目与成本中心。</span></div>`,
        actual: () => `<div class="grid grid--2-1" style="align-items:start">
            <div class="panel panel--flat"><div class="panel-head"><h3>成本实际（按科目）</h3><span class="mini">数据来源：工时 / 费用 / 外包</span></div><div class="panel-body panel-body--flush">
              <table class="table table--compact"><thead><tr><th>科目</th><th class="num">预算</th><th class="num">实际</th><th class="num">执行率</th><th class="num">预测 EAC</th><th class="num">偏差</th></tr></thead>
              <tbody>${M.costActuals.map(c => `<tr><td class="strong">${c.subject}</td><td class="num">${money(c.budget)}</td><td class="num">${money(c.actual)}</td>
                <td class="num">${pct(c.actual / c.budget)}</td><td class="num">${money(c.forecast)}</td><td class="num ${c.forecast > c.budget ? 'text-danger' : 'text-success'}">${money(c.forecast - c.budget)}</td></tr>`).join('')}
                <tr class="row-total"><td>合计</td><td class="num">${money(6240000)}</td><td class="num">${money(4076000)}</td><td class="num">65.3%</td><td class="num">${money(6120000)}</td><td class="num">${money(-120000)}</td></tr>
              </tbody></table></div></div>
            <div class="panel panel--flat"><div class="panel-head"><h3>成本自动生成规则</h3></div><div class="panel-body" style="padding-top:6px">
              <div class="timeline">
                <div class="timeline__item is-done"><div class="timeline__title">工时锁定 → 人工成本</div><div class="timeline__meta">fin_timesheet_item → fin_labor_cost_allocation</div></div>
                <div class="timeline__item is-done"><div class="timeline__title">费用审批 → 费用成本</div><div class="timeline__meta">fin_expense → fin_cost_actual（source_type=EXPENSE）</div></div>
                <div class="timeline__item is-done"><div class="timeline__title">外包结算 → 采购成本</div><div class="timeline__meta">fin_settlement_order(SUPPLIER) → fin_cost_actual</div></div>
                <div class="timeline__item is-current"><div class="timeline__title">月度关账 → EAC 重算</div><div class="timeline__meta">每期间只允许一个 ACTIVE 预测版本</div></div>
              </div>
              <button class="btn btn--primary" style="width:100%;margin-top:8px" onclick="LY.toast('成本归集任务已执行：新增 12 条成本实际','success')">立即执行归集</button>
            </div></div>
          </div>`,
        eac: () => `<div class="grid grid--1-2">
            <div class="panel panel--flat"><div class="panel-head"><h3>EAC 预测参数</h3><span class="mini">${M.forecast.version}</span></div><div class="panel-body">
              <div class="form-grid">
                <div class="form-item"><label>预测方法</label><select class="select"><option>EFFORT（工时进度法）</option><option>COST（成本进度法）</option><option>PERCENT_COMPLETE（完工百分比）</option></select></div>
                <div class="form-item"><label>完工百分比</label><input class="input" value="62%"></div>
                <div class="form-item"><label>已发生成本（AC）</label><input class="input" value="4,076,000.00" readonly></div>
                <div class="form-item"><label>预计剩余成本（ETC）</label><input class="input" value="2,044,000.00"></div>
                <div class="form-item"><label>预计总成本（EAC）</label><input class="input" value="6,120,000.00" readonly></div>
                <div class="form-item"><label>预测版本</label><input class="input" value="F2026-10-V2" readonly></div>
              </div>
              <div class="alert alert--success">${icon('check-circle', 15)}<span>EAC 6,120,000.00 &lt; 预算 6,240,000.00，预计结余 120,000.00。</span></div>
              <div class="toolbar" style="margin-top:12px;justify-content:flex-end"><button class="btn">保存草稿</button><button class="btn btn--primary" onclick="LY.toast('预测版本已提交，等待财务确认')">提交预测</button></div>
            </div></div>
            <div class="panel panel--flat"><div class="panel-head"><h3>EAC 版本趋势</h3><span class="mini">单位：万元</span></div><div class="panel-body"><div id="eacChart"></div>
              <div class="table-wrap" style="margin-top:10px"><table class="table table--compact"><thead><tr><th>版本</th><th>期间</th><th class="num">AC</th><th class="num">ETC</th><th class="num">EAC</th><th>状态</th></tr></thead>
              <tbody>
                <tr><td class="mono">F2026-08-V1</td><td>2026-08</td><td class="num">3,120,000</td><td class="num">3,180,000</td><td class="num">6,300,000</td><td>${tag('历史', 'info')}</td></tr>
                <tr><td class="mono">F2026-09-V1</td><td>2026-09</td><td class="num">3,680,000</td><td class="num">2,520,000</td><td class="num">6,200,000</td><td>${tag('历史', 'info')}</td></tr>
                <tr><td class="mono">F2026-10-V2</td><td>2026-10</td><td class="num">4,076,000</td><td class="num">2,044,000</td><td class="num">6,120,000</td><td>${tag('当前', 'success')}</td></tr>
              </tbody></table></div>
            </div></div>
          </div>`
      };
      const host = root.querySelector('#costTab');
      const render = k => { host.innerHTML = tabs[k](); if (k === 'eac') chart(host.querySelector('#eacChart'), 'line', { categories: ['2026-06', '2026-07', '2026-08', '2026-09', '2026-10'], series: [{ name: 'EAC', data: [5980000, 6120000, 6300000, 6200000, 6120000], color: '#1d4ed8' }, { name: '预算', data: [6240000, 6240000, 6240000, 6240000, 6240000], color: '#c7d7f7' }], height: 210, fmt: v => LY.wan(v) }); };
      render('labor');
      root.querySelectorAll('[data-ctab]').forEach(t => t.addEventListener('click', () => {
        root.querySelectorAll('[data-ctab]').forEach(x => x.classList.remove('is-active'));
        t.classList.add('is-active'); render(t.dataset.ctab);
      }));
      root.querySelector('#costRun').addEventListener('click', () => {
        LY.openModal({
          title: '执行成本归集', width: 520,
          body: `<div class="alert">${icon('info', 15)}<span>将按 2026-10 期间执行：工时锁定检查 → 人工成本分摊 → 费用归集 → EAC 重算。</span></div>
            <div style="margin-top:14px"><label class="checkbox"><input type="checkbox" checked> 分摊人工成本（按工时）</label></div>
            <div style="margin-top:8px"><label class="checkbox"><input type="checkbox" checked> 归集已审批费用与外包结算</label></div>
            <div style="margin-top:8px"><label class="checkbox"><input type="checkbox" checked> 重算 EAC 并生成新版本</label></div>`,
          footer: `<button class="btn" data-close>取消</button><button class="btn btn--primary" onclick="LY.closeModal();LY.toast('归集完成：人工 12 条、费用 4 条，EAC 已更新','success')">执行</button>`
        });
      });
      root.querySelector('#costRefresh').addEventListener('click', () => LY.toast('已重新归集 2026-10 成本：人工 12 条、费用 4 条', 'success'));
      root.querySelector('#costPeriod').addEventListener('change', e => LY.toast('已切换期间：' + e.target.value, 'info'));
    }
  });

  /* ---------------- N12 项目利润 ---------------- */
  LY.register('/profit', {
    title: '项目利润', crumb: ['成本与利润', '项目利润'],
    render(root, query) {
      const p = proj(query.id);
      const ps = M.summary.project;
      const pnlRows = [
        ['一、营业收入', ps.revenue, 1],
        ['其中：合同收入（不含税）', ps.contract, 1],
        ['二、营业成本', ps.cost, 1],
        ['　人力成本', 2986000, 0], ['　采购 / 外包', 780000, 0], ['　差旅费用', 214000, 0], ['　其他费用', 96000, 0],
        ['三、项目毛利', ps.profit, 1],
        ['　毛利率', ps.margin, 2],
        ['四、预计总成本（EAC）', ps.eac, 1],
        ['五、预计毛利（EAC 口径）', ps.forecastProfit, 1],
        ['　预计毛利率', ps.forecastMargin, 2]
      ];
      root.innerHTML = `
      <div class="page-head">
        <div class="page-head__l"><div class="page-title">项目利润 <span class="tag tag--primary">N12</span></div><div class="page-sub">项目 P&amp;L · 毛利率 · 三算对比 · 收入确认口径：开票</div></div>
        <div class="page-actions">
          <select class="select" id="profitProj" style="width:250px">${M.projects.map(x => `<option value="${x.id}" ${x.id === p.id ? 'selected' : ''}>${esc(x.name)}</option>`).join('')}</select>
          <select class="select" style="width:110px"><option>2026-10</option><option>2026 年度</option></select>
          <button class="btn" id="profitExport">${icon('download', 14)}导出 P&amp;L</button>
        </div>
      </div>
      <div class="kpi-grid">
        <div class="kpi"><div class="kpi-label">合同额（不含税）</div><div class="kpi-value">${(ps.contract / 10000).toFixed(1)}<small>万</small></div><div class="kpi-foot">含税 860.0 万 · 税率 6%</div></div>
        <div class="kpi"><div class="kpi-label">已确认收入</div><div class="kpi-value">${(ps.revenue / 10000).toFixed(1)}<small>万</small></div><div class="kpi-foot">收入确认率 ${pct(ps.revenue / ps.contract)}</div></div>
        <div class="kpi kpi--warning"><div class="kpi-label">实际成本（AC）</div><div class="kpi-value">${(ps.cost / 10000).toFixed(1)}<small>万</small></div><div class="kpi-foot">人工占比 73.3%</div></div>
        <div class="kpi kpi--success"><div class="kpi-label">项目毛利</div><div class="kpi-value">${(ps.profit / 10000).toFixed(1)}<small>万</small></div><div class="kpi-foot">毛利率 ${pct(ps.margin)}</div></div>
        <div class="kpi kpi--info"><div class="kpi-label">EAC</div><div class="kpi-value">${(ps.eac / 10000).toFixed(1)}<small>万</small></div><div class="kpi-foot">ETC ${wan(ps.etc)}</div></div>
        <div class="kpi ${ps.forecastMargin < 0.28 ? 'kpi--danger' : 'kpi--success'}"><div class="kpi-label">预计毛利率</div><div class="kpi-value">${pct(ps.forecastMargin)}</div><div class="kpi-foot">目标 28.0% · 差 ${((0.28 - ps.forecastMargin) * 100).toFixed(1)}pt</div></div>
      </div>
      <div class="grid grid--2-1">
        <div class="panel"><div class="panel-head"><h3>${icon('trend', 16)}收入 / 成本 / 毛利趋势 <span class="sub">2026-03 ~ 2026-10</span></h3>
            <div class="legend-line"><span><i class="legend-dot" style="background:#1d4ed8"></i>确认收入</span><span><i class="legend-dot" style="background:#e6a23c"></i>实际成本</span></div></div>
          <div class="panel-body"><div id="profitTrend"></div></div></div>
        <div class="panel"><div class="panel-head"><h3>${icon('target', 16)}毛利率 vs 目标</h3></div><div class="panel-body" style="display:flex;flex-direction:column;align-items:center;gap:6px">
          <div id="marginRing"></div>
          <div style="width:100%;margin-top:6px">
            <div class="desc-grid desc-grid--2">
              <div class="desc-item"><span class="desc-label">预算毛利率</span><span class="desc-value">${pct(ps.budgetMargin)}</span></div>
              <div class="desc-item"><span class="desc-label">实际毛利率</span><span class="desc-value">${pct(ps.margin)}</span></div>
              <div class="desc-item"><span class="desc-label">预计毛利率</span><span class="desc-value">${pct(ps.forecastMargin)}</span></div>
              <div class="desc-item"><span class="desc-label">公司目标</span><span class="desc-value">28.0%</span></div>
            </div>
          </div>
        </div></div>
      </div>
      <div class="grid grid--1-2">
        <div class="panel"><div class="panel-head"><h3>${icon('file', 16)}项目利润表（P&amp;L）</h3><span class="mini">单位：元</span></div><div class="panel-body panel-body--flush">
          <table class="table table--compact"><tbody>
            ${pnlRows.map(([name, val, type]) => `<tr class="${name.startsWith('三、') || name.startsWith('五、') ? 'row-total' : ''}">
              <td style="${name.startsWith('　') ? 'padding-left:28px;color:#909399' : 'font-weight:' + (type === 1 ? 500 : 400)}">${name}</td>
              <td class="num ${type === 2 ? 'strong ' + (val < 0.28 ? 'text-danger' : 'text-success') : ''}">${type === 2 ? pct(val) : money(val)}</td>
            </tr>`).join('')}
          </tbody></table>
        </div></div>
        <div class="panel"><div class="panel-head"><h3>${icon('chart', 16)}三算对比（预算 / 实际 / 预测）</h3><span class="mini">单位：万元</span></div><div class="panel-body"><div id="profitThree"></div>
          <div class="table-wrap" style="margin-top:8px"><table class="table table--compact">
            <thead><tr><th>口径</th><th class="num">收入</th><th class="num">成本</th><th class="num">毛利</th><th class="num">毛利率</th></tr></thead>
            <tbody>
              <tr><td>预算（V2.0）</td><td class="num">811.3 万</td><td class="num">624.0 万</td><td class="num">187.3 万</td><td class="num">23.1%</td></tr>
              <tr><td>实际（截至 10 月）</td><td class="num">534.8 万</td><td class="num">407.6 万</td><td class="num">127.2 万</td><td class="num">23.8%</td></tr>
              <tr><td>预测（EAC）</td><td class="num">811.3 万</td><td class="num">612.0 万</td><td class="num">199.3 万</td><td class="num">24.6%</td></tr>
            </tbody></table></div>
        </div></div>
      </div>
      <div class="panel">
        <div class="panel-head"><h3>${icon('layers', 16)}项目组合利润排行</h3><button class="link-btn" onclick="LY.go('/analysis')">经营分析 →</button></div>
        <div class="panel-body panel-body--flush">
          <table class="table"><thead><tr><th>排名</th><th>项目</th><th>客户</th><th class="num">合同额</th><th class="num">合同收入（不含税）</th><th class="num">预计总成本（EAC）</th><th class="num">预计毛利</th><th class="num">预计毛利率</th><th class="center">健康度</th></tr></thead>
          <tbody>${M.projects.slice().sort((a, b) => b.margin - a.margin).slice(0, 6).map((x, i) => {
            const rev = x.contractAmount / 1.06;
            const profit = rev - x.eac;
            return `<tr style="cursor:pointer" onclick="LY.go('/project/detail?id=${x.id}&tab=pnl')">
              <td><span class="rank ${i < 3 ? 'rank--' + (i + 1) : ''}">${i + 1}</span></td>
              <td class="strong">${esc(x.name)}</td><td>${esc(x.customer)}</td>
              <td class="num">${wan(x.contractAmount)}</td><td class="num">${wan(rev)}</td><td class="num">${wan(x.eac)}</td>
              <td class="num ${profit < 0 ? 'text-danger' : ''}">${wan(profit)}</td>
              <td class="num ${x.margin < 0.2 ? 'text-danger' : 'text-success'}">${pct(x.margin)}</td>
              <td class="center">${statusTag('health', x.health)}</td></tr>`;
          }).join('')}</tbody></table>
        </div>
      </div>`;
      chart(root.querySelector('#profitTrend'), 'bar', {
        categories: M.monthly.map(m => m.month.slice(5) + '月'),
        series: [
          { name: '确认收入', data: M.monthly.map(m => m.revenue), color: '#1d4ed8' },
          { name: '实际成本', data: M.monthly.map(m => m.cost), color: '#e6a23c' }
        ], height: 240, fmt: v => LY.wan(v)
      });
      chart(root.querySelector('#profitThree'), 'bar', {
        categories: ['收入', '成本', '毛利'],
        series: [
          { name: '预算', data: [8113208, 6240000, 1873208], color: '#c7d7f7' },
          { name: '实际', data: [5348019, 4076000, 1272019], color: '#1d4ed8' },
          { name: '预测', data: [8113208, 6120000, 1993208], color: '#e6a23c' }
        ], height: 210, fmt: v => LY.wan(v)
      });
      LY.chart.ring(root.querySelector('#marginRing'), { value: ps.forecastMargin, label: '预计毛利率', color: ps.forecastMargin < 0.28 ? '#e6a23c' : '#1d4ed8', size: 118, thickness: 10 });
      root.querySelector('#profitProj').addEventListener('change', e => LY.go('/profit?id=' + e.target.value));
      root.querySelector('#profitExport').addEventListener('click', () => LY.toast('项目 P&L 已导出（xlsx）', 'info'));
    }
  });

  /* ---------------- N12 经营分析 ---------------- */
  LY.register('/analysis', {
    title: '经营分析', crumb: ['成本与利润', '经营分析'],
    render(root) {
      const customerRows = M.customers.filter(c => c.margin != null).map(c => {
        const revenue = c.contractAmount / 1.06;
        const profit = revenue * c.margin;
        return { ...c, revenue, profit, cost: revenue - profit };
      });
      const orgRows = [
        { name: '交付中心', headcount: 96, revenue: 48600000, labor: 26100000, utilization: 0.842 },
        { name: '技术中心', headcount: 84, revenue: 32400000, labor: 19800000, utilization: 0.796 },
        { name: '产品与设计中心', headcount: 32, revenue: 8600000, labor: 6200000, utilization: 0.724 },
        { name: '质量中心', headcount: 28, revenue: 5400000, labor: 4100000, utilization: 0.768 }
      ];
      const lines = [
        { name: '数据中台', revenue: 28600000, margin: 0.274 },
        { name: '智慧园区', revenue: 12400000, margin: 0.165 },
        { name: '数据资产', revenue: 9800000, margin: 0.214 },
        { name: '营销数字化', revenue: 6200000, margin: 0.261 },
        { name: '供应链协同', revenue: 7600000, margin: 0.259 },
        { name: '客户数据', revenue: 4200000, margin: 0.232 },
        { name: '运维与订阅', revenue: 26200000, margin: 0.32 }
      ];
      root.innerHTML = `
      <div class="page-head">
        <div class="page-head__l"><div class="page-title">经营分析 <span class="tag tag--primary">多维利润</span></div><div class="page-sub">项目 / 客户 / 组织 / 产品线四维利润与人效 · 2026 年度（截至 10-31）</div></div>
        <div class="page-actions">
          <div class="radio-group" id="anaDim"><button class="is-active" data-d="customer">客户维度</button><button data-d="org">组织维度</button><button data-d="line">产品线</button></div>
          <button class="btn" id="anaExport">${icon('download', 14)}导出分析报告</button>
        </div>
      </div>
      <div class="kpi-grid">
        <div class="kpi"><div class="kpi-label">客户数（有收入）</div><div class="kpi-value">42</div><div class="kpi-foot">A 类客户 8 · 新增 6</div></div>
        <div class="kpi kpi--success"><div class="kpi-label">平均客户毛利率</div><div class="kpi-value">24.8<small>%</small></div><div class="kpi-foot">目标 28% · 差距 3.2pt</div></div>
        <div class="kpi"><div class="kpi-label">人均收入</div><div class="kpi-value">39.6<small>万</small></div><div class="kpi-foot">240 名业务人员 · +6.2%</div></div>
        <div class="kpi"><div class="kpi-label">人均利润</div><div class="kpi-value">16.2<small>万</small></div><div class="kpi-foot">+2.8%</div></div>
        <div class="kpi kpi--warning"><div class="kpi-label">项目组合毛利率</div><div class="kpi-value">24.6<small>%</small></div><div class="kpi-foot">24 个在执行项目</div></div>
        <div class="kpi kpi--info"><div class="kpi-label">资源利用率</div><div class="kpi-value">81.4<small>%</small></div><div class="kpi-foot">可计费占比 68.2%</div></div>
      </div>

      <div class="grid grid--2-1">
        <div class="panel"><div class="panel-head"><h3>${icon('chart', 16)}收入与毛利趋势</h3><span class="mini">单位：万元</span></div><div class="panel-body"><div id="anaTrend"></div></div></div>
        <div class="panel"><div class="panel-head"><h3>${icon('pie', 16)}收入结构（产品线）</h3></div><div class="panel-body"><div id="anaDonut"></div></div></div>
      </div>

      <div class="panel">
        <div class="panel-head"><h3>${icon('users', 16)}客户毛利分析</h3><span class="mini">收入 = 合同额 / 1.06 · 成本含人工分摊</span></div>
        <div class="panel-body panel-body--flush">
          <div class="table-wrap"><table class="table">
            <thead><tr><th>客户</th><th>客户等级</th><th>负责人</th><th class="num">合同额</th><th class="num">确认收入</th><th class="num">成本</th><th class="num">毛利</th><th class="num">毛利率</th><th class="num">应收余额</th><th class="center">信用状态</th></tr></thead>
            <tbody>${customerRows.map(c => `<tr>
              <td class="strong">${esc(c.name)}</td><td>${tag(c.level + ' 类', c.level === 'A' ? 'primary' : 'info')}</td><td>${esc(c.owner)}</td>
              <td class="num">${wan(c.contractAmount)}</td><td class="num">${wan(c.revenue)}</td><td class="num">${wan(c.cost)}</td>
              <td class="num ${c.profit < 0 ? 'text-danger' : ''}">${wan(c.profit)}</td>
              <td class="num ${c.margin < 0.2 ? 'text-danger' : 'text-success'}">${pct(c.margin)}</td>
              <td class="num">${c.receivable ? wan(c.receivable) : '-'}</td>
              <td class="center">${c.overdue ? tag('有逾期', 'danger') : tag('正常', 'success')}</td></tr>`).join('')}
            </tbody></table></div>
        </div>
      </div>

      <div class="grid grid--2">
        <div class="panel"><div class="panel-head"><h3>${icon('building', 16)}组织人效</h3><span class="mini">人均收入 / 人均利润 / 利用率</span></div><div class="panel-body panel-body--flush">
          <table class="table table--compact"><thead><tr><th>组织</th><th class="num">人数</th><th class="num">收入</th><th class="num">人工成本</th><th class="num">人均收入</th><th class="num">人均利润</th><th class="num">利用率</th></tr></thead>
          <tbody>${orgRows.map(o => `<tr><td class="strong">${o.name}</td><td class="num">${o.headcount}</td><td class="num">${wan(o.revenue)}</td><td class="num">${wan(o.labor)}</td>
            <td class="num">${(o.revenue / o.headcount / 10000).toFixed(1)} 万</td><td class="num">${((o.revenue - o.labor) / o.headcount / 10000).toFixed(1)} 万</td>
            <td class="num"><span class="${o.utilization < 0.75 ? 'text-warning' : 'text-success'}">${pct(o.utilization)}</span></td></tr>`).join('')}</tbody></table>
        </div></div>
        <div class="panel"><div class="panel-head"><h3>${icon('layers', 16)}产品线毛利率</h3><span class="mini">按确认收入排序</span></div><div class="panel-body"><div id="anaLines"></div></div></div>
      </div>

      <div class="panel">
        <div class="panel-head"><h3>${icon('grid', 16)}多维利润汇总</h3><span class="mini">客户 / 组织 / 产品线 / 项目</span></div>
        <div class="panel-body panel-body--flush">
          <table class="table"><thead><tr><th>维度</th><th>对象</th><th class="num">收入</th><th class="num">成本</th><th class="num">毛利</th><th class="num">毛利率</th><th class="num">同比</th><th>结论</th></tr></thead>
          <tbody>
            <tr><td>${tag('客户', 'primary')}</td><td>华润数科集团</td><td class="num">811.3 万</td><td class="num">617.8 万</td><td class="num">193.5 万</td><td class="num text-success">23.8%</td><td class="num text-success">+1.2pt</td><td>核心客户，二期续约概率 70%</td></tr>
            <tr><td>${tag('客户', 'primary')}</td><td>中海物业</td><td class="num">301.9 万</td><td class="num">252.1 万</td><td class="num">49.8 万</td><td class="num text-danger">16.5%</td><td class="num text-danger">-6.0pt</td><td>成本超支，需重谈结算单价</td></tr>
            <tr><td>${tag('组织', 'success')}</td><td>交付中心</td><td class="num">4,860.0 万</td><td class="num">3,712.0 万</td><td class="num">1,148.0 万</td><td class="num">23.6%</td><td class="num text-success">+0.8pt</td><td>人效最高，利用率 84.2%</td></tr>
            <tr><td>${tag('产品线', 'warning')}</td><td>数据中台</td><td class="num">2,860.0 万</td><td class="num">2,076.4 万</td><td class="num">783.6 万</td><td class="num text-success">27.4%</td><td class="num text-success">+2.1pt</td><td>标准化程度提升，毛利改善</td></tr>
            <tr><td>${tag('产品线', 'warning')}</td><td>智慧园区</td><td class="num">1,240.0 万</td><td class="num">1,035.4 万</td><td class="num">204.6 万</td><td class="num text-danger">16.5%</td><td class="num text-danger">-5.1pt</td><td>定制化高，需产品化改造</td></tr>
          </tbody></table>
        </div>
      </div>`;
      chart(root.querySelector('#anaTrend'), 'line', {
        categories: M.monthly.map(m => m.month.slice(5) + '月'),
        series: [
          { name: '收入', data: [186, 412, 528, 466, 502, 546, 588, 610], color: '#1d4ed8' },
          { name: '毛利', data: [42, 96, 128, 112, 124, 138, 148, 152], color: '#67c23a' }
        ], height: 230, area: true, fmt: v => v + ' 万'
      });
      chart(root.querySelector('#anaDonut'), 'donut', {
        data: lines.map((l, i) => ({ name: l.name, value: l.revenue, color: LY.PALETTE[i % 6] })),
        centerValue: '9,500', centerLabel: '总收入（万）', height: 230, thickness: 22
      });
      chart(root.querySelector('#anaLines'), 'hbar', {
        data: lines.map(l => ({ name: l.name, value: Math.round(l.margin * 1000) / 10, color: l.margin < 0.2 ? '#f56c6c' : '#1d4ed8' })),
        height: 220, fmt: v => v + '%', labelWidth: 88
      });
      root.querySelector('#anaExport').addEventListener('click', () => LY.toast('经营分析报告已导出（PDF）', 'info'));
      root.querySelectorAll('#anaDim button').forEach(b => b.addEventListener('click', () => {
        root.querySelectorAll('#anaDim button').forEach(x => x.classList.remove('is-active'));
        b.classList.add('is-active');
        LY.toast('已切换维度：' + ({ customer: '客户维度', org: '组织维度', line: '产品线' })[b.dataset.d], 'info');
      }));
    }
  });
})();
