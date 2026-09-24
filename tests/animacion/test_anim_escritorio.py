#!/usr/bin/env python3
"""Animación + voz en el ESCRITORIO (WPF + WebView2), por el canal --ctl.

Carga tests/animacion/anim_voz.lisp y comprueba, en la página que dibuja el motor:
  · cuántos reproductores hay y cuántos cuadros tiene cada uno (#anim fplot/surf/map y los bloques);
  · que la animación AVANZA sola (data-i cambia) y que ▶/⏸ y la barra la mueven;
  · que el texto de la voz está: subtítulo de cada cuadro, con {n} ya sustituido;
  · que la superficie animada es UN lienzo con sus cuadros (data-frames) y cambia al mover la barra;
  · si Windows tiene voz en español, que el botón 🔊 aparece (si no, que está oculto).
Guarda PNG de varios cuadros para MIRARLOS.

Uso: python tests/animacion/test_anim_escritorio.py [carpeta_png]
"""
import json, os, subprocess, sys, tempfile, time
sys.stdout.reconfigure(encoding="utf-8")
RAIZ = os.path.normpath(os.path.join(os.path.dirname(os.path.abspath(__file__)), "..", ".."))
EXE = os.path.join(RAIZ, "bin", "Release", "net8.0-windows", "HekatanLisp.exe")
OUT = sys.argv[1] if len(sys.argv) > 1 else os.path.join(tempfile.gettempdir(), "hk_anim_escritorio")
os.makedirs(OUT, exist_ok=True)
CTL = tempfile.mkdtemp(prefix="hlisp_ctl_anim_")
_n = 0

def cmd(op, **kw):
    global _n
    _n += 1
    c, r = os.path.join(CTL, f"cmd-{_n:04d}.json"), os.path.join(CTL, f"resp-{_n:04d}.json")
    json.dump({"op": op, **kw}, open(c, "w", encoding="utf-8"))
    for _ in range(900):
        if os.path.exists(r):
            time.sleep(0.05); return json.load(open(r, encoding="utf-8"))
        time.sleep(0.1)
    raise TimeoutError(op)

def js(code):
    return cmd("js", code=code).get("result")

fallos = []
def ok(c, m):
    print(("  ✓ " if c else "  ✗ ") + m)
    if not c: fallos.append(m)

HOJA = open(os.path.join(RAIZ, "tests", "animacion", "anim_voz.lisp"), encoding="utf-8").read()
A = "document.querySelectorAll('.hk-anim')"

proc = subprocess.Popen([EXE, "--ctl", CTL])
try:
    for _ in range(100):
        if os.path.exists(os.path.join(CTL, "ready.txt")): break
        time.sleep(0.2)
    time.sleep(2)
    cmd("settext", text=HOJA)
    for _ in range(60):                       # espera a que la página tenga los reproductores
        if (js(A + ".length") or 0) >= 6: break
        time.sleep(0.5)
    print("1. reproductores y cuadros")
    ns = json.loads(js("JSON.stringify(Array.from(" + A + ").map(r=>+r.dataset.n))") or "[]")
    ok(ns == [4, 4, 4, 3, 5, 3], f"cuadros por animación: {ns} (esperado [4, 4, 4, 3, 5, 3])")
    ok(js(A + "[0].hkAnim && " + A + "[0].hkAnim.n") == 4, "el reproductor se inicializó (hkAnim)")
    cmd("capture", path=os.path.join(OUT, "a1_cuadro1.png"))

    print("2. avanza solo")
    time.sleep(4.0)
    i0 = js(A + "[0].hkAnim.i")
    ok(isinstance(i0, int) and i0 > 0, f"la gráfica de x avanzó sola: cuadro {i0}")
    js(A + "[0].hkAnim.para()")

    print("3. voz: subtítulo por cuadro, con {n} sustituido")
    js(A + "[0].hkAnim.show(2)")
    sub = js(A + "[0].querySelector('.hk-anim-sub').textContent")
    ok(sub == "La potencia 3 de x.", f"subtítulo del cuadro 3: {sub!r}")
    voces = json.loads(js("JSON.stringify(" + A + "[1].hkAnim.voz)"))
    ok(voces == ["Amplitud un cuarto.", "Amplitud un medio.", "Amplitud tres cuartos.", "Amplitud completa."],
       f"una #voz por cuadro (superficie): {voces}")
    vb = json.loads(js("JSON.stringify(" + A + "[4].hkAnim.voz)"))
    ok(vb[4] == "Con 5 tramos de carga.", f"bloque de dibujo, voz del cuadro 5: {vb[4]!r}")
    vt = json.loads(js("JSON.stringify(" + A + "[5].hkAnim.voz)"))
    ok(vt == ["Cuadro 1.", "Cuadro 2.", "Cuadro 3."], f"#voz dentro del bloque: {vt}")
    ok(js("Array.from(document.querySelectorAll('.hk-voz-txt')).pop().textContent")
       == "Esta frase va sola, con su botón para escucharla.", "la #voz suelta se ve como texto")

    print("4. superficie: un lienzo, varios cuadros")
    nfr = js("JSON.parse(" + A + "[1].querySelector('canvas').dataset.frames).length")
    ok(nfr == 4, f"lienzo con {nfr} cuadros")
    js(A + "[1].hkAnim.para();" + A + "[1].hkAnim.show(3)")
    ok(js(A + "[1].querySelector('canvas').dataset.frame") == "3", "la barra mueve el lienzo al cuadro 4")
    lb = js(A + "[1].querySelector('.hk-anim-lbl').textContent")
    ok(lb.startswith("A = 1") and "(4/4)" in lb, f"rótulo: {lb!r}")
    nm = js(A + "[2].hkAnim.n")
    ok(nm == 4, f"surf(M) sin parámetro: {nm} componentes de la matriz 2×2")

    print("5. bloque de dibujo: un SVG por cuadro; la barra enseña uno")
    nsvg = js(A + "[4].querySelectorAll('.hkfr svg').length")
    ok(nsvg >= 5, f"SVG en los cuadros: {nsvg}")
    js(A + "[4].hkAnim.para();" + A + "[4].hkAnim.show(4)")
    vis = json.loads(js("JSON.stringify(Array.from(" + A + "[4].querySelectorAll('.hkfr')).map(f=>f.style.visibility))"))
    ok(vis == ["hidden"] * 4 + ["visible"], f"visibilidad: {vis}")
    js("(" + A + "[4].closest('.hk-plotslot')||" + A + "[4]).scrollIntoView()")
    cmd("capture", path=os.path.join(OUT, "a2_dibujo_cuadro5.png"))

    print("6. voz del sistema")
    lang = js(A + "[0].dataset.voz")
    btn = js(A + "[0].querySelector('.hk-anim-voz').style.display")
    if lang:
        ok(btn == "", f"hay voz ({lang}): el botón 🔊 se ve")
        js(A + "[0].hkAnim.para();" + A + "[0].hkAnim.show(0);" + A + "[0].querySelector('.hk-anim-voz').click()")
        time.sleep(0.8)
        ok(js("speechSynthesis.speaking") is True, "🔊 → speechSynthesis está hablando")
        ok(js(A + "[0].hkAnim.jugando") is True, "con voz la animación sigue (avanza al terminar cada frase)")
        time.sleep(3.5)
        ok(js(A + "[0].hkAnim.i") >= 1, f"tras la primera frase pasó al cuadro {js(A + '[0].hkAnim.i') + 1}")
        js(A + "[0].querySelector('.hk-anim-voz').click()")   # 🔇
        time.sleep(0.3)
        ok(js("speechSynthesis.speaking") is False, "segundo clic → calla")
    else:
        ok(btn == "none", "sin voz en español: el botón 🔊 está oculto y la animación sigue sola")
    print(f"     voz elegida: {lang!r}")

    print("7. bloque #autolisp animado (k = 3:8, un polígono por cuadro)")
    cmd("settext", text=open(os.path.join(RAIZ, "tests", "animacion", "anim_autolisp.lisp"), encoding="utf-8").read())
    for _ in range(60):
        if (js(A + ".length") or 0) >= 1 and js(A + "[0].hkAnim") is not None: break
        time.sleep(0.5)
    ok(js(A + "[0].hkAnim.n") == 6, "6 cuadros")
    ok(js(A + "[0].querySelectorAll('.hkfr svg').length") >= 6, "un dibujo AutoLISP por cuadro")
    ok(js(A + "[0].hkAnim.voz[5]") == "Polígono regular de 8 lados inscrito en la circunferencia.", "voz del cuadro 6 con {k} = 8")
    js(A + "[0].hkAnim.para();" + A + "[0].hkAnim.show(5)")
    cmd("capture", path=os.path.join(OUT, "a3_autolisp_octogono.png"))
finally:
    try: cmd("quit")
    except Exception: pass
    try: proc.wait(timeout=10)
    except Exception: proc.kill()

print(f"\nPNG en {OUT}")
print("TODO OK" if not fallos else f"{len(fallos)} FALLARON")
sys.exit(1 if fallos else 0)
