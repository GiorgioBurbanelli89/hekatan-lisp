# Un punto de Gauss plástico de GeoFEM: peso propio, predictor elástico y retorno de Drucker-Prager, contra GEO5
#numerico

#: **Qué se hace.** Se sigue **un solo punto de Gauss** del talud Demo04 de GEO5 FEM durante las **dos primeras iteraciones de Newton** de la etapa 1 (peso propio, sin reducir la resistencia): la deformación que le llega, la tensión de prueba (predictor elástico), la función de fluencia de Drucker-Prager, el retorno a la superficie y la tangente algorítmica que va a la matriz de rigidez de la iteración siguiente.
#: **El punto.** El punto de Gauss 1 (el centroide) del elemento 36 de la malla, el triángulo de la hoja 132: suelo 1, en (22.18, −8.42) m, bajo el borde de la coronación. Es de los primeros que plastifican: en la iteración 1 ya se sale de la superficie de fluencia, como 154 puntos más de los 2009 del talud.
#: **De dónde sale el algoritmo.** No es de libro: está **extraído del binario** de GEO5 (FRGeoFEM.exe, módulo druckerprager_sh.cpp, decompilado el 15-ago-2026: ingenieria-inversa/hekatan-geo5-bridge/EXTRAIDO_GeoFEM_DP_returnmap.md). FUN_005bfa20 fija el ajuste de **extensión** del cono, FUN_005bd2b0 el retorno y FUN_005bc220 la tangente. El solver de Hekatan Geotechnic es el port de eso.
#: **Juez.** Los números que GEO5 tenía en memoria en este punto: la deformación y la tensión que devuelve su rutina FUN_005bb940, volcadas con Frida a 17 cifras el 4-sep-2026 (dp_dump3_e1.txt). La tangente, que GEO5 no vuelca, se compara con la de Geotechnic.
#: **Unidades.** kPa, deformaciones en µε (10⁻⁶). Compresión negativa, como en GEO5.

## 1 · El material del punto (suelo 1 de la Demo04)

E = 130347 'módulo de elasticidad [kPa]
ν = 0.3 'coeficiente de Poisson
φ = 22.7 'ángulo de rozamiento interno [°]
c = 9 'cohesión [kPa]
γ = 18 'peso específico [kN/m³]
#: La dilatancia es ψ = 0 (dato de la Demo04): al plastificar el suelo no cambia de volumen. Eso hará el retorno muy simple.
G = E/(2*(1 + ν)) 'módulo de corte [kPa]
K_v = E/(3*(1 - 2*ν)) 'módulo volumétrico [kPa]
#: La matriz elástica de **deformación plana** con las 4 componentes que guarda GeoFEM (σ_{x}, σ_{y}, σ_{z}, τ_{xy}); la tercera deformación, ε_{z}, es siempre 0, pero σ_{z} no:
f_D = E/((1 + ν)*(1 - 2*ν)) 'factor de la matriz [kPa]
D_e = f_D*[1 - ν, ν, ν, 0; ν, 1 - ν, ν, 0; ν, ν, 1 - ν, 0; 0, 0, 0, (1 - 2*ν)/2] 'matriz elástica 4 × 4 de deformación plana [kPa]

## 2 · El estado inicial: GeoFEM arranca de tensión CERO

#: En la reducción de resistencia de la Demo04, GeoFEM **no** impone un estado geostático (σ_{v} = γ·h, σ_{h} = K₀·σ_{v}) antes de empezar: arranca con σ = 0 y aplica **todo el peso propio** de golpe; la tensión inicial sale de resolver el talud. Así lo hace el binario (medido el 3-sep-2026 en el «course of analysis» de GEO5) y así lo copia Geotechnic.
#: Como orden de magnitud, la columna de suelo sobre el punto (todo suelo 1, hasta la coronación a −2.50 m) daría:
h = 8.41545 - 2.495 'profundidad del punto bajo la coronación [m]
σ_v0 = -γ*h 'tensión vertical de una columna γ·h [kPa]
K_0 = ν/(1 - ν) 'coeficiente de empuje en reposo elástico (deformación lateral nula)
σ_h0 = K_0*σ_v0 'tensión horizontal con K₀ [kPa]
#: Más abajo se ve que el talud, con su ladera a la izquierda, da algo menos: parte del peso se va hacia la ladera y el corte τ_{xy} ya no es cero.

## 3 · La deformación que le llega al punto (iteración 1)

#: En la iteración 1 la matriz es la elástica y la carga, todo el peso: los desplazamientos son los del talud **elástico**. La hoja 132 comprobó que ε = B·u en este punto es lo que GEO5 tiene en memoria. Se toma el valor de GEO5 (en µε, orden ε_{x}, ε_{y}, ε_{z}, γ_{xy}):
Δε_1 = [33.601130614284883; -546.07359502585953; 0; -123.71389243874369]/1000000 'incremento de deformación de GEO5, iteración 1

## 4 · El predictor elástico

#: Se supone que todo es elástico: σ de prueba = σ anterior + D_{e}·Δε. Como se parte de cero:
σ_tr = D_e*Δε_1 'tensión de prueba: σ_x, σ_y, σ_z, τ_xy [kPa]
#: **Los invariantes.** I₁ = σ_{x} + σ_{y} + σ_{z} (primer invariante), σ_{m} = I₁/3 (tensión media) y la parte desviadora s = σ − σ_{m}:
I_1 = σ_tr(1) + σ_tr(2) + σ_tr(3) 'primer invariante [kPa]
σ_m = I_1/3 'tensión media [kPa]
s_d = σ_tr - σ_m*[1; 1; 1; 0] 'tensión desviadora [kPa]
#: J es la raíz del segundo invariante del desviador. Con 4 componentes, τ_{xy} cuenta dos veces (τ_{xy} y τ_{yx}):
J_tr = sqrt(0.5*(s_d(1)^2 + s_d(2)^2 + s_d(3)^2) + s_d(4)^2) 'J = √J₂ de la prueba [kPa]

## 5 · La superficie de Drucker-Prager de GeoFEM

#: El binario (FUN_005bfa20) escribe la función de fluencia así:
#: f = J + M_{φ}·(σ_{m} − c·cot φ),     M_{φ} = 2·√3·sen φ/(3 + sen φ)
#: con el **ajuste de extensión** (el cono pasa por los vértices de extensión del hexágono de Mohr-Coulomb; el de compresión llevaría 3 − sen φ). Desarrollando, es lo mismo que la forma de Geotechnic f = J + α·I₁ − k:
#: α = M_{φ}/3 = 2·sen φ/(√3·(3 + sen φ)),     k = M_{φ}·c·cot φ = 6·c·cos φ/(√3·(3 + sen φ))
s_φ = sin(φ*pi/180) 'seno de φ
α = 2*s_φ/(sqrt(3)*(3 + s_φ)) 'pendiente del cono
k = 6*c*cos(φ*pi/180)/(sqrt(3)*(3 + s_φ)) 'ordenada del cono, J con I₁ = 0 [kPa]
f_tr = J_tr + α*I_1 - k 'función de fluencia en la prueba [kPa]
#: **f > 0: el punto se sale del cono.** La prueba no es admisible y hay que **devolverla** a la superficie.
#: **¿Cono o vértice?** El vértice del cono está en σ_{m} = c·cot φ (tracción). Con ψ = 0 el criterio del binario (FUN_005bf160) se reduce a: si σ_{m} < c·cot φ, retorno al cono.
σ_ap = c/tan(φ*pi/180) 'tensión media del vértice [kPa]
#: σ_{m} = −55.7 kPa (compresión) queda muy lejos del vértice (+21.5 kPa): **retorno al cono**.

## 6 · El retorno (return mapping) de GeoFEM

#: El binario resuelve un Newton local en [λ, c, sen φ, sen ψ]; sin endurecimiento y con ψ = 0 ese Newton cierra en un paso y queda:
#: σ_{m} no cambia (ψ = 0: sin cambio de volumen),   J_{nuevo} = J_{tr} − G·λ,   λ = f_{tr}/G
#: Es decir, el desviador se **encoge** sin girar (retorno **radial**) hasta tocar el cono:
λ = f_tr/G 'multiplicador plástico
J_n = J_tr - G*λ 'J después del retorno [kPa]
β = J_n/J_tr 'factor con que se encoge el desviador
σ_1 = σ_m*[1; 1; 1; 0] + β*s_d 'tensión devuelta, iteración 1 [kPa]
#hide
f_1 = round(J_n + α*I_1 - k, 10)
#show
#: Comprobación: después del retorno f = **@{f_1} kPa** (a 10 decimales): el punto queda justo sobre el cono.
#: **La tensión de GEO5** en este punto, al final de la iteración 1 (su rutina devuelve σ_{x}, σ_{y}, τ_{xy}, σ_{z}; aquí reordenada):
σ_g1 = [-36.859652803705295; -90.187632607799515; -39.950835385134056; -5.6906155000751300] 'σ de GEO5, iteración 1 [kPa]
#hide
d_1 = max(abs(σ_1 - σ_g1))
r_1 = round(d_1, 8)
#show
#: Mayor diferencia con GEO5: **@{r_1} kPa** (a 8 decimales).
#: **Lectura.** El retorno baja J de 33.21 a 30.47 kPa sin tocar σ_{m}: el punto pierde 2.74 kPa de corte, y ese corte que «no cabe» en el suelo 1 se lo tiene que llevar el resto del talud en la iteración 2.

#dibujo("El punto en el plano (−σm, J): cono de Drucker-Prager de GeoFEM, prueba y retorno (ejes en kPa/10)", ud = m, escala = auto, alto = 220)
#  linea(-2.5, 0, 8.5, 0, "media")
#  linea(0, 0, 0, 4.6, "media")
#  texto(8.0, -0.35, "−σm", 3, "c")
#  texto(-0.6, 4.4, "J", 3, "c")
#  linea(-σ_ap/10, 0, 8.5, (k + 3*α*85)/10, "gruesa rojo")
#  texto(6.2, 3.9, "cono f = 0 (c = 9, φ = 22.7°)", 2.6, "c", estilo = "rojo")
#  circulo(-σ_m/10, J_tr/10, 0.08, "azul relleno")
#  texto(-σ_m/10 + 1.1, J_tr/10 + 0.15, "prueba it 1", 2.4, "c", estilo = "azul")
#  flecha(-σ_m/10, J_tr/10, -σ_m/10, J_n/10, "azul")
#  circulo(-σ_m/10, J_n/10, 0.08, "verde relleno")
#  texto(-σ_m/10 - 1.3, J_n/10 - 0.2, "devuelto it 1", 2.4, "c", estilo = "verde")
#  circulo(-σ_ap/10, 0, 0.08, "negro relleno")
#  texto(-σ_ap/10, -0.35, "vértice", 2.4, "c")
#  texto(-σ_m/10, -0.35, "55.7", 2.4, "c")
#fin
#: Con ψ = 0 el retorno es **vertical** en este plano (el zoom está al final de la sección 8).

## 7 · La tangente algorítmica (la D que va a la K de la iteración 2)

#: Después del retorno, la matriz con que GeoFEM arma la rigidez de este punto ya no es D_{e}: es la **tangente consistente** con el retorno (FUN_005bc220). Con el desviador devuelto s, su J, la dirección w = s/(2·J) (con 2·τ_{xy} en la cuarta) y n = w + α·[1; 1; 1; 0]:
p_1 = (σ_1(1) + σ_1(2) + σ_1(3))/3 'tensión media devuelta [kPa]
s_1 = σ_1 - p_1*[1; 1; 1; 0] 'desviador devuelto [kPa]
J_1 = sqrt(0.5*(s_1(1)^2 + s_1(2)^2 + s_1(3)^2) + s_1(4)^2) 'J devuelto [kPa]
w_1 = [s_1(1); s_1(2); s_1(3); 2*s_1(4)]/(2*J_1) 'dirección del flujo (ψ = 0: solo desviadora)
n_1 = w_1 + α*[1; 1; 1; 0] 'normal al cono
#: La rigidez «encogida» Ξ = K·(1⊗1) + β·2G·P_{dev}, con P_{dev} el proyector desviador y la cuarta diagonal β·G (corte de ingeniería):
P_d = [2/3, -1/3, -1/3, 0; -1/3, 2/3, -1/3, 0; -1/3, -1/3, 2/3, 0; 0, 0, 0, 1/2] 'proyector desviador (cuarta fila para γ_xy)
U_1 = [1, 1, 1, 0; 1, 1, 1, 0; 1, 1, 1, 0; 0, 0, 0, 0] 'producto 1⊗1
Ξ = K_v*U_1 + β*2*G*P_d 'rigidez elástica encogida [kPa]
#: y la tangente **no simétrica** (la normal n y la dirección de flujo w no son iguales porque ψ ≠ φ):
D_ep = Ξ - (Ξ*w_1)*(transpose(n_1)*Ξ)/(transpose(n_1)*Ξ*w_1) 'tangente algorítmica [kPa]
#: La de Geotechnic para este punto y esta iteración:
D_ref = [125965.91495404902, 83649.72050275785, 36849.26571169705, 5301.3609180544245; 158701.88377211674, 159503.75815581746, 153415.7490486464, -9731.343717318105; 41199.70127383428, 82714.02134142473, 135602.48523965658, 4429.982799263682; 13310.15864831885, -1722.545987053678, 12438.780529528109, 44394.05680741031] 'tangente de Geotechnic [kPa]
#hide
d_D = max(max(abs(D_ep - D_ref)))
r_D = round(d_D, 6)
a_D = round(max(max(abs(D_ep - transpose(D_ep)))), 1)
#show
#: Mayor diferencia con Geotechnic: **@{r_D} kPa** (a 6 decimales, sobre términos de 160 000). La asimetría de D_{ep} es de **@{a_D} kPa**: la K de la iteración 2 deja de ser simétrica, y por eso GEO5 (y Geotechnic) la factoriza con una LU en banda no simétrica.

## 8 · La iteración 2: desde la tensión acumulada

#: En la iteración 2 el punto ya no parte de cero: parte de σ₁. Le llega un incremento pequeño (el talud corrige el desequilibrio que dejó la iteración 1). De GEO5, en µε:
Δε_2 = [-1.6283907571145694; -28.710233069497412; 0; -30.788147477639331]/1000000 'incremento de deformación de GEO5, iteración 2
σ_tr2 = σ_1 + D_e*Δε_2 'nueva prueba [kPa]
I_2 = σ_tr2(1) + σ_tr2(2) + σ_tr2(3) 'primer invariante [kPa]
s_2 = σ_tr2 - I_2/3*[1; 1; 1; 0] 'desviador de la prueba [kPa]
J_tr2 = sqrt(0.5*(s_2(1)^2 + s_2(2)^2 + s_2(3)^2) + s_2(4)^2) 'J de la prueba [kPa]
f_tr2 = J_tr2 + α*I_2 - k 'fluencia en la prueba [kPa]
#: Vuelve a salirse (f > 0) y vuelve el mismo retorno radial:
β_2 = (J_tr2 - f_tr2)/J_tr2 'factor del desviador
σ_2 = I_2/3*[1; 1; 1; 0] + β_2*s_2 'tensión devuelta, iteración 2 [kPa]
σ_g2 = [-39.663123089987600; -94.683769237691322; -42.537599968778423; -7.1021148426813845] 'σ de GEO5, iteración 2 [kPa]
#hide
d_2 = max(abs(σ_2 - σ_g2))
r_2 = round(d_2, 8)
#show
#: Mayor diferencia con GEO5: **@{r_2} kPa** (a 8 decimales). Que Δε₂ de GEO5 sea lo que es depende de la K tangente de toda la iteración 2; como el σ₂ que sale aquí con él es el de GEO5, la tangente del paso 7 está bien también por ese lado.

#: **De cerca**, las dos iteraciones en el plano (−σ_{m}, J). Con ψ = 0 el retorno es **vertical**: baja J a σ_{m} constante, hasta la recta roja:
#dibujo("Zoom: −σm de 52 a 62 kPa, J de 29 a 34 kPa (ejes en kPa, origen desplazado)", ud = m, escala = auto, alto = 200)
#  linea(0, 0, 10, 0, "media")
#  linea(0, 0, 0, 5, "media")
#  texto(9.5, -0.3, "−σm", 3, "c")
#  texto(0.4, 5, "J", 3, "c")
#  texto(0, -0.3, "52", 2.4, "c")
#  texto(10, -0.3, "62", 2.4, "c")
#  texto(-0.5, 0, "29", 2.4, "c")
#  texto(-0.5, 5, "34", 2.4, "c")
#  linea(0, k + 3*α*52 - 29, 10, k + 3*α*62 - 29, "gruesa rojo")
#  texto(9.2, k + 3*α*60 - 29 - 1.2, "cono f = 0", 2.6, "c", estilo = "rojo")
#  circulo(-σ_m - 52, J_tr - 29, 0.1, "azul relleno")
#  flecha(-σ_m - 52, J_tr - 29, -σ_m - 52, J_n - 29, "azul")
#  circulo(-σ_m - 52, J_n - 29, 0.1, "verde relleno")
#  texto(-σ_m - 52 - 1.4, J_tr - 29, "prueba it 1", 2.4, "c", estilo = "azul")
#  texto(-σ_m - 52 - 1.5, J_n - 29 - 0.3, "devuelto it 1", 2.4, "c", estilo = "verde")
#  circulo(-I_2/3 - 52, J_tr2 - 29, 0.1, "azul relleno")
#  flecha(-I_2/3 - 52, J_tr2 - 29, -I_2/3 - 52, J_tr2 - f_tr2 - 29, "azul")
#  circulo(-I_2/3 - 52, J_tr2 - f_tr2 - 29, 0.1, "verde relleno")
#  texto(-I_2/3 - 52 + 1.4, J_tr2 - 29 + 0.2, "prueba it 2", 2.4, "c", estilo = "azul")
#  texto(-I_2/3 - 52 + 1.5, J_tr2 - f_tr2 - 29 - 0.3, "devuelto it 2", 2.4, "c", estilo = "verde")
#fin
#: El punto se va moviendo **sobre** el cono hacia más compresión: en cada iteración la prueba vuelve a salirse un poco (2.74 kPa en la 1, 0.59 kPa en la 2) y el retorno la baja otra vez.

## 9 · Hekatan LISP contra GEO5 y Geotechnic

#hide
h_J = round(J_tr, 6)
h_f = round(f_tr, 6)
h_l = round(1000000*λ, 4)
h_sx = round(σ_1(1), 6)
h_sy = round(σ_1(2), 6)
h_sz = round(σ_1(3), 6)
h_txy = round(σ_1(4), 6)
h_sy2 = round(σ_2(2), 6)
h_txy2 = round(σ_2(4), 6)
h_D11 = round(D_ep(1, 1), 4)
h_D12 = round(D_ep(1, 2), 4)
h_D21 = round(D_ep(2, 1), 4)
#show
#| Magnitud (punto 1 del elemento 36) | Hekatan LISP | GEO5 (Frida) / Geotechnic | Diferencia |
#|---|---:|---:|---:|
#| J de la prueba, it 1 [kPa] | @{h_J} | — | — |
#| f de la prueba, it 1 [kPa] | @{h_f} | > 0 en los dos | — |
#| λ·10⁶, it 1 | @{h_l} | — | — |
#| σ_{x} devuelta, it 1 [kPa] | @{h_sx} | −36.859653 (GEO5) | |
#| σ_{y} devuelta, it 1 [kPa] | @{h_sy} | −90.187633 (GEO5) | |
#| σ_{z} devuelta, it 1 [kPa] | @{h_sz} | −39.950835 (GEO5) | |
#| τ_{xy} devuelta, it 1 [kPa] | @{h_txy} | −5.690616 (GEO5) | |
#| **σ completa, it 1** | | **GEO5** | **@{r_1} kPa** |
#| D_{ep}(1,1) / (1,2) / (2,1) [kPa] | @{h_D11} / @{h_D12} / @{h_D21} | 125965.9150 / 83649.7205 / 158701.8838 (Geotechnic) | |
#| **D_{ep} completa (16 términos)** | | **Geotechnic** | **@{r_D} kPa** |
#| σ_{y} / τ_{xy} devueltas, it 2 [kPa] | @{h_sy2} / @{h_txy2} | −94.683769 / −7.102115 (GEO5) | |
#| **σ completa, it 2** | | **GEO5** | **@{r_2} kPa** |
#: **Qué queda comprobado.** El predictor elástico, la función de fluencia de Drucker-Prager con el ajuste de extensión, el retorno radial con λ = f/G y la acumulación de σ de una iteración a la siguiente son los de GEO5, en este punto, a la precisión del double. La tangente algorítmica es la de Geotechnic; contra GEO5 se comprueba de forma indirecta (σ de la iteración 2).
#: **Qué no entra aquí.** El caso del vértice (no le toca a este punto: haría σ = c·cot φ en las tres normales) y el Newton local completo del binario con endurecimiento (la Demo04 no tiene endurecimiento: c y φ fijos). La reducción de c y φ para el factor de seguridad es la hoja 134.
