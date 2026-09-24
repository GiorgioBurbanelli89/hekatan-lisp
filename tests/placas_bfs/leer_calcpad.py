"""Lee del HTML de Calcpad los valores del bloque ORACULO (w, Mx, My en nudos clave) y las matrices
transp(W_z), transp(Mx), transp(My)."""
import html as H, re, sys


def texto(path):
    s = open(path, encoding="utf-8").read()
    s = re.sub(r"<(script|style).*?</\1>", " ", s, flags=re.S)
    s = re.sub(r"<svg.*?</svg>", "[SVG]", s, flags=re.S)
    s = re.sub(r"<img[^>]*>", "[IMG]", s)
    s = re.sub(r"</(p|div|tr|h\d|table)>", "\n", s)
    s = H.unescape(re.sub(r"<[^>]+>", " ", s))
    return [t for t in (re.sub(r"\s+", " ", l).strip() for l in s.split("\n")) if t]


def pot(s):
    """Calcpad escribe 10⁻¹⁹ sin mantisa («10 -19»): se pasa a 1e-19."""
    return re.sub(r"(?<![×\d.])(-?)10 (-\d{2,})", r"\g<1>1e\g<2>", s.replace("−", "-"))


def num(s):
    s = pot(s).strip()
    if re.match(r"^-?1e-\d+", s): return float(s.split()[0])
    m = re.match(r"(-?\d+(?:\.\d+)?)(?:×10 (-?\d+))?", s)
    return float(m.group(1)) * (10 ** int(m.group(2)) if m.group(2) else 1)


def nums(s):
    s = pot(s).replace("⋯", " ")
    return [float(a) * (10 ** int(b) if b else 1) for a, b in re.findall(r"(-?\d+(?:\.\d+)?(?:e-\d+)?)(?:×10 (-?\d+))?", s)]


def oraculo(path):
    T = texto(path)
    todo = " ".join(T)
    out = {}
    i = todo.index("ORACULO")
    for m in re.finditer(r"(W|MX|MY) (\w+) \S+ \S+ = [^=]*= (-?1e-\d+|-?[\d.]+(?:×10 -?\d+)?)", pot(todo[i:])):
        out[{"W": "w", "MX": "Mx", "MY": "My"}[m.group(1)] + "_" + m.group(2)] = num(m.group(3))
    for lab, nom in (("transp ( W z ) =", "W_z"), ("transp ( Mx ) =", "Mx"), ("transp ( My ) =", "My")):
        k = next(k for k, t in enumerate(T) if t.startswith(lab))
        filas = []
        for t in T[k + 1:]:
            v = nums(t)
            if not v or not re.match(r"^[-\d. ×⋯]+( (mm|kNm/m))?$", t.replace("−", "-")):
                if filas: break
                continue
            filas.append(v)
            if t.endswith("mm") or t.endswith("kNm/m"): break
        out[nom] = filas
    return out


if __name__ == "__main__":
    sys.stdout.reconfigure(encoding="utf-8")
    o = oraculo(sys.argv[1])
    for k, v in o.items():
        print(k, v if not isinstance(v, list) else f"{len(v)}x{len(v[0])} {v[0][:4]} … {v[-1][-2:]}")


def adelgaza(path):
    """Quita del HTML de Calcpad lo que pesa y no se compara (imágenes base64, SVG, scripts, estilos):
    de ~2 MB a unas decenas de KB, para poder guardar el oráculo en el repositorio."""
    s = open(path, encoding="utf-8").read()
    s = re.sub(r"<(script|style)\b.*?</\1>", "", s, flags=re.S)
    s = re.sub(r"<svg\b.*?</svg>", "[SVG]", s, flags=re.S)
    s = re.sub(r"<img\b[^>]*>", "[IMG]", s)
    open(path, "w", encoding="utf-8").write(s)
