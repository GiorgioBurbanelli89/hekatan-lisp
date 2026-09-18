"""AutoRun en LISP COMPLETO (el modo que ejecuta codigo de verdad).
   python tests/_ctl_autorun_full.py
"""
import json, os, shutil, subprocess, sys, tempfile, time
def P(*a): print(*[str(x).encode("ascii","replace").decode("ascii") for x in a])

EXE = os.path.abspath(os.path.join(os.path.dirname(__file__), "..", "bin", "Release", "net8.0-windows", "HekatanLisp.exe"))
carpeta = tempfile.mkdtemp(prefix="hklisp_full_")
P("canal:", carpeta)
proc = subprocess.Popen([EXE, "--ctl", carpeta]); time.sleep(6)
n = 0
def cmd(op, espera=60, **kw):
    global n; n += 1
    c = os.path.join(carpeta, f"cmd-{n:04d}.json"); r = os.path.join(carpeta, f"resp-{n:04d}.json")
    json.dump({"op": op, **kw}, open(c, "w", encoding="utf-8"), ensure_ascii=False)
    t0 = time.time()
    while time.time() - t0 < espera:
        if os.path.exists(r):
            time.sleep(0.12)
            try: return json.load(open(r, encoding="utf-8"))
            except Exception: return {"raw": open(r, encoding="utf-8").read()[:300]}
        time.sleep(0.15)
    return {"__timeout__": f"{op} sin respuesta en {espera}s"}
try:
    P("1) estado inicial     :", json.dumps(cmd("state"), ensure_ascii=False))
    P("2) boton LISP completo:", json.dumps(cmd("synfull"), ensure_ascii=False)[:160])
    P("   estado ahora       :", json.dumps(cmd("state"), ensure_ascii=False))

    guion = "(defun cuadrado (x) (* x x))\n(cuadrado 7)"
    P("3) escribe un script LISP (sin forzar el calculo)")
    P("   ", json.dumps(cmd("escribe", text=guion), ensure_ascii=False))
    t0 = time.time(); out = cmd("getoutput", espera=90); dt = time.time() - t0
    s = json.dumps(out, ensure_ascii=False)
    P(f"   getoutput ({dt:.1f}s):", s[:260])
    ok1 = "49" in s

    guion2 = "(defun cubo (x) (* x x x))\n(cubo 5)"
    P("4) CAMBIA el script (cubo 5 = 125), otra vez sin forzar")
    P("   ", json.dumps(cmd("escribe", text=guion2), ensure_ascii=False))
    time.sleep(3.0)
    t0 = time.time(); out2 = cmd("getoutput", espera=90); dt2 = time.time() - t0
    s2 = json.dumps(out2, ensure_ascii=False)
    P(f"   getoutput ({dt2:.1f}s):", s2[:260])
    ok2 = "125" in s2
    P("")
    if "__timeout__" in s or "__timeout__" in s2: P("   >>> EL MOTOR SE CUELGA en LISP completo (getoutput no vuelve).")
    elif not ok1: P("   >>> El primer script NO dio 49: el motor no ejecuta el codigo.")
    elif not ok2: P("   >>> AL CAMBIAR el script NO se recalcula (se queda en el anterior).")
    else: P("   >>> LISP completo ejecuta y recalcula al cambiar el script.")
finally:
    cmd("quit", espera=5); time.sleep(1.5)
    if proc.poll() is None: proc.kill()
    shutil.rmtree(carpeta, ignore_errors=True)
