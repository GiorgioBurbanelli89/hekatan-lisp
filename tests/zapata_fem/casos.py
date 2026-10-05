"""Zapata Demo01 de GEO5 por FEM: genera los .heks de Struct y resuelve lo mismo en numpy
con el Shell-Thick de CSI copiado de shellQ4.cpp (getBendingK_CSI)."""
import numpy as np, json, sys

L = 1.2; t = 0.4; E = 30e6; nu = 0.2; h = 0.1
n = int(round(L / h)); nn = n + 1
ks = 1044.0888888888889 / 0.0159          # q_n de la carga 3 / asiento de GEO5
N1 = 3000.0; GZ = 13.248 + 20.48
V = N1 + GZ
qg = GZ / (L * L)

def xy(i): return -L / 2 + i * h
def nid(i, j): return j * nn + i + 1

def Kcsi(x, y, E, nu, t):
    D0 = E * t**3 / (12 * (1 - nu * nu))
    Db = np.array([[D0, D0 * nu, 0], [D0 * nu, D0, 0], [0, 0, D0 * (1 - nu) / 2]])
    Ds = (5 / 6) * E * t / (2 * (1 + nu)) * np.eye(2)
    D = np.zeros((5, 5)); D[:3, :3] = Db; D[3:, 3:] = Ds
    Dsum = np.trace(Db); PEN = 1000.0
    ca = []; sa = []; LL = []
    for k in range(4):
        j = (k + 1) % 4; dx = x[j] - x[k]; dy = y[j] - y[k]; Lk = np.hypot(dx, dy)
        LL.append(Lk); ca.append(dx / Lk); sa.append(dy / Lk)
    Bl = np.zeros((4, 22))
    for k in range(4):
        j = (k + 1) % 4
        Bl[k, 3 * j] += 1 / LL[k]; Bl[k, 3 * k] -= 1 / LL[k]
        Bl[k, 3 * k + 1] -= sa[k] / 2; Bl[k, 3 * j + 1] -= sa[k] / 2
        Bl[k, 3 * k + 2] += ca[k] / 2; Bl[k, 3 * j + 2] += ca[k] / 2
        Bl[k, 12 + 2 * k] -= 2 / 3 * sa[k]; Bl[k, 13 + 2 * k] += 2 / 3 * ca[k]
    gb = Bl[0] * LL[0] / 2; gt = -Bl[2] * LL[2] / 2; gR = Bl[1] * LL[1] / 2; gL = -Bl[3] * LL[3] / 2
    A0 = (gb + gt) / 2; bb = (gt - gb) / 2; C0 = (gL + gR) / 2; dd = (gR - gL) / 2; mm = (bb + dd) / 2
    qA = np.sqrt(7 / 9); qB = np.sqrt(7 / 15)
    qp = [(-qA, -qA), (qA, -qA), (qA, qA), (-qA, qA), (0, -qB), (qB, 0), (0, qB), (-qB, 0)]
    qw = [9 / 49] * 4 + [40 / 49] * 4
    Bs = []; vs = []; ws = []
    for (r, s), wq in zip(qp, qw):
        dN4r = np.array([-(1 - s), (1 - s), (1 + s), -(1 + s)]) / 4
        dN4s = np.array([-(1 - r), -(1 + r), (1 + r), (1 - r)]) / 4
        dNhr = [-r * (1 - s), (1 - s * s) / 2, -r * (1 + s), -(1 - s * s) / 2]
        dNhs = [-(1 - r * r) / 2, -s * (1 + r), (1 - r * r) / 2, -s * (1 - r)]
        J = np.array([[dN4r @ x, dN4r @ y], [dN4s @ x, dN4s @ y]])
        Ji = np.linalg.inv(J); dJ = abs(np.linalg.det(J))
        B = np.zeros((5, 22)); v = np.zeros(22)
        def giro(col, a, b, fx, fy):
            B[0, col] += b * fx; B[1, col] -= a * fy; B[2, col] += b * fy - a * fx; v[col] += a * fx + b * fy
        for i in range(4):
            gx = Ji[0, 0] * dN4r[i] + Ji[0, 1] * dN4s[i]; gy = Ji[1, 0] * dN4r[i] + Ji[1, 1] * dN4s[i]
            giro(3 * i + 1, 1, 0, gx, gy); giro(3 * i + 2, 0, 1, gx, gy)
        for k in range(4):
            hx = Ji[0, 0] * dNhr[k] + Ji[0, 1] * dNhs[k]; hy = Ji[1, 0] * dNhr[k] + Ji[1, 1] * dNhs[k]
            giro(12 + 2 * k, 1, 0, hx, hy); giro(13 + 2 * k, 0, 1, hx, hy)
        d9r = -2 * r * (1 - s * s); d9s = -2 * s * (1 - r * r)
        g9x = Ji[0, 0] * d9r + Ji[0, 1] * d9s; g9y = Ji[1, 0] * d9r + Ji[1, 1] * d9s
        giro(20, 1, 0, g9x, g9y); giro(21, 0, 1, g9x, g9y)
        gcov = np.vstack([A0 + mm * s, C0 + mm * r]); B[3:5] = Ji @ gcov
        Bs.append(B); vs.append(v); ws.append(wq * dJ)
    media = sum(B[:3, 12:] * w for B, w in zip(Bs, ws)) / sum(ws)
    K = np.zeros((22, 22))
    for B, v, w in zip(Bs, vs, ws):
        B[:3, 12:] -= media
        K += (B.T @ D @ B + PEN * Dsum * np.outer(v, v)) * w
    esc = abs(K).max(); skipped = 0
    for i in range(12, 22):
        piv = K[i, i]
        if abs(piv) <= 1e-14 * esc: skipped += 1; continue
        f = K[i].copy(); c = K[:, i].copy(); K -= np.outer(c, f) / piv; K[i, :] = 0; K[:, i] = 0
    return K[:12, :12], skipped

def caso(nombre, xc, yc, MX, MY, comp=True, viga=None, cargas_extra=None, qcol=None, qall=qg, sin_columna=False):
    """xc,yc centro de la columna (sobre la malla); MX, MY momentos añadidos en ese nudo."""
    nodes = [(xy(i), xy(j)) for j in range(nn) for i in range(nn)]
    shells = []; areal = {}
    for j in range(n):
        for i in range(n):
            s = len(shells) + 1
            shells.append((s, nid(i, j), nid(i + 1, j), nid(i + 1, j + 1), nid(i, j + 1)))
            mx = xy(i) + h / 2; my = xy(j) + h / 2
            q = -qall
            if not sin_columna and abs(mx - xc) < 0.2 and abs(my - yc) < 0.2: q += -(qcol if qcol else N1 / 0.16)
            areal[s] = q
    ic = int(round((xc + L / 2) / h)); jc = int(round((yc + L / 2) / h)); nc = nid(ic, jc)
    extra_nodes = []; frames = []; springs = []; loads = {nc: [0, 0, 0, MX, MY, 0]}
    if viga:
        xi, Ev, Av, I22, I33, Jv, kint, Pint = viga
        ni = len(nodes) + 1
        extra_nodes.append((ni, xi, yc))
        frames.append((1, nc, ni, Ev, Av, I22, I33, Jv))
        springs.append((ni, kint)); loads[ni] = [0, 0, -Pint, 0, 0, 0]
    # heks
    Lh = [f"# Zapata Demo01 GEO5 por FEM: {nombre}. kN, m. ks = {ks:.6f} kN/m3"]
    for k, (x, y) in enumerate(nodes): Lh.append(f"node {k+1} {x:.9g} {y:.9g} 0")
    for (ni, x, y) in extra_nodes: Lh.append(f"node {ni} {x:.9g} {y:.9g} 0")
    for (s, a, b, c, d) in shells:
        Lh.append(f"shell {s} {a} {b} {c} {d} {t} {E:.6g} 0 0")
        Lh.append(f"shelltype {s} thick")
        Lh.append(f"areaspring {s} {ks:.9g} nodal" + (" compresion" if comp else ""))
    for (fid, a, b, Ev, Av, I22, I33, Jv) in frames:
        Lh.append(f"frame {fid} {a} {b} {Ev:.6g} {Av:.9g} {I22:.9g} {I33:.9g} {Jv:.9g} 0.2 0")
    for k in range(len(nodes) + len(extra_nodes)): Lh.append(f"support {k+1} 1 1 0 0 0 1")
    for (ni, kk) in springs: Lh.append(f"spring {ni} uz {kk:.9g}")
    for s, q in areal.items():
        if q != 0: Lh.append(f"areaload {s} {q:.9g}")
    for ni, f in loads.items():
        if any(f): Lh.append("load %d %s" % (ni, " ".join(f"{v:.9g}" for v in f)))
    Lh.append("solve")
    heks = "\n".join(Lh) + "\n"
    # numpy
    nN = len(nodes) + len(extra_nodes); ndof = 3 * nN
    K = np.zeros((ndof, ndof)); F = np.zeros(ndof)
    allxy = nodes + [(x, y) for (_, x, y) in extra_nodes]
    Ke, sk = Kcsi(np.array([0, h, h, 0.]), np.array([0, 0, h, h.__float__()]), E, nu, t)
    kw = np.zeros(nN)
    for (s, a, b, c, d) in shells:
        g = sum([[3 * (q - 1), 3 * (q - 1) + 1, 3 * (q - 1) + 2] for q in (a, b, c, d)], [])
        K[np.ix_(g, g)] += Ke
        for q in (a, b, c, d):
            F[3 * (q - 1)] += areal[s] * h * h / 4; kw[q - 1] += ks * h * h / 4
    for ni, f in loads.items():
        F[3 * (ni - 1)] += f[2]; F[3 * (ni - 1) + 1] += f[3]; F[3 * (ni - 1) + 2] += f[4]
    for (fid, a, b, Ev, Av, I22, I33, Jv) in frames:
        (xa, ya), (xb, yb) = allxy[a - 1], allxy[b - 1]; Lb = xb - xa
        EI = Ev * I33; GJ = Ev / 2.4 * Jv
        ph = 12 * EI / (Ev / 2.4 * 5 / 6 * Av * Lb**2)       # Timoshenko, As = 5/6 A (Struct)
        kb = EI / (Lb**3 * (1 + ph)) * np.array([[12, 6 * Lb, -12, 6 * Lb], [6 * Lb, (4 + ph) * Lb**2, -6 * Lb, (2 - ph) * Lb**2],
                                     [-12, -6 * Lb, 12, -6 * Lb], [6 * Lb, (2 - ph) * Lb**2, -6 * Lb, (4 + ph) * Lb**2]])
        T = np.diag([1, -1, 1, -1.])     # phi = dw/dx = -thy
        kb = T @ kb @ T
        g = [3 * (a - 1), 3 * (a - 1) + 2, 3 * (b - 1), 3 * (b - 1) + 2]
        K[np.ix_(g, g)] += kb
        gt_ = [3 * (a - 1) + 1, 3 * (b - 1) + 1]
        K[np.ix_(gt_, gt_)] += GJ / Lb * np.array([[1, -1], [-1, 1.]])
    for (ni, kk) in springs: K[3 * (ni - 1), 3 * (ni - 1)] += kk
    act = np.ones(len(nodes), bool); hist = []
    for it in range(60):
        Kt = K.copy()
        for q in range(len(nodes)):
            if act[q]: Kt[3 * q, 3 * q] += kw[q]
        U = np.linalg.solve(Kt, F); hist.append(int(act.sum()))
        w = U[0:3 * len(nodes):3]
        nuevo = (w < 0) if comp else np.ones(len(nodes), bool)
        if (nuevo == act).all(): break
        act = nuevo
    w = U[0::3]
    p = -np.where(act, w[:len(nodes)], 0) * ks          # presion de contacto en el nudo (kPa)
    R = p * kw[:len(nodes)] / ks                                       # fuerza del muelle
    return dict(nombre=nombre, heks=heks, U=U, w=w, act=act, p=p, R=R, hist=hist, nodes=allxy,
                Ke=Ke, skipped=sk, F=F, nc=nc)

def resumen(r):
    nd = r["nodes"]; R = r["R"]; nN = len(R)
    xs = np.array([q[0] for q in nd[:nN]]); ys = np.array([q[1] for q in nd[:nN]])
    Rt = R.sum()
    print(f"{r['nombre']}: it {r['hist']} sumR {Rt:.4f} xR {(R@xs)/Rt:.5f} yR {(R@ys)/Rt:.5f} "
          f"wmin {r['w'][:nN].min()*1000:.4f} mm wmax {r['w'][:nN].max()*1000:.4f} pmax {r['p'].max():.3f} "
          f"activos {r['act'].sum()} skipped {r['skipped']}")

if __name__ == "__main__":
    out = {}
    casos = [
        caso("135 centrica carga 1", 0, 0, 0, -64.4, comp=True),
        caso("135 centrica carga 3 neta", 0, 0, 0, 40.0, comp=True, qall=1044.0888888888889, sin_columna=True),
        caso("136 lindero", -0.4, 0, 0, -34.4, comp=True),
        caso("137 esquinera", -0.4, -0.4, -30.0, -34.4, comp=True),
        caso("138 lindero con viga", -0.4, 0, 0, -34.4, comp=True,
             viga=(4.6, 30e6, 0.4 * 0.9, 0.9 * 0.4**3 / 12, 0.4 * 0.9**3 / 12, 0.013845, ks * 1.44, V)),
        caso("135 centrica carga 4 neta", 0, 0, -100.0, 0, comp=True, qall=(700 + GZ) / 1.44 - 21, sin_columna=True),
    ]
    for i, r in enumerate(casos):
        resumen(r)
        open(f"c{i}.heks", "w", encoding="utf-8").write(r["heks"])
        out[f"c{i}"] = dict(nombre=r["nombre"], U=r["U"].tolist(), act=r["act"].tolist(), hist=r["hist"])
    json.dump(out, open("numpy.json", "w"))
    np.set_printoptions(linewidth=200, precision=1, suppress=True)
    print(casos[0]["Ke"][:6, :6])
