# ShellMITC4 de OpenSees paso a paso: por qué el C++ hace lo que hace
#numerico
#: Hoja de la clase «OpenSees · ShellMITC4». Cada paso va de la **pregunta** a la **idea**, de la idea al **símbolo** (lo deduce el motor) y del símbolo a la **línea de C++** de `SRC/element/shell/ShellMITC4.cpp` (OpenSees master, 2555 líneas). Los números son del elemento de la **zapata de Guerra** (cap. 5, ej. 1): un cuadrado de 0.345 m, h = 0.45 m, en t y m.
#: Verificación: la réplica numpy del C++ da la K 24 × 24 de OpenSees corriendo con error relativo 1e-16 (hekatan-school/VIDEOS/mitc4_clase/datos.py).

## 1 · ¿Qué hace la cáscara? Membrana + placa + giro en el plano
#: Cada nudo lleva 6 números: u1, u2 de **membrana** (estirarse en su plano), w, θ1, θ2 de **placa** (flexión y cortante) y θ3 de **drilling** (giro en su plano). C++: comentario de `formResidAndTangent`, líneas 1332-1343; `ndf = 6` l.1370; `nstress = 8` l.1372 (3 de membrana, 3 momentos, 2 cortantes).
E = 14100*sqrt(280)*10 'módulo del hormigón f'c = 280, en t/m²
nu = 0.2
h = 0.45 'espesor de la zapata, m
#: La sección (ElasticMembranePlateSection.cpp, l.244-267) da cuatro rigideces:
M_m = E/(1 - nu^2)*h 'membrana, t/m
G_h = 0.5*E/(1 + nu)*h 'cortante en el plano, t/m
D_b = E*h^3/12/(1 - nu^2) 'flexión, t·m
G_s = 5/6*G_h 'cortante transversal con κ = 5/6 (five6, l.41 y l.265)
#: **Drilling.** La membrana Q4 no tiene rigidez para θ3: la K saldría singular. OpenSees le pone una rigidez ficticia Ktt = el menor autovalor del bloque de membrana (l.397-401). En un material isótropo los autovalores son M(1+ν), M(1−ν) y G·h; el menor es G·h:
eig_1 = M_m*(1 + nu)
eig_2 = M_m*(1 - nu)
Ktt = G_h 'el menor de los tres

## 2 · ¿En qué ejes se mide? La base local (computeBasis, l.1788-1835)
#: Si el elemento está inclinado en el espacio, x e y del elemento no son los globales. v1 = ½(nudo3 + nudo2 − nudo4 − nudo1): la dirección media «de izquierda a derecha». v2 = ½(nudo4 + nudo3 − nudo2 − nudo1), con Gram-Schmidt para que sea perpendicular a v1. v3 = v1 × v2 es la normal. Con un cuadrilátero inclinado (el distorsionado de la clase girado 35° y 20°, datos.py):
X_i = [0.5, 0.3, 1; 2.3794, 0.8562, 0.5544; 2.6613, 2.2257, 1.3881; 0.406, 1.5091, 1.8884]
w_1 = 0.5*(X_i(3, :) + X_i(2, :) - X_i(4, :) - X_i(1, :))
v_1 = w_1/norm(w_1)
w_2 = 0.5*(X_i(4, :) + X_i(3, :) - X_i(2, :) - X_i(1, :))
al = w_2(1)*v_1(1) + w_2(2)*v_1(2) + w_2(3)*v_1(3) 'alpha = v2·v1 de Gram-Schmidt (l.1812)
u_2 = w_2 - al*v_1
v_2 = u_2/norm(u_2)
v_3 = [v_1(2)*v_2(3) - v_1(3)*v_2(2), v_1(3)*v_2(1) - v_1(1)*v_2(3), v_1(1)*v_2(2) - v_1(2)*v_2(1)] 'la normal v1 × v2 (LovelyCrossProduct, l.1825)
#: Las coordenadas locales son las proyecciones (l.1833-1834): xl = X·v1, yl = X·v2. No se resta el nudo 1: solo importan las diferencias.
x_l = X_i*transpose(v_1)
y_l = X_i*transpose(v_2)

## 3 · Una sola fórmula para todos: el elemento padre [−1, 1]²
#: Cada elemento real tiene otra forma; se escribe todo en un cuadrado fijo de ξ, η entre −1 y 1. El C++ (shape2d, l.2196-2206) escribe las funciones con s_k, t_k = ±½: N_k = (½ + s_k·ξ)(½ + t_k·η). Son las bilineales de siempre:
N_1 = Expand{(1/2 - xi/2)*(1/2 - eta/2)}
N_2 = Expand{(1/2 + xi/2)*(1/2 - eta/2)}
N_3 = Expand{(1/2 + xi/2)*(1/2 + eta/2)}
N_4 = Expand{(1/2 - xi/2)*(1/2 + eta/2)}
#: Derivadas respecto a ξ y η (l.2204-2205: shp[0] = s_k·(½ + t_k·η), shp[1] = t_k·(½ + s_k·ξ)):
dN1_dxi = Partial{(1/2 - xi/2)*(1/2 - eta/2) @ xi}
dN1_deta = Partial{(1/2 - xi/2)*(1/2 - eta/2) @ eta}
#: **Jacobiano** (l.2211-2222): xs = Σ x_k·∂N_k/∂ξ. Para un rectángulo de lados L_x × L_y con el nudo 1 en el origen, x = L_x·(N_2 + N_3) e y = L_y·(N_3 + N_4):
x_r = Simplify{Lx*((1/2 + xi/2)*(1/2 - eta/2) + (1/2 + xi/2)*(1/2 + eta/2))}
y_r = Simplify{Ly*((1/2 + xi/2)*(1/2 + eta/2) + (1/2 - xi/2)*(1/2 + eta/2))}
J11 = Partial{Lx*(1+xi)/2 @ xi}
J12 = Partial{Lx*(1+xi)/2 @ eta}
J21 = Partial{Ly*(1+eta)/2 @ xi}
J22 = Partial{Ly*(1+eta)/2 @ eta}
detJ_r = Simplify{J11*J22 - J12*J21}
#: det J = L_x·L_y/4: el área real (L_x·L_y) entre el área del padre (4). Es el factor que convierte dξ·dη en dx·dy. En un cuadrilátero cualquiera J cambia de punto a punto; en el distorsionado de la clase, en el primer punto de Gauss:
X_d = [0, 0; 2, 0.2; 2.3, 1.8; -0.1, 1.5]
s_g = 1/sqrt(3)
dN_g(xi, eta) = 0.25*[-(1 - eta), (1 - eta), (1 + eta), -(1 + eta); -(1 - xi), -(1 + xi), (1 + xi), (1 - xi)]
J_g1 = dN_g(-s_g, -s_g)*X_d
detJ_g1 = det(J_g1) 'xsj del punto 1
#: Las derivadas reales salen con la inversa (l.2225-2238): [∂N/∂x; ∂N/∂y] = J⁻¹·[∂N/∂ξ; ∂N/∂η]:
dNxy_g1 = inv(J_g1)*dN_g(-s_g, -s_g)

## 4 · ¿Por qué Gauss 2 × 2? La integral se vuelve un bucle de 4 vueltas
#: K = ∫∫ Bᵀ·D·B dx·dy. Con 4 puntos (±1/√3, ±1/√3) y peso 1 (l.234-247) la suma es EXACTA para polinomios hasta grado 3 en cada dirección. Prueba con el motor: integral exacta contra la suma de 4 puntos.
I_22 = Area{Area{xi^2*eta^2 @ xi = -1 : 1} @ eta = -1 : 1} 'exacta
G_22 = 4*(1/3)*(1/3) 'Gauss: cuatro puntos con ξ² = η² = 1/3
I_32 = Area{Area{(1 + xi)^3*eta^2 @ xi = -1 : 1} @ eta = -1 : 1}
G_32 = ((1 - s_g)^3 + (1 + s_g)^3)*2*(1/3)
I_4 = Area{Area{xi^4 @ xi = -1 : 1} @ eta = -1 : 1} 'grado 4: Gauss 2 × 2 ya no acierta
G_4 = 4*(1/9)
#: En el C++ cada vuelta multiplica por dvol = w·det J (l.1532): el peso por el área que representa el punto. Suma de los 4 dvol del distorsionado = su área:
A_g = det(dN_g(-s_g, -s_g)*X_d) + det(dN_g(s_g, -s_g)*X_d) + det(dN_g(s_g, s_g)*X_d) + det(dN_g(-s_g, s_g)*X_d)

## 5 · Las filas de B, nudo por nudo
#: B convierte los 6 desplazamientos de UN nudo en las 8 deformaciones. Se arma un nudo a la vez (bucle j, l.1553) porque la B de un nudo solo depende de SU función de forma; las cuatro se guardan (saveB, l.1569-1572) y K se arma por bloques 6 × 6: K_jk = B_jᵀ·D·B_k.
#: **Membrana** (computeBmembrane, l.2140-2143): ε11 = N,1·u1; ε22 = N,2·u2; γ12 = N,2·u1 + N,1·u2.
#: **Flexión** (computeBbend, l.2171-2174): κ11 = −N,1·θ2; κ22 = N,2·θ1; 2κ12 = N,1·θ1 − N,2·θ2.
#: **Drilling** (computeBdrill, l.1973-1977): [−½·N,2, +½·N,1, −N] sobre [u1, u2, θ3].
#: Para el nudo 1 de un rectángulo de lados 2a × 2b (centro en el origen), ∂N_1/∂x y ∂N_1/∂y:
N1_x = Simplify{Partial{(1-xi)*(1-eta)/4 @ xi}/a}
N1_y = Simplify{Partial{(1-xi)*(1-eta)/4 @ eta}/b}
#: y sus filas (columnas [θ1, θ2] en la flexión):
Bbend_1 = Simplify{[0, -(-(1-eta)/(4*a)); -(1-xi)/(4*b), 0; -(1-eta)/(4*a), -(-(1-xi)/(4*b))]}
#: El signo: la sección da M = −D·κ (dd(3,3) = −D en la sección), y el elemento cambia el signo del bloque de flexión de BJ (l.1641-1646): (−Bb)ᵀ(−D)Bb = +BbᵀDBb.

## 6 · El bloqueo por cortante y la corrección MITC4
#: Placa delgada en **flexión pura**: el giro θy va de −θ0 a +θ0 a lo largo de x y la flecha w es 0 en los cuatro nudos. La teoría dice γxz = ∂w/∂x + θy = 0 (una placa delgada no se deforma por cortante). Pero con las bilineales el elemento solo puede hacer:
th_y(xi, eta) = Simplify{-t0*(1-xi)*(1-eta)/4 + t0*(1+xi)*(1-eta)/4 + t0*(1+xi)*(1+eta)/4 - t0*(1-xi)*(1+eta)/4}
#: Como w = 0 en los nudos, ∂w/∂x = 0 y el cortante directo es solo el giro interpolado:
g_dir(xi, eta) = th_y(xi, eta) 'γ = θ0·ξ: distinto de cero
#: En los puntos de Gauss vale ±θ0/√3: el elemento «cree» que hay cortante y lo cobra con G_s·h, que es enorme frente a la flexión. Energía de cortante falsa contra energía de flexión verdadera (κ = θ0/a):
U_s = Simplify{1/2*Gs*a*b*Area{Area{(t0*xi)^2 @ xi = -1 : 1} @ eta = -1 : 1}}
U_b = Simplify{1/2*Db*(t0/a)^2*4*a*b}
r_sb = Simplify{U_s/U_b}
#: Con G_s = (5/6)·G·h y D = E·h³/(12(1−ν²)), el cociente crece como (a/h)²: cuanto más delgada, más se bloquea.
rsb_h = Simplify{(5/6*Ee/(2*(1+nn))*hh)*a^2/(3*Ee*hh^3/(12*(1-nn^2)))}
#: **La idea MITC4.** En el centro de cada lado (puntos de amarre A(0, −1), B(0, +1) para γxz; C(−1, 0), D(+1, 0) para γyz) el cortante falso vale CERO. Se mide solo ahí y se interpola linealmente: γxz(ξ, η) = ½(1 − η)·γ_A + ½(1 + η)·γ_B.
g_A = g_dir(0, -1) 'punto de amarre A, centro del lado de abajo
g_B = g_dir(0, 1) 'punto de amarre B, centro del lado de arriba
g_mitc = Simplify{(1-eta)/2*g_A + (1+eta)/2*g_B} 'cero en todo el elemento: no hay bloqueo
#: En el C++ los puntos de amarre son las filas de G(4,12) (l.1462-1488): una por lado (4-1, 1-2, 2-3, 3-4) con ±½ para las w (diferencia de flechas) y ±Δy/4, Δx/4 para los giros (giro medio del lado por el largo del lado). La interpolación lineal es Ms (l.1535-1538) con (1 − s), (1 − t), (1 + s), (1 + t); r/(8·det J) (l.1542-1543) pasa de cortante «por lado» a cortante por unidad de largo, y Rot (l.1503-1510) lo gira a los ejes x, y.

## 7 · El bucle de formStiffness: la caja que empieza en cero
#: K = Σ_{gp=1..4} Σ_{j=1..4} Σ_{k=1..4} B_jᵀ·D·B_k·dvol_gp (l.1518 bucle de Gauss, l.1633 nudo j, l.1676 nudo k, l.1693-1698 stiff(jj+p, kk+q) += ...). Con el elemento de la zapata, el término de la flecha del nudo 1 (solo cortante: la flexión no toca a w) en cada vuelta:
a_z = 0.345/2 'semilado
d_z = a_z*a_z 'det J del cuadrado: (0.345/2)², igual en los 4 puntos
#: Fila de γxz y γyz para la columna w1 (MITC4 en un rectángulo: −1/(4a)·(1 ∓ η) y −1/(4b)·(1 ∓ ξ) medidos en los lados):
kw(xi, eta) = d_z*G_s*((-(1 - eta)/(4*a_z))^2 + (-(1 - xi)/(4*a_z))^2)
K_0 = 0 'la caja empieza en cero (stiff.Zero(), l.1442)
K_1 = K_0 + kw(-s_g, -s_g)
K_2 = K_1 + kw(s_g, -s_g)
K_3 = K_2 + kw(s_g, s_g)
K_4 = K_3 + kw(-s_g, s_g)
#: OpenSees corriendo (printA) da K[w1, w1] = 245768.882794 t/m: K_4 tiene que dar eso. En la columna de w la fila MITC4 de un rectángulo es igual a la directa (∂w/∂x ya es lineal en η); la diferencia MITC está en las columnas de los giros, que es donde nacía el cortante falso del paso 6.
K_ops = 245768.882794 't/m, OpenSees printA
err_K = (K_4 - K_ops)/K_ops

## 8 · La zapata entera
#: 100 elementos así, 121 nudos con muelles de Vínkler ks = 2920 t/m³, carga de servicio P = 121 t y My = 17 t·m en el centro. El mismo bucle (réplica) y OpenSees corriendo dan la misma presión máxima:
sigR = 13.249780 't/m², réplica numpy del C++ (calc_extra.py)
sigO = 13.249780 't/m², openseespy 3.7.1 (zapata_opensees.py)
sigL = 13.163 't/m², SAFE en el libro de Guerra
difL = (sigO - sigL)/sigL*100 '% de diferencia con el libro
