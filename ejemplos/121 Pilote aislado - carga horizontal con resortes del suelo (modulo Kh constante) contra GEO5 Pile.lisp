# Pilote aislado con carga horizontal: viga sobre resortes del suelo (módulo k_h constante), contra GEO5
#numerico

#: **Qué se calcula.** El mismo pilote de la hoja 120 (GEO5 Pile, **Demo_manual_13.gpi**: hormigón C 20/25, 1.00 m de diámetro, 12.00 m de largo) con la carga de la cabeza: **H = 85 kN** y **M = 120 kN·m**. Se busca lo que da el marco «Horizontal cap.» de GEO5: el **desplazamiento de la cabeza**, el cortante y el momento máximos.
#: **Cómo.** GEO5 usa «Elastic subsoil (p-y method)»: el pilote es una viga y el suelo, resortes horizontales (modelo de Winkler) de módulo k_{h}. El ejemplo elige k_{h} **constante** por capa; la fórmula sale de la ayuda de GEO5 («Constant Distribution of Modulus of Subsoil Reaction»). Aquí la viga se resuelve por **elementos finitos**: 24 elementos de viga de 0.50 m con el resorte repartido en cada uno.
#: **Juez.** El informe de GEO5 2024 («In detail» del marco Horizontal cap.): desplazamiento de la cabeza −4.2 mm, cortante máximo 85.00 kN, momento máximo 120.00 kN·m.
#: **Unidades.** kN, m, kPa y MPa (= MN/m²); desplazamientos en mm.

## 1 · Datos

#: **El pilote.** GEO5 toma el módulo E_{cm} del hormigón C 20/25 que imprime su informe.
d_p = 1.0 'diámetro [m]
L_p = 12.0 'longitud [m]
E_c = 30000 'módulo de elasticidad del hormigón C 20/25 [MPa]
I_p = pi·d_p^4/64 'momento de inercia de la sección circular [m4]
EI = E_c·1000·I_p 'rigidez a flexión [kN·m2]
#: **El suelo.** Dos capas, con su módulo de deformación E_{def} y su ángulo de dispersión β (dato del ejemplo, para k_{h} constante). E_{def} se leyó de los registros de suelo del archivo .gpi (el informe imprime E_{oed}: 8 y 21 MPa).
h_1 = 6.0 'espesor de la arcilla [m]
E_1 = 5.0 'módulo de deformación de la arcilla [MPa]
β_1 = 10 'ángulo de dispersión de la arcilla [grados]
E_2 = 15.5 'módulo de deformación de la arena [MPa]
β_2 = 15 'ángulo de dispersión de la arena [grados]
#: **La carga en la cabeza** (Load No. 1): la cabeza está libre (sin desplazamiento ni giro impuestos) y la base no está empotrada.
H_0 = 85 'fuerza horizontal en la cabeza [kN]
M_0 = 120 'momento en la cabeza [kN·m]

## 2 · El módulo de reacción k_h (ayuda de GEO5)

#: **Ancho reducido** del pilote: el suelo «reparte» la presión con el ángulo β a cada lado.
r_1 = d_p + 2·d_p·tan(β_1·pi/180) 'ancho reducido en la arcilla [m]
r_2 = d_p + 2·d_p·tan(β_2·pi/180) 'ancho reducido en la arena [m]
#: **Módulo constante en cada capa:**
k_h1 = 3·E_1/(2·r_1) 'módulo de reacción de la arcilla [MN/m3]
k_h2 = 3·E_2/(2·r_2) 'módulo de reacción de la arena [MN/m3]
#: El resorte por metro de pilote es k_{h}·d (presión por ancho): es lo que se reparte en cada elemento.
c_1 = k_h1·1000·d_p 'resorte de la arcilla por metro de pilote [kN/m2]
c_2 = k_h2·1000·d_p 'resorte de la arena por metro de pilote [kN/m2]

## 3 · La viga sobre resortes por elementos finitos

#: **Rigidez de cada elemento** de longitud h: la de flexión de la viga (Hermite) más la del resorte repartido c (matriz consistente, con las mismas funciones de forma). Los grados de libertad de cada nudo son el desplazamiento w y el giro θ.
n_e = 24 'número de elementos
h = L_p/n_e 'longitud de cada elemento [m]
K_v = EI/h^3·[12, 6·h, -12, 6·h; 6·h, 4·h^2, -6·h, 2·h^2; -12, -6·h, 12, -6·h; 6·h, 2·h^2, -6·h, 4·h^2] 'rigidez de flexión del elemento
K_r = h/420·[156, 22·h, 54, -13·h; 22·h, 4·h^2, 13·h, -3·h^2; 54, 13·h, 156, -22·h; -13·h, -3·h^2, -22·h, 4·h^2] 'rigidez del resorte, por unidad de c
#: **Ensamblaje**: cada elemento suma su rigidez en los 4 grados de libertad de sus dos nudos; el resorte es el de la capa en la que cae el centro del elemento.
n_g = 2·(n_e + 1) 'grados de libertad del pilote
#hide
K = zeros(n_g, n_g)
#show
for e = 1:n_e
  g = 2·e - 1 + (0:3)
  if (e - 0.5)·h < h_1
    K(g, g) = K(g, g) + K_v + c_1·K_r
  else
    K(g, g) = K(g, g) + K_v + c_2·K_r
  end
end
#: **Cargas**: la horizontal y el momento entran en el nudo de la cabeza.
#hide
F = zeros(n_g, 1)
F(1) = H_0
F(2) = M_0
#show
#: **Solución** K·u = F. Sin apoyos: los resortes del suelo sostienen todo el pilote.
u = clsolve(K, F)
w_0 = u(1)·1000 'desplazamiento de la cabeza [mm]
θ_0 = u(2)·1000 'giro de la cabeza [mrad]
w_L = u(n_g - 1)·1000 'desplazamiento de la punta [mm]
#hide
r_w0 = round(w_0, 2)
r_wL = round(w_L, 2)
#show
#: La cabeza se corre @{r_w0} mm y la punta @{r_wL} mm **en sentido contrario**: el pilote se comporta casi como un cuerpo rígido que gira, porque 12 m de hormigón de 1 m de diámetro son mucho más rígidos que la arcilla que lo rodea.

## 4 · Cortante y momento a lo largo del pilote

#: En cada elemento, las fuerzas en sus extremos son (K_{v} + c·K_{r})·u_{e}; el cortante y el momento al inicio del elemento salen con signo cambiado del primer nudo.
#hide
z_n = zeros(n_e + 1, 1)
w_n = zeros(n_e + 1, 1)
V_n = zeros(n_e, 1)
M_n = zeros(n_e, 1)
z_m = zeros(n_e, 1)
for j = 1:n_e + 1
  z_n(j) = (j - 1)·h
  w_n(j) = u(2·j - 1)·1000
end
for e = 1:n_e
  g = 2·e - 1 + (0:3)
  if (e - 0.5)·h < h_1
    f_e = (K_v + c_1·K_r)·u(g)
  else
    f_e = (K_v + c_2·K_r)·u(g)
  end
  V_n(e) = f_e(1)
  M_n(e) = -f_e(2)
  z_m(e) = (e - 1)·h
end
#show
V_max = max(abs(V_n)) 'cortante máximo [kN]
M_max = max(abs(M_n)) 'momento máximo [kN·m]
#: Los máximos están en la cabeza: el suelo nunca devuelve más de lo que entra. Es lo mismo que imprime GEO5 (85.00 kN y 120.00 kN·m).
#: Para el dibujo, el desplazamiento y el momento se escalan:
p_w = 0.6·w_n 'desplazamiento de los nudos, escalado
p_z = -z_n 'profundidad de los nudos (hacia abajo)
p_M = -M_n/40 'momento al inicio de cada elemento, escalado
p_zm = -z_m 'profundidad del inicio de cada elemento
#dibujo("Pilote deformado (azul, desplazamiento ×600: 1 m = 1.67 mm) y momento flector (rojo, 1 m = 40 kN·m)", ud = m, cotas = m, escala = auto, alto = 120)
#  rect(-7, -6, 13, 6, "relleno azul tenue sinborde")
#  rect(-7, -13, 13, 7, "relleno naranja tenue sinborde")
#  texto(-6.9, -0.8, "arcilla: k_{h} = 5.54 MN/m³", 3.2, "i")
#  texto(-6.9, -6.8, "arena: k_{h} = 15.14 MN/m³", 3.2, "i")
#  linea(-7, 0, 6, 0, "media verde")
#  linea(0, 0, 0, -12, "eje")
#  polilinea(p_w, p_z, "gruesa azul")
#  polilinea(p_M, p_zm, "media rojo")
#  flecha(-2.2, 0.6, 0, 0.6, "rojo")
#  texto(-6.9, 0.9, "H = 85 kN, M = 120 kN·m", 3.2, "i")
#  texto(2.7, -0.6, "w = 4.21 mm", 3.2, "i")
#  texto(3.3, -1.6, "M = 120 kN·m (rojo)", 3.2, "i")
#  cota(1.3, 0, 1.3, -12, 0.2, "12.00")
#  cota(-7.4, 0, -7.4, -6, 0.2, "6.00")
#  cota(-7.4, -6, -7.4, -13, 0.2, "7.00")
#  cota(-0.5, -13.6, 0.5, -13.6, -0.1, "d = 1.00")
#fin

## 5 · NEC-SE-GC 2015 (oficial)

#: La NEC-15 (§6.4, p. 45) resuelve la carga lateral y el sismo del pilote como **viga sobre resortes p-y** (Reese y Van Impe, 2001), que es lo que hace este marco de GEO5. La norma pide resortes **no lineales**; GEO5 con k_{h} constante es lineal (la opción «according to Matlock and Reese» es la de los mismos autores, solo para arenas). En suelos E y F pide además **interacción cinemática**.
#: La NEC-15 **no da un límite** al desplazamiento de la cabeza: los @{r_w0} mm los juzga el estructural con la deriva y los esfuerzos de la superestructura. El borrador 2023 (no oficial) tampoco fija un número en la cabeza del pilote.

## 6 · Hekatan contra GEO5

#hide
g_w = 4.2
g_V = 85.00
g_M = 120.00
h_w = round(abs(w_0), 1)
h_V = round(V_max, 2)
h_M = round(M_max, 2)
x_w = round(100·(h_w/g_w - 1), 3)
x_V = round(100·(h_V/g_V - 1), 4)
x_M = round(100·(h_M/g_M - 1), 4)
#show
#| Magnitud | Hekatan | GEO5 2024 | Diferencia [%] |
#|---|---:|---:|---:|
#| desplazamiento de la cabeza [mm] | @{h_w} | @{g_w} | @{x_w} |
#| cortante máximo [kN] | @{h_V} | @{g_V} | @{x_V} |
#| momento máximo [kN·m] | @{h_M} | @{g_M} | @{x_M} |
#: GEO5 imprime el desplazamiento con **un solo decimal** (−4.2 mm; el signo es su convención de ejes): la comparación vale a 2 cifras. Con 12, 24, 48 y 96 elementos Hekatan da 4.2121 mm siempre (la viga de Hermite con resorte consistente ya converge con 12).
#: **Lo que NO es cálculo de Hekatan:** E_{def} = 5.0 y 15.5 MPa (leídos del archivo .gpi; no salen de E_{oed} = 8 y 21 MPa con β = 1 − 2ν²/(1 − ν), que daría 4.98 y 15.60) y la verificación de la sección de hormigón (N_{Rd} = 9144.06 kN, M_{Rd} = 756.75 kN·m, V_{Rd} = 419.94 kN, EN 1992-1-1): queda pendiente.
