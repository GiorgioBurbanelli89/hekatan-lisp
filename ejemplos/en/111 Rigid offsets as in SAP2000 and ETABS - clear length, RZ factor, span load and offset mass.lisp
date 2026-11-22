# Rigid offsets as in SAP2000 and ETABS: clear length, rigid-zone factor RZ, span load and offset mass
#numerico

#: **What is explained.** In a concrete frame the beam and the column cross at a **joint** that has size: the beam does not start at the column axis, it starts at its **face**. SAP2000 and ETABS model this with **rigid offsets** (*End Length Offsets*) and a **rigid-zone factor RZ** (*Rigid-zone factor*, from 0 to 1). This sheet derives what each one does to stiffness, to the beam load and to mass, and checks it against SAP2000 24.1 and ETABS 22.6 with the measured numbers.
#: **What is being corrected.** In the video "ETABS, SAP2000 and LISP" (20-Sep-2026, subtitle at 00:00:38) it was said: "the stiffness does not change, because the offset does not touch the matrix". That is **true with RZ = 0**, which is what ETABS sets by default: there the offset only discounts weight. But as soon as the engineer raises RZ, the offset **does** enter the matrix and the frame stiffens. RZ = 0 is only the **starting point**; the case in this sheet is RZ = 0.5 and RZ = 1.
#: **Where the CSI numbers come from** (none is invented): repository hekatan-struct, branch main. Law frame: validation/brazos-rigidos/refˍporticoˍcsi.py → tests/datos/brazosˍporticoˍsap2000.json and brazosˍporticoˍetabs.json (OAPI). Frame with the ETABS automatic rule: validation/brazos-rigidos/newblank (porticoˍrz1.s2k and sap/porticoˍrz1.json). Building: validation/brazos-rigidos/plantillasˍrz/v2 (P1 and P1rz05). Offset mass in ETABS: CLAUDE.md of hekatan-struct, section on the Paz 6.3 frame.
#: **Units.** Those of the measured references: kN, m, s; mass in t (= kN·s²/m). To convert to Ecuador's: 1 tonf = 9.80665 kN (50 kN = 5.10 tonf; 10 kN·m = 1.02 tonf·m). Inside the formulas the units are in the text of each variable.

## 1 · What a rigid offset is

#: The bars of the model run from **axis to axis**. But the part of the beam that lies **inside** the column cannot bend like the rest: it is embedded in a much stiffer concrete block. That stretch is the **offset**. CSI describes it with two numbers per bar, off_{I} and off_{J} (offset length at each end), and a factor **RZ**:
#: l = RZ·off        (length taken as **truly rigid**)
#: With RZ = 0 the offset exists (ETABS draws it and reports forces at the face) but **stiffens nothing**. With RZ = 1 the whole offset is rigid. RZ = 0.5 is the intermediate value usually used to account for the joint also deforming.
#: **The ETABS automatic rule** (*Automatic from Connectivity*, measured in ETABS 22 through OAPI on 8-Sep-2026, validation/isse/ETABSˍDEFECTOSˍQUEˍANADE.md):
#| Barra | Brazo en el extremo | Valor en el pórtico de esta hoja |
#|---|---|---:|
#| Viga | **la mitad del lado de la columna** (en la dirección de la viga), en cada extremo que toca columna | 0.40/2 = **0.20 m** |
#| Columna | **el canto entero de la viga** más alta que llega al nudo, solo arriba (la viga cuelga del nivel) | **0.50 m** |
#| Factor RZ | **0** por defecto | se cambia a mano: 0.5, 1 |
#: SAP2000 **does not set offsets** by default: they must be assigned (Assign → Frame → End Length Offsets), with the same off_{I}, off_{J} and RZ.

#dibujo("Beam-column joint with the ETABS rule: beam offset = half the column side, column offset = beam depth (RZ = 1)", ud = m, escala = auto, cotas = m, alto = 230)
#  rect(-0.2, -1.6, 0.4, 1.6, "gruesa")
#  rect(0.2, -0.5, 1.4, 0.5, "gruesa")
#  rect(-1.6, -0.5, 1.4, 0.5, "gruesa")
#  achurado(-0.2, -0.5, 0.4, 0.5, "cruzado")
#  linea(0, 0.3, 0, -1.6, "trazos")
#  linea(-1.6, 0, 1.6, 0, "trazos")
#  linea(0.2, 0, 1.6, 0, "gruesa azul")
#  linea(-0.2, 0, -1.6, 0, "gruesa azul")
#  linea(0, -0.5, 0, -1.6, "gruesa azul")
#  linea(0, 0, 0.2, 0, "gruesa rojo")
#  linea(0, 0, -0.2, 0, "gruesa rojo")
#  linea(0, 0, 0, -0.5, "gruesa rojo")
#  circulo(0, 0, 0.04, "rojo relleno")
#  texto(-1.55, 0.12, "joint: axis with axis, at floor level", 2.4, "i")
#  texto(0.3, -0.3, "beam 30 × 50", 2.4, "i")
#  texto(0.3, -1.1, "column 40 × 40", 2.4, "i")
#  texto(0.3, -1.35, "blue: flexible bar", 2.4, "i")
#  texto(0.3, -1.55, "red: rigid offsets", 2.4, "i")
#  cota(0, 0.45, 0.2, 0.45, 0.08, "0.20")
#  cota(-0.75, 0, -0.75, -0.5, -0.08, "0.50")
#  texto(0.3, 0.45, "beam offset", 2.4, "i")
#  texto(-1.55, -0.75, "column offset", 2.4, "i")
#fin
#: The hatched part is the **joint panel**. In blue, what the program leaves flexible; in red, what it treats as a rigid solid. With RZ = 0.5 only **half** of each red offset is rigid; with RZ = 0, none.

## 2 · The clear length and the bar matrix

### 2a · What changes and what does not

#: The law used by SAP2000 and ETABS (measured against ETABS 22.6 through OAPI on cantilevers and on a frame, and written in the Hekatan Struct solver, getLocalStiffnessMatrix.cpp):
#| Qué | Con qué largo | Por qué |
#|---|---|---|
#| Flexión y cortante | **L_{f} = L − l_{I} − l_{J}** (longitud flexible) | el tramo rígido no se dobla |
#| Axil (E·A/L) y torsión (G·J/L) | **L completa** | CSI: *rigid zones never affect axial and torsional deformation* |
#| Unión con los nudos | **K = Rᵀ·K(L_{f})·R** | la transformación de cuerpo rígido del brazo |

### 2b · The flexible beam, of length L_{f} (Timoshenko, as CSI)

#: CSI includes **shear** deformation with the shear area A_{s} (in a rectangle, 5/6 of the area). With the parameter
#: φ = 12·E·I / (G·A_{s}·L_{f}²)
#: the in-plane bending matrix (degrees v_{I}, θ_{I}, v_{J}, θ_{J}: deflection and rotation at each end **of the flexible stretch**) is the Timoshenko one; with φ = 0 it returns to Euler-Bernoulli:
k_t(EI, ϕ, L_f) = EI/((1 + ϕ)*L_f^3)*[12, 6*L_f, -12, 6*L_f; 6*L_f, (4 + ϕ)*L_f^2, -6*L_f, (2 - ϕ)*L_f^2; -12, -6*L_f, 12, -6*L_f; 6*L_f, (2 - ϕ)*L_f^2, -6*L_f, (4 + ϕ)*L_f^2] @@(rigidez a flexión y cortante del tramo flexible: EI = módulo por inercia, ϕ = parámetro de cortante, L_f = longitud flexible)
#: Bending stiffness goes with 1/L_{f}³ and 1/L_{f}: that is why a slightly shorter flexible stretch weighs a lot in the matrix.

### 2c · The offset: rigid-body transformation R

#: The offset of length l_{I} is a solid that **rotates** with the joint. If joint I moves down v_{I} and rotates θ_{I}, the start of the flexible stretch, at l_{I} from the joint, moves down **v_{I} + l_{I}·θ_{I}** (lever arm) and rotates the same, θ_{I}. At the other end the offset goes backward: the end of the flexible stretch moves down **v_{J} − l_{J}·θ_{J}**. Written as a matrix:
#: [v_{I}′; θ_{I}′; v_{J}′; θ_{J}′] = R·[v_{I}; θ_{I}; v_{J}; θ_{J}]
R_b(l_I, l_J) = [1, l_I, 0, 0; 0, 1, 0, 0; 0, 0, 1, -l_J; 0, 0, 0, 1] @@(transformación de cuerpo rígido de los dos brazos: l_I, l_J = largos rígidos en cada extremo, m)
#: The energy of the flexible stretch, ½·u′ᵀ·K(L_{f})·u′, written with u′ = R·u, is ½·uᵀ·(Rᵀ·K(L_{f})·R)·u. Hence the stiffness **seen from the joints**:
#: K = Rᵀ·K(L_{f})·R
#: With RZ = 0 the rigid lengths are zero, R is the identity and L_{f} = L: the matrix is the usual one. That is what the previous video said, and it only holds there.

### 2d · With numbers: the frame beam

#: The data are those of the frame measured in SAP2000 and ETABS (refˍporticoˍcsi.py): material with E = 2·10⁷ kN/m² and ν = 0.2, weightless; beam of 30 × 50 cm and 6 m; columns of 40 × 40 cm and 3 m. The shear areas are those returned by the program itself (GetSectProps): 5/6 of the area.
E_m = 20000000 @@(módulo de elasticidad del material de la referencia, kN/m²)
ν = 0.2 @@(coeficiente de Poisson)
G_m = E_m/(2*(1 + ν)) @@(módulo de corte, kN/m²)
L_v = 6 @@(luz de la viga de eje a eje, m)
H_c = 3 @@(altura de la columna de eje a eje, m)
A_b = 0.30*0.50 @@(área de la viga, m²)
I_b = 0.30*0.50^3/12 @@(inercia de la viga, flexión en el plano del pórtico, m⁴)
As_b = 5/6*A_b @@(área de cortante de la viga, m²)
A_c = 0.40*0.40 @@(área de la columna, m²)
I_c = 0.40^4/12 @@(inercia de la columna, m⁴)
As_c = 5/6*A_c @@(área de cortante de la columna, m²)
off_v = 0.40/2 @@(brazo de la viga en cada extremo: medio lado de la columna, m)
#: For the beam with **RZ = 1** (whole offset rigid): l_{I} = l_{J} = 0.20 m and the flexible length drops from 6 to 5.60 m.
rz_1 = 1 @@(factor de zona rígida del ejemplo)
lr_v = rz_1*off_v @@(largo rígido en cada extremo de la viga, m)
Lf_v = L_v - 2*lr_v @@(longitud flexible de la viga, m)
ϕ_v = 12*E_m*I_b/(G_m*As_b*Lf_v^2) @@(parámetro de cortante de la viga con su longitud flexible)
Kf_v = k_t(E_m*I_b, ϕ_v, Lf_v) @@(rigidez del tramo flexible de 5.60 m: v en kN/m, θ en kN·m/rad)
Rv_1 = R_b(lr_v, lr_v) @@(transformación de los dos brazos de 0.20 m)
Kn_v = transpose(Rv_1)*Kf_v*Rv_1 @@(rigidez de la viga vista desde los nudos, con sus brazos)
#: And without offsets (RZ = 0), to compare the rotation term:
ϕ_0 = 12*E_m*I_b/(G_m*As_b*L_v^2) @@(parámetro de cortante con la luz entera)
K0_v = k_t(E_m*I_b, ϕ_0, L_v) @@(rigidez de la viga de eje a eje, RZ = 0)
#hide
c_gi = round(Kn_v(2, 2)/K0_v(2, 2), 4)
c_fl = round(Kn_v(1, 1)/K0_v(1, 1), 4)
#show
#: **Reading.** The rotation term θ_{I}–θ_{I} grows **@{c_gi} times** and the deflection term v_{I}–v_{I} **@{c_fl} times** with just 0.20 m of offset on each side: the beam "gets shorter" for bending purposes, and the stiffness goes with the cube of the length. The axial term, in contrast, stays at E·A/L with L = 6 m.

## 3 · The whole frame: what happens with RZ = 0, 0.5 and 1

#: The frame of the references: one 6 m bay, one 3 m story, columns fixed at the base. Joints 1 (0, 0) and 2 (6, 0) at the bottom; 3 (0, 3) and 4 (6, 3) at the top. It is solved **in the plane of the frame**: at each top joint, u_{x}, u_{z} and the rotation θ (6 degrees). Each bar: the 4 × 4 matrix above (with its R) plus the axial E·A/L, rotated to global axes and added.
#: **Two frames** are solved, both with a beam offset of 0.20 m at each end:
#| Pórtico | Brazo de columna (arriba) | Material y cargas | Referencia medida |
#|---|---|---|---|
#| **A · la ley** | 0.25 m (medio canto de viga, puesto **a mano** en refˍporticoˍcsi.py) | E = 2·10⁷ kN/m², sin masa del material; 10 t en cada nudo de arriba | SAP2000 24.1 y ETABS 22.6, RZ 0 / 0.5 / 1 |
#| **B · regla automática de ETABS** | **0.50 m (canto entero)** | E = 2.5·10⁷ kN/m², hormigón ρ = 2.44732 t/m³; 10 kN en x y −10 kN en z en los nudos 3 y 4 | SAP2000 24.1 con RZ = 1 (porticoˍrz1.s2k) |
#hide
E_B = 25000000
G_B = E_B/(2*(1 + ν))
Ic_B = 0.00213333
ρ_h = 2.44732
mA = 10
n_r = 11
rz_g = zeros(n_r, 1)
uxA = zeros(n_r, 1)
ux4A = zeros(n_r, 1)
ryA = zeros(n_r, 1)
uzA = zeros(n_r, 1)
McA = zeros(n_r, 1)
pS_A = zeros(n_r, 1)
pE_A = zeros(n_r, 1)
uxB = zeros(n_r, 1)
pD_B = zeros(n_r, 1)
pN_B = zeros(n_r, 1)
w_v = 10
for ir = 1:n_r
  z_r = (ir - 1)/10
  rz_g(ir) = z_r
  for cs_o = 1:2
    if cs_o == 1
      E_x = E_m
      G_x = G_m
      Ic_x = I_c
      oc_x = 0.25
    else
      E_x = E_B
      G_x = G_B
      Ic_x = Ic_B
      oc_x = 0.50
    end
    K_g = zeros(6, 6)
    kb6 = zeros(6, 6)
    for ib = 1:3
      if ib < 3
        c_o = 0
        s_o = 1
        L_e = H_c
        A_e = A_c
        I_e = Ic_x
        As_e = As_c
        a_I = 0
        a_J = z_r*oc_x
      else
        c_o = 1
        s_o = 0
        L_e = L_v
        A_e = A_b
        I_e = I_b
        As_e = As_b
        a_I = z_r*off_v
        a_J = z_r*off_v
      end
      L_x = L_e - a_I - a_J
      f_x = 12*E_x*I_e/(G_x*As_e*L_x^2)
      R4 = R_b(a_I, a_J)
      k4 = transpose(R4)*k_t(E_x*I_e, f_x, L_x)*R4
      k6 = zeros(6, 6)
      k6([2, 3, 5, 6], [2, 3, 5, 6]) = k4
      k6([1, 4], [1, 4]) = E_x*A_e/L_e*[1, -1; -1, 1]
      q3 = [c_o, s_o, 0; -s_o, c_o, 0; 0, 0, 1]
      Q6 = zeros(6, 6)
      Q6([1, 2, 3], [1, 2, 3]) = q3
      Q6([4, 5, 6], [4, 5, 6]) = q3
      kg = transpose(Q6)*k6*Q6
      if ib == 1
        K_g([1, 2, 3], [1, 2, 3]) = K_g([1, 2, 3], [1, 2, 3]) + kg([4, 5, 6], [4, 5, 6])
      end
      if ib == 2
        K_g([4, 5, 6], [4, 5, 6]) = K_g([4, 5, 6], [4, 5, 6]) + kg([4, 5, 6], [4, 5, 6])
      end
      if ib == 3
        K_g = K_g + kg
        kb6 = k6
      end
    end
    t_m = [1, 2, 4, 5]
    r_m = [3, 6]
    S_c = K_g(r_m, r_m)\K_g(r_m, t_m)
    Kc = K_g(t_m, t_m) - K_g(t_m, r_m)*S_c
    x_i = [1; 0; 1; 0]
    for it = 1:60
      x_i = Kc\x_i
      x_i = x_i/norm(x_i)
    end
    y_i = Kc*x_i
    λ_1 = 0
    for j = 1:4
      λ_1 = λ_1 + x_i(j)*y_i(j)
    end
    if cs_o == 1
      P_L = [50; 0; 0; 0; 0; 0]
      u_L = K_g\P_L
      uxA(ir) = u_L(1)
      ux4A(ir) = u_L(4)
      l_w = z_r*off_v
      Lf_w = L_v - 2*l_w
      F_w = w_v*(Lf_w/2 + l_w)
      M_w = w_v*(Lf_w^2/12 + l_w*Lf_w/2 + l_w^2/2)
      P_w = [0; -F_w; -M_w; 0; -F_w; M_w]
      u_W = K_g\P_w
      uzA(ir) = u_W(2)
      ryA(ir) = -u_W(3)
      f_b = kb6*u_W - P_w
      McA(ir) = -f_b(3) + f_b(2)*off_v - w_v*off_v^2/2
      pS_A(ir) = 2*pi/sqrt(λ_1/mA)
      t_l = [1, 4]
      r_l = [2, 3, 5, 6]
      S_l = K_g(r_l, r_l)\K_g(r_l, t_l)
      K_l = K_g(t_l, t_l) - K_g(t_l, r_l)*S_l
      λ_l = (K_l(1, 1) + K_l(2, 2))/2 - sqrt(((K_l(1, 1) - K_l(2, 2))/2)^2 + K_l(1, 2)^2)
      pE_A(ir) = 2*pi/sqrt(λ_l/mA)
    else
      P_B = [10; -10; 0; 10; -10; 0]
      u_B = K_g\P_B
      uxB(ir) = u_B(1)
      m_D = ρ_h*A_c*H_c/2 + ρ_h*A_b*(L_v - 2*off_v)/2
      m_N = ρ_h*A_c*H_c/2 + ρ_h*A_b*L_v/2
      pD_B(ir) = 2*pi/sqrt(λ_1/m_D)
      pN_B(ir) = 2*pi/sqrt(λ_1/m_N)
    end
  end
end
uA0 = round(uxA(1)*1000, 7)
uA5 = round(uxA(6)*1000, 7)
uA1 = round(uxA(11)*1000, 7)
u4A0 = round(ux4A(1)*1000, 7)
u4A5 = round(ux4A(6)*1000, 7)
u4A1 = round(ux4A(11)*1000, 7)
kA0 = round(50/uxA(1), 1)
kA5 = round(50/uxA(6), 1)
kA1 = round(50/uxA(11), 1)
dA5 = round(100*(1 - uxA(6)/uxA(1)), 2)
dA1 = round(100*(1 - uxA(11)/uxA(1)), 2)
uB0 = round(uxB(1)*1000, 7)
uB5 = round(uxB(6)*1000, 7)
uB1 = round(uxB(11)*1000, 7)
dB5 = round(100*(1 - uxB(6)/uxB(1)), 2)
dB1 = round(100*(1 - uxB(11)/uxB(1)), 2)
uch = round((uxA(1) + uxA(11))/2*1000, 4)
uA5c = round(uxA(6)*1000, 4)
hA = zeros(1, n_r)
hB = zeros(1, n_r)
hC = zeros(1, n_r)
hx = zeros(1, n_r)
for ir = 1:n_r
  hx(ir) = 6*rz_g(ir)
  hA(ir) = (100*uxA(ir)/uxA(1) - 70)/5
  hB(ir) = (100*uxB(ir)/uxB(1) - 70)/5
  hC(ir) = (100*pS_A(ir)/pS_A(1) - 70)/5
end
#show
#: **The lateral displacement** of joint 3 with 50 kN horizontal (frame A), and the **lateral stiffness** k = F/u:
#| RZ | u_{x} nudo 3 [mm] | u_{x} nudo 4 [mm] | k = 50/u_{x} [kN/m] | baja respecto de RZ = 0 |
#|---:|---:|---:|---:|---:|
#| 0 | @{uA0} | @{u4A0} | @{kA0} | — |
#| 0.5 | @{uA5} | @{u4A5} | @{kA5} | @{dA5} % |
#| 1 | @{uA1} | @{u4A1} | @{kA1} | @{dA1} % |
#: And frame B, with the **automatic rule** (column with the full beam depth, 0.50 m): u_{x} of joint 3 = **@{uB0} mm** with RZ = 0, **@{uB5} mm** with RZ = 0.5 and **@{uB1} mm** with RZ = 1: it drops **@{dB5} %** and **@{dB1} %**. The longer column offset stiffens more.

#: The points of the plot (RZ from 0 to 1 every 0.1; vertical, (100·u/u_{RZ=0} − 70)/5, that is 6 = 100 % and 0 = 70 %):
g_x = hx @@(abscisa: 6·RZ, para RZ = 0, 0.1, … 1)
g_A = hA @@(ordenada del pórtico A: desplazamiento lateral relativo a RZ = 0, en la escala de la gráfica)
g_B = hB @@(ordenada del pórtico B, regla automática de ETABS)
g_C = hC @@(ordenada del periodo de ladeo del pórtico A, masa 3D)
#dibujo("Lateral displacement relative to RZ = 0 (vertical axis, from 70 % to 100 %) against RZ (horizontal axis, from 0 to 1). Blue: frame A. Green: frame B (automatic rule). Orange: sway period of A. Red circles: SAP2000 and ETABS measured (B: only RZ = 1, over the RZ = 0 of the sheet)", ud = m, escala = auto, alto = 190)
#  linea(0, 0, 6.3, 0, "media")
#  linea(0, 0, 0, 6.3, "media")
#  linea(0, 6, 6, 6, "puntos")
#  linea(0, 4, 6, 4, "puntos")
#  linea(0, 2, 6, 2, "puntos")
#  linea(3, 0, 3, 6, "puntos")
#  linea(6, 0, 6, 6, "puntos")
#  texto(-0.9, 5.95, "100 %", 2.4, "i")
#  texto(-0.9, 3.95, "90 %", 2.4, "i")
#  texto(-0.9, 1.95, "80 %", 2.4, "i")
#  texto(-0.9, -0.05, "70 %", 2.4, "i")
#  texto(-0.1, -0.45, "RZ = 0", 2.4, "i")
#  texto(2.8, -0.45, "0.5", 2.4, "i")
#  texto(5.9, -0.45, "1", 2.4, "i")
#  polilinea(g_x, g_A, "gruesa azul")
#  polilinea(g_x, g_B, "gruesa verde")
#  polilinea(g_x, g_C, "media naranja")
#  linea(0, 6, 6, 2.9941, "trazos azul")
#  circulo([0, 3, 6], [6, 4.4589, 2.9941], 0.09, "rojo relleno")
#  circulo(6, 1.5028, 0.09, "rojo relleno")
#  texto(6.2, 2.95, "A: u_x", 2.4, "i")
#  texto(6.2, 1.5, "B: u_x", 2.4, "i")
#  texto(6.2, 4.4, "A: period", 2.4, "i")
#fin
#: The red circles are the **measured** u_{x} in SAP2000 and ETABS (both give the same to 7 digits: table in section 7), placed on the same scale. They fall on the sheet's curve.
#: **Is it a straight line, y = m·x + b?** Almost. The dashed line joins RZ = 0 with RZ = 1: it is the line u = m·RZ + b with b = u(0) and m = u(1) − u(0). At RZ = 0.5 the line gives @{uch} mm and the curve @{uA5c} mm: the curve lies a little **below**. The reason: L_{f} = L − RZ·(off_{I} + off_{J}) is indeed a line in RZ, but the stiffness goes with 1/L_{f}³, and that curves it. For an engineer, "every 0.1 of RZ, about 0.03 mm less" is a good rule of thumb in this frame; the exact count is the matrix one.

## 4 · The span load when there is an offset

#: A distributed load w on the beam. The part that falls **on the rigid offset** (length l) bends nothing: it goes **directly to the joint** through the offset lever arm. The part that falls on the flexible stretch L_{f} gives the usual fixed-end reactions, w·L_{f}/2 and w·L_{f}²/12, at the **end of the flexible stretch**, which the offset then carries to the joint. Adding up, at each joint:
#: F = w·(L_{f}/2 + l)
#: M = ±w·(L_{f}²/12 + l·L_{f}/2 + l²/2)
#: (L_{f}²/12: fixed end of the flexible stretch · l·L_{f}/2: its reaction through the lever arm l · l²/2: the load of the offset itself, w·l, with its center at l/2)
#: With l = 0 it returns to w·L/2 and w·L²/12. The force **does not change** (L_{f}/2 + l = L/2 always): what changes is the moment. With w = 10 kN/m:
F_0 = w_v*(L_v/2) @@(fuerza de empotramiento en cada nudo, igual con cualquier RZ, kN)
l_05 = 0.5*off_v @@(largo rígido de la viga con RZ = 0.5, m)
Lf_05 = L_v - 2*l_05 @@(longitud flexible con RZ = 0.5, m)
M_00 = w_v*L_v^2/12 @@(momento de empotramiento con RZ = 0, kN·m)
M_05 = w_v*(Lf_05^2/12 + l_05*Lf_05/2 + l_05^2/2) @@(momento de empotramiento con RZ = 0.5, kN·m)
M_10 = w_v*(Lf_v^2/12 + lr_v*Lf_v/2 + lr_v^2/2) @@(momento de empotramiento con RZ = 1, kN·m)
#: Measured against ETABS 22.6: without this distribution the span load gave a 3.2 % and 6.1 % error (commit 9ed88c9a0 of hekatan-struct). With it, the frame solved with w = 10 kN/m (frame A):
#hide
mc0 = round(McA(1), 6)
mc5 = round(McA(6), 6)
mc1 = round(McA(11), 6)
ry0 = round(ryA(1)*1000, 7)
ry5 = round(ryA(6)*1000, 7)
ry1 = round(ryA(11)*1000, 7)
uz0 = round(uzA(1)*1000, 7)
#show
#| RZ | Giro del nudo 3, θ_{y} [mrad] | Momento M_{3} de la viga **en la cara** de la columna (x = 0.20 m) [kN·m] |
#|---:|---:|---:|
#| 0 | @{ry0} | @{mc0} |
#| 0.5 | @{ry5} | @{mc5} |
#| 1 | @{ry1} | @{mc1} |
#: The drop of joint 3 is @{uz0} mm with the three RZ (it is the axial shortening of the column, and the axial goes with the full L). The **negative moment at the face grows** with RZ: the stiffer joint rotates less and the beam looks more like a fixed one. It is the moment with which the beam is designed. CSI reports at the face ("no output forces are produced within the end offset"); the moment is carried from the joint to the face by equilibrium: M(x) = −M_{I} + V_{I}·x − w·x²/2.

## 5 · The mass inside the offset: SAP2000 versus ETABS

#: Here the two programs **do not do the same thing**, and it must be known in order to compare (measured, CLAUDE.md of hekatan-struct, rigid offsets section):
#| Programa | Masa (y peso propio) del tramo de viga dentro del brazo | Columnas |
#|---|---|---|
#| **ETABS** | **la descuenta**: la viga pesa y vibra con su luz libre L − off_{I} − off_{J}, **con cualquier RZ** (también con RZ = 0) | no descuenta |
#| **SAP2000** | **no la descuenta**: la viga pesa de eje a eje aunque tenga brazos | no descuenta |
#: **Test measured in ETABS** (Paz 6.3 frame, AssembledJointMass): ETABS removed 1857.4 in³ of beam = 2·24.7·24.7 + 2·24.7·12.9, exactly the beam offsets. Free joint mass 5.707652·10⁻³ against 6.048429·10⁻³ without discounting; √(6.048429/5.707652) = 1.02942, and the measured frequency went from 8.8305 to 9.0903 Hz: **+2.94 %**, the same figure by both routes.
#: **In frame B** (lumped mass: half column and half beam at each top joint; the lower half column goes to the support):
m_SAP = ρ_h*A_c*H_c/2 + ρ_h*A_b*L_v/2 @@(masa de un nudo de arriba sin descontar el brazo: SAP2000 con el hormigón tal cual, t)
m_ETB = ρ_h*A_c*H_c/2 + ρ_h*A_b*(L_v - 2*off_v)/2 @@(masa de un nudo de arriba descontando 0.20 m de viga en cada brazo: ETABS, t)
ρ_eq = ρ_h*(L_v - 2*off_v)/L_v @@(densidad rebajada que hay que darle a la viga en SAP2000 para que pese como en ETABS, t/m³)
#: That ρ_{eq} is exactly the 2.28416 that the Hekatan Struct .s2k exporter writes in the beam material (commit 25ca0bdbf): so SAP2000 and ETABS solve **the same** model.
#hide
pd0 = round(pD_B(1), 7)
pd5 = round(pD_B(6), 7)
pd1 = round(pD_B(11), 7)
pn1 = round(pN_B(11), 7)
dmix = round(100*(pN_B(11)/pD_B(11) - 1), 2)
dsw = round(100*(1 - pD_B(11)/pD_B(1)), 2)
#show
#: Sway period of frame B: with the ETABS mass **@{pd0} s** (RZ = 0), **@{pd5} s** (RZ = 0.5) and **@{pd1} s** (RZ = 1): **@{dsw} %** shorter with RZ = 1. If with RZ = 1 the mass is left undiscounted (SAP2000 with the material as is): **@{pn1} s**, **@{dmix} %** longer. **Mixing** "ETABS offsets" with "SAP2000 mass" moves the period as much as RZ itself: that is why both things must be fixed before comparing.

## 6 · The frame solved with RZ = 0, 0.5 and 1: displacement and period

#: The periods of frame A (10 t at each top joint, massless material: the period depends only on stiffness). Here another **mass source** difference appears: SAP2000 puts the 10 t in all three directions (3D mass); ETABS, by default, only in the horizontal ones. With 3D mass the u_{z} drops have inertia and stay in the problem (4 degrees); with lateral mass they are **condensed** like the rotations (2 remain):
#: K̂ = K_{tt} − K_{tr}·K_{rr}⁻¹·K_{rt}        T = 2·π / √(λ_{min}/m)
#hide
ps0 = round(pS_A(1), 7)
ps5 = round(pS_A(6), 7)
ps1 = round(pS_A(11), 7)
pe0 = round(pE_A(1), 7)
pe5 = round(pE_A(6), 7)
pe1 = round(pE_A(11), 7)
dps = round(100*(1 - pS_A(11)/pS_A(1)), 2)
#show
#| RZ | Periodo de ladeo, masa 3D (como SAP2000) [s] | Periodo de ladeo, masa lateral (como ETABS) [s] |
#|---:|---:|---:|
#| 0 | @{ps0} | @{pe0} |
#| 0.5 | @{ps5} | @{pe5} |
#| 1 | @{ps1} | @{pe1} |
#: From RZ = 0 to RZ = 1 the sway period drops **@{dps} %**: the rigid offset does change the dynamics. (The λ_{min} of 4 degrees is obtained by inverse iteration, x ← K̂⁻¹·x; that of 2 degrees, with the eigenvalue formula of a 2 × 2 matrix.) The out-of-plane modes (weak-axis bending and beam torsion) do not appear in this 2D sheet: they are in the table, measured.

## 7 · Comparison: Hekatan LISP, Hekatan Struct, SAP2000 and ETABS

#: **Sources.** SAP2000 24.1 and ETABS 22.6: tests/datos/brazosˍporticoˍsap2000.json and brazosˍporticoˍetabs.json (OAPI, refˍporticoˍcsi.py) for frame A; validation/brazos-rigidos/newblank/sap/porticoˍrz1.json for B; validation/brazos-rigidos/plantillasˍrz/v2/sap and etabs, P1.json and P1rz05.json, for the building. Hekatan Struct: cliModeler + modalAnalysis of hekatan-struct main (1e7fd20e3), run on 4-Oct-2026 with the same .heks as the brazos-portico-csi test (57/57 at 0.000 %).

### 7a · Frame A (the law), RZ 0 → 0.5 → 1
#| Resultado | RZ | Hekatan LISP | Hekatan Struct | SAP2000 24.1 | ETABS 22.6 |
#|---|---:|---:|---:|---:|---:|
#| u_{x} nudo 3, LAT 50 kN [mm] | 0 | @{uA0} | 2.1595725 | 2.1595725 | 2.1595726 |
#| | 0.5 | @{uA5} | 1.9931700 | 1.9931700 | 1.9931700 |
#| | 1 | @{uA1} | 1.8349961 | 1.8349961 | 1.8349961 |
#| θ_{y} nudo 3, w = 10 kN/m [mrad] | 0 | @{ry0} | 0.4004011 | 0.4004011 | 0.4004011 |
#| | 0.5 | @{ry5} | 0.3635708 | 0.3635708 | 0.3635708 |
#| | 1 | @{ry1} | 0.3267740 | 0.3267740 | 0.3267740 |
#| M_{3} viga en la cara [kN·m] | 0 | @{mc0} | −15.858311 | −15.858311 | −15.858311 |
#| | 0.5 | @{mc5} | −17.347755 | −17.347755 | −17.347755 |
#| | 1 | @{mc1} | −18.839270 | −18.839270 | −18.839270 |
#| Periodo de ladeo [s] (SAP: masa 3D; ETABS: lateral) | 0 | @{ps0} / @{pe0} | 0.1836076 | 0.1836076 | 0.1836058 |
#| | 0.5 | @{ps5} / @{pe5} | 0.1763073 | 0.1763073 | 0.1763050 |
#| | 1 | @{ps1} / @{pe1} | 0.1690762 | 0.1690762 | 0.1690733 |
#| Periodo 1, fuera del plano [s] | 0 | (2D: no) | 0.2904147 | 0.2904147 | 0.2904147 |
#| | 1 | (2D: no) | 0.2901787 | 0.2901787 | 0.2901787 |

### 7b · Frame B (ETABS automatic rule: beam 0.20 / 0.20, column 0.50), beam mass discounted
#| Resultado | RZ | Hekatan LISP | Hekatan Struct | SAP2000 24.1 (ρ_{eq} en la viga) |
#|---|---:|---:|---:|---:|
#| u_{x} nudo 3 [mm] | 0 | @{uB0} | 0.6831303 | — (no medido) |
#| | 0.5 | @{uB5} | 0.5999412 | — (no medido) |
#| | 1 | @{uB1} | 0.5295209 | 0.5295209 |
#| Periodo de ladeo [s] | 0 | @{pd0} | 0.0660014 | — (no medido) |
#| | 0.5 | @{pd5} | 0.0618526 | — (no medido) |
#| | 1 | @{pd1} | 0.0581097 | 0.0581097 |
#| Periodo, masa SIN descontar, RZ = 1 [s] | 1 | @{pn1} | 0.0594157 | — |
#: The same frame **drawn in the application** (Rigid offsets: automatic ETABS, RZ = 1) gave u_{x} = 0.5295204 mm against 0.5295209 from SAP2000: 0.00009 % (validation/brazos-rigidos/newblank/hekatanˍu.json, commit 897e58f7f).

### 7c · Building: 3D frame from the templates, automatic ETABS offsets and their discounted mass
#| Resultado | RZ | SAP2000 24.1 | ETABS 22.6 |
#|---|---:|---:|---:|
#| Periodo 1 [s] | 0 | 0.4121746 | 0.4121746 |
#| | 0.5 | 0.3830101 | 0.3830101 |
#| Periodo 3 (torsión) [s] | 0 | 0.3716574 | 0.3716574 |
#| | 0.5 | 0.3456614 | 0.3456614 |
#| Descenso máximo, carga muerta [mm] | 0 | 2.2770591 | 2.2770591 |
#| | 0.5 | 2.1959379 | 2.1959379 |
#: Hekatan Struct exports this building to both programs (s2k with ρ_{eq}, e2k with the full density, which ETABS discounts by itself) and matches them: static 0.0000 % joint by joint and periods to 4 decimals (CLAUDE.md of hekatan-struct, "Whole building, 29-Sep"). With RZ = 0.5 the fundamental period drops 7.1 %.

## 8 · Summary

#: 1. **RZ = 0** (the ETABS default): the offset **does not** change the stiffness; it only moves where the forces are reported (the face) and, in ETABS, **removes the beam mass** inside the joint. What was said in the 20-Sep video holds **only here**.
#: 2. **RZ > 0**: bending and shear with L_{f} = L − l_{I} − l_{J}, axial and torsion with the full L, K = Rᵀ·K(L_{f})·R. The frame stiffens: −@{dA1} % displacement with RZ = 1 (frame A), −@{dB1} % with the automatic rule (frame B).
#: 3. **Span load**: the force does not change, the fixed-end moment does; the moment at the face grows with RZ.
#: 4. **Mass**: ETABS discounts the beam inside the offset, SAP2000 does not. To compare, the beam in SAP2000 carries ρ·(L − off_{I} − off_{J})/L.
#: 5. With all that fixed, Hekatan LISP, Hekatan Struct, SAP2000 and ETABS give **the same** to 6-7 digits.
