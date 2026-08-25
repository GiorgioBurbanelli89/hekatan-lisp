# Deformada de un pórtico: cómo se dibujaba ANTES del FEM vs con FEM
#: La misma curva por los dos caminos. **Antes** (clásico) se integraba la elástica de cada barra. **Ahora** (FEM) las funciones de forma ya llevan esa integración hecha. Mismo resultado, misma gráfica. Todo con el motor.

## 0 · El problema
#: Pórtico de un vano, bases empotradas, carga lateral H en la esquina superior izquierda. Sin deformar:
#frame(fixed-fixed, H)
#: Resolviendo la estructura (ejemplos 22 y 24) los nudos se mueven: el tope ladea Δ y las esquinas giran θ_B, θ_C. Con esos datos hay que DIBUJAR la curva que toma cada barra entre sus nudos:
Delta = 5/84 @@(ladeo del tope)
theta_B = 1/28 @@(giro esquina izquierda)
theta_C = 1/28 @@(giro esquina derecha)

## 1 · ANTES del FEM — integrando la elástica (clásico)
#: En un tramo sin carga la barra cumple EI·v'''' = 0. Cada integración sube el grado; integrando, v(x) sale CÚBICA. El motor muestra que una integral ya sube el grado:
p1 = Integral{-2+3*x @ x} @@(integrar una lineal → una cuadrática)
#: Entonces v es una cúbica con 4 constantes. Se fijan con los 4 datos de los EXTREMOS de la barra. Tomo la columna izquierda: abajo empotrada (ni baja ni gira) y arriba con el ladeo y el giro del nudo:
u_col = [0; 0; Delta; theta_B] @@(abajo v=0,θ=0 · arriba Δ,θ)
#: Meter esos 4 datos en la cúbica y en su pendiente arma el sistema C·a = u. Resolverlo (a mano se hacía integrando; aquí lo despejo) da las constantes de ESTA barra:
C = [1 0 0 0; 0 1 0 0; 1 1 1 1; 0 1 2 3] @@(las 4 condiciones de los extremos)
a = C^-1 * u_col @@(a = C⁻¹·u_col = las constantes de la cúbica)
base = [1 x x^2 x^3]
v_clasico = base*a @@(deformada de la columna = base·a)
#: Esa cúbica es la curva que toma la columna. Dibujada:
#fplot(x^2/7 - x^3/12, [0 1])
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
