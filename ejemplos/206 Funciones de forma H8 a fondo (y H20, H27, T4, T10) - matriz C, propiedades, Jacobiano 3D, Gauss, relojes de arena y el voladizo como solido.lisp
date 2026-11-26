# Funciones de forma H8 a fondo (y H20, H27, T4, T10) - matriz C, propiedades, Jacobiano 3D, Gauss, relojes de arena y el voladizo como solido
#numerico

## 0 · La idea
#: Lo mismo que en el cuadrilátero (hoja 204) y el triángulo (205), ahora en 3D: cada **Nᵢ(ξ, η, ζ) vale 1 en su nudo y 0 en los demás**, y todas **suman 1**. El **H8** (hexaedro de 8 nudos, «ladrillo») es el sólido más usado: zapatas y cabezales macizos, suelo en 3D, bloques de anclaje. Sus parientes: **H20** (serendípito, con nudos en las aristas), **H27** (Lagrange), y los tetraedros **T4** y **T10**, que mallan cualquier volumen.
#: La hoja 203 ya usó el H8 en una barra (con la cara atada). Aquí se **deduce** con la matriz C, se comprueban sus propiedades, se mapea a un ladrillo real, se ve cuántos puntos de Gauss pide y qué pasa con uno solo, y se pone a trabajar el **mismo voladizo** de las hojas 204 y 205, ahora como sólido.
#dibujo("H8 en perspectiva: cara de abajo ζ = −1 (nudos 1-4) y de arriba ζ = +1 (nudos 5-8); ejes ξ, η, ζ", ud = m, escala = auto, alto = 70)
#  poligono(0, 0, 2, 0, 2.8, 0.8, 0.8, 0.8, "gruesa")
#  poligono(0, 2, 2, 2, 2.8, 2.8, 0.8, 2.8, "gruesa")
#  linea(0, 0, 0, 2, "gruesa")
#  linea(2, 0, 2, 2, "gruesa")
#  linea(2.8, 0.8, 2.8, 2.8, "gruesa")
#  linea(0.8, 0.8, 0.8, 2.8, "trazos")
#  circulo(0, 0, 0.07, "negro")
#  circulo(2, 0, 0.07, "negro")
#  circulo(2.8, 0.8, 0.07, "negro")
#  circulo(0.8, 0.8, 0.07, "negro")
#  circulo(0, 2, 0.07, "negro")
#  circulo(2, 2, 0.07, "negro")
#  circulo(2.8, 2.8, 0.07, "negro")
#  circulo(0.8, 2.8, 0.07, "negro")
#  texto(-0.2, -0.2, "1", 2.4, "c")
#  texto(2.15, -0.2, "2", 2.4, "c")
#  texto(3.05, 0.75, "3", 2.4, "c")
#  texto(0.6, 0.95, "4", 2.4, "c")
#  texto(-0.2, 2.15, "5", 2.4, "c")
#  texto(2.1, 1.8, "6", 2.4, "c")
#  texto(3.05, 2.95, "7", 2.4, "c")
#  texto(0.65, 3.0, "8", 2.4, "c")
#  flecha(1.4, 1.4, 2.2, 1.4, "fina")
#  flecha(1.4, 1.4, 1.8, 1.8, "fina")
#  flecha(1.4, 1.4, 1.4, 2.2, "fina")
#  texto(2.35, 1.4, "ξ", 2.4, "c")
#  texto(1.95, 1.9, "η", 2.4, "c")
#  texto(1.4, 2.35, "ζ", 2.4, "c")
#  poligono(4.5, 0, 5.8, 0, 5.2, 0.6, "gruesa")
#  linea(4.5, 0, 5, 1.9, "gruesa")
#  linea(5.8, 0, 5, 1.9, "gruesa")
#  linea(5.2, 0.6, 5, 1.9, "trazos")
#  texto(5.1, -0.4, "T4 (4 nudos) / T10 (+ 6 en las aristas)", 2.2, "c")
#  texto(1.4, -0.6, "H8 (H20: + 12 en las aristas; H27: + 6 caras + centro)", 2.2, "c")
#fin
#: Nudos de referencia (ξ, η, ζ de −1 a +1): 1 (−1, −1, −1), 2 (+1, −1, −1), 3 (+1, +1, −1), 4 (−1, +1, −1), y 5 a 8 iguales con ζ = +1.

## 1 · H8: del polinomio a N con la matriz C (8 × 8)
#: La base trilineal tiene 8 términos para 8 nudos: [1, ξ, η, ζ, ξη, ηζ, ζξ, ξηζ] (sin cuadrados: es lineal en cada dirección por separado). Cada fila de C es la base en un nudo:
C_8 = [1, -1, -1, -1, 1, 1, 1, -1; 1, 1, -1, -1, -1, 1, -1, 1; 1, 1, 1, -1, 1, -1, -1, -1; 1, -1, 1, -1, -1, -1, 1, 1; 1, -1, -1, 1, 1, -1, -1, 1; 1, 1, -1, 1, -1, -1, 1, -1; 1, 1, 1, 1, 1, 1, 1, 1; 1, -1, 1, 1, -1, 1, -1, -1] 'filas: nudos 1…8
d_8 = det(C_8) '4096 = 2¹²: distinto de 0
C_8i = inv(C_8) 'columna j = coeficientes de Nⱼ (todos ±1/8)
N_H8 = Simplify{[1, xi, eta, zeta, xi*eta, eta*zeta, zeta*xi, xi*eta*zeta]*[0.125, 0.125, 0.125, 0.125, 0.125, 0.125, 0.125, 0.125; -0.125, 0.125, 0.125, -0.125, -0.125, 0.125, 0.125, -0.125; -0.125, -0.125, 0.125, 0.125, -0.125, -0.125, 0.125, 0.125; -0.125, -0.125, -0.125, -0.125, 0.125, 0.125, 0.125, 0.125; 0.125, -0.125, 0.125, -0.125, 0.125, -0.125, 0.125, -0.125; 0.125, 0.125, -0.125, -0.125, -0.125, -0.125, 0.125, 0.125; 0.125, -0.125, -0.125, 0.125, -0.125, 0.125, 0.125, -0.125; -0.125, 0.125, -0.125, 0.125, 0.125, -0.125, 0.125, -0.125]}
#: **Nᵢ = (1 ± ξ)(1 ± η)(1 ± ζ)/8**. El atajo: el **producto de tres rectas** de Lagrange, una por dirección. El motor expande las dos formas del nudo 1 para compararlas:
n_81 = Simplify{[1, xi, eta, zeta, xi*eta, eta*zeta, zeta*xi, xi*eta*zeta]*[0.125; -0.125; -0.125; -0.125; 0.125; 0.125; 0.125; -0.125]} 'base · columna 1 de C⁻¹
f_81 = Simplify{(1 - xi)/2*(1 - eta)/2*(1 - zeta)/2} 'ℓ₁(ξ)·ℓ₁(η)·ℓ₁(ζ) expandido: igual
#: **¿Cómo se ve una función de 3 variables?** Por cortes. En la cara de abajo (ζ = −1), N₁ del H8 **es exactamente N₁ del Q4**; en el plano del medio (ζ = 0) vale la mitad; arriba (ζ = +1) es cero:
k_1 = Simplify{(1 - xi)*(1 - eta)*(1 - (-1))/8} 'ζ = −1: el Q4
k_0 = Simplify{(1 - xi)*(1 - eta)*(1 - 0)/8} 'ζ = 0: la mitad
#: Los tres cortes como superficies (ζ = −1 arriba de todo, ζ = 0 en el medio, ζ = +1 plana en cero; arrastra para girar):
#surf(c_1 = (1 - x)*(1 - y)/4, c_0 = (1 - x)*(1 - y)/8, c_m = 0*x, [-1 1], [-1 1])
#: Planta del corte ζ = 0 con colores (pasa el cursor): el valor máximo es ½ en la arista del nudo 1:
#map((1 - x)*(1 - y)/8, [-1 1], [-1 1])
#: Corte por la arista 1-5 (ξ = η = −1): N₁ y N₅ son **rectas** en ζ que se cruzan en ½:
#fplot(N_1 = (1 - x)/2, N_5 = (1 + x)/2, nudos = [-1 1; 1 0; -1 0; 1 1], [-1 1])

## 2 · H20, H27, T4 y T10
#: **H20 (serendípito):** sin nudos en el centro de las caras ni en el centro. Esquina **(1 − ξ)(1 − η)(1 − ζ)(−ξ − η − ζ − 2)/8**, arista **(1 − ξ²)(1 − η)(1 − ζ)/4**. Igual que el Q8, la esquina se hunde en el centro:
h_c = (1 - 0)*(1 - 0)*(1 - 0)*(-0 - 0 - 0 - 2)/8 'esquina del H20 en el centro
#: **H27 (Lagrange):** el producto de **tres parábolas** ℓ(ξ)·ℓ(η)·ℓ(ζ), con nudos en las caras y en el centro (su base va hasta ξ²η²ζ²). Deducidas con C⁻¹ en Python (sympy; det C del H20 = 2²⁴ y del H27 = −2²⁷): las fórmulas coinciden exactas.
#: **T4 (tetraedro lineal):** coordenadas de volumen, L₁ = 1 − ξ − η − ζ, L₂ = ξ, L₃ = η, L₄ = ζ. Su C es 4 × 4:
N_T4 = Simplify{[1, xi, eta, zeta]*inv([1, 0, 0, 0; 1, 1, 0, 0; 1, 0, 1, 0; 1, 0, 0, 1])}
#: **T10 (tetraedro cuadrático):** vértice **Lᵢ(2Lᵢ − 1)**, arista **4LᵢLⱼ** (igual que el T6 de la hoja 205, con una coordenada más). La de la arista 1-2 en el centroide (¼, ¼, ¼):
t_10 = 4*(1 - 0.75)*0.25 '4L₁L₂ en el centroide

## 3 · Propiedades
#: **ΣN = 1**: la primera columna de C es de unos, así que C⁻¹·[1; …; 1] = [1; 0; …; 0]:
c_s8 = inv(C_8)*[1; 1; 1; 1; 1; 1; 1; 1] 'C⁻¹·unos
s_8 = Simplify{[1, xi, eta, zeta, xi*eta, eta*zeta, zeta*xi, xi*eta*zeta]*[1; 0; 0; 0; 0; 0; 0; 0]} 'ΣN del H8
#: **Completitud**: con los ξᵢ de los nudos vuelve ξ; con ξᵢ² (todos 1) vuelve **1, no ξ²**: el H8, como el Q4, no puede curvarse dentro del elemento.
c_r8 = inv(C_8)*[-1; 1; 1; -1; -1; 1; 1; -1] 'C⁻¹·ξᵢ
r_8 = Simplify{[1, xi, eta, zeta, xi*eta, eta*zeta, zeta*xi, xi*eta*zeta]*[0; 1; 0; 0; 0; 0; 0; 0]} 'ΣNᵢξᵢ = ξ
c_p8 = inv(C_8)*[1; 1; 1; 1; 1; 1; 1; 1] 'C⁻¹·ξᵢ² (todos 1)
#: Como ξᵢ² = 1 en los 8 nudos, ΣNᵢξᵢ² = ΣNᵢ = 1. H20, H27 y T10 sí devuelven ξ² (Python). **Derivada**: ∂N₁/∂ξ no depende de ξ, solo de η y ζ:
e_1 = Simplify{Diff{(1 - xi)*(1 - eta)*(1 - zeta)/8 @ xi}} '∂N₁/∂ξ

## 4 · Jacobiano de un ladrillo real (m)
#dibujo("Ladrillo real: base 2 × 1 m en z = 0; la tapa corrida 0.2 m y con el borde derecho a 1.2 m de alto (vista lateral, plano x-z)", ud = m, escala = auto, cotas = m, alto = 50)
#  poligono(0, 0, 2, 0, 2.4, 1.2, 0.2, 1, "gruesa")
#  circulo(0, 0, 0.04, "negro")
#  circulo(2, 0, 0.04, "negro")
#  circulo(2.4, 1.2, 0.04, "negro")
#  circulo(0.2, 1, 0.04, "negro")
#  texto(-0.15, -0.15, "1, 4", 2.2, "c")
#  texto(2.15, -0.15, "2, 3", 2.2, "c")
#  texto(2.55, 1.35, "6, 7", 2.2, "c")
#  texto(0.05, 1.15, "5, 8", 2.2, "c")
#  cota(0, -0.4, 2, -0.4, 0, "2 m")
#  cota(2.8, 0, 2.8, 1.2, 0, "1.2 m")
#fin
#: Nudos (m): 1 (0, 0, 0), 2 (2, 0, 0), 3 (2, 1, 0), 4 (0, 1, 0), 5 (0.2, 0, 1), 6 (2.4, 0, 1.2), 7 (2.4, 1, 1.2), 8 (0.2, 1, 1). Los coeficientes del mapa son C⁻¹·(coordenadas de los nudos):
c_x = inv(C_8)*[0; 2; 2; 0; 0.2; 2.4; 2.4; 0.2] 'coeficientes de x
c_y = inv(C_8)*[0; 0; 1; 1; 0; 0; 1; 1] 'coeficientes de y
c_z = inv(C_8)*[0; 0; 0; 0; 1; 1.2; 1.2; 1] 'coeficientes de z
x_b = Simplify{[1, xi, eta, zeta, xi*eta, eta*zeta, zeta*xi, xi*eta*zeta]*[1.15; 1.05; 0; 0.15; 0; 0; 0.05; 0]} 'x(ξ, η, ζ) [m]
y_b = Simplify{[1, xi, eta, zeta, xi*eta, eta*zeta, zeta*xi, xi*eta*zeta]*[0.5; 0; 0.5; 0; 0; 0; 0; 0]} 'y [m]
z_b = Simplify{[1, xi, eta, zeta, xi*eta, eta*zeta, zeta*xi, xi*eta*zeta]*[0.55; 0.05; 0; 0.55; 0; 0; 0.05; 0]} 'z [m]
#: El Jacobiano 3 × 3 (filas: ∂/∂ξ, ∂/∂η, ∂/∂ζ de x, y, z). El motor deriva cada término:
j_11 = Simplify{Diff{23/20 + 21*xi/20 + 3*zeta/20 + xi*zeta/20 @ xi}} '∂x/∂ξ
j_13 = Simplify{Diff{11/20 + xi/20 + 11*zeta/20 + xi*zeta/20 @ xi}} '∂z/∂ξ
j_22 = Simplify{Diff{1/2 + eta/2 @ eta}} '∂y/∂η
j_31 = Simplify{Diff{23/20 + 21*xi/20 + 3*zeta/20 + xi*zeta/20 @ zeta}} '∂x/∂ζ
j_33 = Simplify{Diff{11/20 + xi/20 + 11*zeta/20 + xi*zeta/20 @ zeta}} '∂z/∂ζ
#: Los demás términos son 0 (y no depende de ξ ni de ζ). det J = (1/2)·(∂x/∂ξ·∂z/∂ζ − ∂z/∂ξ·∂x/∂ζ):
d_J = Simplify{(1/2)*((21 + zeta)/20*(11 + xi)/20 - (1 + zeta)/20*(3 + xi)/20)} 'det J [m³]
#: **det J = 57/200 + ξ/40 + ζ/100**. Con los 8 puntos de Gauss (±1/√3, peso 1) su suma da el volumen exacto:
v_J(a, b, c) = 57/200 + a/40 + c/100
g_s = 1/sqrt(3)
V_b = v_J(-g_s, -g_s, -g_s) + v_J(g_s, -g_s, -g_s) + v_J(g_s, g_s, -g_s) + v_J(-g_s, g_s, -g_s) + v_J(-g_s, -g_s, g_s) + v_J(g_s, -g_s, g_s) + v_J(g_s, g_s, g_s) + v_J(-g_s, g_s, g_s) 'volumen [m³]
#: Comprobación: el ladrillo es un prisma de 1 m de ancho (en y) cuya cara lateral (x-z) es el cuadrilátero (0, 0), (2, 0), (2.4, 1.2), (0.2, 1), de área 2.28 m² (fórmula del área de Gauss): 2.28 m³. Mapa de det J en el plano η = 0 (ξ horizontal, ζ vertical):
#map(57/200 + x/40 + y/100, [-1 1], [-1 1])
#: **Distorsión excesiva**: si el nudo 7 se mete hacia (0.5, 0.3, 0.2) m, det J en la esquina 7 pasa de 0.32 a **−0.37 m³** y en su punto de Gauss a **−0.115 m³** (Python): el elemento se da vuelta y el programa para.

## 5 · Gauss en 3D y los relojes de arena
#: Con 2 × 2 × 2 = **8 puntos** el H8 se integra exacto en un ladrillo recto; el H20 y el H27 piden **3 × 3 × 3 = 27**. Con **1 punto** (el centro), todo modo cuyas derivadas se anulen en el centro no cuesta energía: en 3D hay **12** de esos (relojes de arena). El modo u = ξη:
m_1 = Simplify{Diff{xi*eta @ xi}} 'εₓ ∝ η: vale 0 en el centro
#: Autovalores nulos de K (6 son de cuerpo rígido: 3 traslaciones y 3 giros), contados en Python:
q_a = [18, 6, 12, 6, 6, 24, 6] 'autovalores nulos
q_b = [12, 0, 6, 0, 0, 18, 0] 'modos espurios
#tabla("Elemento e integración","autovalores nulos:0","espurios:0")({"H8, 1 punto","H8, 2 × 2 × 2","H20, 2 × 2 × 2 (reducida)","H20, 3 × 3 × 3","T4, 1 punto (exacto)","T10, 1 punto","T10, 4 puntos"}; q_a; q_b)
#: En el voladizo de la sección 6, el H8 con 1 punto y malla 4 × 1 × 1 da una matriz **singular** (los relojes de arena no tienen quién los frene); con 8 × 2 × 1 da 132.8 % (demasiado blando). Por eso los H8 reducidos de los programas llevan **estabilización** (SSPbrick en OpenSees).

## 6 · El mismo voladizo, como sólido
#dibujo("Voladizo sólido: L = 4 m, h = 0.5 m, b = 0.2 m, E = 25 GPa, ν = 0.2; P = 10 kN (cortante parabólico en la cara x = L). Malla 4 × 1 × 1", ud = m, escala = auto, cotas = m, alto = 45)
#  achurado([-0.3, 0, 0, -0.3], [-0.45, -0.45, 0.6, 0.6], "concreto")
#  poligono(0, -0.25, 4, -0.25, 4, 0.25, 0, 0.25, "gruesa")
#  poligono(0, 0.25, 4, 0.25, 4.15, 0.4, 0.15, 0.4, "gruesa")
#  poligono(4, -0.25, 4.15, -0.1, 4.15, 0.4, 4, 0.25, "gruesa")
#  linea(1, -0.25, 1, 0.25, "fina")
#  linea(2, -0.25, 2, 0.25, "fina")
#  linea(3, -0.25, 3, 0.25, "fina")
#  flecha(4.07, 1, 4.07, 0.35, "gruesa rojo")
#  texto(4.3, 1.05, "P", 2.6, "c")
#  cota(0, -0.6, 4, -0.6, 0, "L = 4 m")
#fin
#: Referencia: H20 de 32 × 4 × 2 = **4.13043 mm** (un poco menos que los 4.13736 de la hoja 204 en tensión plana: el sólido es un poco más rígido). Flecha en la punta, en mm. Python = Hekatan OpenSees con la misma malla nudo a nudo: **stdBrick, 20NodeBrick y FourNodeTetrahedron iguales hasta 2e−8 mm**. Los tetraedros parten cada celda en 6 (Kuhn).
w_a = [1.51773, 2.87051] 'H8 [mm] (4 × 1 × 1 y 8 × 2 × 1)
w_b = [36.7, 69.5] '% H8
w_c = [4.06005, 4.11465] 'H20 [mm]
w_d = [98.3, 99.6] '% H20
w_e = [0.53144, 1.50025] 'T4 [mm]
w_f = [12.9, 36.3] '% T4
w_g = [4.03447, 4.10871] 'T10 [mm]
w_h = [97.7, 99.5] '% T10
#tabla("Malla","H8 [mm]:4","%:1","H20 [mm]:4","%:1","T4 [mm]:4","%:1","T10 [mm]:4","%:1")({"4 × 1 × 1","8 × 2 × 1"}; w_a; w_b; w_c; w_d; w_e; w_f; w_g; w_h)
#: Lo mismo que en 2D: **los lineales (H8, T4) se traban en flexión**; los cuadráticos (H20, T10) llegan al 98-99 %. El H8 da casi lo mismo que el Q4 (36.7 % contra 36.9 %): es el mismo problema, ξ² no cabe adentro.
#: **Un hallazgo al comparar:** el TenNodeTetrahedron de esta DLL de OpenSees da **exactamente 6 veces** la flecha (24.2068 mm en vez de 4.03447). En su código, el peso de Gauss es 1/24 (línea 228) y además divide det J entre 6 (línea 2146): integra V/6, así que su K sale 6 veces menor. Corregido ese factor, coincide con Python.
#: % de la flecha correcta, malla 4 × 1 × 1 y 8 × 2 × 1 (pasa el cursor):
#hide
c_H8 = [1, 36.7; 2, 69.5]
c_H20 = [1, 98.3; 2, 99.6]
c_T4 = [1, 12.9; 2, 36.3]
c_T10 = [1, 97.7; 2, 99.5]
#show
#fplot(H8 = c_H8, H20 = c_H20, T4 = c_T4, T10 = c_T10, correcto = 100 + 0*x, [0.8 2.2])
#: **Bloqueo volumétrico** (ν → 0.5, malla 8 × 2 × 1, % de la referencia H20 fina con el mismo ν):
w_i = [69.3, 45.7, 6.8] '% H8
w_j = [99.0, 93.2, 91.8] '% H20
w_k = [35.4, 10.5, 2.6] '% T4
w_l = [98.7, 92.0, 89.2] '% T10
#tabla("ν","H8 %:1","H20 %:1","T4 %:1","T10 %:1")({"0.3","0.49","0.4999"}; w_i; w_j; w_k; w_l)

## 7 · ¿Cuándo uso cada uno?
#tabla("Elemento","Gauss","lo bueno","lo malo","úsalo en")({"H8","H20","H27","T4","T10"}; {"2 × 2 × 2","3 × 3 × 3 (o 2³ reducido)","3 × 3 × 3","1","4"}; {"simple, barato","flexión casi exacta, caras curvas","el más completo","malla cualquier volumen","malla cualquier volumen y es exacto"}; {"se traba en flexión; bloqueo con ν → 0.5; 1 punto: 12 relojes de arena","más nudos","27 nudos por elemento","muy rígido: casi nunca solo","más caro que el T4"}; {"bloques macizos con malla fina; o B-barra / SSP","zapatas, cabezales, suelo 3D","suelos casi incompresibles","relleno; nunca en flexión","geometrías complicadas (malladores automáticos)"})
#: **Resumen:** en 3D se repite todo lo del 2D: base → C → C⁻¹ → N, ΣN = 1 gratis, el lineal no cabe ξ² y se traba, el cuadrático llega con pocos elementos, y la integración reducida pide estabilización.
#> Fuentes: O. C. Zienkiewicz, R. L. Taylor, *The Finite Element Method*, vol. 1, cap. 6 (elementos 3D, serendípitos y Lagrange) y cap. 10 (integración reducida); K. J. Bathe, *Finite Element Procedures*, cap. 5; código de OpenSees: SRC/element/tetrahedron/TenNodeTetrahedron.cpp (l. 228 y 2146). Números: hekatan-school/VIDEOS/01_elementos_finitos_funciones_de_forma/ff_h8_manim/juez (Python y Hekatan OpenSees).
