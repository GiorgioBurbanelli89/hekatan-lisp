"""Botón «expr LISP» y «LISP ▶»: ¿qué enseña el panel del resultado?  (Jorge, 27-sep-2026)

Jorge, con `y = x+x` y `2*x` en matemática + simplify: «cuando presiono el botón LISP no se
muestra como debe: me muestras x+x en LISP pero el resultado también en forma LISP, y no me
muestras como ahora, y = x+x simbólicamente es 2*x».

Se mide, sin adivinar, lo que hay en el editor y en el resultado en cada estado:
  matemática -> expr LISP -> LISP completo -> matemática, y escribiendo en modo LISP.

  python tests/_ctl_boton_lisp.py [ruta_del_exe]
"""
import json, os, subprocess, sys, tempfile, time


def P(*a):
    print(*[str(x).encode("ascii", "replace").decode("ascii") for x in a])


EXE = sys.argv[1] if len(sys.argv) > 1 else os.path.join(
    os.path.dirname(__file__), "..", "bin", "Release", "net8.0-windows", "HekatanLisp.exe")
EXE = os.path.abspath(EXE)
carpeta = tempfile.mkdtemp(prefix="hklisp_ctl_")
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
            try:
                return json.load(open(r, encoding="utf-8"))
            except Exception:
                return {"crudo": open(r, encoding="utf-8").read()[:400]}
        time.sleep(0.15)
    return {"__timeout__": op}


def estado(rotulo, png=None):
    time.sleep(0.8)
    st = cmd("state")
    ed = cmd("gettext").get("input", "")
    out = cmd("getoutput", espera=40).get("output", "")
    P("--- " + rotulo)
    P("    estado   :", json.dumps(st, ensure_ascii=False))
    P("    editor   :", repr(ed)[:300])
    P("    resultado:", repr(out)[:300])
    if png:
        cmd("capture", path=png, espera=30)
    return ed, out


try:
    destino = os.path.join(carpeta, "cap")
    os.makedirs(destino, exist_ok=True)
    cmd("settext", text="y = x+x\n2*x")
    cmd("op", name="simplify")
    cmd("view", name="render")
    estado("1) matematica + simplify + render", os.path.join(destino, "1_matematica.png"))
    cmd("syntax", lisp=True)
    estado("2) boton expr LISP", os.path.join(destino, "2_expr_lisp.png"))
    cmd("run")
    estado("3) expr LISP + Ejecutar")
    cmd("synfull")
    estado("4) boton LISP completo", os.path.join(destino, "4_lisp_completo.png"))
    cmd("syntax", lisp=False)
    estado("5) vuelta a matematica")
    # escribir DIRECTAMENTE en modo expr LISP (el camino de quien escribe LISP)
    cmd("syntax", lisp=True)
    cmd("escribe", text="(setf y (+ x x))\n(* 3 x)")
    time.sleep(3)
    estado("6) escrito en expr LISP: (setf y (+ x x)) y (* 3 x)", os.path.join(destino, "6_escrito_lisp.png"))
    cmd("op", name="auto")
    estado("7) lo mismo con «tal cual»")
    P("capturas en:", destino)
finally:
    cmd("quit", espera=5)
    time.sleep(1)
    if proc.poll() is None:
        proc.kill()
