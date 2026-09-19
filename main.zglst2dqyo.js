// Hekatan LISP Web — la ventana del escritorio (MainWindow) en el navegador.
// Motor LISP: hlisp.wasm (ECL, engine.lisp compilado antes).  Render: el MISMO C# del escritorio (.NET WASM).
import { dotnet } from './_framework/dotnet.js';

const $ = id => document.getElementById(id);

// ---------- 1) motor LISP (ECL) + runtime .NET ----------
const hl = await HLisp({ print() {}, printErr() {} });
const lispRun = hl.cwrap('hlisp_run', 'string', ['string']);
const { setModuleImports, getAssemblyExports, getConfig, runMain } = await dotnet.create();
// registro de llamadas al motor (window.hekatanLog = [] lo activa; para depurar)
setModuleImports('hlisp', { run: code => { const out = lispRun(code); if (window.hekatanLog) window.hekatanLog.push({ code, out }); return out; } });
const W = (await getAssemblyExports(getConfig().mainAssemblyName)).HekatanLisp.MainWindow;
runMain();
// para pruebas automáticas (mismo cálculo que la pantalla)
window.hekatan = { compute: (t, o = 'simplify', v = '', vista = 'render', d = false) => W.Compute(t, o, v, vista, d) };

// ---------- 2) estado (mismos nombres que MainWindow.xaml.cs) ----------
const EJ_MATH = 'x^2 + 3*x\nsqrt(x) + sin(x)\n[1 2 3]\n[1 2; 3 4]\n3*x/2';
let view = 'render', op = 'simplify', autoRun = true, dark = false;
let syntaxLisp = false, synFull = false, transliterated = false, lispBackup = null;
let archivo = null;
const ed = $('code');

const guardarLocal = (k, v) => { try { localStorage.setItem(k, v); } catch { } };
const leerLocal = k => { try { return localStorage.getItem(k); } catch { return null; } };

// ---------- 3) resaltado de sintaxis (reglas de Lisp.xshd, en su mismo orden) ----------
const ID = '[A-Za-zξηθρτλμνφψωαβγδε_][A-Za-z0-9ξηθρτλμνφψωαβγδε_]*';
const NUM = '\\b\\d+(?:\\.\\d*)?(?:[eE][+-]?\\d+)?|\\.\\d+(?:[eE][+-]?\\d+)?';
const KW = 'defun defparameter defvar lambda let let\\* setf setq loop for from to by do while across in collect cond if then else elseif when unless progn return dolist dotimes function end'.split(' ');
const BI = 'Simplify Expand Factor Slope Sum Product Root Area Find Partial deriv integ diff despejar format print list vector aref car cdr cons first second third expt sqrt exp log sin cos tan abs mod max min floor ceiling round range dsimp meval mprint'.split(' ');
const BI_DEQ = 'Simplify Expand Factor Slope Sum Product Root Area Find deriv integ diff despejar Partial'.split(' ');
const kw = list => new RegExp('\\b(?:' + list.join('|') + ')\\b', 'y');
const R = (src, c) => ({ re: new RegExp(src, 'y'), c });
const REGLAS = [
  R('"[^"\\n]*"?', 'string'),
  R("'[A-Za-z_][A-Za-z0-9_\\-]*", 'eqtag'),
  { re: kw(KW), c: 'keyword' }, { re: kw(BI), c: 'builtin' },
  R(NUM, 'number'), R(ID + '(?=\\s*\\()', 'function'), R(ID, 'variable'),
];
const REGLAS_DEQ = [{ re: kw(BI_DEQ), c: 'builtin' }, R(NUM, 'number'), R(ID + '(?=\\s*\\()', 'function'), R(ID, 'variable')];
const REGLAS_PLOT = [R('\\b\\d+(?:\\.\\d*)?(?:[eE][+-]?\\d+)?|\\.\\d+', 'number'), R('[A-Za-zξηθρτ_][A-Za-z0-9ξηθρτ_]*', 'variable')];
const RE_PLOT = /#(?:fplot|plot|ezplot|graficas?|grafico|surf|superficie|plot3d|mesh|map|mapa|heatmap|contourf?|beam|viga|esquema|frame|portico|framedef|porticodef)\b/y;
const esc = s => s.replace(/[&<>]/g, c => ({ '&': '&amp;', '<': '&lt;', '>': '&gt;' }[c]));
const span = (c, t) => `<span class="c-${c}">${esc(t)}</span>`;

function pintarReglas(s, i, fin, reglas, out) {
  while (i < fin) {
    let hit = false;
    for (const r of reglas) {
      r.re.lastIndex = i;
      const m = r.re.exec(s);
      if (m && m[0].length && m.index === i && i + m[0].length <= fin) { out.push(span(r.c, m[0])); i += m[0].length; hit = true; break; }
    }
    if (!hit) { out.push(esc(s[i])); i++; }
  }
}

function resaltar(text) {
  const out = [];
  let enCorchete = false;              // el span [ ... ] puede cruzar líneas
  for (const linea of text.split('\n')) {
    let i = 0; const n = linea.length;
    while (i < n) {
      if (enCorchete) {                // dentro de [ ]: solo números
        const j = linea.indexOf(']', i); const fin = j < 0 ? n : j + 1;
        const buf = []; pintarReglas(linea, i, fin, [R(NUM, 'number')], buf);
        out.push(`<span class="c-bracket">${buf.join('')}</span>`); i = fin; if (j >= 0) enCorchete = false; continue;
      }
      const resto = linea.slice(i);
      let m;
      if ((m = /^#deq\b/.exec(resto))) {
        out.push(span('directive', m[0])); i += m[0].length;
        const k = linea.indexOf('@@', i); const fin = k < 0 ? n : k;
        const buf = []; pintarReglas(linea, i, fin, REGLAS_DEQ, buf); out.push(buf.join(''));
        if (k >= 0) out.push(span('eqtag', linea.slice(k)));
        i = n; continue;
      }
      RE_PLOT.lastIndex = i;
      if ((m = RE_PLOT.exec(linea)) && m.index === i) {
        out.push(span('directive', m[0])); const buf = []; pintarReglas(linea, i + m[0].length, n, REGLAS_PLOT, buf); out.push(buf.join('')); i = n; continue;
      }
      if (resto.startsWith('@@(')) { const j = linea.indexOf(')', i + 3); const fin = j < 0 ? n : j + 1; out.push(span('eqtag', linea.slice(i, fin))); i = fin; continue; }
      const c = linea[i];
      if (c === '#' || c === ';' || c === '%') { out.push(span('comment', resto)); i = n; continue; }
      if (c === '[') { enCorchete = true; continue; }
      let hit = false;
      for (const r of REGLAS) {
        r.re.lastIndex = i; const mm = r.re.exec(linea);
        if (mm && mm[0].length && mm.index === i) { out.push(span(r.c, mm[0])); i += mm[0].length; hit = true; break; }
      }
      if (!hit) { out.push(esc(c)); i++; }
    }
    out.push('\n');
  }
  return out.join('');
}

function pintarEditor() {
  $('hl').innerHTML = resaltar(ed.value) + ' ';
  const n = ed.value.split('\n').length;
  $('gutter').textContent = Array.from({ length: n }, (_, k) => k + 1).join('\n');
  sincronizarScroll();
}
function sincronizarScroll() {
  $('hl').scrollTop = ed.scrollTop; $('hl').scrollLeft = ed.scrollLeft;
  $('gutter').scrollTop = ed.scrollTop;
}
ed.addEventListener('scroll', sincronizarScroll);

// ---------- 4) resultado (RunShowAsync) ----------
let pendiente = 0;
function sourceText() {                 // SourceText(): el ORIGINAL, no el derivado
  const t = ed.value, ts = t.trimStart();
  if (syntaxLisp && !synFull && !transliterated && lispBackup != null) return lispBackup;
  const derivado = ts.startsWith(';;;; Script LISP') || ts.startsWith('% Hekatan Lab') || ts.startsWith('% =====');
  return derivado && lispBackup != null ? lispBackup : t;
}
function showResult() {
  const text = sourceText();
  let out;
  try { out = W.Compute(text, op, $('txt-var').value.trim(), view, dark); }
  catch (e) { out = view === 'render' || view === 'learn' ? `<pre style="color:#c0392b">${esc(String(e))}</pre>` : String(e); }
  const render = view === 'render' || view === 'learn';
  $('render').hidden = !render; $('texto').hidden = render;
  if (render) $('render').srcdoc = out; else $('texto').textContent = out;
}
function programar() {                  // _debounce de 280 ms, como el escritorio
  clearTimeout(pendiente);
  pendiente = setTimeout(showResult, 280);
}

// ---------- 5) botones (SetView / SetOp / SetSyntax / HighlightSyntax) ----------
function setView(v) {
  view = v;
  document.querySelectorAll('.mode[data-view]').forEach(b => b.classList.toggle('on', b.dataset.view === v));
  $('lbl-out').textContent = { render: 'resultado — render CSS', lisp: 'resultado — forma LISP',
    learn: 'resultado — 3 formas (Renderizado · LISP · Texto plano)' }[v] || 'resultado — texto plano';
  showResult();
}
function setOp(o) {
  op = o;
  document.querySelectorAll('.sym[data-op]').forEach(b => b.classList.toggle('on', b.dataset.op === o));
  showResult();
}
function highlightSyntax() {
  const on = { math: !syntaxLisp && !synFull && !transliterated, lisp: syntaxLisp && !synFull && !transliterated, full: synFull, lab: transliterated };
  document.querySelectorAll('.sym[data-syn]').forEach(b => b.classList.toggle('on', on[b.dataset.syn]));
}
function ponerEditor(t) { ed.value = t; pintarEditor(); }
function setSyntax(toLisp) {
  if ((synFull || transliterated || (syntaxLisp && !toLisp)) && lispBackup != null) ponerEditor(lispBackup);
  synFull = false; transliterated = false;
  if (!toLisp && W.IsProgram(ed.value)) {
    syntaxLisp = true; highlightSyntax();
    $('lbl-in').textContent = 'escribes: LISP (programa — no se convierte a texto plano por línea)'; return;
  }
  if (toLisp && !syntaxLisp) lispBackup = ed.value;
  ponerEditor(toLisp ? W.ToExprLisp(ed.value) : W.ToMath(ed.value));
  syntaxLisp = toLisp; highlightSyntax();
  $('lbl-in').textContent = toLisp ? 'escribes: expresión LISP (símbolo — NO ejecutable; para correr usa «LISP completo»)' : 'escribes: texto plano';
}
function synFullLisp() {
  const text = sourceText(); if (!text.trim()) return;
  const s = W.FullLisp(text, op); if (!s.trim()) return;
  lispBackup = text; ponerEditor(s);
  synFull = true; syntaxLisp = true; transliterated = false; highlightSyntax();
  $('lbl-in').textContent = 'escribes: LISP completo (cópialo entero a un .lisp y córrelo)';
}
function synHekLab() {
  const text = sourceText(); if (!text.trim()) return;
  if (W.IsProgram(text)) { aviso('«Hekatan Lab» convierte EXPRESIONES a MATLAB (syms, diff, int).<br>No aplica a un programa LISP.'); return; }
  const c = W.HekatanLab(text, op); if (!c.trim()) return;
  lispBackup = text; ponerEditor(c);
  transliterated = true; synFull = false; syntaxLisp = false; highlightSyntax();
  $('lbl-in').textContent = 'escribes: Hekatan Lab / MATLAB (cópialo a Hekatan Lab; aquí no corre)';
}
function applyTheme(d) {
  dark = d; document.documentElement.dataset.theme = d ? 'dark' : 'light';
  $('btn-theme').textContent = d ? '☾' : '☀';
  guardarLocal('hlisp-tema', d ? 'dark' : 'light');
  showResult();
}

// OnInsert: "lisp|matemática" según el modo; §§ = dónde queda el cursor
function insertar(tag) {
  if (!tag) return;
  if (tag.includes('|')) { const alt = tag.split('|'); tag = (syntaxLisp || alt.length < 2) ? alt[0] : alt[1]; }
  const a = ed.selectionStart, b = ed.selectionEnd;
  const [p0, p1 = ''] = tag.split('§§');
  ed.setRangeText(p0 + p1, a, b, 'end');
  ed.selectionStart = ed.selectionEnd = a + p0.length;
  ed.focus(); pintarEditor(); if (autoRun) programar();
}

// ---------- 6) archivo / menú ----------
function setArchivo(nombre) { archivo = nombre; $('lbl-archivo').textContent = nombre || '(sin guardar)'; }
function cargarTexto(t, nombre) {
  syntaxLisp = synFull = transliterated = false; lispBackup = null; highlightSyntax();
  $('lbl-in').textContent = 'escribes: texto plano';
  ponerEditor(t); setArchivo(nombre); showResult();
}
function descargar(nombre, texto) {
  const a = document.createElement('a');
  a.href = URL.createObjectURL(new Blob([texto], { type: 'text/plain;charset=utf-8' }));
  a.download = nombre; a.click(); setTimeout(() => URL.revokeObjectURL(a.href), 1000);
}
function aviso(html) { $('modal-txt').innerHTML = html; $('modal').classList.add('on'); }
$('modal').onclick = e => { if (e.target === $('modal')) $('modal').classList.remove('on'); };   // solo al tocar AFUERA
document.addEventListener('keydown', e => { if (e.key === 'Escape') $('modal').classList.remove('on'); });
// pegar otro enlace compartido en la misma pestaña → carga esa hoja
addEventListener('hashchange', async () => {
  try {
    if (await abrirDesdeEnlace()) {
      document.querySelectorAll('.sym[data-op]').forEach(b => b.classList.toggle('on', b.dataset.op === op));
      setView(view);
    }
  } catch { }
});

const ACCIONES = {
  nuevo: () => { cargarTexto('', null); $('sel-ejemplos').value = ''; ed.focus(); },
  abrir: () => $('file').click(),
  guardar: () => descargar(archivo || 'hoja.lisp', sourceText()),
  guardarLisp: () => descargar((archivo || 'hoja').replace(/\.lisp$/, '') + '_ejecutable.lisp', W.FullLisp(sourceText(), op)),
  copiarLisp: () => navigator.clipboard?.writeText(W.FullLisp(sourceText(), op)),
  pdf: () => { if (view !== 'render') setView('render'); $('render').contentWindow?.print(); },
  verMotor: async () => cargarTexto(await (await fetch('engine.lisp')).text(), 'engine.lisp'),
  compartir: () => compartir(),
  acerca: () => aviso('<b style="color:var(--gold)">Hekatan LISP</b> — una forma de mostrar operaciones <b>simbólicas y numéricas</b>, paso a paso.<br><br>' +
    'Sirve para compartir ejemplos: el <b>Jacobiano</b>, las <b>funciones de forma</b>, y las formulaciones que usan ' +
    '<b>ETABS, SAP2000, SAFE, Hekatan Struct</b> o cualquier programa de cálculo. Escribe la hoja y pulsa <b>🔗 Compartir</b>: ' +
    'quien abra el enlace la ve igual, ya calculada.<br><br>' +
    '<span style="font-size:12px;color:var(--muted)">Motor: ECL (Common Lisp) compilado a WebAssembly · Render: el mismo código de la app de escritorio.</span>'),
};
// ---------- enlace para compartir: la hoja viaja en el #hash (no pasa por ningún servidor) ----------
//   #ej=<ejemplo>            ejemplo sin cambios (enlace corto)
//   #h=<texto comprimido>    hoja propia: deflate-raw + base64url
//   &op=deriv&v=lisp         operación y vista, si no son las de siempre
async function comprimir(t) {
  const s = new Blob([t]).stream().pipeThrough(new CompressionStream('deflate-raw'));
  const b = new Uint8Array(await new Response(s).arrayBuffer());
  let bin = ''; for (const x of b) bin += String.fromCharCode(x);
  return btoa(bin).replace(/\+/g, '-').replace(/\//g, '_').replace(/=+$/, '');
}
async function descomprimir(c) {
  const bin = atob(c.replace(/-/g, '+').replace(/_/g, '/'));
  const b = Uint8Array.from(bin, ch => ch.charCodeAt(0));
  const s = new Blob([b]).stream().pipeThrough(new DecompressionStream('deflate-raw'));
  return await new Response(s).text();
}
async function compartir() {
  const t = sourceText();
  const p = new URLSearchParams();
  if (archivo && ejemploTexto !== null && t === ejemploTexto) p.set('ej', archivo);
  else p.set('h', await comprimir(t));
  if (op !== 'simplify') p.set('op', op);
  if (view !== 'render') p.set('v', view);
  const url = location.origin + location.pathname + '#' + p.toString();
  let copiado = false;
  try { await navigator.clipboard.writeText(url); copiado = true; } catch { }
  aviso(`<b style="color:var(--gold)">🔗 Enlace para compartir</b><br>
    Quien lo abra ve esta hoja, ya calculada${copiado ? ' — <b>copiado</b> al portapapeles' : ''}:<br>
    <input id="url-compartir" readonly value="${url.replace(/"/g, '&quot;')}"
      style="width:100%;margin-top:8px;padding:6px;font:12px Consolas,monospace;background:var(--editor);color:var(--text);border:1px solid var(--btn-border)">
    <div style="margin-top:6px;font-size:11px;color:var(--muted)">${url.length.toLocaleString()} caracteres · la hoja va dentro del enlace</div>`);
  const i = $('url-compartir'); i.focus(); i.select();
}
async function abrirDesdeEnlace() {
  const p = new URLSearchParams(location.hash.slice(1));
  if (p.get('op')) op = p.get('op');
  if (p.get('v')) view = p.get('v');
  if (p.get('ej')) {
    const f = p.get('ej'), t = await (await fetch('ejemplos/' + encodeURIComponent(f))).text();
    ejemploTexto = t; ponerEditor(t); setArchivo(f); $('sel-ejemplos').value = f;
    return true;
  }
  if (p.get('h')) { ponerEditor(await descomprimir(p.get('h'))); return true; }
  return false;
}

$('file').onchange = async e => { const f = e.target.files[0]; if (f) cargarTexto(await f.text(), f.name); e.target.value = ''; };

const menu = $('menu');
menu.querySelectorAll('.mi > span').forEach(s => s.addEventListener('click', e => {
  const mi = s.parentElement, abierto = mi.classList.contains('open');
  menu.querySelectorAll('.mi').forEach(m => m.classList.remove('open'));
  if (!abierto) mi.classList.add('open'); e.stopPropagation();
}));
menu.querySelectorAll('.mi > span').forEach(s => s.addEventListener('mouseenter', () => {
  if (menu.querySelector('.mi.open')) { menu.querySelectorAll('.mi').forEach(m => m.classList.remove('open')); s.parentElement.classList.add('open'); }
}));
document.addEventListener('click', () => menu.querySelectorAll('.mi').forEach(m => m.classList.remove('open')));

document.addEventListener('click', e => {
  const b = e.target.closest('button'); if (!b) return;
  if (b.dataset.view) setView(b.dataset.view);
  else if (b.dataset.op) setOp(b.dataset.op);
  else if (b.dataset.ins !== undefined) insertar(b.dataset.ins);
  else if (b.dataset.syn) ({ math: () => setSyntax(false), lisp: () => setSyntax(true), full: synFullLisp, lab: synHekLab })[b.dataset.syn]();
  else if (b.dataset.a) ACCIONES[b.dataset.a]?.();
  else if (b.dataset.ej) { cargarEjemplo(b.dataset.ej); $('sel-ejemplos').value = b.dataset.ej; }
});
$('btn-run').onclick = showResult;
if (leerLocal('hlisp-intro-cerrada') === '1') $('intro').classList.add('oculto');
$('intro-cerrar').onclick = () => { $('intro').classList.add('oculto'); guardarLocal('hlisp-intro-cerrada', '1'); };
$('chk-auto').onchange = e => { autoRun = e.target.checked; if (autoRun) showResult(); };
$('btn-theme').onclick = () => applyTheme(!dark);
$('btn-keypad').onclick = $('kp-min').onclick = () => $('keypad').classList.toggle('oculto');
$('btn-full').onclick = () => { const s = W.FullLisp(sourceText(), op); navigator.clipboard?.writeText(s); synFullLisp(); };
$('txt-var').oninput = () => { if (autoRun) programar(); };

ed.addEventListener('input', () => {
  pintarEditor(); guardarLocal('hlisp-autosave', ed.value);
  if (autoRun) programar();
});
ed.addEventListener('keydown', e => {
  if (e.key === 'Tab') { e.preventDefault(); ed.setRangeText('    ', ed.selectionStart, ed.selectionEnd, 'end'); pintarEditor(); }
});
document.addEventListener('keydown', e => {
  if (e.key === 'F5') { e.preventDefault(); showResult(); }
  if (e.key === 's' && (e.ctrlKey || e.metaKey)) { e.preventDefault(); ACCIONES.guardar(); }
});

// divisor arrastrable (GridSplitter)
$('split').addEventListener('pointerdown', e => {
  const main = $('main'); const x0 = main.getBoundingClientRect().left;
  $('split').setPointerCapture(e.pointerId);
  const mover = ev => { const w = Math.max(220, Math.min(ev.clientX - x0, main.clientWidth - 226)); main.style.setProperty('--izq', w + 'px'); };
  const soltar = () => { $('split').removeEventListener('pointermove', mover); $('split').removeEventListener('pointerup', soltar); };
  $('split').addEventListener('pointermove', mover); $('split').addEventListener('pointerup', soltar);
});

// letras griegas de la calculadora
const GR = [['α', 'alpha'], ['β', 'beta'], ['γ', 'gamma'], ['δ', 'delta'], ['ε', 'epsilon'], ['ζ', 'zeta'], ['η', 'eta'], ['θ', 'theta'], ['κ', 'kappa'], ['λ', 'lambda'],
  ['μ', 'mu'], ['ν', 'nu'], ['ξ', 'xi'], ['ρ', 'rho'], ['σ', 'sigma'], ['τ', 'tau'], ['φ', 'phi'], ['χ', 'chi'], ['ψ', 'psi'], ['ω', 'omega']];
$('griegas').innerHTML = GR.map(([g, t]) => `<button class="sym gr" data-ins="${t}">${g}</button>`).join('');

// lista de ejemplos: en Archivo → Ejemplos y en la lista de la barra de arriba
let ejemploTexto = null;   // texto del ejemplo cargado: si no se tocó, el enlace lo nombra (corto)
const cargarEjemplo = f => fetch('ejemplos/' + encodeURIComponent(f)).then(r => r.text()).then(t => { ejemploTexto = t; cargarTexto(t, f); });
fetch('ejemplos.json').then(r => r.json()).then(l => {
  $('lista-ejemplos').innerHTML = l.map(f => `<button data-ej="${f.replace(/"/g, '&quot;')}">${esc(f.replace(/\.lisp$/, ''))}</button>`).join('');
  for (const f of l) $('sel-ejemplos').add(new Option(f.replace(/\.lisp$/, ''), f));
  if (archivo && l.includes(archivo)) $('sel-ejemplos').value = archivo;   // abierto por enlace antes de que llegara la lista
});
$('sel-ejemplos').onchange = e => { if (e.target.value) cargarEjemplo(e.target.value); };

// ---------- 7) arranque (como OnLoaded: autosave o EJ_MATH; ApplyTheme → SetView/SetOp) ----------
const temaGuardado = leerLocal('hlisp-tema');
dark = temaGuardado === 'dark';
document.documentElement.dataset.theme = dark ? 'dark' : 'light';
$('btn-theme').textContent = dark ? '☾' : '☀';
// si se abrió con un enlace compartido, esa hoja manda; si no, lo último que escribiste (o el ejemplo)
let desdeEnlace = false;
try { desdeEnlace = location.hash.length > 1 && await abrirDesdeEnlace(); } catch { desdeEnlace = false; }
if (!desdeEnlace) ponerEditor(leerLocal('hlisp-autosave') || EJ_MATH);
if (matchMedia('(max-width: 760px)').matches) $('keypad').classList.add('oculto');   // celular: calculadora a un toque (🖩)
highlightSyntax();
document.querySelectorAll('.sym[data-op]').forEach(b => b.classList.toggle('on', b.dataset.op === op));
setView(view);
$('carga').remove();
