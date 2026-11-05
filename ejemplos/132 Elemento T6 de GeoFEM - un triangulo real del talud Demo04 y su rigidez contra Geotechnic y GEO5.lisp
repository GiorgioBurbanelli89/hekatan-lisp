# Elemento T6 de GeoFEM: un triángulo real del talud Demo04 y su matriz de rigidez, contra Hekatan Geotechnic y GEO5
#numerico

#: **Qué se hace.** Se toma **un solo elemento** de la malla que GEO5 FEM (GeoFEM) genera para su ejemplo oficial **Demo04.gmk** (un talud en dos suelos, 628 nudos, 287 triángulos de seis nudos) y se rehace a mano todo lo que el programa hace con él antes de resolver: funciones de forma, jacobiano, matriz B, matriz constitutiva D, integración de Gauss y la **matriz de rigidez de 12 × 12**.
#: **Juez.** Dos, y en cadena. (1) **Hekatan Geotechnic**, cuyo solver es GEO5 a 12 cifras por punto de Gauss en las 3 etapas de la Demo04 (142 de 142 iteraciones iguales); de él sale la K del elemento, ejecutando su propio código sin tocarlo. (2) **GEO5 mismo**: el 4-sep-2026 se leyó, con un depurador (Frida) enganchado a FRGeoFEM.exe, la deformación y la tensión que GEO5 calcula en cada punto de Gauss (rutina FUN_005bb940, 17 cifras). Con eso se comprueba aquí **ε = B·u** contra los números internos de GEO5.
#: **Unidades.** kN, m y kPa (kN/m²). La rigidez se enseña en MN/m (miles de kN/m) y las deformaciones en microdeformaciones (µε = 10⁻⁶).

## 1 · El elemento

#: Es el elemento **36** de la malla (contando desde 0; nudos 56, 54, 57, 266, 267 y 268 del modelo de Geotechnic, que es la malla de GEO5 nudo a nudo). Está en el **suelo 1** (el de arriba, el débil: c = 9 kPa, φ = 22.7°), bajo el borde de la coronación del talud (que está a la cota −2.5 m), en x ≈ 21-23 m y z ≈ −9.3 a −6.8 m: justo en la franja que plastifica primero y por donde pasa la cuña que se desliza en GEO5.
#: Primero las tres **esquinas**, en sentido antihorario, y luego los tres **nudos medios** (entre 1-2, 2-3 y 3-1). Coordenadas tal como las guarda el modelo:
x_n = [21; 23.0776; 22.47681; 22.0388; 22.7772; 21.7384] 'abscisa de los nudos 1 a 6 [m]
y_n = [-9.25; -9.222663; -6.773686; -9.236332; -7.998174; -8.011843] 'cota de los nudos 1 a 6 [m]
#: Las mismas, juntas en una tabla de 6 × 2 (columna 1: x; columna 2: y):
X_e = [21, -9.25; 23.0776, -9.222663; 22.47681, -6.773686; 22.0388, -9.236332; 22.7772, -7.998174; 21.7384, -8.011843] 'coordenadas de los 6 nudos [m]
#: El suelo 1 de la Demo04 (lo que GEO5 guarda y Geotechnic lee del .gmk):
E = 130347 'módulo de elasticidad del suelo 1 [kPa]
ν = 0.3 'coeficiente de Poisson del suelo 1

#dibujo("El elemento 36 de la Demo04: tres esquinas y tres nudos medios (cotas en m)", ud = m, escala = auto, cotas = m, alto = 200)
#  linea(21, -9.25, 22.0388, -9.236332, "gruesa")
#  linea(22.0388, -9.236332, 23.0776, -9.222663, "gruesa")
#  linea(23.0776, -9.222663, 22.7772, -7.998174, "gruesa")
#  linea(22.7772, -7.998174, 22.47681, -6.773686, "gruesa")
#  linea(22.47681, -6.773686, 21.7384, -8.011843, "gruesa")
#  linea(21.7384, -8.011843, 21, -9.25, "gruesa")
#  circulo(21, -9.25, 0.05, "rojo relleno")
#  circulo(23.0776, -9.222663, 0.05, "rojo relleno")
#  circulo(22.47681, -6.773686, 0.05, "rojo relleno")
#  circulo(22.0388, -9.236332, 0.05, "azul relleno")
#  circulo(22.7772, -7.998174, 0.05, "azul relleno")
#  circulo(21.7384, -8.011843, 0.05, "azul relleno")
#  texto(20.75, -9.45, "1", 3, "c")
#  texto(23.3, -9.45, "2", 3, "c")
#  texto(22.5, -6.55, "3", 3, "c")
#  texto(22.04, -9.5, "4", 3, "c")
#  texto(23.0, -7.95, "5", 3, "c")
#  texto(21.45, -7.95, "6", 3, "c")
#  circulo(22.18, -8.42, 0.04, "verde relleno")
#  texto(22.18, -8.62, "punto de Gauss 1", 2.4, "c", estilo = "verde")
#  cota(21, -9.75, 23.0776, -9.75, -0.1, "2.08")
#fin
#: Rojo: esquinas. Azul: nudos medios. Verde: el centroide, que es el primer punto de Gauss (el de la hoja 133).

## 2 · Las funciones de forma del triángulo de seis nudos

#: GeoFEM trabaja con **coordenadas de área** L_{1}, L_{2} y L_{3} = 1 − L_{1} − L_{2}: valen 1 en su esquina y 0 en el lado de enfrente. Con seis nudos el desplazamiento dentro del triángulo es un polinomio **cuadrático** (seis términos, seis nudos). Las seis funciones (las mismas, en el mismo orden, que t6() del solver de Geotechnic):
N_6(L_1, L_2) = [L_1*(2*L_1 - 1), L_2*(2*L_2 - 1), (1 - L_1 - L_2)*(2*(1 - L_1 - L_2) - 1), 4*L_1*L_2, 4*L_2*(1 - L_1 - L_2), 4*(1 - L_1 - L_2)*L_1] 'funciones de forma: 3 de esquina y 3 de nudo medio
#: Sus derivadas respecto a L_{1} y L_{2} (fila 1 y fila 2). Como L_{3} depende de las otras dos, cada derivada de L_{3} entra con signo menos:
dN_6(L_1, L_2) = [4*L_1 - 1, 0, -(4*(1 - L_1 - L_2) - 1), 4*L_2, -4*L_2, 4*(1 - L_1 - L_2) - 4*L_1; 0, 4*L_2 - 1, -(4*(1 - L_1 - L_2) - 1), 4*L_1, 4*(1 - L_1 - L_2) - 4*L_2, -4*L_1] 'derivadas de las seis funciones respecto a L₁ (fila 1) y L₂ (fila 2)
#: **Prueba.** En cualquier punto suman 1 (un desplazamiento igual en los seis nudos mueve todo el triángulo igual). En L_{1} = 0.2, L_{2} = 0.3:
s_N = sum(N_6(0.2, 0.3)) 'suma de las seis funciones en un punto cualquiera
#: **Verlas.** Una función de esquina es una «carpa» que sube a 1 en su nudo y se hunde por debajo de 0 en medio de los lados (eso la hace cuadrática). Se dibuja N₁ = L₁·(2·L₁ − 1) con x = L₁ y y = L₂ (el triángulo real es la mitad x + y ≤ 1 del cuadrado):
#surf(x*(2*x-1), [0 1], [0 1])
#: Y una de nudo medio, N₄ = 4·L₁·L₂: vale 1 en el punto medio del lado 1-2 (L₁ = L₂ = ½) y cero en las tres esquinas:
#surf(4*x*y, [0 1], [0 1])

## 3 · Los puntos de Gauss de GeoFEM

#: GeoFEM integra con **7 puntos** en el triángulo (cuadratura de Hammer de grado 5). No es una suposición: el volcado de GEO5 llama a su rutina de tensión **7 veces por elemento** y por pasada, y el solver de Geotechnic (copiado de lo extraído) usa estos mismos puntos y pesos. Los pesos van divididos por 2 porque el triángulo de referencia tiene área ½:
G_p = [1/3, 1/3; 0.1012865073235, 0.1012865073235; 0.7974269853531, 0.1012865073235; 0.1012865073235, 0.7974269853531; 0.4701420641051, 0.4701420641051; 0.0597158717898, 0.4701420641051; 0.4701420641051, 0.0597158717898] 'coordenadas (L₁, L₂) de los 7 puntos
w_g = [0.225; 0.1259391805448; 0.1259391805448; 0.1259391805448; 0.1323941527885; 0.1323941527885; 0.1323941527885]/2 'pesos de los 7 puntos
#: **Prueba.** Los pesos suman el área del triángulo de referencia:
s_w = sum(w_g) 'suma de pesos = ½

## 4 · El jacobiano: del triángulo de referencia al real

#: Las coordenadas reales se interpolan con las mismas funciones (elemento **isoparamétrico**): x = Σ N_{a}·x_{a}, y = Σ N_{a}·y_{a}. El jacobiano reúne cómo cambian x e y al moverse en L_{1} y L_{2}:
#: J = [∂x/∂L₁, ∂y/∂L₁; ∂x/∂L₂, ∂y/∂L₂] = dN·X_{e}
#: En el primer punto de Gauss (el centroide):
J_1 = dN_6(1/3, 1/3)*X_e 'jacobiano en el punto de Gauss 1
dJ_1 = det(J_1) 'determinante del jacobiano = 2 × área real [m²]
A_e = dJ_1/2 'área del elemento [m²]
#: Las derivadas respecto a x e y salen de invertir J: [∂N/∂x; ∂N/∂y] = J⁻¹·dN.
d_xy = inv(J_1)*dN_6(1/3, 1/3) 'derivadas cartesianas de las 6 funciones en el punto 1 [1/m]

## 5 · La matriz B y la matriz D

#: **B** convierte los 12 desplazamientos de los nudos (u_{x} y u_{y} de cada uno, en el orden u₁, v₁, u₂, v₂, …) en las tres deformaciones del plano: ε_{x} = ∂u/∂x, ε_{y} = ∂v/∂y, γ_{xy} = ∂u/∂y + ∂v/∂x. En el punto 1:
#hide
B_1 = zeros(3, 12)
for a = 1:6
  B_1(1, 2*a - 1) = d_xy(1, a)
  B_1(2, 2*a) = d_xy(2, a)
  B_1(3, 2*a - 1) = d_xy(2, a)
  B_1(3, 2*a) = d_xy(1, a)
end
#show
B_1 'matriz B en el punto de Gauss 1 [1/m]
#: **D** es la de **deformación plana** (el talud es largo: ε_{z} = 0). GeoFEM la guarda de 4 × 4 (σ_{x}, σ_{y}, σ_{z}, τ_{xy}) porque la tensión fuera del plano σ_{z} = ν·(σ_{x} + σ_{y}) entra en la plasticidad (hoja 133). Para la rigidez basta la parte del plano:
f_D = E/((1 + ν)*(1 - 2*ν)) 'factor de la matriz de deformación plana [kPa]
D = f_D*[1 - ν, ν, 0; ν, 1 - ν, 0; 0, 0, (1 - 2*ν)/2] 'matriz constitutiva en el plano [kPa]
G_s = E/(2*(1 + ν)) 'módulo de corte = D(3,3) [kPa]

## 6 · La matriz de rigidez: suma sobre los 7 puntos

#: K_{e} = ∫ Bᵀ·D·B dA = Σ_{q} Bᵀ·D·B·|J|·w_{q}. Se repite en cada punto lo de las secciones 4 y 5 (el espesor es 1 m de talud):
#hide
K_e = zeros(12, 12)
#show
for q = 1:7
  dN_q = dN_6(G_p(q, 1), G_p(q, 2))
  J_q = dN_q*X_e
  d_q = inv(J_q)*dN_q
  B_q = zeros(3, 12)
  for a = 1:6
    B_q(1, 2*a - 1) = d_q(1, a)
    B_q(2, 2*a) = d_q(2, a)
    B_q(3, 2*a - 1) = d_q(2, a)
    B_q(3, 2*a) = d_q(1, a)
  end
  K_e = K_e + transpose(B_q)*D*B_q*det(J_q)*w_g(q)
end
#: Se enseña en **cuatro bloques de 6 × 6**, en MN/m. Arriba a la izquierda, los nudos 1-3 (esquinas) entre sí; abajo a la derecha, los nudos 4-6 (medios) entre sí:
#hide
i_1 = [1, 2, 3, 4, 5, 6]
i_2 = [7, 8, 9, 10, 11, 12]
#show
K_11 = K_e(i_1, i_1)/1000 'bloque esquinas-esquinas [MN/m]
K_12 = K_e(i_1, i_2)/1000 'bloque esquinas-medios [MN/m]
K_22 = K_e(i_2, i_2)/1000 'bloque medios-medios [MN/m]
#: El bloque medios-esquinas es el transpuesto de K₁₂ (K es simétrica). Los términos de nudo medio (322.9 MN/m) son casi el triple de los de esquina: en un T6 los nudos medios «cargan» más rigidez.
#: **Pruebas de la física.** K simétrica, y una traslación rígida (todos los nudos 1 mm en x) no produce fuerzas:
#hide
a_sim = max(max(abs(K_e - transpose(K_e))))
r_x = [1; 0; 1; 0; 1; 0; 1; 0; 1; 0; 1; 0]/1000
F_r = max(abs(K_e*r_x))
r_s = round(a_sim, 8)
r_F = round(F_r, 8)
#show
#: Asimetría máxima: **@{r_s} kN/m**. Fuerza máxima en los nudos por la traslación rígida: **@{r_F} kN** (a 8 decimales; lo que queda es el redondeo del double, del orden de 10⁻¹¹).

## 7 · Contra Hekatan Geotechnic: la K del mismo elemento

#: La matriz que arma el solver de Geotechnic para este elemento (sus arreglos Bc, dJw y D4, que son los que usa en cada iteración), copiada con todas sus cifras:
#hide
K_ref = [104856.09822367188, 18063.733111389705, 33292.337372351925, -6444.907773201235, 1659.6656072880437, 12466.152446998982, -133169.26460751682, 25779.64028537574, -0.03401514035431319, -0.16242005026151674, -6638.802580654712, -49864.45565051294; 18063.733111389705, 35656.57011077325, -2267.1193116646987, 4843.709315434811, 8288.363985461812, 7041.720340830101, 9068.486439224693, -19374.72480546388, -0.16242004963021373, -0.0249790599195876, -33153.30180436189, -28167.249982514368; 33292.337372351925, -2267.1193116646987, 116107.86941863039, -44897.107941091635, 5410.306752558619, -12698.58568488964, -133169.38090281485, 9068.464383086486, -21641.134023038612, 50794.50285487617, 0.001382312511850614, -0.1543003166680137; -6444.907773201236, 4843.70931543481, -44897.107941091635, 67598.98206397063, -8520.797223352478, 17689.38366142077, 25779.61822923753, -19374.943996707916, 34083.34900872513, -70757.29774679425, -0.15430031729738403, 0.1667026759369037; 1659.6656072880444, 8288.363985461812, 5410.306752558619, -8520.797223352478, 21209.890751779996, -697.3058526481565, -0.018365706986060104, 0.011856011006784684, -21641.405027741956, 34083.19241130584, -6638.439718177725, -33153.46517677802; 12466.152446998982, 7041.720340830101, -12698.58568488964, 17689.38366142077, -697.3058526481566, 74193.32773377914, 0.011856011006784684, -0.02669325185161142, 50794.34625745375, -70758.12141938061, -49864.61902292592, -28166.28362339756; -133169.26460751682, 9068.486439224693, -133169.38090281485, 25779.61822923753, -0.018365706985605357, 0.011856011005875189, 322898.1905179742, -36707.51213468322, -13277.361631182808, -83018.05248050028, -43282.16501075277, 84877.44809071027; 25779.64028537574, -19374.72480546388, 9068.464383086486, -19374.94399670792, 0.011856011007694178, -0.0266932518552494, -36707.51213468322, 236598.3768752575, -83018.05248050379, -56334.0766974797, 84877.44809071376, -141514.60468235414; -0.03401514035431319, -0.16242004963021373, -21641.134023038612, 34083.34900872513, -21641.405027741956, 50794.34625745375, -13277.361631182815, -83018.05248050379, 322898.6819178008, -36708.87845572436, -266338.7472206971, 34849.3980900989; -0.16242005026333572, -0.0249790599195876, 50794.50285487617, -70757.29774679424, 34083.19241130584, -70758.12141938061, -83018.05248050028, -56334.0766974797, -36708.87845572436, 236599.8061229753, 34849.39809009289, -38750.28528026076; -6638.802580654708, -33153.30180436189, 0.001382312515488593, -0.154300317301022, -6638.439718177725, -49864.61902292592, -43282.165010752775, 84877.44809071376, -266338.74722069706, 34849.39809009289, 322898.15314796974, -36708.77105320154; -49864.45565051294, -28167.24998251437, -0.15430031666983268, 0.16670267593872268, -33153.46517677802, -28166.283623397547, 84877.44809071027, -141514.60468235414, 34849.39809009891, -38750.28528026077, -36708.77105320153, 236598.25686585088]
dJw_1 = 0.5742472926683748
d_K = max(max(abs(K_e - K_ref)))
d_Kr = 100*d_K/max(max(abs(K_ref)))
d_J = 100*(dJ_1*w_g(1) - dJw_1)/dJw_1
r_K = round(d_K, 8)
r_Kr = round(d_Kr, 10)
#show
#: Mayor diferencia entre las dos K, término a término: **@{r_K} kN/m** (a 8 decimales), o sea **@{r_Kr} %** del término mayor (322 898 kN/m).
#: Los términos que en K_{ref} valen 0.03 o 0.16 kN/m (casi cero frente a 322 898) existen porque los nudos medios del modelo no caen **exactamente** en la mitad de cada lado (la cota del nudo 4 lleva 6 decimales). Por eso |J| no es exactamente igual en los 7 puntos: vale 5.10442 m² (el doble del área) en todos, pero cambia en la sexta cifra de un punto a otro (|J|·w = 0.3214230 en el punto 2 y 0.3214233 en el 3). Esta hoja los reproduce igual.

## 8 · Contra GEO5: la deformación en los 7 puntos

#: En la **primera iteración** de la Demo04 (etapa 1, factor de reducción 1) GeoFEM resuelve el talud elástico con todo el peso propio. El desplazamiento de los seis nudos de este elemento en esa iteración (de Geotechnic, que es el de GEO5 a 12 cifras) es, en mm:
u_e = [-0.21944116174743908; -18.27511452760742; -0.12941416268067674; -18.919172101148858; 0.318999771740479; -20.018626130526677; -0.17859139025973192; -18.629156436727395; 0.06793001647263578; -19.54959315855677; 0.03428278222644265; -19.218099610541124] 'u₁, v₁, …, u₆, v₆ en la iteración 1 [mm]
#: Con la B de cada punto, ε = B·u. Se pasa a µε (u en mm → ×1000):
#hide
e_h = zeros(7, 3)
for q = 1:7
  dN_q = dN_6(G_p(q, 1), G_p(q, 2))
  J_q = dN_q*X_e
  d_q = inv(J_q)*dN_q
  B_q = zeros(3, 12)
  for a = 1:6
    B_q(1, 2*a - 1) = d_q(1, a)
    B_q(2, 2*a) = d_q(2, a)
    B_q(3, 2*a - 1) = d_q(2, a)
    B_q(3, 2*a) = d_q(1, a)
  end
  e_q = 1000*B_q*u_e
  e_h(q, 1) = e_q(1)
  e_h(q, 2) = e_q(2)
  e_h(q, 3) = e_q(3)
end
#show
e_h 'ε_{x}, ε_{y}, γ_{xy} en los 7 puntos (filas), calculadas aquí [µε]
#: Lo que GEO5 tenía en memoria en esos mismos puntos (volcado con Frida, dp_dump3_e1.txt, iteración 1). GEO5 recorre los puntos en otro orden: nuestro punto 1 es su 7.º, el 2 su 3.º, el 3 su 1.º, el 4 su 2.º, y del 5 al 7 son su 4.º a 6.º. Ya ordenados como aquí:
e_g5 = [33.601130614284883, -546.07359502585953, -123.71389243874369; 23.020793809996603, -441.86765670145654, -101.29839623730305; 33.213008503175779, -585.16397648758489, -170.56371543683856; 44.569575867166764, -611.18893520932614, -99.279467273746900; 39.839005327797579, -607.51055415502429, -136.92943281076730; 33.829949973011304, -523.02705926975807, -96.092495014139800; 27.134431793034591, -507.68309633596534, -138.11971529871514] 'ε de GEO5 en los 7 puntos [µε]
#hide
d_e = max(max(abs(e_h - e_g5)))
d_er = 100*d_e/max(max(abs(e_g5)))
r_d = round(d_e, 8)
#show
#: Mayor diferencia con GEO5 en los 21 valores: **@{r_d} µε** (a 8 decimales; el valor real es del orden de 10⁻¹⁰ µε, el redondeo del double).
#: **Lectura.** ε_{y} ≈ −500 µε: el suelo se acorta en vertical por su propio peso; ε_{x} es pequeña y positiva (se ensancha un poco hacia la ladera) y γ_{xy} ≈ −100 a −170 µε es el **corte** que ya empieza a marcar el deslizamiento hacia la izquierda.

## 9 · Hekatan LISP contra Geotechnic y GEO5

#hide
r_J = round(d_J, 10)
r_e = round(d_er, 10)
k_77 = round(K_e(7, 7), 4)
k_11 = round(K_e(1, 1), 4)
#show
#| Qué se compara | Hekatan LISP | Referencia | Diferencia |
#|---|---:|---:|---:|
#| K_{e}(1,1), esquina 1 en x [kN/m] | @{k_11} | 104856.0982 (Geotechnic) | — |
#| K_{e}(7,7), nudo medio 4 en x [kN/m] | @{k_77} | 322898.1905 (Geotechnic) | — |
#| **K_{e} completa, 144 términos** | — | Geotechnic | **@{r_Kr} %** del término mayor |
#| det J · w en el punto 1 [m²] | — | 0.5742472927 (Geotechnic) | @{r_J} % |
#| **ε en los 7 puntos, iteración 1** | e_{h} | GEO5 (Frida, 17 cifras) | **@{r_e} %** de la mayor |
#| simetría de K [kN/m] | @{r_s} | 0 | — |
#| fuerza por traslación rígida [kN] | @{r_F} | 0 | — |
#: **Qué queda comprobado.** Las funciones de forma, los 7 puntos de Gauss, el jacobiano, B, D de deformación plana y la suma Bᵀ·D·B·|J|·w de esta hoja son los de GeoFEM: la K del elemento es la de Geotechnic término a término, y ε = B·u da lo mismo que GEO5 tenía en memoria en los 7 puntos. Las diferencias son de redondeo del double (10⁻¹⁰ % o menos).
#: **Qué NO se comprueba aquí.** GEO5 no deja ver la K de un elemento (no se volcó esa rutina); la K se compara contra Geotechnic, y Geotechnic contra GEO5 por punto de Gauss y nudo a nudo (registros/talud_geo5.md, 4-sep-2026). La hoja 133 sigue con la tensión de ese punto 1 y su retorno a la superficie de fluencia.
