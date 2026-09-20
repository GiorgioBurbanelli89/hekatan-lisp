#!/usr/bin/env python
# -*- coding: utf-8 -*-
"""hkslides.py — convierte el HTML que exporta Hekatan LISP (--html) en DIAPOSITIVAS.

    python hkslides.py entrada.html salida.html [--logo logo.png] [--titulo "..."]

Cómo funciona (el porqué, no el truco):
  el --html del motor saca un documento PLANO: divs hermanos, donde `ws-h1` es el
  título y cada `ws-h2` empieza una sección. Ese "cada ws-h2" ES la diapositiva.
  El script NO toca el contenido: conserva el <head> del motor (su CSS y sus
  gráficas en base64) y solo reagrupa los divs en <section> y añade encima una
  capa de presentación (navegación, escalado, revelado por pasos).
  Así la matemática que se proyecta es EXACTAMENTE la que calculó el motor.
"""
import sys, os, re, base64, argparse

# ---------------------------------------------------------------- troceado
VOID = {"img", "br", "hr", "meta", "link", "input", "source", "col"}


def top_level_nodes(body: str):
    """Corta el body en nodos de PRIMER nivel (divs hermanos, scripts, style...).

    Hay que contar la profundidad a mano: un regex no distingue el </div> que
    cierra una matriz del que cierra el bloque. Se recorre una vez, se suma al
    abrir y se resta al cerrar; cuando la profundidad vuelve a 0, ahí termina
    un nodo hermano.
    """
    nodes, depth, start = [], 0, 0
    for m in re.finditer(r"<(/?)([a-zA-Z][a-zA-Z0-9]*)([^>]*)>", body):
        closing, name, attrs = m.group(1), m.group(2).lower(), m.group(3)
        if name in VOID or attrs.rstrip().endswith("/"):
            if depth == 0:
                nodes.append(body[start:m.end()])
                start = m.end()
            continue
        if not closing:
            if depth == 0:
                if body[start:m.start()].strip():
                    nodes.append(body[start:m.start()])
                start = m.start()
            depth += 1
        else:
            depth -= 1
            if depth <= 0:
                depth = 0
                nodes.append(body[start:m.end()])
                start = m.end()
    if body[start:].strip():
        nodes.append(body[start:])
    return nodes


def clase(node: str) -> str:
    m = re.match(r"\s*<[a-zA-Z]+[^>]*class=\"([^\"]*)\"", node)
    return m.group(1) if m else ""


def texto(node: str) -> str:
    import html as H
    return H.unescape(re.sub(r"<[^>]+>", "", node)).strip()


def trocear(body: str):
    """→ (portada, [(titulo, [bloques]), ...], colas)  — colas = scripts/styles sueltos."""
    portada, slides, colas = [], [], []
    actual = None
    for n in top_level_nodes(body):
        c = clase(n)
        raw = n.strip()
        if raw.startswith("<script") or raw.startswith("<style"):
            colas.append(n)
            continue
        if "ws-h2" in c:
            actual = (texto(n), [])
            slides.append(actual)
        elif actual is None:
            portada.append(n)
        else:
            actual[1].append(n)
    return portada, slides, colas


# ---------------------------------------------------------------- estilos
CSS = """
/* ---- capa de presentación (no toca el CSS del motor) ---- */
html,body{margin:0;padding:0;height:100%;overflow:hidden;background:#0d0f14;}
body{--slw:1600px;--slh:900px;}
#deck{position:fixed;inset:0;display:flex;align-items:center;justify-content:center;}
#stage{position:relative;width:var(--slw);height:var(--slh);transform-origin:center center;}
.slide{position:absolute;inset:0;width:var(--slw);height:var(--slh);
  background:var(--bg);color:var(--fg);border-radius:14px;
  box-shadow:0 30px 90px rgba(0,0,0,.55);
  padding:54px 74px 78px 74px;opacity:0;pointer-events:none;
  transform:translateY(26px) scale(.985);transition:opacity .34s ease, transform .34s ease;
  overflow:hidden;}
.slide.on{opacity:1;pointer-events:auto;transform:none;}
.slide.portada{display:flex;flex-direction:column;justify-content:center;text-align:center;}

/* el contenido se encoge solo si no cabe (JS mide y pone --k) */
.wrap{transform-origin:top left;}
.slide.portada .wrap{transform-origin:top center;}

/* tipografía de PROYECTOR: todo más grande que en la hoja */
.slide .ws-fmt{font-size:26px;line-height:1.5;margin:.42em 0;}
.slide .ws-eq{font-size:30px;margin:.5em 0;}
.slide .m-expr{font-size:1em;}
.slide img{max-width:100%;height:auto;}
.slide svg{max-width:880px!important;}        /* gráficas de proyector, no de hoja A4 */
.slide .hkfr svg{max-width:760px!important;}
.slide .ws-h1{font-size:54px;font-weight:700;line-height:1.15;}
.slide .ws-h2{display:none;}          /* el título va en la barra de arriba */
h2.tit{margin:0 0 26px 0;font:600 40px/1.15 'Segoe UI',system-ui,sans-serif;
  color:var(--fg);border-bottom:3px solid var(--dib-azul);padding-bottom:14px;}
h2.tit .num{color:var(--dib-azul);margin-right:.35em;}

/* revelado por pasos: lo que aún no toca, atenuado (no oculto: no salta el layout) */
.step{opacity:.08;filter:blur(1.5px);transition:opacity .3s ease, filter .3s ease;}
.step.vis{opacity:1;filter:none;}

/* cromo */
#barra{position:fixed;left:0;bottom:0;height:5px;background:var(--dib-azul);
  width:0;transition:width .3s ease;z-index:20;}
#pie{position:fixed;right:18px;bottom:12px;z-index:20;font:500 16px/1 'Segoe UI',system-ui,sans-serif;
  color:#8b93a7;letter-spacing:.04em;}
#marca{position:fixed;left:18px;bottom:10px;z-index:20;display:flex;align-items:center;gap:9px;
  font:600 15px/1 'Segoe UI',system-ui,sans-serif;color:#8b93a7;}
#marca img{height:26px;width:26px;border-radius:6px;opacity:.92;}
/* marca de agua: va ENCIMA de la diapositiva (si va detrás, el papel la tapa) */
#agua{position:fixed;inset:0;display:flex;align-items:center;justify-content:center;
  z-index:15;pointer-events:none;font:700 104px/1 'Segoe UI',system-ui,sans-serif;
  color:#171310;opacity:.04;letter-spacing:.06em;white-space:nowrap;
  transform:rotate(-16deg);}
#ayuda{position:fixed;right:18px;top:14px;z-index:20;font:500 14px/1.6 'Segoe UI',system-ui,sans-serif;
  color:#8b93a7;text-align:right;opacity:.85;}
#indice{position:fixed;inset:0;z-index:30;background:#0a0c12;color:#e8ecf5;
  display:none;padding:46px 60px;overflow:auto;
  font:400 19px/1.75 'Segoe UI',system-ui,sans-serif;}
#indice.on{display:block;}
#indice h3{font-size:26px;margin:0 0 22px 0;color:#fff;}
#indice a{display:block;color:#b9c4dc;text-decoration:none;padding:5px 10px;border-radius:7px;}
#indice a:hover{background:#1d2333;color:#fff;}
@media print{html,body{overflow:visible;height:auto;background:#fff;}
  .slide{position:relative;opacity:1;pointer-events:auto;transform:none;page-break-after:always;
         box-shadow:none;margin:0 auto 12px;}
  .step{opacity:1;filter:none;} #deck{position:static;display:block;}
  #barra,#pie,#marca,#agua,#ayuda,#indice{display:none;}}
"""

JS = """
(function(){
  var slides=[].slice.call(document.querySelectorAll('.slide'));
  var i=0, paso=0;
  var pie=document.getElementById('pie'), barra=document.getElementById('barra');

  function pasos(s){ return [].slice.call(s.querySelectorAll('.step')); }

  // ENCAJAR: la diapositiva mide 1600x900 fijos; si el contenido es más alto,
  // se encoge con scale. Medir el alto real exige que la diapositiva esté
  // visible, así que se mide con visibility oculta y luego se restaura.
  function encajar(s){
    var w=s.querySelector('.wrap'); if(!w) return;
    w.style.transform='none';
    var dispo=s.clientHeight-(s.querySelector('h2.tit')?s.querySelector('h2.tit').offsetHeight+26:0)-60;
    var alto=w.scrollHeight, ancho=w.scrollWidth, util=s.clientWidth-156;
    var k=Math.min(1, dispo/Math.max(1,alto), util/Math.max(1,ancho));
    if(k<1) w.style.transform='scale('+k.toFixed(4)+')';
  }
  function escala(){
    var st=document.getElementById('stage');
    var k=Math.min(window.innerWidth/1600, window.innerHeight/900)*0.96;
    st.style.transform='scale('+k+')';
  }
  function pinta(){
    slides.forEach(function(s,n){ s.classList.toggle('on', n===i); });
    var ps=pasos(slides[i]);
    ps.forEach(function(p,n){ p.classList.toggle('vis', n<=paso); });
    pie.textContent=(i+1)+' / '+slides.length;
    barra.style.width=((i)/(slides.length-1)*100)+'%';
    escala();
    location.hash='d'+(i+1);
  }
  function adelante(){
    var ps=pasos(slides[i]);
    if(paso<ps.length-1){ paso++; pinta(); return; }
    if(i<slides.length-1){ i++; paso=0; pinta(); }
  }
  function atras(){
    if(paso>0){ paso--; pinta(); return; }
    if(i>0){ i--; paso=pasos(slides[i]).length-1; pinta(); }
  }
  function ir(n){ i=Math.max(0,Math.min(slides.length-1,n)); paso=pasos(slides[i]).length-1; pinta(); }

  document.addEventListener('keydown',function(e){
    var idx=document.getElementById('indice');
    if(e.key==='Escape'){ idx.classList.remove('on'); return; }
    if(e.key==='o'||e.key==='O'){ idx.classList.toggle('on'); return; }
    if(idx.classList.contains('on')) return;
    if(e.key==='ArrowRight'||e.key===' '||e.key==='PageDown'||e.key==='Enter'){ e.preventDefault(); adelante(); }
    else if(e.key==='ArrowLeft'||e.key==='PageUp'||e.key==='Backspace'){ e.preventDefault(); atras(); }
    else if(e.key==='ArrowDown'){ e.preventDefault(); if(i<slides.length-1){i++;paso=0;pinta();} }
    else if(e.key==='ArrowUp'){ e.preventDefault(); if(i>0){i--;paso=0;pinta();} }
    else if(e.key==='Home'){ ir(0); }
    else if(e.key==='End'){ ir(slides.length-1); }
    else if(e.key==='t'||e.key==='T'){ document.body.classList.toggle('claro'); }
    else if(e.key==='f'||e.key==='F'){ if(!document.fullscreenElement) document.documentElement.requestFullscreen(); else document.exitFullscreen(); }
    else if(e.key==='a'||e.key==='A'){ slides[i].querySelectorAll('.step').forEach(function(p){p.classList.add('vis');}); paso=pasos(slides[i]).length-1; }
  });
  document.getElementById('deck').addEventListener('click',function(e){
    if(e.target.closest('a')) return;
    (e.clientX < window.innerWidth*0.22 ? atras : adelante)();
  });
  window.addEventListener('resize',escala);
  window.addEventListener('load',function(){
    slides.forEach(encajar);
    var h=(location.hash||'').match(/^#d(\\d+)$/);
    i=h?Math.min(slides.length-1,parseInt(h[1],10)-1):0; paso=0; pinta();
    setTimeout(function(){ slides.forEach(encajar); pinta(); },350);
  });
  window.hkIr=function(n){ document.getElementById('indice').classList.remove('on'); ir(n); };
})();
"""


def construir(html: str, logo_b64: str, titulo_pie: str) -> str:
    head = re.search(r"<head>(.*?)</head>", html, re.S).group(1)
    body = re.search(r"<body[^>]*>(.*?)</body>", html, re.S)
    body = body.group(1) if body else html[html.find("<body"):]
    portada, slides, colas = trocear(body)

    out = []
    # --- portada
    out.append('<section class="slide portada"><div class="wrap">'
               + "".join(portada) + "</div></section>")
    # --- una por ws-h2
    ind = []
    for k, (tit, bloques) in enumerate(slides, start=1):
        num, _, resto = tit.partition("·")
        if resto.strip():
            cab = ('<h2 class="tit"><span class="num">' + num.strip()
                   + "</span>" + resto.strip() + "</h2>")
        else:
            cab = '<h2 class="tit">' + tit + "</h2>"
        pasos = "".join('<div class="step">' + b + "</div>" for b in bloques)
        out.append('<section class="slide">' + cab + '<div class="wrap">'
                   + pasos + "</div></section>")
        ind.append('<a href="#" onclick="hkIr(%d);return false;">%s</a>' % (k, tit))

    marca = ('<div id="marca">'
             + ('<img alt="" src="data:image/png;base64,%s">' % logo_b64 if logo_b64 else "")
             + "<span>Hekatan Engineers</span></div>")

    return (
        "<!doctype html><html><head>" + head
        + "<style>" + CSS + "</style></head><body>"
        + '<div id="agua">Hekatan Engineers</div>'
        + '<div id="deck"><div id="stage">' + "".join(out) + "</div></div>"
        + '<div id="barra"></div>' + marca
        + '<div id="pie">1 / 1</div>'
        + '<div id="ayuda">← →  avanzar · O índice · F pantalla completa · A todo</div>'
        + '<div id="indice"><h3>' + titulo_pie + "</h3>"
        + '<a href="#" onclick="hkIr(0);return false;">Portada</a>' + "".join(ind) + "</div>"
        + "".join(colas)
        + "<script>" + JS + "</script></body></html>"
    )


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("entrada")
    ap.add_argument("salida")
    ap.add_argument("--logo", default="")
    ap.add_argument("--titulo", default="Índice")
    a = ap.parse_args()

    html = open(a.entrada, encoding="utf-8").read()
    logo = ""
    if a.logo and os.path.exists(a.logo):
        logo = base64.b64encode(open(a.logo, "rb").read()).decode("ascii")
    open(a.salida, "w", encoding="utf-8").write(construir(html, logo, a.titulo))
    n = len(re.findall(r'<section class="slide', open(a.salida, encoding="utf-8").read()))
    print("%s  ->  %s   (%d diapositivas)" % (a.entrada, a.salida, n))


if __name__ == "__main__":
    main()
