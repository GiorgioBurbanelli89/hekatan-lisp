# -*- coding: utf-8 -*-
"""TODOS los botones y menús de Hekatan LISP, pulsados por el canal --ctl, y capturas con --shot.
(Jorge, 27-sep-2026: «prueba todos los botones y usa --shot --ctl».)

La lista de botones NO está escrita aquí: se le pide a la ventana (orden `botones`), así un botón
nuevo entra en la prueba sin tocar este guion. Cada uno se pulsa y se comprueba lo que cambió.
Lo que abriría algo fuera (navegador, PDF, bloc de notas, portapapeles) en --ctl solo se apunta.
Los cuadros de diálogo (Abrir, Guardar como, Acerca de…) se abren y se cierran desde aquí.

  python tests/_ctl_todos_los_botones.py [exe] [carpeta_de_salida] [--sin-ejemplos]
"""
import base64, ctypes, ctypes.wintypes as wt, io, json, os, re, subprocess, sys, tempfile, time, zlib

sys.stdout = io.TextIOWrapper(sys.stdout.buffer, encoding="utf-8", line_buffering=True)
AQUI = os.path.dirname(os.path.abspath(__file__))
args = [a for a in sys.argv[1:] if not a.startswith("--")]
EXE = os.path.abspath(args[0] if args else os.path.join(AQUI, "..", "bin", "Release", "net8.0-windows", "HekatanLisp.exe"))
SAL = os.path.abspath(args[1] if len(args) > 1 else os.path.join(AQUI, "salida_botones"))
SIN_EJEMPLOS = "--sin-ejemplos" in sys.argv
os.makedirs(SAL, exist_ok=True)
CTL = tempfile.mkdtemp(prefix="hklisp_ctl_")
proc = subprocess.Popen([EXE, "--ctl", CTL])
t0 = time.time()
while not os.path.exists(os.path.join(CTL, "ready.txt")) and time.time() - t0 < 60:
    time.sleep(0.2)
time.sleep(2)
n = 0
filas = []          # (grupo, boton, ok, detalle)
pulsados = set()


def cmd(op, espera=30, **kw):
    global n
    n += 1
    c = os.path.join(CTL, "cmd-%04d.json" % n)
    r = os.path.join(CTL, "resp-%04d.json" % n)
    with open(c, "w", encoding="utf-8") as f:
        json.dump(dict(op=op, **kw), f, ensure_ascii=False)
    t = time.time()
    while time.time() - t < espera:
        if os.path.exists(r):
            for _ in range(20):
                try:
                    return json.load(open(r, encoding="utf-8"))
                except Exception:
                    time.sleep(0.05)
            return {"error": "respuesta ilegible"}
        time.sleep(0.05)
    return {"error": "sin respuesta a " + op}


def nota(grupo, boton, ok, detalle=""):
    filas.append((grupo, boton, bool(ok), detalle))
    print("%s  [%s] %s  %s" % ("ok   " if ok else "FALLO", grupo, boton.replace("\n", " "), detalle))


def estado():
    return cmd("estado")


def reposo(tope=120):
    """Espera a que no quede nada por calcular ni por pintar (si no, se lee la página de la hoja anterior)."""
    return cmd("reposo", tope=tope * 1000, espera=tope + 20)


def salida(espera=60):
    reposo(espera)
    return cmd("getoutput", espera=espera).get("output", "") or ""


def pulsa(b, **kw):
    pulsados.add(b["i"])
    return cmd("pulsa", indice=b["i"], **kw)


def foto(nombre):
    p = os.path.join(SAL, nombre + ".png")
    cmd("capture", path=p, ventana=True, espera=40)
    return p


def norm(t):
    return (t or "").replace("\r\n", "\n").replace("\r", "\n")


# ---- cuadros de diálogo del proceso (se cierran desde fuera) ----
u32 = ctypes.windll.user32
ENUM = ctypes.WINFUNCTYPE(wt.BOOL, wt.HWND, wt.LPARAM)


def cuadros():
    res = []

    def cb(h, _):
        pid = wt.DWORD()
        u32.GetWindowThreadProcessId(h, ctypes.byref(pid))
        if pid.value == proc.pid and u32.IsWindowVisible(h):
            cl = ctypes.create_unicode_buffer(64)
            u32.GetClassNameW(h, cl, 64)
            if cl.value == "#32770":
                ti = ctypes.create_unicode_buffer(256)
                u32.GetWindowTextW(h, ti, 256)
                res.append((h, ti.value))
        return True

    u32.EnumWindows(ENUM(cb), 0)
    return res


def abre_y_cierra(b, grupo="cuadro"):
    pulsa(b, diferido=True)
    t = time.time()
    vistos = []
    while time.time() - t < 8 and not vistos:
        time.sleep(0.25)
        vistos = cuadros()
    titulos = [v[1] for v in vistos]
    for _ in range(4):                      # un cuadro puede abrir otro (PDF guardado…)
        for h, _t in cuadros():
            u32.PostMessageW(h, 0x0010, 0, 0)   # WM_CLOSE
        time.sleep(0.5)
        if not cuadros():
            break
    nota(grupo, b["texto"], bool(vistos) and not cuadros(),
         "cuadro: " + " | ".join(titulos) if vistos else "no abrió ningún cuadro")


try:
    inv = cmd("botones")
    B = inv.get("botones", [])
    print("pulsables: %d  (%s)" % (len(B), ", ".join("%s %d" % (t, sum(1 for b in B if b["tipo"] == t))
                                                     for t in ("boton", "casilla", "opcion", "menu"))))
    nota("inventario", "lista de botones", len(B) > 60, "%d" % len(B))

    def por_nombre(x):
        return next(b for b in B if b["nombre"] == x)

    def por_texto(x, padre=None):
        return next(b for b in B if b["texto"] == x and (padre is None or b["padre"] == padre))

    foto("00_arranque")

    # ---------- A. teclas que ESCRIBEN (calculadora, griegas, menú Insertar) ----------
    auto = por_nombre("ChkAutoRun")
    pulsa(auto)
    nota("AutoRun", "apagar", estado().get("autorun") is False)
    teclas = [b for b in B if b["etiqueta"] and b["tipo"] in ("boton", "opcion")
              and b["nombre"] == "" and b["padre"] not in ("_Dibujo", "A_yuda")
              and not b["etiqueta"].endswith(".pdf") and b["etiqueta"] != "web"]
    for modo in ("matematica", "lisp"):
        for b in teclas:
            tag = b["etiqueta"]
            if "|" not in tag and modo == "lisp":
                continue                     # sin variante LISP: ya probada
            cmd("escribe", text="")
            if modo == "lisp":
                cmd("syntax", lisp=True)
            alt = tag.split("|")
            esp = alt[0] if (modo == "lisp" or len(alt) < 2) else alt[1]
            partes = esp.split("§§")
            texto, cursor = "".join(partes[:2]), (len(partes[0]) if len(partes) > 1 else len(esp))
            pulsa(b)
            e = estado()
            ok = norm(e.get("editor")) == norm(texto) and e.get("cursor") == cursor
            nota("escribe/" + modo, b["texto"], ok,
                 "" if ok else "editor %r cursor %s, esperado %r cursor %s" % (e.get("editor"), e.get("cursor"), texto, cursor))
    cmd("syntax", lisp=False)
    pulsa(auto)
    nota("AutoRun", "encender", estado().get("autorun") is True)

    # ---------- B. resultado como: / menú Ver resultado ----------
    HOJA = "y = x^2 + 2*x + 1\nx + x\nf = (a + b)^2"
    cmd("settext", text=HOJA)
    for nom, vista, clave in (("BtnLisp", "lisp", "(setf"), ("BtnMath", "math", "y ="), ("BtnLearn", "learn", "LISP"),
                              ("BtnRender", "render", "y =")):
        pulsa(por_nombre(nom))
        e, o = estado(), salida()
        nota("resultado como", por_nombre(nom)["texto"], e.get("vista") == vista and clave in o, "vista=%s  %r" % (e.get("vista"), o[:60]))
        foto("10_vista_" + vista)
    for txt, vista in (("LISP", "lisp"), ("MATLAB", "math"), ("Render CSS", "render")):
        pulsa(por_texto(txt, "_Ver resultado"))
        nota("menú Ver resultado", txt, estado().get("vista") == vista and len(salida()) > 3)

    # ---------- C. operar: ----------
    casos = (("OpAuto", "auto", "y = x2 + 2·x + 1", None),
             ("OpSimplify", "simplify", "x + x = 2·x", None),
             ("OpExpand", "expand", "a2 + 2·a·b + b2", None),
             ("OpDeriv", "deriv", "2·x + 2", "x"),
             ("OpInteg", "integ", "x", "x"),
             ("OpDespejar", "despejar", "x", "x"))
    for nom, op, clave, var in casos:
        if op == "despejar":
            cmd("settext", text="y = m*x + b")
        if var:
            cmd("setvar", var=var)
        pulsa(por_nombre(nom))
        e, o = estado(), salida()
        plano = re.sub(r"\s*\n\s*", "", o)
        nota("operar", por_nombre(nom)["texto"], e.get("operar") == op and clave.replace(" ", "") in plano.replace(" ", ""),
             "%r" % o[:110])
        foto("20_operar_" + op)
    cmd("setvar", var="")
    pulsa(por_nombre("OpSimplify"))

    # ---------- D. escribo: ----------
    cmd("settext", text="y = x+x\n2*x")
    pulsa(por_nombre("BtnSynLisp"))
    e = estado()
    nota("escribo", "expr LISP", e.get("lisp") and norm(e["editor"]) == "(setf y (+ x x))\n(* 2 x)", repr(e.get("editor")))
    nota("escribo", "expr LISP: el resultado sigue en matemática", "y = x + x = 2·x" in salida(), repr(salida()[:60]))
    foto("30_expr_lisp")
    cmd("escribe", text="(setf y (+ x x))\n(* 3 x)")
    time.sleep(2.5)
    o = salida()
    nota("escribo", "expr LISP: escribir (* 3 x) da 3·x", "3·x" in o and "y = x + x = 2·x" in o, repr(o[:60]))
    foto("31_expr_lisp_escrito")
    pulsa(por_nombre("BtnSynLispFull"))
    e = estado()
    nota("escribo", "LISP ▶", e.get("lispCompleto") and "(load " in e["editor"] and "3·x" in salida(), repr(e["editor"][:50]))
    foto("32_lisp_completo")
    pulsa(por_nombre("BtnSynHekLab"))
    e = estado()
    nota("escribo", "Hekatan Lab", e.get("heklab") and "syms" in e["editor"], repr(e["editor"][:80]))
    foto("33_hekatan_lab")
    pulsa(por_nombre("BtnSynMath"))
    e = estado()
    nota("escribo", "matemática (vuelta)", not e.get("lisp") and norm(e["editor"]) == "y = x+x\n3*x", repr(e.get("editor")))   # la línea que no se tocó vuelve TAL COMO se escribió

    # ---------- E. ejecutar, calculadora, tema ----------
    pulsa(auto)
    cmd("escribe", text="k = 3*4")
    time.sleep(1.5)
    antes = salida()
    pulsa(por_nombre("BtnRun"))
    o = salida()
    nota("Ejecutar", "▶ Ejecutar con AutoRun apagado", "k = 3·4 = 12" not in antes and "12" in o, "antes %r  después %r" % (antes[:40], o[:40]))
    pulsa(auto)
    k0 = estado().get("calculadora")
    pulsa(por_nombre("BtnKeypad"))
    k1 = estado().get("calculadora")
    foto("40_sin_calculadora")
    pulsa(por_nombre("BtnKeypad"))
    nota("calculadora", "🖩 ocultar / mostrar", k0 and not k1 and estado().get("calculadora"))
    mini = next(b for b in B if "minimizar" in b["texto"])
    pulsa(mini)
    nota("calculadora", "− minimizar", not estado().get("calculadora"))
    pulsa(por_nombre("BtnKeypad"))
    d0 = estado().get("oscuro")
    pulsa(por_nombre("BtnTheme"))
    d1 = estado().get("oscuro")
    salida()
    foto("41_tema_cambiado")
    pulsa(por_nombre("BtnTheme"))
    salida()
    nota("tema", "☾ claro / oscuro", d0 != d1 and estado().get("oscuro") == d0, "%s → %s → %s" % (d0, d1, d0))

    # ---------- F. lo que sale FUERA de la app ----------
    cmd("fuera")
    HOJA2 = "# Prueba de enlace\nL = 3 [m]\nq = L^2"
    cmd("settext", text=HOJA2)
    for b in (por_nombre("BtnCompartir"), por_texto("Compartir enlace web…  (Hekatan LISP web)")):
        pulsa(b)
        # desde la 1.30.1 el enlace corto se pide por la red (#s=clave): llega un poco después
        url, f = "", []
        for _ in range(30):
            f = cmd("fuera", vaciar=False).get("fuera", [])
            url = next((x.split("\t", 1)[1] for x in f if x.startswith("abrir\t")), "")
            if url:
                break
            time.sleep(0.5)
        cmd("fuera")
        copia = any(x.startswith("copiar\t") for x in f)
        hoja, tipo = "", "?"
        m = re.search(r"#h=([A-Za-z0-9_\-]+)$", url)
        if m:                                   # la hoja va DENTRO del enlace (sin red)
            c = m.group(1)
            hoja = zlib.decompress(base64.urlsafe_b64decode(c + "=" * (-len(c) % 4)), -15).decode("utf-8")
            tipo = "largo (#h)"
        m = re.search(r"#s=([0-9A-Za-z]+)", url)
        if m:                                   # enlace corto: la hoja está en el servicio
            import urllib.request
            try:
                pet = urllib.request.Request("https://hekatan-compartir.j-b-jazz.workers.dev/h/" + m.group(1),
                                             headers={"User-Agent": "Mozilla/5.0 (prueba de Hekatan LISP)"})   # sin esto Cloudflare da 403
                hoja = urllib.request.urlopen(pet, timeout=15).read().decode("utf-8")
            except Exception as ex:
                hoja = "(el servicio no contesta: %s)" % ex
            tipo = "corto (#s)"
        igual = norm(hoja).strip() == HOJA2.strip()
        nota("fuera", b["texto"], url.startswith("https://giorgioburbanelli89.github.io/hekatan-lisp/#") and copia and igual,
             "enlace %s de %d caracteres; la hoja a la que lleva %s" % (tipo, len(url), "es la del editor" if igual else "NO coincide: %r" % hoja[:60]))
    for b in (por_texto("📋 LISP completo"), por_texto("Copiar como LISP ejecutable (portapapeles)")):
        pulsa(b)
        f = cmd("fuera").get("fuera", [])
        guion = next((x.split("\t", 2)[2] for x in f if x.startswith("copiar\t")), "")
        fich = next((x.split("\t", 1)[1] for x in f if x.startswith("abrir\t")), "")
        nota("fuera", b["texto"], "(load " in guion and os.path.exists(fich) and "(load " in io.open(fich, encoding="utf-8").read(),
             "guion de %d caracteres; fichero %s" % (len(guion), os.path.basename(fich)))
    for b in [x for x in B if x["padre"] == "A_yuda" and (x["etiqueta"].endswith(".pdf") or x["etiqueta"] == "web")]:
        pulsa(b)
        f = cmd("fuera").get("fuera", [])
        d = next((x.split("\t", 1)[1] for x in f if x.startswith("abrir\t")), "")
        if b["etiqueta"] == "web":
            ok = d == "https://giorgioburbanelli89.github.io/hekatan-lisp/manual/Manual_Hekatan_LISP.pdf"
        else:
            ok = os.path.isfile(d) and os.path.getsize(d) > 10000 and io.open(d, "rb").read(5) == b"%PDF-"
        nota("fuera", b["texto"], ok, d[-70:])

    # ---------- G. dibujo ----------
    for b in [x for x in B if x["padre"] == "_Dibujo"] + [por_nombre("BtnDibujar")]:
        cmd("settext", text="a = 2")
        salida()
        pulsa(b, diferido=True)
        time.sleep(4.5)
        e = estado()
        clave = {"2d": "#dibujar(dibujo1, ud = m, cuadricula = 0.1)", "3d": "vista = 3d", "autolisp": "#autolisp(", "dibujo": "#dibujo("}[b["etiqueta"]]
        ok = clave in e.get("editor", "")
        det = ""
        if b["etiqueta"] in ("2d", "3d"):
            r = cmd("js", code="(function(){return document.querySelector('.hkcad')?1:0})()").get("result")
            ok = ok and r == 1
            det = "ventana de dibujo %s" % ("abierta" if r == 1 else "NO abierta")
        else:
            o = salida()
            ok = ok and "⚠" not in o
            det = "sin avisos" if "⚠" not in o else o[:80]
        nota("dibujo", b["texto"], ok, det)
        foto("50_dibujo_" + b["etiqueta"] + ("_boton" if b["nombre"] else ""))

    # ---------- H. archivo y motor ----------
    ancho_cad = cmd("layout").get("editor")
    pulsa(por_texto("Nuevo"))
    salida()
    time.sleep(0.5)
    ancho = cmd("layout").get("editor")
    nota("dibujo", "con la ventana de dibujo abierta, «Nuevo» devuelve el editor", ancho_cad == 0 and ancho > 100,
         "ancho del editor: %s con la ventana de dibujo, %s después" % (ancho_cad, ancho))
    e = estado()
    nota("archivo", "Nuevo",e.get("editor") == "" and e.get("archivo") == "" and "sin guardar" not in e.get("titulo", "x"), repr(e.get("titulo")))
    pulsa(por_texto("Cargar ejemplo"))
    e, o = estado(), salida()
    nota("archivo", "Cargar ejemplo", len(e.get("editor", "")) > 10 and "⚠" not in o, repr(e.get("editor", "")[:50]))
    foto("60_cargar_ejemplo")
    pulsa(por_texto("Cargar ejemplo (loop)"))
    e, o = estado(), salida()
    nota("archivo", "Cargar ejemplo (loop)", "for" in e.get("editor", "") and "⚠" not in o and len(o) > 3, repr(o[:60]))
    foto("61_cargar_ejemplo_loop")
    m1 = next(b for b in B if b["texto"].startswith("Ver funciones del motor"))
    pulsa(m1)
    e, o = estado(), salida()
    nota("motor", m1["texto"], "(defun " in e.get("editor", "") and len(e["editor"]) > 20000 and "Motor de Hekatan LISP" in o and "⚠" not in o,
         "%d caracteres; resultado %r" % (len(e.get("editor", "")), o[:40]))
    foto("62_motor_lisp")
    m2 = next(b for b in B if b["texto"].startswith("Ver funciones en MATLAB"))
    pulsa(m2, diferido=True)          # diferido: si falla abre un cuadro, y la prueba no debe quedarse colgada
    time.sleep(5)
    avisos = cuadros()
    for h, _t in avisos:
        u32.PostMessageW(h, 0x0010, 0, 0)
    e, o = estado(), salida()
    nf = e.get("editor", "").count("function r = ")
    nota("motor", m2["texto"], not avisos and e.get("heklab") and nf > 100 and "no pude" not in e["editor"] and "⚠" not in o,
         "%d funciones traducidas, %d sin traducir%s" % (nf, e.get("editor", "").count("% (sin traducir"), "; salió un cuadro de error" if avisos else ""))
    foto("63_motor_matlab")

    # ---------- I. cuadros de diálogo ----------
    pulsa(por_texto("Nuevo"))
    cmd("settext", text="y = x + x")
    salida()
    for t in ("Abrir…", "Guardar", "Guardar como…", "Guardar como LISP ejecutable (archivo)…",
              "Exportar a PDF…  (para imprimir / LinkedIn)", "Guardar dibujo como…  (DXF · SVG · PNG · PDF · DWG)",
              "Reglas de LISP (para comentar)", "Acerca de Hekatan LISP"):
        abre_y_cierra(por_texto(t))
    e = estado()
    nota("cuadro", "tras cerrar los cuadros la hoja sigue igual", norm(e.get("editor")) == "y = x + x" and e.get("archivo") == "")

    # ---------- J. menú Ejemplos: cada hoja ----------
    ejemplos = [b for b in B if b["padre"].startswith("Ejemplos")]
    carpeta = os.path.join(os.path.dirname(EXE), "ejemplos")
    SABIDOS = ("30 Como se mide", "55 Unidades")      # llevan ⚠ a propósito
    if SIN_EJEMPLOS:
        ejemplos = ejemplos[:3] + ejemplos[-3:]
    te = time.time()
    malos = 0
    for k, b in enumerate(ejemplos, 1):
        nombre = b["texto"].replace("__", "_")
        pulsa(b)
        rp = reposo(400)
        o = cmd("getoutput", espera=60)
        if not rp.get("ok"):
            o["error"] = "no llegó al reposo en 400 s"
        e = estado()
        fich = os.path.join(carpeta, nombre + ".lisp")
        igual = os.path.exists(fich) and norm(io.open(fich, encoding="utf-8").read()) == norm(e.get("editor"))
        txt = o.get("output", "") or ""
        aviso = "⚠" in txt and not nombre.startswith(SABIDOS)
        # una hoja #numerico sin dibujo AutoLISP es matemática: el botón «escribo:» no puede decir LISP
        hoja = e.get("editor", "")
        modo_mal = bool(e.get("lisp")) and "#numerico" in hoja and "#autolisp" not in hoja and "(defun " not in hoja
        ok = (igual and e.get("archivo", "").endswith(nombre + ".lisp") and len(txt) > 3 and not aviso
              and "error" not in o and not modo_mal)
        malos += 0 if ok else 1
        if not ok or k % 10 == 0:
            nota("ejemplos", nombre[:70], ok, "%d de %d, %.0f s%s" % (k, len(ejemplos), time.time() - te,
                 "" if ok else "  igual=%s salida=%d aviso=%r %s%s" % (
                     igual, len(txt), " | ".join(re.sub(r"\s+", " ", x)[:90] for x in re.findall(r"⚠[^\n]*", txt)[:2]), o.get("error", ""),
                     " el botón «escribo:» dice LISP en una hoja de matemática" if modo_mal else "")))
        if k in (1, len(ejemplos) // 2, len(ejemplos)):
            foto("70_ejemplo_%03d" % k)
    nota("ejemplos", "menú Ejemplos: %d hojas abiertas y calculadas" % len(ejemplos), malos == 0, "%d con fallo, %.0f s" % (malos, time.time() - te))

    # ---------- K. lo que no se pulsó ----------
    resto = [b for b in B if b["i"] not in pulsados and b["texto"] != "Salir"
             and not (SIN_EJEMPLOS and b["padre"].startswith("Ejemplos"))]
    menus = [b for b in resto if b["tipo"] == "menu"]
    otros = [b for b in resto if b["tipo"] != "menu"]
    nota("cobertura", "menús que solo despliegan (no hacen nada al pulsar)", True, ", ".join(b["texto"] for b in menus))
    nota("cobertura", "botones sin pulsar", not otros,
         ("%d: " % len(otros) + ", ".join(b["texto"][:30] for b in otros[:8])) if otros else "ninguno")
    nota("cobertura", "pulsados", True, "%d de %d" % (len(pulsados) + 1, len(B)))

    # ---------- L. Salir ----------
    pulsa(por_texto("Salir"), diferido=True)
    t = time.time()
    while proc.poll() is None and time.time() - t < 15:
        time.sleep(0.3)
    nota("archivo", "Salir", proc.poll() is not None, "el proceso terminó" if proc.poll() is not None else "sigue abierto")
finally:
    if proc.poll() is None:
        cmd("quit", espera=5)
        time.sleep(1)
        if proc.poll() is None:
            proc.kill()

# ---------- M. --shot: el resultado a PNG, sin ventana que tocar ----------
hoja = os.path.join(SAL, "_shot.lisp")
io.open(hoja, "w", encoding="utf-8", newline="\n").write("# Prueba de --shot\ny = x + x\nf = (a + b)^2\n#fplot(g = x^2, [0 3])\n")
for nombre, extra in (("80_shot_por_defecto", []), ("81_shot_tal_cual", ["--op", "auto"]), ("82_shot_expand_oscuro", ["--op", "expand", "--dark"]),
                      ("83_shot_vista_lisp", ["--view", "lisp"])):
    p = os.path.join(SAL, nombre + ".png")
    if os.path.exists(p):
        os.remove(p)
    try:
        subprocess.run([EXE, "--shot", p] + extra + ["--in", hoja], timeout=120)
    except subprocess.TimeoutExpired:
        pass
    nota("--shot", nombre, os.path.exists(p) and os.path.getsize(p) > 3000, "%d bytes" % (os.path.getsize(p) if os.path.exists(p) else 0))

mal = [f for f in filas if not f[2]]
print("\nRESUMEN: %d comprobaciones, %d fallos" % (len(filas), len(mal)))
for g, b, _, d in mal:
    print("  FALLO [%s] %s  %s" % (g, b, d))
io.open(os.path.join(SAL, "resultado.txt"), "w", encoding="utf-8").write(
    "\n".join("%s\t%s\t%s\t%s" % ("ok" if o else "FALLO", g, b.replace("\n", " "), d) for g, b, o, d in filas) + "\n")
print("capturas y resultado.txt en:", SAL)
sys.exit(1 if mal else 0)
