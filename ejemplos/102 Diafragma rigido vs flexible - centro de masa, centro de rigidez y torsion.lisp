# Diafragma rígido vs flexible: centro de masa, centro de rigidez y torsión
#: Una misma planta de **12 m × 8 m** con sismo en **Y**. Tres muros resisten en Y (ejes x = 0, 6 y 12 m) y dos en X (ejes y = 0 y 8 m). La masa está repartida de forma uniforme. La resolvemos dos veces: con losa **rígida** y con losa **flexible**.

#numerico
## 1 · Datos
#| Muro | Dirección | Posición [m] | Rigidez [kN/mm] |
#|---|---|---:|---:|
#| 1 | Y | x₁ = 0 | k₁ = 200 |
#| 2 | Y | x₂ = 6 | k₂ = 100 |
#| 3 | Y | x₃ = 12 | k₃ = 50 |
#| 4 y 5 | X | y = 0 y y = 8 | kx = 150 cada uno |
#: Planta **Lx = 12 m**, **Ly = 8 m**; cortante del piso en Y **V = 300 kN**.
#hide
Lx = 12 @@(largo de la planta en X, m)
Ly = 8 @@(ancho de la planta en Y, m)
V = 300 @@(cortante del piso en dirección Y, kN)
k1 = 200 @@(rigidez del muro 1 en Y, eje x = 0, kN/mm)
k2 = 100 @@(rigidez del muro 2 en Y, eje x = 6 m, kN/mm)
k3 = 50 @@(rigidez del muro 3 en Y, eje x = 12 m, kN/mm)
x1 = 0 @@(posición del muro 1, m)
x2 = 6 @@(posición del muro 2, m)
x3 = 12 @@(posición del muro 3, m)
kx = 150 @@(rigidez de cada uno de los 2 muros en X, ejes y = 0 y y = 8 m, kN/mm)
#show

## 2 · Diafragma RÍGIDO: por qué SÍ hay CM y CR
#: La losa no se deforma en su plano. Entonces **todo el piso** se mueve con solo 3 números: u_x, u_y y el giro θ. Cada muro se mueve según la recta **u_i = u_y + θ·(x_i − x_CR)**, igual que y = m·x + b: la pendiente es θ y la ordenada es u_y.
#: Si toda la planta sigue una sola recta, también existen **un solo punto donde actúa la inercia (CM)** y **un solo punto donde una fuerza no hace girar la planta (CR)**.
xCM = Lx/2 @@(centro de masa: masa uniforme, centro de la planta, m)
Ky = k1 + k2 + k3 @@(rigidez lateral total del piso en Y, kN/mm)
xCR = (k1*x1 + k2*x2 + k3*x3)/Ky @@(centro de rigidez: posición promedio pesada por la rigidez, m)
e = xCM - xCR @@(excentricidad inherente CM − CR, m)
ea = 0.05*Lx @@(excentricidad accidental: 5 % de la dimensión perpendicular a la fuerza, NEC-15 §6.3.6, m)
et = e + ea @@(excentricidad total, m)
Mt = V*et @@(momento torsor del piso, kN·m)
Kt = k1*(x1-xCR)^2 + k2*(x2-xCR)^2 + k3*(x3-xCR)^2 + 2*kx*(Ly/2)^2 @@(rigidez a torsión respecto del CR, kN·m²/mm)
uy = V/Ky @@(traslación del piso en Y, mm)
th = Mt/Kt @@(giro θ del piso, mm/m (milésimas de radián))
u1 = uy + th*(x1-xCR) @@(desplazamiento del muro 1: está sobre la recta, mm)
u2 = uy + th*(x2-xCR) @@(desplazamiento del muro 2, mm)
u3 = uy + th*(x3-xCR) @@(desplazamiento del muro 3, mm)
V1 = k1*u1 @@(cortante que toma el muro 1, kN)
V2 = k2*u2 @@(cortante que toma el muro 2, kN)
V3 = k3*u3 @@(cortante que toma el muro 3, kN)
Vsum = V1 + V2 + V3 @@(comprobación: suma de cortantes = V, kN)
#: El muro **más rígido** (el 1) toma más cortante: con losa rígida la fuerza se reparte **por rigidez** y el giro mueve más al borde flexible.

## 3 · Control de torsión con diafragma RÍGIDO
umax = u3 @@(desplazamiento máximo, en el borde flexible x = 12 m, mm)
uprom = (u1 + u3)/2 @@(promedio de los dos bordes, mm)
rt = umax/uprom @@(relación de torsión δmax/δprom; irregular si > 1.2, NEC-15 Tabla 13 tipo 1)
Ax = (umax/(1.2*uprom))^2 @@(amplificación de la torsión accidental, borrador ec. 6.7, entre 1 y 3)
#: Se corrige acercando el CR al CM (en este ejemplo, rigidizar el muro 3) hasta que δmax/δprom ≤ 1.2.

## 4 · Diafragma FLEXIBLE: por qué NO hay CR (y el CM deja de importar)
#: La losa se dobla como una **viga simple apoyada en los muros**. Cada muro recibe la carga de su **área tributaria**, sin importar su rigidez.
w = V/Lx @@(carga sísmica por metro de planta, kN/m)
F1 = w*(x2-x1)/2 @@(muro 1: tributaria de 3 m, kN)
F2 = w*((x2-x1)/2 + (x3-x2)/2) @@(muro 2: tributaria de 6 m, kN)
F3 = w*(x3-x2)/2 @@(muro 3: tributaria de 3 m, kN)
d1 = F1/k1 @@(desplazamiento del muro 1 con losa flexible, mm)
d2 = F2/k2 @@(desplazamiento del muro 2, mm)
d3 = F3/k3 @@(desplazamiento del muro 3, mm)
g12 = (d2 - d1)/(x2 - x1) @@(«giro» del tramo 1–2: pendiente entre muros 1 y 2, mm/m)
g23 = (d3 - d2)/(x3 - x2) @@(«giro» del tramo 2–3: pendiente entre muros 2 y 3, mm/m)
#: **g12 ≠ g23**: los muros **no están sobre una sola recta**, así que el piso no tiene un único giro θ. Sin un θ único no existe el punto «donde θ = 0», o sea, **no hay CR**.
#: El **CM** sí existe en la geometría (x = 6 m), pero la losa **no lleva** la inercia hasta ese punto: cada trozo de masa va a su muro. Por eso **no hay torsión del piso** que repartir.

## 5 · Cómo se controla la torsión con diafragma flexible
#: 1. **Cada línea de muros por separado**: se diseña con su fuerza tributaria (F1, F2, F3) y debe cumplir la deriva límite **por sí sola** (borrador §5.3.1.1 c.2).
#: 2. **Sin torsión accidental**: el borrador §6.2.4.2 pide el 5 % solo *«para diafragmas que no son flexibles»*. La NEC-15 §6.3.6 pide repartir *«tomando en cuenta aquella condición»*.
#: 3. **Comprobar que de verdad es flexible**: borrador ec. 5.1, **MDD/ADVE > 2** (flecha máxima de la losa entre el promedio de derivas de los muros). Si no cumple y la losa tampoco es rígida (§5.3.1.2), es **semirrígida**: se modela la losa con cáscaras.
#: 4. **Semirrígida**: el CR solo se puede aproximar (repartiendo la carga por masa). La irregularidad torsional se mide con **δmax/δprom** en los bordes, que **no necesita CR**: solo dos desplazamientos. Así lo hace Hekatan Struct sin diafragma.
#: 5. Práctica común: diseñar cada muro con la **mayor** de las dos fuerzas (rígido y flexible), porque la losa real está entre las dos.
Vm1 = max(V1, F1) @@(muro 1: envolvente rígido/flexible, kN)
Vm2 = max(V2, F2) @@(muro 2: envolvente rígido/flexible, kN)
Vm3 = max(V3, F3) @@(muro 3: envolvente rígido/flexible, kN)

## 6 · Resumen: el mismo piso, dos losas
#| Muro | Rígido: V [kN] | Flexible: F [kN] | Rígido: u [mm] | Flexible: d [mm] |
#|---|---:|---:|---:|---:|
#| 1 (k = 200) | 114.6 | 75 | 0.573 | 0.375 |
#| 2 (k = 100) | 107.0 | 150 | 1.070 | 1.500 |
#| 3 (k = 50) | 78.4 | 75 | 1.567 | 1.500 |
#: Rígida: los 3 desplazamientos caen en **una recta** (giro θ único → hay CR y torsión). Flexible: **no** caen en una recta (no hay CR) y cada muro toma lo de su área tributaria.
