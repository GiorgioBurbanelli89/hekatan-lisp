# Deformada de un pórtico: cómo se dibujaba ANTES del FEM vs con FEM
#: La misma curva por los dos caminos. **Antes** (clásico) se integraba la elástica de cada barra. **Ahora** (FEM) las funciones de forma ya llevan esa integración hecha. Mismo resultado, misma gráfica. Todo con el motor.

## 0 · El problema — y de dónde salen los desplazamientos
#: Pórtico de un vano: columnas de altura h=1, viga de luz L=1, rigidez EI=1 (unitarios, para ver los números limpios). Bases empotradas. Carga lateral H=1 en la esquina B. Sin deformar:
#frame(fixed-fixed, H)
#: Hay 3 incógnitas: el giro de cada esquina (θ_B, θ_C) y el ladeo del piso (Δ). Salen de la ecuación de rigidez K·u = F, o sea u = K⁻¹·F. ¿Y de dónde sale K? Se ENSAMBLA de las barras. Cada barra tiene su rigidez de flexión, deducida de las funciones de forma en el ejemplo 24:
K_barra = [12, 6, -12, 6; 6, 4, -6, 2; -12, -6, 12, -6; 6, 2, -6, 4] @@(rigidez de una barra: EI=1, L=1)
#: En cada grado de libertad se SUMAN las barras que lo tocan. El giro θ_B lo comparten la viga (4) y la columna izquierda (4); el ladeo Δ lo empujan las dos columnas (12 y 12); el término θ_B–θ_C es solo la viga (2) y el giro–ladeo es la columna (−6):
kBB = 4 + 4 @@(θ_B: viga + columna izq)
kCC = 4 + 4 @@(θ_C: viga + columna der)
kDD = 12 + 12 @@(Δ: las dos columnas)
K = [kBB, 2, -6; 2, kCC, -6; -6, -6, kDD] @@(K del pórtico, ensamblada de las barras)
F = [0; 0; 1] @@(la carga H va en el ladeo Δ)
u = K^-1 * F @@(u = K⁻¹·F = [θ_B ; θ_C ; Δ])
#: De ese vector saco cada desplazamiento (una fila selectora × u toma la componente):
theta_B = [1 0 0]*u @@(giro esquina izquierda)
theta_C = [0 1 0]*u @@(giro esquina derecha)
Delta = [0 0 1]*u @@(ladeo del tope)
#: Con esos datos hay que DIBUJAR la curva que toma cada barra entre sus nudos.

## 1 · ANTES del FEM — integrando la elástica (clásico)
#: ¿De dónde parte? De la física de la barra. Un tramo SIN carga cumple EI·v'''' = 0 (nada la dobla de más). Integrando esa ecuación cuatro veces —cada ∫ sube un grado: 0 → constante → recta → parábola → cúbica— la flecha v(x) queda como una CÚBICA con 4 constantes. Sus ingredientes:
base = [1 x x^2 x^3] @@(v = a·base = una cúbica)
#: Las 4 constantes se fijan con los 4 datos de los EXTREMOS de la barra. La columna izquierda: abajo empotrada (v=0, θ=0) y arriba con el ladeo Δ y el giro θ_B. De u global selecciono esos 4:
u_col = [0 0 0; 0 0 0; 0 0 1; 1 0 0]*u @@(v,θ abajo=0 · arriba Δ=u₃, θ_B=u₁)
#: Meter esos 4 datos en la cúbica y en su pendiente arma el sistema C·a = u_col. Despejando las constantes:
C = [1 0 0 0; 0 1 0 0; 1 1 1 1; 0 1 2 3] @@(las 4 condiciones de los extremos)
a = C^-1 * u_col @@(a = C⁻¹·u_col)
v_clasico = base*a @@(la deformada de la columna)
#: Esa cúbica es la curva que toma la columna. Dibujada:
#fplot(x^2/7 - x^3/12, [0 1])
#: ¿De veras es una barra sin carga? Se comprueba: derivo la flecha hasta la curvatura (2ª derivada) y tiene que salir LINEAL. El motor deriva:
vp = Diff{x^2/7 - x^3/12 @ x} @@(pendiente = v')
curv = Diff{2*x/7 - x^2/4 @ x} @@(curvatura = v'' → sale LINEAL)
#: Y al revés — la doble integración de la elástica que se hacía A MANO: integro esa curvatura dos veces, con la base empotrada (pendiente y flecha valen 0 abajo → constantes 0), y RECUPERO la misma flecha:
pend = Integral{2/7 - x/2 @ x} @@(∫ curvatura = pendiente)
flecha = Integral{2*x/7 - x^2/4 @ x} @@(∫ pendiente = la misma flecha)
#: Lo laborioso del clásico: esto había que rehacerlo barra por barra, cada una con su propio u.

## 2 · CON FEM — funciones de forma (sin integrar por barra)
#: Las Hermite YA son la solución de EI·v''''=0 con datos de borde unitarios: la integración se hizo UNA vez, para siempre. La deformada de la barra es N·u = cada dato por su peso. En la columna los dos datos no nulos son Δ (peso H₃) y θ (peso H₄):
H3 = 3*x^2-2*x^3 @@(peso del desplazamiento del tope)
H4 = -x^2+x^3 @@(peso del giro del tope)
v_fem = H3*Delta + H4*theta_B @@(deformada FEM = H₃·Δ + H₄·θ)
#: Da la MISMA cúbica que el clásico. Dibujada (idéntica):
#fplot(x^2/7 - x^3/12, [0 1])

## 3 · La deformada del pórtico completo
#: Cada barra se dibuja con su cúbica; juntas dan la deformada del pórtico (punteado = sin deformar):
#framedef(5/84, 1/28, 1/28)
#: El clásico integraba la elástica de CADA barra a mano; el FEM reusa las mismas 4 funciones de forma y solo hace N·u. Mismo dibujo. El FEM es esa doble integración hecha una vez y guardada en las Hermite.
