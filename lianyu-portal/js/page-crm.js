/* ================= CRM：客户主数据 / 商机 / 合同 / 登录 ================= */
(function () {
  const LY = window.LY, M = LY.MOCK;
  const { icon, wan, money, pct, num, esc, tag, statusTag } = LY;

  const sum = (arr, f) => arr.reduce((a, b) => a + f(b), 0);
  const roleTag = r => tag(r, r === '客户' ? 'primary' : r === '供应商' ? 'warning' : 'success');
  const pagerHtml = (total, page, size) => {
    if (LY.pagerHtml) return LY.pagerHtml(total, page, size);
    const pages = Math.max(1, Math.ceil(total / size));
    let html = '';
    for (let i = 1; i <= pages; i++) html += '<button class="pager__btn ' + (i === page ? 'is-active' : '') + '" data-p="' + i + '">' + i + '</button>';
    return '<span class="total">共 ' + total + ' 条</span>' + html;
  };
  const cust = id => M.customers.find(c => c.id === id) || {};

  /* ---------------- 客户主数据 ---------------- */
  const MERGE_FIELDS = [
    { key: 'name', label: '客户名称' },
    { key: 'taxNo', label: '税号' },
    { key: 'owner', label: '负责人' },
    { key: 'level', label: '客户等级' },
    { key: 'org', label: '归属组织' }
  ];

  function openMergeModal(mainId, fromId) {
    const a = cust(mainId), b = cust(fromId);
    if (!a.id || !b.id) return;
    const cs = M.contracts.filter(x => x.customerId === a.id && x.status !== 'UNSIGNED');
    const ps = M.projects.filter(x => x.customerId === a.id);
    const ivs = M.invoices.filter(x => x.customerId === a.id && x.status === 'ISSUED');
    const rcs = M.receipts.filter(x => x.customerId === a.id);
    const body = `
      <div class="grid grid--2" style="margin-bottom:14px">
        <div class="panel panel--flat" style="border-color:#c6d4f5">
          <div class="panel-head" style="height:auto;padding:10px 12px"><h3 style="font-size:13px">主客户 ${a.id} ${tag('保留', 'primary')}</h3></div>
          <div class="panel-body" style="padding:10px 12px">
            <div style="font-size:13px;font-weight:600;color:var(--ly-text)">${esc(a.name)}</div>
            <div class="mini" style="margin-top:4px">税号 ${esc(a.taxNo)}</div>
            <div class="mini">负责人 ${esc(a.owner)} · ${a.level} 类 · ${esc(a.org)}</div>
          </div>
        </div>
        <div class="panel panel--flat" style="border-color:#faecd8">
          <div class="panel-head" style="height:auto;padding:10px 12px"><h3 style="font-size:13px">待合并 ${b.id} ${tag('失效', 'warning')}</h3></div>
          <div class="panel-body" style="padding:10px 12px">
            <div style="font-size:13px;font-weight:600;color:var(--ly-text)">${esc(b.name)}</div>
            <div class="mini" style="margin-top:4px">税号 ${esc(b.taxNo)}</div>
            <div class="mini">负责人 ${esc(b.owner)} · ${b.level} 类 · ${esc(b.org)} · 重复度 ${pct(b.duplicateRate || 0, 0)}</div>
          </div>
        </div>
      </div>
      <div class="alert alert--warning" style="margin-bottom:12px">${icon('alert', 15)}<span>两客户税号一致（${esc(a.taxNo)}），按 md_customer 唯一性规则判定为同一客户，需按字段级 Survivorship 规则保留主记录。</span></div>
      <div class="toolbar" style="margin-bottom:6px"><div class="toolbar__l"><b style="font-size:13px">字段级 Survivorship 规则</b></div><span class="mini">逐字段选择取值来源</span></div>
      <div class="table-wrap" style="border:1px solid var(--ly-border-light);border-radius:4px">
        <table class="table table--compact">
          <thead><tr><th style="width:110px">字段</th><th>主客户 ${a.id}</th><th>待合并 ${b.id}</th><th style="width:120px">取值规则</th></tr></thead>
          <tbody>
            ${MERGE_FIELDS.map(f => `<tr>
              <td class="strong">${f.label}</td>
              <td>${esc(a[f.key])}</td>
              <td class="text-muted">${esc(b[f.key])}</td>
              <td><select class="select" style="min-width:100px;height:28px;font-size:12px" data-f="${f.key}"><option>保留主</option><option>取从</option></select></td>
            </tr>`).join('')}
          </tbody>
        </table>
      </div>
      <div class="toolbar" style="margin:14px 0 6px"><div class="toolbar__l"><b style="font-size:13px">影响范围</b></div><span class="mini">以下关联数据统一归集至 ${a.id}</span></div>
      <div class="grid grid--4">
        <div class="panel panel--flat"><div class="panel-body" style="padding:10px 12px"><div class="mini">关联合同</div><div class="kv" style="margin-top:2px"><b>${cs.length}</b><span>份生效合同</span></div></div></div>
        <div class="panel panel--flat"><div class="panel-body" style="padding:10px 12px"><div class="mini">关联项目</div><div class="kv" style="margin-top:2px"><b>${ps.length}</b><span>个项目</span></div></div></div>
        <div class="panel panel--flat"><div class="panel-body" style="padding:10px 12px"><div class="mini">已开具发票</div><div class="kv" style="margin-top:2px"><b>${ivs.length}</b><span>张</span></div></div></div>
        <div class="panel panel--flat"><div class="panel-body" style="padding:10px 12px"><div class="mini">收款记录</div><div class="kv" style="margin-top:2px"><b>${rcs.length}</b><span>笔</span></div></div></div>
      </div>
      <div class="alert" style="margin-top:12px">${icon('info', 15)}<span>合并后 ${b.id} 标记为 <b>失效</b> 并保留来源映射，历史单据外键自动改写，操作写入 <b>md_customer_merge_log</b>。</span></div>`;
    LY.openModal({
      title: '客户合并 · 主数据治理', width: 760, body,
      footer: `<button class="btn" data-close>取消</button><button class="btn btn--primary" id="okMerge">确认合并</button>`,
      onMount(m) {
        m.querySelector('#okMerge').addEventListener('click', () => {
          LY.closeModal();
          LY.toast('合并完成，' + b.id + ' 已标记为失效并写入合并日志');
        });
      }
    });
  }

  function openNewCustomerModal() {
    LY.openModal({
      title: '新建客户', width: 640,
      body: `<div class="form-grid">
        <div class="form-item"><label>客户名称 <span class="text-danger">*</span></label><input class="input" placeholder="请输入客户全称"></div>
        <div class="form-item"><label>税号（统一社会信用代码）<span class="text-danger">*</span></label><input class="input" placeholder="18 位统一社会信用代码"></div>
        <div class="form-item"><label>行业</label><select class="select"><option>科技/数字化</option><option>物业服务</option><option>能源信息化</option><option>地产科技</option><option>智能制造</option><option>物流邮政</option></select></div>
        <div class="form-item"><label>区域</label><select class="select"><option>深圳</option><option>北京</option><option>上海</option><option>广州</option></select></div>
        <div class="form-item"><label>负责人</label><select class="select"><option>陈立</option><option>周涛</option><option>王强</option><option>李娜</option><option>张伟</option></select></div>
        <div class="form-item"><label>归属组织</label><select class="select"><option>交付中心</option><option>技术中心</option><option>产品与设计中心</option></select></div>
        <div class="form-item" style="grid-column:1/-1"><label>客户角色（可多选）</label>
          <div style="display:flex;gap:18px;padding-top:2px">
            <label class="checkbox"><input type="checkbox" checked>客户</label>
            <label class="checkbox"><input type="checkbox">供应商</label>
            <label class="checkbox"><input type="checkbox">付款单位</label>
          </div>
        </div>
      </div>
      <div class="alert">${icon('info', 15)}<span>保存时按税号执行唯一性校验，命中已有客户将提示合并而非新建。</span></div>`,
      footer: `<button class="btn" data-close>取消</button><button class="btn btn--primary" id="okCus">保存客户</button>`,
      onMount(m) {
        m.querySelector('#okCus').addEventListener('click', () => {
          LY.closeModal();
          LY.toast('客户已创建，编码 CUS-0008（待审核）');
        });
      }
    });
  }

  function openCustomerDrawer(id) {
    const c = cust(id);
    if (!c.id) return;
    const cts = M.contacts.filter(x => x.customerId === c.id);
    const cs = M.contracts.filter(x => x.customerId === c.id);
    const ps = M.projects.filter(x => x.customerId === c.id);
    const body = `
      <div style="display:flex;gap:12px;align-items:center;padding-bottom:14px;border-bottom:1px solid var(--ly-border-light)">
        <div class="avatar-sm" style="width:40px;height:40px;font-size:16px">${esc(c.short.slice(0, 1))}</div>
        <div style="flex:1;min-width:0">
          <div style="font-size:15px;font-weight:600;color:var(--ly-text)">${esc(c.name)}</div>
          <div class="mini" style="margin-top:3px">${c.id} · 来源 ${esc(c.source)} · ${esc(c.status)}${c.duplicateOf ? ' · 疑似重复' : ''}</div>
        </div>
        <div class="inline-tag-group">${c.partyType.map(roleTag).join('')}</div>
      </div>

      <div class="toolbar" style="margin:14px 0 2px"><div class="toolbar__l"><b style="font-size:13px">基本信息</b></div><span class="mini">${c.level} 类客户 · ${esc(c.industry)}</span></div>
      <div class="desc-grid desc-grid--2">
        <div class="desc-item"><span class="desc-label">客户编码</span><span class="desc-value mono">${c.id}</span></div>
        <div class="desc-item"><span class="desc-label">税号</span><span class="desc-value mono">${esc(c.taxNo)}</span></div>
        <div class="desc-item"><span class="desc-label">行业</span><span class="desc-value">${esc(c.industry)}</span></div>
        <div class="desc-item"><span class="desc-label">区域</span><span class="desc-value">${esc(c.region)}</span></div>
        <div class="desc-item"><span class="desc-label">负责人</span><span class="desc-value">${esc(c.owner)}</span></div>
        <div class="desc-item"><span class="desc-label">归属组织</span><span class="desc-value">${esc(c.org)}</span></div>
        <div class="desc-item"><span class="desc-label">信用额度</span><span class="desc-value money">${money(c.creditLimit)}</span></div>
        <div class="desc-item"><span class="desc-label">已用额度</span><span class="desc-value money">${money(c.creditUsed)}</span></div>
      </div>

      <div class="toolbar" style="margin:14px 0 6px"><div class="toolbar__l"><b style="font-size:13px">联系人</b></div><span class="mini">${cts.length} 位</span></div>
      ${cts.length ? `<div class="table-wrap"><table class="table table--compact">
        <thead><tr><th>姓名</th><th>职位</th><th>手机</th><th>邮箱</th><th class="center">关键人</th></tr></thead>
        <tbody>${cts.map(x => `<tr>
          <td class="strong">${esc(x.name)} ${x.primary ? tag('主', 'primary') : ''}</td>
          <td>${esc(x.title)}</td><td class="mono">${esc(x.mobile)}</td><td>${esc(x.email)}</td>
          <td class="center">${x.decision ? tag('决策人', 'warning') : '<span class="text-muted">-</span>'}</td>
        </tr>`).join('')}</tbody>
      </table></div>` : `<div class="empty">${icon('users', 32)}暂无联系人</div>`}

      <div class="toolbar" style="margin:14px 0 6px"><div class="toolbar__l"><b style="font-size:13px">关联合同</b></div><span class="mini">${cs.length} 份</span></div>
      ${cs.length ? `<div class="table-wrap"><table class="table table--compact">
        <thead><tr><th>合同号</th><th>合同名称</th><th class="num">含税金额</th><th>状态</th></tr></thead>
        <tbody>${cs.map(x => `<tr>
          <td class="mono">${x.id}</td>
          <td>${esc(x.name)}</td>
          <td class="num">${money(x.incl)}</td>
          <td>${statusTag('contract', x.status)}</td>
        </tr>`).join('')}</tbody>
      </table></div>` : `<div class="empty">${icon('file', 32)}暂无合同</div>`}

      <div class="toolbar" style="margin:14px 0 6px"><div class="toolbar__l"><b style="font-size:13px">关联项目</b></div><span class="mini">${ps.length} 个</span></div>
      ${ps.length ? `<div class="table-wrap"><table class="table table--compact">
        <thead><tr><th>项目</th><th>项目经理</th><th class="num">合同额</th><th>状态</th></tr></thead>
        <tbody>${ps.map(x => `<tr>
          <td><div class="strong" style="font-size:13px">${esc(x.name)}</div><span class="sub">${x.id}</span></td>
          <td>${esc(x.pm)}</td>
          <td class="num">${wan(x.contractAmount)}</td>
          <td>${statusTag('project', x.status)}</td>
        </tr>`).join('')}</tbody>
      </table></div>` : `<div class="empty">${icon('folder', 32)}暂无项目</div>`}

      <div class="toolbar" style="margin:14px 0 2px"><div class="toolbar__l"><b style="font-size:13px">财务信息</b></div><span class="mini">口径：FS 应收 / 项目毛利</span></div>
      <div class="desc-grid desc-grid--2">
        <div class="desc-item"><span class="desc-label">框架合同额</span><span class="desc-value money">${money(c.contractAmount)}</span></div>
        <div class="desc-item"><span class="desc-label">应收余额</span><span class="desc-value money">${money(c.receivable)}</span></div>
        <div class="desc-item"><span class="desc-label">逾期金额</span><span class="desc-value money ${c.overdue > 0 ? 'text-danger' : ''}">${money(c.overdue)}</span></div>
        <div class="desc-item"><span class="desc-label">平均毛利率</span><span class="desc-value">${c.margin == null ? '-' : pct(c.margin)}</span></div>
      </div>`;
    LY.openDrawer({
      title: '客户详情 · ' + c.short, width: 720, body,
      footer: `<button class="btn" data-close>关闭</button><button class="btn" id="cusOpp">发起商机</button><button class="btn btn--primary" id="cusEdit">编辑客户</button>`,
      onMount(d) {
        d.querySelector('#cusOpp').addEventListener('click', () => { LY.closeDrawer(); LY.go('/opportunity'); });
        d.querySelector('#cusEdit').addEventListener('click', () => LY.toast('客户编辑已打开（原型演示）', 'info'));
      }
    });
  }

  LY.register('/customer', {
    title: '客户主数据', crumb: ['客户与商机', '客户主数据'],
    render(root) {
      const state = { kw: '', level: '', role: '', source: '', page: 1, size: 5 };
      const dup = M.customers.filter(c => c.duplicateOf);

      const draw = () => {
        const kw = state.kw.trim();
        const list = M.customers.filter(c =>
          (!kw || c.name.indexOf(kw) > -1 || c.id.indexOf(kw) > -1 || c.taxNo.indexOf(kw) > -1) &&
          (!state.level || c.level === state.level) &&
          (!state.role || c.partyType.indexOf(state.role) > -1) &&
          (!state.source || c.source === state.source));
        const total = list.length;
        const pages = Math.max(1, Math.ceil(total / state.size));
        if (state.page > pages) state.page = pages;
        const rows = list.slice((state.page - 1) * state.size, state.page * state.size);
        root.querySelector('#cusBody').innerHTML = rows.length ? rows.map(c => `
          <tr data-id="${c.id}" class="${c.duplicateOf ? 'hl-row' : ''}" style="cursor:pointer">
            <td class="mono">${c.id}</td>
            <td><div class="strong">${esc(c.name)}</div><span class="sub">${esc(c.short)}</span></td>
            <td class="mono">${esc(c.taxNo)}</td>
            <td>${c.level === 'A' ? tag('A 类', 'danger') : tag(c.level + ' 类', 'info')}</td>
            <td><div class="inline-tag-group">${c.partyType.map(roleTag).join('')}</div></td>
            <td>${esc(c.owner)}</td>
            <td class="num">${wan(c.contractAmount)}</td>
            <td class="num ${c.overdue > 0 ? 'text-danger' : ''}">${wan(c.receivable)}</td>
            <td class="num">${c.margin == null ? '-' : pct(c.margin)}</td>
            <td>${tag(c.source, c.source === 'CRM' ? 'primary' : c.source === 'PMT' ? 'success' : 'warning')}</td>
            <td class="center">
              <button class="link-btn" data-detail="${c.id}">详情</button>${c.duplicateOf ? `<button class="link-btn link-btn--danger" data-merge="${c.duplicateOf}|${c.id}">合并</button>` : ''}
            </td>
          </tr>`).join('') : `<tr><td colspan="11"><div class="empty">${icon('users', 40)}没有符合条件的客户</div></td></tr>`;

        root.querySelector('#cusTotal').textContent = '共 ' + total + ' 条客户';
        root.querySelector('#cusPager').innerHTML = pagerHtml(total, state.page, state.size);

        root.querySelectorAll('#cusBody tr[data-id]').forEach(tr => {
          tr.addEventListener('click', e => {
            const mg = e.target.closest('[data-merge]');
            if (mg) { e.stopPropagation(); const p = mg.dataset.merge.split('|'); openMergeModal(p[0], p[1]); return; }
            openCustomerDrawer(tr.dataset.id);
          });
        });
        root.querySelectorAll('#cusPager .pager__btn[data-p]').forEach(b => b.addEventListener('click', () => {
          state.page = +b.dataset.p; draw();
        }));
      };

      root.innerHTML = `
      <div class="page-head">
        <div class="page-head__l">
          <div class="page-title">客户主数据 <span class="tag tag--primary">md_customer</span></div>
          <div class="page-sub">CRM / PMT / FS 三套系统客户统一合并至 md_customer · 一客一码 · 税号唯一 · 数据截至 2026-11-10</div>
        </div>
        <div class="page-actions">
          <button class="btn" id="cusMerge">${icon('merge', 14)}客户合并</button>
          <button class="btn btn--primary" id="cusNew">${icon('plus', 14)}新建客户</button>
          <button class="btn" id="cusExport">${icon('download', 14)}导出</button>
        </div>
      </div>

      <div class="grid grid--4">
        <div class="kpi"><div class="kpi-label">客户总数</div><div class="kpi-value">42</div><div class="kpi-foot">全量主数据 · 当前加载 7 条样例</div></div>
        <div class="kpi"><div class="kpi-label">A 类客户</div><div class="kpi-value">8</div><div class="kpi-foot">占比 19.0% · 当前视图 4 家</div></div>
        <div class="kpi kpi--warning"><div class="kpi-label">疑似重复</div><div class="kpi-value">${dup.length}<small>组</small></div><div class="kpi-foot">CUS-0007 与 CUS-0001 税号一致</div></div>
        <div class="kpi kpi--success"><div class="kpi-label">客户平均毛利率</div><div class="kpi-value">24.8<small>%</small></div><div class="kpi-foot">按合同额加权 · 剔除无合同客户</div></div>
      </div>

      <div class="alert alert--warning">${icon('alert', 15)}
        <span><b>CUS-0007 ${esc(dup.length ? dup[0].name : '')}</b> 与 <b>CUS-0001 ${esc(cust('CUS-0001').name || '')}</b> 税号相同，重复度 ${dup.length ? pct(dup[0].duplicateRate, 0) : '92%'}，建议执行客户合并。
        <button class="link-btn" id="alertMerge">去合并</button></span>
      </div>

      <div class="filter-bar">
        <div class="field"><span class="field-label">客户名称 / 税号</span><input class="input" id="fCusKw" placeholder="名称、编码或税号" style="width:220px"></div>
        <div class="field"><span class="field-label">客户等级</span><select class="select" id="fCusLevel" style="width:110px"><option value="">全部</option><option value="A">A 类</option><option value="B">B 类</option><option value="C">C 类</option></select></div>
        <div class="field"><span class="field-label">客户角色</span><select class="select" id="fCusRole" style="width:120px"><option value="">全部</option><option>客户</option><option>供应商</option><option>付款单位</option></select></div>
        <div class="field"><span class="field-label">来源系统</span><select class="select" id="fCusSource" style="width:110px"><option value="">全部</option><option>CRM</option><option>PMT</option><option>FS</option></select></div>
        <div class="field"><button class="btn btn--primary" id="fCusSearch">${icon('search', 14)}查询</button><button class="btn" id="fCusReset">重置</button></div>
      </div>

      <div class="panel">
        <div class="panel-head"><h3>${icon('building', 16)}客户台账</h3><span class="mini" id="cusTotal"></span></div>
        <div class="panel-body panel-body--flush">
          <div class="table-wrap"><table class="table">
            <thead><tr><th>客户编码</th><th>客户名称</th><th>税号</th><th>等级</th><th>客户角色</th><th>负责人</th><th class="num">合同额</th><th class="num">应收余额</th><th class="num">毛利率</th><th>来源</th><th class="center">操作</th></tr></thead>
            <tbody id="cusBody"></tbody>
          </table></div>
        </div>
        <div class="panel-foot"><span class="mini">主数据唯一键：税号 + 客户名称；合并后保留来源映射，历史单据外键自动改写</span><div class="pager" id="cusPager"></div></div>
      </div>`;

      const bind = () => {
        state.kw = root.querySelector('#fCusKw').value;
        state.level = root.querySelector('#fCusLevel').value;
        state.role = root.querySelector('#fCusRole').value;
        state.source = root.querySelector('#fCusSource').value;
        state.page = 1; draw();
      };
      root.querySelector('#fCusSearch').addEventListener('click', bind);
      root.querySelector('#fCusKw').addEventListener('keyup', e => { if (e.key === 'Enter') bind(); });
      ['#fCusLevel', '#fCusRole', '#fCusSource'].forEach(sel => root.querySelector(sel).addEventListener('change', bind));
      root.querySelector('#fCusReset').addEventListener('click', () => {
        root.querySelector('#fCusKw').value = '';
        root.querySelector('#fCusLevel').value = '';
        root.querySelector('#fCusRole').value = '';
        root.querySelector('#fCusSource').value = '';
        bind();
      });
      root.querySelector('#cusMerge').addEventListener('click', () => openMergeModal('CUS-0001', 'CUS-0007'));
      root.querySelector('#alertMerge').addEventListener('click', () => openMergeModal('CUS-0001', 'CUS-0007'));
      root.querySelector('#cusNew').addEventListener('click', openNewCustomerModal);
      root.querySelector('#cusExport').addEventListener('click', () => LY.toast('客户主数据已导出（xlsx）', 'info'));

      draw();
    }
  });

  /* ---------------- 商机管理 ---------------- */
  const STAGES = ['初步接触', '需求确认', '方案阶段', '商务谈判'];
  const STAGE_COLOR = { '初步接触': '#93b4f7', '需求确认': '#6d96f0', '方案阶段': '#3b82f6', '商务谈判': '#1d4ed8' };

  function openFollowModal(o) {
    LY.openModal({
      title: '新增跟进 · ' + o.id, width: 560,
      body: `<div class="form-grid">
        <div class="form-item"><label>跟进方式</label><select class="select"><option>电话沟通</option><option>现场拜访</option><option>方案汇报</option><option>邮件往来</option></select></div>
        <div class="form-item"><label>跟进时间</label><input class="input" type="date" value="2026-11-10"></div>
        <div class="form-item" style="grid-column:1/-1"><label>跟进内容 <span class="text-danger">*</span></label><textarea class="textarea" placeholder="记录客户反馈、关键人态度、竞争态势…"></textarea></div>
        <div class="form-item" style="grid-column:1/-1"><label>下一步计划</label><input class="input" placeholder="如：11-18 提交最终报价"></div>
      </div>`,
      footer: `<button class="btn" data-close>取消</button><button class="btn btn--primary" id="okFollow">保存跟进</button>`,
      onMount(m) {
        m.querySelector('#okFollow').addEventListener('click', () => {
          LY.closeModal();
          LY.toast('跟进记录已保存，商机最近跟进时间已更新');
        });
      }
    });
  }

  function openToContractModal(o) {
    LY.openModal({
      title: '商机转合同 · ' + o.id, width: 620,
      body: `<div class="alert" style="margin-bottom:14px">${icon('info', 15)}<span>将创建 <b>md_contract</b> 草稿并建立合同-商机关联（opportunity_id），客户、金额、预计签约日自动带入。</span></div>
      <div class="form-grid">
        <div class="form-item"><label>客户</label><input class="input" value="${esc(o.customer)}" readonly></div>
        <div class="form-item"><label>合同名称</label><input class="input" value="${esc(o.name)}"></div>
        <div class="form-item"><label>含税金额（元）</label><input class="input" value="${money(o.amount)}"></div>
        <div class="form-item"><label>税率</label><select class="select"><option>6%</option><option>9%</option><option>13%</option></select></div>
        <div class="form-item"><label>预计签约日</label><input class="input" type="date" value="${o.expectSign}"></div>
        <div class="form-item"><label>合同类型</label><select class="select"><option>主合同</option><option>框架协议</option><option>补充协议</option></select></div>
      </div>`,
      footer: `<button class="btn" data-close>取消</button><button class="btn btn--primary" id="okToCt">创建合同草稿</button>`,
      onMount(m) {
        m.querySelector('#okToCt').addEventListener('click', () => {
          LY.closeModal();
          LY.toast('合同草稿已创建：CT-2026-0089');
        });
      }
    });
  }

  function openOppDrawer(id) {
    const o = M.opportunities.find(x => x.id === id);
    if (!o) return;
    const fs = M.follows.filter(f => f.oppId === o.id).slice().sort((a, b) => a.time < b.time ? 1 : -1);
    const body = `
      <div style="display:flex;gap:12px;align-items:flex-start;padding-bottom:14px;border-bottom:1px solid var(--ly-border-light)">
        <div style="flex:1;min-width:0">
          <div style="font-size:15px;font-weight:600;color:var(--ly-text)">${esc(o.name)}</div>
          <div class="mini" style="margin-top:3px">${o.id} · ${esc(o.customer)} · 来源 ${esc(o.source)}</div>
        </div>
        <div>${tag(o.stage, o.stage === '商务谈判' ? 'danger' : o.stage === '已签约' ? 'success' : 'primary')}</div>
      </div>
      <div class="desc-grid desc-grid--2" style="margin-top:6px">
        <div class="desc-item"><span class="desc-label">商机金额</span><span class="desc-value money">${money(o.amount)}</span></div>
        <div class="desc-item"><span class="desc-label">成交概率</span><span class="desc-value">${o.probability}%</span></div>
        <div class="desc-item"><span class="desc-label">加权金额</span><span class="desc-value money">${money(o.amount * o.probability / 100)}</span></div>
        <div class="desc-item"><span class="desc-label">预计签约</span><span class="desc-value">${o.expectSign}</span></div>
        <div class="desc-item"><span class="desc-label">负责人</span><span class="desc-value">${esc(o.owner)}</span></div>
        <div class="desc-item"><span class="desc-label">创建日期</span><span class="desc-value">${o.created}</span></div>
        <div class="desc-item full"><span class="desc-label">下次动作</span><span class="desc-value">${esc(o.nextAction)}</span></div>
      </div>
      <div class="toolbar" style="margin:16px 0 10px"><div class="toolbar__l"><b style="font-size:13px">跟进记录</b></div><span class="mini">${fs.length} 条</span></div>
      ${fs.length ? `<div class="timeline">${fs.map(f => `<div class="timeline__item ${f.planStatus === '已完成' ? 'is-done' : 'is-current'}">
        <div class="timeline__title">${esc(f.type)} ${f.planStatus === '已完成' ? tag('已完成', 'success') : tag('计划中', 'warning')}</div>
        <div class="timeline__meta">${f.time} · ${esc(f.owner)}</div>
        <div class="timeline__body">${esc(f.content)}</div>
      </div>`).join('')}</div>` : `<div class="empty">${icon('clock', 32)}暂无跟进记录</div>`}`;
    LY.openDrawer({
      title: '商机详情', width: 660, body,
      footer: `<button class="btn" data-close>关闭</button><button class="btn" id="oppFollow">新增跟进</button><button class="btn btn--primary" id="oppToCt">转合同</button>`,
      onMount(d) {
        d.querySelector('#oppFollow').addEventListener('click', () => openFollowModal(o));
        d.querySelector('#oppToCt').addEventListener('click', () => openToContractModal(o));
      }
    });
  }

  LY.register('/opportunity', {
    title: '商机管理', crumb: ['客户与商机', '商机管理'],
    render(root) {
      const list = M.opportunities;
      const totalAmt = sum(list, o => o.amount);
      const weighted = sum(list, o => o.amount * o.probability / 100);
      const avgProb = sum(list, o => o.probability) / list.length;
      const BASE = new Date('2026-11-10').getTime();
      const near = list.filter(o => {
        const t = new Date(o.expectSign).getTime();
        return t >= BASE && t <= BASE + 90 * 86400000;
      }).sort((a, b) => a.expectSign < b.expectSign ? -1 : 1);
      const maxStageAmt = Math.max.apply(null, STAGES.map(s => sum(list.filter(o => o.stage === s), o => o.amount)));
      let view = 'kanban';

      const card = o => `<div data-opp="${o.id}" style="cursor:pointer;background:#fff;border:1px solid var(--ly-border-light);border-radius:4px;padding:10px 11px;box-shadow:var(--ly-shadow)">
        <div style="font-size:13px;font-weight:500;color:var(--ly-text);line-height:19px">${esc(o.name)}</div>
        <div class="mini" style="margin-top:3px">${esc(o.customer)} · ${o.id}</div>
        <div style="display:flex;justify-content:space-between;align-items:baseline;margin-top:8px">
          <b class="money" style="font-size:14px;color:var(--ly-text)">${wan(o.amount)}</b><span class="mini">${o.probability}%</span>
        </div>
        <div class="progress" style="margin-top:5px"><div class="progress__bar" style="width:${o.probability}%"></div></div>
        <div style="display:flex;justify-content:space-between;margin-top:8px"><span class="mini">${o.expectSign}</span><span class="mini">${esc(o.owner)}</span></div>
      </div>`;

      const kanbanHtml = () => `
        <div class="grid grid--4">
          ${STAGES.map(s => {
            const arr = list.filter(o => o.stage === s);
            return `<div class="panel">
              <div class="panel-head" style="padding:0 12px"><h3 style="font-size:14px">${s} <span class="sub">${arr.length}</span></h3><span class="mini">${wan(sum(arr, o => o.amount))}</span></div>
              <div class="panel-body" style="padding:10px;display:flex;flex-direction:column;gap:8px;background:#fafbfc;min-height:360px">
                ${arr.length ? arr.map(card).join('') : `<div class="empty" style="padding:36px 8px">${icon('target', 28)}暂无商机</div>`}
              </div>
            </div>`;
          }).join('')}
        </div>
        <div class="alert" style="margin-top:12px">${icon('info', 15)}<span>已签约商机 1 个（OPP-2026-009 · 已转合同 CT-2026-0074），不计入在跟看板。</span></div>`;

      const listHtml = () => `
        <div class="panel">
          <div class="panel-head"><h3>${icon('target', 16)}商机列表</h3><span class="mini">共 ${list.length} 个</span></div>
          <div class="panel-body panel-body--flush">
            <div class="table-wrap"><table class="table">
              <thead><tr><th>商机编号</th><th>商机名称</th><th>客户</th><th class="num">金额</th><th>阶段</th><th class="num">概率</th><th>预计签约</th><th>负责人</th><th class="center">操作</th></tr></thead>
              <tbody>${list.map(o => `<tr data-opp="${o.id}" style="cursor:pointer">
                <td class="mono">${o.id}</td>
                <td class="strong">${esc(o.name)}</td>
                <td>${esc(o.customer)}</td>
                <td class="num">${money(o.amount)}</td>
                <td>${tag(o.stage, o.stage === '已签约' ? 'success' : o.stage === '商务谈判' ? 'danger' : 'primary')}</td>
                <td class="num">${o.probability}%</td>
                <td>${o.expectSign}</td>
                <td>${esc(o.owner)}</td>
                <td class="center"><button class="link-btn" data-follow="${o.id}">跟进</button><button class="link-btn" data-toct="${o.id}">转合同</button></td>
              </tr>`).join('')}</tbody>
            </table></div>
          </div>
        </div>`;

      const draw = () => {
        const host = root.querySelector('#oppView');
        host.innerHTML = view === 'kanban' ? kanbanHtml() : listHtml();
        host.querySelectorAll('[data-opp]').forEach(el => el.addEventListener('click', e => {
          const f = e.target.closest('[data-follow]');
          if (f) { e.stopPropagation(); openFollowModal(M.opportunities.find(x => x.id === f.dataset.follow)); return; }
          const t = e.target.closest('[data-toct]');
          if (t) { e.stopPropagation(); openToContractModal(M.opportunities.find(x => x.id === t.dataset.toct)); return; }
          openOppDrawer(el.dataset.opp);
        }));
      };

      root.innerHTML = `
      <div class="page-head">
        <div class="page-head__l">
          <div class="page-title">商机管理</div>
          <div class="page-sub">商机 → 合同转化链路 · 阶段 / 概率 / 加权预测 · 数据截至 2026-11-10</div>
        </div>
        <div class="page-actions">
          <div class="radio-group" id="oppViewSwitch">
            <button class="is-active" data-v="kanban">看板</button>
            <button data-v="list">列表</button>
          </div>
          <button class="btn" id="oppExport">${icon('download', 14)}导出</button>
          <button class="btn btn--primary" id="oppNew">${icon('plus', 14)}新建商机</button>
        </div>
      </div>

      <div class="grid grid--4">
        <div class="kpi"><div class="kpi-label">商机总数</div><div class="kpi-value">${list.length}<small>个</small></div><div class="kpi-foot">在跟 5 个 · 已签约 1 个</div></div>
        <div class="kpi"><div class="kpi-label">商机总金额</div><div class="kpi-value">${(totalAmt / 10000).toFixed(1)}<small>万</small></div><div class="kpi-foot">加权金额 ${wan(weighted)}</div></div>
        <div class="kpi kpi--info"><div class="kpi-label">平均成交概率</div><div class="kpi-value">${pct(avgProb / 100, 1)}</div><div class="kpi-foot">商务谈判 2 个 · 概率 70% 以上</div></div>
        <div class="kpi kpi--success"><div class="kpi-label">90 天内预计签约</div><div class="kpi-value">${(sum(near, o => o.amount) / 10000).toFixed(1)}<small>万</small></div><div class="kpi-foot">${near.length} 个商机 · 最近 ${near.length ? near[0].expectSign : '-'}</div></div>
      </div>

      <div class="panel">
        <div class="panel-head"><h3>${icon('filter', 16)}商机阶段漏斗 <span class="sub">按阶段金额占比</span></h3><span class="mini">单位：含税金额</span></div>
        <div class="panel-body" style="display:flex;flex-direction:column;gap:8px;padding:14px 16px">
          ${STAGES.map(s => {
            const arr = list.filter(o => o.stage === s);
            const amt = sum(arr, o => o.amount);
            const w = maxStageAmt ? Math.max(8, amt / maxStageAmt * 100) : 8;
            return `<div style="display:flex;align-items:center;gap:10px">
              <span style="width:64px;font-size:12px;color:var(--ly-text-regular)">${s}</span>
              <div style="flex:1;height:22px;background:#f5f7fa;border-radius:3px;overflow:hidden">
                <div style="height:100%;width:${w}%;background:${STAGE_COLOR[s]};border-radius:3px;display:flex;align-items:center;justify-content:flex-end;padding-right:6px">
                  <span style="color:#fff;font-size:10px;white-space:nowrap">${wan(amt)}</span>
                </div>
              </div>
              <span style="width:56px;text-align:right;font-size:12px;color:var(--ly-text-secondary)">${arr.length} 个</span>
            </div>`;
          }).join('')}
        </div>
      </div>

      <div id="oppView"></div>`;

      root.querySelectorAll('#oppViewSwitch button').forEach(b => b.addEventListener('click', () => {
        view = b.dataset.v;
        root.querySelectorAll('#oppViewSwitch button').forEach(x => x.classList.toggle('is-active', x === b));
        draw();
      }));
      root.querySelector('#oppExport').addEventListener('click', () => LY.toast('商机清单已导出（xlsx）', 'info'));
      root.querySelector('#oppNew').addEventListener('click', () => {
        LY.openModal({
          title: '新建商机', width: 620,
          body: `<div class="form-grid">
            <div class="form-item"><label>商机名称 <span class="text-danger">*</span></label><input class="input" placeholder="请输入商机名称"></div>
            <div class="form-item"><label>客户 <span class="text-danger">*</span></label><select class="select">${M.customers.map(c => `<option>${esc(c.name)}</option>`).join('')}</select></div>
            <div class="form-item"><label>预计金额（元）</label><input class="input" placeholder="0.00"></div>
            <div class="form-item"><label>预计签约日期</label><input class="input" type="date"></div>
            <div class="form-item"><label>商机阶段</label><select class="select">${STAGES.map(s => `<option>${s}</option>`).join('')}</select></div>
            <div class="form-item"><label>负责人</label><input class="input" value="${esc(M.user.name)}"></div>
          </div>`,
          footer: `<button class="btn" data-close>取消</button><button class="btn btn--primary" id="okOpp">创建商机</button>`,
          onMount(m) {
            m.querySelector('#okOpp').addEventListener('click', () => { LY.closeModal(); LY.toast('商机已创建，编号 OPP-2026-025'); });
          }
        });
      });
      draw();
    }
  });

  /* ---------------- 合同台账 ---------------- */
  function openNewContractModal() {
    LY.openModal({
      title: '新建合同', width: 660,
      body: `<div class="form-grid">
        <div class="form-item"><label>客户 <span class="text-danger">*</span></label><select class="select">${M.customers.filter(c => !c.duplicateOf).map(c => `<option>${esc(c.name)}</option>`).join('')}</select></div>
        <div class="form-item"><label>合同名称 <span class="text-danger">*</span></label><input class="input" placeholder="请输入合同名称"></div>
        <div class="form-item"><label>含税金额（元）</label><input class="input" placeholder="0.00"></div>
        <div class="form-item"><label>税率</label><select class="select"><option>6%</option><option>9%</option><option>13%</option></select></div>
        <div class="form-item"><label>签约日期</label><input class="input" type="date" value="2026-11-10"></div>
        <div class="form-item"><label>合同类型</label><select class="select"><option>主合同</option><option>框架协议</option><option>补充协议</option></select></div>
        <div class="form-item" style="grid-column:1/-1"><label>付款条件</label><textarea class="textarea">预付款 30%（签约后 10 个工作日）、蓝图确认 20%、上线验收 40%、质保金 10%（质保期满 30 日）</textarea></div>
      </div>
      <div class="alert">${icon('info', 15)}<span>含税 = 不含税 + 税额，税率默认 6%；保存后自动生成 4 期收款里程碑。</span></div>`,
      footer: `<button class="btn" data-close>取消</button><button class="btn btn--primary" id="okCt">保存合同</button>`,
      onMount(m) {
        m.querySelector('#okCt').addEventListener('click', () => {
          LY.closeModal();
          LY.toast('合同已创建：CT-2026-0089（草稿）');
        });
      }
    });
  }

  LY.register('/contract', {
    title: '合同台账', crumb: ['合同管理', '合同台账'],
    render(root) {
      const state = { kw: '', customer: '', status: '', type: '', page: 1, size: 6 };
      const signed = M.contracts.filter(c => c.status !== 'UNSIGNED');
      const totalIncl = sum(signed, c => c.incl);
      const totalRecv = sum(signed, c => c.received);
      const inProgress = M.contracts.filter(c => c.status === 'IN_PROGRESS').length;
      const unsigned = M.contracts.filter(c => c.status === 'UNSIGNED').length;

      const draw = () => {
        const kw = state.kw.trim();
        const list = M.contracts.filter(c =>
          (!kw || c.id.indexOf(kw) > -1 || c.name.indexOf(kw) > -1) &&
          (!state.customer || c.customer === state.customer) &&
          (!state.status || c.status === state.status) &&
          (!state.type || c.type === state.type));
        const total = list.length;
        const pages = Math.max(1, Math.ceil(total / state.size));
        if (state.page > pages) state.page = pages;
        const rows = list.slice((state.page - 1) * state.size, state.page * state.size);
        root.querySelector('#ctBody').innerHTML = rows.length ? rows.map(c => {
          const rate = c.incl ? c.received / c.incl : 0;
          return `<tr data-id="${c.id}" style="cursor:pointer">
            <td class="mono">${c.id}</td>
            <td><div class="strong">${esc(c.name)}</div><span class="sub">${esc(c.type)} · ${esc(c.productLine)}</span></td>
            <td>${esc(c.customer)}</td>
            <td class="num">${money(c.incl)}</td>
            <td class="num">${money(c.excl)}</td>
            <td>${c.signDate || '<span class="text-muted">未签约</span>'}</td>
            <td>${statusTag('contract', c.status)}</td>
            <td class="num">${wan(c.invoiced)}</td>
            <td class="num">${wan(c.received)}</td>
            <td style="width:130px"><div class="progress-row"><div class="progress"><div class="progress__bar ${rate >= 1 ? 'progress__bar--success' : rate < 0.3 ? 'progress__bar--warning' : ''}" style="width:${Math.min(rate * 100, 100)}%"></div></div><span>${pct(rate)}</span></div></td>
            <td class="center"><button class="link-btn" data-detail="${c.id}">详情</button></td>
          </tr>`;
        }).join('') : `<tr><td colspan="11"><div class="empty">${icon('file', 40)}没有符合条件的合同</div></td></tr>`;
        root.querySelector('#ctTotal').textContent = '共 ' + total + ' 份合同';
        root.querySelector('#ctPager').innerHTML = pagerHtml(total, state.page, state.size);
        root.querySelectorAll('#ctBody tr[data-id]').forEach(tr => tr.addEventListener('click', e => {
          const d = e.target.closest('[data-detail]');
          LY.go('/contract/detail?id=' + (d ? d.dataset.detail : tr.dataset.id));
        }));
        root.querySelectorAll('#ctPager .pager__btn[data-p]').forEach(b => b.addEventListener('click', () => { state.page = +b.dataset.p; draw(); }));
      };

      root.innerHTML = `
      <div class="page-head">
        <div class="page-head__l">
          <div class="page-title">合同台账 <span class="tag tag--primary">md_contract</span></div>
          <div class="page-sub">三套旧合同（crm_contract / bus_contract / pmt_contract）统一至 md_contract · 含税 = 不含税 + 税额 · 数据截至 2026-11-10</div>
        </div>
        <div class="page-actions">
          <button class="btn" id="ctExport">${icon('download', 14)}导出</button>
          <button class="btn btn--primary" id="ctNew">${icon('plus', 14)}新建合同</button>
        </div>
      </div>

      <div class="grid grid--4">
        <div class="kpi"><div class="kpi-label">合同总额（不含待签约）</div><div class="kpi-value">${(totalIncl / 10000).toFixed(1)}<small>万</small></div><div class="kpi-foot">${signed.length} 份生效合同</div></div>
        <div class="kpi kpi--success"><div class="kpi-label">执行中合同</div><div class="kpi-value">${inProgress}<small>份</small></div><div class="kpi-foot">含税 ${wan(sum(M.contracts.filter(c => c.status === 'IN_PROGRESS'), c => c.incl))}</div></div>
        <div class="kpi kpi--warning"><div class="kpi-label">待签约</div><div class="kpi-value">${unsigned}<small>份</small></div><div class="kpi-foot">CT-2026-0088 · 框架协议</div></div>
        <div class="kpi kpi--info"><div class="kpi-label">整体回款率</div><div class="kpi-value">${pct(totalRecv / totalIncl)}</div><div class="kpi-foot">已回款 ${wan(totalRecv)}</div></div>
      </div>

      <div class="filter-bar">
        <div class="field"><span class="field-label">合同号 / 名称</span><input class="input" id="fCtKw" placeholder="合同号或名称" style="width:210px"></div>
        <div class="field"><span class="field-label">客户</span><select class="select" id="fCtCus" style="width:150px"><option value="">全部</option>${[...new Set(M.contracts.map(c => c.customer))].map(c => `<option>${esc(c)}</option>`).join('')}</select></div>
        <div class="field"><span class="field-label">合同状态</span><select class="select" id="fCtStatus" style="width:120px"><option value="">全部</option><option value="DRAFT">草稿</option><option value="UNSIGNED">待签约</option><option value="SIGNED">已签约</option><option value="IN_PROGRESS">执行中</option><option value="COMPLETED">已完成</option></select></div>
        <div class="field"><span class="field-label">合同类型</span><select class="select" id="fCtType" style="width:120px"><option value="">全部</option><option>主合同</option><option>框架协议</option><option>补充协议</option></select></div>
        <div class="field"><button class="btn btn--primary" id="fCtSearch">${icon('search', 14)}查询</button><button class="btn" id="fCtReset">重置</button></div>
      </div>

      <div class="panel">
        <div class="panel-head"><h3>${icon('receipt', 16)}合同台账</h3><span class="mini" id="ctTotal"></span></div>
        <div class="panel-body panel-body--flush">
          <div class="table-wrap"><table class="table">
            <thead><tr><th>合同号</th><th>合同名称</th><th>客户</th><th class="num">含税金额</th><th class="num">不含税金额</th><th>签约日期</th><th>状态</th><th class="num">已开票</th><th class="num">已回款</th><th>回款进度</th><th class="center">操作</th></tr></thead>
            <tbody id="ctBody"></tbody>
          </table></div>
        </div>
        <div class="panel-foot"><span class="mini">金额单位：元；回款进度 = 已回款 / 含税金额</span><div class="pager" id="ctPager"></div></div>
      </div>

      <div class="alert">${icon('info', 15)}<span>数据治理说明：三套旧合同（crm_contract / bus_contract / pmt_contract）已统一到 <b>md_contract</b>，统一口径 <b>含税 = 不含税 + 税额</b>，旧合同号保留在 legacy_contract_no。</span></div>`;

      const bind = () => {
        state.kw = root.querySelector('#fCtKw').value;
        state.customer = root.querySelector('#fCtCus').value;
        state.status = root.querySelector('#fCtStatus').value;
        state.type = root.querySelector('#fCtType').value;
        state.page = 1; draw();
      };
      root.querySelector('#fCtSearch').addEventListener('click', bind);
      root.querySelector('#fCtKw').addEventListener('keyup', e => { if (e.key === 'Enter') bind(); });
      ['#fCtCus', '#fCtStatus', '#fCtType'].forEach(sel => root.querySelector(sel).addEventListener('change', bind));
      root.querySelector('#fCtReset').addEventListener('click', () => {
        root.querySelector('#fCtKw').value = '';
        root.querySelector('#fCtCus').value = '';
        root.querySelector('#fCtStatus').value = '';
        root.querySelector('#fCtType').value = '';
        bind();
      });
      root.querySelector('#ctExport').addEventListener('click', () => LY.toast('合同台账已导出（xlsx）', 'info'));
      root.querySelector('#ctNew').addEventListener('click', openNewContractModal);
      draw();
    }
  });

  /* ---------------- 合同详情 ---------------- */
  const PAY_COND = {
    CM1: '签约后 10 个工作日内支付',
    CM2: '蓝图确认签认后 15 个工作日内支付',
    CM3: '上线验收通过后 30 日内支付',
    CM4: '质保期满 30 日内支付'
  };

  function openChangeModal(ct) {
    LY.openModal({
      title: '合同变更 · ' + ct.id, width: 640,
      body: `<div class="alert" style="margin-bottom:14px">${icon('info', 15)}<span>补充协议通过 <b>parent_contract_id</b> + <b>contract_type = CHANGE</b> 建立版本链，原合同金额保持不变，变更金额单独累计。</span></div>
      <div class="form-grid">
        <div class="form-item"><label>变更类型</label><select class="select"><option>补充协议</option><option>变更申请</option></select></div>
        <div class="form-item"><label>变更标题 <span class="text-danger">*</span></label><input class="input" placeholder="如：新增数据治理范围"></div>
        <div class="form-item"><label>金额增减（元）</label><input class="input" placeholder="0.00"></div>
        <div class="form-item"><label>生效日期</label><input class="input" type="date" value="2026-11-10"></div>
        <div class="form-item" style="grid-column:1/-1"><label>变更说明</label><textarea class="textarea" placeholder="请说明变更背景、范围与影响"></textarea></div>
      </div>`,
      footer: `<button class="btn" data-close>取消</button><button class="btn btn--primary" id="okChange">提交变更</button>`,
      onMount(m) {
        m.querySelector('#okChange').addEventListener('click', () => {
          LY.closeModal();
          LY.toast('变更申请已提交审批 AP-2026-1025');
        });
      }
    });
  }

  LY.register('/contract/detail', {
    title: '合同详情',
    titleFor: q => (M.contracts.find(c => c.id === q.id) || M.contracts.find(c => c.id === 'CT-2026-0087')).name,
    crumb: ['合同管理', '合同台账', '合同详情'],
    render(root, query) {
      const ct = M.contracts.find(c => c.id === query.id) || M.contracts.find(c => c.id === 'CT-2026-0087');
      const ms = M.contractMilestones.filter(m => m.contractId === ct.id);
      const ps = M.projects.filter(p => p.contractId === ct.id);
      const ivs = M.invoices.filter(i => i.contract === ct.id);
      const rcs = M.receipts.filter(r => r.contract === ct.id);
      const isMain = ct.id === 'CT-2026-0087';
      const invPct = ct.incl ? ct.invoiced / ct.incl : 0;
      const payPct = ct.incl ? ct.received / ct.incl : 0;
      const TABS = [
        { key: 'base', name: '基本信息' },
        { key: 'lines', name: '合同行' },
        { key: 'milestone', name: '收款里程碑' },
        { key: 'change', name: '变更与补充协议', numb: isMain ? M.contractChanges.length : 0 },
        { key: 'invoice', name: '开票与回款' }
      ];

      const invTag = s => s === 'ISSUED' ? tag('已开具', 'success') : s === 'PARTIAL' ? tag('部分开票', 'warning') : s === 'NONE' ? tag('未开票', 'info') : tag(s || '-', 'info');

      const baseHtml = () => {
        const opp = M.opportunities.find(o => o.contractId === ct.id);
        return `<div class="panel panel--flat">
          <div class="panel-head"><h3>基本信息</h3><span class="mini">${tag(ct.type, 'info')} ${statusTag('contract', ct.status)}</span></div>
          <div class="panel-body" style="padding-top:4px">
            <div class="desc-grid desc-grid--2">
              <div class="desc-item"><span class="desc-label">合同号</span><span class="desc-value mono">${ct.id}</span></div>
              <div class="desc-item"><span class="desc-label">子合同号</span><span class="desc-value">${isMain ? 'CT-2026-0087-01' : '-'}</span></div>
              <div class="desc-item"><span class="desc-label">客户</span><span class="desc-value">${esc(ct.customer)}</span></div>
              <div class="desc-item"><span class="desc-label">关联商机</span><span class="desc-value">${opp ? `<span class="text-primary" style="cursor:pointer" onclick="LY.go('/opportunity')">${opp.id}</span>` : '<span class="text-muted">未关联商机</span>'}</span></div>
              <div class="desc-item"><span class="desc-label">签约日期</span><span class="desc-value">${ct.signDate || '未签约'}</span></div>
              <div class="desc-item"><span class="desc-label">合同周期</span><span class="desc-value">${ct.start} ~ ${ct.end}</span></div>
              <div class="desc-item"><span class="desc-label">归属组织</span><span class="desc-value">${esc(ct.org)}</span></div>
              <div class="desc-item"><span class="desc-label">产品线</span><span class="desc-value">${esc(ct.productLine)}</span></div>
              <div class="desc-item"><span class="desc-label">负责人</span><span class="desc-value">${esc(ct.owner)}</span></div>
              <div class="desc-item"><span class="desc-label">收款方式</span><span class="desc-value">按里程碑 / 银行转账</span></div>
            </div>
          </div>
        </div>

        <div class="panel panel--flat">
          <div class="panel-head"><h3>结构化付款条件</h3><span class="mini">含税合计 ${money(ct.incl)} · ${ms.length} 期</span></div>
          <div class="panel-body panel-body--flush">
            ${ms.length ? `<div class="table-wrap"><table class="table table--compact">
              <thead><tr><th>期次</th><th>付款节点</th><th class="num">比例</th><th class="num">含税金额</th><th>付款条件</th><th>计划回款</th></tr></thead>
              <tbody>${ms.map(m => `<tr>
                <td class="mono">${m.code}</td>
                <td class="strong">${esc(m.name)}</td>
                <td class="num">${pct(m.ratio, 0)}</td>
                <td class="num">${money(m.amount)}</td>
                <td class="text-muted" style="font-size:12px">${esc(PAY_COND[m.id] || '按合同约定')}</td>
                <td>${m.planPay}</td>
              </tr>`).join('')}
              <tr class="row-total"><td colspan="2">合计</td><td class="num">${pct(sum(ms, m => m.ratio), 0)}</td><td class="num">${money(sum(ms, m => m.amount))}</td><td colspan="2"></td></tr>
              </tbody></table></div>` : `<div class="empty">${icon('coins', 32)}该合同暂未维护付款条件</div>`}
          </div>
        </div>

        <div class="panel panel--flat">
          <div class="panel-head"><h3>合同-项目关联</h3><span class="mini">is_primary 标识主合同</span></div>
          <div class="panel-body panel-body--flush">
            ${ps.length ? `<div class="table-wrap"><table class="table table--compact">
              <thead><tr><th>项目编码</th><th>项目名称</th><th>项目经理</th><th>项目状态</th><th class="num">合同金额</th><th class="center">主合同</th></tr></thead>
              <tbody>${ps.map((p, i) => `<tr>
                <td class="mono">${p.id}</td>
                <td class="strong">${esc(p.name)}</td>
                <td>${esc(p.pm)}</td>
                <td>${statusTag('project', p.status)}</td>
                <td class="num">${money(p.contractAmount)}</td>
                <td class="center">${i === 0 ? tag('主合同', 'primary') : tag('子项目', 'info')}</td>
              </tr>`).join('')}</tbody></table></div>` : `<div class="empty">${icon('folder', 32)}暂无关联项目</div>`}
          </div>
        </div>`;
      };

      const linesHtml = () => isMain ? `<div class="panel panel--flat">
        <div class="panel-head"><h3>合同行</h3><span class="mini">共 ${M.contractLines.length} 行</span></div>
        <div class="panel-body panel-body--flush">
          <div class="table-wrap"><table class="table">
            <thead><tr><th>行号</th><th>名称</th><th>类型</th><th class="num">数量</th><th class="num">单价（元）</th><th class="num">含税金额</th><th>结算方式</th></tr></thead>
            <tbody>${M.contractLines.map(l => `<tr>
              <td class="mono">${l.no}</td>
              <td class="strong">${esc(l.name)}</td>
              <td>${tag(l.type, l.type === '软件' ? 'primary' : 'success')}</td>
              <td class="num">${num(l.qty)} ${esc(l.unit)}</td>
              <td class="num">${money(l.price)}</td>
              <td class="num strong">${money(l.amount)}</td>
              <td class="text-muted" style="font-size:12px">${esc(l.settle)}</td>
            </tr>`).join('')}
            <tr class="row-total"><td colspan="5">合计</td><td class="num">${money(sum(M.contractLines, l => l.amount))}</td><td></td></tr>
            </tbody></table></div>
        </div>
      </div>` : `<div class="panel panel--flat"><div class="panel-body"><div class="empty">${icon('list', 32)}该合同暂未维护合同行</div></div></div>`;

      const milestoneHtml = () => ms.length ? `<div class="panel panel--flat">
        <div class="panel-head"><h3>收款里程碑</h3><span class="mini">含税合计 ${money(ct.incl)}</span></div>
        <div class="panel-body panel-body--flush">
          <div class="table-wrap"><table class="table table--compact">
            <thead><tr><th>编码</th><th>名称</th><th>类型</th><th class="num">比例</th><th class="num">含税金额</th><th>计划开票</th><th>实际开票</th><th>计划回款</th><th>实际回款</th><th>开票状态</th><th>回款状态</th></tr></thead>
            <tbody>${ms.map(m => `<tr>
              <td class="mono">${m.code}</td>
              <td class="strong">${esc(m.name)}</td>
              <td>${tag(m.type, 'info')}</td>
              <td class="num">${pct(m.ratio, 0)}</td>
              <td class="num">${money(m.amount)}</td>
              <td>${m.planInvoice || '-'}</td>
              <td>${m.actualInvoice || '-'}</td>
              <td>${m.planPay || '-'}</td>
              <td>${m.actualPay || '-'}</td>
              <td>${invTag(m.invoiceStatus)}</td>
              <td>${statusTag('pay', m.payStatus)}</td>
            </tr>`).join('')}</tbody></table></div>
          <div class="panel-foot" style="display:block">
            <div style="display:flex;align-items:center;gap:10px;margin-bottom:8px">
              <span style="width:76px;font-size:12px;color:var(--ly-text-secondary)">开票进度</span>
              <div class="progress" style="flex:1"><div class="progress__bar" style="width:${(invPct * 100).toFixed(1)}%"></div></div>
              <span class="num" style="font-size:12px;width:52px;text-align:right">${pct(invPct)}</span>
            </div>
            <div style="display:flex;align-items:center;gap:10px">
              <span style="width:76px;font-size:12px;color:var(--ly-text-secondary)">回款进度</span>
              <div class="progress" style="flex:1"><div class="progress__bar progress__bar--success" style="width:${(payPct * 100).toFixed(1)}%"></div></div>
              <span class="num" style="font-size:12px;width:52px;text-align:right">${pct(payPct)}</span>
            </div>
          </div>
        </div>
      </div>` : `<div class="panel panel--flat"><div class="panel-body"><div class="empty">${icon('coins', 32)}该合同暂未维护收款里程碑</div></div></div>`;

      const changeHtml = () => isMain ? `
        <div class="panel panel--flat">
          <div class="panel-head"><h3>变更与补充协议</h3><div class="toolbar__r"><button class="btn btn--sm btn--primary" id="ctAddChange">${icon('plus', 13)}新增变更</button></div></div>
          <div class="panel-body panel-body--flush">
            <div class="table-wrap"><table class="table table--compact">
              <thead><tr><th>编号</th><th>类型</th><th>变更标题</th><th class="num">金额增减</th><th>生效日期</th><th>状态</th><th>发起人</th></tr></thead>
              <tbody>${M.contractChanges.map(c => `<tr>
                <td class="mono">${c.id}</td>
                <td>${tag(c.type, c.type === '补充协议' ? 'primary' : 'warning')}</td>
                <td class="strong">${esc(c.title)}</td>
                <td class="num ${c.amount > 0 ? 'text-danger' : ''}">${c.amount ? money(c.amount) : '-'}</td>
                <td>${c.date}</td>
                <td>${tag(c.status, c.status === '已签署' ? 'success' : c.status === '审批中' ? 'warning' : 'info')}</td>
                <td>${esc(c.owner)}</td>
              </tr>`).join('')}</tbody></table></div>
          </div>
          <div class="panel-foot"><span class="mini">补充协议通过 parent_contract_id / contract_type = CHANGE 建立版本链，原合同金额不变，变更金额单独累计</span></div>
        </div>` : `<div class="panel panel--flat"><div class="panel-body"><div class="empty">${icon('file', 32)}该合同暂无变更记录</div></div></div>`;

      const invoiceHtml = () => `
        <div class="panel panel--flat">
          <div class="panel-head"><h3>开票记录</h3><span class="mini">${ivs.length} 张 · 合计 ${money(sum(ivs.filter(i => i.status === 'ISSUED'), i => i.incl))}</span></div>
          <div class="panel-body panel-body--flush">
            ${ivs.length ? `<div class="table-wrap"><table class="table table--compact">
              <thead><tr><th>发票号</th><th>类型</th><th>开票日期</th><th class="num">不含税</th><th class="num">税额</th><th class="num">含税金额</th><th>状态</th><th>来源</th></tr></thead>
              <tbody>${ivs.map(i => `<tr>
                <td class="mono">${i.no}</td>
                <td>${esc(i.type)}</td>
                <td>${i.date}</td>
                <td class="num">${money(i.excl)}</td>
                <td class="num">${money(i.tax)}</td>
                <td class="num strong">${money(i.incl)}</td>
                <td>${statusTag('invoice', i.status)}</td>
                <td class="text-muted" style="font-size:12px">${esc(i.milestone || i.settlement || i.source)}</td>
              </tr>`).join('')}</tbody></table></div>` : `<div class="empty">${icon('receipt', 32)}暂无开票记录</div>`}
          </div>
        </div>
        <div class="panel panel--flat">
          <div class="panel-head"><h3>回款记录</h3><span class="mini">${rcs.length} 笔 · 合计 ${money(sum(rcs, r => r.amount))}</span></div>
          <div class="panel-body panel-body--flush">
            ${rcs.length ? `<div class="table-wrap"><table class="table table--compact">
              <thead><tr><th>收款单号</th><th>收款日期</th><th class="num">金额</th><th>方式</th><th>收款银行</th><th class="num">核销金额</th><th>关联发票</th><th>状态</th></tr></thead>
              <tbody>${rcs.map(r => `<tr>
                <td class="mono">${r.no}</td>
                <td>${r.date}</td>
                <td class="num strong">${money(r.amount)}</td>
                <td>${esc(r.method)}</td>
                <td class="text-muted" style="font-size:12px">${esc(r.bank)}</td>
                <td class="num">${money(r.writeOff)}</td>
                <td>${r.invoice ? `<span class="mono">${r.invoice}</span>` : '<span class="text-muted">-</span>'}</td>
                <td>${tag(r.status, r.status === '已核销' ? 'success' : 'warning')}</td>
              </tr>`).join('')}</tbody></table></div>` : `<div class="empty">${icon('wallet', 32)}暂无回款记录</div>`}
          </div>
        </div>`;

      const htmlOf = key => key === 'base' ? baseHtml() : key === 'lines' ? linesHtml() : key === 'milestone' ? milestoneHtml() : key === 'change' ? changeHtml() : invoiceHtml();

      root.innerHTML = `
      <div class="page-head">
        <div class="page-head__l">
          <div class="page-title">${esc(ct.name)} ${statusTag('contract', ct.status)} ${tag(ct.type, 'info')}</div>
          <div class="page-sub">${ct.id} · ${esc(ct.customer)} · 签约 ${ct.signDate || '未签约'} · 归属 ${esc(ct.org)}</div>
        </div>
        <div class="page-actions">
          <button class="btn" id="ctChangeBtn">${icon('edit', 14)}合同变更</button>
          <button class="btn" id="ctUpload">${icon('upload', 14)}上传附件</button>
          <button class="btn" id="ctPrint">${icon('file', 14)}打印</button>
        </div>
      </div>

      <div class="kpi-grid">
        <div class="kpi"><div class="kpi-label">含税金额</div><div class="kpi-value">${(ct.incl / 10000).toFixed(1)}<small>万</small></div><div class="kpi-foot">${money(ct.incl)} · 税率 ${pct(ct.taxRate, 0)}</div></div>
        <div class="kpi"><div class="kpi-label">不含税金额</div><div class="kpi-value">${(ct.excl / 10000).toFixed(1)}<small>万</small></div><div class="kpi-foot">${money(ct.excl)}</div></div>
        <div class="kpi kpi--info"><div class="kpi-label">税额</div><div class="kpi-value">${(ct.tax / 10000).toFixed(1)}<small>万</small></div><div class="kpi-foot">${money(ct.tax)}</div></div>
        <div class="kpi kpi--success"><div class="kpi-label">已开票</div><div class="kpi-value">${(ct.invoiced / 10000).toFixed(1)}<small>万</small></div><div class="kpi-foot">开票进度 ${pct(invPct)}</div></div>
        <div class="kpi kpi--success"><div class="kpi-label">已回款</div><div class="kpi-value">${(ct.received / 10000).toFixed(1)}<small>万</small></div><div class="kpi-foot">回款进度 ${pct(payPct)}</div></div>
        <div class="kpi kpi--warning"><div class="kpi-label">未回款</div><div class="kpi-value">${((ct.incl - ct.received) / 10000).toFixed(1)}<small>万</small></div><div class="kpi-foot">${money(ct.incl - ct.received)}</div></div>
      </div>

      <div class="panel">
        <div class="tabs" id="ctTabs">
          ${TABS.map((t, i) => `<div class="tabs__item ${i === 0 ? 'is-active' : ''}" data-tab="${t.key}">${t.name}${t.numb ? `<span class="numb">${t.numb}</span>` : ''}</div>`).join('')}
        </div>
        <div class="panel-body" id="ctTab" style="padding:14px;display:flex;flex-direction:column;gap:12px"></div>
      </div>`;

      const host = root.querySelector('#ctTab');
      const show = key => {
        root.querySelectorAll('#ctTabs .tabs__item').forEach(el => el.classList.toggle('is-active', el.dataset.tab === key));
        host.innerHTML = htmlOf(key);
        const add = host.querySelector('#ctAddChange');
        if (add) add.addEventListener('click', () => openChangeModal(ct));
      };
      root.querySelectorAll('#ctTabs .tabs__item').forEach(el => el.addEventListener('click', () => show(el.dataset.tab)));
      root.querySelector('#ctChangeBtn').addEventListener('click', () => openChangeModal(ct));
      root.querySelector('#ctUpload').addEventListener('click', () => LY.toast('附件上传已打开（原型演示）', 'info'));
      root.querySelector('#ctPrint').addEventListener('click', () => LY.toast('合同打印预览已生成（原型演示）', 'info'));
      show('base');
    }
  });

  /* ---------------- 登录（standalone） ---------------- */
  LY.register('/login', {
    title: '登录', standalone: true,
    render(app) {
      app.innerHTML = `
      <div class="login-page">
        <div class="login-container">
          <div class="login-left">
            <div class="login-brand">
              <div class="mark">链</div>
              <h1>链宇企业数字化平台</h1>
              <p>Lianyu Enterprise Digital Platform</p>
            </div>
            <div class="login-features">
              <div class="login-feature"><i>${icon('grid', 12)}</i><span>经营一体门户</span></div>
              <div class="login-feature"><i>${icon('link', 12)}</i><span>链路全流程闭环</span></div>
              <div class="login-feature"><i>${icon('shield', 12)}</i><span>统一主数据与权限</span></div>
            </div>
            <div class="footer">© 2026 链宇数字科技<br>经营一体门户 V3.0 · 保留所有权利</div>
          </div>
          <div class="login-right">
            <h2>欢迎登录</h2>
            <div class="sub">请输入账号密码登录经营一体门户</div>
            <div class="login-field"><label>账号</label><input class="input" id="lgUser" value="chenli" placeholder="请输入账号" autocomplete="username"></div>
            <div class="login-field"><label>密码</label><input class="input" id="lgPwd" type="password" value="ly@2026" placeholder="请输入密码" autocomplete="current-password"></div>
            <div class="login-opt">
              <label class="checkbox"><input type="checkbox" id="lgRemember" checked>记住我</label>
              <a href="javascript:;" id="lgForgot">忘记密码？</a>
            </div>
            <button class="btn btn--primary login-btn" id="lgBtn">登 录</button>
            <div class="login-tip">演示账号：chenli / ly@2026（原型无需真实校验）</div>
            <div class="login-copy">© 2026 链宇数字科技 · 经营一体门户 V3.0</div>
          </div>
        </div>
      </div>`;

      const submit = () => {
        const u = app.querySelector('#lgUser').value.trim();
        const p = app.querySelector('#lgPwd').value.trim();
        if (!u || !p) { LY.toast('请输入账号和密码', 'error'); return; }
        LY.toast('登录成功，欢迎 ' + M.user.name, 'info');
        LY.go('/home');
      };
      app.querySelector('#lgBtn').addEventListener('click', submit);
      app.querySelector('#lgPwd').addEventListener('keyup', e => { if (e.key === 'Enter') submit(); });
      app.querySelector('#lgUser').addEventListener('keyup', e => { if (e.key === 'Enter') submit(); });
      app.querySelector('#lgForgot').addEventListener('click', () => LY.toast('请联系系统管理员重置密码（原型演示）', 'info'));
    }
  });
})();
