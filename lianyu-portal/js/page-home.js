/* ================= 经营工作台 ================= */
(function () {
  const LY = window.LY, M = LY.MOCK;
  const { icon, wan, money, pct, num, esc, tag, statusTag } = LY;
  const chart = (el, type, opt) => { if (!el) return; LY.chart[type](el, opt); LY.watchChart(el, type, opt); };

  const KPIS = [
    { label: '年度签约额', value: '8,640', unit: '万元', trend: '+18.6%', dir: 'up', foot: '目标 9,000 万 · 达成 96.0%', cls: '' },
    { label: '在执行项目', value: '24', unit: '个', trend: '+3', dir: 'up', foot: '正常 19 · 关注 4 · 风险 1', cls: 'kpi--info' },
    { label: '本月结算额', value: (M.summary.octSettle / 10000).toFixed(1), unit: '万元', trend: '-6.2%', dir: 'down', foot: '3 个批次待确认 · 5 张结算单', cls: 'kpi--warning' },
    { label: '应收账款余额', value: (M.summary.ar / 10000).toFixed(1), unit: '万元', trend: `逾期 ${(M.summary.overdue / 10000).toFixed(1)} 万`, dir: 'down', foot: '2 张发票逾期 · 最长 46 天', cls: 'kpi--danger' },
    { label: '综合毛利率', value: '28.1', unit: '%', trend: '+0.9pt', dir: 'up', foot: '预算口径 26.8% · 目标 28%', cls: 'kpi--success' },
    { label: '资源利用率', value: '81.4', unit: '%', trend: '-2.3pt', dir: 'down', foot: '12 人资源池 · 2 人满负荷', cls: 'kpi--info' }
  ];

  const FUNNEL = [
    { stage: '商机', count: 26, amount: 38600, rate: 100, route: '/opportunity', color: '#93b4f7' },
    { stage: '签约合同', count: 18, amount: 29160, rate: 75.6, route: '/contract', color: '#6d96f0' },
    { stage: '立项项目', count: 16, amount: 27400, rate: 71.0, route: '/project', color: '#3b82f6' },
    { stage: '已结算', count: 12, amount: 18620, rate: 48.2, route: '/settlement', color: '#2563eb' },
    { stage: '已开票', count: 9, amount: 13240, rate: 34.3, route: '/invoice', color: '#1d4ed8' },
    { stage: '已回款', count: 7, amount: 10860, rate: 28.1, route: '/receivable', color: '#1e3a8a' }
  ];

  const NODES = [
    { n: 'N1', name: '客户/商机', route: '/customer', icon: 'users' },
    { n: 'N2', name: '合同签订', route: '/contract', icon: 'file' },
    { n: 'N3', name: '立项/项目', route: '/project', icon: 'layers' },
    { n: 'N4', name: 'WBS/交付', route: '/wbs', icon: 'list' },
    { n: 'N5', name: '项目预算', route: '/budget', icon: 'coins' },
    { n: 'N6', name: '人员配置', route: '/resource', icon: 'users' },
    { n: 'N7', name: '工时', route: '/timesheet', icon: 'clock' },
    { n: 'N8', name: '结算', route: '/settlement', icon: 'coins' },
    { n: 'N9', name: '开票', route: '/invoice', icon: 'receipt' },
    { n: 'N10', name: '回款/应收', route: '/receivable', icon: 'wallet' },
    { n: 'N11', name: '成本归集', route: '/cost', icon: 'chart' },
    { n: 'N12', name: '项目利润', route: '/profit', icon: 'trend' }
  ];

  LY.register('/home', {
    title: '经营工作台',
    crumb: ['经营工作台'],
    render(root) {
      root.innerHTML = `
      <div class="page-head">
        <div class="page-head__l">
          <div class="page-title">经营工作台 <span class="tag tag--primary">链路 1 · 客户签约到项目交付</span></div>
          <div class="page-sub">数据截至 2026-11-10 09:45 · 口径：统一主数据（CRM / PMT / HR / FS 融合）· 当前组织：交付中心</div>
        </div>
        <div class="page-actions">
          <div class="radio-group" id="homeRange">
            <button class="is-active" data-r="year">本年度</button>
            <button data-r="quarter">本季度</button>
            <button data-r="month">本月</button>
          </div>
          <button class="btn" id="homeExport">${icon('download', 14)}导出经营简报</button>
          <button class="btn btn--primary" id="homeNew">${icon('plus', 14)}新建商机</button>
        </div>
      </div>

      <div class="kpi-grid">
        ${KPIS.map(k => `<div class="kpi ${k.cls}">
          <div class="kpi-label">${esc(k.label)}</div>
          <div class="kpi-value">${k.value}<small>${k.unit}</small></div>
          <div class="kpi-foot"><span class="kpi-trend ${k.dir}">${k.trend}</span><span>${esc(k.foot)}</span></div>
        </div>`).join('')}
      </div>

      <div class="panel">
        <div class="panel-head">
          <h3>${icon('target', 16)}链路 1 转化漏斗 <span class="sub">商机 → 合同 → 项目 → 结算 → 开票 → 回款</span></h3>
          <div class="legend-line"><span>金额单位：万元</span><span class="text-muted">整体转化率 28.1%</span></div>
        </div>
        <div class="panel-body" style="padding:14px 16px">
          <div class="funnel-grid">
            ${FUNNEL.map((f, i) => `
              <div style="cursor:pointer" data-jump="${f.route}">
                <div style="display:flex;align-items:baseline;justify-content:space-between;margin-bottom:6px">
                  <span style="font-size:12px;color:var(--ly-text-regular)">${f.stage}</span>
                  <span style="font-size:11px;color:var(--ly-text-secondary)">${f.count} 个</span>
                </div>
                <div style="height:26px;background:#f5f7fa;border-radius:3px;overflow:hidden">
                  <div style="height:100%;width:${f.rate}%;background:${f.color};border-radius:3px;display:flex;align-items:center;justify-content:flex-end;padding-right:6px;transition:width .4s">
                    ${f.rate > 30 ? `<span style="color:#fff;font-size:10px">${f.rate}%</span>` : ''}
                  </div>
                </div>
                <div style="margin-top:6px;font-size:15px;font-weight:600;color:var(--ly-text);font-variant-numeric:tabular-nums">${num(f.amount)}<span style="font-size:11px;font-weight:400;color:var(--ly-text-secondary);margin-left:2px">万</span></div>
                ${i < 5 ? '' : ''}
              </div>`).join('')}
          </div>
        </div>
      </div>

      <div class="grid grid--2-1">
        <div class="panel">
          <div class="panel-head">
            <h3>${icon('chart', 16)}收入与成本趋势 <span class="sub">2026-03 ~ 2026-10 · 华润数科中台项目</span></h3>
            <button class="link-btn" data-jump="/profit">项目利润 →</button>
          </div>
          <div class="panel-body">
            <div id="homeTrend"></div>
          </div>
        </div>
        <div class="panel">
          <div class="panel-head"><h3>${icon('pie', 16)}项目健康度分布</h3><span class="mini">共 24 个在执行</span></div>
          <div class="panel-body" style="display:flex;flex-direction:column;align-items:center;justify-content:center">
            <div id="homeHealth" style="width:100%"></div>
            <div style="width:100%;margin-top:10px;display:flex;flex-direction:column;gap:7px">
              <div style="display:flex;justify-content:space-between;font-size:12px"><span><i class="dot"></i>正常</span><b style="font-weight:600">19 个 · 79.2%</b></div>
              <div style="display:flex;justify-content:space-between;font-size:12px"><span><i class="dot dot--warning"></i>需关注</span><b style="font-weight:600">4 个 · 16.7%</b></div>
              <div style="display:flex;justify-content:space-between;font-size:12px"><span><i class="dot dot--danger"></i>高风险</span><b style="font-weight:600">1 个 · 4.1%</b></div>
            </div>
          </div>
        </div>
      </div>

      <div class="grid grid--1-2">
        <div class="panel">
          <div class="panel-head"><h3>${icon('check-circle', 16)}待办与审批 <span class="badge-count">5</span></h3><button class="link-btn" data-jump="/approval">全部</button></div>
          <div class="panel-body" style="padding-top:4px;padding-bottom:8px">
            ${M.todos.map(t => `<div style="display:flex;gap:10px;padding:11px 0;border-bottom:1px dashed #f0f2f5;align-items:flex-start">
              <div style="margin-top:2px">${tag(t.type, t.type === '应收催收' ? 'danger' : 'primary')}</div>
              <div style="flex:1;min-width:0">
                <div style="font-size:13px;color:var(--ly-text);line-height:19px">${esc(t.title)}</div>
                <div class="mini" style="margin-top:2px">${esc(t.meta)}</div>
              </div>
              <button class="link-btn" data-jump="${t.route}">处理</button>
            </div>`).join('')}
          </div>
        </div>
        <div class="panel">
          <div class="panel-head"><h3>${icon('layers', 16)}重点项目监控</h3><button class="link-btn" data-jump="/project">项目列表 →</button></div>
          <div class="panel-body panel-body--flush">
            <div class="table-wrap">
              <table class="table table--compact">
                <thead><tr><th>项目</th><th>项目经理</th><th class="num">合同额</th><th style="width:130px">进度</th><th class="num">预计毛利率</th><th class="center">健康度</th></tr></thead>
                <tbody>
                  ${M.projects.slice(0, 5).map(p => `<tr style="cursor:pointer" data-project="${p.id}">
                    <td><div class="strong" style="font-size:13px">${esc(p.name)}</div><span class="sub">${p.id} · ${esc(p.customer)}</span></td>
                    <td>${esc(p.pm)}</td>
                    <td class="num">${wan(p.contractAmount)}</td>
                    <td><div class="progress-row"><div class="progress"><div class="progress__bar ${p.percent < 50 ? 'progress__bar--warning' : ''}" style="width:${p.percent}%"></div></div><span>${p.percent}%</span></div></td>
                    <td class="num ${p.margin < 0.2 ? 'text-danger' : ''}">${pct(p.margin)}</td>
                    <td class="center">${statusTag('health', p.health)}</td>
                  </tr>`).join('')}
                </tbody>
              </table>
            </div>
          </div>
        </div>
      </div>

      <div class="panel">
        <div class="panel-head"><h3>${icon('alert', 16)}风险预警 <span class="sub">按影响金额排序</span></h3><span class="tag tag--danger">4 项待处理</span></div>
        <div class="panel-body risk-grid">
          ${M.severityList.map(s => `<div style="border:1px solid ${s.level === 'danger' ? '#fde2e2' : '#faecd8'};background:${s.level === 'danger' ? '#fef7f7' : '#fffcf5'};border-radius:4px;padding:12px 14px">
            <div style="display:flex;align-items:center;gap:6px;font-size:13px;font-weight:600;color:${s.level === 'danger' ? '#c45656' : '#a86a1c'}">
              ${icon('alert', 14)}${esc(s.title)}
            </div>
            <div class="mini" style="margin:6px 0 8px;color:#7a6a55">${esc(s.desc)}</div>
            <button class="link-btn" data-jump="${s.route}">${esc(s.action)} →</button>
          </div>`).join('')}
        </div>
      </div>

      <div class="panel">
        <div class="panel-head"><h3>${icon('grid', 16)}链路 1 节点导航 <span class="sub">12 个节点全覆盖</span></h3><span class="mini">N1 → N12</span></div>
        <div class="panel-body node-grid" style="padding:12px">
          ${NODES.map(n => `<div data-jump="${n.route}" style="cursor:pointer;border:1px solid var(--ly-border-light);border-radius:4px;padding:10px 8px;text-align:center;transition:.15s" onmouseover="this.style.borderColor='#c6d4f5';this.style.background='#f7faff'" onmouseout="this.style.borderColor='';this.style.background=''">
            <div style="color:var(--ly-primary)">${icon(n.icon, 16)}</div>
            <div style="font-size:11px;color:var(--ly-text-secondary);margin-top:5px">${n.n}</div>
            <div style="font-size:12px;color:var(--ly-text);margin-top:2px;white-space:nowrap">${n.name}</div>
          </div>`).join('')}
        </div>
      </div>`;

      // 图表
      chart(root.querySelector('#homeTrend'), 'line', {
        categories: M.monthly.map(m => m.month.slice(5) + '月'),
        series: [
          { name: '确认收入', data: M.monthly.map(m => m.revenue), color: '#1d4ed8' },
          { name: '实际成本', data: M.monthly.map(m => m.cost), color: '#e6a23c' }
        ],
        height: 236, area: true, fmt: v => LY.wan(v)
      });
      chart(root.querySelector('#homeHealth'), 'donut', {
        data: [
          { name: '正常', value: 19, color: '#67c23a' },
          { name: '需关注', value: 4, color: '#e6a23c' },
          { name: '高风险', value: 1, color: '#f56c6c' }
        ],
        centerValue: '24', centerLabel: '在执行项目', height: 190, thickness: 18, legend: false
      });

      // 交互
      root.querySelectorAll('[data-jump]').forEach(el => el.addEventListener('click', () => LY.go(el.dataset.jump)));
      root.querySelectorAll('[data-project]').forEach(el => el.addEventListener('click', () => LY.go('/project/detail?id=' + el.dataset.project)));
      root.querySelector('#homeExport').addEventListener('click', () => LY.toast('经营简报已生成，正在下载…', 'info'));
      root.querySelector('#homeNew').addEventListener('click', () => {
        LY.openModal({
          title: '新建商机', width: 620,
          body: `<div class="form-grid">
            <div class="form-item"><label>商机名称 <span class="text-danger">*</span></label><input class="input" placeholder="请输入商机名称"></div>
            <div class="form-item"><label>客户 <span class="text-danger">*</span></label><select class="select"><option>华润数科集团</option><option>中海物业</option><option>国网信通</option></select></div>
            <div class="form-item"><label>预计金额（元）</label><input class="input" placeholder="0.00"></div>
            <div class="form-item"><label>预计签约日期</label><input class="input" type="date"></div>
            <div class="form-item"><label>商机阶段</label><select class="select"><option>初步接触</option><option>需求确认</option><option>方案阶段</option><option>商务谈判</option></select></div>
            <div class="form-item"><label>负责人</label><input class="input" value="陈立"></div>
          </div>`,
          footer: `<button class="btn" data-close>取消</button><button class="btn btn--primary" id="okOpp">创建商机</button>`,
          onMount(m) { m.querySelector('#okOpp').addEventListener('click', () => { LY.closeModal(); LY.toast('商机已创建，编号 OPP-2026-025'); }); }
        });
      });
      root.querySelectorAll('#homeRange button').forEach(b => b.addEventListener('click', () => {
        root.querySelectorAll('#homeRange button').forEach(x => x.classList.remove('is-active'));
        b.classList.add('is-active');
        LY.toast('已切换统计周期：' + ({ year: '本年度', quarter: '本季度', month: '本月' })[b.dataset.r], 'info');
      }));
    }
  });
})();
