# Carga móvil HL-93 en una alcantarilla cajón: líneas de influencia y envolvente
#: Esta hoja explica, paso a paso, QUÉ hace Hekatan Struct cuando un camión HL-93 cruza la alcantarilla cajón del ejemplo público. Primero en letras, después con los números. Las fórmulas y los números salen del motor de la app, no de la memoria: cada una lleva su archivo:línea.
#: El ejemplo vivo: https://giorgioburbanelli89.github.io/hekatan-struct-lineal/workspace/?t=alcantarilla-carga-movil
#: Motor: examples/src/shared/cargaMovil.ts y examples/src/alcantarilla-carga-movil/ (repo hekatan-struct, rama carga-movil-alcantarilla).
#: Unidades: el motor trabaja en kN y m (cargaMovil.ts:31). Aquí se dan también en tonf, que es lo que se usa en Ecuador. 1 tonf = 9.80665 kN.

## 1 · El camión HL-93: qué es, en letras

#: El HL-93 no es un camión: son cargas que se aplican a la vez, y la combinación se llama HL-93K (cargaMovil.ts:16). Primero el camión de diseño, tres ejes seguidos. El peso total es la suma de los tres:
P_tot = P_1 + P_2 + P_3
#: Los ejes no están fijos: el eje delantero manda, y cada eje va una distancia d DETRÁS de él (cargaMovil.ts:37-41, «distancia DETRÁS del eje delantero»). Si el eje delantero está en la abscisa x_F, el eje k está en:
x_k = x_F - d_k
#: Las tres distancias del HL-93 (cargaMovil.ts:82-84): el delantero en 0, el segundo a a₁, y el tercero a a₁ más la separación trasera a₂, que NO es fija:
d_1 = 0
d_2 = a_1
d_3 = a_1 + a_2
#: El largo total del camión es la distancia del primer eje al último (cargaMovil.ts:90, largoVehiculo = máximo de las d):
L_cam = a_1 + a_2
#: Y junto al camión va la carga de carril: una carga repartida w_c a todo lo largo, que no se mueve; se pone donde más daño hace.

## 2 · Ahora los números (AASHTO LRFD, en SI)

#: De dónde salen: no hay PDF de AASHTO en esta PC. La fuente comprobada es el CSI Analysis Reference Manual de SAP2000 24, cap. XXVI, pág. 515 y Figura 92 pág. 517 (cargaMovil.ts:16-20 y :72). Ahí el HL-93 está en unidades inglesas: 8 k · 32 k · 32 k, separaciones 14 ft y 14-30 ft, carril 0.640 k/ft. En SI son los redondeos de norma que usa el motor en cargaMovil.ts:67-71:
P_1 = 35
P_2 = 145
P_3 = 145
a_1 = 4.3
#: El peso total del camión, en kN y en tonf:
P_tot = dec(P_1 + P_2 + P_3, 1)
P_tonf = dec(P_tot/9.80665, 3)
#: La carga de carril (cargaMovil.ts:71), en kN/m y en tonf/m:
w_c = 9.3
w_tonf = dec(w_c/9.80665, 5)
#: Y la separación trasera a₂ es un RANGO, no un número (cargaMovil.ts:69-70): el camión se estira o se encoge buscando el peor caso.
a_2min = 4.3
a_2max = 9.0
#: Con eso el camión mide entre:
L_min = a_1 + a_2min
L_max = a_1 + a_2max

## 3 · Los factores que tocan las cargas

#: (a) IMPACTO IM. La carga de un camión que pasa rodando pega más que la misma carga puesta despacio. La norma lo mete multiplicando los ejes por un factor. En el motor (cargaMovil.ts:77 y :82-84):
f_IM = 1 + IM/100
P_din = P_eje*f_IM
#: El porqué del despeje: si un ensayo te da la carga medida P_med, el IM sale de aquí:
Despejar{P_med = P_eje*(1 + IM/100) @ IM}
#: Con el IM del 33 % del HL-93 (CSI Ref. p. 515: «if im = 33 ... multiplied by 1.33»), el eje trasero pasa a valer:
IM = 33
f_IM = 1 + IM/100
P_eje33 = dec(145*f_IM, 2)
#: Ojo, y esto es importante: el factor solo toca los EJES, no el carril (cargaMovil.ts:57 y :86 — el carril se divide por el ancho, pero no se multiplica por f_IM). En el ejemplo público el IM viene en 0 % por defecto (alcantarillaCargaMovil.ts:52), para que se vea el efecto de la carga móvil sola; se sube con el mando.

#: (b) ANCHO DE REPARTO E. El modelo es un pórtico plano: una FRANJA de 1 m de la alcantarilla (modeloAlcantarilla.ts:1-2). Un eje real se reparte a lo ancho, así que la carga que entra en la franja es:
P_franja = P_eje/E_r
#: Y al revés: si quieres que en la franja entre una carga P_obj, el ancho que hace falta sale de despejar E:
Despejar{P_eje = P_obj*E_r @ E_r}
#: AVISO: aquí la hoja dice lo que NO sabe. El ancho de reparto de AASHTO LRFD para alcantarillas (franja equivalente más la propagación de la rueda por el relleno) NO tiene fuente en esta PC: no hay PDF de AASHTO y los manuales de CSI no lo traen. Por eso el ejemplo abre con E_r = 1 m, o sea el eje ENTERO sobre la franja de 1 m, que es el lado seguro, y lo avisa en pantalla en naranja (alcantarillaCargaMovil.ts:53 y :193-196). No se inventa un número.
E_r = 1

#: (c) FACTOR DE PRESENCIA MÚLTIPLE. El HL-93 completo lleva un factor m según cuántos carriles se cargan a la vez. El motor de Hekatan Struct NO lo aplica: camionHL93 solo admite separación trasera, IM, ancho y carril sí/no (cargaMovil.ts:53-62). Lo que se calcula es UN carril sobre la franja de 1 m. Si tu norma pide m, se multiplica fuera.

## 4 · La idea que lo hace todo posible: superposición

#: El modelo es LINEAL. Lineal significa lo mismo que y = m·x: si doblas la carga, se dobla la respuesta, y si pones dos cargas, la respuesta es la SUMA de las dos por separado. Eso está dicho con esas palabras en el propio motor (cargaMovil.ts:8-13).
#: Entonces no hace falta resolver la estructura en cada posición del camión. Basta resolverla UNA vez por cada nudo del tablero con 1 kN hacia abajo. Esa colección de respuestas es la LÍNEA DE INFLUENCIA. Después, el camión en cualquier posición es una suma:
R = P_1*IL_1 + P_2*IL_2 + P_3*IL_3
#: R puede ser cualquier cosa: un momento, un cortante, una flecha, la reacción de un muelle. La línea de influencia se calcula una vez y sirve para todas las posiciones. Es lo mismo que hace el Moving Load de SAP2000 (cargaMovil.ts:13).
#: El ahorro es enorme. Nudos del tablero del ejemplo público (19 m de tablero, un nudo cada 0.1 m):
n_nudos = 191
#: Posiciones que se prueban en la envolvente:
n_pos = 14424
#: Sin superposición habría que resolver la estructura 14 424 veces. Con líneas de influencia se resuelve 191 veces. El ahorro:
ahorro = dec(n_pos/n_nudos, 1)

## 5 · El elemento: de dónde sale la rigidez (formulación real del motor)

#: Antes de mover ningún camión hay que saber qué resuelve el programa. Todo el cálculo es UNA ecuación, y es y = m·x con matrices en vez de números: la rigidez por el desplazamiento da la fuerza.
f = K*u
#: Con un resorte de toda la vida se ve el porqué. La fuerza es la rigidez por el estiramiento:
F_r = k_r*u_r
#: Y si lo que conoces es la fuerza P_dato, despejas el desplazamiento. Más rigidez, menos se mueve:
Despejar{P_dato = k_r*u_r @ u_r}
#: Con la estructura entera es lo mismo, solo que K es una matriz grande y en vez de dividir se resuelve el sistema. El motor lo hace con una factorización de Cholesky, LDLT, porque K es simétrica y definida positiva (deform.cpp:224-238).

#: ¿Y de dónde salen los números de K? De las FUNCIONES DE FORMA. Entre dos nudos, sin carga en el medio, la cuarta derivada de la deformada de la viga es cero. Integrar cuatro veces un cero da un polinomio de grado 3 (esto está deducido paso a paso en el ejemplo 15 de esta misma web). La deformada del elemento es, entonces, una cúbica:
v = c_1 + c_2*x + c_3*x^2 + c_4*x^3
#: No es una aproximación: es la forma EXACTA de la viga entre nudos. Y tiene cuatro constantes que encajan justo con los cuatro grados de libertad de flexión del elemento: el desplazamiento y el giro en cada extremo. Escritas en función de esos cuatro grados de libertad, esas cúbicas son las funciones de HERMITE.
#: La deformación que importa en flexión es la CURVATURA, que es la segunda derivada de la deformada:
kappa = Diff{Diff{v @ x} @ x}
#: Sale lineal en x: la curvatura varía en línea recta dentro del elemento, y por eso el momento también. Las derivadas segundas de las funciones de forma son las filas de la matriz B, la que pasa de desplazamientos a deformaciones:
#|  ε = B · u        (B = derivadas de las funciones de forma)
#: Y la rigidez del elemento es la integral clásica del método, la energía de deformación puesta en forma de matriz:
#|  K_e = ∫ Bᵀ · E · B  dx        (a lo largo del elemento, de 0 a L)

#: Hecha esa integral con las cúbicas de Hermite, la matriz de una barra de pórtico plano tiene esta forma. Seis grados de libertad: en cada nudo dos desplazamientos y un giro. En letras primero, que es como hay que leerla:
K_e = [EA_L, 0, 0, -EA_L, 0, 0; 0, t_f, b_f, 0, -t_f, b_f; 0, b_f, k_f, 0, -b_f, a_f; -EA_L, 0, 0, EA_L, 0, 0; 0, -t_f, -b_f, 0, t_f, -b_f; 0, b_f, a_f, 0, -b_f, k_f]
#: Cómo se lee: es SIMÉTRICA (lo que el nudo i le hace al j es igual que lo que el j le hace al i). Las filas 1 y 4 son el axil puro y no se mezclan con nada: estirar no dobla. Las filas 2, 3, 5 y 6 son la flexión, y ahí todo está mezclado, porque bajar un extremo obliga a girarlo.
#: Y los cinco coeficientes son los de siempre. El motor los tiene escritos tal cual en getLocalStiffnessMatrix.cpp:214-226:
EA_L = E*A/L
t_f = 12*E*I/L^3
b_f = 6*E*I/L^2
k_f = 4*E*I/L
a_f = 2*E*I/L
#: Mira las unidades y ya entiendes la física: EA/L es cuánta fuerza hace falta por metro de estiramiento, 12EI/L³ es cuánta fuerza por metro de bajada, 4EI/L es cuánto momento por radián de giro. Y fíjate en la L: la rigidez a flexión va con L al cubo. Partir un elemento en dos NO lo hace un poco más rígido, lo hace ocho veces más rígido.

#: Pero el motor NO es Euler-Bernoulli puro: es TIMOSHENKO, o sea que también cuenta lo que la barra se deforma por CORTANTE. Eso entra con un solo número, phi, que compara la flexibilidad a cortante con la flexibilidad a flexión (getLocalStiffnessMatrix.cpp:198 y :211):
phi = 12*E*I/(G*A_s*L^2)
#: y los cuatro coeficientes de flexión se corrigen así (getLocalStiffnessMatrix.cpp:218-221). Si phi = 0 quedan exactamente los de Bernoulli, o sea que Bernoulli es el caso particular:
t_T = (12*E*I/L^3)/(1 + phi)
b_T = (6*E*I/L^2)/(1 + phi)
k_T = (4*E*I/L)*(1 + phi/4)/(1 + phi)
a_T = (2*E*I/L)*(1 - phi/2)/(1 + phi)
#: El área de cortante por defecto es la de ETABS, 5/6 del área (getLocalStiffnessMatrix.cpp:209-210):
A_s = 5*A/6
#: Y aquí sale una fórmula bonita, todavía en letras. Para una sección rectangular de ancho b y canto t: el área es A = b·t, la inercia I = b·t³/12, y G = E/(2(1+ν)). Metiendo todo eso en phi, el ancho b se va, E y G se van, y queda solo la esbeltez del elemento:
phi_sim = Simplify{12*E*(b*t^3/12)/((E/(2*(1 + nu)))*(5/6)*(b*t)*L^2)}
#: Léelo así: phi = 12(1+ν)/5 por (t/L) al cuadrado. El cortante manda cuando el canto t es grande frente al LARGO DEL ELEMENTO L. Una barra larga y delgada tiene phi casi cero y Timoshenko y Bernoulli dan lo mismo; una barra corta y gruesa, no.

#: Ahora los números, para UN elemento de la losa superior del ejemplo: canto t = 0.50 m, ancho de franja b = 1 m, y largo L = 0.1 m, porque el tablero está mallado al paso del camión.
t_losa = 0.50
b_fr = 1
L_el = 0.1
nu = 0.2
A_el = dec(b_fr*t_losa, 4)
I_el = dec(b_fr*t_losa^3/12, 8)
phi_el = dec(12*(1 + nu)/5*(t_losa/L_el)^2, 2)
#: phi = 72, y no es un detalle: el término 12EI/L³ queda dividido por 73. Si el motor fuera Bernoulli puro, ese elemento sería 73 veces más rígido. Por eso la malla fina no dispara la rigidez, y por eso la validación en OpenSees tuvo que hacerse con ElasticTimoshenkoBeam y no con la viga elástica normal (alcantarillaCargaMovil.ts:95).
#: Con el hormigón del ejemplo, E = 250 000 kgf/cm² (1 kgf/cm² = 98.0665 kN/m²):
E_kg = 250000
E_c = dec(E_kg*98.0665, 0)
G_c = dec(E_c/(2*(1 + nu)), 0)
#: Y los cuatro coeficientes de flexión de ese elemento, ya en kN y m:
t_num = dec((12*E_c*I_el/L_el^3)/(1 + phi_el), 0)
b_num = dec((6*E_c*I_el/L_el^2)/(1 + phi_el), 0)
k_num = dec((4*E_c*I_el/L_el)*(1 + phi_el/4)/(1 + phi_el), 0)
a_num = dec((2*E_c*I_el/L_el)*(1 - phi_el/2)/(1 + phi_el), 0)
#: Ojo al signo del último: con phi grande, el término que arrastra un extremo con el otro se vuelve NEGATIVO. Eso es Timoshenko, no un error.
#: La matriz que escribe el motor es de 12x12, para el espacio (getLocalStiffnessMatrix.cpp:229-241): las seis casillas que hemos visto son su sub-bloque del plano. Las otras seis son la flexión fuera del plano y la torsión, y aquí están bloqueadas (modeloAlcantarilla.ts:13-16).

#: ENSAMBLAJE. Cada barra tiene su matriz en SUS ejes. Para poder sumarlas hay que llevarlas a los ejes globales con la matriz de giro T (getGlobalStiffnessMatrix.cpp:69-80):
K_glob = T_t*K_loc*T
#: Y luego se SUMAN, casilla a casilla, en la matriz global: la fila de un grado de libertad es 6 por el número de nudo más el grado de libertad (getGlobalStiffnessMatrix.cpp:114-133). Sumar es todo el ensamblaje: si dos barras llegan al mismo nudo, sus rigideces se suman en la misma casilla. Por eso una esquina de la alcantarilla es rígida: ahí están la losa y el muro a la vez.
#: Los MUELLES del suelo son aún más simples: se suman directamente a la casilla de la DIAGONAL de ese nudo y ese grado de libertad (deform.cpp:162-170). Eso es, exactamente, el muelle nodal de SAP2000:
K_dd = K_dd + k_muelle
#: Y el valor del muelle es el módulo de balasto por el área que le toca a ese nudo:
k_muelle = k_s*b_trib*b_franja
#: En números: ks = 2.0 kgf/cm³ son 19 613.3 kN/m³ (1 kgf/cm³ = 9806.65 kN/m³), con 0.5 m de tributario y la franja de 1 m:
ks_kg = 2.0
ks_kN = dec(ks_kg*9806.65, 1)
k_muelle = dec(ks_kN*0.5*1, 0)
#: Por último se quitan las filas de los apoyos y se resuelve (deform.cpp:214-238). Eso es UN caso de carga. Toda esta hoja va de no tener que hacerlo 14 424 veces.

## 6 · Cómo saca el motor la línea de influencia

#: Por cada nudo k del tablero se pone 1 kN hacia abajo y se resuelve (cargaMovil.ts:203-204): la carga es el vector [0, 0, -1, 0, 0, 0], o sea -1 en el grado de libertad vertical. De ahí sale el vector de desplazamientos de toda la estructura.
#: ¿Y los momentos? Aquí está el truco de velocidad. Llamar al analizador en cada caso costaba 35 ms x 191 casos = 6.6 s (cargaMovil.ts:156). Como todo es lineal, las fuerzas de una barra son una matriz constante por sus 12 desplazamientos:
f_barra = B*u_barra
#: B es de 6x12: seis resultados (N, V, M en los dos extremos) por doce grados de libertad de la barra. Y no está reescrita a mano: se saca del PROPIO analizador, dándole desplazamientos unitarios y leyendo las columnas (cargaMovil.ts:150-186). Esa es la regla de la casa: no fabricar la formulación, extraerla.
#: El signo es el del DIAGRAMA de CSI, no el de las fuerzas de extremo: en el nudo i el diagrama es -f, en el nudo j es +f (cargaMovil.ts:128-131 y :181-182).
M_i = -f_i
M_j = f_j
#: La fuerza de los muelles Winkler, igual de simple: rigidez por lo que se hunde el nudo, con signo cambiado porque el muelle empuja hacia arriba (cargaMovil.ts:225):
R_muelle = -k_s*u_z

## 7 · GRÁFICA: las dos líneas de influencia del ejemplo

#: Alcantarilla del enlace: 2 celdas, luz 9.5 m a ejes, alto 6.0 m, losa superior 0.50 m, losa inferior 0.55 m, muros 0.45 m (modeloAlcantarilla.ts:36-40). Hormigón E = 250 000 kgf/cm2, nu = 0.2; balasto ks = 2.0 kgf/cm3 bajo la losa inferior. Tablero de 19 m, malla de 0.1 m: 263 nudos, 264 barras, 39 muelles.
#: Dos secciones de control: C, el centro de la celda 1 (x = 4.70 m, el nudo más cercano a 4.75), y W, sobre el muro central (x = 9.50 m). Cada curva dice cuánto momento (kN·m) aparece en esa sección cuando 1 kN se para en la abscisa x del tablero. Salen del motor: 191 casos unitarios, muestreados cada 0.5 m para la gráfica.
#fila
#fplot(IL_centro = [0 0.0253; 0.5 0.114; 1 0.2188; 1.5 0.34; 2 0.4781; 2.5 0.6333; 3 0.8061; 3.5 0.9968; 4 1.2058; 4.5 1.4335; 5 1.3802; 5.5 1.1463; 6 0.9322; 6.5 0.7383; 7 0.5648; 7.5 0.4122; 8 0.2809; 8.5 0.1712; 9 0.0835; 9.5 0.0181; 10 -0.0314; 10.5 -0.0727; 11 -0.1062; 11.5 -0.1326; 12 -0.1523; 12.5 -0.1659; 13 -0.174; 13.5 -0.1771; 14 -0.1756; 14.5 -0.1702; 15 -0.1615; 15.5 -0.1498; 16 -0.1358; 16.5 -0.1201; 17 -0.103; 17.5 -0.0853; 18 -0.0674; 18.5 -0.0499; 19 -0.0333], [0 19])
#fplot(IL_muro = [0 -0.1364; 0.5 -0.2523; 1 -0.3712; 1.5 -0.49; 2 -0.6056; 2.5 -0.7151; 3 -0.8153; 3.5 -0.9031; 4 -0.9756; 4.5 -1.0296; 5 -1.0622; 5.5 -1.0701; 6 -1.0504; 6.5 -1.0001; 7 -0.916; 7.5 -0.7951; 8 -0.6344; 8.5 -0.4307; 9 -0.181; 9.5 0.1177; 10 -0.0418; 10.5 -0.1727; 11 -0.2775; 11.5 -0.3583; 12 -0.4175; 12.5 -0.4573; 13 -0.4801; 13.5 -0.4882; 14 -0.4837; 14.5 -0.4692; 15 -0.4467; 15.5 -0.4186; 16 -0.3873; 16.5 -0.3549; 17 -0.3238; 17.5 -0.2963; 18 -0.2747; 18.5 -0.2613; 19 -0.2583], [0 19])
#finfila
#: Léelas así, que es todo el oficio de la carga móvil:
#: - IL_centro es casi toda POSITIVA en la celda 1 y con una punta justo encima de la sección. El pico vale 1.5299 kN·m por cada kN. Es decir: para el momento positivo del centro del vano, lo que manda es poner el eje pesado AHÍ.
#: - En la celda 2 (x > 9.5) la misma curva se vuelve NEGATIVA, pequeña, unos -0.177. O sea: cargar la otra celda ALIVIA el centro de la primera. Por eso la envolvente busca posiciones, no una sola.
#: - IL_muro es casi toda negativa, con su punta en x = 5.4 m y valor -1.0706. El momento negativo del apoyo se saca cargando el CENTRO del vano de al lado, no encima del muro. En x = 9.5 (justo sobre el muro) la curva vale +0.118, casi nada: una carga sobre el muro baja derecha a la zapata.

## 8 · El camión en una posición: la regla de la palanca

#: Un eje cae en un punto cualquiera, casi nunca justo en un nudo. Si cae entre el nudo i y el nudo j, se reparte por la regla de la palanca (cargaMovil.ts:279-283). Primero, dónde cae dentro del tramo, en tanto por uno:
Despejar{x_e = s_i + t*(s_j - s_i) @ t}
#: Y el reparto es el complementario en cada nudo: lo que está más cerca se lleva más:
w_i = P_eje*(1 - t)
w_j = P_eje*t
#: Esto es una APROXIMACIÓN, y el motor lo dice y lo mide: devuelve «repartido», los kN que ha tenido que repartir, para que quien llama lo vea (cargaMovil.ts:22-25 y :263). El ejemplo está mallado a propósito con un nudo cada 0.1 m, y el camión avanza también de 0.1 en 0.1 (alcantarillaCargaMovil.ts:55): los ejes caen SIEMPRE en nudo y «repartido» sale 0. La carga móvil es exacta, sin palanca.
#: El recorrido del camión no es el del tablero: empieza cuando entra el primer eje y acaba cuando sale el último (cargaMovil.ts:288-293). En letras:
x_fin = L_tab + L_cam
#: Con el tablero de 19 m y el camión corto de 8.6 m:
L_tab = 19
L_cam = 8.6
x_fin = L_tab + L_cam
paso = 0.1
n_posic = x_fin/paso + 1

## 9 · GRÁFICA: el momento según avanza el camión

#: Ahora se aplica la suma R = P₁·IL₁ + P₂·IL₂ + P₃·IL₃ en cada posición. La curva de abajo es el momento en la sección C (centro de la celda 1) según dónde esté el eje DELANTERO. Camión solo, separación trasera 4.3 m, sin carril y sin IM. Datos del motor, cada 0.5 m:
#fplot(M_centro = [0 0.88; 0.5 3.99; 1 7.66; 1.5 11.9; 2 16.73; 2.5 22.17; 3 28.21; 3.5 34.89; 4 42.2; 4.5 58.71; 5 70.63; 5.5 78.59; 6 89.64; 6.5 103.86; 7 121.31; 7.5 142.06; 8 166.17; 8.5 193.72; 9 238.53; 9.5 215.36; 10 197.95; 10.5 186.15; 11 180.04; 11.5 179.71; 12 185.25; 12.5 196.75; 13 214.3; 13.5 208.98; 14 166.24; 14.5 128.11; 15 94.18; 15.5 64.39; 16 38.72; 16.5 17.11; 17 -0.48; 17.5 -14.09; 18 -23.76; 18.5 -30.18; 19 -34.83; 19.5 -37.3; 20 -39.49; 20.5 -40.39; 21 -40.17; 21.5 -38.98; 22 -36.97; 22.5 -34.31; 23 -31.14; 23.5 -23.7; 24 -22.09; 24.5 -20.12; 25 -17.88; 25.5 -15.45; 26 -12.89; 26.5 -10.29; 27 -7.74; 27.5 -5.29], [0 27.6])
#: El pico está en x_F = 9.0 m. ¿Por qué justo ahí? Porque con el delantero en 9.0 los ejes caen en 9.0, en 9.0 - 4.3 = 4.7 y en 9.0 - 8.6 = 0.4. El eje de 145 kN se planta EXACTAMENTE sobre la sección C. Vamos a comprobarlo sumando a mano, con los tres valores de la línea de influencia:
IL_04 = 0.09497629
IL_47 = 1.52989986
IL_90 = 0.08349465
#: La suma, primero en letras:
R_max = P_1*IL_90 + P_2*IL_47 + P_3*IL_04
#: Y ahora con los números:
R_max = dec(35*IL_90 + 145*IL_47 + 145*IL_04, 4)
#: El motor, resolviendo el pórtico entero, da 238.5294 kN·m en esa posición. Coinciden cifra a cifra: la superposición no es una aproximación, es el mismo cálculo.
R_tonf = dec(R_max/9.80665, 3)
#: Y fíjate en la cola: pasado el metro 17 la curva se vuelve NEGATIVA (hasta -40.4 kN·m). Es el camión, ya en la celda 2, levantando el centro de la celda 1: la parte negativa de la línea de influencia del centro que vimos en la sección 7.

## 10 · ANIMACIÓN: el camión HL-93 cruzando el tablero

#: Dos películas a la vez, las dos con el mismo contador n (el fotograma). El camión avanza 1.2 m por fotograma: la posición del eje delantero es xF = 1.2·n.
#: IZQUIERDA, el camión dibujado. La silueta (caja, cabina y chasis) está hecha con escalones: cada trozo es un rectángulo construido con sign(), que vale 1 dentro del tramo y 0 fuera. Debajo de la línea del suelo, tres marcas: son los EJES, en 0, 4.3 y 8.6 m por detrás del delantero. Y de fondo, la línea de influencia del centro de la celda 1, la misma de la sección 7.
#: DERECHA, la respuesta. La curva es el momento en esa sección para cada posición del camión (la de la sección 9) y la barra que se mueve marca EN QUÉ posición va el camión de la izquierda. Cuando la rueda pesada se monta sobre la punta de la línea de influencia, la barra de la derecha llega al pico.
#fila
#anim fplot(camion = 0.55*(sign(x - 1.2*n + 9.0) + 1)*(sign(1.2*n + 0.9 - x) + 1)/4 + 1.05*(sign(x - 1.2*n + 8.9) + 1)*(sign(1.2*n - 1.3 - x) + 1)/4 + 0.55*(sign(x - 1.2*n + 1.1) + 1)*(sign(1.2*n + 0.75 - x) + 1)/4, ejes = -0.35*((sign(x - 1.2*n + 0.2) + 1)*(sign(1.2*n + 0.2 - x) + 1)/4 + (sign(x - 1.2*n + 4.5) + 1)*(sign(1.2*n - 4.1 - x) + 1)/4 + (sign(x - 1.2*n + 8.8) + 1)*(sign(1.2*n - 8.4 - x) + 1)/4), IL_centro = [0 0.0253; 0.5 0.114; 1 0.2188; 1.5 0.34; 2 0.4781; 2.5 0.6333; 3 0.8061; 3.5 0.9968; 4 1.2058; 4.5 1.4335; 5 1.3802; 5.5 1.1463; 6 0.9322; 6.5 0.7383; 7 0.5648; 7.5 0.4122; 8 0.2809; 8.5 0.1712; 9 0.0835; 9.5 0.0181; 10 -0.0314; 10.5 -0.0727; 11 -0.1062; 11.5 -0.1326; 12 -0.1523; 12.5 -0.1659; 13 -0.174; 13.5 -0.1771; 14 -0.1756; 14.5 -0.1702; 15 -0.1615; 15.5 -0.1498; 16 -0.1358; 16.5 -0.1201; 17 -0.103; 17.5 -0.0853; 18 -0.0674; 18.5 -0.0499; 19 -0.0333], [0 19]), n = 0:23
#anim fplot(M_centro = [0 0.88; 0.5 3.99; 1 7.66; 1.5 11.9; 2 16.73; 2.5 22.17; 3 28.21; 3.5 34.89; 4 42.2; 4.5 58.71; 5 70.63; 5.5 78.59; 6 89.64; 6.5 103.86; 7 121.31; 7.5 142.06; 8 166.17; 8.5 193.72; 9 238.53; 9.5 215.36; 10 197.95; 10.5 186.15; 11 180.04; 11.5 179.71; 12 185.25; 12.5 196.75; 13 214.3; 13.5 208.98; 14 166.24; 14.5 128.11; 15 94.18; 15.5 64.39; 16 38.72; 16.5 17.11; 17 -0.48; 17.5 -14.09; 18 -23.76; 18.5 -30.18; 19 -34.83; 19.5 -37.3; 20 -39.49; 20.5 -40.39; 21 -40.17; 21.5 -38.98; 22 -36.97; 22.5 -34.31; 23 -31.14; 23.5 -23.7; 24 -22.09; 24.5 -20.12; 25 -17.88; 25.5 -15.45; 26 -12.89; 26.5 -10.29; 27 -7.74; 27.5 -5.29], xF_ahora = 240*(sign(x - 1.2*n + 0.2) + 1)*(sign(1.2*n + 0.2 - x) + 1)/4, [0 27.6]), n = 0:23
#finfila
#: Lo que hay que mirar, y es TODO el oficio de la carga móvil: el momento de cada fotograma es la suma de la altura de la línea de influencia bajo cada eje, multiplicada por la carga de ese eje. Ni más ni menos. Cuando un eje pisa donde la curva es alta, suma mucho; cuando pisa donde la curva es negativa (la segunda celda), RESTA. Por eso el peor caso no es «el camión en el centro»: hay que probarlos todos.
#: La silueta en letras, para que se vea que no hay magia. Un rectángulo entre a y b, de altura h, es:
rect = h*(sign(x - a) + 1)*(sign(b - x) + 1)/4
#: El primer paréntesis vale 2 si x está a la derecha de a y 0 si no; el segundo vale 2 si x está a la izquierda de b. Multiplicados y divididos entre 4 dan 1 solo DENTRO del tramo. Sumando tres rectángulos sale el camión, y moviendo a y b con n, el camión anda.

## 11 · La envolvente: el peor de TODOS los casos

#: La envolvente es, en cada punto de la estructura, el máximo y el mínimo de todas las posiciones probadas (cargaMovil.ts:375-383). Y no es un barrido: son TRES barridos anidados.
#: (1) CADA SEPARACIÓN TRASERA. a₂ va de 4.3 a 9.0 cada 0.1 m (cargaMovil.ts:406-409). Son 48 camiones distintos:
n_sep = (a_2max - a_2min)/0.1 + 1
#: (2) CADA CAMIÓN RECORRE SU PROPIO LARGO. Esto fue un error que hubo que arreglar (registro del 19-sep-2026): un camión de 13.3 m tarda más en salir que uno de 8.6 m; si se usan las posiciones del corto, el largo se queda a medio salir (cargaMovil.ts:368-374). Posiciones de un camión con separación a₂:
n_por_sep = (L_tab + a_1 + a_2)/paso + 1
#: Sumando las 48 separaciones salen las 14 424 posiciones que dijimos arriba. Se comprueba: la suma de (19 + 4.3 + a₂)/0.1 + 1 para las 48 separaciones vale
n_tot = 48*234 + 10*48*(a_2min + a_2max)/2
#: (3) EL CARRIL, CARGADO «A TROZOS». El carril no se mueve: se pone donde hace daño y se quita donde ayuda. El motor recorre nudo a nudo y suma la contribución al máximo si es positiva y al mínimo si es negativa (cargaMovil.ts:396-399). En letras, la carga puntual equivalente de cada nudo es la carga repartida por su ancho tributario:
q_k = w_c*b_k
#: Y el ancho tributario es medio tramo a cada lado (cargaMovil.ts:120-123):
b_k = (s_k - s_ant + s_sig - s_k)/2
#: En el tablero, con nudos cada 0.1 m, eso vale 0.1 m en el interior. La carga nodal del carril:
q_nodo = dec(w_c*0.1, 3)
#: Y el reparto por signo: rₖ = qₖ·ILₖ; si rₖ es positivo suma al MÁXIMO, si es negativo suma al MÍNIMO. Así es como define SAP2000 el HL-93K: camión y carril a la vez (cargaMovil.ts:351-356).

## 12 · GRÁFICAS: la envolvente de M y de V

#: Momento en la losa superior a lo largo de los 19 m. Las dos curvas son el máximo y el mínimo de las 14 424 posiciones, camión más carril. Muestreadas cada 0.5 m:
#fplot(M_max = [0 55.14; 0.5 67.1; 1 111.39; 1.5 151.43; 2 193.93; 2.5 236.9; 3 267.64; 3.5 285.98; 4 292.5; 4.5 292.37; 5 293.46; 5.5 282.03; 6 257.71; 6.5 220.84; 7 172.65; 7.5 134.64; 8 97.02; 8.5 61.26; 9 20.43; 9.5 -4.47; 10 36.28; 10.5 75.61; 11 109.46; 11.5 144.84; 12 180.4; 12.5 226.02; 13 260.34; 13.5 282.29; 14 291.68; 14.5 296.18; 15 296.87; 15.5 289.05; 16 269.52; 16.5 237.88; 17 194.45; 17.5 151.28; 18 112.65; 18.5 73.79; 19 54.73], M_min = [0 -180.64; 0.5 -103.88; 1 -48.73; 1.5 -20.03; 2 -9.28; 2.5 -10.79; 3 -18.68; 3.5 -27.81; 4 -37.31; 4.5 -47; 5 -56.74; 5.5 -66.53; 6 -76.37; 6.5 -86.38; 7 -97.24; 7.5 -110.72; 8 -144.24; 8.5 -196.45; 9 -257.84; 9.5 -346.99; 10 -257.92; 10.5 -191.92; 11 -136.18; 11.5 -103.84; 12 -90.18; 12.5 -79.34; 13 -69.5; 13.5 -59.98; 14 -50.59; 14.5 -41.36; 15 -32.3; 15.5 -23.55; 16 -15.29; 16.5 -8.14; 17 -9.04; 17.5 -20.7; 18 -49.4; 18.5 -106.78; 19 -183.13], [0 19])
#: Cortante en la misma losa, máximo y mínimo:
#fplot(V_max = [0 20.37; 0.5 20.57; 1 23.17; 1.5 33.74; 2 44.38; 2.5 55.08; 3 65.85; 3.5 76.67; 4 87.53; 4.5 98.42; 5 109.53; 5.5 128.39; 6 147.59; 6.5 167; 7 186.45; 7.5 205.79; 8 224.84; 8.5 243.44; 9 261.41; 9.5 278.58; 10 0.34; 10.5 11.45; 11 17.41; 11.5 24.21; 12 31.8; 12.5 40.12; 13 49.09; 13.5 58.65; 14 68.84; 14.5 85.21; 15 103.2; 15.5 120.13; 16 137.89; 16.5 156.31; 17 175.22; 17.5 194.45; 18 213.82; 18.5 233.17; 19 252.31], V_min = [0 -254.71; 0.5 -238.52; 1 -218.25; 1.5 -198.1; 2 -178.2; 2.5 -158.72; 3 -139.81; 3.5 -121.64; 4 -104.36; 4.5 -88.12; 5 -73.07; 5.5 -60.85; 6 -50.47; 6.5 -40.8; 7 -31.91; 7.5 -23.84; 8 -16.64; 8.5 -10.37; 9 -1.08; 9.5 0.85; 10 -265.01; 10.5 -244.89; 11 -226.54; 11.5 -207.8; 12 -188.83; 12.5 -169.83; 13 -150.97; 13.5 -132.43; 14 -114.37; 14.5 -100.84; 15 -88.14; 15.5 -77.19; 16 -66.25; 16.5 -55.35; 17 -44.5; 17.5 -33.74; 18 -23.07; 18.5 -20.73; 19 -20.46], [0 19])
#: Lo que cuenta la primera gráfica, en oficio:
#: - Dos jorobas positivas, una por celda, de unos 293-297 kN·m en el centro de cada vano.
#: - Un pico negativo clavado en x = 9.5 m, el muro central: -346.99 kN·m. Es el mayor de la hoja, y manda la armadura de arriba sobre el muro.
#: - En los extremos (x = 0 y x = 19) también hay negativo fuerte, -180 y -183 kN·m: la losa está unida a los muros exteriores, no simplemente apoyada.
#: - La curva de máximos y la de mínimos no se cruzan nunca: la envolvente no es una curva, son DOS, y la sección se arma para las dos.
#: La de cortante: el máximo aparece pegado a los muros (278.58 kN a la izquierda del muro central, -265.01 justo a su derecha) y pasa por cero cerca del centro de cada vano. El salto en x = 9.5 es la carga que baja por el muro.

## 13 · Cuánto pone el carril

#: El motor guarda las dos envolventes por separado: la del camión SOLO, antes de sumar el carril (cargaMovil.ts:388-389), y la total. Así se ve qué aporta cada uno. Momento máximo y mínimo del camión solo:
#fplot(M_max_camion = [0 45.61; 0.5 56.32; 1 96.41; 1.5 129.68; 2 164.01; 2.5 198; 3 221.27; 3.5 234.2; 4 237.47; 4.5 236.36; 5 238.78; 5.5 230.99; 6 212.62; 6.5 183.87; 7 145.29; 7.5 116.61; 8 86.59; 8.5 56.17; 9 18.59; 9.5 -4.77; 10 34.44; 10.5 70.52; 11 99.02; 11.5 126.82; 12 153.04; 12.5 189.05; 13 215.25; 13.5 231.25; 14 236.99; 14.5 240.16; 15 241.84; 15.5 237.27; 16 223.15; 16.5 198.98; 17 164.53; 17.5 129.54; 18 97.66; 18.5 63; 19 45.2], M_min_camion = [0 -143.48; 0.5 -82.99; 1 -38.84; 1.5 -16.25; 2 -7.88; 2.5 -8.64; 3 -14.96; 3.5 -22.25; 4 -29.76; 4.5 -37.38; 5 -45.05; 5.5 -52.76; 6 -60.49; 6.5 -68.26; 7 -76.02; 7.5 -83.81; 8 -107.57; 8.5 -145.45; 9 -188.09; 9.5 -254.45; 10 -188.17; 10.5 -140.92; 11 -99.5; 11.5 -76.93; 12 -68.96; 12.5 -61.21; 13 -53.63; 13.5 -46.21; 14 -38.89; 14.5 -31.73; 15 -24.75; 15.5 -17.99; 16 -11.57; 16.5 -5.98; 17 -7.65; 17.5 -16.92; 18 -39.52; 18.5 -85.9; 19 -145.98], [0 19])
#: Los picos, lado a lado:
#tabla("Resultado","Camión solo:2","Camión + carril:2","Aumento [%]:1")({"M máx [kN·m]","M mín [kN·m]","Flecha Uz mín [mm]"}; [241.84, -254.45, -9.694]; [297.61, -346.99, -12.323]; [23.1, 36.4, 27.1])
#: El carril no es un adorno: sube el momento negativo del muro central un 36 %. Y sube más el negativo que el positivo, porque la línea de influencia del muro es negativa en casi TODO el tablero (sección 7): el carril puede cargar los 19 m enteros y todos suman en contra.
#: En unidades de Ecuador, los picos que mandan:
M_pos_tonf = dec(297.61/9.80665, 3)
M_neg_tonf = dec(-346.99/9.80665, 3)
V_max_tonf = dec(279.95/9.80665, 3)

## 14 · ¿Está bien? Lo que tiene juez y lo que no

#: Regla de la casa: el oráculo es OTRO programa, mismo modelo, misma malla nodo a nodo, offsets = 0. Esto es lo que hay comprobado (validation/carga-movil/COMPARACION_ejemplo.md):
#tabla("Comprobación","Hekatan:4","SAP2000 24 (juez):4","OpenSeesPy:4","dif [%]:4")({"M3 máx envolvente [kN·m]","M3 mín envolvente [kN·m]","Uz mín [mm]","Peor componente P/V2/M3"}; [77.3201, -89.6117, -6.5198, 0]; [77.3201, -89.6117, -6.5198, 0]; [77.3201, -89.6117, -6.5198, 0]; [0, 0, 0, 0])
#: SÍ COMPROBADO: la alcantarilla del EJEMPLO, 2 celdas de 3.0 x 2.5 m con 0.30 m de espesor. SAP2000 24 y OpenSeesPy resolvieron los 61 casos unitarios y un código APARTE rehizo la envolvente de las 8 184 posiciones: 0.0000 % en Ux, Uz, Ry, P, V2 y M3. Cero a cuatro decimales significa que los tres programas hacen el MISMO cálculo.
#: Y hay una segunda comprobación, más dura todavía: SAP2000 tiene camión NATIVO (caso Moving Load y caso Multi-Step Static con vehículo), o sea que hace la carga móvil con SU propio código, no con casos estáticos que le pasamos nosotros. Se montó un carril sobre las 60 barras de la losa y dos vehículos generales (35/145/145 con 4.3 m, y el HL-93 con carril 9.3 kN/m y trasera 4.3-9.0). Resultado (registros/2026-09-19_alcantarilla_verificacion.md):
#tabla("Envolvente (ejemplo 3.0 x 2.5 m)","Hekatan:4","SAP2000 Moving Load nativo:4","dif [%]:3")({"Camión: M3 máx [kN·m]","Camión: M3 mín [kN·m]","Camión: Uz mín [mm]","HL-93 + carril: M3 máx [kN·m]","HL-93 + carril: M3 mín [kN·m]","HL-93 + carril: Uz mín [mm]"}; [71.5127, -77.7595, -5.8512, 77.3201, -89.6117, -6.5198]; [71.5128, -77.7599, -5.8512, 77.3194, -89.6053, -6.5198]; [0.000, 0.001, 0.000, 0.001, 0.007, 0.000])
#: Y el camión paso a paso de SAP (Multi-Step Static, 147 pasos): 134 pasos casan con Hekatan a 5e-10 % en Ux, Uz, Ry, P, V2 y M3, todos los nudos y todas las barras. Los pasos que no casan son de convenio, no de cálculo: SAP no carga un eje que cae justo en x = 0 (el inicio del carril) y Hekatan sí.
#: La hoja 51 de esta misma web, «Alcantarilla cajón con camión HL-93 - verificación analítica y SAP2000», lleva esa verificación con todas sus leyes: equilibrio, Maxwell-Betti, simetría y cotas a mano que encierran al elemento finito. Esta hoja EXPLICA; aquella VERIFICA.
#: Y una tercera: la misma alcantarilla hecha con PLACAS en vez de barras. La app deja elegir el elemento (Barras / Placas shell-thick / shell-thin) y la carga móvil corre igual, porque la línea de influencia no pregunta de qué está hecho el modelo. Resultados del registro de la verificación del 19-sep-2026 (caso EJEMPLO 3.0 x 2.5 m, 87 placas Q4, 172 nudos):
#|  fuente: registros/2026-09-19_alcantarilla_verificacion.md
#tabla("Comparación con PLACAS (ejemplo 3.0 x 2.5 m)","Desplazamientos [%]:4","Momento [%]:2")({"Hekatan placas vs SAP2000 shell-thick (26 pos., 172 nudos)","Hekatan placas vs Hekatan barras (shell-thick)","Hekatan placas vs Hekatan barras (shell-thin)"}; [0.0000, 0.14, 1.00]; [0.33, 1.09, 0.90])
#: Los dos primeros números dicen cosas distintas y conviene no confundirlos:
#: - Contra SAP2000, placa contra placa: 0.0000 % en desplazamientos y 0.33 % en M11. Eso es EL MISMO CÁLCULO; el 0.33 % es un solo momento de nudo junto al muro central (0.26 de 78 kN·m), el resto de nudos coincide.
#: - Placas contra barras: 0.14 % en Uz y 1.09 % en M3. Eso NO es un error: son dos modelos matemáticos distintos, una placa Q4 de Mindlin con ν = 0.2 contra una viga. Que difieran un 1 % es la señal de que los dos están bien y de que la teoría pesa poco aquí.
#: - En la envolvente HL-93 + carril: placas -6.5117 mm y 77.72 / -90.34 kN·m, barras -6.5198 mm y 77.32 / -89.61 kN·m. Un +0.5 % y un -0.8 %.
#: FALTA: el caso GRANDE de esta hoja, el de 9.5 x 6 m del enlace. Los números de las secciones 7 a 13 son del motor de Hekatan y están comprobados por equilibrio (suma de reacciones = suma de cargas a 1e-9 kN en todas las posiciones), pero SAP2000 aún no los ha arbitrado. No se ponen cifras de SAP2000 para este caso porque no existen: fabricarlas sería mentir.
#: FALTA TAMBIÉN: el ancho de reparto E de AASHTO (sección 3b). Mientras no haya norma en la PC, E = 1 m y avisado en naranja.

## 15 · Los límites, dichos y no escondidos

#: El propio motor los escribe en su cabecera (cargaMovil.ts:22-30). Repetidos aquí:
#: - Solo modelos LINEALES. Toda la hoja se apoya en la superposición. Muelles que solo trabajan a compresión (la zapata que se levanta del ejemplo 48) son NO lineales: ahí la superposición no vale y hay que resolver posición por posición.
#: - El eje entre dos nudos se reparte por la palanca. Es exacto solo si cae en nudo. Por eso se malla a 0.1 m.
#: - El carril no se dibuja en la animación: se ve el camión, pero en la envolvente el carril está sumado.
#: - El modelo es una franja de 1 m en el plano XZ, con los grados de libertad de fuera del plano bloqueados y un Ux en el nudo inferior izquierdo para que el cajón no deslice (modeloAlcantarilla.ts:13-16). Las cargas son verticales, así que esa reacción sale 0: es un apoyo de sujeción, no de carga.
#: - Sin factor de presencia múltiple (sección 3c) y sin reparto de la rueda por el relleno.

## 16 · La pantalla de la app, rótulo a rótulo

#: Esta sección lee la pantalla del ejemplo público como se lee un plano: qué es cada cosa y de dónde sale su número. Todo con el archivo:línea del código que lo dibuja.

#: **(a) Los rótulos rojos de los ejes: 14.79 · 14.79 · 3.57 tonf.**
#: Cada flecha roja es un eje del camión y su rótulo es la carga que ese eje mete EN EL MODELO, pasada a tonf. En letras:
rotulo = P_k/9.80665
#: Y ojo: P_k NO es el número de la norma tal cual. Es el de la norma, con el impacto y dividido por el ancho de reparto (cargaMovil.ts:82-84). O sea, el rótulo lleva dentro los dos factores de la sección 3 (el impacto y el ancho que tengas puestos en los mandos):
P_k = P_norma*(1 + IM_x/100)/E_x
#: El rótulo se escribe con dos decimales en animadorCargaMovil.ts:466. Ahora los números, con los valores por defecto del ejemplo (IM = 0 % en alcantarillaCargaMovil.ts:52, y E = 1 m en :53):
IM_def = 0
Er_def = 1
rot_trasero = dec(145*(1 + IM_def/100)/Er_def/9.80665, 2)
rot_delantero = dec(35*(1 + IM_def/100)/Er_def/9.80665, 2)
#: 14.79 y 3.57. Salen clavados. Así que la lectura correcta de esa pantalla es: **son los ejes del HL-93 SIN impacto y SIN repartir**, que es lo que trae el ejemplo abierto. No es que el programa no sepa aplicarlos: es que vienen apagados a propósito, para que se vea el efecto de la carga móvil sola.
#: Si subes el IM al 33 %, ese mismo rótulo cambia delante de tus ojos:
rot_IM33 = dec(145*(1 + 33/100)/1/9.80665, 2)
#: Y si pones un ancho de reparto de 3 m, se divide entre 3:
rot_E3 = dec(145*(1 + 0/100)/3/9.80665, 2)
#: Esa es la comprobación de que el rótulo no es un adorno: es la carga de verdad que entra al sistema de ecuaciones.

#: **(b) La caja blanca: «franja de cálculo 1 m».**
#: El modelo NO es la alcantarilla entera: es una REBANADA de 1 m de ancho, un pórtico plano (modeloAlcantarilla.ts:1-2). La caja blanca es exactamente esa rebanada: se dibuja en y = -0.5 y y = +0.5 (animadorCargaMovil.ts:307), un metro justo. La calzada gris de alrededor mide 9 m y es SOLO DIBUJO, para que las ruedas no se vean colgando en el aire antes de entrar (animadorCargaMovil.ts:225 y :390-392).
#: El porqué de la rebanada es el mismo de siempre en una alcantarilla: es larga y todas sus rebanadas trabajan igual, así que basta calcular una y repetirla. Todo lo que sale de la hoja está en «por metro de alcantarilla».
#: Y entonces, ¿cuánta carga le toca a esa rebanada? Ahí entra el ancho de reparto E:
P_franja = P_eje*(1 + IM_x/100)/E_x
#: Léelo como y = m·x con m = 1/E: cuanto más ancho repartes, menos carga por metro. Con E = 1 m se mete el EJE ENTERO en un solo metro, que es lo más desfavorable que puede pasar: nada se reparte a los lados. Por eso es el lado seguro.
#: ¿Qué cambiaría si hubiera fuente de AASHTO para la franja equivalente? Que E sería mayor que 1, y como el modelo es LINEAL, TODOS los resultados bajarían en la misma proporción 1/E. Eso sí se puede afirmar, porque es la superposición de la sección 4:
M_conE = M_con1/E_x
#: Con el momento negativo del muro central de esta hoja, -346.99 kN·m con E = 1 m, un reparto en 2 m daría:
M_E2 = dec(-346.99/2, 2)
#: y en 3 m:
M_E3 = dec(-346.99/3, 2)
#: Lo que NO se puede decir es CUÁNTO vale E, porque no hay norma en esta PC (sección 3b). Por eso el aviso naranja de la pantalla y por eso el mando está ahí, para que lo ponga quien tenga la norma delante.

#: **(c) Por qué el camión va en esa dirección, y qué pasa al entrar y al salir.**
#: El camino son los nudos de la losa superior ORDENADOS por la coordenada X (cargaMovil.ts:110-116), así que el camión avanza en +X. Manda el eje delantero, y los otros dos van detrás (cargaMovil.ts:277):
x_k = x_F - d_k
#: El recorrido no es el del tablero: empieza cuando el PRIMER eje pisa y acaba cuando el ÚLTIMO sale (cargaMovil.ts:288-293):
x_fin = L_tab + L_x
#: Con los números del ejemplo (tablero 19 m, camión corto 8.6 m):
x_fin = dec(19 + 8.6, 1)
#: Y lo que pasa mientras tanto: un eje cuya abscisa cae FUERA del camino no carga nada. El motor no lo tira a la basura, lo apunta aparte, en «fuera», para que se pueda comprobar el equilibrio (cargaMovil.ts:263 y :272). En letras, la carga que de verdad está sobre la estructura en cada posición es:
P_dentro = P_camion - P_fuera
#: Por eso el arranque de la animación es tan suave: durante los primeros 4.3 m solo está dentro el eje delantero, el de 3.57 tonf, que es la novena parte del camión. Y por eso el final también baja despacio: los ejes se van saliendo de uno en uno.

#: **(d) El eje que cae entre dos nudos.**
#: Es el caso general y se resuelve con la regla de la palanca (sección 8): lo que está más cerca se lleva más. El reparto conserva las dos cosas que importan, la fuerza total y su momento respecto de los dos nudos:
w_i = P_eje*(1 - t)
w_j = P_eje*t
suma = w_i + w_j
#: Y basta porque el modelo es LINEAL: la respuesta a dos cargas es la suma de las respuestas (sección 4). En esta pantalla, además, ni siquiera hace falta: el tablero está mallado cada 0.1 m y el camión avanza cada 0.1 m, así que los ejes caen SIEMPRE en nudo y el contador «repartido» del motor sale 0. La carga móvil es exacta.

#: **(e) Los colores de la deformada.**
#: El color de cada punto es su desplazamiento TOTAL dividido por el peor desplazamiento de TODO el recorrido (animadorCargaMovil.ts:290 y :480-491). En letras:
mag = sqrt(u_x^2 + u_z^2)
color = mag/u_ref
#: La clave es que u_ref es FIJO: no es el máximo de este fotograma, es el de los 277 fotogramas. Por eso, cuando entra el eje pequeño, la losa se pinta azul aunque sí se esté moviendo: se mueve el 6-24 % de lo que se moverá después. Cuando entra el primer eje de 14.79 tonf salta al 79 % y se pone naranja. Si la escala fuera la de cada cuadro, todo se vería rojo siempre y no se aprendería nada.
#: Y la deformada está AMPLIFICADA, porque si no no se vería. La regla es: el peor desplazamiento del recorrido se dibuja como el 1.5 % de la diagonal del modelo (animadorCargaMovil.ts:226 y :491):
esc_def = 0.015*diag/u_max
#: Los números de esta alcantarilla. La diagonal del cuadro que ocupa el modelo (19 m de largo por 6 m de alto):
diag = dec((19^2 + 6^2)^0.5, 4)
#: El peor desplazamiento de todo el recorrido, medido en el motor:
u_max = 0.0098386
#: Y el tamaño con el que se dibuja, y el factor:
dibujado = dec(0.015*diag, 3)
esc_def = dec(0.015*diag/u_max, 1)
#: O sea que la deformada va multiplicada por unas 30 veces, y 9.84 mm de flecha real se dibujan como 30 cm. El factor no se esconde: la app lo escribe en pantalla («deformada xN»). Es la misma idea que el «Auto» de SAP2000 para los modos, pero más prudente: con el 3.7 % que usa el modal, esta alcantarilla salía de goma (x75) y los muros se veían doblados como si fueran de plastilina.
