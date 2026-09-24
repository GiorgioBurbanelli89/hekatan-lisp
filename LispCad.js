// LispCad.js — la VENTANA DE DIBUJO de #dibujar (Hekatan LISP). Corre dentro de la página del resultado:
// WebView2 en el escritorio, iframe en la web (el mismo archivo para los dos; LispAutoLisp.cs lo incrusta).
//
// Reglas de AutoCAD (no inventadas): la referencia a objetos (OSNAP, apertura 10 px) manda sobre ORTO y
// sobre el forzado a la rejilla; F3 refent · F7 rejilla · F8 orto · F9 forzcursor; Intro, Espacio y clic
// derecho = Intro; Intro vacío repite la última orden; Esc cancela. Coordenadas: x,y (absoluta),
// @dx,dy (relativa), @d<ang (polar relativa), d<ang (polar absoluta) y un número solo = distancia directa
// en la dirección del cursor. Designar: clic, ventana (izq→der: dentro) o captura (der→izq: cruza), TODO, Último.
//
// GUARDAR: cada entidad se escribe como (entmake '((0 . "LINE") …)) — la lista DXF de AutoLISP — y la app
// la pone en el bloque #dibujar(nombre) … #fin de la hoja (escritorio: chrome.webview.postMessage; web:
// parent.postMessage). La hoja se recalcula y lo dibujado sigue en el motor (ssget, entget, area…).
(function () {
  if (window.hkCad) return;
  var APERTURA = 10, PICK = 5, S = null;

  // ------------------------------------------------------------------ utilidades
  function $(sel, r) { return (r || document).querySelector(sel); }
  function el(tag, cls, html) { var e = document.createElement(tag); if (cls) e.className = cls; if (html != null) e.innerHTML = html; return e; }
  function clon(o) { return JSON.parse(JSON.stringify(o)); }
  function pt2(v) { return [+(v && v[0]) || 0, +(v && v[1]) || 0]; }
  function esPt(v) { return Array.isArray(v) && v.length >= 2 && isFinite(v[0]) && isFinite(v[1]); }
  function dist(a, b) { return Math.hypot(b[0] - a[0], b[1] - a[1]); }
  function ang(a, b) { var t = Math.atan2(b[1] - a[1], b[0] - a[0]); return t < 0 ? t + 2 * Math.PI : t; }
  function norm(t) { t = t % (2 * Math.PI); return t < 0 ? t + 2 * Math.PI : t; }
  function limpio(p) { return [+(+p[0]).toFixed(12), +(+p[1]).toFixed(12)]; }   // 0.6000000000000001 → 0.6
  function fmt(v) { var s = (Math.round(v * 1e4) / 1e4).toFixed(4).replace(/\.?0+$/, ''); return s === '-0' ? '0' : s; }
  function css(v, d) { try { var x = getComputedStyle(document.body).getPropertyValue(v).trim(); return x || d; } catch (e) { return d; } }
  function colorCss(s) { if (!s) return css('--fg', '#222'); var m = /^var\((--[\w-]+)\)$/.exec(s); return m ? css(m[1], '#888') : s; }

  // ------------------------------------------------------------------ modelo: pares DXF ⇄ entidad
  // Entidad de trabajo: {t, capa, color (256 = PORCAPA), x: pares que no se tocan (tipo de línea, grosor…)}
  //   LINE a b · POINT p · CIRCLE c r · ARC c r a1 a2 (rad) · LWPOLYLINE pts bul cerr · TEXT p h s rot
  //   DIMENSION p1 p2 d rot alin txt · RAW tipo (lo demás: se dibuja su contorno y se guarda tal cual)
  var GEO = { LINE: [10, 11], POINT: [10], CIRCLE: [10, 40], ARC: [10, 40, 50, 51], TEXT: [10, 40, 1, 50],
    DIMENSION: [10, 13, 14, 15, 70, 1, 50, 40, 42], LWPOLYLINE: [10, 42, 70, 90] };
  // tipo de cota (código 70 & 7): 0 girada · 1 alineada · 3 diámetro · 4 radio · 5 angular de 3 puntos.
  // La angular de 2 líneas (2) y la de coordenadas (6) se guardan tal cual (RAW).
  function tipoCota(P) { for (var i = 0; i < P.length; i++) if (P[i][0] === 70) return (+P[i][1]) & 7; return 0; }
  function desdePares(P) {
    var t = String(P[0][1]).toUpperCase(), e = { t: t, capa: '0', color: 256, x: [] }, g = {}, pts = [], bul = [];
    var kc = t === 'DIMENSION' ? tipoCota(P) : 0;
    if (t === 'POLYLINE') {           // la POLYLINE 2D se edita como LWPOLYLINE
      e.t = 'LWPOLYLINE'; e.cerr = 0;
      P.forEach(function (p) {
        if (p[0] === 8) e.capa = String(p[1]); else if (p[0] === 62) e.color = +p[1];
        else if (p[0] === 70) e.cerr = (+p[1]) & 1; else if (p[0] === 1011) { pts.push(pt2(p[1])); bul.push(0); }
        else if (p[0] === 1042 && bul.length) bul[bul.length - 1] = +p[1];
      });
      e.pts = pts; e.bul = bul; return e;
    }
    var geo = GEO[t];
    if (t === 'DIMENSION' && (kc === 2 || kc > 5)) geo = null;
    if (!geo) { e.t = 'RAW'; e.tipo = t; }
    P.forEach(function (p) {
      var c = p[0], v = p[1];
      if (c === 0 || c === 5 || c === 100 || c === -1 || c === 330) return;
      if (c === 8) { e.capa = String(v); return; }
      if (c === 62) { e.color = +v; return; }
      if (!geo) { e.x.push([c, v]); return; }
      if (t === 'LWPOLYLINE') {
        if (c === 10) { pts.push(pt2(v)); bul.push(0); return; }
        if (c === 42) { if (bul.length) bul[bul.length - 1] = +v; return; }
        if (c === 70) { e.cerr = (+v) & 1; return; }
        if (c === 90) return;
      } else if (geo.indexOf(c) >= 0 && !(c in g)) { g[c] = v; return; }
      e.x.push([c, v]);
    });
    switch (t) {
      case 'LINE': e.a = pt2(g[10]); e.b = pt2(g[11]); break;
      case 'POINT': e.p = pt2(g[10]); break;
      case 'CIRCLE': e.c = pt2(g[10]); e.r = +g[40]; break;
      case 'ARC': e.c = pt2(g[10]); e.r = +g[40]; e.a1 = +g[50]; e.a2 = +g[51]; break;
      case 'TEXT': e.p = pt2(g[10]); e.h = +(g[40] || 2.5); e.s = String(g[1] == null ? '' : g[1]); e.rot = +(g[50] || 0); break;
      case 'DIMENSION':
        e.txt = String(g[1] == null ? '' : g[1]);
        if (kc === 5) { e.k = 'ang'; e.d = pt2(g[10]); e.p1 = pt2(g[13]); e.p2 = pt2(g[14]); e.v = pt2(g[15]); break; }
        if (kc === 4) { e.k = 'rad'; e.c = pt2(g[10]); e.p = pt2(g[15]); e.L = +(g[40] || 0); break; }
        if (kc === 3) { e.k = 'dia'; e.p1 = pt2(g[10]); e.p2 = pt2(g[15]); e.L = +(g[40] || 0); break; }
        e.p1 = pt2(g[13]); e.p2 = pt2(g[14]); e.d = g[10] ? pt2(g[10]) : e.p2.slice();
        e.alin = ((+(g[70] || 32)) & 7) === 1; e.rot = +(g[50] || 0); break;
      case 'LWPOLYLINE': e.pts = pts; e.bul = bul; e.cerr = e.cerr || 0; break;
    }
    return e;
  }
  function p3(p) { return [p[0], p[1], 0]; }
  // Entidad → pares DXF en el orden que acepta entmake de AutoCAD (LWPOLYLINE y DIMENSION con sus 100)
  function aPares(e) {
    var P = [];
    if (e.t === 'RAW') { P.push([0, e.tipo], [8, e.capa]); if (e.color !== 256) P.push([62, e.color]); return P.concat(e.x); }
    P.push([0, e.t]);
    if (e.t === 'LWPOLYLINE' || e.t === 'DIMENSION') P.push([100, 'AcDbEntity']);
    P.push([8, e.capa]);
    if (e.color !== 256) P.push([62, e.color]);
    switch (e.t) {
      case 'LINE': P.push([10, p3(e.a)], [11, p3(e.b)]); break;
      case 'POINT': P.push([10, p3(e.p)]); break;
      case 'CIRCLE': P.push([10, p3(e.c)], [40, e.r]); break;
      case 'ARC': P.push([10, p3(e.c)], [40, e.r], [50, e.a1], [51, e.a2]); break;
      case 'TEXT': P.push([10, p3(e.p)], [40, e.h], [1, e.s]); if (e.rot) P.push([50, e.rot]); break;
      case 'LWPOLYLINE':
        P.push([100, 'AcDbPolyline'], [90, e.pts.length], [70, e.cerr ? 1 : 0]);
        P = P.concat(e.x);
        e.pts.forEach(function (p, i) { P.push([10, [p[0], p[1]]]); if (e.bul[i]) P.push([42, e.bul[i]]); });
        return P;
      case 'DIMENSION':
        if (e.k === 'ang') { P.push([100, 'AcDbDimension'], [10, p3(e.d)], [70, 37], [1, e.txt || ''], [100, 'AcDb3PointAngularDimension'], [13, p3(e.p1)], [14, p3(e.p2)], [15, p3(e.v)]); break; }
        if (e.k === 'rad') { P.push([100, 'AcDbDimension'], [10, p3(e.c)], [70, 36], [1, e.txt || ''], [100, 'AcDbRadialDimension'], [15, p3(e.p)], [40, e.L || 0]); break; }
        if (e.k === 'dia') { P.push([100, 'AcDbDimension'], [10, p3(e.p1)], [70, 35], [1, e.txt || ''], [100, 'AcDbDiametricDimension'], [15, p3(e.p2)], [40, e.L || 0]); break; }
        P.push([100, 'AcDbDimension'], [10, p3(e.d)], [70, e.alin ? 33 : 32], [1, e.txt || ''],
               [100, 'AcDbAlignedDimension'], [13, p3(e.p1)], [14, p3(e.p2)]);
        if (!e.alin) P.push([50, e.rot || 0], [100, 'AcDbRotatedDimension']);
        break;
    }
    return P.concat(e.x);
  }
  function entero(c) { return (c >= 60 && c <= 99) || (c >= 170 && c <= 179) || (c >= 270 && c <= 289) || (c >= 1060 && c <= 1071); }
  function num(v, ent) {
    if (ent) return String(Math.round(+v));
    var r = Math.round(+v * 1e9) / 1e9; if (r === 0) r = 0;
    var s = String(r); if (!/[.eE]/.test(s)) s += '.0'; return s;       // 0.0 y no 0: número real en AutoLISP
  }
  function cad(s) { return '"' + String(s).replace(/\\/g, '\\\\').replace(/"/g, '\\"') + '"'; }
  function lispPar(p) {
    var c = p[0], v = p[1];
    if (Array.isArray(v)) return '(' + c + ' ' + v.map(function (x) { return num(x); }).join(' ') + ')';
    if (typeof v === 'string') return '(' + c + ' . ' + cad(v) + ')';
    return '(' + c + ' . ' + num(v, entero(c)) + ')';
  }
  function entmake(P) { return "(entmake '(" + P.map(lispPar).join(' ') + '))'; }
  // El bloque entero: capas (tabla LAYER, como AutoCAD) y una entidad por línea
  function cuerpo() {
    var L = [';; dibujado con la ventana ✏ — ' + S.ents.length + (S.ents.length === 1 ? ' entidad' : ' entidades') +
             ' (listas DXF de AutoLISP: se reescribe al guardar)'];
    S.capas.forEach(function (c) {
      var usada = S.ents.some(function (e) { return e.capa.toUpperCase() === c.n.toUpperCase(); });
      if (c.n === '0' && c.c === 7) return;
      if (!usada && c.n !== S.capa) return;
      L.push(entmake([[0, 'LAYER'], [100, 'AcDbSymbolTableRecord'], [100, 'AcDbLayerTableRecord'], [2, c.n], [70, 0], [62, c.c], [6, c.tipo || 'CONTINUOUS']]));
    });
    S.ents.forEach(function (e) { L.push(entmake(aPares(e))); });
    return L.join('\n');
  }

  // ------------------------------------------------------------------ constructores
  function nueva(t, o) { o.t = t; o.capa = S.capa; o.color = S.color; o.x = []; return o; }
  function lin(a, b) { return nueva('LINE', { a: a.slice(), b: b.slice() }); }
  function poliE(pts, cerr) { return nueva('LWPOLYLINE', { pts: pts.map(function (p) { return p.slice(); }), bul: pts.map(function () { return 0; }), cerr: cerr ? 1 : 0 }); }
  function rectE(a, b) { return poliE([a, [b[0], a[1]], b, [a[0], b[1]]], true); }
  function circE(c, r) { return nueva('CIRCLE', { c: c.slice(), r: r }); }
  function arcE(c, r, a1, a2) { return nueva('ARC', { c: c.slice(), r: r, a1: norm(a1), a2: norm(a2) }); }
  function arco3(p1, p2, p3) {
    var ax = p1[0], ay = p1[1], bx = p2[0], by = p2[1], cx = p3[0], cy = p3[1];
    var d = 2 * (ax * (by - cy) + bx * (cy - ay) + cx * (ay - by));
    if (Math.abs(d) < 1e-14) return null;
    var ux = ((ax * ax + ay * ay) * (by - cy) + (bx * bx + by * by) * (cy - ay) + (cx * cx + cy * cy) * (ay - by)) / d;
    var uy = ((ax * ax + ay * ay) * (cx - bx) + (bx * bx + by * by) * (ax - cx) + (cx * cx + cy * cy) * (bx - ax)) / d;
    var c = [ux, uy], r = dist(c, p1), ccw = ((bx - ax) * (cy - ay) - (by - ay) * (cx - ax)) > 0;
    return ccw ? arcE(c, r, ang(c, p1), ang(c, p3)) : arcE(c, r, ang(c, p3), ang(c, p1));
  }
  function cotaE(p1, p2, q, modo) {
    var e = nueva('DIMENSION', { p1: p1.slice(), p2: p2.slice(), txt: '', alin: false, rot: 0 });
    if (!modo) {                     // DIMLINEAR: la posición decide horizontal o vertical (como AutoCAD)
      var x0 = Math.min(p1[0], p2[0]), x1 = Math.max(p1[0], p2[0]), y0 = Math.min(p1[1], p2[1]), y1 = Math.max(p1[1], p2[1]);
      var fx = q[0] < x0 ? x0 - q[0] : (q[0] > x1 ? q[0] - x1 : 0), fy = q[1] < y0 ? y0 - q[1] : (q[1] > y1 ? q[1] - y1 : 0);
      modo = fy > fx ? 'H' : (fx > fy ? 'V' : (Math.abs(p2[0] - p1[0]) >= Math.abs(p2[1] - p1[1]) ? 'H' : 'V'));
    }
    if (modo === 'H') { e.rot = 0; e.d = [p2[0], q[1]]; }
    else if (modo === 'V') { e.rot = Math.PI / 2; e.d = [q[0], p2[1]]; }
    else {
      var L = dist(p1, p2) || 1, n = [-(p2[1] - p1[1]) / L, (p2[0] - p1[0]) / L];
      var s = (q[0] - p1[0]) * n[0] + (q[1] - p1[1]) * n[1];
      e.alin = true; e.d = [p2[0] + s * n[0], p2[1] + s * n[1]];
    }
    return e;
  }
  // geometría de una cota: pies de las líneas de referencia sobre la línea de cota y la medida
  function cotaGeo(e) {
    var u = e.alin ? (function () { var L = dist(e.p1, e.p2) || 1; return [(e.p2[0] - e.p1[0]) / L, (e.p2[1] - e.p1[1]) / L]; })() : [Math.cos(e.rot), Math.sin(e.rot)];
    var n = [-u[1], u[0]];
    function pie(p) { var s = (e.d[0] - p[0]) * n[0] + (e.d[1] - p[1]) * n[1]; return [p[0] + s * n[0], p[1] + s * n[1]]; }
    var q1 = pie(e.p1), q2 = pie(e.p2);
    return { q1: q1, q2: q2, u: u, n: n, m: Math.abs((e.p2[0] - e.p1[0]) * u[0] + (e.p2[1] - e.p1[1]) * u[1]) };
  }
  function trasladar(e, v) {
    function m(p) { p[0] += v[0]; p[1] += v[1]; }
    ['a', 'b', 'p', 'c', 'd', 'p1', 'p2', 'v'].forEach(function (k) { if (esPt(e[k])) m(e[k]); });
    if (e.pts) e.pts.forEach(m);
    e.x.forEach(function (p) { if (((p[0] >= 10 && p[0] <= 18) || p[0] === 1011) && esPt(p[1])) { p[1] = p[1].slice(); m(p[1]); } });
  }
  // GIRAR, ESCALA y SIMETRÍA: f lleva cada punto; rot = giro (rad), esc = factor; alfa = ángulo de la línea de
  // simetría (solo en SIMETRÍA). El texto se refleja con MIRRTEXT = 0 (por defecto en AutoCAD): cambia de sitio
  // pero se sigue leyendo al derecho.
  function transformar(e, f, rot, esc, alfa) {
    var esp = alfa !== undefined;
    function m(p) { var q = f(p); p[0] = q[0]; p[1] = q[1]; }
    function giro(t) { t = norm(t); return t > 2 * Math.PI - 1e-12 ? 0 : t; }
    if (e.t === 'TEXT' && esp) {
      var w = e.h * 0.6 * Math.max(1, e.s.length), fin = [e.p[0] + w * Math.cos(e.rot), e.p[1] + w * Math.sin(e.rot)];
      var dA = giro(2 * alfa - e.rot), dB = giro(dA + Math.PI);
      var dif = function (x) { var t = Math.abs(norm(x - e.rot)); return Math.min(t, 2 * Math.PI - t); };
      if (dif(dA) <= dif(dB)) { e.p = f(e.p); e.rot = dA; } else { e.p = f(fin); e.rot = dB; }
    }
    ['a', 'b', 'p', 'c', 'd', 'p1', 'p2', 'v'].forEach(function (k) { if (esPt(e[k]) && !(e.t === 'TEXT' && esp)) m(e[k]); });
    if (e.pts) e.pts.forEach(m);
    e.x.forEach(function (p) { if (((p[0] >= 10 && p[0] <= 18) || p[0] === 1011) && esPt(p[1])) p[1] = f(p[1]); });
    if (e.t === 'CIRCLE' || e.t === 'ARC') e.r *= esc;
    if (e.t === 'ARC') { if (esp) { var a1 = giro(2 * alfa - e.a2); e.a2 = giro(2 * alfa - e.a1); e.a1 = a1; } else { e.a1 = giro(e.a1 + rot); e.a2 = giro(e.a2 + rot); } }
    if (e.t === 'LWPOLYLINE' && esp) e.bul = e.bul.map(function (b) { return b ? -b : 0; });
    if (e.t === 'TEXT') { e.h *= esc; if (!esp) e.rot = giro(e.rot + rot); }
    if (e.t === 'DIMENSION' && !e.k && !e.alin) e.rot = giro(esp ? 2 * alfa - e.rot : e.rot + rot);
    if (e.t === 'DIMENSION' && e.L) e.L *= esc;
  }

  // segmentos, arcos y puntos notables (para OSNAP, designar y encuadre)
  function segs(e) {
    var r = [];
    if (e.t === 'LINE') r.push([e.a, e.b]);
    else if (e.t === 'LWPOLYLINE') {
      var n = e.pts.length;
      for (var i = 0; i < (e.cerr ? n : n - 1); i++) if (!e.bul[i]) r.push([e.pts[i], e.pts[(i + 1) % n]]);
    } else if (e.t === 'DIMENSION') { if (!e.k) { var g = cotaGeo(e); r.push([g.q1, g.q2]); } }
    else if (e.t === 'RAW') { var q = e.x.filter(function (p) { return p[0] === 10 && esPt(p[1]); }).map(function (p) { return pt2(p[1]); }); for (var j = 0; j + 1 < q.length; j++) r.push([q[j], q[j + 1]]); if (q.length > 2) r.push([q[q.length - 1], q[0]]); }
    return r;
  }
  function bulgeArco(p, q, b) {        // tramo con abultamiento → arco (centro, radio, a1, a2 antihorario)
    var th = 4 * Math.atan(b), c = dist(p, q), r = c / (2 * Math.sin(Math.abs(th) / 2));
    var m = [(p[0] + q[0]) / 2, (p[1] + q[1]) / 2], u = [(q[0] - p[0]) / c, (q[1] - p[1]) / c];
    var d = c * (1 - b * b) / (4 * b), cen = [m[0] - d * u[1], m[1] + d * u[0]];   // centro a la izquierda de p→q si d > 0
    return b > 0 ? { c: cen, r: r, a1: ang(cen, p), a2: ang(cen, q) } : { c: cen, r: r, a1: ang(cen, q), a2: ang(cen, p) };
  }
  function arcos(e) {
    if (e.t === 'CIRCLE') return [{ c: e.c, r: e.r, full: true }];
    if (e.t === 'ARC') return [{ c: e.c, r: e.r, a1: e.a1, a2: e.a2 }];
    if (e.t === 'LWPOLYLINE') {
      var r = [], n = e.pts.length;
      for (var i = 0; i < (e.cerr ? n : n - 1); i++) if (e.bul[i]) r.push(bulgeArco(e.pts[i], e.pts[(i + 1) % n], e.bul[i]));
      return r;
    }
    return [];
  }
  function enArco(a, t) { if (a.full) return true; var s = norm(a.a2 - a.a1), d = norm(t - a.a1); return d <= s + 1e-9; }
  function notables(e) {             // [punto, modo]: fin, medio, centro, nodo
    var r = [];
    if (e.t === 'LINE') { r.push([e.a, 'fin'], [e.b, 'fin'], [[(e.a[0] + e.b[0]) / 2, (e.a[1] + e.b[1]) / 2], 'medio']); }
    else if (e.t === 'LWPOLYLINE') {
      e.pts.forEach(function (p) { r.push([p, 'fin']); });
      segs(e).forEach(function (s) { r.push([[(s[0][0] + s[1][0]) / 2, (s[0][1] + s[1][1]) / 2], 'medio']); });
    } else if (e.t === 'POINT') r.push([e.p, 'nodo']);
    else if (e.t === 'TEXT') r.push([e.p, 'nodo']);
    else if (e.t === 'DIMENSION') { if (!e.k) r.push([e.p1, 'nodo'], [e.p2, 'nodo']); }
    arcos(e).forEach(function (a) {
      r.push([a.c, 'centro']);
      if (!a.full) {
        var am = a.a1 + norm(a.a2 - a.a1) / 2;
        r.push([[a.c[0] + a.r * Math.cos(a.a1), a.c[1] + a.r * Math.sin(a.a1)], 'fin'], [[a.c[0] + a.r * Math.cos(a.a2), a.c[1] + a.r * Math.sin(a.a2)], 'fin'],
               [[a.c[0] + a.r * Math.cos(am), a.c[1] + a.r * Math.sin(am)], 'medio']);
      }
    });
    return r;
  }
  function interSS(a, b) {
    var d1 = [a[1][0] - a[0][0], a[1][1] - a[0][1]], d2 = [b[1][0] - b[0][0], b[1][1] - b[0][1]], den = d1[0] * d2[1] - d1[1] * d2[0];
    if (Math.abs(den) < 1e-14) return [];
    var w = [b[0][0] - a[0][0], b[0][1] - a[0][1]], t = (w[0] * d2[1] - w[1] * d2[0]) / den, u = (w[0] * d1[1] - w[1] * d1[0]) / den;
    return (t >= -1e-9 && t <= 1 + 1e-9 && u >= -1e-9 && u <= 1 + 1e-9) ? [[a[0][0] + t * d1[0], a[0][1] + t * d1[1]]] : [];
  }
  function interSA(s, a) {
    var d = [s[1][0] - s[0][0], s[1][1] - s[0][1]], f = [s[0][0] - a.c[0], s[0][1] - a.c[1]];
    var A = d[0] * d[0] + d[1] * d[1], B = 2 * (f[0] * d[0] + f[1] * d[1]), C = f[0] * f[0] + f[1] * f[1] - a.r * a.r, D = B * B - 4 * A * C, r = [];
    if (D < 0 || A < 1e-20) return r;
    [(-B - Math.sqrt(D)) / (2 * A), (-B + Math.sqrt(D)) / (2 * A)].forEach(function (t) {
      if (t >= -1e-9 && t <= 1 + 1e-9) { var p = [s[0][0] + t * d[0], s[0][1] + t * d[1]]; if (enArco(a, ang(a.c, p))) r.push(p); }
    });
    return r;
  }
  function interAA(a, b) {
    var d = dist(a.c, b.c), r = [];
    if (d < 1e-12 || d > a.r + b.r || d < Math.abs(a.r - b.r)) return r;
    var x = (d * d + a.r * a.r - b.r * b.r) / (2 * d), h = Math.sqrt(Math.max(0, a.r * a.r - x * x));
    var u = [(b.c[0] - a.c[0]) / d, (b.c[1] - a.c[1]) / d], m = [a.c[0] + x * u[0], a.c[1] + x * u[1]];
    [[m[0] - h * u[1], m[1] + h * u[0]], [m[0] + h * u[1], m[1] - h * u[0]]].forEach(function (p) {
      if (enArco(a, ang(a.c, p)) && enArco(b, ang(b.c, p))) r.push(p);
    });
    return r;
  }
  function caja(e) {
    var P = [];
    if (e.t === 'LINE') P = [e.a, e.b];
    else if (e.t === 'LWPOLYLINE') P = e.pts;
    else if (e.t === 'POINT') P = [e.p];
    else if (e.t === 'TEXT') { var w = e.h * 0.6 * Math.max(1, e.s.length); P = [e.p, [e.p[0] + w * Math.cos(e.rot) - e.h * Math.sin(e.rot), e.p[1] + w * Math.sin(e.rot) + e.h * Math.cos(e.rot)]]; }
    else if (e.t === 'DIMENSION') {
      if (e.k === 'ang') { var R = dist(e.v, e.d); P = [e.p1, e.p2, e.d, [e.v[0] - R, e.v[1] - R], [e.v[0] + R, e.v[1] + R]]; }
      else if (e.k === 'rad') P = [e.c, e.p]; else if (e.k === 'dia') P = [e.p1, e.p2];
      else { var g = cotaGeo(e); P = [e.p1, e.p2, g.q1, g.q2]; }
    }
    else if (e.t === 'RAW') P = e.x.filter(function (p) { return p[0] >= 10 && p[0] <= 18 && esPt(p[1]); }).map(function (p) { return p[1]; });
    arcos(e).forEach(function (a) { P = P.concat([[a.c[0] - a.r, a.c[1] - a.r], [a.c[0] + a.r, a.c[1] + a.r]]); });
    if (!P.length) return null;
    var b = [Infinity, Infinity, -Infinity, -Infinity];
    P.forEach(function (p) { b[0] = Math.min(b[0], p[0]); b[1] = Math.min(b[1], p[1]); b[2] = Math.max(b[2], p[0]); b[3] = Math.max(b[3], p[1]); });
    return b;
  }

  // ------------------------------------------------------------------ vista (mundo ⇄ pantalla)
  function aPant(p) { return [(p[0] - S.v.x0) * S.v.k, S.H - (p[1] - S.v.y0) * S.v.k]; }
  function aMundo(q) { return [q[0] / S.v.k + S.v.x0, (S.H - q[1]) / S.v.k + S.v.y0]; }
  function encuadre() {
    var b = [Infinity, Infinity, -Infinity, -Infinity];
    S.ents.forEach(function (e) { var c = caja(e); if (c) { b[0] = Math.min(b[0], c[0]); b[1] = Math.min(b[1], c[1]); b[2] = Math.max(b[2], c[2]); b[3] = Math.max(b[3], c[3]); } });
    if (!isFinite(b[0])) b = [0, 0, 20 * S.rej, 12 * S.rej];
    var w = Math.max(b[2] - b[0], S.rej * 4), h = Math.max(b[3] - b[1], S.rej * 4);
    var k = Math.min(S.W / (w * 1.25), S.H / (h * 1.25));
    S.v = { k: k, x0: (b[0] + b[2]) / 2 - S.W / (2 * k), y0: (b[1] + b[3]) / 2 - S.H / (2 * k) };
    pintar();
  }
  function paso() {                    // separación de la rejilla que se ve (≥ 8 px), múltiplo de la de trabajo
    var s = S.rej; while (s * S.v.k < 8) s *= (String(s / S.rej).charAt(0) === '2' ? 2.5 : 2);
    return s;
  }

  // ------------------------------------------------------------------ cursor: OSNAP > ORTO > FORZC
  function osnap(q, base) {
    var w = aMundo(q), tol = APERTURA / S.v.k, best = null, cand = [];
    function prueba(p, modo) { var s = aPant(p), d = Math.hypot(s[0] - q[0], s[1] - q[1]); if (d <= APERTURA) cand.push({ p: p, modo: modo, d: d }); }
    var cerca = S.ents.filter(function (e) {
      var b = caja(e); return b && w[0] >= b[0] - tol && w[0] <= b[2] + tol && w[1] >= b[1] - tol && w[1] <= b[3] + tol;
    });
    cerca.forEach(function (e) { notables(e).forEach(function (n) { if (S.modos[n[1]]) prueba(n[0], n[1]); }); });
    // CUADRANTE: 0°, 90°, 180°, 270° del círculo (en un arco, los que caen dentro)
    if (S.modos.cuad) cerca.forEach(function (e) { arcos(e).forEach(function (a) {
      for (var k = 0; k < 4; k++) { var t = k * Math.PI / 2; if (enArco(a, t)) prueba([a.c[0] + a.r * Math.cos(t), a.c[1] + a.r * Math.sin(t)], 'cuad'); }
    }); });
    // TANGENTE (desde el punto anterior): los dos puntos donde la recta desde la base toca el círculo
    if (S.modos.tan && base) cerca.forEach(function (e) { arcos(e).forEach(function (a) {
      var d = dist(a.c, base); if (d <= a.r + 1e-12) return;
      var b0 = ang(a.c, base), be = Math.acos(a.r / d);
      [b0 + be, b0 - be].forEach(function (t) { if (enArco(a, norm(t))) prueba([a.c[0] + a.r * Math.cos(t), a.c[1] + a.r * Math.sin(t)], 'tan'); });
    }); });
    if (S.modos.inter) {
      var S1 = [], A1 = [];
      cerca.forEach(function (e) { if (e.t !== 'DIMENSION') { segs(e).forEach(function (s) { S1.push(s); }); arcos(e).forEach(function (a) { A1.push(a); }); } });
      for (var i = 0; i < S1.length; i++) for (var j = i + 1; j < S1.length; j++) interSS(S1[i], S1[j]).forEach(function (p) { prueba(p, 'inter'); });
      S1.forEach(function (s) { A1.forEach(function (a) { interSA(s, a).forEach(function (p) { prueba(p, 'inter'); }); }); });
      for (var m = 0; m < A1.length; m++) for (var n = m + 1; n < A1.length; n++) interAA(A1[m], A1[n]).forEach(function (p) { prueba(p, 'inter'); });
    }
    if (S.modos.perp && base) {
      cerca.forEach(function (e) {
        if (e.t === 'DIMENSION') return;
        segs(e).forEach(function (s) {
          var d = [s[1][0] - s[0][0], s[1][1] - s[0][1]], L2 = d[0] * d[0] + d[1] * d[1]; if (L2 < 1e-20) return;
          var t = ((base[0] - s[0][0]) * d[0] + (base[1] - s[0][1]) * d[1]) / L2;
          if (t >= -1e-9 && t <= 1 + 1e-9) prueba([s[0][0] + t * d[0], s[0][1] + t * d[1]], 'perp');
        });
        arcos(e).forEach(function (a) { var t = ang(a.c, base); if (enArco(a, t)) prueba([a.c[0] + a.r * Math.cos(t), a.c[1] + a.r * Math.sin(t)], 'perp'); });
      });
    }
    var ORD = { fin: 0, inter: 1, medio: 2, centro: 3, cuad: 4, nodo: 5, tan: 6, perp: 7 };
    cand.forEach(function (c) { if (!best || c.d < best.d - 0.5 || (Math.abs(c.d - best.d) <= 0.5 && ORD[c.modo] < ORD[best.modo])) best = c; });
    return best;
  }
  function cursor(q) {
    var req = S.req, base = req && req.base;
    S.snap = S.osnapOn && req && (req.t === 'punto' || req.t === 'numero') ? osnap(q, base) : null;
    S.pol = null;
    if (S.snap) return S.snap.p.slice();
    var p = aMundo(q);
    // RASTREO POLAR (F10): cerca (≤ apertura) de un rayo a k·incremento desde el punto anterior, el cursor va
    // SOBRE el rayo (como AutoCAD: OSNAP > polar; polar y orto se excluyen). Con Forzc la distancia va a
    // múltiplos de la rejilla (el «PolarSnap» de AutoCAD).
    if (S.polar && base && !(req && req.sinOrto) && req && (req.t === 'punto' || req.t === 'numero')) {
      var inc = S.polarAng * Math.PI / 180, a = ang(base, p), ap = Math.round(a / inc) * inc, d = dist(base, p);
      if (d * S.v.k > 4 && Math.cos(a - ap) > 0 && Math.abs(Math.sin(a - ap)) * d * S.v.k <= APERTURA) {
        var L = d * Math.cos(a - ap); if (S.forzc) L = Math.round(L / S.rej) * S.rej;
        S.pol = { ang: norm(ap), L: L };
        return limpio([base[0] + L * Math.cos(ap), base[1] + L * Math.sin(ap)]);
      }
    }
    if (S.forzc) p = limpio([Math.round(p[0] / S.rej) * S.rej, Math.round(p[1] / S.rej) * S.rej]);
    if (S.orto && base && !(req && req.sinOrto)) {
      if (Math.abs(p[0] - base[0]) >= Math.abs(p[1] - base[1])) p = [p[0], base[1]]; else p = [base[0], p[1]];
    }
    return p;
  }

  // ------------------------------------------------------------------ pintar
  function colorDe(e) {
    var c = e.color; if (c === 256 || c === 0) { var cp = capaDe(e.capa); c = cp ? cp.c : 7; }
    return colorCss(S.pal[c] || S.pal[7]);
  }
  function capaDe(n) { n = String(n).toUpperCase(); for (var i = 0; i < S.capas.length; i++) if (S.capas[i].n.toUpperCase() === n) return S.capas[i]; return null; }
  function trazar(g, e, col, ancho) {
    g.strokeStyle = col; g.fillStyle = col; g.lineWidth = ancho || 1.3;
    var P;
    switch (e.t) {
      case 'LINE': g.beginPath(); P = aPant(e.a); g.moveTo(P[0], P[1]); P = aPant(e.b); g.lineTo(P[0], P[1]); g.stroke(); break;
      case 'LWPOLYLINE':
        var n = e.pts.length; if (!n) break;
        g.beginPath(); P = aPant(e.pts[0]); g.moveTo(P[0], P[1]);
        for (var i = 0; i < (e.cerr ? n : n - 1); i++) {
          var p = e.pts[i], q = e.pts[(i + 1) % n];
          if (e.bul[i]) { var a = bulgeArco(p, q, e.bul[i]), c = aPant(a.c); if (e.bul[i] > 0) g.arc(c[0], c[1], a.r * S.v.k, -a.a1, -a.a2, true); else g.arc(c[0], c[1], a.r * S.v.k, -a.a2, -a.a1, false); }
          else { P = aPant(q); g.lineTo(P[0], P[1]); }
        }
        g.stroke(); break;
      case 'CIRCLE': P = aPant(e.c); g.beginPath(); g.arc(P[0], P[1], e.r * S.v.k, 0, 2 * Math.PI); g.stroke(); break;
      case 'ARC': P = aPant(e.c); g.beginPath(); g.arc(P[0], P[1], e.r * S.v.k, -e.a1, -e.a2, true); g.stroke(); break;
      case 'POINT': P = aPant(e.p); g.beginPath(); g.arc(P[0], P[1], 2.2, 0, 2 * Math.PI); g.fill(); g.beginPath(); g.moveTo(P[0] - 5, P[1]); g.lineTo(P[0] + 5, P[1]); g.moveTo(P[0], P[1] - 5); g.lineTo(P[0], P[1] + 5); g.lineWidth = 0.8; g.stroke(); break;
      case 'TEXT':
        P = aPant(e.p); g.save(); g.translate(P[0], P[1]); g.rotate(-e.rot);
        var mat = e.x.some(function (x) { return x[0] === 7 && /HKMATH/i.test(x[1]); });
        g.font = (mat ? 'italic ' : '') + Math.max(1, e.h * S.v.k).toFixed(1) + 'px ' + (mat ? '"Times New Roman",serif' : '"Segoe UI",Arial,sans-serif');
        g.textBaseline = 'alphabetic'; g.fillText(e.s, 0, 0); g.restore(); break;
      case 'DIMENSION':
        if (e.k) { trazarCota(g, e); break; }
        var G = cotaGeo(e), a1 = aPant(G.q1), a2 = aPant(G.q2), b1 = aPant(e.p1), b2 = aPant(e.p2);
        g.lineWidth = 0.9; g.beginPath(); g.moveTo(b1[0], b1[1]); g.lineTo(a1[0], a1[1]); g.moveTo(b2[0], b2[1]); g.lineTo(a2[0], a2[1]);
        g.moveTo(a1[0], a1[1]); g.lineTo(a2[0], a2[1]); g.stroke();
        var ux = a2[0] - a1[0], uy = a2[1] - a1[1], L = Math.hypot(ux, uy) || 1; ux /= L; uy /= L;
        [[a1, 1], [a2, -1]].forEach(function (f) {  // flechas de 8 px
          var o = f[0], s = f[1]; g.beginPath(); g.moveTo(o[0], o[1]);
          g.lineTo(o[0] + s * 8 * ux - 2.5 * uy, o[1] + s * 8 * uy + 2.5 * ux); g.lineTo(o[0] + s * 8 * ux + 2.5 * uy, o[1] + s * 8 * uy - 2.5 * ux); g.closePath(); g.fill();
        });
        var t = e.txt && e.txt !== '<>' ? e.txt.replace('<>', fmt(G.m)) : fmt(G.m);
        g.save(); g.translate((a1[0] + a2[0]) / 2, (a1[1] + a2[1]) / 2); var an = Math.atan2(uy, ux); if (an > Math.PI / 2 || an < -Math.PI / 2) an += Math.PI;
        g.rotate(an); g.font = '12px "Segoe UI",Arial,sans-serif'; g.textAlign = 'center'; g.textBaseline = 'bottom'; g.fillText(t, 0, -3); g.restore(); break;
      case 'RAW':
        var s0 = segs(e); g.beginPath(); s0.forEach(function (s) { var u = aPant(s[0]), v = aPant(s[1]); g.moveTo(u[0], u[1]); g.lineTo(v[0], v[1]); }); g.stroke(); break;
    }
  }
  // cotas angular, de radio y de diámetro: medida y dibujo
  function cotaAng(e) {                 // arco de cota: empieza en t0 y barre dt (antihorario) por el lado de d
    var a1 = ang(e.v, e.p1), a2 = ang(e.v, e.p2), ad = ang(e.v, e.d);
    return norm(ad - a1) <= norm(a2 - a1) ? { t0: a1, dt: norm(a2 - a1), R: dist(e.v, e.d) } : { t0: a2, dt: norm(a1 - a2), R: dist(e.v, e.d) };
  }
  function medidaCota(e) {
    if (e.k === 'ang') return cotaAng(e).dt * 180 / Math.PI;
    if (e.k === 'rad') return dist(e.c, e.p);
    if (e.k === 'dia') return dist(e.p1, e.p2);
    return cotaGeo(e).m;
  }
  function textoCota(e) {
    var m = medidaCota(e), s = e.k === 'ang' ? (Math.round(m * 100) / 100) + '°' : (e.k === 'rad' ? 'R' : e.k === 'dia' ? 'Ø' : '') + fmt(m);
    return e.txt && e.txt !== '<>' ? e.txt.replace('<>', s) : s;
  }
  function flecha(g, o, ux, uy) {       // punta en o, hacia (ux, uy) en pantalla; 8 px
    g.beginPath(); g.moveTo(o[0], o[1]); g.lineTo(o[0] - 8 * ux - 2.5 * uy, o[1] - 8 * uy + 2.5 * ux); g.lineTo(o[0] - 8 * ux + 2.5 * uy, o[1] - 8 * uy - 2.5 * ux); g.closePath(); g.fill();
  }
  function rotulo(g, t, x, y) { g.save(); g.font = '12px "Segoe UI",Arial,sans-serif'; g.textAlign = 'center'; g.textBaseline = 'middle'; g.fillText(t, x, y); g.restore(); }
  function trazarCota(g, e) {
    g.lineWidth = 0.9;
    if (e.k === 'ang') {
      var A = cotaAng(e), c = aPant(e.v), R = A.R * S.v.k;
      [[e.p1, ang(e.v, e.p1)], [e.p2, ang(e.v, e.p2)]].forEach(function (f) {   // líneas de referencia hasta el arco
        var r0 = dist(e.v, f[0]); if (r0 >= A.R) return; var q0 = aPant(f[0]), q1 = aPant([e.v[0] + A.R * Math.cos(f[1]), e.v[1] + A.R * Math.sin(f[1])]);
        g.beginPath(); g.moveTo(q0[0], q0[1]); g.lineTo(q1[0], q1[1]); g.stroke();
      });
      g.beginPath(); g.arc(c[0], c[1], R, -A.t0, -(A.t0 + A.dt), true); g.stroke();
      var s1 = [c[0] + R * Math.cos(A.t0), c[1] - R * Math.sin(A.t0)], s2 = [c[0] + R * Math.cos(A.t0 + A.dt), c[1] - R * Math.sin(A.t0 + A.dt)];
      flecha(g, s1, Math.sin(A.t0), Math.cos(A.t0)); flecha(g, s2, -Math.sin(A.t0 + A.dt), -Math.cos(A.t0 + A.dt));
      var tm = A.t0 + A.dt / 2; rotulo(g, textoCota(e), c[0] + (R + 12) * Math.cos(tm), c[1] - (R + 12) * Math.sin(tm));
      return;
    }
    var p = aPant(e.k === 'rad' ? e.c : e.p1), q = aPant(e.k === 'rad' ? e.p : e.p2), ux = q[0] - p[0], uy = q[1] - p[1], L = Math.hypot(ux, uy) || 1; ux /= L; uy /= L;
    g.beginPath(); g.moveTo(p[0], p[1]); g.lineTo(q[0], q[1]); g.stroke();
    flecha(g, q, ux, uy); if (e.k === 'dia') flecha(g, p, -ux, -uy);
    var an = Math.atan2(uy, ux); if (an > Math.PI / 2 || an < -Math.PI / 2) an += Math.PI;
    g.save(); g.translate((p[0] + q[0]) / 2, (p[1] + q[1]) / 2); g.rotate(an); g.font = '12px "Segoe UI",Arial,sans-serif'; g.textAlign = 'center'; g.textBaseline = 'bottom'; g.fillText(textoCota(e), 0, -3); g.restore();
  }
  function marca(g, s) {                // marcador de OSNAP (formas de AutoCAD) + su nombre
    var p = aPant(s.p), r = 6; g.save(); g.strokeStyle = S.cMarca; g.lineWidth = 2; g.beginPath();
    switch (s.modo) {
      case 'fin': g.rect(p[0] - r, p[1] - r, 2 * r, 2 * r); break;
      case 'medio': g.moveTo(p[0], p[1] - r); g.lineTo(p[0] + r, p[1] + r); g.lineTo(p[0] - r, p[1] + r); g.closePath(); break;
      case 'centro': g.arc(p[0], p[1], r, 0, 2 * Math.PI); break;
      case 'inter': g.moveTo(p[0] - r, p[1] - r); g.lineTo(p[0] + r, p[1] + r); g.moveTo(p[0] + r, p[1] - r); g.lineTo(p[0] - r, p[1] + r); break;
      case 'perp': g.moveTo(p[0] - r, p[1] - r); g.lineTo(p[0] - r, p[1] + r); g.lineTo(p[0] + r, p[1] + r); g.moveTo(p[0] - r, p[1]); g.lineTo(p[0], p[1]); g.lineTo(p[0], p[1] + r); break;
      case 'nodo': g.arc(p[0], p[1], r, 0, 2 * Math.PI); g.moveTo(p[0] - r, p[1] - r); g.lineTo(p[0] + r, p[1] + r); g.moveTo(p[0] + r, p[1] - r); g.lineTo(p[0] - r, p[1] + r); break;
      case 'cuad': g.moveTo(p[0], p[1] - r); g.lineTo(p[0] + r, p[1]); g.lineTo(p[0], p[1] + r); g.lineTo(p[0] - r, p[1]); g.closePath(); break;
      case 'tan': g.arc(p[0], p[1], r * 0.8, 0, 2 * Math.PI); g.moveTo(p[0] - r, p[1] - r); g.lineTo(p[0] + r, p[1] - r); break;
    }
    g.stroke();
    var nom = { fin: 'Punto final', medio: 'Punto medio', centro: 'Centro', inter: 'Intersección', perp: 'Perpendicular', nodo: 'Punto', cuad: 'Cuadrante', tan: 'Tangente' }[s.modo];
    g.font = '11px "Segoe UI",Arial,sans-serif'; var w = g.measureText(nom).width;
    g.fillStyle = S.cMarca; g.fillRect(p[0] + 10, p[1] + 10, w + 8, 16); g.fillStyle = '#111'; g.fillText(nom, p[0] + 14, p[1] + 22); g.restore();
  }
  var _raf = 0;
  function pintar() { if (!_raf) _raf = requestAnimationFrame(function () { _raf = 0; pintarYa(); }); }
  function pintarYa() {
    if (!S) return;
    var g = S.g, W = S.W, H = S.H;
    g.setTransform(S.dpr, 0, 0, S.dpr, 0, 0);
    g.fillStyle = S.cFondo; g.fillRect(0, 0, W, H);
    if (S.rejilla) {                    // rejilla de puntos (como AutoCAD clásico) y ejes por el origen
      var s = paso(), a = aMundo([0, H]), b = aMundo([W, 0]);
      g.fillStyle = S.cRej;
      for (var x = Math.ceil(a[0] / s) * s; x <= b[0]; x += s)
        for (var y = Math.ceil(a[1] / s) * s; y <= b[1]; y += s) { var q = aPant([x, y]); g.fillRect(q[0] - 0.8, q[1] - 0.8, 1.6, 1.6); }
    }
    var o = aPant([0, 0]); g.strokeStyle = S.cEje; g.lineWidth = 1; g.setLineDash([6, 4]); g.beginPath();
    g.moveTo(0, o[1]); g.lineTo(W, o[1]); g.moveTo(o[0], 0); g.lineTo(o[0], H); g.stroke(); g.setLineDash([]);
    S.ents.forEach(function (e) {
      var sel = S.sel.indexOf(e) >= 0 || (S.req && S.req.marcar && S.req.marcar.indexOf(e) >= 0);
      if (sel) { g.setLineDash([5, 3]); trazar(g, e, S.cSel, 2); g.setLineDash([]); } else trazar(g, e, colorDe(e), 1.4);
    });
    if (S.req && S.req.prev && S.cur) { g.setLineDash([4, 3]); (S.req.prev(S.cur) || []).forEach(function (e) { trazar(g, e, S.cPrev, 1.2); }); g.setLineDash([]); }
    if (S.req && S.req.base && S.cur && !S.req.prev) { var b0 = aPant(S.req.base), c0 = aPant(S.cur); g.strokeStyle = S.cPrev; g.setLineDash([4, 3]); g.beginPath(); g.moveTo(b0[0], b0[1]); g.lineTo(c0[0], c0[1]); g.stroke(); g.setLineDash([]); }
    if (S.ventana && S.q) {             // ventana (azul, continua) o captura (verde, a trazos)
      var v0 = S.ventana, cr = S.q[0] < v0[0];
      g.fillStyle = cr ? 'rgba(60,180,90,.12)' : 'rgba(60,110,220,.12)'; g.strokeStyle = cr ? '#3cb45a' : '#3c6edc';
      g.setLineDash(cr ? [5, 3] : []); g.fillRect(v0[0], v0[1], S.q[0] - v0[0], S.q[1] - v0[1]); g.strokeRect(v0[0], v0[1], S.q[0] - v0[0], S.q[1] - v0[1]); g.setLineDash([]);
    }
    if (S.snap) marca(g, S.snap);
    if (S.pol && S.req && S.req.base && S.q) {   // rastreo polar: el rayo de alineación y su rótulo (distancia < ángulo)
      var pb = aPant(S.req.base), far = 4 * (S.W + S.H);
      g.save(); g.strokeStyle = '#2e9e4f'; g.lineWidth = 1; g.setLineDash([2, 4]); g.beginPath(); g.moveTo(pb[0], pb[1]);
      g.lineTo(pb[0] + far * Math.cos(S.pol.ang), pb[1] - far * Math.sin(S.pol.ang)); g.stroke(); g.setLineDash([]);
      var tp = 'Polar: ' + fmt(S.pol.L) + ' < ' + fmt(S.pol.ang * 180 / Math.PI) + '°', cq = aPant(S.cur);
      g.font = '11px "Segoe UI",Arial,sans-serif'; var wp = g.measureText(tp).width;
      g.fillStyle = '#2e9e4f'; g.fillRect(cq[0] + 12, cq[1] + 12, wp + 8, 16); g.fillStyle = '#fff'; g.fillText(tp, cq[0] + 16, cq[1] + 24); g.restore();
    }
    if (S.q && S.cur) {                 // mirilla: cruz + cuadro de designación
      var c = S.snap ? S.q : aPant(S.cur); g.strokeStyle = S.cFg; g.lineWidth = 1; g.beginPath();
      g.moveTo(c[0] - 22, c[1]); g.lineTo(c[0] + 22, c[1]); g.moveTo(c[0], c[1] - 22); g.lineTo(c[0], c[1] + 22); g.stroke();
      if (!S.req || S.req.t === 'sel' || S.req.t === 'obj') g.strokeRect(c[0] - PICK, c[1] - PICK, 2 * PICK, 2 * PICK);
    }
    estado();
  }

  // ------------------------------------------------------------------ designar
  function distEnt(e, w) {
    var d = Infinity;
    function dseg(a, b) { var dx = b[0] - a[0], dy = b[1] - a[1], L2 = dx * dx + dy * dy, t = L2 ? Math.max(0, Math.min(1, ((w[0] - a[0]) * dx + (w[1] - a[1]) * dy) / L2)) : 0; return Math.hypot(w[0] - a[0] - t * dx, w[1] - a[1] - t * dy); }
    segs(e).forEach(function (s) { d = Math.min(d, dseg(s[0], s[1])); });
    arcos(e).forEach(function (a) { var t = ang(a.c, w); if (enArco(a, t)) d = Math.min(d, Math.abs(dist(a.c, w) - a.r)); });
    if (e.t === 'POINT') d = Math.min(d, dist(e.p, w));
    if (e.t === 'TEXT') { var b = caja(e); if (w[0] >= b[0] && w[0] <= b[2] && w[1] >= b[1] && w[1] <= b[3]) d = 0; }
    if (e.t === 'DIMENSION' && e.k === 'ang') { var A = cotaAng(e); if (norm(ang(e.v, w) - A.t0) <= A.dt) d = Math.min(d, Math.abs(dist(e.v, w) - A.R)); }
    if (e.t === 'DIMENSION' && e.k === 'rad') d = Math.min(d, dseg(e.c, e.p));
    if (e.t === 'DIMENSION' && e.k === 'dia') d = Math.min(d, dseg(e.p1, e.p2));
    return d;
  }
  function pick(q) { return pickW(aMundo(q)); }
  function pickW(w) {                   // el objeto más cercano a w (mundo) dentro del cuadro de designación
    var tol = PICK / S.v.k, best = null, bd = Infinity;
    S.ents.forEach(function (e) { var d = distEnt(e, w); if (d <= tol && d < bd) { bd = d; best = e; } });
    return best;
  }
  function enVentana(a, b) {            // a, b en pantalla; a→b hacia la derecha = ventana, hacia la izquierda = captura
    var p = aMundo(a), q = aMundo(b), x0 = Math.min(p[0], q[0]), x1 = Math.max(p[0], q[0]), y0 = Math.min(p[1], q[1]), y1 = Math.max(p[1], q[1]);
    var cruzar = b[0] < a[0];
    return S.ents.filter(function (e) {
      var c = caja(e); if (!c) return false;
      if (!cruzar) return c[0] >= x0 && c[2] <= x1 && c[1] >= y0 && c[3] <= y1;
      if (c[2] < x0 || c[0] > x1 || c[3] < y0 || c[1] > y1) return false;
      if (c[0] >= x0 && c[2] <= x1 && c[1] >= y0 && c[3] <= y1) return true;
      var R = [[[x0, y0], [x1, y0]], [[x1, y0], [x1, y1]], [[x1, y1], [x0, y1]], [[x0, y1], [x0, y0]]];
      return segs(e).some(function (s) { return (s[0][0] >= x0 && s[0][0] <= x1 && s[0][1] >= y0 && s[0][1] <= y1) || R.some(function (r) { return interSS(s, r).length; }); }) ||
             arcos(e).some(function (a) { return R.some(function (r) { return interSA(r, a).length; }); }) || e.t === 'POINT' || e.t === 'TEXT';
    });
  }

  // ------------------------------------------------------------------ deshacer
  function foto() { return JSON.stringify({ e: S.ents, c: S.capas }); }
  function volver(f) { var o = JSON.parse(f); S.ents = o.e; S.capas = o.c; S.sel = []; }
  function agregar(e) { S.ents.push(e); S.ult = e; }
  function quitar(e) { var i = S.ents.indexOf(e); if (i >= 0) S.ents.splice(i, 1); }
  function deshacer() { if (!S.undo.length) { msg('Nada que deshacer'); return; } S.redo.push(foto()); volver(S.undo.pop()); msg('DESHACER'); marcarSucio(); pintar(); }
  function rehacer() { if (!S.redo.length) { msg('Nada que rehacer'); return; } S.undo.push(foto()); volver(S.redo.pop()); msg('REHACER'); marcarSucio(); pintar(); }
  function marcarSucio() { S.sucio = foto() !== S.original; $('.hkcad-guardar', S.raiz).classList.toggle('on', S.sucio); }

  // ------------------------------------------------------------------ órdenes (generadores: piden y reciben)
  //   {t:'punto'} → [x,y] · {t:'numero'} → número (un punto da la distancia, o el ángulo si angulo:true)
  //   {t:'texto'} → cadena · {t:'sel'} → {ids:[…]} · opciones → {kw:'C'} · Intro → null
  function* designar() {
    S.sel = [];
    for (;;) {
      var r = yield { t: 'sel', msg: 'Designe objetos (' + S.sel.length + ') o [TODO/Último] — Intro para terminar', op: ['TODO', 'ALL', 'ULTIMO', 'ÚLTIMO', 'U', 'L', 'LAST'] };
      if (r === null) break;
      if (r.kw) { if (/^(TODO|ALL)$/.test(r.kw)) S.sel = S.ents.slice(); else if (S.ult && S.ents.indexOf(S.ult) >= 0 && S.sel.indexOf(S.ult) < 0) S.sel.push(S.ult); continue; }
      (r.ids || []).forEach(function (e) { if (S.sel.indexOf(e) < 0) S.sel.push(e); });
    }
    var s = S.sel; S.sel = []; return s;
  }

  // ------------------------------------------------------------------ piezas: la entidad como tramos con parámetro
  // u ∈ [k, k+1] recorre la pieza k en el sentido de la entidad: LINE a→b · ARC a1→a2 (antihorario) · CIRCLE
  // desde 0 rad · LWPOLYLINE vértice i→i+1 (con abultamiento: dt < 0 = horario). RECORTAR, ALARGAR, DESFASE,
  // EMPALME y CHAFLÁN trabajan sobre u, así la polilínea se corta y se rehace con sus abultamientos.
  function sub(a, b) { return [a[0] - b[0], a[1] - b[1]]; }
  function cruz(a, b) { return a[0] * b[1] - a[1] * b[0]; }
  function unit(v) { var L = Math.hypot(v[0], v[1]) || 1; return [v[0] / L, v[1] / L]; }
  function piezas(e) {
    var r = [];
    if (e.t === 'LINE') r.push({ s: 1, a: e.a, b: e.b });
    else if (e.t === 'ARC') r.push({ s: 0, c: e.c, r: e.r, t0: e.a1, dt: norm(e.a2 - e.a1) || 2 * Math.PI });
    else if (e.t === 'CIRCLE') r.push({ s: 0, c: e.c, r: e.r, t0: 0, dt: 2 * Math.PI, full: true });
    else if (e.t === 'LWPOLYLINE') {
      var n = e.pts.length;
      for (var i = 0; i < (e.cerr ? n : n - 1); i++) {
        var p = e.pts[i], q = e.pts[(i + 1) % n], b = e.bul[i];
        if (!b) r.push({ s: 1, a: p, b: q });
        else { var A = bulgeArco(p, q, b); r.push({ s: 0, c: A.c, r: A.r, t0: ang(A.c, p), dt: 4 * Math.atan(b) }); }
      }
    } else if (e.t === 'RAW') segs(e).forEach(function (s) { r.push({ s: 1, a: s[0], b: s[1] }); });
    return r;
  }
  function cerrada(e) { return e.t === 'CIRCLE' || (e.t === 'LWPOLYLINE' && !!e.cerr); }
  function enPieza(P, t) { return P.s ? [P.a[0] + t * (P.b[0] - P.a[0]), P.a[1] + t * (P.b[1] - P.a[1])] : [P.c[0] + P.r * Math.cos(P.t0 + t * P.dt), P.c[1] + P.r * Math.sin(P.t0 + t * P.dt)]; }
  function tArco(P, p) {                // fracción recorrida del arco hasta el punto p (del círculo); > 1 = fuera
    var d = P.dt >= 0 ? norm(ang(P.c, p) - P.t0) : norm(P.t0 - ang(P.c, p));
    if (d > 2 * Math.PI - 1e-9) d = 0;
    return d / Math.abs(P.dt);
  }
  function puntoU(e, u) {
    var P = piezas(e), n = P.length; if (cerrada(e)) u = ((u % n) + n) % n;
    var k = Math.min(n - 1, Math.max(0, Math.floor(u + 1e-12))); return enPieza(P[k], Math.min(1, Math.max(0, u - k)));
  }
  function uDe(e, w) {                   // parámetro del punto de la entidad más cercano a w
    var P = piezas(e), best = { u: 0, d: Infinity };
    P.forEach(function (Q, k) {
      var t, d;
      if (Q.s) { var v = sub(Q.b, Q.a), L2 = v[0] * v[0] + v[1] * v[1]; t = L2 ? Math.max(0, Math.min(1, ((w[0] - Q.a[0]) * v[0] + (w[1] - Q.a[1]) * v[1]) / L2)) : 0; d = dist(enPieza(Q, t), w); }
      else { t = tArco(Q, w); if (t <= 1) d = Math.abs(dist(Q.c, w) - Q.r); else { var d0 = dist(enPieza(Q, 0), w), d1 = dist(enPieza(Q, 1), w); t = d0 < d1 ? 0 : 1; d = Math.min(d0, d1); } }
      if (d < best.d) best = { u: k + t, d: d, k: k };
    });
    return best;
  }
  function raices(a, d, c, r) {         // a + t·d sobre el círculo (c, r): los t
    var f = sub(a, c), A = d[0] * d[0] + d[1] * d[1], B = 2 * (f[0] * d[0] + f[1] * d[1]), C = f[0] * f[0] + f[1] * f[1] - r * r, D = B * B - 4 * A * C;
    if (A < 1e-24 || D < -1e-12) return [];
    D = Math.sqrt(Math.max(0, D)); return D < 1e-12 ? [-B / (2 * A)] : [(-B - D) / (2 * A), (-B + D) / (2 * A)];
  }
  function sobre(P, p) { return P.full || tArco(P, p) <= 1 + 1e-9; }
  // t sobre X donde X toca a Y (Y acotada; X también, salvo libre = su recta o su círculo enteros)
  function cortes(X, Y, libre) {
    var out = [], E = 1e-9;
    if (X.s && Y.s) {
      var d1 = sub(X.b, X.a), d2 = sub(Y.b, Y.a), den = cruz(d1, d2); if (Math.abs(den) < 1e-14) return out;
      var w = sub(Y.a, X.a), t = cruz(w, d2) / den, u = cruz(w, d1) / den;
      if (u >= -E && u <= 1 + E && (libre || (t >= -E && t <= 1 + E))) out.push(t);
    } else if (X.s) {
      raices(X.a, sub(X.b, X.a), Y.c, Y.r).forEach(function (t) { if ((libre || (t >= -E && t <= 1 + E)) && sobre(Y, enPieza(X, t))) out.push(t); });
    } else if (Y.s) {
      raices(Y.a, sub(Y.b, Y.a), X.c, X.r).forEach(function (u) { if (u < -E || u > 1 + E) return; var p = enPieza(Y, u), t = tArco(X, p); if (libre || X.full || t <= 1 + E) out.push(t); });
    } else {
      interAA({ c: X.c, r: X.r, full: true }, { c: Y.c, r: Y.r, full: true }).forEach(function (p) { if (!sobre(Y, p)) return; var t = tArco(X, p); if (libre || X.full || t <= 1 + E) out.push(t); });
    }
    return out;
  }
  function bordesDe(lista, e) { return (lista || S.ents).filter(function (b) { return b !== e && S.ents.indexOf(b) >= 0; }); }
  function uCortes(e, bordes) {         // los u donde los bordes cortan a e, ordenados y sin repetir
    var P = piezas(e), us = [];
    P.forEach(function (X, k) { bordes.forEach(function (b) { piezas(b).forEach(function (Y) { cortes(X, Y, false).forEach(function (t) { us.push(k + Math.min(1, Math.max(0, t))); }); }); }); });
    us.sort(function (a, b) { return a - b; });
    return us.filter(function (u, i) { return i === 0 || u - us[i - 1] > 1e-9; });
  }
  // el trozo [u0, u1] de e como entidad nueva (u1 puede pasar de n en una cerrada: da la vuelta)
  function trozo(e, u0, u1) {
    var o = clon(e), P = piezas(e), n = P.length;
    if (e.t === 'LINE') { o.a = puntoU(e, u0); o.b = puntoU(e, u1); return o; }
    if (e.t === 'ARC') { var A = P[0]; o.a1 = norm(A.t0 + u0 * A.dt); o.a2 = norm(A.t0 + u1 * A.dt); return o; }
    if (e.t === 'CIRCLE') { o.t = 'ARC'; o.a1 = norm(2 * Math.PI * u0); o.a2 = norm(2 * Math.PI * u1); return o; }
    var pts = [], bul = [], ua = u0;
    while (ua < u1 - 1e-12) {
      var k = Math.floor(ua + 1e-12), ub = Math.min(u1, k + 1), Q = P[((k % n) + n) % n], ta = Math.max(0, ua - k), tb = ub - k;
      pts.push(enPieza(Q, ta)); bul.push(Q.s ? 0 : Math.tan((tb - ta) * Q.dt / 4)); ua = ub;
    }
    pts.push(puntoU(e, u1)); bul.push(0);
    o.pts = pts; o.bul = bul; o.cerr = 0; return o;
  }
  function reemplazar(e, nuevos) { var i = S.ents.indexOf(e); if (i < 0) return; S.ents.splice.apply(S.ents, [i, 1].concat(nuevos)); if (nuevos.length) S.ult = nuevos[nuevos.length - 1]; }
  // RECORTAR: quita el trozo de e entre los dos cortes que rodean al punto designado
  function recortar(e, w, bordes) {
    var P = piezas(e), n = P.length; if (!n) return 'ese objeto no se puede recortar';
    var us = uCortes(e, bordesDe(bordes, e)), u0 = uDe(e, w).u;
    if (!cerrada(e)) {
      us = us.filter(function (u) { return u > 1e-9 && u < n - 1e-9; });
      var lo = null, hi = null; us.forEach(function (u) { if (u < u0) lo = u; else if (hi === null && u > u0) hi = u; });
      if (lo === null && hi === null) return 'el objeto no corta ninguna arista de corte';
      var r = []; if (lo !== null) r.push(trozo(e, 0, lo)); if (hi !== null) r.push(trozo(e, hi, n));
      reemplazar(e, r); return null;
    }
    if (us.length < 2) return 'un objeto cerrado necesita dos cortes';
    var lo2 = null, hi2 = null; us.forEach(function (u) { if (u < u0) lo2 = u; else if (hi2 === null && u > u0) hi2 = u; });
    if (lo2 === null) lo2 = us[us.length - 1] - n; if (hi2 === null) hi2 = us[0] + n;
    reemplazar(e, [trozo(e, hi2, lo2 + n)]); return null;
  }
  // ALARGAR: lleva el extremo más cercano a w hasta el primer borde que encuentre su prolongación
  function alargar(e, w, bordes) {
    var B = bordesDe(bordes, e), P = piezas(e), n = P.length;
    if (!n || cerrada(e)) return 'ese objeto no se puede alargar';
    var fin = uDe(e, w).u > n / 2, k = fin ? n - 1 : 0, X = P[k];
    if (!fin) X = X.s ? { s: 1, a: X.b, b: X.a } : { s: 0, c: X.c, r: X.r, t0: X.t0 + X.dt, dt: -X.dt };   // la pieza al revés: se alarga «su final»
    var best = null;
    B.forEach(function (b) { piezas(b).forEach(function (Y) { cortes(X, Y, true).forEach(function (t) { if (t > 1 + 1e-9 && (X.s || t * Math.abs(X.dt) < 2 * Math.PI - 1e-9) && (best === null || t < best)) best = t; }); }); });
    if (best === null) return 'la prolongación no toca ningún borde';
    var p = enPieza(X, best), o = clon(e);
    if (e.t === 'LINE') { if (fin) o.b = p; else o.a = p; }
    else if (e.t === 'ARC') { if (fin) o.a2 = norm(ang(e.c, p)); else o.a1 = norm(ang(e.c, p)); }
    else if (e.t === 'LWPOLYLINE') {
      var i = fin ? n : 0, j = fin ? n - 1 : 0;
      o.pts[i] = p; if (!P[k].s) o.bul[j] = Math.tan(best * X.dt / 4) * (fin ? 1 : -1);
    } else return 'ese objeto no se puede alargar';
    reemplazar(e, [o]); return null;
  }
  // DESFASE: copia paralela a distancia d del lado de w (líneas, arcos, círculos y polilíneas, con inglete en las esquinas)
  function desfase(e, d, w) {
    var o = clon(e);
    if (e.t === 'LINE') {
      var n0 = unit([-(e.b[1] - e.a[1]), e.b[0] - e.a[0]]), s = cruz(sub(e.b, e.a), sub(w, e.a)) >= 0 ? 1 : -1;
      o.a = [e.a[0] + s * d * n0[0], e.a[1] + s * d * n0[1]]; o.b = [e.b[0] + s * d * n0[0], e.b[1] + s * d * n0[1]]; return o;
    }
    if (e.t === 'CIRCLE' || e.t === 'ARC') { o.r = e.r + (dist(e.c, w) > e.r ? d : -d); return o.r > 1e-12 ? o : null; }
    if (e.t !== 'LWPOLYLINE') return null;
    var P = piezas(e), n = P.length, near = uDe(e, w), Q = P[near.k || 0], sg;
    if (Q.s) sg = cruz(sub(Q.b, Q.a), sub(w, Q.a)) >= 0 ? 1 : -1;
    else sg = (dist(Q.c, w) < Q.r) === (Q.dt > 0) ? 1 : -1;
    var dl = sg * d, O = P.map(function (X) {         // cada pieza desplazada dl a su IZQUIERDA
      if (X.s) { var nn = unit([-(X.b[1] - X.a[1]), X.b[0] - X.a[0]]); return { s: 1, a: [X.a[0] + dl * nn[0], X.a[1] + dl * nn[1]], b: [X.b[0] + dl * nn[0], X.b[1] + dl * nn[1]] }; }
      var r = X.r - dl * (X.dt > 0 ? 1 : -1); return r > 1e-12 ? { s: 0, c: X.c, r: r, t0: X.t0, dt: X.dt } : null;
    });
    if (O.some(function (X) { return !X; })) return null;
    function esquina(A, B) {             // vértice entre la pieza A (llega) y la B (sale)
      if (A.s && B.s) { var d1 = sub(A.b, A.a), d2 = sub(B.b, B.a); if (Math.abs(cruz(d1, d2)) > 1e-14) { var t = cruz(sub(B.a, A.a), d2) / cruz(d1, d2); return enPieza(A, t); } }
      var p = enPieza(A, 1), q = enPieza(B, 0); return [(p[0] + q[0]) / 2, (p[1] + q[1]) / 2];
    }
    var m = e.pts.length;
    o.pts = e.pts.map(function (p, i) {
      if (e.cerr) return esquina(O[(i - 1 + n) % n], O[i]);
      if (i === 0) return enPieza(O[0], 0); if (i === m - 1) return enPieza(O[n - 1], 1);
      return esquina(O[i - 1], O[i]);
    });
    return o;
  }
  function distA(e, w) { return dist(puntoU(e, uDe(e, w).u), w); }
  // EMPALME (r > 0) y CHAFLÁN (d1, d2): dos líneas, o dos tramos rectos seguidos de una polilínea
  function esquinaDe(e1, w1, e2, w2) {
    function recta(e, w) { if (e.t === 'LINE') return { a: e.a, b: e.b }; if (e.t === 'LWPOLYLINE') { var r = uDe(e, w), Q = piezas(e)[r.k]; return Q && Q.s ? { a: Q.a, b: Q.b, k: r.k } : null; } return null; }
    var A = recta(e1, w1), B = recta(e2, w2); if (!A || !B) return null;
    var d1 = sub(A.b, A.a), d2 = sub(B.b, B.a), den = cruz(d1, d2); if (Math.abs(den) < 1e-14) return { paralelas: true };
    var X = enPieza({ s: 1, a: A.a, b: A.b }, cruz(sub(B.a, A.a), d2) / den);
    function lado(R, w) {               // dirección desde X hacia el lado designado y el extremo lejano de ese lado
      var u = unit(sub(R.b, R.a)), pw = (w[0] - X[0]) * u[0] + (w[1] - X[1]) * u[1]; if (pw < 0) u = [-u[0], -u[1]];
      var fa = (R.a[0] - X[0]) * u[0] + (R.a[1] - X[1]) * u[1], fb = (R.b[0] - X[0]) * u[0] + (R.b[1] - X[1]) * u[1];
      return { u: u, F: fa >= fb ? R.a : R.b, L: Math.max(fa, fb) };
    }
    return { X: X, A: A, B: B, l1: lado(A, w1), l2: lado(B, w2) };
  }
  function redondeo(e1, w1, e2, w2, r, cha) {   // cha = [d1, d2] para CHAFLÁN
    var q = esquinaDe(e1, w1, e2, w2);
    if (!q) return 'solo líneas o tramos rectos de una polilínea';
    if (q.paralelas) return 'las líneas son paralelas';
    var X = q.X, u1 = q.l1.u, u2 = q.l2.u, phi = Math.acos(Math.max(-1, Math.min(1, u1[0] * u2[0] + u1[1] * u2[1])));
    var L1, L2; if (cha) { L1 = cha[0]; L2 = cha[1]; } else { L1 = L2 = r / Math.tan(phi / 2); }
    if (L1 > q.l1.L + 1e-9 || L2 > q.l2.L + 1e-9) return cha ? 'la distancia es mayor que la línea' : 'el radio es demasiado grande';
    var T1 = [X[0] + L1 * u1[0], X[1] + L1 * u1[1]], T2 = [X[0] + L2 * u2[0], X[1] + L2 * u2[1]];
    if (e1 === e2) {                     // misma polilínea: los dos tramos deben ser seguidos
      // la pieza i va del vértice i al i+1: si k2 = k1 + 1, el vértice común es k2 (k1 llega, k2 sale)
      var e = e1, n = e.pts.length, np = piezas(e).length, k1 = q.A.k, k2 = q.B.k, v, primeroLlega;
      if (np > 2 && k2 === (k1 + 1) % np) { v = k2; primeroLlega = true; }
      else if (np > 2 && k1 === (k2 + 1) % np) { v = k1; primeroLlega = false; }
      else return 'los dos tramos deben ser seguidos';
      if (!cha && !(r > 0)) return null;
      var Pv = e.pts[(v - 1 + n) % n], Nv = e.pts[(v + 1) % n], V = e.pts[v];
      var dPrev = unit(sub(Pv, V)), dNext = unit(sub(Nv, V)), Lp = primeroLlega ? L1 : L2, Ln = primeroLlega ? L2 : L1;
      var A1 = [V[0] + Lp * dPrev[0], V[1] + Lp * dPrev[1]], A2 = [V[0] + Ln * dNext[0], V[1] + Ln * dNext[1]], b = 0;
      if (!cha) { var giroIzq = cruz(sub(V, Pv), sub(Nv, V)) > 0; b = (giroIzq ? 1 : -1) * Math.tan((Math.PI - phi) / 4); }
      var o = clon(e), bv = o.bul[v];
      o.pts.splice(v, 1, A1, A2); o.bul.splice(v, 1, b, bv);
      reemplazar(e, [o]); return null;
    }
    var n1 = clon(e1), n2 = clon(e2);
    if (e1.t !== 'LINE' || e2.t !== 'LINE') return 'con dos objetos distintos: solo líneas';
    n1.a = q.l1.F.slice(); n1.b = T1; n2.a = q.l2.F.slice(); n2.b = T2;
    reemplazar(e1, [n1]); reemplazar(e2, [n2]);
    if (cha) { if (dist(T1, T2) > 1e-12) { var l = lin(T1, T2); l.capa = e1.capa; l.color = e1.color; agregar(l); } }
    else if (r > 0) {
      var C = [X[0] + (r / Math.sin(phi / 2)) * unit([u1[0] + u2[0], u1[1] + u2[1]])[0], X[1] + (r / Math.sin(phi / 2)) * unit([u1[0] + u2[0], u1[1] + u2[1]])[1]];
      var ar = cruz(sub(T1, C), sub(T2, C)) > 0 ? arcE(C, r, ang(C, T1), ang(C, T2)) : arcE(C, r, ang(C, T2), ang(C, T1));
      ar.capa = e1.capa; ar.color = e1.color; agregar(ar);
    }
    return null;
  }
  function* designarBordes(nombre) {    // «Designe aristas … o <seleccionar todo>»: Intro sin nada = TODO
    var r = yield { t: 'sel', msg: nombre + '  Designe aristas o <seleccionar todo>', op: ['TODO', 'ALL'] };
    if (r === null) return null;
    if (r.kw) return null;
    var sel = (r.ids || []).slice(); S.sel = sel.slice();
    for (;;) {
      var m = yield { t: 'sel', msg: 'Designe aristas (' + S.sel.length + ') — Intro para terminar' };
      if (m === null) break; (m.ids || []).forEach(function (e) { if (S.sel.indexOf(e) < 0) S.sel.push(e); });
    }
    sel = S.sel; S.sel = []; return sel;
  }
  function espejo(m1, m2) {
    var al = ang(m1, m2), u = [Math.cos(al), Math.sin(al)];
    return { alfa: al, f: function (p) { var v = sub(p, m1), s = v[0] * u[0] + v[1] * u[1]; return limpio([m1[0] + 2 * s * u[0] - v[0], m1[1] + 2 * s * u[1] - v[1]]); } };
  }
  function girarF(b, t) { var c = Math.cos(t), s = Math.sin(t); return function (p) { var v = sub(p, b); return limpio([b[0] + c * v[0] - s * v[1], b[1] + s * v[0] + c * v[1]]); }; }
  function escalaF(b, k) { return function (p) { return limpio([b[0] + k * (p[0] - b[0]), b[1] + k * (p[1] - b[1])]); }; }
  function aplicar(sel, f, rot, esc, alfa, copia) {
    return sel.map(function (e) { var o = copia ? clon(e) : e; transformar(o, f, rot, esc, alfa); if (copia) agregar(o); return o; });
  }
  function previa(sel, f, rot, esc, alfa) { return sel.map(function (e) { var o = clon(e); transformar(o, f, rot, esc, alfa); return o; }); }
  var ORDENES = {
    LINEA: function* () {
      var ini = yield { t: 'punto', msg: 'LINEA  Primer punto' }; if (!esPt(ini)) return;
      var prev = ini, hechos = [];
      for (;;) {
        var n = hechos.length;
        var r = yield { t: 'punto', msg: 'Siguiente punto o [' + (n >= 2 ? 'Cerrar/' : '') + 'Deshacer]', op: n >= 2 ? ['C', 'D', 'U'] : ['D', 'U'], base: prev, prev: function (q) { return [lin(prev, q)]; } };
        if (r === null) return;
        if (r.kw === 'C') { agregar(lin(prev, ini)); return; }
        if (r.kw === 'D' || r.kw === 'U') { if (hechos.length) { quitar(hechos.pop()); prev = hechos.length ? hechos[hechos.length - 1].b : ini; } continue; }
        var e = lin(prev, r); agregar(e); hechos.push(e); prev = r;
      }
    },
    POLILINEA: function* () {
      var p = yield { t: 'punto', msg: 'POLILINEA  Punto inicial' }; if (!esPt(p)) return;
      var pts = [p], hecho = false;
      try {
        for (;;) {
          var r = yield { t: 'punto', msg: 'Siguiente punto o [' + (pts.length >= 2 ? 'Cerrar/' : '') + 'Deshacer]', op: pts.length >= 2 ? ['C', 'D', 'U'] : ['D', 'U'], base: pts[pts.length - 1], prev: function (q) { return [poliE(pts.concat([q]), false)]; } };
          if (r === null) break;
          if (r.kw === 'C') { if (pts.length >= 2) { agregar(poliE(pts, true)); hecho = true; } return; }
          if (r.kw === 'D' || r.kw === 'U') { if (pts.length > 1) pts.pop(); continue; }
          pts.push(r);
        }
      } finally { if (!hecho && pts.length >= 2) agregar(poliE(pts, false)); }   // Esc también la deja (AutoCAD)
    },
    RECTANGULO: function* () {
      var a = yield { t: 'punto', msg: 'RECTANGULO  Primera esquina' }; if (!esPt(a)) return;
      var b = yield { t: 'punto', msg: 'Otra esquina (o @dx,dy)', base: a, sinOrto: true, prev: function (q) { return [rectE(a, q)]; } }; if (!esPt(b)) return;
      if (Math.abs(b[0] - a[0]) < 1e-12 || Math.abs(b[1] - a[1]) < 1e-12) { msg('Rectángulo nulo'); return; }
      agregar(rectE(a, b));
    },
    CIRCULO: function* () {
      var c = yield { t: 'punto', msg: 'CIRCULO  Centro' }; if (!esPt(c)) return;
      var r = yield { t: 'numero', msg: 'Radio o [Diámetro]', op: ['D'], base: c, sinOrto: true, prev: function (q) { return [circE(c, dist(c, q))]; } };
      if (r && r.kw === 'D') { r = yield { t: 'numero', msg: 'Diámetro', base: c, sinOrto: true, prev: function (q) { return [circE(c, dist(c, q) / 2)]; } }; if (typeof r === 'number') r /= 2; }
      if (typeof r !== 'number' || !(r > 0)) return;
      agregar(circE(c, r));
    },
    ARCO: function* () {
      var r = yield { t: 'punto', msg: 'ARCO  Punto inicial o [Centro]', op: ['C', 'CE'] };
      if (r && r.kw) {
        var c = yield { t: 'punto', msg: 'Centro del arco' }; if (!esPt(c)) return;
        var s = yield { t: 'punto', msg: 'Punto inicial del arco', base: c, sinOrto: true }; if (!esPt(s)) return;
        var R = dist(c, s), a1 = ang(c, s);
        var f = yield { t: 'punto', msg: 'Punto final del arco (antihorario)', base: c, sinOrto: true, prev: function (q) { return [arcE(c, R, a1, ang(c, q))]; } }; if (!esPt(f)) return;
        agregar(arcE(c, R, a1, ang(c, f))); return;
      }
      if (!esPt(r)) return;
      var p1 = r, p2 = yield { t: 'punto', msg: 'Segundo punto del arco', base: p1 }; if (!esPt(p2)) return;
      var p3 = yield { t: 'punto', msg: 'Punto final del arco', base: p2, sinOrto: true, prev: function (q) { var a = arco3(p1, p2, q); return a ? [a] : [lin(p1, q)]; } }; if (!esPt(p3)) return;
      var a = arco3(p1, p2, p3); if (!a) { msg('Los tres puntos están alineados'); return; } agregar(a);
    },
    PUNTO: function* () { var p = yield { t: 'punto', msg: 'PUNTO  Precise un punto' }; if (esPt(p)) agregar(nueva('POINT', { p: p })); },
    TEXTO: function* () {
      var p = yield { t: 'punto', msg: 'TEXTO  Punto inicial del texto' }; if (!esPt(p)) return;
      var h = yield { t: 'numero', msg: 'Altura <' + fmt(S.th) + '>', base: p, sinOrto: true }; if (h === null) h = S.th; if (typeof h !== 'number' || !(h > 0)) return; S.th = h;
      var a = yield { t: 'numero', msg: 'Ángulo de rotación <0>', base: p, angulo: true }; if (a === null) a = 0; if (typeof a !== 'number') return;
      var s = yield { t: 'texto', msg: 'Texto' }; if (!s) return;
      agregar(nueva('TEXT', { p: p, h: h, s: s, rot: a * Math.PI / 180 }));
    },
    COTA: function* (alin) {
      var p1 = yield { t: 'punto', msg: (alin ? 'COTA ALINEADA' : 'COTA') + '  Origen de la primera línea de referencia' }; if (!esPt(p1)) return;
      var p2 = yield { t: 'punto', msg: 'Origen de la segunda línea de referencia', base: p1 }; if (!esPt(p2)) return;
      var modo = alin ? 'A' : null;
      for (;;) {
        var r = yield { t: 'punto', msg: 'Posición de la línea de cota' + (alin ? '' : ' o [Horizontal/Vertical/Alineada]'), op: alin ? [] : ['H', 'V', 'A'], sinOrto: true, prev: function (q) { return [cotaE(p1, p2, q, modo)]; } };
        if (r && r.kw) { modo = r.kw; continue; }
        if (!esPt(r)) return;
        agregar(cotaE(p1, p2, r, modo)); return;
      }
    },
    BORRAR: function* () {
      var sel = S.sel.length ? S.sel.slice() : yield* designar(); S.sel = [];
      sel.forEach(quitar); msg(sel.length + (sel.length === 1 ? ' objeto borrado' : ' objetos borrados'));
    },
    MOVER: function* () {
      var sel = S.sel.length ? S.sel.slice() : yield* designar(); S.sel = [];
      if (!sel.length) return;
      var b = yield { t: 'punto', msg: 'Punto base o desplazamiento', marcar: sel }; if (!esPt(b)) return;
      var q = yield { t: 'punto', msg: 'Segundo punto o <usar el primer punto como desplazamiento>', base: b, marcar: sel,
        prev: function (p) { return sel.map(function (e) { var c = clon(e); trasladar(c, [p[0] - b[0], p[1] - b[1]]); return c; }); } };
      var v = q === null ? b : (esPt(q) ? [q[0] - b[0], q[1] - b[1]] : null); if (!v) return;
      sel.forEach(function (e) { trasladar(e, v); });
    },
    // COPIAR (CO): varias copias seguidas (COPYMODE múltiple de AutoCAD); Intro en la primera = desplazamiento
    COPIAR: function* () {
      var sel = S.sel.length ? S.sel.slice() : yield* designar(); S.sel = [];
      if (!sel.length) return;
      var b = yield { t: 'punto', msg: 'Punto base o <desplazamiento>', marcar: sel }; if (!esPt(b)) return;
      var hechas = 0;
      for (;;) {
        var q = yield { t: 'punto', msg: hechas ? 'Segundo punto o [Salir/desHacer] <Salir>' : 'Segundo punto o <usar el primer punto como desplazamiento>', op: hechas ? ['S', 'H'] : [], base: b, marcar: sel,
          prev: function (p) { return sel.map(function (e) { var c = clon(e); trasladar(c, [p[0] - b[0], p[1] - b[1]]); return c; }); } };
        if (q && q.kw === 'H') { if (hechas) { for (var i = 0; i < sel.length; i++) S.ents.pop(); hechas--; } continue; }
        if (q === null && !hechas) { sel.forEach(function (e) { var c = clon(e); trasladar(c, b); agregar(c); }); return; }
        if (!esPt(q)) return;
        sel.forEach(function (e) { var c = clon(e); trasladar(c, [q[0] - b[0], q[1] - b[1]]); agregar(c); }); hechas++;
      }
    },
    // GIRAR (RO): ángulo en grados (antihorario) o con el cursor; [Copia/Referencia]
    GIRAR: function* () {
      var sel = S.sel.length ? S.sel.slice() : yield* designar(); S.sel = [];
      if (!sel.length) return;
      var b = yield { t: 'punto', msg: 'GIRAR  Punto base', marcar: sel }; if (!esPt(b)) return;
      var copia = false, a;
      for (;;) {
        a = yield { t: 'numero', msg: 'Ángulo de rotación o [Copia/Referencia] <0>', op: ['C', 'R'], base: b, angulo: true, marcar: sel,
          prev: function (p) { var t = ang(b, p); return previa(sel, girarF(b, t), t, 1); } };
        if (a && a.kw === 'C') { copia = !copia; msg(copia ? 'Girando una copia de los objetos designados.' : 'Girando los objetos designados.'); continue; }
        if (a && a.kw === 'R') {
          var r0 = yield { t: 'numero', msg: 'Ángulo de referencia <0>', base: b, angulo: true }; if (r0 === null) r0 = 0; if (typeof r0 !== 'number') return;
          var r1 = yield { t: 'numero', msg: 'Ángulo nuevo', base: b, angulo: true }; if (typeof r1 !== 'number') return;
          a = r1 - r0;
        }
        break;
      }
      if (a === null) a = 0; if (typeof a !== 'number') return;
      var t = a * Math.PI / 180; aplicar(sel, girarF(b, t), t, 1, undefined, copia);
    },
    // ESCALA (SC): factor tecleado o la distancia base → cursor; [Copia/Referencia]
    ESCALA: function* () {
      var sel = S.sel.length ? S.sel.slice() : yield* designar(); S.sel = [];
      if (!sel.length) return;
      var b = yield { t: 'punto', msg: 'ESCALA  Punto base', marcar: sel }; if (!esPt(b)) return;
      var copia = false, k;
      for (;;) {
        k = yield { t: 'numero', msg: 'Factor de escala o [Copia/Referencia]', op: ['C', 'R'], base: b, sinOrto: true, marcar: sel,
          prev: function (p) { var f = dist(b, p) || 1e-9; return previa(sel, escalaF(b, f), 0, f); } };
        if (k && k.kw === 'C') { copia = !copia; msg(copia ? 'Escalando una copia de los objetos designados.' : 'Escalando los objetos designados.'); continue; }
        if (k && k.kw === 'R') {
          var l0 = yield { t: 'numero', msg: 'Longitud de referencia <1>', base: b, sinOrto: true }; if (l0 === null) l0 = 1; if (!(l0 > 0)) return;
          var l1 = yield { t: 'numero', msg: 'Longitud nueva', base: b, sinOrto: true }; if (!(l1 > 0)) return;
          k = l1 / l0;
        }
        break;
      }
      if (typeof k !== 'number' || !(k > 0)) return;
      aplicar(sel, escalaF(b, k), 0, k, undefined, copia);
    },
    // SIMETRÍA (MI): dos puntos de la línea de simetría; ¿borrar los de origen? <No>
    SIMETRIA: function* () {
      var sel = S.sel.length ? S.sel.slice() : yield* designar(); S.sel = [];
      if (!sel.length) return;
      var m1 = yield { t: 'punto', msg: 'SIMETRÍA  Primer punto de la línea de simetría', marcar: sel }; if (!esPt(m1)) return;
      var m2 = yield { t: 'punto', msg: 'Segundo punto de la línea de simetría', base: m1, marcar: sel,
        prev: function (p) { if (dist(m1, p) < 1e-12) return []; var E = espejo(m1, p); return previa(sel, E.f, 0, 1, E.alfa); } };
      if (!esPt(m2) || dist(m1, m2) < 1e-12) return;
      var bo = yield { t: 'punto', msg: '¿Borrar los objetos de origen? [Sí/No] <No>', op: ['S', 'N', 'SI', 'SÍ', 'Y'], marcar: sel };
      var E = espejo(m1, m2), borra = bo && /^(S|SI|SÍ|Y)$/.test(bo.kw || '');
      aplicar(sel, E.f, 0, 1, E.alfa, !borra);
    },
    // DESFASE (O / EQ): distancia (o punto a atravesar) y, en bucle: objeto → lado
    DESFASE: function* () {
      var d = yield { t: 'numero', msg: 'DESFASE  Distancia o [Punto a atravesar] <' + (S.desf > 0 ? fmt(S.desf) : 'Punto a atravesar') + '>', op: ['P', 'A'] };
      var pasa = false;
      if (d === null) { if (S.desf > 0) d = S.desf; else pasa = true; }
      else if (d.kw) pasa = true;
      else if (!(d > 0)) return;
      if (!pasa) S.desf = d;
      for (;;) {
        var o = yield { t: 'obj', msg: 'Designe el objeto a desplazar o [Salir] <Salir>', op: ['S'] };
        if (!o || o.kw) return;
        var e = o.e, q = yield { t: 'punto', msg: pasa ? 'Punto por el que pasa la copia' : 'Punto en el lado del desfase', marcar: [e],
          prev: function (p) { var c = desfase(e, pasa ? distA(e, p) : d, p); return c ? [c] : []; } };
        if (!esPt(q)) return;
        var c = desfase(e, pasa ? distA(e, q) : d, q);
        if (c) agregar(c); else msg('No se puede desfasar ese objeto a esa distancia.');
      }
    },
    // RECORTAR (TR): aristas de corte (Intro = todas) y, en bucle, el trozo a quitar
    RECORTAR: function* () {
      S.pila = []; var bordes = yield* designarBordes('RECORTAR');
      for (;;) {
        var o = yield { t: 'obj', msg: 'Designe el objeto a recortar o [desHacer] — Intro para terminar', op: ['H'], marcar: bordes || [] };
        if (!o) return;
        if (o.kw === 'H') { if (S.pila && S.pila.length) volver(S.pila.pop()); continue; }
        (S.pila = S.pila || []).push(foto());
        var m = recortar(o.e, o.p, bordes); if (m) { S.pila.pop(); msg('RECORTAR: ' + m + '.'); }
      }
    },
    // ALARGAR (EX): aristas contorno (Intro = todas) y, en bucle, el extremo a alargar
    ALARGAR: function* () {
      S.pila = []; var bordes = yield* designarBordes('ALARGAR');
      for (;;) {
        var o = yield { t: 'obj', msg: 'Designe el objeto a alargar (cerca del extremo) o [desHacer] — Intro para terminar', op: ['H'], marcar: bordes || [] };
        if (!o) return;
        if (o.kw === 'H') { if (S.pila && S.pila.length) volver(S.pila.pop()); continue; }
        (S.pila = S.pila || []).push(foto());
        var m = alargar(o.e, o.p, bordes); if (m) { S.pila.pop(); msg('ALARGAR: ' + m + '.'); }
      }
    },
    // EMPALME (F): [Radio/Múltiple]; radio 0 = esquina viva (alarga o recorta hasta cortarse)
    EMPALME: function* () {
      var multiple = false;
      for (;;) {
        var o1 = yield { t: 'obj', msg: 'EMPALME (radio = ' + fmt(S.radio) + ')  Designe el primer objeto o [Radio/Múltiple]', op: ['R', 'M'] };
        if (!o1) return;
        if (o1.kw === 'R') { var r = yield { t: 'numero', msg: 'Radio de empalme <' + fmt(S.radio) + '>' }; if (typeof r === 'number' && r >= 0) S.radio = r; continue; }
        if (o1.kw === 'M') { multiple = true; continue; }
        var o2 = yield { t: 'obj', msg: 'Designe el segundo objeto', marcar: [o1.e] }; if (!o2 || o2.kw) return;
        var m = redondeo(o1.e, o1.p, o2.e, o2.p, S.radio, null); if (m) msg('EMPALME: ' + m + '.');
        if (!multiple) return;
      }
    },
    // CHAFLÁN (CHA): [Distancia/Múltiple]; primera distancia sobre el primer objeto
    CHAFLAN: function* () {
      var multiple = false;
      for (;;) {
        var o1 = yield { t: 'obj', msg: 'CHAFLÁN (dist1 = ' + fmt(S.cha[0]) + ', dist2 = ' + fmt(S.cha[1]) + ')  Designe la primera línea o [Distancia/Múltiple]', op: ['D', 'M'] };
        if (!o1) return;
        if (o1.kw === 'D') {
          var d1 = yield { t: 'numero', msg: 'Primera distancia de chaflán <' + fmt(S.cha[0]) + '>' }; if (d1 === null) d1 = S.cha[0]; if (!(d1 >= 0)) continue;
          var d2 = yield { t: 'numero', msg: 'Segunda distancia de chaflán <' + fmt(d1) + '>' }; if (d2 === null) d2 = d1; if (!(d2 >= 0)) continue;
          S.cha = [d1, d2]; continue;
        }
        if (o1.kw === 'M') { multiple = true; continue; }
        var o2 = yield { t: 'obj', msg: 'Designe la segunda línea', marcar: [o1.e] }; if (!o2 || o2.kw) return;
        var m = redondeo(o1.e, o1.p, o2.e, o2.p, 0, S.cha); if (m) msg('CHAFLÁN: ' + m + '.');
        if (!multiple) return;
      }
    },
    // COTA ANGULAR (DAN): dos líneas, un arco, o <vértice> y dos puntos; luego dónde va el arco de cota
    COTAANG: function* () {
      var o = yield { t: 'obj', msg: 'COTA ANGULAR  Designe un arco o una línea, o <precisar vértice>' }, v, p1, p2;
      if (o === null) {
        v = yield { t: 'punto', msg: 'Vértice del ángulo' }; if (!esPt(v)) return;
        p1 = yield { t: 'punto', msg: 'Primer punto del ángulo', base: v }; if (!esPt(p1)) return;
        p2 = yield { t: 'punto', msg: 'Segundo punto del ángulo', base: v }; if (!esPt(p2)) return;
      } else if (o.kw) return;
      else if (o.e.t === 'ARC') { v = o.e.c.slice(); p1 = enPieza(piezas(o.e)[0], 0); p2 = enPieza(piezas(o.e)[0], 1); }
      else {
        var o2 = yield { t: 'obj', msg: 'Designe la segunda línea', marcar: [o.e] }; if (!o2 || o2.kw) return;
        var q = esquinaDe(o.e, o.p, o2.e, o2.p); if (!q || q.paralelas) { msg('COTA ANGULAR: hacen falta dos líneas que se corten.'); return; }
        v = q.X; var L1 = dist(q.A.a, q.A.b), L2 = dist(q.B.a, q.B.b);
        p1 = [v[0] + L1 * q.l1.u[0], v[1] + L1 * q.l1.u[1]]; p2 = [v[0] + L2 * q.l2.u[0], v[1] + L2 * q.l2.u[1]];
        var elegir = function (d) {            // el sector (de los cuatro) donde cae el arco de cota, como AutoCAD
          var best = null;
          [[1, 1], [1, -1], [-1, 1], [-1, -1]].forEach(function (s) {
            var a = [v[0] + s[0] * (p1[0] - v[0]), v[1] + s[0] * (p1[1] - v[1])], b = [v[0] + s[1] * (p2[0] - v[0]), v[1] + s[1] * (p2[1] - v[1])];
            var t1 = ang(v, a), t2 = ang(v, b); if (norm(t2 - t1) > Math.PI) { var x = a; a = b; b = x; x = t1; t1 = t2; t2 = x; }
            if (norm(ang(v, d) - t1) <= norm(t2 - t1) + 1e-12) best = [a, b];
          });
          return best || [p1, p2];
        };
      }
      var mk = function (d) { var pp = elegir ? elegir(d) : [p1, p2]; return nueva('DIMENSION', { k: 'ang', v: v.slice(), p1: pp[0].slice(), p2: pp[1].slice(), d: d.slice(), txt: '' }); };
      var d = yield { t: 'punto', msg: 'Posición del arco de cota', sinOrto: true, prev: function (x) { return dist(x, v) > 1e-12 ? [mk(x)] : []; } };
      if (!esPt(d) || dist(d, v) < 1e-12) return;
      agregar(mk(d));
    },
    // COTA RADIO (DRA) / DIÁMETRO (DDI): círculo o arco, y la posición de la línea de cota
    COTARAD: function* (dia) {
      var o = yield { t: 'obj', msg: (dia ? 'COTA DIÁMETRO' : 'COTA RADIO') + '  Designe un arco o un círculo' };
      if (!o || o.kw) return;
      if (o.e.t !== 'CIRCLE' && o.e.t !== 'ARC') { msg('Designe un arco o un círculo.'); return; }
      var c = o.e.c, r = o.e.r;
      var mk = function (x) {
        var u = unit(sub(x, c)), p = [c[0] + r * u[0], c[1] + r * u[1]], L = Math.max(0, dist(c, x) - r);
        return dia ? nueva('DIMENSION', { k: 'dia', p1: [c[0] - r * u[0], c[1] - r * u[1]], p2: p, L: L, txt: '' }) : nueva('DIMENSION', { k: 'rad', c: c.slice(), p: p, L: L, txt: '' });
      };
      var x = yield { t: 'punto', msg: 'Posición de la línea de cota', sinOrto: true, prev: function (q) { return dist(q, c) > 1e-12 ? [mk(q)] : []; } };
      if (!esPt(x) || dist(x, c) < 1e-12) return;
      agregar(mk(x));
    },
    // EDITAR TEXTO (ED, doble clic): el texto o la cota se editan EN SU SITIO; en una cota, <> = la medida
    EDITAR: function* (pre) {
      var e = pre;
      if (!e) { var o = yield { t: 'obj', msg: 'EDITAR  Designe un texto o una cota' }; if (!o || o.kw) return; e = o.e; }
      if (e.t !== 'TEXT' && e.t !== 'DIMENSION') { msg('Designe un texto o una cota.'); return; }
      var ov = editorEnSitio(e, e.t === 'TEXT' ? e.s : (e.txt || '<>'));
      try {
        var s = yield { t: 'texto', msg: 'Texto nuevo (' + (e.t === 'TEXT' ? 'Intro vacío = sin cambios' : '<> = la medida') + ')', marcar: [e] };
        if (s === null || s === undefined) return;
        if (e.t === 'TEXT') { if (s.length) e.s = s; } else e.txt = s === '<>' ? '' : s;
      } finally { ov.remove(); }
    },
    POLAR: function* () {
      var a = yield { t: 'numero', msg: 'RASTREO POLAR  Incremento de ángulo (grados) <' + fmt(S.polarAng) + '>' };
      if (typeof a === 'number' && a > 0 && a <= 180) S.polarAng = a;
      S.polar = true; S.orto = false; barra();
    },
    CAPA: function* () {
      var n = yield { t: 'texto', msg: 'CAPA  Nombre de la capa actual <' + S.capa + '>', una: true }; if (!n) return;
      n = n.trim().replace(/[<>\/\\":;?*|=`]/g, '_'); if (!n) return;
      if (!capaDe(n)) {
        var c = yield { t: 'texto', msg: 'Capa nueva «' + n + '»: color (1-255 o nombre) <7>', una: true };
        S.capas.push({ n: n, c: aci(c) || 7 });
      }
      S.capa = capaDe(n).n; barra();
    },
    COLOR: function* () {
      var c = yield { t: 'texto', msg: 'COLOR  Color actual (PORCAPA, 1-255 o nombre) <' + (S.color === 256 ? 'PORCAPA' : S.color) + '>', una: true }; if (!c) return;
      S.color = /^(PORCAPA|BYLAYER|CAPA)$/i.test(c.trim()) ? 256 : (aci(c) || S.color); barra();
    },
    REJILLA: function* () {
      var r = yield { t: 'numero', msg: 'REJILLA  Separación <' + fmt(S.rej) + '>' }; if (typeof r === 'number' && r > 0) { S.rej = r; barra(); }
    },
    ZOOM: function* () {
      var r = yield { t: 'texto', msg: 'ZOOM  [Extensión/Ampliar/Reducir] <Extensión>', una: true };
      if (/^(A|AMPLIAR|\+)/i.test(r || '')) zoomEn([S.W / 2, S.H / 2], 1.5); else if (/^(R|REDUCIR|-)/i.test(r || '')) zoomEn([S.W / 2, S.H / 2], 1 / 1.5); else encuadre();
    },
  };
  var ALIAS = { L: 'LINEA', LINE: 'LINEA', LINEA: 'LINEA', 'LÍNEA': 'LINEA', PL: 'POLILINEA', PLINE: 'POLILINEA', POL: 'POLILINEA', POLILINEA: 'POLILINEA',
    REC: 'RECTANGULO', RECTANG: 'RECTANGULO', RECTANGULO: 'RECTANGULO', 'RECTÁNGULO': 'RECTANGULO', C: 'CIRCULO', CIRCLE: 'CIRCULO', CIRCULO: 'CIRCULO', 'CÍRCULO': 'CIRCULO',
    A: 'ARCO', ARC: 'ARCO', ARCO: 'ARCO', PO: 'PUNTO', POINT: 'PUNTO', PUNTO: 'PUNTO', T: 'TEXTO', DT: 'TEXTO', TEXT: 'TEXTO', TEXTO: 'TEXTO',
    DIM: 'COTA', DLI: 'COTA', DIMLINEAR: 'COTA', COTA: 'COTA', DAL: 'COTAA', DIMALIGNED: 'COTAA',
    E: 'BORRAR', ERASE: 'BORRAR', BORRAR: 'BORRAR', SUPR: 'BORRAR', M: 'MOVER', MOVE: 'MOVER', MOVER: 'MOVER', DESPLAZA: 'MOVER',
    U: 'DESHACER', DESHACER: 'DESHACER', UNDO: 'DESHACER', REDO: 'REHACER', REHACER: 'REHACER',
    LA: 'CAPA', CAPA: 'CAPA', LAYER: 'CAPA', COL: 'COLOR', COLOR: 'COLOR', REJ: 'REJILLA', GRID: 'REJILLA', REJILLA: 'REJILLA', FORZC: 'REJILLA', SNAP: 'REJILLA',
    Z: 'ZOOM', ZOOM: 'ZOOM', GUARDAR: 'GUARDAR', SAVE: 'GUARDAR', QSAVE: 'GUARDAR',
    CO: 'COPIAR', CP: 'COPIAR', COPY: 'COPIAR', COPIA: 'COPIAR', COPIAR: 'COPIAR',
    RO: 'GIRAR', ROTATE: 'GIRAR', GIRA: 'GIRAR', GIRAR: 'GIRAR', SC: 'ESCALA', SCALE: 'ESCALA', ESCALA: 'ESCALA',
    MI: 'SIMETRIA', MIRROR: 'SIMETRIA', SIMETRIA: 'SIMETRIA', 'SIMETRÍA': 'SIMETRIA',
    O: 'DESFASE', OFFSET: 'DESFASE', EQ: 'DESFASE', EQUIDIST: 'DESFASE', DESFASE: 'DESFASE',
    TR: 'RECORTAR', TRIM: 'RECORTAR', RECORTA: 'RECORTAR', RECORTAR: 'RECORTAR', EX: 'ALARGAR', EXTEND: 'ALARGAR', ALARGA: 'ALARGAR', ALARGAR: 'ALARGAR',
    F: 'EMPALME', FILLET: 'EMPALME', EMPALME: 'EMPALME', CHA: 'CHAFLAN', CHAMFER: 'CHAFLAN', CHAFLAN: 'CHAFLAN', 'CHAFLÁN': 'CHAFLAN',
    DAN: 'COTAANG', DIMANGULAR: 'COTAANG', ACOANG: 'COTAANG', DRA: 'COTARAD', DIMRADIUS: 'COTARAD', ACORADIO: 'COTARAD',
    DDI: 'COTADIA', DIMDIAMETER: 'COTADIA', ACODIAM: 'COTADIA',
    ED: 'EDITAR', DDEDIT: 'EDITAR', TEXTEDIT: 'EDITAR', EDITAR: 'EDITAR', POLAR: 'POLAR', DSETTINGS: 'POLAR' };
  var NOMBRES = { rojo: 1, amarillo: 2, verde: 3, cian: 4, azul: 5, magenta: 6, blanco: 7, negro: 7, gris: 8, 'gris-claro': 9, naranja: 30 };
  function aci(s) { s = String(s || '').trim().toLowerCase(); if (!s) return 0; if (NOMBRES[s]) return NOMBRES[s]; var n = parseInt(s, 10); return n >= 1 && n <= 255 ? n : 0; }

  function orden(nom, arg) {
    var o = ALIAS[String(nom).toUpperCase()];
    if (!o) { msg('Orden desconocida «' + nom + '». Pulse F1 o mire la barra de herramientas.'); return; }
    S.ultOrden = nom.toUpperCase();
    if (o === 'DESHACER') { eco('U'); deshacer(); return; }
    if (o === 'REHACER') { eco('REHACER'); rehacer(); return; }
    if (o === 'GUARDAR') { guardar(); return; }
    eco(nom.toUpperCase());
    S.antes = foto();
    S.cmd = o === 'COTAA' ? ORDENES.COTA(true) : o === 'COTADIA' ? ORDENES.COTARAD(true) : ORDENES[o](arg);
    avanzar(undefined);
    barra();
  }
  function avanzar(resp) {
    var r;
    try { r = S.cmd.next(resp); } catch (ex) { msg('⚠ ' + ex.message); r = { done: true }; }
    if (r.done) terminar(); else { S.req = r.value; prompt(); }
    if (S.q) S.cur = cursor(S.q);
    pintar();
  }
  function terminar() {
    S.cmd = null; S.req = null; S.ventana = null;
    if (S.antes && S.antes !== foto()) { S.undo.push(S.antes); S.redo = []; }
    S.antes = null; marcarSucio(); prompt(); barra();
  }
  function cancelar() {
    if (S.cmd) { try { S.cmd.return(); } catch (e) { } eco('*Cancelar*'); terminar(); }
    S.sel = []; S.ventana = null; pintar();
  }

  // ------------------------------------------------------------------ línea de órdenes
  function leer(txt) {               // lo tecleado → respuesta para la petición actual
    var req = S.req, s = txt.trim(), U = s.toUpperCase();
    if (req.t === 'texto') return txt;
    if (req.op && req.op.indexOf(U) >= 0) return { kw: U };
    if (req.op && U.length >= 2 && /^[A-ZÁÉÍÓÚ]+$/.test(U)) { for (var i = 0; i < req.op.length; i++) if (req.op[i].indexOf(U) === 0) return { kw: req.op[i] }; }   // «CE» → CENTRO…
    var N = '([-+]?(?:\\d+\\.?\\d*|\\.\\d+)(?:[eE][-+]?\\d+)?)', m;
    if ((m = new RegExp('^(@?)\\s*' + N + '\\s*,\\s*' + N + '$').exec(s))) {
      var p = [+m[2], +m[3]]; if (m[1]) { var b = S.ult0 || [0, 0]; p = limpio([b[0] + p[0], b[1] + p[1]]); }
      return req.t === 'numero' && req.base ? (req.angulo ? ang(req.base, p) * 180 / Math.PI : dist(req.base, p)) : (req.t === 'sel' ? null : p);
    }
    if ((m = new RegExp('^(@?)\\s*' + N + '\\s*<\\s*' + N + '$').exec(s))) {
      var o = m[1] ? (S.ult0 || [0, 0]) : [0, 0], t = +m[3] * Math.PI / 180, q = limpio([o[0] + +m[2] * Math.cos(t), o[1] + +m[2] * Math.sin(t)]);
      return req.t === 'numero' && req.base ? dist(req.base, q) : q;
    }
    if ((m = new RegExp('^' + N + '$').exec(s))) {
      var v = +m[1];
      if (req.t === 'numero') return v;
      if (req.t === 'punto' && req.base) {    // distancia directa: v en la dirección del cursor (con ORTO, la ortogonal)
        var c = S.cur || [req.base[0] + 1, req.base[1]], d = dist(req.base, c) || 1;
        return limpio([req.base[0] + v * (c[0] - req.base[0]) / d, req.base[1] + v * (c[1] - req.base[1]) / d]);
      }
    }
    return undefined;
  }
  function responder(txt) {
    var inp = S.inp;
    if (!S.cmd) {
      var t = txt.trim();
      if (!t) { if (S.ultOrden) orden(S.ultOrden); return; }   // Intro vacío repite
      orden(t.split(/\s+/)[0]);
      var resto = t.split(/\s+/).slice(1);            // «rec 0,0 @0.3,0.5» en una sola línea
      resto.forEach(function (x) { if (S.cmd) responder(x); });
      return;
    }
    if (!txt.trim() && S.req.t !== 'texto') { eco(''); avanzar(null); return; }
    if (S.req.t === 'texto' && !txt.length) { avanzar(null); return; }
    var r = leer(txt);
    if (r === undefined || r === null && txt.trim()) { msg('Punto o valor no válido: «' + txt + '»'); return; }
    if (S.req.t === 'obj' && esPt(r)) {         // x,y tecleado = designar el objeto que pasa por ese punto
      var eo = pickW(r); if (!eo) { msg('Ningún objeto en ' + fmt(r[0]) + ',' + fmt(r[1]) + '.'); inp.value = ''; return; }
      eco(txt); inp.value = ''; avanzar({ e: eo, p: r }); return;
    }
    eco(txt);
    if (esPt(r)) S.ult0 = r.slice();
    avanzar(r);
    inp.value = '';
  }
  function prompt() {
    var t = S.cmd && S.req ? S.req.msg + ':' : 'Orden:';
    $('.hkcad-prompt', S.raiz).textContent = t;
  }
  function eco(t) { var h = $('.hkcad-hist', S.raiz), p = $('.hkcad-prompt', S.raiz).textContent; linea(p + ' ' + t); }
  function msg(t) { linea(t); }
  function linea(t) { var h = $('.hkcad-hist', S.raiz); var d = el('div', null); d.textContent = t; h.appendChild(d); while (h.children.length > 60) h.removeChild(h.firstChild); h.scrollTop = h.scrollHeight; }

  // ------------------------------------------------------------------ zoom / encuadre
  function zoomEn(q, f) { var w = aMundo(q); S.v.k *= f; S.v.x0 = w[0] - q[0] / S.v.k; S.v.y0 = w[1] - (S.H - q[1]) / S.v.k; pintar(); }

  // ------------------------------------------------------------------ barra de estado
  function estado() {
    var c = S.cur || [0, 0];
    $('.hkcad-xy', S.raiz).textContent = 'x = ' + fmt(c[0]) + '   y = ' + fmt(c[1]) + '  ' + S.ud;
  }
  function barra() {
    var b = S.raiz;
    b.querySelectorAll('[data-t]').forEach(function (x) {
      var k = x.getAttribute('data-t'); x.classList.toggle('on', !!(k === 'rejilla' ? S.rejilla : k === 'forzc' ? S.forzc : k === 'orto' ? S.orto : k === 'polar' ? S.polar : S.osnapOn));
    });
    b.querySelectorAll('[data-m]').forEach(function (x) { x.checked = !!S.modos[x.getAttribute('data-m')]; });
    var sc = $('.hkcad-capa', b); sc.innerHTML = '';
    S.capas.forEach(function (c) { var o = new Option(c.n, c.n); sc.add(o); }); sc.value = S.capa;
    var co = $('.hkcad-color', b); co.value = String(S.color); if (co.value !== String(S.color)) { co.add(new Option('ACI ' + S.color, String(S.color))); co.value = String(S.color); }
    $('.hkcad-rej', b).value = fmt(S.rej);
    b.querySelectorAll('.hkcad-herr button[data-o]').forEach(function (x) { x.classList.toggle('on', !!S.cmd && S.ultOrden && ALIAS[S.ultOrden] === ALIAS[x.getAttribute('data-o')]); });
  }
  function conmuta(k) {
    // orto y polar se excluyen (como F8 / F10 en AutoCAD)
    if (k === 'rejilla') S.rejilla = !S.rejilla; else if (k === 'forzc') S.forzc = !S.forzc; else if (k === 'orto') { S.orto = !S.orto; if (S.orto) S.polar = false; }
    else if (k === 'polar') { S.polar = !S.polar; if (S.polar) S.orto = false; } else S.osnapOn = !S.osnapOn;
    var nom = { rejilla: 'Rejilla', forzc: 'Forzcursor', orto: 'Orto', polar: 'Polar', osnap: 'Refent' }[k], on = k === 'rejilla' ? S.rejilla : k === 'forzc' ? S.forzc : k === 'orto' ? S.orto : k === 'polar' ? S.polar : S.osnapOn;
    msg('<' + nom + (on ? ' act' : ' desact') + '>'); barra(); pintar();
  }

  // ------------------------------------------------------------------ guardar
  function anfitrion(m) {
    try { if (window.chrome && chrome.webview) { chrome.webview.postMessage(JSON.stringify(m)); return true; } } catch (e) { }
    try { if (window.parent && window.parent !== window) { window.parent.postMessage(m, '*'); return true; } } catch (e) { }
    return false;
  }
  function guardar() {
    if (S.cmd) cancelar();
    var txt = cuerpo();
    window.hkCadUltimo = txt;
    if (anfitrion({ hkCad: 'guardar', nombre: S.nombre, cuerpo: txt })) {
      msg('Guardado en la hoja: ' + S.ents.length + ' entidades. Recalculando…');
      S.original = foto(); marcarSucio();
    } else {                            // página suelta (HTML exportado): se muestra el texto para copiarlo
      var ta = el('textarea', 'hkcad-copia'); ta.value = '#dibujar(' + S.nombre + ')\n' + txt + '\n#fin'; S.raiz.appendChild(ta); ta.select();
      msg('Sin aplicación anfitriona: copie el bloque del recuadro a la hoja.');
    }
  }
  function cerrar() {
    if (S && S.sucio && !confirm('Hay cambios sin guardar en «' + S.nombre + '». ¿Cerrar sin guardar?')) return;
    document.removeEventListener('keydown', S.tecla, true); window.removeEventListener('resize', S.resize);
    S.raiz.remove(); document.documentElement.style.overflow = S.ovf; S = null;
    anfitrion({ hkCad: 'cerrar' });
  }

  // ------------------------------------------------------------------ la ventana
  var CSS = '.hkcad{position:fixed;inset:1.2vh 1.2vw;z-index:2147483000;display:flex;flex-direction:column;background:var(--bg,#fff);color:var(--fg,#222);border:1px solid var(--sep,#bbb);border-radius:6px;box-shadow:0 8px 40px rgba(0,0,0,.45);font:12px "Segoe UI",Arial,sans-serif;overflow:hidden}' +
    '.hkcad-velo{position:fixed;inset:0;z-index:2147482999;background:rgba(0,0,0,.35)}' +
    '.hkcad-cab{display:flex;align-items:center;gap:8px;padding:6px 10px;border-bottom:1px solid var(--sep,#ccc)}' +
    '.hkcad-cab b{font-size:13px}.hkcad-cab .hkcad-sp{flex:1}' +
    '.hkcad button{font:inherit;color:var(--fg,#222);background:transparent;border:1px solid var(--sep,#bbb);border-radius:3px;padding:3px 8px;cursor:pointer;white-space:nowrap}' +
    '.hkcad button:hover{border-color:var(--var,#1c5fbf);color:var(--var,#1c5fbf)}' +
    '.hkcad button.on{background:var(--var,#1c5fbf);border-color:var(--var,#1c5fbf);color:var(--bg,#fff)}' +
    '.hkcad-guardar.on{background:#b08a2e!important;border-color:#b08a2e!important;color:#fff!important}' +
    '.hkcad-herr{display:flex;flex-wrap:wrap;align-items:center;gap:4px;padding:5px 10px;border-bottom:1px solid var(--sep,#ccc)}' +
    '.hkcad-herr .hkcad-g{display:inline-flex;gap:3px;margin-right:8px;align-items:center}' +
    '.hkcad-herr button small{opacity:.65;margin-left:3px;font-size:10px}' +
    '.hkcad select,.hkcad input{font:inherit;color:var(--fg,#222);background:var(--bg,#fff);border:1px solid var(--sep,#bbb);border-radius:3px;padding:2px 4px}' +
    '.hkcad-lienzo{position:relative;flex:1;min-height:120px}.hkcad-lienzo canvas{position:absolute;inset:0;width:100%;height:100%;cursor:none;touch-action:none}' +
    '.hkcad-hist{height:62px;overflow:auto;padding:3px 10px;border-top:1px solid var(--sep,#ccc);font:12px Consolas,monospace;color:var(--mut,#777);white-space:pre-wrap}' +
    '.hkcad-ord{display:flex;align-items:center;gap:6px;padding:3px 10px 5px;font:13px Consolas,monospace}.hkcad-prompt{white-space:nowrap;color:var(--fg,#222)}' +
    '.hkcad-ord input{flex:1;font:13px Consolas,monospace;border:none;border-bottom:1px solid var(--sep,#bbb);border-radius:0;outline:none;background:transparent}' +
    '.hkcad-est{display:flex;flex-wrap:wrap;align-items:center;gap:4px;padding:4px 10px;border-top:1px solid var(--sep,#ccc);color:var(--mut,#777)}' +
    '.hkcad-est .hkcad-xy{font:12px Consolas,monospace;min-width:230px;color:var(--fg,#222)}.hkcad-est label{margin-right:6px;white-space:nowrap}' +
    '.hkcad-copia{position:absolute;left:10%;right:10%;top:20%;height:50%;z-index:3;font:12px Consolas,monospace}';
  var HERR = [['LINEA', 'Línea', 'L'], ['POLILINEA', 'Polilínea', 'PL'], ['RECTANGULO', 'Rectángulo', 'REC'], ['CIRCULO', 'Círculo', 'C'], ['ARCO', 'Arco', 'A'],
    ['PUNTO', 'Punto', 'PO'], ['TEXTO', 'Texto', 'T'], ['COTA', 'Cota', 'DIM'], ['COTAANG', 'Cota ∠', 'DAN'], ['COTARAD', 'Radio', 'DRA'], ['COTADIA', 'Diámetro', 'DDI'], ['|'],
    ['MOVER', 'Mover', 'M'], ['COPIAR', 'Copiar', 'CO'], ['GIRAR', 'Girar', 'RO'], ['ESCALA', 'Escala', 'SC'], ['SIMETRIA', 'Simetría', 'MI'], ['DESFASE', 'Desfase', 'O'],
    ['RECORTAR', 'Recortar', 'TR'], ['ALARGAR', 'Alargar', 'EX'], ['EMPALME', 'Empalme', 'F'], ['CHAFLAN', 'Chaflán', 'CHA'], ['EDITAR', 'Editar texto', 'ED'], ['BORRAR', 'Borrar', 'E'], ['|'],
    ['U', '↶ Deshacer', 'Ctrl+Z'], ['REHACER', '↷ Rehacer', 'Ctrl+Y']];

  function abrir(id) {
    if (S) return;
    var dat = JSON.parse(document.getElementById(id + '-cad').textContent);
    var raiz = el('div', 'hkcad'), velo = el('div', 'hkcad-velo');
    if (!document.getElementById('hkcad-css')) { var st = el('style'); st.id = 'hkcad-css'; st.textContent = CSS; document.head.appendChild(st); }
    var hb = HERR.map(function (h) { return h[0] === '|' ? '</span><span class="hkcad-g">' : '<button type="button" data-o="' + h[0] + '" title="' + h[1] + ' (' + h[2] + ')">' + h[1] + '<small>' + h[2] + '</small></button>'; }).join('');
    var cols = [['256', 'PorCapa'], ['1', 'rojo'], ['2', 'amarillo'], ['3', 'verde'], ['4', 'cian'], ['5', 'azul'], ['6', 'magenta'], ['7', 'blanco/negro'], ['8', 'gris'], ['9', 'gris claro'], ['30', 'naranja']];
    raiz.innerHTML =
      '<div class="hkcad-cab"><b>✏ Dibujar — ' + dat.nombre.replace(/[<>&]/g, '') + '</b><span style="color:var(--mut,#777)">(' + dat.ud + ')</span><span class="hkcad-sp"></span>' +
      '<button type="button" class="hkcad-enc" title="Zoom a la extensión (doble clic con la rueda)">⤢ Encuadre</button>' +
      '<button type="button" class="hkcad-guardar" title="Escribe el dibujo en la hoja como listas DXF (entmake) y recalcula">💾 Guardar en la hoja</button>' +
      '<button type="button" class="hkcad-cerrar" title="Cerrar sin guardar">✕ Cerrar</button></div>' +
      '<div class="hkcad-herr"><span class="hkcad-g">' + hb + '</span>' +
      '<span class="hkcad-g">Capa <select class="hkcad-capa"></select><button type="button" class="hkcad-nueva" title="Capa nueva (LA)">＋</button></span>' +
      '<span class="hkcad-g">Color <select class="hkcad-color">' + cols.map(function (c) { return '<option value="' + c[0] + '">' + c[1] + '</option>'; }).join('') + '</select></span></div>' +
      '<div class="hkcad-lienzo"><canvas tabindex="0"></canvas></div>' +
      '<div class="hkcad-hist"></div>' +
      '<div class="hkcad-ord"><span class="hkcad-prompt">Orden:</span><input class="hkcad-inp" spellcheck="false" autocomplete="off"></div>' +
      '<div class="hkcad-est"><span class="hkcad-xy"></span>' +
      '<button type="button" data-t="rejilla" title="F7">Rejilla</button><button type="button" data-t="forzc" title="F9: el cursor salta a la rejilla">Forzc</button>' +
      '<button type="button" data-t="orto" title="F8">Orto</button><button type="button" data-t="polar" title="F10: rastreo polar (POLAR fija el incremento)">Polar</button><button type="button" data-t="osnap" title="F3: referencia a objetos">Refent</button>' +
      '<label><input type="checkbox" data-m="fin">Final</label><label><input type="checkbox" data-m="medio">Medio</label><label><input type="checkbox" data-m="centro">Centro</label>' +
      '<label><input type="checkbox" data-m="inter">Intersección</label><label><input type="checkbox" data-m="perp">Perpendicular</label><label><input type="checkbox" data-m="nodo">Punto</label>' +
      '<label><input type="checkbox" data-m="cuad">Cuadrante</label><label><input type="checkbox" data-m="tan">Tangente</label>' +
      '<span class="hkcad-sp" style="flex:1"></span>Rejilla <input class="hkcad-rej" style="width:64px"> ' + dat.ud + '</div>';
    document.body.appendChild(velo); document.body.appendChild(raiz);
    var fondo = css('--bg', '#ffffff');
    S = { raiz: raiz, velo: velo, id: id, nombre: dat.nombre, ud: dat.ud || 'm', pal: dat.pal || {}, capas: dat.capas && dat.capas.length ? dat.capas : [{ n: '0', c: 7 }],
      ents: (dat.ents || []).map(desdePares), capa: '0', color: 256, rej: +dat.rejilla || 0, th: 0,
      rejilla: true, forzc: true, orto: false, osnapOn: true, modos: { fin: 1, medio: 1, centro: 1, inter: 1, perp: 1, nodo: 1, cuad: 1, tan: 1 },
      polar: false, polarAng: 90, desf: 0, radio: 0, cha: [0, 0],
      undo: [], redo: [], sel: [], cmd: null, req: null, v: { k: 1, x0: 0, y0: 0 }, ovf: document.documentElement.style.overflow,
      cFondo: fondo, cFg: css('--fg', '#222'), cRej: css('--mut', '#999'), cEje: css('--sep', '#ccc'), cSel: '#3c8dff', cPrev: css('--var', '#1c5fbf'), cMarca: '#e8a400' };
    if (S.capas.length > 1) { var cu = S.ents.length ? S.ents[S.ents.length - 1].capa : S.capas[S.capas.length - 1].n; if (capaDe(cu)) S.capa = capaDe(cu).n; }
    if (!(S.rej > 0)) {                 // rejilla por defecto: ~1/20 de lo dibujado, redonda (1, 2, 5 × 10ⁿ)
      var b = null; S.ents.forEach(function (e) { var c = caja(e); if (c) b = b ? [Math.min(b[0], c[0]), Math.min(b[1], c[1]), Math.max(b[2], c[2]), Math.max(b[3], c[3])] : c; });
      var L = b ? Math.max(b[2] - b[0], b[3] - b[1]) / 20 : 0.1, e10 = Math.pow(10, Math.floor(Math.log10(L || 0.1))), f = (L || 0.1) / e10;
      S.rej = (f < 1.5 ? 1 : f < 3.5 ? 2 : f < 7.5 ? 5 : 10) * e10;
    }
    S.th = S.rej;
    S.original = foto();
    document.documentElement.style.overflow = 'hidden';
    var cv = $('canvas', raiz); S.cv = cv; S.g = cv.getContext('2d'); S.inp = $('.hkcad-inp', raiz);
    S.resize = function () {
      var r = cv.getBoundingClientRect(); S.dpr = window.devicePixelRatio || 1; S.W = r.width; S.H = r.height;
      cv.width = Math.round(r.width * S.dpr); cv.height = Math.round(r.height * S.dpr); pintar();
    };
    window.addEventListener('resize', S.resize); S.resize(); encuadre();
    barra(); prompt();
    linea('Ventana de dibujo «' + S.nombre + '». Órdenes: L PL REC C A PO T · DIM DAL DAN DRA DDI · M CO RO SC MI O TR EX F CHA ED E · U REDO · LA COL REJ Z POLAR · Intro repite, Esc cancela.');
    linea('Coordenadas: x,y · @dx,dy · @d<ángulo · un número = distancia en la dirección del cursor. F3 Refent · F7 Rejilla · F8 Orto · F9 Forzc · F10 Polar. Doble clic en un texto o una cota: editarlo.');

    // --- ratón
    var pan = null;
    function qDe(ev) { var r = cv.getBoundingClientRect(); return [ev.clientX - r.left, ev.clientY - r.top]; }
    cv.addEventListener('contextmenu', function (ev) { ev.preventDefault(); });
    cv.addEventListener('pointerdown', function (ev) {
      var q = qDe(ev); cv.focus();
      if (ev.button === 1 || (ev.button === 0 && ev.shiftKey)) { pan = { q: q, x0: S.v.x0, y0: S.v.y0 }; cv.setPointerCapture(ev.pointerId); ev.preventDefault(); return; }
      if (ev.button === 2) { responder(S.inp.value); S.inp.value = ''; return; }   // clic derecho = Intro
      if (ev.button !== 0) return;
      clic(q);
    });
    cv.addEventListener('pointermove', function (ev) {
      var q = qDe(ev);
      if (pan) { S.v.x0 = pan.x0 - (q[0] - pan.q[0]) / S.v.k; S.v.y0 = pan.y0 + (q[1] - pan.q[1]) / S.v.k; pintar(); return; }
      S.q = q; S.cur = cursor(q); pintar();
    });
    cv.addEventListener('pointerup', function (ev) { if (pan) { pan = null; try { cv.releasePointerCapture(ev.pointerId); } catch (e) { } } });
    cv.addEventListener('pointerleave', function () { S.q = null; S.snap = null; pintar(); });
    cv.addEventListener('dblclick', function (ev) {
      if (ev.button === 1) { encuadre(); return; }
      if (ev.button !== 0 || S.cmd) return;
      var e = pick(qDe(ev)); if (!e || (e.t !== 'TEXT' && e.t !== 'DIMENSION')) return;
      S.sel = []; orden('ED', e);
    });
    cv.addEventListener('auxclick', function (ev) { if (ev.button === 1 && ev.detail === 2) encuadre(); });
    cv.addEventListener('wheel', function (ev) { ev.preventDefault(); zoomEn(qDe(ev), ev.deltaY < 0 ? 1.2 : 1 / 1.2); S.cur = S.q ? cursor(S.q) : S.cur; }, { passive: false });

    // --- teclado: todo va a la línea de órdenes (como AutoCAD)
    S.tecla = function (ev) {
      if (!S) return;
      var k = ev.key, inp = S.inp, enInp = document.activeElement === inp, otro = !enInp && /^(INPUT|SELECT|TEXTAREA)$/.test((document.activeElement || {}).tagName || '');
      var F = { F3: 'osnap', F7: 'rejilla', F8: 'orto', F9: 'forzc', F10: 'polar' }[k];
      if (F) { ev.preventDefault(); ev.stopPropagation(); conmuta(F); return; }
      if ((ev.ctrlKey || ev.metaKey) && /^[zZ]$/.test(k)) { ev.preventDefault(); ev.stopPropagation(); if (!S.cmd) deshacer(); return; }
      if ((ev.ctrlKey || ev.metaKey) && /^[yY]$/.test(k)) { ev.preventDefault(); ev.stopPropagation(); if (!S.cmd) rehacer(); return; }
      if ((ev.ctrlKey || ev.metaKey) && /^[sS]$/.test(k)) { ev.preventDefault(); ev.stopPropagation(); guardar(); return; }
      if (k === 'Escape') { ev.preventDefault(); ev.stopPropagation(); inp.value = ''; cancelar(); return; }
      if (otro) return;
      if (k === 'Delete' && !S.cmd && S.sel.length && !inp.value) { ev.preventDefault(); orden('E'); return; }
      var texto = S.cmd && S.req && S.req.t === 'texto' && !S.req.una;
      if (k === 'Enter' || (k === ' ' && !texto)) { ev.preventDefault(); ev.stopPropagation(); var v = inp.value; inp.value = ''; responder(v); return; }
      if (!enInp && k.length === 1 && !ev.ctrlKey && !ev.metaKey && !ev.altKey) { ev.preventDefault(); inp.value += k; inp.focus(); return; }
      if (!enInp && k === 'Backspace') { ev.preventDefault(); inp.value = inp.value.slice(0, -1); }
    };
    document.addEventListener('keydown', S.tecla, true);

    // --- botones
    raiz.addEventListener('click', function (ev) {
      var b = ev.target.closest('button'); if (!b) return;
      if (b.dataset.o) { if (S.cmd) cancelar(); orden(b.dataset.o); S.inp.focus(); }
      else if (b.dataset.t) conmuta(b.dataset.t);
      else if (b.classList.contains('hkcad-enc')) encuadre();
      else if (b.classList.contains('hkcad-guardar')) guardar();
      else if (b.classList.contains('hkcad-cerrar')) cerrar();
      else if (b.classList.contains('hkcad-nueva')) { if (S.cmd) cancelar(); orden('LA'); S.inp.focus(); }
    });
    raiz.addEventListener('change', function (ev) {
      var t = ev.target;
      if (t.dataset.m) { S.modos[t.dataset.m] = t.checked ? 1 : 0; }
      else if (t.classList.contains('hkcad-capa')) S.capa = t.value;
      else if (t.classList.contains('hkcad-color')) S.color = +t.value;
      else if (t.classList.contains('hkcad-rej')) { var r = parseFloat(t.value); if (r > 0) S.rej = r; }
      barra(); pintar(); S.inp.focus();
    });
    S.inp.focus();
    anfitrion({ hkCad: 'abrir', nombre: S.nombre });
  }
  // el cuadro de edición EN SU SITIO: encima del texto (o del rótulo de la cota), con su tamaño; Intro acepta, Esc cancela
  function editorEnSitio(e, valor) {
    var p, hpx = 14, rot = 0;
    if (e.t === 'TEXT') { p = aPant(e.p); hpx = Math.max(12, e.h * S.v.k); rot = e.rot; }
    else {
      var b = caja(e); p = aPant([(b[0] + b[2]) / 2, (b[1] + b[3]) / 2]);
      if (!e.k) { var G = cotaGeo(e); p = aPant([(G.q1[0] + G.q2[0]) / 2, (G.q1[1] + G.q2[1]) / 2]); }
    }
    var ov = el('input', 'hkcad-ensitio'); ov.value = valor; ov.spellcheck = false;
    ov.style.cssText = 'position:absolute;z-index:4;left:' + (p[0] - (e.t === 'TEXT' ? 2 : 60)) + 'px;top:' + (p[1] - hpx - 4) + 'px;font:' + hpx.toFixed(1) +
      'px "Segoe UI",Arial,sans-serif;min-width:120px;padding:1px 3px;border:1px dashed #3c8dff;background:var(--bg,#fff);color:var(--fg,#222);transform-origin:0 100%;transform:rotate(' + (-rot) + 'rad)';
    ov.style.width = Math.max(120, (valor.length + 3) * hpx * 0.6) + 'px';
    ov.addEventListener('keydown', function (ev) { if (ev.key === 'Enter') { ev.preventDefault(); ev.stopPropagation(); var v = ov.value; responder(v.length ? v : ''); } });
    $('.hkcad-lienzo', S.raiz).appendChild(ov); setTimeout(function () { ov.focus(); ov.select(); }, 0);
    return ov;
  }
  function clic(q) {
    var req = S.req;
    if (S.ventana) {                    // segunda esquina de la ventana de designación
      var ids = enVentana(S.ventana, q); S.ventana = null;
      if (S.cmd && req && req.t === 'sel') avanzar({ ids: ids });
      else { ids.forEach(function (e) { if (S.sel.indexOf(e) < 0) S.sel.push(e); }); pintar(); }
      return;
    }
    if (S.cmd && req && req.t === 'obj') {
      var eo = pick(q); if (!eo) { msg('Designe un objeto.'); return; }
      var w = aMundo(q); eco(fmt(w[0]) + ',' + fmt(w[1])); avanzar({ e: eo, p: w }); return;
    }
    if (!S.cmd || (req && req.t === 'sel')) {
      var e = pick(q);
      if (e) { if (S.cmd) avanzar({ ids: [e] }); else { var i = S.sel.indexOf(e); if (i >= 0) S.sel.splice(i, 1); else S.sel.push(e); pintar(); } }
      else S.ventana = q;
      return;
    }
    var p = cursor(q), r = p;
    if (req.t === 'numero') r = req.base ? (req.angulo ? ang(req.base, p) * 180 / Math.PI : dist(req.base, p)) : undefined;
    else if (req.t !== 'punto') return;
    if (r === undefined) return;
    eco(fmt(p[0]) + ',' + fmt(p[1]));
    S.ult0 = p.slice();
    avanzar(r);
  }

  // ------------------------------------------------------------------ API (botón de la hoja y pruebas)
  window.hkCadAbrir = abrir;
  window.hkCad = {
    abrir: abrir, cerrar: function () { if (S) { S.sucio = false; cerrar(); } }, guardar: function () { if (S) guardar(); },
    orden: function (t) { if (!S) return; t.split('\n').forEach(function (l) { responder(l); }); },
    pantalla: function (x, y) { var r = S.cv.getBoundingClientRect(), p = aPant([x, y]); return [r.left + p[0], r.top + p[1]]; },
    estado: function () { return S ? { ents: S.ents.map(aPares), capas: S.capas, orden: S.cmd ? S.req.msg : null, rej: S.rej, v: S.v } : null; },
    cuerpo: function () { return S ? cuerpo() : null; },
    // para las pruebas: medida de una cota, enganche y rastreo polar activos, y encuadrar una zona
    medida: function (i) { var e = S && S.ents[i]; return e && e.t === 'DIMENSION' ? medidaCota(e) : null; },
    enganche: function () { return S && S.snap ? S.snap.modo : null; },
    polar: function () { return S && S.pol ? S.pol.ang * 180 / Math.PI : null; },
    estadoPolar: function () { return !!(S && S.polar); },
    ver: function (x0, y0, x1, y1) { if (!S) return; var k = Math.min(S.W / (x1 - x0), S.H / (y1 - y0)); S.v = { k: k, x0: (x0 + x1) / 2 - S.W / (2 * k), y0: (y0 + y1) / 2 - S.H / (2 * k) }; pintarYa(); },
    desdePares: desdePares, aPares: aPares, entmake: entmake,
  };
})();
