// Hekatan LISP web — idioma español / inglés (Jorge, 22-nov-2026): UN botón «🌐 Idioma» con opciones:
//   · Todo en English / Todo en español (interfaz + hoja)   · Solo la barra de menús   · Solo la hoja (el ejemplo en el otro idioma)
//   · Traducir la selección con clic derecho: diccionario de la interfaz → la línea gemela de la hoja en el otro idioma
//     (las hojas ES/EN están alineadas línea a línea) → si no, el traductor (Google) con ese texto en una pestaña nueva.
//   Se guarda por separado (hk-idioma-ui, hk-idioma-hoja); ?lang=en|es en el enlace fija los dos.
(function (G) {
  const CFG = { global: 'HKI18N', hoja: '#render, #texto, #code, #hl, #gutter', editor: '#code, #hl, #gutter', menu: '#menu', dirEs: 'ejemplos/', dirEn: 'ejemplos/en/', listaEs: 'ejemplos.json', dic: 'i18n_en.json',
    actual: () => { const s = document.getElementById('sel-ejemplos'); const m = /^(\d+) /.exec(String(s && s.value || '')); return m ? m[1] : null; }, enlace: (n) => '#ej=' + n + '&solo=1' };
  const HK = G[CFG.global] = G[CFG.global] || {};
  const lee = (k, d) => { try { return localStorage.getItem(k) || d; } catch (e) { return d; } };
  const pon = (k, v) => { try { localStorage.setItem(k, v); } catch (e) { /* nada */ } };
  const nav = (navigator.language || 'es').toLowerCase().startsWith('es') ? 'es' : 'en';
  const viejo = lee('hk-idioma', null);          // versión anterior: un solo idioma para todo
  let UI = lee('hk-idioma-ui', viejo || nav), HO = lee('hk-idioma-hoja', viejo || nav), CLIC = lee('hk-traducir-clic', '1') === '1';
  { const q = /[?&#]lang=(es|en)(?![a-z])/.exec(location.search + location.hash); if (q) { UI = HO = q[1]; pon('hk-idioma-ui', UI); pon('hk-idioma-hoja', HO); } }
  HK.idioma = HO; HK.idiomaUI = UI;
  HK.dirHlisp = () => (HO === 'en' ? CFG.dirEn : CFG.dirEs);
  HK.dirEj = HK.dirHlisp;
  const ES = UI !== 'en';
  const PAT = [
    [/^Abierto: /, 'Opened: '], [/^Abriendo /, 'Opening '], [/^listo en /, 'done in '], [/^calculando… ?/, 'computing… '],
    [/^motor simbólico: listo/, 'symbolic engine: ready'], [/^motor simbólico: cargando…/, 'symbolic engine: loading…'], [/^motor simbólico: /, 'symbolic engine: '],
    [/^No existe el ejemplo /, 'There is no example '], [/^No hay ejemplo /, 'There is no example '], [/^No se pudo abrir /, 'Could not open '],
    [/^Guardado: /, 'Saved: '], [/^Región: /, 'Region: '], [/^Zoom /, 'Zoom '], [/ \(la página debe servirse por http\)$/, ' (the page must be served over http)'],
    [/^⚠ cálculo pesado: pasa de /, '⚠ heavy computation: more than '], [/ millón\(es\) de pasos/, ' million steps'], [/Puede tardar y congelar la pestaña unos segundos\./, 'It may take a while and freeze the tab for a few seconds.'],
    [/^\(ninguno todavía\)$/, '(none yet)'], [/^Hekatan LISP \(\.lisp\) · no se pudo leer la lista$/, 'Hekatan LISP (.lisp) · could not read the list'], [/^Hekatan LISP \(\.lisp\) · cargando…$/, 'Hekatan LISP (.lisp) · loading…'],
    [/^Bloque Hekatan LISP$/, 'Hekatan LISP block'], [/se dibuja con el motor de Hekatan LISP \(WPF o Hekatan LISP web\); aquí se conserva y se guarda igual/, 'drawn with the Hekatan LISP engine (desktop or Hekatan LISP web); here it is kept and saved as is'],
  ];
  // frases que pone el MOTOR en los resultados: siguen el idioma de la HOJA
  const RES = [
    [/^Esc\. 1:/, 'Scale 1:'], [/ · geometría en m/, ' · geometry in m'], [/ · cotas en m/, ' · dimensions in m'], [/ · cotas en cm/, ' · dimensions in cm'], [/ · cotas en mm/, ' · dimensions in mm'],
    [/^mapa de\s+/, 'map of  '], [/\s+\(planta\)\s*$/, '  (plan)'],
    [/arrastra para girar, rueda para acercar, cursor para leer/, 'drag to rotate, wheel to zoom, hover to read'], [/arrastra para girar/, 'drag to rotate'],
    [/^losa: /, 'slab: '], [/ · barras: /, ' · bars: '], [/^malla del modelo: nudos, elementos y apoyos$/, 'model mesh: nodes, elements and supports'],
    [/^sólido de hexaedros \(se gira con el ratón\)$/, 'hexahedral solid (rotate with the mouse)'],
    [/^Gráfica$/, 'Chart'], [/^de Hekatan LISP · con los valores de la hoja$/, 'from Hekatan LISP · with the values of the sheet'], [/^‹› código$/, '‹› code'],
    [/^Dibujo$/, 'Drawing'], [/^#dibujo de Hekatan LISP · con los valores de la hoja$/, 'Hekatan LISP #drawing · with the values of the sheet'],
  ];
  let D = null;
  const fuera = (el) => !(el && el.closest && el.closest(CFG.hoja));
  const editor = (el) => !!(el && el.closest && el.closest(CFG.editor));
  function traduce(t) {
    if (!D || !t) return null; const k = t.trim(); if (!k) return null;
    if (Object.prototype.hasOwnProperty.call(D, k)) return t.replace(k, D[k]);
    let r = k, c = false; for (const [re, en] of PAT) if (re.test(r)) { r = r.replace(re, en); c = true; }
    return c ? t.replace(k, r) : null;
  }
  function traduceRes(t) { if (!t) return null; let r = t, c = false; for (const [re, en] of RES) if (re.test(r)) { r = r.replace(re, en); c = true; } return c ? r : null; }
  function texto(n) {
    const p = n.parentElement; if (!p || editor(p) || p.closest('#hk-idioma-menu, #hk-trad')) return;
    const r = fuera(p) ? (UI === 'en' ? traduce(n.nodeValue) : null) : (HO === 'en' ? traduceRes(n.nodeValue) : null);
    if (r !== null && r !== n.nodeValue) n.nodeValue = r;
  }
  function atributos(x) { if (UI !== 'en' || !fuera(x) || x.closest('#hk-idioma-menu, #hk-trad')) return; for (const a of ['title', 'placeholder', 'aria-label']) { const v = x.getAttribute(a); if (v) { const r = traduce(v); if (r !== null && r !== v) x.setAttribute(a, r); } } }
  function nodo(n) {
    if (n.nodeType === 3) { texto(n); return; }
    if (n.nodeType !== 1 || n.tagName === 'SCRIPT' || n.tagName === 'STYLE') return;
    atributos(n); const w = document.createTreeWalker(n, NodeFilter.SHOW_TEXT | NodeFilter.SHOW_ELEMENT); let x;
    while ((x = w.nextNode())) { if (x.nodeType === 3) texto(x); else atributos(x); }
  }
  // ---------------------------------------------------------------- botón «🌐 Idioma» con sus opciones
  const T = (es, en) => (ES ? es : en);
  function recarga() { const n = CFG.actual(); if (n) location.hash = CFG.enlace(n); location.reload(); }
  function boton() {
    const m = document.querySelector(CFG.menu); if (!m || document.getElementById('hk-idioma')) return;
    const b = document.createElement('button'); b.id = 'hk-idioma'; b.type = 'button';
    b.textContent = '🌐 ' + T('Idioma', 'Language') + ' (' + UI.toUpperCase() + (HO !== UI ? '/' + HO.toUpperCase() : '') + ') ▾';
    b.title = T('Idioma de la interfaz y de la hoja, y traductor con clic derecho', 'Language of the interface and of the sheet, and right-click translator');
    b.style.cssText = 'margin:0 0 0 14px;padding:2px 10px;font-weight:700;border:1px solid #b08a2e;border-radius:12px;background:#fff6dc;color:#5a4410;cursor:pointer;flex:none;display:inline-block;vertical-align:middle;position:relative';
    const mn = document.createElement('div'); mn.id = 'hk-idioma-menu';
    mn.style.cssText = 'position:fixed;z-index:10000;display:none;background:#fffdf6;border:1px solid #b08a2e;border-radius:8px;box-shadow:0 4px 14px #0003;padding:6px 0;font:13px Segoe UI,sans-serif;color:#222;min-width:290px';
    const op = (txt, fn, marca) => { const d = document.createElement('div'); d.textContent = (marca === undefined ? '   ' : marca ? '✓ ' : '   ') + txt; d.style.cssText = 'padding:5px 14px;cursor:pointer;white-space:pre'; d.onmouseenter = () => { d.style.background = '#f3e5b8'; }; d.onmouseleave = () => { d.style.background = ''; }; d.onclick = (e) => { e.stopPropagation(); mn.style.display = 'none'; fn(); }; mn.appendChild(d); };
    const sep = () => { const h = document.createElement('div'); h.style.cssText = 'border-top:1px solid #e6d7a8;margin:4px 0'; mn.appendChild(h); };
    op(T('Todo en English (interfaz y hoja)', 'Everything in English (interface and sheet)'), () => { pon('hk-idioma-ui', 'en'); pon('hk-idioma-hoja', 'en'); recarga(); }, UI === 'en' && HO === 'en');
    op(T('Todo en español (interfaz y hoja)', 'Everything in Spanish (interface and sheet)'), () => { pon('hk-idioma-ui', 'es'); pon('hk-idioma-hoja', 'es'); recarga(); }, UI === 'es' && HO === 'es');
    sep();
    op(T('Solo la barra de menús: ', 'Menus only: ') + (UI === 'en' ? T('pasar a español', 'switch to Spanish') : T('pasar a English', 'switch to English')), () => { pon('hk-idioma-ui', UI === 'en' ? 'es' : 'en'); recarga(); });
    op(T('Solo la hoja: ', 'Sheet only: ') + (HO === 'en' ? T('pasar a español', 'switch to Spanish') : T('pasar a English', 'switch to English')), () => { pon('hk-idioma-hoja', HO === 'en' ? 'es' : 'en'); recarga(); });
    sep();
    op(T('Traducir la selección con clic derecho', 'Translate the selection with right click'), () => { CLIC = !CLIC; pon('hk-traducir-clic', CLIC ? '1' : '0'); }, CLIC);
    document.body.appendChild(mn);
    b.addEventListener('click', (e) => { e.stopPropagation(); const r = b.getBoundingClientRect(); mn.style.left = Math.min(r.left, innerWidth - 310) + 'px'; mn.style.top = (r.bottom + 4) + 'px'; mn.style.display = mn.style.display === 'none' ? 'block' : 'none'; });
    document.addEventListener('click', () => { mn.style.display = 'none'; });
    m.appendChild(b);
  }
  // ---------------------------------------------------------------- traducir la selección con clic derecho
  const lineas = {};
  async function hojaTexto(lang) {
    const n = CFG.actual(); if (!n) return null; const k = lang + ':' + n; if (lineas[k] !== undefined) return lineas[k];
    try {
      const dir = lang === 'en' ? CFG.dirEn : CFG.dirEs; const l = await (await fetch(dir + 'lista.json', { cache: 'no-cache' }).then((r) => (r.ok ? r : fetch(CFG.listaEs, { cache: 'no-cache' })))).json();
      const f = l.find((x) => x.startsWith(n + ' ')); if (!f) return (lineas[k] = null);
      return (lineas[k] = (await (await fetch(dir + encodeURIComponent(f))).text()).replace(/\r/g, '').split('\n'));
    } catch (e) { return (lineas[k] = null); }
  }
  const limpia = (s) => String(s).replace(/^\s*(#:|##+|#)\s*/, '').replace(/\*\*/g, '').replace(/\s+/g, ' ').trim();
  async function busca(sel) {
    const s = sel.replace(/\s+/g, ' ').trim(); if (!s) return null;
    if (D) { if (D[s]) return D[s]; for (const k in D) if (D[k] === s) return k; }          // interfaz: es→en o en→es
    const a = await hojaTexto(HO), b = await hojaTexto(HO === 'en' ? 'es' : 'en');          // la hoja y su gemela (alineadas línea a línea)
    if (a && b && a.length === b.length) {
      const cab = s.slice(0, 60).toLowerCase();
      for (let i = 0; i < a.length; i++) { const la = limpia(a[i]).toLowerCase(); if (la && (la.includes(cab) || (cab.length > 12 && cab.includes(la.slice(0, 40))))) return limpia(b[i]); }
    }
    return null;
  }
  function ventana(orig, trad) {
    let v = document.getElementById('hk-trad'); if (!v) { v = document.createElement('div'); v.id = 'hk-trad'; document.body.appendChild(v); }
    v.style.cssText = 'position:fixed;z-index:10001;right:18px;bottom:40px;max-width:560px;background:#fffdf6;border:1px solid #b08a2e;border-radius:10px;box-shadow:0 6px 20px #0004;padding:10px 14px;font:14px Segoe UI,sans-serif;color:#222';
    const esc = (t) => String(t).replace(/&/g, '&amp;').replace(/</g, '&lt;');
    v.innerHTML = '<div style="font-size:12px;color:#8a6d1f;font-weight:700;margin-bottom:4px">🌐 ' + T('Traducción', 'Translation') + '</div><div style="white-space:pre-wrap">' + esc(trad) + '</div><div style="margin-top:8px;text-align:right"><button type="button" data-a="c">' + T('Copiar', 'Copy') + '</button> <button type="button" data-a="x">' + T('Cerrar', 'Close') + '</button></div>';
    v.querySelector('[data-a=c]').onclick = () => { try { navigator.clipboard.writeText(trad); } catch (e) { /* nada */ } };
    v.querySelector('[data-a=x]').onclick = () => { v.remove(); };
  }
  function menuClic(e) {
    if (!CLIC) return; const sel = String(getSelection ? getSelection() : '').trim(); if (!sel) return;
    if (e.target && e.target.closest && e.target.closest('textarea, input')) return;
    e.preventDefault(); let m = document.getElementById('hk-trad-menu');
    if (!m) { m = document.createElement('div'); m.id = 'hk-trad-menu'; document.body.appendChild(m); }
    m.style.cssText = 'position:fixed;z-index:10002;left:' + e.clientX + 'px;top:' + e.clientY + 'px;background:#fffdf6;border:1px solid #b08a2e;border-radius:8px;box-shadow:0 4px 14px #0003;padding:6px 0;font:13px Segoe UI,sans-serif';
    const dest = HO === 'en' ? 'es' : 'en';
    m.innerHTML = '<div data-a="t" style="padding:5px 14px;cursor:pointer">🌐 ' + T('Traducir', 'Translate') + ' → ' + (dest === 'en' ? 'English' : 'español') + '</div><div data-a="g" style="padding:5px 14px;cursor:pointer">🔎 ' + T('Traducir con Google', 'Translate with Google') + '</div>';
    m.querySelectorAll('div').forEach((d) => { d.onmouseenter = () => { d.style.background = '#f3e5b8'; }; d.onmouseleave = () => { d.style.background = ''; }; });
    const google = () => open('https://translate.google.com/?sl=auto&tl=' + dest + '&text=' + encodeURIComponent(sel) + '&op=translate', '_blank', 'noopener');
    m.querySelector('[data-a=t]').onclick = async () => { m.remove(); const r = await busca(sel); if (r) ventana(sel, r); else google(); };
    m.querySelector('[data-a=g]').onclick = () => { m.remove(); google(); };
    setTimeout(() => document.addEventListener('click', function f() { if (m.isConnected) m.remove(); document.removeEventListener('click', f); }), 0);
  }
  function arranca() {
    document.documentElement.lang = HO; boton(); document.addEventListener('contextmenu', menuClic, true);
    const obs = () => new MutationObserver((ms) => { for (const m of ms) { if (m.type === 'childList') m.addedNodes.forEach(nodo); else if (m.type === 'characterData') texto(m.target); else if (m.type === 'attributes') atributos(m.target); } })
      .observe(document.body, { childList: true, subtree: true, characterData: true, attributes: true, attributeFilter: ['title', 'placeholder', 'aria-label'] });
    fetch(CFG.dic).then((r) => r.json()).then((d) => { D = d; if (UI === 'en' || HO === 'en') { nodo(document.body); obs(); } }).catch(() => { if (HO === 'en') { nodo(document.body); obs(); } });
  }
  if (document.readyState === 'loading') document.addEventListener('DOMContentLoaded', arranca); else arranca();
})(window);
