# Placa delgada DKQ de Batoz (cuadrilátero de 4 nodos, 12 GDL) · símbolos, K, parche, mapas y SAP2000
#numerico
#: Elemento DKQ (Discrete Kirchhoff Quadrilateral) de Batoz y Tahar (1982): el cuadrilátero de placa delgada que usa Shell-Thin de CSI. Tres grados de libertad por nodo: w, θx = ∂w/∂y, θy = −∂w/∂x. Primero todo en símbolos y después con números; se valida con la prueba de parche, los cuerpos rígidos, los mapas de momentos y la comparación con SAP2000 y ETABS. Solo flexión: la membrana y el drilling son otro elemento.

## 0 · De la ecuación diferencial a la forma débil
#: Placa delgada de Kirchhoff. El desplazamiento vertical w cumple la ecuación diferencial D·∇⁴w = q, con la rigidez a flexión D = E·t³/(12·(1−ν²)) en kN·m y la carga q por unidad de área en kN/m².
D_flex = Simplify{Em*t^3/(12*(1-nu^2))}
#: Condiciones de borde. Esenciales, se imponen al desplazamiento: empotrado w = 0 y ∂w/∂n = 0; apoyado w = 0. Naturales, salen solas de la forma débil: apoyado Mn = 0; libre Mn = 0 y Vn = 0.
#: Función de prueba. Se multiplica la ecuación por una variación δw y se integra en el área A: ∫ δw·(D·∇⁴w − q) dA = 0.
#: Se integra por partes dos veces. Con las condiciones de borde desaparecen los términos de borde y solo quedan segundas derivadas: ∫ δκᵀ·Db·κ dA = ∫ δw·q dA, con las curvaturas κ = [−w,xx ; −w,yy ; −2·w,xy] y Db la matriz de comportamiento a flexión.
#: Discretización. Se aproxima w con funciones de forma nodo a nodo: w ≈ Σ Nᵢ·wᵢ. Las curvaturas salen de sus segundas derivadas: κ = B·u. La rigidez del elemento es K = ∫ Bᵀ·Db·B dA y el sistema es K·u = f. Las funciones de forma y B se construyen en las secciones siguientes.

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

## 2 · Números: datos
Em = 24850000 [kN/m²] 'módulo de elasticidad del hormigón
nu = 0.2 'relación de Poisson (sin unidad)
t = 0.1 [m] 'espesor de la placa
Dpl = Em*t^3/(12*(1-nu^2)) [kN·m] 'rigidez a flexión de la placa
Db = Dpl*[1, nu, 0; nu, 1, 0; 0, 0, (1-nu)/2] [kN·m] 'matriz de comportamiento a flexión

## 3 · DKQ: las N de ocho nodos (cuatro esquinas y cuatro puntos medios)
#: N5 = 1/2·(1−ξ²)(1−η), N6 = 1/2·(1+ξ)(1−η²), N7 = 1/2·(1−ξ²)(1+η), N8 = 1/2·(1−ξ)(1−η²) y las de esquina N1 = 1/4·(1−ξ)(1−η) − 1/2·(N8 + N5), etc.
Q5 = Simplify{1/2*(1-xi^2)*(1-eta)}
Q8 = Simplify{1/2*(1-xi)*(1-eta^2)}
Q1 = Simplify{1/4*(1-xi)*(1-eta) - 1/2*(Q8 + Q5)}
#: Los coeficientes a…e del lado k son los mismos del DKT; en cada nodo i entran el lado que sale de i (k = i+4) y el que llega (k = i+3), y para el nodo 1 el que llega es el 8.
Hx1_dkq = Simplify{[1.5*(a5*Q5 - a8*Q8), b5*Q5 + b8*Q8, Q1 - c5*Q5 - c8*Q8]}

## 4 · DKQ con números (cuadrilátero cualquiera)
X1 = 0 [m] 'coordenada del nodo
Y1 = 0 [m] 'coordenada del nodo
X2 = 2 [m] 'coordenada del nodo
Y2 = 0.2 [m] 'coordenada del nodo
X3 = 2.2 [m] 'coordenada del nodo
Y3 = 1.8 [m] 'coordenada del nodo
X4 = 0.1 [m] 'coordenada del nodo
Y4 = 1.6 [m] 'coordenada del nodo
XY = [X1, Y1; X2, Y2; X3, Y3; X4, Y4]
#: Lados 5 = 1-2, 6 = 2-3, 7 = 3-4, 8 = 4-1:
m5 = (X1-X2)^2 + (Y1-Y2)^2 [m²] 'cuadrado del largo del lado
m6 = (X2-X3)^2 + (Y2-Y3)^2 [m²] 'cuadrado del largo del lado
m7 = (X3-X4)^2 + (Y3-Y4)^2 [m²] 'cuadrado del largo del lado
m8 = (X4-X1)^2 + (Y4-Y1)^2 [m²] 'cuadrado del largo del lado
A5 = -(X1-X2)/m5 'coeficiente de lado, en 1/m
A6 = -(X2-X3)/m6 'coeficiente de lado, en 1/m
A7 = -(X3-X4)/m7 'coeficiente de lado, en 1/m
A8 = -(X4-X1)/m8 'coeficiente de lado, en 1/m
B5 = 0.75*(X1-X2)*(Y1-Y2)/m5
B6 = 0.75*(X2-X3)*(Y2-Y3)/m6
B7 = 0.75*(X3-X4)*(Y3-Y4)/m7
B8 = 0.75*(X4-X1)*(Y4-Y1)/m8
C5 = (0.25*(X1-X2)^2 - 0.5*(Y1-Y2)^2)/m5
C6 = (0.25*(X2-X3)^2 - 0.5*(Y2-Y3)^2)/m6
C7 = (0.25*(X3-X4)^2 - 0.5*(Y3-Y4)^2)/m7
C8 = (0.25*(X4-X1)^2 - 0.5*(Y4-Y1)^2)/m8
D5 = -(Y1-Y2)/m5 'coeficiente de lado, en 1/m
D6 = -(Y2-Y3)/m6 'coeficiente de lado, en 1/m
D7 = -(Y3-Y4)/m7 'coeficiente de lado, en 1/m
D8 = -(Y4-Y1)/m8 'coeficiente de lado, en 1/m
E5 = (0.25*(Y1-Y2)^2 - 0.5*(X1-X2)^2)/m5
E6 = (0.25*(Y2-Y3)^2 - 0.5*(X2-X3)^2)/m6
E7 = (0.25*(Y3-Y4)^2 - 0.5*(X3-X4)^2)/m7
E8 = (0.25*(Y4-Y1)^2 - 0.5*(X4-X1)^2)/m8
#: Filas Hx y Hy (12 columnas) lineales en las ocho N o en sus derivadas:
Hx_q(n1, n2, n3, n4, n5, n6, n7, n8) = [1.5*(A5*n5 - A8*n8); B5*n5 + B8*n8; n1 - C5*n5 - C8*n8; 1.5*(A6*n6 - A5*n5); B6*n6 + B5*n5; n2 - C6*n6 - C5*n5; 1.5*(A7*n7 - A6*n6); B7*n7 + B6*n6; n3 - C7*n7 - C6*n6; 1.5*(A8*n8 - A7*n7); B8*n8 + B7*n7; n4 - C8*n8 - C7*n7]
Hy_q(n1, n2, n3, n4, n5, n6, n7, n8) = [1.5*(D5*n5 - D8*n8); -n1 + E5*n5 + E8*n8; -B5*n5 - B8*n8; 1.5*(D6*n6 - D5*n5); -n2 + E6*n6 + E5*n5; -B6*n6 - B5*n5; 1.5*(D7*n7 - D6*n6); -n3 + E7*n7 + E6*n6; -B7*n7 - B6*n6; 1.5*(D8*n8 - D7*n7); -n4 + E8*n8 + E7*n7; -B8*n8 - B7*n7]
#: Derivadas de las ocho N (ξ y η):
N5x(xi, eta) = -xi*(1-eta)
N5y(xi, eta) = -0.5*(1-xi^2)
N6x(xi, eta) = 0.5*(1-eta^2)
N6y(xi, eta) = -(1+xi)*eta
N7x(xi, eta) = -xi*(1+eta)
N7y(xi, eta) = 0.5*(1-xi^2)
N8x(xi, eta) = -0.5*(1-eta^2)
N8y(xi, eta) = -(1-xi)*eta
N1x(xi, eta) = -0.25*(1-eta) - 0.5*(N8x(xi, eta) + N5x(xi, eta))
N1y(xi, eta) = -0.25*(1-xi) - 0.5*(N8y(xi, eta) + N5y(xi, eta))
N2x(xi, eta) = 0.25*(1-eta) - 0.5*(N5x(xi, eta) + N6x(xi, eta))
N2y(xi, eta) = -0.25*(1+xi) - 0.5*(N5y(xi, eta) + N6y(xi, eta))
N3x(xi, eta) = 0.25*(1+eta) - 0.5*(N6x(xi, eta) + N7x(xi, eta))
N3y(xi, eta) = 0.25*(1+xi) - 0.5*(N6y(xi, eta) + N7y(xi, eta))
N4x(xi, eta) = -0.25*(1+eta) - 0.5*(N7x(xi, eta) + N8x(xi, eta))
N4y(xi, eta) = 0.25*(1-xi) - 0.5*(N7y(xi, eta) + N8y(xi, eta))
Hxs(xi, eta) = Hx_q(N1x(xi, eta), N2x(xi, eta), N3x(xi, eta), N4x(xi, eta), N5x(xi, eta), N6x(xi, eta), N7x(xi, eta), N8x(xi, eta))
Hxh(xi, eta) = Hx_q(N1y(xi, eta), N2y(xi, eta), N3y(xi, eta), N4y(xi, eta), N5y(xi, eta), N6y(xi, eta), N7y(xi, eta), N8y(xi, eta))
Hys(xi, eta) = Hy_q(N1x(xi, eta), N2x(xi, eta), N3x(xi, eta), N4x(xi, eta), N5x(xi, eta), N6x(xi, eta), N7x(xi, eta), N8x(xi, eta))
Hyh(xi, eta) = Hy_q(N1y(xi, eta), N2y(xi, eta), N3y(xi, eta), N4y(xi, eta), N5y(xi, eta), N6y(xi, eta), N7y(xi, eta), N8y(xi, eta))
#: Jacobiano de la geometría (bilineal en las cuatro esquinas) J = [p, q; r, s]:
jp(xi, eta) = 0.25*(-(1-eta)*X1 + (1-eta)*X2 + (1+eta)*X3 - (1+eta)*X4)
jq(xi, eta) = 0.25*(-(1-eta)*Y1 + (1-eta)*Y2 + (1+eta)*Y3 - (1+eta)*Y4)
jr(xi, eta) = 0.25*(-(1-xi)*X1 - (1+xi)*X2 + (1+xi)*X3 + (1-xi)*X4)
js(xi, eta) = 0.25*(-(1-xi)*Y1 - (1+xi)*Y2 + (1+xi)*Y3 + (1-xi)*Y4)
dj(xi, eta) = jp(xi, eta)*js(xi, eta) - jq(xi, eta)*jr(xi, eta)
#: Inverso de J: (1/det)·[s, −q; −r, p]. Derivadas respecto a x e y:
Hx_xq(xi, eta) = (js(xi, eta)*Hxs(xi, eta) - jq(xi, eta)*Hxh(xi, eta))/dj(xi, eta)
Hx_yq(xi, eta) = (-jr(xi, eta)*Hxs(xi, eta) + jp(xi, eta)*Hxh(xi, eta))/dj(xi, eta)
Hy_xq(xi, eta) = (js(xi, eta)*Hys(xi, eta) - jq(xi, eta)*Hyh(xi, eta))/dj(xi, eta)
Hy_yq(xi, eta) = (-jr(xi, eta)*Hys(xi, eta) + jp(xi, eta)*Hyh(xi, eta))/dj(xi, eta)
B1_q(xi, eta) = Hx_xq(xi, eta)
B2_q(xi, eta) = Hy_yq(xi, eta)
B3_q(xi, eta) = Hx_yq(xi, eta) + Hy_xq(xi, eta)
kb_q(xi, eta) = (Db(1, 1)*B1_q(xi, eta)*transpose(B1_q(xi, eta)) + Db(1, 2)*(B1_q(xi, eta)*transpose(B2_q(xi, eta)) + B2_q(xi, eta)*transpose(B1_q(xi, eta))) + Db(2, 2)*B2_q(xi, eta)*transpose(B2_q(xi, eta)) + Db(3, 3)*B3_q(xi, eta)*transpose(B3_q(xi, eta)))*dj(xi, eta)
#: Cuatro puntos de Gauss ±1/√3, peso 1:
g = 1/sqrt(3)
K_dkq = kb_q(-g, -g) + kb_q(g, -g) + kb_q(g, g) + kb_q(-g, g)
K_dkq_11 = K_dkq(1, 1) [kN/m] 'rigidez a w del nodo 1
K_dkq_22 = K_dkq(2, 2) [kN·m] 'rigidez al giro del nodo 1
K_dkq_33 = K_dkq(3, 3) [kN·m] 'rigidez al giro del nodo 1

## 5 · DKQ: prueba de parche y cuerpo rígido
u_par_q = [X1^2/2; 0; -X1; X2^2/2; 0; -X2; X3^2/2; 0; -X3; X4^2/2; 0; -X4]
kxx_q = transpose(B1_q(0.3, -0.4))*u_par_q
kyy_q = transpose(B2_q(0.3, -0.4))*u_par_q
kxy_q = transpose(B3_q(0.3, -0.4))*u_par_q
kxx_q2 = transpose(B1_q(-0.7, 0.6))*u_par_q
#: Área del cuadrilátero por la fórmula del cordón:
Aq = 0.5*((X1*Y2 - X2*Y1) + (X2*Y3 - X3*Y2) + (X3*Y4 - X4*Y3) + (X4*Y1 - X1*Y4)) [m²] 'área
U_q = 0.5*transpose(u_par_q)*K_dkq*u_par_q [kN·m] 'energía de deformación
U_q_exacta = 0.5*Dpl*Aq [kN·m] 'energía de deformación
u_tras_q = [1; 0; 0; 1; 0; 0; 1; 0; 0; 1; 0; 0]
f_tras_q = K_dkq*u_tras_q
u_giro_q = [X1; 0; -1; X2; 0; -1; X3; 0; -1; X4; 0; -1]
f_giro_q = K_dkq*u_giro_q

## 6 · Comparación con SAP2000 (Plate-Thin)
#: Mismo cuadrilátero de la sección 4 y el campo w = x³/6 + x·y²/2 impuesto como desplazamientos en los cuatro nodos (w, θx = x·y, θy = −(x²+y²)/2). Con los 12 GDL restringidos, la reacción de SAP2000 es K·u. SAP2000 24: área Plate-Thin, sin malla automática, unidades kN y m.
wf(x, y) = x^3/6 + x*y^2/2
u_s_q = [wf(X1, Y1); X1*Y1; -(X1^2+Y1^2)/2; wf(X2, Y2); X2*Y2; -(X2^2+Y2^2)/2; wf(X3, Y3); X3*Y3; -(X3^2+Y3^2)/2; wf(X4, Y4); X4*Y4; -(X4^2+Y4^2)/2]
f_q = K_dkq*u_s_q 'reacciones: kN para w y kN·m para θx, θy
#: Reacciones de SAP2000 (w, θx, θy de cada nodo), copiadas de su salida [SAP2000 OAPI]:
f_sap_q = [5503.829765; -751.808244; -316.323307; -4502.797955; -3135.217694; -4287.655588; 398.404973; 4136.870944; -3873.509261; -1399.436783; 2172.684486; 208.439509]
dif_q = f_q - f_sap_q
err_q = 100*sqrt(transpose(dif_q)*dif_q)/sqrt(transpose(f_sap_q)*f_sap_q) [%] 'diferencia relativa
#: Momentos en el nodo: B del DKQ en los puntos de Gauss y extrapolación bilineal a los nodos (así los da SAP2000).
Mxx_n(xi, eta) = Db(1, 1)*transpose(B1_q(xi, eta))*u_s_q + Db(1, 2)*transpose(B2_q(xi, eta))*u_s_q
Myy_n(xi, eta) = Db(1, 2)*transpose(B1_q(xi, eta))*u_s_q + Db(2, 2)*transpose(B2_q(xi, eta))*u_s_q
Mxy_n(xi, eta) = Db(3, 3)*transpose(B3_q(xi, eta))*u_s_q
Mxx_x(si, ti) = 0.25*((1-sqrt(3)*si)*(1-sqrt(3)*ti)*Mxx_n(-g, -g) + (1+sqrt(3)*si)*(1-sqrt(3)*ti)*Mxx_n(g, -g) + (1+sqrt(3)*si)*(1+sqrt(3)*ti)*Mxx_n(g, g) + (1-sqrt(3)*si)*(1+sqrt(3)*ti)*Mxx_n(-g, g))
Myy_x(si, ti) = 0.25*((1-sqrt(3)*si)*(1-sqrt(3)*ti)*Myy_n(-g, -g) + (1+sqrt(3)*si)*(1-sqrt(3)*ti)*Myy_n(g, -g) + (1+sqrt(3)*si)*(1+sqrt(3)*ti)*Myy_n(g, g) + (1-sqrt(3)*si)*(1+sqrt(3)*ti)*Myy_n(-g, g))
Mxy_x(si, ti) = 0.25*((1-sqrt(3)*si)*(1-sqrt(3)*ti)*Mxy_n(-g, -g) + (1+sqrt(3)*si)*(1-sqrt(3)*ti)*Mxy_n(g, -g) + (1+sqrt(3)*si)*(1+sqrt(3)*ti)*Mxy_n(g, g) + (1-sqrt(3)*si)*(1+sqrt(3)*ti)*Mxy_n(-g, g))
M_q1 = [Mxx_x(-1, -1), Myy_x(-1, -1), Mxy_x(-1, -1)] [kN·m/m] 'momentos Mxx Myy Mxy del nodo
M_q2 = [Mxx_x(1, -1), Myy_x(1, -1), Mxy_x(1, -1)] [kN·m/m] 'momentos Mxx Myy Mxy del nodo
M_q3 = [Mxx_x(1, 1), Myy_x(1, 1), Mxy_x(1, 1)] [kN·m/m] 'momentos Mxx Myy Mxy del nodo
M_q4 = [Mxx_x(-1, 1), Myy_x(-1, 1), Mxy_x(-1, 1)] [kN·m/m] 'momentos Mxx Myy Mxy del nodo
#: SAP2000 (M11, M22, M12) en los nodos 1 a 4 [SAP2000 OAPI]. SAP2000 da el momento con el signo contrario al de esta hoja (M11 = −Mxx, M22 = −Myy, M12 = −Mxy), así que la suma de los dos debe dar cero:
M_sap1 = [-221.352005, -161.569777, 773.527219] [kN·m/m] 'momentos Mxx Myy Mxy del nodo
M_sap2 = [4990.463335, 4961.900813, 938.655492] [kN·m/m] 'momentos Mxx Myy Mxy del nodo
M_sap3 = [5922.245888, 5968.54638, 2329.722025] [kN·m/m] 'momentos Mxx Myy Mxy del nodo
M_sap4 = [417.801978, 379.808169, 2149.254494] [kN·m/m] 'momentos Mxx Myy Mxy del nodo
n3(v) = sqrt(v(1)^2 + v(2)^2 + v(3)^2)
err_M_q = 100*sqrt(n3(M_q1 + M_sap1)^2 + n3(M_q2 + M_sap2)^2 + n3(M_q3 + M_sap3)^2 + n3(M_q4 + M_sap4)^2)/sqrt(n3(M_sap1)^2 + n3(M_sap2)^2 + n3(M_sap3)^2 + n3(M_sap4)^2) [%] 'diferencia relativa

#: ETABS 22 (OAPI, losa Shell-Thin, OBJMESHTYPE NOAUTOMESH para que no remalle; sus GDL de membrana quedan en cero, así que no afectan la flexión). Mismas reacciones y mismos momentos [ETABS OAPI]:
f_etabs_q = [5503.829972; -751.807911; -316.323343; -4502.796709; -3135.216921; -4287.655684; 398.403504; 4136.871793; -3873.509643; -1399.436767; 2172.684901; 208.439283]
err_q_etabs = 100*sqrt(transpose(f_q - f_etabs_q)*(f_q - f_etabs_q))/sqrt(transpose(f_etabs_q)*f_etabs_q) [%] 'diferencia relativa
M_etabs1 = [-221.351797, -161.569725, 773.527096] [kN·m/m] 'momentos Mxx Myy Mxy del nodo
M_etabs2 = [4990.462902, 4961.899605, 938.655356] [kN·m/m] 'momentos Mxx Myy Mxy del nodo
M_etabs3 = [5922.24661, 5968.547651, 2329.721915] [kN·m/m] 'momentos Mxx Myy Mxy del nodo
M_etabs4 = [417.801466, 379.808048, 2149.254371] [kN·m/m] 'momentos Mxx Myy Mxy del nodo
err_M_q_etabs = 100*sqrt(n3(M_q1 + M_etabs1)^2 + n3(M_q2 + M_etabs2)^2 + n3(M_q3 + M_etabs3)^2 + n3(M_q4 + M_etabs4)^2)/sqrt(n3(M_etabs1)^2 + n3(M_etabs2)^2 + n3(M_etabs3)^2 + n3(M_etabs4)^2) [%] 'diferencia relativa

## 7 · Mapas sobre el cuadrilátero de SAP2000 y ETABS (para comparar con el ratón)
#: El mismo cuadrilátero (0,0), (2,0.2), (2.2,1.8), (0.1,1.6) y el mismo campo, dibujado en el cuadrado de referencia ξ, η (x = ξ, y = η). Es el campo que da SAP2000: valores en los 4 puntos de Gauss extrapolados de forma bilineal. Pasa el ratón por las esquinas: (−1,−1), (1,−1), (1,1), (−1,1) son los nodos 1 a 4 y deben leer Mxx = −M11 de SAP2000 y ETABS (221.35, −4990.46, −5922.25, −417.80 con el signo de SAP).
Mxx_p(x, y) = Mxx_x(x, y)
Myy_p(x, y) = Myy_x(x, y)
Mxy_p(x, y) = Mxy_x(x, y)
#: Mxx (kN·m/m):
#map(Mxx_p(x, y), [-1 1], [-1 1])
#: Myy (kN·m/m):
#map(Myy_p(x, y), [-1 1], [-1 1])
#: Mxy (kN·m/m):
#map(Mxy_p(x, y), [-1 1], [-1 1])

## 8 · Mapas de Mxx, Myy y Mxy (pasa el ratón y lee el valor)
#: Un elemento DKQ rectangular de 4 × 3 con el campo w = x³/6 + x·y²/2, cuyos giros en los nodos son θx = x·y y θy = −(x² + y²)/2. Los momentos salen de M = Db·κ con la B del DKQ en cada punto (x, y) del elemento: ξ = x/2 − 1, η = 2·y/3 − 1.
X1 = 0 [m] 'coordenada del nodo
Y1 = 0 [m] 'coordenada del nodo
X2 = 4 [m] 'coordenada del nodo
Y2 = 0 [m] 'coordenada del nodo
X3 = 4 [m] 'coordenada del nodo
Y3 = 3 [m] 'coordenada del nodo
X4 = 0 [m] 'coordenada del nodo
Y4 = 3 [m] 'coordenada del nodo
m5 = (X1-X2)^2 + (Y1-Y2)^2 [m²] 'cuadrado del largo del lado
m6 = (X2-X3)^2 + (Y2-Y3)^2 [m²] 'cuadrado del largo del lado
m7 = (X3-X4)^2 + (Y3-Y4)^2 [m²] 'cuadrado del largo del lado
m8 = (X4-X1)^2 + (Y4-Y1)^2 [m²] 'cuadrado del largo del lado
A5 = -(X1-X2)/m5 'coeficiente de lado, en 1/m
A6 = -(X2-X3)/m6 'coeficiente de lado, en 1/m
A7 = -(X3-X4)/m7 'coeficiente de lado, en 1/m
A8 = -(X4-X1)/m8 'coeficiente de lado, en 1/m
B5 = 0.75*(X1-X2)*(Y1-Y2)/m5
B6 = 0.75*(X2-X3)*(Y2-Y3)/m6
B7 = 0.75*(X3-X4)*(Y3-Y4)/m7
B8 = 0.75*(X4-X1)*(Y4-Y1)/m8
C5 = (0.25*(X1-X2)^2 - 0.5*(Y1-Y2)^2)/m5
C6 = (0.25*(X2-X3)^2 - 0.5*(Y2-Y3)^2)/m6
C7 = (0.25*(X3-X4)^2 - 0.5*(Y3-Y4)^2)/m7
C8 = (0.25*(X4-X1)^2 - 0.5*(Y4-Y1)^2)/m8
D5 = -(Y1-Y2)/m5 'coeficiente de lado, en 1/m
D6 = -(Y2-Y3)/m6 'coeficiente de lado, en 1/m
D7 = -(Y3-Y4)/m7 'coeficiente de lado, en 1/m
D8 = -(Y4-Y1)/m8 'coeficiente de lado, en 1/m
E5 = (0.25*(Y1-Y2)^2 - 0.5*(X1-X2)^2)/m5
E6 = (0.25*(Y2-Y3)^2 - 0.5*(X2-X3)^2)/m6
E7 = (0.25*(Y3-Y4)^2 - 0.5*(X3-X4)^2)/m7
E8 = (0.25*(Y4-Y1)^2 - 0.5*(X4-X1)^2)/m8
uw = [0; 0; 0; 64/6; 0; -8; 64/6+0.5*4*9; 12; -(16+9)/2; 0.5*0*9; 0; -9/2]
#: κxx, κyy, κxy en el punto (x, y):
k1_q(x, y) = transpose(B1_q(x/2-1, 2*y/3-1))*uw
k2_q(x, y) = transpose(B2_q(x/2-1, 2*y/3-1))*uw
k3_q(x, y) = transpose(B3_q(x/2-1, 2*y/3-1))*uw
#: Momentos por unidad de ancho (kN·m/m):
Mxx_q(x, y) = Db(1, 1)*k1_q(x, y) + Db(1, 2)*k2_q(x, y)
Myy_q(x, y) = Db(1, 2)*k1_q(x, y) + Db(2, 2)*k2_q(x, y)
Mxy_q(x, y) = Db(3, 3)*k3_q(x, y)
#: En el centro (2, 1.5) y el valor exacto de la placa continua (κxx = κyy = −x, κxy = −2·y):
Mxx_c = Mxx_q(2, 1.5)
Mxx_ex = -Dpl*(1+nu)*2
Mxy_c = Mxy_q(2, 1.5)
Mxy_ex = -Dpl*(1-nu)*1.5
#: Con un solo elemento el centro coincide con el exacto (arriba); hacia los bordes el DKQ se aparta, sobre todo en Mxy (su rango sale de −1294 a −3883, el continuo iría de 0 a −5177). Con más elementos el mapa converge.
#: Mxx (kN·m/m):
#map(Mxx_q(x, y), [0 4], [0 3])
#: Myy (kN·m/m):
#map(Myy_q(x, y), [0 4], [0 3])
#: Mxy (kN·m/m):
#map(Mxy_q(x, y), [0 4], [0 3])

## Los rotulos
