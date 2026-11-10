/* ================= 应用启动 ================= */
(function () {
  const LY = window.LY;

  // 默认路由
  if (!location.hash) location.hash = '#/home';

  // 全局异常提示（不中断原型）
  window.addEventListener('error', e => {
    console.error('[链宇门户]', e.message);
  });

  // 关键路由自检：缺失时提示，避免白屏
  window.addEventListener('load', () => {
    const required = ['/home', '/customer', '/opportunity', '/contract', '/contract/detail', '/project',
      '/project/detail', '/wbs', '/budget', '/resource', '/timesheet', '/settlement', '/invoice',
      '/receivable', '/cost', '/profit', '/analysis', '/approval', '/integration', '/login'];
    const missing = required.filter(r => !LY.pages[r]);
    if (missing.length) console.warn('未注册路由：', missing);
    if (!document.querySelector('.ly-layout') && !document.querySelector('.login-page')) {
      if (LY.navigate) LY.navigate();
    }
    console.log('%c链宇企业数字化平台 · 经营一体门户', 'color:#1d4ed8;font-weight:600;font-size:13px');
  });
})();
