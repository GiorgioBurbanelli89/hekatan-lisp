# -*- coding: utf-8 -*-
"""Una hoja con animaciones y ventana de dibujo, comprobada en la VENTANA REAL por --ctl.

  python tests/_ctl_hoja_animada.py <exe> <hoja.lisp> <carpeta_de_salida> [cuadro ...]

Qué hace:
  1. abre la hoja como la abre el usuario (--in) y espera al reposo;
  2. cuenta los avisos (⚠) del resultado;
  3. para cada «cuadro» pedido, para TODAS las animaciones en ese cuadro y captura el resultado entero
     (en --shot y en PDF solo sale el cuadro 1: sin esto la animación no se comprueba);
  4. pulsa «Dibujar / Editar», comprueba que la ventana de dibujo se abre y que al cerrarla vuelve el editor.

La carpeta de control va DENTRO de la de salida, no en %TEMP%: el 28-sep-2026 algo vació las carpetas
temporales a mitad de una prueba.
"""
import io, json, os, re, subprocess, sys, time

sys.stdout = io.TextIOWrapper(sys.stdout.buffer, encoding="utf-8", line_buffering=True)
EXE, HOJA, SAL = (os.path.abspath(a) for a in sys.argv[1:4])
cuadros = [int(c) for c in sys.argv[4:]]
os.makedirs(SAL, exist_ok=True)
CTL = os.path.join(SAL, "ctl_%d" % int(time.time()))
os.makedirs(CTL)
proc = subprocess.Popen([EXE, "--ctl", CTL, "--in", HOJA])
t0 = time.time()
while not os.path.exists(os.path.join(CTL, "ready.txt")) and time.time() - t0 < 60:
    time.sleep(0.2)
time.sleep(2)
n = 0
fallos = []


def cmd(op, espera=60, **kw):
    global n
    n += 1
    c = os.path.join(CTL, "cmd-%04d.json" % n)
    r = os.path.join(CTL, "resp-%04d.json" % n)
    with open(c, "w", encoding="utf-8") as f:
        json.dump(dict(op=op, **kw), f, ensure_ascii=False)
    t = time.time()
    while time.time() - t < espera:
        if os.path.exists(r):
            for _ in range(20):
                try:
                    return json.load(open(r, encoding="utf-8"))
                except Exception:
                    time.sleep(0.05)
        time.sleep(0.05)
    return {"error": "sin respuesta a " + op}


def js(code):
    return cmd("js", code=code).get("result")


def nota(que, ok, detalle=""):
    print("%s  %s  %s" % ("ok   " if ok else "FALLO", que, detalle))
    if not ok:
        fallos.append(que)


PARAR = """(function(c){var r=[];document.querySelectorAll('.hk-anim').forEach(function(a){
var b=a.querySelector('input[type=range]');if(!b)return;
b.value=Math.min(c,+b.max);b.dispatchEvent(new Event('input',{bubbles:true}));b.dispatchEvent(new Event('change',{bubbles:true}));
r.push(b.value+'/'+b.max)});return r.join(' ')})(%d)"""
try:
    rp = cmd("reposo", tope=200000, espera=220)
    nota("la hoja termina de calcular", rp.get("ok"), "%s ms" % rp.get("ms"))
    o = cmd("getoutput").get("output", "") or ""
    av = [re.sub(r"\s+", " ", x)[:100] for x in re.findall(r"⚠[^\n]*", o)]
    nota("sin avisos", not av and "calculando" not in o and len(o) > 200, "%d caracteres %s" % (len(o), av[:3]))
    io.open(os.path.join(SAL, "resultado.txt"), "w", encoding="utf-8").write(o)
    na = js("document.querySelectorAll('.hk-anim').length")
    nota("animaciones en la hoja", (na or 0) > 0, str(na))
    cmd("capture", path=os.path.join(SAL, "ventana.png"), ventana=True)
    for c in cuadros:
        r = js(PARAR % c)
        time.sleep(0.8)
        cmd("capture", path=os.path.join(SAL, "cuadro_%02d.png" % c))
        nota("animaciones paradas en el cuadro %d" % c, bool(r), str(r))
    ancho0 = cmd("layout").get("editor")
    r = js("(function(){var b=document.querySelector('.hk-cad-btn');if(!b)return 0;b.scrollIntoView({block:'center'});b.click();return 1})()")
    if r == 1:
        time.sleep(3)
        abierta = js("(function(){return document.querySelector('.hkcad')?1:0})()")
        ancho1 = cmd("layout").get("editor")
        cmd("capture", path=os.path.join(SAL, "ventana_de_dibujo.png"), ventana=True)
        nota("«Dibujar / Editar» abre la ventana de dibujo", abierta == 1 and ancho1 == 0, "editor %s → %s" % (ancho0, ancho1))
        js("(function(){var b=[...document.querySelectorAll('.hkcad button')].find(function(x){return /Cerrar/.test(x.textContent)});if(b)b.click()})()")
        time.sleep(1.5)
        ancho2 = cmd("layout").get("editor")
        nota("al cerrarla vuelve el editor", (ancho2 or 0) > 100, "editor %s" % ancho2)
    else:
        print("      (la hoja no tiene ventana de dibujo)")
finally:
    cmd("quit", espera=5)
    time.sleep(1)
    if proc.poll() is None:
        proc.kill()
print("RESUMEN: %d fallos  ·  salida en %s" % (len(fallos), SAL))
sys.exit(1 if fallos else 0)
