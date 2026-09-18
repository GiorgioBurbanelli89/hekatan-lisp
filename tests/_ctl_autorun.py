"""AutoRun de Hekatan LISP: ¿al cambiar el script se recalcula?  (Jorge, 16-sep-2026)

Arranca la ventana con --ctl y comprueba, en vivo:
  1. state        -> ¿AutoRun está encendido?
  2. settext A    -> getoutput  (¿el motor responde?)
  3. settext B    -> getoutput  (¿el resultado CAMBIA al cambiar el script?)
Sin adivinar: si getoutput no vuelve, es el motor; si vuelve igual, es el AutoRun.

  python tests/_ctl_autorun.py
"""
import json, os, shutil, subprocess, sys, tempfile, time

# la consola de Windows es cp1252 y revienta con los signos matematicos del motor
def P(*a):
    print(*[str(x).encode("ascii", "replace").decode("ascii") for x in a])

EXE = os.path.join(os.path.dirname(__file__), "..", "bin", "Release", "net8.0-windows", "HekatanLisp.exe")
EXE = os.path.abspath(EXE)
if not os.path.exists(EXE):
    P("NO existe el exe:", EXE); sys.exit(2)

carpeta = tempfile.mkdtemp(prefix="hklisp_ctl_")
P("canal:", carpeta)
proc = subprocess.Popen([EXE, "--ctl", carpeta])
time.sleep(6)

n = 0
def cmd(op, espera=25, **kw):
    global n
    n += 1
    c = os.path.join(carpeta, f"cmd-{n:04d}.json")
    r = os.path.join(carpeta, f"resp-{n:04d}.json")
    with open(c, "w", encoding="utf-8") as f:
        json.dump({"op": op, **kw}, f, ensure_ascii=False)
    t0 = time.time()
    while time.time() - t0 < espera:
        if os.path.exists(r):
            time.sleep(0.12)
            try: return json.load(open(r, encoding="utf-8"))
            except Exception: return open(r, encoding="utf-8").read()[:400]
        time.sleep(0.15)
    return {"__timeout__": f"{op} no respondio en {espera}s"}

try:
    st = cmd("state")
    P("1) state     :", json.dumps(st, ensure_ascii=False)[:200])

    P("2) settext A :", json.dumps(cmd("settext", text="(+ 1 2)"), ensure_ascii=False)[:120])
    outA = cmd("getoutput", espera=40)
    sA = json.dumps(outA, ensure_ascii=False)
    P("   getoutput A:", sA[:220])

    P("3) settext B :", json.dumps(cmd("settext", text="(* 6 7)"), ensure_ascii=False)[:120])
    outB = cmd("getoutput", espera=40)
    sB = json.dumps(outB, ensure_ascii=False)
    P("   getoutput B:", sB[:220])

    # 4) EL CAMINO DEL USUARIO: escribir y NO tocar nada mas. Si AutoRun vive, el
    #    debounce (280 ms) recalcula solo. Se espera 3 s y se mira el resultado.
    P()
    P("4) escribe C (sin forzar):", json.dumps(cmd("escribe", text="(- 100 1)"), ensure_ascii=False)[:120])
    time.sleep(3.0)
    outC = cmd("getoutput", espera=40)
    sC = json.dumps(outC, ensure_ascii=False)
    P("   getoutput C:", sC[:220])
    if "99" in sC:
        P("   >>> AUTORUN VIVO: al escribir, recalcula solo.")
    else:
        P("   >>> AUTORUN MUERTO: se escribio y el resultado NO cambio (sigue en B).")

    P()
    if "__timeout__" in sA or "__timeout__" in sB:
        P("   >>> El MOTOR no responde (getoutput se queda esperando _showTask).")
    elif sA == sB:
        P("   >>> El motor responde pero el resultado NO CAMBIA al cambiar el script.")
    else:
        P("   >>> El motor recalcula al cambiar el script (A != B).")
finally:
    cmd("quit", espera=5)
    time.sleep(1.5)
    if proc.poll() is None: proc.kill()
    shutil.rmtree(carpeta, ignore_errors=True)
