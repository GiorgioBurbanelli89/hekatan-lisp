"""AutoRun con una HOJA REAL (la de 8 KB, cascara no lineal): abrirla, cambiarla y ver
   si recalcula sola. Es el caso de Jorge: «estaba cambiando algo en el script».
   python tests/_ctl_hoja_real.py [ruta.lisp]
"""
import json, os, shutil, subprocess, sys, tempfile, time, glob
def P(*a): print(*[str(x).encode("ascii","replace").decode("ascii") for x in a])

base = os.path.dirname(os.path.abspath(__file__))
EXE = os.path.abspath(os.path.join(base, "..", "bin", "Release", "net8.0-windows", "HekatanLisp.exe"))
hoja = sys.argv[1] if len(sys.argv) > 1 else sorted(glob.glob(os.path.join(base, "..", "ejemplos", "11*.lisp")))[0]
texto = open(hoja, encoding="utf-8").read()
P("hoja:", os.path.basename(hoja), f"({len(texto)} caracteres, {texto.count(chr(10))+1} lineas)")

carpeta = tempfile.mkdtemp(prefix="hklisp_hoja_")
proc = subprocess.Popen([EXE, "--ctl", carpeta]); time.sleep(6)
n = 0
def cmd(op, espera=120, **kw):
    global n; n += 1
    c = os.path.join(carpeta, f"cmd-{n:04d}.json"); r = os.path.join(carpeta, f"resp-{n:04d}.json")
    json.dump({"op": op, **kw}, open(c, "w", encoding="utf-8"), ensure_ascii=False)
    t0 = time.time()
    while time.time() - t0 < espera:
        if os.path.exists(r):
            time.sleep(0.15)
            try: return json.load(open(r, encoding="utf-8"))
            except Exception: return {"raw": open(r, encoding="utf-8").read()[:200]}
        time.sleep(0.2)
    return {"__timeout__": f"{op} sin respuesta en {espera}s"}
try:
    cmd("synfull")
    P("1) escribo la hoja entera (sin forzar el calculo)")
    P("  ", json.dumps(cmd("escribe", text=texto), ensure_ascii=False))
    t0 = time.time(); o1 = cmd("getoutput", espera=180); d1 = time.time() - t0
    s1 = json.dumps(o1, ensure_ascii=False)
    P(f"   getoutput ({d1:.1f}s): {s1[:200]}")

    # cambio de UNA linea, como quien edita
    cambiado = texto.replace("\n", "\n", 1) + "\n(+ 12345 1)"
    P("2) le anado una linea al final y NO toco nada mas")
    P("  ", json.dumps(cmd("escribe", text=cambiado), ensure_ascii=False))
    time.sleep(3.0)
    t0 = time.time(); o2 = cmd("getoutput", espera=180); d2 = time.time() - t0
    s2 = json.dumps(o2, ensure_ascii=False)
    P(f"   getoutput ({d2:.1f}s): {s2[:200]}")
    P("")
    if "__timeout__" in s1 or "__timeout__" in s2:
        P("   >>> SE CUELGA con la hoja real (getoutput no vuelve). Es el motor, no el AutoRun.")
    elif "12346" in s2:
        P("   >>> Con hoja real tambien recalcula solo al editar.")
    else:
        P("   >>> Con HOJA REAL el AutoRun NO recalcula al editar (el resultado no cambio).")
finally:
    cmd("quit", espera=5); time.sleep(1.5)
    if proc.poll() is None: proc.kill()
    shutil.rmtree(carpeta, ignore_errors=True)
