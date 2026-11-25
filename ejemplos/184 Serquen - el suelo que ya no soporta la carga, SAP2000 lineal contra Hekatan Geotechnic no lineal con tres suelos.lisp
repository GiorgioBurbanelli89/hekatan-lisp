# Serquén, «El SAP2000 aplicado al suelo»: ¿qué pasa cuando la carga crece? SAP2000 (lineal) contra Hekatan Geotechnic (Mohr-Coulomb) con tres suelos
#numerico

## 1 · El ejemplo del libro
#: C. Eng. William Rodríguez Serquén, «El SAP2000 aplicado al suelo»: bloque de suelo de 20 × 20 × 10 m en cubos de 0.5 m, arcilla rígida E = 2000 tonf/m², ν = 0.42, carga de 10 tonf/m² sobre 3 × 5 m. El libro solo da E y ν: el suelo es elástico, no tiene resistencia.
#dibujo("Corte por el centro (y = 0): suelo, franja cargada y bulbo", ud = m, escala = auto, cotas = m, alto = 120)
#  achurado(-10, -10, 20, 10, "suelo")
#  rect(-10, -10, 20, 10, "gruesa")
#  carga(-B/2, 0, B/2, 0, 1, 1, "q = {q_l:0} tonf/m²", "rojo")
#  circulo(0, -2.2, 2.2, "azul")
#  texto(0, -2.2, "bulbo", 2.4, "c")
#  cota(-B/2, 0.8, B/2, 0.8, 0, "B = {B:1} m")
#  cota(-10, -10.8, 10, -10.8, 0, "20 m")
#  cota(10.6, -10, 10.6, 0, 0, "H = 10 m")
#  texto(0, -9.4, "base fija · caras laterales con apoyo", 2.4, "c")
#fin
B = 3 'ancho de la franja cargada (lado corto de 3 × 5) [m]
q_l = 10 'carga del libro [tonf/m²]
E_s = 2000 'módulo del suelo, libro [tonf/m²]
gamma = 18/9.80665 'peso específico supuesto, 18 kN/m³ [tonf/m³]

## 2 · Lo que hace SAP2000: una recta
#: El sólido de SAP2000 es elástico lineal: F = K·u con K fija. Si la carga se multiplica por 3, el asiento se multiplica por 3 y nada avisa que el suelo falló. Medido en la GUI de SAP2000 (bloque 3D del libro): 14.095 mm con 10 tonf/m² y 42.285 mm con la combinación ×3 (= 3 × 14.095 exacto).
s_l = Simplify{q*s_1/q_1}
#: En el corte 2D de Hekatan Geotechnic, con el mismo E, la parte lineal sale 8.0988 mm por cada 5 tonf/m²:
k_2d = 5/8.0988 'rigidez lineal del corte 2D [tonf/m² por mm]

## 3 · Lo que el suelo de verdad aguanta: capacidad de carga (símbolos primero)
#: **Arcilla sin drenar (φ = 0), Prandtl 1920:** la cuña de Prandtl bajo la franja da
q_cu = Simplify{(pi + 2)*c_u}
#: **Suelo con c y φ, Terzaghi con los factores de Meyerhof:**
N_q = Simplify{e^(pi*tan(phi))*tan(pi/4 + phi/2)^2}
N_c = Simplify{(N_q - 1)*cot(phi)}
N_g = Simplify{(N_q - 1)*tan(7/5*phi)}
q_u = Simplify{c*N_c + gamma*B*N_g/2}
#: **Por qué es no lineal:** el suelo plastifica primero en los bordes de la franja (donde se concentra el esfuerzo); esa zona ya no toma más carga y la pasa al resto. La rigidez baja con cada incremento hasta que se forma el mecanismo de Prandtl y el suelo falla.

#: **Números** (los tres suelos supuestos: el libro no da resistencia):
c_1 = 5 'arcilla: c_u [tonf/m²]
q_u1 = (pi + 2)·c_1 'Prandtl [tonf/m²]
#hide
fNq(p) = exp(pi·tan(p))·tan(pi/4 + p/2)^2
fNc(p) = (fNq(p) - 1)/tan(p)
fNg(p) = (fNq(p) - 1)·tan(1.4·p)
#show
p_2 = 20·pi/180 'suelo 2: φ = 20° [rad]
c_2 = 2 'suelo 2: c [tonf/m²]
q_u2 = c_2·fNc(p_2) + gamma·B·fNg(p_2)/2 'Terzaghi-Meyerhof [tonf/m²]
p_3 = 30·pi/180 'arena de Portoviejo: φ = 30° (estudio TSN-ES-2025-206, SPT)
c_3 = 1/9.80665 'c = 1 kPa numérico (la arena tiene c = 0) [tonf/m²]
q_u3 = c_3·fNc(p_3) + gamma·B·fNg(p_3)/2 'Terzaghi-Meyerhof [tonf/m²]

## 4 · Hekatan Geotechnic: Mohr-Coulomb, la carga crece de 5 en 5
#: Corte 2D en deformación plana del mismo bloque (20 × 10 m, malla de 0.5 m, 1974 T6), peso propio primero (u = 0) y luego la carga en etapas. Cuando Newton ya no encuentra equilibrio, el suelo falló («carga alcanzada» < 100 %).
q_t = [5, 10, 15, 20, 25, 30, 35, 40] 'carga [tonf/m²]
s_lin = [8.099, 16.198, 24.296, 32.395, 40.494, 48.593, 56.691, 64.790] 'lineal = lo que da SAP2000 [mm]
s_1 = [8.099, 16.199, 24.892, 47.816, 106.159, 0, 0, 0] 'arcilla c_u = 5 (falla a 25.94) [mm]
s_2 = [8.099, 16.198, 24.692, 36.643, 51.333, 68.640, 89.234, 0] 'c = 2, φ = 20° (falla a 36.56) [mm]
#tabla("q [tonf/m²]:1","Lineal = SAP2000 [mm]:2","Arcilla c_u=5 [mm]:2","c=2, φ=20° [mm]:2")(q_t; s_lin; s_1; s_2)
#: (0 = el suelo ya falló con esa carga.)
#: **Curva carga-asiento** — la recta es SAP2000; las curvas son el suelo real:
#fplot(lineal = 5·x/8.0988, arcilla = [0 0; 8.099 5; 16.199 10; 24.892 15; 47.816 20; 106.159 25; 130.781 25.94], c2_phi20 = [0 0; 8.099 5; 16.198 10; 24.692 15; 36.643 20; 51.333 25; 68.64 30; 89.234 35; 96.365 36.56], [0 140])

## 5 · Validación: falla del FEM contra la teoría
q_fem1 = 25.94 'Geotechnic, arcilla [tonf/m²]
q_fem2 = 36.56 'Geotechnic, c-φ [tonf/m²]
d_1 = 100·(q_fem1 - q_u1)/q_u1 'diferencia arcilla [%]
d_2 = 100·(q_fem2 - q_u2)/q_u2 'diferencia c-φ [%]
t_teo = [q_u1, q_u2] 'teoría [tonf/m²]
t_fem = [q_fem1, q_fem2] 'Hekatan Geotechnic [tonf/m²]
t_dif = [d_1, d_2] 'diferencia [%]
#tabla("Suelo","Teoría [tonf/m²]:2","Hekatan Geotechnic [tonf/m²]:2","Dif. [%]:1")({"Arcilla c_u = 5 (Prandtl)","c = 2, φ = 20° (Meyerhof)"}; t_teo; t_fem; t_dif)
#: **Arena de Portoviejo (φ = 30°, c ≈ 0): el cálculo no llega a la falla, en NINGÚN programa.** Geotechnic (Mohr-Coulomb c = 1 kPa y Drucker-Prager) se detiene en 12.5 tonf/m²; Abaqus (Riks, CPE8R, misma malla) se detiene en 2.6 tonf/m², con flujo asociado en 2.2 y con zapata rígida a desplazamiento impuesto en 3.4 mm. Meyerhof da q_u3 ≈ 46 tonf/m². Es un límite NUMÉRICO de la arena en la superficie (presión de confinamiento ≈ 0: la punta del cono), no la falla: el manual de PLAXIS (Material Models §3.3) pide c > 0.2 kPa cerca de la superficie y define el colapso con longitud de arco (Reference §7.8.2). Pendiente: GEO5 FEM con longitud de arco.
#: **3D:** el esfuerzo vertical elástico bajo la franja (Boussinesq en deformación plana), el «bulbo» que SAP2000 dibuja en el corte — y que con 3 veces la carga solo se triplica:
s_z(x, z) = q_l/pi·(atan((B/2 - x)/z) + atan((B/2 + x)/z) + (B/2 - x)·z/((B/2 - x)^2 + z^2) + (B/2 + x)·z/((B/2 + x)^2 + z^2))
#surf(s_z(x, -z), [-6 6], [-8 -0.2])
#contourf(s_z(x, -z), [-6 6], [-8 -0.2])

## 6 · Por qué el suelo no lineal es más difícil (Newton-Raphson y el modelo del suelo)
#: **Newton-Raphson, la idea.** En lineal basta resolver K·u = F una vez. En no lineal la fuerza interna R(u) ya no es una recta: se busca u tal que R(u) = F. Newton parte de u₀, mira la PENDIENTE (rigidez tangente K_T) y salta por la tangente; repite hasta que R(u) = F:
u_k1 = Simplify{u_k + (F - R_k)/K_T}
#: Un suelo cargado se parece a R(u) = F_u·(1 − e^(−u/u₀)): rígido al inicio, cada vez más blando, y con un TECHO F_u (la falla). La tangente es K_T = (F_u/u₀)·e^(−u/u₀):
K_T_s = Simplify{Partial{F_u*(1 - e^(-u/u_0)) @ u}}
F_u = 25.94 'techo = falla de la arcilla en Geotechnic [tonf/m²]
u_0 = 30 'escala del asiento [mm]
R(u) = F_u·(1 - exp(-u/u_0))
#hide
n_r = 8
u_a = zeros(n_r, 1)
u_b = zeros(n_r, 1)
F_a = 0.9·F_u
F_b = 1.05·F_u
for k = 2:n_r
  u_a(k) = u_a(k - 1) + (F_a - R(u_a(k - 1)))/(F_u/u_0·exp(-u_a(k - 1)/u_0))
  u_b(k) = min(u_b(k - 1) + (F_b - R(u_b(k - 1)))/max(F_u/u_0·exp(-u_b(k - 1)/u_0), 1e-9), 99999)
end
i_t = zeros(n_r, 1)
for k = 1:n_r
  i_t(k) = k - 1
end
#show
#tabla("Iteración:0","u con F = 0.90·F_u [mm]:3","u con F = 1.05·F_u [mm]:1")(i_t; u_a; u_b)
#: Con 0.90·F_u converge en pocas iteraciones (u = 69.1 mm). Con 1.05·F_u NO hay solución: la curva nunca llega a esa altura, Newton salta cada vez más lejos y el asiento se dispara (la tabla lo corta en 99 999 mm: la tangente K_T → 0 y el salto (F − R)/K_T → ∞). Eso es lo que Geotechnic reporta como «carga alcanzada < 100 %»: el suelo FALLÓ.
#: **Las tangentes de Newton con F = 1.05·F_u (2D).** En cada iteración Newton traza la recta tangente a la curva en u_k y la sigue hasta la altura de la carga F. Como el suelo se ablanda, cada tangente es MÁS PLANA que la anterior y corta la línea de carga MÁS LEJOS: u = 0 → 31.5 → 65.8 → 109.2 → 196.4 mm…
T_K(u_k, x) = R(u_k) + F_u/u_0·exp(-u_k/u_0)·(x - u_k)
#fplot(suelo = F_u·(1 - exp(-x/u_0)), carga_105 = 1.05·F_u, tang_0 = F_u·(1 - exp(-0/u_0)) + F_u/u_0·exp(-0/u_0)·(x - 0), tang_32 = F_u·(1 - exp(-31.5/u_0)) + F_u/u_0·exp(-31.5/u_0)·(x - 31.5), tang_66 = F_u·(1 - exp(-65.8/u_0)) + F_u/u_0·exp(-65.8/u_0)·(x - 65.8), tang_109 = F_u·(1 - exp(-109.2/u_0)) + F_u/u_0·exp(-109.2/u_0)·(x - 109.2), [0 220])
#: **La pendiente se va a cero (2D).** La rigidez tangente K_T = (F_u/u₀)·e^(−u/u₀) cae hacia 0 al crecer el asiento; el salto de Newton es Δu = (F − R)/K_T, o sea algo FINITO dividido entre algo que tiende a CERO → infinito:
K_T(x) = F_u/u_0·exp(-x/u_0)
#fplot(K_T = F_u/u_0·exp(-x/u_0), [0 200])
#: **3D: el salto de Newton Δu según el asiento actual u (eje x) y la carga F (eje y).** Bajo F_u = 25.94 el salto es chico y lleva al equilibrio; encima de F_u la superficie se dispara (cortada en 300 mm): no hay equilibrio que encontrar.
D_u(x, y) = min(max((y - R(x))/K_T(x), -300), 300)
#surf(D_u(x, y), [0 150], [20 30])
#contourf(D_u(x, y), [0 150], [20 30])
#: **2D:** la curva del suelo (azul), la recta lineal de SAP2000 (sigue para siempre) y las cargas 0.90·F_u y 1.05·F_u:
#fplot(suelo = F_u·(1 - exp(-x/u_0)), sap2000 = F_u/u_0·x, carga_090 = 0.9·F_u, carga_105 = 1.05·F_u, [0 160])

#: **¿Por qué el suelo es tan distinto a una estructura de acero?** El acero fluye cuando su esfuerzo de corte llega a f_y, sin importar la presión que lo rodea (von Mises: un CILINDRO en el espacio de esfuerzos). El suelo es de granos que se traban por fricción: su resistencia al corte CRECE con la presión de confinamiento p (Mohr-Coulomb: τ = c + σ·tan φ, un CONO). En la superficie, al lado de la zapata, p ≈ 0: la arena casi no resiste ahí, y el cono termina en una PUNTA (el ápice).
#: Superficies de fluencia en la sección meridiana (resistencia al corte q contra presión p): acero plano, suelo creciente:
#fplot(acero_vonMises = 30, suelo_MC_phi30 = 6·sin(pi/6)/(3 - sin(pi/6))·x, suelo_MC_c2_phi20 = 6·c_2·cos(pi/9)/(3 - sin(pi/9)) + 6·sin(pi/9)/(3 - sin(pi/9))·x, [0 60])
#: **3D:** el cono de Mohr-Coulomb (hexagonal, con aristas) y el de Drucker-Prager (redondo) vistos en el plano desviador: la altura es la presión p que hace falta para fluir con ese desviador (x, y). Las ARISTAS y la PUNTA de Mohr-Coulomb son donde la pendiente no existe: ahí Newton tiene que adivinar hacia dónde volver, y con c = 0 y p ≈ 0 la rigidez tangente se va a cero → no converge aunque el suelo aún aguante.
g_MC(t) = (3 - sin(pi/6))/(2·sqrt(3)·(cos(t) - sin(t)·sin(pi/6)/sqrt(3)))
t_L(x, y) = asin(sin(3·atan2(y, x)))/3
p_MC(x, y) = sqrt(x^2 + y^2)/g_MC(t_L(x, y))
#surf(p_MC(x, y), [-1 1], [-1 1])
#contourf(p_MC(x, y), [-1 1], [-1 1])
#: **Por eso hay que ESCOGER el modelo según la falla:**
#: • Arcilla sin drenar (φ = 0): Mohr-Coulomb = Tresca; no tiene punta y la falla sale = Prandtl (0.9 %).
#: • Suelo con c y φ: Mohr-Coulomb reproduce la cuña de Meyerhof (−2.7 %).
#: • Arena con c = 0: la punta de Mohr-Coulomb frena a Newton en la superficie. Drucker-Prager (cono redondo, sin aristas) o una cohesión mínima (Plaxis usa c ≥ 1 kPa) son las salidas; el valor de falla depende de cuál se elija, y por eso se valida contra otro programa (GEO5, Plaxis) con la misma malla.
#: En una estructura de acero nada de esto pasa: el cilindro de von Mises no tiene punta ni depende de p, y Newton converge hasta muy cerca del colapso.

## 7 · La ventaja
#: SAP2000 no tiene material no lineal en el sólido ni en el elemento plano: con 30 tonf/m² (×3) da 42 mm y sigue. Hekatan Geotechnic, con el mismo E y una resistencia del suelo, muestra que la arcilla FALLA antes (25.9 tonf/m²) y que el suelo c-φ asienta 68.6 mm en vez de 48.6 (+41 %). Para saber si la carga se puede poner, hace falta el no lineal.
