# Talud con anclajes por el método de Spencer: las fuerzas entre dovelas y su inclinación, contra GEO5
#numerico

#: **Qué se calcula.** El mismo talud y el mismo círculo de la hoja 112 (Demo01.gst de GEO5 Slope Stability, etapa 3), ahora con el método de **Spencer**: un método «riguroso», que cumple el equilibrio de fuerzas **y** de momentos de **cada** dovela. Además del FS da las **fuerzas entre dovelas** E_{i} y su inclinación δ.
#: **Por qué importa.** Bishop (hoja 112) desprecia el cortante entre dovelas y solo cumple el equilibrio de momentos de toda la masa. Spencer no desprecia nada: supone que todas las fuerzas entre dovelas tienen **la misma inclinación δ** y busca el δ y el FS que cumplen a la vez fuerzas y momentos. La NEC-SE-GC 2015 cita el manual USACE EM 1110-2-1902, que recomienda este método.
#: **Cómo.** Las cinco ecuaciones y las dos recurrencias de la ayuda de GEO5 2024 (página «Spencer»), leídas del propio archivo de ayuda.
#: **Juez.** GEO5 2024 guarda en el Demo01.gst el FS, el δ y las 19 fuerzas E_{i} de su cálculo, sin redondear: se comparan una a una.
#: **Unidades.** kN, m y kPa por metro de talud.

## 1 · Datos (los de la hoja 112)

#: Suelos, terreno, techo del suelo 2, sobrecargas, anclajes y círculo de la etapa 3 (ver la hoja 112, sección 1):
gamma_1 = 20 'suelo 1 (limo): peso específico [kN/m3]
phi_1 = 21 'suelo 1: rozamiento [grados]
c_1 = 12 'suelo 1: cohesión [kPa]
gamma_2 = 18 'suelo 2 (limo arenoso): peso específico [kN/m3]
phi_2 = 26.5 'suelo 2: rozamiento [grados]
c_2 = 16 'suelo 2: cohesión [kPa]
gamma_R = 25 'muro de pie (cuerpo rígido): peso específico [kN/m3]
T_A = [-20; 0; 7.89; 11.54; 17.2; 17.25; 19; 20; 21.5; 26.5; 29.8; 32.39; 36.16; 38.69; 41; 41.5; 53; 54] 'terreno: inicio de cada tramo [m]
T_B = [0; 7.89; 11.54; 17.2; 17.25; 19; 20; 21.5; 26.5; 29.8; 32.39; 36.16; 38.69; 41; 41.5; 53; 54; 70] 'terreno: final de cada tramo [m]
Z_A = [115.32; 115.32; 115.2; 116.85; 117.99; 119; 119; 122.98; 122.98; 122.98; 124.92; 125.92; 127.92; 128.51; 128.67; 127.5; 127.5; 128.75] 'terreno: cota del inicio [m]
Z_B = [115.32; 115.2; 116.85; 117.99; 118; 119; 122.98; 122.98; 122.98; 124.92; 125.92; 127.92; 128.51; 128.67; 127.5; 127.5; 128.75; 128.75] 'terreno: cota del final [m]
S_A = [-20; 0; 7.89; 11.54; 17.2; 21.5; 36.18; 53.99] 'techo del suelo 2: inicio de cada tramo [m]
S_B = [0; 7.89; 11.54; 17.2; 21.5; 36.18; 53.99; 70] 'techo del suelo 2: final [m]
Y_A = [115.32; 115.32; 115.2; 116.85; 117.99; 120.02; 120.75; 121.7] 'techo del suelo 2: cota del inicio [m]
Y_B = [115.32; 115.2; 116.85; 117.99; 117.9; 120.75; 121.7; 122.34] 'techo del suelo 2: cota del final [m]
q_1 = 12 'sobrecarga 1, de x = 22.4 a 25.9 [kPa]
q_2 = 160 'sobrecarga 2, de x = 42 a 52 [kPa]
x_h1 = 29.29 'cabeza del anclaje 1, x [m]
z_h1 = 124.62 'cabeza del anclaje 1, z [m]
x_h2 = 33.97 'cabeza del anclaje 2, x [m]
z_h2 = 126.76 'cabeza del anclaje 2, z [m]
P_a = 200 'fuerza de cada anclaje por metro [kN/m]
beta_a = 30 'inclinación de los anclajes bajo la horizontal [grados]
x_c = 14.56 'centro del círculo, x [m]
z_c = 166.63 'centro del círculo, z [m]
R = 51.88 'radio [m]
n = 20 'dovelas de igual ancho, como GEO5 (hoja 112, sección 4)
#: Las funciones del perfil (hoja 112, sección 2):
dentro(x, a, b) = (sign(x - a) + 1).*(sign(b - x) + 1)/4
z_t(x) = sum(dentro(x, T_A, T_B).*(Z_A + (x - T_A).*(Z_B - Z_A)./(T_B - T_A)))
z_s(x) = sum(dentro(x, S_A, S_B).*(Y_A + (x - S_A).*(Y_B - Y_A)./(S_B - S_A)))
z_o(x) = z_c - sqrt(R^2 - (x - x_c)^2)
g_u(x) = gamma_R + (gamma_1 - gamma_R)·(sign(x - 21.5) + 1)/2
q_d(x, a, s) = gamma_2·max(0, z_s(x) - a - s·x) + g_u(x)·max(0, z_t(x) - max(z_s(x), a + s·x))

## 2 · Las 20 dovelas (el mismo cálculo de la hoja 112)

#: Entrada y salida del círculo, cruce con el techo del suelo 2, cuerdas, pesos por Simpson entre quiebres y sobrecargas: el bloque de la hoja 112, sección 5, oculto aquí.
#hide
x_L = 5
x_U = 10
for k = 1:60
  x_m = (x_L + x_U)/2
  if (z_t(x_L) - z_o(x_L))·(z_t(x_m) - z_o(x_m)) <= 0
    x_U = x_m
  else
    x_L = x_m
  end
end
x_a = (x_L + x_U)/2
x_L = 45
x_U = 50
for k = 1:60
  x_m = (x_L + x_U)/2
  if (z_t(x_L) - z_o(x_L))·(z_t(x_m) - z_o(x_m)) <= 0
    x_U = x_m
  else
    x_L = x_m
  end
end
x_b = (x_L + x_U)/2
x_L = 36.18
x_U = 53.99
for k = 1:60
  x_m = (x_L + x_U)/2
  if (z_s(x_L) - z_o(x_L))·(z_s(x_m) - z_o(x_m)) <= 0
    x_U = x_m
  else
    x_L = x_m
  end
end
x_x = (x_L + x_U)/2
b = (x_b - x_a)/n
B_k = [7.89; 11.54; 17.2; 17.25; 19; 20; 21.5; 26.5; 29.8; 32.39; 36.16; 36.18; 38.69; 41; 41.5]
X_i = zeros(n + 1, 1)
Z_i = zeros(n + 1, 1)
for i = 1:n + 1
  X_i(i) = x_a + (i - 1)·b
  Z_i(i) = z_o(X_i(i))
end
r_e = 1e-9
W = zeros(n, 1)
al = zeros(n, 1)
c_m = zeros(n, 1)
t_m = zeros(n, 1)
x_M = zeros(n, 1)
z_M = zeros(n, 1)
P_t = zeros(30, 1)
for i = 1:n
  s_i = (Z_i(i + 1) - Z_i(i))/b
  a_i = Z_i(i) - s_i·X_i(i)
  m = 1
  P_t(1) = X_i(i)
  for k = 1:15
    if B_k(k) > X_i(i)
      if B_k(k) < X_i(i + 1)
        m = m + 1
        P_t(m) = B_k(k)
      end
    end
  end
  m = m + 1
  P_t(m) = X_i(i + 1)
  w_i = 0
  for j = 1:m - 1
    p = P_t(j) + r_e
    q = P_t(j + 1) - r_e
    g_1 = z_s(p) - a_i - s_i·p
    g_2 = z_s(q) - a_i - s_i·q
    if g_1·g_2 < 0
      r = p + (q - p)·g_1/(g_1 - g_2)
      w_i = w_i + (r - p)·(q_d(p, a_i, s_i) + 4·q_d((p + r)/2, a_i, s_i) + q_d(r, a_i, s_i))/6 + (q - r)·(q_d(r, a_i, s_i) + 4·q_d((r + q)/2, a_i, s_i) + q_d(q, a_i, s_i))/6
    else
      w_i = w_i + (q - p)·(q_d(p, a_i, s_i) + 4·q_d((p + q)/2, a_i, s_i) + q_d(q, a_i, s_i))/6
    end
  end
  o_1 = max(0, min(X_i(i + 1), 25.9) - max(X_i(i), 22.4))
  o_2 = max(0, min(X_i(i + 1), 52) - max(X_i(i), 42))
  W(i) = w_i + q_1·o_1 + q_2·o_2
  al(i) = atan(s_i)
  f_2 = max(0, min(1, (x_x - X_i(i))/b))
  c_m(i) = f_2·c_2 + (1 - f_2)·c_1
  t_m(i) = f_2·tan(phi_2·pi/180) + (1 - f_2)·tan(phi_1·pi/180)
  x_M(i) = (X_i(i) + X_i(i + 1))/2
  z_M(i) = (Z_i(i) + Z_i(i + 1))/2
end
#show
W_T = sum(W) 'peso total con sobrecargas (hoja 112: 5324.90) [kN/m]
b = b 'ancho de cada dovela [m]
#: En la dovela 16 la base se reparte entre los dos suelos; Spencer lleva una sola N por dovela, así que se usa la mezcla c̄ = f_{2}·c_{2} + (1 − f_{2})·c_{1} y tan φ̄ = f_{2}·tan φ_{2} + (1 − f_{2})·tan φ_{1}, que es lo mismo que repartir N en esa proporción.

## 3 · Los anclajes como fuerzas sobre la dovela

#: Cada anclaje es una fuerza en su cabeza (hoja 112, sección 7). En las ecuaciones de Spencer de GEO5 entra como fuerza exterior de la dovela: horizontal Fx (positiva hacia +x, hacia dentro del talud), vertical Fy (positiva hacia arriba) y su momento M1 respecto al centro M de la base de la dovela (positivo antihorario):
F_x = P_a·cos(beta_a·pi/180) 'componente horizontal de cada anclaje [kN/m]
F_y = -P_a·sin(beta_a·pi/180) 'componente vertical (hacia abajo, negativa) [kN/m]
k_1 = floor((x_h1 - x_a)/b) + 1 'dovela del anclaje 1
k_2 = floor((x_h2 - x_a)/b) + 1 'dovela del anclaje 2
#hide
Fx = zeros(n, 1)
Fy = zeros(n, 1)
M1 = zeros(n, 1)
Fx(k_1) = F_x
Fy(k_1) = F_y
M1(k_1) = (x_h1 - x_M(k_1))·F_y - (z_h1 - z_M(k_1))·F_x
Fx(k_2) = F_x
Fy(k_2) = F_y
M1(k_2) = (x_h2 - x_M(k_2))·F_y - (z_h2 - z_M(k_2))·F_x
#show
M1_11 = M1(k_1) 'momento del anclaje 1 respecto al centro de la base de su dovela [kN·m/m]
M1_13 = M1(k_2) 'momento del anclaje 2 respecto al centro de la base de su dovela [kN·m/m]

## 4 · Las ecuaciones de Spencer (ayuda de GEO5)

#: En la base de la dovela i actúan la normal N_{i} y el cortante T_{i}; en sus caras, E_{i} (izquierda) y E_{i+1} (derecha), inclinadas δ; además el peso W_{i} (por el centro M de la base) y las fuerzas del anclaje.
#: **(2) Mohr-Coulomb con el FS:** T_{i} = N_{i}·tan φ_{i} + c_{i}·b_{i}/cos α_{i}, reducidos por FS.
#: **(3) Equilibrio normal a la base:** N_{i} − (W_{i} − Fy_{i})·cos α_{i} − Fx_{i}·sen α_{i} + E_{i+1}·sen(α_{i} − δ) − E_{i}·sen(α_{i} − δ) = 0
#: **(4) Equilibrio a lo largo de la base:** N_{i}·tan φ_{i}/FS + c_{i}·b_{i}/(FS·cos α_{i}) − (W_{i} − Fy_{i})·sen α_{i} + Fx_{i}·cos α_{i} − E_{i+1}·cos(α_{i} − δ) + E_{i}·cos(α_{i} − δ) = 0
#: Despejando N de (3) y llevándola a (4) sale la **recurrencia de fuerzas** (fórmula (6) de la ayuda), que da E_{i+1} a partir de E_{i}, empezando con E_{1} = 0 en el pie:
#: E_{i+1} = {[(W − Fy)·cos α + Fx·sen α + E_{i}·sen(α − δ_{i})]·tan φ/FS + c·b/(FS·cos α) − (W − Fy)·sen α + Fx·cos α + E_{i}·cos(α − δ_{i})} / [sen(α − δ_{i+1})·tan φ/FS + cos(α − δ_{i+1})]
#: **(5) Momentos de la dovela respecto a M** → la **recurrencia de brazos** (fórmula (7)): la altura z_{i+1} de E_{i+1} sobre la base, empezando con z_{1} = 0:
#: z_{i+1} = {b/2·[E_{i+1}·(sen δ_{i+1} − cos δ_{i+1}·tan α) + E_{i}·(sen δ_{i} − cos δ_{i}·tan α)] + E_{i}·z_{i}·cos δ_{i} − M1_{i}} / (E_{i+1}·cos δ_{i+1})
#: En los dos extremos de la superficie δ = 0 (ayuda: «only at slip surface endpoint is δ = 0»).
#: **Las dos condiciones de cierre.** Al final (después de la última dovela) no hay nada: E_{n+1} = 0 (fuerzas) y la última dovela tiene que estar en equilibrio de momentos con E_{n+1} = 0 (momentos). Para cada δ, el FS que cumple la primera se busca por bisección; después se busca, también por bisección, el δ que cumple la segunda.

## 5 · La solución

#hide
d_L = 0
d_U = 25·pi/180
E = zeros(n + 1, 1)
z_a = zeros(n + 1, 1)
d_v = zeros(n + 1, 1)
for o = 1:50
  for side = 1:2
    if side == 1
      dd = d_L
    else
      dd = (d_L + d_U)/2
    end
    for i = 2:n
      d_v(i) = dd
    end
    F_L = 1
    F_U = 3
    for k = 1:50
      for t = 1:2
        if t == 1
          FF = F_L
        else
          FF = (F_L + F_U)/2
        end
        E(1) = 0
        for i = 1:n
          a = al(i)
          E(i + 1) = (((W(i) - Fy(i))·cos(a) + Fx(i)·sin(a) + E(i)·sin(a - d_v(i)))·t_m(i)/FF + c_m(i)·b/(FF·cos(a)) - (W(i) - Fy(i))·sin(a) + Fx(i)·cos(a) + E(i)·cos(a - d_v(i)))/(sin(a - d_v(i + 1))·t_m(i)/FF + cos(a - d_v(i + 1)))
        end
        if t == 1
          e_L = E(n + 1)
        else
          e_M = E(n + 1)
        end
      end
      if e_L·e_M <= 0
        F_U = (F_L + F_U)/2
      else
        F_L = (F_L + F_U)/2
      end
    end
    FF = (F_L + F_U)/2
    E(1) = 0
    for i = 1:n
      a = al(i)
      E(i + 1) = (((W(i) - Fy(i))·cos(a) + Fx(i)·sin(a) + E(i)·sin(a - d_v(i)))·t_m(i)/FF + c_m(i)·b/(FF·cos(a)) - (W(i) - Fy(i))·sin(a) + Fx(i)·cos(a) + E(i)·cos(a - d_v(i)))/(sin(a - d_v(i + 1))·t_m(i)/FF + cos(a - d_v(i + 1)))
    end
    z_a(1) = 0
    for i = 1:n - 1
      a = al(i)
      z_a(i + 1) = (b/2·(E(i + 1)·(sin(d_v(i + 1)) - cos(d_v(i + 1))·tan(a)) + E(i)·(sin(d_v(i)) - cos(d_v(i))·tan(a))) + E(i)·z_a(i)·cos(d_v(i)) - M1(i))/(E(i + 1)·cos(d_v(i + 1)))
    end
    a = al(n)
    r_m = -E(n)·cos(d_v(n))·(z_a(n) - b/2·tan(a)) - E(n)·sin(d_v(n))·b/2 + M1(n)
    if side == 1
      r_L = r_m
    else
      r_M = r_m
    end
  end
  if r_L·r_M <= 0
    d_U = (d_L + d_U)/2
  else
    d_L = (d_L + d_U)/2
  end
end
FS_S = FF
d_S = (d_L + d_U)/2
#show
delta_S = d_S·180/pi 'inclinación de las fuerzas entre dovelas δ [grados]
FS_S = FS_S 'factor de seguridad de Spencer
#: Las fuerzas entre dovelas E_{2} … E_{20} [kN/m] y la altura de su punto de aplicación sobre la base z [m] (al final de cada dovela):
E_i = E(2:n) 'fuerzas entre dovelas [kN/m]
z_i = z_a(2:n) 'altura de cada E sobre la base [m]
#hide
r_FS = round(FS_S, 3)
r_d = round(delta_S, 2)
#show
#: **Lectura.** FS = @{r_FS} con δ = @{r_d}°. Las fuerzas entre dovelas **crecen** desde el pie (cada dovela de la izquierda frena a las de arriba), dan **dos saltos** en las dovelas 11 y 13 (los anclajes empujan la masa hacia dentro del talud y aumentan la compresión entre dovelas) y bajan a cero en la salida.
#: E_{i} de Hekatan (azul) y de GEO5 (rojo), en la abscisa del corte; casi no se distinguen:
#fplot(Hekatan = [9.768 27.531; 11.813 68.686; 13.858 114.863; 15.903 160.988; 17.948 208.884; 19.993 265.505; 22.038 330.754; 24.083 377.754; 26.128 411.004; 28.173 431.663; 30.218 612.504; 32.264 607.873; 34.309 750.552; 36.354 716.686; 38.399 669.938; 40.444 600.923; 42.489 509.345; 44.534 334.382; 46.579 161.894], GEO5 = [9.768 27.519; 11.813 68.663; 13.858 114.848; 15.903 160.984; 17.948 209.151; 19.993 265.789; 22.038 331.001; 24.083 378.038; 26.128 411.322; 28.173 432.012; 30.218 612.905; 32.264 608.313; 34.309 751.045; 36.354 717.223; 38.399 670.517; 40.444 600.789; 42.489 509.225; 44.534 334.305; 46.579 161.858], [7 49])
#: **El punto de aplicación.** Las alturas z quedan dentro de la dovela (entre 0.3 y 3.4 m sobre la base, alturas de dovela de 1 a 9 m): la «línea de empuje» es razonable, otra señal de que la solución es buena.

## 6 · Hekatan contra GEO5

#hide
G_E = [27.51938568613442; 68.6631; 114.848; 160.984; 209.151; 265.789; 331.001; 378.038; 411.322; 432.012; 612.905; 608.313; 751.045; 717.223; 670.517; 600.789; 509.225; 334.305; 161.858]
g_FS = 1.8998778176916171
g_d = 10.54406970739365
x_FS = round(100·(FS_S/g_FS - 1), 4)
x_d = round(100·(delta_S/g_d - 1), 4)
h_FS = round(FS_S, 5)
h_d = round(delta_S, 4)
D_1 = zeros(10, 4)
D_2 = zeros(9, 4)
e_mx = 0
for i = 1:19
  e_i = round(100·(E_i(i)/G_E(i) - 1), 3)
  e_mx = max(e_mx, abs(e_i))
  if i <= 10
    D_1(i, :) = [i + 1, round(E_i(i), 3), round(G_E(i), 3), e_i]
  else
    D_2(i - 10, :) = [i + 1, round(E_i(i), 3), round(G_E(i), 3), e_i]
  end
end
#show
#| Magnitud | Hekatan | GEO5 2024 | Diferencia [%] |
#|---|---:|---:|---:|
#| **FS de Spencer** | @{h_FS} | 1.89988 | @{x_FS} |
#| **δ [°]** | @{h_d} | 10.5441 | @{x_d} |
#: Las 19 fuerzas entre dovelas. Columnas: corte · E Hekatan [kN/m] · E GEO5 [kN/m] · diferencia [%]. Cortes 2 a 11 y 12 a 20:
D_1
D_2
#: La mayor diferencia es la del corte 6 (−0.128 %), al pie del muro.
#: **Lectura honrada.** El FS y el δ coinciden en tres cifras (0.04 % y 0.03 %). Las 19 fuerzas E quedan a menos de 0.13 %; las mayores diferencias están en los cortes 6 a 15, los que tocan el muro y los anclajes. Con el FS y el δ **de GEO5** metidos en la recurrencia, la primera E sale 27.542 frente a 27.519 (0.08 %): la diferencia no está en el método sino en el **peso** de las dovelas (la primera dovela solo tiene suelo 2, sin quiebres). Es la misma diferencia pequeña de la hoja 112. Cerrarla pide leer en el binario (SlopeStability_5.dll) cómo calcula GEO5 el área de una dovela. No se ha metido ningún factor de ajuste.

## 7 · Los otros métodos rigurosos y la NEC

#: Leídos del Demo01.gst (mismo círculo, etapa 3): Janbu 1.89871 y Morgenstern-Price 1.89871 (los dos a 0.06 % de Spencer, como se espera de métodos que cumplen todos los equilibrios), Bishop 1.78813 y Fellenius 1.73651 (hoja 112).
#: **Spencer da 6 % más que Bishop aquí (1.90 contra 1.79).** La única diferencia de hipótesis es el cortante entre dovelas: Bishop lo hace cero y Spencer lo toma como E·sen δ, con δ ≈ 10.5°. Ese cortante, sumado en las caras, es lo que separa los dos resultados.
#: **NEC-SE-GC 2015**, Tabla 4 (p. 31), talud estático con agua normal: FS ≥ 1.50. Spencer @{r_FS} → **cumple**. (El borrador 2023, no oficial, mantiene 1.50 en estático.) Para la comprobación pseudoestática ver la hoja 112, sección 10: en este círculo no llega al 1.05 con k_{h} = 0.288.
