# Diagrama de interacción P–M de un muro con elementos de borde distintos: compatibilidad de deformaciones, centroide plástico y los dos sentidos
#numerico

## 1 · El muro
#: Muro rectangular de concreto armado con **elementos de borde distintos** a cada lado: el izquierdo más grueso y con más acero. Por eso **la capacidad no es la misma** si se comprime el lado izquierdo (caso 1) o el derecho (caso 2), y el momento se mide respecto al **centroide plástico**, no al geométrico. Método ACI 318: compatibilidad de deformaciones (ε_cu = 0.003), bloque de Whitney y acero elastoplástico. Datos propios de esta hoja.
#dibujo("Planta del muro con TODO el acero (las mismas posiciones que usa el cálculo)", ud = m, escala = auto, cotas = m, alto = 70)
#  poligono(0, -0.2, 0.6, -0.2, 0.6, -0.125, 3.5, -0.125, 3.5, -0.15, 4, -0.15, 4, 0.15, 3.5, 0.15, 3.5, 0.125, 0.6, 0.125, 0.6, 0.2, 0, 0.2, "gruesa")
#  estribo(0, -0.2, 0.6, 0.4, 0.04, 10)
#  estribo(3.5, -0.15, 0.5, 0.3, 0.04, 10)
#  circulo(0.060, -0.140, 0.0100, "rojo relleno")
#  circulo(0.060, 0.000, 0.0100, "rojo relleno")
#  circulo(0.060, 0.140, 0.0100, "rojo relleno")
#  circulo(0.300, -0.140, 0.0100, "rojo relleno")
#  circulo(0.300, 0.140, 0.0100, "rojo relleno")
#  circulo(0.540, -0.140, 0.0100, "rojo relleno")
#  circulo(0.540, 0.000, 0.0100, "rojo relleno")
#  circulo(0.540, 0.140, 0.0100, "rojo relleno")
#  circulo(3.940, -0.090, 0.0080, "azul relleno")
#  circulo(3.940, 0.090, 0.0080, "azul relleno")
#  circulo(3.750, -0.090, 0.0080, "azul relleno")
#  circulo(3.750, 0.090, 0.0080, "azul relleno")
#  circulo(3.560, -0.090, 0.0080, "azul relleno")
#  circulo(3.560, 0.090, 0.0080, "azul relleno")
#  circulo(0.800, -0.085, 0.0050, "verde relleno")
#  circulo(0.800, 0.085, 0.0050, "verde relleno")
#  circulo(1.000, -0.085, 0.0050, "verde relleno")
#  circulo(1.000, 0.085, 0.0050, "verde relleno")
#  circulo(1.200, -0.085, 0.0050, "verde relleno")
#  circulo(1.200, 0.085, 0.0050, "verde relleno")
#  circulo(1.400, -0.085, 0.0050, "verde relleno")
#  circulo(1.400, 0.085, 0.0050, "verde relleno")
#  circulo(1.600, -0.085, 0.0050, "verde relleno")
#  circulo(1.600, 0.085, 0.0050, "verde relleno")
#  circulo(1.800, -0.085, 0.0050, "verde relleno")
#  circulo(1.800, 0.085, 0.0050, "verde relleno")
#  circulo(2.000, -0.085, 0.0050, "verde relleno")
#  circulo(2.000, 0.085, 0.0050, "verde relleno")
#  circulo(2.200, -0.085, 0.0050, "verde relleno")
#  circulo(2.200, 0.085, 0.0050, "verde relleno")
#  circulo(2.400, -0.085, 0.0050, "verde relleno")
#  circulo(2.400, 0.085, 0.0050, "verde relleno")
#  circulo(2.600, -0.085, 0.0050, "verde relleno")
#  circulo(2.600, 0.085, 0.0050, "verde relleno")
#  circulo(2.800, -0.085, 0.0050, "verde relleno")
#  circulo(2.800, 0.085, 0.0050, "verde relleno")
#  circulo(3.000, -0.085, 0.0050, "verde relleno")
#  circulo(3.000, 0.085, 0.0050, "verde relleno")
#  circulo(3.200, -0.085, 0.0050, "verde relleno")
#  circulo(3.200, 0.085, 0.0050, "verde relleno")
#  circulo(3.400, -0.085, 0.0050, "verde relleno")
#  circulo(3.400, 0.085, 0.0050, "verde relleno")
#  texto(0.3, 0.42, "borde 1: 8φ20", 2.2, "c")
#  texto(3.75, 0.36, "borde 2: 6φ16", 2.2, "c")
#  texto(2.05, 0.30, "alma: φ10 @ 0.20 m en 2 capas (vertical)", 2.2, "c")
#  cota(0, -0.45, 0.6, -0.45, 0, "l_1 = 0.60")
#  cota(0.6, -0.45, 3.5, -0.45, 0, "alma 2.90")
#  cota(3.5, -0.45, 4, -0.45, 0, "l_2 = 0.50")
#fin
#: **El detallado de los elementos de borde** (las barras longitudinales en rojo y azul son las que entran al diagrama P–M; el estribo y la traba confinan el núcleo):
#dibujo("Detalle del borde 1 (0.40 × 0.60): 8φ20, estribo φ10 y traba", ud = m, escala = auto, cotas = m, alto = 120)
#  poligono(0, -0.2, 0.6, -0.2, 0.6, -0.125, 0.75, -0.125, 0.75, 0.125, 0.6, 0.125, 0.6, 0.2, 0, 0.2, "gruesa")
#  estribo(0, -0.2, 0.6, 0.4, 0.04, 10)
#  linea(0.30, -0.16, 0.30, 0.16, "fina")
#  circulo(0.060, -0.140, 0.0100, "rojo relleno")
#  circulo(0.060, 0.000, 0.0100, "rojo relleno")
#  circulo(0.060, 0.140, 0.0100, "rojo relleno")
#  circulo(0.300, -0.140, 0.0100, "rojo relleno")
#  circulo(0.300, 0.140, 0.0100, "rojo relleno")
#  circulo(0.540, -0.140, 0.0100, "rojo relleno")
#  circulo(0.540, 0.000, 0.0100, "rojo relleno")
#  circulo(0.540, 0.140, 0.0100, "rojo relleno")
#  cota(0, -0.28, 0.06, -0.28, 0, "0.06")
#  cota(0.06, -0.28, 0.30, -0.28, 0, "0.24")
#  cota(0.30, -0.28, 0.54, -0.28, 0, "0.24")
#  cota(0.54, -0.28, 0.6, -0.28, 0, "0.06")
#  cota(-0.08, -0.14, -0.08, 0, 0, "0.14")
#  cota(-0.08, 0, -0.08, 0.14, 0, "0.14")
#  texto(0.3, 0.27, "8φ20: filas de 3 + 2 + 3; recubrimiento 4 cm al estribo", 2.0, "c")
#  texto(0.3, -0.38, "estribo φ10 cerrado con ganchos a 135°, traba φ10 en la fila central", 2.0, "c")
#fin
#dibujo("Detalle del borde 2 (0.30 × 0.50): 6φ16 y estribo φ10", ud = m, escala = auto, cotas = m, alto = 80)
#  poligono(3.35, -0.125, 3.5, -0.125, 3.5, -0.15, 4, -0.15, 4, 0.15, 3.5, 0.15, 3.5, 0.125, 3.35, 0.125, "gruesa")
#  estribo(3.5, -0.15, 0.5, 0.3, 0.04, 10)
#  circulo(3.940, -0.090, 0.0080, "azul relleno")
#  circulo(3.940, 0.090, 0.0080, "azul relleno")
#  circulo(3.750, -0.090, 0.0080, "azul relleno")
#  circulo(3.750, 0.090, 0.0080, "azul relleno")
#  circulo(3.560, -0.090, 0.0080, "azul relleno")
#  circulo(3.560, 0.090, 0.0080, "azul relleno")
#  cota(3.5, -0.23, 3.56, -0.23, 0, "0.06")
#  cota(3.56, -0.23, 3.75, -0.23, 0, "0.19")
#  cota(3.75, -0.23, 3.94, -0.23, 0, "0.19")
#  cota(3.94, -0.23, 4, -0.23, 0, "0.06")
#  cota(4.22, -0.09, 4.22, 0.09, 0, "0.18")
#  texto(3.75, 0.22, "6φ16 en 3 filas de 2; recubrimiento 4 cm", 2.0, "c")
#fin

## 2 · Primero con símbolos
#: **Compatibilidad:** las secciones planas siguen planas. Con el eje neutro a una distancia c del borde comprimido, la deformación de una barra a la distancia d es:
u_e = Simplify{e_cu*(c - d)/c}
#: y su esfuerzo es **f_s = E_s·ε_s**, con tope **±f_y**. **Concreto:** bloque de Whitney de profundidad a = β₁·c con esfuerzo 0.85·f'c sobre el espesor t(x) de cada tramo:
C_c = Simplify{0.85*f_c*(t_1*s_1 + t_w*s_2 + t_2*s_3)}
#: (s₁, s₂, s₃ = el largo comprimido de cada tramo: borde, alma y el otro borde). **Equilibrio** (compresión positiva; x_c es dónde actúa C_c y x_i dónde está cada barra, medido desde el borde comprimido):
P_n = Simplify{C_c + A_1*f_1 + A_2*f_2}
M_n = Simplify{C_c*(x_p - x_c) + A_1*f_1*(x_p - x_1) + A_2*f_2*(x_p - x_2)}
#: (con todas las barras es Σ Aᵢ·fᵢ; las barras dentro del bloque restan el concreto que desplazan: fᵢ − 0.85·f'c). **El centroide plástico** es donde actúa la carga axial máxima con todo el concreto y todo el acero en fluencia:
#: **x_pc = [0.85·f'c·(A_g·x_g − S_x) + f_y·S_x] / [0.85·f'c·(A_g − A_st) + f_y·A_st]**
#: (S_x = Σ Aᵢ·xᵢ del acero, con el centro del concreto corregido por las barras). **Compresión pura** y **factor φ** de ACI según la deformación ε_t del acero más traccionado:
P_0 = Simplify{0.85*f_c*(A_g - A_st) + f_y*A_st}
p_f = Simplify{0.65 + 0.25*(e_t - e_y)/(0.005 - e_y)}
#: (φ = 0.65 si ε_t ≤ ε_y, 0.90 si ε_t ≥ 0.005, y esa recta en medio).

## 3 · Ahora con números (con unidades)
f_c = 28000 'resistencia del concreto f'c = 28 MPa [kPa]
f_y = 420000 'fluencia del acero [kPa]
E_s = 200000000 'módulo del acero [kPa]
e_c = 0.003 'deformación última del concreto [-]
b_1 = 0.85 'β₁ (f'c ≤ 28 MPa) [-]
l_w = 4 'largo del muro [m]
t_w = 0.25 'espesor del alma [m]
t_1 = 0.40 'espesor del borde 1 (izquierdo) [m]
l_1 = 0.60 'largo del borde 1 [m]
t_2 = 0.30 'espesor del borde 2 (derecho) [m]
l_2 = 0.50 'largo del borde 2 [m]
#: **El acero** (posición x desde el borde izquierdo y área de cada fila): borde 1 con 8φ20 en tres filas, borde 2 con 6φ16 en tres filas, y el alma con φ10 @ 0.20 m en dos capas:
r_20 = pi·0.020^2/4 'área de una φ20 [m²]
r_16 = pi·0.016^2/4 'área de una φ16 [m²]
r_10 = pi·0.010^2/4 'área de una φ10 [m²]
#hide
n_b = 20
x_s = zeros(n_b, 1)
A_s = zeros(n_b, 1)
x_s(1) = 0.06
x_s(2) = 0.30
x_s(3) = 0.54
A_s(1) = 3·r_20
A_s(2) = 2·r_20
A_s(3) = 3·r_20
x_s(4) = l_w - 0.06
x_s(5) = l_w - 0.25
x_s(6) = l_w - 0.44
A_s(4) = 2·r_16
A_s(5) = 2·r_16
A_s(6) = 2·r_16
for i = 7:n_b
  x_s(i) = 0.80 + 0.20·(i - 7)
  A_s(i) = 2·r_10
end
#show
A_g = t_1·l_1 + t_w·(l_w - l_1 - l_2) + t_2·l_2 'área bruta [m²]
A_st = sum(A_s) 'área total de acero [m²]
r_h = A_st/A_g 'cuantía [-]
x_g = (t_1·l_1^2/2 + t_w·(l_w - l_1 - l_2)·(l_1 + (l_w - l_1 - l_2)/2) + t_2·l_2·(l_w - l_2/2))/A_g 'centroide geométrico [m]
S_x = sum(A_s.*x_s) 'Σ Aᵢ·xᵢ del acero [m³]
x_pc = (0.85·f_c·(A_g·x_g - S_x) + f_y·S_x)/(0.85·f_c·(A_g - A_st) + f_y·A_st) 'centroide plástico (desde el borde 1) [m]
P_00 = 0.85·f_c·(A_g - A_st) + f_y·A_st 'compresión pura P₀ [kN]
P_t = -f_y·A_st 'tracción pura [kN]
#: El centroide plástico (1.883 m) está **más cerca del borde 1** que el geométrico (1.902 m): el lado con más acero «tira» de la resultante. Es el punto respecto al que se mide M.

## 4 · El barrido del eje neutro (los dos sentidos)
#: Para cada profundidad del eje neutro c (de 5 cm a 6 m) se calculan las deformaciones, los esfuerzos, C_c, P_n y M_n. **Caso 1:** se comprime el borde 1 (izquierdo). **Caso 2:** se comprime el borde 2: el mismo cálculo con el muro dado vuelta (x → l_w − x).
#hide
n_c = 50
R_1 = zeros(n_c, 5)
R_2 = zeros(n_c, 5)
for k_s = 1:2
  if k_s == 1
    h_1 = t_1
    g_1 = l_1
    h_2 = t_2
    g_2 = l_2
    x_q = x_pc
  end
  if k_s == 2
    h_1 = t_2
    g_1 = l_2
    h_2 = t_1
    g_2 = l_1
    x_q = l_w - x_pc
  end
  for k = 1:n_c
    if k <= 10
      c_n = 0.05 + 0.05·(k - 1)
    end
    if k > 10
      c_n = 0.55 + (6 - 0.55)·(k - 11)/39
    end
    a_w = min(b_1·c_n, l_w)
    s_1 = min(a_w, g_1)
    s_2 = min(max(a_w - g_1, 0), l_w - g_1 - g_2)
    s_3 = min(max(a_w - l_w + g_2, 0), g_2)
    A_a = h_1·s_1 + t_w·s_2 + h_2·s_3
    Q_a = h_1·s_1^2/2 + t_w·s_2·(g_1 + s_2/2) + h_2·s_3·(l_w - g_2 + s_3/2)
    K_c = 0.85·f_c·A_a
    x_k = Q_a/A_a
    P_k = K_c
    M_k = K_c·(x_q - x_k)
    d_m = 0
    for i = 1:n_b
      x_i = x_s(i)
      if k_s == 2
        x_i = l_w - x_s(i)
      end
      e_i = e_c·(c_n - x_i)/c_n
      f_i = min(max(E_s·e_i, -f_y), f_y)
      if x_i < a_w
        f_i = f_i - 0.85·f_c
      end
      P_k = P_k + A_s(i)·f_i
      M_k = M_k + A_s(i)·f_i·(x_q - x_i)
      d_m = max(d_m, x_i)
    end
    e_t = -e_c·(c_n - d_m)/c_n
    p_h = 0.65 + 0.25·(e_t - f_y/E_s)/(0.005 - f_y/E_s)
    p_h = min(max(p_h, 0.65), 0.9)
    if k_s == 1
      R_1(k, 1) = c_n
      R_1(k, 2) = P_k
      R_1(k, 3) = M_k
      R_1(k, 4) = p_h
      R_1(k, 5) = e_t
    end
    if k_s == 2
      R_2(k, 1) = c_n
      R_2(k, 2) = P_k
      R_2(k, 3) = M_k
      R_2(k, 4) = p_h
      R_2(k, 5) = e_t
    end
  end
end
N_1 = zeros(n_c + 2, 2)
N_2 = zeros(n_c + 2, 2)
D_1 = zeros(n_c + 2, 2)
D_2 = zeros(n_c + 2, 2)
N_1(1, 1) = 0
N_1(1, 2) = P_t
N_2(1, 1) = 0
N_2(1, 2) = P_t
D_1(1, 1) = 0
D_1(1, 2) = 0.9·P_t
D_2(1, 1) = 0
D_2(1, 2) = 0.9·P_t
for k = 1:n_c
  N_1(k + 1, 1) = R_1(k, 3)
  N_1(k + 1, 2) = R_1(k, 2)
  N_2(k + 1, 1) = -R_2(k, 3)
  N_2(k + 1, 2) = R_2(k, 2)
  D_1(k + 1, 1) = R_1(k, 4)·R_1(k, 3)
  D_1(k + 1, 2) = min(R_1(k, 4)·R_1(k, 2), 0.8·0.65·P_00)
  D_2(k + 1, 1) = -R_2(k, 4)·R_2(k, 3)
  D_2(k + 1, 2) = min(R_2(k, 4)·R_2(k, 2), 0.8·0.65·P_00)
end
N_1(n_c + 2, 1) = 0
N_1(n_c + 2, 2) = P_00
N_2(n_c + 2, 1) = 0
N_2(n_c + 2, 2) = P_00
D_1(n_c + 2, 1) = 0
D_1(n_c + 2, 2) = 0.8·0.65·P_00
D_2(n_c + 2, 1) = 0
D_2(n_c + 2, 2) = 0.8·0.65·P_00
M_1 = 0
M_2 = 0
c_1 = 0
c_2 = 0
for k = 1:n_c
  if R_1(k, 3) > M_1
    M_1 = R_1(k, 3)
    c_1 = R_1(k, 1)
  end
  if R_2(k, 3) > M_2
    M_2 = R_2(k, 3)
    c_2 = R_2(k, 1)
  end
end
z_1 = 0
z_2 = 0
for k = 1:n_c - 1
  if R_1(k, 2)·R_1(k + 1, 2) <= 0
    z_1 = R_1(k, 3) + (R_1(k + 1, 3) - R_1(k, 3))·(0 - R_1(k, 2))/(R_1(k + 1, 2) - R_1(k, 2))
  end
  if R_2(k, 2)·R_2(k + 1, 2) <= 0
    z_2 = R_2(k, 3) + (R_2(k + 1, 3) - R_2(k, 3))·(0 - R_2(k, 2))/(R_2(k + 1, 2) - R_2(k, 2))
  end
end
#show
#: **El diagrama de interacción** (eje horizontal: M en kN·m, a la derecha el caso 1 y a la izquierda el caso 2; eje vertical: P en kN, compresión arriba). Nominal (Pn, Mn) y de diseño (φPn, φMn, con el tope 0.80·φ·P₀). Pasa el cursor:
#fplot(nominal_1 = N_1, nominal_2 = N_2, diseno_1 = D_1, diseno_2 = D_2, [-20000 20000])

## 5 · Los puntos clave
M_1 'momento máximo, caso 1 (borde 1 comprimido) [kN·m]
c_1 'eje neutro del momento máximo, caso 1 [m]
M_2 'momento máximo, caso 2 (borde 2 comprimido) [kN·m]
c_2 'eje neutro del momento máximo, caso 2 [m]
z_1 'flexión pura (P = 0), caso 1 [kN·m]
z_2 'flexión pura (P = 0), caso 2 [kN·m]
#: **Las dos ramas no son iguales**: con el borde 2 comprimido (el pequeño) trabaja en tracción el borde 1, que tiene más acero, y la flexión pura es mayor. Con el borde 1 comprimido, la compresión cae en el bloque grueso pero tracciona el borde con menos acero. Por eso un muro asimétrico debe revisarse **en los dos sentidos**.

## 6 · La deformación en 2D y en 3D
#: La deformación del muro en cada punto x para cada posición del eje neutro c (ε = 0.003·(c − x)/c, en ‰; positiva = compresión; la tracción se corta en −10 ‰ para que se vea la escala). La línea de cero es el eje neutro. Pasa el cursor (x = posición en el muro [m], y = profundidad del eje neutro c [m]):
e_p(x, y) = max(3·(y - x)/y, -10)
#map(e_p(x, y), [0 4], [0.5 6])
#surf(e_p(x, y), [0 4], [0.5 6])
