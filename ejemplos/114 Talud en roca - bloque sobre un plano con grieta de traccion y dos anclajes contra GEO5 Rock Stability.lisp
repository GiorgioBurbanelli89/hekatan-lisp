# Talud en roca: bloque que desliza sobre un plano, con grieta de tracción y dos anclajes, contra GEO5
#numerico

#: **Qué se calcula.** El ejemplo oficial de GEO5 Rock Stability (**Demo01.gsk**, etapa 1): un macizo rocoso cortado por una diaclasa que cae hacia afuera a 46°. El bloque que queda encima, separado detrás por una grieta de tracción vertical, puede **deslizar sobre la diaclasa**. Dos anclajes activos de 95 kN lo cosen a la roca sana.
#: **Cómo.** Equilibrio de un solo bloque rígido (ayuda de GEO5: «Plane Slip Surface», «Anchorage of Rock Slope», «Mohr-Coulomb», «Verification According to the Factor of Safety»). Todas las fuerzas se descomponen en la dirección **normal** al plano y en la dirección **del deslizamiento**. Las fórmulas se leyeron de la ayuda del propio GEO5 2024.
#: **Juez.** El cuadro «Analysis → In detail» de GEO5 2024 con este archivo. Al final, la tabla **Hekatan contra GEO5** con la diferencia en %.
#: **Unidades.** kN, m y kPa por metro de talud (como GEO5); el peso también en tonf (1 tonf = 9.80665 kN). Dentro de las fórmulas los ángulos van en radianes.

## 1 · Datos del ejemplo (Demo01.gsk)

#: **El perfil del talud.** GEO5 lo da por tramos (inclinación y longitud), pero guarda los vértices con dos decimales; son estos (x hacia el talud, z hacia arriba):
x_1 = 0 'pie del talud [m]
z_1 = 0
x_2 = 2 'arriba del primer tramo, a 70° [m]
z_2 = 5.5
x_3 = 1 'el voladizo: el segundo tramo vuelve hacia afuera, a 120° [m]
z_3 = 7.23
x_4 = 6 'arriba del tercer tramo, a 50° [m]
z_4 = 13.19
x_5 = 18 'coronación, tramo a 10° [m]
z_5 = 15.31
#: **La roca** (criterio de Mohr-Coulomb sobre la diaclasa):
gamma_r = 15 'peso específico de la roca (dato del ejemplo) [kN/m3]
phi_r = 36 'ángulo de rozamiento en la diaclasa [grados]
c_r = 15 'cohesión en la diaclasa [kPa]
#: **La superficie de deslizamiento** (marco «Sl. surface»): un punto del plano, su inclinación y la grieta de tracción vertical (inclinación 0° respecto a la vertical) a 9 m del origen. La superficie es **lisa** (smooth).
x_p = 1 'punto del plano, x [m]
z_p = 2 'punto del plano, z [m]
alpha_g = 46 'inclinación del plano [grados]
x_g = 9 'distancia de la grieta de tracción [m]
#: **Los anclajes** (marco «Anchors»): dos, activos (pretensados), de 95 kN cada uno, con 10° de inclinación hacia abajo, separados 1 m a lo largo del talud.
n_a = 2 'número de anclajes
P_a = 95 'fuerza de pretensado de cada anclaje [kN]
beta_a = 10 'inclinación del anclaje bajo la horizontal [grados]
s_a = 1 'separación de los anclajes a lo largo del talud [m]
#: **Lo que exige GEO5 en el ejemplo** (Settings: factores de seguridad, ASD): SF_{s} = 1.50.
SF_s = 1.5 'factor de seguridad pedido

#: Los tres ángulos, en radianes para las fórmulas:
a_r = alpha_g·pi/180 'inclinación del plano α [rad]
b_r = beta_a·pi/180 'inclinación del anclaje β [rad]
f_r = phi_r·pi/180 'rozamiento φ [rad]

## 2 · La geometría del bloque

#: **Por dónde sale el plano al talud.** El plano pasa por (x_{p}, z_{p}) con pendiente tan α: z = z_{p} + (x − x_{p})·tan α. El primer tramo del talud es la recta z = (z_{2}/x_{2})·x. Donde se cortan, el plano sale al aire («aflora»):
m_1 = z_2/x_2 'pendiente del primer tramo del talud
x_0 = (z_p - x_p·tan(a_r))/(m_1 - tan(a_r)) 'abscisa del afloramiento [m]
z_0 = m_1·x_0 'cota del afloramiento [m]
#: **Dónde corta el plano a la grieta** (x = x_{g}) y dónde llega la grieta al terreno (el tramo 4–5):
z_b = z_p + (x_g - x_p)·tan(a_r) 'fondo de la grieta, sobre el plano [m]
z_t = z_4 + (x_g - x_4)·(z_5 - z_4)/(x_5 - x_4) 'boca de la grieta, en el terreno [m]
h_g = z_t - z_b 'altura de la grieta [m]
#: **Largo de la superficie de deslizamiento**, del afloramiento a la grieta:
L_s = (x_g - x_0)/cos(a_r) 'largo del plano [m]
#: **El área del bloque.** Es el polígono afloramiento → vértices 2, 3, 4 del talud → boca de la grieta → fondo de la grieta. Con la fórmula del área de Gauss («del cordón de zapato»): A = ½·Σ (x_{i}·z_{i+1} − x_{i+1}·z_{i}), dando la vuelta completa:
X_b = [x_0; x_2; x_3; x_4; x_g; x_g] 'abscisas del polígono [m]
Z_b = [z_0; z_2; z_3; z_4; z_t; z_b] 'cotas del polígono [m]
#hide
S_a = 0
for i = 1:6
  j = i + 1
  if i == 6
    j = 1
  end
  S_a = S_a + X_b(i)·Z_b(j) - X_b(j)·Z_b(i)
end
#show
A_b = abs(S_a)/2 'área del bloque [m2]

#dibujo("Demo01.gsk: el bloque (rayado) sobre la diaclasa a 46°, la grieta de tracción y los dos anclajes", ud = m, escala = auto, cotas = m, alto = 170)
#  polilinea([0, 2, 1, 6, 18], [0, 5.5, 7.23, 13.19, 15.31], "gruesa")
#  linea(-1, 0, 0, 0, "media")
#  achurado([x_0, 2, 1, 6, 9, 9], [z_0, 5.5, 7.23, 13.19, z_t, z_b], "diagonal")
#  poligono(x_0, z_0, 2, 5.5, 1, 7.23, 6, 13.19, 9, z_t, 9, z_b, "media rojo")
#  linea(x_0, z_0, 14, z_p + 13·tan(a_r), "trazos rojo")
#  linea(1.98, 5.53, 1.98 + 10·cos(b_r), 5.53 - 10·sin(b_r), "media azul")
#  linea(3.54, 10.26, 3.54 + 10·cos(b_r), 10.26 - 10·sin(b_r), "media azul")
#  flecha(0.2, 6.4, 1.98, 5.53, "azul")
#  texto(5.3, 3.4, "anclajes 2 × 95 kN, 10°", 2.6, "i", estilo = "azul")
#  texto(9.3, 11.9, "grieta de tracción", 2.6, "i")
#  texto(10.5, 8.6, "diaclasa α = 46°", 2.6, "i", estilo = "rojo")
#  texto(4.6, 9.9, "W", 3.0, "c")
#  circulo(x_0, z_0, 0.12, "rojo relleno")
#  texto(x_0 + 0.25, z_0 - 0.4, "afloramiento", 2.4, "i", estilo = "rojo")
#  cota(0, -0.6, 9, -0.6, -0.3, "x = 9.00")
#fin

## 3 · Las fuerzas sobre el bloque

#: **Peso.** El área por el peso específico, por metro de talud:
W_z = gamma_r·A_b 'peso del bloque [kN/m]
W_t = W_z/9.80665 'el mismo peso en tonf/m
#: **Anclajes.** Por metro de talud valen n·P/s. GEO5 da sus dos componentes:
F_a = n_a·P_a/s_a 'fuerza total de los anclajes por metro [kN/m]
F_ax = F_a·cos(b_r) 'componente horizontal (hacia la roca) [kN/m]
F_az = F_a·sin(b_r) 'componente vertical (hacia abajo) [kN/m]
#: **Proyección sobre el plano.** El bloque baja por la diaclasa en la dirección (−cos α, −sen α); la normal que aprieta el plano es (sen α, −cos α).
#: — El peso, vertical, da W·cos α de normal y W·sen α de empuje hacia abajo del plano.
#: — El anclaje forma con el plano el ángulo α + β (α hacia arriba de la horizontal, β hacia abajo). Aprieta el plano con F·sen(α + β) y **frena** el bloque con F·cos(α + β). Como es activo (pretensado), GEO5 resta esa parte de las fuerzas que empujan («the tangent component … is subtracted from the shear (active) forces»).
#: N = W·cos α + F·sen(α + β)
#: T_{act} = W·sen α − F·cos(α + β)
N_n = W_z·cos(a_r) + F_a·sin(a_r + b_r) 'fuerza normal sobre el plano [kN/m]
T_act = W_z·sin(a_r) - F_a·cos(a_r + b_r) 'fuerza que empuja el bloque [kN/m]
#: **Resistencia** de Mohr-Coulomb a lo largo de todo el plano (ayuda: τ = c + (N/l)·tan φ):
#: T_{res} = c·L + N·tan φ
T_res = c_r·L_s + N_n·tan(f_r) 'fuerza que resiste [kN/m]
tau_r = T_res/L_s 'tensión de corte resistente media [kPa]
#: **Factor de seguridad** (ayuda: SF = T_{res}/T_{act} > SF_{s}):
FS = T_res/T_act 'factor de seguridad al deslizamiento
#hide
r_fs = round(FS, 2)
r_c = round(100·c_r·L_s/T_res, 1)
W_0 = W_z·sin(a_r)
FS_0 = (c_r·L_s + W_z·cos(a_r)·tan(f_r))/W_0
r_f0 = round(FS_0, 2)
#show
#: **Lectura.** FS = @{r_fs} > 1.50: **cumple**. La cohesión da el @{r_c} % de la resistencia. Sin los anclajes el mismo bloque tendría FS = @{r_f0}: los dos anclajes de 95 kN son los que lo llevan por encima de 1.50.

#: **Cuánto anclaje hace falta.** La misma cuenta con la fuerza por metro F como variable (de 0 a 300 kN/m); la recta roja es el 1.50 pedido:
#fplot(FS = (c_r·L_s + (W_z·cos(a_r) + x·sin(a_r + b_r))·tan(f_r))/(W_z·sin(a_r) - x·cos(a_r + b_r)), limite = 1.5, [0 300])
#: Con F = 190 kN/m (este ejemplo) FS = 1.83; el 1.50 se alcanza hacia los 114 kN/m.

## 4 · Hekatan contra GEO5

#hide
g_L = 12.15
g_al = 46.00
g_W = 603.03
g_Fx = 187.11
g_Fz = 32.99
g_N = 576.42
g_tau = 49.48
g_Tr = 600.98
g_Ta = 327.54
g_FS = 1.83
h_L = round(L_s, 2)
h_W = round(W_z, 2)
h_Fx = round(F_ax, 2)
h_Fz = round(F_az, 2)
h_N = round(N_n, 2)
h_tau = round(tau_r, 2)
h_Tr = round(T_res, 2)
h_Ta = round(T_act, 2)
h_FS = round(FS, 2)
h_FS4 = round(FS, 4)
x_L = round(100·(h_L/g_L - 1), 3)
x_W = round(100·(h_W/g_W - 1), 4)
x_Fx = round(100·(h_Fx/g_Fx - 1), 4)
x_Fz = round(100·(h_Fz/g_Fz - 1), 4)
x_N = round(100·(h_N/g_N - 1), 4)
x_tau = round(100·(h_tau/g_tau - 1), 4)
x_Tr = round(100·(h_Tr/g_Tr - 1), 4)
x_Ta = round(100·(h_Ta/g_Ta - 1), 4)
x_FS = round(100·(h_FS/g_FS - 1), 2)
#show
#| Magnitud | Hekatan | GEO5 2024 | Diferencia [%] |
#|---|---:|---:|---:|
#| largo del plano l [m] | @{h_L} | @{g_L} | @{x_L} |
#| peso del bloque W_{z} [kN/m] | @{h_W} | @{g_W} | @{x_W} |
#| anclajes F_{ax} [kN/m] | @{h_Fx} | @{g_Fx} | @{x_Fx} |
#| anclajes F_{az} [kN/m] | @{h_Fz} | @{g_Fz} | @{x_Fz} |
#| normal N [kN/m] | @{h_N} | @{g_N} | @{x_N} |
#| tensión resistente τ [kPa] | @{h_tau} | @{g_tau} | @{x_tau} |
#| **T_{res} [kN/m]** | @{h_Tr} | @{g_Tr} | @{x_Tr} |
#| **T_{act} [kN/m]** | @{h_Ta} | @{g_Ta} | @{x_Ta} |
#| **FS** | @{h_FS} | @{g_FS} | @{x_FS} |
#: Diferencias con el valor de Hekatan redondeado a los decimales que imprime GEO5. Todo es igual. Sin redondear, FS = @{h_FS4}.
#: **Lo único que hubo que averiguar:** el perfil. Con la tabla de GEO5 (70°, 120°, 50°, 10° y las longitudes) el área sale 40.18 m² y el peso 602.7 kN/m; con los vértices de dos decimales que GEO5 dibuja y guarda, 40.20 m² y **603.03**, el suyo. GEO5 trabaja con los vértices.

## 5 · Comprobación con la NEC-SE-GC 2015

#: La NEC-SE-GC 2015, Tabla 4 (p. 31), pide para taludes un FS por corte de **1.50** en condición estática (diseño) y **1.05** pseudoestática; su nota dice que vale también para roca. GEO5 compara con el SF_{s} = 1.50 de su ajuste, que coincide con el estático de la NEC.
#: **Estático:** FS = @{r_fs} ≥ 1.50 → **cumple**.
#: **Pseudoestático (cálculo de Hekatan, no de GEO5).** La NEC-15 da k_{h} = 0.6·Z·F_{a}. Por ejemplo, zona V (Z = 0.40) y suelo tipo B de roca (F_{a} = 1.0): k_{h} = 0.24. GEO5 aplica S = k_{h}·W horizontal, hacia afuera, en el centro de gravedad del bloque (ayuda «Influence of Seismic Effects»); proyectada sobre el plano quita k_{h}·W·sen α a la normal y suma k_{h}·W·cos α al empuje:
Z_s = 0.4 'factor de zona sísmica (zona V)
F_as = 1.0 'amplificación del suelo, perfil B (roca)
k_h = 0.6·Z_s·F_as 'coeficiente sísmico horizontal (NEC-15)
N_s = N_n - k_h·W_z·sin(a_r) 'normal con sismo [kN/m]
T_as = T_act + k_h·W_z·cos(a_r) 'empuje con sismo [kN/m]
FS_s = (c_r·L_s + N_s·tan(f_r))/T_as 'factor de seguridad pseudoestático
#hide
r_fss = round(FS_s, 2)
k_23 = 0.6·Z_s
FS_23 = (c_r·L_s + (N_n - k_23·W_z·sin(a_r))·tan(f_r))/(T_act + k_23·W_z·cos(a_r))
r_f23 = round(FS_23, 2)
#show
#: Con sismo FS = @{r_fss} ≥ 1.05: **cumple** la NEC-15. El borrador NEC-SE-GC 2023 (**no oficial**, solo como valores) quita el F_{a} (k_{h} = 0.6·Z = 0.24, el mismo número aquí porque F_{a} = 1) y sube el mínimo a 1.15: FS = @{r_f23} ≥ 1.15, también cumple.
#: Este último cálculo no se comprobó contra GEO5 (el ejemplo no trae sismo); la proyección de la fuerza sísmica es la misma que la del peso, con el ángulo girado 90°.
