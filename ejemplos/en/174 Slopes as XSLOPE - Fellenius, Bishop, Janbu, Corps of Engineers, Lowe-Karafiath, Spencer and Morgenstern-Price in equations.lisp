# Slopes as XSLOPE: the seven limit equilibrium methods, each in its own equation
#numerico

#: **What XSLOPE is.** An open slope stability program (Norm Jones, BYU; Jones & Williams 2026, SoftwareX 36, 103018). It brings seven **limit equilibrium** methods by slices and a **finite element** method (strength reduction). This sheet explains what each one means in mathematics, with the equations of its documentation (docs/lem), and calculates them all on **the same slope and the same circle** to see how they are alike and how they differ. The XSLOPE code was not run: the formulas were read from its documents.
#: **The idea of all of them.** The mass above the failure surface is cut into vertical slices. At the base of each slice the soil resists with Mohr-Coulomb, but only with a fraction 1/F of its strength: c_{m} = c/F and tan φ_{m} = tan φ/F. **F is the safety factor**: the number by which the strength must be divided for the mass to be just in equilibrium.
#: **Why there are so many methods.** Each slice has more unknowns (the normal and shear of the base, and the forces on its faces) than equilibrium equations. Each method **assumes something** about the interslice forces so the problem can be solved. That assumption, and which equilibria it satisfies, is what distinguishes one from another.

## 1 · The example slope

#: Homogeneous 10 m high slope with 2:1 inclination (horizontal:vertical), toe at (0; 0) and crest at 10 m. Dry c-φ soil (u = 0). It is the same ratio c/(γ·H) = 0.05 as example 1 of Griffiths and Lane (1999), one of the cases with which XSLOPE is verified.
H = 10 'height of the slope [m]
gamma = 20 'unit weight of the soil [kN/m3]
c = 10 'effective cohesion [kPa]
phi = 20 'effective friction angle [degrees]
t_p = tan(phi·pi/180) 'tan φ
n_s = 2 'slope inclination: meters horizontal per meter vertical
#: The ground: horizontal at elevation 0 in front of the toe, rises with slope 1/n_{s} up to the crest and continues horizontal at elevation H:
z_t(x) = min(max(x/n_s, 0), H)
#: **The trial circle** (it is not the critical one; it serves to compare the methods on the same surface). It passes through the toe and exits at the crest:
x_c = 8 'center of the circle, x [m]
z_c = 22 'center of the circle, z [m]
R = sqrt(x_c^2 + z_c^2) 'radius: the circle passes through the toe (0; 0) [m]
z_o(x) = z_c - sqrt(R^2 - (x - x_c)^2)
x_a = 0 'entry at the toe [m]
x_b = x_c + sqrt(R^2 - (z_c - H)^2) 'exit at the crest [m]
#hide
z_a0 = z_o(x_a)
P_x = zeros(3, 1)
P_z = zeros(3, 1)
for k = 1:1
  P_x(1) = x_a
  P_z(1) = z_a0
  P_x(2) = x_b
  P_z(2) = H
  P_x(3) = x_c
  P_z(3) = z_c
end
a_e = -90 - atan((x_c - x_a)/(z_c - z_a0))*180/pi
a_s = -90 + atan((x_b - x_c)/(z_c - H))*180/pi
x_cr = n_s*H
x_fin = max(x_b, x_cr) + 0.5*H
x_ini = -0.6*H
G_x = zeros(4, 1)
G_z = zeros(4, 1)
for k = 1:1
  G_x(1) = x_ini
  G_x(3) = x_cr
  G_x(4) = x_fin
  G_z(3) = H
  G_z(4) = H
end
A_x = zeros(41, 1)
A_z = zeros(41, 1)
for k = 1:41
  a_k = (a_e + (a_s - a_e)*(k - 1)/40)*pi/180
  A_x(k) = x_c + R*cos(a_k)
  A_z(k) = z_c + R*sin(a_k)
end
z_fondo = min(A_z) - 0.25*H
x_R = (x_c + x_b)/2 + 0.05*H
z_R = (z_c + H)/2
x_ms = x_cr/2 + 0.1*H
z_ms = H/2 - 0.12*H
x_su = x_cr + 0.25*H
z_su = 0.55*H
x_ct = x_ini + 0.25*H
#show
#dibujo("The slope, the trial circle and its center O (changes with H, n_s, x_c, z_c)", ud = m, escala = auto, cotas = m, alto = 120)
#  poligono(x_ini, z_fondo, x_ini, 0, 0, 0, x_cr, H, x_fin, H, x_fin, z_fondo, "fina gris")
#  polilinea(G_x, G_z, "gruesa")
#  polilinea(A_x, A_z, "gruesa rojo")
#  circulo(x_c, z_c, 0.03*H, "rojo")
#  texto(x_c + 0.06*H, z_c, "O ({x_c:1}; {z_c:1})", 2.6, "i")
#  linea(x_c, z_c, x_a, z_a0, "fina trazos rojo")
#  linea(x_c, z_c, x_b, H, "fina trazos rojo")
#  texto(x_R, z_R, "R = {R:2} m", 2.6, "i")
#  texto(x_ms, z_ms, "{n_s:0}:1", 2.8, "c")
#  texto(x_su, z_su, "c = {c:0} kPa, φ = {phi:0}°, γ = {gamma:0} kN/m³", 2.5, "i")
#  cota(x_ct, 0, x_ct, H, 0, "H = {H:1} m")
#  cota(0, z_fondo + 0.1*H, x_cr, z_fondo + 0.1*H, 0, "{x_cr:1} m")
#  hover(P_x, P_z, "({#1:2}; {#2:2}) m", P_x, P_z)
#fin

## 2 · The slices

#: The mass is cut into n slices of equal width b. In each one the base is the **chord** of the circle between its two edges:
n = 20 'number of slices
b = (x_b - x_a)/n 'width of each slice [m]
#: For each slice i: α_{i} = inclination of the base, Δℓ_{i} = b/cos α_{i} = length of the base, W_{i} = γ·(area) = weight, x_{i} = abscissa of the center, y_{i} = elevation of the center of the base.
#hide
W = zeros(n, 1)
al = zeros(n, 1)
dl = zeros(n, 1)
xm = zeros(n, 1)
yb = zeros(n, 1)
X_j = zeros(n + 1, 1)
for i = 1:n + 1
  X_j(i) = x_a + (i - 1)*b
end
for i = 1:n
  x1 = X_j(i)
  x2 = X_j(i + 1)
  z1 = z_o(x1)
  z2 = z_o(x2)
  al(i) = atan((z2 - z1)/b)
  dl(i) = b/cos(al(i))
  h1 = z_t(x1) - z1
  h2 = z_t(x2) - z2
  hm = z_t((x1 + x2)/2) - (z1 + z2)/2
  W(i) = gamma*b*(h1 + 4*hm + h2)/6
  xm(i) = (x1 + x2)/2
  yb(i) = (z1 + z2)/2
end
cc = c*ones(n, 1)
tp = t_p*ones(n, 1)
uu = zeros(n, 1)
#show
W_T = sum(W) 'total weight of the sliding mass [kN/m]
a_min = min(al)·180/pi 'flattest base (near the toe, negative: it rises toward the toe) [degrees]
a_max = max(al)·180/pi 'steepest base (under the crest) [degrees]
#: The example slice of the force drawings (chapters 3, 4 and 6) is number k_{d}:
k_d = 15 'example slice
#hide
X_z = zeros(3*(n + 1), 1)
Z_z = zeros(3*(n + 1), 1)
Zo_j = zeros(n + 1, 1)
for j = 1:n + 1
  X_z(3*j - 2) = X_j(j)
  X_z(3*j - 1) = X_j(j)
  X_z(3*j) = X_j(j)
  Z_z(3*j - 2) = z_o(X_j(j))
  Z_z(3*j - 1) = z_t(X_j(j))
  Z_z(3*j) = z_o(X_j(j))
  Zo_j(j) = z_o(X_j(j))
end
a_g = zeros(n, 1)
for i = 1:n
  a_g(i) = al(i)*180/pi
end
x_L = X_j(k_d)
x_D = X_j(k_d + 1)
z_bL = z_o(x_L)
z_bD = z_o(x_D)
z_tL = z_t(x_L)
z_tD = z_t(x_D)
x_md = (x_L + x_D)/2
z_md = (z_bL + z_bD)/2
h_d = (z_tL - z_bL + z_tD - z_bD)/2
W_d = W(k_d)
a_d = al(k_d)
a_dg = a_d*180/pi
l_d = dl(k_d)
L_f = 0.45*h_d
x_W0 = x_md
z_W0 = z_md + 0.8*h_d
z_W1 = z_W0 - L_f
x_N0 = x_md + L_f*sin(a_d)
z_N0 = z_md - L_f*cos(a_d)
x_S0 = x_L + 0.1*b + 0.12*h_d*sin(a_d)
z_S0 = z_bL + 0.1*(z_bD - z_bL) - 0.12*h_d*cos(a_d)
x_S1 = x_L + 0.9*b + 0.12*h_d*sin(a_d)
z_S1 = z_bL + 0.9*(z_bD - z_bL) - 0.12*h_d*cos(a_d)
x_hz = x_L + 0.8*b
z_cb = max(z_tL, z_tD) + 0.12*h_d
x_tx = x_D + 0.25*b
z_tW = z_W0 - L_f/2
x_tN = x_N0 + 0.15*b
z_tN = z_N0
x_tS = x_S1 + 0.15*b
z_tS = z_S1 - 0.1*h_d
z_tA = z_md - 0.95*h_d
z_tX = z_md + 0.95*h_d
#show
#dibujo("The slices; in blue, slice k_d of the force drawings", ud = m, escala = auto, alto = 75)
#  polilinea(G_x, G_z, "gruesa")
#  polilinea(X_z, Z_z, "media rojo")
#  poligono(x_L, z_bL, x_D, z_bD, x_D, z_tD, x_L, z_tL, "gruesa azul")
#  cota(x_L, z_cb, x_D, z_cb, 0, "b = {b:2} m")
#  texto(x_md, z_cb + 0.5*h_d, "k_d = {k_d:0} of {n:0}", 2.5, "c")
#  hover(xm, yb, "slice: W = {#1:1} kN/m, α = {#2:1}°, Δℓ = {#3:2} m", W, a_g, dl)
#fin

## 3 · Fellenius (Ordinary Method of Slices, OMS)

#: **Assumption:** the interslice forces **do not exist** (they cancel). **Equilibrium it satisfies:** only the moments of the whole mass about the center of the circle. **Unknowns:** only F; it comes out directly, without iterating.
#: Without forces on the faces, the normal at the base comes from balancing the slice perpendicular to its base: N_{i} = W_{i}·cos α_{i}. The resisting moment (base shear × R) over the driving one (weight × arm, W·R·sin α):
#: F = Σ [c·Δℓ + (W·cos α − u·Δℓ·cos²α)·tan φ] / Σ W·sin α    (XSLOPE uses the form with u·Δℓ·cos²α, the "preferred" one: it avoids negative normals with a lot of water)
F_OMS = sum(cc.*dl + (W.*cos(al) - uu.*dl.*cos(al).^2).*tp)/sum(W.*sin(al)) 'Fellenius
#hide
N_Fd = W_d*cos(a_d)
S_Fd = (c*l_d + N_Fd*t_p)/F_OMS
#show
#dibujo("Fellenius at slice k_d: no forces on the faces; N = W·cos α", ud = m, escala = auto, alto = 150, lado = derecha)
#  poligono(x_L, z_bL, x_D, z_bD, x_D, z_tD, x_L, z_tL, "gruesa")
#  linea(x_L, z_bL, x_hz, z_bL, "fina trazos")
#  flecha(x_W0, z_W0, x_W0, z_W1, "rojo")
#  flecha(x_N0, z_N0, x_md, z_md, "azul")
#  flecha(x_S0, z_S0, x_S1, z_S1, "verde")
#  texto(x_md, z_tX, "W = {W_d:1} kN/m", 2.5, "c")
#  texto(x_tx, z_tA, "α = {a_dg:1}°, Δℓ = {l_d:2} m", 2.5, "i")
#  texto(x_tN, z_tN, "N = W·cos α = {N_Fd:1} kN/m", 2.5, "i")
#  texto(x_tS, z_tS, "S = (c·Δℓ + N·tan φ)/F = {S_Fd:1} kN/m", 2.5, "i")
#fin
#: **What it means:** since it ignores the interslice forces, the normal comes out "wrong" in the steep slices and the result tends to be **conservative** (lower). XSLOPE includes it as a historical and teaching reference, not for design.

## 4 · Simplified Bishop

#: **Assumption:** the interslice forces are **horizontal** (no shear between faces). **Equilibrium it satisfies:** moments about the center and **vertical** forces of each slice. It does not satisfy the horizontal. **Only for circles.**
#: From the vertical equilibrium of the slice, with the mobilized shear S = [c·Δℓ + N'·tan φ]/F, the effective normal comes out:
#: N' = [W − u·Δℓ·cos α − (c·Δℓ/F)·sin α] / m_{α},   m_{α} = cos α + sin α·tan φ/F
#: Carried into the moment equation:
#: F = Σ [(c·Δℓ·cos α + (W − u·Δℓ·cos α)·tan φ) / m_{α}] / Σ W·sin α
#: F appears on both sides (inside m_{α}): it is iterated, starting with F = 1, until it does not change.
#hide
F_B = 1
for k = 1:100
  m_a = cos(al) + sin(al).*tp/F_B
  F_B = sum((cc.*dl.*cos(al) + (W - uu.*dl.*cos(al)).*tp)./m_a)/sum(W.*sin(al))
end
#show
F_Bishop = F_B 'Simplified Bishop
#hide
m_ad = cos(a_d) + sin(a_d)*t_p/F_B
N_Bd = (W_d - c*l_d*sin(a_d)/F_B)/m_ad
S_Bd = (c*l_d + N_Bd*t_p)/F_B
z_EL = z_bL + 0.45*(z_tL - z_bL)
z_ED = z_bD + 0.45*(z_tD - z_bD)
x_EL = x_L - L_f
x_ED = x_D + L_f
#show
#dibujo("Bishop at slice k_d: Eᵢ and Eᵢ₊₁ horizontal", ud = m, escala = auto, alto = 150, lado = derecha)
#  poligono(x_L, z_bL, x_D, z_bD, x_D, z_tD, x_L, z_tL, "gruesa")
#  linea(x_L, z_bL, x_hz, z_bL, "fina trazos")
#  flecha(x_W0, z_W0, x_W0, z_W1, "rojo")
#  flecha(x_N0, z_N0, x_md, z_md, "azul")
#  flecha(x_S0, z_S0, x_S1, z_S1, "verde")
#  texto(x_md, z_tX, "W = {W_d:1} kN/m", 2.5, "c")
#  texto(x_tx, z_tA, "α = {a_dg:1}°, Δℓ = {l_d:2} m", 2.5, "i")
#  flecha(x_EL, z_EL, x_L, z_EL, "naranja")
#  flecha(x_ED, z_ED, x_D, z_ED, "naranja")
#  texto(x_EL, z_EL - 0.1*h_d, "Eᵢ", 2.8, "i")
#  texto(x_ED, z_ED - 0.1*h_d, "Eᵢ₊₁", 2.8, "d")
#  texto(x_tN, z_tN, "N' = {N_Bd:1} kN/m (m_α = {m_ad:3})", 2.5, "i")
#  texto(x_tS, z_tS, "S = {S_Bd:1} kN/m with F = {F_Bishop:3}", 2.5, "i")
#fin
#: **What it means:** on circles it ends up almost the same as the complete methods (Spencer), which is why it is the one used daily. XSLOPE uses it as the reference "moment" value on circular surfaces.

## 5 · Simplified Janbu

#: **Assumption:** no shear between slices (same as Bishop). **Equilibrium it satisfies:** **horizontal** forces of the whole mass and vertical of each slice. It does **not** satisfy moments. It works for circles and non-circles.
#: The normal comes out the same as in Bishop: N = [W − (c·Δℓ − u·Δℓ·tan φ)·sin α/F] / m_{α}. From the horizontal equilibrium (Σ S·cos α = Σ N·sin α):
#: F_{0} = Σ [c·Δℓ + (N − u·Δℓ)·tan φ]·cos α / Σ N·sen α
#hide
F_J = 1
for k = 1:200
  m_a = cos(al) + sin(al).*tp/F_J
  NN = (W - (cc.*dl - uu.*dl.*tp).*sin(al)/F_J)./m_a
  F_J = sum((cc.*dl + (NN - uu.*dl).*tp).*cos(al))/sum(NN.*sin(al))
end
#show
F_0 = F_J 'Uncorrected Janbu
#: Since it forgets the moments, Janbu comes out low. It corrects it with an empirical factor f_{0} that depends on how deep the surface is: d = maximum rise of the arc with respect to the chord, L = length of the chord:
#: f_{0} = 1 + b_{1}·[d/L − 1.4·(d/L)²],   b_{1} = 0.67 (c only), 0.5 (c-φ), 0.31 (φ only). XSLOPE limits d/L ≤ 1/2.8, where the polynomial has its maximum.
L_c = sqrt((x_b - x_a)^2 + (z_o(x_b) - z_o(x_a))^2) 'length of the chord between entry and exit [m]
d_c = R - abs((x_b - x_a)·(z_o(x_a) - z_c) - (x_a - x_c)·(z_o(x_b) - z_o(x_a)))/L_c 'rise of the arc [m]
r_dL = min(d_c/L_c, 1/2.8) 'd/L
b_1 = 0.5 'c-φ soil
f_0 = 1 + b_1·(r_dL - 1.4·r_dL^2) 'Janbu correction factor
F_Janbu = f_0·F_0 'Corrected Janbu
#hide
x_m1 = (x_a + x_b)/2
z_m1 = (z_a0 + H)/2
r_m1 = sqrt((x_m1 - x_c)^2 + (z_m1 - z_c)^2)
x_d1 = x_c + R*(x_m1 - x_c)/r_m1
z_d1 = z_c + R*(z_m1 - z_c)/r_m1
x_L1 = x_m1 - 0.15*H
z_L1 = z_m1 + 0.08*H
x_t5 = x_ini
z_t5 = H + 0.15*H
#show
#dibujo("Janbu: ΣF_x = 0 of the whole mass; f₀ comes from the rise d and the chord L", ud = m, escala = auto, alto = 75)
#  polilinea(G_x, G_z, "gruesa")
#  polilinea(A_x, A_z, "gruesa rojo")
#  linea(x_a, z_a0, x_b, H, "media trazos azul")
#  linea(x_m1, z_m1, x_d1, z_d1, "gruesa azul")
#  texto(x_L1, z_L1, "L = {L_c:2} m", 2.6, "c")
#  texto(x_d1 + 0.04*H, z_d1 - 0.06*H, "d = {d_c:2} m", 2.6, "i")
#  texto(x_t5, z_t5, "f₀ = 1 + b₁·[d/L − 1.4·(d/L)²] = {f_0:4}", 2.6, "i")
#fin
#: **What it means:** it is a quick estimate, above all for non-circular surfaces; XSLOPE recommends confirming it with Spencer.

## 6 · The force sweep (what the four remaining methods use)

#: The methods that follow do put forces on the faces: a resultant Z at each edge j, inclined θ_{j}. If θ_{j} is known, each slice has two unknowns, N' (effective normal of the base) and Z_{i+1} (the force passed to the next one), and two equations (Σ F_{x} = 0 and Σ F_{y} = 0). In matrix form, A·x = b:
#: [tan φ_{m}·cos α − sen α,  −cos θ_{i+1};  tan φ_{m}·sen α + cos α,  −sen θ_{i+1}] · [N'; Z_{i+1}] = [−c_{m}·Δℓ·cos α + u·Δℓ·sen α − Z_{i}·cos θ_{i};  −c_{m}·Δℓ·sen α − u·Δℓ·cos α + W − Z_{i}·sen θ_{i}]
#: One starts at the toe with Z_{1} = 0 and goes slice by slice to the end. Behind the last slice there is no soil: the force that is "left over", Z_{n+1}(F), has to be **zero**. That is the **force residual**: the correct F is the one that makes Z_{n+1}(F) = 0.
#: The **moment residual** of the whole mass about the origin (the interslice forces cancel between neighbors, only weight, normal and base shear remain):
#: R_{m} = Σ [−W·x + (N' + u·Δℓ)·(x·cos α + y·sen α) + S·(x·sen α − y·cos α)],   S = (c·Δℓ + N'·tan φ)/F
#hide
function R = barrido(F, TH, W, al, dl, cc, tp, uu, n)
  Z = 0
  R = zeros(n + 1, 1)
  for i = 1:n
    cm = cc(i)/F
    tm = tp(i)/F
    a11 = tm*cos(al(i)) - sin(al(i))
    a12 = -cos(TH(i + 1))
    a21 = tm*sin(al(i)) + cos(al(i))
    a22 = -sin(TH(i + 1))
    b1 = -cm*dl(i)*cos(al(i)) + uu(i)*dl(i)*sin(al(i)) - Z*cos(TH(i))
    b2 = -cm*dl(i)*sin(al(i)) - uu(i)*dl(i)*cos(al(i)) + W(i) - Z*sin(TH(i))
    de = a11*a22 - a12*a21
    R(i + 1) = (b1*a22 - a12*b2)/de
    Z = (a11*b2 - a21*b1)/de
  end
  R(1) = Z
end
function r = residuo(t, F, TH, W, al, dl, cc, tp, uu, xm, yb, n)
  B = barrido(F, TH, W, al, dl, cc, tp, uu, n)
  if t == 1
    r = B(1)
  else
    r = 0
    for i = 1:n
      Np = B(i + 1)
      S = (cc(i)*dl(i) + Np*tp(i))/F
      r = r - W(i)*xm(i) + (Np + uu(i)*dl(i))*(xm(i)*cos(al(i)) + yb(i)*sin(al(i))) + S*(xm(i)*sin(al(i)) - yb(i)*cos(al(i)))
    end
  end
end
function Fr = raiz(t, TH, Fref, WT, W, al, dl, cc, tp, uu, xm, yb, n)
  lim = 20*WT*(1 + 30*(t - 1))
  r0 = residuo(t, Fref, TH, W, al, dl, cc, tp, uu, xm, yb, n)
  Fl = -1
  Fu = -1
  pu = Fref
  ru = r0
  pd = Fref
  rd = r0
  for k = 1:60
    if Fl < 0
      q = Fref + 0.05*k
      rq = residuo(t, q, TH, W, al, dl, cc, tp, uu, xm, yb, n)
      if ru*rq <= 0
        if abs(ru) + abs(rq) < lim
          Fl = pu
          Fu = q
          rl = ru
          rh = rq
        end
      end
      pu = q
      ru = rq
    end
    if Fl < 0
      q = Fref - 0.05*k
      if q > 0.2
        rq = residuo(t, q, TH, W, al, dl, cc, tp, uu, xm, yb, n)
        if rd*rq <= 0
          if abs(rd) + abs(rq) < lim
            Fl = q
            Fu = pd
            rl = rq
            rh = rd
          end
        end
        pd = q
        rd = rq
      end
    end
  end
  Fr = -1
  if Fl > 0
    for k = 1:40
      if abs(rh) > 0
        Fq = Fu - rh*(Fu - Fl)/(rh - rl)
        rq = residuo(t, Fq, TH, W, al, dl, cc, tp, uu, xm, yb, n)
        if rq*rh < 0
          Fl = Fu
          rl = rh
        else
          rl = rl/2
        end
        Fu = Fq
        rh = rq
        if abs(rq) < 1e-10*WT
          rh = 0
        end
      end
    end
    Fr = Fu
  end
end
function S = lamsol(fx, Fref, WT, W, al, dl, cc, tp, uu, xm, yb, n)
  la = -1
  lb = -1
  dmin = 1e9
  lp = 0
  TH = fx
  for jj = 1:n + 1
    TH(jj) = atan(lp*fx(jj))
  end
  Ff = raiz(1, TH, Fref, WT, W, al, dl, cc, tp, uu, xm, yb, n)
  Fm = raiz(2, TH, Fref, WT, W, al, dl, cc, tp, uu, xm, yb, n)
  gp = Ff - Fm
  mp = Fm
  for s = 1:12
    if la < 0
    lq = 0.1*s
    for jj = 1:n + 1
      TH(jj) = atan(lq*fx(jj))
    end
    Ff = raiz(1, TH, Fref, WT, W, al, dl, cc, tp, uu, xm, yb, n)
    Fm = raiz(2, TH, Fref, WT, W, al, dl, cc, tp, uu, xm, yb, n)
    gq = Ff - Fm
    if mp > 0.4
      if Fm > 0.4
        if gp*gq <= 0
          if abs(Ff - Fref) < dmin
            dmin = abs(Ff - Fref)
            la = lp
            lb = lq
            ga = gp
            gb = gq
          end
        end
      end
    end
    lp = lq
    gp = gq
    mp = Fm
    end
  end
  for k = 1:25
    if abs(gb) > 1e-12
      lq = lb - gb*(lb - la)/(gb - ga)
      for jj = 1:n + 1
        TH(jj) = atan(lq*fx(jj))
      end
      Ff = raiz(1, TH, Fref, WT, W, al, dl, cc, tp, uu, xm, yb, n)
      Fm = raiz(2, TH, Fref, WT, W, al, dl, cc, tp, uu, xm, yb, n)
      gq = Ff - Fm
      if gq*gb < 0
        la = lb
        ga = gb
      else
        ga = ga/2
      end
      lb = lq
      gb = gq
      if abs(gq) < 1e-10
        gb = 0
      end
    end
  end
  S = zeros(4, 1)
  S(1) = lb
  S(2) = Ff
  S(3) = Fm
end
#show
#dibujo("The sweep at slice k_d: unknowns N' and Zᵢ₊₁ (with the Spencer θ)", ud = m, escala = auto, alto = 150, lado = derecha)
#  poligono(x_L, z_bL, x_D, z_bD, x_D, z_tD, x_L, z_tL, "gruesa")
#  linea(x_L, z_bL, x_hz, z_bL, "fina trazos")
#  flecha(x_W0, z_W0, x_W0, z_W1, "rojo")
#  flecha(x_N0, z_N0, x_md, z_md, "azul")
#  flecha(x_S0, z_S0, x_S1, z_S1, "verde")
#  texto(x_md, z_tX, "W = {W_d:1} kN/m", 2.5, "c")
#  texto(x_tx, z_tA, "α = {a_dg:1}°, Δℓ = {l_d:2} m", 2.5, "i")
#  flecha(x_ZL, z_ZL0, x_L, z_ZL, "morado")
#  flecha(x_ZD, z_ZD0, x_D, z_ZD, "morado")
#  texto(x_ZL, z_ZL0 - 0.08*h_d, "Zᵢ (known)", 2.5, "i")
#  texto(x_ZD, z_ZD0 + 0.1*h_d, "Zᵢ₊₁ (unknown)", 2.5, "d")
#  texto(x_md, z_tX + 0.12*h_d, "Z₁ = 0 → … → Zₙ₊₁(F) = 0", 2.5, "i")
#fin
#: The F of each method is searched as XSLOPE asks: the root **closest to the moment value** (Bishop). One leaves F_{Bishop} upward and downward in steps of 0.05 until the first sign change of the residual (discarding the poles, where the determinant of A becomes zero and the residual jumps) and refines with regula falsi: a few passes instead of hundreds.

## 7 · US Army Corps of Engineers (Corps of Engineers #2)

#: **Assumption:** the force on each edge is **parallel to the ground** at the top of that edge: θ_{j} = ground slope at x_{j}. **Equilibrium it satisfies:** only forces (horizontal and vertical of each slice). It does **not** satisfy moments.
#: Z_{n+1}(F) = 0 is solved with the sweep of section 6.
#hide
TH = zeros(n + 1, 1)
for j = 1:n + 1
  TH(j) = atan((z_t(X_j(j) + 0.001) - z_t(X_j(j) - 0.001))/0.002)
end
F_C = raiz(1, TH, F_B, W_T, W, al, dl, cc, tp, uu, xm, yb, n)
#show
F_Corps = F_C 'Corps of Engineers #2
#hide
T_C_x = zeros(3*(n + 1), 1)
T_C_z = zeros(3*(n + 1), 1)
T_C_g = zeros(n + 1, 1)
for j = 1:n + 1
  z0 = z_o(X_j(j))
  T_C_x(3*j - 2) = X_j(j)
  T_C_z(3*j - 2) = z0
  T_C_x(3*j - 1) = X_j(j) + 0.3*H*cos(TH(j))
  T_C_z(3*j - 1) = z0 + 0.3*H*sin(TH(j))
  T_C_x(3*j) = X_j(j)
  T_C_z(3*j) = z0
  T_C_g(j) = TH(j)*180/pi
end
#show
#dibujo("Corps #2: Z parallel to the ground at each edge", ud = m, escala = auto, alto = 80)
#  polilinea(G_x, G_z, "gruesa")
#  polilinea(X_z, Z_z, "fina gris")
#  polilinea(T_C_x, T_C_z, "media morado")
#  texto(x_ini, H, "F = {F_Corps:4}", 2.6, "i")
#  hover(X_j, Zo_j, "θ = {#1:1}°", T_C_g)
#fin
#: **What it means:** XSLOPE warns that this convention systematically gives the **highest** F (least conservative) of all, from a few % up to ~15 % over Spencer. It is reported for comparison; for design, Spencer.

## 8 · Lowe and Karafiath

#: **Assumption:** the force on each edge has the **average** inclination between that of the ground and that of the failure surface at that edge: θ_{j} = [ground slope + circle slope]/2. **Equilibrium it satisfies:** only forces.
#hide
for j = 1:n + 1
  xj = X_j(j)
  g_t = atan((z_t(xj + 0.001) - z_t(xj - 0.001))/0.002)
  g_o = atan((xj - x_c)/sqrt(R^2 - (xj - x_c)^2))
  TH(j) = (g_t + g_o)/2
end
F_L = raiz(1, TH, F_B, W_T, W, al, dl, cc, tp, uu, xm, yb, n)
#show
F_LoweK = F_L 'Lowe and Karafiath
#hide
T_L_x = zeros(3*(n + 1), 1)
T_L_z = zeros(3*(n + 1), 1)
T_L_g = zeros(n + 1, 1)
for j = 1:n + 1
  z0 = z_o(X_j(j))
  T_L_x(3*j - 2) = X_j(j)
  T_L_z(3*j - 2) = z0
  T_L_x(3*j - 1) = X_j(j) + 0.3*H*cos(TH(j))
  T_L_z(3*j - 1) = z0 + 0.3*H*sin(TH(j))
  T_L_x(3*j) = X_j(j)
  T_L_z(3*j) = z0
  T_L_g(j) = TH(j)*180/pi
end
#show
#dibujo("Lowe-Karafiath: θ = average of ground and circle", ud = m, escala = auto, alto = 80)
#  polilinea(G_x, G_z, "gruesa")
#  polilinea(X_z, Z_z, "fina gris")
#  polilinea(T_L_x, T_L_z, "media morado")
#  texto(x_ini, H, "F = {F_LoweK:4}", 2.6, "i")
#  hover(X_j, Zo_j, "θ = {#1:1}°", T_L_g)
#fin
#: **What it means:** according to manual EM 1110-2-1902 it usually ends up within ~10 % of the complete methods. Careful on non-circular surfaces: since θ follows the base, an almost vertical base at the toe lowers F artificially.

## 9 · Spencer

#: **Assumption:** all interslice forces are **parallel**: the same inclination θ at all edges, tan θ = λ. **Equilibrium it satisfies:** **everything** (horizontal forces, vertical forces and moments). **Unknowns:** F and λ.
#: For each λ there are two safety factors: F_{f}(λ), the one that closes the forces (Z_{n+1} = 0), and F_{m}(λ), the one that closes the moments (R_{m} = 0). The solution is the λ where **the two coincide**: F_{f}(λ) = F_{m}(λ). XSLOPE solves it with 2D Newton; here λ is swept from 0 in steps of 0.1 to the first crossing of the two curves and refined with regula falsi (same result).
#hide
S_p = lamsol(ones(n + 1, 1), F_B, W_T, W, al, dl, cc, tp, uu, xm, yb, n)
l_q = S_p(1)
F_f = S_p(2)
F_m = S_p(3)
#show
lambda_S = l_q 'Spencer λ = tan θ
theta_S = atan(l_q)·180/pi 'inclination of the interslice forces [degrees]
#hide
t_hS = atan(lambda_S)
z_ZL = z_bL + 0.45*(z_tL - z_bL)
z_ZD = z_bD + 0.45*(z_tD - z_bD)
x_ZL = x_L - L_f*cos(t_hS)
z_ZL0 = z_ZL - L_f*sin(t_hS)
x_ZD = x_D + L_f*cos(t_hS)
z_ZD0 = z_ZD + L_f*sin(t_hS)
#show
F_Spencer = (F_f + F_m)/2 'Spencer
#hide
for j = 1:n + 1
  TH(j) = atan(l_q)
end
#show
#hide
T_S_x = zeros(3*(n + 1), 1)
T_S_z = zeros(3*(n + 1), 1)
T_S_g = zeros(n + 1, 1)
for j = 1:n + 1
  z0 = z_o(X_j(j))
  T_S_x(3*j - 2) = X_j(j)
  T_S_z(3*j - 2) = z0
  T_S_x(3*j - 1) = X_j(j) + 0.3*H*cos(TH(j))
  T_S_z(3*j - 1) = z0 + 0.3*H*sin(TH(j))
  T_S_x(3*j) = X_j(j)
  T_S_z(3*j) = z0
  T_S_g(j) = TH(j)*180/pi
end
#show
#dibujo("Spencer: all Z parallel, constant θ", ud = m, escala = auto, alto = 80)
#  polilinea(G_x, G_z, "gruesa")
#  polilinea(X_z, Z_z, "fina gris")
#  polilinea(T_S_x, T_S_z, "media morado")
#  texto(x_ini, H, "θ = {theta_S:1}° at all edges, F = {F_Spencer:4}", 2.6, "i")
#  hover(X_j, Zo_j, "θ = {#1:1}°", T_S_g)
#fin
dF_S = F_f - F_m 'check: F from forces − F from moments (must be ≈ 0)
#: **What it means:** it is the "rigorous" method that XSLOPE recommends for design: it does not assume the direction of the interslice forces, it **calculates** it.

## 10 · Morgenstern-Price

#: **Assumption:** the inclination of the interslice forces **varies** along the surface according to a function f(x) that is chosen: tan θ_{j} = λ·f(x_{j}). XSLOPE uses by default the **half sine wave**, which equals 0 at both ends (no shear is transmitted beyond the toe or the crest):
#: f(x) = sen[π·(x − x_{L})/(x_{R} − x_{L})]
#: **Equilibrium it satisfies:** everything, like Spencer. **Unknowns:** F and λ, with the same two conditions F_{f}(λ) = F_{m}(λ). With f(x) = 1 it is **exactly Spencer** (XSLOPE is verified this way, to 10⁻¹⁰).
#hide
f_x = zeros(n + 1, 1)
for j = 1:n + 1
  f_x(j) = sin(pi*(X_j(j) - x_a)/(x_b - x_a))
end
S_p = lamsol(f_x, F_B, W_T, W, al, dl, cc, tp, uu, xm, yb, n)
l_q = S_p(1)
F_f = S_p(2)
F_m = S_p(3)
#show
lambda_MP = l_q 'Morgenstern-Price λ (with half sine wave)
F_MP = (F_f + F_m)/2 'Morgenstern-Price
#hide
TH = zeros(n + 1, 1)
F_xz = zeros(n + 1, 1)
for j = 1:n + 1
  TH(j) = atan(l_q*f_x(j))
  F_xz(j) = z_fondo + 0.3*H*f_x(j)
end
#show
#hide
T_M_x = zeros(3*(n + 1), 1)
T_M_z = zeros(3*(n + 1), 1)
T_M_g = zeros(n + 1, 1)
for j = 1:n + 1
  z0 = z_o(X_j(j))
  T_M_x(3*j - 2) = X_j(j)
  T_M_z(3*j - 2) = z0
  T_M_x(3*j - 1) = X_j(j) + 0.3*H*cos(TH(j))
  T_M_z(3*j - 1) = z0 + 0.3*H*sin(TH(j))
  T_M_x(3*j) = X_j(j)
  T_M_z(3*j) = z0
  T_M_g(j) = TH(j)*180/pi
end
#show
#dibujo("Morgenstern-Price: tan θ = λ·f(x) (below, the curve f(x))", ud = m, escala = auto, alto = 80)
#  polilinea(G_x, G_z, "gruesa")
#  polilinea(X_z, Z_z, "fina gris")
#  polilinea(T_M_x, T_M_z, "media morado")
#  polilinea(X_j, F_xz, "media azul")
#  linea(x_a, z_fondo, x_b, z_fondo, "fina")
#  texto(x_b, z_fondo + 0.1*H, "f(x)", 2.6, "i")
#  texto(x_ini, H, "λ = {lambda_MP:3}, F = {F_MP:4}", 2.6, "i")
#  hover(X_j, Zo_j, "θ = {#1:1}°", T_M_g)
#fin
dF_MP = F_f - F_m 'check: F from forces − F from moments (must be ≈ 0)
#: **What it means:** it is the most general. F hardly depends on the chosen f(x); λ does.

## 11 · The seven together

F_OMS = F_OMS 'Fellenius (moments only, no interslice forces)
F_Bishop = F_Bishop 'Bishop (moments + vertical, horizontal forces)
F_Janbu = F_Janbu 'Corrected Janbu (forces only, no shear between slices)
F_Corps = F_Corps 'Corps of Engineers #2 (forces only, θ = ground)
F_LoweK = F_LoweK 'Lowe-Karafiath (forces only, θ = average of ground and base)
F_Spencer = F_Spencer 'Spencer (everything, constant θ)
F_MP = F_MP 'Morgenstern-Price (everything, θ = λ·f(x))
#hide
F_v = zeros(7, 1)
B_x = zeros(7, 1)
B_h = zeros(7, 1)
B_c = zeros(7, 1)
B_t = zeros(7, 1)
B_y = zeros(7, 1)
for k = 1:1
  F_v(1) = F_OMS
  F_v(2) = F_Bishop
  F_v(3) = F_Janbu
  F_v(4) = F_Corps
  F_v(5) = F_LoweK
  F_v(6) = F_Spencer
  F_v(7) = F_MP
end
F_0b = floor(10*min(F_v) - 1)/10
for j = 1:7
  B_x(j) = 1.5*(j - 1)
  B_h(j) = 20*(F_v(j) - F_0b)
  B_c(j) = B_x(j) + 0.5
  B_t(j) = B_h(j) + 0.25
  B_y(j) = -0.5 - 0.6*(j - 2*floor(j/2))
end
#show
#dibujo("The seven F", alto = 110)
#  rect(B_x, 0, 1, B_h, "media azul")
#  linea(-0.5, 0, 10.5, 0, "media")
#  texto(-0.6, 0, "{F_0b:2}", 2.5, "d")
#  texto(B_c, B_t, {"{F_OMS:3}", "{F_Bishop:3}", "{F_Janbu:3}", "{F_Corps:3}", "{F_LoweK:3}", "{F_Spencer:3}", "{F_MP:3}"}, 2.4, "c")
#  texto(B_c, B_y, {"OMS", "Bishop", "Janbu", "Corps", "L-K", "Spencer", "M-P"}, 2.4, "c")
#  hover(B_c, B_h, "F = {#1:4}", F_v)
#fin
#: **How to read it.** The two complete methods (Spencer and Morgenstern-Price) and Bishop come out almost equal on a circle: they satisfy the moments, which is what weighs most. Fellenius comes out lower because it ignores the interslice forces. The force-only ones depend on the θ they assume: Corps #2 comes out higher, as XSLOPE warns.
#: This is a trial circle; for the **safety factor of the slope** the critical circle (the one with minimum F) has to be searched, which XSLOPE does with its automatic search.

## 12 · The other XSLOPE algorithm: finite elements with strength reduction (SSR)

#: It uses no slices. The slope is modeled with finite elements (XSLOPE uses 6-node triangles by default) and the soil strength is **reduced** by a factor F until the slope cannot remain in equilibrium:
#: c_{r} = c/F,   tan φ_{r} = tan φ/F
#hide
c_r1 = c/F_Spencer
p_r1 = atan(t_p/F_Spencer)*180/pi
k_1 = 14
k_2 = 30
x_f1 = A_x(k_1) + 0.15*H
z_f1 = A_z(k_1) + 0.25*H
x_f2 = A_x(k_2) + 0.15*H
z_f2 = A_z(k_2) + 0.25*H
x_f1b = A_x(k_1) - 0.05*H
z_f1b = A_z(k_1) + 0.13*H
x_f2b = A_x(k_2) - 0.05*H
z_f2b = A_z(k_2) + 0.13*H
#show
#dibujo("SSR: no slices; at failure c and tan φ are already divided by F", ud = m, escala = auto, alto = 75)
#  poligono(x_ini, z_fondo, x_ini, 0, 0, 0, x_cr, H, x_fin, H, x_fin, z_fondo, "fina gris")
#  polilinea(G_x, G_z, "gruesa")
#  polilinea(A_x, A_z, "muygruesa naranja")
#  flecha(x_f1, z_f1, x_f1b, z_f1b, "rojo")
#  flecha(x_f2, z_f2, x_f2b, z_f2b, "rojo")
#  texto(x_su, z_su + 0.15*H, "with F = {F_Spencer:3}", 2.6, "i")
#  texto(x_su, z_su, "c_r = c/F = {c_r1:2} kPa", 2.6, "i")
#  texto(x_su, z_su - 0.15*H, "φ_r = atan(tan φ/F) = {p_r1:1}°", 2.6, "i")
#fin
#: **Plasticity:** Mohr-Coulomb, with the Smith and Griffiths **explicit viscoplastic** method: the elastic stiffness K is factorized **only once**; at each step, the excess over the yield surface is converted into viscoplastic strain, ε^{vp} += Δt·∂Q/∂σ·⟨f⟩, with Δt = 4·(1 + ν)/(3·E), and returns as load. **Non-associated** flow with dilatancy ψ = 0.
#: **When it fails:** XSLOPE uses a hybrid criterion: (1) that it does not converge (displacements and forces per node with tolerance 10⁻³) and (2) that the displacement grows with respect to the elastic one, u/u_{elastic} ≥ 1.5. The failure F is searched by **bisection** between 1 and 2 (widening the interval if needed) with tolerance 0.01.
#: **What it means:** nothing has to be assumed about the shape of the surface or about the interslice forces: the failure **appears** by itself, as the zone where the shear strain concentrates. Hekatan Geotechnic does the same with Newton-Raphson instead of the viscoplastic method (sheet 164).
