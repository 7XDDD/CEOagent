/* ================= Shell：布局 / 路由 / 通用组件 ================= */
(function () {
  const LY = window.LY;
  const M = LY.MOCK;
  LY.pages = {};
  LY.register = function (route, def) { LY.pages[route] = def; };

  /* ---------- utils ---------- */
  const esc = s => String(s == null ? '' : s).replace(/[&<>"]/g, c => ({ '&': '&amp;', '<': '&lt;', '>': '&gt;', '"': '&quot;' }[c]));
  const money = n => (n == null || isNaN(n)) ? '-' : Number(n).toLocaleString('zh-CN', { minimumFractionDigits: 2, maximumFractionDigits: 2 });
  const num = n => (n == null || isNaN(n)) ? '-' : Number(n).toLocaleString('zh-CN');
  const wan = n => {
    if (n == null || isNaN(n)) return '-';
    if (Math.abs(n) >= 10000) return (n / 10000).toLocaleString('zh-CN', { minimumFractionDigits: 1, maximumFractionDigits: 1 }) + ' 万';
    return money(n);
  };
  const pct = (n, d = 1) => (n == null || isNaN(n)) ? '-' : (n * 100).toFixed(d) + '%';
  const icon = (name, size = 16, cls = 'ic') => `<svg class="${cls}" width="${size}" height="${size}" aria-hidden="true"><use href="#i-${name}"></use></svg>`;

  const STATUS = {
    contract: { DRAFT: ['草稿', 'info'], UNSIGNED: ['待签约', 'warning'], SIGNED: ['已签约', 'primary'], IN_PROGRESS: ['执行中', 'success'], COMPLETED: ['已完成', 'info'], TERMINATED: ['已终止', 'danger'] },
    project: { PREPARING: ['准备中', 'info'], IN_PROGRESS: ['进行中', 'success'], PAUSED: ['已暂停', 'warning'], COMPLETED: ['已完成', 'info'], CANCELLED: ['已取消', 'danger'] },
    task: { NOT_STARTED: ['未开始', 'info'], IN_PROGRESS: ['进行中', 'primary'], COMPLETED: ['已完成', 'success'], BLOCKED: ['阻塞', 'danger'], CANCELLED: ['已取消', 'info'] },
    timesheet: { DRAFT: ['草稿', 'info'], PENDING: ['待审批', 'warning'], APPROVED: ['已通过', 'success'], REJECTED: ['已驳回', 'danger'], LOCKED: ['已锁定', 'primary'] },
    settlement: { DRAFT: ['草稿', 'info'], PENDING: ['待确认', 'warning'], CONFIRMED: ['已确认', 'primary'], SETTLED: ['已结算', 'success'], CANCELLED: ['已取消', 'danger'] },
    invoice: { DRAFT: ['草稿', 'info'], ISSUED: ['已开具', 'success'], VOID: ['已作废', 'info'], RED_FLUSH: ['已红冲', 'danger'] },
    pay: { UNPAID: ['未回款', 'warning'], PARTIAL: ['部分回款', 'warning'], PAID: ['已回款', 'success'], OVERDUE: ['已逾期', 'danger'], NONE: ['未开票', 'info'] },
    expense: { DRAFT: ['草稿', 'info'], SUBMITTED: ['待审批', 'warning'], APPROVED: ['已审批', 'primary'], PAID: ['已支付', 'success'], REJECTED: ['已驳回', 'danger'] },
    approval: { PENDING: ['审批中', 'warning'], APPROVED: ['已通过', 'success'], REJECTED: ['已驳回', 'danger'], CANCELLED: ['已撤回', 'info'] },
    workType: { CUSTOMER_PROJECT: ['客户项目', 'primary'], INTERNAL_RND: ['内部研发', 'success'], INTERNAL_ADMIN: ['内部管理', 'info'], TRAINING: ['培训', 'warning'], LEAVE: ['请假', 'warning'], IDLE: ['闲置', 'danger'], OTHER: ['其他', 'info'] },
    nature: { SETTLE: ['可结算', 'success'], NON_SETTLE: ['不可结算', 'info'] },
    health: { '正常': ['正常', 'success'], '风险': ['风险', 'warning'], '预警': ['预警', 'danger'], '待立项': ['待立项', 'info'] },
    batch: { CUSTOMER: ['客户结算', 'primary'], SUPPLIER: ['供应商结算', 'warning'] }
  };
  function statusTag(key, val) {
    const map = STATUS[key] || {};
    const it = map[val];
    if (!it) return `<span class="tag tag--info">${esc(val || '-')}</span>`;
    return `<span class="tag tag--${it[1]}">${it[0]}</span>`;
  }
  const tag = (text, type = 'info') => `<span class="tag tag--${type}">${esc(text)}</span>`;

  LY.esc = esc; LY.money = money; LY.num = num; LY.wan = wan; LY.pct = pct;
  LY.icon = icon; LY.tag = tag; LY.statusTag = statusTag; LY.STATUS = STATUS;
  LY.date = s => s || '-';
  LY.dailyCost = (emp, day) => Math.round((emp.costDay || 0) * day);

  /* ---------- toast ---------- */
  let toastTimer = null;
  LY.toast = function (msg, type = 'success') {
    let el = document.querySelector('.ly-toast');
    if (el) el.remove();
    el = document.createElement('div');
    el.className = 'ly-toast' + (type === 'info' ? ' ly-toast--info' : type === 'error' ? ' ly-toast--error' : type === 'warning' ? ' ly-toast--warning' : '');
    el.innerHTML = icon(type === 'error' ? 'alert' : type === 'info' ? 'info' : type === 'warning' ? 'alert' : 'check-circle', 15) + `<span>${esc(msg)}</span>`;
    document.body.appendChild(el);
    clearTimeout(toastTimer);
    toastTimer = setTimeout(() => el.remove(), 2400);
  };

  /* ---------- modal / drawer ---------- */
  function closeAny() {
    document.querySelectorAll('.modal-mask,.drawer-mask,.drawer').forEach(n => n.remove());
  }
  LY.closeModal = LY.closeDrawer = closeAny;
  LY.openModal = function (opt) {
    closeAny();
    const mask = document.createElement('div');
    mask.className = 'modal-mask';
    mask.innerHTML = `<div class="modal" style="width:${opt.width || 560}px">
      <div class="modal-head"><h3>${esc(opt.title || '')}</h3>${icon('close', 15)}</div>
      <div class="modal-body">${opt.body || ''}</div>
      <div class="modal-foot">${opt.footer || '<button class="btn" data-close>取消</button>'}</div>
    </div>`;
    document.body.appendChild(mask);
    mask.addEventListener('click', e => { if (e.target === mask || e.target.closest('[data-close]') || e.target.closest('.modal-head .ic')) closeAny(); });
    if (opt.onMount) opt.onMount(mask);
    return mask;
  };
  LY.openDrawer = function (opt) {
    closeAny();
    const mask = document.createElement('div');
    mask.className = 'drawer-mask';
    const drawer = document.createElement('div');
    drawer.className = 'drawer';
    drawer.style.width = (opt.width || 620) + 'px';
    drawer.innerHTML = `<div class="drawer-head"><h3>${opt.title || ''}</h3>${icon('close', 15)}</div>
      <div class="drawer-body">${opt.body || ''}</div>
      ${opt.footer === null ? '' : `<div class="drawer-foot">${opt.footer || '<button class="btn" data-close>关闭</button>'}</div>`}`;
    document.body.appendChild(mask); document.body.appendChild(drawer);
    const close = () => closeAny();
    mask.addEventListener('click', close);
    drawer.querySelector('.drawer-head .ic').addEventListener('click', close);
    drawer.querySelectorAll('[data-close]').forEach(b => b.addEventListener('click', close));
    if (opt.onMount) opt.onMount(drawer);
    return drawer;
  };
  LY.confirm = function (opt) {
    const body = `<div style="display:flex;gap:10px;align-items:flex-start">
      <span style="color:var(--ly-warning);margin-top:2px">${icon('alert', 18)}</span>
      <div>${opt.content || ''}</div></div>`;
    LY.openModal({
      title: opt.title || '操作确认', width: opt.width || 440, body,
      footer: `<button class="btn" data-close>取消</button><button class="btn ${opt.danger ? 'btn--danger' : 'btn--primary'}" id="lyConfirmOk">${esc(opt.okText || '确定')}</button>`,
      onMount(m) {
        m.querySelector('#lyConfirmOk').addEventListener('click', () => {
          closeAny();
          if (opt.onOk) opt.onOk();
        });
      }
    });
  };

  /* ---------- nav ---------- */
  const NAV = [
    { path: '/home', title: '经营工作台', icon: 'home' },
    {
      title: '客户与商机', icon: 'users', children: [
        { path: '/customer', title: '客户主数据', icon: 'building' },
        { path: '/opportunity', title: '商机管理', icon: 'target' }
      ]
    },
    {
      title: '合同管理', icon: 'file', children: [
        { path: '/contract', title: '合同台账', icon: 'receipt' }
      ]
    },
    {
      title: '项目交付', icon: 'folder', children: [
        { path: '/project', title: '项目列表', icon: 'layers' },
        { path: '/wbs', title: '阶段与 WBS', icon: 'list' },
        { path: '/budget', title: '项目预算', icon: 'coins' }
      ]
    },
    {
      title: '资源与工时', icon: 'user', children: [
        { path: '/resource', title: '资源池', icon: 'users' },
        { path: '/timesheet', title: '工时管理', icon: 'clock' }
      ]
    },
    {
      title: '结算与收款', icon: 'wallet', children: [
        { path: '/settlement', title: '结算管理', icon: 'coins' },
        { path: '/invoice', title: '开票管理', icon: 'receipt' },
        { path: '/receivable', title: '回款与应收', icon: 'wallet' }
      ]
    },
    {
      title: '成本与利润', icon: 'chart', children: [
        { path: '/cost', title: '成本归集', icon: 'coins' },
        { path: '/profit', title: '项目利润', icon: 'trend' },
        { path: '/analysis', title: '经营分析', icon: 'pie' }
      ]
    },
    {
      title: '协同与治理', icon: 'shield', children: [
        { path: '/approval', title: '审批中心', icon: 'check-circle', badge: 5 },
        { path: '/integration', title: '主数据融合', icon: 'database' }
      ]
    }
  ];
  const NAV_MAP = {};
  NAV.forEach(g => { if (g.path) NAV_MAP[g.path] = g.title; (g.children || []).forEach(c => NAV_MAP[c.path] = c.title); });
  function parentOf(path) {
    for (const g of NAV) if (g.children && g.children.some(c => c.path === path)) return g;
    return null;
  }

  /* ---------- router ---------- */
  function parseHash() {
    const raw = location.hash.replace(/^#/, '') || '/home';
    const [path, qs] = raw.split('?');
    const query = {};
    (qs || '').split('&').filter(Boolean).forEach(kv => {
      const [k, v] = kv.split('=');
      query[decodeURIComponent(k)] = decodeURIComponent(v || '');
    });
    return { path: path || '/home', query };
  }
  function basePath(path) {
    if (path.startsWith('/contract/detail')) return '/contract/detail';
    if (path.startsWith('/project/detail')) return '/project/detail';
    return path;
  }
  LY.go = function (route) { location.hash = '#' + route; };

  let tabs = [{ route: '/home', title: '经营工作台' }];
  let activeRoute = '/home';

  function tabsHtml() {
    return tabs.map(t => {
      const active = t.route === activeRoute;
      return `<div class="ly-tab ${active ? 'is-active' : ''}" data-tab="${esc(t.route)}">
        <span>${esc(t.title)}</span>${t.route === '/home' ? '' : '<i data-close-tab>×</i>'}
      </div>`;
    }).join('');
  }
  function renderTabs() {
    const wrap = document.getElementById('lyTabs');
    if (!wrap) return;
    wrap.innerHTML = tabsHtml();
    wrap.querySelectorAll('.ly-tab').forEach(el => {
      el.addEventListener('click', e => {
        if (e.target.hasAttribute('data-close-tab')) {
          e.stopPropagation();
          const route = el.dataset.tab;
          tabs = tabs.filter(t => t.route !== route);
          if (activeRoute === route) LY.go(tabs[tabs.length - 1].route);
          else renderTabs();
          return;
        }
        LY.go(el.dataset.tab);
      });
    });
  }
  function addTab(route, title) {
    if (!tabs.some(t => t.route === route)) tabs.push({ route, title });
    renderTabs();
  }

  const layoutHtml = () => `
  <div class="ly-layout">
    <aside class="ly-sidebar" id="lySidebar">
      <div class="ly-logo" id="lyLogo">
        <div class="ly-logo__mark">链</div>
        <div class="ly-logo__text">链宇企业数字化平台<small>经营一体门户 · V3.0</small></div>
      </div>
      <nav class="ly-nav" id="lyNav"></nav>
    </aside>
    <div class="ly-main">
      <header class="ly-header">
        <div class="ly-header__left">
          <div class="ly-collapse" id="lyCollapse">${icon('list', 18)}</div>
          <div class="ly-crumb" id="lyCrumb"></div>
        </div>
        <div class="ly-header__right">
          <div class="ly-hicon" id="lyRefresh" title="刷新">${icon('refresh', 17)}</div>
          <div class="ly-hicon" id="lyBell" title="通知"><span class="numb">5</span>${icon('bell', 17)}</div>
          <div class="ly-user" id="lyUser">
            <div class="ly-avatar">陈</div>
            <span class="ly-user__name">陈立</span>
            <span class="ly-user__dept">交付中心 · 项目经理</span>
            ${icon('chevron-down', 12)}
          </div>
        </div>
      </header>
      <div class="ly-tabs" id="lyTabs"></div>
      <main class="ly-content" id="lyContent"><div id="page" class="ly-page"></div></main>
    </div>
  </div>`;

  function renderNav(activePath) {
    const nav = document.getElementById('lyNav');
    if (!nav) return;
    const activeBase = basePath(activePath);
    nav.innerHTML = NAV.map((g) => {
      if (g.path) {
        const active = activeBase === g.path;
        return `<div class="ly-menu-group"><div class="ly-menu-title ${active ? 'is-active-parent' : ''}" data-route="${g.path}">
          ${icon(g.icon, 18)}<span>${g.title}</span></div></div>`;
      }
      const open = !!parentOf(activeBase) && parentOf(activeBase).title === g.title;
      return `<div class="ly-menu-group ${open ? 'is-open' : ''}" data-group>
        <div class="ly-menu-title">${icon(g.icon, 18)}<span>${g.title}</span>${icon('chevron-down', 12, 'arrow')}</div>
        <div class="ly-sub">${g.children.map(c => `
          <div class="ly-menu-item ${activeBase === c.path ? 'is-active' : ''}" data-route="${c.path}">
            ${icon(c.icon, 16)}<span>${c.title}</span>${c.badge ? `<span class="badge">${c.badge}</span>` : ''}
          </div>`).join('')}</div>
      </div>`;
    }).join('');
    nav.querySelectorAll('.ly-menu-title[data-route],.ly-menu-item[data-route]').forEach(el => {
      el.addEventListener('click', () => {
        LY.go(el.dataset.route);
        const sb = document.getElementById('lySidebar');
        if (sb) sb.classList.remove('is-mobile-open');
      });
    });
    nav.querySelectorAll('[data-group] > .ly-menu-title').forEach(el => {
      el.addEventListener('click', () => {
        const grp = el.parentElement;
        grp.classList.toggle('is-open');
      });
    });
  }

  function renderShell() {
    const app = document.getElementById('app');
    app.innerHTML = layoutHtml();
    document.getElementById('lyCollapse').addEventListener('click', () => {
      const sb = document.getElementById('lySidebar');
      if (window.innerWidth <= 860) sb.classList.toggle('is-mobile-open');
      else sb.classList.toggle('is-collapse');
    });
    document.getElementById('lyLogo').addEventListener('click', () => LY.go('/home'));
    document.getElementById('lyRefresh').addEventListener('click', () => { navigate(); LY.toast('已刷新当前页面', 'info'); });
    document.getElementById('lyBell').addEventListener('click', () => {
      LY.openDrawer({
        title: '通知与待办',
        width: 480,
        body: `<div class="tabs" style="margin-bottom:12px"><div class="tabs__item is-active">待办（5）</div><div class="tabs__item">系统通知</div></div>` +
          M.todos.map(t => `<div style="padding:11px 0;border-bottom:1px dashed #f0f2f5">
            <div style="display:flex;justify-content:space-between;gap:10px"><span style="font-size:13px;color:var(--ly-text);font-weight:500">${esc(t.title)}</span>${tag(t.type, 'primary')}</div>
            <div class="mini" style="margin-top:4px">${esc(t.meta)} · ${esc(t.status)}</div>
          </div>`).join(''),
        footer: `<button class="btn" data-close>关闭</button><button class="btn btn--primary" onclick="LY.go('/approval');LY.closeDrawer()">前往审批中心</button>`
      });
    });
    document.getElementById('lyUser').addEventListener('click', () => {
      LY.openDrawer({
        title: '个人中心', width: 420,
        body: `<div style="display:flex;gap:14px;align-items:center;padding-bottom:16px;border-bottom:1px solid var(--ly-border-light)">
            <div class="ly-avatar" style="width:52px;height:52px;font-size:20px">陈</div>
            <div><div style="font-size:16px;font-weight:600">陈立</div>
            <div class="mini">${M.user.no} · 项目经理 · 交付中心</div></div></div>
          <div class="desc-grid desc-grid--2" style="margin-top:12px">
            <div class="desc-item"><span class="desc-label">所属组织</span><span class="desc-value">交付中心 / 项目管理部</span></div>
            <div class="desc-item"><span class="desc-label">数据范围</span><span class="desc-value">本部门及下属项目</span></div>
            <div class="desc-item"><span class="desc-label">角色</span><span class="desc-value">项目经理、预算申请人</span></div>
            <div class="desc-item"><span class="desc-label">审批权限</span><span class="desc-value">工时审批、费用初审</span></div>
          </div>`,
        footer: `<button class="btn" data-close>关闭</button><button class="btn btn--danger" onclick="LY.go('/login')">退出登录</button>`
      });
    });
    renderTabs();
  }

  function ensureShell() {
    if (!document.querySelector('.ly-layout')) renderShell();
  }

  function navigate() {
    const { path, query } = parseHash();
    const base = basePath(path);
    const def = LY.pages[base];
    const content = document.getElementById('lyContent');
    if (!def) {
      const app = document.getElementById('app');
      app.innerHTML = `<div style="padding:40px;font-family:var(--ly-font)"><h2>页面未注册：${esc(path)}</h2><p class="mini" style="margin-top:8px">可用路由：${Object.keys(LY.pages).join('、')}</p></div>`;
      return;
    }
    if (def.standalone) {
      document.getElementById('app').innerHTML = '';
      def.render(document.getElementById('app'), query);
      return;
    }
    ensureShell();
    const app = document.getElementById('app');
    if (!app.querySelector('.ly-layout')) renderShell();

    activeRoute = location.hash.slice(1) || '/home';
    const title = def.titleFor ? def.titleFor(query) : def.title;
    document.title = (title || '工作台') + ' · 链宇企业数字化平台';
    addTab(activeRoute, title);
    renderNav(path);

    const crumb = document.getElementById('lyCrumb');
    if (crumb) {
      const parts = def.crumb || [NAV_MAP[base] || def.title];
      crumb.innerHTML = `${icon('home', 15)}${parts.map((p, i) => i === parts.length - 1 ? `<b>${esc(p)}</b>` : `<span>${esc(p)}</span><em>/</em>`).join('')}`;
    }

    const page = document.getElementById('page');
    if (!page) return;
    page.innerHTML = '';
    page.className = 'ly-page';
    try {
      def.render(page, query);
    } catch (err) {
      console.error(err);
      page.innerHTML = `<div class="panel"><div class="panel-body"><div class="alert alert--danger">${icon('alert', 15)}<span>页面渲染异常：${esc(err.message)}</span></div></div></div>`;
    }
    if (content) content.scrollTop = 0;
    window.scrollTo(0, 0);
  }
  LY.navigate = navigate;
  LY.rerender = navigate;

  window.addEventListener('hashchange', navigate);
  window.addEventListener('DOMContentLoaded', () => {
    if (!location.hash) location.hash = '#/home';
    navigate();
  });
  // 页面脚本先于 DOMContentLoaded 执行，兜底
  if (document.readyState !== 'loading' && !window.__lyBooted) {
    window.__lyBooted = true;
    setTimeout(() => { if (!document.querySelector('.ly-layout') && !document.querySelector('.login-page')) navigate(); }, 0);
  }
})();
