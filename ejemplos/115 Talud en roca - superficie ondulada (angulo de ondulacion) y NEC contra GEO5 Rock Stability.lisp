# Talud en roca con la diaclasa ondulada: el ángulo de ondulación y la NEC, contra GEO5
#numerico

#: **Qué se calcula.** La etapa 2 del ejemplo oficial de GEO5 Rock Stability (**Demo01.gsk**). Es el mismo bloque de la hoja 114 (diaclasa a 46°, grieta de tracción, dos anclajes de 95 kN), pero ahora la diaclasa **no es lisa: es ondulada**, con un ángulo de ondulación ν = 15°. GEO5 pasa de FS = 1.83 a FS = 2.31.
#: **Por qué cambia.** Una diaclasa real no es un plano perfecto: tiene ondas de 1 a 10 m. Para que el bloque deslice tiene que **subir** por las ondas, y eso exige más fuerza que deslizar sobre un plano liso.
#: **Cómo.** Las fórmulas de la ayuda de GEO5 2024 («Undulated Slip Surface», con la referencia de Miller, 1988) y las del bloque plano («Plane Slip Surface»).
#: **Juez.** El cuadro «Analysis → In detail» de la etapa 2 de GEO5 2024. Al final, la tabla **Hekatan contra GEO5**.
#: **Unidades.** kN, m y kPa por metro de talud; el peso también en tonf (1 tonf = 9.80665 kN).

## 1 · Datos (los de la hoja 114, más la ondulación)

#: El perfil del talud (vértices que guarda GEO5), la roca, el plano, la grieta y los anclajes son los mismos de la etapa 1:
z_2 = 5.5 'cota del vértice 2 del talud (x = 2) [m]
x_2 = 2 'abscisa del vértice 2 [m]
gamma_r = 15 'peso específico de la roca [kN/m3]
phi_r = 36 'ángulo de rozamiento en la diaclasa [grados]
c_r = 15 'cohesión en la diaclasa [kPa]
x_p = 1 'punto del plano, x [m]
z_p = 2 'punto del plano, z [m]
alpha_g = 46 'inclinación media del plano [grados]
x_g = 9 'distancia de la grieta de tracción [m]
F_a = 190 'anclajes: 2 × 95 kN cada 1 m [kN/m]
beta_a = 10 'inclinación de los anclajes bajo la horizontal [grados]
#: **Lo nuevo de la etapa 2** (marco «Sl. surface», Slip surface type = undulated):
nu_g = 15 'ángulo de ondulación ν [grados]
SF_s = 1.5 'factor de seguridad pedido en el ejemplo
#: Los ángulos en radianes, para las fórmulas:
a_r = alpha_g·pi/180 'inclinación del plano α [rad]
b_r = beta_a·pi/180 'inclinación de los anclajes β [rad]
f_r = phi_r·pi/180 'rozamiento φ [rad]
n_r = nu_g·pi/180 'ondulación ν [rad]

## 2 · El bloque: lo mismo que en la etapa 1

#: Afloramiento del plano en el primer tramo del talud y largo hasta la grieta (hoja 114, sección 2):
x_0 = (z_p - x_p·tan(a_r))/(z_2/x_2 - tan(a_r)) 'abscisa del afloramiento [m]
L_s = (x_g - x_0)/cos(a_r) 'largo de la superficie de deslizamiento [m]
#: El área del bloque, con el mismo polígono de la hoja 114 (afloramiento, vértices 2, 3 y 4, boca y fondo de la grieta):
X_b = [x_0; 2; 1; 6; 9; 9] 'abscisas del polígono [m]
Z_b = [z_2/x_2·x_0; 5.5; 7.23; 13.19; 13.72; z_p + (x_g - x_p)·tan(a_r)] 'cotas del polígono [m]
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
W_z = gamma_r·A_b 'peso del bloque [kN/m]
W_t = W_z/9.80665 'el mismo peso en tonf/m
#: La normal y el empuje no dependen de la ondulación (las ondas cambian la **resistencia**, no las cargas):
N_n = W_z·cos(a_r) + F_a·sin(a_r + b_r) 'normal sobre el plano medio [kN/m]
T_act = W_z·sin(a_r) - F_a·cos(a_r + b_r) 'fuerza que empuja el bloque [kN/m]

## 3 · Qué hace la ondulación

#: **El ángulo de ondulación.** Si la superficie sube y baja alrededor del plano medio (inclinación α), con tramos de inclinaciones α_{i}, la ayuda de GEO5 lo define como ν = α − min(α_{i}): cuánto se aparta del plano medio el tramo más tendido. Es el ángulo que el bloque tiene que «remontar». Aquí GEO5 lo pide directamente: ν = 15°.
#dibujo("La diaclasa ondulada: el bloque desliza a lo largo del plano medio pero tiene que remontar cada onda con el ángulo ν", ud = m, cotas = m, escala = auto, alto = 110)
#  linea(0, 0, 12, 0, "trazos gris")
#  polilinea([0, 1.5, 3, 4.5, 6, 7.5, 9, 10.5, 12], [0, 0.4, 0, 0.4, 0, 0.4, 0, 0.4, 0], "gruesa rojo")
#  rect(3.6, 0.42, 3.0, 1.4, "media")
#  achurado(3.6, 0.42, 3.0, 1.4, "diagonal")
#  flecha(6.6, 1.1, 8.4, 1.1, "negro")
#  texto(7.0, 1.35, "deslizamiento", 2.4, "i")
#  flecha(4.6, -0.6, 4.6, 0.25, "azul")
#  texto(4.75, -0.55, "σ_{n}", 2.6, "i", estilo = "azul")
#  linea(6, 0, 7.5, 0, "fina")
#  texto(7.6, 0.05, "plano medio (α)", 2.4, "i", estilo = "gris")
#  texto(6.35, 0.17, "ν", 3.0, "c", estilo = "rojo")
#  cota(0, -1.0, 3, -1.0, -0.05, "longitud de onda 3.0 m")
#  cota(12.4, 0, 12.4, 0.4, 0.05, "0.4")
#  cota(3.6, 2.05, 6.6, 2.05, 0.05, "bloque 3.0 m")
#fin
#: **El aumento de resistencia** (ayuda de GEO5, fórmula de la página «Undulated Slip Surface»): la ondulación suma a la tensión de corte resistente
#: Δτ = σ_{n}·tan ν
#: donde σ_{n} es la tensión normal sobre el plano. Integrada a lo largo de toda la superficie (σ_{n}·L = N), la resistencia del bloque queda
#: T_{res} = c·L + N·tan φ + N·tan ν
#: Primero cada parte por separado:
s_n = N_n/L_s 'tensión normal media sobre la diaclasa [kPa]
D_tau = s_n·tan(n_r) 'aumento de la tensión resistente por la ondulación [kPa]
T_c = c_r·L_s 'parte de la cohesión [kN/m]
T_f = N_n·tan(f_r) 'parte del rozamiento [kN/m]
T_n = N_n·tan(n_r) 'parte de la ondulación [kN/m]
#: y la suma:
T_res = T_c + T_f + T_n 'fuerza resistente con la diaclasa ondulada [kN/m]
tau_r = T_res/L_s 'tensión de corte resistente media [kPa]
FS = T_res/T_act 'factor de seguridad
#hide
r_fs = round(FS, 2)
r_n = round(100·T_n/T_res, 1)
FS_1 = (T_c + T_f)/T_act
r_f1 = round(FS_1, 2)
FS_p = (T_c + N_n·tan(f_r + n_r))/T_act
r_fp = round(FS_p, 2)
#show
#: **Lectura.** La ondulación aporta el @{r_n} % de la resistencia: el FS sube de @{r_f1} (diaclasa lisa, hoja 114) a **@{r_fs}**.
#: **Ojo, no es la fórmula de Patton.** Patton (1966) suma los ángulos: tan(φ + i). GEO5 suma las tangentes: tan φ + tan ν. Con φ = 36° y ν = 15° no es lo mismo: Patton daría FS = @{r_fp}. Esta hoja usa la de GEO5 porque es la que reproduce su resultado (tabla de abajo).

#: **Cuánto pesa la ondulación.** El FS con ν como variable, de 0° a 25° (x en grados). La recta roja es el 1.50:
#fplot(FS = (c_r·L_s + N_n·tan(f_r) + N_n·tan(x·pi/180))/T_act, limite = 1.5, [0 25])
#: Con ν = 0 es la hoja 114 (1.83); con ν = 15°, 2.31. Crece casi en línea recta porque tan ν ≈ ν para ángulos pequeños.

## 4 · Hekatan contra GEO5

#hide
g_W = 603.03
g_N = 576.42
g_tau = 62.20
g_Tr = 755.44
g_Ta = 327.54
g_FS = 2.31
h_W = round(W_z, 2)
h_N = round(N_n, 2)
h_tau = round(tau_r, 2)
h_Tr = round(T_res, 2)
h_Ta = round(T_act, 2)
h_FS = round(FS, 2)
h_FS4 = round(FS, 4)
x_W = round(100·(h_W/g_W - 1), 4)
x_N = round(100·(h_N/g_N - 1), 4)
x_tau = round(100·(h_tau/g_tau - 1), 4)
x_Tr = round(100·(h_Tr/g_Tr - 1), 4)
x_Ta = round(100·(h_Ta/g_Ta - 1), 4)
x_FS = round(100·(h_FS/g_FS - 1), 2)
#show
#| Magnitud | Hekatan | GEO5 2024 | Diferencia [%] |
#|---|---:|---:|---:|
#| peso del bloque W_{z} [kN/m] | @{h_W} | @{g_W} | @{x_W} |
#| normal N [kN/m] | @{h_N} | @{g_N} | @{x_N} |
#| tensión resistente τ [kPa] | @{h_tau} | @{g_tau} | @{x_tau} |
#| **T_{res} [kN/m]** | @{h_Tr} | @{g_Tr} | @{x_Tr} |
#| **T_{act} [kN/m]** | @{h_Ta} | @{g_Ta} | @{x_Ta} |
#| **FS** | @{h_FS} | @{g_FS} | @{x_FS} |
#: Diferencias con el valor de Hekatan redondeado a los decimales que imprime GEO5. Sin redondear, FS = @{h_FS4}. La única magnitud que cambia respecto a la etapa 1 es T_{res} (600.98 → 755.44), y cambia exactamente en N·tan 15°.

## 5 · Comprobación con la NEC-SE-GC 2015

#: Tabla 4 (p. 31) de la NEC-SE-GC 2015: FS por corte ≥ **1.50** estático y ≥ **1.05** pseudoestático, con k_{h} = 0.6·Z·F_{a}; su nota lo extiende a roca.
#: **Estático:** FS = @{r_fs} ≥ 1.50 → **cumple**, con holgura.
#: **Pseudoestático (cálculo de Hekatan, no comprobado contra GEO5).** Zona V (Z = 0.40), roca de perfil B (F_{a} = 1.0). La fuerza k_{h}·W, horizontal hacia afuera, quita normal y suma empuje; la ondulación actúa sobre la normal que queda:
Z_s = 0.4 'factor de zona sísmica (zona V)
F_as = 1.0 'amplificación del suelo, perfil B (roca)
k_h = 0.6·Z_s·F_as 'coeficiente sísmico horizontal (NEC-15)
N_s = N_n - k_h·W_z·sin(a_r) 'normal con sismo [kN/m]
T_as = T_act + k_h·W_z·cos(a_r) 'empuje con sismo [kN/m]
FS_s = (c_r·L_s + N_s·(tan(f_r) + tan(n_r)))/T_as 'factor de seguridad pseudoestático
#hide
r_fss = round(FS_s, 2)
#show
#: Con sismo FS = @{r_fss} ≥ 1.05 → **cumple** la NEC-15; también el 1.15 del borrador NEC-SE-GC 2023 (**no oficial**; con F_{a} = 1 su k_{h} = 0.6·Z es el mismo).
#: **Advertencia de ingeniería.** El ángulo de ondulación se mide en el macizo (levantamiento de discontinuidades que pide la NEC-SE-GC 2015, 3.4.3, p. 21-22). Aquí aporta la quinta parte de la resistencia: si en obra la diaclasa resulta más lisa, el FS vuelve a 1.83.
