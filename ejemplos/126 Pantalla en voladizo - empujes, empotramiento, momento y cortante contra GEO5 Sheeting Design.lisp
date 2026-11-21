# Pantalla en voladizo (tablestaca): empujes, empotramiento, momento y cortante, contra GEO5 Sheeting Design
#numerico

#: **Qué se calcula.** La pantalla del ejemplo oficial de GEO5 Sheeting Design (**Demo_manual_04.gp1**, manual EM 4 «Design of a non-anchored retaining wall»): una tablestaca de acero VL 601, sin anclar, que sostiene una zanja de **2.75 m**. Se busca lo mismo que el marco «Analysis» de GEO5: cuánto hay que **empotrarla** en el suelo, el **largo total**, el **momento máximo** y el **cortante máximo** (etapa 1).
#: **Cómo.** Con la ayuda oficial de GEO5: «Analysis of Sheet Pile Wall» (equilibrio de momentos y luego de cortantes), «Active Earth Pressure – The Coulomb Theory», «Passive Earth Pressure – The Caquot-Kérisel Theory» con sus dos tablas, y «Analysis of Sheeting Structures» (EN 1997, enfoque DA3). Los datos de los suelos se leyeron del propio archivo .gp1 (es binario: los números están guardados tal cual).
#: **Juez.** El marco «Analysis» de GEO5 2024 y su «In detail». Al final, la tabla **Hekatan contra GEO5** con la diferencia en %.
#: **Unidades.** kN, m y kPa (como GEO5); al final también en tonf. Dentro de las fórmulas los ángulos van en radianes.

## 1 · Datos del ejemplo (Demo_manual_04.gp1)

#: **El terreno**, tres estratos medidos desde la cabeza de la pantalla:
gamma_1 = 17.5 'peso específico de la arena con finos (0 a 1.50 m) [kN/m3]
phi_1 = 29.5 'ángulo de rozamiento de la arena [grados]
c_1 = 0 'cohesión de la arena [kPa]
gamma_2 = 18.5 'peso específico de la arena arcillosa (1.50 a 2.50 m) [kN/m3]
phi_2 = 27 'ángulo de rozamiento de la arena arcillosa [grados]
c_2 = 8 'cohesión de la arena arcillosa [kPa]
gamma_3 = 21 'peso específico de la arcilla de baja plasticidad (bajo 2.50 m) [kN/m3]
phi_3 = 19 'ángulo de rozamiento de la arcilla [grados]
c_3 = 12 'cohesión de la arcilla [kPa]
delta_k = 14 'rozamiento suelo-pantalla, igual en los tres suelos [grados]
#: El peso saturado es igual al natural en los tres suelos (dato del archivo), así que bajo el agua el peso sumergido es γ − γ_{w}.
gamma_w = 10 'peso específico del agua [kN/m3]
#: **La excavación y el agua.** El nivel freático está **solo detrás**, a 1.00 m; delante, en la zanja, no hay agua (marco Water, etapa 1). No hay sobrecargas ni anclajes, y el empuje es el **activo** sin el «empuje mínimo de dimensionamiento».
H_e = 2.75 'profundidad de la zanja [m]
z_w = 1.0 'profundidad del nivel freático detrás [m]
#: **El enfoque de cálculo.** El ejemplo usa EN 1997, **DA3**: los parámetros del suelo se dividen por 1.25 (tan φ y c) y las acciones geotécnicas quedan con factor 1.00 (ayuda «Analysis of Sheeting Structures»).
F_m = 1.25 'factor parcial del suelo (DA3) sobre tan φ y c

#dibujo("Corte del ejemplo: tres estratos, zanja de 2.75 m y agua detrás a 1.00 m", ud = m, escala = auto, cotas = m, alto = 160)
#  linea(-3, 0, 0, 0, "media verde")
#  linea(0, -2.75, 3, -2.75, "media verde")
#  rect(-0.05, -5.54, 0.1, 5.54, "gruesa")
#  linea(-3, -1.5, 0, -1.5, "fina")
#  linea(-3, -2.5, 0, -2.5, "fina")
#  linea(0, -2.5, 3, -2.5, "fina")
#  linea(-3, -1.0, -0.1, -1.0, "trazos azul")
#  texto(-2.9, -0.88, "nivel freático detrás", 2.6, "i")
#  texto(-2.9, -0.4, "arena con finos  φ 29.5°", 2.6, "i")
#  texto(-2.9, -2.0, "arena arcillosa  φ 27°, c 8", 2.6, "i")
#  texto(-2.9, -3.6, "arcilla  φ 19°, c 12", 2.6, "i")
#  texto(0.3, -2.6, "fondo de la zanja", 2.6, "i")
#  cota(0.4, 0, 0.4, -2.75, 0.25, "2.75")
#  cota(0.4, -2.75, 0.4, -5.54, 0.25, "empotramiento (GEO5: 2.79)")
#fin

## 2 · Los parámetros de cálculo (DA3)

#: Cada ángulo se reduce por su tangente y la cohesión directamente. El rozamiento suelo-pantalla δ GEO5 lo reduce **en la misma proporción que φ** (δ_{d} = δ·φ_{d}/φ): la ayuda no lo escribe, pero es lo que dan las presiones que GEO5 guarda en el propio .gp1 (las tres capas, a 6 cifras).
f_1 = atan(tan(phi_1·pi/180)/F_m) 'φ de cálculo de la arena [rad]
f_2 = atan(tan(phi_2·pi/180)/F_m) 'φ de cálculo de la arena arcillosa [rad]
f_3 = atan(tan(phi_3·pi/180)/F_m) 'φ de cálculo de la arcilla [rad]
d_1 = delta_k·f_1/phi_1 'δ de cálculo en la arena [rad]
d_2 = delta_k·f_2/phi_2 'δ de cálculo en la arena arcillosa [rad]
d_3 = delta_k·f_3/phi_3 'δ de cálculo en la arcilla [rad]
c_d2 = c_2/F_m 'cohesión de cálculo de la arena arcillosa [kPa]
c_d3 = c_3/F_m 'cohesión de cálculo de la arcilla [kPa]
#hide
g_f1 = round(f_1·180/pi, 2)
g_f3 = round(f_3·180/pi, 2)
g_d1 = round(d_1·180/pi, 2)
g_d3 = round(d_3·180/pi, 2)
r_cd3 = round(c_d3, 2)
#show
#: En grados: φ_{d} de la arena = @{g_f1}°, de la arcilla = @{g_f3}°, y δ_{d} va de @{g_d1}° (arena) a @{g_d3}° (arcilla). La arcilla queda con c_{d} = @{r_cd3} kPa: son los mismos 15.40° y 9.60 kPa que GEO5 escribe en su informe de estabilidad.

## 3 · Empuje activo detrás (Coulomb)

#: **Ayuda de GEO5** (pantalla vertical α = 0, terreno horizontal β = 0): σ_{a} = σ_{z}·K_{a} − 2·c·K_{ac}, y la parte horizontal es σ_{a}·cos δ.
#: K_{a} = cos²φ / (cos δ·(1 + √(sen(φ + δ)·sen φ / cos δ))²) y K_{ac} = cos φ / (1 + sen(φ + δ)). Ya con el cos δ de la componente horizontal:
Kh_1 = cos(f_1)^2/(1 + sqrt(sin(f_1 + d_1)·sin(f_1)/cos(d_1)))^2 'K_a·cos δ, arena
Kh_2 = cos(f_2)^2/(1 + sqrt(sin(f_2 + d_2)·sin(f_2)/cos(d_2)))^2 'K_a·cos δ, arena arcillosa
Kh_3 = cos(f_3)^2/(1 + sqrt(sin(f_3 + d_3)·sin(f_3)/cos(d_3)))^2 'K_a·cos δ, arcilla
Ch_2 = 2·c_d2·cos(f_2)/(1 + sin(f_2 + d_2))·cos(d_2) 'término de cohesión horizontal, arena arcillosa [kPa]
Ch_3 = 2·c_d3·cos(f_3)/(1 + sin(f_3 + d_3))·cos(d_3) 'término de cohesión horizontal, arcilla [kPa]
#: **La tensión vertical efectiva detrás**, σ'_{z}: con γ hasta el agua y con γ − γ_{w} debajo:
sv_10 = gamma_1·z_w 'σ′z a 1.00 m (nivel freático) [kPa]
sv_15 = sv_10 + (gamma_1 - gamma_w)·0.5 'σ′z a 1.50 m [kPa]
sv_25 = sv_15 + (gamma_2 - gamma_w)·1.0 'σ′z a 2.50 m [kPa]
sv_H = sv_25 + (gamma_3 - gamma_w)·(H_e - 2.5) 'σ′z al fondo de la zanja [kPa]
#: **La presión total sobre la pantalla** = tierra + agua. Si la cohesión deja la tierra en negativo, se corta a cero (ayuda: «tension cutoff»):
p_10 = sv_10·Kh_1 'a 1.00 m [kPa]
p_15a = sv_15·Kh_1 + gamma_w·0.5 'a 1.50 m, arena [kPa]
p_15b = max(sv_15·Kh_2 - Ch_2, 0) + gamma_w·0.5 'a 1.50 m, arena arcillosa [kPa]
p_25a = max(sv_25·Kh_2 - Ch_2, 0) + gamma_w·1.5 'a 2.50 m, arena arcillosa [kPa]
p_25b = max(sv_25·Kh_3 - Ch_3, 0) + gamma_w·1.5 'a 2.50 m, arcilla [kPa]
p_H = max(sv_H·Kh_3 - Ch_3, 0) + gamma_w·(H_e - z_w) 'al fondo de la zanja [kPa]
#: En la arena arcillosa la cohesión resta, pero no alcanza a anular la tierra (σ'_{z}·K_{h2} = 8.54 kPa > 7.49 kPa a 1.50 m): no hay grieta de tracción.
#: **El empuje total hasta el fondo de la zanja** (área del diagrama, tramo a tramo; todo es lineal entre los puntos de arriba):
E_1 = sv_10·Kh_1·z_w/2 + (p_10 + p_15a)/2·0.5 'arena, 0 a 1.50 m [kN/m]
E_2 = (p_15b + p_25a)/2·1.0 'arena arcillosa, 1.50 a 2.50 m [kN/m]
E_3 = (p_25b + p_H)/2·(H_e - 2.5) 'arcilla, 2.50 a 2.75 m [kN/m]
E_a = E_1 + E_2 + E_3 'empuje total sobre el tramo libre = cortante en el fondo de la zanja [kN/m]
#hide
r_Ea = round(E_a, 4)
r_pH = round(p_H, 2)
#show
#: E_{a} = @{r_Ea} kN/m. **GEO5 dibuja −25.74 kN/m** en el diagrama de cortante a 2.75 m: es este número (el signo es solo el sentido). Y la presión al fondo de la zanja, @{r_pH} kPa, es la punta del diagrama de presiones que dibuja GEO5 (unos 21 kPa en la captura). De esos 21 kPa, 17.5 son agua.

## 4 · Resistencia pasiva delante (Caquot-Kérisel)

#: Por debajo de la zanja, delante de la pantalla, la arcilla resiste con el **empuje pasivo**. Ayuda de GEO5: σ_{p} = σ_{z}·K_{p}·ψ + 2·c·√(K_{p}·ψ), con K_{p} de la tabla para δ = −φ y ψ, la reducción porque aquí |δ| < φ (segunda tabla). La componente horizontal es σ_{p}·cos δ.
#: **Tabla «Coefficient of Passive Earth Pressure Kp»**, fila α = 0, columna β = 0: K_{p} = 2.19 para φ = 15° y 3.01 para φ = 20°. **Tabla «Reduction Coefficient ψ»**, con |δ|/φ entre 0.6 y 0.8: para φ = 15°, ψ = 0.934 y 0.979; para φ = 20°, 0.901 y 0.968. Se interpola en línea recta:
a_p = (f_3·180/pi - 15)/5 'posición de φ_d entre 15° y 20°
K_p = 2.19 + (3.01 - 2.19)·a_p 'coeficiente pasivo para δ = −φ
r_δ = d_3/f_3 'relación |δ|/φ
w_r = (r_δ - 0.6)/0.2 'posición de |δ|/φ entre 0.6 y 0.8
psi_15 = 0.934 + (0.979 - 0.934)·w_r 'ψ para φ = 15°
psi_20 = 0.901 + (0.968 - 0.901)·w_r 'ψ para φ = 20°
psi_r = psi_15 + (psi_20 - psi_15)·a_p 'ψ para φ_d
K_pp = K_p·psi_r 'coeficiente pasivo reducido, K_p·ψ
#: Delante no hay agua: la arcilla pesa entera, γ_{3}·(z − 2.75). La presión pasiva horizontal y su valor justo bajo la zanja:
Kp_h = K_pp·cos(d_3) 'pendiente pasiva horizontal, por kPa de σz
Cp_h = 2·c_d3·sqrt(K_pp)·cos(d_3) 'término de cohesión pasivo horizontal [kPa]
#hide
r_Kpp = round(K_pp, 4)
r_net0 = round(p_H - Cp_h, 2)
#show
#: Justo bajo la zanja la pasiva ya vale C_{ph}, por la cohesión, así que la presión neta salta de @{r_pH} kPa a @{r_net0} kPa: el escalón que dibuja GEO5 en 2.75 m.

## 5 · El equilibrio de la pantalla: empotramiento, momento y cortante

#: **Ayuda de GEO5, «Analysis of Sheet Pile Wall»:** el programa busca, iterando, el punto de la pantalla donde se cumple **M_{volcador} = M_{resistente}** (la suma de momentos de todas las presiones es cero); después alarga la pantalla hasta que se cumple el **equilibrio de cortantes** (la «profundidad de empotramiento»).
#: Aquí se hace igual: la presión neta p(z) = activa + agua − pasiva se integra dos veces de arriba abajo (V = ∫p dz, M = ∫V dz, regla del punto medio, paso 2.5 mm) y se busca bajo la zanja la profundidad donde M pasa por cero (interpolando entre dos pasos):
#hide
dz = 0.0025
n_z = 2400
V_z = zeros(n_z + 1, 1)
M_z = zeros(n_z + 1, 1)
P_z = zeros(n_z + 1, 1)
for i = 1:n_z
  z = (i - 0.5)·dz
  sv = gamma_1·min(z, 1) + (gamma_1 - gamma_w)·max(min(z, 1.5) - 1, 0) + (gamma_2 - gamma_w)·max(min(z, 2.5) - 1.5, 0) + (gamma_3 - gamma_w)·max(z - 2.5, 0)
  u = gamma_w·max(z - z_w, 0)
  if z < 1.5
    pa = sv·Kh_1
  elseif z < 2.5
    pa = max(sv·Kh_2 - Ch_2, 0)
  else
    pa = max(sv·Kh_3 - Ch_3, 0)
  end
  pp = 0
  if z > H_e
    pp = gamma_3·(z - H_e)·Kp_h + Cp_h
  end
  p = pa + u - pp
  P_z(i) = p
  V_z(i + 1) = V_z(i) + p·dz
  M_z(i + 1) = M_z(i) + V_z(i)·dz + p·dz^2/2
end
k_t = 0
for j = round(H_e/dz) + 2:n_z
  if k_t == 0
    if M_z(j) <= 0
      k_t = j
    end
  end
end
s_f = M_z(k_t - 1)/(M_z(k_t - 1) - M_z(k_t))
d_0 = (k_t - 2 + s_f)·dz - H_e
d_G = 2.401829
R_V = zeros(2, 1)
R_M = zeros(2, 1)
R_z = zeros(2, 1)
R_t = zeros(2, 1)
R_D = zeros(2, 1)
for c = 1:2
  if c == 1
    dc = d_0
  else
    dc = d_G
  end
  zt = H_e + dc
  j = floor(zt/dz) + 1
  R_V(c) = -(V_z(j) + (zt/dz - j + 1)·(V_z(j + 1) - V_z(j)))
  R_t(c) = M_z(j) + (zt/dz - j + 1)·(M_z(j + 1) - M_z(j))
  for k = 0:7
    zn = H_e + k·dc/7
    j = floor(zn/dz) + 1
    mn = M_z(j) + (zn/dz - j + 1)·(M_z(j + 1) - M_z(j))
    if mn > R_M(c)
      R_M(c) = mn
      R_z(c) = zn
    end
  end
  zb = zt + 0.01
  svb = sv_25 + (gamma_3 - gamma_w)·(zb - 2.5)
  R_D(c) = R_V(c)/(svb·Kp_h + Cp_h + gamma_w·(zb - z_w))
end
M_pk = 0
for i = 1:k_t
  M_pk = max(M_pk, M_z(i))
end
#show
d_0 'profundidad bajo la zanja donde M = 0 [m]
#: **El momento máximo.** GEO5 no lo lee en el pico de la curva sino en los **nudos de su dibujo**: el tramo enterrado partido en 7 partes iguales (2.75 + k·d_{0}/7). Así se hace aquí.
#: **El tramo final (equilibrio de cortantes).** En el punto de M = 0 la pantalla todavía lleva un cortante V_{t}; por debajo, la pantalla gira y el suelo de **detrás** pasa a resistir con su pasiva (más el agua). La ayuda no da la fórmula. Los números que GEO5 guarda en el .gp1 cumplen Δ = V_{t}/p_{cb}, con p_{cb} la pasiva de detrás + agua evaluada **1 cm por debajo** del punto de M = 0, y el alargue empieza también 1 cm más abajo: empotramiento = d_{0} + 0.01 + Δ.
V_t = R_V(1) 'cortante en el punto de M = 0 = cortante máximo [kN/m]
M_mx = R_M(1) 'momento máximo en los nudos de GEO5 [kN·m/m]
M_pk 'pico verdadero de la curva de momentos [kN·m/m]
D_e = R_D(1) 'alargue por el equilibrio de cortantes [m]
d_emp = d_0 + 0.01 + D_e 'empotramiento total bajo la zanja [m]
L_p = H_e + d_emp 'largo total de la pantalla [m]
#: **GEO5 no se para en M = 0 exacto.** Su iteración termina en d_{0} = 2.401829 m (el último nudo de su diagrama; guarda 2.411829 = d_{0} + 1 cm), y ahí su propio momento vale −0.304655 kN·m/m, no cero (el «−0.30» que se ve al pie del dibujo). Con la presión de esta hoja, M = 0 cae 4 mm más arriba. Tomando el d_{0} donde se paró GEO5, lo demás sale igual que GEO5:
M_G = R_t(2) 'momento en el d0 de GEO5 (GEO5 guarda −0.304655) [kN·m/m]
V_G = R_V(2) 'cortante con el d0 de GEO5 [kN/m]
Mx_G = R_M(2) 'momento máximo en los nudos, con el d0 de GEO5 [kN·m/m]
D_G = R_D(2) 'alargue con el d0 de GEO5 [m]
L_G = H_e + d_G + 0.01 + D_G 'largo con el d0 de GEO5 [m]
#: **En tonf** (1 tonf = 9.80665 kN):
M_ton = M_mx/9.80665 'momento máximo [tonf·m/m]
V_ton = V_t/9.80665 'cortante máximo [tonf/m]

#hide
n_g = 53
zg = zeros(n_g, 1)
pg = zeros(n_g, 1)
vg = zeros(n_g, 1)
mg = zeros(n_g, 1)
for k = 1:n_g
  i = min((k - 1)·40 + 1, k_t)
  zg(k) = -(i - 1)·dz
  pg(k) = P_z(i)/25
  vg(k) = V_z(i)/25
  mg(k) = M_z(i)/12.5
end
#show
#: Para dibujar, cada 10 cm (presión: 1 unidad = 25 kPa; cortante: 1 = 25 kN/m; momento: 1 = 12.5 kN·m/m; profundidad en m):
p_g = pg 'presión neta escalada
v_g = vg 'cortante escalado
m_g = mg 'momento escalado
z_g = zg 'profundidad
#dibujo("Presión neta (azul), cortante (rojo) y momento (verde) a lo largo de la pantalla — etapa 1", ud = m, escala = auto, alto = 200)
#  linea(0, 0.2, 0, -5.6, "eje")
#  linea(-3.4, -2.75, 3.6, -2.75, "trazos")
#  texto(2.2, -2.65, "fondo de la zanja", 2.6, "i")
#  polilinea(p_g, z_g, "gruesa azul")
#  polilinea(v_g, z_g, "media rojo")
#  polilinea(m_g, z_g, "media verde")
#  linea(-3.4, -5.15, 3.6, -5.15, "puntos")
#  texto(-3.3, -5.05, "giro (M = 0) a 2.40 m bajo la zanja", 2.6, "i")
#  linea(-3.4, -5.54, 3.6, -5.54, "puntos rojo")
#  texto(-3.3, -5.44, "pie de la pantalla, 5.54 m (GEO5)", 2.6, "i")
#  texto(0.95, -1.4, "presión neta", 2.6, "i")
#  texto(3.35, -3.6, "M máx", 2.6, "i")
#  texto(-3.2, -4.6, "pasiva delante", 2.6, "i")
#fin
#hide
r_d0 = round(d_0, 3)
r_Vt = round(V_t, 2)
r_Mm = round(M_mx, 2)
r_zm = round(R_z(1), 2)
r_De = round(D_e, 3)
#show
#: **Lectura.** A @{r_d0} m bajo la zanja el momento se anula: arriba manda el empuje de detrás (tierra + agua) y abajo la pasiva de la arcilla. El momento máximo, @{r_Mm} kN·m/m, cae a @{r_zm} m, donde el cortante pasa por cero. El cortante máximo, @{r_Vt} kN/m, está en el punto de M = 0: es la fuerza que el tramo final de @{r_De} m tiene que devolver.

## 6 · Hekatan contra GEO5

#: GEO5 imprime 2 decimales, pero **guarda los resultados enteros** dentro del .gp1 (objeto TPaz1Posouzeni y los puntos del diagrama). Se compara con esos, a 4 decimales:
#hide
g_Ea = 25.742982
g_p1 = 6.482615
g_p25 = 19.460799
g_pH = 21.580005
g_n0 = -6.170034
g_d0 = 2.401829
g_V = 73.08522
g_M = 40.855667
g_De = 0.374533
g_de = 2.786361
g_L = 5.536361
h_Ea = round(E_a, 4)
h_p1 = round(p_10, 4)
h_p25 = round(p_25a, 4)
h_pH = round(p_H, 4)
h_n0 = round(p_H - Cp_h, 4)
h_d0 = round(d_0, 4)
h_V = round(V_G, 4)
h_M = round(Mx_G, 4)
h_De = round(D_G, 4)
h_de = round(d_G + 0.01 + D_G, 4)
h_L = round(L_G, 4)
x_Ea = round(100·(h_Ea/g_Ea - 1), 4)
x_p1 = round(100·(h_p1/g_p1 - 1), 4)
x_p25 = round(100·(h_p25/g_p25 - 1), 4)
x_pH = round(100·(h_pH/g_pH - 1), 4)
x_n0 = round(100·(h_n0/g_n0 - 1), 4)
x_d0 = round(100·(h_d0/g_d0 - 1), 4)
x_V = round(100·(h_V/g_V - 1), 4)
x_M = round(100·(h_M/g_M - 1), 4)
x_De = round(100·(h_De/g_De - 1), 4)
x_de = round(100·(h_de/g_de - 1), 4)
x_L = round(100·(h_L/g_L - 1), 4)
o_V = round(V_t, 2)
o_M = round(M_mx, 2)
o_L = round(L_p, 3)
#show
#| Magnitud | Hekatan | GEO5 2024 (.gp1) | Diferencia [%] |
#|---|---:|---:|---:|
#| presión a 1.00 m (arena) [kPa] | @{h_p1} | @{g_p1} | @{x_p1} |
#| presión a 2.50 m (arena arcillosa) [kPa] | @{h_p25} | @{g_p25} | @{x_p25} |
#| presión al fondo de la zanja [kPa] | @{h_pH} | @{g_pH} | @{x_pH} |
#| presión neta bajo la zanja [kPa] | @{h_n0} | @{g_n0} | @{x_n0} |
#| cortante en el fondo de la zanja [kN/m] | @{h_Ea} | @{g_Ea} | @{x_Ea} |
#| punto de giro (M = 0) bajo la zanja [m] | @{h_d0} | @{g_d0} | @{x_d0} |
#| **cortante máximo** [kN/m] (GEO5: 73.09) ¹ | @{h_V} | @{g_V} | @{x_V} |
#| **momento máximo** [kN·m/m] (GEO5: 40.86) ¹ | @{h_M} | @{g_M} | @{x_M} |
#| alargue por cortantes [m] ¹ | @{h_De} | @{g_De} | @{x_De} |
#| **empotramiento** [m] (GEO5: 2.79) ¹ | @{h_de} | @{g_de} | @{x_de} |
#| **largo de la pantalla** [m] (GEO5: 5.54) ¹ | @{h_L} | @{g_L} | @{x_L} |
#: ¹ Con el d_{0} donde se para la iteración de GEO5 (2.401829 m). Con el M = 0 exacto de esta hoja (@{h_d0} m) salen @{o_V} kN/m, @{o_M} kN·m/m y @{o_L} m: **lo único que no se reproduce es el criterio de parada de la iteración de GEO5** (para con M = −0.30 en vez de 0, 4 mm más abajo). Eso está en el binario, no en la ayuda.
#: **Tres cosas que la ayuda no dice y que se sacaron de los resultados guardados por GEO5** (no son ajustes: cada una se comprobó en todas las capas o puntos): (1) δ se reduce en proporción a φ; (2) el momento máximo se lee en los 7 nudos del tramo enterrado; (3) el alargue empieza 1 cm por debajo del punto de giro y usa la pasiva de detrás de ese punto. La tabla de Caquot-Kérisel se interpola en línea recta en φ y en |δ|/φ.
#: **No reproducido (pendiente):** la etapa 2 (agua 1 m por encima del terreno detrás, parámetros sin reducir) y su envolvente de 178.81 kN·m/m y 215.82 kN/m; la verificación de la sección VL 601 con EN 1993-1-1 (flexión NOT OK al 100.4 %); y la profundidad mínima de 4.46 m del marco Stability, que sale de un análisis de estabilidad de taludes (otro programa).

## 7 · Lo que pide la NEC

#: **NEC-SE-GC 2015** (oficial), §5.2 (p. 36): las tablestacas y las excavaciones entibadas son estructuras de contención. Pide revisar la rotura estructural y la deformación excesiva, y el sismo con Mononobe-Okabe (p. 37).
#: **Tabla 5** (p. 38), estabilidad general: 1.50 en obra permanente (estático), 1.30 en obra temporal, 1.20 en construcción; 1.05 y 1.00 en pseudoestático. **No da** factor para el empotramiento ni para la pasiva movilizada: el que se use es criterio del ingeniero.
#: §4.2.1 (p. 29): la NEC-15 trabaja con **factor de seguridad global** y cargas sin mayorar. El ejemplo de GEO5 usa EN 1997-DA3 (factores parciales); para la NEC se cambia en Settings a «Safety factors (ASD)». Aquí se mantiene DA3 para poder comparar con el ejemplo.
#: §5.1 (p. 35): considerar las sobrecargas de la vía pública y la falla de fondo. El **borrador 2023 (no oficial)** pone como sobrecarga mínima 15 kPa; este ejemplo no lleva sobrecarga.
#: **Sismo:** k_{h} = 0.6·Z·F_{a} (nota de la Tabla 4, p. 31). Zona V (Z = 0.40) con suelo D (F_{a} = 1.20):
k_h = 0.6·0.40·1.20 'coeficiente sísmico horizontal NEC-15, zona V, suelo D
#: El ejemplo no tiene sismo (Earthquake apagado); para la NEC se escribe este k_{h} a mano en GEO5.
