"""Test de la ventana WPF via canal --ctl (como hekatan-lab/tests/wpf).
Lanza HekatanLisp.exe --ctl <carpeta>, manda comandos, verifica respuestas."""
import json, os, subprocess, sys, tempfile, time

EXE = os.path.join(os.path.dirname(os.path.abspath(__file__)),
                   "bin", "Release", "net8.0-windows", "HekatanLisp.exe")
CTL = tempfile.mkdtemp(prefix="hlisp_ctl_")
_n = 0

def cmd(op, **kw):
    global _n
    _n += 1
    c = os.path.join(CTL, f"cmd-{_n:04d}.json")
    r = os.path.join(CTL, f"resp-{_n:04d}.json")
    json.dump({"op": op, **kw}, open(c, "w", encoding="utf-8"))
    for _ in range(200):                     # espera respuesta (hasta 20 s: SBCL tarda)
        if os.path.exists(r):
            time.sleep(0.05)
            return json.load(open(r, encoding="utf-8"))
        time.sleep(0.1)
    raise TimeoutError(f"sin respuesta a {op}")

proc = subprocess.Popen([EXE, "--ctl", CTL])
time.sleep(3)                                # arranque de la ventana + WebView2

fails = 0
def check(nombre, got, esperado):
    global fails
    ok = esperado in got
    print(f"  [{'OK ' if ok else 'FALLA'}] {nombre}: {got!r}")
    if not ok: fails += 1

try:
    # modo 1: code -> LISP
    cmd("mode", n=1)
    cmd("settext", text="x^2 + 3*x")
    check("code->LISP", cmd("getoutput")["output"], "(+ (expt x 2) (* 3 x))")

    # modo 3: LISP -> MATLAB
    cmd("mode", n=3)
    cmd("settext", text="(+ (expt x 2) (* 3 x))")
    check("LISP->MATLAB", cmd("getoutput")["output"], "x^2 + 3*x")

    # modo 5: MOTOR SBCL deriva de verdad
    cmd("mode", n=5)
    cmd("settext", text="x^2 + 3*x")
    check("motor: d/dx(x^2+3x)", cmd("getoutput")["output"], "2*x + 3")
    cmd("settext", text="x^3")
    check("motor: d/dx(x^3)", cmd("getoutput")["output"], "3*x^2")

    # autorun inteligente: linea incompleta NO se ejecuta, muestra "..."
    cmd("settext", text="x^2 + 3*")
    check("incompleto no ejecuta", cmd("getoutput")["output"], "…")
finally:
    cmd("quit")
    proc.wait(timeout=10)

print(f"\n{'TODO OK' if fails==0 else str(fails)+' FALLARON'}")
sys.exit(1 if fails else 0)
