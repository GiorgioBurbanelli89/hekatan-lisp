# Funciones de forma Q4, Q8 y Q9 a fondo - deducidas con la matriz C, propiedades, Jacobiano, Gauss, modos espurios y bloqueo en un voladizo
#numerico

## 0 · La idea
#: Un elemento finito solo conoce los movimientos de sus **nudos**. Para saber cuánto se mueve un punto cualquiera de adentro, se mezclan los valores de los nudos con unos pesos: las **funciones de forma** Nᵢ(ξ, η). La regla es simple: **Nᵢ vale 1 en su nudo y 0 en todos los demás**, y en cualquier punto **todas suman 1** (si todos los nudos se mueven lo mismo, el elemento entero se mueve lo mismo).
#: Esta hoja va **más a fondo** que las anteriores: la 04b dibujó el Q4, la 04f mostró por qué el cuarto término es ξη (triángulo de Pascal), la 201 presentó la familia T3…Q9 y la 203 usó el Q4 en una barra. Aquí se **deducen** las tres funciones del cuadrilátero (Q4, Q8 y Q9) con la matriz C, se comprueban sus propiedades, se mapean a un elemento real, se integran con Gauss y se ponen a trabajar en un voladizo.
#dibujo("La familia del cuadrilátero: esquinas (1-4), mitad de los lados (5-8) y nudo central (9). Referencia: ξ y η de -1 a +1", ud = m, escala = auto, alto = 70)
#  poligono(0, 0, 2, 0, 2, 2, 0, 2, "gruesa")
#  poligono(3, 0, 5, 0, 5, 2, 3, 2, "gruesa")
#  poligono(6, 0, 8, 0, 8, 2, 6, 2, "gruesa")
#  circulo(0, 0, 0.1, "negro")
#  circulo(2, 0, 0.1, "negro")
#  circulo(2, 2, 0.1, "negro")
#  circulo(0, 2, 0.1, "negro")
#  texto(-0.25, -0.3, "1", 2.4, "c")
#  texto(2.25, -0.3, "2", 2.4, "c")
#  texto(2.25, 2.3, "3", 2.4, "c")
#  texto(-0.25, 2.3, "4", 2.4, "c")
#  circulo(3, 0, 0.1, "negro")
#  circulo(5, 0, 0.1, "negro")
#  circulo(5, 2, 0.1, "negro")
#  circulo(3, 2, 0.1, "negro")
#  circulo(4, 0, 0.1, "azul")
#  circulo(5, 1, 0.1, "azul")
#  circulo(4, 2, 0.1, "azul")
#  circulo(3, 1, 0.1, "azul")
#  texto(2.75, -0.3, "1", 2.4, "c")
#  texto(5.25, -0.3, "2", 2.4, "c")
#  texto(5.25, 2.3, "3", 2.4, "c")
#  texto(2.75, 2.3, "4", 2.4, "c")
#  texto(4, -0.35, "5", 2.4, "c")
#  texto(5.3, 1, "6", 2.4, "c")
#  texto(4, 2.35, "7", 2.4, "c")
#  texto(2.7, 1, "8", 2.4, "c")
#  circulo(6, 0, 0.1, "negro")
#  circulo(8, 0, 0.1, "negro")
#  circulo(8, 2, 0.1, "negro")
#  circulo(6, 2, 0.1, "negro")
#  circulo(7, 0, 0.1, "azul")
#  circulo(8, 1, 0.1, "azul")
#  circulo(7, 2, 0.1, "azul")
#  circulo(6, 1, 0.1, "azul")
#  circulo(7, 1, 0.1, "rojo")
#  texto(7.25, 1.25, "9", 2.4, "c")
#  flecha(6, 1, 6.7, 1, "fina")
#  flecha(7, 1, 7, 1.7, "fina")
#  texto(1, -0.8, "Q4 bilineal", 2.6, "c")
#  texto(4, -0.8, "Q8 serendípito", 2.6, "c")
#  texto(7, -0.8, "Q9 Lagrange", 2.6, "c")
#fin
#: #: **De dónde se parte (nada «porque sí»).** **¿Qué sé?** el desplazamiento de cada nudo (es lo que resuelve K·u = F). **¿Qué quiero?** saberlo en cualquier punto de adentro. **¿Qué propongo?** un polinomio con **tantas constantes como nudos** (4, 8 o 9), con los términos más bajos del triángulo de Pascal y tratando igual a ξ y a η. **¿Qué exijo?** que en cada nudo valga el desplazamiento de ese nudo: eso arma C·a = u. **¿Qué sale?** a = C⁻¹·u, y lo que multiplica a cada uᵢ es Nᵢ. **¿Para qué?** sus derivadas dan la deformación (B = ∂N/∂x) y con ella la rigidez K = ∫Bᵀ·D·B dA. **¿Por qué ξ y η?** para no repetir la cuenta en cada elemento, todo se hace una vez en un cuadrado de referencia (ξ, η de −1 a +1) y el Jacobiano (sección 5) lo estira al elemento real.
Coordenadas de los nudos en el cuadrado de referencia: esquinas 1 (−1, −1), 2 (+1, −1), 3 (+1, +1), 4 (−1, +1); mitades 5 (0, −1), 6 (+1, 0), 7 (0, +1), 8 (−1, 0); centro 9 (0, 0). La letra dice la forma (Q = cuadrilátero) y el número, cuántos nudos.

## 1 · Q4: del polinomio a N con la matriz C
#: **Idea:** dentro del elemento el movimiento es un polinomio con tantos coeficientes como nudos: u = a₀ + a₁ξ + a₂η + a₃ξη. Si se piden los 4 valores de los nudos, sale un sistema C·a = u, donde cada fila de C es la base [1, ξ, η, ξη] evaluada en un nudo:
C_4 = [1, -1, -1, 1; 1, 1, -1, -1; 1, 1, 1, 1; 1, -1, 1, -1] 'filas: nudos 1, 2, 3, 4
d_4 = det(C_4) 'distinto de 0: se puede invertir
#: Los coeficientes son a = C⁻¹·u, y entonces u = [1, ξ, η, ξη]·C⁻¹·u: lo que multiplica a cada uᵢ es su función de forma. El motor invierte y multiplica:
N_Q4 = Simplify{[1, xi, eta, xi*eta]*inv([1, -1, -1, 1; 1, 1, -1, -1; 1, 1, 1, 1; 1, -1, 1, -1])}
#: Ordenando: **N₁ = (1 − ξ)(1 − η)/4, N₂ = (1 + ξ)(1 − η)/4, N₃ = (1 + ξ)(1 + η)/4, N₄ = (1 − ξ)(1 + η)/4**. Cada **columna de C⁻¹** son los coeficientes de una N:
C_4i = inv(C_4) 'columna j = coeficientes de Nⱼ
n_41 = Simplify{[1, xi, eta, xi*eta]*[0.25; -0.25; -0.25; 0.25]} 'base · columna 1 = N₁
f_41 = Simplify{(1 - xi)*(1 - eta)/4} 'la forma factorizada, expandida por el motor: el mismo polinomio
#: **El atajo del producto.** Las rectas de Lagrange 1D son ℓ₁(t) = (1 − t)/2 y ℓ₂(t) = (1 + t)/2. El Q4 es el producto de una recta en ξ por una recta en η:
c_42 = Simplify{(1 - xi)/2*(1 - eta)/2 - (1 - xi)*(1 - eta)/4} 'N₁ = ℓ₁(ξ)·ℓ₁(η)
#: N₁ en 3D: un «toldo» que vale 1 en la esquina (−1, −1) y 0 en las otras tres (x = ξ, y = η; arrastra para girar):
#surf((1 - x)*(1 - y)/4, [-1 1], [-1 1])
#: Planta con colores (pasa el cursor para leer el valor):
#map((1 - x)*(1 - y)/4, [-1 1], [-1 1])
#: Corte por el lado η = −1 (lado 1-2): N₁ y N₂ son **rectas** y se cruzan en 0.5. Los puntos son los nudos:
#fplot(N_1 = (1 - x)/2, N_2 = (1 + x)/2, nudos = [-1 1; 1 0; -1 0; 1 1], [-1 1])

## 2 · Q9: el producto de dos parábolas (Lagrange)
#: Con 3 nudos por lado, cada dirección pide una **parábola**. Las tres parábolas de Lagrange 1D (nudos en t = −1, 0, +1): ℓ₁ = t(t − 1)/2, ℓ₂ = 1 − t², ℓ₃ = t(t + 1)/2. Su producto da 9 funciones, y la base es [1, ξ, η, ξ², ξη, η², ξ²η, ξη², ξ²η²]. Primero con la matriz C de 9 × 9 (filas = nudos 1…9):
C_9 = [1, -1, -1, 1, 1, 1, -1, -1, 1; 1, 1, -1, 1, -1, 1, -1, 1, 1; 1, 1, 1, 1, 1, 1, 1, 1, 1; 1, -1, 1, 1, -1, 1, 1, -1, 1; 1, 0, -1, 0, 0, 1, 0, 0, 0; 1, 1, 0, 1, 0, 0, 0, 0, 0; 1, 0, 1, 0, 0, 1, 0, 0, 0; 1, -1, 0, 1, 0, 0, 0, 0, 0; 1, 0, 0, 0, 0, 0, 0, 0, 0]
d_9 = det(C_9) 'distinto de 0
C_9i = inv(C_9) 'C⁻¹ calculada (columna j = coeficientes de Nⱼ)
N_Q9 = Simplify{[1, xi, eta, xi^2, xi*eta, eta^2, xi^2*eta, xi*eta^2, xi^2*eta^2]*[0, 0, 0, 0, 0, 0, 0, 0, 1; 0, 0, 0, 0, 0, 0.5, 0, -0.5, 0; 0, 0, 0, 0, -0.5, 0, 0.5, 0, 0; 0, 0, 0, 0, 0, 0.5, 0, 0.5, -1; 0.25, -0.25, 0.25, -0.25, 0, 0, 0, 0, 0; 0, 0, 0, 0, 0.5, 0, 0.5, 0, -1; -0.25, -0.25, 0.25, 0.25, 0.5, 0, -0.5, 0, 0; -0.25, 0.25, 0.25, -0.25, 0, -0.5, 0, 0.5, 0; 0.25, 0.25, 0.25, 0.25, -0.5, -0.5, -0.5, -0.5, 1]}
#: Las 9 salen del motor. Comprobación contra el atajo del producto: la esquina 1 es ℓ₁(ξ)·ℓ₁(η) y el centro 9 es ℓ₂(ξ)·ℓ₂(η):
n_91 = Simplify{[1, xi, eta, xi^2, xi*eta, eta^2, xi^2*eta, xi*eta^2, xi^2*eta^2]*[0; 0; 0; 0; 0.25; 0; -0.25; -0.25; 0.25]} 'base · columna 1 de C⁻¹
f_91 = Simplify{xi*(xi - 1)/2*eta*(eta - 1)/2} 'ℓ₁(ξ)·ℓ₁(η) expandido: igual
n_99 = Simplify{[1, xi, eta, xi^2, xi*eta, eta^2, xi^2*eta, xi*eta^2, xi^2*eta^2]*[1; 0; 0; -1; 0; -1; 0; 0; 1]} 'base · columna 9 de C⁻¹
f_99 = Simplify{(1 - xi^2)*(1 - eta^2)} 'ℓ₂(ξ)·ℓ₂(η) expandido: igual
#: La esquina del Q9 en 3D: vale 1 en (−1, −1) y **se hace negativa** entre nudos (los pesos de un elemento cuadrático no son siempre positivos):
#surf(x*(x - 1)/2*y*(y - 1)/2, [-1 1], [-1 1])
#: El nudo central del Q9, N₉ = (1 − ξ²)(1 − η²), una «carpa» que vale 1 en el centro y 0 en los 8 nudos del borde:
#surf((1 - x^2)*(1 - y^2), [-1 1], [-1 1])

## 3 · Q8: serendípito, por qué NO es un producto
#: Si se quita el nudo central quedan 8 nudos y la base pierde un término. ¿Cuál? El de mayor grado, ξ²η² (que solo sirve para el centro). La base del Q8 es [1, ξ, η, ξ², ξη, η², ξ²η, ξη²] y su C es 8 × 8:
C_8 = [1, -1, -1, 1, 1, 1, -1, -1; 1, 1, -1, 1, -1, 1, -1, 1; 1, 1, 1, 1, 1, 1, 1, 1; 1, -1, 1, 1, -1, 1, 1, -1; 1, 0, -1, 0, 0, 1, 0, 0; 1, 1, 0, 1, 0, 0, 0, 0; 1, 0, 1, 0, 0, 1, 0, 0; 1, -1, 0, 1, 0, 0, 0, 0]
d_8 = det(C_8) 'distinto de 0
C_8i = inv(C_8) 'C⁻¹ calculada (columna j = coeficientes de Nⱼ)
N_Q8 = Simplify{[1, xi, eta, xi^2, xi*eta, eta^2, xi^2*eta, xi*eta^2]*[-0.25, -0.25, -0.25, -0.25, 0.5, 0.5, 0.5, 0.5; 0, 0, 0, 0, 0, 0.5, 0, -0.5; 0, 0, 0, 0, -0.5, 0, 0.5, 0; 0.25, 0.25, 0.25, 0.25, -0.5, 0, -0.5, 0; 0.25, -0.25, 0.25, -0.25, 0, 0, 0, 0; 0.25, 0.25, 0.25, 0.25, 0, -0.5, 0, -0.5; -0.25, -0.25, 0.25, 0.25, 0.5, 0, -0.5, 0; -0.25, 0.25, 0.25, -0.25, 0, -0.5, 0, 0.5]}
#: Las esquinas son **N₁ = (1 − ξ)(1 − η)(−ξ − η − 1)/4** y los lados **N₅ = (1 − ξ²)(1 − η)/2**. El motor lo comprueba (columna de C⁻¹ contra la forma factorizada):
n_81 = Simplify{[1, xi, eta, xi^2, xi*eta, eta^2, xi^2*eta, xi*eta^2]*[-0.25; 0; 0; 0.25; 0.25; 0.25; -0.25; -0.25]} 'base · columna 1 de C⁻¹
f_81e = Simplify{(1 - xi)*(1 - eta)*(-xi - eta - 1)/4} 'forma factorizada expandida: igual
n_85 = Simplify{[1, xi, eta, xi^2, xi*eta, eta^2, xi^2*eta, xi*eta^2]*[0.5; 0; -0.5; -0.5; 0; 0; 0.5; 0]} 'base · columna 5 de C⁻¹
f_85 = Simplify{(1 - xi^2)*(1 - eta)/2} 'igual
#: **¿Por qué no es un producto?** La esquina del Q8 menos la esquina del Q9:
q_89 = Simplify{(1 - xi)*(1 - eta)*(-xi - eta - 1)/4 - xi*(xi - 1)/2*eta*(eta - 1)/2}
#: Es **−(1 − ξ²)(1 − η²)/4 = −N₉/4**: la esquina del Q8 es la del Q9 a la que se le repartió el nudo central que ya no existe. Por eso el Q8 no sale de multiplicar dos parábolas: tiene ξ²η y ξη² pero no ξ²η² (por eso se llama «serendípito», hallado por casualidad).
#: La esquina del Q8 en 3D: vale 1 en (−1, −1), 0 en los otros 7 nudos, y se hunde hasta −1/4 en el centro:
#surf((1 - x)*(1 - y)*(-x - y - 1)/4, [-1 1], [-1 1])
n_c8 = (1 - 0)*(1 - 0)*(-0 - 0 - 1)/4 'N₁ del Q8 en el centro
#: Corte por el lado η = −1: **en el borde Q8 y Q9 son la misma parábola** ξ(ξ − 1)/2 (así dos elementos vecinos encajan). Corte por el centro η = 0: ahí sí difieren (Q9 da 0, Q8 da −(1 − ξ)(ξ + 1)/4):
#fplot(borde_Q8 = (1 - x)*2*(-x)/4, borde_Q9 = x*(x - 1)/2, centro_Q8 = (1 - x)*(-x - 1)/4, centro_Q9 = 0*x, nudos = [-1 1; 0 0; 1 0], [-1 1])

## 4 · Propiedades: el motor las comprueba
#: **(a) Partición de la unidad, ΣNᵢ = 1.** Hay un atajo precioso: la suma es base·C⁻¹·[1; 1; …; 1], y como la **primera columna de C es toda de unos**, C⁻¹·[1; …; 1] = [1; 0; …; 0]. Queda base·[1; 0; …] = 1. El motor:
s_4 = Simplify{[1, xi, eta, xi*eta]*(inv([1, -1, -1, 1; 1, 1, -1, -1; 1, 1, 1, 1; 1, -1, 1, -1])*[1; 1; 1; 1])} 'ΣN del Q4
c_s8 = inv(C_8)*[1; 1; 1; 1; 1; 1; 1; 1] 'coeficientes = C⁻¹·valores
s_8 = Simplify{[1, xi, eta, xi^2, xi*eta, eta^2, xi^2*eta, xi*eta^2]*[1; 0; 0; 0; 0; 0; 0; 0]} 'ΣN del Q8
c_s9 = inv(C_9)*[1; 1; 1; 1; 1; 1; 1; 1; 1] 'coeficientes = C⁻¹·valores
s_9 = Simplify{[1, xi, eta, xi^2, xi*eta, eta^2, xi^2*eta, xi*eta^2, xi^2*eta^2]*[1; 0; 0; 0; 0; 0; 0; 0; 0]} 'ΣN del Q9
#: **(b) Delta de Kronecker:** Nᵢ(nudo j) = 1 si i = j, 0 si no. N₁ del Q8 en sus 8 nudos:
f_81(xi, eta) = (1 - xi)*(1 - eta)*(-xi - eta - 1)/4
k_81 = [f_81(-1, -1), f_81(1, -1), f_81(1, 1), f_81(-1, 1), f_81(0, -1), f_81(1, 0), f_81(0, 1), f_81(-1, 0)] '1 en el nudo 1, 0 en los demás
#: **(c) Completitud: reproduce x.** Si a los nudos se les da su propia coordenada ξᵢ, la interpolación devuelve ξ exacto (un estado de deformación constante se representa sin error):
r_4 = Simplify{[1, xi, eta, xi*eta]*(inv([1, -1, -1, 1; 1, 1, -1, -1; 1, 1, 1, 1; 1, -1, 1, -1])*[-1; 1; 1; -1])} 'ΣNᵢξᵢ (Q4)
c_r8 = inv(C_8)*[-1; 1; 1; -1; 0; 1; 0; -1] 'coeficientes = C⁻¹·valores
r_8 = Simplify{[1, xi, eta, xi^2, xi*eta, eta^2, xi^2*eta, xi*eta^2]*[0; 1; 0; 0; 0; 0; 0; 0]} 'ΣNᵢξᵢ (Q8)
#: ¿Y ξ²? Con los valores ξᵢ² en los nudos, el Q4 devuelve **1** (no puede curvarse: la flexión le cuesta), el Q8 y el Q9 devuelven **ξ²**:
p_4 = Simplify{[1, xi, eta, xi*eta]*(inv([1, -1, -1, 1; 1, 1, -1, -1; 1, 1, 1, 1; 1, -1, 1, -1])*[1; 1; 1; 1])} 'ΣNᵢξᵢ² (Q4): no es ξ²
c_p8 = inv(C_8)*[1; 1; 1; 1; 0; 1; 0; 1] 'coeficientes = C⁻¹·valores
p_8 = Simplify{[1, xi, eta, xi^2, xi*eta, eta^2, xi^2*eta, xi*eta^2]*[0; 0; 0; 1; 0; 0; 0; 0]} 'ΣNᵢξᵢ² (Q8)
#: Y ξ²η² (con los valores ξᵢ²ηᵢ²): solo el Q9 lo reproduce; el Q8 da otra cosa:
c_p88 = inv(C_8)*[1; 1; 1; 1; 0; 0; 0; 0] 'coeficientes = C⁻¹·valores
p_88 = Simplify{[1, xi, eta, xi^2, xi*eta, eta^2, xi^2*eta, xi*eta^2]*[-1; 0; 0; 1; 0; 1; 0; 0]} 'Q8: ξ² + η² − 1, no ξ²η²
c_p99 = inv(C_9)*[1; 1; 1; 1; 0; 0; 0; 0; 0] 'coeficientes = C⁻¹·valores
p_99 = Simplify{[1, xi, eta, xi^2, xi*eta, eta^2, xi^2*eta, xi*eta^2, xi^2*eta^2]*[0; 0; 0; 0; 0; 0; 0; 0; 1]} 'Q9: ξ²η²
#: **(d) Derivadas.** Lo que entra en la rigidez son ∂N/∂ξ y ∂N/∂η. Como ΣN = 1 es constante, la suma de las derivadas es **cero** (un movimiento rígido no deforma):
e_41 = Simplify{Diff{(1 - xi)*(1 - eta)/4 @ xi}} '∂N₁/∂ξ del Q4: no depende de ξ
e_81 = Simplify{Diff{(1 - xi)*(1 - eta)*(-xi - eta - 1)/4 @ xi}} '∂N₁/∂ξ del Q8: depende de ξ
e_85 = Simplify{Diff{(1 - xi^2)*(1 - eta)/2 @ xi}} '∂N₅/∂ξ del Q8
e_4s = Simplify{Diff{(1 - xi)*(1 - eta)/4 + (1 + xi)*(1 - eta)/4 + (1 + xi)*(1 + eta)/4 + (1 - xi)*(1 + eta)/4 @ xi}} 'Σ∂N/∂ξ = 0
#: En el Q4, ∂N₁/∂ξ = −(1 − η)/4 es **constante a lo largo de ξ**: la deformación εₓ no puede variar en la dirección x dentro del elemento. Eso es justo lo que la flexión necesita y el Q4 no tiene (sección 7).

## 5 · Jacobiano y B en un elemento real (m)
#: El elemento de la obra no es un cuadrado de −1 a +1. Se usan **las mismas N** para la geometría (isoparamétrico): x = ΣNᵢxᵢ, y = ΣNᵢyᵢ. Un Q4 deformado con nudos (en m):
#dibujo("Q4 real: nudos 1 (0, 0), 2 (2, 0), 3 (2.4, 1.6), 4 (0.4, 1.2) m", ud = m, escala = auto, cotas = m, alto = 55)
#  poligono(0, 0, 2, 0, 2.4, 1.6, 0.4, 1.2, "gruesa")
#  circulo(0, 0, 0.05, "negro")
#  circulo(2, 0, 0.05, "negro")
#  circulo(2.4, 1.6, 0.05, "negro")
#  circulo(0.4, 1.2, 0.05, "negro")
#  texto(-0.15, -0.15, "1", 2.4, "c")
#  texto(2.15, -0.15, "2", 2.4, "c")
#  texto(2.55, 1.75, "3", 2.4, "c")
#  texto(0.25, 1.35, "4", 2.4, "c")
#  cota(0, -0.4, 2, -0.4, 0, "2 m")
#  cota(2.7, 0, 2.7, 1.6, 0, "1.6 m")
#fin
x_m = Simplify{[1, xi, eta, xi*eta]*(inv([1, -1, -1, 1; 1, 1, -1, -1; 1, 1, 1, 1; 1, -1, 1, -1])*[0; 2; 2.4; 0.4])} 'x(ξ, η) [m]
y_m = Simplify{[1, xi, eta, xi*eta]*(inv([1, -1, -1, 1; 1, 1, -1, -1; 1, 1, 1, 1; 1, -1, 1, -1])*[0; 0; 1.6; 1.2])} 'y(ξ, η) [m]
#: El Jacobiano J dice cuánto se estira el cuadrado de referencia: J = [∂x/∂ξ, ∂y/∂ξ; ∂x/∂η, ∂y/∂η]. El motor deriva:
j_11 = Simplify{Diff{6/5 + xi + eta/5 @ xi}} '∂x/∂ξ [m]
j_12 = Simplify{Diff{7/10 + xi/10 + 7*eta/10 + xi*eta/10 @ xi}} '∂y/∂ξ [m]
j_21 = Simplify{Diff{6/5 + xi + eta/5 @ eta}} '∂x/∂η [m]
j_22 = Simplify{Diff{7/10 + xi/10 + 7*eta/10 + xi*eta/10 @ eta}} '∂y/∂η [m]
#: Su determinante es el factor de área: dA = det J·dξ·dη:
d_J = Simplify{1*(7/10 + xi/10) - (1/10 + eta/10)*(1/5)} 'det J [m²]
#: **det J = 17/25 + ξ/10 − η/50**, lineal (en un paralelogramo sería constante). En los 4 puntos de Gauss (ξ, η = ±1/√3):
g_J(a, b) = 17/25 + a/10 - b/50
g_s = 1/sqrt(3)
v_J = [g_J(-g_s, -g_s), g_J(g_s, -g_s), g_J(g_s, g_s), g_J(-g_s, g_s)] 'det J en los 4 puntos [m²]
A_r = g_J(-g_s, -g_s) + g_J(g_s, -g_s) + g_J(g_s, g_s) + g_J(-g_s, g_s) 'Σ det J·1·1 = área [m²]
#: El área del cuadrilátero (diagonales) es ½|d₁ × d₂| = ½|2.4·1.2 − 1.6·(−1.6)| = 2.72 m²: Gauss 2 × 2 la da exacta.
#: **B (deformación desde los nudos).** Las derivadas en x e y salen de invertir J: [∂N/∂x; ∂N/∂y] = J⁻¹·[∂N/∂ξ; ∂N/∂η]. En el centro (ξ = η = 0):
J_0 = [1, 1/10; 1/5, 7/10] 'J en el centro [m]
D_0 = [-1/4, 1/4, 1/4, -1/4; -1/4, -1/4, 1/4, 1/4] '∂N/∂ξ y ∂N/∂η en el centro
G_0 = inv(J_0)*D_0 '∂N/∂x y ∂N/∂y en el centro [1/m]
#: Con esas dos filas se arma B (3 × 8): εₓ = Σ∂Nᵢ/∂x·uᵢ, ε_y = Σ∂Nᵢ/∂y·vᵢ, γ = Σ(∂Nᵢ/∂y·uᵢ + ∂Nᵢ/∂x·vᵢ). Comprobación: las dos filas suman cero (movimiento rígido sin deformación):
z_0 = G_0*[1; 1; 1; 1] 'Σ ∂N/∂x y Σ ∂N/∂y
#: **¿Y si se distorsiona demasiado?** Se mete el nudo 3 hacia adentro, a (0.6, 0.5) m: el cuadrilátero se vuelve **cóncavo**. Su det J:
x_c = Simplify{[1, xi, eta, xi*eta]*(inv([1, -1, -1, 1; 1, 1, -1, -1; 1, 1, 1, 1; 1, -1, 1, -1])*[0; 2; 3/5; 2/5])} 'x(ξ, η) con el nudo 3 en (0.6, 0.5)
g_c(a, b) = ((2 - 0)*(1 - b) + (0.6 - 0.4)*(1 + b))/4*((1.2 - 0)*(1 - a) + (0.5 - 0)*(1 + a))/4 - ((0 - 0)*(1 - b) + (0.5 - 1.2)*(1 + b))/4*((0.4 - 0)*(1 - a) + (0.6 - 2)*(1 + a))/4
v_c = [g_c(-1, -1), g_c(1, -1), g_c(1, 1), g_c(-1, 1)] 'det J en las esquinas [m²]
w_c = [g_c(-g_s, -g_s), g_c(g_s, -g_s), g_c(g_s, g_s), g_c(-g_s, g_s)] 'det J en los puntos de Gauss [m²]
#: **det J < 0 en la esquina 3 (−0.22 m²) y en su punto de Gauss (−0.047 m²)**: el mapa se «da vuelta» y ese pedazo aporta área y rigidez **negativas**. Los programas paran con «Jacobiano no positivo». Mapa de det J del cuadrilátero sano (arriba) y del cóncavo (abajo), en ξ–η:
#map(17/25 + x/10 - y/50, [-1 1], [-1 1])
#map(((2)*(1 - y) + (0.2)*(1 + y))/4*((1.2)*(1 - x) + (0.5)*(1 + x))/4 - ((-0.7)*(1 + y))/4*((0.4)*(1 - x) + (-1.4)*(1 + x))/4, [-1 1], [-1 1])
#: En el Q8 pasa lo mismo si un nudo de lado se corre: en un cuadrado de 2 m, con el nudo 5 a ¼ del lado (x = 0.5 m) det J = 0 en la esquina 1 (el «elemento de cuarto de punto» que se usa a propósito en la punta de una grieta); más allá, det J < 0 (calculado en Python: x₅ = 0.4 m → det J = −0.2 m²).

## 6 · Gauss: cuántos puntos y qué pasa si faltan
#: Con n puntos por dirección, Gauss integra **exacto** un polinomio de grado 2n − 1. En un rectángulo de lados 2a × 2b, un término de la rigidez es ∫∫(∂N₁/∂x)² dA, con ∂N/∂x = (∂N/∂ξ)/a y dA = a·b·dξ·dη. El integrando es de grado 2 en el Q4 y de grado 4 en el Q8/Q9. Q4, exacta contra Gauss:
i_4 = Simplify{Integral{Integral{(1 - eta)^2/(16*a^2)*a*b @ xi = -1 : 1} @ eta = -1 : 1}} 'exacta
i_41 = Simplify{4*(1 - 0)^2/(16*a^2)*a*b} '1 punto (peso 4): falta
i_42 = Simplify{2*(1 + 1/sqrt(3))^2/(16*a^2)*a*b + 2*(1 - 1/sqrt(3))^2/(16*a^2)*a*b} '2 × 2: exacta
#: Lo mismo con la esquina del Q8, cuyo integrando ((1 − η)(2ξ + η)/4)² es de grado 4:
i_8 = Simplify{Integral{Integral{((1 - eta)*(2*xi + eta)/4)^2/a^2*a*b @ xi = -1 : 1} @ eta = -1 : 1}} 'exacta: 26b/45a = 0.5778·b/a
q_8(a, b) = ((1 - b)*(2*a + b)/4)^2
i_82 = q_8(-g_s, -g_s) + q_8(g_s, -g_s) + q_8(g_s, g_s) + q_8(-g_s, g_s) '2 × 2 (·b/a): 0.5556, no alcanza
t_3 = sqrt(3/5)
i_83 = 25/81*(q_8(-t_3, -t_3) + q_8(t_3, -t_3) + q_8(t_3, t_3) + q_8(-t_3, t_3)) + 40/81*(q_8(0, -t_3) + q_8(t_3, 0) + q_8(0, t_3) + q_8(-t_3, 0)) + 64/81*q_8(0, 0) '3 × 3 (·b/a): 0.5778, exacta
#: **Integración reducida y modos de energía nula.** Con 1 solo punto (el centro), el Q4 no «ve» el modo de reloj de arena u = ξη: su deformación ∂(ξη)/∂ξ = η vale **cero justo en el centro**:
m_1 = Simplify{Diff{xi*eta @ xi}} 'εₓ del modo ξη
m_c = 0 'η en el único punto de Gauss → energía 0
m_2 = 4*(1/3) 'con 2 × 2: Σ η² = 4·(1/3) ≠ 0
#: El elemento se deforma así **sin costar energía**: K tiene más ceros de los 3 de cuerpo rígido. Autovalores nulos de K (cuadrado unitario, ν = 0.25), contados en Python (numpy) y confirmados con Hekatan OpenSees:
u_a = [5, 3, 4, 3, 6, 3] 'autovalores nulos
u_b = [3, 3, 3, 3, 3, 3] 'de cuerpo rígido
u_c = [2, 0, 1, 0, 3, 0] 'espurios
#tabla("Elemento e integración","autovalores nulos de K:0","de cuerpo rígido:0","modos espurios:0")({"Q4, 1 punto","Q4, 2 × 2","Q8, 2 × 2 (reducida)","Q8, 3 × 3","Q9, 2 × 2 (reducida)","Q9, 3 × 3"}; u_a; u_b; u_c)
#: El Q4 con 1 punto tiene 2 relojes de arena (hourglass): en una malla se propagan y la deformada sale en zigzag. El Q8 con 2 × 2 tiene 1 espurio que **no se propaga** entre vecinos (por eso el Q8 reducido es tan usado). El Q9 con 2 × 2 tiene 3 y es peligroso.

## 7 · El mismo voladizo con Q4, Q8 y Q9
#dibujo("Voladizo: L = 4 m, h = 0.5 m, t = 0.2 m, E = 25 GPa, ν = 0.2; P = 10 kN en la punta (cortante parabólico). Malla 4 × 1", ud = m, escala = auto, cotas = m, alto = 45)
#  achurado([-0.3, 0, 0, -0.3], [-0.45, -0.45, 0.45, 0.45], "concreto")
#  poligono(0, -0.25, 4, -0.25, 4, 0.25, 0, 0.25, "gruesa")
#  linea(1, -0.25, 1, 0.25, "fina")
#  linea(2, -0.25, 2, 0.25, "fina")
#  linea(3, -0.25, 3, 0.25, "fina")
#  flecha(4, 0.85, 4, 0.27, "gruesa rojo")
#  texto(4.25, 0.9, "P", 2.6, "c")
#  cota(0, -0.6, 4, -0.6, 0, "L = 4 m")
#  cota(4.4, -0.25, 4.4, 0.25, 0, "h = 0.5 m")
#fin
E_c = 25000000 'E [kPa]
I_c = 0.2*0.5^3/12 'I = t·h³/12 [m⁴]
d_EB = 1000*10*4^3/(3*E_c*I_c) 'flecha de Euler-Bernoulli PL³/3EI [mm]
G_c = E_c/(2*(1 + 0.2)) 'G [kPa]
d_T = d_EB + 1000*10*4/(5/6*G_c*0.2*0.5) '+ cortante PL/(κGA) (Timoshenko) [mm]
#: Referencia: malla muy fina (Q9 de 64 × 8) = **4.13736 mm** (la viga de Timoshenko da 4.14208; la diferencia es el empotramiento, que en elasticidad no deja girar la sección). Flecha en la punta con cada elemento, en mm. Calculado en Python y con Hekatan OpenSees (quad, quad8n, quad9n): **iguales hasta 1e−8 mm** con la misma malla nudo a nudo y las mismas fuerzas:
u_d = [0.14927, 0.53656, 1.52714, 2.89062, 3.73189] 'Q4 [mm]
u_e = [3.6, 13.0, 36.9, 69.9, 90.2] '% Q4
u_f = [3.22824, 3.92443, 4.08358, 4.12789, 4.13502] 'Q8 [mm]
u_g = [78.0, 94.9, 98.7, 99.8, 99.9] '% Q8
u_h = [3.25258, 3.96684, 4.10403, 4.13117, 4.13576] 'Q9 [mm]
u_i = [78.6, 95.9, 99.2, 99.9, 100.0] '% Q9
#tabla("Malla","Q4 2×2 [mm]:4","% Q4:1","Q8 3×3 [mm]:4","% Q8:1","Q9 3×3 [mm]:4","% Q9:1")({"1 × 1","2 × 1","4 × 1","8 × 2","16 × 4"}; u_d; u_e; u_f; u_g; u_h; u_i)
#: **El Q4 se «traba» en flexión (shear locking):** como ∂N/∂ξ no varía en ξ (sección 4d), el Q4 no puede curvarse y para doblarse inventa una **distorsión angular γ falsa** que se come la energía. Con 4 elementos da el 37 %; el Q8 y el Q9, el 99 %. Porcentaje de la flecha correcta contra el número de elementos a lo largo (pasa el cursor):
#hide
c_Q4 = [1, 3.6; 2, 13.0; 4, 36.9; 8, 69.9; 16, 90.2]
c_Q8 = [1, 78.0; 2, 94.9; 4, 98.7; 8, 99.8; 16, 99.9]
c_Q9 = [1, 78.6; 2, 95.9; 4, 99.2; 8, 99.9; 16, 100.0]
#show
#fplot(Q4 = c_Q4, Q8 = c_Q8, Q9 = c_Q9, correcto = 100 + 0*x, [0 16])
#: **Bloqueo volumétrico.** Ahora en deformación plana y con ν → 0.5 (arcilla saturada, goma, concreto confinado: casi no cambia de volumen). Malla 8 × 2, % de la flecha correcta (referencia: Q8 de 128 × 16):
u_j = [3.76065, 3.27478, 3.10837, 3.06753, 3.06255] 'flecha correcta [mm]
u_k = [70.5, 53.6, 22.1, 4.2, 1.8] '% Q4
u_l = [99.1, 95.5, 92.1, 90.8, 90.6] '% Q8 3×3
u_m = [99.4, 96.9, 93.5, 91.6, 91.3] '% Q8 2×2
u_n = [99.4, 96.7, 93.0, 91.0, 90.7] '% Q9
#tabla("ν","flecha correcta [mm]:5","Q4 %:1","Q8 3×3 %:1","Q8 2×2 %:1","Q9 3×3 %:1")({"0.3","0.45","0.49","0.499","0.4999"}; u_j; u_k; u_l; u_m; u_n)
#: El Q4 **se congela** (1.8 %): con ν = 0.4999 cada punto de Gauss exige volumen constante y 4 puntos × 1 restricción ahogan a los pocos movimientos que tiene. El Q8 y el Q9 se quedan en ~91 % (el resto es la esquina empotrada, que converge lento con cualquier elemento).
#: **Las curas del Q4**, probadas en Hekatan OpenSees con la misma malla: enhancedQuad (modos incompatibles) 98.4 % en flexión con 4 × 1 y 92.4 % con ν = 0.4999; bbarQuad (B-barra, presión constante) 88.7 % con ν = 0.4999; SSPquad (1 punto + estabilización) se pasa: 234.8 % con 4 × 1 (demasiado blando).

## 8 · ¿Cuándo uso cada uno?
#hide

#show
#tabla("Elemento","Gauss completo","lo bueno","lo malo")({"Q4 (4 nudos)","Q8 (8 nudos)","Q9 (9 nudos)"}; {"2 × 2","3 × 3 (o 2 × 2 reducido)","3 × 3"}; {"simple, barato, malla fácil","flexión casi exacta, borde curvo; 2 × 2 sin propagar espurios","el más completo (reproduce ξ²η²), aguanta más distorsión"}; {"shear locking en flexión; bloqueo con ν → 0.5","más nudos; sensible a nudos de lado corridos","nudo central; 2 × 2 da 3 modos espurios"})
#tabla("Elemento","úsalo en")({"Q4","Q8","Q9"}; {"membranas y mallas densas; o sus versiones mejoradas (enhanced, B-barra)","muros, vigas de gran altura, suelos (consolidación: Q8 + presión Q4)","suelos casi incompresibles, mallas gruesas, elementos distorsionados"})
#: **Resumen en una línea:** las tres familias salen de lo mismo (base → C → C⁻¹ → N); lo que cambia es **qué polinomio cabe adentro**. Si la solución tiene curvatura (flexión) o volumen constante, el Q4 se queda corto: usa Q8/Q9 o malla fina. Siguiente hoja: triángulos T3 y T6 (205) y sólidos H8 (206).
#> Fuentes: O. C. Zienkiewicz, R. L. Taylor, *The Finite Element Method*, vol. 1, cap. 6 (Lagrange y serendípito) y cap. 10 (integración reducida); R. D. Cook et al., *Concepts and Applications of Finite Element Analysis*, cap. 6 y 7 (Q4 en flexión, modos espurios); K. J. Bathe, *Finite Element Procedures*, cap. 5 (Jacobiano). Números: hekatan-school/VIDEOS/01_elementos_finitos_funciones_de_forma/ff_q4q8_manim/juez (Python y Hekatan OpenSees).
