# Brazos rígidos como SAP2000 y ETABS: longitud libre, factor de zona rígida RZ, carga de vano y masa del brazo
#numerico

#: **Qué se explica.** En un pórtico de hormigón la viga y la columna se cruzan en un **nudo** que tiene tamaño: la viga no empieza en el eje de la columna, empieza en su **cara**. SAP2000 y ETABS lo modelan con **brazos rígidos** (*End Length Offsets*) y un **factor de zona rígida RZ** (*Rigid-zone factor*, de 0 a 1). Esta hoja deduce qué hace cada uno con la rigidez, con la carga de la viga y con la masa, y lo comprueba contra SAP2000 24.1 y ETABS 22.6 con los números medidos.
#: **Lo que se corrige.** En el vídeo «ETABS, SAP2000 y LISP» (20-sep-2026, subtítulo de 00:00:38) se dijo: «la rigidez no cambia, porque el brazo no toca la matriz». Es **cierto con RZ = 0**, que es lo que ETABS pone por defecto: ahí el brazo solo descuenta peso. Pero en cuanto el ingeniero sube RZ, el brazo **sí** entra en la matriz y el pórtico se rigidiza. RZ = 0 es solo el **punto de partida**; el caso de esta hoja es RZ = 0.5 y RZ = 1.
#: **De dónde salen los números de CSI** (no se inventa ninguno): repositorio hekatan-struct, rama main. Pórtico de la ley: validation/brazos-rigidos/refˍporticoˍcsi.py → tests/datos/brazosˍporticoˍsap2000.json y brazosˍporticoˍetabs.json (OAPI). Pórtico con la regla automática de ETABS: validation/brazos-rigidos/newblank (porticoˍrz1.s2k y sap/porticoˍrz1.json). Edificio: validation/brazos-rigidos/plantillasˍrz/v2 (P1 y P1rz05). Masa del brazo en ETABS: CLAUDE.md de hekatan-struct, apartado del pórtico de Paz 6.3.
#: **Unidades.** Las de las referencias medidas: kN, m, s; masa en t (= kN·s²/m). Para pasar a las de Ecuador: 1 tonf = 9.80665 kN (50 kN = 5.10 tonf; 10 kN·m = 1.02 tonf·m). Dentro de las fórmulas las unidades van en el texto de cada variable.

## 1 · Qué es el brazo rígido

#: Las barras del modelo van de **eje a eje**. Pero la parte de viga que está **dentro** de la columna no se puede doblar como el resto: está metida en un bloque de hormigón mucho más rígido. Ese tramo es el **brazo**. CSI lo describe con dos números por barra, off_{I} y off_{J} (largo del brazo en cada extremo), y un factor **RZ**:
#: l = RZ·off        (largo que se toma como **realmente rígido**)
#: Con RZ = 0 el brazo existe (ETABS lo dibuja y reporta los esfuerzos en la cara) pero **no rigidiza nada**. Con RZ = 1 todo el brazo es rígido. RZ = 0.5 es el valor intermedio que suele usarse para tomar en cuenta que el nudo también se deforma.
#: **La regla automática de ETABS** (*Automatic from Connectivity*, medida en ETABS 22 por OAPI el 8-sep-2026, validation/isse/ETABSˍDEFECTOSˍQUEˍANADE.md):
#| Barra | Brazo en el extremo | Valor en el pórtico de esta hoja |
#|---|---|---:|
#| Viga | **la mitad del lado de la columna** (en la dirección de la viga), en cada extremo que toca columna | 0.40/2 = **0.20 m** |
#| Columna | **el canto entero de la viga** más alta que llega al nudo, solo arriba (la viga cuelga del nivel) | **0.50 m** |
#| Factor RZ | **0** por defecto | se cambia a mano: 0.5, 1 |
#: SAP2000 **no pone brazos** por defecto: hay que asignarlos (Assign → Frame → End Length Offsets), con el mismo off_{I}, off_{J} y RZ.

#dibujo("Nudo viga-columna con la regla de ETABS: brazo de viga = medio lado de columna, brazo de columna = canto de la viga (RZ = 1)", ud = m, escala = auto, cotas = m, alto = 230)
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
#  texto(-1.55, 0.12, "nudo: eje con eje, al nivel del piso", 2.4, "i")
#  texto(0.3, -0.3, "viga 30 × 50", 2.4, "i")
#  texto(0.3, -1.1, "columna 40 × 40", 2.4, "i")
#  texto(0.3, -1.35, "azul: barra flexible", 2.4, "i")
#  texto(0.3, -1.55, "rojo: brazos rígidos", 2.4, "i")
#  cota(0, 0.45, 0.2, 0.45, 0.08, "0.20")
#  cota(-0.75, 0, -0.75, -0.5, -0.08, "0.50")
#  texto(0.3, 0.45, "brazo de viga", 2.4, "i")
#  texto(-1.55, -0.75, "brazo de columna", 2.4, "i")
#fin
#: La parte rayada es el **panel del nudo**. En azul, lo que el programa deja flexible; en rojo, lo que trata como un sólido rígido. Con RZ = 0.5 solo la **mitad** de cada brazo rojo es rígida; con RZ = 0, nada.

## 2 · La longitud libre y la matriz de la barra

### 2a · Lo que cambia y lo que no

#: La ley que usan SAP2000 y ETABS (medida contra ETABS 22.6 por OAPI en voladizos y en un pórtico, y escrita en el solver de Hekatan Struct, getLocalStiffnessMatrix.cpp):
#| Qué | Con qué largo | Por qué |
#|---|---|---|
#| Flexión y cortante | **L_{f} = L − l_{I} − l_{J}** (longitud flexible) | el tramo rígido no se dobla |
#| Axil (E·A/L) y torsión (G·J/L) | **L completa** | CSI: *rigid zones never affect axial and torsional deformation* |
#| Unión con los nudos | **K = Rᵀ·K(L_{f})·R** | la transformación de cuerpo rígido del brazo |

### 2b · La viga flexible, de largo L_{f} (Timoshenko, como CSI)

#: CSI incluye la deformación por **cortante** con el área de cortante A_{s} (en un rectángulo, 5/6 del área). Con el parámetro
#: φ = 12·E·I / (G·A_{s}·L_{f}²)
#: la matriz de flexión en el plano (grados v_{I}, θ_{I}, v_{J}, θ_{J}: flecha y giro en cada extremo **del tramo flexible**) es la de Timoshenko; con φ = 0 vuelve a la de Euler-Bernoulli:
k_t(EI, ϕ, L_f) = EI/((1 + ϕ)*L_f^3)*[12, 6*L_f, -12, 6*L_f; 6*L_f, (4 + ϕ)*L_f^2, -6*L_f, (2 - ϕ)*L_f^2; -12, -6*L_f, 12, -6*L_f; 6*L_f, (2 - ϕ)*L_f^2, -6*L_f, (4 + ϕ)*L_f^2] @@(rigidez a flexión y cortante del tramo flexible: EI = módulo por inercia, ϕ = parámetro de cortante, L_f = longitud flexible)
#: La rigidez a flexión va con 1/L_{f}³ y 1/L_{f}: por eso un tramo flexible algo más corto pesa mucho en la matriz.

### 2c · El brazo: transformación de cuerpo rígido R

#: El brazo de largo l_{I} es un sólido que **gira** con el nudo. Si el nudo I baja v_{I} y gira θ_{I}, el principio del tramo flexible, a l_{I} del nudo, baja **v_{I} + l_{I}·θ_{I}** (palanca) y gira lo mismo, θ_{I}. En el otro extremo el brazo va hacia atrás: el final del tramo flexible baja **v_{J} − l_{J}·θ_{J}**. Escrito en matriz:
#: [v_{I}′; θ_{I}′; v_{J}′; θ_{J}′] = R·[v_{I}; θ_{I}; v_{J}; θ_{J}]
R_b(l_I, l_J) = [1, l_I, 0, 0; 0, 1, 0, 0; 0, 0, 1, -l_J; 0, 0, 0, 1] @@(transformación de cuerpo rígido de los dos brazos: l_I, l_J = largos rígidos en cada extremo, m)
#: La energía del tramo flexible, ½·u′ᵀ·K(L_{f})·u′, escrita con u′ = R·u, es ½·uᵀ·(Rᵀ·K(L_{f})·R)·u. De ahí la rigidez **vista desde los nudos**:
#: K = Rᵀ·K(L_{f})·R
#: Con RZ = 0 los largos rígidos son cero, R es la identidad y L_{f} = L: la matriz es la de siempre. Eso es lo que decía el vídeo anterior, y solo vale ahí.

### 2d · Con números: la viga del pórtico

#: Los datos son los del pórtico medido en SAP2000 y ETABS (refˍporticoˍcsi.py): material de E = 2·10⁷ kN/m² y ν = 0.2, sin peso; viga de 30 × 50 cm y 6 m; columnas de 40 × 40 cm y 3 m. Las áreas de cortante son las que devuelve el propio programa (GetSectProps): 5/6 del área.
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
#: Para la viga con **RZ = 1** (todo el brazo rígido): l_{I} = l_{J} = 0.20 m y la longitud flexible baja de 6 a 5.60 m.
rz_1 = 1 @@(factor de zona rígida del ejemplo)
lr_v = rz_1*off_v @@(largo rígido en cada extremo de la viga, m)
Lf_v = L_v - 2*lr_v @@(longitud flexible de la viga, m)
ϕ_v = 12*E_m*I_b/(G_m*As_b*Lf_v^2) @@(parámetro de cortante de la viga con su longitud flexible)
Kf_v = k_t(E_m*I_b, ϕ_v, Lf_v) @@(rigidez del tramo flexible de 5.60 m: v en kN/m, θ en kN·m/rad)
Rv_1 = R_b(lr_v, lr_v) @@(transformación de los dos brazos de 0.20 m)
Kn_v = transpose(Rv_1)*Kf_v*Rv_1 @@(rigidez de la viga vista desde los nudos, con sus brazos)
#: Y sin brazos (RZ = 0), para comparar el término de giro:
ϕ_0 = 12*E_m*I_b/(G_m*As_b*L_v^2) @@(parámetro de cortante con la luz entera)
K0_v = k_t(E_m*I_b, ϕ_0, L_v) @@(rigidez de la viga de eje a eje, RZ = 0)
#hide
c_gi = round(Kn_v(2, 2)/K0_v(2, 2), 4)
c_fl = round(Kn_v(1, 1)/K0_v(1, 1), 4)
#show
#: **Lectura.** El término de giro θ_{I}–θ_{I} crece **@{c_gi} veces** y el de flecha v_{I}–v_{I} **@{c_fl} veces** con solo 0.20 m de brazo en cada lado: la viga «se acorta» a efectos de flexión, y la rigidez va con el cubo del largo. El axil, en cambio, se queda en E·A/L con L = 6 m.

## 3 · El pórtico entero: qué pasa con RZ = 0, 0.5 y 1

#: El pórtico de las referencias: un vano de 6 m, un piso de 3 m, columnas empotradas en la base. Nudos 1 (0, 0) y 2 (6, 0) abajo; 3 (0, 3) y 4 (6, 3) arriba. Se resuelve **en el plano del pórtico**: en cada nudo de arriba, u_{x}, u_{z} y el giro θ (6 grados). Cada barra: la matriz 4 × 4 de arriba (con su R) más el axil E·A/L, girada a ejes globales y sumada.
#: Se resuelven **dos pórticos**, los dos con viga de brazo 0.20 m en cada extremo:
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
#: **El desplazamiento lateral** del nudo 3 con 50 kN horizontales (pórtico A), y la **rigidez lateral** k = F/u:
#| RZ | u_{x} nudo 3 [mm] | u_{x} nudo 4 [mm] | k = 50/u_{x} [kN/m] | baja respecto de RZ = 0 |
#|---:|---:|---:|---:|---:|
#| 0 | @{uA0} | @{u4A0} | @{kA0} | — |
#| 0.5 | @{uA5} | @{u4A5} | @{kA5} | @{dA5} % |
#| 1 | @{uA1} | @{u4A1} | @{kA1} | @{dA1} % |
#: Y el pórtico B, con la **regla automática** (columna con el canto entero de la viga, 0.50 m): u_{x} del nudo 3 = **@{uB0} mm** con RZ = 0, **@{uB5} mm** con RZ = 0.5 y **@{uB1} mm** con RZ = 1: baja un **@{dB5} %** y un **@{dB1} %**. El brazo de columna más largo rigidiza más.

#: Los puntos de la gráfica (RZ de 0 a 1 cada 0.1; en vertical, (100·u/u_{RZ=0} − 70)/5, o sea 6 = 100 % y 0 = 70 %):
g_x = hx @@(abscisa: 6·RZ, para RZ = 0, 0.1, … 1)
g_A = hA @@(ordenada del pórtico A: desplazamiento lateral relativo a RZ = 0, en la escala de la gráfica)
g_B = hB @@(ordenada del pórtico B, regla automática de ETABS)
g_C = hC @@(ordenada del periodo de ladeo del pórtico A, masa 3D)
#dibujo("Desplazamiento lateral relativo a RZ = 0 (eje vertical, de 70 % a 100 %) contra RZ (eje horizontal, de 0 a 1). Azul: pórtico A. Verde: pórtico B (regla automática). Naranja: periodo de ladeo del A. Círculos rojos: SAP2000 y ETABS medidos (B: solo RZ = 1, sobre el RZ = 0 de la hoja)", ud = m, escala = auto, alto = 190)
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
#  texto(6.2, 4.4, "A: periodo", 2.4, "i")
#fin
#: Los círculos rojos son los u_{x} **medidos** en SAP2000 y ETABS (los dos dan lo mismo a 7 cifras: tabla del apartado 7), puestos en la misma escala. Caen sobre la curva de la hoja.
#: **¿Es una recta, y = m·x + b?** Casi. La línea a trazos une RZ = 0 con RZ = 1: es la recta u = m·RZ + b con b = u(0) y m = u(1) − u(0). En RZ = 0.5 la recta da @{uch} mm y la curva @{uA5c} mm: la curva queda un poco **por debajo**. El porqué: L_{f} = L − RZ·(off_{I} + off_{J}) sí es una recta en RZ, pero la rigidez va con 1/L_{f}³, y eso curva. Para un ingeniero, «cada 0.1 de RZ, unos 0.03 mm menos» es una buena regla mental en este pórtico; la cuenta exacta es la de la matriz.

## 4 · La carga de vano cuando hay brazo

#: Una carga repartida w sobre la viga. La parte que cae **sobre el brazo rígido** (largo l) no dobla nada: va **directa al nudo** por la palanca del brazo. La que cae sobre el tramo flexible L_{f} da las reacciones de empotramiento de siempre, w·L_{f}/2 y w·L_{f}²/12, en el **extremo del tramo flexible**, que luego el brazo lleva al nudo. Sumando, en cada nudo:
#: F = w·(L_{f}/2 + l)
#: M = ±w·(L_{f}²/12 + l·L_{f}/2 + l²/2)
#: (L_{f}²/12: empotramiento del tramo flexible · l·L_{f}/2: su reacción por la palanca l · l²/2: la carga del propio brazo, w·l, con su centro a l/2)
#: Con l = 0 vuelve a w·L/2 y w·L²/12. La fuerza **no cambia** (L_{f}/2 + l = L/2 siempre): lo que cambia es el momento. Con w = 10 kN/m:
F_0 = w_v*(L_v/2) @@(fuerza de empotramiento en cada nudo, igual con cualquier RZ, kN)
l_05 = 0.5*off_v @@(largo rígido de la viga con RZ = 0.5, m)
Lf_05 = L_v - 2*l_05 @@(longitud flexible con RZ = 0.5, m)
M_00 = w_v*L_v^2/12 @@(momento de empotramiento con RZ = 0, kN·m)
M_05 = w_v*(Lf_05^2/12 + l_05*Lf_05/2 + l_05^2/2) @@(momento de empotramiento con RZ = 0.5, kN·m)
M_10 = w_v*(Lf_v^2/12 + lr_v*Lf_v/2 + lr_v^2/2) @@(momento de empotramiento con RZ = 1, kN·m)
#: Medido contra ETABS 22.6: sin este reparto la carga de vano daba un 3.2 % y un 6.1 % de error (commit 9ed88c9a0 de hekatan-struct). Con él, el pórtico resuelto con w = 10 kN/m (pórtico A):
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
#: El descenso del nudo 3 es @{uz0} mm con los tres RZ (es el acortamiento axil de la columna, y el axil va con la L completa). El **momento negativo en la cara crece** con RZ: el nudo, más rígido, gira menos y la viga se parece más a una empotrada. Es el momento con el que se diseña la viga. CSI reporta en la cara («no output forces are produced within the end offset»); el momento se lleva del nudo a la cara por equilibrio: M(x) = −M_{I} + V_{I}·x − w·x²/2.

## 5 · La masa dentro del brazo: SAP2000 contra ETABS

#: Aquí los dos programas **no hacen lo mismo**, y hay que saberlo para comparar (medido, CLAUDE.md de hekatan-struct, apartado de brazos rígidos):
#| Programa | Masa (y peso propio) del tramo de viga dentro del brazo | Columnas |
#|---|---|---|
#| **ETABS** | **la descuenta**: la viga pesa y vibra con su luz libre L − off_{I} − off_{J}, **con cualquier RZ** (también con RZ = 0) | no descuenta |
#| **SAP2000** | **no la descuenta**: la viga pesa de eje a eje aunque tenga brazos | no descuenta |
#: **Prueba medida en ETABS** (pórtico de Paz 6.3, AssembledJointMass): ETABS quitó 1857.4 in³ de viga = 2·24.7·24.7 + 2·24.7·12.9, exactamente los brazos de las vigas. Masa del nudo libre 5.707652·10⁻³ contra 6.048429·10⁻³ sin descontar; √(6.048429/5.707652) = 1.02942, y la frecuencia medida pasó de 8.8305 a 9.0903 Hz: **+2.94 %**, la misma cifra por las dos vías.
#: **En el pórtico B** (masa concentrada: media columna y media viga en cada nudo de arriba; la media columna de abajo va al apoyo):
m_SAP = ρ_h*A_c*H_c/2 + ρ_h*A_b*L_v/2 @@(masa de un nudo de arriba sin descontar el brazo: SAP2000 con el hormigón tal cual, t)
m_ETB = ρ_h*A_c*H_c/2 + ρ_h*A_b*(L_v - 2*off_v)/2 @@(masa de un nudo de arriba descontando 0.20 m de viga en cada brazo: ETABS, t)
ρ_eq = ρ_h*(L_v - 2*off_v)/L_v @@(densidad rebajada que hay que darle a la viga en SAP2000 para que pese como en ETABS, t/m³)
#: Ese ρ_{eq} es justo el 2.28416 que escribe el exportador .s2k de Hekatan Struct en el material de la viga (commit 25ca0bdbf): así SAP2000 y ETABS resuelven **el mismo** modelo.
#hide
pd0 = round(pD_B(1), 7)
pd5 = round(pD_B(6), 7)
pd1 = round(pD_B(11), 7)
pn1 = round(pN_B(11), 7)
dmix = round(100*(pN_B(11)/pD_B(11) - 1), 2)
dsw = round(100*(1 - pD_B(11)/pD_B(1)), 2)
#show
#: Periodo de ladeo del pórtico B: con la masa de ETABS **@{pd0} s** (RZ = 0), **@{pd5} s** (RZ = 0.5) y **@{pd1} s** (RZ = 1): un **@{dsw} %** más corto con RZ = 1. Si con RZ = 1 se deja la masa sin descontar (SAP2000 con el material tal cual): **@{pn1} s**, un **@{dmix} %** más largo. **Mezclar** «brazos de ETABS» con «masa de SAP2000» mueve el periodo tanto como el propio RZ: por eso hay que fijar las dos cosas antes de comparar.

## 6 · El pórtico resuelto con RZ = 0, 0.5 y 1: desplazamiento y periodo

#: Los periodos del pórtico A (10 t en cada nudo de arriba, material sin masa: el periodo depende solo de la rigidez). Aquí aparece otra diferencia de **fuente de masa**: SAP2000 pone las 10 t en las tres direcciones (masa 3D); ETABS, por defecto, solo en las horizontales. Con la masa 3D los descensos u_{z} tienen inercia y se quedan en el problema (4 grados); con la masa lateral se **condensan** como los giros (quedan 2):
#: K̂ = K_{tt} − K_{tr}·K_{rr}⁻¹·K_{rt}        T = 2·π / √(λ_{mín}/m)
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
#: De RZ = 0 a RZ = 1 el periodo de ladeo baja un **@{dps} %**: el brazo rígido sí cambia la dinámica. (El λ_{mín} de 4 grados se saca por iteración inversa, x ← K̂⁻¹·x; el de 2 grados, con la fórmula del autovalor de una matriz 2 × 2.) Los modos fuera del plano (flexión débil y torsión de la viga) no salen en esta hoja de 2D: están en la tabla, medidos.

## 7 · Comparación: Hekatan LISP, Hekatan Struct, SAP2000 y ETABS

#: **Fuentes.** SAP2000 24.1 y ETABS 22.6: tests/datos/brazosˍporticoˍsap2000.json y brazosˍporticoˍetabs.json (OAPI, refˍporticoˍcsi.py) para el pórtico A; validation/brazos-rigidos/newblank/sap/porticoˍrz1.json para el B; validation/brazos-rigidos/plantillasˍrz/v2/sap y etabs, P1.json y P1rz05.json, para el edificio. Hekatan Struct: cliModeler + modalAnalysis de hekatan-struct main (1e7fd20e3), corrido el 4-oct-2026 con el mismo .heks que el test brazos-portico-csi (57/57 a 0.000 %).

### 7a · Pórtico A (la ley), RZ 0 → 0.5 → 1
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

### 7b · Pórtico B (regla automática de ETABS: viga 0.20 / 0.20, columna 0.50), masa de la viga descontada
#| Resultado | RZ | Hekatan LISP | Hekatan Struct | SAP2000 24.1 (ρ_{eq} en la viga) |
#|---|---:|---:|---:|---:|
#| u_{x} nudo 3 [mm] | 0 | @{uB0} | 0.6831303 | — (no medido) |
#| | 0.5 | @{uB5} | 0.5999412 | — (no medido) |
#| | 1 | @{uB1} | 0.5295209 | 0.5295209 |
#| Periodo de ladeo [s] | 0 | @{pd0} | 0.0660014 | — (no medido) |
#| | 0.5 | @{pd5} | 0.0618526 | — (no medido) |
#| | 1 | @{pd1} | 0.0581097 | 0.0581097 |
#| Periodo, masa SIN descontar, RZ = 1 [s] | 1 | @{pn1} | 0.0594157 | — |
#: El mismo pórtico **dibujado en la aplicación** (Brazos rígidos: ETABS automáticos, RZ = 1) dio u_{x} = 0.5295204 mm contra 0.5295209 de SAP2000: 0.00009 % (validation/brazos-rigidos/newblank/hekatanˍu.json, commit 897e58f7f).

### 7c · Edificio: pórtico 3D de las plantillas, brazos automáticos de ETABS y su masa descontada
#| Resultado | RZ | SAP2000 24.1 | ETABS 22.6 |
#|---|---:|---:|---:|
#| Periodo 1 [s] | 0 | 0.4121746 | 0.4121746 |
#| | 0.5 | 0.3830101 | 0.3830101 |
#| Periodo 3 (torsión) [s] | 0 | 0.3716574 | 0.3716574 |
#| | 0.5 | 0.3456614 | 0.3456614 |
#| Descenso máximo, carga muerta [mm] | 0 | 2.2770591 | 2.2770591 |
#| | 0.5 | 2.1959379 | 2.1959379 |
#: Hekatan Struct exporta este edificio a los dos programas (s2k con ρ_{eq}, e2k con la densidad completa, que ETABS descuenta solo) y los iguala: estático 0.0000 % nudo a nudo y periodos a 4 decimales (CLAUDE.md de hekatan-struct, «Edificio entero, 29-sep»). Con RZ = 0.5 el periodo fundamental baja un 7.1 %.

## 8 · Resumen

#: 1. **RZ = 0** (lo de ETABS por defecto): el brazo **no** cambia la rigidez; solo mueve dónde se reportan los esfuerzos (la cara) y, en ETABS, **quita la masa de la viga** dentro del nudo. Lo dicho en el vídeo del 20-sep vale **solo aquí**.
#: 2. **RZ > 0**: flexión y cortante con L_{f} = L − l_{I} − l_{J}, axil y torsión con L completa, K = Rᵀ·K(L_{f})·R. El pórtico se rigidiza: −@{dA1} % de desplazamiento con RZ = 1 (pórtico A), −@{dB1} % con la regla automática (pórtico B).
#: 3. **Carga de vano**: la fuerza no cambia, el momento de empotramiento sí; el momento en la cara crece con RZ.
#: 4. **Masa**: ETABS descuenta la viga dentro del brazo, SAP2000 no. Para comparar, la viga en SAP2000 lleva ρ·(L − off_{I} − off_{J})/L.
#: 5. Con todo eso fijado, Hekatan LISP, Hekatan Struct, SAP2000 y ETABS dan **lo mismo** a 6-7 cifras.
