# Talud por elementos finitos: ¿hasta dónde es lineal y desde dónde es no lineal? Griffiths y Lane (1999) contra GEO5, Tellus y XSLOPE
#numerico

## 1 · El talud
#: Ejemplo 2 de Griffiths y Lane (1999, Géotechnique 49(3)), el mismo que valida XSLOPE: cara 2:1 de H = 15.24 m (50 ft) sobre una cimentación de H/2, suelo homogéneo con c = 15 kPa y φ = 20°, sin agua. Peso propio solamente.
#dibujo("El talud de Griffiths y Lane y el círculo crítico de Bishop", ud = m, escala = auto, cotas = m, alto = 120)
#  achurado([0, 91.44, 91.44, 60.96, 30.48, 0], [0, 0, 22.86, 22.86, 7.62, 7.62], "suelo")
#  poligono(0, 0, 91.44, 0, 91.44, 22.86, 60.96, 22.86, 30.48, 7.62, 0, 7.62, "gruesa")
#  polilinea([29.68, 31.83, 33.98, 36.12, 38.27, 40.42, 42.56, 44.71, 46.86, 49.00, 51.15, 53.29, 55.44, 57.59, 59.73, 61.88, 64.03], [7.62, 7.22, 6.97, 6.86, 6.90, 7.09, 7.43, 7.92, 8.58, 9.41, 10.43, 11.65, 13.12, 14.87, 16.98, 19.57, 22.86], "gruesa rojo")
#  cota(93.5, 7.62, 93.5, 22.86, 0, "H = 15.24 m")
#  cota(93.5, 0, 93.5, 7.62, 0, "H/2")
#  cota(30.48, 24.5, 60.96, 24.5, 0, "2H (cara 2:1)")
#  texto(45, 3, "c = 15 kPa · φ = 20° · γ = 19.64 kN/m³", 2.6, "c")
#  texto(47, 9.5, "superficie de falla", 2.2, "c")
#fin

## 2 · Los elementos finitos del talud, paso a paso (símbolos primero)
#: Hekatan Geotechnic (y GEO5) cortan el talud en triángulos de 6 nudos (T6): 3 esquinas y 3 nudos a la mitad de cada lado. Dentro del triángulo el desplazamiento se interpola con las FUNCIONES DE FORMA, escritas en coordenadas naturales ξ, η (el triángulo de referencia con esquinas (0,0), (1,0), (0,1)):
N_1 = Simplify{(1 - xi - eta)*(2*(1 - xi - eta) - 1)}
N_2 = Simplify{xi*(2*xi - 1)}
N_3 = Simplify{eta*(2*eta - 1)}
N_4 = Simplify{4*xi*(1 - xi - eta)}
N_5 = Simplify{4*xi*eta}
N_6 = Simplify{4*eta*(1 - xi - eta)}
#: Suman 1 en todo punto (el triángulo se mueve entero sin deformarse si todos los nudos se mueven igual):
S_N = Simplify{(1 - xi - eta)*(2*(1 - xi - eta) - 1) + xi*(2*xi - 1) + eta*(2*eta - 1) + 4*xi*(1 - xi - eta) + 4*xi*eta + 4*eta*(1 - xi - eta)}
#: Las derivadas (con ellas sale la deformación ε = B·u):
dN1_dxi = Simplify{Partial{(1 - xi - eta)*(2*(1 - xi - eta) - 1) @ xi}}
dN4_dxi = Simplify{Partial{4*xi*(1 - xi - eta) @ xi}}
dN4_deta = Simplify{Partial{4*xi*(1 - xi - eta) @ eta}}
#: **3D:** la función de forma de una esquina (N₁) y la de un nudo del medio (N₄): valen 1 en su nudo y 0 en los demás.
N1s(x, y) = max((1 - x - y)·(2·(1 - x - y) - 1), -0.2)·(x + y <= 1)
N4s(x, y) = max(4·x·(1 - x - y), 0)
#surf(N4s(x, y), [0 1], [0 1])
#contourf(N1s(x, y), [0 1], [0 1])
#: **El Jacobiano.** x = Σ Nᵢ·xᵢ y y = Σ Nᵢ·yᵢ; con lados rectos el T6 se comporta como el triángulo de sus esquinas y
J_11 = Simplify{x_2 - x_1}
J_12 = Simplify{y_2 - y_1}
J_21 = Simplify{x_3 - x_1}
J_22 = Simplify{y_3 - y_1}
det_J = Simplify{(x_2 - x_1)*(y_3 - y_1) - (x_3 - x_1)*(y_2 - y_1)}
#: det J = 2·(área del triángulo). Las derivadas reales salen de las naturales con la inversa: [∂N/∂x; ∂N/∂y] = J⁻¹·[∂N/∂ξ; ∂N/∂η].
#: **La matriz constitutiva elástica** en deformación plana (la parte LINEAL):
D_11 = Simplify{E*(1 - nu)/((1 + nu)*(1 - 2*nu))}
D_12 = Simplify{E*nu/((1 + nu)*(1 - 2*nu))}
D_33 = Simplify{E/(2*(1 + nu))}
#: **El suelo (la parte NO LINEAL): Drucker-Prager de GEO5**, f = J + α·I₁ − k, con
a_DP = Simplify{2*sin(phi)/(sqrt(3)*(3 + sin(phi)))}
k_DP = Simplify{6*c*cos(phi)/(sqrt(3)*(3 + sin(phi)))}
#: Si en un punto de Gauss f > 0, el esfuerzo se devuelve a la superficie de fluencia (retorno radial, ψ = 0): λ = f/G y el desviador baja a J − G·λ:
J_n = Simplify{J - G*(J + alpha*I_1 - k)/G}
#: **Y el equilibrio, con Newton-Raphson:** K_T·Δu = F_ext − F_int(u); se repite hasta que Δu es despreciable. En lineal K_T = K y basta UNA vez.
du_N = Simplify{(F_ext - F_int)/K_T}
#: **Los números, en el triángulo del pie del talud** (elemento 266 de la malla de Geotechnic, 2361 T6 y 4902 nudos):
x_1 = 32.3136 'esquina 1 [m]
y_1 = 6.9934
x_2 = 31.5686 'esquina 2 [m]
y_2 = 8.1643
x_3 = 31.1317 'esquina 3 [m]
y_3 = 6.5756
dJ = (x_2 - x_1)·(y_3 - y_1) - (x_3 - x_1)·(y_2 - y_1) 'det J [m²] (> 0: nudos antihorarios)
A_e = dJ/2 'área del triángulo [m²]
#: Integración con 3 puntos de Gauss (ξ, η) = (1/6, 1/6), (2/3, 1/6), (1/6, 2/3), peso 1/6 cada uno: ∫dA = Σ wᵢ·det J
A_g = (1/6 + 1/6 + 1/6)·dJ 'área por Gauss [m²] (= A_e)
W_e = 19.6363·A_e 'peso del triángulo [kN/m]
W_m = W_e/3 'carga en cada nudo del MEDIO [kN/m] (las esquinas llevan 0 en el T6)
a_1 = 2·sin(20·pi/180)/(sqrt(3)·(3 + sin(20·pi/180))) 'α de Drucker-Prager con φ = 20°
k_1 = 6·14.9625·cos(20·pi/180)/(sqrt(3)·(3 + sin(20·pi/180))) 'k con c = 15 kPa [kPa]
#: **La iteración de Newton del solver** (registro real de Geotechnic, talud entero): DNorm = |Δu|/|u| en cada iteración. Con SRF = 1.4069 converge en 8 iteraciones; con SRF = 1.4439 no baja y diverge: ahí está la falla.
i_N = [1, 2, 3, 4, 5, 6, 7, 8] 'iteración
d_ok = [1, 0.2924, 0.09952, 0.02609, 0.01418, 0.003741, 0.0004525, 0.0005802] 'DNorm con SRF = 1.4069 (converge)
#tabla("Iteración:0","DNorm, SRF = 1.4069:6")(i_N; d_ok)
#: **2D:** log₁₀(DNorm) por iteración: con 1.4069 baja hasta la tolerancia; con 1.4439 se estanca (el paso de Newton se recorta, η < 1, y no converge).
#fplot(converge_14069 = [1 0; 2 -0.534; 3 -1.002; 4 -1.584; 5 -1.848; 6 -2.427; 7 -3.344; 8 -3.236], diverge_14439 = [1 0; 2 -0.517; 3 -0.927; 4 -1.293; 5 -1.587], [1 8])

## 3 · Parte LINEAL: ¿algún punto llega a su resistencia?
#: En un análisis lineal (como SAP2000 con sólidos) el suelo es elástico: los esfuerzos salen de K·u = F y nadie revisa si el suelo los aguanta. Para saber HASTA DÓNDE vale lo lineal se compara, en cada punto, el corte que actúa (el radio R del círculo de Mohr) con el que el suelo resiste según Mohr-Coulomb:
r_MC = Simplify{R/(c*cos(phi) + s*sin(phi))}
#: con s = (σ₁ + σ₃)/2 el centro del círculo (compresión positiva). Mientras r < 1 en todos los puntos, lo lineal vale. Donde r = 1 el punto plastifica.
#: **Lejos de la cara (terreno horizontal), con el peso propio:** σ_v = γ·z y, elástico en deformación plana, σ_h = K₀·σ_v con K₀ = ν/(1 − ν):
K_0s = Simplify{nu/(1 - nu)}
R_z = Simplify{(1 - K_0)*gamma*z/2}
s_z = Simplify{(1 + K_0)*gamma*z/2}
r_z = Simplify{(1 - K_0)*gamma*z/(2*c*cos(phi) + (1 + K_0)*gamma*z*sin(phi))}
#: **Más símbolos, antes de los números.** La resistencia dividida por F (método de reducción de resistencia, sección 4):
c_F = Simplify{c/F}
tan_phi_F = Simplify{sin(phi)/(cos(phi)*F)}
#: y lo que resiste una dovela en el método de Bishop (sección 4), con b el ancho, W el peso y α el ángulo de su base:
M_res = Simplify{(c*b + W*sin(phi)/cos(phi))/(cos(alpha) + sin(alpha)*sin(phi)/(cos(phi)*FS))}
#: **Números del talud:**
H = 15.24 'altura del talud [m]
c = 14.9625 'cohesión [kPa]
phi = 20·pi/180 'ángulo de fricción [rad]
gamma = 19.6363 'peso específico [kN/m³]
nu = 0.3 'Poisson
E = 100000 'módulo [kPa] (no cambia el factor de seguridad)
#: Muy hondo (z → ∞) la cohesión ya no cuenta y r → (1 − K₀)/((1 + K₀)·sin φ). Ese límite es 1 exactamente cuando K₀ = K_a = (1 − sin φ)/(1 + sin φ), el empuje activo de Rankine:
K_a = (1 - sin(phi))/(1 + sin(phi)) 'activo de Rankine
K_0 = nu/(1 - nu) 'elástico: está apenas debajo de K_a
r_inf = (1 - K_0)/((1 + K_0)·sin(phi)) 'r muy hondo
r(z) = (1 - K_0)·gamma·z/(2·c·cos(phi) + (1 + K_0)·gamma·z·sin(phi))
r_5 = r(5) 'a 5 m
r_10 = r(10) 'a 10 m
r_H = r(H) 'a 15.24 m
#: **2D:** r contra la profundidad. Con la resistencia completa (F = 1) no llega a 1 en la altura del talud: el peso propio es casi todo LINEAL. Si la resistencia se divide por F = 1.2, la base ya pasa de 1:
#fplot(r_F1 = (1 - K_0)·gamma·x/(2·c·cos(phi) + (1 + K_0)·gamma·x·sin(phi)), r_F12 = (1 - K_0)·gamma·x/(2·c/1.2·cos(atan(tan(phi)/1.2)) + (1 + K_0)·gamma·x·sin(atan(tan(phi)/1.2))), limite = 1, [0 23])
#: Hekatan Geotechnic lo confirma en el talud entero: con el peso propio (F = 1) la deformación plástica máxima es 0.014 % y τ/τ_res ≤ 1. **El talud, solo con su peso, se puede calcular LINEAL.**

## 4 · Parte NO LINEAL: reducir la resistencia hasta que falle
#: El factor de seguridad no sale de un cálculo lineal: hay que buscar CUÁNTO hay que debilitar el suelo para que falle. Es el método de reducción de resistencia (Griffiths y Lane 1999; PLAXIS lo llama «Safety», ΣMsf; GEO5 «reducción c-φ»): se divide la resistencia por F y se calcula otra vez, con Newton-Raphson, hasta que no converge.
#: (la resistencia dividida por F, c/F y tan φ/F, está en la sección 2 con los demás símbolos)
#: **3D:** la razón r con la resistencia dividida por F, según la profundidad z (eje x) y F (eje y). La zona sobre 1 (que plastifica) crece con F:
r_ZF(x, y) = min((1 - K_0)·gamma·x/(2·c/y·cos(atan(tan(phi)/y)) + (1 + K_0)·gamma·x·sin(atan(tan(phi)/y))), 1.6)
#surf(r_ZF(x, y), [0.5 23], [1 1.6])
#contourf(r_ZF(x, y), [0.5 23], [1 1.6])
#: Pero que un punto plastifique NO es la falla: el suelo de abajo está confinado y pasa la carga a sus vecinos. La falla es cuando la zona plástica une el PIE con la CORONA (un mecanismo). Eso se ve en el desplazamiento: cuánto se mueve el talud al pasar de F = 1 a F.
#: **Hekatan Geotechnic** (Drucker-Prager, ψ = 0, malla T6 de 1.2 m, cada F es un cálculo con c/F y tanφ/F; Δu = |u(F) − u(1)| máximo):
F_v = [1, 1.1, 1.2, 1.3, 1.35, 1.38, 1.4, 1.41, 1.42] 'factor de reducción
du_v = [0, 2.75, 6.25, 10.88, 14.15, 16.79, 19.15, 20.57, 22.38] 'Δu máximo [mm]
#tabla("F:2","Δu [mm]:2")(F_v; du_v)
#: **2D: la curva NO lineal.** Un cálculo lineal da Δu = 0 para todo F (no sabe que el suelo tiene resistencia). El no lineal sube despacio y luego se dispara: con F = 1.43 Newton ya no converge. Ese F es el factor de seguridad.
#fplot(no_lineal = [1 0; 1.1 2.75; 1.2 6.25; 1.3 10.88; 1.35 14.15; 1.38 16.79; 1.4 19.15; 1.41 20.57; 1.42 22.38], lineal = 0, FS = [1.425 0; 1.425 25], [1 1.45])
FS_hk = 1.425 'Hekatan Geotechnic, Drucker-Prager ψ = 0

## 5 · Equilibrio límite: Bishop (como XSLOPE y GEO5 Slope Stability)
#: Sin elementos finitos: se supone un círculo, se corta en dovelas y se iguala momentos. Para cada dovela de ancho b, peso W y ángulo α en la base:
#: (M_res, lo que resiste UNA dovela, está escrito con símbolos en la sección 2)
#: es lo que resiste UNA dovela; FS = (suma de M_res de todas las dovelas) / (suma de W·sin α).
#: FS aparece a los dos lados: se itera. El círculo crítico (el del dibujo) lo busca Hekatan Geotechnic:
FS_bishop = 1.377 'Bishop, círculo crítico (36.58, 38.40), R = 31.55 m

## 6 · Los mismos números en otros programas
#: Mismo talud, malla de cada programa. GEO5 FEM con su propia malla y Drucker-Prager; Tellus (solo su solver, sin conexión a internet) con Mohr-Coulomb y triángulos de 15 nudos; XSLOPE y Griffiths y Lane publicados.
FS_geo5 = 1.44 'GEO5 2024 FEM, Drucker-Prager ψ = 0
FS_tellus = 1.349 'Tellus 0.1.4, Mohr-Coulomb ψ = 0, gravedad + Safety
FS_xslope = 1.35 'XSLOPE, elementos finitos (bisección), Mohr-Coulomb ψ = 0
FS_gl = 1.40 'Griffiths y Lane 1999, elementos finitos
d_geo5 = 100·(FS_hk - FS_geo5)/FS_geo5 'Hekatan contra GEO5 [%]
#tabla("Programa","Modelo","FS:3")({"Hekatan Geotechnic","GEO5 2024 FEM","Tellus 0.1.4","XSLOPE","Griffiths y Lane","Bishop (equilibrio límite)"}; {"Drucker-Prager ψ=0","Drucker-Prager ψ=0","Mohr-Coulomb ψ=0","Mohr-Coulomb ψ=0","Mohr-Coulomb","círculo, dovelas"}; [FS_hk, FS_geo5, FS_tellus, FS_xslope, FS_gl, FS_bishop])
#: Drucker-Prager (cono redondo) da algo más que Mohr-Coulomb (cono hexagonal): por eso GEO5 y Hekatan (1.44 / 1.425) quedan sobre Tellus y XSLOPE (1.35). Con el MISMO modelo la diferencia es de 1 %.

## 7 · Lineal o no lineal
#: • **Lineal** (SAP2000, elástico): sirve para saber CUÁNTO se deforma el talud con su peso, mientras ningún punto llegue a su resistencia (r < 1). Aquí vale: r máximo ≈ 0.98 en la base.
#: • **No lineal** (Mohr-Coulomb / Drucker-Prager + Newton-Raphson): es la única forma de saber SI SE CAE. El factor de seguridad es el F con el que el cálculo ya no encuentra equilibrio: la banda plástica une el pie con la corona y el desplazamiento se dispara.
#: Fuentes: Griffiths y Lane (1999); manual de PLAXIS 2D, Reference §7.4.5 (Safety, ΣMsf); ayuda de GEO5 FEM (estabilidad por reducción c-φ); XSLOPE (Jones y Williams 2026, SoftwareX 36).
