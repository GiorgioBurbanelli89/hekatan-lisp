#!/usr/bin/env python3
"""Hoja numérica (#numerico) de punta a punta: la app exporta la hoja (--html) y el motor deja
sus valores en HK_NUM_DEBUG. Dos pruebas:

1. hoja_basica.lisp: bucles, palabras de Calcpad, if/elseif, índices, rangos, A\\b, funciones,
   @(x), integral/integral2, e ≠ E, #hide, y que un error no tumbe la hoja.
2. El ejemplo 71 (Rectangular Slab FEA) contra el HTML que generó CALCPAD (el oráculo):
   todos los números que Calcpad imprime, a 4 decimales.

Uso: python tests/numerico/test_hoja_numerica.py [--exe ruta]
"""
import argparse, html as H, os, re, subprocess, sys, tempfile

AQUI = os.path.dirname(os.path.abspath(__file__))
RAIZ = os.path.normpath(os.path.join(AQUI, "..", ".."))
EXE = os.path.join(RAIZ, "bin", "Release", "net8.0-windows", "HekatanLisp.exe")
SLAB = os.path.join(RAIZ, "ejemplos", "71 Losa rectangular por elementos finitos (Rectangular Slab FEA de Calcpad).lisp")
ORACULO = os.path.normpath(os.path.join(RAIZ, "..", "calcpad-examples", "Rectangular Slab FEA.html"))


def corre(exe, hoja):
    tmp = tempfile.mkdtemp(prefix="hkn_")
    out, dbg = os.path.join(tmp, "h.html"), os.path.join(tmp, "dbg.lisp")
    env = dict(os.environ, HK_NUM_DEBUG=dbg)
    subprocess.run([exe, "--html", out, "--in", hoja], env=env, timeout=180)
    vals, errs, tiempo = {}, {}, None
    seccion = None
    for l in open(dbg, encoding="utf-8"):
        l = l.rstrip("\n")
        if l.startswith(";; ---- valores"): seccion = "v"; continue
        if l.startswith(";; ---- errores"): seccion = "e"; continue
        m = re.match(r";; ([\d.]+) s total, ([\d.]+) s calculo", l)
        if m: tiempo = (float(m.group(1)), float(m.group(2)))
        if seccion == "v":
            m = re.match(r";; (\d+) \[([^\]]*)\] (.*?) => (.*)$", l)
            if m: vals[int(m.group(1))] = (m.group(2), m.group(3), m.group(4))
        elif seccion == "e":
            m = re.match(r";; (\d+) (.*)$", l)
            if m: errs[int(m.group(1))] = m.group(2)
    texto = open(out, encoding="utf-8").read()
    return vals, errs, tiempo, texto


def lit(s):
    """(vector …) → lista (o lista de listas); número → float."""
    s = s.strip()
    if s.startswith("(vector (vector"):
        return [[float(x) for x in r.split()] for r in re.findall(r"\(vector ([^()]*)\)", s)]
    if s.startswith("(vector"):
        return [float(x) for x in s[len("(vector"):-1].split()]
    return float(s)


def prueba_basica(exe):
    vals, errs, t, _ = corre(exe, os.path.join(AQUI, "hoja_basica.lisp"))
    por_texto = {txt: lit(v) for (_, txt, v) in vals.values()}
    fallos = 0
    def chk(cond, nombre):
        nonlocal fallos
        fallos += not cond
        print(f"  [{'OK ' if cond else 'MAL'}] {nombre}")
    esperado = {"s": 15, "p": 24, "c": 3 + 200, "f(3)": 10, "oculta + 1": 100}
    for k, v in esperado.items():
        if k in por_texto: chk(abs(por_texto[k] - v) < 1e-12, f"{k} = {v}")
    for k, v in esperado.items(): chk(k in por_texto, f"hay valor para «{k}»")
    chk(any(txt.startswith("e·") and lit(v) == 6 for (_, txt, v) in vals.values()), "e = 2, E = 3 → e·E = 6 (mayúsculas distintas)")
    chk(por_texto.get("v") == [1, 4, 9, 16], "v(i) = i^2 en un bucle")
    x = [v for (n, txt, v) in vals.values() if n == "x"]
    chk(x and all(abs(a - b) < 1e-12 for a, b in zip(lit(x[0]), [0.1, 0.6])), "x = A\\b")
    B = [v for (n, txt, v) in vals.values() if n == "B"]
    chk(B and lit(B[-1]) == [[7, 0, 0], [8, 4, 1], [9, 2, 3]], "B(2:3, 2:3) += A y B(:, 1) = …")
    chk(abs(por_texto.get("integral2(g, 0, 1, 0, 1)", 0) - 0.25) < 1e-12, "integral2 de @(x, y) x·y = 1/4")
    I = [v for (n, txt, v) in vals.values() if n == "I"]
    chk(I and abs(lit(I[0]) - 2) < 1e-10, "integral de sin en [0, π] = 2")
    chk(any("zz" in e for e in errs.values()), "«zz» sin valor se avisa en su línea")
    S = [v for (n, txt, v) in vals.values() if n == "sigue"]
    chk(S and lit(S[0]) == 42, "la hoja sigue después del error")
    chk(not any(n == "oculta" for (n, _, _) in vals.values()), "#hide: la línea oculta no vuelve a la hoja")
    print(f"  tiempo: {t}")
    return fallos


def oraculo():
    s = open(ORACULO, encoding="utf-8").read()
    for pat in (r"<script.*?</script>", r"<style.*?</style>"):
        s = re.sub(pat, "", s, flags=re.S)
    s = re.sub(r"<svg.*?</svg>", "[SVG]", s, flags=re.S)
    s = re.sub(r"<img[^>]*>", "[IMG]", s)
    s = re.sub(r"</(p|div|tr|h\d|table)>", "\n", s)
    s = H.unescape(re.sub(r"<[^>]+>", " ", s))
    return [t for t in (re.sub(r"\s+", " ", l) for l in s.split("\n")) if t.strip()]


def nums(s):
    s = s.replace("10 20", "1e20").replace("−", "-").replace("⋯", " ")
    return [float(x) for x in re.findall(r"-?\d+(?:\.\d+)?(?:e-?\d+)?", s)]


def prueba_losa(exe):
    vals, errs, t, texto = corre(exe, SLAB)
    T = oraculo()
    def after(label, n=1, start=0):
        for i in range(start, len(T)):
            if T[i].strip().startswith(label): return i, T[i + 1:i + 1 + n]
        raise KeyError(label)
    # valores de Hekatan por el TEXTO de la línea (no por su número: así la hoja puede crecer)
    V = {}
    for (n, txt, v) in vals.values():
        V[txt] = lit(v)
        if n: V[n] = lit(v)
    def hk(txt):
        if txt not in V: raise KeyError("Hekatan no dio valor para: " + txt)
        return V[txt]
    res = []
    i, _ = after("D = E")
    for k, (c, h) in enumerate(zip(nums(" ".join(T[i + 1:i + 4])), [x for r in hk("D") for x in r])): res.append((f"D{k}", c, h))
    i, rows = after("K e =", 16)
    Ke = hk("K_e")
    for r in range(16):
        v = nums(rows[r])
        for c in range(r, 16): res.append((f"Ke[{r+1},{c+1}]", v[c], Ke[r][c]))
    i, _ = after("Element load vector")
    for k, (c, h) in enumerate(zip(nums(T[i + 2].split("=")[1]), hk("F_e"))): res.append((f"Fe{k+1}", c, h))
    i, rows = after("K =", 20, start=i)
    K = hk("K")
    for r in range(20):
        v = nums(rows[r])
        for c in range(20): res.append((f"K[{r+1},{c+1}]", v[c], K[r][c]))
        res.append((f"K[{r+1},140]", v[20], K[r][139]))
    i, _ = after("Global load vector")
    fg, F = nums(T[i + 1].split("=")[1]), hk("F")
    res += [(f"F{k+1}", fg[k], F[k]) for k in range(20)] + [("F140", fg[20], F[139])]
    i, _ = after("Solution of the system")
    z = nums(T[i + 1].split("=")[-1])
    Z = [v for (n, txt, v) in vals.values() if n == "Z"]
    Z = lit(Z[0])
    res += [(f"Z{k+1}", z[k], Z[k]) for k in range(20)] + [("Z140", z[20], Z[139])]
    for lab, nom in (("transp ( W z ) =", "transpose(W_z)"), ("transp ( Mx ) =", "transpose(Mx)"),
                     ("transp ( My ) =", "transpose(My)"), ("transp ( Mxy ) =", "transpose(Mxy)")):
        i, rows = after(lab, 5)
        M = hk(nom)
        for r in range(5):
            v = nums(rows[r])
            res += [(f"{nom}[{r+1},{c+1}]", v[c], M[r][c]) for c in range(7)]
    res.append(("w(a/2,b/2)", 6.629, hk("w(a/2, b/2)")))
    line = [l for l in T if "Results for element" in l][0]
    ze = nums(line.split("Z e ( 15 ) =")[1])
    res += [(f"Ze{k+1}", ze[k], hk("Z_e(e_c)")[k]) for k in range(16)]
    me = nums([l for l in T if "M e ( 0; 0 )" in l][0].split("=")[-1])
    res += [(f"Me{k+1}", me[k], hk("M_e(0, 0)")[k]) for k in range(3)]
    i, rows = after("M j =", 3)
    Mj = hk("M_j")
    for r in range(3):
        v = nums(rows[r])
        res += [(f"Mj[{r+1},{c+1}]", v[c], Mj[r][c]) for c in range(20)] + [(f"Mj[{r+1},35]", v[20], Mj[r][34])]
    res += [("Mx max", 6.275108, hk("M_x(a/2, b/2)")), ("My max", 12.744382, hk("M_y(a/2, b/2)")),
            ("Mxy max", -8.377645, hk("M_xy(0, 0)"))]
    malos = [(n, c, h) for n, c, h in res
             if abs(round(c, 4) - round(h, 4)) > 1.00001e-4 and not (abs(c) >= 1e19 and abs(h - c) / abs(c) < 1e-9)]
    rel = max(abs(h - c) / abs(c) for n, c, h in res if abs(c) > 1e-6)
    print(f"  {len(res)} valores de Calcpad comparados; distintos a 4 decimales: {len(malos)}; "
          f"máx. diferencia relativa {rel:.1e}")
    for m in malos[:20]: print("   ", m)
    print(f"  errores en la hoja: {len(errs)}   tiempo (total, cálculo): {t}")
    graficas = texto.count("data:image/png;base64")
    print(f"  gráficas en el HTML: {graficas} (malla + 4 mapas)")
    return len(malos) + len(errs) + (graficas < 5)


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--exe", default=EXE)
    a = ap.parse_args()
    print("1 · hoja básica")
    f = prueba_basica(os.path.abspath(a.exe))
    print("2 · Rectangular Slab FEA contra Calcpad")
    f += prueba_losa(os.path.abspath(a.exe))
    print("TODO OK" if not f else f"FALLAN {f}")
    sys.exit(1 if f else 0)


if __name__ == "__main__":
    main()
