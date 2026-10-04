# Dinámica de estructuras, clase 2: varios grados de libertad — edificio de 3 pisos, modos, periodos y masa participativa
#numerico

#: **Qué se hace.** El pórtico de la clase 1 (hoja 108), ahora con **tres pisos**. Cada losa es una masa y cada entrepiso un resorte. Se arma M y K a mano, se resuelve det(K − ω²·M) = 0, se dibujan las tres formas de vibrar y se calcula cuánta masa mueve cada modo. Al final, el mismo edificio en 3D con sus **seis** direcciones de masa participativa.
#: **Fuentes.** Chopra, *Dinámica de Estructuras*, 4.ª ed.: ec. 10.2.4 y 10.2.6 (problema de valores propios), 13.1.5 (factor de participación Γ), §13.2.5 (masa modal efectiva). NEC-SE-DS 2015 §6.2.2 e, «Número de modos» (pág. 58).
#: **Unidades.** tonf, m, s (masa en tonf·s²/m); SI entre paréntesis donde se pide.

## 1 · El modelo: tres masas y tres resortes

#: Planta de 6 × 6 m, las mismas cuatro columnas de 40 × 50 cm por piso y 3 m de entrepiso (clase 1). Las losas se suponen rígidas: cada piso es **una masa que solo se traslada**. Es el **edificio de cortante**.
k_p = 8818.187592 'rigidez lateral de un entrepiso en X, de la clase 1: 4·12·E·0.8·I_g/h³ [tonf/m]
k_1 = k_p 'entrepiso 1 (base a piso 1) [tonf/m]
k_2 = k_p 'entrepiso 2 [tonf/m]
k_3 = k_p 'entrepiso 3 [tonf/m]
g = 9.80665 'gravedad [m/s²]
m_1 = 1.0·36/g 'piso 1: 1.0 tonf/m² sobre 36 m² [tonf·s²/m]
m_2 = 1.0·36/g 'piso 2 [tonf·s²/m]
m_3 = 0.8·36/g 'azotea: 0.8 tonf/m², sin tabiquería [tonf·s²/m]
m_t = m_1 + m_2 + m_3 'masa total [tonf·s²/m]
m_tSI = m_t·g·1000 'la misma en el SI [kg]

#dibujo("Edificio de cortante: cada losa es una masa, cada entrepiso un resorte", ud = m, alto = 150)
#  linea(-1, 0, 7, 0, "gruesa")
#  achurado(-1, -0.4, 8, 0.4, "diagonal")
#  linea(0, 0, 0, 9, "gruesa azul")
#  linea(6, 0, 6, 9, "gruesa azul")
#  rect(-0.2, 2.85, 6.4, 0.3, "gruesa")
#  rect(-0.2, 5.85, 6.4, 0.3, "gruesa")
#  rect(-0.2, 8.85, 6.4, 0.3, "gruesa")
#  texto(2.4, 3.4, "m₁, u₁", 3, "i")
#  texto(2.4, 6.4, "m₂, u₂", 3, "i")
#  texto(2.4, 9.4, "m₃, u₃", 3, "i")
#  texto(6.3, 1.4, "k₁", 3, "i")
#  texto(6.3, 4.4, "k₂", 3, "i")
#  texto(6.3, 7.4, "k₃", 3, "i")
#  flecha(6.6, 3.0, 7.6, 3.0, "rojo")
#  flecha(6.6, 6.0, 7.6, 6.0, "rojo")
#  flecha(6.6, 9.0, 7.6, 9.0, "rojo")
#  cota(-0.8, 0, -0.8, 9, -0.2, "3 × 3.00")
#fin

## 2 · Las ecuaciones del movimiento, deducidas

#: Se aísla cada losa y se aplica Newton, igual que en la clase 1. Al piso i lo jala el entrepiso de abajo con k_{i}·(u_{i} − u_{i−1}) y el de arriba con k_{i+1}·(u_{i+1} − u_{i}):
#: piso 1: m₁·ü₁ = −k₁·u₁ + k₂·(u₂ − u₁)
#: piso 2: m₂·ü₂ = −k₂·(u₂ − u₁) + k₃·(u₃ − u₂)
#: piso 3: m₃·ü₃ = −k₃·(u₃ − u₂)
#: Pasando todo a la izquierda y ordenando por u₁, u₂, u₃ sale la misma ecuación de la clase 1, ahora con **matrices**:
#: **M·ü + K·u = 0**
M = [m_1, 0, 0; 0, m_2, 0; 0, 0, m_3] 'matriz de masa: diagonal, cada losa con lo suyo [tonf·s²/m]
K = [k_1 + k_2, -k_2, 0; -k_2, k_2 + k_3, -k_3; 0, -k_3, k_3] 'matriz de rigidez: tridiagonal [tonf/m]
#: La fila i de K son las fuerzas sobre el piso i cuando se mueve una unidad cada piso. Por eso es simétrica y solo acopla vecinos.

## 3 · El problema de valores propios

#: Como en la clase 1 se prueba u(t) = φ·cos(ω·t): **todos los pisos vibran con la misma frecuencia y una forma fija φ**. La aceleración es −ω²·φ·cos(ω·t) y, sustituyendo (Chopra ec. 10.2.4):
#: **(K − ω²·M)·φ = 0**
#: Para que haya una forma φ distinta de cero, la matriz tiene que ser singular (Chopra ec. 10.2.6):
#: **det(K − λ·M) = 0**, con λ = ω²
#: Desarrollando el determinante por la primera fila (la tercera columna de la fila 1 es cero):
#: D(λ) = (k₁ + k₂ − λ·m₁)·[(k₂ + k₃ − λ·m₂)·(k₃ − λ·m₃) − k₃²] − k₂²·(k₃ − λ·m₃)
D(x) = (k_1 + k_2 - x·m_1)·((k_2 + k_3 - x·m_2)·(k_3 - x·m_3) - k_3^2) - k_2^2·(k_3 - x·m_3) 'el determinante como función de λ
D_0 = D(0) 'D(0) = det(K) [tonf³/m³]
#: Comprobación de que el desarrollo está bien: el determinante del motor con λ = 1000:
d_A = D(1000) 'desarrollo a mano con λ = 1000
d_B = det(K - 1000·M) 'det() del motor con λ = 1000
#: Dibujado (dividido por D(0) para que se lea): **cada cruce con cero es una frecuencia del edificio**. Hay tres porque hay tres pisos.
#fplot(D_rel = ((k_1 + k_2 - x*m_1)*((k_2 + k_3 - x*m_2)*(k_3 - x*m_3) - k_3^2) - k_2^2*(k_3 - x*m_3))/D_0, cero = 0*x, [0 9000])
#: Eje horizontal: λ = ω² en (rad/s)²; vertical: D(λ)/D(0).

## 4 · Las tres raíces

#: D(λ) es un polinomio de grado 3: D = c₃·λ³ + c₂·λ² + c₁·λ + c₀. Multiplicando el desarrollo término a término (con a = k₁ + k₂, b = k₂ + k₃, c = k₃):
a_k = k_1 + k_2 'a [tonf/m]
b_k = k_2 + k_3 'b [tonf/m]
c_k = k_3 'c [tonf/m]
c_3 = -m_1·m_2·m_3 'coeficiente de λ³
c_2 = a_k·m_2·m_3 + m_1·(b_k·m_3 + c_k·m_2) 'coeficiente de λ²
c_1 = -a_k·(b_k·m_3 + c_k·m_2) - m_1·(b_k·c_k - c_k^2) + k_2^2·m_3 'coeficiente de λ
c_0 = a_k·(b_k·c_k - c_k^2) - k_2^2·c_k 'término independiente (= D(0))
#: **La primera raíz por Newton**, arrancando en λ = 0 (como se haría con una calculadora): λ ← λ − D(λ)/D′(λ), con D′ = 3·c₃·λ² + 2·c₂·λ + c₁.
#hide
l_a = 0
#show
for i = 1:30
  l_a = l_a - (c_3·l_a^3 + c_2·l_a^2 + c_1·l_a + c_0)/(3·c_3·l_a^2 + 2·c_2·l_a + c_1)
end
lambda_1 = l_a 'primera raíz λ₁ = ω₁² [(rad/s)²]
r_1 = D(lambda_1)/D_0 'residuo relativo: tiene que dar ≈ 0
#: **Las otras dos sin iterar.** Si λ₁ es raíz, D(λ) = (λ − λ₁)·(q₂·λ² + q₁·λ + q₀) (división sintética), y la cuadrática se resuelve con la fórmula de siempre:
q_2 = c_3 'coeficiente de λ² del cociente
q_1 = c_2 + c_3·lambda_1 'coeficiente de λ del cociente
q_0 = c_1 + q_1·lambda_1 'término independiente del cociente
d_q = sqrt(q_1^2 - 4·q_2·q_0) 'raíz del discriminante
lambda_2 = min((-q_1 + d_q)/(2·q_2), (-q_1 - d_q)/(2·q_2)) 'segunda raíz λ₂ [(rad/s)²]
lambda_3 = max((-q_1 + d_q)/(2·q_2), (-q_1 - d_q)/(2·q_2)) 'tercera raíz λ₃ [(rad/s)²]
#: **Frecuencias y periodos** (ω = √λ, T = 2·π/ω):
omega_1 = sqrt(lambda_1) 'modo 1 [rad/s]
omega_2 = sqrt(lambda_2) 'modo 2 [rad/s]
omega_3 = sqrt(lambda_3) 'modo 3 [rad/s]
T_1 = 2·pi/omega_1 'periodo fundamental [s]
T_2 = 2·pi/omega_2 'periodo del modo 2 [s]
T_3 = 2·pi/omega_3 'periodo del modo 3 [s]
#: El de 1 piso daba 0.128 s; con 3 pisos el fundamental es **0.272 s**: más masa colgando de resortes en serie. Es un periodo corto porque se supuso la losa rígida (cota alta de k): las vigas reales flexan y lo alargan.

## 5 · Las formas de los modos

#: Con cada λ, (K − λ·M)·φ = 0 se resuelve fijando φ₁ = 1. La fila 1 da φ₂ y la fila 3 da φ₃:
#: φ₂ = (k₁ + k₂ − λ·m₁)/k₂ · φ₃ = k₃·φ₂/(k₃ − λ·m₃)
f_11 = 1 'modo 1, piso 1
f_21 = (k_1 + k_2 - lambda_1·m_1)/k_2 'modo 1, piso 2
f_31 = k_3·f_21/(k_3 - lambda_1·m_3) 'modo 1, piso 3 (azotea)
f_12 = 1 'modo 2, piso 1
f_22 = (k_1 + k_2 - lambda_2·m_1)/k_2 'modo 2, piso 2
f_32 = k_3·f_22/(k_3 - lambda_2·m_3) 'modo 2, piso 3
f_13 = 1 'modo 3, piso 1
f_23 = (k_1 + k_2 - lambda_3·m_1)/k_2 'modo 3, piso 2
f_33 = k_3·f_23/(k_3 - lambda_3·m_3) 'modo 3, piso 3
#: La fila 2 no se usó: tiene que cumplirse sola. Es la prueba de que λ es raíz:
e_1 = -k_2·f_11 + (k_2 + k_3 - lambda_1·m_2)·f_21 - k_3·f_31 'fila 2 con el modo 1: ≈ 0
#: Para dibujar se escalan a azotea = 1 (la forma importa, no el tamaño):
p_11 = f_11/f_31 'modo 1 dibujado, piso 1
p_21 = f_21/f_31 'modo 1 dibujado, piso 2
p_12 = f_12/f_32 'modo 2 dibujado, piso 1
p_22 = f_22/f_32 'modo 2 dibujado, piso 2
p_13 = f_13/f_33 'modo 3 dibujado, piso 1
p_23 = f_23/f_33 'modo 3 dibujado, piso 2

#dibujo("Los tres modos (azotea = 1). Modo 1: T = 0.2722 s · modo 2: T = 0.0987 s · modo 3: T = 0.0701 s", ud = m, alto = 150)
#  linea(0, 0, 0, 9, "trazos")
#  linea(6, 0, 6, 9, "trazos")
#  linea(12, 0, 12, 9, "trazos")
#  linea(-1, 0, 14, 0, "gruesa")
#  polilinea(0, 0, 1.5·p_11, 3, 1.5·p_21, 6, 1.5, 9, "gruesa azul")
#  polilinea(6, 0, 6 + 1.5·p_12, 3, 6 + 1.5·p_22, 6, 7.5, 9, "gruesa rojo")
#  polilinea(12, 0, 12 + 1.5·p_13, 3, 12 + 1.5·p_23, 6, 13.5, 9, "gruesa verde")
#  circulo(1.5·p_11, 3, 0.25, "azul relleno")
#  circulo(1.5·p_21, 6, 0.25, "azul relleno")
#  circulo(1.5, 9, 0.22, "azul relleno")
#  circulo(6 + 1.5·p_12, 3, 0.25, "rojo relleno")
#  circulo(6 + 1.5·p_22, 6, 0.25, "rojo relleno")
#  circulo(7.5, 9, 0.22, "rojo relleno")
#  circulo(12 + 1.5·p_13, 3, 0.25, "verde relleno")
#  circulo(12 + 1.5·p_23, 6, 0.25, "verde relleno")
#  circulo(13.5, 9, 0.22, "verde relleno")
#  texto(-0.6, 10.0, "modo 1", 3, "i")
#  texto(5.4, 10.0, "modo 2", 3, "i")
#  texto(11.4, 10.0, "modo 3", 3, "i")
#fin
#: **Cómo se leen.** El modo 1 va todo al mismo lado y crece con la altura: es el que manda. El modo 2 cruza una vez el eje (un piso quieto entre medio) y el 3 cruza dos. Cuantos más cruces, más corto el periodo.

## 6 · Cuánta masa mueve cada modo: Γ y masa efectiva

#: Un sismo empuja **todos los pisos a la vez en la misma dirección**: r = [1; 1; 1]. Cuánto de ese empuje toma el modo n lo dice su **factor de participación** (Chopra ec. 13.1.5):
#: **Γ_{n} = φ_{n}ᵀ·M·r / φ_{n}ᵀ·M·φ_{n} = L_{n}/M_{n}**
#: y la masa que se comporta como un oscilador de 1 grado (clase 1) con el periodo de ese modo es la **masa modal efectiva** (Chopra §13.2.5):
#: **M_{ef,n} = Γ_{n}²·M_{n} = L_{n}²/M_{n}**
L_1 = m_1·f_11 + m_2·f_21 + m_3·f_31 'φ₁ᵀ·M·r [tonf·s²/m]
M_1 = m_1·f_11^2 + m_2·f_21^2 + m_3·f_31^2 'φ₁ᵀ·M·φ₁, masa generalizada [tonf·s²/m]
L_2 = m_1·f_12 + m_2·f_22 + m_3·f_32 'φ₂ᵀ·M·r [tonf·s²/m]
M_2 = m_1·f_12^2 + m_2·f_22^2 + m_3·f_32^2 'φ₂ᵀ·M·φ₂ [tonf·s²/m]
L_3 = m_1·f_13 + m_2·f_23 + m_3·f_33 'φ₃ᵀ·M·r [tonf·s²/m]
M_3 = m_1·f_13^2 + m_2·f_23^2 + m_3·f_33^2 'φ₃ᵀ·M·φ₃ [tonf·s²/m]
G_1 = L_1/M_1 'Γ₁, factor de participación del modo 1
G_2 = L_2/M_2 'Γ₂
G_3 = L_3/M_3 'Γ₃
Me_1 = G_1^2·M_1 'masa efectiva del modo 1 [tonf·s²/m]
Me_2 = G_2^2·M_2 'masa efectiva del modo 2 [tonf·s²/m]
Me_3 = G_3^2·M_3 'masa efectiva del modo 3 [tonf·s²/m]
P_1 = 100·Me_1/m_t 'porcentaje de la masa total que mueve el modo 1 [%]
P_2 = 100·Me_2/m_t 'modo 2 [%]
P_3 = 100·Me_3/m_t 'modo 3 [%]
S_1 = P_1 'suma acumulada hasta el modo 1 [%]
S_2 = P_1 + P_2 'suma acumulada hasta el modo 2 [%]
S_3 = P_1 + P_2 + P_3 'suma con los tres modos: tiene que dar 100 [%]
#: Γ depende de cómo se escale φ (aquí φ₁ = 1); **M_{ef} no**: es una masa física. Por eso la regla de la NEC se mide en porcentaje de masa, no en Γ.
#: **La regla de la NEC-15** (NEC-SE-DS 2015, §6.2.2 e, «Procedimiento 1: análisis espectral → Número de modos», pág. 58), textual: se deben considerar *«todos los modos que involucren la participación de una masa modal acumulada de al menos el 90% de la masa total de la estructura, en cada una de las direcciones horizontales principales consideradas»*.
#: Aquí el modo 1 solo ya mueve el **91.85 %**: cumple con un modo. En edificios altos, o con torsión, hacen falta muchos más (cpp06: 12 modos y en Y aún faltaban).

## 7 · En 3D son seis direcciones

#: Un nudo de un modelo 3D tiene **seis** grados de libertad: tres traslaciones (U_{x}, U_{y}, U_{z}) y tres giros (R_{x}, R_{y}, R_{z}). Con **diafragma rígido** cada losa se reduce a tres: U_{x}, U_{y} y el giro R_{z} de la planta. Al giro se opone el **momento polar de masa** J = m·(a² + b²)/12 (planta a × b).
#: Este edificio es simétrico (centro de masa = centro de rigidez), así que las tres familias **no se acoplan** y cada una repite el problema de 3 pisos de arriba con su propia rigidez. Columna de 40 en X y 50 en Y: rigidez en Y mayor.
k_y = k_p·(0.5/0.4)^2 'entrepiso en Y: I crece con (50/40)² respecto a X [tonf/m]
k_c = k_p/4 'una columna en X [tonf/m]
k_cy = k_y/4 'una columna en Y [tonf/m]
K_t = 4·(k_c·3^2 + k_cy·3^2) 'rigidez a torsión del entrepiso: Σ k·d², columnas a 3 m del centro [tonf·m]
J_m = (6^2 + 6^2)/12 'J/m de una losa de 6 × 6 m [m²]
#: Como las rigideces de Y y de giro son proporcionales a las de X (mismo reparto por piso) y J = 6·m en todas las losas, las formas son **las mismas** y los λ se escalan:
T_y1 = T_1·sqrt(k_p/k_y) 'modo 1 de la familia Y [s]
T_r1 = T_1·sqrt(k_p·J_m/K_t) 'modo 1 de la familia de giro R_z [s]
#: Ordenando los nueve periodos de mayor a menor: **modo 1 = U_{x} (0.2722 s), modo 2 = U_{y} (0.2177 s), modo 3 = R_{z} (0.1388 s)**; después vienen los segundos modos de cada familia (0.0987, 0.0790, 0.0701, 0.0561, 0.0504, 0.0358 s). Traslación, traslación y giro: el orden sano (hoja 60).
#: **Las seis sumatorias.** Para los giros, el sismo «gira» la base alrededor del origen (centro de la planta, en la base): un piso a la altura z se mueve z por radián. Por eso un modo en X también aporta masa a R_{y} (con el brazo z) y uno en Y a R_{x}:
z_1 = 3 'altura del piso 1 [m]
z_2 = 6 'altura del piso 2 [m]
z_3 = 9 'altura de la azotea [m]
L_r1 = m_1·f_11·z_1 + m_2·f_21·z_2 + m_3·f_31·z_3 'φ₁ᵀ·M·r con r = z (giro de la base) [tonf·s²]
I_rb = m_1·z_1^2 + m_2·z_2^2 + m_3·z_3^2 'inercia total al giro de la base, Σ m·z² [tonf·s²·m]
P_r1 = 100·L_r1^2/(M_1·I_rb) 'R_y que aporta el modo 1 (= R_x del modo 2) [%]

#| Modo | T [s] | U_{x} | U_{y} | U_{z} | R_{x} | R_{y} | R_{z} |
#|---:|---:|---:|---:|---:|---:|---:|---:|
#| 1 | 0.2722 | 91.85 | 0 | 0 | 0 | 98.52 | 0 |
#| 2 | 0.2177 | 0 | 91.85 | 0 | 98.52 | 0 | 0 |
#| 3 | 0.1388 | 0 | 0 | 0 | 0 | 0 | 91.85 |
#| **Σ modos 1-3** | | **91.85** | **91.85** | **0** | **98.52** | **98.52** | **91.85** |
#| **Σ los 9 modos** | | **100** | **100** | **0** | **100** | **100** | **100** |

#: **U_{z} = 0**: este modelo no tiene masa vertical (como ETABS por defecto; SAP2000 sí la cuenta). Que la masa vertical entre o no cambia periodos y sumatorias: es el tema de la hoja 107 (masa sísmica).
#: **R_{z} con tres modos se queda en 91.85 %** aunque U_{x} y U_{y} también: con 3 modos se cumple la NEC en las dos direcciones horizontales. Pero si el modo 3 no fuera de giro, R_{z} quedaría en 0 y la torsión no estaría representada: por eso se miran las seis columnas, no solo X e Y.

#: El edificio en 3D con los modos de verdad (arrastra para girar). Primero el modo 1, U_{x}:
#hide
X_n = zeros(16, 3)
for l = 0:3
  X_n(4·l + 1, 3) = 3·l
  X_n(4·l + 2, 1) = 6
  X_n(4·l + 2, 3) = 3·l
  X_n(4·l + 3, 1) = 6
  X_n(4·l + 3, 2) = 6
  X_n(4·l + 3, 3) = 3·l
  X_n(4·l + 4, 2) = 6
  X_n(4·l + 4, 3) = 3·l
end
e_s = zeros(3, 4)
e_f = zeros(12, 2)
for l = 1:3
  for c = 1:4
    e_s(l, c) = 4·l + c
    e_f(4·(l - 1) + c, 1) = 4·(l - 1) + c
    e_f(4·(l - 1) + c, 2) = 4·l + c
  end
end
v_f = zeros(12, 2)
s_1 = [0; p_11; p_21; 1]
s_r = [0; p_11; p_21; 1]
U_x = zeros(16, 3)
U_y = zeros(16, 3)
U_r = zeros(16, 3)
v_x = zeros(16, 1)
v_y = zeros(16, 1)
v_r = zeros(16, 1)
for l = 0:3
  for c = 1:4
    n = 4·l + c
    U_x(n, 1) = s_1(l + 1)
    U_y(n, 2) = s_1(l + 1)
    U_r(n, 1) = -0.25·s_r(l + 1)·(X_n(n, 2) - 3)
    U_r(n, 2) = 0.25·s_r(l + 1)·(X_n(n, 1) - 3)
    v_x(n) = s_1(l + 1)
    v_y(n) = s_1(l + 1)
    v_r(n) = 0.25·s_r(l + 1)·sqrt((X_n(n, 1) - 3)^2 + (X_n(n, 2) - 3)^2)
  end
end
#show
#modelo3d(X_n, e_s, e_f, v_x, v_f, U_x, 1.5)
#: Modo 2, U_{y} (las columnas son más rígidas en Y, por eso es más rápido):
#modelo3d(X_n, e_s, e_f, v_y, v_f, U_y, 1.5)
#: Modo 3, R_{z}: las losas giran alrededor del centro de la planta, las esquinas son las que más se mueven:
#modelo3d(X_n, e_s, e_f, v_r, v_f, U_r, 1.5)

## 8 · Comprobación independiente (numpy / scipy)

#: El mismo edificio armado como modelo de **9 grados de libertad** (U_{x}, U_{y}, R_{z} por piso, cada columna con su posición) y resuelto con scipy.linalg.eigh, sin ninguna de las simplificaciones de esta hoja:
#hide
n_T1 = 0.272179
n_T2 = 0.098737
n_T3 = 0.070122
n_Ty = 0.217743
n_Tr = 0.138828
n_P1 = 91.85
h_T1 = round(T_1, 6)
h_T2 = round(T_2, 6)
h_T3 = round(T_3, 6)
h_Ty = round(T_y1, 6)
h_Tr = round(T_r1, 6)
h_P1 = round(P_1, 2)
h_P2 = round(P_2, 2)
h_P3 = round(P_3, 2)
h_Pr = round(P_r1, 2)
x_T1 = round(100·(T_1 - n_T1)/n_T1, 3)
x_T2 = round(100·(T_2 - n_T2)/n_T2, 3)
x_T3 = round(100·(T_3 - n_T3)/n_T3, 3)
x_Ty = round(100·(T_y1 - n_Ty)/n_Ty, 3)
x_Tr = round(100·(T_r1 - n_Tr)/n_Tr, 3)
#show
#| Magnitud | Esta hoja | scipy (9 gdl) | Diferencia [%] |
#|---|---:|---:|---:|
#| T₁, modo 1 en X [s] | @{h_T1} | 0.272179 | @{x_T1} |
#| T₂, segundo modo en X [s] | @{h_T2} | 0.098737 | @{x_T2} |
#| T₃, tercer modo en X [s] | @{h_T3} | 0.070122 | @{x_T3} |
#| primer modo en Y [s] | @{h_Ty} | 0.217743 | @{x_Ty} |
#| primer modo de giro R_{z} [s] | @{h_Tr} | 0.138828 | @{x_Tr} |
#| masa efectiva modo 1 / 2 / 3 [%] | @{h_P1} / @{h_P2} / @{h_P3} | 91.85 / 7.19 / 0.96 | 0 |
#| R_{y} del modo 1 [%] | @{h_Pr} | 98.52 | 0 |
#: Los mismos periodos y porcentajes por dos caminos distintos: el determinante a mano con Newton, y la descomposición completa de 9 × 9 de scipy. Script: `hekatan-lisp/tests/numerico/clase_dinamica_9gdl.py`.
#: **Siguiente: clase 3 (hoja 110).** De dónde sale m en un edificio real (Mass Source, masa de losa repartida a nudos, con o sin masa vertical) y qué cambia cada tipo de losa en m y en k, o sea, en T.
