# La masa para el sismo: de dónde sale, cómo se reparte a los nudos y qué cambia sin la masa vertical
#numerico

#: **Qué se explica.** El análisis modal necesita dos cosas: la rigidez K y la masa M. Esta hoja va solo de la **masa**: de dónde sale (la norma y el *Mass Source*), cómo se reparte a los nudos (barras, cáscaras, membrana y Deck) y qué pasa con los modos cuando se cuenta la masa en las tres direcciones (**masa 3D**, lo que hacen SAP2000 y Hekatan Struct) o **solo la horizontal** (lo que hace ETABS si no se toca nada).
#: **Lo que ya está hecho y no se repite aquí:** la hoja 60 (qué es un modo, diafragma y torsión), la 64 (la membrana del galpón y el *Mass Source* que escribe ETABS en el .e2k), la 102 (diafragma rígido contra flexible) y el vídeo del curso CSI «ETABS, masa de la losa: Shell Thin, Thick y Membrane». Al final, sus números entran en la tabla de comparación.
#: **Unidades.** tonf, m y s. La masa sale en **tonf·s²/m** (peso en tonf dividido por g en m/s²). Dentro de las fórmulas las unidades van en el texto de cada variable, no pegadas al nombre.

## 1 · De dónde sale la masa

#: La masa no se mide: se **calcula a partir del peso**. Es la segunda ley de Newton leída al revés, F = m·a con a = g:
#: m = W / g
#: **Qué peso W.** La NEC-15 lo define en **NEC-SE-DS §6.1.7 «Carga sísmica reactiva W»** (pág. 55 del capítulo; pág. 60 del PDF):

#| Caso (NEC-15, oficial) | Carga sísmica reactiva |
#|---|---|
#| Caso general | **W = D** (carga muerta total de la estructura) |
#| Bodegas y almacenaje | **W = D + 0.25·L_{i}** (L_{i}: carga viva del piso i) |

#: **Borrador NEC-SE-DS 2023 (12-09-23), no oficial.** Sí cambia: §6.1.3, ecuación 6.1 (pág. 23; pág. 83 del PDF), **W = W_{D} + x_{L}·W_{L}**, con x_{L} de su Tabla 6.1:

#| Ocupación (borrador, no oficial) | x_{L} |
#|---|---:|
#| Azoteas, marquesinas y techos | 0.00 |
#| Residencial, oficinas, hoteles, restaurantes | 0.15 |
#| Salud, educación | 0.25 |
#| Bodegas, archivos, almacenamiento | 0.25 |
#| Cines, teatros, centros comerciales, estacionamientos | 0.30 |

#: O sea: con la NEC-15 una vivienda **no lleva carga viva** en la masa; con el borrador, el 15 %.

### 1b · El *Mass Source*: masa de los elementos o masa desde las cargas

#: Los programas dan dos caminos, y se pueden sumar. Lo que importa es **no contar dos veces el peso propio**:

#| Camino | De dónde sale | Fórmula | Cuidado |
#|---|---|---|---|
#| **Masa de los elementos** | densidad de masa del material × volumen | ρ = γ / g | en ETABS **peso** y **masa** del material son dos casillas distintas |
#| **Masa desde las cargas** | patrones de carga × factor | D + x_{L}·L, dividido por g | si el peso propio ya entra por el material, el patrón «Dead» de peso propio **no** se vuelve a meter |

#: En Hekatan Struct el .heks guarda la **densidad de masa** (ρ en tonf·s²/m⁴, el peso ya dividido por g). Meter ahí el peso (2.4 en vez de 0.245) hace el modal 3.13 veces más lento (√9.81): ese error se encontró en 24 ejemplos y se corrigió (commit 853f8b85d de hekatan-struct).

#: **Los números de esta hoja** (los de la losa del modelo del apartado 4):
γ_c = 2.4 @@(peso unitario del hormigón armado, tonf/m³)
g = 9.80665 @@(aceleración de la gravedad, m/s²)
ρ_c = γ_c/g @@(densidad de MASA del hormigón: lo que pide el programa en «Mass per unit volume», tonf·s²/m⁴)
t_l = 0.20 @@(espesor de la losa, m)
q_D = 0.20 @@(carga muerta sobreimpuesta: acabados y mampostería repartida, tonf/m²)
q_L = 0.20 @@(carga viva de vivienda, tonf/m²)
x_L = 0.15 @@(fracción de carga viva del borrador para vivienda, Tabla 6.1, no oficial)
w_15 = γ_c*t_l + q_D @@(peso sísmico por m² de losa con la NEC-15, caso general W = D, tonf/m²)
w_23 = γ_c*t_l + q_D + x_L*q_L @@(peso sísmico por m² con el borrador, W = W_D + x_L·W_L, tonf/m²)
μ_15 = w_15/g @@(masa por m² de losa con la NEC-15, tonf·s²/m³)
μ_23 = w_23/g @@(masa por m² de losa con el borrador, tonf·s²/m³)

#: La masa por m² es una **recta en x_{L}**, del tipo y = m·x + b: la ordenada b es la carga muerta (lo que siempre está) y la pendiente m es la carga viva dividida por g. En el eje horizontal x_{L} de 0 a 0.30, en el vertical la masa por m² (tonf·s²/m³):
#fplot((0.48 + 0.20 + x*0.20)/9.80665, [0 0.3])
#: Del 0 (NEC-15, vivienda) al 0.15 (borrador) la masa sube un 4.4 %, y el periodo con su raíz cuadrada: un 2.2 %.

## 2 · Cómo se reparte la masa a los nudos

#: El programa no trabaja con una masa repartida: la **concentra en los nudos** (masa *lumped*, «agrupada»). Cada elemento entrega su masa a sus propios nudos, y la de un nudo es la suma de lo que le dan los elementos que llegan a él.

### 2a · Barra: mitad y mitad

#: Una viga o columna de sección A y largo L pesa γ·A·L. Su masa, ρ·A·L, se parte en **dos mitades iguales**, una a cada extremo:
#: m_{i} = m_{j} = ρ·A·L / 2
b_v = 0.30 @@(ancho de la viga, m)
h_v = 0.50 @@(peralte de la viga, m)
A_v = b_v*h_v @@(área de la viga, m²)
b_c = 0.40 @@(lado de la columna cuadrada, m)
A_c = b_c^2 @@(área de la columna, m²)
H = 3 @@(altura del piso, m)
m_vx = ρ_c*A_v*3/2 @@(masa que entrega una viga de 3 m a CADA uno de sus dos nudos, tonf·s²/m)
m_vy = ρ_c*A_v*2/2 @@(masa que entrega una viga de 2 m a cada nudo, tonf·s²/m)
m_co = ρ_c*A_c*H/2 @@(masa que entrega una columna a cada extremo, tonf·s²/m)
#: **La mitad de abajo de la columna va al apoyo.** Un nudo empotrado no se mueve, así que esa masa **no vibra** y no aparece en la participación modal: por eso la masa «total» de los programas es mayor que la «participante».
#: Así lo hace Hekatan Struct: lumpedMass en examples/src/shared/ritzModal.ts (líneas 21-45), me = rho·A·L/2 a cada extremo de la barra.

### 2b · Cáscara de 4 nudos (Q4): ρ·t·∫N dA

#: La masa de una cáscara es ρ·t por su área. A cada nudo le toca lo que pesa **su función de forma** N_{i} (la que vale 1 en ese nudo y 0 en los otros tres):
#: m_{i} = ρ·t·∫ N_{i} dA
#: En un rectángulo de lados a y b, con las coordenadas naturales ξ, η de −1 a 1, N_{1} = (1 − ξ)·(1 − η)/4 y dA = (a·b/4)·dξ·dη. La función de forma del nudo 1, dibujada: vale 1 en la esquina (−1, −1) y 0 en las otras tres.
#surf((1-x)*(1-y)/4, [-1 1], [-1 1])
#: El volumen bajo esa superficie es exactamente **la cuarta parte** del cuadrado. El motor lo integra:
#hide
I_N = integral2(@(ξ, η) (1 - ξ)*(1 - η)/4, -1, 1, -1, 1)/4 @@(fracción del área que le toca al nudo 1: ∫N₁ dA dividido entre el área, que en coordenadas naturales es 4)
r_IN = round(I_N, 4) @@(la misma fracción, redondeada)
#show
#: ∫∫ N₁ dξ dη / 4 = **@{r_IN}**
#: **Un cuarto a cada nudo** en un rectángulo (y en cualquier paralelogramo). Entonces, en una malla regular:

#| Nudo | Elementos que llegan | Masa que recibe |
#|---|---:|---|
#| Interior | 4 | 4/4 = la de un elemento entero |
#| De borde | 2 | 2/4 = medio elemento |
#| De esquina | 1 | 1/4 = un cuarto de elemento |

#: **En un trapecio ya no son cuartos.** Medido en SAP2000 24 (commit 96e1a020d de hekatan-struct, script del trapecio en cli): un trapecio que pesa 2.88 t reparte **0.80 / 0.80 / 0.64 / 0.64 t**, no 0.72 × 4. El lado largo se lleva más. Hekatan Struct calcula ρ·t·∫N dA en el motor (getGlobalMassMatrix.cpp) igual que SAP2000.

### 2c · Membrana y Deck: la masa tiene que llegar a algo que la sostenga

#: Una **membrana** no tiene rigidez fuera de su plano (hoja 64). Si se malla y sus nudos interiores **no están sobre una viga**, esos nudos tienen masa vertical y **ninguna rigidez vertical**. Es el problema del apartado 3.
#: Un **Deck** (o una membrana con reparto en una dirección, ONEWAYLOADDIST) no se malla nudo a nudo: su carga y su masa **pasan a las vigas o correas** por área tributaria, w = q·s (hoja 64). Los nudos que quedan son los de las vigas, y esos sí tienen rigidez.

### 2d · El reparto, en el modelo de esta hoja

#: Una planta de **6 m × 4 m** con una losa de 20 cm partida en **2 × 2 cáscaras** de 3 m × 2 m, **4 columnas** de 40 × 40 cm y 3 m de alto en las esquinas, y **vigas** de 30 × 50 cm en los bordes y en los dos ejes centrales. Así **cada nudo de la losa está sobre una viga**: ninguno queda sin rigidez vertical. Nueve nudos arriba (1 a 9, por columnas de x) y cuatro apoyos (10 a 13).
#: Barras: vigas en x 1-4, 4-7, 2-5, 5-8, 3-6, 6-9; vigas en y 1-2, 2-3, 4-5, 5-6, 7-8, 8-9; columnas 10-1, 11-3, 12-7, 13-9. Las coordenadas de los nudos de arriba están en la tabla de masas, más abajo; los apoyos están debajo de las esquinas, en z = 0.
#hide
X_n = [0, 0, 3; 0, 2, 3; 0, 4, 3; 3, 0, 3; 3, 2, 3; 3, 4, 3; 6, 0, 3; 6, 2, 3; 6, 4, 3; 0, 0, 0; 0, 4, 0; 6, 0, 0; 6, 4, 0] @@(coordenadas x, y, z de los 13 nudos, m)
e_n = [1, 4; 4, 7; 2, 5; 5, 8; 3, 6; 6, 9; 1, 2; 2, 3; 4, 5; 5, 6; 7, 8; 8, 9; 10, 1; 11, 3; 12, 7; 13, 9] @@(barras: nudo inicial y final; 1-6 vigas en x, 7-12 vigas en y, 13-16 columnas)
#show
s_q = [1, 4, 5, 2; 2, 5, 6, 3; 4, 7, 8, 5; 5, 8, 9, 6] @@(las 4 cáscaras de la losa, nudos en sentido antihorario)
#: La masa de **una cáscara** de la losa, con su carga muerta sobreimpuesta (el *Mass Source* de la NEC-15: elementos + D):
m_q = (ρ_c*t_l + q_D/g)*3*2 @@(masa de una cáscara de 3 m × 2 m: losa más acabados, tonf·s²/m)
#: Y el reparto: cada barra entrega la mitad a cada extremo, cada cáscara un cuarto a cada uno de sus cuatro nudos.
#: m_{nudo} = Σ (ρ·A·L/2 de cada barra que llega) + Σ (m_{q}/4 de cada cáscara que llega)
#hide
m_n = zeros(13, 1)
for e = 1:16
  a = e_n(e, 1)
  b = e_n(e, 2)
  L = norm(X_n(b, :) - X_n(a, :))
  A_e = A_v
  if e > 12
    A_e = A_c
  end
  m_n(a) = m_n(a) + ρ_c*A_e*L/2
  m_n(b) = m_n(b) + ρ_c*A_e*L/2
end
for q = 1:4
  for k = 1:4
    m_n(s_q(q, k)) = m_n(s_q(q, k)) + m_q/4
  end
end
#show
#hide
M_vib = 0
M_apo = 0
for j = 1:9
  M_vib = M_vib + m_n(j)
end
for j = 10:13
  M_apo = M_apo + m_n(j)
end
r_cen = round(m_n(5), 4)
r_esq = round(m_n(1), 4)
r_bx = round(m_n(4), 4)
r_by = round(m_n(2), 4)
r_vib = round(M_vib, 4)
r_apo = round(M_apo, 4)
r_W = round((M_vib + M_apo)*g, 3)
rm1 = round(m_n(1), 4) @@(masa del nudo 1, tonf·s²/m)
rm2 = round(m_n(2), 4) @@(masa del nudo 2, tonf·s²/m)
rm3 = round(m_n(3), 4) @@(masa del nudo 3, tonf·s²/m)
rm4 = round(m_n(4), 4) @@(masa del nudo 4, tonf·s²/m)
rm5 = round(m_n(5), 4) @@(masa del nudo 5, tonf·s²/m)
rm6 = round(m_n(6), 4) @@(masa del nudo 6, tonf·s²/m)
rm7 = round(m_n(7), 4) @@(masa del nudo 7, tonf·s²/m)
rm8 = round(m_n(8), 4) @@(masa del nudo 8, tonf·s²/m)
rm9 = round(m_n(9), 4) @@(masa del nudo 9, tonf·s²/m)
rm10 = round(m_n(10), 4) @@(masa del nudo 10, tonf·s²/m)
rm11 = round(m_n(11), 4) @@(masa del nudo 11, tonf·s²/m)
rm12 = round(m_n(12), 4) @@(masa del nudo 12, tonf·s²/m)
rm13 = round(m_n(13), 4) @@(masa del nudo 13, tonf·s²/m)
#show
#: La masa de cada nudo, en tonf·s²/m:
#| Nudo | x [m] | y [m] | Dónde está | Masa [tonf·s²/m] |
#|---:|---:|---:|---|---:|
#| 1 | 0 | 0 | esquina, sobre columna | @{rm1} |
#| 2 | 0 | 2 | borde corto, viga central | @{rm2} |
#| 3 | 0 | 4 | esquina, sobre columna | @{rm3} |
#| 4 | 3 | 0 | borde largo, viga central | @{rm4} |
#| 5 | 3 | 2 | **centro** | **@{rm5}** |
#| 6 | 3 | 4 | borde largo, viga central | @{rm6} |
#| 7 | 6 | 0 | esquina, sobre columna | @{rm7} |
#| 8 | 6 | 2 | borde corto, viga central | @{rm8} |
#| 9 | 6 | 4 | esquina, sobre columna | @{rm9} |
#| 10 a 13 | — | — | apoyos (mitad de abajo de cada columna) | @{rm10} cada uno |
#: **Lectura.** El nudo central (5) junta cuatro cuartos de losa y cuatro medias vigas: @{r_cen}. Una esquina (1) solo un cuarto de losa, dos medias vigas y media columna: @{r_esq}. Los de borde quedan entre medias (@{r_bx} en el borde largo, @{r_by} en el corto). Los nueve nudos que vibran suman **@{r_vib} tonf·s²/m**; los apoyos se quedan @{r_apo}. Peso total: @{r_W} tonf.
#: **La masa de cada nudo, en 3D.** La losa está pintada con la masa de sus nudos (rojo = más masa); pasa el cursor para leer el valor:
#hide
masa_nudo = m_n
sin_diagrama = zeros(16, 2)
#show
#modelo3d(X_n, s_q, e_n, masa_nudo, sin_diagrama)
#: Se ve el reparto: el centro pesa más del doble que una esquina. Ahí está la losa que la rodea.

## 3 · La matriz de masa: tres números por nudo

#: Cada nudo tiene seis grados de libertad (u_{x}, u_{y}, u_{z}, θ_{x}, θ_{y}, θ_{z}). La masa concentrada es **diagonal**: la misma masa en las tres traslaciones, y nada en los giros (un punto no tiene inercia de giro):
#: M_{nudo} = diag(m, m, m, 0, 0, 0)        masa 3D (SAP2000, Hekatan Struct)
#: M_{nudo} = diag(m, m, 0, 0, 0, 0)        solo horizontal (ETABS por defecto: INCLUDEVERTICALMASS "No")
#: Hekatan Struct tiene las dos: lumpedMass(…, lateralOnly) en ritzModal.ts; con lateralOnly = true hace m[2] = 0 (línea 43), la masa vertical fuera, como ETABS.

### 3a · Sin masa vertical no hay modos verticales

#: El modo sale de K·φ = ω²·M·φ. Si en la dirección vertical la masa es **cero**, esa fila dice K·φ = 0: no hay inercia que oponga, y el desplazamiento vertical **se ajusta solo, al instante**, a lo que haga el resto. Se elimina por **condensación estática**, igual que los giros:
#: K̂ = K_{tt} − K_{tr}·K_{rr}⁻¹·K_{rt}
#: donde t son los grados **con masa** y r los que no tienen. Con masa 3D quedan 3 por nudo (27 modos); con solo horizontal, 2 por nudo (**18 modos**): los modos verticales **no existen**, no es que salgan con poca participación.

### 3b · Masa vertical sin rigidez vertical: periodos absurdos

#: Es lo contrario: una **membrana mallada** cuyos nudos interiores no caen sobre una viga. Tienen masa vertical m pero rigidez vertical k ≈ 0 (solo el ruido numérico). El periodo de ese nudo sale de un oscilador de un grado:
#: T = 2·π·√(m / k)
m_1 = 0.6 @@(masa vertical de un nudo interior de losa, como el nudo 5 de este modelo, tonf·s²/m)
k_1 = 0.0000176 @@(rigidez vertical residual de un nudo de membrana, la que da 1160 s, tonf/m)
T_abs = 2*pi*sqrt(m_1/k_1) @@(periodo de ese nudo, s: el de ETABS con la losa Membrane mallada)
#: Con k → 0 el periodo se dispara. En el eje horizontal la rigidez vertical del nudo (de 0.00001 a 0.01 tonf/m), en el vertical su periodo en segundos:
#fplot(2*pi*sqrt(0.6/x), [0.00001 0.01])
#: Medido en el vídeo del curso CSI con la losa Membrane mallada: **ETABS 1160 s**, **SAP2000 cinco millones de segundos** (su rigidez residual es todavía menor). No es un modo de la estructura: es un nudo suelto. Hekatan Struct **quita** esos nudos y avisa cuánta carga no llega a la base. La solución en el modelo: Deck, o reparto en una dirección a las vigas (apartado 2c).

## 4 · Un modelo pequeño, resuelto: masa 3D contra solo horizontal

### 4a · La rigidez

#: Hormigón f'c = 210 kgf/cm², E = 15100·√f'c (en kgf/cm²), pasado a tonf/m² multiplicando por 10:
E = 15100*sqrt(210)*10 @@(módulo de elasticidad del hormigón, tonf/m²)
ν = 0.2 @@(coeficiente de Poisson del hormigón)
G_m = E/(2*(1 + ν)) @@(módulo de corte, tonf/m²)
I_vs = b_v*h_v^3/12 @@(inercia fuerte de la viga: flexión vertical, m⁴)
I_vd = h_v*b_v^3/12 @@(inercia débil de la viga: flexión horizontal, m⁴)
J_v = h_v*b_v^3*(1/3 - 0.21*b_v/h_v*(1 - b_v^4/(12*h_v^4))) @@(constante de torsión de Saint-Venant de la viga, m⁴)
I_c = b_c^4/12 @@(inercia de la columna, igual en los dos ejes, m⁴)
J_c = b_c^4*(1/3 - 0.21*(1 - 1/12)) @@(constante de torsión de la columna cuadrada, m⁴)
#: Cada barra es un pórtico 3D de 12 grados (Euler-Bernoulli, sin deformación por cortante). La flexión en cada plano es el bloque clásico de 4 × 4, con c = E·I:
k_f(c, L) = c*[12/L^3, 6/L^2, -12/L^3, 6/L^2; 6/L^2, 4/L, -6/L^2, 2/L; -12/L^3, -6/L^2, 12/L^3, -6/L^2; 6/L^2, 2/L, -6/L^2, 4/L] @@(flexión en el plano x'-y' local: giro alrededor de z', c = E por la inercia débil o la de la columna)
k_g(c, L) = c*[12/L^3, -6/L^2, -12/L^3, -6/L^2; -6/L^2, 4/L, 6/L^2, 2/L; -12/L^3, 6/L^2, 12/L^3, 6/L^2; -6/L^2, 2/L, 6/L^2, 4/L] @@(flexión en el plano x'-z' local: giro alrededor de y', c = E por la inercia fuerte o la de la columna)
#: k_{f} es la flexión en el plano x'-y' local (giro alrededor de z'), k_{g} en el plano x'-z' (giro alrededor de y', con el signo cambiado). Más el axil E·A/L y la torsión G·J/L. Cada barra se gira a ejes globales con su matriz de cosenos directores λ y se **suma** en K: K = Σ Tᵀ·k·T.
λ_x = [1, 0, 0; 0, 1, 0; 0, 0, 1] @@(viga en x: x' = X, y' = Y, z' = Z)
λ_y = [0, 1, 0; -1, 0, 0; 0, 0, 1] @@(viga en y: x' = Y, y' = −X, z' = Z)
λ_z = [0, 0, 1; 1, 0, 0; 0, 1, 0] @@(columna: x' = Z, y' = X, z' = Y)
#hide
K = zeros(78, 78)
for e = 1:16
  a = e_n(e, 1)
  b = e_n(e, 2)
  L = norm(X_n(b, :) - X_n(a, :))
  if e <= 6
    lam = λ_x
  elseif e <= 12
    lam = λ_y
  else
    lam = λ_z
  end
  if e <= 12
    A_e = A_v
    I_y = I_vs
    I_z = I_vd
    J_e = J_v
  else
    A_e = A_c
    I_y = I_c
    I_z = I_c
    J_e = J_c
  end
  k_l = zeros(12, 12)
  k_l([1, 7], [1, 7]) = E*A_e/L*[1, -1; -1, 1]
  k_l([4, 10], [4, 10]) = G_m*J_e/L*[1, -1; -1, 1]
  k_l([2, 6, 8, 12], [2, 6, 8, 12]) = k_f(E*I_z, L)
  k_l([3, 5, 9, 11], [3, 5, 9, 11]) = k_g(E*I_y, L)
  T_e = zeros(12, 12)
  for s = 0:3
    T_e([3*s + 1, 3*s + 2, 3*s + 3], [3*s + 1, 3*s + 2, 3*s + 3]) = lam
  end
  k_e = transpose(T_e)*k_l*T_e
  gd = [6*a - 5, 6*a - 4, 6*a - 3, 6*a - 2, 6*a - 1, 6*a, 6*b - 5, 6*b - 4, 6*b - 3, 6*b - 2, 6*b - 1, 6*b]
  K(gd, gd) = K(gd, gd) + k_e
end
#show
#: Los apoyos (nudos 10 a 13) están empotrados: quedan los 54 grados de los nueve nudos de arriba. La rigidez **es la misma** en los dos casos; lo único que cambia es la masa.

### 4b · Masa 3D (como SAP2000 y Hekatan Struct)

#: Grados con masa: u_{x}, u_{y}, u_{z} de los 9 nudos (27). Los giros se condensan. Para resolver K̂·φ = ω²·M·φ con M diagonal se hace el cambio φ = M^{−1/2}·v, que deja un problema simétrico normal, (M^{−1/2}·K̂·M^{−1/2})·v = ω²·v, y se resuelve por **rotaciones de Jacobi** (se anulan uno a uno los términos fuera de la diagonal; lo que queda en la diagonal son los ω²).
#: **Participación de masa** del modo φ en la dirección r (φ normalizado con φᵀ·M·φ = 1):
#: Γ = φᵀ·M·r        y        participación = Γ² / (rᵀ·M·r)
#: Para U_{x}, U_{y}, U_{z}, r vale 1 en esa traslación. Para los giros R_{x}, R_{y}, R_{z}, r es el desplazamiento que produce un giro unidad **alrededor del origen (0, 0, 0)**, como en SAP2000: por ejemplo R_{z} da u_{x} = −y, u_{y} = x. (Hekatan Struct lo hace igual: commit d7492031b, R_{x} y R_{y} = SAP2000 y ETABS a 4 decimales en la bóveda.) Por eso R_{x} y R_{y} recogen la masa por su brazo z (y la vertical por su brazo en planta).
#hide
t_a = zeros(27, 1)
r_a = zeros(27, 1)
i_t = 0
i_r = 0
for j = 1:9
  for d = 1:6
    if d <= 3
      i_t = i_t + 1
      t_a(i_t) = 6*(j - 1) + d
    else
      i_r = i_r + 1
      r_a(i_r) = 6*(j - 1) + d
    end
  end
end
m_a = zeros(27, 1)
R_a = zeros(27, 6)
for i = 1:27
  j = floor((t_a(i) - 1)/6) + 1
  d = t_a(i) - 6*(j - 1)
  m_a(i) = m_n(j)
  x = X_n(j, 1)
  y = X_n(j, 2)
  z = X_n(j, 3)
  if d == 1
    R_a(i, 1) = 1
    R_a(i, 5) = z
    R_a(i, 6) = -y
  end
  if d == 2
    R_a(i, 2) = 1
    R_a(i, 4) = -z
    R_a(i, 6) = x
  end
  if d == 3
    R_a(i, 3) = 1
    R_a(i, 4) = y
    R_a(i, 5) = -x
  end
end
S_a = K(r_a, r_a)\K(r_a, t_a)
Kc_a = K(t_a, t_a) - K(t_a, r_a)*S_a
D_a = zeros(27, 27)
for i = 1:27
  D_a(i, i) = 1/sqrt(m_a(i))
end
A = D_a*Kc_a*D_a
V = eye(27)
t_am = 1:27
for w = 1:14
  for p = 1:26
    for q = p + 1:27
      if abs(A(p, q)) > 1e-13*sqrt(abs(A(p, p)*A(q, q)))
        th = (A(q, q) - A(p, p))/(2*A(p, q))
        if th >= 0
          tg = 1/(th + sqrt(th^2 + 1))
        else
          tg = -1/(-th + sqrt(th^2 + 1))
        end
        cs = 1/sqrt(tg^2 + 1)
        sn = tg*cs
        gq = [p, q]
        Rr = [cs, sn; -sn, cs]
        A(t_am, gq) = A(t_am, gq)*Rr
        A(gq, t_am) = transpose(Rr)*A(gq, t_am)
        V(t_am, gq) = V(t_am, gq)*Rr
      end
    end
  end
end
w2_a = zeros(27, 1)
for i = 1:27
  w2_a(i) = A(i, i)
end
for i = 1:26
  k = i
  for j = i + 1:27
    if w2_a(j) < w2_a(k)
      k = j
    end
  end
  if k > i
    aux = w2_a(i)
    w2_a(i) = w2_a(k)
    w2_a(k) = aux
    V(t_am, [i, k]) = V(t_am, [k, i])
  end
end
F_a = D_a*V
T_a = zeros(27, 1)
for i = 1:27
  T_a(i) = 2*pi/sqrt(w2_a(i))
end
Mr_a = zeros(6, 1)
for d = 1:6
  for i = 1:27
    Mr_a(d) = Mr_a(d) + m_a(i)*R_a(i, d)^2
  end
end
P_a = zeros(27, 6)
for k = 1:27
  for d = 1:6
    Gm = 0
    for i = 1:27
      Gm = Gm + F_a(i, k)*m_a(i)*R_a(i, d)
    end
    if Mr_a(d) > 0
      P_a(k, d) = Gm^2/Mr_a(d)
    end
  end
end
#show
T_a @@(periodos de los 27 modos con masa 3D, s)

### 4c · Solo masa horizontal (como ETABS por defecto)

#: Lo mismo con m_{z} = 0: ahora los u_{z} también se condensan, quedan 18 grados con masa y **18 modos**.
#hide
t_b = zeros(18, 1)
r_b = zeros(36, 1)
i_t = 0
i_r = 0
for j = 1:9
  for d = 1:6
    if d <= 2
      i_t = i_t + 1
      t_b(i_t) = 6*(j - 1) + d
    else
      i_r = i_r + 1
      r_b(i_r) = 6*(j - 1) + d
    end
  end
end
m_b = zeros(18, 1)
R_b = zeros(18, 6)
for i = 1:18
  j = floor((t_b(i) - 1)/6) + 1
  d = t_b(i) - 6*(j - 1)
  m_b(i) = m_n(j)
  x = X_n(j, 1)
  y = X_n(j, 2)
  z = X_n(j, 3)
  if d == 1
    R_b(i, 1) = 1
    R_b(i, 5) = z
    R_b(i, 6) = -y
  end
  if d == 2
    R_b(i, 2) = 1
    R_b(i, 4) = -z
    R_b(i, 6) = x
  end
  if d == 3
    R_b(i, 3) = 1
    R_b(i, 4) = y
    R_b(i, 5) = -x
  end
end
S_b = K(r_b, r_b)\K(r_b, t_b)
Kc_b = K(t_b, t_b) - K(t_b, r_b)*S_b
D_b = zeros(18, 18)
for i = 1:18
  D_b(i, i) = 1/sqrt(m_b(i))
end
A = D_b*Kc_b*D_b
V = eye(18)
t_bm = 1:18
for w = 1:14
  for p = 1:17
    for q = p + 1:18
      if abs(A(p, q)) > 1e-13*sqrt(abs(A(p, p)*A(q, q)))
        th = (A(q, q) - A(p, p))/(2*A(p, q))
        if th >= 0
          tg = 1/(th + sqrt(th^2 + 1))
        else
          tg = -1/(-th + sqrt(th^2 + 1))
        end
        cs = 1/sqrt(tg^2 + 1)
        sn = tg*cs
        gq = [p, q]
        Rr = [cs, sn; -sn, cs]
        A(t_bm, gq) = A(t_bm, gq)*Rr
        A(gq, t_bm) = transpose(Rr)*A(gq, t_bm)
        V(t_bm, gq) = V(t_bm, gq)*Rr
      end
    end
  end
end
w2_b = zeros(18, 1)
for i = 1:18
  w2_b(i) = A(i, i)
end
for i = 1:17
  k = i
  for j = i + 1:18
    if w2_b(j) < w2_b(k)
      k = j
    end
  end
  if k > i
    aux = w2_b(i)
    w2_b(i) = w2_b(k)
    w2_b(k) = aux
    V(t_bm, [i, k]) = V(t_bm, [k, i])
  end
end
F_b = D_b*V
T_b = zeros(18, 1)
for i = 1:18
  T_b(i) = 2*pi/sqrt(w2_b(i))
end
Mr_b = zeros(6, 1)
for d = 1:6
  for i = 1:18
    Mr_b(d) = Mr_b(d) + m_b(i)*R_b(i, d)^2
  end
end
P_b = zeros(18, 6)
for k = 1:18
  for d = 1:6
    Gm = 0
    for i = 1:18
      Gm = Gm + F_b(i, k)*m_b(i)*R_b(i, d)
    end
    if Mr_b(d) > 0
      P_b(k, d) = Gm^2/Mr_b(d)
    end
  end
end
#show
T_b @@(periodos de los 18 modos con solo masa horizontal, s)

### 4d · Las participaciones, en las seis direcciones

#hide
Ta1 = round(T_a(1), 4)
pa1ux = round(100*P_a(1, 1), 2)
pa1uy = round(100*P_a(1, 2), 2)
pa1uz = round(100*P_a(1, 3), 2)
pa1rx = round(100*P_a(1, 4), 2)
pa1ry = round(100*P_a(1, 5), 2)
pa1rz = round(100*P_a(1, 6), 2)
Ta2 = round(T_a(2), 4)
pa2ux = round(100*P_a(2, 1), 2)
pa2uy = round(100*P_a(2, 2), 2)
pa2uz = round(100*P_a(2, 3), 2)
pa2rx = round(100*P_a(2, 4), 2)
pa2ry = round(100*P_a(2, 5), 2)
pa2rz = round(100*P_a(2, 6), 2)
Ta3 = round(T_a(3), 4)
pa3ux = round(100*P_a(3, 1), 2)
pa3uy = round(100*P_a(3, 2), 2)
pa3uz = round(100*P_a(3, 3), 2)
pa3rx = round(100*P_a(3, 4), 2)
pa3ry = round(100*P_a(3, 5), 2)
pa3rz = round(100*P_a(3, 6), 2)
Ta4 = round(T_a(4), 4)
pa4ux = round(100*P_a(4, 1), 2)
pa4uy = round(100*P_a(4, 2), 2)
pa4uz = round(100*P_a(4, 3), 2)
pa4rx = round(100*P_a(4, 4), 2)
pa4ry = round(100*P_a(4, 5), 2)
pa4rz = round(100*P_a(4, 6), 2)
Ta5 = round(T_a(5), 4)
pa5ux = round(100*P_a(5, 1), 2)
pa5uy = round(100*P_a(5, 2), 2)
pa5uz = round(100*P_a(5, 3), 2)
pa5rx = round(100*P_a(5, 4), 2)
pa5ry = round(100*P_a(5, 5), 2)
pa5rz = round(100*P_a(5, 6), 2)
Ta6 = round(T_a(6), 4)
pa6ux = round(100*P_a(6, 1), 2)
pa6uy = round(100*P_a(6, 2), 2)
pa6uz = round(100*P_a(6, 3), 2)
pa6rx = round(100*P_a(6, 4), 2)
pa6ry = round(100*P_a(6, 5), 2)
pa6rz = round(100*P_a(6, 6), 2)
saux = round(100*(P_a(1, 1) + P_a(2, 1) + P_a(3, 1) + P_a(4, 1) + P_a(5, 1) + P_a(6, 1)), 2)
Saux = round(100*sum(P_a(t_am, 1)), 2)
sauy = round(100*(P_a(1, 2) + P_a(2, 2) + P_a(3, 2) + P_a(4, 2) + P_a(5, 2) + P_a(6, 2)), 2)
Sauy = round(100*sum(P_a(t_am, 2)), 2)
sauz = round(100*(P_a(1, 3) + P_a(2, 3) + P_a(3, 3) + P_a(4, 3) + P_a(5, 3) + P_a(6, 3)), 2)
Sauz = round(100*sum(P_a(t_am, 3)), 2)
sarx = round(100*(P_a(1, 4) + P_a(2, 4) + P_a(3, 4) + P_a(4, 4) + P_a(5, 4) + P_a(6, 4)), 2)
Sarx = round(100*sum(P_a(t_am, 4)), 2)
sary = round(100*(P_a(1, 5) + P_a(2, 5) + P_a(3, 5) + P_a(4, 5) + P_a(5, 5) + P_a(6, 5)), 2)
Sary = round(100*sum(P_a(t_am, 5)), 2)
sarz = round(100*(P_a(1, 6) + P_a(2, 6) + P_a(3, 6) + P_a(4, 6) + P_a(5, 6) + P_a(6, 6)), 2)
Sarz = round(100*sum(P_a(t_am, 6)), 2)
Tb1 = round(T_b(1), 4)
pb1ux = round(100*P_b(1, 1), 2)
pb1uy = round(100*P_b(1, 2), 2)
pb1uz = round(100*P_b(1, 3), 2)
pb1rx = round(100*P_b(1, 4), 2)
pb1ry = round(100*P_b(1, 5), 2)
pb1rz = round(100*P_b(1, 6), 2)
Tb2 = round(T_b(2), 4)
pb2ux = round(100*P_b(2, 1), 2)
pb2uy = round(100*P_b(2, 2), 2)
pb2uz = round(100*P_b(2, 3), 2)
pb2rx = round(100*P_b(2, 4), 2)
pb2ry = round(100*P_b(2, 5), 2)
pb2rz = round(100*P_b(2, 6), 2)
Tb3 = round(T_b(3), 4)
pb3ux = round(100*P_b(3, 1), 2)
pb3uy = round(100*P_b(3, 2), 2)
pb3uz = round(100*P_b(3, 3), 2)
pb3rx = round(100*P_b(3, 4), 2)
pb3ry = round(100*P_b(3, 5), 2)
pb3rz = round(100*P_b(3, 6), 2)
Tb4 = round(T_b(4), 4)
pb4ux = round(100*P_b(4, 1), 2)
pb4uy = round(100*P_b(4, 2), 2)
pb4uz = round(100*P_b(4, 3), 2)
pb4rx = round(100*P_b(4, 4), 2)
pb4ry = round(100*P_b(4, 5), 2)
pb4rz = round(100*P_b(4, 6), 2)
Tb5 = round(T_b(5), 4)
pb5ux = round(100*P_b(5, 1), 2)
pb5uy = round(100*P_b(5, 2), 2)
pb5uz = round(100*P_b(5, 3), 2)
pb5rx = round(100*P_b(5, 4), 2)
pb5ry = round(100*P_b(5, 5), 2)
pb5rz = round(100*P_b(5, 6), 2)
Tb6 = round(T_b(6), 4)
pb6ux = round(100*P_b(6, 1), 2)
pb6uy = round(100*P_b(6, 2), 2)
pb6uz = round(100*P_b(6, 3), 2)
pb6rx = round(100*P_b(6, 4), 2)
pb6ry = round(100*P_b(6, 5), 2)
pb6rz = round(100*P_b(6, 6), 2)
sbux = round(100*(P_b(1, 1) + P_b(2, 1) + P_b(3, 1) + P_b(4, 1) + P_b(5, 1) + P_b(6, 1)), 2)
Sbux = round(100*sum(P_b(t_bm, 1)), 2)
sbuy = round(100*(P_b(1, 2) + P_b(2, 2) + P_b(3, 2) + P_b(4, 2) + P_b(5, 2) + P_b(6, 2)), 2)
Sbuy = round(100*sum(P_b(t_bm, 2)), 2)
sbuz = round(100*(P_b(1, 3) + P_b(2, 3) + P_b(3, 3) + P_b(4, 3) + P_b(5, 3) + P_b(6, 3)), 2)
Sbuz = round(100*sum(P_b(t_bm, 3)), 2)
sbrx = round(100*(P_b(1, 4) + P_b(2, 4) + P_b(3, 4) + P_b(4, 4) + P_b(5, 4) + P_b(6, 4)), 2)
Sbrx = round(100*sum(P_b(t_bm, 4)), 2)
sbry = round(100*(P_b(1, 5) + P_b(2, 5) + P_b(3, 5) + P_b(4, 5) + P_b(5, 5) + P_b(6, 5)), 2)
Sbry = round(100*sum(P_b(t_bm, 5)), 2)
sbrz = round(100*(P_b(1, 6) + P_b(2, 6) + P_b(3, 6) + P_b(4, 6) + P_b(5, 6) + P_b(6, 6)), 2)
Sbrz = round(100*sum(P_b(t_bm, 6)), 2)
r_Mx = round(Mr_a(1), 4)
r_Mz = round(Mr_a(3), 4)
r_Rxa = round(Mr_a(4), 3)
r_Rxb = round(Mr_b(4), 3)
r_Rz = round(Mr_a(6), 3)
#show
#: **Masa 3D** (27 modos). Masa en cada dirección, rᵀ·M·r: U_{x} = U_{y} = U_{z} = @{r_Mx} tonf·s²/m; R_{x} = @{r_Rxa}, R_{z} = @{r_Rz} tonf·s²·m.
#| Modo | T [s] | U_{x} [%] | U_{y} [%] | U_{z} [%] | R_{x} [%] | R_{y} [%] | R_{z} [%] |
#|---:|---:|---:|---:|---:|---:|---:|---:|
#| 1 | @{Ta1} | @{pa1ux} | @{pa1uy} | @{pa1uz} | @{pa1rx} | @{pa1ry} | @{pa1rz} |
#| 2 | @{Ta2} | @{pa2ux} | @{pa2uy} | @{pa2uz} | @{pa2rx} | @{pa2ry} | @{pa2rz} |
#| 3 | @{Ta3} | @{pa3ux} | @{pa3uy} | @{pa3uz} | @{pa3rx} | @{pa3ry} | @{pa3rz} |
#| 4 | @{Ta4} | @{pa4ux} | @{pa4uy} | @{pa4uz} | @{pa4rx} | @{pa4ry} | @{pa4rz} |
#| 5 | @{Ta5} | @{pa5ux} | @{pa5uy} | @{pa5uz} | @{pa5rx} | @{pa5ry} | @{pa5rz} |
#| 6 | @{Ta6} | @{pa6ux} | @{pa6uy} | @{pa6uz} | @{pa6rx} | @{pa6ry} | @{pa6rz} |
#| **Σ modos 1-6** | | **@{saux}** | **@{sauy}** | **@{sauz}** | **@{sarx}** | **@{sary}** | **@{sarz}** |
#| **Σ todos los modos** | | **@{Saux}** | **@{Sauy}** | **@{Sauz}** | **@{Sarx}** | **@{Sary}** | **@{Sarz}** |

#: **Solo masa horizontal** (18 modos). U_{z} no tiene masa (rᵀ·M·r = 0: la columna queda en 0) y R_{x} baja a @{r_Rxb} tonf·s²·m, porque ya no cuenta la masa vertical por su brazo en planta.
#| Modo | T [s] | U_{x} [%] | U_{y} [%] | U_{z} [%] | R_{x} [%] | R_{y} [%] | R_{z} [%] |
#|---:|---:|---:|---:|---:|---:|---:|---:|
#| 1 | @{Tb1} | @{pb1ux} | @{pb1uy} | @{pb1uz} | @{pb1rx} | @{pb1ry} | @{pb1rz} |
#| 2 | @{Tb2} | @{pb2ux} | @{pb2uy} | @{pb2uz} | @{pb2rx} | @{pb2ry} | @{pb2rz} |
#| 3 | @{Tb3} | @{pb3ux} | @{pb3uy} | @{pb3uz} | @{pb3rx} | @{pb3ry} | @{pb3rz} |
#| 4 | @{Tb4} | @{pb4ux} | @{pb4uy} | @{pb4uz} | @{pb4rx} | @{pb4ry} | @{pb4rz} |
#| 5 | @{Tb5} | @{pb5ux} | @{pb5uy} | @{pb5uz} | @{pb5rx} | @{pb5ry} | @{pb5rz} |
#| 6 | @{Tb6} | @{pb6ux} | @{pb6uy} | @{pb6uz} | @{pb6rx} | @{pb6ry} | @{pb6rz} |
#| **Σ modos 1-6** | | **@{sbux}** | **@{sbuy}** | **@{sbuz}** | **@{sbrx}** | **@{sbry}** | **@{sbrz}** |
#| **Σ todos los modos** | | **@{Sbux}** | **@{Sbuy}** | **@{Sbuz}** | **@{Sbrx}** | **@{Sbry}** | **@{Sbrz}** |

#: **Lectura, modo a modo:**
#: • **Modos 1 a 3 iguales en los dos casos**: el 1 traslada en Y, el 2 en X y el 3 **gira** (R_{z}). La masa vertical no los toca porque en este pórtico casi no mueven nada en vertical.
#: • **El modo 4 con masa 3D es vertical** (U_{z} ≈ 51 %): la losa y las vigas centrales «botan». **Con solo masa horizontal ese modo no existe**, y el «modo 4» de ETABS es el modo 5 de SAP2000. Comparar «modo 4 contra modo 4» entre los dos programas es comparar dos modos distintos: así salió el −29.7 % del galpón (commit f8c187cba de hekatan-struct), que desapareció al encender la masa vertical de ETABS.
#: • **La suma en U_{z}** pasa de 100 % a nada, y **R_{x} y R_{y} cambian de valor** aunque los modos 1-3 sean los mismos: su masa de referencia rᵀ·M·r cambió. Las columnas U_{x}, U_{y} y R_{z} son las que se pueden comparar entre programas sin mirar el *Mass Source*.
#: • La NEC pide el **90 % de la masa** en cada dirección horizontal: aquí lo dan los dos primeros modos (más del 94 % y del 99 %).

### 4e · Las formas de los modos, en 3D

#: Cada forma está escalada a 1 en el nudo que más se mueve, y la losa pintada con lo que se mueve cada nudo. Se gira arrastrando.
#hide
u_f = zeros(54, 1)
u_f(t_a) = F_a(t_am, 1)
u_f(r_a) = -S_a*F_a(t_am, 1)
U_a1 = zeros(13, 3)
um = 0
for j = 1:9
  for d = 1:3
    U_a1(j, d) = u_f(6*(j - 1) + d)
    if abs(U_a1(j, d)) > um
      um = abs(U_a1(j, d))
    end
  end
end
forma_a1 = zeros(13, 1)
um = 0
for j = 1:9
  forma_a1(j) = sqrt(U_a1(j, 1)^2 + U_a1(j, 2)^2 + U_a1(j, 3)^2)
  if forma_a1(j) > um
    um = forma_a1(j)
  end
end
U_a1 = U_a1/um
forma_a1 = forma_a1/um
#show
#: **Modo 1** (traslación en Y), masa 3D:
#modelo3d(X_n, s_q, e_n, forma_a1, sin_diagrama, U_a1, 0.6)
#hide
u_f = zeros(54, 1)
u_f(t_a) = F_a(t_am, 2)
u_f(r_a) = -S_a*F_a(t_am, 2)
U_a2 = zeros(13, 3)
um = 0
for j = 1:9
  for d = 1:3
    U_a2(j, d) = u_f(6*(j - 1) + d)
    if abs(U_a2(j, d)) > um
      um = abs(U_a2(j, d))
    end
  end
end
forma_a2 = zeros(13, 1)
um = 0
for j = 1:9
  forma_a2(j) = sqrt(U_a2(j, 1)^2 + U_a2(j, 2)^2 + U_a2(j, 3)^2)
  if forma_a2(j) > um
    um = forma_a2(j)
  end
end
U_a2 = U_a2/um
forma_a2 = forma_a2/um
#show
#: **Modo 2** (traslación en X):
#modelo3d(X_n, s_q, e_n, forma_a2, sin_diagrama, U_a2, 0.6)
#hide
u_f = zeros(54, 1)
u_f(t_a) = F_a(t_am, 3)
u_f(r_a) = -S_a*F_a(t_am, 3)
U_a3 = zeros(13, 3)
um = 0
for j = 1:9
  for d = 1:3
    U_a3(j, d) = u_f(6*(j - 1) + d)
    if abs(U_a3(j, d)) > um
      um = abs(U_a3(j, d))
    end
  end
end
forma_a3 = zeros(13, 1)
um = 0
for j = 1:9
  forma_a3(j) = sqrt(U_a3(j, 1)^2 + U_a3(j, 2)^2 + U_a3(j, 3)^2)
  if forma_a3(j) > um
    um = forma_a3(j)
  end
end
U_a3 = U_a3/um
forma_a3 = forma_a3/um
#show
#: **Modo 3** (giro alrededor de Z, la torsión): las esquinas se mueven y el centro casi no.
#modelo3d(X_n, s_q, e_n, forma_a3, sin_diagrama, U_a3, 0.6)
#hide
u_f = zeros(54, 1)
u_f(t_a) = F_a(t_am, 4)
u_f(r_a) = -S_a*F_a(t_am, 4)
U_a4 = zeros(13, 3)
um = 0
for j = 1:9
  for d = 1:3
    U_a4(j, d) = u_f(6*(j - 1) + d)
    if abs(U_a4(j, d)) > um
      um = abs(U_a4(j, d))
    end
  end
end
forma_a4 = zeros(13, 1)
um = 0
for j = 1:9
  forma_a4(j) = sqrt(U_a4(j, 1)^2 + U_a4(j, 2)^2 + U_a4(j, 3)^2)
  if forma_a4(j) > um
    um = forma_a4(j)
  end
end
U_a4 = U_a4/um
forma_a4 = forma_a4/um
#show
#: **Modo 4, vertical: solo existe con masa 3D.** El centro de la losa baja y sube sobre las vigas centrales.
#modelo3d(X_n, s_q, e_n, forma_a4, sin_diagrama, U_a4, 0.6)

## 5 · Hekatan contra SAP2000 contra ETABS: los números que hay

#: Solo números **medidos**, con su fuente. Lo que no se ha corrido no se rellena.

#: **a) Pórtico con losa** (4 × 3 vanos, un piso, losa de 20 cm), el de los vídeos del curso CSI sobre la masa de la losa, exportado de Hekatan Struct a SAP2000 (s2k) y a ETABS (e2k):
#| Magnitud | Hekatan Struct | SAP2000 | ETABS |
#|---|---:|---:|---:|
#| masa total [tonf·s²/m] | 302.59 | 302.59 | — |
#| T₁, Shell-Thin, masa 3D [s] | 0.2330 | 0.233 | 0.233 |
#| T₄, modo vertical de la losa [s] | 0.0873 | — | 0.087 |
#| U_{z} del modo 4 | 8.6 % | 8.6 % | 8.6 % |
#| T₁, Shell-Thick [s] | 0.2321 | — | 0.232 |
#| T₁, Membrane mallada [s] | 0.2439 (¹) | ≈ 5 000 000 | 1160 |
#| T₁, Membrane sin masa vertical [s] | 0.2437 | — | 0.244 |
#: Fuente: tabla modal leída de Hekatan Struct en la grabación (curso CSI, carpeta masa de Struct) y subtítulos de los vídeos de SAP2000 y ETABS. (¹) Struct quita los nudos de membrana sin rigidez vertical y avisa. «—»: el vídeo no lo dice.

#: **b) Galpón curvo** (214 nudos, 443 barras, 100 chapas), diferencia contra Hekatan:
#| Magnitud | Hekatan | SAP2000 | ETABS sin masa vertical | ETABS con masa vertical |
#|---|---:|---:|---:|---:|
#| T₁ [s] | 0.331144 | −0.00 % | — | −0.02 % |
#| T₄ [s] | 0.172513 | −0.00 % | −29.7 % | −0.01 % |
#| ΣU_{z} | 38.445 % | — | 0 | 38.446 % |
#: Fuente: hekatan-struct, validation/opensees/README.md (16-sep-2026) y commit f8c187cba. El −29.7 % no es un error de ETABS: su «modo 4» era otro modo.

#: **c) Galpón de la bodega electoral** (masa = solo el peso propio del acero):
#| Magnitud | Hekatan Struct | SAP2000 | ETABS |
#|---|---:|---:|---:|
#| T₁ [s] | 0.4314 | 0.4314 | 0.4267 |
#: Fuente: medición del 2-ago-2026 (galpon-bodega-electoral, a_etabs.py con y sin --sap). Hekatan y SAP2000: los 12 modos iguales a 4 cifras. ETABS ~1 % distinto porque su masa es lateral y concentrada por piso.

#: **d) El modelo de esta hoja** (6 × 4 m, 2 × 2 cáscaras sobre vigas):
#| Magnitud | Hekatan LISP | SAP2000 | ETABS |
#|---|---:|---:|---:|
#| T₁, masa 3D [s] | @{Ta1} | pendiente | pendiente |
#| T₂ [s] | @{Ta2} | pendiente | pendiente |
#| T₃ [s] | @{Ta3} | pendiente | pendiente |
#| T₄, vertical [s] | @{Ta4} | pendiente | pendiente |
#| T₄, solo masa horizontal [s] | @{Tb4} | pendiente | pendiente |

#: **La regla que sale de la tabla:** antes de comparar periodos entre programas, mirar **el Mass Source** (qué masa, en qué direcciones, si se concentra por pisos). Con la misma masa, Hekatan, SAP2000 y ETABS dan lo mismo; con masa distinta, ninguno está mal y ninguno coincide.
#: **Comprobación de esta hoja (no es un juez):** los periodos y las participaciones de 4b y 4c se repitieron con numpy/scipy (scipy.linalg.eigh sobre la misma K y M condensadas) y coinciden a 4 decimales. El juez de verdad, SAP2000 con este mismo modelo nudo a nudo, está **pendiente**.

## 6 · Resumen

#| Pregunta | Respuesta corta |
#|---|---|
#| ¿De dónde sale la masa? | m = W/g; NEC-15: W = D (bodegas + 0.25 L); borrador: W = W_{D} + x_{L}·W_{L} |
#| ¿Elementos o cargas? | los dos se suman; el peso propio, una sola vez |
#| ¿Barra? | ρ·A·L/2 a cada extremo; la mitad de abajo de la columna se queda en el apoyo |
#| ¿Cáscara Q4? | ρ·t·∫N_{i} dA: cuartos en un rectángulo, no en un trapecio |
#| ¿Membrana o Deck? | la masa tiene que llegar a una viga; un nudo con masa y sin rigidez da periodos absurdos |
#| ¿Masa 3D o solo horizontal? | los modos laterales casi iguales; los verticales solo existen con masa 3D y corren la numeración |
