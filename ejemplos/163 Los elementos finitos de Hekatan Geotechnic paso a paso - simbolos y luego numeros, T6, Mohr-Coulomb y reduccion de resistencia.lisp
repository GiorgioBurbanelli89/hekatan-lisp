# Los elementos finitos de Hekatan Geotechnic paso a paso: de los símbolos a los números
#numerico
#: **Hekatan Geotechnic** calcula la estabilidad de un talud por elementos finitos con el elemento **T6**: un triángulo de **6 nudos** (3 esquinas y 3 puntos medios) en **deformación plana**. Esta hoja hace, en el orden de siempre, lo que hace el motor por dentro: **datos → malla → funciones de forma → Jacobiano → matriz B → matriz constitutiva → cuadratura de Gauss → rigidez → ensamblaje → carga de gravedad → apoyos → solución → tensiones → plasticidad de Mohr-Coulomb → reducción de resistencia**.
#: **Cómo se lee.** En cada paso primero van las **operaciones simbólicas** (con letras: la deducción, el porqué) y después las **numéricas** (con los datos de esta hoja). Al final, cada número se compara con el que da el solver real de Geotechnic para el mismo bloque.
#: **Idea en una frase:** la rigidez es la energía de deformación del elemento, **K = ∫ Bᵀ·D·B dA**. B convierte los desplazamientos de los nudos en deformaciones, D convierte deformaciones en tensiones, y la integral suma sobre el área. Todo el motor es esto, repetido en cada triángulo.

## 1 · Datos
#: Un bloque de suelo de **4 m × 2 m** apoyado en una base rígida. Se usan **solo 2 elementos T6** para que cada número quepa en pantalla; el motor real usa cientos, con exactamente las mismas fórmulas.
#: **Mira la Figura 1:** es el problema completo, con sus datos, su carga (el peso propio) y su apoyo.
#dibujo("Figura 1. El problema: un bloque de suelo de 4 m × 2 m sobre una base rígida, cargado por su propio peso", ud = m, ancho = 200, alto = 109)
#  achurado(-0.6, -0.45, 5.2, 0.45, "terreno")
#  poligono([0, 4, 4, 0], [0, 0, 2, 2], "azul tenue")
#  polilinea([0, 4, 4, 0, 0], [0, 0, 2, 2, 0], "gruesa")
#  flecha(0.8, 1.85, 0.8, 1.15, "rojo")
#  flecha(2, 1.85, 2, 1.15, "rojo")
#  flecha(3.2, 1.85, 3.2, 1.15, "rojo")
#  texto(2.1, 0.78, "peso propio  γ = 18 kN/m³", 3, "c", estilo = "rojo")
#  cota(0, -0.55, 4, -0.55, -0.2, "Lx = 4 m")
#  cota(-0.5, 0, -0.5, 2, 0.2, "Ly = 2 m")
#  texto(2, 0.35, "suelo: E = 20000 kPa, ν = 0.3, c = 2 kPa, φ = 25°", 2.6, "c")
#  texto(2, -1.2, "base fija (u = v = 0); los lados quedan libres", 2.8, "c")
#fin
#: En símbolos. El problema queda definido por la geometría (Lx, Ly) y el suelo (E, ν, γ, c, φ). De ellos salen directamente el módulo de corte, el peso del bloque y la presión sobre la base:
Gc_s = Simplify{E_m/(2*(1 + ν_m))}
Wt_s = Simplify{γ_m*Lx*Ly}
qb_s = Simplify{γ_m*Lx*Ly/Lx}
#: Con números (los datos de esta hoja):
B = 4 [m] 'ancho del bloque
H = 2 [m] 'alto del bloque
E = 20000 [kPa] 'módulo de elasticidad del suelo
ν = 0.3 'coeficiente de Poisson
γ = 18 [kN/m³] 'peso unitario
c = 2 [kPa] 'cohesión
phi_g = 25 'ángulo de fricción en grados
phi = phi_g·pi/180 'ángulo de fricción en radianes
#: **Unidades.** kPa para E y tensiones, m para longitudes, kN para fuerzas. Entonces K sale en kN/m y los desplazamientos en m (se muestran en mm).

## 2 · La malla: dos triángulos de 6 nudos
#: El bloque se parte en dos triángulos por la diagonal. **Numeración de cada T6:** primero las 3 esquinas en sentido antihorario, después los 3 puntos medios de los lados 1-2, 2-3 y 3-1. Cada nudo tiene 2 grados de libertad (u, v): el nudo j usa los grados 2j−1 y 2j.
#: En símbolos. Dos triángulos iguales de base Lx y altura Ly tienen cada uno el área ½·Lx·Ly, y entre los dos cubren **justo el bloque** (Lx·Ly). Con N nudos hay 2N grados de libertad:
Am_s = Simplify{Lx*Ly/2 + Lx*Ly/2}
gdl_s = Simplify{2*N_m}
#: Con números:
x_j = [0, 4, 4, 0, 2, 4, 2, 2, 0] 'coordenada x de cada nudo, en m (sin unidad: así se puede indexar)
y_j = [0, 0, 2, 2, 0, 1, 1, 2, 1] 'coordenada y de cada nudo, en m
e_j = [1, 2, 3, 5, 6, 7; 1, 3, 4, 7, 8, 9]
s_j = [1, 2, 5]
n_j = 9 'nudos
n_e = 2 'elementos
n_d = 2·n_j 'grados de libertad en total
#: Cada fila de e_j es un elemento (esquinas 1-2-3 y medios 4-5-6). **Apoyos:** los tres nudos de la base (y = 0) quedan fijos en x e y: **6 grados de libertad fijos, 12 libres.** Los lados quedan libres.
#: **Mira la Figura 2:** los 9 nudos, los 2 elementos y los grados de libertad. Los nudos 1, 2 y 5 (la base) son los apoyos.
#dibujo("Figura 2. La malla: 2 elementos T6, 9 nudos y 18 grados de libertad (el nudo j usa los grados 2j−1 = u y 2j = v)", ud = m, ancho = 200, alto = 103)
#  poligono([0, 4, 4], [0, 0, 2], "verde tenue")
#  poligono([0, 4, 0], [0, 2, 2], "azul tenue")
#  polilinea([0, 4, 4, 0, 0], [0, 0, 2, 2, 0], "gruesa")
#  linea(0, 0, 4, 2, "media")
#  circulo(0, 0, 0.09, "azul relleno")
#  circulo(4, 0, 0.09, "azul relleno")
#  circulo(4, 2, 0.09, "azul relleno")
#  circulo(0, 2, 0.09, "azul relleno")
#  circulo(2, 0, 0.06, "fina")
#  circulo(4, 1, 0.06, "fina")
#  circulo(2, 1, 0.06, "fina")
#  circulo(2, 2, 0.06, "fina")
#  circulo(0, 1, 0.06, "fina")
#  texto(-0.12, -0.32, "1", 3.2, "c")
#  texto(4.12, -0.32, "2", 3.2, "c")
#  texto(4.2, 2.12, "3", 3.2, "i")
#  texto(-0.2, 2.12, "4", 3.2, "d")
#  texto(2, -0.32, "5", 3.2, "c")
#  texto(4.2, 1, "6", 3.2, "i")
#  texto(2.15, 0.72, "7", 3.2, "i")
#  texto(2, 2.28, "8", 3.2, "c")
#  texto(-0.2, 1, "9", 3.2, "d")
#  texto(3, 0.45, "elemento 1", 2.8, "c", estilo = "azul")
#  texto(1, 1.55, "elemento 2", 2.8, "c", estilo = "azul")
#  flecha(4, 2, 4.9, 2, "rojo")
#  texto(4.95, 2, "u₃ (grado 5)", 2.6, "i", estilo = "rojo")
#  flecha(4, 2, 4, 2.8, "rojo")
#  texto(4, 2.9, "v₃ (grado 6)", 2.6, "c", estilo = "rojo")
#  achurado(-0.6, -0.45, 5.2, 0.45, "terreno")
#  texto(2, -1, "nudos 1, 2 y 5 fijos: 6 grados de libertad fijos y 12 libres", 2.6, "c")
#fin

## 3 · Funciones de forma del T6
#: En símbolos. El triángulo de referencia tiene coordenadas de área **ξ, η y ζ = 1 − ξ − η** (valen 1 en un vértice y 0 en el lado opuesto). Cada función de forma debe valer **1 en su nudo y 0 en los otros cinco**. Las de las esquinas son N = L(2L − 1); las de los puntos medios, N = 4·L_a·L_b:
#: **Mira la Figura 3:** el triángulo de referencia con sus 6 nudos y sus coordenadas. Las funciones de forma se definen sobre ÉL, no sobre el elemento real.
#dibujo("Figura 3. El triángulo de referencia del T6: coordenadas de área ξ, η y ζ = 1 − ξ − η; los nudos 4, 5 y 6 están en los puntos medios", ud = m, ancho = 188, alto = 145)
#  poligono([0, 1, 0], [0, 0, 1], "azul tenue")
#  polilinea([0, 1, 0, 0], [0, 0, 1, 0], "gruesa")
#  flecha(-0.2, 0, 1.3, 0, "negro")
#  texto(1.33, 0, "ξ", 3.4, "i")
#  flecha(0, -0.2, 0, 1.25, "negro")
#  texto(0, 1.3, "η", 3.4, "c")
#  circulo(0, 0, 0.028, "azul relleno")
#  circulo(1, 0, 0.028, "azul relleno")
#  circulo(0, 1, 0.028, "azul relleno")
#  circulo(0.5, 0, 0.02, "fina")
#  circulo(0, 0.5, 0.02, "fina")
#  circulo(0.5, 0.5, 0.02, "fina")
#  texto(-0.05, -0.1, "3  (ξ=0, η=0)", 2.5, "d")
#  texto(1.05, -0.1, "1  (ξ=1, η=0)", 2.5, "i")
#  texto(-0.05, 1.07, "2  (ξ=0, η=1)", 2.5, "d")
#  texto(0.5, -0.1, "6", 2.6, "c")
#  texto(-0.06, 0.5, "5", 2.6, "d")
#  texto(0.55, 0.55, "4", 2.6, "i")
#  linea(0.5, 0, 0.5, 0.5, "trazos")
#  texto(0.52, 0.2, "ξ = ½", 2.3, "i", estilo = "azul")
#  texto(0.78, 0.82, "ζ = 0", 2.4, "i", estilo = "rojo")
#  texto(0.12, 0.12, "ζ = 1", 2.3, "i", estilo = "rojo")
#fin
N_1 = Expand{xi*(2*xi - 1)}
N_2 = Expand{eta*(2*eta - 1)}
N_3 = Expand{(1 - xi - eta)*(2*(1 - xi - eta) - 1)}
N_4 = Expand{4*xi*eta}
N_5 = Expand{4*eta*(1 - xi - eta)}
N_6 = Expand{4*(1 - xi - eta)*xi}
#: **Partición de la unidad.** Las seis deben sumar 1 en todo el elemento; si no, el elemento no puede representar un movimiento de cuerpo rígido:
particion = Simplify{xi*(2*xi - 1) + eta*(2*eta - 1) + (1 - xi - eta)*(2*(1 - xi - eta) - 1) + 4*xi*eta + 4*eta*(1 - xi - eta) + 4*(1 - xi - eta)*xi}
#: **Así se ven.** A lo largo del lado 3→1 (η = 0), las tres funciones que tocan ese lado: cada una vale 1 en su nudo y 0 en los otros dos (N₃ en ξ = 0, N₆ en ξ = ½, N₁ en ξ = 1). Es la propiedad que las define:
#fplot(N_1 = x*(2*x - 1), N_3 = (1 - x)*(1 - 2*x), N_6 = 4*x*(1 - x), [0 1])
#: **Derivadas** respecto a ξ y a η (con ζ = 1 − ξ − η). Son las que necesita la deformación; salen **lineales**, así que la deformación del T6 varía linealmente dentro del elemento:
dN1_dxi = Derivate{xi*(2*xi - 1) @ xi}
dN4_dxi = Derivate{4*xi*eta @ xi}
dN5_dxi = Derivate{4*eta*(1 - xi - eta) @ xi}
dN6_dxi = Derivate{4*(1 - xi - eta)*xi @ xi}
dN3_deta = Derivate{(1 - xi - eta)*(2*(1 - xi - eta) - 1) @ eta}
#: Con números. Las seis funciones y sus 12 derivadas como funciones (fila 1: ∂N/∂ξ; fila 2: ∂N/∂η, una columna por nudo):
Nq(xi, eta) = [xi*(2*xi - 1), eta*(2*eta - 1), (1 - xi - eta)*(2*(1 - xi - eta) - 1), 4*xi*eta, 4*eta*(1 - xi - eta), 4*(1 - xi - eta)*xi]
dNq(xi, eta) = [4*xi - 1, 0, -(4*(1 - xi - eta) - 1), 4*eta, -4*eta, 4*(1 - xi - eta) - 4*xi; 0, 4*eta - 1, -(4*(1 - xi - eta) - 1), 4*xi, 4*(1 - xi - eta) - 4*eta, -4*xi]
#: En el centro del triángulo (ξ = η = 1/3) las esquinas valen −1/9 y los medios 4/9; en el nudo 4 (ξ = η = 1/2) solo N₄ vale 1:
N_centro = Nq(1/3, 1/3)
N_nudo4 = Nq(1/2, 1/2)
suma_centro = N_centro(1) + N_centro(2) + N_centro(3) + N_centro(4) + N_centro(5) + N_centro(6)

## 4 · Jacobiano: del triángulo de referencia al elemento real
#: En símbolos. La geometría se interpola con **las mismas funciones de forma** (isoparamétrico): x = ΣNᵢ·xᵢ. Si los puntos medios están en el centro de los lados (lados rectos, como aquí), la suma se simplifica a una fórmula **lineal**:
x_interp = Simplify{xi*(2*xi - 1)*x1 + eta*(2*eta - 1)*x2 + (1 - xi - eta)*(2*(1 - xi - eta) - 1)*x3 + 4*xi*eta*(x1 + x2)/2 + 4*eta*(1 - xi - eta)*(x2 + x3)/2 + 4*(1 - xi - eta)*xi*(x3 + x1)/2}
#: o sea x = ξ·x₁ + η·x₂ + (1 − ξ − η)·x₃. El **Jacobiano** es la derivada de (x, y) respecto a (ξ, η), una fila por variable natural:
J_s = [x1 - x3, y1 - y3; x2 - x3, y2 - y3]
#: Su **determinante** es el factor de área, dA = detJ·dξ·dη, y vale **dos veces el área del triángulo**. Debe salir positivo (nudos antihorarios):
dJ_s = Simplify{det([x1 - x3, y1 - y3; x2 - x3, y2 - y3])}
#: **Mira la Figura 4:** la transformación x = ΣNᵢ·xᵢ lleva el triángulo de referencia al elemento 1 real, y el Jacobiano dice cuánto lo estira (detJ = 8 = el doble del área).
#dibujo("Figura 4. La transformación isoparamétrica: el triángulo de referencia (ξ, η) se convierte en el elemento 1 real (x, y); su Jacobiano J mide cuánto se estira", ud = m, ancho = 200, alto = 70)
#  poligono([0, 2, 0], [0, 0, 2], "azul tenue")
#  polilinea([0, 2, 0, 0], [0, 0, 2, 0], "gruesa")
#  poligono([5.6, 9.6, 9.6], [0, 0, 2], "verde tenue")
#  polilinea([5.6, 9.6, 9.6, 5.6], [0, 0, 2, 0], "gruesa")
#  circulo(0, 0, 0.07, "azul relleno")
#  circulo(2, 0, 0.07, "azul relleno")
#  circulo(0, 2, 0.07, "azul relleno")
#  circulo(1, 0, 0.05, "fina")
#  circulo(0, 1, 0.05, "fina")
#  circulo(1, 1, 0.05, "fina")
#  circulo(5.6, 0, 0.07, "azul relleno")
#  circulo(9.6, 0, 0.07, "azul relleno")
#  circulo(9.6, 2, 0.07, "azul relleno")
#  circulo(7.6, 0, 0.05, "fina")
#  circulo(9.6, 1, 0.05, "fina")
#  circulo(7.6, 1, 0.05, "fina")
#  texto(-0.1, -0.3, "3", 2.8, "c")
#  texto(2.1, -0.3, "1", 2.8, "c")
#  texto(-0.1, 2.15, "2", 2.8, "c")
#  texto(1, -0.3, "6", 2.6, "c")
#  texto(-0.2, 1, "5", 2.6, "d")
#  texto(1.15, 1.1, "4", 2.6, "i")
#  texto(5.5, -0.3, "1", 2.8, "c")
#  texto(9.7, -0.3, "2", 2.8, "c")
#  texto(9.75, 2.1, "3", 2.8, "i")
#  texto(7.6, -0.3, "4", 2.6, "c")
#  texto(9.75, 1, "5", 2.6, "i")
#  texto(7.7, 1.1, "6", 2.6, "i")
#  flecha(2.5, 1, 5, 1, "naranja")
#  texto(3.75, 1.35, "x = ΣNᵢ·xᵢ", 2.7, "c", estilo = "naranja")
#  texto(3.75, 0.65, "y = ΣNᵢ·yᵢ", 2.7, "c", estilo = "naranja")
#  texto(1, -0.9, "referencia: área 1/2", 2.7, "c")
#  texto(8.1, -0.9, "elemento 1: área 4 m², detJ = 8 = 2·A", 2.7, "c")
#  texto(6.8, 2.55, "J = [x₁−x₃ y₁−y₃ ; x₂−x₃ y₂−y₃] = [−4 −2 ; 0 −2]", 2.5, "c", estilo = "azul")
#fin
#: Las derivadas respecto a **x e y** salen con la inversa del Jacobiano: [∂N/∂x; ∂N/∂y] = J⁻¹·[∂N/∂ξ; ∂N/∂η]. En símbolos:
Ji_s = Simplify{inv([x1 - x3, y1 - y3; x2 - x3, y2 - y3])}
#: Con números, elemento por elemento. **Xe** es la tabla de coordenadas del elemento (una fila por nudo, en el orden de e_j). Se arma con un bucle y se usa el elemento 1:
#hide
Xe = zeros(6, 2)
e = 1
for a = 1:6
  Xe(a, 1) = x_j(e_j(e, a))
  Xe(a, 2) = y_j(e_j(e, a))
end
#show
Xel_1 = 1*Xe 'coordenadas del elemento 1, una fila por nudo (en m)
Xel_1
Jq(xi, eta) = dNq(xi, eta)*Xe
dJq(xi, eta) = det(Jq(xi, eta))
J_1 = Jq(1/3, 1/3) 'Jacobiano del elemento 1 (constante: lados rectos)
dJ_1 = dJq(1/3, 1/3) 'dos veces el área del elemento 1
A_1 = dJ_1/2 [m²] 'área del triángulo 1: base 4 × altura 2 / 2

## 5 · La matriz B: deformaciones a partir de los desplazamientos
#: En símbolos. La deformación plana tiene tres componentes, ε_{x} = ∂u/∂x, ε_{y} = ∂v/∂y y γ_{xy} = ∂u/∂y + ∂v/∂x. Con u = ΣNᵢ·uᵢ y v = ΣNᵢ·vᵢ, cada una es una **combinación lineal de los 12 desplazamientos** del elemento [u₁, v₁, u₂, v₂, …, u₆, v₆]:
#: **Mira la Figura 5:** las tres deformaciones de la deformación plana. Es lo que B calcula a partir de los desplazamientos.
#dibujo("Figura 5. Las tres deformaciones de la deformación plana: estirar en x, estirar en y y distorsionar (corte). En trazos, el cuadrado sin deformar", ud = m, ancho = 200, alto = 70)
#  polilinea([0, 1, 1, 0, 0], [0, 0, 1, 1, 0], "fina trazos")
#  polilinea([0, 1.4, 1.4, 0, 0], [0, 0, 1, 1, 0], "gruesa rojo")
#  flecha(1, 0.5, 1.4, 0.5, "rojo")
#  texto(0.7, -0.4, "ε_{x} = ∂u/∂x", 3, "c")
#  polilinea([3.6, 4.6, 4.6, 3.6, 3.6], [0, 0, 1, 1, 0], "fina trazos")
#  polilinea([3.6, 4.6, 4.6, 3.6, 3.6], [0, 0, 1.4, 1.4, 0], "gruesa azul")
#  flecha(4.1, 1, 4.1, 1.4, "azul")
#  texto(4.1, -0.4, "ε_{y} = ∂v/∂y", 3, "c")
#  polilinea([7.2, 8.2, 8.2, 7.2, 7.2], [0, 0, 1, 1, 0], "fina trazos")
#  polilinea([7.2, 8.2, 8.5, 7.5, 7.2], [0, 0, 1, 1, 0], "gruesa verde")
#  flecha(7.7, 1, 8, 1, "verde")
#  texto(7.9, -0.4, "γ_{xy} = ∂u/∂y + ∂v/∂x", 3, "c")
#fin
#: ε = B·u_e,   con   B = [ ∂N/∂x en las columnas de u ;  ∂N/∂y en las columnas de v ;  ∂N/∂y en u + ∂N/∂x en v ]
#: **Derivadas respecto a x e y.** Salen de la regla de la cadena con la inversa del Jacobiano de la sección 4 (N_ξ y N_η son las derivadas de la función de forma respecto a ξ y a η):
dNdx_s = Simplify{((y2 - y3)*Nxi + (y3 - y1)*Neta)/dJ_m}
dNdy_s = Simplify{((x3 - x2)*Nxi + (x1 - x3)*Neta)/dJ_m}
#: **Las tres deformaciones** que produce un nudo, con sus derivadas n_x = ∂N/∂x y n_y = ∂N/∂y y sus desplazamientos u_a y v_a:
ex_s = Expand{nx*ua}
ey_s = Expand{ny*va}
gxy_s = Expand{ny*ua + nx*va}
#: **Mira la Figura 6:** los 12 grados de libertad del elemento, en el orden en que se apilan en el vector u_{e} y en las columnas de B.
#dibujo("Figura 6. Los 12 grados de libertad del T6 (2 por nudo, numeración local 1 a 6): B convierte este vector en las 3 deformaciones", ud = m, ancho = 200, alto = 96)
#  poligono([0, 4, 4], [0, 0, 2], "verde tenue")
#  polilinea([0, 4, 4, 0], [0, 0, 2, 0], "gruesa")
#  circulo(0, 0, 0.06, "negro relleno")
#  flecha(0, 0, 0.55, 0, "rojo")
#  texto(0.62, -0.08, "u_{1}", 2.4, "i", estilo = "rojo")
#  flecha(0, 0, 0, 0.55, "azul")
#  texto(-0.06, 0.7, "v_{1}", 2.4, "c", estilo = "azul")
#  circulo(4, 0, 0.06, "negro relleno")
#  flecha(4, 0, 4.55, 0, "rojo")
#  texto(4.62, -0.08, "u_{2}", 2.4, "i", estilo = "rojo")
#  flecha(4, 0, 4, 0.55, "azul")
#  texto(3.94, 0.7, "v_{2}", 2.4, "c", estilo = "azul")
#  circulo(4, 2, 0.06, "negro relleno")
#  flecha(4, 2, 4.55, 2, "rojo")
#  texto(4.62, 1.92, "u_{3}", 2.4, "i", estilo = "rojo")
#  flecha(4, 2, 4, 2.55, "azul")
#  texto(3.94, 2.7, "v_{3}", 2.4, "c", estilo = "azul")
#  circulo(2, 0, 0.06, "negro relleno")
#  flecha(2, 0, 2.55, 0, "rojo")
#  texto(2.62, -0.08, "u_{4}", 2.4, "i", estilo = "rojo")
#  flecha(2, 0, 2, 0.55, "azul")
#  texto(1.94, 0.7, "v_{4}", 2.4, "c", estilo = "azul")
#  circulo(4, 1, 0.06, "negro relleno")
#  flecha(4, 1, 4.55, 1, "rojo")
#  texto(4.62, 0.92, "u_{5}", 2.4, "i", estilo = "rojo")
#  flecha(4, 1, 4, 1.55, "azul")
#  texto(3.94, 1.7, "v_{5}", 2.4, "c", estilo = "azul")
#  circulo(2, 1, 0.06, "negro relleno")
#  flecha(2, 1, 2.55, 1, "rojo")
#  texto(2.62, 0.92, "u_{6}", 2.4, "i", estilo = "rojo")
#  flecha(2, 1, 2, 1.55, "azul")
#  texto(1.94, 1.7, "v_{6}", 2.4, "c", estilo = "azul")
#  texto(2, -0.85, "u_{e} = [u₁ v₁ u₂ v₂ … u₆ v₆]ᵀ : 12 grados de libertad por elemento", 2.6, "c")
#fin
#: Es decir, **cada nudo aporta a B un bloque de 3 × 2**, [n_x 0; 0 n_y; n_y n_x], y B es la unión de los 6 bloques. Con números, las matrices E_{u} y E_{v} solo colocan cada nudo en su sitio (u en las posiciones impares, v en las pares):
#hide
Eu = zeros(6, 12)
Ev = zeros(6, 12)
for a = 1:6
  Eu(a, 2*a - 1) = 1
  Ev(a, 2*a) = 1
end
#show
#: Con números. Derivadas respecto a x e y (una columna por nudo) y **las tres filas de B por separado** (cada una de 1 × 12; puestas una debajo de otra forman la matriz B de 3 × 12):
gx(xi, eta) = [1, 0]*inv(Jq(xi, eta))*dNq(xi, eta)
gy(xi, eta) = [0, 1]*inv(Jq(xi, eta))*dNq(xi, eta)
Bx_q(xi, eta) = gx(xi, eta)*Eu
By_q(xi, eta) = gy(xi, eta)*Ev
Bg_q(xi, eta) = gy(xi, eta)*Eu + gx(xi, eta)*Ev
dNdx_c = gx(1/3, 1/3)
dNdy_c = gy(1/3, 1/3)
Bx_c = Bx_q(1/3, 1/3)
By_c = By_q(1/3, 1/3)
Bg_c = Bg_q(1/3, 1/3)
#: **Comprobación de cuerpo rígido.** Si todos los nudos se trasladan 1 en x, la deformación debe ser cero:
u_tras = [1; 0; 1; 0; 1; 0; 1; 0; 1; 0; 1; 0]
eps_x = Bx_c*u_tras
eps_y = By_c*u_tras
gam_xy = Bg_c*u_tras

## 6 · La matriz constitutiva D (deformación plana)
#: En símbolos. La ley de Hooke en deformación plana (ε_{z} = 0) relaciona las tensiones [σ_{x}, σ_{y}, σ_{z}, τ_{xy}] con las deformaciones [ε_{x}, ε_{y}, ε_{z}, γ_{xy}] mediante las constantes de Lamé **λ** y **G**:
#: **Mira la Figura 7:** el estado de tensión de un elemento de suelo en deformación plana; D relaciona estas tensiones con las deformaciones de la Figura 5.
#dibujo("Figura 7. Elemento de suelo en deformación plana: las tensiones del plano σx, σy y τxy, y la σz que aparece porque la deformación εz está impedida", ud = m, ancho = 188, alto = 113)
#  poligono([0, 2, 2, 0], [0, 0, 2, 2], "azul tenue")
#  polilinea([0, 2, 2, 0, 0], [0, 0, 2, 2, 0], "gruesa")
#  flecha(-0.9, 1, 0, 1, "rojo")
#  flecha(2.9, 1, 2, 1, "rojo")
#  texto(-0.95, 1.25, "σx", 3, "d", estilo = "rojo")
#  texto(2.95, 1.25, "σx", 3, "i", estilo = "rojo")
#  flecha(1, -0.9, 1, 0, "azul")
#  flecha(1, 2.9, 1, 2, "azul")
#  texto(1.2, -0.75, "σy", 3, "i", estilo = "azul")
#  texto(1.2, 2.75, "σy", 3, "i", estilo = "azul")
#  flecha(0.4, 2.35, 1.6, 2.35, "verde")
#  flecha(1.6, -0.35, 0.4, -0.35, "verde")
#  texto(1, 2.75, "", 2, "c")
#  texto(2.35, 2.35, "τxy", 2.6, "i", estilo = "verde")
#  circulo(1, 1, 0.22, "media")
#  linea(0.85, 0.85, 1.15, 1.15, "media")
#  linea(0.85, 1.15, 1.15, 0.85, "media")
#  texto(1, 0.35, "σz hacia el plano", 2.4, "c", estilo = "naranja")
#fin
lam_s = Simplify{E_m*ν_m/((1 + ν_m)*(1 - 2*ν_m))}
G_s = Simplify{E_m/(2*(1 + ν_m))}
#: El término de corte de D, que sale como E(1−2ν)/2 dividido por (1+ν)(1−2ν), **es exactamente G** (comprobación simbólica: la diferencia vale cero):
dif_G = Simplify{E_m*(1 - 2*ν_m)/2/((1 + ν_m)*(1 - 2*ν_m)) - E_m/(2*(1 + ν_m))}
#: Y la fila normal, E(1−ν)/((1+ν)(1−2ν)), es **λ + 2G**:
dif_L = Simplify{E_m*(1 - ν_m)/((1 + ν_m)*(1 - 2*ν_m)) - (E_m*ν_m/((1 + ν_m)*(1 - 2*ν_m)) + 2*E_m/(2*(1 + ν_m)))}
#: Con números:
lam = E*ν/((1 + ν)*(1 - 2*ν)) [kPa]
G = E/(2*(1 + ν)) [kPa]
D = [lam + 2*G, lam, lam, 0; lam, lam + 2*G, lam, 0; lam, lam, lam + 2*G, 0; 0, 0, 0, G]
#: Como ε_{z} = 0, la rigidez solo usa tres componentes (ε_{x}, ε_{y}, γ_{xy}); σ_{z} no hace trabajo pero **se calcula** (σ_{z} = ν·(σ_{x} + σ_{y}) en el rango elástico) porque Mohr-Coulomb la necesita:
D3 = [lam + 2*G, lam, 0; lam, lam + 2*G, 0; 0, 0, G]

## 7 · Cuadratura de Gauss de 7 puntos
#: En símbolos. La integral sobre el triángulo de referencia (área 1/2) se cambia por una suma de 7 muestras, ∫∫ f dξdη ≈ Σ wᵢ·f(ξᵢ, ηᵢ). La regla de **Radon** es exacta para polinomios hasta **grado 5**, y sus pesos y posiciones tienen forma exacta con raíces de 15. Los pesos, uno al centro y dos grupos de tres, **suman 1/2** (el área del triángulo):
suma_pesos = Simplify{9/80 + 3*(155 - sqrt(15))/2400 + 3*(155 + sqrt(15))/2400}
#: Con números, los pesos:
w_centro = 9/80
w_a = (155 - sqrt(15))/2400
w_b = (155 + sqrt(15))/2400
#: Las posiciones, en coordenadas de área, son combinaciones de (6 ∓ √15)/21 y (9 ± 2√15)/21:
a_1 = (6 - sqrt(15))/21
b_1 = (9 + 2*sqrt(15))/21
a_2 = (6 + sqrt(15))/21
b_2 = (9 - 2*sqrt(15))/21
#: **Mira la Figura 8:** dónde caen los 7 puntos en el triángulo de referencia y en el elemento real, y cuánto pesa cada uno.
#dibujo("Figura 8. Los 7 puntos de Gauss de Radon (el tamaño del círculo es el peso): la integral sobre el triángulo se reemplaza por 7 muestras", ud = m, ancho = 200, alto = 75)
#  poligono([0, 3.2, 0], [0, 0, 3.2], "azul tenue")
#  polilinea([0, 3.2, 0, 0], [0, 0, 3.2, 0], "gruesa")
#  poligono([6.3, 9.5, 9.5], [0, 0, 1.6], "verde tenue")
#  polilinea([6.3, 9.5, 9.5, 6.3], [0, 0, 1.6, 0], "gruesa")
#  circulo(1.0667, 1.0667, 0.14, "rojo relleno")
#  texto(1.1867, 1.1667, "1", 2.5, "i")
#  circulo(8.4333, 0.5333, 0.14, "rojo relleno")
#  texto(8.5533, 0.6333, "1", 2.5, "i")
#  circulo(0.3241, 0.3241, 0.1004, "rojo relleno")
#  texto(0.4441, 0.4241, "2", 2.5, "i")
#  circulo(9.1759, 1.2759, 0.1004, "rojo relleno")
#  texto(9.2959, 1.3759, "2", 2.5, "i")
#  circulo(2.5518, 0.3241, 0.1004, "rojo relleno")
#  texto(2.6718, 0.4241, "3", 2.5, "i")
#  circulo(6.9482, 0.1621, 0.1004, "rojo relleno")
#  texto(7.0682, 0.2621, "3", 2.5, "i")
#  circulo(0.3241, 2.5518, 0.1004, "rojo relleno")
#  texto(0.4441, 2.6518, "4", 2.5, "i")
#  circulo(9.1759, 0.1621, 0.1004, "rojo relleno")
#  texto(9.2959, 0.2621, "4", 2.5, "i")
#  circulo(1.5045, 1.5045, 0.103, "rojo relleno")
#  texto(1.6245, 1.6045, "5", 2.5, "i")
#  circulo(7.9955, 0.0955, 0.103, "rojo relleno")
#  texto(8.1155, 0.1955, "5", 2.5, "i")
#  circulo(0.1911, 1.5045, 0.103, "rojo relleno")
#  texto(0.3111, 1.6045, "6", 2.5, "i")
#  circulo(9.3089, 0.7522, 0.103, "rojo relleno")
#  texto(9.4289, 0.8522, "6", 2.5, "i")
#  circulo(1.5045, 0.1911, 0.103, "rojo relleno")
#  texto(1.6245, 0.2911, "7", 2.5, "i")
#  circulo(7.9955, 0.7522, 0.103, "rojo relleno")
#  texto(8.1155, 0.8522, "7", 2.5, "i")
#  texto(1.6, -0.55, "triángulo de referencia", 2.6, "c")
#  texto(7.9, -0.55, "los mismos puntos en el elemento 1", 2.6, "c")
#  texto(1.6, 3.6, "círculo mayor = peso mayor: w₁ = 9/80 = 0.1125;  w₂…w₄ = 0.0630;  w₅…w₇ = 0.0662;  Σw = ½", 2.5, "c")
#fin
#: Con números. Los 7 puntos (ξ, η) y sus pesos, en el orden del motor (el centro, tres del grupo a, tres del grupo b):
xg = [1/3; a_1; b_1; a_1; a_2; b_2; a_2]
yg = [1/3; a_1; a_1; b_1; a_2; a_2; b_2]
wg = [w_centro; w_a; w_a; w_a; w_b; w_b; w_b]
#: **Comprobaciones.** Los pesos suman 1/2, y la regla integra exacto ∫∫ξ²η² dξdη = 2!·2!/6! = 1/180 (un polinomio de grado 4):
sum_w = wg(1) + wg(2) + wg(3) + wg(4) + wg(5) + wg(6) + wg(7)
int_x2y2 = wg(1)*xg(1)^2*yg(1)^2 + wg(2)*xg(2)^2*yg(2)^2 + wg(3)*xg(3)^2*yg(3)^2 + wg(4)*xg(4)^2*yg(4)^2 + wg(5)*xg(5)^2*yg(5)^2 + wg(6)*xg(6)^2*yg(6)^2 + wg(7)*xg(7)^2*yg(7)^2
exacta_x2y2 = 1/180
#: Y reproduce el área del elemento 1 (detJ constante × suma de pesos = 8 × 1/2 = 4 m²):
area_1 = dJq(1/3, 1/3)*sum_w [m²]

## 8 · La rigidez del elemento
#: En símbolos. K es la energía de deformación, K = ∫ Bᵀ·D·B dA, por metro de profundidad (deformación plana). Con la cuadratura, **cada término es una suma sobre los 7 puntos**:
#: K_{e} = Σ_{q=1…7} w_{q} · detJ · B(ξ_{q}, η_{q})ᵀ · D₃ · B(ξ_{q}, η_{q})
#: **Mira la Figura 9:** la forma de K_{e}: 12 × 12 con bloques de 2 × 2, uno por cada par de nudos (el bloque naranja es el acoplamiento entre los nudos 3 y 4).
#dibujo("Figura 9. Estructura de la rigidez del elemento K_{e} (12 × 12): 6 × 6 bloques de 2 × 2, uno por cada par de nudos", ud = , ancho = 200, alto = 133)
#  poligono([0, 2, 2, 0], [10, 10, 12, 12], "azul tenue")
#  poligono([2, 4, 4, 2], [8, 8, 10, 10], "azul tenue")
#  poligono([4, 6, 6, 4], [6, 6, 8, 8], "azul tenue")
#  poligono([6, 8, 8, 6], [4, 4, 6, 6], "azul tenue")
#  poligono([8, 10, 10, 8], [2, 2, 4, 4], "azul tenue")
#  poligono([10, 12, 12, 10], [0, 0, 2, 2], "azul tenue")
#  poligono([4, 6, 6, 4], [4, 4, 6, 6], "naranja tenue")
#  linea(0, 0, 12, 0, "fina")
#  linea(0, 0, 0, 12, "fina")
#  linea(0, 2, 12, 2, "fina")
#  linea(2, 0, 2, 12, "fina")
#  linea(0, 4, 12, 4, "fina")
#  linea(4, 0, 4, 12, "fina")
#  linea(0, 6, 12, 6, "fina")
#  linea(6, 0, 6, 12, "fina")
#  linea(0, 8, 12, 8, "fina")
#  linea(8, 0, 8, 12, "fina")
#  linea(0, 10, 12, 10, "fina")
#  linea(10, 0, 10, 12, "fina")
#  linea(0, 12, 12, 12, "fina")
#  linea(12, 0, 12, 12, "fina")
#  polilinea([0, 12, 12, 0, 0], [0, 0, 12, 12, 0], "gruesa")
#  texto(1, 12.6, "nudo 1", 2.3, "c")
#  texto(-0.3, 11, "nudo 1", 2.3, "d")
#  texto(3, 12.6, "nudo 2", 2.3, "c")
#  texto(-0.3, 9, "nudo 2", 2.3, "d")
#  texto(5, 12.6, "nudo 3", 2.3, "c")
#  texto(-0.3, 7, "nudo 3", 2.3, "d")
#  texto(7, 12.6, "nudo 4", 2.3, "c")
#  texto(-0.3, 5, "nudo 4", 2.3, "d")
#  texto(9, 12.6, "nudo 5", 2.3, "c")
#  texto(-0.3, 3, "nudo 5", 2.3, "d")
#  texto(11, 12.6, "nudo 6", 2.3, "c")
#  texto(-0.3, 1, "nudo 6", 2.3, "d")
#  texto(13, 8, "cada cuadro de 2×2 acopla", 2.4, "i")
#  texto(13, 7.2, "el nudo a con el nudo b:", 2.4, "i")
#  texto(13, 6.4, "[ k_{uu} k_{uv} ; k_{vu} k_{vv} ]", 2.4, "i", estilo = "azul")
#  texto(13, 5, "el cuadro naranja (nudos 3 y 4)", 2.3, "i", estilo = "naranja")
#  texto(13, 4.2, "es K_{34}", 2.3, "i", estilo = "naranja")
#  texto(13, 2.6, "K_{e} es simétrica 12×12", 2.4, "i")
#  texto(13, 1.8, "(144 números, 78 distintos)", 2.4, "i")
#fin
#: Una sola entrada, la del grado de libertad u₁ consigo mismo. La columna u₁ de B es [∂N₁/∂x; 0; ∂N₁/∂y] (u₁ solo afecta a ε_{x} y γ_{xy}), así que el aporte de un punto es:
k11_q = Expand{dJ_m*(nx^2*(λ_m + 2*G_m) + ny^2*G_m)}
#: o sea, **(λ+2G)·(∂N₁/∂x)² + G·(∂N₁/∂y)²**, por detJ. El primer término es la rigidez axial y el segundo la de corte.
#: Con números. Un bucle suma los 7 puntos. Se hace para el elemento 1 (Xe ya contiene sus coordenadas):
#: Aporte de **un** punto de Gauss, 12 × 12 (con las tres filas de B por separado; el producto Bᵀ·D·B se escribe sumando los términos de D₃):
kq(xi, eta) = dJq(xi, eta)*(D3(1, 1)*transpose(Bx_q(xi, eta))*Bx_q(xi, eta) + D3(1, 2)*(transpose(Bx_q(xi, eta))*By_q(xi, eta) + transpose(By_q(xi, eta))*Bx_q(xi, eta)) + D3(2, 2)*transpose(By_q(xi, eta))*By_q(xi, eta) + D3(3, 3)*transpose(Bg_q(xi, eta))*Bg_q(xi, eta))
#hide
Ke = zeros(12, 12)
for q = 1:7
  Ke = Ke + wg(q)*kq(xg(q), yg(q))
end
#show
Kel_11 = Ke(1, 1) [kN/m]
#: **Comprobaciones** (si fallan, hay un error de signo o de orden). La K es simétrica, y un movimiento de cuerpo rígido (traslación en x) **no produce fuerzas**:
asim = Ke(1, 2) - Ke(2, 1)
f_tras = Ke*u_tras
n_tras = norm(f_tras) 'tiene que ser ≈ 0 (ruido numérico)
#: **Energía de una deformación constante.** Con u = 0.001·x en los nudos, ε_{x} = 0.001 y el resto cero: la energía exacta es U = ½·(λ+2G)·ε²·A = ½·(λ+2G)·10⁻⁶·4. El elemento debe darla exacta:
u_x = [0; 0; 0.004; 0; 0.004; 0; 0.002; 0; 0.004; 0; 0.002; 0]
U_fem = 0.5*transpose(u_x)*Ke*u_x [kN·m]
U_exacta = 0.5*(lam + 2*G)*0.001*0.001*area_1 [kN·m]

## 9 · Ensamblaje y carga de gravedad
#: En símbolos. Los grados de libertad del nudo j son 2j−1 y 2j; los de un elemento, los de sus 6 nudos seguidos. El ensamblaje **suma** la rigidez de cada elemento en las filas y columnas de sus grados de libertad: K(g,g) ← K(g,g) + K_{e}. Donde dos elementos comparten un nudo, sus aportes se suman.
#: Un ejemplo con letras: dos resortes k₁ y k₂ en serie, que comparten el nudo 2. Cada elemento coloca su matriz 2×2 [k, −k; −k, k] en los grados que le tocan y las dos se **suman**; el único término que reciben los dos elementos es el del nudo compartido, K(2,2):
K22_s = Simplify{k1 + k2}
Kg_s = [k1, -k1, 0; -k1, k1 + k2, -k2; 0, -k2, k2]
#: **Mira la Figura 10:** el ejemplo de los dos resortes, con los dos aportes y el término compartido.
#dibujo("Figura 10. Ensamblaje con letras: dos resortes k₁ y k₂ que comparten el nudo 2. Cada uno aporta su matriz 2×2 y en el nudo compartido se SUMAN", ud = m, ancho = 200, alto = 65)
#  polilinea([0, 0.45, 0.75, 1.05, 1.35, 1.65, 1.95, 2.25, 2.55, 3], [0, 0.28, -0.28, 0.28, -0.28, 0.28, -0.28, 0.28, -0.28, 0], "gruesa")
#  polilinea([3, 3.45, 3.75, 4.05, 4.35, 4.65, 4.95, 5.25, 5.55, 6], [0, 0.28, -0.28, 0.28, -0.28, 0.28, -0.28, 0.28, -0.28, 0], "gruesa")
#  circulo(0, 0, 0.12, "azul relleno")
#  circulo(3, 0, 0.12, "rojo relleno")
#  circulo(6, 0, 0.12, "azul relleno")
#  texto(0, -0.5, "1", 3, "c")
#  texto(3, -0.5, "2", 3, "c")
#  texto(6, -0.5, "3", 3, "c")
#  texto(1.5, 0.6, "k₁", 3, "c", estilo = "azul")
#  texto(4.5, 0.6, "k₂", 3, "c", estilo = "azul")
#  texto(1.5, -1.05, "K_{e1} = [ k₁ −k₁ ; −k₁ k₁ ]", 2.6, "c")
#  texto(4.5, -1.05, "K_{e2} = [ k₂ −k₂ ; −k₂ k₂ ]", 2.6, "c")
#  texto(3, 1.35, "K(2,2) = k₁ + k₂", 3, "c", estilo = "rojo")
#  flecha(3, 1.15, 3, 0.3, "rojo")
#fin
#: El K ensamblado (arriba) tiene en K(2,2) el valor **k₁ + k₂**: lo aportan los dos elementos. Con las cargas pasa lo mismo: en el nudo 7 de esta malla se suman los aportes de los dos T6.
#: **Mira la Figura 11:** el patrón de la K de esta malla. Los nudos 1, 3 y 7 pertenecen a los dos elementos (casillas verdes), y ahí se suman los aportes.
#dibujo("Figura 11. La K global (18 × 18) por bloques de nudos: se llena solo donde dos nudos pertenecen a un mismo elemento (cada cuadro es 2 × 2)", ud = , ancho = 200, alto = 125)
#  poligono([0, 1, 1, 0], [8, 8, 9, 9], "verde relleno")
#  poligono([1, 2, 2, 1], [8, 8, 9, 9], "naranja relleno")
#  poligono([2, 3, 3, 2], [8, 8, 9, 9], "verde relleno")
#  poligono([3, 4, 4, 3], [8, 8, 9, 9], "azul relleno")
#  poligono([4, 5, 5, 4], [8, 8, 9, 9], "naranja relleno")
#  poligono([5, 6, 6, 5], [8, 8, 9, 9], "naranja relleno")
#  poligono([6, 7, 7, 6], [8, 8, 9, 9], "verde relleno")
#  poligono([7, 8, 8, 7], [8, 8, 9, 9], "azul relleno")
#  poligono([8, 9, 9, 8], [8, 8, 9, 9], "azul relleno")
#  poligono([0, 1, 1, 0], [7, 7, 8, 8], "naranja relleno")
#  poligono([1, 2, 2, 1], [7, 7, 8, 8], "naranja relleno")
#  poligono([2, 3, 3, 2], [7, 7, 8, 8], "naranja relleno")
#  poligono([4, 5, 5, 4], [7, 7, 8, 8], "naranja relleno")
#  poligono([5, 6, 6, 5], [7, 7, 8, 8], "naranja relleno")
#  poligono([6, 7, 7, 6], [7, 7, 8, 8], "naranja relleno")
#  poligono([0, 1, 1, 0], [6, 6, 7, 7], "verde relleno")
#  poligono([1, 2, 2, 1], [6, 6, 7, 7], "naranja relleno")
#  poligono([2, 3, 3, 2], [6, 6, 7, 7], "verde relleno")
#  poligono([3, 4, 4, 3], [6, 6, 7, 7], "azul relleno")
#  poligono([4, 5, 5, 4], [6, 6, 7, 7], "naranja relleno")
#  poligono([5, 6, 6, 5], [6, 6, 7, 7], "naranja relleno")
#  poligono([6, 7, 7, 6], [6, 6, 7, 7], "verde relleno")
#  poligono([7, 8, 8, 7], [6, 6, 7, 7], "azul relleno")
#  poligono([8, 9, 9, 8], [6, 6, 7, 7], "azul relleno")
#  poligono([0, 1, 1, 0], [5, 5, 6, 6], "azul relleno")
#  poligono([2, 3, 3, 2], [5, 5, 6, 6], "azul relleno")
#  poligono([3, 4, 4, 3], [5, 5, 6, 6], "azul relleno")
#  poligono([6, 7, 7, 6], [5, 5, 6, 6], "azul relleno")
#  poligono([7, 8, 8, 7], [5, 5, 6, 6], "azul relleno")
#  poligono([8, 9, 9, 8], [5, 5, 6, 6], "azul relleno")
#  poligono([0, 1, 1, 0], [4, 4, 5, 5], "naranja relleno")
#  poligono([1, 2, 2, 1], [4, 4, 5, 5], "naranja relleno")
#  poligono([2, 3, 3, 2], [4, 4, 5, 5], "naranja relleno")
#  poligono([4, 5, 5, 4], [4, 4, 5, 5], "naranja relleno")
#  poligono([5, 6, 6, 5], [4, 4, 5, 5], "naranja relleno")
#  poligono([6, 7, 7, 6], [4, 4, 5, 5], "naranja relleno")
#  poligono([0, 1, 1, 0], [3, 3, 4, 4], "naranja relleno")
#  poligono([1, 2, 2, 1], [3, 3, 4, 4], "naranja relleno")
#  poligono([2, 3, 3, 2], [3, 3, 4, 4], "naranja relleno")
#  poligono([4, 5, 5, 4], [3, 3, 4, 4], "naranja relleno")
#  poligono([5, 6, 6, 5], [3, 3, 4, 4], "naranja relleno")
#  poligono([6, 7, 7, 6], [3, 3, 4, 4], "naranja relleno")
#  poligono([0, 1, 1, 0], [2, 2, 3, 3], "verde relleno")
#  poligono([1, 2, 2, 1], [2, 2, 3, 3], "naranja relleno")
#  poligono([2, 3, 3, 2], [2, 2, 3, 3], "verde relleno")
#  poligono([3, 4, 4, 3], [2, 2, 3, 3], "azul relleno")
#  poligono([4, 5, 5, 4], [2, 2, 3, 3], "naranja relleno")
#  poligono([5, 6, 6, 5], [2, 2, 3, 3], "naranja relleno")
#  poligono([6, 7, 7, 6], [2, 2, 3, 3], "verde relleno")
#  poligono([7, 8, 8, 7], [2, 2, 3, 3], "azul relleno")
#  poligono([8, 9, 9, 8], [2, 2, 3, 3], "azul relleno")
#  poligono([0, 1, 1, 0], [1, 1, 2, 2], "azul relleno")
#  poligono([2, 3, 3, 2], [1, 1, 2, 2], "azul relleno")
#  poligono([3, 4, 4, 3], [1, 1, 2, 2], "azul relleno")
#  poligono([6, 7, 7, 6], [1, 1, 2, 2], "azul relleno")
#  poligono([7, 8, 8, 7], [1, 1, 2, 2], "azul relleno")
#  poligono([8, 9, 9, 8], [1, 1, 2, 2], "azul relleno")
#  poligono([0, 1, 1, 0], [0, 0, 1, 1], "azul relleno")
#  poligono([2, 3, 3, 2], [0, 0, 1, 1], "azul relleno")
#  poligono([3, 4, 4, 3], [0, 0, 1, 1], "azul relleno")
#  poligono([6, 7, 7, 6], [0, 0, 1, 1], "azul relleno")
#  poligono([7, 8, 8, 7], [0, 0, 1, 1], "azul relleno")
#  poligono([8, 9, 9, 8], [0, 0, 1, 1], "azul relleno")
#  linea(0, 0, 9, 0, "fina")
#  linea(0, 0, 0, 9, "fina")
#  linea(0, 1, 9, 1, "fina")
#  linea(1, 0, 1, 9, "fina")
#  linea(0, 2, 9, 2, "fina")
#  linea(2, 0, 2, 9, "fina")
#  linea(0, 3, 9, 3, "fina")
#  linea(3, 0, 3, 9, "fina")
#  linea(0, 4, 9, 4, "fina")
#  linea(4, 0, 4, 9, "fina")
#  linea(0, 5, 9, 5, "fina")
#  linea(5, 0, 5, 9, "fina")
#  linea(0, 6, 9, 6, "fina")
#  linea(6, 0, 6, 9, "fina")
#  linea(0, 7, 9, 7, "fina")
#  linea(7, 0, 7, 9, "fina")
#  linea(0, 8, 9, 8, "fina")
#  linea(8, 0, 8, 9, "fina")
#  linea(0, 9, 9, 9, "fina")
#  linea(9, 0, 9, 9, "fina")
#  polilinea([0, 9, 9, 0, 0], [0, 0, 9, 9, 0], "gruesa")
#  texto(0.5, 9.5, "1", 2.6, "c")
#  texto(-0.3, 8.35, "1", 2.6, "d")
#  texto(1.5, 9.5, "2", 2.6, "c")
#  texto(-0.3, 7.35, "2", 2.6, "d")
#  texto(2.5, 9.5, "3", 2.6, "c")
#  texto(-0.3, 6.35, "3", 2.6, "d")
#  texto(3.5, 9.5, "4", 2.6, "c")
#  texto(-0.3, 5.35, "4", 2.6, "d")
#  texto(4.5, 9.5, "5", 2.6, "c")
#  texto(-0.3, 4.35, "5", 2.6, "d")
#  texto(5.5, 9.5, "6", 2.6, "c")
#  texto(-0.3, 3.35, "6", 2.6, "d")
#  texto(6.5, 9.5, "7", 2.6, "c")
#  texto(-0.3, 2.35, "7", 2.6, "d")
#  texto(7.5, 9.5, "8", 2.6, "c")
#  texto(-0.3, 1.35, "8", 2.6, "d")
#  texto(8.5, 9.5, "9", 2.6, "c")
#  texto(-0.3, 0.35, "9", 2.6, "d")
#  texto(10, 7.5, "naranja: solo el elemento 1", 2.5, "i", estilo = "naranja")
#  texto(10, 6.5, "azul: solo el elemento 2", 2.5, "i", estilo = "azul")
#  texto(10, 5.5, "verde: los dos (se suman)", 2.5, "i", estilo = "verde")
#  texto(10, 3.8, "vacío: nudos que no comparten", 2.4, "i")
#  texto(10, 3, "ningún elemento (K = 0)", 2.4, "i")
#fin
#: **La carga de gravedad.** El peso reparte la fuerza γ·∫Nᵢ dA en cada nudo. En el triángulo de referencia, con ∫∫ξᵃηᵇ dξdη = a!·b!/(a+b+2)!, la integral de cada función de forma sale **cero en las esquinas y 1/6 en los puntos medios**:
int_N1 = Simplify{2*(2/24) - 1/6}
int_N4 = Simplify{4*(1/24)}
#: (si N₁ = 2ξ² − ξ, entonces ∫N₁ = 2·(2/24) − 1/6 = 0; si N₄ = 4ξη, ∫N₄ = 4·(1/24) = 1/6). Multiplicado por detJ y por γ, **cada punto medio recibe γ·detJ/6 hacia abajo** y las esquinas nada: una consecuencia curiosa de los elementos de segundo grado. **Comprobación simbólica:** los tres puntos medios, con W·detJ/6 cada uno (W = peso unitario), suman W·detJ/2 = W·A, el peso del elemento (A = área):
Pe_s = Simplify{3*W_m*dJ_m/6}
#: **Mira la Figura 12:** adónde va el peso. Cada punto medio recibe γ·detJ/6 = 24 kN y las esquinas cero; el nudo 7, compartido por los dos elementos, recibe 48.
#dibujo("Figura 12. La carga de gravedad repartida a los nudos: el T6 manda TODO el peso a los puntos medios (las esquinas no reciben nada)", ud = m, ancho = 200, alto = 120)
#  poligono([0, 4, 4], [0, 0, 2], "verde tenue")
#  poligono([0, 4, 0], [0, 2, 2], "azul tenue")
#  polilinea([0, 4, 4, 0, 0], [0, 0, 2, 2, 0], "gruesa")
#  linea(0, 0, 4, 2, "media")
#  achurado(-0.6, -0.45, 5.2, 0.45, "terreno")
#  circulo(2, 0, 0.07, "negro relleno")
#  flecha(2, 0.475, 2, 0.05, "rojo")
#  texto(2.12, 0.275, "24 kN", 2.7, "i", estilo = "rojo")
#  circulo(4, 1, 0.07, "negro relleno")
#  flecha(4, 1.475, 4, 1.05, "rojo")
#  texto(4.12, 1.275, "24 kN", 2.7, "i", estilo = "rojo")
#  circulo(2, 1, 0.07, "negro relleno")
#  flecha(2, 1.95, 2, 1.05, "rojo")
#  texto(2.12, 1.55, "48 kN", 2.7, "i", estilo = "rojo")
#  circulo(2, 2, 0.07, "negro relleno")
#  flecha(2, 2.475, 2, 2.05, "rojo")
#  texto(2.12, 2.275, "24 kN", 2.7, "i", estilo = "rojo")
#  circulo(0, 1, 0.07, "negro relleno")
#  flecha(0, 1.475, 0, 1.05, "rojo")
#  texto(0.12, 1.275, "24 kN", 2.7, "i", estilo = "rojo")
#  circulo(0, 0, 0.06, "negro relleno")
#  circulo(4, 0, 0.06, "negro relleno")
#  circulo(4, 2, 0.06, "negro relleno")
#  circulo(0, 2, 0.06, "negro relleno")
#  texto(2, -1, "esquinas: 0 kN  ·  puntos medios: γ·detJ/6 = 18·8/6 = 24 kN  ·  nudo 7 (compartido): 48 kN", 2.4, "c")
#  texto(2, 3.1, "suma = 24·4 + 48 = 144 kN = γ·Lx·Ly", 2.8, "c", estilo = "rojo")
#fin
#: Con números. Un bucle recorre los elementos, arma su Xe, calcula su rigidez y su carga, y los suma:
#hide
K = zeros(n_d, n_d)
F = zeros(n_d, 1)
for e = 1:n_e
  for a = 1:6
    Xe(a, 1) = x_j(e_j(e, a))
    Xe(a, 2) = y_j(e_j(e, a))
  end
  g = zeros(1, 12)
  for a = 1:6
    g(2*a - 1) = 2*e_j(e, a) - 1
    g(2*a) = 2*e_j(e, a)
  end
  Ke = zeros(12, 12)
  Fe = zeros(12, 1)
  for q = 1:7
    Ke = Ke + wg(q)*kq(xg(q), yg(q))
    Nv = Nq(xg(q), yg(q))
    for a = 1:6
      Fe(2*a) = Fe(2*a) - γ*wg(q)*dJq(xg(q), yg(q))*Nv(a)
    end
  end
  K(g, g) = K(g, g) + Ke
  F(g) = F(g) + Fe
end
#show
#: Vector de cargas global (kN). Los nudos 5, 6, 8 y 9 (puntos medios de un solo elemento) reciben −24 kN y el 7 (medio de la diagonal, compartido por los dos) recibe **−48 kN**. La suma es el peso total del bloque, W = γ·B·H = 18·4·2 = 144 kN:
#hide
F_r = zeros(n_d, 1)
for i = 1:n_d
  F_r(i) = round(F(i)*1000000)/1000000
end
#show
F_r [kN]
peso_total = -(F(6) + F(10) + F(12) + F(14) + F(16) + F(18)) [kN]
W = γ*B*H [kN]

## 10 · Apoyos y solución
#: En símbolos. Con los grados de libertad fijos (u = 0) las ecuaciones de equilibrio K·u = F se reducen a las de los **libres**: K_{ff}·u_{f} = F_{f}. K_{ff} es simétrica y definida positiva (si el apoyo impide el movimiento de cuerpo rígido), así que se resuelve por Cholesky.
#: Con letras, un sistema de 2 incógnitas, [m₁₁ m₁₂; m₁₂ m₂₂]·[u₁; u₂] = [f₁; f₂]. La solución (regla de Cramer) y la comprobación de que satisface la primera ecuación:
u1_s = Simplify{(m22*f1 - m12*f2)/(m11*m22 - m12^2)}
u2_s = Simplify{(m11*f2 - m12*f1)/(m11*m22 - m12^2)}
chk_s = Simplify{m11*(m22*f1 - m12*f2)/(m11*m22 - m12^2) + m12*(m11*f2 - m12*f1)/(m11*m22 - m12^2) - f1}
#: (el resultado simbólico de la comprobación es cero). El motor hace lo mismo con 12 incógnitas, o con miles en una malla real, factorizando la matriz en banda en lugar de usar Cramer.
#: Con números. Los grados fijos son los de los nudos 1, 2 y 5 (la base): 1, 2, 3, 4, 9 y 10.
i_fix = [1; 2; 3; 4; 9; 10]
#hide
fijo = zeros(n_d, 1)
for i = 1:6
  k_f = i_fix(i)
  fijo(k_f) = 1
end
lib = zeros(12, 1)
k_l = 0
for i = 1:n_d
  if fijo(i) == 0
    k_l = k_l + 1
    lib(k_l) = i
  end
end
#show
lib
Kff = K(lib, lib)
Ff = F(lib)
uf = lsolve(Kff, Ff)
#: Se devuelven los desplazamientos a los 18 grados de libertad y se muestran por nudo (**u** y **v** en mm):
#hide
u = zeros(n_d, 1)
for i = 1:12
  u(lib(i)) = uf(i)
end
U_n = zeros(n_j, 2)
for j = 1:n_j
  U_n(j, 1) = u(2*j - 1)*1000
  U_n(j, 2) = u(2*j)*1000
end
#show
U_n [mm]
#: **Mira la Figura 13:** el resultado en un dibujo. El bloque se asienta (v < 0) y sus esquinas superiores se separan por el efecto de Poisson; la base no se mueve.
#dibujo("Figura 13. La solución K·u = F: malla deformada (ampliada 400 veces) contra la original", ud = m, ancho = 200, alto = 109)
#  polilinea([0, 2, 4, 4, 4, 2, 0, 0, 0], [0, 0, 0, 1, 2, 2, 2, 1, 0], "media trazos azul")
#  linea(0, 0, 4, 2, "fina trazos")
#  polilinea([0, 2, 4, 4.1557, 4.1412, 1.989, -0.1642, -0.171, 0], [0, 0, 0, 0.5811, 1.3921, 1.4163, 1.388, 0.5487, 0], "gruesa rojo")
#  polilinea([0, 1.9969, 4.1412], [0, 0.5872, 1.3921], "media rojo")
#  achurado(-0.6, -0.45, 5.2, 0.45, "terreno")
#  circulo(0, 0, 0.05, "rojo relleno")
#  circulo(4, 0, 0.05, "rojo relleno")
#  circulo(4.1412, 1.3921, 0.05, "rojo relleno")
#  circulo(-0.1642, 1.388, 0.05, "rojo relleno")
#  circulo(2, 0, 0.05, "rojo relleno")
#  circulo(4.1557, 0.5811, 0.05, "rojo relleno")
#  circulo(1.9969, 0.5872, 0.05, "rojo relleno")
#  circulo(1.989, 1.4163, 0.05, "rojo relleno")
#  circulo(-0.171, 0.5487, 0.05, "rojo relleno")
#  texto(4.2912, 1.4421, "3: u = 0.353, v = −1.520 mm", 2.4, "i", estilo = "rojo")
#  texto(-0.3142, 1.438, "4: u = −0.411, v = −1.530 mm", 2.4, "d", estilo = "rojo")
#  texto(2, -1, "desplazamientos ×400 (1 mm real se dibuja como 0.4 m); en trazos, la malla sin deformar", 2.5, "c")
#  texto(2, 3.3, "la base no se mueve; el bloque se asienta y las esquinas se abren (efecto Poisson)", 2.5, "c")
#fin
#: **Comparación con el solver de Hekatan Geotechnic** (mismo bloque, mismo modelo): nudo 3, esquina superior derecha, u = 0.353110519 mm y v = −1.519685519 mm. La diferencia debe ser ruido numérico:
ref_u3 = [0.353110519; -1.519685519] [mm]
dif_u3 = [U_n(3, 1) - ref_u3(1); U_n(3, 2) - ref_u3(2)] [mm]
#: **Reacciones.** R = K·u − F en los grados fijos; la suma de las reacciones verticales debe igualar el peso:
Rn = K*u - F
suma_Ry = Rn(2) + Rn(4) + Rn(10) [kN]

## 11 · Tensiones en los puntos de Gauss
#: En símbolos. En cada punto de Gauss, ε = B·u_{e} y σ = D·ε. Las tensiones **no son continuas** entre elementos (el T6 solo garantiza continuidad de desplazamientos); por eso el motor las evalúa y guarda **en los puntos de Gauss**, que es donde la aproximación es más precisa.
#: σ_{q} = D · [ε_{x}; ε_{y}; 0; γ_{xy}]_{q}  con  ε_{q} = B(ξ_{q}, η_{q}) · u_{e}
#: Multiplicando D por las deformaciones, componente a componente:
sx_s = Expand{(lm + 2*Gm)*ex + lm*ey}
sy_s = Expand{lm*ex + (lm + 2*Gm)*ey}
sz_s = Expand{lm*(ex + ey)}
tau_s = Expand{Gm*gxy}
#: **La σ_{z}** no sale de ningún desplazamiento (ε_{z} = 0) pero sí tiene valor. Con las constantes de Lamé en función de E y ν, se cumple **σ_{z} = ν·(σ_{x} + σ_{y})** (la diferencia vale cero):
sz_dif = Simplify{E_m*ν_m/((1 + ν_m)*(1 - 2*ν_m))*(ex + ey) - ν_m*((E_m*ν_m/((1 + ν_m)*(1 - 2*ν_m)) + 2*E_m/(2*(1 + ν_m)))*ex + E_m*ν_m/((1 + ν_m)*(1 - 2*ν_m))*ey + E_m*ν_m/((1 + ν_m)*(1 - 2*ν_m))*ex + (E_m*ν_m/((1 + ν_m)*(1 - 2*ν_m)) + 2*E_m/(2*(1 + ν_m)))*ey)}
#: Con números:
#: Con números. Un bucle recorre los 14 puntos (7 por elemento) y guarda [σ_{x}, σ_{y}, σ_{z}, τ_{xy}] en kPa (compresión negativa):
#hide
S = zeros(14, 4)
for e = 1:n_e
  for a = 1:6
    Xe(a, 1) = x_j(e_j(e, a))
    Xe(a, 2) = y_j(e_j(e, a))
  end
  g = zeros(1, 12)
  for a = 1:6
    g(2*a - 1) = 2*e_j(e, a) - 1
    g(2*a) = 2*e_j(e, a)
  end
  ue = u(g)
  for q = 1:7
    de_x = Bx_q(xg(q), yg(q))*ue
    de_y = By_q(xg(q), yg(q))*ue
    dg_xy = Bg_q(xg(q), yg(q))*ue
    ex1 = de_x(1, 1)
    ey1 = de_y(1, 1)
    gg1 = dg_xy(1, 1)
    r_s = 7*(e - 1) + q
    S(r_s, 1) = D(1, 1)*ex1 + D(1, 2)*ey1
    S(r_s, 2) = D(2, 1)*ex1 + D(2, 2)*ey1
    S(r_s, 3) = D(3, 1)*ex1 + D(3, 2)*ey1
    S(r_s, 4) = D(4, 4)*gg1
  end
end
#show
S [kPa]
#: **Mira la Figura 14:** las tensiones verticales σy de la tabla S, puestas en el lugar de cada punto de Gauss. Crecen con la profundidad (σy ≈ −γ·z).
#dibujo("Figura 14. Las tensiones verticales σy en los 14 puntos de Gauss, donde el motor guarda y evalúa la plasticidad", ud = m, ancho = 200, alto = 102)
#  poligono([0, 4, 4], [0, 0, 2], "verde tenue")
#  poligono([0, 4, 0], [0, 2, 2], "azul tenue")
#  polilinea([0, 4, 4, 0, 0], [0, 0, 2, 2, 0], "gruesa")
#  linea(0, 0, 4, 2, "media")
#  achurado(-0.6, -0.45, 5.2, 0.45, "terreno")
#  circulo(2.6667, 0.6667, 0.05, "azul relleno")
#  texto(2.7467, 0.5067, "-23.8", 1.9, "i")
#  circulo(1.3333, 1.3333, 0.05, "azul relleno")
#  texto(1.4133, 1.1733, "-12.2", 1.9, "i")
#  circulo(3.5949, 1.5949, 0.05, "rojo relleno")
#  texto(3.6749, 1.4349, "-7.5", 1.9, "i")
#  circulo(0.4051, 1.7974, 0.05, "rojo relleno")
#  texto(0.4851, 1.6374, "-2.9", 1.9, "i")
#  circulo(0.8103, 0.2026, 0.05, "azul relleno")
#  texto(0.8903, 0.0426, "-31.7", 1.9, "i")
#  circulo(0.4051, 0.4051, 0.05, "azul relleno")
#  texto(0.4851, 0.2451, "-29.8", 1.9, "i")
#  circulo(3.5949, 0.2026, 0.05, "azul relleno")
#  texto(3.6749, 0.0426, "-32.3", 1.9, "i")
#  circulo(3.1897, 1.7974, 0.05, "rojo relleno")
#  texto(3.2697, 1.6374, "-3.9", 1.9, "i")
#  circulo(2.1194, 0.1194, 0.05, "azul relleno")
#  texto(2.1994, -0.0406, "-33.4", 1.9, "i")
#  circulo(1.8806, 1.0597, 0.05, "azul relleno")
#  texto(1.9606, 0.8997, "-17.7", 1.9, "i")
#  circulo(3.7611, 0.9403, 0.05, "azul relleno")
#  texto(3.8411, 0.7803, "-19.2", 1.9, "i")
#  circulo(1.8806, 1.8806, 0.05, "rojo relleno")
#  texto(1.9606, 1.7206, "-1.8", 1.9, "i")
#  circulo(2.1194, 0.9403, 0.05, "azul relleno")
#  texto(2.1994, 0.7803, "-18.8", 1.9, "i")
#  circulo(0.2389, 1.0597, 0.05, "azul relleno")
#  texto(0.3189, 0.8997, "-17.1", 1.9, "i")
#  texto(2, -1, "σy en kPa (compresión negativa): crece con la profundidad, como el peso γ·z; rojo = poca compresión, azul = mucha", 2.4, "c")
#  texto(2, 2.45, "14 puntos de Gauss (7 por elemento): las tensiones NO son continuas entre elementos", 2.6, "c")
#fin
#: **Comparación con el solver real**, punto 3 del elemento 2 (fila 10): σ = (−7.915809, −29.819866, −11.320703, −3.091447) kPa.
ref_S10 = [-7.915809, -29.819866, -11.320703, -3.091447] [kPa]
dif_S10 = [S(10, 1) - ref_S10(1), S(10, 2) - ref_S10(2), S(10, 3) - ref_S10(3), S(10, 4) - ref_S10(4)] [kPa]

## 12 · Plasticidad de Mohr-Coulomb en un punto de Gauss
#: En símbolos. El suelo no puede soportar cualquier tensión: el criterio de **Mohr-Coulomb** pone el límite en función de las tensiones principales σ₁ ≥ σ₂ ≥ σ₃ (tracción positiva). Con el centro p = (σ₁+σ₃)/2 y el radio R = (σ₁−σ₃)/2 del círculo de Mohr mayor, la función de fluencia es:
f_s = Simplify{(σ_1 - σ_3)/2 + (σ_1 + σ_3)/2*sin(φ_m) - c_m*cos(φ_m)}
#: **Mira la Figura 15:** la función f es una distancia en el plano de Mohr: el círculo de tensiones contra la recta de rotura τ = c − σ·tanφ.
#dibujo("Figura 15. El criterio de Mohr-Coulomb en el plano de Mohr: la envolvente τ = c − σ·tanφ y el círculo mayor (centro p, radio R) de un estado de tensión", ud = kPa, ancho = 200, alto = 117)
#  flecha(-44, 0, 9, 0, "negro")
#  texto(9.4, 0, "σ", 3.4, "i")
#  flecha(0, -16.5, 0, 17, "negro")
#  texto(0, 17.8, "τ", 3.4, "c")
#  polilinea([4.289, -30], [0, 15.9892], "gruesa rojo")
#  polilinea([4.289, -30], [0, -15.9892], "gruesa rojo")
#  circulo(-18.8678, 0, 11.3804, "media azul")
#  circulo(-18.8678, 0, 0.35, "azul relleno")
#  texto(-18.8678, -1.9, "p", 3, "c", estilo = "azul")
#  linea(-18.8678, 0, -11.5527, 8.7179, "media azul")
#  texto(-15.2678, 5.4, "R", 3, "i", estilo = "azul")
#  texto(-30.6482, -1.9, "σ₃", 3, "d")
#  texto(-7.0875, -1.9, "σ₁", 3, "i")
#  texto(0.8, 3.3, "c", 3, "i", estilo = "rojo")
#  circulo(0, 2, 0.3, "rojo relleno")
#  texto(1.3, 14.2, "recta de rotura:", 2.8, "i", estilo = "rojo")
#  texto(1.3, 12.6, "τ = c − σ·tanφ", 2.8, "i", estilo = "rojo")
#  texto(-12, -10.5, "f = R + p·senφ − c·cosφ", 3.2, "i", estilo = "azul")
#  texto(-12, -12.4, "f < 0: el círculo queda por debajo de la recta (el suelo resiste)", 2.6, "i")
#  texto(-12, -14, "f = 0: el círculo toca la recta (se alcanza la resistencia)", 2.6, "i")
#  texto(-12, -15.6, "f > 0: el círculo la corta (el estado no puede existir)", 2.6, "i", estilo = "rojo")
#fin
#: **f ≤ 0:** el punto es elástico. **f > 0:** el punto no puede existir (se pasó del límite) y hay que **devolverlo** a la superficie. El motor lo hace con una **corrección plástica**: σ' = σ_{prueba} − Δλ·D·g, donde g es la dirección del flujo plástico (ψ = ángulo de dilatancia) y Δλ el multiplicador. Para que f(σ') = 0, como f es lineal en σ con gradiente n, hace falta **Δλ = f / (nᵀ·D·g)**:
#: n = [½(1+senφ), 0, ½(senφ−1)],   g = [½(1+senψ), 0, ½(senψ−1)]   (en el orden σ₁, σ₂, σ₃)
an_s = (1 + sin(φ_m))/2
bn_s = (sin(φ_m) - 1)/2
ag_s = (1 + sin(ψ_m))/2
bg_s = (sin(ψ_m) - 1)/2
den_s = Simplify{an_s*ag_s*(λ_m + 2*G_m) + bn_s*bg_s*(λ_m + 2*G_m) + (an_s*bg_s + bn_s*ag_s)*λ_m}
#: **Comprobación simbólica:** tras la corrección, f(σ') = f − Δλ·(nᵀDg) = f − (f/den)·den = 0.
f_despues = Simplify{f_0 - (f_0/den_m)*den_m}
#: Con números. Se toma el punto con mayor exceso (elemento 2, punto 3, fila 10 de la tabla). Sus tensiones principales en el plano salen del círculo de Mohr, y la tercera es σ_{z}:
sx = S(10, 1)
sy = S(10, 2)
sz = S(10, 3)
txy = S(10, 4)
cen = (sx + sy)/2
Rr = sqrt(((sx - sy)/2)^2 + txy^2)
s_a = cen + Rr
s_b = cen - Rr
#: El orden es σ₁ = s_a, σ₂ = σ_{z}, σ₃ = s_b (comprobable en los valores). Con φ = 25° y c = 2 kPa:
psi = 0 'dilatancia nula
sp = sin(phi)
cc = c*cos(phi)
s1 = s_a
s2 = sz
s3 = s_b
f_prueba = (s1 - s3)/2 + (s1 + s3)/2*sp - cc [kPa]
#: f > 0: **el punto está fuera de la superficie** (por elasticidad puro). Retorno a la cara σ₁-σ₃, con D en ejes principales y la dirección de flujo g:
Dp = [lam + 2*G, lam, lam; lam, lam + 2*G, lam; lam, lam, lam + 2*G]
n1 = [(1 + sp)/2; 0; (sp - 1)/2]
g1 = [(1 + sin(psi))/2; 0; (sin(psi) - 1)/2]
den = transpose(n1)*Dp*g1
dlam = f_prueba/den(1, 1) 'multiplicador plástico
sret = [s1; s2; s3] - dlam*Dp*g1
f_ret = (sret(1) - sret(3))/2 + (sret(1) + sret(3))/2*sp - cc [kPa]
#: f(σ') ≈ 0: el punto volvió a la superficie. **Validez:** las otras dos funciones (caras σ₂-σ₃ y σ₁-σ₂) deben ser ≤ 0, si no, el retorno iría a una arista o al vértice:
f_23 = (sret(2) - sret(3))/2 + (sret(2) + sret(3))/2*sp - cc [kPa]
f_12 = (sret(1) - sret(2))/2 + (sret(1) + sret(2))/2*sp - cc [kPa]
#: **Mira las Figuras 16 y 17:** el mismo retorno que se acaba de calcular, dibujado en el plano de Mohr y en el plano de tensiones principales.
#dibujo("Figura 16. El retorno plástico del punto 10 con números: el círculo de prueba (en trazos) cruza la envolvente; el retorno lo encoge hasta hacerlo tangente", ud = kPa, ancho = 200, alto = 117)
#  flecha(-44, 0, 9, 0, "negro")
#  texto(9.4, 0, "σ", 3.4, "i")
#  flecha(0, -16.5, 0, 17, "negro")
#  texto(0, 17.8, "τ", 3.4, "c")
#  polilinea([4.289, -30], [0, 15.9892], "gruesa rojo")
#  polilinea([4.289, -30], [0, -15.9892], "gruesa rojo")
#  circulo(-18.8678, 0, 11.3804, "media trazos rojo")
#  circulo(-18.8678, 0, 9.7865, "gruesa verde")
#  circulo(-9.4041, 0, 1.9166, "fina trazos rojo")
#  circulo(-20.7845, 0, 9.4638, "fina trazos rojo")
#  circulo(-7.4875, 0, 0.3, "rojo relleno")
#  circulo(-11.3207, 0, 0.3, "rojo relleno")
#  circulo(-30.2482, 0, 0.3, "rojo relleno")
#  circulo(-9.0813, 0, 0.3, "verde relleno")
#  circulo(-28.6543, 0, 0.3, "verde relleno")
#  texto(-30.7482, -2.3, "σ₃ = −30.25", 2.5, "d", estilo = "rojo")
#  texto(-6.9875, -2.3, "σ₁ = −7.49", 2.5, "i", estilo = "rojo")
#  texto(-11.3207, -4.6, "σ₂ = σz = −11.32", 2.5, "c", estilo = "rojo")
#  texto(-20.8678, 13.6, "prueba (trazos): f = +1.593 kPa", 2.7, "c", estilo = "rojo")
#  texto(-18.8678, -13.2, "devuelto (verde): f = 0, tangente a la recta", 2.8, "c", estilo = "verde")
#  texto(-43, -7.5, "σ₁' = −9.08;  σ₃' = −28.65;  σ₂' = −11.32 (no cambia: ψ = 0)", 2.6, "i", estilo = "verde")
#  texto(-43, -9.4, "Δλ = f / (nᵀ·D·g) = 2.07·10⁻⁴", 2.6, "i")
#  texto(1.3, 14.2, "recta de rotura:", 2.8, "i", estilo = "rojo")
#  texto(1.3, 12.6, "τ = c − σ·tanφ", 2.8, "i", estilo = "rojo")
#fin
#dibujo("Figura 17. El retorno en el plano de tensiones principales (σ₁, σ₃): se mueve en la dirección −D·g hasta la superficie de fluencia", ud = kPa, ancho = 200, alto = 150)
#  flecha(-12, -35, -4.5, -35, "negro")
#  texto(-4.2, -35, "σ₁", 3, "i")
#  flecha(-12, -35, -12, -21.5, "negro")
#  texto(-12, -20.6, "σ₃", 3, "c")
#  polilinea([-11.4, -6.6], [-34.3673, -22.5406], "gruesa rojo")
#  texto(-6.2, -22.3406, "f = 0 (cara σ₁–σ₃)", 2.6, "i", estilo = "rojo")
#  circulo(-7.4875, -30.2482, 0.12, "rojo relleno")
#  texto(-7.1875, -30.6482, "prueba (−7.49; −30.25)", 2.5, "i", estilo = "rojo")
#  circulo(-9.0813, -28.6543, 0.12, "verde relleno")
#  texto(-9.3813, -28.3543, "devuelto (−9.08; −28.65)", 2.5, "d", estilo = "verde")
#  flecha(-7.4875, -30.2482, -9.0013, -28.7343, "negro")
#  texto(-11.7, -23, "Δσ = −Δλ·D·g, con g = [½, 0, −½]", 2.5, "i")
#  texto(-11.7, -24.2, "D·g = G·[1, 0, −1]: baja σ₁ y sube σ₃ lo mismo", 2.5, "i")
#fin
#: Se rotan las tensiones principales de vuelta a los ejes x, y con el mismo ángulo (2θ = atan2(2·τ_{xy}, σ_{x} − σ_{y})):
t2 = atan2(2*txy, sx - sy)
cen2 = (sret(1) + sret(3))/2
R2 = (sret(1) - sret(3))/2
s_dev = [cen2 + R2*cos(t2); cen2 - R2*cos(t2); sret(2); R2*sin(t2)] [kPa]
#: **Comparación con el solver real** (retorno de Mohr-Coulomb de Hekatan Geotechnic con las mismas tensiones de prueba): σ' = (−9.44935831, −28.28631697, −11.32070259, −2.65856958) kPa.
ref_sdev = [-9.44935831; -28.28631697; -11.32070259; -2.65856958] [kPa]
dif_sdev = [s_dev(1) - ref_sdev(1); s_dev(2) - ref_sdev(2); s_dev(3) - ref_sdev(3); s_dev(4) - ref_sdev(4)] [kPa]

## 13 · Reducción de resistencia: el factor de seguridad
#: En símbolos. El **factor de seguridad** de un talud es el número F por el que hay que dividir la resistencia del suelo para que el talud **justo** deje de ser estable: c_{F} = c/SRF  y  tanφ_{F} = tanφ/SRF. Para un solo punto de Gauss, con tensiones fijas (σ₁, σ₃), el F que lo lleva a la fluencia sale en **forma cerrada**. Con t = tanφ, las razones trigonométricas del ángulo reducido son senφ_{F} = t/√(SRF²+t²) y cosφ_{F} = SRF/√(SRF²+t²), y la función de fluencia se simplifica a:
fF_s = Simplify{R_m + (p_m*t_m - c_m)/sqrt(SRF^2 + t_m^2)}
#: **Mira la Figura 18:** al aumentar SRF la recta de rotura baja y se aplana; el SRF al que toca el círculo es el factor de seguridad del punto.
#dibujo("Figura 18. La reducción de resistencia en un punto: al dividir c y tanφ por SRF la envolvente baja hasta tocar el círculo; ese SRF es el factor de seguridad del punto", ud = kPa, ancho = 200, alto = 127)
#  flecha(-14, 0, 14, 0, "negro")
#  texto(14.4, 0, "σ", 3.4, "i")
#  flecha(0, -10, 0, 20, "negro")
#  texto(0, 20.8, "τ", 3.4, "c")
#  circulo(-1.8858, 0, 5.7741, "gruesa azul")
#  texto(-1.8858, -1.9, "círculo del punto", 2.6, "c", estilo = "azul")
#  texto(-1.8858, -3.5, "(tensiones fijas)", 2.4, "c", estilo = "azul")
#  polilinea([13.8564, -13], [0, 15.5056], "media verde")
#  texto(-13.3, 15.9056, "SRF = 1 (resistencia real)", 2.6, "d", estilo = "verde")
#  polilinea([13.8564, -13], [0, 12.4044], "media naranja")
#  texto(-13.3, 12.8044, "SRF = 1.25", 2.6, "d", estilo = "naranja")
#  polilinea([13.8564, -13], [0, 10.5886], "gruesa rojo")
#  texto(-13.3, 10.9886, "SRF = 1.464: toca el círculo", 2.6, "d", estilo = "rojo")
#  texto(-13, -7, "c_F = c/SRF  y  tanφ_F = tanφ/SRF:", 2.6, "i")
#  texto(-13, -8.7, "al aumentar SRF la recta baja y se aplana", 2.6, "i")
#fin
#: Igualando a cero, se despeja el factor:  √(SRF² + t²) = (c − p·t)/R   →   **SRF = √( ((c − p·t)/R)² − t² )**.
F_s = Simplify{sqrt(((c_m - p_m*t_m)/R_m)^2 - t_m^2)}
#: Con números. Para ver un factor mayor que 1 se usa un suelo más resistente, c = 8 kPa y φ = 30°. En cada uno de los 14 puntos (con las tensiones elásticas de la tabla S) se calcula R, p y F:
c_s = 8 [kPa]
t_s = tan(30*pi/180)
#hide
Fpt = zeros(14, 1)
Rcv = zeros(14, 1)
pcv = zeros(14, 1)
for i = 1:14
  cen_i = (S(i, 1) + S(i, 2))/2
  R_i = sqrt(((S(i, 1) - S(i, 2))/2)^2 + S(i, 4)^2)
  sa_i = cen_i + R_i
  sb_i = cen_i - R_i
  smax = max(max(sa_i, sb_i), S(i, 3))
  smin = min(min(sa_i, sb_i), S(i, 3))
  Rc = (smax - smin)/2
  pc = (smax + smin)/2
  Rcv(i) = Rc
  pcv(i) = pc
  Fpt(i) = sqrt(((c_s - pc*t_s)/Rc)^2 - t_s^2)
end
#show
Fpt
F_min = min(min(min(Fpt(1), Fpt(2)), min(Fpt(3), Fpt(4))), min(min(Fpt(5), Fpt(6)), min(Fpt(7), Fpt(8))))
F_min2 = min(min(min(Fpt(9), Fpt(10)), min(Fpt(11), Fpt(12))), min(Fpt(13), Fpt(14)))
F_punto = min(F_min, F_min2) 'el primer punto que fluye, con las tensiones elásticas
#: **La función f(SRF)** del punto 2 con los datos de esta hoja: cruza el cero justo en SRF = 1.464, el factor de seguridad de ese punto:
#fplot(f_SRF = 5.77407 + (-1.88579*0.57735 - 8.0)/sqrt(x^2 + 0.33333), cero = 0*x, [0.6 3])
#: **Comprobación de la fórmula cerrada** en el punto 2: con la resistencia reducida por su factor, la función de fluencia debe valer cero:
F_2 = Fpt(2)
f_chk = Rcv(2) + pcv(2)*sin(atan(t_s/F_2)) - (c_s/F_2)*cos(atan(t_s/F_2)) [kPa]
#: Eso es solo un **indicador local**: dice cuándo empieza a plastificar el primer punto, con las tensiones elásticas. Pero el factor de seguridad real es el F al que **el sistema completo pierde el equilibrio**: cuando un punto fluye, sus tensiones se reparten a los vecinos y el bloque aguanta más. Por eso el motor no se queda en este número: **reduce la resistencia por escalones (F = 1, 1.1, 1.2, …) y en cada escalón resuelve el problema no lineal completo**; el último F que converge es el factor de seguridad.
#: Para este bloque de 2 elementos, con c = 8 kPa y φ = 30°, **el solver de Hekatan Geotechnic da FS = 1.9299** (la SRM completa, 7 escalones), mayor que el indicador local, como se espera por la redistribución:
FS_solver = 1.929925
reserva = FS_solver/F_punto 'cuánto aguanta de más el sistema que el primer punto

## 14 · Lo que el motor añade a esto
#: Todo lo anterior es **el mismo código** que corre en cada elemento del motor; lo que cambia con una malla de cientos de elementos es solo el tamaño de la matriz (banda con Cuthill-McKee inverso) y que la plasticidad entra en un lazo de Newton-Raphson. Esto es lo que se suma y está **comprobado contra GEO5 2024**:
#: **Mira la Figura 19:** el lazo completo de la reducción de resistencia, con Newton-Raphson dentro de cada escalón.
#dibujo("Figura 19. El lazo de la reducción de resistencia en Geotechnic: Newton-Raphson dentro de cada escalón, y el escalón de SRF más alto que converge es el factor de seguridad", ud = , ancho = 200, alto = 117)
#  poligono([0, 6, 6, 0], [8, 8, 9.2, 9.2], "azul tenue")
#  polilinea([0, 6, 6, 0, 0], [8, 8, 9.2, 9.2, 8], "media")
#  texto(3, 8.48, "SRF = 1; σ = peso propio", 2.4, "c")
#  poligono([0, 6, 6, 0], [6, 6, 7.2, 7.2], "azul tenue")
#  polilinea([0, 6, 6, 0, 0], [6, 6, 7.2, 7.2, 6], "media")
#  texto(3, 6.48, "c_F = c/SRF; tanφ_F = tanφ/SRF", 2.4, "c")
#  poligono([0, 6, 6, 0], [4, 4, 5.2, 5.2], "azul tenue")
#  polilinea([0, 6, 6, 0, 0], [4, 4, 5.2, 5.2, 4], "media")
#  texto(3, 4.48, "iteración de Newton: K con la tangente", 2.4, "c")
#  poligono([0, 6, 6, 0], [2, 2, 3.2, 3.2], "azul tenue")
#  polilinea([0, 6, 6, 0, 0], [2, 2, 3.2, 3.2, 2], "media")
#  texto(3, 2.48, "du = −K⁻¹·R; búsqueda lineal η", 2.4, "c")
#  poligono([0, 6, 6, 0], [0, 0, 1.2, 1.2], "azul tenue")
#  polilinea([0, 6, 6, 0, 0], [0, 0, 1.2, 1.2, 0], "media")
#  texto(3, 0.48, "σ ← retorno de Mohr-Coulomb; R nuevo", 2.4, "c")
#  flecha(3, 8, 3, 7.25, "negro")
#  flecha(3, 6, 3, 5.25, "negro")
#  flecha(3, 4, 3, 3.25, "negro")
#  flecha(3, 2, 3, 1.25, "negro")
#  poligono([8.5, 14, 14, 8.5], [0, 0, 1.2, 1.2], "naranja tenue")
#  polilinea([8.5, 14, 14, 8.5, 8.5], [0, 0, 1.2, 1.2, 0], "media")
#  texto(11.25, 0.48, "|R| < tolerancia ?", 2.4, "c")
#  flecha(6, 0.6, 8.5, 0.6, "negro")
#  texto(7.25, 0.9, "", 2, "c")
#  poligono([8.5, 14, 14, 8.5], [3, 3, 4.4, 4.4], "verde tenue")
#  polilinea([8.5, 14, 14, 8.5, 8.5], [3, 3, 4.4, 4.4, 3], "media")
#  texto(11.25, 3.58, "sí: converge → guarda y sube SRF", 2.4, "c")
#  flecha(11.25, 1.2, 11.25, 3, "negro")
#  texto(11.9, 1.9, "sí", 2.4, "i")
#  polilinea([8.5, 7, 7], [0.6, 0.6, 3.6], "media negro")
#  flecha(7, 3.6, 6, 4.6, "negro")
#  texto(7.4, 1.8, "no", 2.4, "i")
#  poligono([8.5, 14, 14, 8.5], [6, 6, 7.4, 7.4], "rojo tenue")
#  polilinea([8.5, 14, 14, 8.5, 8.5], [6, 6, 7.4, 7.4, 6], "media")
#  texto(11.25, 6.58, "no converge → FS = último SRF que convergió", 2.4, "c")
#  polilinea([14, 14.6, 14.6], [3.7, 3.7, 6.7], "media negro")
#  flecha(14.6, 6.7, 14, 6.7, "negro")
#  texto(14.75, 5.2, "si diverge", 2.4, "i")
#  polilinea([8.5, 8, 8], [3.7, 3.7, 6.6], "media negro")
#  flecha(8, 6.6, 6, 6.6, "negro")
#fin
#: **1. Newton-Raphson con tangente algorítmica.** Cuando un punto fluye, su rigidez ya no es D, sino la **tangente** D − (D·g)(nᵀD)/(nᵀDg), que no es simétrica. Cada iteración rehace K con esas tangentes y corrige los desplazamientos hasta que el residuo (F − fuerzas internas) es cero. En la dinámica de GEO5, la tangente de la primera iteración de cada paso es elástica.
#: **2. Retorno multisuperficie.** El criterio de Mohr-Coulomb es una pirámide hexagonal: además de la cara (esta hoja), hay **aristas** y un **vértice** (ápice). La tolerancia de la fluencia es **absoluta**, 10⁻³ kPa.
#: **3. Búsqueda lineal.** Si un paso de Newton aumenta el residuo, se acorta con un factor η. GEO5 lo calcula con la inercia congelada y una sola secante: η ← η·e₀/(e₀−e₁).
#: **4. Dinámica.** Con masa consistente M = ∫ρ·NᵀN dA, el método HHT-α y el amortiguamiento de Rayleigh, el mismo T6 responde a un sismo en la base. Comparado con GEO5 2024 corriendo: error relativo de **3.9 × 10⁻⁷** en los desplazamientos de una malla de 8 T6 con plasticidad, 16 pasos.
#: **Resumen de lo comprobado en esta hoja contra el solver real:** desplazamientos del nudo 3 (diferencia ≈ 10⁻¹⁰ mm), tensiones del punto 10 (≈ 10⁻⁷ kPa), retorno de Mohr-Coulomb (≈ 10⁻⁹ kPa), reacciones = peso, y el FS de la reducción de resistencia.
