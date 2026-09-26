# La cáscara que rota sin romperse — Simo·Fox·Rifai (1990)
#: Documento autocontenido en Hekatan LISP. El texto explica; lo que el **motor puede calcular se calcula de verdad** (roll-up, la norma del director, la constitutiva).
#: Fuente: J.C. Simo, D.D. Fox, M.S. Rifai — *On a stress resultant geometrically exact shell model, Part III*, CMAME **79** (1990) 21–70.

## 1 · El problema, en una frase
#: Una cáscara delgada bajo cargas grandes **gira mucho** (una viga plana se puede enrollar en un círculo completo). Si describes ese giro con **ángulos de Euler**, en cierto punto **se atascan** (singularidad de Gimbal): dos ejes se alinean y pierdes un grado de libertad. El elemento revienta.
#: La idea del paper: **no guardes ángulos**. Guarda la **normal** de la cáscara —el *director* **t**— y hazla **rodar sobre la esfera**. Rodar nunca se atasca.

## 2 · Dónde vive el director: la esfera S²
#: El director es un vector **unitario**: apunta, no mide. Por eso vive en la esfera de radio 1, que se llama **S²**.
#: La regla madre es que su norma vale siempre uno:  ‖t‖ = 1.
#: Un incremento **Δt** admisible es **tangente** a la esfera, o sea **perpendicular** al director:  t · Δt = 0.
#: Esa perpendicularidad es la que deja **2 grados de libertad** al giro del director (no 3): moverse sobre una superficie 2D.

## 3 · El corazón: el mapa exponencial (Box 2)
#: Para actualizar el director en cada iteración de Newton, en vez de sumar `t + Δt` (que se saldría de la esfera), lo hace **rodar por un arco de círculo máximo**. Con θ = ‖Δt‖ el tamaño del paso angular, la fórmula (2.7)/(4.9) es:
#|  t_nuevo  =  cos(θ)·t  +  ( sin(θ) / θ )·Δt
#: La pregunta clave: **¿sigue siendo unitario el nuevo director?** Como t ⊥ Δt y ‖t‖ = 1, al elevar la norma al cuadrado los términos cruzados se anulan y queda **cos²θ + sin²θ**. Lo **calculo con el motor** en dos pasos, uno pequeño y otro grande:
theta_chico = 0.6
unitario_chico = cos(0.6)^2 + sin(0.6)^2
unitario_grande = cos(3.0)^2 + sin(3.0)^2
#: El motor devuelve **1** en ambos (salvo redondeo). Da igual que el paso sea de 0.6 rad o de 3 rad (≈172°): el director cae **clavado** sobre la esfera. Ahí está, sin singularidad (Remark 4.2), el porqué de todo el paper.

## 4 · La geodésica, dibujada
#: Al rodar, las dos componentes del director —la que apunta a **t** y la que apunta a **Δt**— **se intercambian** manteniendo cos²+sin²=1. Es exactamente un coseno y un seno recorriendo el círculo:
#fplot(cos(x), sin(x), [0 6.283])
#: Cada punto (cos θ, sin θ) está a distancia 1 del centro. Eso **es** la esfera vista de canto: el director nunca se aleja del radio unidad.

## 5 · La rotación asociada: Rodrigues (SO(3))
#: Rodar el director equivale a aplicarle una **rotación ΔΛ**, con eje **t × Δt**. La fórmula (2.9) es la clásica de **Rodrigues**:
#|  ΔΛ  =  cos(θ)·1  +  ( sin(θ) / θ )·[t×Δt]  +  ( (1−cos θ) / θ² )·(t×Δt)⊗(t×Δt)
#: y la matriz de rotación del nudo se **acumula** producto a producto:  Λ_nuevo = ΔΛ · Λ.
#: Esto es un sistema de **2 GDL implícito** (Remark 4.3): la tercera rotación —el giro alrededor del propio director— queda **amarrada**, no es libre. Guarda este dato para la §9.

## 6 · Por qué se enrolla en círculo perfecto (roll-up)
#: Test clásico (§6.1.1): viga plana empotrada, momento en la punta. La teoría dice que se curva con radio ρ dado por  1/ρ = M/(E·I). Datos del paper:
E_viga = 12·10^6
w = 1
t_k = 0.1
L = 10
I_viga = w·t_k^3/12
EI_viga = E_viga·I_viga
#: El momento que da la **vuelta completa** es M = 2π·EI/L. Uso 2π como número (τ):
τ = 6.2831853
M_rot = τ·EI_viga/L
#: El radio con que se enrolla y su **perímetro**:
ρ = EI_viga/M_rot
perimetro = τ·ρ
#: El motor da **perímetro = 10 = L**: la viga de largo {L} se enrolla **una vez justa**, en **un solo paso de carga**, con 25 elementos. Ninguna formulación de ángulos aguanta eso sin atascarse.

## 7 · El elemento: QUAD de 4 nudos, formulación mixta
### (a) Los tres campos y su plantilla común
#: El QUAD bilineal parte la energía en tres piezas —**membrana**, **cortante**, **flexión**— y cada una sigue la **misma receta** (Apéndice C):  deformación ε → tensión σ = ℂ·ε → rigidez material Km = BᵀℂB → rigidez geométrica Kg → residuo R.
### (b) La constitutiva de flexión, con números
#: La rigidez de flexión (ec. 2.37) para E=12·10⁶, ν=0.3, t=0.1. El motor la calcula (nombre D_b para no chocar con la D del motor):
D_b = E_viga·t_k^3/(12·(1-0.3^2))
C_b = D_b·[1 0.3 0; 0.3 1 0; 0 0 0.35]
#: El factor 1/(1−ν²) es la rigidización por **estado plano** —la misma D₀ que ya usamos en las placas.
### (c) El truco anti-bloqueo: cortante supuesto (MITC4)
#: Un QUAD ingenuo **se bloquea** a cortante (sale infinitamente rígido al adelgazar). Simo lo evita evaluando el cortante **no en los puntos de Gauss** sino en los **puntos medios de los lados** A,B,C,D (ec. A.6–A.7). Es el método de **Bathe–Dvorkin / MITC4** —el mismo patrón que aislaste en el Q4 de ETABS.
### (d) La rigidez del elemento: una DOBLE integral
#: Con la constitutiva ℂ (la C_b de arriba) y la matriz **B** —que liga la deformación con los desplazamientos de nudo— la rigidez del elemento es una **doble integral** sobre el cuadrado natural ξ,η ∈ [−1,1]:
#|  K_e  =  ∫₋₁¹ ∫₋₁¹  Bᵀ · ℂ · B · det J  dξ dη
#: Esa integral **no se resuelve a mano**: se aproxima por **cuadratura de Gauss** —evaluar el integrando en unos pocos puntos y sumar con pesos. Para el QUAD bilineal basta **2×2** (cuatro puntos), en ξ,η = ±1/√3, todos con peso 1. Es el mismo Gauss de §7c.
pg = 1/sqrt(3)
#: Lo pruebo con un término escalar tipo BᵀℂB —un polinomio de grado 2, f = ξ²+η², cuya doble integral exacta sobre [−1,1]² es 8/3—. Sumo Gauss en los 4 puntos (±1/√3, ±1/√3):
K_gauss = (pg^2 + pg^2) + (pg^2 + pg^2) + (pg^2 + pg^2) + (pg^2 + pg^2)
#: El motor da **8/3 = 2.6667**, clavado al valor exacto: Gauss 2×2 integra sin error hasta grado 3, y BᵀℂB de un QUAD bilineal cae justo en ese rango. Así se arma, punto de Gauss a punto de Gauss, **cada una de las 12×12 entradas** de K_e —la matriz del paso siguiente.
### (e) Las matrices del elemento son grandes → colapso automático
#: La constitutiva C_b es 3×3 (chica). Pero la **rigidez del elemento** K_e es **12×12** (4 nudos × 3 GDL). Cuando una matriz pasa de 9 columnas u 11 filas —o un vector de más de 9— Hekatan LISP pone los **índices en los bordes** y **colapsa el centro** con … ⋮ ⋱ (como NumPy/MATLAB). Demostración con la identidad 12×12 (a la que converge K_e·K_e⁻¹) y un vector de 15:
Id = [1 0 0 0 0 0 0 0 0 0 0 0; 0 1 0 0 0 0 0 0 0 0 0 0; 0 0 1 0 0 0 0 0 0 0 0 0; 0 0 0 1 0 0 0 0 0 0 0 0; 0 0 0 0 1 0 0 0 0 0 0 0; 0 0 0 0 0 1 0 0 0 0 0 0; 0 0 0 0 0 0 1 0 0 0 0 0; 0 0 0 0 0 0 0 1 0 0 0 0; 0 0 0 0 0 0 0 0 1 0 0 0; 0 0 0 0 0 0 0 0 0 1 0 0; 0 0 0 0 0 0 0 0 0 0 1 0; 0 0 0 0 0 0 0 0 0 0 0 1]
gdl = 1:15

## 8 · El tangente exacto y por qué importa
#: Newton necesita la derivada del residuo: el **operador tangente**. Simo lo da en **forma cerrada exacta** (§5), partido en material + geométrico. La recompensa es **convergencia cuadrática**: el error se eleva al cuadrado en cada paso. La tabla 6.4.1 del paper, tal cual:
#: iteración 0 → residuo 1.4·10⁰ · iteración 3 → 5.0·10⁻³ · iteración 5 → **2.7·10⁻¹¹**.
#: Cinco pasos y ya está en cero-máquina. Con un tangente aproximado eso **no** pasa —y peor: el **pandeo** sale mal (Remark 5.2). El pandeo se detecta cuando el pivote de la factorización de K_T **cambia de signo** (se vuelve singular).

## 9 · Cómo encaja en tu trabajo (ETABS / drilling)
#: **(1)** Es la línea **Taylor–Simo** que ya identificamos detrás del shell de CSI. El **MITC4** de la §7c es el mismo assumed-strain del Q4 de ETABS.
#: **(2)** Este elemento tiene **5 GDL** por nudo (3 de φ + 2 del director). El **drilling** que aislaste (k₀=0.4·G) es justo el **6º** que aquí falta —Remark 4.3 lo dice: *«el sistema 3-DOF rotacional se trata en otro paper»*. Este es el escalón previo.
#: **(3)** El **mapa exponencial en S²/SO(3)** de la §3 es la herramienta que vas a necesitar para llevar tu shell al **no lineal** (grandes rotaciones), lo que ETABS lineal no hace.

## 10 · Glosario mínimo
#: **director** (t): la normal unitaria de la cáscara. **S²**: la esfera de radio 1, donde vive el director. **SO(3)**: el grupo de rotaciones 3D. **mapa exponencial**: rodar por la geodésica sin salirse de la esfera. **geométricamente exacto**: vale para rotaciones de cualquier tamaño, sin aproximar. **MITC4**: cortante evaluado en los puntos medios de lado (anti-bloqueo). **tangente consistente**: la derivada exacta del residuo → Newton cuadrático. **bifurcación**: donde K_T se vuelve singular (pandeo).
#> Simo · Fox · Rifai (1990), Parte III · Stanford · continúa la Parte I (formulación) y II (lineal).
