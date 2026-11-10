/* ================= 审批中心 / 主数据融合 ================= */
(function () {
  const LY = window.LY, M = LY.MOCK;
  const { icon, wan, money, num, esc, tag, statusTag, pct } = LY;
  const chart = (el, type, opt) => { if (!el) return; LY.chart[type](el, opt); LY.watchChart(el, type, opt); };

  /* ---------------- 审批中心 ---------------- */
  LY.register('/approval', {
    title: '审批中心', crumb: ['协同与治理', '审批中心'],
    render(root) {
      let tab = 'todo';
      const state = { approvals: M.approvals.map(a => ({ ...a })) };
      const typeColor = t => ({ 立项审批: 'primary', 预算审批: 'warning', 工时审批: 'success', 费用报销: 'info', 合同变更: 'danger' }[t] || 'info');

      const listFor = t => {
        if (t === 'todo') return state.approvals.filter(a => a.status === 'PENDING');
        if (t === 'mine') return state.approvals.filter(a => a.applicant === '陈立');
        return state.approvals.filter(a => a.status === 'APPROVED');
      };

      const drawTable = () => {
        const list = listFor(tab);
        root.querySelector('#apCount').textContent = `共 ${list.length} 条`;
        root.querySelector('#apBody').innerHTML = list.length ? list.map(a => `
          <tr data-id="${a.id}">
            <td class="mono">${a.id}</td>
            <td>${tag(a.type, typeColor(a.type))}</td>
            <td><div class="strong" style="font-size:13px">${esc(a.title)}</div><span class="sub">${esc(a.biz)}</span></td>
            <td><div class="user-cell"><span class="avatar-sm">${a.applicant.slice(0, 1)}</span><div><div class="user-cell__n">${esc(a.applicant)}</div><div class="user-cell__d">${esc(a.dept)}</div></div></div></td>
            <td class="text-muted" style="font-size:12px">${a.submitTime}</td>
            <td>${a.status === 'PENDING' ? tag(a.currentNode, 'warning') : tag(a.currentNode, 'success')}</td>
            <td class="num">${a.amount ? money(a.amount) : a.hours ? a.hours + ' h' : '-'}</td>
            <td>${statusTag('approval', a.status)}${a.urgent ? ' ' + tag('加急', 'danger') : ''}</td>
            <td class="center">${a.status === 'PENDING' ? `<button class="link-btn" data-act="${a.id}">审批</button>` : `<button class="link-btn" data-view="${a.id}">查看</button>`}</td>
          </tr>`).join('') : `<tr><td colspan="9"><div class="empty">${icon('check-circle', 40)}暂无待处理审批</div></td></tr>`;
        root.querySelectorAll('[data-act],[data-view]').forEach(b => b.addEventListener('click', () => openDetail(b.dataset.act || b.dataset.view, b.hasAttribute('data-act'))));
      };

      const openDetail = (id, canAct) => {
        const a = state.approvals.find(x => x.id === id);
        const nodes = M.approvalNodes[id] || [
          { name: '申请人提交', approver: a.applicant, status: 'DONE', time: a.submitTime, opinion: '按流程提交。' },
          { name: a.currentNode, approver: '待分配', status: 'CURRENT', time: null, opinion: null },
          { name: '归档', approver: '系统', status: 'WAIT', time: null, opinion: null }
        ];
        LY.openDrawer({
          title: `${a.type} · ${a.id}`,
          width: 700,
          body: `
            <div style="display:flex;align-items:flex-start;justify-content:space-between;gap:12px;padding-bottom:14px;border-bottom:1px solid var(--ly-border-light)">
              <div><div style="font-size:15px;font-weight:600;color:var(--ly-text)">${esc(a.title)}</div>
                <div class="mini" style="margin-top:4px">业务单号 ${esc(a.biz)} · 申请人 ${esc(a.applicant)} · ${esc(a.dept)} · ${a.submitTime}</div></div>
              <div>${statusTag('approval', a.status)}</div>
            </div>
            <div class="grid grid--3" style="margin:14px 0">
              <div class="kpi" style="box-shadow:none"><div class="kpi-label">审批类型</div><div class="kpi-value" style="font-size:16px">${esc(a.type)}</div></div>
              <div class="kpi" style="box-shadow:none"><div class="kpi-label">${a.hours ? '申请工时' : '涉及金额'}</div><div class="kpi-value" style="font-size:16px">${a.hours ? a.hours + ' h' : a.amount ? money(a.amount) : '-'}</div></div>
              <div class="kpi" style="box-shadow:none"><div class="kpi-label">当前节点</div><div class="kpi-value" style="font-size:16px">${esc(a.currentNode)}</div></div>
            </div>
            <div class="panel panel--flat" style="margin-bottom:14px"><div class="panel-head"><h3>业务摘要</h3></div><div class="panel-body">
              <div class="desc-grid desc-grid--2">
                <div class="desc-item"><span class="desc-label">关联业务</span><span class="desc-value">${esc(a.biz)}</span></div>
                <div class="desc-item"><span class="desc-label">所属组织</span><span class="desc-value">${esc(a.dept)}</span></div>
                <div class="desc-item"><span class="desc-label">提交时间</span><span class="desc-value">${a.submitTime}</span></div>
                <div class="desc-item"><span class="desc-label">审批状态</span><span class="desc-value">${a.status === 'PENDING' ? '审批中' : '已完成'}</span></div>
              </div>
              ${a.type === '预算审批' ? `<div class="alert" style="margin-top:10px">${icon('info', 15)}<span>预算 V2.0 合计 ¥6,240,000，人力预算按 12,800h × ¥337.5/h 计算；年度预算占用 18.3%，软校验通过。</span></div>` : ''}
              ${a.type === '合同变更' ? `<div class="alert alert--warning" style="margin-top:10px">${icon('alert', 15)}<span>变更将影响交付里程碑 D4 与回款计划 M3，需法务与财务同步确认。</span></div>` : ''}
              ${a.type === '工时审批' ? `<div class="alert" style="margin-top:10px">${icon('info', 15)}<span>38h 中可计费 32h、内部工时 6h；审批通过后工时锁定并进入结算池。</span></div>` : ''}
            </div></div>
            <div class="panel panel--flat"><div class="panel-head"><h3>审批流程</h3><span class="mini">统一审批引擎 sys_approval_instance</span></div><div class="panel-body">
              <div class="timeline">
                ${nodes.map(n => `<div class="timeline__item ${n.status === 'DONE' ? 'is-done' : n.status === 'CURRENT' ? 'is-current' : ''}">
                  <div class="timeline__title">${esc(n.name)} ${n.status === 'CURRENT' ? tag('待处理', 'warning') : n.status === 'DONE' ? tag('已通过', 'success') : tag('等待中', 'info')}</div>
                  <div class="timeline__meta">${esc(n.approver)}${n.time ? ' · ' + n.time : ''}</div>
                  ${n.opinion ? `<div class="timeline__body">${esc(n.opinion)}</div>` : ''}
                </div>`).join('')}
              </div>
            </div></div>
            ${canAct ? `<div class="form-item" style="margin-top:14px"><label>审批意见</label><textarea class="textarea" id="apOpinion" placeholder="请输入审批意见（可选）"></textarea></div>` : ''}`,
          footer: canAct
            ? `<button class="btn btn--danger" id="apReject">驳回</button><button class="btn" id="apTransfer">转办</button><button class="btn btn--primary" id="apPass">通过</button>`
            : `<button class="btn" data-close>关闭</button>`,
          onMount(d) {
            if (!canAct) return;
            d.querySelector('#apPass').addEventListener('click', () => {
              const op = d.querySelector('#apOpinion').value.trim();
              LY.closeDrawer();
              a.status = 'APPROVED'; a.currentNode = '已完成';
              LY.toast('审批已通过' + (op ? '：' + op : ''), 'success');
              drawTable(); updateKpi();
            });
            d.querySelector('#apReject').addEventListener('click', () => {
              LY.closeDrawer();
              LY.confirm({
                title: '驳回审批', danger: true, okText: '确认驳回',
                content: `确定驳回「${a.title}」？申请人将收到通知并需重新提交。`,
                onOk() { a.status = 'REJECTED'; a.currentNode = '已驳回'; LY.toast('已驳回，申请人已收到通知', 'warning'); drawTable(); updateKpi(); }
              });
            });
            d.querySelector('#apTransfer').addEventListener('click', () => {
              LY.closeDrawer();
              LY.openModal({
                title: '转办', width: 460,
                body: `<div class="form-item"><label>转办给</label><select class="select"><option>王海 · 交付中心负责人</option><option>刘芳 · 财务经理</option><option>赵总 · COO</option></select></div>
                  <div class="form-item"><label>转办说明</label><textarea class="textarea"></textarea></div>`,
                footer: `<button class="btn" data-close>取消</button><button class="btn btn--primary" onclick="LY.closeModal();LY.toast('已转办','success')">确认转办</button>`
              });
            });
          }
        });
      };

      const updateKpi = () => {
        root.querySelector('#kpiTodo').textContent = state.approvals.filter(a => a.status === 'PENDING').length;
        root.querySelector('#kpiMine').textContent = state.approvals.filter(a => a.applicant === '陈立').length;
        root.querySelector('#kpiDone').textContent = state.approvals.filter(a => a.status === 'APPROVED').length;
        root.querySelector('#apBadge').textContent = state.approvals.filter(a => a.status === 'PENDING').length + ' 项待处理';
      };

      root.innerHTML = `
      <div class="page-head">
        <div class="page-head__l"><div class="page-title">审批中心</div><div class="page-sub">统一审批引擎 · 已接入 立项 / 预算 / 工时 / 费用 / 合同变更 5 类业务（B-07 / C-11）</div></div>
        <div class="page-actions">
          <button class="btn" id="apRule">${icon('settings', 14)}审批流配置</button>
          <button class="btn btn--primary" id="apNew">${icon('send', 14)}发起审批</button>
        </div>
      </div>
      <div class="kpi-grid">
        <div class="kpi kpi--warning"><div class="kpi-label">待我审批</div><div class="kpi-value" id="kpiTodo">5</div><div class="kpi-foot">2 项加急 · 平均等待 4.2h</div></div>
        <div class="kpi"><div class="kpi-label">我发起的</div><div class="kpi-value" id="kpiMine">3</div><div class="kpi-foot">审批中 2 · 已通过 1</div></div>
        <div class="kpi kpi--success"><div class="kpi-label">本月已审批</div><div class="kpi-value" id="kpiDone">3</div><div class="kpi-foot">通过率 92.9%</div></div>
        <div class="kpi kpi--info"><div class="kpi-label">平均审批时长</div><div class="kpi-value">4.2<small>h</small></div><div class="kpi-foot">较上月 -1.6h</div></div>
      </div>
      <div class="panel">
        <div class="panel-head"><h3>${icon('check-circle', 16)}审批工作台</h3><span class="tag tag--warning" id="apBadge">5 项待处理</span></div>
        <div class="panel-body" style="padding-bottom:0">
          <div class="tabs" style="border-radius:0;padding:0;border-bottom:1px solid var(--ly-border-light)">
            <div class="tabs__item is-active" data-atab="todo">待我审批</div>
            <div class="tabs__item" data-atab="mine">我发起的</div>
            <div class="tabs__item" data-atab="done">已办结</div>
          </div>
          <div class="table-wrap"><table class="table">
            <thead><tr><th>审批单号</th><th>类型</th><th>标题 / 业务单号</th><th>申请人</th><th>提交时间</th><th>当前节点</th><th class="num">金额 / 工时</th><th>状态</th><th class="center">操作</th></tr></thead>
            <tbody id="apBody"></tbody>
          </table></div>
        </div>
        <div class="panel-foot"><span class="mini" id="apCount"></span><span class="mini">审批通过后自动回写业务单据状态，并触发下游（工时锁定 / 预算锁定 / 合同变更生效）</span></div>
      </div>
      <div class="grid grid--2">
        <div class="panel"><div class="panel-head"><h3>${icon('sliders', 16)}审批流配置</h3><span class="mini">按业务类型注册</span></div><div class="panel-body panel--flush">
          <table class="table table--compact"><thead><tr><th>业务类型</th><th>审批链</th><th>条件</th><th>状态</th></tr></thead><tbody>
            <tr><td>立项审批</td><td>PMO → COO</td><td>合同额 ≥ 500 万</td><td>${tag('启用', 'success')}</td></tr>
            <tr><td>预算审批</td><td>部门负责人 → 财务 → COO</td><td>全部项目预算</td><td>${tag('启用', 'success')}</td></tr>
            <tr><td>工时审批</td><td>项目经理</td><td>周工时 &gt; 32h</td><td>${tag('启用', 'success')}</td></tr>
            <tr><td>费用报销</td><td>部门负责人 → 财务</td><td>金额 ≥ 3,000</td><td>${tag('启用', 'success')}</td></tr>
            <tr><td>合同变更</td><td>法务 → 财务 → COO</td><td>金额或工期变更</td><td>${tag('启用', 'success')}</td></tr>
          </tbody></table>
        </div></div>
        <div class="panel"><div class="panel-head"><h3>${icon('activity', 16)}审批效率</h3><span class="mini">近 6 个月</span></div><div class="panel-body"><div id="apChart"></div></div></div>
      </div>`;

      drawTable(); updateKpi();
      chart(root.querySelector('#apChart'), 'bar', {
        categories: ['6月', '7月', '8月', '9月', '10月', '11月'],
        series: [{ name: '审批单量', data: [46, 52, 61, 58, 72, 28], color: '#1d4ed8' }],
        height: 200
      });
      root.querySelectorAll('[data-atab]').forEach(t => t.addEventListener('click', () => {
        root.querySelectorAll('[data-atab]').forEach(x => x.classList.remove('is-active'));
        t.classList.add('is-active'); tab = t.dataset.atab; drawTable();
      }));
      root.querySelector('#apNew').addEventListener('click', () => LY.openModal({
        title: '发起审批', width: 520,
        body: `<div class="form-item"><label>审批类型</label><select class="select"><option>项目预算审批</option><option>立项审批</option><option>费用报销</option><option>合同变更</option></select></div>
          <div class="form-item"><label>关联业务单号</label><select class="select"><option>PJ-2026-0021 华润数科数字化中台建设</option><option>PJ-2026-0023 中国邮政客户数据平台</option></select></div>
          <div class="form-item"><label>审批说明</label><textarea class="textarea" placeholder="请说明申请事由"></textarea></div>`,
        footer: `<button class="btn" data-close>取消</button><button class="btn btn--primary" onclick="LY.closeModal();LY.toast('审批已发起，单号 AP-2026-1028','success')">提交</button>`
      }));
      root.querySelector('#apRule').addEventListener('click', () => LY.toast('审批流配置需在系统管理 → 审批配置中维护', 'info'));
    }
  });

  /* ---------------- 主数据融合 ---------------- */
  LY.register('/integration', {
    title: '主数据融合', crumb: ['协同与治理', '主数据融合'],
    render(root) {
      const syncTasks = [
        { id: 'SYNC-001', name: '客户主数据增量同步', src: 'CRM', mode: '增量', rows: 128, status: '成功', cost: '1.2s', last: '2026-11-10 09:42' },
        { id: 'SYNC-002', name: '项目主数据全量同步', src: 'PMT', mode: '全量', rows: 1240, status: '成功', cost: '8.6s', last: '2026-11-10 09:40' },
        { id: 'SYNC-003', name: '组织 / 员工 / 岗位同步', src: 'HR', mode: '全量', rows: 268, status: '同步中', cost: '—', last: '2026-11-10 09:35' },
        { id: 'SYNC-004', name: '工时明细增量同步', src: 'PMT', mode: '增量', rows: 3842, status: '成功', cost: '4.1s', last: '2026-11-10 09:38' },
        { id: 'SYNC-005', name: '预算行 / 期间金额同步', src: 'FS', mode: '增量', rows: 620, status: '成功', cost: '2.8s', last: '2026-11-10 09:37' },
        { id: 'SYNC-006', name: '合同主数据增量同步', src: 'CRM', mode: '增量', rows: 36, status: '失败', cost: '—', last: '2026-11-10 09:30' }
      ];
      const caps = [
        ['B-01 统一客户主数据', '已完成'], ['B-02 统一合同主数据', '已完成'], ['B-03 统一项目主数据', '已完成'],
        ['B-04 统一员工/组织/岗位', '进行中'], ['B-05 统一科目', '已完成'], ['B-06 统一工作日历/期间', '已完成'],
        ['B-07 统一审批引擎', '已完成'], ['B-08 统一附件中心', '已完成'], ['B-09 统一单据序列', '已完成'],
        ['B-10 统一权限矩阵', '进行中'], ['B-11 统一应收/账龄', '已完成'], ['B-12 预算 vs 实际', '已完成'],
        ['B-13 项目预算 vs 年度预算', '已完成'], ['B-14 合同-项目 N:N', '已完成'], ['B-15 数据血缘', '进行中']
      ];
      root.innerHTML = `
      <div class="page-head">
        <div class="page-head__l"><div class="page-title">主数据融合与数据治理</div><div class="page-sub">CRM / PMT / HR / FS 四套系统 → 统一主数据（md_ / fin_ / sys_）· 数据血缘 · 编码规则 · 同步监控</div></div>
        <div class="page-actions">
          <button class="btn" id="intHealth">${icon('shield', 14)}数据体检</button>
          <button class="btn btn--primary" id="intSync">${icon('refresh', 14)}全部同步</button>
        </div>
      </div>
      <div class="kpi-grid">
        <div class="kpi"><div class="kpi-label">接入系统</div><div class="kpi-value">4</div><div class="kpi-foot">CRM · PMT · HR · FS</div></div>
        <div class="kpi"><div class="kpi-label">统一主数据表</div><div class="kpi-value">42</div><div class="kpi-foot">md 18 · fin 16 · sys 8</div></div>
        <div class="kpi kpi--success"><div class="kpi-label">今日同步记录</div><div class="kpi-value">386,420</div><div class="kpi-foot">成功率 99.2%</div></div>
        <div class="kpi kpi--warning"><div class="kpi-label">数据质量问题</div><div class="kpi-value">7</div><div class="kpi-foot">重复客户 1 · 员工 3 · 合同 4</div></div>
        <div class="kpi kpi--info"><div class="kpi-label">主数据一致率</div><div class="kpi-value">99.2<small>%</small></div><div class="kpi-foot">目标 ≥ 99.5%</div></div>
        <div class="kpi kpi--danger"><div class="kpi-label">同步异常</div><div class="kpi-value">1</div><div class="kpi-foot">合同主数据同步失败</div></div>
      </div>

      <div class="grid grid--4">
        ${M.integration.map(s => `<div class="panel">
          <div class="panel-body" style="padding:14px 16px">
            <div style="display:flex;align-items:center;justify-content:space-between">
              <div style="display:flex;align-items:center;gap:9px">
                <span style="width:34px;height:34px;border-radius:6px;background:${s.color}1a;color:${s.color};display:flex;align-items:center;justify-content:center;font-size:11px;font-weight:700">${s.code}</span>
                <div><div style="font-size:13px;font-weight:600">${esc(s.name)}</div><div class="mini">${esc(s.desc)}</div></div>
              </div>
              ${s.status === '已同步' ? tag('正常', 'success') : tag('同步中', 'warning')}
            </div>
            <div style="display:flex;gap:16px;margin-top:12px">
              <div><div class="mini">数据表</div><div class="num" style="font-size:15px;font-weight:600">${s.tables}</div></div>
              <div><div class="mini">接口</div><div class="num" style="font-size:15px;font-weight:600">${s.apis}</div></div>
              <div><div class="mini">覆盖率</div><div class="num" style="font-size:15px;font-weight:600">${s.percent}%</div></div>
            </div>
            <div class="progress" style="margin-top:8px"><div class="progress__bar ${s.percent < 100 ? 'progress__bar--warning' : 'progress__bar--success'}" style="width:${s.percent}%"></div></div>
            <div class="mini" style="margin-top:8px">最近同步 ${s.last} · 服务模块 ${s.module}</div>
          </div></div>`).join('')}
      </div>

      <div class="grid grid--2-1">
        <div class="panel">
          <div class="panel-head"><h3>${icon('refresh', 16)}同步任务监控</h3><span class="mini">近 24 小时</span></div>
          <div class="panel-body panel-body--flush">
            <div class="table-wrap"><table class="table table--compact">
              <thead><tr><th>任务</th><th>来源</th><th>模式</th><th class="num">记录数</th><th>状态</th><th class="num">耗时</th><th>最近执行</th><th class="center">操作</th></tr></thead>
              <tbody>${syncTasks.map(t => `<tr class="${t.status === '失败' ? 'hl-row' : ''}">
                <td class="strong">${esc(t.name)}</td><td><span class="tag tag--dark">${t.src}</span></td><td>${t.mode}</td>
                <td class="num">${num(t.rows)}</td>
                <td>${t.status === '成功' ? tag('成功', 'success') : t.status === '同步中' ? tag('同步中', 'warning') : tag('失败', 'danger')}</td>
                <td class="num">${t.cost}</td><td class="text-muted" style="font-size:12px">${t.last}</td>
                <td class="center"><button class="link-btn" data-sync="${t.id}">重跑</button></td></tr>`).join('')}</tbody>
            </table></div>
          </div>
        </div>
        <div class="panel">
          <div class="panel-head"><h3>${icon('alert', 16)}数据质量问题</h3><span class="tag tag--danger">7 项</span></div>
          <div class="panel-body" style="padding-top:6px">
            <div style="display:flex;gap:10px;padding:11px 0;border-bottom:1px dashed #f0f2f5">
              <div style="flex:1"><div style="font-size:13px;font-weight:500">客户税号重复（2 条）</div><div class="mini">CUS-0001 与 CUS-0007 税号相同</div></div>
              <button class="link-btn" onclick="LY.go('/customer')">去合并</button>
            </div>
            <div style="display:flex;gap:10px;padding:11px 0;border-bottom:1px dashed #f0f2f5">
              <div style="flex:1"><div style="font-size:13px;font-weight:500">员工重复（3 条）</div><div class="mini">HR 与 PMT 工号映射冲突</div></div>
              <button class="link-btn" onclick="LY.toast('已进入员工主数据合并向导','info')">处理</button>
            </div>
            <div style="display:flex;gap:10px;padding:11px 0;border-bottom:1px dashed #f0f2f5">
              <div style="flex:1"><div style="font-size:13px;font-weight:500">合同编号冲突（4 条）</div><div class="mini">CRM 时间戳编码与 PMT 序列不一致</div></div>
              <button class="link-btn" onclick="LY.toast('已按 sys_sequence 重新分配合同号','info')">修复</button>
            </div>
            <div style="display:flex;gap:10px;padding:11px 0">
              <div style="flex:1"><div style="font-size:13px;font-weight:500">项目缺失主合同</div><div class="mini">2 个项目未建立 md_contract_project 主关系</div></div>
              <button class="link-btn" onclick="LY.toast('请到项目驾驶舱维护主合同','info')">处理</button>
            </div>
            <button class="btn" style="width:100%;margin-top:8px" onclick="LY.toast('数据体检完成：修复建议 7 条，已生成报告','info')">生成治理报告</button>
          </div>
        </div>
      </div>

      <div class="panel">
        <div class="panel-head"><h3>${icon('database', 16)}源系统 → 统一主数据映射</h3><span class="mini">数据血缘 source_system / legacy_code</span></div>
        <div class="panel-body panel-body--flush">
          <div class="table-wrap"><table class="table">
            <thead><tr><th>来源系统</th><th>源表</th><th></th><th>目标表</th><th class="num">记录数</th><th class="num">已匹配</th><th>映射规则</th><th class="num">重复</th><th class="center">状态</th></tr></thead>
            <tbody>${M.legacyMapping.map(m => `<tr>
              <td><span class="tag tag--dark">${m.source}</span></td>
              <td class="mono">${m.table}</td>
              <td style="color:#c0c4cc;width:24px">${icon('arrow-right', 14)}</td>
              <td class="mono">${m.target}</td>
              <td class="num">${num(m.rows)}</td><td class="num">${num(m.matched)}</td>
              <td class="text-muted" style="font-size:12px">${esc(m.rule)}</td>
              <td class="num ${m.dup ? 'text-danger' : ''}">${m.dup}</td>
              <td class="center">${m.matched === m.rows ? tag('一致', 'success') : tag('待处理', 'warning')}</td></tr>`).join('')}</tbody>
          </table></div>
        </div>
      </div>

      <div class="grid grid--2">
        <div class="panel"><div class="panel-head"><h3>${icon('link', 16)}统一编码规则</h3><span class="mini">sys_sequence</span></div><div class="panel-body panel-body--flush">
          <table class="table table--compact"><thead><tr><th>单据</th><th>规则</th><th>示例</th><th>作用域</th></tr></thead><tbody>
            <tr><td>合同</td><td class="mono">CT-{YYYY}-{0000}</td><td class="mono">CT-2026-0087</td><td>法人 + 年度</td></tr>
            <tr><td>项目</td><td class="mono">PJ-{YYYY}-{0000}</td><td class="mono">PJ-2026-0021</td><td>法人 + 年度</td></tr>
            <tr><td>工时单</td><td class="mono">TS-{YYYYWW}-{000}</td><td class="mono">TS-202645-001</td><td>员工 + 周</td></tr>
            <tr><td>结算批次</td><td class="mono">STB-{YYYYMM}-{TYPE}-{00}</td><td class="mono">STB-202610-CUST-01</td><td>法人 + 月 + 类型</td></tr>
            <tr><td>发票</td><td class="mono">INV-{YYYY}-{0000}</td><td class="mono">INV-2026-0231</td><td>法人 + 年度</td></tr>
            <tr><td>收款</td><td class="mono">RCP-{YYYY}-{0000}</td><td class="mono">RCP-2026-0203</td><td>法人 + 年度</td></tr>
          </tbody></table>
        </div></div>
        <div class="panel"><div class="panel-head"><h3>${icon('check-circle', 16)}跨系统整合能力</h3><span class="mini">15 项 · 已完成 11</span></div><div class="panel-body">
          <div style="display:grid;grid-template-columns:repeat(2,minmax(0,1fr));gap:7px">
            ${caps.map(([name, st]) => `<div style="display:flex;align-items:center;gap:6px;font-size:12px;color:var(--ly-text-regular);padding:6px 8px;border:1px solid var(--ly-border-light);border-radius:4px">
              <span style="color:${st === '已完成' ? 'var(--ly-success)' : 'var(--ly-warning)'}">${icon(st === '已完成' ? 'check-circle' : 'clock', 13)}</span>
              <span style="flex:1">${name}</span>
              <span class="mini">${st}</span>
            </div>`).join('')}
          </div>
          <div class="alert" style="margin-top:12px">${icon('info', 15)}<span>融合后所有业务单据保留 <code class="code">source_system</code> 与 <code class="code">legacy_code</code>，支持回溯到原系统。</span></div>
        </div></div>
      </div>`;

      root.querySelectorAll('[data-sync]').forEach(b => b.addEventListener('click', () => {
        LY.toast('已触发同步任务 ' + b.dataset.sync + '，预计 3 秒完成', 'info');
      }));
      root.querySelector('#intSync').addEventListener('click', () => LY.confirm({
        title: '全部同步', content: '将对 4 套系统执行全量/增量同步，预计耗时 2 分钟，是否继续？',
        onOk() { LY.toast('同步任务已启动，可在监控列表查看进度', 'success'); }
      }));
      root.querySelector('#intHealth').addEventListener('click', () => LY.toast('数据体检完成：整体健康度 92 分，7 项待治理', 'info'));
    }
  });
})();
