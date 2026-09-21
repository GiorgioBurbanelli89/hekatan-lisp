#: # Shell-Thin: funciones de forma, Jacobiano y cuadratura de Gauss
#: 17-sep-2026. Primero el **símbolo** — de dónde salen las funciones de forma, qué es el Jacobiano y por qué Gauss da el valor exacto — y al final el **número** y la **gráfica** de la placa delgada.

#: ## 1. Las funciones de forma del cuadrilátero Q4
#: En el cuadrado natural, de −1 a 1 en las dos direcciones. Cada una vale **1 en su nudo y 0 en los otros tres**.
N_1 = Expand{(1-xi)*(1-eta)/4}
N_2 = Expand{(1+xi)*(1-eta)/4}
N_3 = Expand{(1+xi)*(1+eta)/4}
N_4 = Expand{(1-xi)*(1+eta)/4}

#: **Partición de la unidad**: las cuatro suman 1 en cualquier punto. Si esto falla, el elemento no reproduce un movimiento de cuerpo rígido.
particion = Simplify{(1-xi)*(1-eta)/4 + (1+xi)*(1-eta)/4 + (1+xi)*(1+eta)/4 + (1-xi)*(1+eta)/4}

#: ## 2. Derivadas en coordenadas naturales
dN1_dxi = Simplify{Partial{(1-xi)*(1-eta)/4 @ xi}}
dN1_deta = Simplify{Partial{(1-xi)*(1-eta)/4 @ eta}}
dN3_dxi = Simplify{Partial{(1+xi)*(1+eta)/4 @ xi}}
dN3_deta = Simplify{Partial{(1+xi)*(1+eta)/4 @ eta}}

#: ## 3. El Jacobiano: del cuadrado natural al elemento real
#: La geometría se interpola con las MISMAS funciones de forma (isoparamétrico). Para un rectángulo de lados a y b centrado en el origen:
x_geo = Simplify{(a/2)*xi}
y_geo = Simplify{(b/2)*eta}
J_11 = Simplify{Partial{(a/2)*xi @ xi}}
J_22 = Simplify{Partial{(b/2)*eta @ eta}}
detJ = Simplify{(a/2)*(b/2)}

#: El determinante es el **factor de área**: dx·dy = detJ · dξ·dη. Por eso toda integral del elemento se calcula en el cuadrado y se multiplica por detJ.

#: ## 4. Cuadratura de Gauss
#: Integrar exacto a mano es caro; Gauss cambia la integral por una suma: **∫f ≈ Σ w_i · f(ξ_i)**.
#: Con 2 puntos, ξ = ±1/√3 y pesos 1, es EXACTA hasta grado 3.
xi_g = 1/sqrt(3)
#: Prueba con ξ² (la integral exacta vale 2/3):
exacta = Integral{xi^2 @ xi}
gauss_2 = 1*(1/sqrt(3))^2 + 1*(-1/sqrt(3))^2
#: Gauss da **2/3**, igual que la integral exacta. Por eso la rigidez del Q4 se calcula con 2×2 puntos.

#: ## 5. Lo mismo, pero para la rigidez de la placa
#: La rigidez de flexión sale de **K = ∫ Bᵀ·D·B · detJ dξ dη**, evaluada en los 4 puntos de Gauss del cuadrado.
D_b = E*t^3/(12*(1-nu^2))

#: ## 6. La placa Shell-Thin dibujada (colormap + **hover**: pasa el cursor)
#: La flecha va **hacia abajo** (la carga es la gravedad): por eso el signo menos. La placa se hunde, no se levanta.
#surf(-sin(pi*x/10)*sin(pi*y/10), [0 10], [0 10])

#: Y en planta, como el mapa de color de ETABS:
#map(-sin(pi*x/10)*sin(pi*y/10), [0 10], [0 10])

#: ## 7. AHORA los números
#: Losa 10 × 10 m · t = 0.5 m · E = 2.2e7 kN/m² · nu = 0.2 · q = 10 kN/m² · malla 8×8 (elemento de 1.25 m).
detJ_num = (1.25/2)*(1.25/2)
#: **detJ = 0.3906 m²** por elemento (el área del elemento es 4·detJ = 1.5625 m²).

D_num = 2.2*10^7*0.5^3/(12*(1-0.2^2))
#: **D = 238 715 kN·m**

w_centro = 0.00406*10*10^4/238715
#: **w = 0.0017008 m = 1.70 mm** en el centro.

#: ## 8. Contra ETABS 19 (medido con esta misma malla)
#: - Kirchhoff (serie de Navier, 19 términos): **0.00170175 m**
#: - ETABS 19 Shell-Thin: **0.00170024 m**
#: - Diferencia: **+0.089 %**, la misma en los cinco espesores probados (t/L de 0.001 a 0.2).
#: Es el corte de la serie, no la formulación: el Shell-Thin de ETABS y de SAP2000 cae sobre la solución de Kirchhoff.
