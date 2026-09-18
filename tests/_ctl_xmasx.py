"""x+x deberia dar 2x: ¿lo da? Se prueba con las 3 operaciones y sobre el EXE INSTALADO.
   python tests/_ctl_xmasx.py
"""
import json, os, shutil, subprocess, tempfile, time
def P(*a): print(*[str(x).encode("ascii","replace").decode("ascii") for x in a])
EXE = os.path.expandvars(r"%LOCALAPPDATA%\Programs\Hekatan LISP\HekatanLisp.exe")
P("exe INSTALADO:", EXE, "|", time.strftime("%Y-%m-%d %H:%M", time.localtime(os.path.getmtime(EXE))))
carpeta = tempfile.mkdtemp(prefix="hklisp_xx_")
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
    return {"__timeout__": op}
try:
    P("estado:", json.dumps(cmd("state"), ensure_ascii=False))
    cmd("settext", text="x+x")
    for modo in ["auto", "simplify", "expand"]:
        cmd("op", name=modo)
        time.sleep(0.6)
        o = cmd("getoutput", espera=60)
        s = (o.get("output") if isinstance(o, dict) else str(o)) or json.dumps(o, ensure_ascii=False)
        P(f"  operar='{modo}'  ->  {str(s)[:120]}")
    # y lo mismo con una suma que SI deberia juntarse aunque sea 'tal cual'
    P("")
    for txt in ["x+x", "2*x + 3*x", "x*x"]:
        cmd("settext", text=txt); cmd("op", name="simplify"); time.sleep(0.5)
        o = cmd("getoutput", espera=60)
        s = (o.get("output") if isinstance(o, dict) else str(o))
        P(f"  simplify('{txt}')  ->  {str(s)[:100]}")
finally:
    cmd("quit", espera=5); time.sleep(1.2)
    if proc.poll() is None: proc.kill()
    shutil.rmtree(carpeta, ignore_errors=True)
