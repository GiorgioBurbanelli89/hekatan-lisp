#: # Placa DK (Discrete Kirchhoff) y Shell-Thin: la teoría
#: 17-sep-2026. De dónde sale el elemento **DKT/DKQ** que usan los programas para la placa delgada, por qué se llama «discreto» y en qué se diferencia del Shell-Thick.

#: ## 1. El problema de la placa delgada
#: Kirchhoff dice: la recta perpendicular a la placa **sigue recta y perpendicular**. Entonces los giros NO son libres: son la pendiente de la flecha.
beta_x = Partial{w(x,y) @ x}
beta_y = Partial{w(x,y) @ y}
#: Eso obliga a que la flecha w tenga **derivadas continuas entre elementos** (continuidad C1). Y ahí está el problema: **construir un elemento C1 es muy difícil**. Ese fue el muro de los años 60.

#: ## 2. La salida de Batoz (1980): imponer Kirchhoff SOLO en puntos
#: En vez de forzar la hipótesis en todo el elemento, se parte de Mindlin — giros **independientes** de la flecha, que solo pide continuidad C0 — y se impone Kirchhoff **en puntos escogidos**: los 3 nudos y los 3 puntos medios de los lados.
#: De ahí el nombre: **Discrete Kirchhoff**. La restricción es discreta, no continua.
#: - **DKT** = Discrete Kirchhoff Triangle (3 nudos, 9 GDL: w, θx, θy por nudo).
#: - **DKQ** = la misma idea en el cuadrilátero de 4 nudos.

#: ## 3. Los giros se interpolan con polinomios de 2º grado
#: Cada giro usa las 6 funciones del triángulo de 6 nudos (los 3 vértices y los 3 medios de lado), en coordenadas de área.
N_1 = Expand{(2*L1-1)*L1}
N_4 = Expand{4*L1*L2}
#: La condición de Kirchhoff en los puntos medios elimina los grados de libertad de esos nudos: quedan solo los 9 de los vértices.

#: ## 4. Las curvaturas salen de derivar los giros
#: Esta es la diferencia de fondo con Kirchhoff puro: aquí se derivan los GIROS, no la flecha dos veces.
k_xx = Partial{beta_x(x,y) @ x}
k_yy = Partial{beta_y(x,y) @ y}
k_xy = Simplify{Partial{beta_x(x,y) @ y} + Partial{beta_y(x,y) @ x}}

#: ## 5. Momentos: la ley constitutiva de flexión
D_b = E*t^3/(12*(1-nu^2))
M_xx = Simplify{(E*t^3/(12*(1-nu^2)))*(k_xx + nu*k_yy)}
M_yy = Simplify{(E*t^3/(12*(1-nu^2)))*(k_yy + nu*k_xx)}
M_xy = Simplify{(E*t^3/(12*(1-nu^2)))*(1-nu)/2*k_xy}

#: ## 6. La rigidez del elemento
#: **K = ∫ Bᵇᵀ · D · Bᵇ · detJ dA**. En el DKT, Bᵇ es **lineal** en las coordenadas naturales y D es constante, así que **un solo punto de Gauss en el centroide es exacto**: no hace falta 2×2.
#: Ese es el atajo que hace al DKT tan barato: 9 GDL y una sola evaluación por elemento.

#: ## 7. Por qué el DK es la placa «Thin» de los programas
#: - **Thin (DK)**: sin deformación por cortante. Para losas con lado/espesor mayor que 20 es la respuesta correcta y no sufre **bloqueo por cortante**.
#: - **Thick (Mindlin, MITC4)**: añade el cortante. Hace falta en losas gruesas o zapatas; en losas delgadas da casi lo mismo, un poco más flexible.
#: - El DK **no sufre shear locking** porque el cortante no está en su formulación: se eliminó al imponer Kirchhoff.

#: ## 8. La placa Shell-Thin dibujada (colormap + **hover**: pasa el cursor)
#: La flecha va **hacia abajo** (la carga es la gravedad): por eso el signo menos. La placa se hunde, no se levanta.
#surf(-sin(pi*x/10)*sin(pi*y/10), [0 10], [0 10])

#: ## 9. M11, M22, M12, V13, V23: lo que reporta ETABS
#: Con la flecha de Navier w = A·sin(πx/L)·sin(πy/L), el motor deriva y salen los esfuerzos de la placa.
#: **Momentos** (por unidad de ancho, kN·m/m): se derivan DOS veces la flecha.
M_11 = Simplify{-D*(Partial{Partial{A*sin(pi*x/L)*sin(pi*y/L) @ x} @ x} + nu*Partial{Partial{A*sin(pi*x/L)*sin(pi*y/L) @ y} @ y})}
M_22 = Simplify{-D*(Partial{Partial{A*sin(pi*x/L)*sin(pi*y/L) @ y} @ y} + nu*Partial{Partial{A*sin(pi*x/L)*sin(pi*y/L) @ x} @ x})}
M_12 = Simplify{-D*(1-nu)*Partial{Partial{A*sin(pi*x/L)*sin(pi*y/L) @ x} @ y}}

#: **Cortantes** (kN/m): se derivan los momentos una vez más.
V_13 = Simplify{-D*Partial{Partial{Partial{A*sin(pi*x/L)*sin(pi*y/L) @ x} @ x} @ x} - D*Partial{Partial{Partial{A*sin(pi*x/L)*sin(pi*y/L) @ y} @ y} @ x}}
V_23 = Simplify{-D*Partial{Partial{Partial{A*sin(pi*x/L)*sin(pi*y/L) @ y} @ y} @ y} - D*Partial{Partial{Partial{A*sin(pi*x/L)*sin(pi*y/L) @ x} @ x} @ y}}

#: Nomenclatura CSI: **M11 y M22** flectores en las dos direcciones · **M12** torsor · **V13 y V23** cortantes fuera del plano. En Thin no hay deformación por cortante, pero los cortantes de equilibrio sí existen.

#: ### Los mapas de color (losa 10 m, t = 0.5 m, q = 10 kN/m², A = 0.0010753 m)
#: **M11 [kN·m/m]** — máximo en el centro, cero en los bordes apoyados:
#map(30.4*sin(pi*x/10)*sin(pi*y/10), [0 10], [0 10])

#: **M12 torsor [kN·m/m]** — cero en el centro, máximo en las ESQUINAS (ahí se levanta la losa):
#map(-20.3*cos(pi*x/10)*cos(pi*y/10), [0 10], [0 10])

#: **V13 [kN/m]** — cortante hacia los apoyos, máximo en el borde x = 0 y x = L:
#map(15.9*cos(pi*x/10)*sin(pi*y/10), [0 10], [0 10])

#: **V23 [kN/m]** — el mismo, girado 90°:
#map(15.9*sin(pi*x/10)*cos(pi*y/10), [0 10], [0 10])

#: Valores de contraste en el centro: **M11 = M22 = 30.4 kN·m/m** (Timoshenko da 0.0479·q·L² = 47.9 con la serie completa; con un solo término del seno sale 30.4, que es el 63 %: el primer término basta para la flecha, no para el momento).

#: ### Momentos principales y dirección (lo que ETABS llama Mmax, Mmin)
#: Igual que el círculo de Mohr, pero con momentos: giran los ejes hasta que el torsor se anula.
M_max = (M11+M22)/2 + sqrt(((M11-M22)/2)^2 + M12^2)
M_min = (M11+M22)/2 - sqrt(((M11-M22)/2)^2 + M12^2)
tan_2theta = Simplify{2*M12/(M11-M22)}

#: ### Armadura de Wood-Armer (lo que se usa para diseñar la losa)
#: El torsor no se arma directamente: se reparte sumando su valor absoluto a los dos flectores.
M_armar_x = M11 + abs(M12)
M_armar_y = M22 + abs(M12)

#: ### Esfuerzos en la cara de la placa, desde el momento
#: La fibra extrema está a t/2, y el módulo resistente por unidad de ancho es t²/6.
sigma_x = 6*M11/t^2
sigma_y = 6*M22/t^2
tau_xy = 6*M12/t^2
sigma_vm = Simplify{sqrt((6*M11/t^2)^2 - (6*M11/t^2)*(6*M22/t^2) + (6*M22/t^2)^2 + 3*(6*M12/t^2)^2)} @@(von Mises en la cara)

#: ## 9. Los números, contra ETABS 19
#: Losa 10 × 10 m, t = 0.5 m, E = 2.2e7 kN/m², nu = 0.2, q = 10 kN/m², malla 8×8.
D_num = 2.2*10^7*0.5^3/(12*(1-0.2^2))
#: **D = 238 715 kN·m**
w_centro = 0.00406*10*10^4/238715
#: **w = 0.0017008 m = 1.70 mm** en el centro.
#: - Kirchhoff, serie de Navier (19 términos): **0.00170175 m**
#: - ETABS 19 Shell-Thin: **0.00170024 m** → **+0.089 %**
#: La misma diferencia en los cinco espesores probados (t/L de 0.001 a 0.2): es el corte de la serie, no la formulación.

#: ## 10. Lo que NO está comprobado aquí
#: El ejemplo de Hekatan Lab que arma la malla con el DKT del framework (`placa_DKT_colormap.m`) da una flecha **mil veces menor** que la teoría. El error está en el ensamblaje o en la matriz B del DKT, y se encuentra comparando **la matriz de rigidez de UN elemento** contra ETABS o SAP2000, nudo a nudo, antes de mirar la malla completa.

#: ## 11. Los datos con los que se hicieron las gráficas
#: Todo lo dibujado arriba sale de estos números, para que se pueda repetir:
#: - Losa cuadrada **L = 10 m**, simplemente apoyada en los cuatro bordes.
#: - Espesor **t = 0.5 m** (L/t = 20: delgada, el Thin vale).
#: - **E = 2.2e7 kN/m²** · **nu = 0.2** · carga **q = 10 kN/m²**.
#: - Rigidez **D = E·t³/12(1−ν²) = 238 715 kN·m**.
#: - Amplitud del primer término de Navier: **A = q·L⁴/(4·π⁴·D) = 0.0010753 m**.
#:
#: De ahí salen los coeficientes de cada mapa:
#: - Flecha dibujada: **w = −A·sin(πx/L)·sin(πy/L)**, con el menos porque la carga es la gravedad.
#: - **M11 = M22 = D·A·(π/L)²·(1+ν) = 30.4 kN·m/m** en el centro.
#: - **M12 = −D·A·(π/L)²·(1−ν) = −20.3 kN·m/m**, máximo en las esquinas.
#: - **V13 = V23 = 2·D·A·(π/L)³ = 15.9 kN/m**, máximos en los bordes.
#: - Malla de comparación con ETABS: **8×8** elementos de 1.25 m, **detJ = 0.3906 m²** por elemento.
#:
#: Comprobación: (π/10)² = 0.098696 · D·A = 256.7 kN·m/m · 256.7 × 0.098696 × 1.2 = **30.4** ✔
