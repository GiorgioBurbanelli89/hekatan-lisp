# -*- coding: utf-8 -*-
"""¿Qué enlace da «Compartir»? Medido en la ventana real por --ctl (en --ctl no abre el navegador
ni pisa el portapapeles: apunta lo que habría hecho).

  python tests/_ctl_compartir.py <exe> <carpeta_de_salida> [hoja.lisp ...]

Tres casos: un ejemplo publicado sin tocar (#ej=), una hoja propia corta y una hoja propia larga
(las dos van al servicio de enlaces cortos: #s=). Si el servicio falla cae a #h= (la hoja dentro).
"""
import io, json, os, subprocess, sys, time

sys.stdout = io.TextIOWrapper(sys.stdout.buffer, encoding="utf-8", line_buffering=True)
EXE, SAL = os.path.abspath(sys.argv[1]), os.path.abspath(sys.argv[2])
hojas = [os.path.abspath(h) for h in sys.argv[3:]]
os.makedirs(SAL, exist_ok=True)
CTL = os.path.join(SAL, "ctl_%d" % int(time.time()))
os.makedirs(CTL)
proc = subprocess.Popen([EXE, "--ctl", CTL])
t0 = time.time()
while not os.path.exists(os.path.join(CTL, "ready.txt")) and time.time() - t0 < 60:
    time.sleep(0.2)
time.sleep(2)
n = 0


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


def comparte(rotulo, texto):
    cmd("settext", text=texto)
    cmd("reposo", tope=120000, espera=140)
    cmd("fuera")
    cmd("pulsa", nombre="BtnCompartir")
    url = ""
    for _ in range(40):                       # el enlace corto va por la red: llega un poco después
        time.sleep(0.5)
        f = cmd("fuera", vaciar=False).get("fuera", [])
        url = next((x.split("\t", 1)[1] for x in f if x.startswith("abrir\t")), "")
        if url:
            break
    tipo = "#ej" if "#ej=" in url else "#s" if "#s=" in url else "#h" if "#h=" in url else "?"
    print("%-34s hoja %6d car.  enlace %5d car.  tipo %s" % (rotulo, len(texto), len(url), tipo))
    print("      " + (url if len(url) < 140 else url[:137] + "..."))
    return url


try:
    for h in hojas:
        comparte(os.path.basename(h)[:34], io.open(h, encoding="utf-8").read())
    comparte("hoja propia corta", "# Prueba de enlace corto\nL = 3 [m]\nq = L^2\n")
    # sin título ni comentario: el servicio la rechazaba («no parece una hoja») y salía el enlace largo
    comparte("dos fórmulas sin título", "y = x + x\n2*x\n")
    comparte("hoja propia larga", "# Prueba de enlace corto (hoja larga)\n" + "".join(
        "k_%d = %d*x^2 + %d*x + %d 'fila %d de una hoja larga de prueba\n" % (i, i, i + 1, i + 2, i) for i in range(1, 121)))
finally:
    cmd("quit", espera=5)
    time.sleep(1)
    if proc.poll() is None:
        proc.kill()
