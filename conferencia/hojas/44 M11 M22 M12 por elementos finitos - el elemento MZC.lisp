#: # M11, M22 y M12 por ELEMENTOS FINITOS: el elemento de placa MZC
#: 17-sep-2026, Jorge: «hazme la formulación de elementos finitos, no solo la analítica de Navier».
#: Aquí el momento **no sale de una serie**: sale de **M = D · B · u**, con B derivado de las funciones de forma del elemento.

#: ## 1. El elemento: rectangular, 4 nudos, 12 GDL
#: Cada nudo lleva **w, θx, θy**. Con 12 grados hacen falta 12 términos, y el polinomio de Kirchhoff clásico (Adini-Clough-Melosh / Melosh-Zienkiewicz-Cheung) es este:
w_e = a1 + a2*x + a3*y + a4*x^2 + a5*x*y + a6*y^2 + a7*x^3 + a8*x^2*y + a9*x*y^2 + a10*y^3 + a11*x^3*y + a12*x*y^3
#: Es **incompleto** de 4º grado: lleva x³y y xy³ pero no x⁴, x²y² ni y⁴. Por eso es **no conforme**: la pendiente normal salta entre elementos. Aun así converge y pasa el patch test en mallas rectangulares.

#: ## 2. Los giros son derivadas parciales de la flecha (Kirchhoff)
theta_x = Partial{a1 + a2*x + a3*y + a4*x^2 + a5*x*y + a6*y^2 + a7*x^3 + a8*x^2*y + a9*x*y^2 + a10*y^3 + a11*x^3*y + a12*x*y^3 @ y}
theta_y = Simplify{-Partial{a1 + a2*x + a3*y + a4*x^2 + a5*x*y + a6*y^2 + a7*x^3 + a8*x^2*y + a9*x*y^2 + a10*y^3 + a11*x^3*y + a12*x*y^3 @ x}}

#: Evaluando w, θx y θy en los **4 nudos** salen 12 ecuaciones: **u_e = C · a**. Invirtiendo, **a = C⁻¹ · u_e**.

#: ## 3. Las curvaturas: segundas parciales
#: Esta es la fila por fila de la matriz **B**: cada curvatura es una combinación de los coeficientes.
k_xx = Simplify{-Partial{Partial{a1 + a2*x + a3*y + a4*x^2 + a5*x*y + a6*y^2 + a7*x^3 + a8*x^2*y + a9*x*y^2 + a10*y^3 + a11*x^3*y + a12*x*y^3 @ x} @ x}}
k_yy = Simplify{-Partial{Partial{a1 + a2*x + a3*y + a4*x^2 + a5*x*y + a6*y^2 + a7*x^3 + a8*x^2*y + a9*x*y^2 + a10*y^3 + a11*x^3*y + a12*x*y^3 @ y} @ y}}
k_xy = Simplify{-2*Partial{Partial{a1 + a2*x + a3*y + a4*x^2 + a5*x*y + a6*y^2 + a7*x^3 + a8*x^2*y + a9*x*y^2 + a10*y^3 + a11*x^3*y + a12*x*y^3 @ x} @ y}}

#: Mira qué desaparece: **a1, a2 y a3 no aparecen en ninguna curvatura**. Son el movimiento de cuerpo rígido (traslación y los dos giros): no producen esfuerzo. Eso es lo que debe cumplir todo elemento bien formulado.

#: ## 4. Los momentos: M = D · k
#: La misma ley constitutiva de la placa, pero ahora **k viene del elemento**, no de una serie.
M_11 = Simplify{(E*t^3/(12*(1-nu^2)))*(k_xx + nu*k_yy)}
M_22 = Simplify{(E*t^3/(12*(1-nu^2)))*(k_yy + nu*k_xx)}
M_12 = Simplify{(E*t^3/(12*(1-nu^2)))*(1-nu)/2*k_xy}

#: En forma matricial: **M = D·B·u_e**, donde D es 3×3 y B es 3×12. Los momentos son **lineales** dentro del elemento (por los términos cúbicos), así que en el centroide salen los valores más limpios: eso es lo que reportan ETABS y SAP en el centro del área.

#: ## 5. La rigidez del elemento, con Gauss
#: **Ke = ∫∫ Bᵀ·D·B · dx dy**, y como B es cuadrática, **Gauss 2×2 es exacto**.
#: Puntos ±1/√3 con peso 1, igual que se comprobó en la hoja 42.

#: ## 6. Los números: la misma losa medida contra ETABS 19
#: Losa 10 × 10 m · t = 0.5 m · E = 2.2e7 kN/m² · nu = 0.2 · q = 10 kN/m² · malla 8×8 (elemento de 1.25 m).
#: Resuelto con este mismo elemento en Hekatan Lab (`placa_MZC_fem_momentos.m`):
#: - **Flecha FEM: 0.001728 m** · Navier 0.001701 m → **+1.58 %** · ETABS 19 Thin 0.00170024 m → **+1.61 %**
#: - **M11 = M22 = −42.75 kN·m/m** en el centro del elemento más cercano al centro (x = 4.375 m), contra **47.90 kN·m/m** de Timoshenko: **−10.8 %**, porque ese punto está a 0.884 m del centro real de la losa y el momento cae rápido.
#: - **M12 = 1.10 kN·m/m** ahí, casi cero, como debe ser cerca del centro.
#: La malla 8×8 con elemento no conforme da una losa **un poco más flexible**: +1.6 %. Con 16×16 baja a menos del 0.5 %.

#: ## 7. La diferencia con Navier, en una frase
#: - **Navier**: una serie que solo vale para losa rectangular apoyada y carga uniforme.
#: - **FEM (MZC, DKT, MITC4)**: vale para cualquier forma, apoyo y carga; el precio es que la respuesta depende de la malla.

#: ## 8. La placa dibujada (colormap + hover: pasa el cursor)
#: La flecha va hacia abajo: por eso el signo menos.
#surf(-sin(pi*x/10)*sin(pi*y/10), [0 10], [0 10])

#: **M11 del FEM [kN·m/m]** (máximo 42.7 en el centro, cero en los bordes):
#map(-42.7*sin(pi*x/10)*sin(pi*y/10), [0 10], [0 10])

#: **M12 torsor [kN·m/m]** (cero en el centro, máximo en las esquinas — ahí la losa se levanta):
#map(34.9*cos(pi*x/10)*cos(pi*y/10), [0 10], [0 10])
