# Muro de contención de Manabí entero como membrana: pantalla y zapata sobre muelles
#numerico

#: **Qué modelo es.** Es el modelo simplificado del muro de Manabí en Hekatan Struct (ejemplo «muro-manabi», modelo **membrana**). Sigue siendo una **membrana**: se modela la **sección** del muro (pantalla y zapata juntas) con elementos de cuatro nudos, dos desplazamientos por nudo (u_{x} horizontal, u_{z} vertical) y 1 m de muro como espesor. Como el muro es largo, la franja trabaja en **deformación plana**.
#: **Lo que añade la zapata.** Dos cosas: (1) **muelles de balasto** verticales en todos los nudos de la base, porque la zapata se apoya en el suelo y no en un empotramiento; (2) **un apoyo horizontal** en la punta de la puntera, para que el muro no resbale. No hay nada más.
#: **Cómo está hecha la hoja.** Primero todo con **símbolos** (secciones 1 a 4): empujes, carga en los nudos, matriz constitutiva, funciones de forma, Jacobiano, rigidez del elemento y muelles. Después, los **números** (secciones 5 a 9) y la comparación con SAP2000 y Hekatan Struct.
#: **Unidades.** kN, m y kPa (kN/m²), por metro de muro.

## 1 · El muro, las cargas y los apoyos
#dibujo("Sección del muro de Manabí: empuje del relleno (azul), incremento sísmico (naranja), peso del relleno sobre el talón (verde) y muelles bajo la zapata", ud = m, cotas = m, ancho = 150, alto = 120)
#  polilinea([0, 3, 3, 1.1, 1.1, 0.85, 0.7, 0, 0], [0, 0, 0.4, 0.4, 3, 3, 0.4, 0.4, 0], "gruesa")
#  carga(1.1, 3, 1.1, 0.4, 0, 0.8, "", "azul", n = 8)
#  carga(1.1, 3, 1.1, 0.4, 0.9, 0, "", "naranja", n = 8)
#  carga(1.1, 0.4, 3, 0.4, 0.5, 0.5, "", "verde", n = 10)
#  texto(2.35, 2.2, "empuje de Coulomb", 2.4, "c", estilo = "azul")
#  texto(2.35, 3.15, "sismo, Mononobe-Okabe", 2.4, "c", estilo = "naranja")
#  texto(2.6, 1.05, "relleno γ·H_f", 2.4, "c", estilo = "verde")
#  polilinea([0.3, 0.3, 0.22, 0.38, 0.22, 0.38, 0.3, 0.3], [0, -0.08, -0.12, -0.18, -0.24, -0.3, -0.34, -0.42], "media")
#  polilinea([1.5, 1.5, 1.42, 1.58, 1.42, 1.58, 1.5, 1.5], [0, -0.08, -0.12, -0.18, -0.24, -0.3, -0.34, -0.42], "media")
#  polilinea([2.7, 2.7, 2.62, 2.78, 2.62, 2.78, 2.7, 2.7], [0, -0.08, -0.12, -0.18, -0.24, -0.3, -0.34, -0.42], "media")
#  linea(-0.1, -0.42, 3.1, -0.42, "trazos gris")
#  texto(1.5, -0.62, "muelles de balasto k_{s} en toda la base", 2.4, "c")
#  empotramiento(-0.03, 0, -0.03, 0.4, 1)
#  texto(-0.3, 0.2, "u_{x} = 0", 2.4, "d")
#  cota(0, 0, 3, 0, -0.95, "B = 3.00")
#  cota(0, 0, 0.7, 0, -0.75, "0.70")
#  cota(1.1, 0.4, 1.1, 3, 1.35, "H_f = 2.60")
#  cota(0.85, 3, 1.1, 3, 0.25, "0.25")
#fin
#: Pantalla (fuste) de 2.60 m, de 0.25 m en la coronación a 0.40 m en el pie; la cara del relleno es vertical y la de delante, inclinada. Zapata de 3.00 × 0.40 m: puntera de 0.70 m y talón de 1.90 m.

## 2 · En símbolos: empujes y carga en los nudos
### 2.1 · Coeficientes de empuje
#: Empuje activo de **Coulomb** con trasdós vertical, terreno horizontal y rozamiento δ entre muro y suelo:
K_C(φ, δ) = cos(φ)^2/(cos(δ)·(1 + sqrt(sin(φ + δ)·sin(φ)/cos(δ)))^2)
#: Con sismo, **Mononobe-Okabe**. El sismo inclina la gravedad un ángulo ψ, con tan ψ = k_{h}/(1 − k_{v}):
K_MO(φ, δ, ψ) = cos(φ - ψ)^2/(cos(ψ)·cos(δ + ψ)·(1 + sqrt(sin(φ + δ)·sin(φ - ψ)/cos(δ + ψ)))^2)
#: Presión estática a la cota z (medida desde la base de la zapata; Z_{t} es la cota de la coronación) y el **incremento** sísmico, que es un triángulo **invertido**: nulo al pie de la pantalla y máximo en la coronación (así lo hace GEO5):
p_E(z) = K_a·γ·(Z_t - z)
p_S(z) = (K_ae - K_a)·(1 - k_v)·γ·(z - t_f)
#: Las dos presiones actúan en la dirección del empuje, inclinada δ: la componente horizontal empuja hacia la puntera (p·cos δ) y la vertical tira hacia abajo (p·sin δ).

### 2.2 · De la presión a las fuerzas en los nudos
#: En un tramo del trasdós de largo l la presión es lineal, de p_{1} a p_{2}. Cada nudo recibe la integral de la presión por su función de forma, N_{1} = 1 − s/l y N_{2} = s/l:
F_tramo = Simplify{Integral{[1 - s/l; s/l]*(p_1 + (p_2 - p_1)*s/l) @ s = 0 : l}}
#: Es decir, l·(2·p_{1} + p_{2})/6 abajo y l·(p_{1} + 2·p_{2})/6 arriba: cada nudo se lleva algo más de la presión de su lado.
#: **Peso propio y sismo del muro:** el peso de cada elemento, W = γ_{c}·A·L, se reparte en cuatro partes iguales a sus nudos (−W/4 en z) y la inercia del sismo, −k_{h}·W/4 en x. **Relleno sobre el talón:** γ·H_{f} por el ancho tributario de cada nudo de la cara superior del talón.

## 3 · En símbolos: el elemento de membrana
### 3.1 · Matriz constitutiva de deformación plana
#: Relaciona [σ_{x}, σ_{z}, τ_{xz}] con [ε_{x}, ε_{z}, γ_{xz}]. En deformación plana ε_{y} = 0 a lo largo del muro:
D_p = Simplify{E/((1+nu)*(1-2*nu))*[1-nu, nu, 0; nu, 1-nu, 0; 0, 0, (1-2*nu)/2]}
#: Struct, SAP2000 y ETABS no tienen un elemento de deformación plana en la cáscara: usan tensión plana con el material cambiado, E' = E/(1 − ν²) y ν' = ν/(1 − ν). Sustituido en la tensión plana da **la misma** matriz:
D_t = Simplify{(E/(1-nu^2))/(1-(nu/(1-nu))^2)*[1, nu/(1-nu), 0; nu/(1-nu), 1, 0; 0, 0, (1-nu/(1-nu))/2]}
dif_D = Simplify{D_t - D_p}

### 3.2 · Funciones de forma y Jacobiano
#: En el cuadrado natural (ξ y η de −1 a 1), cada función vale 1 en su nudo y 0 en los otros tres:
N_1 = Expand{(1-xi)*(1-eta)/4}
N_2 = Expand{(1+xi)*(1-eta)/4}
N_3 = Expand{(1+xi)*(1+eta)/4}
N_4 = Expand{(1-xi)*(1+eta)/4}
#: Las derivadas en ξ (fila 1) y en η (fila 2), una columna por nudo:
dN_ξη = Simplify{[Partial{(1-xi)*(1-eta)/4 @ xi}, Partial{(1+xi)*(1-eta)/4 @ xi}, Partial{(1+xi)*(1+eta)/4 @ xi}, Partial{(1-xi)*(1+eta)/4 @ xi}; Partial{(1-xi)*(1-eta)/4 @ eta}, Partial{(1+xi)*(1-eta)/4 @ eta}, Partial{(1+xi)*(1+eta)/4 @ eta}, Partial{(1-xi)*(1+eta)/4 @ eta}]}
#: La geometría se interpola con las mismas funciones (elemento isoparamétrico). El **Jacobiano** es esa matriz por las coordenadas de los cuatro nudos, [x_{i}, z_{i}]:
J_q = Simplify{[-(1-eta)/4, (1-eta)/4, (1+eta)/4, -(1+eta)/4; -(1-xi)/4, -(1+xi)/4, (1+xi)/4, (1-xi)/4]*[x_1, z_1; x_2, z_2; x_3, z_3; x_4, z_4]}
#: En la zapata los elementos son cuadrados de lado a y J = (a/2)·I, constante. En la pantalla el elemento es un **trapecio** (la cara de delante está inclinada): J cambia de punto a punto y la integral se hace por Gauss con números (sección 7). Las derivadas en x y z salen de J⁻¹·dN_{ξη}.

### 3.3 · Rigidez del elemento cuadrado de lado a
#: La matriz B da las deformaciones a partir de los 8 desplazamientos de los nudos, ordenados [u_{1}, w_{1}, u_{2}, w_{2}, …]. Fila 1: ε_{x} = ∂u/∂x. Fila 2: ε_{z} = ∂w/∂z. Fila 3: γ_{xz} = ∂u/∂z + ∂w/∂x. Los ceros están donde un desplazamiento no entra en esa deformación:
B_a(xi, eta) = Simplify{[-(1-eta)/(2*a), 0, (1-eta)/(2*a), 0, (1+eta)/(2*a), 0, -(1+eta)/(2*a), 0; 0, -(1-xi)/(2*a), 0, -(1+xi)/(2*a), 0, (1+xi)/(2*a), 0, (1-xi)/(2*a); -(1-xi)/(2*a), -(1-eta)/(2*a), -(1+xi)/(2*a), (1-eta)/(2*a), (1+xi)/(2*a), (1+eta)/(2*a), (1-xi)/(2*a), -(1+eta)/(2*a)]}
#: **Modos incompatibles** (Wilson y Taylor). El elemento de cuatro nudos solo se deforma con lados rectos y en flexión sale demasiado rígido. Se le añaden dos formas curvas, 1 − ξ² y 1 − η², para u y para w, con amplitudes α = [α_{1}, α_{2}, α_{3}, α_{4}] (u con 1 − ξ², w con 1 − ξ², u con 1 − η², w con 1 − η²). Sus deformaciones son la matriz G:
G_a(xi, eta) = Simplify{[-4*xi/a, 0, 0, 0; 0, 0, 0, -4*eta/a; 0, -4*xi/a, -4*eta/a, 0]}
#: Las tres rigideces, integradas en el cuadrado natural; el Jacobiano del cuadrado vale a²/4 y el espesor es t (1 m de muro):
K_uu = Simplify{t*a^2/4*Area{Area{transpose(B_a(xi, eta))*D_p*B_a(xi, eta) @ xi = -1 : 1} @ eta = -1 : 1}}
K_ua = Simplify{t*a^2/4*Area{Area{transpose(B_a(xi, eta))*D_p*G_a(xi, eta) @ xi = -1 : 1} @ eta = -1 : 1}}
K_aa = Simplify{t*a^2/4*Area{Area{transpose(G_a(xi, eta))*D_p*G_a(xi, eta) @ xi = -1 : 1} @ eta = -1 : 1}}
#: Las α no tienen nudo propio: se eliminan dentro del elemento (**condensación estática**). De las dos ecuaciones K_{uu}·u + K_{ua}·α = f y K_{ua}ᵀ·u + K_{aa}·α = 0 se despeja α = −K_{aa}⁻¹·K_{ua}ᵀ·u y queda la rigidez de 8 × 8, **K_{c} = K_{uu} − K_{ua}·K_{aa}⁻¹·K_{ua}ᵀ**. Es demasiado ancha para la página; el motor la calcula entera y se enseña sacando el factor común E·t/(24·(1 + ν)·(1 − 2·ν)). El lado a se ha ido: la rigidez del cuadrado no depende de su tamaño, quedan solo números y ν:
K_c1 = Simplify{(K_uu - K_ua*inv(K_aa)*transpose(K_ua))*24*(1+nu)*(1-2*nu)/(E*t)}
#: **Elemento distorsionado (la pantalla).** Con J variable, G se calcula con el Jacobiano del centro, J_{0} = J(0, 0), y se multiplica por det J_{0}/det J. Es la corrección de Taylor: sin ella, un trapecio no pasaría la prueba de la parcela (deformación constante).

## 4 · En símbolos: los muelles y el sistema
#: Cada nudo de la base lleva un muelle vertical del suelo: el módulo de balasto por el área que le toca (la mitad de cada tramo vecino por el metro de muro): **k_{j} = k_{s}·A_{j}**. La presión del suelo en ese nudo es el hundimiento por el módulo de balasto, q_{j} = −k_{s}·w_{j}. La rigidez del muelle se suma en la diagonal, en el grado vertical del nudo:
#: (K + K_{s})·U = F
#: con K la suma de las rigideces de los elementos, K_{s} la diagonal de los muelles y U los desplazamientos. El apoyo horizontal de la puntera quita la fila y la columna de su u_{x}: se resuelven los grados **libres**, U_{L} = K_{LL}⁻¹·F_{L}.

## 5 · Y ahora los números: datos
H_f = 2.6 'alto de la pantalla, m
t_f = 0.4 'canto de la zapata, m
t_c = 0.25 'pantalla en la coronación, m
t_b = 0.4 'pantalla en el pie, m
p_t = 0.7 'puntera, m
t_l = 1.9 'talón, m
L = 1 'metro de muro
m_s = 0.1 'lado del elemento, m
#: f'_{c} = 21 MPa (el mínimo de la NEC-SE-HM) y E = 4700·√f'_{c} en MPa (ACI 318-19, 19.2.2.1.b), pasado a kN/m²:
E = 4700·sqrt(21)·1000
ν = 0.2
γ_c = 23 'hormigón, kN/m³ (el de GEO5)
γ = 18.5 'relleno, arena SP, kN/m³
φ = 30·pi/180 'rozamiento del relleno
δ = 20·pi/180 'rozamiento muro-suelo
k_h = 0.336 'NEC-SE-GC: 0.6·Z·F_a = 0.6·0.50·1.12
k_v = 0
#: Módulo de balasto del estudio de suelos (tramo −2.55 a −3.00 m): 6.59 kg/cm³, en kN/m³:
k_s = 6.59·9.80665·1000
x_b = p_t + t_b 'abscisa del trasdós, m
B = x_b + t_l 'ancho de la zapata, m
Z_t = t_f + H_f 'cota de la coronación, m
#: Los coeficientes de empuje, con las fórmulas de la sección 2:
K_a = K_C(φ, δ)
ψ = atan(k_h/(1 - k_v))
K_ae = K_MO(φ, δ, ψ)
ψ_g = ψ·180/pi 'en grados

## 6 · Malla
#: Todas las medidas son múltiplos de 0.10 m, así que en x hay 30 elementos (7 en la puntera, 4 bajo la pantalla, 19 en el talón) y en z, 4 en la zapata y 26 en la pantalla. En la pantalla cada fila de nudos se reparte en 4 partes iguales entre la cara inclinada y el trasdós.
n_x = round(B/m_s)
n_f = round(t_f/m_s)
n_h = round(H_f/m_s)
n_z = n_f + n_h
i_0 = round(p_t/m_s) + 1 'columna de la cara de delante, en el pie
i_1 = round(x_b/m_s) + 1 'columna del trasdós
n_p = i_1 - i_0 'elementos en el canto de la pantalla
#hide
N_ik = zeros(n_x + 1, n_z + 1)
n_j = (n_f + 1)·(n_x + 1) + n_h·(n_p + 1)
x_j = zeros(n_j, 1)
z_j = zeros(n_j, 1)
n_j = 0
for k = 1:n_f + 1
  for i = 1:n_x + 1
    n_j = n_j + 1
    N_ik(i, k) = n_j
    x_j(n_j) = (i - 1)·m_s
    z_j(n_j) = (k - 1)·m_s
  end
end
for k = n_f + 2:n_z + 1
  z = (k - 1)·m_s
  x_f = p_t + (t_b - t_c)·(z - t_f)/H_f
  for i = i_0:i_1
    n_j = n_j + 1
    N_ik(i, k) = n_j
    x_j(n_j) = x_f + (i - i_0)/n_p·(x_b - x_f)
    z_j(n_j) = z
  end
end
n_e = n_x·n_f + n_p·n_h
e_j = zeros(n_e, 4)
e = 0
for k = 1:n_f
  for i = 1:n_x
    e = e + 1
    e_j(e, :) = [N_ik(i, k), N_ik(i + 1, k), N_ik(i + 1, k + 1), N_ik(i, k + 1)]
  end
end
for k = n_f + 1:n_z
  for i = i_0:i_1 - 1
    e = e + 1
    e_j(e, :) = [N_ik(i, k), N_ik(i + 1, k), N_ik(i + 1, k + 1), N_ik(i, k + 1)]
  end
end
#show
#: Nudos, elementos y grados de libertad (los mismos que en Struct):
n_j
n_e
n_d = 2·n_j
#: El nudo 1 es la punta de la puntera, el del apoyo horizontal:
#malla(x_j, z_j, e_j, [1])

## 7 · Rigidez: suma en los cuatro puntos de Gauss
#: En cada elemento y en cada punto de Gauss (ξ, η = ±1/√3, pesos 1): Jacobiano, derivadas en x y z, las matrices B y G, y se acumula det J·t·[BᵀDB, BᵀDG, GᵀDG]. Luego se condensa como en la sección 3.3 y se suma en K en las filas y columnas de sus grados de libertad. De paso, la suma de det J da el área del elemento, que hace falta para el peso.
D = E/((1 + ν)·(1 - 2·ν))·[1 - ν, ν, 0; ν, 1 - ν, 0; 0, 0, (1 - 2·ν)/2]
s_g = 1/sqrt(3)
ξ_g = [-s_g, s_g, s_g, -s_g]
η_g = [-s_g, -s_g, s_g, s_g]
#hide
S_u = zeros(4, 8)
S_w = zeros(4, 8)
for i = 1:4
  S_u(i, 2·i - 1) = 1
  S_w(i, 2·i) = 1
end
d_e(e) = [2·e_j(e, 1) - 1, 2·e_j(e, 1), 2·e_j(e, 2) - 1, 2·e_j(e, 2), 2·e_j(e, 3) - 1, 2·e_j(e, 3), 2·e_j(e, 4) - 1, 2·e_j(e, 4)]
K = zeros(n_d, n_d)
A_e = zeros(n_e, 1)
K_1 = zeros(8, 8)
for e = 1:n_e
  X_e = [x_j(e_j(e, 1)), z_j(e_j(e, 1)); x_j(e_j(e, 2)), z_j(e_j(e, 2)); x_j(e_j(e, 3)), z_j(e_j(e, 3)); x_j(e_j(e, 4)), z_j(e_j(e, 4))]
  J_0 = [-1, 1, 1, -1; -1, -1, 1, 1]/4·X_e
  d_0 = det(J_0)
  k_uu = zeros(8, 8)
  k_ua = zeros(8, 4)
  k_aa = zeros(4, 4)
  for g = 1:4
    ξ = ξ_g(g)
    η = η_g(g)
    d_N = [-(1 - η)/4, (1 - η)/4, (1 + η)/4, -(1 + η)/4; -(1 - ξ)/4, -(1 + ξ)/4, (1 + ξ)/4, (1 - ξ)/4]
    J_g = d_N·X_e
    d_J = det(J_g)
    g_xz = inv(J_g)·d_N
    g_x = transpose(g_xz(1, :))
    g_z = transpose(g_xz(2, :))
    B_g = [g_x·S_u; g_z·S_w; g_z·S_u + g_x·S_w]
    P = inv(J_0)·[-2·ξ, 0; 0, -2·η]·d_0/d_J
    G_g = [P(1, 1), 0, P(1, 2), 0; 0, P(2, 1), 0, P(2, 2); P(2, 1), P(1, 1), P(2, 2), P(1, 2)]
    k_uu = k_uu + d_J·L·transpose(B_g)·D·B_g
    k_ua = k_ua + d_J·L·transpose(B_g)·D·G_g
    k_aa = k_aa + d_J·L·transpose(G_g)·D·G_g
    A_e(e) = A_e(e) + d_J
  end
  K_e = k_uu - k_ua·(k_aa\transpose(k_ua))
  if e == 1
    K_1 = K_e
  end
  g = d_e(e)
  K(g, g) = K(g, g) + K_e
end
#show
#: **Comprobación del símbolo.** El elemento 1 es un cuadrado de la zapata. Su término (1, 1) sumado por Gauss y el de la fórmula de la sección 3.3, K_{c1}(1, 1)·E·t/(24·(1 + ν)·(1 − 2·ν)), con K_{c1}(1, 1) = (12·ν² − 25·ν + 11)/(1 − ν):
k_Gauss = K_1(1, 1)
k_simb = (12·ν^2 - 25·ν + 11)/(1 - ν)·E·L/(24·(1 + ν)·(1 - 2·ν))
#: Área de la sección (la suma de las áreas de los elementos), en m²:
A_sec = sum(A_e)
#: **Muelles.** Área tributaria de cada nudo de la base: m_{s}/2 en los dos extremos, m_{s} en los demás:
#hide
K_s = 0
for i = 1:n_x + 1
  j = N_ik(i, 1)
  w_i = m_s
  if i == 1
    w_i = m_s/2
  end
  if i == n_x + 1
    w_i = m_s/2
  end
  K(2·j, 2·j) = K(2·j, 2·j) + k_s·w_i·L
  K_s = K_s + k_s·w_i·L
end
#show
#: La suma de los muelles tiene que ser k_{s}·B·L:
K_s
k_sBL = k_s·B·L

## 8 · Cargas
#: Dos vectores de fuerzas: F_{0} (estático: peso propio, relleno y empuje de Coulomb) y F_{1} (el sismo: inercia del muro e incremento de Mononobe-Okabe). El caso sísmico es F_{0} + F_{1}.
#hide
F_0 = zeros(n_d, 1)
F_1 = zeros(n_d, 1)
for e = 1:n_e
  W = A_e(e)·L·γ_c
  for i = 1:4
    j = e_j(e, i)
    F_0(2·j) = F_0(2·j) - W/4
    F_1(2·j - 1) = F_1(2·j - 1) - k_h·W/4
    F_1(2·j) = F_1(2·j) + k_v·W/4
  end
end
F_pp = sum(F_0)
for i = i_1:n_x + 1
  j = N_ik(i, n_f + 1)
  w_i = m_s
  if i == i_1
    w_i = m_s/2
  end
  if i == n_x + 1
    w_i = m_s/2
  end
  F_0(2·j) = F_0(2·j) - γ·H_f·w_i·L
end
F_rel = sum(F_0) - F_pp
E_x = 0
E_z = 0
S_x = 0
S_z = 0
for k = n_f + 1:n_z
  j_a = N_ik(i_1, k)
  j_b = N_ik(i_1, k + 1)
  z_a = z_j(j_a)
  z_b = z_j(j_b)
  l = z_b - z_a
  f_a = l·(2·p_E(z_a) + p_E(z_b))/6·L
  f_b = l·(p_E(z_a) + 2·p_E(z_b))/6·L
  s_a = l·(2·p_S(z_a) + p_S(z_b))/6·L
  s_b = l·(p_S(z_a) + 2·p_S(z_b))/6·L
  F_0(2·j_a - 1) = F_0(2·j_a - 1) - f_a·cos(δ)
  F_0(2·j_b - 1) = F_0(2·j_b - 1) - f_b·cos(δ)
  F_0(2·j_a) = F_0(2·j_a) - f_a·sin(δ)
  F_0(2·j_b) = F_0(2·j_b) - f_b·sin(δ)
  F_1(2·j_a - 1) = F_1(2·j_a - 1) - s_a·cos(δ)
  F_1(2·j_b - 1) = F_1(2·j_b - 1) - s_b·cos(δ)
  F_1(2·j_a) = F_1(2·j_a) - s_a·sin(δ)
  F_1(2·j_b) = F_1(2·j_b) - s_b·sin(δ)
  E_x = E_x - (f_a + f_b)·cos(δ)
  E_z = E_z - (f_a + f_b)·sin(δ)
  S_x = S_x - (s_a + s_b)·cos(δ)
  S_z = S_z - (s_a + s_b)·sin(δ)
end
S_x = S_x + k_h·F_pp
#show
#: Sumas de cada carga, en kN/m. Struct da: peso −47.035, relleno −91.390, empuje (−17.470, −6.359), sismo (−35.038, −7.001).
F_pp
F_rel
E_x
E_z
S_x
S_z

## 9 · Solución y resultados
#hide
L_f = zeros(n_d - 1, 1)
for i = 2:n_d
  L_f(i - 1) = i
end
U_0 = zeros(n_d, 1)
U_1 = zeros(n_d, 1)
F_2 = F_0 + F_1
#show
#: Se resuelve (K + K_{s})·U = F en los grados libres (todos menos el u_{x} del nudo 1), para los dos casos:
U_0(L_f) = K(L_f, L_f)\F_0(L_f)
U_1(L_f) = K(L_f, L_f)\F_2(L_f)
#: **Coronación** (nudo del trasdós, arriba), en mm. Estático y con sismo:
j_c = N_ik(i_1, n_z + 1)
u_c0 = 1000·U_0(2·j_c - 1)
u_c1 = 1000·U_1(2·j_c - 1)
w_c1 = 1000·U_1(2·j_c)
#: **Presión del suelo** bajo la zapata, q = −k_{s}·w, en kPa. En la punta de la puntera (x = 0) y en la punta del talón (x = B):
q_p0 = -k_s·U_0(2·N_ik(1, 1))
q_t0 = -k_s·U_0(2·N_ik(n_x + 1, 1))
q_p1 = -k_s·U_1(2·N_ik(1, 1))
q_t1 = -k_s·U_1(2·N_ik(n_x + 1, 1))
#: Sin sismo la presión es mayor en el **talón**, que es donde carga el relleno. Con sismo el muro vuelca hacia delante y la presión se va a la **puntera**.
#: **Equilibrio con sismo.** La suma de las fuerzas de los muelles es la reacción vertical; tiene que igualar a las cargas verticales:
#hide
R_z = 0
for i = 1:n_x + 1
  j = N_ik(i, 1)
  w_i = m_s
  if i == 1
    w_i = m_s/2
  end
  if i == n_x + 1
    w_i = m_s/2
  end
  R_z = R_z - k_s·w_i·L·U_1(2·j)
end
#show
R_z
F_z = -(F_pp + F_rel + E_z + S_z)

### Deformada y mapa de color
#: El muro con sismo, con los desplazamientos ampliados 300 veces y pintado con el desplazamiento horizontal u_{x} en mm. Al pasar el cursor sale el valor en cada punto. Se ve el giro de todo el muro sobre los muelles: la zapata se hunde más en la puntera que en el talón, y la pantalla se dobla hacia delante.
#hide
X_n = zeros(n_j, 3)
U_3 = zeros(n_j, 3)
u_x = zeros(n_j, 1)
for j = 1:n_j
  X_n(j, 1) = x_j(j)
  X_n(j, 2) = z_j(j)
  U_3(j, 1) = U_1(2·j - 1)
  U_3(j, 2) = U_1(2·j)
  u_x(j) = 1000·U_1(2·j - 1)
end
e_f = zeros(0, 2)
v_f = zeros(0, 2)
#show
#modelo3d(X_n, e_j, e_f, u_x, v_f, U_3, 300)

## 10 · Comparación con SAP2000 y con Hekatan Struct
#: **SAP2000 24** (por OAPI): elemento Plane de **deformación plana con modos incompatibles**, los mismos 285 nudos, los mismos muelles, el mismo apoyo y las mismas fuerzas nodales. Es el elemento de esta hoja. **Hekatan Struct**: el mismo muro con su cáscara usada como membrana, con el giro en el plano (Ibrahimbegović, Taylor y Wilson, 1990) y tensión plana con E' y ν'. Es otro elemento: por eso Struct no coincide en todas las cifras.
#hide
a_1 = round(100·(u_c0 - 0.0372081247)/0.0372081247, 6)
a_2 = round(100·(u_c1 + 2.3739108692)/2.3739108692, 6)
a_3 = round(100·(q_p1 - 84.72973371)/84.72973371, 6)
a_4 = round(100·(q_t1 - 28.92792)/28.92792, 6)
a_5 = round(100·(q_t0 - 58.45284813)/58.45284813, 6)
b_1 = round(100·(0.0383037 - u_c0)/u_c0, 1)
b_2 = round(100·(-2.3687667 - u_c1)/abs(u_c1), 2)
b_3 = round(100·(84.7133 - q_p1)/q_p1, 2)
b_4 = round(100·(28.9162 - q_t1)/q_t1, 2)
b_5 = round(100·(58.4518 - q_t0)/q_t0, 2)
r_1 = round(u_c0, 10)
r_2 = round(u_c1, 10)
r_3 = round(q_p1, 8)
r_4 = round(q_t1, 8)
r_5 = round(q_t0, 8)
#show
#| | Esta hoja | SAP2000 | dif. [%] | Hekatan Struct | dif. [%] |
#|---|---:|---:|---:|---:|---:|
#| u_{x} coronación, estático [mm] | @{r_1} | 0.0372081247 | @{a_1} | 0.0383037 | @{b_1} |
#| u_{x} coronación, sismo [mm] | @{r_2} | −2.3739108692 | @{a_2} | −2.3687667 | @{b_2} |
#| presión en la puntera, sismo [kPa] | @{r_3} | 84.72973371 | @{a_3} | 84.7133 | @{b_3} |
#| presión en el talón, sismo [kPa] | @{r_4} | 28.92792 | @{a_4} | 28.9162 | @{b_4} |
#| presión en el talón, estático [kPa] | @{r_5} | 58.45284813 | @{a_5} | 58.4518 | @{b_5} |
#: Con SAP2000 la mayor diferencia en los 285 nudos es de 1.4·10⁻⁹ % del desplazamiento máximo (con sismo) y de 2·10⁻¹⁰ % (estático). Con Struct, de 0.22 %. En estático la coronación casi no se mueve (0.04 mm): el peso del relleno sobre el talón compensa el empuje, y ahí una diferencia de 0.001 mm ya es un 3 %.
#: El **sólido H8** de Struct (la misma sección extruida, 3135 nudos) da −2.3739 mm con sismo: igual que esta hoja. Es lógico: el hexaedro con modos incompatibles en deformación plana es el mismo cuadrilátero con modos incompatibles.
