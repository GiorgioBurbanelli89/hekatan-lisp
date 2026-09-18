"""El canal --ctl, a la vista: que fichero se escribe y que contesta la ventana."""
import json, os, shutil, subprocess, tempfile, time
def P(*a): print(*[str(x).encode("ascii","replace").decode("ascii") for x in a])
EXE = os.path.join(os.environ["LOCALAPPDATA"], "Programs", "Hekatan LISP", "HekatanLisp.exe")
carpeta = tempfile.mkdtemp(prefix="ctl_crudo_")
P(f"1) arranco la ventana:  HekatanLisp.exe --ctl {carpeta}")
proc = subprocess.Popen([EXE, "--ctl", carpeta]); time.sleep(7)
n = 0
def cmd(op, **kw):
    global n; n += 1
    c = os.path.join(carpeta, f"cmd-{n:04d}.json"); r = os.path.join(carpeta, f"resp-{n:04d}.json")
    peticion = {"op": op, **kw}
    json.dump(peticion, open(c, "w", encoding="utf-8"), ensure_ascii=False)
    P(f"\n   ESCRIBO  cmd-{n:04d}.json   -> {json.dumps(peticion, ensure_ascii=False)}")
    t0 = time.time()
    while time.time() - t0 < 40:
        if os.path.exists(r):
            time.sleep(0.12)
            txt = open(r, encoding="utf-8").read()
            P(f"   CONTESTA resp-{n:04d}.json  <- {txt[:300]}")
            try: return json.loads(txt)
            except Exception: return {}
        time.sleep(0.15)
    P("   (sin respuesta)"); return {}
try:
    P("\n2) le pregunto el estado")
    cmd("state")
    P("\n3) le pregunto que ofreceria el autocompletado para 'de'")
    cmd("complete", prefix="de")
    P("\n4) escribo en su editor y le pido el resultado")
    cmd("settext", text="x+x")
    cmd("getoutput")
finally:
    P("\n5) le digo que se cierre")
    cmd("quit"); time.sleep(1.2)
    if proc.poll() is None: proc.kill()
    shutil.rmtree(carpeta, ignore_errors=True)
