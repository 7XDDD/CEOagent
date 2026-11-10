/* ================= 结算管理 N8 / 开票管理 N9 / 回款与应收 N10 ================= */
(function () {
  const LY = window.LY, M = LY.MOCK;
  const { icon, wan, money, pct, num, esc, tag, statusTag } = LY;
  const chart = (el, type, opt) => { if (!el) return; LY.chart[type](el, opt); LY.watchChart(el, type, opt); };
  const sum = (arr, f) => arr.reduce((a, b) => a + (f ? f(b) : b), 0);
  const r2 = n => Math.round(n * 100) / 100;

  /* ================= N8 结算管理 ================= */
  LY.register('/settlement', {
    title: '结算管理',
    crumb: ['结算与收款', '结算管理'],
    render(root) {
      const batches = M.settlementBatches;
      const octCust = sum(batches.filter(b => b.type === 'CUSTOMER' && b.month === '2026-10'), b => b.amount);
      const pendingCnt = batches.filter(b => b.status === 'PENDING').length;
      const settledCnt = batches.filter(b => b.status === 'SETTLED').length;
      const uninvAmt = sum(batches.filter(b => b.status === 'CONFIRMED' && !b.invoiced), b => b.amount);
      const priced = batches.filter(b => b.days > 0);
      const avgPrice = sum(priced, b => b.amount) / sum(priced, b => b.days);
      const state = { month: '', type: '', customer: '', status: '' };

      const openBatch = id => {
        const b = batches.find(x => x.id === id);
        const orders = M.settlementOrders.filter(o => o.batchId === id);
        const total = sum(orders, o => o.amount);
        const totalDays = sum(orders, o => o.days);
        const orderTable = orders.length ? `
          <div class="table-wrap"><table class="table table--compact">
            <thead><tr><th>结算单号</th><th>成员 / 角色</th><th class="num">结算天数</th><th class="num">结算单价</th><th class="num">结算金额</th><th>状态</th><th>关联发票</th><th class="center">操作</th></tr></thead>
            <tbody>
              ${orders.map((o, i) => `
                <tr>
                  <td class="mono">${o.id}</td>
                  <td><div class="strong" style="font-size:13px">${esc(o.employee)}</div><span class="sub">${esc(o.role)} · ${o.employeeId}</span></td>
                  <td class="num">${o.days}</td>
                  <td class="num">${money(o.price)}</td>
                  <td class="num strong">${money(o.amount)}</td>
                  <td>${statusTag('settlement', o.status)}</td>
                  <td>${o.invoiceId ? tag(o.invoiceId, 'primary') : '<span class="text-muted">-</span>'}</td>
                  <td class="center"><button class="link-btn" data-expand="${o.id}">工时明细</button></td>
                </tr>
                <tr data-sub="${o.id}" style="display:none">
                  <td colspan="8" style="background:#fafbfc;padding:10px 12px">
                    <div class="mini" style="margin-bottom:6px">锁定工时明细 · 折算天数 = 工时 ÷ 8 · 金额 = 折算天数 × 结算单价</div>
                    <table class="table table--compact">
                      <thead><tr><th>日期</th><th>工作内容</th><th class="num">工时</th><th class="num">折算天数</th><th class="num">金额</th></tr></thead>
                      <tbody>
                        ${M.timesheetItems.filter((_, k) => k % 4 === i).map(it => {
                          const d = it.hours / 8;
                          return `<tr><td>${it.date}</td><td class="text-muted" style="font-size:12px">${esc(it.content)}</td><td class="num">${it.hours}</td><td class="num">${d.toFixed(2)}</td><td class="num">${money(d * o.price)}</td></tr>`;
                        }).join('')}
                      </tbody>
                    </table>
                  </td>
                </tr>`).join('')}
              <tr class="row-total"><td colspan="2">合计 ${orders.length} 张结算单</td><td class="num">${totalDays}</td><td class="num">-</td><td class="num">${money(total)}</td><td colspan="3"></td></tr>
            </tbody>
          </table></div>` : `
          <div class="empty">${icon('receipt', 40)}该批次尚未生成结算单
            <div style="margin-top:12px"><button class="btn btn--primary btn--sm" id="genSo">生成结算单</button></div>
          </div>`;

        const body = `
          <div class="desc-grid desc-grid--2">
            <div class="desc-item"><span class="desc-label">批次号</span><span class="desc-value mono">${esc(b.no)}</span></div>
            <div class="desc-item"><span class="desc-label">批次类型</span><span class="desc-value">${statusTag('batch', b.type)}</span></div>
            <div class="desc-item"><span class="desc-label">结算月份</span><span class="desc-value">${b.month}</span></div>
            <div class="desc-item"><span class="desc-label">客户 / 供应商</span><span class="desc-value">${esc(b.customer)}${b.customerId ? ' · ' + b.customerId : ''}</span></div>
            <div class="desc-item"><span class="desc-label">项目</span><span class="desc-value">${esc(b.project)}</span></div>
            <div class="desc-item"><span class="desc-label">合同</span><span class="desc-value">${esc(b.contract || '-')}</span></div>
            <div class="desc-item"><span class="desc-label">结算期间</span><span class="desc-value">${b.start} ~ ${b.end}</span></div>
            <div class="desc-item"><span class="desc-label">总天数</span><span class="desc-value num">${b.days || '-'}</span></div>
            <div class="desc-item"><span class="desc-label">总金额</span><span class="desc-value money">${money(b.amount)}</span></div>
            <div class="desc-item"><span class="desc-label">已开票金额</span><span class="desc-value money">${money(b.invoiced || 0)}</span></div>
            <div class="desc-item"><span class="desc-label">状态</span><span class="desc-value">${statusTag('settlement', b.status)}</span></div>
            <div class="desc-item"><span class="desc-label">创建人 / 日期</span><span class="desc-value">${esc(b.owner)} · ${b.created}</span></div>
          </div>
          <div class="divider"></div>
          <div class="toolbar" style="margin-bottom:8px">
            <b style="font-size:14px">结算单列表</b>
            <span class="mini">批次 = 订单合计 · 已生成 ${orders.length} / ${b.orders || 0} 张</span>
          </div>
          ${orderTable}
          <div class="alert alert--info" style="margin-top:12px">${icon('info', 15)}<span>金额 = 结算天数 × 结算单价（md_billing_rate）；结算单生成后回写 invoice_id，同一工时明细仅结算一次。</span></div>
          ${orders.length ? `<div class="alert alert--success" style="margin-top:10px">${icon('check-circle', 15)}<span>本批次结算单合计 <b>${money(total)}</b>，与批次金额 <b>${money(b.amount)}</b> ${total === b.amount ? '一致 · 校验通过' : '存在差异，请核查'}。</span></div>` : ''}`;

        LY.openDrawer({
          title: '结算批次 · ' + b.no,
          width: 760,
          body,
          footer: `<button class="btn" data-close>关闭</button>${b.status === 'CONFIRMED' ? '<button class="btn btn--primary" id="dwInv">转开票</button>' : ''}`,
          onMount(d) {
            d.querySelectorAll('[data-expand]').forEach(btn => btn.addEventListener('click', () => {
              const tr = d.querySelector('[data-sub="' + btn.dataset.expand + '"]');
              const open = tr.style.display !== 'none';
              tr.style.display = open ? 'none' : '';
              btn.textContent = open ? '工时明细' : '收起明细';
            }));
            const gen = d.querySelector('#genSo');
            if (gen) gen.addEventListener('click', () => LY.toast('已按 SETTLE 工时生成 6 张结算单'));
            const dw = d.querySelector('#dwInv');
            if (dw) dw.addEventListener('click', () => openInvoice(b));
          }
        });
      };

      const openInvoice = b => {
        const orders = M.settlementOrders.filter(o => o.batchId === b.id);
        const cap = orders.length ? sum(orders, o => o.amount) : Math.max(b.amount - (b.invoiced || 0), 0);
        LY.openModal({
          title: '结算批次转开票 · ' + b.no,
          width: 620,
          body: `${orders.length ? `
            <div class="alert alert--info">${icon('info', 15)}<span>选择需开票的结算单，开票金额按勾选自动合计；开票金额 ≤ 可开票金额。</span></div>
            <div style="margin-top:10px">
              ${orders.map(o => `<label class="checkbox" style="display:flex;align-items:center;gap:8px;padding:9px 0;border-bottom:1px dashed #f0f2f5">
                <input type="checkbox" data-so data-amount="${o.amount}" checked>
                <span style="flex:1;min-width:0"><b style="font-weight:500">${o.id}</b> · ${esc(o.employee)} · ${esc(o.role)}</span>
                <span class="mini">${o.days} 天 × ${money(o.price)}</span>
                <b class="num" style="margin-left:10px">${money(o.amount)}</b>
              </label>`).join('')}
            </div>` : `<div class="empty">${icon('receipt', 40)}该批次尚未生成结算单，按批次金额开票</div>`}
            <div class="form-grid" style="margin-top:14px">
              <div class="form-item"><label>开票金额（含税）</label><input class="input" id="ivAmt" value="${cap.toFixed(2)}" readonly></div>
              <div class="form-item"><label>税率</label><select class="select" id="ivRate"><option value="0.06">6%</option><option value="0.13">13%</option></select></div>
              <div class="form-item"><label>发票类型</label><select class="select"><option>数电专票</option><option>数电普票</option></select></div>
              <div class="form-item"><label>开票日期</label><input class="input" type="date" value="2026-11-10"></div>
              <div class="form-item" style="grid-column:1/-1"><label>开票备注</label><input class="input" value="${esc(b.project)} · ${b.month} 结算"></div>
            </div>
            <div class="alert alert--warning">${icon('alert', 15)}<span>开票金额 ≤ 结算金额；发票行生成后回写 settlement_order_id，结算单状态转为已开票。</span></div>`,
          footer: `<button class="btn" data-close>取消</button><button class="btn btn--primary" id="okIv">开具发票</button>`,
          onMount(m) {
            const recalc = () => {
              let s = 0, n = 0;
              m.querySelectorAll('[data-so]').forEach(cb => { if (cb.checked) { s += Number(cb.dataset.amount); n++; } });
              m.querySelector('#ivAmt').value = s.toFixed(2);
              return { s, n };
            };
            m.querySelectorAll('[data-so]').forEach(cb => cb.addEventListener('change', recalc));
            m.querySelector('#okIv').addEventListener('click', () => {
              const { s, n } = orders.length ? recalc() : { s: cap, n: 0 };
              if (orders.length && !n) { LY.toast('请至少选择一张结算单', 'error'); return; }
              if (!s) { LY.toast('开票金额必须大于 0', 'error'); return; }
              LY.closeModal();
              LY.toast('发票已开具：INV-2026-0268，关联结算批次 ' + b.no);
            });
          }
        });
      };

      const bindRows = () => {
        root.querySelectorAll('[data-detail]').forEach(el => el.addEventListener('click', () => openBatch(el.dataset.detail)));
        root.querySelectorAll('[data-confirm]').forEach(el => el.addEventListener('click', () => {
          const b = batches.find(x => x.id === el.dataset.confirm);
          LY.confirm({
            title: '确认结算批次',
            okText: '确认批次',
            content: `确认批次 <b>${b.no}</b> 后，结算金额 <b>${money(b.amount)}</b> 将锁定，相关工时不可再调整。是否继续？`,
            onOk() { LY.toast('批次已确认，金额锁定'); }
          });
        }));
        root.querySelectorAll('[data-inv]').forEach(el => el.addEventListener('click', () => {
          openInvoice(batches.find(x => x.id === el.dataset.inv));
        }));
      };

      const draw = () => {
        const list = batches.filter(b =>
          (!state.month || b.month === state.month) &&
          (!state.type || b.type === state.type) &&
          (!state.customer || b.customer === state.customer) &&
          (!state.status || b.status === state.status));
        root.querySelector('#stbCount').textContent = `共 ${list.length} 个批次 · 合计 ${money(sum(list, b => b.amount))}`;
        root.querySelector('#stbBody').innerHTML = list.length ? list.map(b => `
          <tr>
            <td class="mono">${esc(b.no)}</td>
            <td>${statusTag('batch', b.type)}</td>
            <td>${b.month}</td>
            <td><div class="strong" style="font-size:13px">${esc(b.customer)}</div><span class="sub">${b.customerId || '供应商'}</span></td>
            <td>${esc(b.project)}<span class="sub">${esc(b.contract || '-')}</span></td>
            <td class="text-muted" style="font-size:12px">${b.start} ~ ${b.end}</td>
            <td class="num">${b.days || '-'}</td>
            <td class="num strong">${money(b.amount)}</td>
            <td>${statusTag('settlement', b.status)}</td>
            <td class="num">${b.invoiced ? money(b.invoiced) : '<span class="text-muted">0.00</span>'}</td>
            <td class="center">
              <button class="link-btn" data-detail="${b.id}">明细</button>
              ${['DRAFT', 'PENDING'].indexOf(b.status) > -1 ? `<button class="link-btn" data-confirm="${b.id}">确认</button>` : ''}
              ${b.status === 'CONFIRMED' ? `<button class="link-btn" data-inv="${b.id}">转开票</button>` : ''}
            </td>
          </tr>`).join('') : `<tr><td colspan="11"><div class="empty">${icon('coins', 40)}没有符合条件的结算批次</div></td></tr>`;
        bindRows();
      };

      root.innerHTML = `
      <div class="page-head">
        <div class="page-head__l">
          <div class="page-title">结算管理 <span class="tag tag--primary">N8</span></div>
          <div class="page-sub">锁定且可结算工时 → 结算批次 → 结算单 → 金额自动计算 → 转开票</div>
        </div>
        <div class="page-actions">
          <button class="btn" id="stbExport">${icon('download', 14)}导出</button>
          <button class="btn btn--primary" id="stbNew">${icon('plus', 14)}新建结算批次</button>
        </div>
      </div>

      <div class="kpi-grid">
        <div class="kpi"><div class="kpi-label">本月结算额</div><div class="kpi-value">${(octCust / 10000).toFixed(1)}<small>万</small></div><div class="kpi-foot">客户结算 3 个批次 · 供应商另计 18.0 万</div></div>
        <div class="kpi kpi--warning"><div class="kpi-label">待确认批次</div><div class="kpi-value">${pendingCnt}<small>个</small></div><div class="kpi-foot">草稿 1 · 待确认 ${pendingCnt} · 已确认 2</div></div>
        <div class="kpi kpi--success"><div class="kpi-label">已结算批次</div><div class="kpi-value">${settledCnt}<small>个</small></div><div class="kpi-foot">STB-202609-CUST-04 · 229,000.00</div></div>
        <div class="kpi kpi--info"><div class="kpi-label">未开票金额</div><div class="kpi-value">${(uninvAmt / 10000).toFixed(1)}<small>万</small></div><div class="kpi-foot">已确认且未开票 1 个批次</div></div>
        <div class="kpi"><div class="kpi-label">结算工时</div><div class="kpi-value">9,860<small>h</small></div><div class="kpi-foot">折算 1,232.5 人天 · 5 个批次</div></div>
        <div class="kpi"><div class="kpi-label">平均结算单价</div><div class="kpi-value">${money(avgPrice)}<small>元/人天</small></div><div class="kpi-foot">批次金额 ÷ 结算天数（加权）</div></div>
      </div>

      <div class="filter-bar">
        <div class="field"><span class="field-label">结算月份</span><select class="select" id="fMonth" style="width:130px"><option value="">全部</option><option value="2026-10">2026-10</option><option value="2026-09">2026-09</option></select></div>
        <div class="field"><span class="field-label">批次类型</span><select class="select" id="fType" style="width:140px"><option value="">全部</option><option value="CUSTOMER">客户结算</option><option value="SUPPLIER">供应商结算</option></select></div>
        <div class="field"><span class="field-label">客户</span><select class="select" id="fCus" style="width:190px"><option value="">全部</option>${[...new Set(batches.map(b => b.customer))].map(c => `<option>${esc(c)}</option>`).join('')}</select></div>
        <div class="field"><span class="field-label">状态</span><select class="select" id="fStatus" style="width:120px"><option value="">全部</option><option value="DRAFT">草稿</option><option value="PENDING">待确认</option><option value="CONFIRMED">已确认</option><option value="SETTLED">已结算</option><option value="CANCELLED">已取消</option></select></div>
        <div class="field"><button class="btn" id="fReset">重置</button></div>
      </div>

      <div class="panel">
        <div class="panel-head"><h3>${icon('coins', 16)}结算批次</h3><span class="mini" id="stbCount"></span></div>
        <div class="panel-body panel-body--flush">
          <div class="table-wrap"><table class="table">
            <thead><tr><th>批次号</th><th>类型</th><th>结算月份</th><th>客户 / 供应商</th><th>项目</th><th>结算期间</th><th class="num">总天数</th><th class="num">总金额</th><th>状态</th><th class="num">已开票金额</th><th class="center">操作</th></tr></thead>
            <tbody id="stbBody"></tbody>
          </table></div>
        </div>
        <div class="panel-foot"><span class="mini">金额 = 结算天数 × 结算单价（md_billing_rate）· 行合计 = 批次合计</span><span class="tag tag--success">口径校验通过</span></div>
      </div>

      <div class="alert alert--info">${icon('info', 15)}<span>结算资格 = 工时 locked=1 + 未结算 + 成员 work_nature=SETTLE；一条工时明细只能结算一次；批次金额 = 结算单合计。</span></div>`;

      const bindFilter = () => {
        state.month = root.querySelector('#fMonth').value;
        state.type = root.querySelector('#fType').value;
        state.customer = root.querySelector('#fCus').value;
        state.status = root.querySelector('#fStatus').value;
        draw();
      };
      ['#fMonth', '#fType', '#fCus', '#fStatus'].forEach(sel => {
        root.querySelector(sel).addEventListener('change', bindFilter);
      });
      root.querySelector('#fReset').addEventListener('click', () => {
        ['#fMonth', '#fType', '#fCus', '#fStatus'].forEach(sel => { root.querySelector(sel).value = ''; });
        bindFilter();
      });
      root.querySelector('#stbExport').addEventListener('click', () => LY.toast('结算批次已导出（xlsx）', 'info'));
      root.querySelector('#stbNew').addEventListener('click', () => {
        LY.openModal({
          title: '新建结算批次',
          width: 660,
          body: `<div class="alert alert--info">${icon('info', 15)}<span>批次创建后自动汇总符合条件的锁定工时，生成结算单后金额方可确认。</span></div>
          <div class="form-grid" style="margin-top:14px">
            <div class="form-item"><label>批次类型 <span class="text-danger">*</span></label><select class="select"><option>CUSTOMER 客户结算</option><option>SUPPLIER 供应商结算</option></select></div>
            <div class="form-item"><label>结算月份 <span class="text-danger">*</span></label><select class="select"><option>2026-10</option><option>2026-09</option><option>2026-11</option></select></div>
            <div class="form-item"><label>客户 <span class="text-danger">*</span></label><select class="select">${M.customers.map(c => `<option>${esc(c.name)}</option>`).join('')}</select></div>
            <div class="form-item"><label>项目 <span class="text-danger">*</span></label><select class="select">${M.projects.map(p => `<option>${esc(p.name)}</option>`).join('')}</select></div>
            <div class="form-item"><label>开始日期</label><input class="input" type="date" value="2026-11-01"></div>
            <div class="form-item"><label>结束日期</label><input class="input" type="date" value="2026-11-30"></div>
            <div class="form-item" style="grid-column:1/-1"><label>结算对象说明</label><textarea class="textarea">按 2026-11 锁定工时生成结算单，仅包含 work_nature=SETTLE 成员。</textarea></div>
          </div>`,
          footer: `<button class="btn" data-close>取消</button><button class="btn btn--primary" id="okStb">创建批次</button>`,
          onMount(m) {
            m.querySelector('#okStb').addEventListener('click', () => {
              LY.closeModal();
              LY.toast('结算批次已创建：STB-202611-CUST-01');
            });
          }
        });
      });

      draw();
    }
  });

  /* ================= N9 开票管理 ================= */
  LY.register('/invoice', {
    title: '开票管理',
    crumb: ['结算与收款', '开票管理'],
    render(root) {
      const invoices = M.invoices;
      const issued = invoices.filter(i => i.status === 'ISSUED');
      const mainIssued = issued.filter(i => i.contract === 'CT-2026-0087');
      const issuedIncl = sum(mainIssued, i => i.incl);
      const contractIncl = 8600000;
      const remain = contractIncl - issuedIncl;
      const monthIncl = sum(issued.filter(i => i.date.slice(0, 7) === '2026-10' && i.customerId === 'CUS-0001'), i => i.incl);
      const received = sum(M.receipts.filter(r => r.customerId === 'CUS-0001'), r => r.amount);
      const redCnt = invoices.filter(i => i.status === 'RED_FLUSH').length;
      const state = { kw: '', customer: '', source: '', status: '', from: '', to: '' };

      const sourceTag = inv => inv.source === '里程碑'
        ? tag(inv.milestone || '里程碑', 'primary')
        : inv.source === '结算单'
          ? tag(inv.settlement || '结算单', 'primary')
          : tag('其他', 'info');

      const invLines = inv => {
        const total = sum(M.contractLines, l => l.amount);
        let acc = 0;
        return M.contractLines.map((l, i) => {
          const last = i === M.contractLines.length - 1;
          const amt = last ? r2(inv.excl - acc) : r2(inv.excl * l.amount / total);
          acc = r2(acc + amt);
          return { line: l, amt };
        });
      };

      const openDetail = inv => {
        const ctr = M.contracts.find(c => c.id === inv.contract) || {};
        const ms = M.contractMilestones.find(x => x.contractId === inv.contract && inv.milestone && inv.milestone.indexOf(x.code) === 0) || null;
        const batch = inv.settlement ? M.settlementBatches.find(b => b.no === inv.settlement) : null;
        const capAmt = ms ? ms.amount : batch ? batch.amount : (ctr.incl || inv.incl);
        const capName = ms ? `里程碑 ${ms.code}` : batch ? `结算批次 ${batch.no}` : '合同';
        const capDesc = ms ? `${ms.code} ${ms.name}` : batch ? batch.project : (ctr.name || '无关联合同');
        const capMeta = ms ? `计划开票 ${ms.planInvoice} · 已开票 ${money(sum(issued.filter(i => i.contract === ms.contractId && i.milestone && i.milestone.indexOf(ms.code) === 0), i => i.incl))}`
          : batch ? `${batch.start} ~ ${batch.end} · ${batch.orders} 张结算单`
            : `合同含税 ${money(ctr.incl || 0)}`;
        const ok = inv.incl <= capAmt + 0.005;
        const lines = invLines(inv);

        const body = `
          <div class="desc-grid desc-grid--3">
            <div class="desc-item"><span class="desc-label">发票号</span><span class="desc-value mono">${esc(inv.no)}</span></div>
            <div class="desc-item"><span class="desc-label">客户</span><span class="desc-value">${esc(inv.customer)}</span></div>
            <div class="desc-item"><span class="desc-label">状态</span><span class="desc-value">${statusTag('invoice', inv.status)}</span></div>
            <div class="desc-item"><span class="desc-label">合同</span><span class="desc-value">${esc(inv.contract)}</span></div>
            <div class="desc-item"><span class="desc-label">项目</span><span class="desc-value">${esc(inv.project)}</span></div>
            <div class="desc-item"><span class="desc-label">来源</span><span class="desc-value">${sourceTag(inv)}</span></div>
            <div class="desc-item"><span class="desc-label">发票类型</span><span class="desc-value">${esc(inv.type)}</span></div>
            <div class="desc-item"><span class="desc-label">开票日期</span><span class="desc-value">${inv.date}</span></div>
            <div class="desc-item"><span class="desc-label">税率</span><span class="desc-value">${(inv.rate * 100).toFixed(0)}%</span></div>
            <div class="desc-item"><span class="desc-label">不含税金额</span><span class="desc-value money">${money(inv.excl)}</span></div>
            <div class="desc-item"><span class="desc-label">税额</span><span class="desc-value money">${money(inv.tax)}</span></div>
            <div class="desc-item"><span class="desc-label">含税金额</span><span class="desc-value money">${money(inv.incl)}</span></div>
            <div class="desc-item"><span class="desc-label">已回款</span><span class="desc-value money">${money(inv.received)}</span></div>
            <div class="desc-item"><span class="desc-label">红冲原票</span><span class="desc-value">${inv.redFlushOf ? esc(inv.redFlushOf) : '-'}</span></div>
            <div class="desc-item"><span class="desc-label">开票人</span><span class="desc-value">刘芳 · 财务中心</span></div>
          </div>
          <div class="divider"></div>
          <div class="toolbar" style="margin-bottom:8px"><b style="font-size:14px">发票行</b><span class="mini">行合计 = 头合计（不含税）</span></div>
          <div class="table-wrap"><table class="table table--compact">
            <thead><tr><th>行号</th><th>合同行</th><th>类型</th><th class="num">数量</th><th class="num">不含税金额</th><th class="num">税额</th><th class="num">含税金额</th></tr></thead>
            <tbody>
              ${lines.map(({ line, amt }, i) => `<tr>
                <td>${i + 1}</td><td class="strong">${esc(line.name)}</td><td>${esc(line.type)}</td>
                <td class="num">${line.qty}${esc(line.unit)}</td>
                <td class="num">${money(amt)}</td><td class="num">${money(amt * inv.rate)}</td><td class="num">${money(amt * (1 + inv.rate))}</td>
              </tr>`).join('')}
              <tr class="row-total"><td colspan="4">合计</td><td class="num">${money(inv.excl)}</td><td class="num">${money(inv.tax)}</td><td class="num">${money(inv.incl)}</td></tr>
            </tbody>
          </table></div>
          <div class="mini" style="margin-top:6px">行合计 ${money(inv.excl)} = 头合计 ${money(inv.excl)} ${tag('校验通过', 'success')}</div>

          <div class="divider"></div>
          <div class="toolbar" style="margin-bottom:8px"><b style="font-size:14px">三单匹配</b><span class="mini">合同 → 里程碑 / 结算单 → 发票</span></div>
          <div style="display:flex;align-items:stretch;gap:8px;flex-wrap:wrap">
            <div class="panel panel--flat" style="flex:1;min-width:150px;padding:10px 12px;border-color:#dbe7ff">
              <div class="mini">合同</div>
              <div style="font-size:13px;font-weight:600;margin-top:2px">${esc(inv.contract)}</div>
              <div class="num" style="font-size:13px;margin-top:4px">${money(ctr.incl || 0)}</div>
              <div class="mini" style="margin-top:2px">${esc(ctr.name || '-')}</div>
            </div>
            <div style="display:flex;align-items:center;color:#c0c4cc;flex-shrink:0">${icon('arrow-right', 16)}</div>
            <div class="panel panel--flat" style="flex:1;min-width:150px;padding:10px 12px">
              <div class="mini">${ms ? '里程碑' : batch ? '结算单' : '来源'}</div>
              <div style="font-size:13px;font-weight:600;margin-top:2px">${esc(capDesc)}</div>
              <div class="num" style="font-size:13px;margin-top:4px">${money(capAmt)}</div>
              <div class="mini" style="margin-top:2px">${esc(capMeta)}</div>
            </div>
            <div style="display:flex;align-items:center;color:#c0c4cc;flex-shrink:0">${icon('arrow-right', 16)}</div>
            <div class="panel panel--flat" style="flex:1;min-width:150px;padding:10px 12px;border-color:#d6e2ff">
              <div class="mini">发票</div>
              <div style="font-size:13px;font-weight:600;margin-top:2px">${esc(inv.no)}</div>
              <div class="num" style="font-size:13px;margin-top:4px">${money(inv.incl)}</div>
              <div class="mini" style="margin-top:2px">${inv.date} · ${esc(inv.type)}</div>
            </div>
          </div>
          <div class="alert ${ok ? 'alert--success' : 'alert--danger'}" style="margin-top:10px">${icon(ok ? 'check-circle' : 'alert', 15)}<span>校验：开票金额 ${money(inv.incl)} ${ok ? '≤' : '＞'} ${capName} 金额 ${money(capAmt)} ${ok ? '· 通过' : '· 超额，需先变更合同或调整开票金额'}。</span></div>
          ${inv.redFlushOf ? `<div class="alert alert--warning" style="margin-top:8px">${icon('alert', 15)}<span>该发票为红字发票，关联原发票 ${esc(inv.redFlushOf)}（red_flush_of）。</span></div>` : ''}`;

        LY.openDrawer({
          title: '发票详情 · ' + inv.no,
          width: 760,
          body,
          footer: `<button class="btn" data-close>关闭</button><button class="btn btn--primary" id="invPrint">打印发票</button>`,
          onMount(d) {
            d.querySelector('#invPrint').addEventListener('click', () => LY.toast('发票 ' + inv.no + ' 已推送打印队列', 'info'));
          }
        });
      };

      const openRedFlush = inv => {
        LY.confirm({
          title: '红冲发票',
          danger: true,
          okText: '确认红冲',
          content: `确认对发票 <b>${inv.no}</b>（含税 ${money(inv.incl)}）开具红字发票？红冲后原发票状态更新为「已红冲」。`,
          onOk() {
            LY.openModal({
              title: '填写红冲原因 · ' + inv.no,
              width: 520,
              body: `<div class="form-grid">
                <div class="form-item"><label>红冲原因 <span class="text-danger">*</span></label><select class="select"><option>开票信息有误（金额 / 税率）</option><option>客户退票重开</option><option>合同变更 / 终止</option><option>其他</option></select></div>
                <div class="form-item"><label>红冲日期</label><input class="input" type="date" value="2026-11-10"></div>
                <div class="form-item" style="grid-column:1/-1"><label>原因说明</label><textarea class="textarea" placeholder="请说明红冲事由，需与客户确认一致"></textarea></div>
              </div>
              <div class="alert alert--warning">${icon('alert', 15)}<span>红冲发票必须关联原发票（red_flush_of=${esc(inv.no)}），且不可再次红冲。</span></div>`,
              footer: `<button class="btn" data-close>取消</button><button class="btn btn--danger" id="okRed">开具红字发票</button>`,
              onMount(m) {
                m.querySelector('#okRed').addEventListener('click', () => {
                  LY.closeModal();
                  LY.toast(`红冲发票已开具：INV-2026-0269，原发票 ${inv.no} 状态更新为已红冲`);
                });
              }
            });
          }
        });
      };

      const bindRows = () => {
        root.querySelectorAll('[data-view]').forEach(el => el.addEventListener('click', () => {
          openDetail(invoices.find(i => i.id === el.dataset.view));
        }));
        root.querySelectorAll('[data-red]').forEach(el => el.addEventListener('click', () => {
          openRedFlush(invoices.find(i => i.id === el.dataset.red));
        }));
      };

      const draw = () => {
        const list = invoices.filter(inv =>
          (!state.kw || inv.no.indexOf(state.kw) > -1 || inv.contract.indexOf(state.kw) > -1) &&
          (!state.customer || inv.customerId === state.customer) &&
          (!state.source || inv.source === state.source) &&
          (!state.status || inv.status === state.status) &&
          (!state.from || inv.date >= state.from) &&
          (!state.to || inv.date <= state.to));
        root.querySelector('#invCount').textContent = `共 ${list.length} 张 · 含税合计 ${money(sum(list, i => i.incl))}`;
        root.querySelector('#invBody').innerHTML = list.length ? list.map(inv => `
          <tr>
            <td><div class="strong mono">${esc(inv.no)}</div>${inv.redFlushOf ? `<span class="sub">原票 ${esc(inv.redFlushOf)}</span>` : ''}</td>
            <td>${esc(inv.customer)}</td>
            <td><div style="font-size:13px">${esc(inv.contract)}</div><span class="sub">${esc(inv.project)}</span></td>
            <td>${sourceTag(inv)}</td>
            <td>${inv.date}</td>
            <td class="num">${money(inv.excl)}</td>
            <td class="num">${(inv.rate * 100).toFixed(0)}%</td>
            <td class="num">${money(inv.tax)}</td>
            <td class="num strong">${money(inv.incl)}</td>
            <td>${statusTag('invoice', inv.status)}</td>
            <td class="num">${money(inv.received)}</td>
            <td class="center">
              <button class="link-btn" data-view="${inv.id}">查看</button>
              ${inv.status === 'ISSUED' ? `<button class="link-btn link-btn--danger" data-red="${inv.id}">红冲</button>` : '<span class="text-muted" style="font-size:12px">-</span>'}
            </td>
          </tr>`).join('') : `<tr><td colspan="12"><div class="empty">${icon('receipt', 40)}没有符合条件的发票</div></td></tr>`;
        bindRows();
      };

      root.innerHTML = `
      <div class="page-head">
        <div class="page-head__l">
          <div class="page-title">开票管理 <span class="tag tag--primary">N9</span></div>
          <div class="page-sub">按合同里程碑 / 结算单开票 · 金额校验 · 红冲</div>
        </div>
        <div class="page-actions">
          <button class="btn" id="invByOrder">${icon('receipt', 14)}按结算单开票</button>
          <button class="btn btn--primary" id="invByMs">${icon('flag', 14)}按里程碑开票</button>
        </div>
      </div>

      <div class="kpi-grid">
        <div class="kpi"><div class="kpi-label">已开票金额</div><div class="kpi-value">${(issuedIncl / 10000).toFixed(1)}<small>万</small></div><div class="kpi-foot">主合同 CT-2026-0087 · ${mainIssued.length} 张 · 含税</div></div>
        <div class="kpi kpi--warning"><div class="kpi-label">待开票金额</div><div class="kpi-value">${(remain / 10000).toFixed(1)}<small>万</small></div><div class="kpi-foot">主合同 860.0 万 − 已开 ${(issuedIncl / 10000).toFixed(1)} 万</div></div>
        <div class="kpi kpi--info"><div class="kpi-label">本月开票</div><div class="kpi-value">${(monthIncl / 10000).toFixed(1)}<small>万</small></div><div class="kpi-foot">华润数科 2 张 · 2026-10</div></div>
        <div class="kpi kpi--success"><div class="kpi-label">已回款</div><div class="kpi-value">${(received / 10000).toFixed(1)}<small>万</small></div><div class="kpi-foot">回款率 ${pct(received / issuedIncl)}</div></div>
        <div class="kpi kpi--danger"><div class="kpi-label">红冲发票</div><div class="kpi-value">${redCnt}<small>张</small></div><div class="kpi-foot">INV-2026-0166 · 原票 INV-2026-0142</div></div>
        <div class="kpi"><div class="kpi-label">开票率</div><div class="kpi-value">${pct(issuedIncl / contractIncl)}</div><div class="kpi-foot">目标 80% · 缺口 14.1pt</div></div>
      </div>

      <div class="filter-bar">
        <div class="field"><span class="field-label">发票号</span><input class="input" id="fKw" placeholder="发票号 / 合同号" style="width:180px"></div>
        <div class="field"><span class="field-label">客户</span><select class="select" id="fCus" style="width:150px"><option value="">全部</option>${[...new Set(invoices.map(i => i.customerId))].map(id => {
          const c = M.customers.find(x => x.id === id);
          return `<option value="${id}">${esc(c ? c.short : id)}</option>`;
        }).join('')}</select></div>
        <div class="field"><span class="field-label">来源</span><select class="select" id="fSource" style="width:120px"><option value="">全部</option><option>里程碑</option><option>结算单</option><option>其他</option></select></div>
        <div class="field"><span class="field-label">状态</span><select class="select" id="fStatus" style="width:120px"><option value="">全部</option><option value="DRAFT">草稿</option><option value="ISSUED">已开具</option><option value="VOID">已作废</option><option value="RED_FLUSH">已红冲</option></select></div>
        <div class="field"><span class="field-label">开票日期</span><input class="input" type="date" id="fFrom" style="width:140px"><span class="text-muted">至</span><input class="input" type="date" id="fTo" style="width:140px"></div>
        <div class="field"><button class="btn" id="fReset">重置</button></div>
      </div>

      <div class="panel">
        <div class="panel-head"><h3>${icon('receipt', 16)}发票台账</h3><span class="mini" id="invCount"></span></div>
        <div class="panel-body panel-body--flush">
          <div class="table-wrap"><table class="table">
            <thead><tr><th>发票号</th><th>客户</th><th>合同 / 项目</th><th>来源</th><th>开票日期</th><th class="num">不含税金额</th><th class="num">税率</th><th class="num">税额</th><th class="num">含税金额</th><th>状态</th><th class="num">已回款</th><th class="center">操作</th></tr></thead>
            <tbody id="invBody"></tbody>
          </table></div>
        </div>
        <div class="panel-foot"><span class="mini">发票号唯一 · 行合计 = 头合计 · 开票 ≤ 里程碑 / 结算金额</span><span class="tag tag--primary">三单匹配</span></div>
      </div>

      <div class="alert alert--info">${icon('info', 15)}<span>业务规则：发票号唯一；发票行合计 = 发票头合计；开票金额 ≤ 合同里程碑 / 结算单金额；红冲必须关联原发票（red_flush_of）。</span></div>`;

      const bindFilter = () => {
        state.kw = root.querySelector('#fKw').value.trim();
        state.customer = root.querySelector('#fCus').value;
        state.source = root.querySelector('#fSource').value;
        state.status = root.querySelector('#fStatus').value;
        state.from = root.querySelector('#fFrom').value;
        state.to = root.querySelector('#fTo').value;
        draw();
      };
      ['#fCus', '#fSource', '#fStatus', '#fFrom', '#fTo'].forEach(sel => {
        root.querySelector(sel).addEventListener('change', bindFilter);
      });
      root.querySelector('#fKw').addEventListener('keyup', e => { if (e.key === 'Enter') bindFilter(); });
      root.querySelector('#fReset').addEventListener('click', () => {
        ['#fKw', '#fCus', '#fSource', '#fStatus', '#fFrom', '#fTo'].forEach(sel => { root.querySelector(sel).value = ''; });
        bindFilter();
      });

      /* 按结算单开票 */
      root.querySelector('#invByOrder').addEventListener('click', () => {
        const orders = M.settlementOrders;
        const cap = sum(orders, o => o.amount);
        LY.openModal({
          title: '按结算单开票',
          width: 640,
          body: `<div class="alert alert--info">${icon('info', 15)}<span>勾选结算单后自动合计可开票金额，开票金额不得超过可开票金额。</span></div>
          <div style="margin-top:10px">
            ${orders.map(o => `<label class="checkbox" style="display:flex;align-items:center;gap:8px;padding:9px 0;border-bottom:1px dashed #f0f2f5">
              <input type="checkbox" data-si data-amount="${o.amount}" checked>
              <span style="flex:1;min-width:0"><b style="font-weight:500">${o.id}</b> · ${esc(o.employee)} · ${esc(o.role)}</span>
              <span class="mini">${o.days} 天 × ${money(o.price)}</span>
              <b class="num" style="margin-left:10px">${money(o.amount)}</b>
            </label>`).join('')}
          </div>
          <div class="form-grid" style="margin-top:14px">
            <div class="form-item"><label>可开票金额（含税）</label><input class="input" id="siCap" value="${cap.toFixed(2)}" readonly></div>
            <div class="form-item"><label>开票金额（含税）<span class="text-danger">*</span></label><input class="input" id="siAmt" type="number" value="${cap.toFixed(2)}"></div>
            <div class="form-item"><label>税率</label><select class="select" id="siRate"><option value="0.06">6%</option><option value="0.13">13%</option></select></div>
            <div class="form-item"><label>发票类型</label><select class="select"><option>数电专票</option><option>数电普票</option></select></div>
            <div class="form-item"><label>开票日期</label><input class="input" type="date" value="2026-11-10"></div>
            <div class="form-item"><label>开票主体</label><input class="input" value="链宇数字科技有限公司" readonly></div>
          </div>
          <div class="alert alert--warning">${icon('alert', 15)}<span>开票金额 ≤ 可开票金额；发票行将回写 settlement_order_id。</span></div>`,
          footer: `<button class="btn" data-close>取消</button><button class="btn btn--primary" id="okSi">开具发票</button>`,
          onMount(m) {
            const calcCap = () => {
              let s = 0, n = 0;
              m.querySelectorAll('[data-si]').forEach(cb => { if (cb.checked) { s += Number(cb.dataset.amount); n++; } });
              m.querySelector('#siCap').value = s.toFixed(2);
              return { s, n };
            };
            m.querySelectorAll('[data-si]').forEach(cb => cb.addEventListener('change', () => {
              m.querySelector('#siAmt').value = calcCap().s.toFixed(2);
            }));
            m.querySelector('#okSi').addEventListener('click', () => {
              const { s, n } = calcCap();
              const v = parseFloat(m.querySelector('#siAmt').value || 0);
              if (!n) { LY.toast('请至少选择一张结算单', 'error'); return; }
              if (!v || v <= 0) { LY.toast('请输入有效开票金额', 'error'); return; }
              if (v > s + 0.005) { LY.toast('开票金额不能大于可开票金额', 'error'); return; }
              LY.closeModal();
              LY.toast(`发票已开具：INV-2026-0268，关联结算单 ${n} 张`);
            });
          }
        });
      });

      /* 按里程碑开票 */
      root.querySelector('#invByMs').addEventListener('click', () => {
        const remainOf = ms => ms.amount - sum(issued.filter(i => i.contract === ms.contractId && i.milestone && i.milestone.indexOf(ms.code) === 0), i => i.incl);
        const defaultMs = M.contractMilestones.find(x => x.id === 'CM3') || M.contractMilestones[0];
        const initRemain = remainOf(defaultMs);
        LY.openModal({
          title: '按合同里程碑开票',
          width: 640,
          body: `<div class="form-item"><label>合同里程碑 <span class="text-danger">*</span></label>
            <select class="select" id="msSel">${M.contractMilestones.map(ms => `<option value="${ms.id}" ${ms.id === defaultMs.id ? 'selected' : ''}>${ms.code} ${esc(ms.name)} · 剩余 ${money(remainOf(ms))}</option>`).join('')}</select>
          </div>
          <div class="desc-grid desc-grid--3" id="msInfo" style="margin-bottom:4px">
            <div class="desc-item"><span class="desc-label">里程碑金额</span><span class="desc-value money">${money(defaultMs.amount)}</span></div>
            <div class="desc-item"><span class="desc-label">已开票</span><span class="desc-value money">${money(defaultMs.amount - initRemain)}</span></div>
            <div class="desc-item"><span class="desc-label">剩余可开</span><span class="desc-value money">${money(initRemain)}</span></div>
          </div>
          <div class="form-grid">
            <div class="form-item"><label>可开票金额（含税）</label><input class="input" id="msCap" value="${initRemain.toFixed(2)}" readonly></div>
            <div class="form-item"><label>本次开票金额（含税）<span class="text-danger">*</span></label><input class="input" id="msAmt" type="number" value="${initRemain.toFixed(2)}"></div>
            <div class="form-item"><label>税率</label><select class="select"><option value="0.06">6%</option><option value="0.13">13%</option></select></div>
            <div class="form-item"><label>发票类型</label><select class="select"><option>数电专票</option><option>数电普票</option></select></div>
            <div class="form-item"><label>开票日期</label><input class="input" type="date" value="2026-11-10"></div>
            <div class="form-item"><label>关联交付里程碑</label><select class="select"><option>D3 核心模块 UAT 通过</option><option>D4 系统上线验收</option><option>不关联</option></select></div>
          </div>
          <div class="alert alert--warning">${icon('alert', 15)}<span>本次开票金额 ≤ 里程碑剩余可开金额；开票后回写里程碑开票状态。</span></div>`,
          footer: `<button class="btn" data-close>取消</button><button class="btn btn--primary" id="okMs">开具发票</button>`,
          onMount(m) {
            const sel = m.querySelector('#msSel');
            const sync = () => {
              const ms = M.contractMilestones.find(x => x.id === sel.value);
              const rem = remainOf(ms);
              m.querySelector('#msInfo').innerHTML = `
                <div class="desc-item"><span class="desc-label">里程碑金额</span><span class="desc-value money">${money(ms.amount)}</span></div>
                <div class="desc-item"><span class="desc-label">已开票</span><span class="desc-value money">${money(ms.amount - rem)}</span></div>
                <div class="desc-item"><span class="desc-label">剩余可开</span><span class="desc-value money">${money(rem)}</span></div>`;
              m.querySelector('#msCap').value = rem.toFixed(2);
              m.querySelector('#msAmt').value = rem.toFixed(2);
            };
            sel.addEventListener('change', sync);
            m.querySelector('#okMs').addEventListener('click', () => {
              const ms = M.contractMilestones.find(x => x.id === sel.value);
              const rem = remainOf(ms);
              const v = parseFloat(m.querySelector('#msAmt').value || 0);
              if (!v || v <= 0) { LY.toast('请输入有效开票金额', 'error'); return; }
              if (v > rem + 0.005) { LY.toast('开票金额不能大于里程碑剩余可开金额', 'error'); return; }
              LY.closeModal();
              LY.toast(`发票已开具：INV-2026-0270，关联里程碑 ${ms.code} ${ms.name}`);
            });
          }
        });
      });

      draw();
    }
  });

  /* ================= N10 回款与应收 ================= */
  LY.register('/receivable', {
    title: '回款与应收',
    crumb: ['结算与收款', '回款与应收'],
    render(root) {
      const ar = M.summary.ar;
      const overdue = M.summary.overdue;
      const due30 = 1200000;
      const AGING = [
        { name: '未到期', count: 1, amount: 1200000, rate: 0 },
        { name: '0-30 天', count: 1, amount: 218000, rate: 0.01 },
        { name: '31-60 天', count: 1, amount: 96000, rate: 0.05 },
        { name: '61-90 天', count: 0, amount: 0, rate: 0.2 },
        { name: '90 天以上', count: 0, amount: 0, rate: 0.5 }
      ];
      const arCustomers = [...new Set(M.arBalances.map(a => a.customer))];
      const credit = M.customers.find(c => c.id === 'CUS-0002');
      const creditAvail = credit.creditLimit - credit.creditUsed;
      const addDays = (d, n) => new Date(new Date(d).getTime() + n * 86400000).toISOString().slice(0, 10);

      const listHtml = (rows, checkedAll) => rows.map(a => `
        <label class="checkbox" style="display:flex;align-items:center;gap:8px;padding:8px 0;border-bottom:1px dashed #f0f2f5">
          <input type="checkbox" data-wo="${a.invoice}" ${checkedAll ? 'checked' : ''}>
          <span style="flex:1;min-width:0">
            <span class="mono">${a.invoice}</span>
            <span class="mini">到期 ${a.due}${a.overdueDays ? ' · 逾期 ' + a.overdueDays + ' 天' : ''}</span>
          </span>
          <span class="mini">余额 <b class="num">${money(a.balance)}</b></span>
          <input class="input input--sm" type="number" style="width:126px" data-amt="${a.invoice}" value="${a.balance.toFixed(2)}">
        </label>`).join('');

      const openReceipt = cus => {
        const initRows = M.arBalances.filter(a => a.customer === cus);
        const initSum = sum(initRows, a => a.balance);
        LY.openModal({
          title: '登记收款',
          width: 680,
          body: `<div class="form-grid">
            <div class="form-item"><label>客户 <span class="text-danger">*</span></label><select class="select" id="rcpCus">${arCustomers.map(c => `<option ${c === cus ? 'selected' : ''}>${esc(c)}</option>`).join('')}</select></div>
            <div class="form-item"><label>收款日期</label><input class="input" type="date" value="2026-11-10"></div>
            <div class="form-item"><label>收款金额（元）<span class="text-danger">*</span></label><input class="input" id="rcpAmount" type="number" value="${initSum.toFixed(2)}"></div>
            <div class="form-item"><label>收款方式</label><select class="select"><option>银行转账</option><option>银行承兑汇票</option><option>现金</option></select></div>
            <div class="form-item"><label>收款银行</label><input class="input" value="招商银行深圳分行"></div>
            <div class="form-item"><label>收款账号（后四位）</label><input class="input" value="8821"></div>
          </div>
          <div class="divider"></div>
          <div class="toolbar" style="margin-bottom:4px"><b style="font-size:13px">核销发票</b><span class="mini" id="rcpSum"></span></div>
          <div id="rcpList">${listHtml(initRows, true)}</div>
          <div class="alert alert--info" style="margin-top:10px">${icon('info', 15)}<span>核销金额 ≤ 发票应收余额；一笔收款可核销多张发票，核销合计不得超过收款金额。</span></div>`,
          footer: `<button class="btn" data-close>取消</button><button class="btn btn--primary" id="okRcp">登记收款</button>`,
          onMount(m) {
            const sync = () => {
              let n = 0, s = 0;
              m.querySelectorAll('[data-wo]').forEach(cb => {
                if (!cb.checked) return;
                n++;
                const inp = m.querySelector('[data-amt="' + cb.dataset.wo + '"]');
                s += parseFloat(inp.value || 0);
              });
              m.querySelector('#rcpSum').innerHTML = `已核销 <b>${n}</b> 张 · 合计 <b class="num">${money(s)}</b>`;
              return { n, s };
            };
            const bindList = () => {
              m.querySelectorAll('[data-wo],[data-amt]').forEach(el => el.addEventListener('change', sync));
              sync();
            };
            bindList();
            m.querySelector('#rcpCus').addEventListener('change', e => {
              const rows = M.arBalances.filter(a => a.customer === e.target.value);
              m.querySelector('#rcpList').innerHTML = listHtml(rows, true);
              m.querySelector('#rcpAmount').value = sum(rows, a => a.balance).toFixed(2);
              bindList();
            });
            m.querySelector('#okRcp').addEventListener('click', () => {
              const { n, s } = sync();
              const amount = parseFloat(m.querySelector('#rcpAmount').value || 0);
              if (!n) { LY.toast('请至少选择一张待核销发票', 'error'); return; }
              if (!amount || amount <= 0) { LY.toast('请输入有效收款金额', 'error'); return; }
              if (s > amount + 0.005) { LY.toast('核销合计不能大于收款金额', 'error'); return; }
              LY.closeModal();
              LY.toast(`收款已登记：RCP-2026-0211，核销 ${n} 张发票`);
            });
          }
        });
      };

      const openCollect = row => {
        const hasOverdue = row.overdueDays > 0;
        const records = hasOverdue ? [
          { t: addDays(row.due, 1), title: '短信提醒', meta: '系统自动发送逾期提醒 · 客户对接人已接收' },
          { t: addDays(row.due, 7), title: '第一次催款函', meta: '邮件 + 纸质函件 · 客户确认收到' },
          { t: addDays(row.due, 15), title: '第二次催款函', meta: '抄送客户财务负责人 · 要求 5 个工作日内付款' }
        ] : [];
        LY.openDrawer({
          title: '催收 · ' + row.invoice,
          width: 620,
          body: `<div class="desc-grid desc-grid--2">
            <div class="desc-item"><span class="desc-label">客户</span><span class="desc-value">${esc(row.customer)}</span></div>
            <div class="desc-item"><span class="desc-label">发票号</span><span class="desc-value mono">${row.invoice}</span></div>
            <div class="desc-item"><span class="desc-label">开票金额</span><span class="desc-value money">${money(row.amount)}</span></div>
            <div class="desc-item"><span class="desc-label">应收余额</span><span class="desc-value money">${money(row.balance)}</span></div>
            <div class="desc-item"><span class="desc-label">到期日</span><span class="desc-value">${row.due}</span></div>
            <div class="desc-item"><span class="desc-label">逾期天数</span><span class="desc-value ${hasOverdue ? 'text-danger' : ''}">${hasOverdue ? row.overdueDays + ' 天' : '未逾期'}</span></div>
          </div>
          <div class="divider"></div>
          ${hasOverdue ? `<div class="timeline">
            ${records.map(r => `<div class="timeline__item is-done">
              <div class="timeline__title">${esc(r.title)} <span class="mini">${r.t}</span></div>
              <div class="timeline__meta">${esc(r.meta)}</div>
            </div>`).join('')}
          </div>
          <div class="form-item" style="margin-top:12px"><label>新增催收记录</label><textarea class="textarea" id="collectNote" placeholder="记录沟通对象、承诺付款时间与下一步动作"></textarea></div>` : `<div class="empty">${icon('check-circle', 40)}该发票未逾期，无需催收</div>`}
          <div class="alert alert--warning" style="margin-top:10px">${icon('alert', 15)}<span>逾期 90 天以上将计提坏账准备；催收记录同步至客户 360 视图。</span></div>`,
          footer: hasOverdue
            ? `<button class="btn" data-close>关闭</button><button class="btn btn--primary" id="saveCollect">保存催收记录</button>`
            : `<button class="btn" data-close>关闭</button><button class="btn btn--primary" id="sendRemind">发送到期提醒</button>`,
          onMount(d) {
            const save = d.querySelector('#saveCollect');
            if (save) save.addEventListener('click', () => { LY.closeDrawer(); LY.toast('催收记录已保存，已同步至客户 360'); });
            const remind = d.querySelector('#sendRemind');
            if (remind) remind.addEventListener('click', () => { LY.closeDrawer(); LY.toast('到期提醒已发送至客户对接人', 'info'); });
          }
        });
      };

      const bindRows = () => {
        root.querySelectorAll('[data-receipt]').forEach(el => el.addEventListener('click', () => {
          openReceipt(el.dataset.receipt);
        }));
        root.querySelectorAll('[data-collect]').forEach(el => el.addEventListener('click', () => {
          openCollect(M.arBalances.find(a => a.invoice === el.dataset.collect));
        }));
      };

      const arRows = M.arBalances.map(a => `
        <tr>
          <td class="mono">${a.invoice}</td>
          <td>${esc(a.customer)}</td>
          <td class="text-muted" style="font-size:12px">${esc(a.contract)}</td>
          <td>${esc(a.project)}</td>
          <td class="num">${money(a.amount)}</td>
          <td class="num">${money(a.writeOff)}</td>
          <td class="num strong">${money(a.balance)}</td>
          <td>${a.due}</td>
          <td class="num ${a.overdueDays > 0 ? 'text-danger' : ''}">${a.overdueDays > 0 ? a.overdueDays : '-'}</td>
          <td>${a.overdueDays > 0 ? tag('已逾期', 'danger') : tag('未到期', 'success')}</td>
          <td class="center">
            <button class="link-btn" data-receipt="${a.customer}">登记收款</button>
            <button class="link-btn" data-collect="${a.invoice}">催收</button>
          </td>
        </tr>`).join('');

      const agingRows = AGING.map(g => `
        <tr>
          <td class="strong">${g.name}</td>
          <td class="num">${g.count}</td>
          <td class="num">${money(g.amount)}</td>
          <td class="num">${pct(g.amount / ar)}</td>
          <td class="num">${(g.rate * 100).toFixed(0)}%</td>
          <td class="num ${g.amount * g.rate > 0 ? 'text-warning' : ''}">${money(g.amount * g.rate)}</td>
        </tr>`).join('');
      const badDebt = sum(AGING, g => g.amount * g.rate);

      const planRows = M.contractMilestones.filter(m => ['CM1', 'CM2', 'CM3'].indexOf(m.id) > -1).map(m => `
        <tr>
          <td><span class="strong">${m.code}</span> ${esc(m.name)}</td>
          <td>${tag(m.type, 'info')}</td>
          <td class="num">${money(m.amount)}</td>
          <td>${m.planInvoice}</td>
          <td>${m.actualInvoice || '-'}</td>
          <td>${m.planPay}</td>
          <td class="num">${m.actualPay ? money(m.amount) : '<span class="text-muted">0.00</span>'}</td>
          <td>${statusTag('pay', m.payStatus)}</td>
        </tr>`).join('');

      root.innerHTML = `
      <div class="page-head">
        <div class="page-head__l">
          <div class="page-title">回款与应收 <span class="tag tag--primary">N10</span></div>
          <div class="page-sub">收款登记 · 发票核销 · 应收余额 · 账龄 · 信用控制</div>
        </div>
        <div class="page-actions">
          <button class="btn" id="arExport">${icon('download', 14)}导出账龄表</button>
          <button class="btn btn--primary" id="arReceipt">${icon('plus', 14)}登记收款</button>
        </div>
      </div>

      <div class="kpi-grid">
        <div class="kpi"><div class="kpi-label">应收余额</div><div class="kpi-value">${(ar / 10000).toFixed(1)}<small>万</small></div><div class="kpi-foot">${M.arBalances.length} 张发票 · 3 个客户</div></div>
        <div class="kpi kpi--danger"><div class="kpi-label">逾期金额</div><div class="kpi-value">${(overdue / 10000).toFixed(1)}<small>万</small></div><div class="kpi-foot">最长逾期 46 天 · 国网信通</div></div>
        <div class="kpi kpi--warning"><div class="kpi-label">逾期占比</div><div class="kpi-value">${pct(overdue / ar)}</div><div class="kpi-foot">逾期 2 张 / 应收 3 张</div></div>
        <div class="kpi kpi--info"><div class="kpi-label">30 天内到期</div><div class="kpi-value">${(due30 / 10000).toFixed(1)}<small>万</small></div><div class="kpi-foot">INV-2026-0245 · 2026-12-30</div></div>
        <div class="kpi"><div class="kpi-label">平均回款天数</div><div class="kpi-value">43<small>天</small></div><div class="kpi-foot">合同约定 30 天 · 偏差 +13 天</div></div>
        <div class="kpi kpi--danger"><div class="kpi-label">信用预警客户</div><div class="kpi-value">1<small>个</small></div><div class="kpi-foot">中海物业 · 逾期 21.8 万</div></div>
      </div>

      <div class="grid grid--2-1">
        <div class="panel">
          <div class="panel-head"><h3>${icon('wallet', 16)}应收明细</h3><span class="mini">应收余额合计 ${money(ar)}</span></div>
          <div class="panel-body panel-body--flush">
            <div class="table-wrap"><table class="table">
              <thead><tr><th>发票号</th><th>客户</th><th>合同</th><th>项目</th><th class="num">开票金额</th><th class="num">已核销</th><th class="num">应收余额</th><th>到期日</th><th class="num">逾期天数</th><th>状态</th><th class="center">操作</th></tr></thead>
              <tbody id="arBody">${arRows}</tbody>
            </table></div>
          </div>
          <div class="panel-foot"><span class="mini">应收余额 = 开票金额 − 已核销；逾期天数按到期日与 2026-11-10 计算</span><span class="tag tag--danger">逾期 31.4 万</span></div>
        </div>
        <div style="display:flex;flex-direction:column;gap:12px;min-width:0">
          <div class="panel">
            <div class="panel-head"><h3>${icon('pie', 16)}账龄分析</h3><span class="mini">单位：元</span></div>
            <div class="panel-body"><div id="arAging"></div></div>
          </div>
          <div class="panel">
            <div class="panel-head"><h3>${icon('shield', 16)}信用控制</h3>${tag('关注', 'warning')}</div>
            <div class="panel-body" style="padding-top:10px">
              <div style="display:flex;align-items:center;justify-content:space-between;margin-bottom:10px">
                <b style="font-size:14px">中海物业</b><span class="mini">CUS-0002</span>
              </div>
              <div class="desc-grid desc-grid--2">
                <div class="desc-item"><span class="desc-label">信用额度</span><span class="desc-value money">${money(credit.creditLimit)}</span></div>
                <div class="desc-item"><span class="desc-label">已用额度</span><span class="desc-value money">${money(credit.creditUsed)}</span></div>
                <div class="desc-item"><span class="desc-label">可用额度</span><span class="desc-value money">${money(creditAvail)}</span></div>
                <div class="desc-item"><span class="desc-label">逾期金额</span><span class="desc-value money text-danger">${money(218000)}</span></div>
              </div>
              <div style="margin-top:10px">
                <div style="display:flex;justify-content:space-between;font-size:12px;margin-bottom:5px"><span>额度使用率</span><span class="num">${pct(credit.creditUsed / credit.creditLimit)}</span></div>
                <div class="progress"><div class="progress__bar progress__bar--warning" style="width:${credit.creditUsed / credit.creditLimit * 100}%"></div></div>
              </div>
              <div class="alert alert--danger" style="margin-top:10px">${icon('alert', 15)}<span>客户存在逾期，新增合同需财务审批。</span></div>
            </div>
          </div>
        </div>
      </div>

      <div class="grid grid--2">
        <div class="panel">
          <div class="panel-head"><h3>${icon('chart', 16)}账龄表</h3><span class="mini">坏账准备 ${money(badDebt)}</span></div>
          <div class="panel-body panel-body--flush">
            <div class="table-wrap"><table class="table table--compact">
              <thead><tr><th>账龄区间</th><th class="num">发票张数</th><th class="num">应收金额</th><th class="num">占比</th><th class="num">计提比例</th><th class="num">坏账准备</th></tr></thead>
              <tbody>
                ${agingRows}
                <tr class="row-total"><td>合计</td><td class="num">${sum(AGING, g => g.count)}</td><td class="num">${money(ar)}</td><td class="num">100.0%</td><td class="num">-</td><td class="num">${money(badDebt)}</td></tr>
              </tbody>
            </table></div>
          </div>
        </div>
        <div class="panel">
          <div class="panel-head"><h3>${icon('trend', 16)}回款计划 vs 实际</h3><span class="mini">主合同 CT-2026-0087</span></div>
          <div class="panel-body panel-body--flush">
            <div class="table-wrap"><table class="table table--compact">
              <thead><tr><th>里程碑</th><th>类型</th><th class="num">开票金额</th><th>计划开票</th><th>实际开票</th><th>计划回款</th><th class="num">实际回款</th><th>状态</th></tr></thead>
              <tbody>${planRows}</tbody>
            </table></div>
          </div>
        </div>
      </div>

      <div class="alert alert--warning">${icon('alert', 15)}<span>逾期 90 天以上将计提坏账准备；信用额度按 md_customer_finance.credit_limit 控制，超限或存在逾期时新签合同需财务审批。</span></div>`;

      chart(root.querySelector('#arAging'), 'donut', {
        data: [
          { name: '未到期', value: 1200000, color: '#1d4ed8' },
          { name: '0-30 天', value: 218000, color: '#e6a23c' },
          { name: '31-60 天', value: 96000, color: '#f56c6c' },
          { name: '60 天以上', value: 0, color: '#c45656' }
        ],
        centerValue: wan(ar),
        centerLabel: '应收余额',
        height: 200,
        thickness: 20
      });

      bindRows();
      root.querySelector('#arExport').addEventListener('click', () => LY.toast('应收账龄表已导出（xlsx）', 'info'));
      root.querySelector('#arReceipt').addEventListener('click', () => openReceipt(M.arBalances[0].customer));
    }
  });
})();
