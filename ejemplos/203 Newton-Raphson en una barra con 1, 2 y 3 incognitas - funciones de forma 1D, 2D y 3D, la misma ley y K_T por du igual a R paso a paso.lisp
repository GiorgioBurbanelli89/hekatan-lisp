# Newton-Raphson en una barra con 1, 2 y 3 incógnitas - funciones de forma 1D, 2D y 3D, la misma ley que se ablanda y Kₜ·Δu = R paso a paso
#numerico

## 0 · La idea
#: Una barra cargada en la punta se acorta o se alarga. Si el material fuera lineal, bastaría una división (o un sistema K·u = F). Pero la barra **se ablanda** (la ley de la hoja 198): hay que dar **vueltas de Newton**. Esta hoja hace lo mismo tres veces, subiendo de a una incógnita: **1, 2 y 3 GDL** (grados de libertad). Y cada caso se calcula con tres elementos finitos distintos: una **barra 1D**, un **área 2D** (Q4) y un **sólido 3D** (H8). La pregunta: ¿dan lo mismo? (Spoiler: con ν = 0, sí, hasta el último decimal; con ν ≠ 0, depende de qué se deje mover a los lados.)
#dibujo("La misma barra como elemento 1D, 2D y 3D (L = 3 m, sección 1 × 1 m)", ud = m, escala = auto, cotas = m, alto = 95)
#  achurado([-0.4, 0, 0, -0.4], [-0.6, -0.6, 5.6, 5.6], "suelo")
#  linea(0, 5, 3, 5, "gruesa")
#  circulo(0, 5, 0.08, "negro")
#  circulo(3, 5, 0.08, "negro")
#  flecha(3, 5, 3.9, 5, "gruesa rojo")
#  texto(4.3, 5.25, "P", 2.6, "c")
#  texto(1.5, 5.35, "1D: barra de 2 nudos", 2.4, "c")
#  poligono(0, 2.2, 3, 2.2, 3, 3.2, 0, 3.2, "gruesa")
#  circulo(0, 2.2, 0.08, "negro")
#  circulo(3, 2.2, 0.08, "negro")
#  circulo(3, 3.2, 0.08, "negro")
#  circulo(0, 3.2, 0.08, "negro")
#  flecha(3, 2.7, 3.9, 2.7, "gruesa rojo")
#  texto(1.5, 3.5, "2D: área Q4 (4 nudos)", 2.4, "c")
#  poligono(0, -0.6, 3, -0.6, 3, 0.4, 0, 0.4, "gruesa")
#  poligono(3, -0.6, 3.5, -0.2, 3.5, 0.8, 3, 0.4, "gruesa")
#  poligono(0, 0.4, 0.5, 0.8, 3.5, 0.8, 3, 0.4, "gruesa")
#  linea(0, -0.6, 0.5, -0.2, "trazos")
#  linea(0.5, -0.2, 3.5, -0.2, "trazos")
#  linea(0.5, -0.2, 0.5, 0.8, "trazos")
#  flecha(3.25, 0.1, 4.15, 0.1, "gruesa rojo")
#  texto(1.6, 1.15, "3D: sólido H8 (8 nudos)", 2.4, "c")
#  cota(0, -1.2, 3, -1.2, 0, "L = 3 m")
#fin
### Los 6 pasos de Newton (los mismos en toda la hoja)
#: **1.** u₀ = 0.  **2.** En cada punto de Gauss: ε = B·u, σ(ε) con la ley, y Eₜ = dσ/dε.  **3.** fᵢₙₜ = ∫ Bᵀ·σ dV y R = F − fᵢₙₜ.  **4.** Si |R| < tolerancia: terminar.  **5.** Kₜ = ∫ Bᵀ·Eₜ·B dV y resolver Kₜ·Δ u = R.  **6.** u ← u + Δ u y volver al paso 2.
#: En 2D y 3D la cara cargada se **ata** (todos sus nudos se mueven el mismo u) y los lados no se dejan mover hacia arriba ni hacia adentro: así el área y el sólido también tienen **una sola incógnita** por sección, como la barra.

## 1 · 1 GDL: las funciones de forma, primero con símbolos
### 1.1 · Barra 1D: de un polinomio a N₁ y N₂
#: Dentro del elemento (ξ = x/L va de 0 a 1) el movimiento es una recta: u = a₀ + a₁ξ. Sus dos coeficientes salen de las dos condiciones en los nudos: u(0) = u₁ y u(1) = u₂. Escritas como matriz A·[a₀; a₁] = [u₁; u₂]:
A_1 = Simplify{[1, 0; 1, 1]}
#: La inversa da los coeficientes en función de los nudos; multiplicada por la base [1, ξ] da las **funciones de forma**:
C_1 = Simplify{inv([1, 0; 1, 1])}
N_1D = Simplify{[1, xi]*inv([1, 0; 1, 1])}
#: **N₁ = 1 − ξ y N₂ = ξ**: cada una vale 1 en su nudo y 0 en el otro. La deformación es la derivada respecto de x = ξL (el motor deriva; dξ/dx = 1/L):
B_1 = Simplify{Diff{1 - xi @ xi}/L}
B_2 = Simplify{Diff{xi @ xi}/L}
#: Rigidez: k = ∫ Bᵀ·E·A·B dx con B = [−1/L, 1/L]; Bᵀ·B término a término, y con dx = L·dξ el motor integra de 0 a 1:
K_1D = Simplify{E*A*L*Integral{[(-1/L)*(-1/L), (-1/L)*(1/L); (1/L)*(-1/L), (1/L)*(1/L)] @ xi = 0 : 1}}
#: Con el nudo 1 fijo queda **k = EA/L**, una sola incógnita u₂. Las dos funciones de forma (eje horizontal: ξ):
#fplot(N_1 = 1 - x, N_2 = x, [0 1])
### 1.2 · Área 2D (Q4): funciones bilineales
#: En el cuadrado de referencia (ξ y η de −1 a +1) el movimiento es u = a₀ + a₁ξ + a₂η + a₃ξη. Las cuatro condiciones en las esquinas (−1,−1), (1,−1), (1,1), (−1,1):
A_2 = Simplify{[1, -1, -1, 1; 1, 1, -1, -1; 1, 1, 1, 1; 1, -1, 1, -1]}
N_Q4 = Simplify{[1, xi, eta, xi*eta]*inv([1, -1, -1, 1; 1, 1, -1, -1; 1, 1, 1, 1; 1, -1, 1, -1])}
#: Son **(1 ± ξ)(1 ± η)/4**. La cara cargada es la de ξ = +1 (nudos 2 y 3), atada con el mismo u; los nudos 1 y 4 están fijos. Entonces u(ξ, η) = (N₂ + N₃)·u:
S_Q4 = Simplify{(1 + xi)*(1 - eta)/4 + (1 + xi)*(1 + eta)/4}
#: ¡No depende de η! Es la misma recta de la barra. La deformación ε_x = (2/L)·∂/∂ξ es constante, y la integral sobre el área (det J = (L/2)(h/2), espesor t) colapsa a la de la barra:
K_Q4 = Simplify{E*t*Integral{Integral{(1/L)^2*(L/2)*(h/2) @ eta = -1 : 1} @ xi = -1 : 1}}
#: **E·t·h/L = EA/L** con A = t·h. La función de forma N₁ del Q4 en 3D (x = ξ, y = η; arrastra para girar):
#surf((1 - x)*(1 - y)/4, [-1 1], [-1 1])
### 1.3 · Sólido 3D (H8): funciones trilineales
#: Lo mismo con tres coordenadas: N = (1 ± ξ)(1 ± η)(1 ± ζ)/8, una por esquina. La cara ξ = +1 tiene 4 nudos; su suma:
S_H8 = Simplify{(1 + xi)*(1 - eta)*(1 - zeta)/8 + (1 + xi)*(1 + eta)*(1 - zeta)/8 + (1 + xi)*(1 + eta)*(1 + zeta)/8 + (1 + xi)*(1 - eta)*(1 + zeta)/8}
K_H8 = Simplify{E*Integral{Integral{Integral{(1/L)^2*(L/2)*(b/2)*(h/2) @ zeta = -1 : 1} @ eta = -1 : 1} @ xi = -1 : 1}}
#: **E·b·h/L = EA/L** otra vez. Los tres elementos, con la cara atada y ν = 0, son **la misma rigidez**. Un corte de N₁ del H8 en ζ = 0 (en 2D, la mitad del Q4):
#fplot(corte_N1 = (1 - x)/4, corte_N2 = (1 + x)/4, [-1 1])
### 1.4 · La ley del material NO sale de Newton: se elige
#: Dos cosas distintas que se confunden: **la ley N(d) es el material** (un dato: una hipótesis o un ensayo); **Newton es el método** para hallar el d que cumple N(d) = P. Como en y = m·x + b: la recta es el dato, despejar x es el método. Si cambias el material, Newton no cambia; solo cambia la N(d) que le das.
#: **De dónde sale esta ley.** Se pide que cumpla tres hipótesis: **H1** al inicio es elástica, N ≈ k·d (k = EA/L); **H2** tiene un techo, nunca pasa de N_u; **H3** entre ambas, una curva suave, sin saltos. Una forma de cumplir las tres: **dos resortes en serie**, uno elástico (k·d) y un tope (N_u). En serie se suman las inversas:
N_s = Simplify{1/(1/(k*d) + 1/N_u)}
#: Es **N = k·d/(1 + k·d/N_u)**. Comprobaciones: con d pequeño, k·d/N_u ≈ 0 y N ≈ k·d (H1); con d grande, N → N_u (H2); y es suave (H3). Es la **hipérbola de Kondner (1963)**, la base del modelo Duncan-Chang para suelos.
#: **¿Por qué |d|?** Para que valga igual en tracción y en compresión (simétrica). Sin el valor absoluto, con d < 0 el denominador 1 + k·d/N_u se achica y la fuerza crece sin techo. Con números (k = 20 kN/mm, N_u = 300 kN, d = −20 mm):
N_mal = 20*(-20)/(1 + 20*(-20)/300) 'sin |d|: ¡+1200 kN, signo y techo equivocados! [kN]
N_bien = 20*(-20)/(1 + 20*abs(-20)/300) 'con |d|: −171.4 kN, compresión bajo el techo [kN]
#: **Las tres hipótesis sobre la curva** (gráfica dinámica; n recorre d en mm; la recta tangente es lo que usará Newton):
#anim fplot(recta = 20*x, techo = 300 + 0*x, ley = 20*x/(1 + 20*x/300), tangente = 20*n/(1 + 20*n/300) + 20/(1 + 20*n/300)^2*(x - n), [0 150]), n = 0:3:150
#: **Qué toma Newton de la ley** (para d > 0): el residuo R = P − N(d) y la pendiente, la **rigidez tangente** kₜ = dN/dd, que el motor deriva:
N_b = Simplify{k*delta/(1 + k*delta/N_u)}
k_b = Simplify{Diff{k*delta/(1 + k*delta/N_u) @ delta}}
#: Es kₜ = k/(1 + k·|d|/N_u)²: vale k al inicio y baja al estirarse. **El paso de Newton con 1 incógnita: Δ d = R/kₜ.** En el sólido y el área la misma ley se aplica a ε_x en cada punto de Gauss (σ = E·ε/(1 + E·|ε|/σᵤ), σᵤ = N_u/A), con ν = 0.
### 1.5 · De dónde sale la fórmula de Newton
#: Hasta aquí se **usó** Δ d = R/kₜ sin decir de dónde sale. La idea es una sola: **cerca de un punto, una curva se parece a su recta tangente**. Newton cambia la curva R(d) = P − N(d) por su tangente en el punto actual dₖ, busca dónde esa recta corta el cero y repite. (La ley N(d) es el dato, sección 1.4; esto es el método.)
#dibujo("El problema: la barra con P en la punta; adentro responde N(d), que se ablanda", ud = m, escala = auto, cotas = m, alto = 45)
#  achurado([-0.4, 0, 0, -0.4], [-0.6, -0.6, 0.6, 0.6], "suelo")
#  linea(0, 0, 3, 0, "gruesa")
#  circulo(0, 0, 0.08, "negro")
#  circulo(3, 0, 0.08, "negro")
#  flecha(3, 0, 3.9, 0, "gruesa rojo")
#  texto(4.4, 0.3, "P = 240 kN", 2.4, "c")
#  flecha(2.6, -0.35, 1.8, -0.35, "fina azul")
#  texto(2.2, -0.75, "N(d)", 2.2, "c")
#  cota(0, -1.2, 3, -1.2, 0, "d = ? (alargamiento)")
#fin
#: **Antes: ¿de dónde sale la serie de Taylor?** Newton la usa; aquí se deduce, partiendo de lo que ya se sabe.
#: **¿Qué sé?** (1) Una recta, y = m·x + b, es fácil: b es su valor y m su pendiente. (2) La **derivada** f′(x) es la pendiente de la curva en x; la **segunda derivada** f″(x) dice cuánto cambia esa pendiente (la curvatura).  **¿Qué quiero?** Cambiar una curva complicada f(x) por algo fácil que se le **pegue cerca de un punto a**. Lo más fácil después de la recta es un **polinomio** (solo sumas y productos). La curva de ejemplo, f(x) = sen x cerca de a = 1, y su recta tangente (pasa el cursor):
#fplot(f = sin(x), tangente = 0.841471 + 0.540302*(x - 1), [-1 4])
#: **¿Qué propongo?** Un polinomio en potencias de (x − a), con coeficientes c₀, c₁, c₂, c₃ que no se conocen:  p(x) = c₀ + c₁·(x − a) + c₂·(x − a)² + c₃·(x − a)³.  **¿Qué exijo?** Que p y f sean iguales **en el punto a**: el mismo valor, la misma pendiente, la misma curvatura, … El motor pone x = a (Limit con x → a) y deriva. **Mismo valor:** en x = a cada (x − a) vale 0 y solo sobrevive c₀:
p_0 = Limit{c_0 + c_1*(x - a) + c_2*(x - a)^2 + c_3*(x - a)^3 @ x = a}
#: ⇒ **c₀ = f(a)**. Para derivar cómodo llamo t = x − a (dt/dx = 1, así que derivar en t es derivar en x; y x = a es t = 0): p = c₀ + c₁·t + c₂·t² + c₃·t³. **Misma pendiente:** derivo una vez:
p_1 = Diff{c_0 + c_1*t + c_2*t^2 + c_3*t^3 @ t}
#: En t = 0 solo sobrevive c₁ ⇒ **c₁ = f′(a)**: c₀ + c₁·(x − a) es la recta tangente (y = m·x + b con b = f(a) y m = f′(a)). **Misma curvatura:** derivo dos veces; el 2 del cuadrado «baja»:
p_2 = Diff{Diff{c_0 + c_1*t + c_2*t^2 + c_3*t^3 @ t} @ t}
#: En t = 0: 2·c₂ = f″(a) ⇒ **c₂ = f″(a)/2**. Tres derivadas: baja 3·2·1 = 6:
p_3 = Diff{Diff{Diff{c_0 + c_1*t + c_2*t^2 + c_3*t^3 @ t} @ t} @ t}
#: ⇒ 6·c₃ = f‴(a) ⇒ **c₃ = f‴(a)/6**. **El patrón (por qué aparece el factorial):** derivar (x − a)ⁿ n veces deja n·(n − 1)···2·1 = **n!** (n factorial). El motor con n = 4 y n = 5:
F_4 = Simplify{Diff{Diff{Diff{Diff{(x - a)^4 @ x} @ x} @ x} @ x}}
F_5 = Simplify{Diff{Diff{Diff{Diff{Diff{(x - a)^5 @ x} @ x} @ x} @ x} @ x}}
#: **¿Qué sale?**  **cₙ = f⁽ⁿ⁾(a)/n!**  y  **f(x) ≈ f(a) + f′(a)·(x − a) + f″(a)/2!·(x − a)² + f‴(a)/3!·(x − a)³ + …**  Esa es la serie de Taylor: no se inventa, se **exige**.
#: **Con el seno, alrededor de a = 0.** El motor deriva: sen, cos, −sen, −cos y se repite:
s_1 = Diff{sin(x) @ x}
s_2 = Diff{Diff{sin(x) @ x} @ x}
s_3 = Diff{Diff{Diff{sin(x) @ x} @ x} @ x}
s_4 = Diff{Diff{Diff{Diff{sin(x) @ x} @ x} @ x} @ x}
#: En x = 0 valen 0, 1, 0, −1, 0, 1, … Solo sobreviven las potencias impares: **sen x ≈ x − x³/3! + x⁵/5! − x⁷/7!** (3! = 6, 5! = 120, 7! = 5040). El orden 2 es igual al 1 porque sen″(0) = 0. El motor lo confirma:
T_s = Taylor{sin(x) @ x = 0 : 7}
#: Cada término más, el polinomio se pega **más lejos** de 0 (pasa el cursor: valor de cada curva en x):
#fplot(sen = sin(x), orden_1 = x, orden_3 = x - x^3/6, orden_5 = x - x^3/6 + x^5/120, orden_7 = x - x^3/6 + x^5/120 - x^7/5040, [-3.5 3.5])
#: **Lo que se corta: el resto (Lagrange).** f(x) = pₙ(x) + Rₙ(x), con Rₙ(x) = f⁽ⁿ⁺¹⁾(ξ)/(n + 1)!·(x − a)ⁿ⁺¹ y ξ algún punto entre a y x. Para el seno |f⁽ⁿ⁺¹⁾| ≤ 1, así que |Rₙ| ≤ |x|ⁿ⁺¹/(n + 1)!. El error real en x = 1 y en x = 2:
E_1 = 1*[abs(sin(1) - 1), 1/2; abs(sin(1) - (1 - 1/6)), 1/24; abs(sin(1) - (1 - 1/6 + 1/120)), 1/720; abs(sin(1) - (1 - 1/6 + 1/120 - 1/5040)), 1/40320] 'x = 1: [error, cota] para n = 1, 3, 5, 7
E_2 = 1*[abs(sin(2) - 2), 2^2/2; abs(sin(2) - (2 - 8/6)), 2^4/24; abs(sin(2) - (2 - 8/6 + 32/120)), 2^6/720; abs(sin(2) - (2 - 8/6 + 32/120 - 128/5040)), 2^8/40320] 'x = 2: [error, cota]
#: El error siempre queda bajo la cota; en x = 1, con 7 términos, es 2.7·10⁻⁶; lejos de a (x = 2) hacen falta más términos.
#: **¿Para qué sirve?** (a) **Newton** = Taylor cortado en el término lineal (lo que sigue en esta sección). (b) Lo que Newton tira, ½·f″·Δ², es lo que hace que converja **al cuadrado**. (c) **Gauss** integra exacto los polinomios, y una función suave se parece a su polinomio de Taylor: por eso Gauss funciona (∫ eˣ de −1 a 1 = 2.3504; Gauss con 2 puntos, exacto hasta x³: 2.3427). (d) **Péndulo / deformaciones pequeñas:** sen θ ≈ θ (a 10°: 0.17453 contra 0.17365, 0.51 %). (e) **La barra** de las hojas 198 y 203: N(d) = k·d/(1 + k·d/Nᵤ); sus coeficientes con Diff (para d > 0):
N_1d = Simplify{Diff{k*x/(1 + k*x/N_u) @ x}}
N_2d = Simplify{Diff{Diff{k*x/(1 + k*x/N_u) @ x} @ x}}
N_3d = Simplify{Diff{Diff{Diff{k*x/(1 + k*x/N_u) @ x} @ x} @ x}}
#: En d = 0 los denominadores valen Nᵤ², Nᵤ³ y Nᵤ⁴: N′ = k, N″ = −2k²/Nᵤ, N‴ = 6k³/Nᵤ²; divididos entre 1!, 2! y 3!: c₁ = k, c₂ = −k²/Nᵤ, c₃ = k³/Nᵤ². Con números, el motor lo confirma:
T_N = Taylor{20*x/(1 + 20*x/300) @ x = 0 : 3}
#: ⇒ **N(d) ≈ k·d − k²·d²/Nᵤ + k³·d³/Nᵤ² − …** Con k = 20 kN/mm y Nᵤ = 300 kN: 20·d − (4/3)·d² + (4/45)·d³ − …; por eso R = P − N = 240 − 20·d + (4/3)·d² − …, justo lo que sale en el paso 1.
#: **Dos variables (solo lo lineal).** Si me muevo Δ x y Δ y, la función cambia lo que sube en x más lo que sube en y: **f(x + Δ x, y + Δ y) ≈ f + f_x·Δ x + f_y·Δ y**, con f_x = ∂f/∂x y f_y = ∂f/∂y (las pendientes en cada dirección). Eso es un **plano**: el plano tangente. Ejemplo f = 1 + x² + y²/2 en (1, 1):
f_x = Partial{1 + x^2 + y^2/2 @ x}
f_y = Partial{1 + x^2 + y^2/2 @ y}
#: En (1, 1): f = 2.5, f_x = 2, f_y = 1 ⇒ plano **z = 2.5 + 2·(x − 1) + (y − 1)**. Lo que se tira es exactamente Δ x² + Δ y²/2 (el motor resta):
R_pl = Expand{(1 + (1 + u)^2 + (1 + w)^2/2) - (2.5 + 2*u + w)}
#: La superficie y su plano tangente en (1, 1) (arrastra para girar; pasa el cursor):
#surf(f = 1 + x^2 + y^2/2, plano = 2.5 + 2*(x - 1) + (y - 1), [-0.5 2], [-0.5 2.5], punto = [1 1 2.5])
#: Con varios residuos R₁, R₂, …, esas pendientes ∂Rᵢ/∂uⱼ forman una matriz, el **jacobiano**: R(u + Δ u) ≈ R − Kₜ·Δ u. Es la Kₜ de Newton para sistemas (más abajo).
#: **Ahora sí, Taylor aplicado a Newton.**
#: **Paso 1 · Taylor.** Toda curva suave, cerca de dₖ, se escribe como una suma: su valor, más la pendiente por el paso, más la curvatura por el paso al cuadrado, …  **R(dₖ + Δ d) = R(dₖ) + R′(dₖ)·Δ d + ½·R″(dₖ)·Δ d² + …**  El motor lo hace con la ley de la barra alrededor de d = 0 (orden 2; k = 20 kN/mm, Nᵤ = 300 kN, P = 240 kN):
T_0 = Taylor{240 - 20*x/(1 + 20*x/300) @ x = 0 : 2}
#: Los dos primeros términos, **240 − 20·d**, son la recta tangente en d = 0; el tercero, (4/3)·d², es la curvatura que Newton desprecia.
#: **Paso 2 · cortar en el término lineal.** Si el paso Δ d es chico, Δ d² es mucho más chico: se desprecia. Queda una recta en Δ d, como y = m·x + b: **b = Rₖ** (lo que falta ahora), **m = R′(dₖ)** (la pendiente) y **x = Δ d**. La pendiente de R = P − N es menos la de N (el motor deriva):
R_d1 = Simplify{Diff{P - k*x/(1 + k*x/N_u) @ x}}
#: Es −Nᵤ²·k/(k·d + Nᵤ)² = **−k/(1 + k·d/Nᵤ)² = −dN/dd = −kₜ**. **Paso 3 · igualar la recta a cero**: Rₖ − kₜ·Δ d = 0 ⇒ **Δ d = Rₖ/kₜ**. El motor comprueba que ese Δ d anula la recta:
c_0 = Simplify{R_k - k_T*(R_k/k_T)}
#: Entonces **dₖ₊₁ = dₖ + Δ d**. Esa es toda la fórmula de Newton: la recta tangente igualada a cero, una y otra vez.
#: Con números (para d > 0, |d| = d):
G_r(x) = 240 - 20*x/(1 + 20*abs(x)/300) 'R(d) = P − N(d) [kN]
G_t(x) = 20/(1 + 20*abs(x)/300)^2 'kₜ = dN/dd [kN/mm]
#: **Vuelta 1** (d₀ = 0 mm):
r_a = G_r(0) 'R₀ [kN]
t_a = G_t(0) 'kₜ en d₀ [kN/mm]
z_a = r_a/t_a 'Δd = R/kₜ [mm]
h_1 = 0 + z_a 'd₁ [mm]
#: **Vuelta 2** (d₁ = 12 mm):
r_b = G_r(h_1) 'R₁ [kN]
t_b = G_t(h_1) 'kₜ en d₁ [kN/mm]
z_b = r_b/t_b 'Δd [mm]
h_2 = h_1 + z_b 'd₂ [mm]
#: Las siguientes, en una línea cada una:
h_3 = h_2 + G_r(h_2)/G_t(h_2) 'd₃ [mm]
h_4 = h_3 + G_r(h_3)/G_t(h_3) 'd₄ [mm]
h_5 = h_4 + G_r(h_4)/G_t(h_4) 'd₅ [mm]
h_6 = h_5 + G_r(h_5)/G_t(h_5) 'd₆ [mm]
h_7 = h_6 + G_r(h_6)/G_t(h_6) 'd₇ [mm]
#: **La recta tangente en cada vuelta** (eje horizontal: d en mm; vertical: R en kN; cada tangente dibujada solo de dₖ a dₖ₊₁; pasa el cursor por los puntos). Cada tangente corta el cero en el d siguiente: 0 → 12 → 29.28 → 47.42 → 57.89 mm:
#fplot(R = 240 - 20*x/(1 + 20*x/300), tangente_0 = 240 - 20*x + 0*sqrt(x*(14 - x)), tangente_1 = 106.667 - 6.17284*(x - 12) + 0*sqrt((x - 10)*(32 - x)), tangente_2 = 41.626 - 2.29508*(x - 29.28) + 0*sqrt((x - 27)*(50 - x)), cero = 0*x, puntos = [0 240; 12 0; 12 106.667; 29.28 0; 29.28 41.626; 47.4171 0; 47.4171 12.0956; 57.8889 0; 60 0], [0 64])
#: **Por qué converge tan rápido.** El término que se tiró es ½·R″·Δ d². Por eso el error de la vuelta siguiente es proporcional al error **al cuadrado**: eₖ₊₁ ≈ C·eₖ², con C = |R″/(2R′)|. El motor saca R″ y el cociente:
R_d2 = Simplify{Diff{Diff{P - k*x/(1 + k*x/N_u) @ x} @ x}}
C_q = Simplify{Diff{Diff{P - k*x/(1 + k*x/N_u) @ x} @ x}/(2*Diff{P - k*x/(1 + k*x/N_u) @ x})}
#: C = k/(Nᵤ + k·d); en la solución d = 60 mm, C = 20/(300 + 1200) = 1/75 1/mm. Error eₖ = 60 − dₖ y la razón eₖ₊₁/eₖ²:
C_75 = 20/(300 + 20*60) 'C en d = 60 mm [1/mm]
e_v = 1*[60 - 0; 60 - h_1; 60 - h_2; 60 - h_3; 60 - h_4; 60 - h_5; 60 - h_6] 'error eₖ [mm]
c_v = 1*[(60 - h_1)/60^2; (60 - h_2)/(60 - h_1)^2; (60 - h_3)/(60 - h_2)^2; (60 - h_4)/(60 - h_3)^2; (60 - h_5)/(60 - h_4)^2; (60 - h_6)/(60 - h_5)^2] 'eₖ₊₁/eₖ² [1/mm]
#: En esta ley la razón es **exactamente 1/75 en todas las vueltas**: eₖ₊₁ = eₖ²/75 (60 → 48 → 30.72 → 12.58 → 2.111 → 0.0594 → 0.0000471 mm). Al principio, con eₖ cerca de 75 mm, el error apenas baja; cuando eₖ es chico, **los decimales correctos se duplican** en cada vuelta. En escala logarítmica (eje horizontal: la vuelta; vertical: log₁₀ del error en mm):
H_e = [0, log10(60); 1, log10(60 - h_1); 2, log10(60 - h_2); 3, log10(60 - h_3); 4, log10(60 - h_4); 5, log10(60 - h_5); 6, log10(60 - h_6)] 'log₁₀ eₖ
#fplot(error = H_e, [0 6])
#: **Varias incógnitas: la misma deducción con vectores.** R(uₖ + Δ u) ≈ Rₖ + (∂R/∂u)·Δ u = Rₖ − Kₜ·Δ u = 0 ⇒ **Kₜ·Δ u = R**, con Kₜ = ∂fᵢₙₜ/∂u (el jacobiano; en elementos finitos Kₜ = ∫ Bᵀ·Eₜ·B dV). Con los dos elementos de la sección 4, cada residuo es una superficie sobre (u₁, u₂) y su tangente es un **plano**. En u = (0, 0): R₁ ≈ 90 − 40·u₁ + 20·u₂ y R₂ ≈ 150 + 20·u₁ − 20·u₂. Donde los dos planos cortan el cero a la vez está el paso:
K_u0 = 1*[40, -20; -20, 20] 'Kₜ en u = 0 [kN/mm]
U_1 = lsolve(K_u0, [90; 150]) 'Δu de la vuelta 1 [mm]
#: La superficie R₁(u₁, u₂), su plano tangente en (0, 0) y el plano tangente de R₂ (arrastra para girar; x = u₁, y = u₂ en mm, vertical en kN). El punto (12, 19.5, 0) es donde los dos planos cortan el cero:
#surf(R_1 = 90 - 20*x/(1 + 20*abs(x)/300) + 20*(y - x)/(1 + 20*abs(y - x)/200), plano_1 = 90 - 40*x + 20*y, plano_2 = 150 + 20*x - 20*y, cero = 0, [0 20], [0 30], punto = [12 19.5 0])
#: **Cuándo falla.** (a) Si se empieza lejos, donde la tangente es casi horizontal, el corte con el cero cae muy lejos: desde d₀ = 200 mm, kₜ = 0.097 kN/mm y Δ d = −401 mm; la vuelta siguiente salta a 5198 mm y diverge (con eₖ₊₁ = eₖ²/75, si el error pasa de 75 mm el primer paso no acerca):
j_0 = 200 'd₀ [mm]
j_1 = j_0 + G_r(j_0)/G_t(j_0) 'd₁ [mm]
j_2 = j_1 + G_r(j_1)/G_t(j_1) 'd₂: diverge [mm]
#: (b) Si la carga llega al techo, P = Nᵤ = 300 kN, no hay solución: cada vuelta d se duplica (15, 45, 105, 225, 465 mm…), R se divide entre 2 y kₜ → 0. Por eso los programas **cargan por escalones** (cada escalón empieza donde convergió el anterior) y, para pasar un pico, usan **longitud de arco** (se controla el largo del paso, no la carga).

## 2 · 1 GDL con números: siete vueltas
E_y = 60000 'módulo E [kPa]
A_s = 1 'área de la sección 1 × 1 [m²]
L_e = 3 'largo del elemento [m]
k_0 = E_y*A_s/L_e/1000 'k = EA/L [kN/mm]
N_u = 300 'fuerza máxima del elemento 1 [kN]
P_1 = 240 'carga en la punta [kN]
F_a(x) = k_0*x/(1 + k_0*abs(x)/N_u) 'fuerza de la barra con alargamiento x [kN]
T_a(x) = k_0/(1 + k_0*abs(x)/N_u)^2 'rigidez tangente [kN/mm]
s_u = N_u/A_s 'resistencia σᵤ = Nᵤ/A [kPa]
d_0 = 0 'u inicial [mm]
#: **Vuelta 1, paso a paso** (u = d_0 mm). Paso 2, en cada punto de Gauss (todos iguales: la cara está atada):
epsilon_g = d_0/1000/L_e 'ε = u/L [-]
sigma_g = E_y*epsilon_g/(1 + E_y*abs(epsilon_g)/s_u) 'σ(ε) con la ley que se ablanda [kPa]
E_tg = E_y/(1 + E_y*abs(epsilon_g)/s_u)^2 'módulo tangente Eₜ = dσ/dε [kPa]
#: Paso 3 y 5 con cada elemento. **Barra 1D** (2 puntos de Gauss, peso 1, det J = L/2):
f_bar = 2*(1/L_e)*sigma_g*A_s*(L_e/2) 'fᵢₙₜ = Σ B·σ·A·det J [kN]
k_bar = 2*(1/L_e)*E_tg*(1/L_e)*A_s*(L_e/2)/1000 'Kₜ = Σ B·Eₜ·B·A·det J [kN/mm]
#: **Área Q4** (4 puntos, det J = (L/2)(h/2), espesor 1 m):
f_quad = 4*(1/L_e)*sigma_g*1*(L_e/2)*(1/2) 'fᵢₙₜ [kN]
k_quad = 4*(1/L_e)*E_tg*(1/L_e)*1*(L_e/2)*(1/2)/1000 'Kₜ [kN/mm]
#: **Sólido H8** (8 puntos, det J = (L/2)(b/2)(h/2)):
f_hex = 8*(1/L_e)*sigma_g*(L_e/2)*(1/2)*(1/2) 'fᵢₙₜ [kN]
k_hex = 8*(1/L_e)*E_tg*(1/L_e)*(L_e/2)*(1/2)*(1/2)/1000 'Kₜ [kN/mm]
#: Los tres dan lo mismo. Pasos 3 a 6:
R_g = P_1 - f_bar 'R = F − fᵢₙₜ [kN]
D_g = R_g/k_bar 'Δu = R/Kₜ [mm]
u_g = d_0 + D_g 'u nuevo = u + Δu [mm]
d_1 = u_g 'u₁ [mm]
#: **Vuelta 2, paso a paso** (u = d_1 mm). Paso 2, en cada punto de Gauss (todos iguales: la cara está atada):
epsilon_g = d_1/1000/L_e 'ε = u/L [-]
sigma_g = E_y*epsilon_g/(1 + E_y*abs(epsilon_g)/s_u) 'σ(ε) con la ley que se ablanda [kPa]
E_tg = E_y/(1 + E_y*abs(epsilon_g)/s_u)^2 'módulo tangente Eₜ = dσ/dε [kPa]
#: Paso 3 y 5 con cada elemento. **Barra 1D** (2 puntos de Gauss, peso 1, det J = L/2):
f_bar = 2*(1/L_e)*sigma_g*A_s*(L_e/2) 'fᵢₙₜ = Σ B·σ·A·det J [kN]
k_bar = 2*(1/L_e)*E_tg*(1/L_e)*A_s*(L_e/2)/1000 'Kₜ = Σ B·Eₜ·B·A·det J [kN/mm]
#: **Área Q4** (4 puntos, det J = (L/2)(h/2), espesor 1 m):
f_quad = 4*(1/L_e)*sigma_g*1*(L_e/2)*(1/2) 'fᵢₙₜ [kN]
k_quad = 4*(1/L_e)*E_tg*(1/L_e)*1*(L_e/2)*(1/2)/1000 'Kₜ [kN/mm]
#: **Sólido H8** (8 puntos, det J = (L/2)(b/2)(h/2)):
f_hex = 8*(1/L_e)*sigma_g*(L_e/2)*(1/2)*(1/2) 'fᵢₙₜ [kN]
k_hex = 8*(1/L_e)*E_tg*(1/L_e)*(L_e/2)*(1/2)*(1/2)/1000 'Kₜ [kN/mm]
#: Los tres dan lo mismo. Pasos 3 a 6:
R_g = P_1 - f_bar 'R = F − fᵢₙₜ [kN]
D_g = R_g/k_bar 'Δu = R/Kₜ [mm]
u_g = d_1 + D_g 'u nuevo = u + Δu [mm]
#: Las 7 vueltas seguidas (paso 2 a 6 en una línea cada uno):
q_0 = P_1 - F_a(d_0) 'residuo R = P − N [kN]
d_1 = d_0 + q_0/T_a(d_0) 'u nuevo = u + R/kₜ [mm]
q_1 = P_1 - F_a(d_1) 'residuo R = P − N [kN]
d_2 = d_1 + q_1/T_a(d_1) 'u nuevo = u + R/kₜ [mm]
q_2 = P_1 - F_a(d_2) 'residuo R = P − N [kN]
d_3 = d_2 + q_2/T_a(d_2) 'u nuevo = u + R/kₜ [mm]
q_3 = P_1 - F_a(d_3) 'residuo R = P − N [kN]
d_4 = d_3 + q_3/T_a(d_3) 'u nuevo = u + R/kₜ [mm]
q_4 = P_1 - F_a(d_4) 'residuo R = P − N [kN]
d_5 = d_4 + q_4/T_a(d_4) 'u nuevo = u + R/kₜ [mm]
q_5 = P_1 - F_a(d_5) 'residuo R = P − N [kN]
d_6 = d_5 + q_5/T_a(d_5) 'u nuevo = u + R/kₜ [mm]
q_6 = P_1 - F_a(d_6) 'residuo R = P − N [kN]
d_7 = d_6 + q_6/T_a(d_6) 'u nuevo = u + R/kₜ [mm]
q_7 = P_1 - F_a(d_7) 'residuo final [kN]
#: **u = 60 mm en 7 vueltas** (lo lineal diría 12 mm: cinco veces menos). ¿Y el área y el sólido? Con el ensamblado completo (Q4 con 2 × 2 puntos de Gauss, H8 con 2 × 2 × 2) y la cara atada, el residuo es **idéntico** vuelta a vuelta (juez numpy; y Hekatan OpenSees da 60.0000 mm con el elemento truss):
i_t = [0; 1; 2; 3; 4; 5; 6; 7] 'vuelta [-]
R_1D = [240; 106.667; 41.626; 12.0956; 1.73776; 0.0475746; 3.76626e-05; 2.359e-11] '|R| con el elemento 1D (juez) [kN]
R_2D = [240; 106.667; 41.626; 12.0956; 1.73776; 0.0475746; 3.76626e-05; 2.36469e-11] '|R| con el elemento 2D (juez) [kN]
R_3D = [240; 106.667; 41.626; 12.0956; 1.73776; 0.0475746; 3.76626e-05; 2.36469e-11] '|R| con el elemento 3D (juez) [kN]
#tabla("vuelta:0","barra 1D |R| [kN]:4","Q4 2D |R| [kN]:4","H8 3D |R| [kN]:4")(i_t; R_1D; R_2D; R_3D)
#: **La tangente que avanza** (gráfica dinámica): mueve n = el punto donde se toma la recta tangente; donde corta la carga P = 240 kN está el siguiente u (eje horizontal: u en mm; vertical: kN):
#slider fplot(barra = 20*x/(1 + 20*x/300), carga = 240 + 0*x, tangente = 20*n/(1 + 20*n/300) + 20/(1 + 20*n/300)^2*(x - n), [0 80]), n = 0:2:60
Z_z = [d_0, 0; d_1, P_1; d_1, F_a(d_1); d_2, P_1; d_2, F_a(d_2); d_3, P_1; d_3, F_a(d_3); d_4, P_1; d_4, F_a(d_4); d_5, P_1; d_5, F_a(d_5); d_6, P_1; d_6, F_a(d_6)] 'zigzag de Newton (u, N)
#fplot(Newton = Z_z, [0 80])

## 3 · ¿Y si ν ≠ 0? Lo que cambia en 2D y 3D
#: La barra 1D no sabe de Poisson. El área y el sólido sí: al estirarse **se adelgazan** de costado. Si se los deja adelgazar (lados libres), la rigidez sigue siendo **E·A/L** (tensión uniaxial). Si los lados están **restringidos**, el material no puede contraerse y se pone más rígido:
k_libre = Simplify{E*A/L}
k_plano = Simplify{E/(1 - nu^2)*A/L}
k_edom = Simplify{E*(1 - nu)/((1 + nu)*(1 - 2*nu))*A/L}
#: (2D en tensión plana con el lado fijo: E/(1 − ν²). 3D con los dos lados fijos: el **módulo edométrico**, el del ensayo de consolidación.) Con ν = 0.3 (juez numpy y Hekatan OpenSees quad/stdBrick dan lo mismo):
n_p = 0.3 'Poisson [-]
k_l = k_0 'lados libres (1D, 2D, 3D) [kN/mm]
k_p = k_0/(1 - n_p^2) '2D, lado restringido [kN/mm]
k_m = k_0*(1 - n_p)/((1 + n_p)*(1 - 2*n_p)) '3D, lados restringidos [kN/mm]
#: Las tres rigideces contra ν (eje horizontal: ν; vertical: kN/mm). Con ν = 0 coinciden; con ν → 0.5 el edométrico se dispara (el material casi no cambia de volumen):
#fplot(libre = 20 + 0*x, plano = 20/(1 - x^2), edometrico = 20*(1 - x)/((1 + x)*(1 - 2*x)), [0 0.45])
#: **Para comparar Newton en 1D, 2D y 3D se usa ν = 0** (y la ley uniaxial en ε_x): así los tres modelos son el mismo problema.

## 4 · 2 GDL: dos elementos en serie
#dibujo("Dos elementos en serie: incógnitas u₁ (nudo 2) y u₂ (nudo 3)", ud = m, escala = auto, cotas = m, alto = 60)
#  achurado([-0.4, 0, 0, -0.4], [-0.6, -0.6, 0.6, 0.6], "suelo")
#  linea(0, 0, 6, 0, "gruesa")
#  circulo(0, 0, 0.09, "negro")
#  circulo(3, 0, 0.09, "negro")
#  circulo(6, 0, 0.09, "negro")
#  flecha(3, 0.5, 3.9, 0.5, "gruesa rojo")
#  flecha(6, 0, 6.9, 0, "gruesa rojo")
#  texto(3.5, 0.95, "90 kN", 2.4, "c")
#  texto(6.5, 0.45, "150 kN", 2.4, "c")
#  texto(1.5, -0.45, "e1: Nu = 300 kN", 2.2, "c")
#  texto(4.5, -0.45, "e2: Nu = 200 kN", 2.2, "c")
#  texto(3, -0.95, "u₁", 2.4, "c")
#  texto(6, -0.95, "u₂", 2.4, "c")
#fin
#: Cada elemento usa las mismas funciones de forma (1D, Q4 o H8) y se **ensambla**: el elemento 1 se alarga δ₁ = u₁ y el 2, δ₂ = u₂ − u₁. Las fuerzas internas en los nudos 2 y 3 (con S₁ y S₂ = la fuerza máxima de cada elemento):
f_2s = Simplify{[k*u_1/(1 + k*u_1/S_1) - k*(u_2 - u_1)/(1 + k*(u_2 - u_1)/S_2); k*(u_2 - u_1)/(1 + k*(u_2 - u_1)/S_2)]}
#: La matriz tangente es la derivada de cada fuerza respecto de cada incógnita (el motor deriva):
g_11 = Simplify{Diff{k*u_1/(1 + k*u_1/S_1) - k*(u_2 - u_1)/(1 + k*(u_2 - u_1)/S_2) @ u_1}}
g_12 = Simplify{Diff{k*u_1/(1 + k*u_1/S_1) - k*(u_2 - u_1)/(1 + k*(u_2 - u_1)/S_2) @ u_2}}
g_22 = Simplify{Diff{k*(u_2 - u_1)/(1 + k*(u_2 - u_1)/S_2) @ u_2}}
#: Es decir **Kₜ = [t₁ + t₂, −t₂; −t₂, t₂]**: cada elemento pone su tₑ = k/(1 + k·δₑ/Sₑ)² en su lugar (el ensamblado). Y el paso: Kₜ·Δ u = R.
F_b(x) = k_0*x/(1 + k_0*abs(x)/200) 'fuerza del elemento con Nu = 200 kN [kN]
T_b(x) = k_0/(1 + k_0*abs(x)/200)^2 'su rigidez tangente [kN/mm]
Q_2(x, y) = [F_a(x) - F_b(y - x); F_b(y - x)] 'fuerzas internas [kN]
K_2(x, y) = [T_a(x) + T_b(y - x), -T_b(y - x); -T_b(y - x), T_b(y - x)] 'matriz tangente [kN/mm]
F_2 = [90; 150] 'cargas en los nudos 2 y 3 [kN]
v_0 = [0; 0] 'u inicial [mm]
#: **Vuelta 1, paso a paso** (u = v_0 en mm). Paso 2, deformación de cada elemento (igual en todos sus puntos de Gauss):
epsilon_1 = v_0(1)/1000/L_e 'ε del elemento 1 = (u_j − u_i)/L [-]
sigma_1 = E_y*epsilon_1/(1 + E_y*abs(epsilon_1)/300) 'σ(ε), σᵤ = 300 kPa [kPa]
E_t1 = E_y/(1 + E_y*abs(epsilon_1)/300)^2 'Eₜ = dσ/dε [kPa]
epsilon_2 = (v_0(2) - v_0(1))/1000/L_e 'ε del elemento 2 = (u_j − u_i)/L [-]
sigma_2 = E_y*epsilon_2/(1 + E_y*abs(epsilon_2)/200) 'σ(ε), σᵤ = 200 kPa [kPa]
E_t2 = E_y/(1 + E_y*abs(epsilon_2)/200)^2 'Eₜ = dσ/dε [kPa]
#: Fuerza y rigidez de cada elemento con la suma de Gauss (1D: 2 puntos · Q4: 4 · H8: 8; las tres dan lo mismo):
N_bar1 = 2*(1/L_e)*sigma_1*A_s*(L_e/2) 'barra 1D [kN]
N_quad1 = 4*(1/L_e)*sigma_1*(L_e/2)*(1/2) 'Q4 [kN]
N_hex1 = 8*(1/L_e)*sigma_1*(L_e/2)*(1/2)*(1/2) 'H8 [kN]
r_bar1 = 2*(1/L_e)*E_t1*(1/L_e)*A_s*(L_e/2)/1000 'kₜ del elemento 1 (igual en Q4 y H8) [kN/mm]
N_bar2 = 2*(1/L_e)*sigma_2*A_s*(L_e/2) 'barra 1D [kN]
N_quad2 = 4*(1/L_e)*sigma_2*(L_e/2)*(1/2) 'Q4 [kN]
N_hex2 = 8*(1/L_e)*sigma_2*(L_e/2)*(1/2)*(1/2) 'H8 [kN]
r_bar2 = 2*(1/L_e)*E_t2*(1/L_e)*A_s*(L_e/2)/1000 'kₜ del elemento 2 (igual en Q4 y H8) [kN/mm]
f_v = 1*[N_bar1 - N_bar2; N_bar2] 'paso 3: fᵢₙₜ ensamblada [kN]
K_m = 1*[r_bar1 + r_bar2, -r_bar2; -r_bar2, r_bar2] 'paso 5: Kₜ ensamblada [kN/mm]
R_v = F_2 - f_v 'R = F − fᵢₙₜ [kN]
n_v = sqrt(R_v(1)^2 + R_v(2)^2) '|R| [kN]
D_v = lsolve(K_m, R_v) 'resolver Kₜ·Δu = R [mm]
u_v = v_0 + D_v 'paso 6: u nuevo = u + Δu [mm]
v_1 = u_v 'u₁ [mm]
#: **Vuelta 2, paso a paso** (u = v_1 en mm). Paso 2, deformación de cada elemento (igual en todos sus puntos de Gauss):
epsilon_1 = v_1(1)/1000/L_e 'ε del elemento 1 = (u_j − u_i)/L [-]
sigma_1 = E_y*epsilon_1/(1 + E_y*abs(epsilon_1)/300) 'σ(ε), σᵤ = 300 kPa [kPa]
E_t1 = E_y/(1 + E_y*abs(epsilon_1)/300)^2 'Eₜ = dσ/dε [kPa]
epsilon_2 = (v_1(2) - v_1(1))/1000/L_e 'ε del elemento 2 = (u_j − u_i)/L [-]
sigma_2 = E_y*epsilon_2/(1 + E_y*abs(epsilon_2)/200) 'σ(ε), σᵤ = 200 kPa [kPa]
E_t2 = E_y/(1 + E_y*abs(epsilon_2)/200)^2 'Eₜ = dσ/dε [kPa]
#: Fuerza y rigidez de cada elemento con la suma de Gauss (1D: 2 puntos · Q4: 4 · H8: 8; las tres dan lo mismo):
N_bar1 = 2*(1/L_e)*sigma_1*A_s*(L_e/2) 'barra 1D [kN]
N_quad1 = 4*(1/L_e)*sigma_1*(L_e/2)*(1/2) 'Q4 [kN]
N_hex1 = 8*(1/L_e)*sigma_1*(L_e/2)*(1/2)*(1/2) 'H8 [kN]
r_bar1 = 2*(1/L_e)*E_t1*(1/L_e)*A_s*(L_e/2)/1000 'kₜ del elemento 1 (igual en Q4 y H8) [kN/mm]
N_bar2 = 2*(1/L_e)*sigma_2*A_s*(L_e/2) 'barra 1D [kN]
N_quad2 = 4*(1/L_e)*sigma_2*(L_e/2)*(1/2) 'Q4 [kN]
N_hex2 = 8*(1/L_e)*sigma_2*(L_e/2)*(1/2)*(1/2) 'H8 [kN]
r_bar2 = 2*(1/L_e)*E_t2*(1/L_e)*A_s*(L_e/2)/1000 'kₜ del elemento 2 (igual en Q4 y H8) [kN/mm]
f_v = 1*[N_bar1 - N_bar2; N_bar2] 'paso 3: fᵢₙₜ ensamblada [kN]
K_m = 1*[r_bar1 + r_bar2, -r_bar2; -r_bar2, r_bar2] 'paso 5: Kₜ ensamblada [kN/mm]
R_v = F_2 - f_v 'R = F − fᵢₙₜ [kN]
n_v = sqrt(R_v(1)^2 + R_v(2)^2) '|R| [kN]
D_v = lsolve(K_m, R_v) 'resolver Kₜ·Δu = R [mm]
u_v = v_1 + D_v 'paso 6: u nuevo = u + Δu [mm]
#: Las 7 vueltas seguidas:
r_0 = F_2 - Q_2(v_0(1), v_0(2)) 'R = F − fᵢₙₜ [kN]
n_0 = sqrt(r_0(1)^2 + r_0(2)^2) '|R| [kN]
w_0 = lsolve(K_2(v_0(1), v_0(2)), r_0) 'Δu de Kₜ·Δu = R [mm]
v_1 = v_0 + w_0 'u nuevo [mm]
r_1 = F_2 - Q_2(v_1(1), v_1(2)) 'R = F − fᵢₙₜ [kN]
n_1 = sqrt(r_1(1)^2 + r_1(2)^2) '|R| [kN]
w_1 = lsolve(K_2(v_1(1), v_1(2)), r_1) 'Δu de Kₜ·Δu = R [mm]
v_2 = v_1 + w_1 'u nuevo [mm]
r_2 = F_2 - Q_2(v_2(1), v_2(2)) 'R = F − fᵢₙₜ [kN]
n_2 = sqrt(r_2(1)^2 + r_2(2)^2) '|R| [kN]
w_2 = lsolve(K_2(v_2(1), v_2(2)), r_2) 'Δu de Kₜ·Δu = R [mm]
v_3 = v_2 + w_2 'u nuevo [mm]
r_3 = F_2 - Q_2(v_3(1), v_3(2)) 'R = F − fᵢₙₜ [kN]
n_3 = sqrt(r_3(1)^2 + r_3(2)^2) '|R| [kN]
w_3 = lsolve(K_2(v_3(1), v_3(2)), r_3) 'Δu de Kₜ·Δu = R [mm]
v_4 = v_3 + w_3 'u nuevo [mm]
r_4 = F_2 - Q_2(v_4(1), v_4(2)) 'R = F − fᵢₙₜ [kN]
n_4 = sqrt(r_4(1)^2 + r_4(2)^2) '|R| [kN]
w_4 = lsolve(K_2(v_4(1), v_4(2)), r_4) 'Δu de Kₜ·Δu = R [mm]
v_5 = v_4 + w_4 'u nuevo [mm]
r_5 = F_2 - Q_2(v_5(1), v_5(2)) 'R = F − fᵢₙₜ [kN]
n_5 = sqrt(r_5(1)^2 + r_5(2)^2) '|R| [kN]
w_5 = lsolve(K_2(v_5(1), v_5(2)), r_5) 'Δu de Kₜ·Δu = R [mm]
v_6 = v_5 + w_5 'u nuevo [mm]
r_6 = F_2 - Q_2(v_6(1), v_6(2)) 'R = F − fᵢₙₜ [kN]
n_6 = sqrt(r_6(1)^2 + r_6(2)^2) '|R| [kN]
w_6 = lsolve(K_2(v_6(1), v_6(2)), r_6) 'Δu de Kₜ·Δu = R [mm]
v_7 = v_6 + w_6 'u nuevo [mm]
r_7 = F_2 - Q_2(v_7(1), v_7(2)) 'residuo final [kN]
#: **u₁ = 60 mm, u₂ = 90 mm en 7 vueltas** (el elemento 2 se alarga 30 mm). Con Q4 y H8 el juez da el mismo residuo vuelta a vuelta (175 → 77 → 29.6 → 8.58 → 1.33 → 0.043 → 3.7·10⁻⁵ → 2.4·10⁻¹¹ kN); Hekatan OpenSees (truss): 60.0000 y 90.0000 mm.
#: **El mapa del residuo**: para cada (u₁, u₂), cuánto falta. Primero en 3D (x = u₁, y = u₂ en mm), luego en planta:
R_2n(x, y) = sqrt((90 - F_a(x) + F_b(y - x))^2 + (150 - F_b(y - x))^2) '|R| [kN]
#surf(R_2n(x, y), [0 80], [0 120])
#map(R_2n(x, y), [0 80], [0 120])
o_1 = [v_0(1); v_1(1); v_2(1); v_3(1); v_4(1); v_5(1); v_6(1); v_7(1)] 'u₁ por vuelta [mm]
o_2 = [v_0(2); v_1(2); v_2(2); v_3(2); v_4(2); v_5(2); v_6(2); v_7(2)] 'u₂ por vuelta [mm]
o_n = [n_0; n_1; n_2; n_3; n_4; n_5; n_6; 0] '|R| por vuelta [kN]
g_x = o_1/8 'posición en el dibujo [-]
g_y = o_2/8 'posición en el dibujo [-]
#dibujo("El camino de Newton en el plano u₁–u₂ (mm)", ud = m, escala = auto, alto = 80)
#  flecha(0, 0, 11, 0, "fina")
#  flecha(0, 0, 0, 13.5, "fina")
#  texto(11, -0.5, "u₁ [mm]", 2.2, "c")
#  texto(0.3, 13.8, "u₂ [mm]", 2.2, "i")
#  texto(2.500, -0.5, "20", 2.0, "c")
#  texto(5.000, -0.5, "40", 2.0, "c")
#  texto(7.500, -0.5, "60", 2.0, "c")
#  texto(10.000, -0.5, "80", 2.0, "c")
#  texto(-0.7, 3.750, "30", 2.0, "c")
#  texto(-0.7, 7.500, "60", 2.0, "c")
#  texto(-0.7, 11.250, "90", 2.0, "c")
#  flecha(0.000, 0.000, 1.500, 2.438, "media rojo")
#  flecha(1.500, 2.438, 3.660, 5.828, "media rojo")
#  flecha(3.660, 5.828, 5.927, 9.177, "media rojo")
#  flecha(5.927, 9.177, 7.236, 10.936, "media rojo")
#  flecha(7.236, 10.936, 7.493, 11.242, "media rojo")
#  flecha(7.493, 11.242, 7.500, 11.250, "media rojo")
#  circulo(0.000, 0.000, 0.09, "rojo relleno")
#  circulo(1.500, 2.438, 0.09, "rojo relleno")
#  circulo(3.660, 5.828, 0.09, "rojo relleno")
#  circulo(5.927, 9.177, 0.09, "rojo relleno")
#  circulo(7.236, 10.936, 0.09, "rojo relleno")
#  circulo(7.500, 11.250, 0.15, "verde relleno")
#  texto(6.000, 11.950, "solución (60, 90)", 2.2, "c")
#  hover(g_x, g_y, "u₁ = {#1:4} mm, u₂ = {#2:4} mm, |R| = {#3:4} kN", o_1, o_2, o_n)
#fin

## 5 · 3 GDL: tres elementos en serie
#: Tres elementos (fuerzas máximas 300, 250 y 200 kN), cargas 40, 50 y 150 kN en los nudos 2, 3 y 4. Con tres incógnitas, Kₜ es **3 × 3 y tridiagonal**: cada elemento solo toca a sus dos nudos. Con símbolos (t₁, t₂, t₃ = rigidez tangente de cada elemento):
K_3s = Simplify{[t_1 + t_2, -t_2, 0; -t_2, t_2 + t_3, -t_3; 0, -t_3, t_3]}
#: (Se arma igual que antes: el elemento e suma tₑ·[1, −1; −1, 1] en las filas y columnas de sus nudos.)
F_c(x) = k_0*x/(1 + k_0*abs(x)/250) 'fuerza del elemento con Nu = 250 kN [kN]
T_c(x) = k_0/(1 + k_0*abs(x)/250)^2 'su rigidez tangente [kN/mm]
Q_3(x, y, z) = [F_a(x) - F_c(y - x); F_c(y - x) - F_b(z - y); F_b(z - y)] 'fuerzas internas [kN]
K_3(x, y, z) = [T_a(x) + T_c(y - x), -T_c(y - x), 0; -T_c(y - x), T_c(y - x) + T_b(z - y), -T_b(z - y); 0, -T_b(z - y), T_b(z - y)] 'matriz tangente [kN/mm]
F_3 = [40; 50; 150] 'cargas [kN]
y_0 = [0; 0; 0] 'u inicial [mm]
#: **Vuelta 1, paso a paso** (u = y_0 en mm). Paso 2, deformación de cada elemento (igual en todos sus puntos de Gauss):
epsilon_1 = y_0(1)/1000/L_e 'ε del elemento 1 = (u_j − u_i)/L [-]
sigma_1 = E_y*epsilon_1/(1 + E_y*abs(epsilon_1)/300) 'σ(ε), σᵤ = 300 kPa [kPa]
E_t1 = E_y/(1 + E_y*abs(epsilon_1)/300)^2 'Eₜ = dσ/dε [kPa]
epsilon_2 = (y_0(2) - y_0(1))/1000/L_e 'ε del elemento 2 = (u_j − u_i)/L [-]
sigma_2 = E_y*epsilon_2/(1 + E_y*abs(epsilon_2)/250) 'σ(ε), σᵤ = 250 kPa [kPa]
E_t2 = E_y/(1 + E_y*abs(epsilon_2)/250)^2 'Eₜ = dσ/dε [kPa]
epsilon_3 = (y_0(3) - y_0(2))/1000/L_e 'ε del elemento 3 = (u_j − u_i)/L [-]
sigma_3 = E_y*epsilon_3/(1 + E_y*abs(epsilon_3)/200) 'σ(ε), σᵤ = 200 kPa [kPa]
E_t3 = E_y/(1 + E_y*abs(epsilon_3)/200)^2 'Eₜ = dσ/dε [kPa]
#: Fuerza y rigidez de cada elemento con la suma de Gauss (1D: 2 puntos · Q4: 4 · H8: 8; las tres dan lo mismo):
N_bar1 = 2*(1/L_e)*sigma_1*A_s*(L_e/2) 'barra 1D [kN]
N_quad1 = 4*(1/L_e)*sigma_1*(L_e/2)*(1/2) 'Q4 [kN]
N_hex1 = 8*(1/L_e)*sigma_1*(L_e/2)*(1/2)*(1/2) 'H8 [kN]
r_bar1 = 2*(1/L_e)*E_t1*(1/L_e)*A_s*(L_e/2)/1000 'kₜ del elemento 1 (igual en Q4 y H8) [kN/mm]
N_bar2 = 2*(1/L_e)*sigma_2*A_s*(L_e/2) 'barra 1D [kN]
N_quad2 = 4*(1/L_e)*sigma_2*(L_e/2)*(1/2) 'Q4 [kN]
N_hex2 = 8*(1/L_e)*sigma_2*(L_e/2)*(1/2)*(1/2) 'H8 [kN]
r_bar2 = 2*(1/L_e)*E_t2*(1/L_e)*A_s*(L_e/2)/1000 'kₜ del elemento 2 (igual en Q4 y H8) [kN/mm]
N_bar3 = 2*(1/L_e)*sigma_3*A_s*(L_e/2) 'barra 1D [kN]
N_quad3 = 4*(1/L_e)*sigma_3*(L_e/2)*(1/2) 'Q4 [kN]
N_hex3 = 8*(1/L_e)*sigma_3*(L_e/2)*(1/2)*(1/2) 'H8 [kN]
r_bar3 = 2*(1/L_e)*E_t3*(1/L_e)*A_s*(L_e/2)/1000 'kₜ del elemento 3 (igual en Q4 y H8) [kN/mm]
f_v = 1*[N_bar1 - N_bar2; N_bar2 - N_bar3; N_bar3] 'paso 3: fᵢₙₜ ensamblada [kN]
K_m = 1*[r_bar1 + r_bar2, -r_bar2, 0; -r_bar2, r_bar2 + r_bar3, -r_bar3; 0, -r_bar3, r_bar3] 'paso 5: Kₜ ensamblada [kN/mm]
R_v = F_3 - f_v 'R = F − fᵢₙₜ [kN]
n_v = sqrt(R_v(1)^2 + R_v(2)^2 + R_v(3)^2) '|R| [kN]
D_v = lsolve(K_m, R_v) 'resolver Kₜ·Δu = R [mm]
u_v = y_0 + D_v 'paso 6: u nuevo = u + Δu [mm]
y_1 = u_v 'u₁ [mm]
#: **Vuelta 2, paso a paso** (u = y_1 en mm). Paso 2, deformación de cada elemento (igual en todos sus puntos de Gauss):
epsilon_1 = y_1(1)/1000/L_e 'ε del elemento 1 = (u_j − u_i)/L [-]
sigma_1 = E_y*epsilon_1/(1 + E_y*abs(epsilon_1)/300) 'σ(ε), σᵤ = 300 kPa [kPa]
E_t1 = E_y/(1 + E_y*abs(epsilon_1)/300)^2 'Eₜ = dσ/dε [kPa]
epsilon_2 = (y_1(2) - y_1(1))/1000/L_e 'ε del elemento 2 = (u_j − u_i)/L [-]
sigma_2 = E_y*epsilon_2/(1 + E_y*abs(epsilon_2)/250) 'σ(ε), σᵤ = 250 kPa [kPa]
E_t2 = E_y/(1 + E_y*abs(epsilon_2)/250)^2 'Eₜ = dσ/dε [kPa]
epsilon_3 = (y_1(3) - y_1(2))/1000/L_e 'ε del elemento 3 = (u_j − u_i)/L [-]
sigma_3 = E_y*epsilon_3/(1 + E_y*abs(epsilon_3)/200) 'σ(ε), σᵤ = 200 kPa [kPa]
E_t3 = E_y/(1 + E_y*abs(epsilon_3)/200)^2 'Eₜ = dσ/dε [kPa]
#: Fuerza y rigidez de cada elemento con la suma de Gauss (1D: 2 puntos · Q4: 4 · H8: 8; las tres dan lo mismo):
N_bar1 = 2*(1/L_e)*sigma_1*A_s*(L_e/2) 'barra 1D [kN]
N_quad1 = 4*(1/L_e)*sigma_1*(L_e/2)*(1/2) 'Q4 [kN]
N_hex1 = 8*(1/L_e)*sigma_1*(L_e/2)*(1/2)*(1/2) 'H8 [kN]
r_bar1 = 2*(1/L_e)*E_t1*(1/L_e)*A_s*(L_e/2)/1000 'kₜ del elemento 1 (igual en Q4 y H8) [kN/mm]
N_bar2 = 2*(1/L_e)*sigma_2*A_s*(L_e/2) 'barra 1D [kN]
N_quad2 = 4*(1/L_e)*sigma_2*(L_e/2)*(1/2) 'Q4 [kN]
N_hex2 = 8*(1/L_e)*sigma_2*(L_e/2)*(1/2)*(1/2) 'H8 [kN]
r_bar2 = 2*(1/L_e)*E_t2*(1/L_e)*A_s*(L_e/2)/1000 'kₜ del elemento 2 (igual en Q4 y H8) [kN/mm]
N_bar3 = 2*(1/L_e)*sigma_3*A_s*(L_e/2) 'barra 1D [kN]
N_quad3 = 4*(1/L_e)*sigma_3*(L_e/2)*(1/2) 'Q4 [kN]
N_hex3 = 8*(1/L_e)*sigma_3*(L_e/2)*(1/2)*(1/2) 'H8 [kN]
r_bar3 = 2*(1/L_e)*E_t3*(1/L_e)*A_s*(L_e/2)/1000 'kₜ del elemento 3 (igual en Q4 y H8) [kN/mm]
f_v = 1*[N_bar1 - N_bar2; N_bar2 - N_bar3; N_bar3] 'paso 3: fᵢₙₜ ensamblada [kN]
K_m = 1*[r_bar1 + r_bar2, -r_bar2, 0; -r_bar2, r_bar2 + r_bar3, -r_bar3; 0, -r_bar3, r_bar3] 'paso 5: Kₜ ensamblada [kN/mm]
R_v = F_3 - f_v 'R = F − fᵢₙₜ [kN]
n_v = sqrt(R_v(1)^2 + R_v(2)^2 + R_v(3)^2) '|R| [kN]
D_v = lsolve(K_m, R_v) 'resolver Kₜ·Δu = R [mm]
u_v = y_1 + D_v 'paso 6: u nuevo = u + Δu [mm]
#: Las 7 vueltas seguidas:
e_0 = F_3 - Q_3(y_0(1), y_0(2), y_0(3)) 'R [kN]
m_0 = sqrt(e_0(1)^2 + e_0(2)^2 + e_0(3)^2) '|R| [kN]
z_0 = lsolve(K_3(y_0(1), y_0(2), y_0(3)), e_0) 'Δu [mm]
y_1 = y_0 + z_0 'u nuevo [mm]
e_1 = F_3 - Q_3(y_1(1), y_1(2), y_1(3)) 'R [kN]
m_1 = sqrt(e_1(1)^2 + e_1(2)^2 + e_1(3)^2) '|R| [kN]
z_1 = lsolve(K_3(y_1(1), y_1(2), y_1(3)), e_1) 'Δu [mm]
y_2 = y_1 + z_1 'u nuevo [mm]
e_2 = F_3 - Q_3(y_2(1), y_2(2), y_2(3)) 'R [kN]
m_2 = sqrt(e_2(1)^2 + e_2(2)^2 + e_2(3)^2) '|R| [kN]
z_2 = lsolve(K_3(y_2(1), y_2(2), y_2(3)), e_2) 'Δu [mm]
y_3 = y_2 + z_2 'u nuevo [mm]
e_3 = F_3 - Q_3(y_3(1), y_3(2), y_3(3)) 'R [kN]
m_3 = sqrt(e_3(1)^2 + e_3(2)^2 + e_3(3)^2) '|R| [kN]
z_3 = lsolve(K_3(y_3(1), y_3(2), y_3(3)), e_3) 'Δu [mm]
y_4 = y_3 + z_3 'u nuevo [mm]
e_4 = F_3 - Q_3(y_4(1), y_4(2), y_4(3)) 'R [kN]
m_4 = sqrt(e_4(1)^2 + e_4(2)^2 + e_4(3)^2) '|R| [kN]
z_4 = lsolve(K_3(y_4(1), y_4(2), y_4(3)), e_4) 'Δu [mm]
y_5 = y_4 + z_4 'u nuevo [mm]
e_5 = F_3 - Q_3(y_5(1), y_5(2), y_5(3)) 'R [kN]
m_5 = sqrt(e_5(1)^2 + e_5(2)^2 + e_5(3)^2) '|R| [kN]
z_5 = lsolve(K_3(y_5(1), y_5(2), y_5(3)), e_5) 'Δu [mm]
y_6 = y_5 + z_5 'u nuevo [mm]
e_6 = F_3 - Q_3(y_6(1), y_6(2), y_6(3)) 'R [kN]
m_6 = sqrt(e_6(1)^2 + e_6(2)^2 + e_6(3)^2) '|R| [kN]
z_6 = lsolve(K_3(y_6(1), y_6(2), y_6(3)), e_6) 'Δu [mm]
y_7 = y_6 + z_6 'u nuevo [mm]
e_7 = F_3 - Q_3(y_7(1), y_7(2), y_7(3)) 'residuo final [kN]
#: **u = (60, 110, 140) mm en 7 vueltas**; Q4 y H8 dan el mismo residuo (163 → 71.1 → 26.8 → 7.44 → 1.11 → 0.036 → 3.2·10⁻⁵ → 2·10⁻¹¹ kN); Hekatan OpenSees (truss): 60.0000, 110.0000 y 140.0000 mm.
#: **La convergencia de los tres casos** (eje horizontal: la vuelta; vertical: log₁₀|R|). Los tres caen igual de rápido: al final, cada vuelta **duplica las cifras correctas**:
H_1 = [0, log10(abs(q_0)); 1, log10(abs(q_1)); 2, log10(abs(q_2)); 3, log10(abs(q_3)); 4, log10(abs(q_4)); 5, log10(abs(q_5)); 6, log10(abs(q_6)); 7, log10(abs(q_7))] '1 GDL
H_2 = [0, log10(n_0); 1, log10(n_1); 2, log10(n_2); 3, log10(n_3); 4, log10(n_4); 5, log10(n_5); 6, log10(n_6)] '2 GDL
H_3 = [0, log10(m_0); 1, log10(m_1); 2, log10(m_2); 3, log10(m_3); 4, log10(m_4); 5, log10(m_5); 6, log10(m_6)] '3 GDL
#fplot(GDL1 = H_1, GDL2 = H_2, GDL3 = H_3, [0 7])
#: El residuo en 3D cuando u₃ ya está en su valor (140 mm), en función de u₁ y u₂:
R_3n(x, y) = sqrt((40 - F_a(x) + F_c(y - x))^2 + (50 - F_c(y - x) + F_b(140 - y))^2 + (150 - F_b(140 - y))^2) '|R| [kN]
#surf(R_3n(x, y), [0 90], [40 140])

## 6 · Anexo: 2 GDL con barras inclinadas (la cercha de la hoja 196)
#: La misma barra de 2 nudos, pero **girada**: su alargamiento es la proyección del movimiento del nudo sobre la barra, δ = c·u₁ + s·u₂ (c y s = coseno y seno). Entonces Kₑ = t·[c², c·s; c·s, s²] y la cercha de dos barras con P = 300 kN y H = 30 kN da u = (−11.6921, −37.2085) mm en 7 vueltas (hoja 196, y los 7 lenguajes del video).
K_r = Simplify{t*[c^2, c*s; c*s, s^2]}

## 7 · En una línea
#: **1 incógnita: Δ u = R/kₜ. 2 o 3 incógnitas: Kₜ·Δ u = R, con Kₜ ensamblada de los elementos.** La barra, el área y el sólido dan lo mismo con ν = 0 porque sus funciones de forma, con la cara atada, se reducen a la misma recta (N₂ + N₃ = (1 + ξ)/2). Con ν ≠ 0 cambia la rigidez según lo que se deje mover a los lados (E, E/(1 − ν²) o el edométrico). Lo mismo, con miles de incógnitas y el suelo en vez del acero, es el talud de las hojas 190 y 195.
