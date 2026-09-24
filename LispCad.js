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
    DIMENSION: [10, 13, 14, 70, 1, 50, 42], LWPOLYLINE: [10, 42, 70, 90] };
  function desdePares(P) {
    var t = String(P[0][1]).toUpperCase(), e = { t: t, capa: '0', color: 256, x: [] }, g = {}, pts = [], bul = [];
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
        e.p1 = pt2(g[13]); e.p2 = pt2(g[14]); e.d = g[10] ? pt2(g[10]) : e.p2.slice(); e.txt = String(g[1] == null ? '' : g[1]);
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
    ['a', 'b', 'p', 'c', 'd', 'p1', 'p2'].forEach(function (k) { if (esPt(e[k])) m(e[k]); });
    if (e.pts) e.pts.forEach(m);
    e.x.forEach(function (p) { if (((p[0] >= 10 && p[0] <= 18) || p[0] === 1011) && esPt(p[1])) { p[1] = p[1].slice(); m(p[1]); } });
  }

  // segmentos, arcos y puntos notables (para OSNAP, designar y encuadre)
  function segs(e) {
    var r = [];
    if (e.t === 'LINE') r.push([e.a, e.b]);
    else if (e.t === 'LWPOLYLINE') {
      var n = e.pts.length;
      for (var i = 0; i < (e.cerr ? n : n - 1); i++) if (!e.bul[i]) r.push([e.pts[i], e.pts[(i + 1) % n]]);
    } else if (e.t === 'DIMENSION') { var g = cotaGeo(e); r.push([g.q1, g.q2]); }
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
    else if (e.t === 'DIMENSION') r.push([e.p1, 'nodo'], [e.p2, 'nodo']);
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
    else if (e.t === 'DIMENSION') { var g = cotaGeo(e); P = [e.p1, e.p2, g.q1, g.q2]; }
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
    var ORD = { fin: 0, inter: 1, medio: 2, centro: 3, nodo: 4, perp: 5 };
    cand.forEach(function (c) { if (!best || c.d < best.d - 0.5 || (Math.abs(c.d - best.d) <= 0.5 && ORD[c.modo] < ORD[best.modo])) best = c; });
    return best;
  }
  function cursor(q) {
    var req = S.req, base = req && req.base;
    S.snap = S.osnapOn && req && (req.t === 'punto' || req.t === 'numero') ? osnap(q, base) : null;
    if (S.snap) return S.snap.p.slice();
    var p = aMundo(q);
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
  function marca(g, s) {                // marcador de OSNAP (formas de AutoCAD) + su nombre
    var p = aPant(s.p), r = 6; g.save(); g.strokeStyle = S.cMarca; g.lineWidth = 2; g.beginPath();
    switch (s.modo) {
      case 'fin': g.rect(p[0] - r, p[1] - r, 2 * r, 2 * r); break;
      case 'medio': g.moveTo(p[0], p[1] - r); g.lineTo(p[0] + r, p[1] + r); g.lineTo(p[0] - r, p[1] + r); g.closePath(); break;
      case 'centro': g.arc(p[0], p[1], r, 0, 2 * Math.PI); break;
      case 'inter': g.moveTo(p[0] - r, p[1] - r); g.lineTo(p[0] + r, p[1] + r); g.moveTo(p[0] + r, p[1] - r); g.lineTo(p[0] - r, p[1] + r); break;
      case 'perp': g.moveTo(p[0] - r, p[1] - r); g.lineTo(p[0] - r, p[1] + r); g.lineTo(p[0] + r, p[1] + r); g.moveTo(p[0] - r, p[1]); g.lineTo(p[0], p[1]); g.lineTo(p[0], p[1] + r); break;
      case 'nodo': g.arc(p[0], p[1], r, 0, 2 * Math.PI); g.moveTo(p[0] - r, p[1] - r); g.lineTo(p[0] + r, p[1] + r); g.moveTo(p[0] + r, p[1] - r); g.lineTo(p[0] - r, p[1] + r); break;
    }
    g.stroke();
    var nom = { fin: 'Punto final', medio: 'Punto medio', centro: 'Centro', inter: 'Intersección', perp: 'Perpendicular', nodo: 'Punto' }[s.modo];
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
    if (S.q && S.cur) {                 // mirilla: cruz + cuadro de designación
      var c = S.snap ? S.q : aPant(S.cur); g.strokeStyle = S.cFg; g.lineWidth = 1; g.beginPath();
      g.moveTo(c[0] - 22, c[1]); g.lineTo(c[0] + 22, c[1]); g.moveTo(c[0], c[1] - 22); g.lineTo(c[0], c[1] + 22); g.stroke();
      if (!S.req || S.req.t === 'sel') g.strokeRect(c[0] - PICK, c[1] - PICK, 2 * PICK, 2 * PICK);
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
    return d;
  }
  function pick(q) {
    var w = aMundo(q), tol = PICK / S.v.k, best = null, bd = Infinity;
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
    Z: 'ZOOM', ZOOM: 'ZOOM', GUARDAR: 'GUARDAR', SAVE: 'GUARDAR', QSAVE: 'GUARDAR' };
  var NOMBRES = { rojo: 1, amarillo: 2, verde: 3, cian: 4, azul: 5, magenta: 6, blanco: 7, negro: 7, gris: 8, 'gris-claro': 9, naranja: 30 };
  function aci(s) { s = String(s || '').trim().toLowerCase(); if (!s) return 0; if (NOMBRES[s]) return NOMBRES[s]; var n = parseInt(s, 10); return n >= 1 && n <= 255 ? n : 0; }

  function orden(nom) {
    var o = ALIAS[String(nom).toUpperCase()];
    if (!o) { msg('Orden desconocida «' + nom + '». Pulse F1 o mire la barra de herramientas.'); return; }
    S.ultOrden = nom.toUpperCase();
    if (o === 'DESHACER') { eco('U'); deshacer(); return; }
    if (o === 'REHACER') { eco('REHACER'); rehacer(); return; }
    if (o === 'GUARDAR') { guardar(); return; }
    eco(nom.toUpperCase());
    S.antes = foto();
    S.cmd = o === 'COTAA' ? ORDENES.COTA(true) : ORDENES[o]();
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
      var k = x.getAttribute('data-t'); x.classList.toggle('on', !!(k === 'rejilla' ? S.rejilla : k === 'forzc' ? S.forzc : k === 'orto' ? S.orto : S.osnapOn));
    });
    b.querySelectorAll('[data-m]').forEach(function (x) { x.checked = !!S.modos[x.getAttribute('data-m')]; });
    var sc = $('.hkcad-capa', b); sc.innerHTML = '';
    S.capas.forEach(function (c) { var o = new Option(c.n, c.n); sc.add(o); }); sc.value = S.capa;
    var co = $('.hkcad-color', b); co.value = String(S.color); if (co.value !== String(S.color)) { co.add(new Option('ACI ' + S.color, String(S.color))); co.value = String(S.color); }
    $('.hkcad-rej', b).value = fmt(S.rej);
    b.querySelectorAll('.hkcad-herr button[data-o]').forEach(function (x) { x.classList.toggle('on', !!S.cmd && S.ultOrden && ALIAS[S.ultOrden] === ALIAS[x.getAttribute('data-o')]); });
  }
  function conmuta(k) {
    if (k === 'rejilla') S.rejilla = !S.rejilla; else if (k === 'forzc') S.forzc = !S.forzc; else if (k === 'orto') S.orto = !S.orto; else S.osnapOn = !S.osnapOn;
    var nom = { rejilla: 'Rejilla', forzc: 'Forzcursor', orto: 'Orto', osnap: 'Refent' }[k], on = k === 'rejilla' ? S.rejilla : k === 'forzc' ? S.forzc : k === 'orto' ? S.orto : S.osnapOn;
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
    ['PUNTO', 'Punto', 'PO'], ['TEXTO', 'Texto', 'T'], ['COTA', 'Cota', 'DIM'], ['|'], ['MOVER', 'Mover', 'M'], ['BORRAR', 'Borrar', 'E'], ['U', '↶ Deshacer', 'Ctrl+Z'], ['REHACER', '↷ Rehacer', 'Ctrl+Y']];

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
      '<button type="button" data-t="orto" title="F8">Orto</button><button type="button" data-t="osnap" title="F3: referencia a objetos">Refent</button>' +
      '<label><input type="checkbox" data-m="fin">Final</label><label><input type="checkbox" data-m="medio">Medio</label><label><input type="checkbox" data-m="centro">Centro</label>' +
      '<label><input type="checkbox" data-m="inter">Intersección</label><label><input type="checkbox" data-m="perp">Perpendicular</label><label><input type="checkbox" data-m="nodo">Punto</label>' +
      '<span class="hkcad-sp" style="flex:1"></span>Rejilla <input class="hkcad-rej" style="width:64px"> ' + dat.ud + '</div>';
    document.body.appendChild(velo); document.body.appendChild(raiz);
    var fondo = css('--bg', '#ffffff');
    S = { raiz: raiz, velo: velo, id: id, nombre: dat.nombre, ud: dat.ud || 'm', pal: dat.pal || {}, capas: dat.capas && dat.capas.length ? dat.capas : [{ n: '0', c: 7 }],
      ents: (dat.ents || []).map(desdePares), capa: '0', color: 256, rej: +dat.rejilla || 0, th: 0,
      rejilla: true, forzc: true, orto: false, osnapOn: true, modos: { fin: 1, medio: 1, centro: 1, inter: 1, perp: 1, nodo: 1 },
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
    linea('Ventana de dibujo «' + S.nombre + '». Órdenes: L PL REC C A PO T DIM DAL · M E · U REDO · LA COL REJ Z · Intro repite, Esc cancela.');
    linea('Coordenadas: x,y · @dx,dy · @d<ángulo · un número = distancia en la dirección del cursor. F3 Refent · F7 Rejilla · F8 Orto · F9 Forzc.');

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
    cv.addEventListener('dblclick', function (ev) { if (ev.button === 1) encuadre(); });
    cv.addEventListener('auxclick', function (ev) { if (ev.button === 1 && ev.detail === 2) encuadre(); });
    cv.addEventListener('wheel', function (ev) { ev.preventDefault(); zoomEn(qDe(ev), ev.deltaY < 0 ? 1.2 : 1 / 1.2); S.cur = S.q ? cursor(S.q) : S.cur; }, { passive: false });

    // --- teclado: todo va a la línea de órdenes (como AutoCAD)
    S.tecla = function (ev) {
      if (!S) return;
      var k = ev.key, inp = S.inp, enInp = document.activeElement === inp, otro = !enInp && /^(INPUT|SELECT|TEXTAREA)$/.test((document.activeElement || {}).tagName || '');
      var F = { F3: 'osnap', F7: 'rejilla', F8: 'orto', F9: 'forzc' }[k];
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
  function clic(q) {
    var req = S.req;
    if (S.ventana) {                    // segunda esquina de la ventana de designación
      var ids = enVentana(S.ventana, q); S.ventana = null;
      if (S.cmd && req && req.t === 'sel') avanzar({ ids: ids });
      else { ids.forEach(function (e) { if (S.sel.indexOf(e) < 0) S.sel.push(e); }); pintar(); }
      return;
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
    desdePares: desdePares, aPares: aPares, entmake: entmake,
  };
})();
