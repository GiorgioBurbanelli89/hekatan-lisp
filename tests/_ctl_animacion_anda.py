# -*- coding: utf-8 -*-
"""¿La animación ANDA sola, con el botón ▶ y con la voz 🔊?  Ventana real por --ctl.

  python tests/_ctl_animacion_anda.py <exe> <hoja.lisp> <carpeta_de_salida>

Jorge (30-sep-2026, hoja 95, captura con el cuadro 1/11 parado, ▶ y ⏹): «no está funcionando».
La prueba anterior (_ctl_hoja_animada.py) movía la barra a mano: nunca miró si los cuadros AVANZAN solos.
Aquí se mira el cuadro de cada animación segundo a segundo:
  1. sin tocar nada (debe arrancar sola);
  2. tras pulsar ⏸ y ▶;
  3. tras pulsar 🔊 (con voz cada cuadro espera su frase: si la voz no termina, se queda parada).
"""
import io, json, os, subprocess, sys, time

sys.stdout = io.TextIOWrapper(sys.stdout.buffer, encoding="utf-8", line_buffering=True)
EXE, HOJA, SAL = (os.path.abspath(a) for a in sys.argv[1:4])
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


ESTADO = """(function(){var S=window.speechSynthesis;return JSON.stringify({
 a:[...document.querySelectorAll('.hk-anim')].map(function(a){var h=a.hkAnim;return h?[h.i,h.jugando?1:0,
   (a.querySelector('.hk-anim-play')||{}).textContent,(a.querySelector('.hk-anim-voz')||{}).textContent,
   getComputedStyle(a.querySelector('.hk-anim-voz')).display]:null}),
 voces:S?S.getVoices().length:-1, es:S?S.getVoices().filter(function(v){return /^es/i.test(v.lang)}).map(function(v){return v.name+' '+v.lang}):[],
 habla:S?[S.speaking,S.pending,S.paused]:null, origen:location.protocol})})()"""


def mira(segundos, rotulo):
    pasos = []
    for _ in range(segundos):
        e = json.loads(js(ESTADO) or "{}")
        pasos.append([x[0] if x else None for x in e.get("a", [])])
        time.sleep(1)
    print("   %-26s cuadro de cada animación, segundo a segundo:" % rotulo)
    print("     " + "  ".join(",".join(str(v) for v in p) for p in pasos))
    return pasos, e


try:
    rp = cmd("reposo", tope=200000, espera=220)
    e = json.loads(js(ESTADO) or "{}")
    print("página:", e.get("origen"), "| voces:", e.get("voces"), "| en español:", e.get("es"))
    print("botones [cuadro, jugando, ▶, voz, voz visible]:", e.get("a"))
    # 1) sola
    p, e = mira(9, "1) sin tocar nada")
    nota("la animación arranca sola", (p[-1][0] or 0) > 0, "primera animación: %s → %s" % (p[0][0], p[-1][0]))
    primer = next((k for k, x in enumerate(p) if (x[0] or 0) > 0), None)
    nota("se mueve antes de 4 s", primer is not None and primer <= 3, "primer cambio en el segundo %s" % primer)
    nota("al menos 5 cuadros en 9 s", (p[-1][0] or 0) >= 5, "%s cuadros (antes del arreglo: 2)" % p[-1][0])
    # 2) pausa y play en la primera
    js("document.querySelector('.hk-anim .hk-anim-play').click()")
    a = json.loads(js(ESTADO))["a"][0]
    time.sleep(2.5)
    b = json.loads(js(ESTADO))["a"][0]
    nota("⏸ la para", a[1] == 0 and a[0] == b[0], "cuadro %s → %s, botón %s" % (a[0], b[0], b[2]))
    js("document.querySelector('.hk-anim .hk-anim-play').click()")
    p, e = mira(6, "2) tras pulsar ▶")
    nota("▶ la vuelve a mover", p[-1][0] != p[0][0], "%s → %s" % (p[0][0], p[-1][0]))
    # 3) voz en la primera
    js("document.querySelector('.hk-anim .hk-anim-play').click()")            # pausa
    js("(function(){var a=document.querySelector('.hk-anim');a.hkAnim.show(0);a.querySelector('.hk-anim-voz').click()})()")
    time.sleep(0.5)
    e = json.loads(js(ESTADO))
    print("   tras pulsar 🔊: botones", e["a"][0], "| habla [speaking,pending,paused]:", e.get("habla"))
    p, e = mira(16, "3) con la voz 🔊")
    print("   al final: botones", e["a"][0], "| habla:", e.get("habla"))
    nota("con la voz la animación avanza", (p[-1][0] or 0) >= 3, "%s → %s en 16 s" % (p[0][0], p[-1][0]))
    # 4) lo que hizo Jorge: con la voz puesta, ⏸ y otra vez ▶ (quedaba ▶ + ⏹ en el cuadro 1)
    js("(function(){var a=document.querySelector('.hk-anim');a.querySelector('.hk-anim-play').click();a.hkAnim.show(0)})()")
    time.sleep(1)
    a = json.loads(js(ESTADO))["a"][0]
    js("document.querySelector('.hk-anim .hk-anim-play').click()")
    p, e = mira(10, "4) voz puesta, ⏸ y ▶")
    nota("con la voz puesta, ⏸ y ▶ la vuelve a mover", a[1] == 0 and (p[-1][0] or 0) >= 2, "parada en %s con %s %s → cuadro %s" % (a[0], a[2], a[3], p[-1][0]))
    js("(function(){var a=document.querySelector('.hk-anim');a.querySelector('.hk-anim-voz').click()})()")     # voz fuera
    cmd("capture", path=os.path.join(SAL, "con_voz.png"), ventana=True)
finally:
    cmd("quit", espera=5)
    time.sleep(1)
    if proc.poll() is None:
        proc.kill()
print("RESUMEN: %d fallos" % len(fallos))
sys.exit(1 if fallos else 0)
