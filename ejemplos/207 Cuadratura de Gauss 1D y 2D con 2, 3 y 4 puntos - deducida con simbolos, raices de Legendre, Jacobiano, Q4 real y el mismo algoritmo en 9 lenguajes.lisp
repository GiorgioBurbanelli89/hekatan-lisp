# Cuadratura de Gauss 1D y 2D con 2, 3 y 4 puntos - deducida con simbolos, raices de Legendre, Jacobiano, Q4 real y el mismo algoritmo en 9 lenguajes
#numerico

## 0 · La idea en una frase
#: Un computador no sabe integrar: solo suma y multiplica. La **cuadratura de Gauss** cambia la integral por una **suma de pocas alturas con su peso**: ∫₋₁¹ f(ξ) dξ ≈ Σ wᵢ·f(ξᵢ). Las preguntas son dos: **dónde** medir (los puntos ξᵢ) y **cuánto pesa** cada medida (los pesos wᵢ). Con n puntos hay 2n números libres, y con ellos se puede exigir que la suma sea **exacta** para 1, ξ, ξ², …, ξ²ⁿ⁻¹: **n puntos integran exacto cualquier polinomio de grado 2n − 1**.
#: Esta hoja va más a fondo que los videos y hojas anteriores de Gauss (que dedujeron solo n = 2 y un rectángulo): aquí se deducen **n = 2, 3 y 4** con el motor simbólico, se muestra que son las raíces de Legendre, dónde **fallan** (grado 2n), una función que no es polinomio (sin x), el **2D** en el cuadrado y en un **cuadrilátero real** (área, Iₓ y un término de la rigidez K₁₁), y el mismo algoritmo en 9 lenguajes con los mismos números a 10 decimales.
#dibujo("La idea: el área bajo f(ξ) entre −1 y +1 se cambia por 2 columnas: altura f(ξᵢ) y ancho wᵢ = 1", ud = m, escala = auto, alto = 55)
#  linea(-1.2, 0, 1.3, 0, "fina")
#  linea(-1, 0, -1, 2, "fina")
#  linea(1, 0, 1, 2, "fina")
#  linea(-1, 2, -0.9167, 1.8137, "gruesa")
#  linea(-0.9167, 1.8137, -0.8333, 1.6537, "gruesa")
#  linea(-0.8333, 1.6537, -0.75, 1.5188, "gruesa")
#  linea(-0.75, 1.5188, -0.6667, 1.4074, "gruesa")
#  linea(-0.6667, 1.4074, -0.5833, 1.3183, "gruesa")
#  linea(-0.5833, 1.3183, -0.5, 1.25, "gruesa")
#  linea(-0.5, 1.25, -0.4167, 1.2012, "gruesa")
#  linea(-0.4167, 1.2012, -0.3333, 1.1704, "gruesa")
#  linea(-0.3333, 1.1704, -0.25, 1.1562, "gruesa")
#  linea(-0.25, 1.1562, -0.1667, 1.1574, "gruesa")
#  linea(-0.1667, 1.1574, -0.0833, 1.1725, "gruesa")
#  linea(-0.0833, 1.1725, 0, 1.2, "gruesa")
#  linea(0, 1.2, 0.0833, 1.2387, "gruesa")
#  linea(0.0833, 1.2387, 0.1667, 1.287, "gruesa")
#  linea(0.1667, 1.287, 0.25, 1.3438, "gruesa")
#  linea(0.25, 1.3438, 0.3333, 1.4074, "gruesa")
#  linea(0.3333, 1.4074, 0.4167, 1.4766, "gruesa")
#  linea(0.4167, 1.4766, 0.5, 1.55, "gruesa")
#  linea(0.5, 1.55, 0.5833, 1.6262, "gruesa")
#  linea(0.5833, 1.6262, 0.6667, 1.7037, "gruesa")
#  linea(0.6667, 1.7037, 0.75, 1.7813, "gruesa")
#  linea(0.75, 1.7813, 0.8333, 1.8574, "gruesa")
#  linea(0.8333, 1.8574, 0.9167, 1.9308, "gruesa")
#  linea(0.9167, 1.9308, 1, 2, "gruesa")
#  poligono(-1.0774, 0, -0.0774, 0, -0.0774, 1.3127, -1.0774, 1.3127, "fina")
#  circulo(-0.5774, 1.3127, 0.05, "rojo")
#  circulo(-0.5774, 0, 0.04, "rojo")
#  poligono(0.0774, 0, 1.0774, 0, 1.0774, 1.6206, 0.0774, 1.6206, "fina")
#  circulo(0.5774, 1.6206, 0.05, "rojo")
#  circulo(0.5774, 0, 0.04, "rojo")
#  texto(-0.577, -0.25, "ξ₁ = −1/√3", 2.4, "c")
#  texto(0.577, -0.25, "ξ₂ = +1/√3", 2.4, "c")
#  texto(1.25, 1.75, "f(ξ)", 2.6, "c")
#fin

### 0.1 · Recordatorio: por qué basta con polinomios (Taylor)
#: Cerca de un punto, una función suave **se parece a su polinomio de Taylor** (deducido en el video «De dónde sale la fórmula de Newton-Raphson»): f(ξ) ≈ f(0) + f′(0)·ξ + f″(0)·ξ²/2! + … El motor desarrolla sin alrededor de π/2 (el centro del tramo de la sección 6), con u = x − π/2:
t_s = Taylor{cos(u) @ u = 0 : 6} 'sin(π/2 + u) = cos u
#: Si Gauss acierta **exacto** todos los términos hasta grado 2n − 1, solo se equivoca en lo que queda del desarrollo, empezando por el término de grado 2n, el que lleva **f⁽²ⁿ⁾**. Por eso funciona tan bien con funciones suaves: el error lo decide una derivada alta dividida por (2n)!.
#fplot(seno = sin(x), taylor_2 = 1 - (x - 1.5708)^2/2, taylor_4 = 1 - (x - 1.5708)^2/2 + (x - 1.5708)^4/24, [0 3.1416])

## 1 · Lo que hay que acertar: los monomios
#: Si la regla acierta con 1, ξ, ξ², ξ³, … acierta con cualquier suma de ellos (un polinomio). El motor integra cada monomio en [−c, c] (luego c = 1):
m_0 = Integral{1 @ xi = -c : c}
m_1 = Integral{xi @ xi = -c : c}
m_2 = Integral{xi^2 @ xi = -c : c}
m_3 = Integral{xi^3 @ xi = -c : c}
m_4 = Integral{xi^4 @ xi = -c : c}
#: Con c = 1: **los pares dan 2/(k + 1) y los impares dan 0** (lo de la izquierda cancela lo de la derecha). Por eso los puntos van **simétricos** (±a) con pesos iguales: así los impares salen cero solos y solo hay que acertar los pares.

## 2 · n = 2: dos puntos ±a con peso w
#: Incógnitas: a y w (2 números). La suma w·f(−a) + w·f(a) para cada monomio, que el motor expande:
s_0 = Simplify{w*1 + w*1} 'debe ser 2 → w = 1
s_1 = Simplify{w*(-a) + w*a} 'impar: 0 solo
s_2 = Simplify{w*(-a)^2 + w*a^2} 'debe ser 2/3
s_3 = Simplify{w*(-a)^3 + w*a^3} 'impar: 0 solo
#: De s₀: **w = 1**. De s₂ con w = 1: 2a² = 2/3 → **a² = 1/3, a = 1/√3**:
a_2 = Simplify{(2/3)/(2*w)} 'a² = 1/(3w), y con w = 1 queda 1/3
g_2 = 1/sqrt(3) 'ξ = ±1/√3
#: **¿Dónde falla?** En grado 2n = 4: la regla da 2a⁴ y la verdad es 2/5:
q_4 = Simplify{2*(1/3)^2} 'Gauss con 2 puntos
e_4 = Simplify{2/5 - 2*(1/3)^2} 'error = 8/45: ξ⁴ ya no sale exacta

## 3 · n = 3: −a, 0, +a con pesos v, u, v
#: Ahora hay 3 incógnitas (a, v, u) y se pueden acertar 1, ξ², ξ⁴ (los impares salen solos): 2v + u = 2, 2va² = 2/3, 2va⁴ = 2/5. Dividiendo la tercera por la segunda se va v:
a_3 = Simplify{(2/5)/(2/3)} 'a² = 3/5
v_3 = Simplify{(1/3)/(3/5)} 'v = (1/3)/a²
u_3 = Simplify{2 - 2*5/9} 'u = 2 − 2v
g_3 = sqrt(3/5) 'ξ = ±√(3/5)
#: **Puntos 0 y ±√(3/5) = ±0.7746; pesos 8/9 (centro) y 5/9 (lados).** Exacta hasta grado 5; falla en grado 6:
q_6 = Simplify{2*5/9*(3/5)^3} 'Gauss con 3 puntos
e_6 = Simplify{2/7 - 2*5/9*(3/5)^3} 'error = 8/175

## 4 · Los puntos son las raíces de Legendre
#: Con 4 puntos el sistema es de 4 ecuaciones no lineales. Hay un atajo: **los puntos de Gauss son las raíces del polinomio de Legendre Pₙ**, que sale de la fórmula de Rodrigues Pₙ = 1/(2ⁿn!)·dⁿ/dξⁿ (ξ² − 1)ⁿ. El motor deriva:
P_2 = Simplify{Diff{Diff{(xi^2 - 1)^2 @ xi} @ xi}/8}
P_3 = Simplify{Diff{Diff{Diff{(xi^2 - 1)^3 @ xi} @ xi} @ xi}/48}
P_4 = Simplify{Diff{Diff{Diff{Diff{(xi^2 - 1)^4 @ xi} @ xi} @ xi} @ xi}/384}
#: Las raíces de P₂ = (3ξ² − 1)/2 son ±1/√3 y las de P₃ = (5ξ³ − 3ξ)/2 son 0 y ±√(3/5): **justo lo que salió en las secciones 2 y 3**. P₄ = (35ξ⁴ − 30ξ² + 3)/8 es una cuadrática en t = ξ²: t = (15 ± 2√30)/35.
t_a = (15 - 2*sqrt(30))/35 'ξ² del punto interior
t_b = (15 + 2*sqrt(30))/35 'ξ² del punto exterior
g_a = sqrt(t_a) 'ξ interior = 0.3400
g_b = sqrt(t_b) 'ξ exterior = 0.8611
#: Los pesos salen de acertar 1 y ξ²: w_a + w_b = 1 y w_a·t_a + w_b·t_b = 1/3 (dos ecuaciones lineales):
w_a = (1/3 - t_b)/(t_a - t_b) 'peso interior
w_b = 1 - w_a 'peso exterior
c_a = (18 + sqrt(30))/36 'la forma cerrada: (18 + √30)/36
c_b = (18 - sqrt(30))/36 'y (18 − √30)/36
#: Comprobación: exacta en ξ⁶ y falla en ξ⁸ (grado 2n = 8):
q_8 = 2*(w_a*t_a^3 + w_b*t_b^3) 'Gauss en ξ⁶ (debe dar 2/7)
r_8 = 2/7 'exacta
q_9 = 2*(w_a*t_a^4 + w_b*t_b^4) 'Gauss en ξ⁸
e_9 = 2/9 - q_9 'error = 128/11025 = 0.01161
#: **¿Por qué Legendre?** Pₙ es **ortogonal** a todo polinomio de grado menor que n: ∫ Pₙ·ξᵏ dξ = 0 para k < n. Un polinomio de grado 2n − 1 se divide entre Pₙ: p = q·Pₙ + r, con q y r de grado < n. La parte q·Pₙ integra **cero** (ortogonal) y **vale cero en las raíces de Pₙ** (los puntos): Gauss tampoco la ve. Queda r, de grado < n, que n puntos integran exacto. El motor comprueba la ortogonalidad:
o_1 = Integral{(35*xi^4 - 30*xi^2 + 3)/8*xi^2 @ xi = -c : c} 'con c = 1 da 0
o_2 = Integral{(5*xi^3 - 3*xi)/2*xi @ xi = -c : c} 'con c = 1 da 0
#: Los tres polinomios de Legendre y sus raíces (= puntos de Gauss). Pasa el cursor para leer el valor:
#fplot(P_2 = (3*x^2 - 1)/2, P_3 = (5*x^3 - 3*x)/2, P_4 = (35*x^4 - 30*x^2 + 3)/8, raices = [-0.57735 0; 0.57735 0; -0.774597 0; 0 0; 0.774597 0; -0.861136 0; -0.339981 0; 0.339981 0; 0.861136 0], [-1 1])
#dibujo("Los puntos de Gauss en el tramo [−1, 1] para n = 2, 3 y 4; el tamaño de cada punto es su peso", ud = m, escala = auto, alto = 60)
#  linea(-3, 0, 3, 0, "gruesa")
#  linea(-3, -0.15, -3, 0.15, "fina")
#  linea(3, -0.15, 3, 0.15, "fina")
#  circulo(-2.5834, 0, 0.1044, "rojo")
#  texto(-2.5834, 0.45, "-0.8611", 2.2, "c")
#  circulo(-1.0199, 0, 0.1956, "rojo")
#  texto(-1.0199, 0.45, "-0.3400", 2.2, "c")
#  circulo(1.0199, 0, 0.1956, "rojo")
#  texto(1.0199, 0.45, "0.3400", 2.2, "c")
#  circulo(2.5834, 0, 0.1044, "rojo")
#  texto(2.5834, 0.45, "0.8611", 2.2, "c")
#  texto(-3.8, 0, "n = 4", 2.6, "c")
#  linea(-3, 1.1, 3, 1.1, "gruesa")
#  linea(-3, 0.95, -3, 1.25, "fina")
#  linea(3, 0.95, 3, 1.25, "fina")
#  circulo(-2.3238, 1.1, 0.1667, "rojo")
#  texto(-2.3238, 1.55, "-0.7746", 2.2, "c")
#  circulo(0, 1.1, 0.2667, "rojo")
#  texto(0, 1.55, "0.0000", 2.2, "c")
#  circulo(2.3238, 1.1, 0.1667, "rojo")
#  texto(2.3238, 1.55, "0.7746", 2.2, "c")
#  texto(-3.8, 1.1, "n = 3", 2.6, "c")
#  linea(-3, 2.2, 3, 2.2, "gruesa")
#  linea(-3, 2.05, -3, 2.35, "fina")
#  linea(3, 2.05, 3, 2.35, "fina")
#  circulo(-1.7321, 2.2, 0.3, "rojo")
#  texto(-1.7321, 2.65, "-0.5774", 2.2, "c")
#  circulo(1.7321, 2.2, 0.3, "rojo")
#  texto(1.7321, 2.65, "0.5774", 2.2, "c")
#  texto(-3.8, 2.2, "n = 2", 2.6, "c")
#  texto(-3, -0.55, "−1", 2.4, "c")
#  texto(3, -0.55, "+1", 2.4, "c")
#fin
#: Resumen de las reglas (todas deducidas arriba):
#: n = 2: ξ = ±0.5773502692, w = 1 · n = 3: ξ = 0, ±0.7745966692, w = 8/9, 5/9 · n = 4: ξ = ±0.3399810436, ±0.8611363116, w = 0.6521451549, 0.3478548451. **Los pesos de cada regla suman 2** (el largo del tramo).

## 5 · Del tramo real [a, b] al de referencia [−1, 1]: el Jacobiano 1D
#: Los puntos están en [−1, 1]; la integral real va de a a b. Una recta (como y = m·x + b) lleva uno al otro: **x = m + J·ξ**. Con ξ = −1 → x = a y ξ = +1 → x = b: sumando, m = (a + b)/2; restando, **J = (b − a)/2** (la mitad del largo). Y **dx = J·dξ**: J es el Jacobiano 1D.
#: **Ejemplo 1 (polinomio):** ∫₀² (x³ + 2x² + 1) dx. La exacta (el motor, con límite b y luego b = 2):
i_1 = Integral{x^3 + 2*x^2 + 1 @ x = 0 : b}
#: Con b = 2: 4 + 16/3 + 2 = **34/3 = 11.3333333333**. Gauss con 2 puntos: m = 1, J = 1, x = 1 ∓ 1/√3. Es grado 3 = 2n − 1: el motor da exacto, con raíces y todo:
j_1 = Simplify{(1 - 1/sqrt(3))^3 + 2*(1 - 1/sqrt(3))^2 + 1 + (1 + 1/sqrt(3))^3 + 2*(1 + 1/sqrt(3))^2 + 1}
#: **34/3 exacto con 2 puntos** (y también con 3 y 4: más puntos no cambian una integral que ya es exacta).

## 6 · Una función que NO es polinomio: la integral de sin x de 0 a π (= 2)
#: Primero el objeto: la curva sin x entre 0 y π, y su área (= 2):
i_2 = Integral{sin(x) @ x = 0 : b}
#: Con b = π: 1 − cos π = **2**. sin x no es un polinomio: **ningún n la da exacta**, pero el error cae muy rápido. m = J = π/2:
s_e(n) = sin(pi/2 + pi/2*n)
G_2 = pi/2*(s_e(-g_2) + s_e(g_2)) 'n = 2
G_3 = pi/2*(5/9*s_e(-g_3) + 8/9*s_e(0) + 5/9*s_e(g_3)) 'n = 3
G_4 = pi/2*(c_b*s_e(-g_b) + c_a*s_e(-g_a) + c_a*s_e(g_a) + c_b*s_e(g_b)) 'n = 4
E_2 = G_2 - 2 'error con 2 puntos
E_3 = G_3 - 2 'error con 3 puntos
E_4 = G_4 - 2 'error con 4 puntos
#: **El error, con el término de Taylor que se corta.** Gauss acierta todo hasta grado 2n − 1; lo primero que falla es el término f⁽²ⁿ⁾(ζ)·ξ²ⁿ/(2n)!. Su error es (error en ξ²ⁿ)/(2n)!·f⁽²ⁿ⁾(ζ), y en [a, b] se multiplica por J²ⁿ⁺¹:
c_2 = (2/5 - 2/9)/24 'n = 2: (8/45)/4! = 1/135
c_3 = (2/7 - 6/25)/720 'n = 3: (8/175)/6! = 1/15750
c_4 = (2/9 - q_9)/40320 'n = 4: (128/11025)/8! = 1/3472875
#: Para sin x, |f⁽²ⁿ⁾| ≤ 1 y J = π/2: la cota del error es c_n·(π/2)²ⁿ⁺¹, y el error real queda justo debajo:
B_2 = c_2*(pi/2)^5 'cota n = 2 (real 0.0642)
B_3 = c_3*(pi/2)^7 'cota n = 3 (real 0.00139)
B_4 = c_4*(pi/2)^9 'cota n = 4 (real 1.58·10⁻⁵)
#: **El error baja ~ 40 veces por cada punto que se agrega** (−6.4·10⁻², 1.4·10⁻³, −1.6·10⁻⁵). La curva y los 3 puntos de Gauss de n = 3 (x = π/2 ∓ π/2·√(3/5) y π/2):
#fplot(seno = sin(x), puntos = [0.354 0.347; 1.5708 1; 2.788 0.347], [0 3.1416])
n_t = [2; 3; 4]
v_t = [G_2; G_3; G_4]
r_t = [E_2; E_3; E_4]
#tabla("n:0","Gauss:10","error:10")(n_t; v_t; r_t)
#: **La hipótesis «n puntos aciertan hasta grado 2n − 1» en movimiento:** mueve k; la curva es ξᵏ en [−1, 1]. Con n = 2 el área sale exacta mientras k ≤ 3; desde k = 4 Gauss da 2·(1/3)^(k/2) y la verdad 2/(k + 1):
#slider fplot(monomio = x^k, gauss_2 = 0*x + 2*(1/3)^(k/2)/2, exacta = 0*x + 1/(k + 1), [-1 1]), k = 0:1:8
#: (Las dos rectas son las alturas medias: área/2 de Gauss y de la exacta. Para k impar el área real es 0 y Gauss también da 0: en las rectas se compara solo k par.)

## 7 · 2D: dos sumas, una dentro de otra
#: Una integral doble es una integral de integrales: ∫₋₁¹ ∫₋₁¹ f(ξ, η) dξ dη. Gauss se aplica **una vez en cada dirección**: ≈ Σᵢ Σⱼ wᵢ·wⱼ·f(ξᵢ, ηⱼ). Con n por dirección son **n × n puntos**, y el peso de cada uno es el **producto** wᵢ·wⱼ (suman 4 = el área del cuadrado):
#dibujo("Puntos de Gauss en el cuadrado de referencia: 2 × 2, 3 × 3 y 4 × 4. El TAMAÑO de cada punto es su peso wᵢ·wⱼ", ud = m, escala = auto, alto = 60)
#  poligono(0, 0, 2, 0, 2, 2, 0, 2, "gruesa")
#  linea(0, 1, 2, 1, "fina")
#  linea(1, 0, 1, 2, "fina")
#  circulo(0.4226, 0.4226, 0.16, "rojo")
#  circulo(0.4226, 1.5774, 0.16, "rojo")
#  circulo(1.5774, 0.4226, 0.16, "rojo")
#  circulo(1.5774, 1.5774, 0.16, "rojo")
#  texto(1, -0.35, "n = 2: 4 puntos", 2.6, "c")
#  poligono(3, 0, 5, 0, 5, 2, 3, 2, "gruesa")
#  linea(3, 1, 5, 1, "fina")
#  linea(4, 0, 4, 2, "fina")
#  circulo(3.2254, 0.2254, 0.0889, "rojo")
#  circulo(3.2254, 1, 0.1124, "rojo")
#  circulo(3.2254, 1.7746, 0.0889, "rojo")
#  circulo(4, 0.2254, 0.1124, "rojo")
#  circulo(4, 1, 0.1422, "rojo")
#  circulo(4, 1.7746, 0.1124, "rojo")
#  circulo(4.7746, 0.2254, 0.0889, "rojo")
#  circulo(4.7746, 1, 0.1124, "rojo")
#  circulo(4.7746, 1.7746, 0.0889, "rojo")
#  texto(4, -0.35, "n = 3: 9 puntos", 2.6, "c")
#  poligono(6, 0, 8, 0, 8, 2, 6, 2, "gruesa")
#  linea(6, 1, 8, 1, "fina")
#  linea(7, 0, 7, 2, "fina")
#  circulo(6.1389, 0.1389, 0.0557, "rojo")
#  circulo(6.1389, 0.66, 0.0762, "rojo")
#  circulo(6.1389, 1.34, 0.0762, "rojo")
#  circulo(6.1389, 1.8611, 0.0557, "rojo")
#  circulo(6.66, 0.1389, 0.0762, "rojo")
#  circulo(6.66, 0.66, 0.1043, "rojo")
#  circulo(6.66, 1.34, 0.1043, "rojo")
#  circulo(6.66, 1.8611, 0.0762, "rojo")
#  circulo(7.34, 0.1389, 0.0762, "rojo")
#  circulo(7.34, 0.66, 0.1043, "rojo")
#  circulo(7.34, 1.34, 0.1043, "rojo")
#  circulo(7.34, 1.8611, 0.0762, "rojo")
#  circulo(7.8611, 0.1389, 0.0557, "rojo")
#  circulo(7.8611, 0.66, 0.0762, "rojo")
#  circulo(7.8611, 1.34, 0.0762, "rojo")
#  circulo(7.8611, 1.8611, 0.0557, "rojo")
#  texto(7, -0.35, "n = 4: 16 puntos", 2.6, "c")
#  texto(-0.25, 1, "η", 2.4, "c")
#  texto(1, 2.3, "ξ", 2.4, "c")
#fin
#: **Ejemplo (no polinomio):** f(ξ, η) = cos(πξ/2)·cos(πη/2) en el cuadrado. La exacta, con el motor:
i_3 = Integral{cos(u) @ u = -c : c} 'con u = πξ/2: dξ = (2/π)·du y c = π/2 → (2/π)·2 = 4/π por dirección
c_x = 16/pi^2 'la exacta: (4/π)² = 1.6211389383
c_c(a, b) = cos(pi*a/2)*cos(pi*b/2)
C_2 = 1*1*c_c(-g_2, -g_2) + 1*1*c_c(-g_2, g_2) + 1*1*c_c(g_2, -g_2) + 1*1*c_c(g_2, g_2) '2 × 2
C_3 = 5/9*5/9*c_c(-g_3, -g_3) + 5/9*8/9*c_c(-g_3, 0) + 5/9*5/9*c_c(-g_3, g_3) + 8/9*5/9*c_c(0, -g_3) + 8/9*8/9*c_c(0, 0) + 8/9*5/9*c_c(0, g_3) + 5/9*5/9*c_c(g_3, -g_3) + 5/9*8/9*c_c(g_3, 0) + 5/9*5/9*c_c(g_3, g_3) '3 × 3
C_4 = w_b*w_b*c_c(-g_b, -g_b) + w_b*w_a*c_c(-g_b, -g_a) + w_b*w_a*c_c(-g_b, g_a) + w_b*w_b*c_c(-g_b, g_b) + w_a*w_b*c_c(-g_a, -g_b) + w_a*w_a*c_c(-g_a, -g_a) + w_a*w_a*c_c(-g_a, g_a) + w_a*w_b*c_c(-g_a, g_b) + w_a*w_b*c_c(g_a, -g_b) + w_a*w_a*c_c(g_a, -g_a) + w_a*w_a*c_c(g_a, g_a) + w_a*w_b*c_c(g_a, g_b) + w_b*w_b*c_c(g_b, -g_b) + w_b*w_a*c_c(g_b, -g_a) + w_b*w_a*c_c(g_b, g_a) + w_b*w_b*c_c(g_b, g_b) '4 × 4
#: Como f es un producto f(ξ)·f(η), la suma doble es (la suma 1D)²: con 4 × 4 el error es 2.6·10⁻⁵. La superficie en 3D (arrastra para girar) y la planta con colores (pasa el cursor: el valor en cada punto):
#surf(cos(pi*x/2)*cos(pi*y/2), [-1 1], [-1 1])
#map(cos(pi*x/2)*cos(pi*y/2), [-1 1], [-1 1])

## 8 · Un cuadrilátero real: Jacobiano 2D, área e Iₓ
#dibujo("El cuadrilátero real (Q4, en m): nudos 1 (0, 0), 2 (4, 0), 3 (5, 3), 4 (1, 2). No es un paralelogramo", ud = m, escala = auto, cotas = m, alto = 55)
#  poligono(0, 0, 4, 0, 5, 3, 1, 2, "gruesa")
#  circulo(0, 0, 0.08, "negro")
#  circulo(4, 0, 0.08, "negro")
#  circulo(5, 3, 0.08, "negro")
#  circulo(1, 2, 0.08, "negro")
#  texto(-0.3, -0.3, "1", 2.4, "c")
#  texto(4.3, -0.3, "2", 2.4, "c")
#  texto(5.3, 3.2, "3", 2.4, "c")
#  texto(0.7, 2.25, "4", 2.4, "c")
#  cota(0, -0.6, 4, -0.6, 0, "4 m")
#  cota(5.6, 0, 5.6, 3, 0, "3 m")
#  circulo(1.0566, 0.4673, 0.1, "rojo")
#  circulo(1.634, 1.744, 0.1, "rojo")
#  circulo(3.366, 0.5893, 0.1, "rojo")
#  circulo(3.9434, 2.1994, 0.1, "rojo")
#fin
#: Los puntos rojos son los 2 × 2 puntos de Gauss **ya llevados al elemento real**. Igual que en 1D, una función lleva el cuadrado de referencia al elemento: x = ΣNᵢxᵢ, y = ΣNᵢyᵢ, con las funciones del Q4 Nᵢ = (1 ± ξ)(1 ± η)/4. El motor expande:
x_q = Simplify{(1 - xi)*(1 - eta)/4*0 + (1 + xi)*(1 - eta)/4*4 + (1 + xi)*(1 + eta)/4*5 + (1 - xi)*(1 + eta)/4*1} 'x(ξ, η) [m]
y_q = Simplify{(1 - xi)*(1 - eta)/4*0 + (1 + xi)*(1 - eta)/4*0 + (1 + xi)*(1 + eta)/4*3 + (1 - xi)*(1 + eta)/4*2} 'y(ξ, η) [m]
#: El **Jacobiano** J = [∂x/∂ξ, ∂y/∂ξ; ∂x/∂η, ∂y/∂η] dice cuánto se estira el cuadrado; su determinante es el factor de área: **dA = det J·dξ·dη** (el 2D de dx = J·dξ):
J_11 = Simplify{Diff{5/2 + 2*xi + eta/2 @ xi}} '∂x/∂ξ
J_12 = Simplify{Diff{5/4 + xi/4 + 5*eta/4 + xi*eta/4 @ xi}} '∂y/∂ξ
J_21 = Simplify{Diff{5/2 + 2*xi + eta/2 @ eta}} '∂x/∂η
J_22 = Simplify{Diff{5/4 + xi/4 + 5*eta/4 + xi*eta/4 @ eta}} '∂y/∂η
d_s = Simplify{2*(5/4 + xi/4) - (1/4 + eta/4)*(1/2)} 'det J [m²]: varía (no es paralelogramo)
#: **Área = ∫∫ det J dξ dη** y **Iₓ = ∫∫ y² dA = ∫∫ y²·det J dξ dη**. Exactas con el motor (en [−c, c]², luego c = 1):
A_x = Integral{Integral{19/8 + xi/2 - eta/8 @ xi = -c : c} @ eta = -c : c} 'con c = 1: área = 19/2 [m²]
I_xx = Integral{Integral{(5/4 + xi/4 + 5*eta/4 + xi*eta/4)^2*(19/8 + xi/2 - eta/8) @ xi = -c : c} @ eta = -c : c} 'con c = 1: Iₓ = 241/12 [m⁴]
#: y² tiene ξ²η² y det J agrega un grado: el integrando es de grado 3 en cada dirección → **2 × 2 ya es exacto**. Gauss:
d_J(a, b) = 19/8 + a/2 - b/8
y_g(a, b) = 5/4 + a/4 + 5*b/4 + a*b/4
g_A(a, b) = d_J(a, b)
g_I(a, b) = y_g(a, b)^2*d_J(a, b)
A_2 = 1*1*g_A(-g_2, -g_2) + 1*1*g_A(-g_2, g_2) + 1*1*g_A(g_2, -g_2) + 1*1*g_A(g_2, g_2) 'área 2 × 2 [m²]
I_2 = 1*1*g_I(-g_2, -g_2) + 1*1*g_I(-g_2, g_2) + 1*1*g_I(g_2, -g_2) + 1*1*g_I(g_2, g_2) 'Iₓ 2 × 2 [m⁴]
I_3 = 5/9*5/9*g_I(-g_3, -g_3) + 5/9*8/9*g_I(-g_3, 0) + 5/9*5/9*g_I(-g_3, g_3) + 8/9*5/9*g_I(0, -g_3) + 8/9*8/9*g_I(0, 0) + 8/9*5/9*g_I(0, g_3) + 5/9*5/9*g_I(g_3, -g_3) + 5/9*8/9*g_I(g_3, 0) + 5/9*5/9*g_I(g_3, g_3) 'Iₓ 3 × 3 [m⁴]
I_4 = w_b*w_b*g_I(-g_b, -g_b) + w_b*w_a*g_I(-g_b, -g_a) + w_b*w_a*g_I(-g_b, g_a) + w_b*w_b*g_I(-g_b, g_b) + w_a*w_b*g_I(-g_a, -g_b) + w_a*w_a*g_I(-g_a, -g_a) + w_a*w_a*g_I(-g_a, g_a) + w_a*w_b*g_I(-g_a, g_b) + w_a*w_b*g_I(g_a, -g_b) + w_a*w_a*g_I(g_a, -g_a) + w_a*w_a*g_I(g_a, g_a) + w_a*w_b*g_I(g_a, g_b) + w_b*w_b*g_I(g_b, -g_b) + w_b*w_a*g_I(g_b, -g_a) + w_b*w_a*g_I(g_b, g_a) + w_b*w_b*g_I(g_b, g_b) 'Iₓ 4 × 4 [m⁴]
#: Mapa de det J en ξ–η (pasa el cursor): positivo en todo el elemento (no hay pliegue), de 1.75 a 3 m²:
#map(19/8 + x/2 - y/8, [-1 1], [-1 1])

## 9 · Un término de la rigidez: K₁₁ del Q4
#: En FEM lo que se integra es la rigidez: K = ∫∫ Bᵀ·D·B·t dA. El término K₁₁ (fuerza en x del nudo 1 por mover el nudo 1 en x) es ∫∫ (D₁₁·(∂N₁/∂x)² + D₃₃·(∂N₁/∂y)²)·det J dξ dη, con tensión plana, E·t = 1 y ν = 0.25 (D₁₁ = 16/15, D₃₃ = 2/5). Las derivadas en x, y salen de **invertir J**: ∂N/∂x = (J₂₂·∂N/∂ξ − J₁₂·∂N/∂η)/det J. Así **det J queda en el denominador**:
k_s = Simplify{(16/15*((5/4 + xi/4)*(-(1 - eta)/4) - (1/4 + eta/4)*(-(1 - xi)/4))^2 + 2/5*(-(1/2)*(-(1 - eta)/4) + 2*(-(1 - xi)/4))^2)/(19/8 + xi/2 - eta/8)}
#: Es una **fracción** (polinomio / det J): no es un polinomio, así que **ningún n la integra exacta** en un cuadrilátero distorsionado (en un rectángulo o paralelogramo det J es constante y 2 × 2 sí es exacto). Gauss con 2 × 2, 3 × 3 y 4 × 4:
n_x(a, b) = ((5/4 + a/4)*(-(1 - b)/4) - (1/4 + b/4)*(-(1 - a)/4))/d_J(a, b)
n_y(a, b) = (-(1/2)*(-(1 - b)/4) + 2*(-(1 - a)/4))/d_J(a, b)
g_K(a, b) = (16/15*n_x(a, b)^2 + 2/5*n_y(a, b)^2)*d_J(a, b)
K_2 = 1*1*g_K(-g_2, -g_2) + 1*1*g_K(-g_2, g_2) + 1*1*g_K(g_2, -g_2) + 1*1*g_K(g_2, g_2) 'K₁₁ con 2 × 2 (÷ E·t)
K_3 = 5/9*5/9*g_K(-g_3, -g_3) + 5/9*8/9*g_K(-g_3, 0) + 5/9*5/9*g_K(-g_3, g_3) + 8/9*5/9*g_K(0, -g_3) + 8/9*8/9*g_K(0, 0) + 8/9*5/9*g_K(0, g_3) + 5/9*5/9*g_K(g_3, -g_3) + 5/9*8/9*g_K(g_3, 0) + 5/9*5/9*g_K(g_3, g_3) 'K₁₁ con 3 × 3
K_4 = w_b*w_b*g_K(-g_b, -g_b) + w_b*w_a*g_K(-g_b, -g_a) + w_b*w_a*g_K(-g_b, g_a) + w_b*w_b*g_K(-g_b, g_b) + w_a*w_b*g_K(-g_a, -g_b) + w_a*w_a*g_K(-g_a, -g_a) + w_a*w_a*g_K(-g_a, g_a) + w_a*w_b*g_K(-g_a, g_b) + w_a*w_b*g_K(g_a, -g_b) + w_a*w_a*g_K(g_a, -g_a) + w_a*w_a*g_K(g_a, g_a) + w_a*w_b*g_K(g_a, g_b) + w_b*w_b*g_K(g_b, -g_b) + w_b*w_a*g_K(g_b, -g_a) + w_b*w_a*g_K(g_b, g_a) + w_b*w_b*g_K(g_b, g_b) 'K₁₁ con 4 × 4
K_r = 0.3727228863 'referencia: mpmath con 40 dígitos (cuadratura adaptativa)
k_t = [2; 3; 4]
K_t = [K_2; K_3; K_4]
D_t = [K_2 - K_r; K_3 - K_r; K_4 - K_r]
#tabla("n × n:0","K₁₁ (÷ E·t):10","error:10")(k_t; K_t; D_t)
#: **2 × 2 se queda a 0.3 %** de la referencia; 3 × 3 a 0.003 %. Por eso los programas usan 2 × 2 en el Q4: el error es mucho menor que el de la propia malla, y cada punto más cuesta tiempo.

## 10 · ¿Cuántos puntos usa cada elemento?
#: La regla práctica: **los puntos justos para integrar EXACTO el elemento sin distorsionar** (rectángulo, paralelogramo):
#: **Q4** (4 nudos): 2 × 2 = 4 puntos · **Q8 / Q9**: 3 × 3 = 9 · **T3** (triángulo lineal): 1 punto (B constante) · **T6** (triángulo cuadrático): 3 puntos (reglas de Gauss para triángulos, otra familia) · **H8** (ladrillo de 8 nudos): 2 × 2 × 2 = 8 · **H20**: 3 × 3 × 3 = 27.
#: **Integración reducida:** usar MENOS puntos a propósito (Q4 con 1 punto, Q8 con 2 × 2). Ablanda el elemento y quita el bloqueo por cortante, pero aparecen **modos de energía nula** (el «reloj de arena»). Explicado en el video «Puntos de Gauss e integración reducida» del canal y en la hoja 204 (modos espurios).

## 11 · El mismo algoritmo en 9 lenguajes
#: El script recorre n = 2, 3, 4: calcula ξᵢ y wᵢ, ∫₀²(x³ + 2x² + 1) dx, ∫₀^π sin x dx, ∫ ξ²ⁿ (la primera que falla), y en el Q4 el área, Iₓ y K₁₁. Se ejecutó de verdad en **Python, C++ (g++), Fortran (gfortran), MATLAB R2017a, Hekatan Lab, Calcpad, Hekatan LISP, Rust y JavaScript (node)**: los 39 números son **iguales a 10 decimales** entre sí y contra el oráculo (sympy/mpmath). Hekatan Code genera las formas desde una misma hoja.
#: Video: «Cuadratura de Gauss 1D y 2D con 2, 3 y 4 puntos en 9 lenguajes» (Hekatan Engineers, YouTube).
