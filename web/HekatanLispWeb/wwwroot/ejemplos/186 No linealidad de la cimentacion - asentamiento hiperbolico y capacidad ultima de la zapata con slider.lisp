# No linealidad de la cimentación: asentamiento y capacidad última de una zapata
#: **La idea.** La zapata reparte la carga P en un área B×B: la presión es q = P/B². Al principio el suelo responde como un resorte (s = q/k₀, la recta).
#: Al acercarse a la **capacidad última q_ult** se forma una **cuña** de suelo que empuja hacia los lados y el terreno sube junto a la zapata: el asentamiento **se dispara**. Ese es el «techo».
#: Por eso se diseña con **FS = q_ult/q ≥ 3**: lejos del techo la curva es casi recta y el asentamiento es predecible.

## 1 · El objeto: zapata, cuña de falla y bulbo de presiones
#dibujo("Zapata cuadrada B = 2 m a D_f = 1,2 m: cuña de falla (rojo) cuando q se acerca a q_ult", ud = m, escala = auto, cotas = m, alto = 170)
#  linea(-4, 0, -1.3, 0, "media verde")
#  linea(1.3, 0, 4, 0, "media verde")
#  polilinea([-3.2, -2.2, -1.3], [0, 0.15, 0], "media rojo")
#  polilinea([1.3, 2.2, 3.2], [0, 0.15, 0], "media rojo")
#  texto(-3.9, 0.15, "terreno: sube junto a la zapata", 2.4, "i")
#  rect(-1, -1.5, 2, 0.3, "gruesa")
#  achurado(-1, -1.5, 2, 0.3, "concreto")
#  rect(-0.2, -1.2, 0.4, 1.6, "gruesa")
#  flecha(0, 1.2, 0, 0.45, "rojo")
#  texto(0.1, 1.0, "P", 3, "i")
#  poligono(-1, -1.5, 1, -1.5, 0, -2.9, "media rojo")
#  polilinea([0, -1.6, -3.2], [-2.9, -2.6, 0], "trazos rojo")
#  polilinea([0, 1.6, 3.2], [-2.9, -2.6, 0], "trazos rojo")
#  circulo(0, -2.4, 0.9, "trazos azul")
#  texto(1.05, -2.4, "bulbo de presiones", 2.4, "i")
#  cota(-1, -1.8, 1, -1.8, -0.3, "B")
#  cota(1.6, -1.5, 1.6, 0, 0.3, "D_f")
#fin

## 2 · Con letras
q = P/B^2 @@(presión bajo la zapata)
s = q/(k_0*(1 - q/q_ult)) @@(curva hiperbólica de Kondner: pendiente inicial k₀, asíntota q_ult)
k_sec = q/s @@(rigidez secante: cae en línea recta hasta 0 cuando q → q_ult)
#: La capacidad última (Terzaghi, zapata cuadrada) suma tres aportes: cohesión, sobrecarga del desplante y peso de la cuña:
q_u = 1.3*c*N_c + gamma_s*D_f*N_q + 0.4*gamma_s*B*N_g @@(q_ult)
#: La pendiente inicial sale de la teoría elástica (asentamiento de una zapata rígida):
k_e = E_s/(B*(1 - nu^2)*0.82) @@(k₀)

## 3 · Con números: arena densa, P = 1200 kN
#: Para φ = 32° los factores de capacidad (Prandtl–Reissner y Vesić) son los de la tabla; el motor comprueba N_q:
N_q_motor = dec(exp(pi*tan(32*pi/180))*tan(pi/4 + 16*pi/180)^2, 4) @@(N_q = e^(π·tan φ)·tan²(45° + φ/2))
N_q = 23.18
N_c = 35.49 @@(N_c = (N_q − 1)·cot φ)
N_g = 30.21 @@(N_γ = 2·(N_q + 1)·tan φ)
c = 0 @@(kPa)
gamma_s = 18 @@(kN/m³)
D_f = 1.2 @@(m)
B = 2 @@(m)
E_s = 30000 @@(kPa)
nu = 0.3
P = 1200 @@(kN)
q_ult = dec(1.3*c*N_c + gamma_s*D_f*N_q + 0.4*gamma_s*B*N_g, 2) @@(kPa)
k_0 = dec(E_s/(B*(1 - nu^2)*0.82), 1) @@(kPa/m)
q_a = P/B^2 @@(kPa)
FS = dec(935.71/q_a, 3) @@(factor de seguridad = q_ult/q)
s_lin = dec(q_a/20101.8, 5) @@(m: si el suelo fuera lineal)
s_nl = dec(q_a/(20101.8*(1 - q_a/935.71)), 5) @@(m: real, no lineal)
veces = dec(1/(1 - q_a/935.71), 3) @@(cuántas veces más asienta = 1/(1 − q/q_ult))
#: Con FS ≈ 3 el asentamiento real es solo ~1,5 veces el lineal: el tramo casi recto. Si subes P hasta FS = 1,5, ya es el triple; con FS → 1 no tiene límite (falla).

## 4 · Vista 3D: presión q según el asentamiento s y el tamaño B
#: Eje x = s (m), eje y = B (m). Cada corte a B fijo es la curva carga–asentamiento de esa zapata: una zapata más grande es más rígida (k₀ baja con B, pero el área crece) y tiene más capacidad.
#surf(x/((y*(1 - nu^2)*0.82)/E_s + x/(gamma_s*D_f*N_q + 0.4*gamma_s*y*N_g)), [0 0.1], [1 4])

## 5 · Corte 2D con slider: mueve el tamaño B = 0,5·n m
#: La curva azul es la real (no lineal), la recta es la lineal y la horizontal es el techo q_ult. Mira cómo al agrandar B suben las dos cosas: la pendiente y el techo.
#slider fplot(q_real = x/((0.5*n*(1 - nu^2)*0.82)/E_s + x/(gamma_s*D_f*N_q + 0.4*gamma_s*0.5*n*N_g)), q_lineal = min(x*E_s/(0.5*n*(1 - nu^2)*0.82), 1.2*(gamma_s*D_f*N_q + 0.4*gamma_s*0.5*n*N_g)), q_ult = gamma_s*D_f*N_q + 0.4*gamma_s*0.5*n*N_g, [0 0.1]), n = 2:8

## 6 · La rigidez que «siente» la estructura
#: Eje x = q/q_ult. La rigidez secante k = q/s cae en línea recta: con FS = 3 (x = 0,33) queda el 67 % de k₀; cerca de la falla, casi nada. Esa rigidez reducida es la que se le pone al resorte de la cimentación en un modelo de la estructura.
#fplot(k_sec_sobre_k0 = 1 - x, FS_3 = 0.67, [0 0.95])
