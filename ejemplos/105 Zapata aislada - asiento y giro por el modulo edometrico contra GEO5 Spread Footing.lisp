# Zapata aislada: asiento y giro con el módulo edométrico, contra GEO5
#numerico

#: **Qué se calcula.** El marco «Settlement» de GEO5 Spread Footing para la zapata del ejemplo oficial **Demo01.gpa** (1.20 × 1.20 m): el **asiento** del punto característico, la **profundidad de la zona de influencia**, la **rigidez** de la zapata y los dos **giros**.
#: **Cómo lo hace GEO5** (Settings del ejemplo): «Analysis using oedometric modulus», zona de influencia limitada por la **resistencia estructural** del suelo, presión en el fondo descontada desde la rasante y coeficiente κ₁ de profundidad activado. Las fórmulas son las de la ayuda oficial de GEO5 2024 («Analysis Using the Oedometric Modulus», «Theory of Structural Strength», «Increment of Earth Pressure under Footing», «Influence of Foundation Depth», «Overall Settlement and Rotation of Foundation»), leídas del archivo de ayuda, no de memoria.
#: **Juez.** El informe de GEO5 2024 con «Partial results»: la tabla de 24 capas (origen, fin, E_{def}, σ_{or}, Δσ_{z}, asiento) y los asientos de los bordes. Al final, **Hekatan contra GEO5** con la diferencia en %.

## 1 · Datos

#: **El suelo** (los dos estratos del Demo01, con lo que pide el asiento):
gamma_1 = 17.5 'peso específico del suelo 1 [kN/m3]
gamma_s2 = 22 'peso específico del suelo 2 [kN/m3]
gamma_u2 = 12 'peso sumergido del suelo 2, bajo el agua [kN/m3]
E_d1 = 21 'módulo de deformación del suelo 1 [MPa]
nu_1 = 0.3 'coeficiente de Poisson del suelo 1
E_d2 = 1000 'módulo de deformación del suelo 2 [MPa]
nu_2 = 0.2 'coeficiente de Poisson del suelo 2
m_s = 0.3 'coeficiente de resistencia estructural (los dos suelos)
z_12 = 3 'profundidad del contacto suelo 1 / suelo 2 [m]
z_w = 4 'profundidad del nivel freático [m]
#: **La zapata**: el fondo está a 2.00 m del terreno original y a d = 1.20 m de la rasante.
l_x = 1.2 'lado en x [m]
l_y = 1.2 'lado en y [m]
t_z = 0.4 'canto [m]
d_f = 1.2 'profundidad del fondo desde la rasante [m]
z_f = 2 'profundidad del fondo desde el terreno original [m]
E_cm = 30000 'módulo del hormigón C20/25 [MPa]
#: **Las cargas de servicio.** GEO5 elige la más desfavorable para el asiento: la Load No. 3 (axial grande con horizontal en x); la Load No. 4 (momento en x) es la que da el giro en y.
N_3 = 1500 'axial de la carga 3 [kN]
H_x3 = 100 'horizontal en x de la carga 3 [kN]
N_4 = 700 'axial de la carga 4 [kN]
M_x4 = 100 'momento alrededor de x de la carga 4 [kN·m]
G_z = 13.248 'peso de la zapata (hoja 104: 1.2·1.2·0.4·23) [kN]
Z_r = 20.48 'peso del relleno sobre la zapata (hoja 104) [kN]
#: **La sobrecarga** del Demo01: 15 kPa sobre un cuadrado de 2 × 2 m a 3 m del eje, en el terreno original.
q_s = 15 'sobrecarga [kPa]

## 2 · La presión en el fondo y la que realmente asienta

V_3 = N_3 + G_z + Z_r 'vertical en el fondo, carga 3 [kN]
sigma_3 = V_3/(l_x·l_y) 'presión media, carga 3 [kPa]
#: Ayuda «Stress in the Footing Bottom»: antes de repartir la presión en profundidad se le descuenta la tensión que ya tenía el suelo a esa cota. Con la opción «from the finished grade», es la de la rasante:
sigma_sp = gamma_1·d_f 'tensión geostática del fondo, desde la rasante [kPa]
q_n = sigma_3 - sigma_sp 'presión neta que asienta [kPa]
#: **Excentricidades de servicio** (la verificación del 2.º estado límite; GEO5 las imprime relativas):
e_x3 = H_x3·t_z/V_3 'excentricidad en x, carga 3 [m]
V_4 = N_4 + G_z + Z_r 'vertical en el fondo, carga 4 [kN]
e_y4 = M_x4/V_4 'excentricidad en y, carga 4 [m]
er_x = e_x3/l_x 'relativa en x (GEO5: 0.022)
er_y = e_y4/l_y 'relativa en y (GEO5: 0.114)
#: Para los **giros** hace falta la presión de cada borde (trapecio, flexión compuesta), ya neta:
q_3M = V_3/(l_x·l_y) + V_3·e_x3/(l_y·l_x^2/6) - sigma_sp 'borde más cargado, carga 3 [kPa]
q_3m = V_3/(l_x·l_y) - V_3·e_x3/(l_y·l_x^2/6) - sigma_sp 'borde menos cargado, carga 3 [kPa]
q_4M = V_4/(l_x·l_y) + V_4·e_y4/(l_x·l_y^2/6) - sigma_sp 'borde más cargado, carga 4 [kPa]
q_4m = V_4/(l_x·l_y) - V_4·e_y4/(l_x·l_y^2/6) - sigma_sp 'borde menos cargado, carga 4 [kPa]

## 3 · La tensión geostática σ_{or}

#: Se mide desde el **terreno original**: suelo 1 hasta 3 m, suelo 2 hasta el agua (4 m) y sumergido debajo.
sigma_or(z) = gamma_1·min(z, z_12) + gamma_s2·max(0, min(z, z_w) - z_12) + gamma_u2·max(0, z - z_w)
s_or1 = sigma_or(2.025) 'en el centro de la 1.ª capa (GEO5: 35.44) [kPa]
s_or19 = sigma_or(4.075) 'en el centro de la capa 19, ya bajo el agua (GEO5: 75.40) [kPa]

## 4 · El incremento de tensión bajo la zapata (Steinbrenner)

#: Ayuda «Increment of Earth Pressure under Footing»: bajo la **esquina** de un rectángulo l × b cargado con f, a la profundidad z. Con el signo de a y b la misma función sirve para sumar y restar rectángulos (un punto fuera de la zapata):
I_c(a, b, z) = sign(a)·sign(b)/(2·pi)·(atan(abs(a·b)/(z·sqrt(a^2 + b^2 + z^2))) + abs(a·b)·z/sqrt(a^2 + b^2 + z^2)·(1/(a^2 + z^2) + 1/(b^2 + z^2)))
#: Un rectángulo [x₀, x₁] × [y₀, y₁] visto desde el punto (p_{x}, p_{y}) son cuatro esquinas:
R_u(x_0, x_1, y_0, y_1, p_x, p_y, z) = I_c(x_1 - p_x, y_1 - p_y, z) + I_c(p_x - x_0, y_1 - p_y, z) + I_c(x_1 - p_x, p_y - y_0, z) + I_c(p_x - x_0, p_y - y_0, z)
#: La **carga triangular** (cero en un borde, f en el otro), bajo la esquina del lado cero (T₀) y del lado máximo (T_{m}); b es el lado en que crece la carga. Son las dos fórmulas de la misma página de la ayuda:
T_0(l, b, z) = 1/(2·pi)·(l·b·z/(sqrt(l^2 + b^2 + z^2)·(z^2 + b^2)) + l·z/(b·sqrt(l^2 + b^2 + z^2))·(sqrt(l^2 + b^2 + z^2) - sqrt(l^2 + z^2))/sqrt(l^2 + z^2))
T_m(l, b, z) = 1/(2·pi)·(atan(l·b/(z·sqrt(l^2 + b^2 + z^2))) + l·z/(l^2 + z^2)·(sqrt(l^2 + b^2 + z^2) - sqrt(l^2 + z^2))/b)
#: **La profundidad de la zapata** (ayuda «Influence of Foundation Depth and Incompressible Subsoil»): la tensión se calcula a una profundidad ficticia z_{r} = κ₁·z, mayor que la real, porque el suelo de encima confina:
kappa_1(z) = 1 + 0.35·atan(1.55·d_f/z)
k_1a = kappa_1(0.025) 'κ₁ en la 1.ª capa: casi 1 + 0.35·π/2
#: **El punto característico.** Ayuda «Overall Settlement and Rotation of Foundation»: si la zapata es rígida (k > 1, sección 7) su asiento es el de un punto a 0.37 veces el lado desde el eje:
x_c = 0.37·l_x 'abscisa del punto característico [m]
y_c = 0.37·l_y 'ordenada del punto característico [m]
dsz_1 = q_n·R_u(-l_x/2, l_x/2, -l_y/2, l_y/2, x_c, y_c, kappa_1(0.025)·0.025) 'Δσz en la 1.ª capa, sin la sobrecarga [kPa]
#: El **bulbo de presiones** en el plano y = 0 (la presión neta de la carga 3, ya con κ₁): la zona caliente baja poco más de un ancho.
#map(q_n·R_u(-0.6, 0.6, -0.6, 0.6, x, 0, kappa_1(-y)·(-y)), [-2 2], [-4.2 -0.02])

## 5 · El asiento: capa por capa

#: Ayuda «Analysis Using the Oedometric Modulus»: el módulo edométrico sale del de deformación, y cada capa asienta lo que la tensión le comprime **por encima** de su resistencia estructural m·σ_{or} (ayuda «Theory of Structural Strength»):
beta_1 = 1 - 2·nu_1^2/(1 - nu_1) 'β del suelo 1
beta_2 = 1 - 2·nu_2^2/(1 - nu_2) 'β del suelo 2
E_o1 = E_d1/beta_1·1000 'módulo edométrico del suelo 1 [kPa]
E_o2 = E_d2/beta_2·1000 'módulo edométrico del suelo 2 [kPa]
#: **La 1.ª capa a mano** (de 2.00 a 2.05 m), con la sobrecarga de 15 kPa vista desde el punto característico:
h_1 = 0.05 'espesor de la 1.ª capa [m]
sur_1 = q_s·R_u(3 - 1, 3 + 1, -1, 1, x_c, y_c, 2.025) 'aporte de la sobrecarga en la 1.ª capa [kPa]
ds_1 = dsz_1 + sur_1 'Δσz total en la 1.ª capa (GEO5: 1024.93) [kPa]
s_1 = (ds_1 - m_s·s_or1)·h_1/E_o1·1000 'asiento de la 1.ª capa (GEO5: 1.79) [mm]
#: **Las 24 capas de GEO5** (sus cotas de origen, desde el terreno original) y lo que GEO5 imprime para cada una:
z_top = [2, 2.05, 2.1, 2.15, 2.2, 2.25, 2.3, 2.4, 2.5, 2.6, 2.7, 2.8, 2.9, 3, 3.15, 3.4, 3.65, 3.9, 4, 4.15, 4.4, 4.9, 5.4, 5.9, 6.4, 6.9, 7.4] 'cotas de las capas de GEO5 (y tres más por debajo) [m]
D_G = [1024.93, 940.85, 809.34, 691.98, 604.08, 539.05, 471.26, 402.85, 351.86, 310.82, 276.52, 247.34, 223.42, 197.28, 163.09, 131.14, 107.67, 94.58, 86.91, 76.33, 61.72, 47.31, 37.44, 31.75] 'Δσz de GEO5 por capa [kPa]
S_G = [1.79, 1.64, 1.41, 1.2, 1.05, 0.93, 1.62, 1.38, 1.2, 1.05, 0.93, 0.82, 0.74, 0.02, 0.03, 0.03, 0.02, 0.01, 0.01, 0.01, 0.02, 0.01, 0, 0] 'asiento de GEO5 por capa [mm]
#: El cálculo de todas las capas es el de la 1.ª repetido: en cada capa, el centro, σ_{or}, Δσ_{z} (zapata + sobrecarga) y el asiento; en la capa donde Δσ_{z} cae por debajo de m·σ_{or} se busca el punto exacto (bisección) y ahí acaba la zona de influencia. Se hace para siete puntos: el característico y el centro con la carga 3, los dos bordes en x con la carga 3 (trapecio), los dos bordes en y con la carga 4 y el borde en y con la carga 3.
#: **Los siete puntos**, cada uno con su Δσ_{z} (zapata + sobrecarga), en una función de una línea:
D_1(z) = q_n·R_u(-0.6, 0.6, -0.6, 0.6, x_c, y_c, kappa_1(z)·z) + q_s·R_u(2, 4, -1, 1, x_c, y_c, z + z_f) 'punto característico, carga 3
D_2(z) = q_n·R_u(-0.6, 0.6, -0.6, 0.6, 0, 0, kappa_1(z)·z) + q_s·R_u(2, 4, -1, 1, 0, 0, z + z_f) 'centro, carga 3
D_3(z) = 2·q_3m·I_c(0.6, 1.2, kappa_1(z)·z) + 2·(q_3M - q_3m)·T_m(0.6, 1.2, kappa_1(z)·z) + q_s·R_u(2, 4, -1, 1, 0.6, 0, z + z_f) 'borde x más cargado, carga 3
D_4(z) = 2·q_3m·I_c(0.6, 1.2, kappa_1(z)·z) + 2·(q_3M - q_3m)·T_0(0.6, 1.2, kappa_1(z)·z) + q_s·R_u(2, 4, -1, 1, -0.6, 0, z + z_f) 'borde x menos cargado, carga 3
D_5(z) = 2·q_4m·I_c(0.6, 1.2, kappa_1(z)·z) + 2·(q_4M - q_4m)·T_m(0.6, 1.2, kappa_1(z)·z) + q_s·R_u(2, 4, -1, 1, 0, 0.6, z + z_f) 'borde y más cargado, carga 4
D_6(z) = 2·q_4m·I_c(0.6, 1.2, kappa_1(z)·z) + 2·(q_4M - q_4m)·T_0(0.6, 1.2, kappa_1(z)·z) + q_s·R_u(2, 4, -1, 1, 0, -0.6, z + z_f) 'borde y menos cargado, carga 4
D_7(z) = q_n·R_u(-0.6, 0.6, -0.6, 0.6, 0, 0.6, kappa_1(z)·z) + q_s·R_u(2, 4, -1, 1, 0, 0.6, z + z_f) 'centro del borde en y, carga 3
#: Para recorrerlos con un índice k, el peso max(0, 1 − |k − i|) vale 1 solo cuando k = i:
dsig(k, z) = max(0, 1 - abs(k - 1))·D_1(z) + max(0, 1 - abs(k - 2))·D_2(z) + max(0, 1 - abs(k - 3))·D_3(z) + max(0, 1 - abs(k - 4))·D_4(z) + max(0, 1 - abs(k - 5))·D_5(z) + max(0, 1 - abs(k - 6))·D_6(z) + max(0, 1 - abs(k - 7))·D_7(z)
#: El módulo edométrico según el estrato (el signo hace de interruptor en z = 3 m):
E_oed(z) = E_o1 + (E_o2 - E_o1)·(1 + sign(z - z_12))/2
#hide
S_k = zeros(7, 1)
Z_k = zeros(7, 1)
D_H = zeros(24, 1)
S_H = zeros(24, 1)
S_GD = zeros(24, 1)
Z_m = zeros(24, 1)
for k = 1:7
  s = 0
  fin = 0
  j = 1
  while fin == 0
    z0 = z_top(j) - z_f
    z1 = z_top(j + 1) - z_f
    f1 = dsig(k, z1) - m_s·sigma_or(z1 + z_f)
    if f1 < 0
      a = z0
      b = z1
      for it = 1:50
        c = (a + b)/2
        if dsig(k, c) - m_s·sigma_or(c + z_f) > 0
          a = c
        else
          b = c
        end
      end
      z1 = (a + b)/2
      fin = 1
    end
    zm = (z0 + z1)/2
    g = dsig(k, zm)
    ds = max(g - m_s·sigma_or(zm + z_f), 0)·(z1 - z0)/E_oed(zm + z_f)·1000
    s = s + ds
    if k == 1
      D_H(j) = g
      S_H(j) = ds
      Z_m(j) = zm
      S_GD(j) = (D_G(j) - m_s·sigma_or(zm + z_f))·(z1 - z0)/E_oed(zm + z_f)·1000
    end
    j = j + 1
  end
  S_k(k) = s
  Z_k(k) = z1
end
#show
#: **Las 24 capas del punto característico.** Columnas: profundidad del centro bajo el fondo [m] · Δσ_{z} Hekatan · Δσ_{z} GEO5 [kPa] · asiento Hekatan · asiento con la Δσ_{z} de GEO5 · asiento de GEO5 [mm]:
#hide
C_t = zeros(24, 6)
for j = 1:24
  C_t(j, 1) = round(Z_m(j), 3)
  C_t(j, 2) = round(D_H(j), 2)
  C_t(j, 3) = D_G(j)
  C_t(j, 4) = round(S_H(j), 3)
  C_t(j, 5) = round(S_GD(j), 3)
  C_t(j, 6) = S_G(j)
end
#show
C_t
#: La 5.ª columna mete en la fórmula del asiento la Δσ_{z} que imprime GEO5: da su asiento capa a capa, así que **la fórmula del asiento es la misma**. Lo que se separa un poco es la Δσ_{z} en las capas de arriba (1038.9 frente a 1024.9 en la 1.ª, un 1.4 %); más abajo baja a décimas de kPa. La suma, que es lo que importa, cuadra.

#hide
m_or = zeros(24, 1)
for j = 1:24
  m_or(j) = m_s·sigma_or(Z_m(j) + z_f)
end
#show
#: Para dibujar el perfil (1 unidad = 100 kPa en horizontal, la profundidad ×2 en vertical):
p_H = D_H/100 'Δσz de Hekatan, escalado
p_G = D_G'/100 'Δσz de GEO5, escalado
p_m = m_or/100 'm·σor, escalado
p_z = -2·Z_m 'profundidad del centro de cada capa, escalada
#dibujo("Δσz con la profundidad: Hekatan (azul), GEO5 (círculos rojos) y m·σor (verde). Escala: 1 unidad = 100 kPa, z ×2", ud = m, escala = auto, alto = 150)
#  linea(0, 0, 11, 0, "media")
#  linea(0, 0, 0, -8.6, "media")
#  polilinea(p_H, p_z, "gruesa azul")
#  circulo(p_G, p_z, 0.08, "rojo")
#  polilinea(p_m, p_z, "media verde")
#  linea(0, -8.3, 1.2, -8.3, "trazos")
#  texto(1.3, -8.3, "fin de la zona de influencia: 4.17 m (GEO5)", 2.6, "i")
#  texto(10.4, 0.3, "1044 kPa", 2.6, "c")
#  texto(5, 0.3, "500", 2.6, "c")
#  linea(5, 0, 5, 0.12, "media")
#  linea(10, 0, 10, 0.12, "media")
#  texto(-0.15, -4, "2 m", 2.6, "d")
#  texto(-0.15, -8, "4 m", 2.6, "d")
#  texto(4, -2.4, "Δσz (presión de la zapata, ya en profundidad)", 2.6, "i")
#  texto(1.4, -6.6, "m·σor: por debajo de esta línea el suelo ya no asienta", 2.6, "i")
#fin

## 6 · Asiento total, zona de influencia y los otros puntos

s_car = S_k(1) 'asiento del punto característico, carga 3 [mm]
z_inf = Z_k(1) 'profundidad de la zona de influencia bajo el fondo [m]
s_cen = S_k(2) 'asiento del centro, carga 3 [mm]
s_xp = S_k(3) 'borde x más cargado, carga 3 [mm]
s_xm = S_k(4) 'borde x menos cargado, carga 3 [mm]
s_yp = S_k(5) 'borde y más cargado, carga 4 [mm]
s_ym = S_k(6) 'borde y menos cargado, carga 4 [mm]
s_ym3 = S_k(7) 'centro del borde en y, carga 3 [mm]
s_GD = sum(S_GD) 'asiento con la Δσz que imprime GEO5 [mm]
#: La zona de influencia acaba donde la curva azul corta a la verde: ahí Δσ_{z} = m·σ_{or} (ayuda «Theory of Structural Strength»).

## 7 · Rigidez y giro de la zapata

#: Ayuda «Overall Settlement and Rotation of Foundation»: k = E_{basic}·t³/(E_{def,av}·l³). Si k > 1 la zapata es **rígida** y su asiento es el del punto característico. E_{def,av} es la media ponderada del módulo hasta el fondo de la zona de influencia; la ayuda **no dice con qué pondera** y no la he podido reproducir (con el espesor sale 765 MPa; con Δσ_{z}·h, 369). Se toma el valor que imprime GEO5:
E_av = 329.83 'módulo de deformación medio, del informe de GEO5 [MPa]
k_r = E_cm·t_z^3/(E_av·l_x^3) 'rigidez relativa (k > 1: rígida)
#: **El giro** es la diferencia de asiento de los centros de dos bordes opuestos, dividida por el lado. GEO5 lo da en tan·1000:
th_x = (s_xp - s_xm)/l_x 'giro en x, carga 3 [‰]
th_y = (s_yp - s_ym)/l_y 'giro en y, carga 4 [‰]

#: **3D: el cojín de presiones a 0.50 m bajo el fondo** (carga 3). Cada punto de la planta sube lo que vale Δσ_{z} ahí (1 m de altura = 1000 kPa); el color es el mismo valor. Se gira con el ratón y el cursor lee el número:
#hide
n_g = 25
X_n = zeros(n_g^2 + 2, 3)
e_s = zeros((n_g - 1)^2, 4)
v_n = zeros(n_g^2 + 2, 1)
for j = 1:n_g
  for k = 1:n_g
    p = (j - 1)·n_g + k
    X_n(p, 1) = -1.8 + 3.6·(k - 1)/(n_g - 1)
    X_n(p, 2) = -1.8 + 3.6·(j - 1)/(n_g - 1)
    v_n(p) = q_n·R_u(-0.6, 0.6, -0.6, 0.6, X_n(p, 1), X_n(p, 2), kappa_1(0.5)·0.5)
    X_n(p, 3) = v_n(p)/1000
  end
end
for j = 1:n_g - 1
  for k = 1:n_g - 1
    q = (j - 1)·(n_g - 1) + k
    a = (j - 1)·n_g + k
    e_s(q, 1) = a
    e_s(q, 2) = a + 1
    e_s(q, 3) = a + n_g + 1
    e_s(q, 4) = a + n_g
  end
end
X_n(n_g^2 + 2, 3) = 1.5
e_f = [n_g^2 + 1, n_g^2 + 2]
v_f = [0, 0]
#show
#modelo3d(X_n, e_s, e_f, v_n, v_f)
#: La barra vertical es el eje de la columna. A medio metro del fondo la presión ya no es uniforme: arriba del todo valen 1044 kPa, aquí el centro baja a 626 kPa (un 60 %) y a 1.8 m del eje queda en 3 kPa. Es la razón de que el asiento salga casi entero del primer metro (la tabla de la sección 5).

## 8 · Hekatan contra GEO5

#hide
g_s = 15.9
g_z = 4.17
g_cen = 23.1
g_xm3 = 13.1
g_xp = 14.1
g_xm = 12.1
g_k = 3.37
g_tx = 1.638
g_ty = 4.095
g_d1 = 1024.93
g_s1 = 1.79
g_er = 0.022
g_ey = 0.114
h_s = round(s_car, 1)
h_sGD = round(s_GD, 1)
h_z = round(z_inf, 2)
h_cen = round(s_cen, 1)
h_xm3 = round(s_ym3, 1)
h_xp = round(s_xp, 1)
h_xm = round(s_xm, 1)
h_k = round(k_r, 2)
h_tx = round(th_x, 3)
h_ty = round(th_y, 3)
h_d1 = round(ds_1, 2)
h_s1 = round(s_1, 2)
h_er = round(er_x, 3)
h_ey = round(er_y, 3)
x_s = round(100·(h_s/g_s - 1), 2)
x_sGD = round(100·(h_sGD/g_s - 1), 2)
x_z = round(100·(h_z/g_z - 1), 2)
x_cen = round(100·(h_cen/g_cen - 1), 2)
x_xm3 = round(100·(h_xm3/g_xm3 - 1), 2)
x_xp = round(100·(h_xp/g_xp - 1), 2)
x_xm = round(100·(h_xm/g_xm - 1), 2)
x_k = round(100·(h_k/g_k - 1), 2)
x_tx = round(100·(h_tx/g_tx - 1), 2)
x_ty = round(100·(h_ty/g_ty - 1), 2)
x_d1 = round(100·(h_d1/g_d1 - 1), 2)
x_s1 = round(100·(h_s1/g_s1 - 1), 2)
x_er = round(100·(h_er/g_er - 1), 2)
x_ey = round(100·(h_ey/g_ey - 1), 2)
#show
#| Magnitud | Hekatan | GEO5 2024 | Diferencia [%] |
#|---|---:|---:|---:|
#| excentricidad relativa en x (servicio) | @{h_er} | @{g_er} | @{x_er} |
#| excentricidad relativa en y (servicio) | @{h_ey} | @{g_ey} | @{x_ey} |
#| Δσ_{z} en la 1.ª capa [kPa] | @{h_d1} | @{g_d1} | @{x_d1} |
#| asiento de la 1.ª capa [mm] | @{h_s1} | @{g_s1} | @{x_s1} |
#| **asiento del punto característico [mm]** | @{h_s} | @{g_s} | @{x_s} |
#| el mismo, con la Δσ_{z} de GEO5 [mm] | @{h_sGD} | @{g_s} | @{x_sGD} |
#| zona de influencia [m] | @{h_z} | @{g_z} | @{x_z} |
#| asiento del centro [mm] | @{h_cen} | @{g_cen} | @{x_cen} |
#| centro del borde en y, carga 3 [mm] | @{h_xm3} | @{g_xm3} | @{x_xm3} |
#| borde más cargado, carga 3 [mm] | @{h_xp} | @{g_xp} | @{x_xp} |
#| borde menos cargado, carga 3 [mm] | @{h_xm} | @{g_xm} | @{x_xm} |
#| rigidez k (con el E_{def,av} de GEO5) | @{h_k} | @{g_k} | @{x_k} |
#| giro en x [tan·1000] | @{h_tx} | @{g_tx} | @{x_tx} |
#| giro en y [tan·1000] | @{h_ty} | @{g_ty} | @{x_ty} |
#: **Lo que cuadra:** el asiento total (15.9 mm), los asientos de los bordes a la décima que imprime GEO5, la rigidez y las excentricidades. El del centro queda a 0.05 mm (23.05 frente a 23.1). La fórmula del asiento por capa es exactamente la de GEO5 (la 5.ª columna de la tabla de la sección 5 da su asiento con su Δσ_{z}).
#: **Lo que no cuadra a cuatro cifras, y por qué:** (1) **Δσ_{z} en las capas de arriba**, hasta un 1.4 % (1038.9 frente a 1024.9): con la presión de Steinbrenner, κ₁ y la sobrecarga sale esto; no sé qué más hace GEO5 cerca del fondo y no invento un factor. (2) **Los giros**, un 0.8 % y un 0.5 %: salen de restar dos asientos de bordes y esa resta amplifica la diferencia de Δσ_{z}. (3) **La zona de influencia**, 4.15 frente a 4.17 m (0.5 %): el corte con m·σ_{or} es casi tangente y una décima de kPa la mueve centímetros. (4) **E_{def,av} = 329.83 MPa** no se reproduce (la ayuda no da la ponderación); k = 3.37 sale con el valor de GEO5.
#: **NEC-SE-GC 2015**, §6.3.4 (p. 43-44): asiento total admisible de una zapata aislada **20 cm** a 25 años con CM + 50 % CV_{máx}. 15.9 mm está muy lejos; lo que manda en esta zapata es la capacidad portante (hoja 104), no el asiento.
