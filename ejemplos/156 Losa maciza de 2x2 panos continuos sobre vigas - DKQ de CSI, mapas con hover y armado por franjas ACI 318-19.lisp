# Losa maciza de 2 × 2 paños continuos sobre vigas: cáscara de CSI (DKQ + membrana con giro normal), mapas de Mxx, Myy y Mxy con el cursor y armado por franjas (Wood-Armer, ACI 318-19, NEC-15)
#numerico
#: **Qué se calcula.** La losa de la hoja 155 (paño de 4.00 × 4.80 m, 15 cm, la misma carga) repetida en **2 × 2 paños continuos**: 8.00 × 9.60 m con vigas en todos los ejes (A, B, C en x y 1, 2, 3 en y) y columnas en los 9 cruces. Lo nuevo frente a un paño: sobre las vigas interiores la losa es **continua** y aparece el momento **negativo** (tracción arriba), que pide acero superior a los dos lados de la viga. Se arma **por franjas** como ACI 318-19 §8.4.1.5 (franja de columna y franja central) con los momentos de Wood-Armer promediados en cada franja, como hace SAFE.
#: **Elemento**: la cáscara delgada de CSI de la hoja 155 (DKQ de Batoz para la flexión y membrana con giro normal de CSI), 6 grados de libertad por nudo. **Validación**: equilibrio (Σ reacciones = carga), simetría y un **elemento independiente**: el BFS conforme (Bogner-Fox-Schmit, el de Calcpad en la hoja 77) en una malla de 5 cm, resuelto aparte (mismo modelo, otro elemento): para paños continuos no hay serie de Navier.
#: **Modelo de apoyos.** Las vigas se toman **rígidas en vertical** (w = 0 en todos los ejes) y sin rigidez a torsión (giros libres): sobre una viga interior la continuidad la da la propia losa. Las columnas sostienen a las vigas; la losa no se apoya directamente en ellas, así que **no hay punzonamiento** (eso es de la losa plana sin vigas, hoja 77). Unidades: tonf, m, kgf/cm²; signo de CSI (M > 0 = tracción abajo).

## 2 · Datos
l_x = 4.0 [m] 'luz de cada paño en x (entre ejes de vigas)
l_y = 4.8 [m] 'luz de cada paño en y
h_l = 0.15 [m] 'espesor de la losa maciza
f_c = 240 [kgf/cm²] 'resistencia del hormigón f'c
f_y = 4200 [kgf/cm²] 'fluencia del acero de refuerzo
f_cM = f_c·0.0980665 [MPa] 'f'c en MPa
E_c = 4700·sqrt(f_cM)·101.97162 [tonf/m²] 'módulo del hormigón, ACI 318-19 §19.2.2.1 (4700·√f'c en MPa), pasado a tonf/m²
ν = 0.2 'coeficiente de Poisson del hormigón
γ_h = 2.4 [tonf/m³] 'peso específico del hormigón armado
q_pp = γ_h·h_l [tonf/m²] 'peso propio de la losa
q_cm = 0.30 [tonf/m²] 'carga muerta sobreimpuesta supuesta: acabados y mampostería
q_cv = 0.204 [tonf/m²] 'carga viva de vivienda, 2.0 kN/m² (NEC-SE-CG 2015)
q_D = q_pp + q_cm [tonf/m²] 'carga muerta total D
#: **Combinaciones** (NEC-SE-CG 2015 §3.4.3 = ACI 318-19 Tabla 5.3.1): 1.4·D y 1.2·D + 1.6·L. Manda la mayor:
q_u1 = 1.4·q_D [tonf/m²] 'combinación 1
q_u2 = 1.2·q_D + 1.6·q_cv [tonf/m²] 'combinación 2
q_u = max(q_u1, q_u2) [tonf/m²] 'carga última de diseño
D_p = E_c·h_l^3/(12·(1 - ν^2)) [tonf·m] 'rigidez a flexión de la placa
D_b = D_p·[1, ν, 0; ν, 1, 0; 0, 0, (1 - ν)/2] [tonf·m] 'matriz de comportamiento a flexión (momentos ↔ curvaturas)
n_px = 2 'paños en x
n_py = 2 'paños en y
L_x = n_px·l_x [m] 'largo total de la losa en x
L_y = n_py·l_y [m] 'largo total en y
#: **Cómo se lee la planta.** Las líneas de trazo y punto son los ejes de las vigas (burbujas A, B, C y 1, 2, 3); los cuadrados grises, las columnas en los cruces. Cada paño es el de la hoja 155. Las cotas dan las luces entre ejes.
#dibujo("Planta: 2 × 2 paños de 4.00 × 4.80 m sobre vigas y columnas", ud = m, escala = auto, cotas = m, alto = 175)
#  rect(0, 0, 8.0, 9.6, "gruesa")
#  ejesx([0, 4, 8], "A")
#  ejesy([0, 4.8, 9.6], "1")
#  rect([-0.15, 3.85, 7.85, -0.15, 3.85, 7.85, -0.15, 3.85, 7.85], [-0.15, -0.15, -0.15, 4.65, 4.65, 4.65, 9.45, 9.45, 9.45], 0.30, 0.30, "denso")
#  texto(2.0, 2.4, "paño 1", 2.5, "c")
#  texto(6.0, 2.4, "paño 2", 2.5, "c")
#  texto(2.0, 7.2, "paño 3", 2.5, "c")
#  texto(6.0, 7.2, "paño 4", 2.5, "c")
#  texto(4.0, -1.4, "h = 0.15 m · qu = {q_u:3} tonf/m² en toda la losa", 2.4, "c", estilo = "azul")
#  cotas([0, 4, 8], -0.7, -0.05)
#  cotasy([0, 4.8, 9.6], 8.7, -0.05)
#fin

## 3 · El elemento: cáscara delgada de CSI = DKQ (flexión) + membrana con giro normal
#: Cada nudo de una cáscara tiene **6 grados de libertad**: u_x, u_y, w, θx, θy, θz. Una cáscara plana separa dos problemas que no se tocan: la **flexión** (w, θx, θy: el DKQ) y la **membrana** (u_x, u_y y el giro normal θz). Se escriben las dos, se juntan en la matriz de 24 × 24 del elemento y se comprueba al final que, en una losa sin fuerzas en su plano, la membrana NO cambia Mxx, Myy ni Mxy.
#: Malla de elementos cuadrados de 0.40 m: 20 en x y 24 en y (10 × 12 por paño, la malla de la hoja 155).
n_x = 20 'elementos en x
n_y = 24 'elementos en y
h_x = L_x/n_x [m] 'lado del elemento en x
h_y = L_y/n_y [m] 'lado del elemento en y

### 3a · Flexión: DKQ de Batoz y Tahar (Kirchhoff discreto, hoja 153)
#: Giros con la regla de la mano derecha: θx = ∂w/∂y, θy = −∂w/∂x. Coordenadas del elemento tipo (nudos antihorarios):
X1 = 0 [m] 'x del nudo 1
Y1 = 0 [m] 'y del nudo 1
X2 = h_x [m] 'x del nudo 2
Y2 = 0 [m] 'y del nudo 2
X3 = h_x [m] 'x del nudo 3
Y3 = h_y [m] 'y del nudo 3
X4 = 0 [m] 'x del nudo 4
Y4 = h_y [m] 'y del nudo 4
#: Lados 5 = 1-2, 6 = 2-3, 7 = 3-4, 8 = 4-1; sus cinco coeficientes a…e (los de la sección 1 de la hoja 153):
#hide
m5 = (X1-X2)^2 + (Y1-Y2)^2
m6 = (X2-X3)^2 + (Y2-Y3)^2
m7 = (X3-X4)^2 + (Y3-Y4)^2
m8 = (X4-X1)^2 + (Y4-Y1)^2
A5 = -(X1-X2)/m5
A6 = -(X2-X3)/m6
A7 = -(X3-X4)/m7
A8 = -(X4-X1)/m8
B5 = 0.75*(X1-X2)*(Y1-Y2)/m5
B6 = 0.75*(X2-X3)*(Y2-Y3)/m6
B7 = 0.75*(X3-X4)*(Y3-Y4)/m7
B8 = 0.75*(X4-X1)*(Y4-Y1)/m8
C5 = (0.25*(X1-X2)^2 - 0.5*(Y1-Y2)^2)/m5
C6 = (0.25*(X2-X3)^2 - 0.5*(Y2-Y3)^2)/m6
C7 = (0.25*(X3-X4)^2 - 0.5*(Y3-Y4)^2)/m7
C8 = (0.25*(X4-X1)^2 - 0.5*(Y4-Y1)^2)/m8
D5 = -(Y1-Y2)/m5
D6 = -(Y2-Y3)/m6
D7 = -(Y3-Y4)/m7
D8 = -(Y4-Y1)/m8
E5 = (0.25*(Y1-Y2)^2 - 0.5*(X1-X2)^2)/m5
E6 = (0.25*(Y2-Y3)^2 - 0.5*(X2-X3)^2)/m6
E7 = (0.25*(Y3-Y4)^2 - 0.5*(X3-X4)^2)/m7
E8 = (0.25*(Y4-Y1)^2 - 0.5*(X4-X1)^2)/m8
Hx_q(n1, n2, n3, n4, n5, n6, n7, n8) = [1.5*(A5*n5 - A8*n8); B5*n5 + B8*n8; n1 - C5*n5 - C8*n8; 1.5*(A6*n6 - A5*n5); B6*n6 + B5*n5; n2 - C6*n6 - C5*n5; 1.5*(A7*n7 - A6*n6); B7*n7 + B6*n6; n3 - C7*n7 - C6*n6; 1.5*(A8*n8 - A7*n7); B8*n8 + B7*n7; n4 - C8*n8 - C7*n7]
Hy_q(n1, n2, n3, n4, n5, n6, n7, n8) = [1.5*(D5*n5 - D8*n8); -n1 + E5*n5 + E8*n8; -B5*n5 - B8*n8; 1.5*(D6*n6 - D5*n5); -n2 + E6*n6 + E5*n5; -B6*n6 - B5*n5; 1.5*(D7*n7 - D6*n6); -n3 + E7*n7 + E6*n6; -B7*n7 - B6*n6; 1.5*(D8*n8 - D7*n7); -n4 + E8*n8 + E7*n7; -B8*n8 - B7*n7]
N5x(xi, eta) = -xi*(1-eta)
N5y(xi, eta) = -0.5*(1-xi^2)
N6x(xi, eta) = 0.5*(1-eta^2)
N6y(xi, eta) = -(1+xi)*eta
N7x(xi, eta) = -xi*(1+eta)
N7y(xi, eta) = 0.5*(1-xi^2)
N8x(xi, eta) = -0.5*(1-eta^2)
N8y(xi, eta) = -(1-xi)*eta
N1x(xi, eta) = -0.25*(1-eta) - 0.5*(N8x(xi, eta) + N5x(xi, eta))
N1y(xi, eta) = -0.25*(1-xi) - 0.5*(N8y(xi, eta) + N5y(xi, eta))
N2x(xi, eta) = 0.25*(1-eta) - 0.5*(N5x(xi, eta) + N6x(xi, eta))
N2y(xi, eta) = -0.25*(1+xi) - 0.5*(N5y(xi, eta) + N6y(xi, eta))
N3x(xi, eta) = 0.25*(1+eta) - 0.5*(N6x(xi, eta) + N7x(xi, eta))
N3y(xi, eta) = 0.25*(1+xi) - 0.5*(N6y(xi, eta) + N7y(xi, eta))
N4x(xi, eta) = -0.25*(1+eta) - 0.5*(N7x(xi, eta) + N8x(xi, eta))
N4y(xi, eta) = 0.25*(1-xi) - 0.5*(N7y(xi, eta) + N8y(xi, eta))
Hxs(xi, eta) = Hx_q(N1x(xi, eta), N2x(xi, eta), N3x(xi, eta), N4x(xi, eta), N5x(xi, eta), N6x(xi, eta), N7x(xi, eta), N8x(xi, eta))
Hxh(xi, eta) = Hx_q(N1y(xi, eta), N2y(xi, eta), N3y(xi, eta), N4y(xi, eta), N5y(xi, eta), N6y(xi, eta), N7y(xi, eta), N8y(xi, eta))
Hys(xi, eta) = Hy_q(N1x(xi, eta), N2x(xi, eta), N3x(xi, eta), N4x(xi, eta), N5x(xi, eta), N6x(xi, eta), N7x(xi, eta), N8x(xi, eta))
Hyh(xi, eta) = Hy_q(N1y(xi, eta), N2y(xi, eta), N3y(xi, eta), N4y(xi, eta), N5y(xi, eta), N6y(xi, eta), N7y(xi, eta), N8y(xi, eta))
B1_q(xi, eta) = 2/h_x*Hxs(xi, eta)
B2_q(xi, eta) = 2/h_y*Hyh(xi, eta)
B3_q(xi, eta) = 2/h_y*Hxh(xi, eta) + 2/h_x*Hys(xi, eta)
#show
#: En un rectángulo el jacobiano es constante: ∂/∂x = (2/h_x)·∂/∂ξ y ∂/∂y = (2/h_y)·∂/∂η. Curvaturas κ = [βx,x ; βy,y ; βx,y + βy,x] = B·u y rigidez K = Σ Bᵀ·D_b·B·|J| en los 4 puntos de Gauss ±1/√3:
g_p = 1/sqrt(3) 'coordenada de los puntos de Gauss 2 × 2
j_e = h_x·h_y/4 [m²] 'jacobiano |J| del rectángulo
#hide
B_G = zeros(12, 12)
r_g = [-g_p, g_p, g_p, -g_p]
s_g = [-g_p, -g_p, g_p, g_p]
K_p = zeros(12, 12)
for p = 1:4
  B_1 = transpose(B1_q(r_g(p), s_g(p)))
  B_2 = transpose(B2_q(r_g(p), s_g(p)))
  B_3 = transpose(B3_q(r_g(p), s_g(p)))
  K_p = K_p + j_e·(D_b(1, 1)·transpose(B_1)·B_1 + D_b(1, 2)·(transpose(B_1)·B_2 + transpose(B_2)·B_1) + D_b(2, 2)·transpose(B_2)·B_2 + D_b(3, 3)·transpose(B_3)·B_3)
  B_G(3·p - 2, :) = B_1
  B_G(3·p - 1, :) = B_2
  B_G(3·p, :) = B_3
end
#show
K_p11 = K_p(1, 1) [tonf/m] 'rigidez a w del nudo 1 (prototipo Python con las mismas fórmulas: 42 573.9995)
K_p22 = K_p(2, 2) [tonf·m] 'rigidez a θx del nudo 1 (Python: 930.9515)

### 3b · Membrana con giro normal de CSI (Allman + ITW, sacada del binario de SAPFire)
#: Grados de libertad [u_x, u_y, θz] por nudo. El desplazamiento en el plano tiene la parte bilineal de siempre, una **burbuja** (1 − r²)(1 − s²) que se condensa y, en cada lado, un término parabólico que mueve el giro de los dos nudos: Δu = (l/8)·(θ_j − θ_i)·n (Allman). En un rectángulo, (l/8)·n de cada lado es:
c_x = [0, h_y/8, 0, -h_y/8] [m] 'componente x de (l/8)·n de los lados 1-2, 2-3, 3-4, 4-1
c_y = [-h_x/8, 0, h_x/8, 0] [m] 'componente y
a_n = [4, 1, 2, 3] 'lado que LLEGA a cada nudo (el que sale es el de su mismo número)
D_m = E_c·h_l/(1 - ν^2)·[1, ν, 0; ν, 1, 0; 0, 0, (1 - ν)/2] [tonf/m] 'tensión plana por el espesor
G_c = E_c/(2·(1 + ν)) [tonf/m²] 'módulo de corte
#: B de la membrana en (r, s) (3 × 14: u, v, θ de los 4 nudos y las 2 burbujas). Las columnas de θ se **proyectan** (se les resta su media en el elemento): sin eso el elemento se aparta 1.4 % de CSI.
#hide
r_N = [-1, 1, 1, -1]
s_N = [-1, -1, 1, 1]
M_t = zeros(3, 4)
for p = 1:4
  r_p = r_g(p)
  s_p = s_g(p)
  n_r = 0.5·[-2·r_p·(1 - s_p), 1 - s_p^2, -2·r_p·(1 + s_p), -(1 - s_p^2)]
  n_s = 0.5·[-(1 - r_p^2), -2·s_p·(1 + r_p), 1 - r_p^2, -2·s_p·(1 - r_p)]
  for i = 1:4
    k = a_n(i)
    M_t(1, i) = M_t(1, i) + (2/h_x·n_r(k)·c_x(k) - 2/h_x·n_r(i)·c_x(i))/4
    M_t(2, i) = M_t(2, i) + (2/h_y·n_s(k)·c_y(k) - 2/h_y·n_s(i)·c_y(i))/4
    M_t(3, i) = M_t(3, i) + (2/h_y·n_s(k)·c_x(k) - 2/h_y·n_s(i)·c_x(i) + 2/h_x·n_r(k)·c_y(k) - 2/h_x·n_r(i)·c_y(i))/4
  end
end
K_14 = zeros(14, 14)
for p = 1:4
  r_p = r_g(p)
  s_p = s_g(p)
  n_r = 0.5·[-2·r_p·(1 - s_p), 1 - s_p^2, -2·r_p·(1 + s_p), -(1 - s_p^2)]
  n_s = 0.5·[-(1 - r_p^2), -2·s_p·(1 + r_p), 1 - r_p^2, -2·s_p·(1 - r_p)]
  B_m = zeros(3, 14)
  for i = 1:4
    k = a_n(i)
    d_nx = 2/h_x·r_N(i)·(1 + s_N(i)·s_p)/4
    d_ny = 2/h_y·s_N(i)·(1 + r_N(i)·r_p)/4
    B_m(1, 3·i - 2) = d_nx
    B_m(2, 3·i - 1) = d_ny
    B_m(3, 3·i - 2) = d_ny
    B_m(3, 3·i - 1) = d_nx
    B_m(1, 3·i) = 2/h_x·n_r(k)·c_x(k) - 2/h_x·n_r(i)·c_x(i) - M_t(1, i)
    B_m(2, 3·i) = 2/h_y·n_s(k)·c_y(k) - 2/h_y·n_s(i)·c_y(i) - M_t(2, i)
    B_m(3, 3·i) = 2/h_y·n_s(k)·c_x(k) - 2/h_y·n_s(i)·c_x(i) + 2/h_x·n_r(k)·c_y(k) - 2/h_x·n_r(i)·c_y(i) - M_t(3, i)
  end
  B_m(1, 13) = 2/h_x·(-2·r_p·(1 - s_p^2))
  B_m(3, 13) = 2/h_y·(-2·s_p·(1 - r_p^2))
  B_m(2, 14) = 2/h_y·(-2·s_p·(1 - r_p^2))
  B_m(3, 14) = 2/h_x·(-2·r_p·(1 - s_p^2))
  K_14 = K_14 + j_e·transpose(B_m)·D_m·B_m
end
b_0 = zeros(14, 1)
for i = 1:4
  k = a_n(i)
  b_0(3·i - 2) = -0.5·2/h_y·s_N(i)·(1 + r_N(i)·0)/4
  b_0(3·i - 1) = 0.5·2/h_x·r_N(i)·(1 + s_N(i)·0)/4
  n_rk = [0, 0.5, 0, -0.5]
  n_sk = [-0.5, 0, 0.5, 0]
  b_0(3·i) = 0.5·((2/h_x·n_rk(k)·c_y(k) - 2/h_x·n_rk(i)·c_y(i)) - (2/h_y·n_sk(k)·c_x(k) - 2/h_y·n_sk(i)·c_x(i))) - 1/4
end
h_t = zeros(14, 1)
h_t(3) = 1
h_t(6) = -1
h_t(9) = 1
h_t(12) = -1
#show
#: **Los dos términos del giro normal** (leídos en el binario de CSI, `CsiGo2.dll`): el de Wilson, que ata θz al giro del medio, b₀ᵀ·u = ½·(∂v/∂x − ∂u/∂y) − ¼·Σθᵢ, con peso 0.1·G·h·A; y un reloj de arena del giro, h = [+1, −1, +1, −1], con peso 5·10⁻⁵·G·h·A. Después se condensan las dos burbujas (K_bb − K_bα·K_αα⁻¹·K_αb):
A_e = h_x·h_y [m²] 'área del elemento
#hide
K_14 = K_14 + 0.1·G_c·h_l·A_e·(2·b_0)·transpose(2·b_0) + 0.00005·G_c·h_l·A_e·h_t·transpose(h_t)
K_m = K_14(1:12, 1:12) - K_14(1:12, 13:14)·inv(K_14(13:14, 13:14))·K_14(13:14, 1:12)
#show
K_m11 = K_m(1, 1) [tonf/m] 'rigidez a u_x del nudo 1 (k_membrana_csi.py = ETABS 22: 165 387.1483)
K_m33 = K_m(3, 3) [tonf·m] 'rigidez a θz del nudo 1 (k_membrana_csi.py: 1 274.4360)

### 3c · La cáscara: 24 × 24
#: Por nudo [u_x, u_y, w, θx, θy, θz] (el orden de CSI: U1, U2, U3, R1, R2, R3). La flexión va a las posiciones 3, 4, 5 y la membrana a 1, 2, 6; los bloques cruzados son cero porque el elemento es plano.
#hide
i_p = [3, 4, 5]
i_m = [1, 2, 6]
K_c = zeros(24, 24)
for i_a = 1:4
  for i_b = 1:4
    for r = 1:3
      for s = 1:3
        K_c(6·(i_a - 1) + i_p(r), 6·(i_b - 1) + i_p(s)) = K_p(3·(i_a - 1) + r, 3·(i_b - 1) + s)
        K_c(6·(i_a - 1) + i_m(r), 6·(i_b - 1) + i_m(s)) = K_m(3·(i_a - 1) + r, 3·(i_b - 1) + s)
      end
    end
  end
end
#show
K_c33 = K_c(3, 3) [tonf/m] 'w del nudo 1 en la cáscara (= K_p11)

## 4 · Malla, apoyos y carga
n_n = n_x + 1 'nudos en x
n_j = (n_x + 1)·(n_y + 1) 'número de nudos
n_e = n_x·n_y 'número de elementos
#hide
X_j = zeros(n_j, 1)
Y_j = zeros(n_j, 1)
for j = 1:n_y + 1
  for i = 1:n_n
    q = (j - 1)·n_n + i
    X_j(q) = (i - 1)·h_x
    Y_j(q) = (j - 1)·h_y
  end
end
e_j = zeros(n_e, 4)
for j = 1:n_y
  for i = 1:n_x
    e = (j - 1)·n_x + i
    q = (j - 1)·n_n + i
    e_j(e, 1) = q
    e_j(e, 2) = q + 1
    e_j(e, 3) = q + n_n + 1
    e_j(e, 4) = q + n_n
  end
end
s_b = zeros(n_j, 1)
for q = 1:n_j
  for k = 0:n_px
    if abs(X_j(q) - k·l_x) < 0.001
      s_b(q) = 1
    end
  end
  for k = 0:n_py
    if abs(Y_j(q) - k·l_y) < 0.001
      s_b(q) = 1
    end
  end
end
#show
#: Nudos fila a fila desde la esquina A-1. **Cómo se lee:** cuadrícula de 0.40 m; los nudos sobre los ejes A, B, C y 1, 2, 3 llevan el apoyo de la viga (w = 0).
#malla(X_j, Y_j, e_j)
n_ap = sum(s_b) 'nudos apoyados sobre las vigas
#: **La cáscara en sus dos bloques.** En la hoja 155 se armó la matriz de 24 × 24 por elemento y se vio que flexión y membrana no comparten ningún término. Aquí, con 525 nudos, la matriz de 3150 × 3150 no cabe en el motor numérico (1 GB de memoria). Como los dos bloques son independientes, basta resolver el de **flexión** (w, θx, θy, 1575 ecuaciones, con K_p); el de **membrana** (u_x, u_y, θz con K_m) no tiene carga en esta losa horizontal, así que su solución es u = 0 exacto (en la hoja 155, con la matriz completa de 24 × 24 por elemento, salió 0). Con sismo o fuerzas en el plano, el bloque de membrana se resolvería igual, con K_m.
n_g = 3·n_j 'grados de libertad de cada bloque
#hide
F = zeros(n_g, 1)
for e = 1:n_e
  for c = 1:4
    q = e_j(e, c)
    F(3·q - 2) = F(3·q - 2) - q_u·h_x·h_y/4
  end
end
#show
F_z = sum(F) [tonf] 'suma de las cargas nodales = −q_u·L_x·L_y

## 5 · Ensamblaje y solución
d_j(j) = 3·(j - 1) + (1:3)
d_e(e) = [d_j(e_j(e, 1)), d_j(e_j(e, 2)), d_j(e_j(e, 3)), d_j(e_j(e, 4))]
#hide
K = zeros(n_g, n_g)
#show
for e = 1:n_e
  g = d_e(e)
  K(g, g) = K(g, g) + K_p
end
#: Apoyos como muelles muy rígidos k_r en w de todos los nudos de viga.
k_r = 10^20 'rigidez del muelle de apoyo
#hide
for q = 1:n_j
  if s_b(q) == 1
    K(3·q - 2, 3·q - 2) = K(3·q - 2, 3·q - 2) + k_r
  end
end
#show
U = clsolve(K, F) 'flexión: w, θx, θy de los 525 nudos [m, rad]
#hide
K = 0
R_j = zeros(n_j, 1)
for q = 1:n_j
  if s_b(q) == 1
    R_j(q) = -k_r·U(3·q - 2)
  end
end
#show
R_t = sum(R_j) [tonf] 'suma de las reacciones de las vigas
Q_t = q_u·L_x·L_y [tonf] 'carga total
d_R = round(100·(R_t - Q_t)/Q_t, 8) [%] 'diferencia

## 6 · Momentos en los nudos (como los da SAP2000 y ETABS)
#: En cada elemento: B del DKQ en los 4 puntos de Gauss, M = −D_b·B·u (signo de CSI: positivo = tracción abajo), y extrapolación bilineal de Gauss a las esquinas; en cada nudo se promedian los elementos que llegan. La matriz R_E (12 × 12) hace todo de una vez: momentos de las 4 esquinas = R_E·u_e.
#hide
E_x = zeros(4, 4)
s_c = [-1, 1, 1, -1]
t_c = [-1, -1, 1, 1]
for k = 1:4
  for p = 1:4
    E_x(k, p) = 0.25·(1 + sqrt(3)·s_c(k)·r_N(p))·(1 + sqrt(3)·t_c(k)·s_N(p))
  end
end
X_E = zeros(12, 12)
D_B = zeros(12, 12)
for k = 1:4
  D_B(3·k - 2:3·k, 3·k - 2:3·k) = D_b
  for p = 1:4
    for c = 1:3
      X_E(3·(k - 1) + c, 3·(p - 1) + c) = E_x(k, p)
    end
  end
end
R_E = -X_E·D_B·B_G
M_s = zeros(n_j, 3)
c_n = zeros(n_j, 1)
for e = 1:n_e
  u_e = zeros(12, 1)
  for k = 1:4
    q = e_j(e, k)
    u_e(3·k - 2) = U(3·q - 2)
    u_e(3·k - 1) = U(3·q - 1)
    u_e(3·k) = U(3·q)
  end
  m_n = R_E·u_e
  for k = 1:4
    q = e_j(e, k)
    c_n(q) = c_n(q) + 1
    for c = 1:3
      M_s(q, c) = M_s(q, c) + m_n(3·(k - 1) + c)
    end
  end
end
for q = 1:n_j
  M_s(q, :) = M_s(q, :)/c_n(q)
end
#show
n_c1 = (n_y/4)·n_n + n_x/4 + 1 'nudo del centro del paño 1 (x = 2.0, y = 2.4)
n_b1 = (n_y/4)·n_n + n_x/2 + 1 'nudo sobre la viga del eje B, a media luz (x = 4.0, y = 2.4)
n_b2 = (n_y/2)·n_n + n_x/4 + 1 'nudo sobre la viga del eje 2, a media luz (x = 2.0, y = 4.8)
n_c4 = (3·n_y/4)·n_n + 3·n_x/4 + 1 'centro del paño 4 (simétrico del 1)
w_c = 1000·U(3·n_c1 - 2) [mm] 'flecha del centro del paño 1
M_xc = M_s(n_c1, 1) [tonf·m/m] 'Mxx positivo, centro del paño 1
M_yc = M_s(n_c1, 2) [tonf·m/m] 'Myy positivo, centro del paño 1
M_xB = M_s(n_b1, 1) [tonf·m/m] 'Mxx NEGATIVO sobre la viga del eje B
M_y2 = M_s(n_b2, 2) [tonf·m/m] 'Myy NEGATIVO sobre la viga del eje 2
d_sim = abs(M_s(n_c4, 1) - M_xc) [tonf·m/m] 'simetría: Mxx del paño 4 − paño 1

## 7 · Comprobación con un elemento independiente (BFS conforme)
#: El mismo modelo (2 × 2 paños, w = 0 en los ejes, misma carga) resuelto aparte en Python con el **BFS** (Bogner-Fox-Schmit: cúbicas de Hermite, w y su pendiente continuas, el elemento de Calcpad) en mallas de 0.20, 0.10 y 0.05 m; con 0.05 m la flecha ya no cambia en la 7.ª cifra. Valores de la malla de 0.05 m:
w_BFS = -1.2176472 [mm] 'flecha del centro del paño 1, BFS 0.05 m
M_xBFS = 0.6720589 [tonf·m/m] 'Mxx centro paño 1, BFS
M_yBFS = 0.4984077 [tonf·m/m] 'Myy centro paño 1, BFS
M_xBBFS = -1.5148771 [tonf·m/m] 'Mxx sobre viga B, BFS
M_y2BFS = -1.3205699 [tonf·m/m] 'Myy sobre viga 2, BFS
e_w = round(100·(w_c - w_BFS)/w_BFS, 3) [%] 'diferencia de la flecha
e_Mx = round(100·(M_xc - M_xBFS)/M_xBFS, 3) [%] 'Mxx de vano
e_My = round(100·(M_yc - M_yBFS)/M_yBFS, 3) [%] 'Myy de vano
e_MxB = round(100·(M_xB - M_xBBFS)/M_xBBFS, 3) [%] 'Mxx sobre la viga B
e_My2 = round(100·(M_y2 - M_y2BFS)/M_y2BFS, 3) [%] 'Myy sobre la viga 2
#: **Cómo se lee.** Con 0.40 m (10 × 12 por paño, como en la hoja 155) la flecha y los negativos quedan a ≈ 1 % del BFS y el positivo de vano a ≈ 2 % (por encima: lado seguro); afinando el DKQ a 0.10 m (en Python) baja a 0.07 %, 0.1 % y 0.13 %: los dos elementos convergen al mismo valor.

## 8 · Mapas de Mxx, Myy y Mxy (pasa el cursor: el globo da todos a la vez)
#hide
W_m = zeros(n_n, n_y + 1)
M_1 = zeros(n_n, n_y + 1)
M_2 = zeros(n_n, n_y + 1)
M_3 = zeros(n_n, n_y + 1)
for j = 1:n_y + 1
  for i = 1:n_n
    q = (j - 1)·n_n + i
    W_m(i, j) = -1000·U(3·q - 2)
    M_1(i, j) = M_s(q, 1)
    M_2(i, j) = M_s(q, 2)
    M_3(i, j) = M_s(q, 3)
  end
end
#show
#: Planta de 8.00 × 9.60 m vista desde arriba (x a la derecha, y hacia arriba, en metros), escala jet a la derecha. **Al pasar el cursor**, el globo da (x, y) y el valor de TODOS los mapas de esta planta en ese punto: flecha, Mxx, Myy, Mxy y el acero de las cuatro caras (▶ = el mapa de debajo).
w_z(x, y) = spline(1 + x/h_x, 1 + y/h_y, W_m)
M_xx(x, y) = spline(1 + x/h_x, 1 + y/h_y, M_1)
M_yy(x, y) = spline(1 + x/h_x, 1 + y/h_y, M_2)
M_xy(x, y) = spline(1 + x/h_x, 1 + y/h_y, M_3)
#: **Flecha** w (mm, hacia abajo). Cómo se lee: cuatro «platos», uno por paño, y cero sobre todas las vigas.
#map(w_z(x, y), [0 8], [0 9.6])
#: **Mxx** (tonf·m/m). Cómo se lee: rojo = positivo en cada paño (hasta ≈ 0.75, corrido hacia el borde exterior, como en el vano extremo de una viga continua; en el centro del paño 0.69); azul oscuro = el **negativo** sobre la viga del eje B (x = 4, ≈ −1.5): ahí la losa pasa continua y tracciona arriba. Sobre los ejes A y C (bordes) vuelve a cero.
#map(M_xx(x, y), [0 8], [0 9.6])
#: **Myy** (tonf·m/m). Cómo se lee: lo mismo en la otra dirección; el negativo está sobre la viga del eje 2 (y = 4.8, ≈ −1.3).
#map(M_yy(x, y), [0 8], [0 9.6])
#: **Mxy** (tonf·m/m, torsor). Cómo se lee: grande en las cuatro **esquinas exteriores** de la losa (donde dos bordes son apoyo simple); junto a los cruces de vigas interiores es menor, porque la continuidad impide el giro.
#map(M_xy(x, y), [0 8], [0 9.6])
#: **Corte por y = 2.40 m** (centro de los paños 1 y 2): Mxx a lo largo de x. Cómo se lee: dos «barrigas» positivas en los vanos y un pico negativo sobre la viga B (x = 4); cero en los bordes A y C. Es el diagrama de una viga continua de dos tramos, pero de una franja de losa.
#hide
C_Fe = zeros(n_n, 2)
for i = 1:n_n
  C_Fe(i, 1) = (i - 1)·h_x
  C_Fe(i, 2) = M_s((n_y/4)·n_n + i, 1)
end
#show
#fplot(Mxx_y24 = C_Fe, [0 8])

## 9 · Diseño: Wood-Armer y acero (ACI 318-19)
r_ec = 2.0 [cm] 'recubrimiento libre (ACI 318-19 Tabla 20.5.1.3.1)
d_v = 1.0 [cm] 'diámetro de la varilla, Ø10
d_x = 100·h_l - r_ec - d_v/2 [cm] 'peralte de las varillas en x (capa exterior)
d_y = d_x - d_v [cm] 'peralte de las varillas en y (capa interior)
φ_f = 0.9 'flexión, sección controlada por tracción
A_smin = 0.0018·100·100·h_l [cm²/m] 'mínimo, ACI 318-19 §8.6.1.1
s_max = min(2·100·h_l, 45) [cm] 'separación máxima, ACI 318-19 §8.7.2.2
A_b = pi·d_v^2/4 [cm²] 'área de una varilla Ø10
A_req(M_u, d_c) = 0.85·f_c·100·d_c/f_y·(1 - sqrt(1 - 2·M_u·10^5/(φ_f·0.85·f_c·100·d_c^2)))
s_var(A_s) = min(floor(100·A_b/max(A_s, A_smin)/2.5)·2.5, s_max)
#hide
A_1 = zeros(n_n, n_y + 1)
A_2 = zeros(n_n, n_y + 1)
A_3 = zeros(n_n, n_y + 1)
A_4 = zeros(n_n, n_y + 1)
W_A = zeros(n_j, 4)
for q = 1:n_j
  m_x = M_s(q, 1)
  m_y = M_s(q, 2)
  m_t = abs(M_s(q, 3))
  b_x = m_x + m_t
  b_y = m_y + m_t
  if b_x < 0
    b_x = 0
    b_y = m_y + m_t^2/abs(m_x)
  end
  if b_y < 0
    b_y = 0
    b_x = m_x + m_t^2/abs(m_y)
  end
  a_x = m_x - m_t
  a_y = m_y - m_t
  if a_x > 0
    a_x = 0
    a_y = m_y - m_t^2/abs(m_x)
  end
  if a_y > 0
    a_y = 0
    a_x = m_x - m_t^2/abs(m_y)
  end
  W_A(q, 1) = max(b_x, 0)
  W_A(q, 2) = max(b_y, 0)
  W_A(q, 3) = -min(a_x, 0)
  W_A(q, 4) = -min(a_y, 0)
end
for j = 1:n_y + 1
  for i = 1:n_n
    q = (j - 1)·n_n + i
    A_1(i, j) = A_req(W_A(q, 1), d_x)
    A_2(i, j) = A_req(W_A(q, 2), d_y)
    A_3(i, j) = A_req(W_A(q, 3), d_x)
    A_4(i, j) = A_req(W_A(q, 4), d_y)
  end
end
#show
#: **Mapas de acero requerido** (cm²/m, solo por momento; lo que quede bajo A_smin = 2.70 lo cubre el mínimo). Cómo se lee: abajo, máximo en el centro de cada paño; arriba, una banda sobre la viga B (varillas en x) y otra sobre la viga 2 (varillas en y), más las cuatro esquinas exteriores.
A_xi(x, y) = spline(1 + x/h_x, 1 + y/h_y, A_1)
A_yi(x, y) = spline(1 + x/h_x, 1 + y/h_y, A_2)
A_xs(x, y) = spline(1 + x/h_x, 1 + y/h_y, A_3)
A_ys(x, y) = spline(1 + x/h_x, 1 + y/h_y, A_4)
#: Abajo, varillas en x:
#map(A_xi(x, y), [0 8], [0 9.6])
#: Abajo, varillas en y:
#map(A_yi(x, y), [0 8], [0 9.6])
#: Arriba, varillas en x:
#map(A_xs(x, y), [0 8], [0 9.6])
#: Arriba, varillas en y:
#map(A_ys(x, y), [0 8], [0 9.6])

## 10 · Armado por franjas (ACI 318-19 §8.4.1.5)
#: **Franjas.** Franja de columna: a cada lado de un eje, 0.25·min(l_x, l_y) = 1.00 m; franja central: el resto del paño (4.80 − 2·1.00 = 2.80 m para las varillas en x; 4.00 − 2·1.00 = 2.00 m para las varillas en y). En cada franja el momento de diseño es el **promedio** de Wood-Armer en los nudos de la franja (como las franjas de SAFE): para el positivo, en cada línea de nudos se toma el mayor a lo largo de la luz (en el vano extremo el máximo no está en el centro sino corrido hacia el apoyo exterior, ≈ 1.6 m de él); para el negativo, la sección sobre la viga interior (x = 4, y = 4.8).
b_c = 0.25·min(l_x, l_y) [m] 'medio ancho de la franja de columna
#hide
m_xp_c = 0
m_xp_m = 0
m_xn_c = 0
m_xn_m = 0
k_c = 0
k_m = 0
for j = 1:n_y/2 + 1
  y_q = (j - 1)·h_y
  q_n = (j - 1)·n_n + n_x/2 + 1
  m_pk = 0
  for i = 1:n_x/2 + 1
    m_pk = max(m_pk, W_A((j - 1)·n_n + i, 1))
  end
  if y_q < b_c + 0.001 || y_q > l_y - b_c - 0.001
    m_xp_c = m_xp_c + m_pk
    m_xn_c = m_xn_c + W_A(q_n, 3)
    k_c = k_c + 1
  end
  if y_q > b_c + 0.001 && y_q < l_y - b_c - 0.001
    m_xp_m = m_xp_m + m_pk
    m_xn_m = m_xn_m + W_A(q_n, 3)
    k_m = k_m + 1
  end
end
m_xp_c = m_xp_c/k_c
m_xp_m = m_xp_m/k_m
m_xn_c = m_xn_c/k_c
m_xn_m = m_xn_m/k_m
m_yp_c = 0
m_yp_m = 0
m_yn_c = 0
m_yn_m = 0
k_c = 0
k_m = 0
for i = 1:n_x/2 + 1
  x_q = (i - 1)·h_x
  q_n = (n_y/2)·n_n + i
  m_pk = 0
  for j = 1:n_y/2 + 1
    m_pk = max(m_pk, W_A((j - 1)·n_n + i, 2))
  end
  if x_q < b_c + 0.001 || x_q > l_x - b_c - 0.001
    m_yp_c = m_yp_c + m_pk
    m_yn_c = m_yn_c + W_A(q_n, 4)
    k_c = k_c + 1
  end
  if x_q > b_c + 0.001 && x_q < l_x - b_c - 0.001
    m_yp_m = m_yp_m + m_pk
    m_yn_m = m_yn_m + W_A(q_n, 4)
    k_m = k_m + 1
  end
end
m_yp_c = m_yp_c/k_c
m_yp_m = m_yp_m/k_m
m_yn_c = m_yn_c/k_c
m_yn_m = m_yn_m/k_m
#show
M_xpc = m_xp_c [tonf·m/m] 'varillas en x, abajo, franja de columna (promedio del máximo de vano)
M_xpm = m_xp_m [tonf·m/m] 'varillas en x, abajo, franja central
M_xnc = m_xn_c [tonf·m/m] 'varillas en x, arriba sobre la viga B, franja de columna
M_xnm = m_xn_m [tonf·m/m] 'varillas en x, arriba sobre la viga B, franja central
M_ypc = m_yp_c [tonf·m/m] 'varillas en y, abajo, franja de columna
M_ypm = m_yp_m [tonf·m/m] 'varillas en y, abajo, franja central
M_ync = m_yn_c [tonf·m/m] 'varillas en y, arriba sobre la viga 2, franja de columna
M_ynm = m_yn_m [tonf·m/m] 'varillas en y, arriba sobre la viga 2, franja central
#: Acero requerido por franja (cm²/m):
A_xpc = A_req(m_xp_c, d_x) [cm²/m] 'abajo x, columna
A_xpm = A_req(m_xp_m, d_x) [cm²/m] 'abajo x, central
A_xnc = A_req(m_xn_c, d_x) [cm²/m] 'arriba x sobre B, columna
A_xnm = A_req(m_xn_m, d_x) [cm²/m] 'arriba x sobre B, central
A_ypc = A_req(m_yp_c, d_y) [cm²/m] 'abajo y, columna
A_ypm = A_req(m_yp_m, d_y) [cm²/m] 'abajo y, central
A_ync = A_req(m_yn_c, d_y) [cm²/m] 'arriba y sobre 2, columna
A_ynm = A_req(m_yn_m, d_y) [cm²/m] 'arriba y sobre 2, central
#: **Separaciones** (Ø10, múltiplo de 2.5 cm, sin bajar del mínimo ni pasar de s_max):
s_xpc = s_var(A_xpc) [cm] 'abajo x, columna
s_xpm = s_var(A_xpm) [cm] 'abajo x, central
s_xnc = s_var(A_xnc) [cm] 'arriba x sobre B, columna
s_xnm = s_var(A_xnm) [cm] 'arriba x sobre B, central
s_ypc = s_var(A_ypc) [cm] 'abajo y, columna
s_ypm = s_var(A_ypm) [cm] 'abajo y, central
s_ync = s_var(A_ync) [cm] 'arriba y sobre 2, columna
s_ynm = s_var(A_ynm) [cm] 'arriba y sobre 2, central
#: **Largo del acero superior.** Se mide en el corte por el centro del paño: el momento negativo (Mxx < 0) llega hasta el punto de inflexión, a x_0 del eje de la viga; ACI 318-19 §7.7.3.3 pide seguir d o 12·d_b más allá del punto donde ya no se necesita. Se toma el último nudo con momento negativo contando desde la viga, se suma un elemento (lado seguro: el cero está dentro de ese elemento) y luego d o 12·d_b:
#hide
x_0 = 0
f_l = 1
for k = 0:n_x/2
  q = (n_y/4)·n_n + n_x/2 + 1 - k
  if M_s(q, 1) >= 0
    f_l = 0
  end
  if f_l == 1
    x_0 = k·h_x
  end
end
y_0 = 0
f_l = 1
for k = 0:n_y/2
  q = (n_y/2 - k)·n_n + n_x/4 + 1
  if M_s(q, 2) >= 0
    f_l = 0
  end
  if f_l == 1
    y_0 = k·h_y
  end
end
#show
x_0m = x_0 [m] 'punto de inflexión de Mxx, medido desde el eje B
y_0m = y_0 [m] 'punto de inflexión de Myy, medido desde el eje 2
L_bx = ceil(20·(x_0 + h_x + max(d_x/100, 12·d_v/100)))/20 [m] 'largo de la varilla superior en x a CADA lado del eje B
L_by = ceil(20·(y_0 + h_y + max(d_y/100, 12·d_v/100)))/20 [m] 'idem en y a cada lado del eje 2
#: **Esquinas exteriores** (ACI 318-19 §8.7.3.1): arriba y abajo, para el mayor momento positivo del paño, en l/5 = 0.96 m desde la esquina (como en la hoja 155):
l_esq = l_y/5 [m] 'lado del cuadro de esquina
s_e = s_var(max(A_xpm, A_ypm)) [cm] 'separación en las esquinas
#hide
r_vx = 100·L_y/s_xpm
r_vy = 100·L_x/s_ypm
n_vx = floor(r_vx) + 1
n_vy = floor(r_vy) + 1
y_v = zeros(n_vx, 1)
x_v = zeros(n_vy, 1)
for k = 1:n_vx
  y_v(k) = (L_y - (n_vx - 1)·s_xpm/100)/2 + (k - 1)·s_xpm/100
end
for k = 1:n_vy
  x_v(k) = (L_x - (n_vy - 1)·s_ypm/100)/2 + (k - 1)·s_ypm/100
end
r_be = 100·l_esq/s_e
n_be = floor(r_be) + 1
p_e = zeros(n_be, 1)
for k = 1:n_be
  p_e(k) = 0.08 + (k - 1)·s_e/100
end
#show
n_vxm = n_vx 'varillas en x a lo largo de 9.60 m (cada capa)
n_vym = n_vy 'varillas en y a lo largo de 8.00 m

#: **Cómo se lee el armado inferior.** Una planta para cada dirección (si van juntas, los rótulos cruzan las varillas de la otra). Las líneas finas son TODAS las varillas a su separación real; la roja con ganchos es la varilla tipo con su rótulo «cantidad Ø diámetro @ separación». Las líneas de trazos separan las franjas: **FC** = franja de columna (1.00 m a cada lado de un eje), **FCe** = franja central. Aquí todas las franjas dan el mismo armado porque en todas manda el mínimo (tabla de abajo).
#dibujo("Armado inferior, varillas en x (Ø10 en todas las franjas)", ud = m, escala = auto, cotas = m, alto = 180)
#  rect(0, 0, 8.0, 9.6, "gruesa")
#  rect(0.05, y_v, 7.9, 0, "fina")
#  linea(0, 1.0, 8.0, 1.0, "trazos azul")
#  linea(0, 3.8, 8.0, 3.8, "trazos azul")
#  linea(0, 5.8, 8.0, 5.8, "trazos azul")
#  linea(0, 8.6, 8.0, 8.6, "trazos azul")
#  varillas(0.05, y_v(9), 3.95, y_v(9), n_vx, 10, s_xpm, 90, 0, 1)
#  texto(8.2, 0.5, "FC", 2.4, "i", estilo = "azul")
#  texto(8.2, 2.4, "FCe", 2.4, "i", estilo = "azul")
#  texto(8.2, 4.8, "FC", 2.4, "i", estilo = "azul")
#  texto(8.2, 7.2, "FCe", 2.4, "i", estilo = "azul")
#  texto(8.2, 9.1, "FC", 2.4, "i", estilo = "azul")
#  cotas([0, 4, 8], -0.5, -0.05)
#  cotasy([0, 1.0, 3.8, 5.8, 8.6, 9.6], -0.5, 0.05)
#fin
#dibujo("Armado inferior, varillas en y (Ø10 en todas las franjas)", ud = m, escala = auto, cotas = m, alto = 180)
#  rect(0, 0, 8.0, 9.6, "gruesa")
#  rect(x_v, 0.05, 0, 9.5, "fina")
#  linea(1.0, 0, 1.0, 9.6, "trazos azul")
#  linea(3.0, 0, 3.0, 9.6, "trazos azul")
#  linea(5.0, 0, 5.0, 9.6, "trazos azul")
#  linea(7.0, 0, 7.0, 9.6, "trazos azul")
#  varillas(x_v(8), 0.05, x_v(8), 4.75, n_vy, 10, s_ypm, 90, 0, 1)
#  texto(0.5, 9.85, "FC", 2.4, "c", estilo = "azul")
#  texto(2.0, 9.85, "FCe", 2.4, "c", estilo = "azul")
#  texto(4.0, 9.85, "FC", 2.4, "c", estilo = "azul")
#  texto(6.0, 9.85, "FCe", 2.4, "c", estilo = "azul")
#  texto(7.5, 9.85, "FC", 2.4, "c", estilo = "azul")
#  cotas([0, 1, 3, 5, 7, 8], -0.5, -0.05)
#  cotasy([0, 4.8, 9.6], -0.5, 0.05)
#fin
#: **Cómo se lee el armado superior.** Rojo = acero de ARRIBA. Sobre la viga del eje B, varillas en x de 2 × L_{bx} (centradas en el eje); sobre la viga del eje 2, varillas en y de 2 × L_{by}; en las cuatro esquinas exteriores, el cuadro de 0.96 m de ACI §8.7.3. Las cotas de abajo y de la derecha dan el largo de cada banda; los rótulos van fuera de la losa para no tapar varillas.
#dibujo("Armado superior: negativos sobre las vigas interiores y esquinas", ud = m, escala = auto, cotas = m, alto = 180)
#  rect(0, 0, 8.0, 9.6, "gruesa")
#  linea(4.0, 0, 4.0, 9.6, "eje")
#  linea(0, 4.8, 8.0, 4.8, "eje")
#  rect(4.0 - L_bx, y_v, 2·L_bx, 0, "media rojo")
#  rect(x_v, 4.8 - L_by, 0, 2·L_by, "media rojo")
#  rect(0.03, p_e, l_esq - 0.03, 0, "media rojo")
#  rect(p_e, 0.03, 0, l_esq - 0.03, "media rojo")
#  rect(8.0 - l_esq, p_e, l_esq - 0.03, 0, "media rojo")
#  rect(8.0 - p_e, 0.03, 0, l_esq - 0.03, "media rojo")
#  rect(0.03, 9.6 - p_e, l_esq - 0.03, 0, "media rojo")
#  rect(p_e, 9.6 - l_esq, 0, l_esq - 0.03, "media rojo")
#  rect(8.0 - l_esq, 9.6 - p_e, l_esq - 0.03, 0, "media rojo")
#  rect(8.0 - p_e, 9.6 - l_esq, 0, l_esq - 0.03, "media rojo")
#  cota(4.0 - L_bx, -0.45, 4.0 + L_bx, -0.45, -0.05, "2 × {L_bx:2}")
#  cota(8.45, 4.8 - L_by, 8.45, 4.8 + L_by, -0.05, "2 × {L_by:2}")
#  cota(0, -1.15, 8.0, -1.15, -0.05, "8.00")
#  texto(4.0, -1.75, "sobre eje B: Ø10 @ {s_xnm:1} cm en x · sobre eje 2: Ø10 @ {s_ynm:1} cm en y", 2.4, "c", estilo = "rojo")
#  texto(4.0, -2.20, "esquinas: {n_be:0} Ø10 @ {s_e:1} cm en x y en y (0.96 × 0.96 m)", 2.4, "c", estilo = "rojo")
#fin

## 11 · Resumen
#hide
r_wc = round(w_c, 4)
r_wB = round(w_BFS, 4)
r_Mx = round(M_xc, 4)
r_MxB = round(M_xBFS, 4)
r_My = round(M_yc, 4)
r_MyB = round(M_yBFS, 4)
r_Mn = round(M_xB, 4)
r_MnB = round(M_xBBFS, 4)
r_Mn2 = round(M_y2, 4)
r_Mn2B = round(M_y2BFS, 4)
r_R = round(R_t, 4)
t_1 = round(A_xpc, 2)
t_2 = round(A_xnc, 2)
t_3 = round(A_ypc, 2)
t_4 = round(A_ync, 2)
t_5 = round(A_xpm, 2)
t_6 = round(A_xnm, 2)
t_7 = round(A_ypm, 2)
t_8 = round(A_ynm, 2)
r_Q = round(Q_t, 4)
#show
#| Magnitud | Hekatan LISP (cáscara CSI, 0.40 m) | Referencia | Diferencia |
#|---|---:|---:|---:|
#| flecha centro paño 1 [mm] | @{r_wc} | BFS 0.05 m: @{r_wB} | @{e_w} % |
#| Mxx centro paño 1 [tonf·m/m] | @{r_Mx} | BFS: @{r_MxB} | @{e_Mx} % |
#| Myy centro paño 1 [tonf·m/m] | @{r_My} | BFS: @{r_MyB} | @{e_My} % |
#| Mxx sobre viga B [tonf·m/m] | @{r_Mn} | BFS: @{r_MnB} | @{e_MxB} % |
#| Myy sobre viga 2 [tonf·m/m] | @{r_Mn2} | BFS: @{r_Mn2B} | @{e_My2} % |
#| suma de reacciones [tonf] | @{r_R} | q_u·L_x·L_y = @{r_Q} | @{d_R} % |
#: **Franjas** (momento de Wood-Armer promedio → acero requerido → separación Ø10):
#| Franja | abajo x [cm²/m] | arriba x sobre B [cm²/m] | abajo y [cm²/m] | arriba y sobre 2 [cm²/m] |
#|---|---:|---:|---:|---:|
#| de columna (FC) | @{t_1} → @{s_xpc} cm | @{t_2} → @{s_xnc} cm | @{t_3} → @{s_ypc} cm | @{t_4} → @{s_ync} cm |
#| central (FCe) | @{t_5} → @{s_xpm} cm | @{t_6} → @{s_xnm} cm | @{t_7} → @{s_ypm} cm | @{t_8} → @{s_ynm} cm |
#: **Lectura.** La franja de columna pide poco: con vigas rígidas, lo que va «a la columna» lo recoge la viga. La franja central es la que trabaja; aun así, en esta losa de 15 cm y luces de 4-4.8 m el **acero mínimo** (2.70 cm²/m) cubre todo menos los negativos de la franja central (2.84 sobre la viga B y 2.77 sobre la viga 2), que quedan justos con Ø10 @ 27.5 cm = 2.86 cm²/m. Si las luces crecen o la carga sube, la tabla cambia sola: todo sale de los mapas.
