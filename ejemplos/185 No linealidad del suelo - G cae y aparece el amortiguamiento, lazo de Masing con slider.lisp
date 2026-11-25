# No linealidad del suelo: el módulo G cae y aparece el amortiguamiento
#: **La idea.** Lineal es la recta y = m·x: si el suelo se corta el doble, el esfuerzo es el doble, y la pendiente **G** (rigidez al corte) nunca cambia.
#: En un sismo fuerte los granos **se deslizan entre sí**: la pendiente **se cansa** (G baja), y en cada ida y vuelta queda un **lazo**. El área del lazo es energía que el suelo convierte en calor: eso es el **amortiguamiento ξ**.
#: La clave es la deformación de referencia **γ_r**: cuando γ = γ_r, el suelo ya perdió la **mitad** de su rigidez.

## 1 · El objeto: un cubo de suelo que la onda del sismo corta
#dibujo("Elemento de suelo cortado por la onda S (deformación exagerada)", ud = m, escala = auto, alto = 170)
#  linea(-3, 1.6, 3, 1.6, "media verde")
#  texto(-2.9, 1.75, "superficie del terreno", 2.6, "i")
#  rect(-1, -1, 2, 2, "trazos")
#  poligono(-1, -1, 1, -1, 1.6, 1, -0.4, 1, "gruesa azul")
#  flecha(-0.4, 1.25, 1.2, 1.25, "rojo")
#  texto(1.3, 1.3, "τ", 3, "i")
#  flecha(1, -1.25, -0.6, -1.25, "rojo")
#  flecha(-2.4, -1.6, -2.4, 0.6, "verde")
#  texto(-2.3, -0.9, "onda S del sismo", 2.6, "i")
#  cota(1, 0.6, 1.6, 0.6, 0.15, "γ·h")
#fin

## 2 · Con letras: la curva hiperbólica
tau = G_max*gamma/(1 + gamma/gamma_r) @@(esfuerzo de corte: hipérbola de Hardin–Drnevich)
G_sec = tau/gamma @@(módulo secante: la pendiente que «queda»)
#: Si γ es muy chico, γ/γ_r ≈ 0 y queda G_sec = G_max: el suelo es **lineal**. Si γ = γ_r el denominador vale 2: queda **la mitad**.
k_t = Derivate{G_max*gamma/(1 + gamma/gamma_r) @ gamma} @@(pendiente tangente dτ/dγ: cae todavía más rápido)
#: El **amortiguamiento** sale del área del lazo. Con la regla de Masing (la descarga es la curva inicial a doble escala) y r = γ/γ_r:
xi_M = 4/pi*(1 + 1/r)*(1 - ln(1 + r)/r) - 2/pi @@(ξ = A_lazo / (4π·½·τ·γ))

## 3 · Con números: arena media en un sismo moderado
G_max = 80000 @@(kPa)
gamma_r = 0.0003 @@(0,03 %)
gamma_a = 0.0002 @@(0,02 %: amplitud del sismo)
r = gamma_a/gamma_r @@(cuántas veces γ_r)
G_s = G_max/(1 + r) @@(kPa)
G_rel = G_s/G_max @@(fracción de rigidez que queda)
tau_a = G_s*gamma_a @@(kPa)
xi = dec(4/pi*(1 + 1/r)*(1 - ln(1 + r)/r) - 2/pi, 4) @@(amortiguamiento del lazo)
#: El suelo conserva el **60 %** de su rigidez y disipa ξ ≈ **11 %**. Un análisis lineal con G_max se equivoca en las dos cosas: lo cree más rígido y sin amortiguamiento.

## 4 · Vista 3D: G/G_max según γ y γ_r
#: Eje x = log₁₀ γ (de −6 = 0,0001 % a −2 = 1 %). Eje y = γ_r en %. Cada corte a γ_r fijo es la «curva de degradación» de un suelo: arriba a la izquierda es lineal, abajo a la derecha ya casi no tiene rigidez.
#surf(1/(1 + 10^x/(y/100)), [-6 -2], [0.005 0.5])

## 5 · Corte 2D con slider: mueve γ_r (de grava, n = 0, a arcilla blanda, n = 6)
#: γ_r = 0,005 %·2ⁿ. Con γ_r más grande la curva se corre a la derecha: el suelo aguanta más deformación antes de «cansarse».
#slider fplot(G_Gmax = 1/(1 + 10^x/(0.00005*2^n)), xi = 4/pi*(1 + (0.00005*2^n)/10^x)*(1 - ln(1 + 10^x/(0.00005*2^n))*(0.00005*2^n)/10^x) - 2/pi, [-6 -2]), n = 0:6

## 6 · El lazo τ–γ con slider: mueve la amplitud del sismo
#: Amplitud γ_a = n·0,01 %. Eje x = γ/γ_a (de −1 a 1). Descarga: τ = τ_a − 2·f((γ_a − γ)/2). Recarga: τ = −τ_a + 2·f((γ + γ_a)/2). Con n = 1 el lazo es casi una recta; con n = 10 es gordo: mucha energía disipada.
#slider fplot(bajada = 80000*n*0.0001/(1 + n*0.0001/0.0003) - 2*80000*((n*0.0001 - n*0.0001*x)/2)/(1 + ((n*0.0001 - n*0.0001*x)/2)/0.0003), subida = -80000*n*0.0001/(1 + n*0.0001/0.0003) + 2*80000*((n*0.0001*x + n*0.0001)/2)/(1 + ((n*0.0001*x + n*0.0001)/2)/0.0003), lineal_Gmax = 80000*n*0.0001*x, [-1 1]), n = 1:10
