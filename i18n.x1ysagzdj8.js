// Hekatan LISP web — idioma español / inglés (mismo esquema que Math Studio web, i18n.js) (Jorge, 22-nov-2026: «en inglés cambia toda la GUI a inglés y los ejemplos igual»).
//   · el idioma se guarda (localStorage «hk-idioma»); sin elegir, el del navegador (es-* → español, lo demás → inglés)
//   · en inglés: todos los textos y avisos (title/placeholder) FUERA de la hoja se traducen con i18n_en.json, también los que aparecen después
//     (menús, cintas, mensajes de estado) con un MutationObserver; los mensajes con partes variables van por patrones (PAT)
//   · los ejemplos de Hekatan LISP salen de ejemplos/hlisp/en/ (las hojas traducidas: misma hoja, prosa en inglés, código idéntico)
//   · botón EN/ES en la barra de menús: recarga en el otro idioma con el MISMO ejemplo abierto (por su número)
(function (G) {
  const HK = G.HKI18N = G.HKI18N || {};
  let L = 'es';
  try { L = localStorage.getItem('hk-idioma') || ((navigator.language || 'es').toLowerCase().startsWith('es') ? 'es' : 'en'); } catch (e) { /* sin almacenamiento: español */ }
  { const q = /[?&]lang=(es|en)/.exec(location.search) || /[#&]lang=(es|en)/.exec(location.hash); if (q) { L = q[1]; try { localStorage.setItem('hk-idioma', L); } catch (e) { /* nada */ } } }          // enlace con ?lang=en / ?lang=es: abre en ese idioma
  HK.idioma = L;
  HK.dirEj = () => (L === 'en' ? 'ejemplos/en/' : 'ejemplos/');
  const PAT = [
    [/^Abierto: /, 'Opened: '], [/^Abriendo /, 'Opening '], [/^listo en /, 'done in '], [/^calculando… ?/, 'computing… '],
    [/^motor simbólico: listo/, 'symbolic engine: ready'], [/^motor simbólico: cargando…/, 'symbolic engine: loading…'], [/^motor simbólico: /, 'symbolic engine: '],
    [/^No existe el ejemplo /, 'There is no example '], [/^No hay ejemplo /, 'There is no example '], [/^No se pudo abrir /, 'Could not open '],
    [/^Guardado: /, 'Saved: '], [/^Región: /, 'Region: '], [/^Zoom /, 'Zoom '], [/ \(la página debe servirse por http\)$/, ' (the page must be served over http)'],
    [/^⚠ cálculo pesado: pasa de /, '⚠ heavy computation: more than '], [/ millón\(es\) de pasos/, ' million steps'], [/Puede tardar y congelar la pestaña unos segundos\./, 'It may take a while and freeze the tab for a few seconds.'],
    [/^\(ninguno todavía\)$/, '(none yet)'], [/^Hekatan LISP \(\.lisp\) · no se pudo leer la lista$/, 'Hekatan LISP (.lisp) · could not read the list'], [/^Hekatan LISP \(\.lisp\) · cargando…$/, 'Hekatan LISP (.lisp) · loading…'],
    [/^Gráfica$/, 'Chart'], [/de Hekatan LISP · con los valores de la hoja/, 'from Hekatan LISP · with the values of the sheet'], [/^‹› código$/, '‹› code'],
    [/^Dibujo$/, 'Drawing'], [/#dibujo de Hekatan LISP · con los valores de la hoja/, 'Hekatan LISP #drawing · with the values of the sheet'],
    [/^Bloque Hekatan LISP$/, 'Hekatan LISP block'], [/se dibuja con el motor de Hekatan LISP \(WPF o Hekatan LISP web\); aquí se conserva y se guarda igual/, 'drawn with the Hekatan LISP engine (desktop or Hekatan LISP web); here it is kept and saved as is'],
  ];
  let D = null;
  const fuera = (el) => !(el && el.closest && el.closest('#render, #texto, #code, #hl, #gutter'));          // el resultado y el editor no se tocan
  function traduce(t) {
    if (!D || !t) return null; const k = t.trim(); if (!k) return null;
    if (Object.prototype.hasOwnProperty.call(D, k)) return t.replace(k, D[k]);
    let r = k, cambio = false; for (const [re, en] of PAT) { if (re.test(r)) { r = r.replace(re, en); cambio = true; } }
    return cambio ? t.replace(k, r) : null;
  }
  function nodo(n) {
    if (n.nodeType === 3) { if (fuera(n.parentElement)) { const r = traduce(n.nodeValue); if (r !== null && r !== n.nodeValue) n.nodeValue = r; } return; }
    if (n.nodeType !== 1 || !fuera(n) || n.tagName === 'SCRIPT' || n.tagName === 'STYLE') return;
    for (const a of ['title', 'placeholder', 'aria-label']) { const v = n.getAttribute(a); if (v) { const r = traduce(v); if (r !== null && r !== v) n.setAttribute(a, r); } }
    if (n.tagName === 'OPTION' || n.tagName === 'BUTTON' || n.childNodes.length) { const w = document.createTreeWalker(n, NodeFilter.SHOW_TEXT | NodeFilter.SHOW_ELEMENT); let x = w.currentNode; while ((x = w.nextNode())) { if (x.nodeType === 3) nodo(x); else if (x.closest && !fuera(x)) continue; else for (const a of ['title', 'placeholder', 'aria-label']) { const v = x.getAttribute(a); if (v) { const r = traduce(v); if (r !== null && r !== v) x.setAttribute(a, r); } } } }
  }
  function boton() {
    const m = document.getElementById('menu'); if (!m || document.getElementById('hk-idioma')) return;
    const b = document.createElement('button'); b.id = 'hk-idioma'; b.type = 'button'; b.className = '';
    b.textContent = L === 'en' ? '🌐 ES' : '🌐 EN'; b.title = L === 'en' ? 'Cambiar a español (interfaz y ejemplos)' : 'Switch to English (interface and examples)';
    b.style.cssText = 'margin-left:auto;font-weight:600';
    b.addEventListener('click', () => {
      try { localStorage.setItem('hk-idioma', L === 'en' ? 'es' : 'en'); } catch (e) { /* nada */ }
      { const m = /^(\d+) /.exec(String(document.getElementById('sel-ejemplos') && document.getElementById('sel-ejemplos').value || '')); if (m) location.hash = '#ej=' + m[1] + '&solo=1'; }
      location.reload();
    });
    m.appendChild(b);
  }
  function arranca() {
    boton(); document.documentElement.lang = L;
    if (L !== 'en') return;
    fetch('i18n_en.json').then((r) => r.json()).then((d) => {
      D = d; nodo(document.body);
      new MutationObserver((ms) => { for (const m of ms) { if (m.type === 'childList') m.addedNodes.forEach(nodo); else if (m.type === 'characterData') nodo(m.target); else if (m.type === 'attributes') nodo(m.target); } })
        .observe(document.body, { childList: true, subtree: true, characterData: true, attributes: true, attributeFilter: ['title', 'placeholder', 'aria-label'] });
    }).catch(() => { /* sin diccionario: queda en español */ });
  }
  if (document.readyState === 'loading') document.addEventListener('DOMContentLoaded', arranca); else arranca();
})(window);
