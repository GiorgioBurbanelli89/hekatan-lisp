"""¿Cuantos simbolos ofrece el autocompletado de LISP, y cuantos conoce el MOTOR?"""
import json, os, shutil, subprocess, tempfile, time, re, glob
def P(*a): print(*[str(x).encode("ascii","replace").decode("ascii") for x in a])
EXE = os.path.join(os.environ["LOCALAPPDATA"], "Programs", "Hekatan LISP", "HekatanLisp.exe")
carpeta = tempfile.mkdtemp(prefix="cat_")
proc = subprocess.Popen([EXE, "--ctl", carpeta]); time.sleep(7)
n = 0
def cmd(op, espera=40, **kw):
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
    o = cmd("complete", prefix="")
    P(f"catalogo del autocompletado : {o.get('catalogo')} simbolos")
    for pre in ["de", "si", "in", "p", "ma", "s"]:
        r = cmd("complete", prefix=pre)
        P(f"   '{pre}' -> {r.get('total')}  {', '.join(r.get('primeros', [])[:8])}")
finally:
    cmd("quit", espera=5); time.sleep(1.2)
    if proc.poll() is None: proc.kill()
    shutil.rmtree(carpeta, ignore_errors=True)
