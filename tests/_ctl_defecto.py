"""Al ABRIR el programa: ¿que operacion esta puesta y que da x+x con AutoRun?"""
import json, os, shutil, subprocess, tempfile, time
def P(*a): print(*[str(x).encode("ascii","replace").decode("ascii") for x in a])
EXE = os.path.join(os.environ["LOCALAPPDATA"], "Programs", "Hekatan LISP", "HekatanLisp.exe")
carpeta = tempfile.mkdtemp(prefix="hklisp_def_")
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
            except Exception: return {"raw": open(r, encoding="utf-8").read()[:200]}
        time.sleep(0.15)
    return {"__timeout__": op}
try:
    st = cmd("state")
    P("estado al abrir:", json.dumps(st, ensure_ascii=False))
    P("  operacion:", st.get("op"), " autorun:", st.get("autorun"))
    # el camino del usuario: escribir y no tocar NADA
    cmd("escribe", text="x+x"); time.sleep(2.5)
    o = cmd("getoutput", espera=60)
    s = (o.get("output") if isinstance(o, dict) else str(o)) or ""
    P("  escribo 'x+x' y no toco nada ->", str(s)[:90])
    P("")
    P("  >>> " + ("BIEN: sale el 2x solo." if "2" in str(s) else "MAL: sigue sin simplificar."))
finally:
    cmd("quit", espera=5); time.sleep(1.2)
    if proc.poll() is None: proc.kill()
    shutil.rmtree(carpeta, ignore_errors=True)
