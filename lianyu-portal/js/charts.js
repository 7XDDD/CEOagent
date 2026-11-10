/* ================= SVG 图表（无外部依赖） ================= */
(function () {
  const LY = window.LY;
  const PALETTE = ['#1d4ed8', '#3b82f6', '#67c23a', '#e6a23c', '#f56c6c', '#909399'];
  const NS = 'http://www.w3.org/2000/svg';

  function tipEl() {
    let el = document.querySelector('.chart-tip');
    if (!el) { el = document.createElement('div'); el.className = 'chart-tip'; document.body.appendChild(el); }
    return el;
  }
  function bindTip(node, html) {
    node.addEventListener('mousemove', e => {
      const t = tipEl(); t.innerHTML = html; t.style.display = 'block';
      t.style.left = (e.clientX + 12) + 'px'; t.style.top = (e.clientY - 10) + 'px';
    });
    node.addEventListener('mouseleave', () => { tipEl().style.display = 'none'; });
  }
  const esc = s => String(s == null ? '' : s).replace(/[&<>"]/g, c => ({ '&': '&amp;', '<': '&lt;', '>': '&gt;', '"': '&quot;' }[c]));
  const fmtNum = n => {
    if (Math.abs(n) >= 10000) return (n / 10000).toFixed(n % 10000 === 0 ? 0 : 1) + '万';
    return Number(n).toLocaleString('zh-CN');
  };
  function niceMax(max) {
    if (max <= 0) return 10;
    const p = Math.pow(10, Math.floor(Math.log10(max)));
    const n = max / p;
    const step = n <= 1 ? 1 : n <= 2 ? 2 : n <= 5 ? 5 : 10;
    return step * p;
  }
  function el(tag, attrs) {
    const n = document.createElementNS(NS, tag);
    for (const k in attrs) n.setAttribute(k, attrs[k]);
    return n;
  }
  function legend(names, colors) {
    return `<div class="chart-legend" style="margin-top:8px">${names.map((n, i) =>
      `<span class="item"><i class="legend-dot" style="background:${colors[i]}"></i>${esc(n)}</span>`).join('')}</div>`;
  }

  function base(elWrap, height) {
    const w = Math.max(elWrap.clientWidth || 640, 280);
    const h = height || 240;
    elWrap.classList.add('chart');
    elWrap.innerHTML = '';
    const svg = el('svg', { viewBox: `0 0 ${w} ${h}`, width: '100%', height: h, preserveAspectRatio: 'none' });
    svg.style.height = h + 'px';
    elWrap.appendChild(svg);
    return { svg, w, h };
  }

  const chart = {
    bar(wrap, opt) {
      const { categories = [], series = [], stacked = false, horizontal = false, height = 240, legend: showLegend = true, fmt = fmtNum } = opt || {};
      if (!wrap) return;
      const { svg, w, h } = base(wrap, height);
      const colors = series.map((s, i) => s.color || PALETTE[i % PALETTE.length]);
      const padL = horizontal ? 86 : 48, padR = 12, padT = 12, padB = horizontal ? 26 : 30;
      const cw = w - padL - padR, ch = h - padT - padB;

      let maxV = 0;
      if (stacked) categories.forEach((_, ci) => {
        const t = series.reduce((a, s) => a + (s.data[ci] || 0), 0); maxV = Math.max(maxV, t);
      }); else series.forEach(s => s.data.forEach(v => maxV = Math.max(maxV, v || 0)));
      const max = niceMax(maxV);

      // grid + y labels
      for (let i = 0; i <= 4; i++) {
        const y = padT + ch - (ch * i / 4);
        svg.appendChild(el('line', { x1: padL, y1: y, x2: w - padR, y2: y, class: 'chart-grid-line' }));
        const tx = el('text', { x: horizontal ? w - padR : padL - 8, y: y + 4, 'text-anchor': horizontal ? 'end' : 'end', class: 'chart-axis-label' });
        tx.textContent = horizontal ? '' : fmt(max * i / 4);
        if (!horizontal) svg.appendChild(tx);
      }

      const groupW = cw / Math.max(categories.length, 1);
      categories.forEach((cat, ci) => {
        const x0 = padL + groupW * ci;
        if (horizontal) {
          const rowH = ch / Math.max(categories.length, 1);
          const barH = Math.min(18, rowH / (series.length + 1));
          const y0 = padT + rowH * ci + (rowH - barH * series.length - 3 * (series.length - 1)) / 2;
          series.forEach((s, si) => {
            const v = s.data[ci] || 0;
            const bw = Math.max(2, cw * v / max);
            const r = el('rect', { x: padL, y: y0 + si * (barH + 3), width: bw, height: barH, rx: 2, fill: colors[si], class: 'chart-bar' });
            bindTip(r, `${esc(cat)}<br>${esc(s.name)}：${fmt(v)}`);
            svg.appendChild(r);
            const t = el('text', { x: padL - 10, y: padT + rowH * ci + rowH / 2 + 4, 'text-anchor': 'end', class: 'chart-axis-label' });
            t.textContent = cat;
            if (si === 0) svg.appendChild(t);
          });
        } else if (stacked) {
          let acc = 0;
          const barW = Math.min(34, groupW * 0.46);
          series.forEach((s, si) => {
            const v = s.data[ci] || 0;
            const bh = ch * v / max;
            const y = padT + ch - ch * (acc + v) / max;
            acc += v;
            if (v > 0) {
              const r = el('rect', { x: x0 + (groupW - barW) / 2, y, width: barW, height: Math.max(bh, 1), fill: colors[si], class: 'chart-bar' });
              bindTip(r, `${esc(cat)}<br>${esc(s.name)}：${fmt(v)}`);
              svg.appendChild(r);
            }
          });
        } else {
          const n = series.length;
          const gap = 4;
          const barW = Math.min(26, (groupW * 0.62 - gap * (n - 1)) / n);
          const totalW = barW * n + gap * (n - 1);
          series.forEach((s, si) => {
            const v = s.data[ci] || 0;
            const bh = Math.max(ch * v / max, v > 0 ? 1 : 0);
            const x = x0 + (groupW - totalW) / 2 + si * (barW + gap);
            const r = el('rect', { x, y: padT + ch - bh, width: barW, height: bh, rx: 2, fill: colors[si], class: 'chart-bar' });
            bindTip(r, `${esc(cat)}<br>${esc(s.name)}：${fmt(v)}`);
            svg.appendChild(r);
          });
        }
        if (!horizontal) {
          const t = el('text', { x: x0 + groupW / 2, y: h - 10, 'text-anchor': 'middle', class: 'chart-axis-label' });
          t.textContent = cat;
          svg.appendChild(t);
        }
      });
      // axis line
      svg.appendChild(el('line', { x1: padL, y1: padT + ch, x2: w - padR, y2: padT + ch, stroke: '#e4e7ed' }));
      if (showLegend && series.length) wrap.insertAdjacentHTML('beforeend', legend(series.map(s => s.name), colors));
    },

    hbar(wrap, opt) {
      const { data = [], height, fmt = fmtNum, color = '#1d4ed8', labelWidth = 96 } = opt || {};
      if (!wrap) return;
      const h = height || Math.max(120, data.length * 34 + 20);
      const { svg, w } = base(wrap, h);
      const padL = labelWidth, padR = 56;
      const rows = data.length || 1;
      const rowH = (h - 16) / rows;
      const max = niceMax(Math.max(...data.map(d => d.value), 1));
      data.forEach((d, i) => {
        const y = 8 + rowH * i + rowH / 2;
        const bw = (w - padL - padR) * d.value / max;
        const lbl = el('text', { x: padL - 10, y: y + 4, 'text-anchor': 'end', class: 'chart-axis-label' });
        lbl.textContent = d.name; svg.appendChild(lbl);
        svg.appendChild(el('rect', { x: padL, y: y - 8, width: Math.max(w - padL - padR, 1), height: 16, rx: 3, fill: '#f5f7fa' }));
        const r = el('rect', { x: padL, y: y - 8, width: Math.max(bw, 2), height: 16, rx: 3, fill: d.color || color, class: 'chart-bar' });
        bindTip(r, `${esc(d.name)}：${fmt(d.value)}`);
        svg.appendChild(r);
        const v = el('text', { x: padL + bw + 8, y: y + 4, class: 'chart-axis-label', fill: '#606266' });
        v.textContent = fmt(d.value); svg.appendChild(v);
      });
    },

    line(wrap, opt) {
      const { categories = [], series = [], height = 240, area = false, legend: showLegend = true, fmt = fmtNum } = opt || {};
      if (!wrap) return;
      const { svg, w, h } = base(wrap, height);
      const colors = series.map((s, i) => s.color || PALETTE[i % PALETTE.length]);
      const padL = 52, padR = 14, padT = 14, padB = 28;
      const cw = w - padL - padR, ch = h - padT - padB;
      let maxV = 0;
      series.forEach(s => s.data.forEach(v => maxV = Math.max(maxV, v || 0)));
      const max = niceMax(maxV);
      for (let i = 0; i <= 4; i++) {
        const y = padT + ch - ch * i / 4;
        svg.appendChild(el('line', { x1: padL, y1: y, x2: w - padR, y2: y, class: 'chart-grid-line' }));
        const t = el('text', { x: padL - 8, y: y + 4, 'text-anchor': 'end', class: 'chart-axis-label' });
        t.textContent = fmt(max * i / 4); svg.appendChild(t);
      }
      const stepX = cw / Math.max(categories.length - 1, 1);
      series.forEach((s, si) => {
        const pts = s.data.map((v, i) => [padL + stepX * i, padT + ch - ch * (v || 0) / max]);
        if (area) {
          const gid = 'grad' + Math.random().toString(36).slice(2, 8);
          const defs = el('defs', {});
          const g = el('linearGradient', { id: gid, x1: '0', y1: '0', x2: '0', y2: '1' });
          g.appendChild(el('stop', { offset: '0%', 'stop-color': colors[si], 'stop-opacity': '0.22' }));
          g.appendChild(el('stop', { offset: '100%', 'stop-color': colors[si], 'stop-opacity': '0.01' }));
          defs.appendChild(g); svg.appendChild(defs);
          const d = `M${pts.map(p => p.join(',')).join(' L')} L${pts[pts.length - 1][0]},${padT + ch} L${pts[0][0]},${padT + ch} Z`;
          svg.appendChild(el('path', { d, fill: `url(#${gid})`, stroke: 'none' }));
        }
        const d = 'M' + pts.map(p => p.join(',')).join(' L');
        svg.appendChild(el('path', { d, fill: 'none', stroke: colors[si], 'stroke-width': 2, 'stroke-linejoin': 'round', 'stroke-linecap': 'round' }));
        pts.forEach(([x, y], i) => {
          const c = el('circle', { cx: x, cy: y, r: 3.2, fill: '#fff', stroke: colors[si], 'stroke-width': 2, class: 'chart-bar' });
          bindTip(c, `${esc(categories[i])}<br>${esc(s.name)}：${fmt(s.data[i])}`);
          svg.appendChild(c);
        });
      });
      categories.forEach((cat, i) => {
        const t = el('text', { x: padL + stepX * i, y: h - 8, 'text-anchor': 'middle', class: 'chart-axis-label' });
        t.textContent = cat; svg.appendChild(t);
      });
      svg.appendChild(el('line', { x1: padL, y1: padT + ch, x2: w - padR, y2: padT + ch, stroke: '#e4e7ed' }));
      if (showLegend && series.length) wrap.insertAdjacentHTML('beforeend', legend(series.map(s => s.name), colors));
    },

    donut(wrap, opt) {
      const { data = [], centerLabel = '', centerValue = '', height = 200, thickness = 22, legend: showLegend = true } = opt || {};
      if (!wrap) return;
      const size = height;
      const w = Math.max(wrap.clientWidth || 320, 200);
      wrap.classList.add('chart'); wrap.innerHTML = '';
      const svg = el('svg', { viewBox: `0 0 ${w} ${size}`, width: '100%', height: size });
      svg.style.height = size + 'px';
      wrap.appendChild(svg);
      const cx = w / 2, cy = size / 2, r = Math.min(size, w) / 2 - 12;
      const total = data.reduce((a, b) => a + b.value, 0) || 1;
      let angle = -Math.PI / 2;
      data.forEach((d, i) => {
        const a = d.value / total * Math.PI * 2;
        const x1 = cx + r * Math.cos(angle), y1 = cy + r * Math.sin(angle);
        const x2 = cx + r * Math.cos(angle + a), y2 = cy + r * Math.sin(angle + a);
        const large = a > Math.PI ? 1 : 0;
        const path = el('path', {
          d: `M${x1},${y1} A${r},${r} 0 ${large} 1 ${x2},${y2}`,
          fill: 'none', stroke: d.color || PALETTE[i % PALETTE.length], 'stroke-width': thickness,
          'stroke-linecap': 'butt', class: 'chart-bar'
        });
        bindTip(path, `${esc(d.name)}：${fmtNum(d.value)}（${(d.value / total * 100).toFixed(1)}%）`);
        svg.appendChild(path);
        angle += a;
      });
      if (centerValue) {
        const v = el('text', { x: cx, y: cy + 2, 'text-anchor': 'middle', fill: '#303133', 'font-size': 20, 'font-weight': 600 });
        v.textContent = centerValue; svg.appendChild(v);
      }
      if (centerLabel) {
        const l = el('text', { x: cx, y: cy + 20, 'text-anchor': 'middle', fill: '#909399', 'font-size': 11 });
        l.textContent = centerLabel; svg.appendChild(l);
      }
      if (showLegend) {
        wrap.insertAdjacentHTML('beforeend',
          `<div class="chart-legend" style="justify-content:center;margin-top:4px">${data.map((d, i) =>
            `<span class="item"><i class="legend-dot" style="background:${d.color || PALETTE[i % PALETTE.length]}"></i>${esc(d.name)}</span>`).join('')}</div>`);
      }
    },

    ring(wrap, opt) {
      const { value = 0, label = '', color = '#1d4ed8', size = 88, thickness = 8 } = opt || {};
      if (!wrap) return;
      wrap.innerHTML = '';
      const svg = el('svg', { viewBox: `0 0 ${size} ${size}`, width: size, height: size });
      const r = size / 2 - thickness / 2 - 1, cx = size / 2, cy = size / 2;
      const c = 2 * Math.PI * r;
      svg.appendChild(el('circle', { cx, cy, r, fill: 'none', stroke: '#ebeef5', 'stroke-width': thickness }));
      svg.appendChild(el('circle', {
        cx, cy, r, fill: 'none', stroke: color, 'stroke-width': thickness,
        'stroke-dasharray': `${c * value} ${c}`, 'stroke-linecap': 'round',
        transform: `rotate(-90 ${cx} ${cy})`
      }));
      const t = el('text', { x: cx, y: cy + 1, 'text-anchor': 'middle', fill: '#303133', 'font-size': 17, 'font-weight': 600 });
      t.textContent = Math.round(value * 100) + '%'; svg.appendChild(t);
      if (label) {
        const l = el('text', { x: cx, y: cy + 16, 'text-anchor': 'middle', fill: '#909399', 'font-size': 10 });
        l.textContent = label; svg.appendChild(l);
      }
      wrap.appendChild(svg);
    }
  };

  LY.chart = chart;
  LY.PALETTE = PALETTE;

  // 自适应重绘
  const registry = new Set();
  const ro = new ResizeObserver(entries => {
    entries.forEach(e => {
      const rec = e.target.__lyChart;
      if (!rec) return;
      clearTimeout(rec.t);
      rec.t = setTimeout(() => {
        const w = rec.wrap.clientWidth;
        if (rec.lastW && Math.abs(rec.lastW - w) < 8) return;
        rec.lastW = w;
        if (rec.type === 'bar') chart.bar(rec.wrap, rec.opt);
        if (rec.type === 'line') chart.line(rec.wrap, rec.opt);
        if (rec.type === 'donut') chart.donut(rec.wrap, rec.opt);
      }, 180);
    });
  });
  LY.watchChart = function (wrap, type, opt) {
    if (!wrap) return;
    wrap.__lyChart = { wrap, type, opt, lastW: wrap.clientWidth };
    ro.observe(wrap);
  };
})();
