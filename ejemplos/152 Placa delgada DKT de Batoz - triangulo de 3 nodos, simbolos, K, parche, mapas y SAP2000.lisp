# Placa delgada DKT de Batoz (triángulo de 3 nodos, 9 GDL) · símbolos, K, parche, mapas y SAP2000
#numerico
#: Elemento DKT (Discrete Kirchhoff Triangle) de Batoz, Bathe y Ho (1980): el triángulo de placa delgada que usa Shell-Thin de CSI. Tres grados de libertad por nodo: w, θx = ∂w/∂y, θy = −∂w/∂x. Primero todo en símbolos y después con números; se valida con la prueba de parche, los cuerpos rígidos, los mapas de momentos y la comparación con SAP2000 y ETABS. Solo flexión: la membrana y el drilling son otro elemento.

## 1 · Símbolos: de dónde salen los coeficientes
#: Sobre el lado k (de i a j, largo l) la rotación a lo largo del lado sigue un cubo y la normal es lineal. En el punto medio:
#: βs = −3/(2·l)·(wj − wi) − 1/4·(βs_i + βs_j) · βn = 1/2·(βn_i + βn_j)
#: Se pasan a x, y con C = x_ji/l, S = y_ji/l: βx = C·βs − S·βn, βy = S·βs + C·βn. De ahí los cinco coeficientes de cada lado:
a_k = Simplify{-x_ij/(x_ij^2 + y_ij^2)}
b_k = Simplify{3/4*x_ij*y_ij/(x_ij^2 + y_ij^2)}
c_k = Simplify{(1/4*x_ij^2 - 1/2*y_ij^2)/(x_ij^2 + y_ij^2)}
d_k = Simplify{-y_ij/(x_ij^2 + y_ij^2)}
e_k = Simplify{(1/4*y_ij^2 - 1/2*x_ij^2)/(x_ij^2 + y_ij^2)}
#: Comprobación del coeficiente c: lo que aporta βx_i a βx_k es C·(−1/4·C) − S·(1/2)·(−S):
c_comprueba = Simplify{-(C*(-1/4*C) - S*(1/2*(-S)))}
#: Con C² = x²/l² y S² = y²/l² da 1/4·C² − 1/2·S², igual que c_k.

## 2 · Símbolos: el triángulo patrón (nodos (0,0), (a,0), (0,a))
#: Interpolación cuadrática de seis nodos: N1 = (1−ξ−η)(1−2ξ−2η), N2 = ξ(2ξ−1), N3 = η(2η−1) y de lado N4 = 4ξη, N5 = 4η(1−ξ−η), N6 = 4ξ(1−ξ−η).
N1 = Simplify{(1-xi-eta)*(1-2*xi-2*eta)}
N2 = Simplify{xi*(2*xi-1)}
N3 = Simplify{eta*(2*eta-1)}
N4 = Simplify{4*xi*eta}
N5 = Simplify{4*eta*(1-xi-eta)}
N6 = Simplify{4*xi*(1-xi-eta)}
Jt = Simplify{[a, 0; 0, a]}
Dt = Simplify{det([a, 0; 0, a])}
#: Rigidez a flexión de la placa y matriz de comportamiento:
Dpl = Simplify{Em*t^3/(12*(1-nu^2))}
Db = Simplify{Dpl*[1, nu, 0; nu, 1, 0; 0, 0, (1-nu)/2]}
#: Energía de curvatura constante κxx = 1 sobre el área A = a²/2: U = 1/2·Dpl·A
U_const = Simplify{1/2*Dpl*a^2/2}

## 3 · Números: datos
Em = 24850000
nu = 0.2
t = 0.1
Dpl = Em*t^3/(12*(1-nu^2))
Db = Dpl*[1, nu, 0; nu, 1, 0; 0, 0, (1-nu)/2]

## 4 · DKT con números (triángulo cualquiera)
x1 = 0
y1 = 0
x2 = 2
y2 = 0.5
x3 = 0.5
y3 = 1.5
Jt = [x2-x1, y2-y1; x3-x1, y3-y1]
At = det(Jt)/2
#: Lado 4 = nodos 2-3, lado 5 = 3-1, lado 6 = 1-2:
l4 = (x2-x3)^2 + (y2-y3)^2
l5 = (x3-x1)^2 + (y3-y1)^2
l6 = (x1-x2)^2 + (y1-y2)^2
a4 = -(x2-x3)/l4
a5 = -(x3-x1)/l5
a6 = -(x1-x2)/l6
b4 = 0.75*(x2-x3)*(y2-y3)/l4
b5 = 0.75*(x3-x1)*(y3-y1)/l5
b6 = 0.75*(x1-x2)*(y1-y2)/l6
c4 = (0.25*(x2-x3)^2 - 0.5*(y2-y3)^2)/l4
c5 = (0.25*(x3-x1)^2 - 0.5*(y3-y1)^2)/l5
c6 = (0.25*(x1-x2)^2 - 0.5*(y1-y2)^2)/l6
d4 = -(y2-y3)/l4
d5 = -(y3-y1)/l5
d6 = -(y1-y2)/l6
e4 = (0.25*(y2-y3)^2 - 0.5*(x2-x3)^2)/l4
e5 = (0.25*(y3-y1)^2 - 0.5*(x3-x1)^2)/l5
e6 = (0.25*(y1-y2)^2 - 0.5*(x1-x2)^2)/l6
#: Las filas Hx y Hy son lineales en las seis N; se les pasan las N o sus derivadas:
Hx_t(n1, n2, n3, n4, n5, n6) = [1.5*(a6*n6 - a5*n5); b5*n5 + b6*n6; n1 - c5*n5 - c6*n6; 1.5*(a4*n4 - a6*n6); b6*n6 + b4*n4; n2 - c6*n6 - c4*n4; 1.5*(a5*n5 - a4*n4); b4*n4 + b5*n5; n3 - c4*n4 - c5*n5]
Hy_t(n1, n2, n3, n4, n5, n6) = [1.5*(d6*n6 - d5*n5); -n1 + e5*n5 + e6*n6; -b5*n5 - b6*n6; 1.5*(d4*n4 - d6*n6); -n2 + e6*n6 + e4*n4; -b6*n6 - b4*n4; 1.5*(d5*n5 - d4*n4); -n3 + e4*n4 + e5*n5; -b4*n4 - b5*n5]
#: Inverso del Jacobiano (constante en el triángulo): [∂x; ∂y] = J⁻¹·[∂ξ; ∂η]
Ji = inv(Jt)
J11 = Ji(1, 1)
J12 = Ji(1, 2)
J21 = Ji(2, 1)
J22 = Ji(2, 2)
#: Derivadas de Hx y Hy respecto a x e y (cada una es una columna de 9). Las derivadas de las N respecto a ξ: (4(ξ+η)−3, 4ξ−1, 0, 4η, −4η, 4(1−2ξ−η)); respecto a η: (4(ξ+η)−3, 0, 4η−1, 4ξ, 4(1−ξ−2η), −4ξ)
Hx_x(xi, eta) = J11*Hx_t(4*(xi+eta)-3, 4*xi-1, 0, 4*eta, -4*eta, 4*(1-2*xi-eta)) + J12*Hx_t(4*(xi+eta)-3, 0, 4*eta-1, 4*xi, 4*(1-xi-2*eta), -4*xi)
Hx_y(xi, eta) = J21*Hx_t(4*(xi+eta)-3, 4*xi-1, 0, 4*eta, -4*eta, 4*(1-2*xi-eta)) + J22*Hx_t(4*(xi+eta)-3, 0, 4*eta-1, 4*xi, 4*(1-xi-2*eta), -4*xi)
Hy_x(xi, eta) = J11*Hy_t(4*(xi+eta)-3, 4*xi-1, 0, 4*eta, -4*eta, 4*(1-2*xi-eta)) + J12*Hy_t(4*(xi+eta)-3, 0, 4*eta-1, 4*xi, 4*(1-xi-2*eta), -4*xi)
Hy_y(xi, eta) = J21*Hy_t(4*(xi+eta)-3, 4*xi-1, 0, 4*eta, -4*eta, 4*(1-2*xi-eta)) + J22*Hy_t(4*(xi+eta)-3, 0, 4*eta-1, 4*xi, 4*(1-xi-2*eta), -4*xi)
#: Las tres filas de B (curvaturas κxx = βx,x, κyy = βy,y, κxy = βx,y + βy,x):
B1_t(xi, eta) = Hx_x(xi, eta)
B2_t(xi, eta) = Hy_y(xi, eta)
B3_t(xi, eta) = Hx_y(xi, eta) + Hy_x(xi, eta)
#: BᵀDB = suma de Db(i,j)·(fila i)ᵀ·(fila j):
kb_t(xi, eta) = Db(1, 1)*B1_t(xi, eta)*transpose(B1_t(xi, eta)) + Db(1, 2)*(B1_t(xi, eta)*transpose(B2_t(xi, eta)) + B2_t(xi, eta)*transpose(B1_t(xi, eta))) + Db(2, 2)*B2_t(xi, eta)*transpose(B2_t(xi, eta)) + Db(3, 3)*B3_t(xi, eta)*transpose(B3_t(xi, eta))
#: Tres puntos de Gauss (puntos medios de los lados), peso A/3 cada uno:
K_dkt = At/3*(kb_t(0.5, 0) + kb_t(0.5, 0.5) + kb_t(0, 0.5))
K_dkt_11 = K_dkt(1, 1)
K_dkt_22 = K_dkt(2, 2)
K_dkt_33 = K_dkt(3, 3)

## 5 · DKT: prueba de parche y cuerpo rígido
#: Curvatura constante w = x²/2: w = x²/2, θx = ∂w/∂y = 0, θy = −∂w/∂x = −x en cada nodo.
u_par_t = [x1^2/2; 0; -x1; x2^2/2; 0; -x2; x3^2/2; 0; -x3]
#: B·u debe dar (−1, 0, 0) en cualquier punto:
kxx_t = transpose(B1_t(0.2, 0.3))*u_par_t
kyy_t = transpose(B2_t(0.2, 0.3))*u_par_t
kxy_t = transpose(B3_t(0.2, 0.3))*u_par_t
U_t = 0.5*transpose(u_par_t)*K_dkt*u_par_t
U_t_exacta = 0.5*Dpl*At
#: Traslación vertical y giro rígido (w = x): K·u debe ser cero.
u_tras_t = [1; 0; 0; 1; 0; 0; 1; 0; 0]
f_tras_t = K_dkt*u_tras_t
u_giro_t = [x1; 0; -1; x2; 0; -1; x3; 0; -1]
f_giro_t = K_dkt*u_giro_t

## 6 · Comparación con SAP2000 (Plate-Thin)
#: Mismo triángulo de la sección 4 y el campo w = x³/6 + x·y²/2 impuesto como desplazamientos en los tres nodos (w, θx = x·y, θy = −(x²+y²)/2). Con los 9 GDL restringidos, la reacción de SAP2000 es K·u. SAP2000 24: área Plate-Thin, sin malla automática, unidades kN y m.
wf(x, y) = x^3/6 + x*y^2/2
u_s_t = [wf(x1, y1); x1*y1; -(x1^2+y1^2)/2; wf(x2, y2); x2*y2; -(x2^2+y2^2)/2; wf(x3, y3); x3*y3; -(x3^2+y3^2)/2]
f_t = K_dkt*u_s_t
#: Reacciones de SAP2000 (w, θx, θy de cada nodo), copiadas de su salida [SAP2000 OAPI]:
f_sap_t = [3644.278276; -82.364302; -555.595142; -2513.109557; 642.343285; -3290.592954; -1131.168719; 2393.328875; -1745.615377]
dif_t = f_t - f_sap_t
err_t = 100*sqrt(transpose(dif_t)*dif_t)/sqrt(transpose(f_sap_t)*f_sap_t)
#: Momentos del DKT en cada nodo (B evaluada en el nodo, coordenadas de área):
Mxx_nt(xi, eta) = Db(1, 1)*transpose(B1_t(xi, eta))*u_s_t + Db(1, 2)*transpose(B2_t(xi, eta))*u_s_t
Myy_nt(xi, eta) = Db(1, 2)*transpose(B1_t(xi, eta))*u_s_t + Db(2, 2)*transpose(B2_t(xi, eta))*u_s_t
Mxy_nt(xi, eta) = Db(3, 3)*transpose(B3_t(xi, eta))*u_s_t
M_t1 = [Mxx_nt(0, 0), Myy_nt(0, 0), Mxy_nt(0, 0)]
M_t2 = [Mxx_nt(1, 0), Myy_nt(1, 0), Mxy_nt(1, 0)]
M_t3 = [Mxx_nt(0, 1), Myy_nt(0, 1), Mxy_nt(0, 1)]
#: SAP2000 (M11, M22, M12) en los nodos 1 a 3 [SAP2000 OAPI]. SAP2000 da el momento con el signo contrario al de esta hoja (M11 = −Mxx, M22 = −Myy, M12 = −Mxy), así que la suma de los dos debe dar cero:
M_sapt1 = [-611.491059, -740.226019, 836.777239]
M_sapt2 = [5144.695506, 4237.836331, 700.908084]
M_sapt3 = [455.257503, 1573.941943, 2153.497718]
n3(v) = sqrt(v(1)^2 + v(2)^2 + v(3)^2)
err_M_t = 100*sqrt(n3(M_t1 + M_sapt1)^2 + n3(M_t2 + M_sapt2)^2 + n3(M_t3 + M_sapt3)^2)/sqrt(n3(M_sapt1)^2 + n3(M_sapt2)^2 + n3(M_sapt3)^2)

#: ETABS 22 (OAPI, losa Shell-Thin, OBJMESHTYPE NOAUTOMESH para que no remalle; sus GDL de membrana quedan en cero, así que no afectan la flexión). Mismas reacciones y mismos momentos [ETABS OAPI]:
f_etabs_t = [3644.278338; -82.364139; -555.595033; -2513.109192; 642.343417; -3290.592722; -1131.169146; 2393.329038; -1745.615202]
err_t_etabs = 100*sqrt(transpose(f_t - f_etabs_t)*(f_t - f_etabs_t))/sqrt(transpose(f_etabs_t)*f_etabs_t)
M_etabst1 = [-611.490864, -740.226179, 836.777226]
M_etabst2 = [5144.69518, 4237.835935, 700.908183]
M_etabst3 = [455.257903, 1573.942229, 2153.497644]
err_M_t_etabs = 100*sqrt(n3(M_t1 + M_etabst1)^2 + n3(M_t2 + M_etabst2)^2 + n3(M_t3 + M_etabst3)^2)/sqrt(n3(M_etabst1)^2 + n3(M_etabst2)^2 + n3(M_etabst3)^2)

## 7 · Mapas sobre el triángulo de SAP2000 y ETABS (para comparar con el ratón)
#: El mismo triángulo (0,0), (2,0.5), (0.5,1.5) y el mismo campo de las secciones 4 y 6. Se pasa de x, y a ξ, η con el inverso del Jacobiano: ξ = (x−x1)·J11 + (y−y1)·J21, η = (x−x1)·J12 + (y−y1)·J22. Solo vale dentro del triángulo. Pasa el ratón por los nodos: en (0,0), (2,0.5) y (0.5,1.5) debe leer Mxx = −M11 de SAP2000 y ETABS (−611.49, 5144.70, 455.26 con el signo de SAP).
xi_p(x, y) = (x - x1)*J11 + (y - y1)*J21
eta_p(x, y) = (x - x1)*J12 + (y - y1)*J22
Mxx_p(x, y) = Mxx_nt(xi_p(x, y), eta_p(x, y))
Myy_p(x, y) = Myy_nt(xi_p(x, y), eta_p(x, y))
Mxy_p(x, y) = Mxy_nt(xi_p(x, y), eta_p(x, y))
#: Mxx (kN·m/m):
#map(Mxx_p(x, y), [0 2], [0 1.5])
#: Myy (kN·m/m):
#map(Myy_p(x, y), [0 2], [0 1.5])
#: Mxy (kN·m/m):
#map(Mxy_p(x, y), [0 2], [0 1.5])

## 8 · Mapas de Mxx, Myy y Mxy (pasa el ratón y lee el valor)
#: El mismo campo w = x³/6 + x·y²/2 sobre un triángulo recto de catetos 4 y 3: nodos (0,0), (4,0), (0,3), con ξ = x/4 y η = y/3. Solo vale el trozo bajo la diagonal (x/4 + y/3 ≤ 1); el resto del recuadro es extrapolación y no cuenta.
x1 = 0
y1 = 0
x2 = 4
y2 = 0
x3 = 0
y3 = 3
Jt = [x2-x1, y2-y1; x3-x1, y3-y1]
At = det(Jt)/2
#: Lado 4 = nodos 2-3, lado 5 = 3-1, lado 6 = 1-2:
l4 = (x2-x3)^2 + (y2-y3)^2
l5 = (x3-x1)^2 + (y3-y1)^2
l6 = (x1-x2)^2 + (y1-y2)^2
a4 = -(x2-x3)/l4
a5 = -(x3-x1)/l5
a6 = -(x1-x2)/l6
b4 = 0.75*(x2-x3)*(y2-y3)/l4
b5 = 0.75*(x3-x1)*(y3-y1)/l5
b6 = 0.75*(x1-x2)*(y1-y2)/l6
c4 = (0.25*(x2-x3)^2 - 0.5*(y2-y3)^2)/l4
c5 = (0.25*(x3-x1)^2 - 0.5*(y3-y1)^2)/l5
c6 = (0.25*(x1-x2)^2 - 0.5*(y1-y2)^2)/l6
d4 = -(y2-y3)/l4
d5 = -(y3-y1)/l5
d6 = -(y1-y2)/l6
e4 = (0.25*(y2-y3)^2 - 0.5*(x2-x3)^2)/l4
e5 = (0.25*(y3-y1)^2 - 0.5*(x3-x1)^2)/l5
e6 = (0.25*(y1-y2)^2 - 0.5*(x1-x2)^2)/l6
Ji = inv(Jt)
J11 = Ji(1, 1)
J12 = Ji(1, 2)
J21 = Ji(2, 1)
J22 = Ji(2, 2)
uw_t = [0; 0; 0; 64/6; 0; -8; 0; 0; -9/2]
k1_t(x, y) = transpose(B1_t(x/4, y/3))*uw_t
k2_t(x, y) = transpose(B2_t(x/4, y/3))*uw_t
k3_t(x, y) = transpose(B3_t(x/4, y/3))*uw_t
Mxx_t(x, y) = Db(1, 1)*k1_t(x, y) + Db(1, 2)*k2_t(x, y)
Myy_t(x, y) = Db(1, 2)*k1_t(x, y) + Db(2, 2)*k2_t(x, y)
Mxy_t(x, y) = Db(3, 3)*k3_t(x, y)
#: En el centroide (4/3, 1) y el valor exacto de la placa continua:
Mxx_tc = Mxx_t(4/3, 1)
Mxx_tex = -Dpl*(1+nu)*4/3
Mxy_tc = Mxy_t(4/3, 1)
Mxy_tex = -Dpl*(1-nu)*1
#: Mxx del DKT (kN·m/m):
#map(Mxx_t(x, y), [0 4], [0 3])
#: Myy del DKT (kN·m/m):
#map(Myy_t(x, y), [0 4], [0 3])
#: Mxy del DKT (kN·m/m):
#map(Mxy_t(x, y), [0 4], [0 3])

## Los rotulos
