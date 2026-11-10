/* ================= 资源池 / 工时管理 ================= */
(function () {
  const LY = window.LY, M = LY.MOCK;
  const { icon, money, num, pct, esc, tag, statusTag } = LY;
  const sum = (arr, f) => arr.reduce((a, b) => a + (f ? f(b) : b), 0);

  const ROLE_OPTIONS = ['架构师', '后端工程师', '前端工程师', '测试工程师', '数据工程师'];
  const WORK_TYPES = [
    ['CUSTOMER_PROJECT', '客户项目'], ['INTERNAL_RND', '内部研发'], ['INTERNAL_ADMIN', '内部管理'],
    ['TRAINING', '培训'], ['LEAVE', '请假'], ['IDLE', '闲置']
  ];
  const COST_CENTERS = ['技术中心', '交付中心', '质量中心', '产品与设计中心'];
  const WEEK_KEYS = M.weekDays.map(d => d.key);
  const ALL_ROLES = [...new Set(ROLE_OPTIONS.concat(M.employees.map(e => e.role)))];

  function openMemberModal(emp, preset) {
    const p = preset || {};
    const projectId = p.projectId || M.projects[0].id;
    const role = p.role || emp.role;
    const hours = p.hours || 320;
    const projectOpts = M.projects.map(x => `<option value="${esc(x.id)}" ${x.id === projectId ? 'selected' : ''}>${esc(x.name)}</option>`).join('');
    const roleOpts = ALL_ROLES.map(r => `<option ${r === role ? 'selected' : ''}>${esc(r)}</option>`).join('');
    LY.openModal({
      title: '配置项目成员 · ' + emp.name, width: 680,
      body: `<div class="desc-grid desc-grid--2">
          <div class="desc-item"><span class="desc-label">成员</span><span class="desc-value">${esc(emp.name)}（${esc(emp.id)}）</span></div>
          <div class="desc-item"><span class="desc-label">岗位</span><span class="desc-value">${esc(emp.role)} · ${esc(emp.level)}</span></div>
          <div class="desc-item"><span class="desc-label">可用工时</span><span class="desc-value">${emp.available}h · 已分配 ${emp.allocated}h</span></div>
          <div class="desc-item"><span class="desc-label">当前利用率</span><span class="desc-value">${pct(emp.utilization, 0)}</span></div>
        </div>
        <div class="form-grid" style="margin-top:14px">
          <div class="form-item" style="grid-column:1/-1"><label>项目 <span class="text-danger">*</span></label><select class="select" id="mmProject">${projectOpts}</select></div>
          <div class="form-item"><label>角色</label><select class="select" id="mmRole">${roleOpts}</select></div>
          <div class="form-item"><label>工时性质</label><select class="select" id="mmNature"><option value="SETTLE">SETTLE 可结算</option><option value="NON_SETTLE">NON_SETTLE 不可结算</option></select></div>
          <div class="form-item"><label>投入开始</label><input class="input" type="date" id="mmStart" value="2026-11-15"></div>
          <div class="form-item"><label>投入结束</label><input class="input" type="date" id="mmEnd" value="2027-03-31"></div>
          <div class="form-item"><label>投入比例（%）</label><input class="input" type="number" id="mmRatio" value="50" min="0" max="100"></div>
          <div class="form-item"><label>计划工时（h）</label><input class="input" type="number" id="mmPlanned" value="${hours}"></div>
          <div class="form-item"><label>成本单价（元/天）</label><input class="input" type="number" id="mmCost" value="${emp.costDay}"></div>
          <div class="form-item"><label>结算单价（元/天）</label><input class="input" type="number" id="mmBill" value="${emp.billDay}"></div>
        </div>
        <div class="alert">${icon('info', 15)}<span>配置后按投入期间与投入比例占用可用工时，成本/结算单价用于工时结算与人工成本分摊。</span></div>`,
      footer: `<button class="btn" data-close>取消</button><button class="btn btn--primary" id="mmOk">确认配置</button>`,
      onMount(m) {
        m.querySelector('#mmOk').addEventListener('click', () => {
          const planned = Number(m.querySelector('#mmPlanned').value);
          if (!planned || planned <= 0) { LY.toast('计划工时必须大于 0', 'error'); return; }
          LY.closeModal();
          LY.toast('成员已加入项目，期间与单价已生效');
        });
      }
    });
  }

  /* ---------------- N6 资源池与人员配置 ---------------- */
  LY.register('/resource', {
    title: '资源池', crumb: ['资源与工时', '资源池'],
    render(root) {
      const totalAvailable = sum(M.employees, e => e.available);
      const totalAllocated = sum(M.employees, e => e.allocated);
      const avgUtil = sum(M.employees, e => e.utilization) / M.employees.length;
      const fullCount = M.employees.filter(e => e.utilization >= 0.95).length;
      const billableCount = M.employees.filter(e => e.billDay >= 2400).length;

      const statusOf = emp => emp.utilization >= 0.95 ? ['满负荷', 'danger'] : emp.utilization >= 0.7 ? ['可分配', 'success'] : ['闲置', 'warning'];

      const levelColor = { 1: '#eef3ff', 2: '#dbe6ff', 3: '#a9c3f9', 4: '#6d96f0', 5: '#1d4ed8' };
      const skillRows = M.skills.slice(0, 8);
      const weekLabels = ['W45', 'W46', 'W47', 'W48', 'W49', 'W50', 'W51', 'W52'];

      root.innerHTML = `
      <div class="page-head">
        <div class="page-head__l">
          <div class="page-title">资源池</div>
          <div class="page-sub">技能字典 · 员工技能等级 · 可用工时 · 成本/结算单价 · 资源匹配</div>
        </div>
        <div class="page-actions">
          <button class="btn" id="resDict">${icon('grid', 14)}技能字典</button>
          <button class="btn btn--primary" id="resRefresh">${icon('refresh', 14)}刷新可用工时</button>
        </div>
      </div>

      <div class="kpi-grid">
        <div class="kpi"><div class="kpi-label">资源池人数</div><div class="kpi-value">${M.employees.length}<small>人</small></div><div class="kpi-foot">在册员工 · 4 个成本中心</div></div>
        <div class="kpi"><div class="kpi-label">可用工时合计</div><div class="kpi-value">${num(totalAvailable)}<small>h</small></div><div class="kpi-foot">人均 ${(totalAvailable / M.employees.length).toFixed(1)}h · W45~W52</div></div>
        <div class="kpi kpi--info"><div class="kpi-label">已分配工时</div><div class="kpi-value">${num(totalAllocated)}<small>h</small></div><div class="kpi-foot">占可用 ${pct(totalAllocated / totalAvailable)}</div></div>
        <div class="kpi kpi--success"><div class="kpi-label">平均利用率</div><div class="kpi-value">${(avgUtil * 100).toFixed(1)}<small>%</small></div><div class="kpi-foot">按成员利用率均值</div></div>
        <div class="kpi kpi--danger"><div class="kpi-label">满负荷人数</div><div class="kpi-value">${fullCount}<small>人</small></div><div class="kpi-foot">利用率 ≥ 95% · 吴磊 100%</div></div>
        <div class="kpi kpi--warning"><div class="kpi-label">可结算人数</div><div class="kpi-value">${billableCount}<small>人</small></div><div class="kpi-foot">结算单价 ≥ 2,400 元/天</div></div>
      </div>

      <div class="grid grid--2-1">
        <div class="panel">
          <div class="panel-head">
            <h3>${icon('users', 16)}资源池 <span class="sub">· ${M.employees.length} 人</span></h3>
            <span class="mini">利用率口径：已分配 / 可用</span>
          </div>
          <div class="panel-body panel-body--flush">
            <div class="table-wrap"><table class="table table--compact">
              <thead><tr><th>成员</th><th>岗位 / 职级</th><th>技能</th><th>可用 / 已分配</th><th class="num">利用率</th><th class="num">成本单价/天</th><th class="num">结算单价/天</th><th class="center">状态</th><th class="center">操作</th></tr></thead>
              <tbody>${M.employees.map(emp => {
                const st = statusOf(emp);
                const extra = emp.skills.length - 2;
                const barCls = emp.utilization >= 0.95 ? 'progress__bar--danger' : emp.utilization >= 0.7 ? '' : 'progress__bar--warning';
                return `<tr>
                  <td><div class="user-cell"><span class="avatar-sm">${esc(emp.avatar)}</span><div><div class="user-cell__n">${esc(emp.name)}</div><div class="user-cell__d">${esc(emp.id)} · ${esc(emp.dept)}</div></div></div></td>
                  <td>${esc(emp.role)}<span class="sub">${esc(emp.level)}</span></td>
                  <td>${emp.skills.slice(0, 2).map(s => tag(s, 'info')).join(' ')}${extra > 0 ? ` <span class="text-muted" style="font-size:12px">+${extra}</span>` : ''}</td>
                  <td><div style="display:flex;align-items:center;gap:8px"><div class="progress" style="flex:1"><div class="progress__bar ${barCls}" style="width:${Math.min(emp.allocated / emp.available * 100, 100)}%"></div></div><span class="num" style="font-size:12px;white-space:nowrap">${emp.allocated}/${emp.available}</span></div></td>
                  <td class="num">${pct(emp.utilization, 0)}</td>
                  <td class="num">${money(emp.costDay)}</td>
                  <td class="num">${money(emp.billDay)}</td>
                  <td class="center">${tag(st[0], st[1])}</td>
                  <td class="center"><button class="link-btn" data-match="${emp.id}">匹配</button><button class="link-btn" data-config="${emp.id}">配置</button></td>
                </tr>`;
              }).join('')}</tbody>
            </table></div>
          </div>
        </div>

        <div class="panel" id="matchPanel">
          <div class="panel-head">
            <h3>${icon('target', 16)}资源匹配 <span class="sub">A-16</span></h3>
            <span class="mini">技能 / 余量 / 成本</span>
          </div>
          <div class="panel-body">
            <div class="form-grid">
              <div class="form-item" style="grid-column:1/-1"><label>需求项目</label><select class="select" id="mProject">${M.projects.map(p => `<option value="${esc(p.id)}">${esc(p.name)}</option>`).join('')}</select></div>
              <div class="form-item"><label>所需角色</label><select class="select" id="mRole">${ROLE_OPTIONS.map(r => `<option>${esc(r)}</option>`).join('')}</select></div>
              <div class="form-item"><label>所需技能</label><select class="select" id="mSkill">${M.skills.map(s => `<option>${esc(s.name)}</option>`).join('')}</select></div>
              <div class="form-item"><label>进场日期</label><input class="input" type="date" id="mDate" value="2026-11-15"></div>
              <div class="form-item"><label>需求工时（h）</label><input class="input" type="number" id="mHours" value="320" min="1"></div>
              <div class="form-item" style="grid-column:1/-1"><label>每日成本上限（元）</label><input class="input" type="number" id="mCap" value="3000" min="1"></div>
            </div>
            <button class="btn btn--primary" id="runMatch" style="width:100%">${icon('search', 14)}智能匹配</button>
            <div class="mini" style="margin-top:10px;line-height:18px">
              评分算法：技能命中 40 分（主技能 40 / 相关 25）+ 可用余量 (available − allocated) ÷ 需求工时 × 30 + 成本低于上限 30 分（日成本 ≤ 上限得 30，超出按 上限 ÷ 日成本 折算）。
            </div>
            <div id="matchResult" style="margin-top:12px">
              <div class="empty">${icon('target', 34)}设置需求条件后点击「智能匹配」</div>
            </div>
          </div>
        </div>
      </div>

      <div class="grid grid--2">
        <div class="panel">
          <div class="panel-head">
            <h3>${icon('grid', 16)}技能矩阵 <span class="sub">8 项技能 × 12 人</span></h3>
            <span class="mini">灰色「·」= 未登记</span>
          </div>
          <div class="panel-body panel-body--flush">
            <div class="table-wrap"><table class="table table--compact table--bordered">
              <thead><tr><th style="min-width:120px">技能</th>${M.employees.map(e => `<th class="center" title="${esc(e.name)} · ${esc(e.role)}">${esc(e.name.slice(0, 1))}</th>`).join('')}</tr></thead>
              <tbody>${skillRows.map(sk => `<tr>
                <td><span class="strong">${esc(sk.name)}</span><span class="sub">${esc(sk.code)} · ${esc(sk.category)}</span></td>
                ${M.employees.map(emp => {
                  const rec = M.employeeSkills.find(r => r.employeeId === emp.id && r.skill === sk.name);
                  if (!rec) return `<td class="center" style="color:#c0c4cc;background:#fafafa">·</td>`;
                  const color = rec.level >= 4 ? '#fff' : '#33528f';
                  return `<td class="center" title="${esc(emp.name)} · ${esc(sk.name)} · ${rec.level} 级"><span style="display:inline-flex;width:26px;height:22px;align-items:center;justify-content:center;border-radius:3px;background:${levelColor[rec.level]};color:${color};font-size:12px;font-weight:500">${rec.level}</span></td>`;
                }).join('')}
              </tr>`).join('')}</tbody>
            </table></div>
          </div>
          <div class="panel-foot" style="justify-content:flex-start;gap:14px">
            <span class="mini">等级</span>
            ${[1, 2, 3, 4, 5].map(l => `<span class="mini"><i style="display:inline-block;width:12px;height:12px;border-radius:2px;background:${levelColor[l]};vertical-align:-2px;margin-right:4px"></i>${l}</span>`).join('')}
          </div>
        </div>

        <div class="panel">
          <div class="panel-head">
            <h3>${icon('calendar', 16)}可用工时热力 <span class="sub">W45~W52 · 周可用 40h</span></h3>
            <span class="mini">已分配 / 可用</span>
          </div>
          <div class="panel-body panel-body--flush">
            <div class="table-wrap"><table class="table table--compact">
              <thead><tr><th style="min-width:96px">成员</th>${weekLabels.map(w => `<th class="center">${w}</th>`).join('')}</tr></thead>
              <tbody>${M.employees.map((emp, i) => `<tr>
                <td><div class="user-cell"><span class="avatar-sm">${esc(emp.avatar)}</span><span class="user-cell__n">${esc(emp.name)}</span></div></td>
                ${weekLabels.map((w, wi) => {
                  const factor = 1 + (((i * 3 + wi * 5) % 7) - 3) * 0.025;
                  const ratio = Math.min(1.35, Math.max(0, emp.utilization * factor));
                  const used = Math.round(ratio * 40);
                  const pv = Math.round(ratio * 100);
                  const bg = ratio > 1 ? '#f8ddb5' : ratio >= 0.8 ? '#93b4f7' : ratio >= 0.6 ? '#c7d7f7' : '#e8effc';
                  const color = ratio >= 0.8 ? '#fff' : '#33528f';
                  return `<td class="center" title="${esc(emp.name)} · ${w}：已分配 ${used}h / 可用 40h（${pv}%）" style="background:${bg};color:${color};font-size:12px;font-weight:500;padding:4px 2px">${pv}%</td>`;
                }).join('')}
              </tr>`).join('')}</tbody>
            </table></div>
          </div>
          <div class="panel-foot" style="justify-content:flex-start">
            <div class="legend-line" style="gap:14px">
              <span><i class="legend-dot" style="background:#e8effc;border:1px solid #dbe7ff"></i>轻载 &lt;60%</span>
              <span><i class="legend-dot" style="background:#c7d7f7"></i>正常 60~80%</span>
              <span><i class="legend-dot" style="background:#93b4f7"></i>高负载 80~100%</span>
              <span><i class="legend-dot" style="background:#f8ddb5"></i>超载 &gt;100%</span>
            </div>
          </div>
        </div>
      </div>`;

      /* 技能字典 */
      root.querySelector('#resDict').addEventListener('click', () => {
        LY.openDrawer({
          title: '技能字典 · ' + M.skills.length + ' 项',
          width: 560,
          body: `<div class="alert" style="margin-bottom:10px">${icon('info', 15)}<span>技能按技术 / 数据 / 质量 / 管理 / 业务 / 交付 / 设计分类，等级 1~5 由 HR 技能认证与项目评价共同确定。</span></div>
            <div class="table-wrap"><table class="table table--compact">
              <thead><tr><th>编码</th><th>技能名称</th><th>分类</th><th class="num">持证人数</th><th class="num">覆盖人数</th></tr></thead>
              <tbody>${M.skills.map(sk => {
                const certified = M.employeeSkills.filter(r => r.skill === sk.name && r.certified).length;
                const covered = M.employees.filter(e => e.skills.indexOf(sk.name) >= 0).length;
                return `<tr><td class="mono">${esc(sk.code)}</td><td class="strong">${esc(sk.name)}</td><td>${tag(sk.category, 'info')}</td><td class="num">${certified}</td><td class="num">${covered}</td></tr>`;
              }).join('')}</tbody>
            </table></div>`,
          footer: `<button class="btn" data-close>关闭</button><button class="btn btn--primary" id="dictExport">导出技能字典</button>`,
          onMount(d) { d.querySelector('#dictExport').addEventListener('click', () => LY.toast('技能字典已导出（xlsx）', 'info')); }
        });
      });

      root.querySelector('#resRefresh').addEventListener('click', () => {
        LY.toast('可用工时已刷新：' + M.employees.length + ' 人 · ' + num(totalAvailable) + 'h（HR 同步 2026-11-10 10:02）', 'info');
      });

      root.querySelectorAll('[data-config]').forEach(btn => btn.addEventListener('click', () => {
        const emp = M.employees.find(e => e.id === btn.dataset.config);
        if (emp) openMemberModal(emp, { projectId: M.projects[0].id, role: emp.role, hours: 320 });
      }));

      root.querySelectorAll('[data-match]').forEach(btn => btn.addEventListener('click', () => {
        const emp = M.employees.find(e => e.id === btn.dataset.match);
        if (!emp) return;
        const role = ROLE_OPTIONS.indexOf(emp.role) >= 0 ? emp.role : ROLE_OPTIONS[0];
        root.querySelector('#mRole').value = role;
        const hit = M.skills.find(sk => emp.skills.indexOf(sk.name) >= 0);
        if (hit) root.querySelector('#mSkill').value = hit.name;
        root.querySelector('#matchPanel').scrollIntoView({ behavior: 'smooth', block: 'start' });
        LY.toast('已将 ' + emp.name + ' 设为匹配对象，请点击智能匹配', 'info');
      }));

      /* 智能匹配 */
      root.querySelector('#runMatch').addEventListener('click', () => {
        const req = {
          projectId: root.querySelector('#mProject').value,
          role: root.querySelector('#mRole').value,
          skill: root.querySelector('#mSkill').value,
          date: root.querySelector('#mDate').value,
          hours: Number(root.querySelector('#mHours').value) || 0,
          cap: Number(root.querySelector('#mCap').value) || 0
        };
        if (!req.hours || req.hours <= 0) { LY.toast('需求工时必须大于 0', 'error'); return; }
        if (!req.cap || req.cap <= 0) { LY.toast('每日成本上限必须大于 0', 'error'); return; }
        const reqCat = (M.skills.find(sk => sk.name === req.skill) || {}).category;

        const list = M.employees.map(emp => {
          const exact = emp.skills.indexOf(req.skill) >= 0;
          const related = !exact && emp.skills.some(s => {
            const sk = M.skills.find(x => x.name === s);
            return sk && reqCat && sk.category === reqCat;
          });
          const skillScore = exact ? 40 : related ? 25 : 0;
          const remain = Math.max(0, emp.available - emp.allocated);
          const availScore = Math.min(1, remain / req.hours) * 30;
          const costScore = emp.costDay <= req.cap ? 30 : 30 * (req.cap / emp.costDay);
          const score = Math.round(skillScore + availScore + costScore);
          return { emp, exact, related, remain, score, skillScore, availScore, costScore };
        }).sort((a, b) => b.score - a.score || a.emp.costDay - b.emp.costDay);

        const project = M.projects.find(p => p.id === req.projectId) || M.projects[0];
        root.querySelector('#matchResult').innerHTML = `
          <div class="toolbar" style="margin-bottom:6px">
            <div class="toolbar__l"><b style="font-size:13px">推荐结果</b><span class="mini">${esc(project.id)} · ${esc(req.skill)} · ${req.hours}h</span></div>
            <span class="mini">共 ${list.length} 人 · 按评分降序</span>
          </div>
          <div class="table-wrap"><table class="table table--compact">
            <thead><tr><th>成员</th><th>匹配技能</th><th class="num">可用余量</th><th class="num">日成本</th><th style="width:104px">评分</th><th class="center">操作</th></tr></thead>
            <tbody>${list.map(it => {
              const emp = it.emp;
              const hitLabel = it.exact ? '主技能命中 40' : it.related ? '相关技能 25' : '未命中 0';
              return `<tr>
                <td><div class="user-cell"><span class="avatar-sm">${esc(emp.avatar)}</span><div><div class="user-cell__n">${esc(emp.name)}</div><div class="user-cell__d">${esc(emp.role)} · ${esc(emp.level)}</div></div></div></td>
                <td>${tag(req.skill, it.exact ? 'primary' : it.related ? 'info' : 'warning')}<span class="sub">${hitLabel}</span></td>
                <td class="num">${it.remain}<span class="sub">可用 ${emp.available}h</span></td>
                <td class="num">${money(emp.costDay)}</td>
                <td><div class="progress-row"><div class="progress"><div class="progress__bar ${it.score >= 70 ? 'progress__bar--success' : it.score >= 50 ? '' : 'progress__bar--warning'}" style="width:${it.score}%"></div></div><span>${it.score}</span></div></td>
                <td class="center"><button class="link-btn" data-join="${emp.id}" ${it.remain <= 0 ? 'disabled title="无可用余量"' : ''}>加入项目</button></td>
              </tr>`;
            }).join('')}</tbody>
          </table></div>
          <div class="mini" style="margin-top:6px">评分 = 技能 40/25/0 + 余量 ≤30 + 成本 ≤30；分数越高越优先。</div>`;

        root.querySelectorAll('[data-join]').forEach(btn => btn.addEventListener('click', () => {
          if (btn.hasAttribute('disabled')) return;
          const emp = M.employees.find(e => e.id === btn.dataset.join);
          if (emp) openMemberModal(emp, { projectId: req.projectId, role: req.role, hours: req.hours });
        }));
        LY.toast('已按评分生成 ' + list.length + ' 位候选人');
      });
    }
  });

  /* ---------------- N7 工时填报与审批 ---------------- */
  LY.register('/timesheet', {
    title: '工时管理', crumb: ['资源与工时', '工时管理'],
    render(root) {
      const taskById = id => M.tasks.find(t => t.id === id);
      const extraTasks = [];
      M.timesheetItems.forEach(it => {
        if (!taskById(it.taskId)) {
          extraTasks.push({ id: it.taskId, code: it.taskId, name: (it.content || '').split('：')[0] });
        }
      });
      const TASKS = M.tasks.concat(extraTasks);
      const taskOptions = sel => TASKS.map(t => `<option value="${esc(t.id)}" ${t.id === sel ? 'selected' : ''}>${esc(t.code)} · ${esc(t.name)}</option>`).join('');
      const workTypeOptions = sel => WORK_TYPES.map(w => `<option value="${w[0]}" ${w[0] === sel ? 'selected' : ''}>${w[1]}</option>`).join('');
      const costCenterOptions = sel => COST_CENTERS.map(c => `<option ${c === sel ? 'selected' : ''}>${esc(c)}</option>`).join('');
      const projectName = id => (M.projects.find(p => p.id === id) || M.projects[0]).name;

      let uidSeq = 100;
      const newDays = () => {
        const d = {};
        M.weekDays.forEach(w => { d[w.key] = 0; });
        return d;
      };

      /* 初始 7 条明细：逐条展示；已完成任务的工时按内部成本处理，默认不计费 */
      const rows = M.timesheetItems.map((it, i) => {
        const t = taskById(it.taskId);
        const days = newDays();
        const wd = M.weekDays.find(d => d.date === it.date) || M.weekDays.find(d => d.key === it.day);
        days[wd ? wd.key : it.day] = it.hours;
        return {
          uid: 'ts' + i, projectId: it.projectId, taskId: it.taskId, workType: it.workType,
          costCenter: it.costCenter, billable: !!it.billable && !(t && t.status === 'COMPLETED'),
          days, content: it.content || ''
        };
      });

      let docStatus = 'DRAFT';
      let activeTab = 'mine';

      const rowTotal = r => sum(WEEK_KEYS, k => Number(r.days[k]) || 0);
      const weekTotal = () => sum(rows, rowTotal);
      const billableTotal = () => sum(rows.filter(r => r.billable), rowTotal);
      const dayTotal = key => sum(rows, r => Number(r.days[key]) || 0);

      const pendingRows = M.timesheets.filter(t => t.status === 'PENDING').map(t => Object.assign({}, t));
      const lockedRows = M.timesheets.filter(t => t.status === 'LOCKED');

      root.innerHTML = `
      <div class="page-head">
        <div class="page-head__l">
          <div class="page-title">工时管理</div>
          <div class="page-sub">按任务填报 · 工时类型 · 可计费 · 成本中心 · 产能校验</div>
        </div>
        <div class="page-actions">
          <div class="field" style="margin-bottom:0"><span class="field-label">周期</span>
            <select class="select" id="tsWeek" style="width:190px">
              <option value="2026-W44">2026-W44（10-26 ~ 11-01）</option>
              <option value="2026-W45" selected>2026-W45（11-02 ~ 11-08）</option>
              <option value="2026-W46">2026-W46（11-09 ~ 11-15）</option>
            </select>
          </div>
          <button class="btn" id="tsCopy">${icon('copy', 14)}批量复制上周</button>
          <button class="btn btn--primary" id="tsSubmitTop">${icon('send', 14)}提交审批</button>
        </div>
      </div>

      <div class="kpi-grid" style="grid-template-columns:repeat(4,minmax(0,1fr))">
        <div class="kpi"><div class="kpi-label">本周填报</div><div class="kpi-value" id="kpiFilled">40<small>h</small></div><div class="kpi-foot" id="kpiFilledFoot">7 条任务 · 2026-W45</div></div>
        <div class="kpi kpi--info"><div class="kpi-label">可用工时</div><div class="kpi-value">40<small>h</small></div><div class="kpi-foot">标准周产能 · 5 × 8h</div></div>
        <div class="kpi" id="kpiCapCard"><div class="kpi-label">产能占用</div><div class="kpi-value" id="kpiCap">100<small>%</small></div><div class="kpi-foot" id="kpiCapFoot">40h / 40h · 已达上限</div></div>
        <div class="kpi kpi--success"><div class="kpi-label">可计费工时</div><div class="kpi-value" id="kpiBillable">30<small>h</small></div><div class="kpi-foot" id="kpiBillableFoot">可计费 4 条 · 已完成任务不计费</div></div>
      </div>

      <div class="panel" style="padding:0">
        <div class="tabs">
          <div class="tabs__item is-active" data-ts-tab="mine">我的周报</div>
          <div class="tabs__item" data-ts-tab="pending">待审批 <span class="numb">${pendingRows.length}</span></div>
          <div class="tabs__item" data-ts-tab="locked">已锁定 <span class="numb">${lockedRows.length}</span></div>
        </div>
        <div id="tsBody"></div>
      </div>

      <div class="alert" style="margin-top:12px;align-items:flex-start">
        ${icon('info', 15)}
        <div>
          <b style="font-size:13px">工时明细下游流转</b>
          <div style="margin-top:4px;font-size:12px;line-height:19px">
            ① 结算：locked = 1 且 work_type 可计费（SETTLE）→ 生成结算单；
            ② 人工成本分摊：fin_labor_cost_allocation 按工时分摊完整用工成本；
            ③ 项目实际成本：经 task_id 链路归集到项目 / 任务 / 阶段。
          </div>
        </div>
      </div>`;

      const host = root.querySelector('#tsBody');

      function drawWeek() {
        host.innerHTML = `
          <div class="toolbar" style="padding:12px 16px;border-bottom:1px solid var(--ly-border-light)">
            <div class="toolbar__l">
              <span class="avatar-sm">张</span><b style="font-size:14px">张伟</b>
              <span class="mini">E1002 · 技术中心 · 架构师 · 2026-W45</span>
            </div>
            <div class="toolbar__r"><span id="tsDocStatus">${statusTag('timesheet', docStatus)}</span><span class="mini">审批人：陈立</span></div>
          </div>
          <div id="capAlert" style="padding:12px 16px 0"></div>
          <div class="table-wrap" style="margin-top:10px"><table class="table table--compact">
            <thead><tr>
              <th style="min-width:220px">任务 / 项目</th>
              <th style="width:126px">工时类型</th>
              <th style="width:104px">成本中心</th>
              <th class="center" style="width:58px">可计费</th>
              ${M.weekDays.map(d => `<th class="center" style="width:54px"><div>${d.label.slice(6)}</div><div style="font-size:11px;color:#909399;font-weight:400">${d.date.slice(5)}</div></th>`).join('')}
              <th class="num" style="width:56px">合计</th>
              <th class="center" style="width:48px">操作</th>
            </tr></thead>
            <tbody>${rows.map(r => `<tr data-row="${r.uid}">
              <td>
                <select class="select input--sm" data-uid="${r.uid}" data-field="task" style="width:100%;min-width:0">${taskOptions(r.taskId)}</select>
                <span class="sub" style="display:block;white-space:nowrap;overflow:hidden;text-overflow:ellipsis">${esc(projectName(r.projectId))} · ${esc(r.content || '')}</span>
              </td>
              <td><select class="select input--sm" data-uid="${r.uid}" data-field="workType" style="width:100%;min-width:0">${workTypeOptions(r.workType)}</select></td>
              <td><select class="select input--sm" data-uid="${r.uid}" data-field="costCenter" style="width:100%;min-width:0">${costCenterOptions(r.costCenter)}</select></td>
              <td class="center"><label class="checkbox" style="justify-content:center"><input type="checkbox" data-uid="${r.uid}" data-field="billable" ${r.billable ? 'checked' : ''}></label></td>
              ${M.weekDays.map(d => `<td class="center"><input class="input input--sm" type="number" min="0" max="24" step="0.5" data-uid="${r.uid}" data-day="${d.key}" value="${r.days[d.key] || 0}" style="width:44px;min-width:44px;padding:0 2px;text-align:center"></td>`).join('')}
              <td class="num strong" data-rowtotal="${r.uid}">${rowTotal(r)}</td>
              <td class="center"><button class="link-btn link-btn--danger" data-del="${r.uid}" title="删除">${icon('trash', 13)}</button></td>
            </tr>`).join('')}
              <tr class="row-total">
                <td colspan="4">合计（可计费 <span id="billableInline">${billableTotal()}</span>h）</td>
                ${M.weekDays.map(d => `<td class="center" data-daytotal="${d.key}">${dayTotal(d.key)}</td>`).join('')}
                <td class="num" data-grand="1">${weekTotal()}</td><td></td>
              </tr>
            </tbody>
          </table></div>
          <div style="padding:12px 16px 0">
            <div style="display:flex;align-items:center;justify-content:space-between;font-size:12px;color:var(--ly-text-regular)">
              <span>产能占用（总工时 / 40h）</span><span id="capText" class="num">${weekTotal()} / 40h · ${Math.round(weekTotal() / 40 * 100)}%</span>
            </div>
            <div class="progress" style="height:8px;margin-top:6px"><div class="progress__bar" id="capBar" style="width:${Math.min(weekTotal() / 40 * 100, 100)}%"></div></div>
          </div>
          <div class="toolbar" style="padding:12px 16px">
            <div class="toolbar__l"><button class="btn btn--sm" id="addRow">${icon('plus', 13)}添加行</button><span class="mini">每日 ≤ 8h 为常规填报，> 12h 需说明</span></div>
            <div class="toolbar__r"><button class="btn btn--sm" id="saveDraft">保存草稿</button><button class="btn btn--sm btn--primary" id="submitSheet">${icon('send', 13)}提交审批</button></div>
          </div>`;
        bindWeek();
        recalcWeek();
      }

      function recalcWeek() {
        const total = weekTotal();
        const bill = billableTotal();
        const cap = Math.round(total / 40 * 100);
        const f = root.querySelector('#kpiFilled');
        if (f) f.innerHTML = num(total) + '<small>h</small>';
        const ff = root.querySelector('#kpiFilledFoot');
        if (ff) ff.textContent = rows.length + ' 条任务 · 2026-W45';
        const kc = root.querySelector('#kpiCapCard');
        if (kc) kc.classList.toggle('kpi--danger', total > 40);
        const kp = root.querySelector('#kpiCap');
        if (kp) kp.innerHTML = cap + '<small>%</small>';
        const kpf = root.querySelector('#kpiCapFoot');
        if (kpf) kpf.textContent = total + 'h / 40h · ' + (total > 40 ? '超限' : total === 40 ? '已达上限' : '可继续填报');
        const kb = root.querySelector('#kpiBillable');
        if (kb) kb.innerHTML = num(bill) + '<small>h</small>';
        const kbf = root.querySelector('#kpiBillableFoot');
        if (kbf) kbf.textContent = '可计费 ' + rows.filter(r => r.billable).length + ' 条 · 已完成任务默认不计费';

        rows.forEach(r => {
          const cell = root.querySelector('[data-rowtotal="' + r.uid + '"]');
          if (cell) cell.textContent = rowTotal(r);
        });
        M.weekDays.forEach(d => {
          const cell = root.querySelector('[data-daytotal="' + d.key + '"]');
          if (cell) cell.textContent = dayTotal(d.key);
        });
        const grand = root.querySelector('[data-grand]');
        if (grand) grand.textContent = total;
        const inline = root.querySelector('#billableInline');
        if (inline) inline.textContent = bill;
        const bar = root.querySelector('#capBar');
        if (bar) {
          bar.style.width = Math.min(total / 40 * 100, 100) + '%';
          bar.className = 'progress__bar' + (total > 40 ? ' progress__bar--danger' : total >= 36 ? ' progress__bar--warning' : '');
        }
        const ct = root.querySelector('#capText');
        if (ct) ct.textContent = total + ' / 40h · ' + cap + '%';
        const alertBox = root.querySelector('#capAlert');
        if (alertBox) {
          if (total > 40) {
            alertBox.innerHTML = `<div class="alert alert--danger">${icon('alert', 15)}<span>超出可用工时 ${total - 40} h，无法提交</span></div>`;
          } else if (total === 40) {
            alertBox.innerHTML = `<div class="alert alert--warning">${icon('alert', 15)}<span>本周工时已达可用工时上限 40h，新增工时会触发产能超限校验</span></div>`;
          } else {
            alertBox.innerHTML = `<div class="alert">${icon('info', 15)}<span>本周已填报 ${total}h，剩余可用 ${40 - total}h。</span></div>`;
          }
        }
      }

      function bindWeek() {
        host.querySelectorAll('input[data-day]').forEach(inp => inp.addEventListener('input', () => {
          const r = rows.find(x => x.uid === inp.dataset.uid);
          if (!r) return;
          let v = Number(inp.value);
          if (isNaN(v) || v < 0) v = 0;
          r.days[inp.dataset.day] = v;
          recalcWeek();
        }));
        host.querySelectorAll('input[data-field="billable"]').forEach(inp => inp.addEventListener('change', () => {
          const r = rows.find(x => x.uid === inp.dataset.uid);
          if (r) r.billable = inp.checked;
          recalcWeek();
        }));
        host.querySelectorAll('select[data-field]').forEach(sel => sel.addEventListener('change', () => {
          const r = rows.find(x => x.uid === sel.dataset.uid);
          if (!r) return;
          r[sel.dataset.field] = sel.value;
          if (sel.dataset.field === 'task') {
            const t = taskById(sel.value);
            r.content = t ? t.name : r.content;
          }
          recalcWeek();
        }));
        host.querySelectorAll('[data-del]').forEach(btn => btn.addEventListener('click', () => {
          const idx = rows.findIndex(x => x.uid === btn.dataset.del);
          if (idx >= 0) { rows.splice(idx, 1); drawWeek(); }
        }));
        const add = host.querySelector('#addRow');
        if (add) add.addEventListener('click', () => {
          rows.push({
            uid: 'ts' + (uidSeq++), projectId: M.projects[0].id, taskId: TASKS[0].id,
            workType: 'CUSTOMER_PROJECT', costCenter: '技术中心', billable: true,
            days: newDays(), content: TASKS[0].name
          });
          drawWeek();
        });
        const save = host.querySelector('#saveDraft');
        if (save) save.addEventListener('click', () => {
          docStatus = 'DRAFT';
          const st = root.querySelector('#tsDocStatus');
          if (st) st.innerHTML = statusTag('timesheet', 'DRAFT');
          LY.toast('草稿已保存（2026-W45 · ' + weekTotal() + 'h）', 'info');
        });
        const sub = host.querySelector('#submitSheet');
        if (sub) sub.addEventListener('click', submitSheet);
      }

      function submitSheet() {
        if (activeTab !== 'mine') switchTab('mine');
        const total = weekTotal();
        if (total > 40) { LY.toast('超出可用工时 ' + (total - 40) + ' h，无法提交', 'error'); return; }
        if (docStatus === 'PENDING') { LY.toast('工时单已在审批中，审批人：陈立', 'info'); return; }
        docStatus = 'PENDING';
        const st = root.querySelector('#tsDocStatus');
        if (st) st.innerHTML = statusTag('timesheet', 'PENDING');
        LY.toast('工时单已提交，审批人：陈立');
      }

      function drawPending() {
        host.innerHTML = `
          <div style="padding:12px 16px 0">
            <div class="alert">${icon('info', 15)}<span>以下为待项目经理审批的工时单，通过后进入锁定队列；驳回需填写原因并通知申请人。</span></div>
          </div>
          <div class="table-wrap" style="margin-top:10px"><table class="table table--compact">
            <thead><tr><th>工时单号</th><th>员工</th><th>项目</th><th>周期</th><th class="num">总工时</th><th class="num">可计费</th><th>提交时间</th><th>状态</th><th class="center">操作</th></tr></thead>
            <tbody>${pendingRows.map(t => `<tr data-tsrow="${t.id}">
              <td class="mono">${esc(t.no)}</td>
              <td><div class="user-cell"><span class="avatar-sm">${esc(t.employee.slice(0, 1))}</span><span class="user-cell__n">${esc(t.employee)}</span></div></td>
              <td>${esc(t.project)}</td>
              <td class="mono">${esc(t.week)}</td>
              <td class="num strong">${t.total}h</td>
              <td class="num">${t.billable}h</td>
              <td>${esc(t.submitTime || '-')}</td>
              <td>${statusTag('timesheet', t.status)}</td>
              <td class="center">${t.status === 'PENDING'
                ? `<button class="link-btn" data-approve="${t.id}">通过</button><button class="link-btn link-btn--danger" data-reject="${t.id}">驳回</button>`
                : '<span class="text-muted">已处理</span>'}</td>
            </tr>`).join('')}</tbody>
          </table></div>`;
        host.querySelectorAll('[data-approve]').forEach(btn => btn.addEventListener('click', () => {
          const t = pendingRows.find(x => x.id === btn.dataset.approve);
          if (!t) return;
          LY.confirm({
            title: '通过工时单', okText: '通过',
            content: `确认通过 <b>${esc(t.no)}</b>（${esc(t.employee)} · ${esc(t.week)} · ${t.total}h）？通过后工时将进入锁定队列。`,
            onOk() {
              t.status = 'APPROVED';
              LY.toast('工时单 ' + t.no + ' 已通过，已进入锁定队列');
              drawPending();
            }
          });
        }));
        host.querySelectorAll('[data-reject]').forEach(btn => btn.addEventListener('click', () => {
          const t = pendingRows.find(x => x.id === btn.dataset.reject);
          if (!t) return;
          LY.openModal({
            title: '驳回工时单 · ' + t.no, width: 480,
            body: `<div class="alert alert--warning">${icon('alert', 15)}<span>${esc(t.employee)} · ${esc(t.week)} · ${t.total}h，驳回后将通知申请人修改并重新提交。</span></div>
              <div class="form-item" style="margin-top:14px"><label>驳回原因 <span class="text-danger">*</span></label><textarea class="textarea" id="rejReason" placeholder="请填写驳回原因，例如：周三工时超出项目计划"></textarea></div>`,
            footer: `<button class="btn" data-close>取消</button><button class="btn btn--danger" id="rejOk">确认驳回</button>`,
            onMount(m) {
              m.querySelector('#rejOk').addEventListener('click', () => {
                const reason = m.querySelector('#rejReason').value.trim();
                if (!reason) { LY.toast('请填写驳回原因', 'error'); return; }
                t.status = 'REJECTED';
                LY.closeModal();
                LY.toast('工时单 ' + t.no + ' 已驳回，原因已通知申请人');
                drawPending();
              });
            }
          });
        }));
      }

      function drawLocked() {
        host.innerHTML = `
          <div style="padding:12px 16px 0">
            <div class="alert">${icon('lock', 15)}<span>锁定后工时不可修改，已进入结算池（locked = 1 + work_type 可计费）。</span></div>
          </div>
          <div class="table-wrap" style="margin-top:10px"><table class="table table--compact">
            <thead><tr><th>工时单号</th><th>员工</th><th>项目</th><th>周期</th><th class="num">总工时</th><th class="num">可计费</th><th>提交时间</th><th>状态</th><th class="center">操作</th></tr></thead>
            <tbody>${lockedRows.map(t => `<tr>
              <td class="mono">${esc(t.no)}</td>
              <td><div class="user-cell"><span class="avatar-sm alt">${esc(t.employee.slice(0, 1))}</span><span class="user-cell__n">${esc(t.employee)}</span></div></td>
              <td>${esc(t.project)}</td>
              <td class="mono">${esc(t.week)}</td>
              <td class="num strong">${t.total}h</td>
              <td class="num">${t.billable}h</td>
              <td>${esc(t.submitTime || '-')}</td>
              <td>${statusTag('timesheet', t.status)}</td>
              <td class="center"><button class="link-btn" data-view="${t.id}">查看明细</button></td>
            </tr>`).join('')}</tbody>
          </table></div>
          <div class="alert" style="margin:12px 16px">${icon('info', 15)}<span>锁定工时共 ${lockedRows.length} 条，合计 ${sum(lockedRows, x => x.total)}h；其中可计费 ${sum(lockedRows, x => x.billable)}h 已流向结算池。</span></div>`;
        host.querySelectorAll('[data-view]').forEach(btn => btn.addEventListener('click', () => {
          LY.toast('工时明细已锁定，仅支持查看（' + btn.dataset.view + '）', 'info');
        }));
      }

      function switchTab(key) {
        activeTab = key;
        root.querySelectorAll('[data-ts-tab]').forEach(x => x.classList.toggle('is-active', x.dataset.tsTab === key));
        if (key === 'mine') drawWeek();
        else if (key === 'pending') drawPending();
        else drawLocked();
      }

      root.querySelectorAll('[data-ts-tab]').forEach(t => t.addEventListener('click', () => switchTab(t.dataset.tsTab)));

      root.querySelector('#tsWeek').addEventListener('change', e => LY.toast('已切换周期：' + e.target.value, 'info'));

      root.querySelector('#tsSubmitTop').addEventListener('click', submitSheet);

      root.querySelector('#tsCopy').addEventListener('click', () => {
        const preview = M.timesheetItems.map(it => {
          const t = taskById(it.taskId);
          return `<tr><td>${esc((t ? t.code + ' ' + t.name : it.taskId))}</td><td>${esc((WORK_TYPES.find(w => w[0] === it.workType) || ['', it.workType])[1])}</td><td class="num">${it.hours}h</td><td class="center">${it.billable ? tag('是', 'success') : tag('否', 'info')}</td></tr>`;
        }).join('');
        LY.openModal({
          title: '批量复制上周 · 2026-W44', width: 600,
          body: `<div class="alert">${icon('copy', 15)}<span>将 2026-W44（10-26 ~ 11-01）的 ${M.timesheetItems.length} 条工时复制到 2026-W45，合计 ${sum(M.timesheetItems, x => x.hours)}h。</span></div>
            <div class="table-wrap" style="margin-top:12px"><table class="table table--compact">
              <thead><tr><th>任务</th><th>工时类型</th><th class="num">工时</th><th class="center">可计费</th></tr></thead>
              <tbody>${preview}</tbody>
            </table></div>
            <div class="alert alert--warning" style="margin-top:12px">${icon('alert', 15)}<span>复制后本周将超出 40h 产能上限，请调整工时后再提交。</span></div>`,
          footer: `<button class="btn" data-close>取消</button><button class="btn btn--primary" id="doCopy">复制到本周</button>`,
          onMount(m) {
            m.querySelector('#doCopy').addEventListener('click', () => {
              const copies = rows.map(r => Object.assign({}, r, {
                uid: 'ts' + (uidSeq++), days: Object.assign({}, r.days), content: r.content
              }));
              copies.forEach(c => rows.push(c));
              LY.closeModal();
              switchTab('mine');
              LY.toast('已复制上周 ' + copies.length + ' 条工时，超出产能请调整', 'warning');
            });
          }
        });
      });

      drawWeek();
    }
  });
})();
