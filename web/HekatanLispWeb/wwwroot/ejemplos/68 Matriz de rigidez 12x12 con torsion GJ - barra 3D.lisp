# Matriz de rigidez completa de una barra 3D, con la torsión G·J

#: En el plano una barra tiene 6 grados de libertad. En el espacio tiene **12**: en cada extremo se corre en x, y, z y gira alrededor de x, y, z. El giro alrededor de su propio eje (θx) es la **torsión**, y es lo que el plano no tenía.

## 1 · El orden de los grados de libertad

#: Filas y columnas van así (nudo i, luego nudo j):
#: **0** u_{i} · **1** v_{i} · **2** w_{i} · **3** θx_{i} · **4** θy_{i} · **5** θz_{i} · **6** u_{j} · **7** v_{j} · **8** w_{j} · **9** θx_{j} · **10** θy_{j} · **11** θz_{j}
#: · u = axial · v, w = desplazamientos transversales · θx = torsión · θy, θz = giros de flexión.

## 2 · La torsión se deduce igual que el axial

#: El giro θx varía en **línea recta** a lo largo de la barra, igual que el estiramiento. Sus funciones de forma son rectas:
N_1 = 1 - x/L
N_2 = x/L
#: Derivo (el motor) para tener la **B** de la torsión, el giro por unidad de largo:
dN1 = Diff{1 - x/L @ x} @@(dN₁/dx)
dN2 = Diff{x/L @ x} @@(dN₂/dx)
#: Entonces B = [−1/L, 1/L] y la rigidez es la integral de siempre, con **G·J** en lugar de E·A:
#: K_{t} = ∫_{0}^{L} B^{T}·G·J·B dx = (G·J/L)·[1, −1; −1, 1]
k_t = G*J/L
#: Con L = 1, el motor integra el término (1,1) y da 1 → queda **G·J/L**:
k11_t = Area{(-1)*(-1) @ x=0:1} @@(B₁·B₁ con L=1)

## 3 · Los cuatro bloques de la matriz

#: Dentro de la 12×12 hay **cuatro físicas**, y ninguna se mezcla con las otras en una barra recta:

#: · **axial** (u_{i}, u_{j}): E·A/L
#: · **torsión** (θx_{i}, θx_{j}): **G·J/L**
#: · **flexión en el plano x-y** (v, θz): 12·E·I_{z}/L³ · 6·E·I_{z}/L² · 4·E·I_{z}/L · 2·E·I_{z}/L
#: · **flexión en el plano x-z** (w, θy): 12·E·I_{y}/L³ · 6·E·I_{y}/L² · 4·E·I_{y}/L · 2·E·I_{y}/L

#: La flexión en x-z lleva el **6·E·I_{y}/L² con signo menos**: girar θy positivo baja el extremo (regla de la mano derecha).

## 4 · La matriz completa, en símbolos

K_12 = [E*A/L, 0, 0, 0, 0, 0, -E*A/L, 0, 0, 0, 0, 0; 0, 12*E*I_z/L^3, 0, 0, 0, 6*E*I_z/L^2, 0, -12*E*I_z/L^3, 0, 0, 0, 6*E*I_z/L^2; 0, 0, 12*E*I_y/L^3, 0, -6*E*I_y/L^2, 0, 0, 0, -12*E*I_y/L^3, 0, -6*E*I_y/L^2, 0; 0, 0, 0, G*J/L, 0, 0, 0, 0, 0, -G*J/L, 0, 0; 0, 0, -6*E*I_y/L^2, 0, 4*E*I_y/L, 0, 0, 0, 6*E*I_y/L^2, 0, 2*E*I_y/L, 0; 0, 6*E*I_z/L^2, 0, 0, 0, 4*E*I_z/L, 0, -6*E*I_z/L^2, 0, 0, 0, 2*E*I_z/L; -E*A/L, 0, 0, 0, 0, 0, E*A/L, 0, 0, 0, 0, 0; 0, -12*E*I_z/L^3, 0, 0, 0, -6*E*I_z/L^2, 0, 12*E*I_z/L^3, 0, 0, 0, -6*E*I_z/L^2; 0, 0, -12*E*I_y/L^3, 0, 6*E*I_y/L^2, 0, 0, 0, 12*E*I_y/L^3, 0, 6*E*I_y/L^2, 0; 0, 0, 0, -G*J/L, 0, 0, 0, 0, 0, G*J/L, 0, 0; 0, 0, -6*E*I_y/L^2, 0, 2*E*I_y/L, 0, 0, 0, 6*E*I_y/L^2, 0, 4*E*I_y/L, 0; 0, 6*E*I_z/L^2, 0, 0, 0, 2*E*I_z/L, 0, -6*E*I_z/L^2, 0, 0, 0, 4*E*I_z/L]

#: Las filas 3 y 9 (θx de i y de j) son la torsión: **solo tienen G·J/L**, nada de flexión ni axial.

## 5 · J no es la inercia polar

#: En una sección circular J = I_{y} + I_{z}. En una **rectangular no**: la sección se alabea y J es mucho menor. Saint-Venant (Roark), con a = lado mayor, b = lado menor, r = b/a:
#: J = [1/3 − 0.21·r·(1 − r⁴/12)]·a·b³

## 6 · Con números: la viga V30×50 de la mesa de torsión

E_c = dec(24850000, 0) [kN/m²] 'módulo del hormigón ; ν = dec(0.2, 2) [—] 'Poisson ; L_v = dec(6, 1) [m] 'luz de la viga
G_c = dec(24850000/2.4, 0) [kN/m²] 'módulo de corte: E entre 2·(1+ν)
A_v = dec(0.30*0.50, 4) [m²] 'área ; I_y = dec(0.30*0.50^3/12, 6) [m⁴] 'inercia fuerte ; I_z = dec(0.50*0.30^3/12, 6) [m⁴] 'inercia débil
r_v = dec(0.30/0.50, 2) [—] 'b/a
J_v = dec((1/3 - 0.21*0.6*(1 - 0.6^4/12))*0.50*0.30^3, 7) [m⁴] 'torsión de Saint-Venant
J_polar = dec(0.003125 + 0.001125, 6) [m⁴] 'lo que daría Iy + Iz (MAL para un rectángulo)
#: J de Saint-Venant vale {J_v} m⁴; la polar daría {J_polar} m⁴. Usar la polar **sobrestima la torsión un 51 %**.

## 7 · Los términos, con números

k_a = dec(24850000*0.15/6, 0) [kN/m] 'axial: E·A/L
k_t = dec(10354167*0.0028174/6, 0) [kN·m] 'torsión: G·J/L
k_vz = dec(12*24850000*0.001125/6^3, 0) [kN/m] '12·E·Iz/L³ ; k_mz = dec(6*24850000*0.001125/6^2, 0) [kN] '6·E·Iz/L² ; k_gz = dec(4*24850000*0.001125/6, 0) [kN·m] '4·E·Iz/L ; k_cz = dec(2*24850000*0.001125/6, 0) [kN·m] '2·E·Iz/L
k_vy = dec(12*24850000*0.003125/6^3, 0) [kN/m] '12·E·Iy/L³ ; k_my = dec(6*24850000*0.003125/6^2, 0) [kN] '6·E·Iy/L² ; k_gy = dec(4*24850000*0.003125/6, 0) [kN·m] '4·E·Iy/L ; k_cy = dec(2*24850000*0.003125/6, 0) [kN·m] '2·E·Iy/L

## 8 · La matriz 12×12, con números

K_v = [621250, 0, 0, 0, 0, 0, -621250, 0, 0, 0, 0, 0; 0, 1553, 0, 0, 0, 4659, 0, -1553, 0, 0, 0, 4659; 0, 0, 4314, 0, -12943, 0, 0, 0, -4314, 0, -12943, 0; 0, 0, 0, 4862, 0, 0, 0, 0, 0, -4862, 0, 0; 0, 0, -12943, 0, 51771, 0, 0, 0, 12943, 0, 25885, 0; 0, 4659, 0, 0, 0, 18637, 0, -4659, 0, 0, 0, 9319; -621250, 0, 0, 0, 0, 0, 621250, 0, 0, 0, 0, 0; 0, -1553, 0, 0, 0, -4659, 0, 1553, 0, 0, 0, -4659; 0, 0, -4314, 0, 12943, 0, 0, 0, 4314, 0, 12943, 0; 0, 0, 0, -4862, 0, 0, 0, 0, 0, 4862, 0, 0; 0, 0, -12943, 0, 25885, 0, 0, 0, 12943, 0, 51771, 0; 0, 4659, 0, 0, 0, 9319, 0, -4659, 0, 0, 0, 18637]

#: El visor recorta una matriz de 12 columnas con `⋯`. Para ver **todos** los términos, la misma matriz en sus cuatro bloques 6×6 (filas y columnas 0-5 = nudo i, 6-11 = nudo j):
K_ii = [621250, 0, 0, 0, 0, 0; 0, 1553, 0, 0, 0, 4659; 0, 0, 4314, 0, -12943, 0; 0, 0, 0, 4862, 0, 0; 0, 0, -12943, 0, 51771, 0; 0, 4659, 0, 0, 0, 18637] @@(nudo i con nudo i)
K_ij = [-621250, 0, 0, 0, 0, 0; 0, -1553, 0, 0, 0, 4659; 0, 0, -4314, 0, -12943, 0; 0, 0, 0, -4862, 0, 0; 0, 0, 12943, 0, 25885, 0; 0, -4659, 0, 0, 0, 9319] @@(nudo i con nudo j)
K_jj = [621250, 0, 0, 0, 0, 0; 0, 1553, 0, 0, 0, -4659; 0, 0, 4314, 0, 12943, 0; 0, 0, 0, 4862, 0, 0; 0, 0, 12943, 0, 51771, 0; 0, -4659, 0, 0, 0, 18637] @@(nudo j con nudo j)
#: Y el bloque que falta es la transpuesta: K_{ji} = K_{ij}^{T}. El **4862** de la diagonal (fila 3) y el **−4862** del bloque cruzado son la torsión.

#: Tres comprobaciones que se ven a ojo:
#: · Es **simétrica** (Betti).
#: · En cada fila, las columnas de **desplazamiento** (u, v, w de i y de j) suman cero: si la barra se traslada entera, no aparece fuerza.
#: · Tiene **6 autovalores nulos** = los 6 movimientos de cuerpo rígido (3 traslaciones + 3 giros). Una barra sin apoyos no tiene rigidez contra ellos.

## 9 · Por qué la torsión es "la débil"

razon_y = dec(51771/4862, 1) [—] 'girar en flexión fuerte vs torcer
razon_z = dec(18637/4862, 1) [—] 'girar en flexión débil vs torcer
#: Torcer la viga cuesta {razon_y} veces menos que girarla en su plano fuerte. Por eso, cuando la losa gira en el borde, la viga **se tuerce** (en la mesa de torsión: T = 1.17 tonf·m en las vigas junto a las columnas) en lugar de tomar el giro con flexión.

## 10 · El mismo elemento en OpenSees

#: `model basic -ndm 3 -ndf 6`
#: `geomTransf Linear 1 0 0 1`
#: `element elasticBeamColumn 1 1 2 0.15 24850000 10354167 0.0028174 0.003125 0.001125 1`
#: El orden es **A, E, G, J, I_{y}, I_{z}**. Sacada con `printA`, la matriz de OpenSees es **idéntica término a término** a la de la sección 8 (621250, 1553, 4314, **4862**, 51771, 18637…).
