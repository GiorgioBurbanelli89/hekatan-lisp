# Losa maciza de un paño apoyada en vigas: cáscara de CSI (DKQ de Batoz + membrana con giro normal), mapas de Mxx, Myy y Mxy con el cursor y diseño gráfico por Wood-Armer (ACI 318-19, NEC-15)
#numerico
#: **Qué se calcula.** Una losa maciza de 4.00 × 4.80 m y 15 cm, apoyada en las cuatro vigas del borde, con la carga última de la NEC-15. Se resuelve por elementos finitos con la **cáscara delgada de CSI** (Shell-Thin de SAP2000 y ETABS): flexión con el **DKQ de Batoz y Tahar** y, en el plano, la **membrana con giro normal (drilling) de CSI**. Salen los momentos Mxx, Myy y Mxy en toda la planta (mapas: al pasar el cursor el globo da los tres a la vez y la posición), y con ellos el **diseño**: momentos de Wood-Armer, acero por cara y dirección (ACI 318-19), mapa de acero y el armado dibujado.
#: **Cómo se valida.** (1) Navier, la solución exacta de la placa apoyada (a 4 cifras); (2) equilibrio: la suma de las reacciones es la carga total; (3) un cálculo de acero a mano en el centro; (4) la cáscara completa (6 grados de libertad por nudo) da los mismos momentos que la placa sola. El elemento DKQ de esta hoja es el de la hoja 153 (= SAP2000 y ETABS a 1e-8 %) y la membrana es la de `k_membrana_csi.py` (= ETABS 22 a 2e-15).
#: **Unidades** (Ecuador): tonf, m, kgf/cm²; momentos en tonf·m/m y acero en cm²/m. **Signo de CSI**: M > 0 = tracción ABAJO (momento positivo de vano).

## 1 · En símbolos
#: **Rigidez a flexión** de la placa, de E, del espesor h y de ν:
D_f = Simplify{E*h^3/(12*(1-nu^2))}
#: **Ecuación de la placa delgada** (Kirchhoff): D·∇⁴w = q. Navier la resuelve en una placa apoyada de a × b con una serie doble de senos; cada término m, n (impares) es una flecha senoidal:
w_mn = Simplify{W*sin(m*pi*x/a)*sin(n*pi*y/b)}
#: Los momentos salen de las curvaturas, Mx = −D·(w,xx + ν·w,yy) (con w hacia abajo). Derivando el término dos veces:
k_xx = Simplify{-Diff{Diff{W*sin(m*pi*x/a)*sin(n*pi*y/b) @ x} @ x}}
k_yy = Simplify{-Diff{Diff{W*sin(m*pi*x/a)*sin(n*pi*y/b) @ y} @ y}}
#: Con la carga uniforme q, su desarrollo en senos da q_{mn} = 16·q/(π²·m·n) y la amplitud es W_{mn} = q_{mn}/(D·π⁴·(m²/a² + n²/b²)²). Sumando: w = Σ W_mn·sin·sin, Mx = Σ W_mn·D·π²·(m²/a² + ν·n²/b²)·sin·sin, My igual con ν en el otro término.
#: **Acero a flexión** (ACI 318-19 §22.2, bloque de Whitney en una franja de b = 100 cm): M_u = φ·A_s·f_y·(d − a/2) con a = A_s·f_{y} /(0.85·f'c·b). Es una ecuación de segundo grado en A_s; su raíz menor es
#: A_s = 0.85·f'c·b·d/f_y · (1 − √(1 − 2·M_{u} /(φ·0.85·f'c·b·d²)))
#: **Wood-Armer** (el que usan SAFE y ETABS para armar losas con Mxy): en cada punto, momento de diseño de la cara inferior Mx⁺ = Mxx + |Mxy|, My⁺ = Myy + |Mxy|; de la superior Mx⁻ = Mxx − |Mxy|, My⁻ = Myy − |Mxy|. Si uno de los dos cambia de signo se pone en cero y el otro pasa a Myy ± Mxy²/|Mxx| (o al revés). El torsor Mxy no tiene varilla propia: se arma sumándolo a las dos direcciones.

## 2 · Datos
l_x = 4.0 [m] 'luz corta (entre ejes de vigas), en x
l_y = 4.8 [m] 'luz larga, en y
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

#: **Cómo se lee la planta.** El rectángulo grueso es la losa de 4.00 × 4.80 m entre ejes; las bandas grises de los bordes son las vigas que la sostienen (en el modelo, un apoyo simple: w = 0 en todo el borde, giros libres). Las flechas rojas dan las direcciones x e y; el origen de coordenadas es la esquina de abajo a la izquierda (nudo 1). La carga q_u se reparte en toda la planta. **El corte A-A** (por x, a media luz) muestra el espesor de 15 cm, el bloque de carga y las vigas; las cotas están en metros.
#dibujo("Planta de la losa: 4.00 × 4.80 m sobre vigas en los 4 bordes", ud = m, escala = auto, cotas = m, alto = 150)
#  rect(-0.15, -0.15, 4.30, 0.30, "denso")
#  rect(-0.15, 4.65, 4.30, 0.30, "denso")
#  rect(-0.15, 0.15, 0.30, 4.50, "denso")
#  rect(3.85, 0.15, 0.30, 4.50, "denso")
#  rect(0, 0, 4.0, 4.8, "gruesa")
#  linea(-0.6, 2.4, 4.6, 2.4, "trazos")
#  texto(-0.75, 2.4, "A", 3, "c")
#  texto(4.75, 2.4, "A", 3, "c")
#  flecha(0.45, 0.45, 1.25, 0.45, "rojo")
#  flecha(0.45, 0.45, 0.45, 1.25, "rojo")
#  texto(1.35, 0.45, "x", 2.8, "i", estilo = "rojo")
#  texto(0.45, 1.40, "y", 2.8, "c", estilo = "rojo")
#  texto(2.0, 3.4, "losa maciza h = 0.15 m", 2.6, "c")
#  texto(2.0, 3.0, "qu = {q_u:3} tonf/m²", 2.6, "c", estilo = "azul")
#  texto(2.0, 1.4, "vigas de borde = apoyo simple", 2.4, "c")
#  cota(0, -0.55, 4.0, -0.55, -0.05, "4.00")
#  cota(-1.15, 0, -1.15, 4.8, 0.05, "4.80")
#fin
#dibujo("Corte A-A: losa de 15 cm entre vigas, con la carga última", ud = m, escala = auto, cotas = m, alto = 110)
#  seccion(0, 0, 4.0, 0.15)
#  rect(-0.15, -0.30, 0.30, 0.45, "gruesa")
#  rect(3.85, -0.30, 0.30, 0.45, "gruesa")
#  carga(0, 0.15, 4.0, 0.15, 0.35, 0.35, "qu = {q_u:3} tonf/m²", "azul", n = 11)
#  cota(0, -0.55, 4.0, -0.55, -0.05, "4.00")
#  texto(4.35, 0.075, "h = 0.15", 2.4, "i")
#fin

## 3 · El elemento: cáscara delgada de CSI = DKQ (flexión) + membrana con giro normal
#: Cada nudo de una cáscara tiene **6 grados de libertad**: u_x, u_y, w, θx, θy, θz. Una cáscara plana separa dos problemas que no se tocan: la **flexión** (w, θx, θy: el DKQ) y la **membrana** (u_x, u_y y el giro normal θz). Se escriben las dos, se juntan en la matriz de 24 × 24 del elemento y se comprueba al final que, en una losa sin fuerzas en su plano, la membrana NO cambia Mxx, Myy ni Mxy.
#: Malla de elementos cuadrados de 0.40 m: 10 en x y 12 en y.
n_x = 10 'elementos en x
n_y = 12 'elementos en y
h_x = l_x/n_x [m] 'lado del elemento en x
h_y = l_y/n_y [m] 'lado del elemento en y

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
  if X_j(q) < 0.001 || X_j(q) > l_x - 0.001 || Y_j(q) < 0.001 || Y_j(q) > l_y - 0.001
    s_b(q) = 1
  end
end
#show
#: Nudos numerados fila a fila desde la esquina de abajo a la izquierda. **Cómo se lee:** los números chicos son nudos, los de los cuadros son elementos; los nudos del borde llevan el apoyo (w = 0).
#malla(X_j, Y_j, e_j)
n_ap = sum(s_b) 'nudos apoyados (todo el contorno)
#: **Carga.** Cada elemento reparte q_u·A_e en sus 4 nudos (un cuarto cada uno), hacia abajo (−z).
n_g = 6·n_j 'grados de libertad de la cáscara
#hide
F = zeros(n_g, 1)
for e = 1:n_e
  for c = 1:4
    q = e_j(e, c)
    F(6·q - 3) = F(6·q - 3) - q_u·h_x·h_y/4
  end
end
#show
F_z = sum(F) [tonf] 'suma de las cargas nodales = −q_u·l_x·l_y

## 5 · Ensamblaje y solución
#: Grados de libertad del nudo j: 6·(j − 1) + 1 … 6. La K de cada elemento se **suma** en las filas y columnas de sus 4 nudos:
d_j(j) = 6·(j - 1) + (1:6)
d_e(e) = [d_j(e_j(e, 1)), d_j(e_j(e, 2)), d_j(e_j(e, 3)), d_j(e_j(e, 4))]
#hide
K = zeros(n_g, n_g)
#show
for e = 1:n_e
  g = d_e(e)
  K(g, g) = K(g, g) + K_c
end
#: **Apoyos** como muelles muy rígidos k_r (el mismo truco que Calcpad en la hoja 77): w de todo el borde. La membrana solo necesita que no se deslice ni gire en su plano: u_x y u_y del nudo 1 y u_y del nudo 11.
k_r = 10^20 'rigidez del muelle de apoyo
#hide
for q = 1:n_j
  if s_b(q) == 1
    K(6·q - 3, 6·q - 3) = K(6·q - 3, 6·q - 3) + k_r
  end
end
K(1, 1) = K(1, 1) + k_r
K(2, 2) = K(2, 2) + k_r
K(6·n_n - 4, 6·n_n - 4) = K(6·n_n - 4, 6·n_n - 4) + k_r
#show
U = clsolve(K, F) 'desplazamientos de los 858 grados de libertad [m, rad]
#: **Equilibrio.** La reacción de cada apoyo es −k_r·w; su suma tiene que ser la carga total:
#hide
R_j = zeros(n_j, 1)
for q = 1:n_j
  if s_b(q) == 1
    R_j(q) = -k_r·U(6·q - 3)
  end
end
#show
R_t = sum(R_j) [tonf] 'suma de las reacciones
Q_t = q_u·l_x·l_y [tonf] 'carga total
d_R = round(100·(R_t - Q_t)/Q_t, 8) [%] 'diferencia
u_mem = max(abs(U(1:6:n_g))) [m] 'mayor desplazamiento u_x de la membrana (sin fuerzas en el plano: 0)

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
    u_e(3·k - 2) = U(6·q - 3)
    u_e(3·k - 1) = U(6·q - 2)
    u_e(3·k) = U(6·q - 1)
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
n_m = (n_y/2)·n_n + n_x/2 + 1 'nudo del centro de la losa
w_c = 1000·U(6·n_m - 3) [mm] 'flecha del centro (negativa = baja)
M_xc = M_s(n_m, 1) [tonf·m/m] 'Mxx en el centro
M_yc = M_s(n_m, 2) [tonf·m/m] 'Myy en el centro
M_xy1 = M_s(1, 3) [tonf·m/m] 'Mxy en la esquina del nudo 1 (el torsor máximo)

## 7 · La membrana no cambia la flexión: la placa sola da lo mismo
#: Se resuelve otra vez SOLO la flexión (3 grados de libertad por nudo, K_p) y se comparan los momentos nudo a nudo con los de la cáscara completa:
#hide
n_3 = 3·n_j
K_3 = zeros(n_3, n_3)
F_3 = zeros(n_3, 1)
for e = 1:n_e
  g_3 = [3·e_j(e, 1) - 2:3·e_j(e, 1), 3·e_j(e, 2) - 2:3·e_j(e, 2), 3·e_j(e, 3) - 2:3·e_j(e, 3), 3·e_j(e, 4) - 2:3·e_j(e, 4)]
  K_3(g_3, g_3) = K_3(g_3, g_3) + K_p
end
for q = 1:n_j
  F_3(3·q - 2) = F(6·q - 3)
  if s_b(q) == 1
    K_3(3·q - 2, 3·q - 2) = K_3(3·q - 2, 3·q - 2) + k_r
  end
end
U_3 = clsolve(K_3, F_3)
M_p = zeros(n_j, 3)
for e = 1:n_e
  u_e = zeros(12, 1)
  for k = 1:4
    q = e_j(e, k)
    u_e(3·k - 2:3·k) = U_3(3·q - 2:3·q)
  end
  m_n = R_E·u_e
  for k = 1:4
    q = e_j(e, k)
    for c = 1:3
      M_p(q, c) = M_p(q, c) + m_n(3·(k - 1) + c)/c_n(q)
    end
  end
end
#show
w_c3 = 1000·U_3(3·n_m - 2) [mm] 'flecha del centro con la placa sola
d_w = abs(w_c3 - w_c) [mm] 'diferencia de flecha, cáscara − placa sola
d_M = max(max(abs(M_p - M_s))) [tonf·m/m] 'mayor diferencia de Mxx, Myy o Mxy en los 143 nudos, cáscara − placa sola
#: **Por qué.** En un elemento plano la membrana (u_x, u_y, θz) y la flexión (w, θx, θy) no comparten ningún término de la K: la carga vertical solo mueve la flexión y la membrana queda en cero (u_mem = 0 arriba). La membrana con giro normal importa cuando hay **fuerzas en el plano** (diafragma con sismo, muros, losas inclinadas o con vigas excéntricas) o cuando la losa se une a barras que sí giran en su plano (columnas en los nudos). En una losa horizontal cargada en vertical, Mxx, Myy y Mxy salen solo del DKQ.

## 8 · Comprobación con Navier (solución exacta)
#: Serie doble de la sección 1 en el centro (x = l_x/2, y = l_y/2), con m, n impares hasta 59:
#hide
w_N = 0
M_xN = 0
M_yN = 0
for m = 1:2:59
  for n = 1:2:59
    s_mn = sin(m·pi/2)·sin(n·pi/2)
    d_mn = m·n·(m^2/l_x^2 + n^2/l_y^2)^2
    w_N = w_N + s_mn/d_mn
    M_xN = M_xN + (m^2/l_x^2 + ν·n^2/l_y^2)·s_mn/d_mn
    M_yN = M_yN + (ν·m^2/l_x^2 + n^2/l_y^2)·s_mn/d_mn
  end
end
w_N = -1000·16·q_u/(pi^6·D_p)·w_N
M_xN = 16·q_u/pi^4·M_xN
M_yN = 16·q_u/pi^4·M_yN
#show
w_Nc = w_N [mm] 'flecha del centro, Navier
M_xNc = M_xN [tonf·m/m] 'Mxx del centro, Navier
M_yNc = M_yN [tonf·m/m] 'Myy del centro, Navier
e_w = round(100·(w_c - w_N)/w_N, 3) [%] 'elementos finitos frente a Navier, flecha
e_Mx = round(100·(M_xc - M_xN)/M_xN, 3) [%] 'idem, Mxx
e_My = round(100·(M_yc - M_yN)/M_yN, 3) [%] 'idem, Myy
#: **Cómo se lee.** Con 10 × 12 elementos la flecha difiere ≈ 0.1 % y los momentos ≈ 0.4-0.7 % de la solución exacta (con 20 × 24 elementos el Mxx baja a 0.16 %: el DKQ converge). Navier con ν = 0.3 y b/a = 1.2 da los coeficientes que tabula Timoshenko (w = α·q·a⁴/D, M = β·q·a²), así que esta comprobación es la misma que la de las tablas.

## 9 · Mapas de Mxx, Myy y Mxy (pasa el cursor: el globo da los tres a la vez)
#hide
W_m = zeros(n_n, n_y + 1)
M_1 = zeros(n_n, n_y + 1)
M_2 = zeros(n_n, n_y + 1)
M_3 = zeros(n_n, n_y + 1)
for j = 1:n_y + 1
  for i = 1:n_n
    q = (j - 1)·n_n + i
    W_m(i, j) = -1000·U(6·q - 3)
    M_1(i, j) = M_s(q, 1)
    M_2(i, j) = M_s(q, 2)
    M_3(i, j) = M_s(q, 3)
  end
end
#show
#: Cada mapa es la planta de 4.00 × 4.80 m vista desde arriba, con x hacia la derecha e y hacia arriba (en metros), pintada con la escala jet de la derecha. Los valores de los nudos se unen con un spline. **Al pasar el cursor** el globo da la posición (x, y) y el valor de TODOS los mapas de esta planta en ese punto (▶ marca el mapa que tienes debajo): la flecha, Mxx, Myy, Mxy y, más abajo, el acero de las cuatro caras.
w_z(x, y) = spline(1 + x/h_x, 1 + y/h_y, W_m)
M_xx(x, y) = spline(1 + x/h_x, 1 + y/h_y, M_1)
M_yy(x, y) = spline(1 + x/h_x, 1 + y/h_y, M_2)
M_xy(x, y) = spline(1 + x/h_x, 1 + y/h_y, M_3)
#: **Flecha** w (mm, hacia abajo). Cómo se lee: es un «plato» con el fondo en el centro (2.37 mm) y cero en los cuatro bordes apoyados.
#map(w_z(x, y), [0 4], [0 4.8])
#: **Mxx** (tonf·m/m): el que arma las varillas paralelas a x. Cómo se lee: máximo en el centro (≈ 1.07, rojo), cero en los bordes x = 0 y x = 4 (apoyo simple: no hay momento), y la franja central es más ancha en y porque la luz corta es la de x.
#map(M_xx(x, y), [0 4], [0 4.8])
#: **Myy** (tonf·m/m): el que arma las varillas paralelas a y. Cómo se lee: menor que Mxx (0.81 en el centro) porque la luz y es la larga; cero en los bordes y = 0 e y = 4.8.
#map(M_yy(x, y), [0 4], [0 4.8])
#: **Mxy** (tonf·m/m, torsor). Cómo se lee: cero en el centro y en los ejes de simetría, máximo en las **esquinas** (≈ ±0.75): el signo cambia de una esquina a la vecina. Es el que levanta las esquinas de una losa apoyada (si la viga no la sujeta) y el que pide acero ARRIBA en las esquinas.
#map(M_xy(x, y), [0 4], [0 4.8])
#: **Corte por el centro**, y = 2.40 m: Mxx de los elementos finitos (nudos) y de Navier. Cómo se lee: las dos curvas casi se tapan; cero en los apoyos x = 0 y x = 4 y máximo en x = 2.
#hide
C_Fe = zeros(n_n, 2)
C_Nv = zeros(41, 2)
for i = 1:n_n
  C_Fe(i, 1) = (i - 1)·h_x
  C_Fe(i, 2) = M_s((n_y/2)·n_n + i, 1)
end
for k = 1:41
  x_k = (k - 1)·l_x/40
  m_k = 0
  for m = 1:2:59
    for n = 1:2:59
      m_k = m_k + (m^2/l_x^2 + ν·n^2/l_y^2)·sin(m·pi·x_k/l_x)·sin(n·pi/2)/(m·n·(m^2/l_x^2 + n^2/l_y^2)^2)
    end
  end
  C_Nv(k, 1) = x_k
  C_Nv(k, 2) = 16·q_u/pi^4·m_k
end
#show
#fplot(Mxx_FEM = C_Fe, Mxx_Navier = C_Nv, [0 4])

## 10 · Diseño: momentos de Wood-Armer y acero (ACI 318-19)
r_ec = 2.0 [cm] 'recubrimiento libre de la losa (ACI 318-19 Tabla 20.5.1.3.1: 20 mm, losa no expuesta)
d_v = 1.0 [cm] 'diámetro de la varilla supuesta, Ø10
d_x = 100·h_l - r_ec - d_v/2 [cm] 'peralte efectivo de las varillas en x (capa exterior, la luz corta)
d_y = d_x - d_v [cm] 'peralte efectivo de las varillas en y (capa interior)
φ_f = 0.9 'factor de reducción a flexión (sección controlada por tracción, se comprueba abajo)
A_smin = 0.0018·100·100·h_l [cm²/m] 'acero mínimo, ACI 318-19 §8.6.1.1 (0.0018·A_g, f_y = 420 MPa), en la cara traccionada
s_max = min(2·100·h_l, 45) [cm] 'separación máxima, ACI 318-19 §8.7.2.2 (2·h y 45 cm)
#: El acero por metro, la fórmula de la sección 1 con b = 100 cm y M_u en tonf·m/m (×10⁵ para kgf·cm):
A_req(M_u, d_c) = 0.85·f_c·100·d_c/f_y·(1 - sqrt(1 - 2·M_u·10^5/(φ_f·0.85·f_c·100·d_c^2)))
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
#: **Momentos de diseño máximos** (Wood-Armer), en valor absoluto:
M_xinf = max(W_A(:, 1)) [tonf·m/m] 'cara inferior, dirección x (centro)
M_yinf = max(W_A(:, 2)) [tonf·m/m] 'cara inferior, dirección y
M_xsup = max(W_A(:, 3)) [tonf·m/m] 'cara superior, dirección x (esquinas, por Mxy)
M_ysup = max(W_A(:, 4)) [tonf·m/m] 'cara superior, dirección y (esquinas)
#: **Acero requerido máximo** por cara y dirección:
A_xinf = A_req(M_xinf, d_x) [cm²/m] 'abajo, varillas en x
A_yinf = A_req(M_yinf, d_y) [cm²/m] 'abajo, varillas en y
A_xsup = A_req(M_xsup, d_x) [cm²/m] 'arriba, varillas en x (esquinas)
A_ysup = A_req(M_ysup, d_y) [cm²/m] 'arriba, varillas en y (esquinas)
#: **Mapas de acero requerido** (cm²/m, sin el mínimo, para ver DÓNDE pide). Cómo se lee: abajo, el acero sigue a Mxx + |Mxy| y My + |Mxy| (máximo en el centro); arriba solo aparece en las cuatro esquinas, por el torsor. Todo valor por debajo de A_smin = 2.70 cm²/m lo cubre el mínimo.
A_xi(x, y) = spline(1 + x/h_x, 1 + y/h_y, A_1)
A_yi(x, y) = spline(1 + x/h_x, 1 + y/h_y, A_2)
A_xs(x, y) = spline(1 + x/h_x, 1 + y/h_y, A_3)
A_ys(x, y) = spline(1 + x/h_x, 1 + y/h_y, A_4)
#: Abajo, dirección x:
#map(A_xi(x, y), [0 4], [0 4.8])
#: Abajo, dirección y:
#map(A_yi(x, y), [0 4], [0 4.8])
#: Arriba, dirección x:
#map(A_xs(x, y), [0 4], [0 4.8])
#: Arriba, dirección y:
#map(A_ys(x, y), [0 4], [0 4.8])

### 10a · Un punto a mano: el centro, abajo en x
#: En el centro Mxy = 0, así que Wood-Armer da Mx⁺ = Mxx. Paso a paso con la fórmula de Whitney:
M_uc = M_xc [tonf·m/m] 'momento último del centro
M_uk = M_uc·10^5 [kgf·cm/m] 'en kgf·cm por metro de ancho
R_nu = M_uk/(φ_f·100·d_x^2) [kgf/cm²] 'resistencia pedida a la sección
ρ_c = 0.85·f_c/f_y·(1 - sqrt(1 - 2·R_nu/(0.85·f_c))) 'cuantía requerida
A_sc = ρ_c·100·d_x [cm²/m] 'acero requerido = A_req del mapa en el centro
a_w = A_sc·f_y/(0.85·f_c·100) [cm] 'profundidad del bloque de compresiones
c_n0 = a_w/0.85 [cm] 'eje neutro (β₁ = 0.85 para f'c ≤ 280 kgf/cm²)
ε_t = 0.003·(d_x - c_n0)/c_n0 'deformación del acero: ≥ 0.005 ⇒ controlada por tracción, φ = 0.9 válido
M_ver = φ_f·A_sc·f_y·(d_x - a_w/2)/10^5 [tonf·m/m] 'comprobación: φ·Mn con ese acero = M_u
#: **Cómo se lee.** 2.30 cm²/m pide el centro, menos que el mínimo de 2.70: en esta losa manda el **acero mínimo** en casi toda la planta. La deformación del acero sale muy por encima de 0.005, así que φ = 0.9 está bien tomado.

### 10b · Armado propuesto
A_b = pi·d_v^2/4 [cm²] 'área de una varilla Ø10
A_dx = max(A_xinf, A_smin) [cm²/m] 'acero de diseño abajo en x
A_dy = max(A_yinf, A_smin) [cm²/m] 'acero de diseño abajo en y
s_x = min(floor(100·A_b/A_dx/2.5)·2.5, s_max) [cm] 'separación abajo en x (múltiplo de 2.5 cm)
s_y = min(floor(100·A_b/A_dy/2.5)·2.5, s_max) [cm] 'separación abajo en y
A_px = 100·A_b/s_x [cm²/m] 'acero colocado abajo en x
A_py = 100·A_b/s_y [cm²/m] 'acero colocado abajo en y
#: **Esquinas (arriba y abajo).** ACI 318-19 §8.7.3.1: en las esquinas exteriores de una losa sobre vigas se arma, arriba y abajo, para el **mayor momento positivo** del paño, en una distancia de l/5 de la luz larga desde la esquina. Wood-Armer pide arriba A_xsup en x y A_ysup en y; se toma el mayor de los dos criterios:
l_esq = l_y/5 [m] 'lado del cuadro de refuerzo de esquina
A_esq = max(max(A_xsup, A_ysup), A_xinf) [cm²/m] 'acero de esquina, arriba, en las dos direcciones
s_e = min(floor(100·A_b/max(A_esq, A_smin)/2.5)·2.5, s_max) [cm] 'separación del refuerzo de esquina
n_bx = floor(100·l_y/s_x) + 1 'varillas abajo en x (repartidas en 4.80 m)
n_by = floor(100·l_x/s_y) + 1 'varillas abajo en y (repartidas en 4.00 m)
n_be = floor(100·l_esq/s_e) + 1 'varillas por dirección en cada esquina
#: Posiciones de las varillas para el dibujo (centradas en la luz; las de esquina, desde 8 cm del borde):
#hide
y_bx = zeros(n_bx, 1)
x_by = zeros(n_by, 1)
p_e = zeros(n_be, 1)
for k = 1:n_bx
  y_bx(k) = (l_y - (n_bx - 1)·s_x/100)/2 + (k - 1)·s_x/100
end
for k = 1:n_by
  x_by(k) = (l_x - (n_by - 1)·s_y/100)/2 + (k - 1)·s_y/100
end
for k = 1:n_be
  p_e(k) = 0.08 + (k - 1)·s_e/100
end
#show
#: **Cómo se lee la planta de armado.** Dos plantas iguales de la losa, una al lado de la otra para que los rótulos no se crucen con las varillas de la otra dirección. **Izquierda:** las varillas en x (paralelas a la luz corta, capa exterior de abajo); **derecha:** las varillas en y (capa interior de abajo). Se dibujan TODAS, a su separación real; la roja con ganchos es la varilla tipo y su rótulo dice «cantidad Ø diámetro @ separación». Las cotas dan las luces.
#dibujo("Armado inferior: Ø10 en x (izquierda) y Ø10 en y (derecha)", ud = m, escala = auto, cotas = m, alto = 175)
#  rect(0, 0, 4.0, 4.8, "gruesa")
#  rect(5.5, 0, 4.0, 4.8, "gruesa")
#  rect(0.05, y_bx, 3.9, 0, "fina")
#  rect(5.5 + x_by, 0.05, 0, 4.7, "fina")
#  varillas(0.05, y_bx(9), 3.95, y_bx(9), n_bx, 10, s_x, 90, 90, 1)
#  varillas(5.5 + x_by(7), 0.05, 5.5 + x_by(7), 4.75, n_by, 10, s_y, 90, 90, 1)
#  texto(2.0, 5.15, "abajo, en x (capa exterior)", 2.5, "c")
#  texto(7.5, 5.15, "abajo, en y (capa interior)", 2.5, "c")
#  cota(0, -0.45, 4.0, -0.45, -0.05, "4.00")
#  cota(5.5, -0.45, 9.5, -0.45, -0.05, "4.00")
#  cota(-0.45, 0, -0.45, 4.8, 0.05, "4.80")
#fin
#: **Cómo se lee el armado superior.** Solo hay acero arriba en las cuatro esquinas: un cuadro de l/5 = 0.96 m (trazos rojos) con @{n_be} varillas Ø10 en x y @{n_be} en y (líneas rojas). El centro de la losa no lleva acero arriba porque ahí el momento es positivo en todas partes (tracción abajo).
#dibujo("Armado superior: refuerzo de esquina (ACI 318-19 §8.7.3)", ud = m, escala = auto, cotas = m, alto = 175)
#  rect(0, 0, 4.0, 4.8, "gruesa")
#  rect(0, 0, l_esq, l_esq, "trazos rojo")
#  rect(4.0 - l_esq, 0, l_esq, l_esq, "trazos rojo")
#  rect(0, 4.8 - l_esq, l_esq, l_esq, "trazos rojo")
#  rect(4.0 - l_esq, 4.8 - l_esq, l_esq, l_esq, "trazos rojo")
#  rect(0.03, p_e, l_esq - 0.03, 0, "media rojo")
#  rect(p_e, 0.03, 0, l_esq - 0.03, "media rojo")
#  rect(4.0 - l_esq, p_e, l_esq - 0.03, 0, "media rojo")
#  rect(4.0 - p_e, 0.03, 0, l_esq - 0.03, "media rojo")
#  rect(0.03, 4.8 - p_e, l_esq - 0.03, 0, "media rojo")
#  rect(p_e, 4.8 - l_esq, 0, l_esq - 0.03, "media rojo")
#  rect(4.0 - l_esq, 4.8 - p_e, l_esq - 0.03, 0, "media rojo")
#  rect(4.0 - p_e, 4.8 - l_esq, 0, l_esq - 0.03, "media rojo")
#  texto(2.0, 2.65, "en cada esquina, arriba:", 2.5, "c", estilo = "rojo")
#  texto(2.0, 2.25, "{n_be:0} Ø10 @ {s_e:1} cm en x y en y", 2.5, "c", estilo = "rojo")
#  texto(2.0, 1.85, "centro: sin acero superior", 2.4, "c")
#  cota(0, -0.45, l_esq, -0.45, -0.05, "{l_esq:2}")
#  cota(0, -0.45, 4.0, -0.45, -0.40, "4.00")
#  cota(-0.45, 0, -0.45, 4.8, 0.05, "4.80")
#  cota(4.45, 4.8 - l_esq, 4.45, 4.8, -0.05, "{l_esq:2}")
#fin
#: **Corte A-A con el armado** (vertical exagerada ×5 para que se vean las capas). Cómo se lee: los puntos son las varillas en y cortadas (capa interior de abajo); la línea de abajo es una varilla en x (capa exterior, la de mayor peralte d_{x}); arriba hay acero solo en las esquinas (trazos rojos de l/5 a cada lado). Los rótulos van fuera de la sección.
#dibujo("Corte A-A: capas de acero (vertical ×5)", ud = m, ancho = 180, vert = 5, cotas = m)
#  seccion(0, 0, 4.0, 0.15)
#  varilla(0.03, 0.025, 3.97, 0.025, 10, 90, 90, "", 1)
#  fila(x_by(1), 0.037, x_by(n_by), 0.037, n_by, 10, s_y, 1, rotulo = "no")
#  varilla(0.03, 0.12, l_esq, 0.12, 10, -90, 0, "", 1, estilo = "rojo")
#  varilla(4.0 - l_esq, 0.12, 3.97, 0.12, 10, 0, -90, "", 1, estilo = "rojo")
#  texto(2.0, -0.035, "abajo: Ø10 @ {s_x:1} cm en x (línea) y Ø10 @ {s_y:1} cm en y (puntos)", 2.3, "c")
#  texto(0.0, 0.19, "arriba, esquina: Ø10 @ {s_e:1} cm", 2.3, "i", estilo = "rojo")
#  texto(4.0, 0.19, "esquina", 2.3, "d", estilo = "rojo")
#  cota(0, -0.11, 4.0, -0.11, -0.02, "4.00")
#  texto(4.12, 0.075, "h = 0.15", 2.3, "i")
#fin

## 11 · Cortante (las vigas reciben la losa)
#: La losa apoyada en vigas no tiene punzonamiento (no hay columnas): se revisa el cortante en una vía en el borde. La reacción de borde por metro es la del nudo dividida para su ancho tributario; el mayor está en el medio de cada lado:
v_ux = R_j((n_y/2)·n_n + 1)/h_y [tonf/m] 'reacción por metro en el medio del borde x = 0 (sostiene la luz corta)
v_uy = R_j(n_x/2 + 1)/h_x [tonf/m] 'reacción por metro en el medio del borde y = 0
R_esq = R_j(1) [tonf] 'reacción de la esquina (negativa: la viga sujeta la esquina, que quiere levantarse)
#: Resistencia del hormigón a cortante sin estribos, ACI 318-19 Tabla 22.5.5.1 (c), en MPa y mm: V_c = 0.66·λ_s·ρ_w^(1/3)·√f'c·b·d, con λ_s = √(2/(1 + 0.004·d)) ≤ 1:
d_mm = 10·d_x [mm] 'peralte en mm
λ_s = min(sqrt(2/(1 + 0.004·d_mm)), 1) 'efecto de tamaño
ρ_w = A_px/(100·d_x) 'cuantía del acero colocado en x
V_cN = 0.66·λ_s·ρ_w^(1/3)·sqrt(f_cM)·1000·d_mm/1000 [kN/m] 'resistencia nominal por metro
V_cmax = 0.42·sqrt(f_cM)·1000·d_mm/1000 [kN/m] 'tope de ACI 318-19 §22.5.5.1.1
V_cd = 0.75·min(V_cN, V_cmax)/9.80665 [tonf/m] 'resistencia de diseño (φ = 0.75)
r_V = max(v_ux, v_uy)/V_cd 'demanda/capacidad (≤ 1 cumple; conservador: la reacción en el eje, no a d de la cara)
#: **Cómo se lee.** La losa trabaja a cortante con holgura (r_V bastante menor que 1): en losas macizas sobre vigas casi nunca manda el cortante. La reacción NEGATIVA de las esquinas es la fuerza con que la viga tiene que sujetar la esquina (la losa apoyada quiere levantarlas, por el torsor Mxy): se ancla con el armado superior de esquina y la continuidad viga-losa.

## 12 · Espesor mínimo (ACI 318-19 Tabla 8.3.1.2, losa con vigas rígidas, α_fm > 2)
l_n = l_y - 0.30 [m] 'luz libre larga (vigas de 30 cm)
β_l = (l_y - 0.30)/(l_x - 0.30) 'relación de luces libres
h_min = max(1000·l_n·(0.8 + f_y·0.0980665/1400)/(36 + 9·β_l), 90) [mm] 'espesor mínimo para no calcular deflexiones
#: 15 cm > h_min: cumple sin calcular la flecha a largo plazo.

## 13 · Resumen
#hide
r_wc = round(w_c, 4)
r_wN = round(w_N, 4)
r_Mx = round(M_xc, 4)
r_MxN = round(M_xN, 4)
r_My = round(M_yc, 4)
r_MyN = round(M_yN, 4)
r_Mxy = round(M_xy1, 4)
r_R = round(R_t, 4)
r_Q = round(Q_t, 4)
r_Ai = round(A_xinf, 2)
r_Ayi = round(A_yinf, 2)
r_As = round(A_xsup, 2)
r_Ays = round(A_ysup, 2)
r_dw = round(d_w, 10)
#show
#| Magnitud | Elementos finitos (cáscara CSI) | Referencia | Diferencia |
#|---|---:|---:|---:|
#| flecha del centro [mm] | @{r_wc} | Navier @{r_wN} | @{e_w} % |
#| Mxx del centro [tonf·m/m] | @{r_Mx} | Navier @{r_MxN} | @{e_Mx} % |
#| Myy del centro [tonf·m/m] | @{r_My} | Navier @{r_MyN} | @{e_My} % |
#| Mxy de la esquina [tonf·m/m] | @{r_Mxy} | — | — |
#| suma de reacciones [tonf] | @{r_R} | q_u·l_x·l_y = @{r_Q} | @{d_R} % |
#| flecha cáscara − placa sola [mm] | @{r_dw} | 0 | — |
#| acero abajo x / y requerido [cm²/m] | @{r_Ai} / @{r_Ayi} | mínimo 2.70 | manda el mínimo |
#| acero arriba x / y requerido (esquinas) [cm²/m] | @{r_As} / @{r_Ays} | ACI §8.7.3: = el de abajo | esquinas |
#: **Armado:** abajo Ø10 @ @{s_x} cm en x y Ø10 @ @{s_y} cm en y en toda la losa; arriba, en cada esquina, un cuadro de @{l_esq} m con Ø10 @ @{s_e} cm en las dos direcciones. **Siguiente:** varios paños continuos (vigas y columnas), donde aparecen los momentos negativos sobre los apoyos interiores y las franjas de columna y central.
