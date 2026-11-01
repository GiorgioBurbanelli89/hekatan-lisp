# Placa gruesa del triángulo de CSI (Shell-Thick) · forma cerrada, K, momentos, cortante y mapas contra SAP2000 y ETABS
#numerico
#: El triángulo Shell-Thick de SAP2000 24 y ETABS 22 no es el CS-DSG3 ni ninguno de los publicados: se obtuvo midiendo el binario de ETABS (emulación del código del kernel) y se comprobó contra los dos programas. Tres grados de libertad por nodo: w, θx = ∂w/∂y, θy = −∂w/∂x. Aquí se arma entero, primero con las fórmulas y después con números: K de 9×9, reacciones, momentos en los nodos, cortante V13 y V23 y los mapas de Mxx, Myy y Mxy con el ratón. Solo flexión: la membrana y el drilling son otro elemento.

## 1 · La receta, en palabras (por qué es así)
#: Los giros no son lineales: además de los tres nodales Lᵢ, cada lado lleva una función propia 4·La·Lb (dos componentes, θx y θy). Son seis grados de libertad internos que se eliminan por condensación. No hay burbuja. Con eso el giro puede curvarse dentro del elemento.
#: El cortante de cada lado sale de Wilson: gk = (wb − wa)/L − (sa/2)(θx_a + θx_b) + (ca/2)(θy_a + θy_b) − (2/3)·sa·θx_k + (2/3)·ca·θy_k, con ca, sa el coseno y el seno del lado. El cortante dentro del triángulo se toma CONSTANTE: (γr, γs) = C·(g1·L1, g2·L2, g3·L3) con C = [2/3 −1/3 −1/3; 1/3 1/3 −2/3], y γ = J⁻¹·(γr, γs). Por eso V13 y V23 valen lo mismo en los tres nodos.
#: La flexión se integra con los tres puntos medios de los lados (peso A/3). En las seis columnas de lado se resta la media de las tres filas de curvatura (B-barra): así un campo de curvatura constante no excita los modos internos. Se añade una penalización 1000·tr(Db)·(div θ)² que ata los giros de lado al campo de giros.

## 2 · Datos
Em = 24850000 [kN/m²] 'módulo de elasticidad del hormigón
nu = 0.2 'relación de Poisson (sin unidad)
t = 0.1 [m] 'espesor de la placa
Dpl = Em*t^3/(12*(1-nu^2)) [kN·m] 'rigidez a flexión de la placa
Db = Dpl*[1, nu, 0; nu, 1, 0; 0, 0, (1-nu)/2]
Gm = Em/(2*(1+nu)) [kN/m²] 'módulo de corte
Ds = 5/6*Gm*t [kN/m] 'rigidez a corte (5/6·G·t)
pen = 1000*(Db(1, 1) + Db(2, 2) + Db(3, 3)) [kN·m] 'penalización de giros

## 3 · El triángulo (el mismo de la hoja del DKT)
x1 = 0 [m] 'coordenada del nodo
y1 = 0 [m] 'coordenada del nodo
x2 = 2 [m] 'coordenada del nodo
y2 = 0.5 [m] 'coordenada del nodo
x3 = 0.5 [m] 'coordenada del nodo
y3 = 1.5 [m] 'coordenada del nodo
Jt = [x2-x1, y2-y1; x3-x1, y3-y1]
A2 = det(Jt) [m²] 'área
At = A2/2 [m²] 'área
Ji = inv(Jt)
#: Gradientes de las coordenadas de área L1, L2, L3 (constantes en el triángulo):
g1x = (y2-y3)/A2
g1y = (x3-x2)/A2
g2x = (y3-y1)/A2
g2y = (x1-x3)/A2
g3x = (y1-y2)/A2
g3y = (x2-x1)/A2
#: Lados 1 (nodos 1-2), 2 (nodos 2-3) y 3 (nodos 3-1): largo, coseno y seno.
L1 = sqrt((x2-x1)^2 + (y2-y1)^2) [m] 'largo del lado
L2 = sqrt((x3-x2)^2 + (y3-y2)^2) [m] 'largo del lado
L3 = sqrt((x1-x3)^2 + (y1-y3)^2) [m] 'largo del lado
c1 = (x2-x1)/L1
s1 = (y2-y1)/L1
c2 = (x3-x2)/L2
s2 = (y3-y2)/L2
c3 = (x1-x3)/L3
s3 = (y1-y3)/L3

## 4 · Curvaturas: giros nodales + giros de lado (B-barra)
#: Orden de los 15 grados de libertad: [w1 θx1 θy1, w2 θx2 θy2, w3 θx3 θy3, lado1 (θx θy), lado2 (θx θy), lado3 (θx θy)]. Derivada de la función de lado 4·La·Lb respecto a x e y, menos su valor medio en los tres puntos medios (B-barra), con (a, b, c) = (L1, L2, L3) del punto:
sx1(a, b, c) = 4*(a*g2x + b*g1x) - 4*(g2x + g1x)/3
sx2(a, b, c) = 4*(b*g3x + c*g2x) - 4*(g3x + g2x)/3
sx3(a, b, c) = 4*(c*g1x + a*g3x) - 4*(g1x + g3x)/3
sy1(a, b, c) = 4*(a*g2y + b*g1y) - 4*(g2y + g1y)/3
sy2(a, b, c) = 4*(b*g3y + c*g2y) - 4*(g3y + g2y)/3
sy3(a, b, c) = 4*(c*g1y + a*g3y) - 4*(g1y + g3y)/3
#: Las tres filas de curvatura (κxx = βx,x, κyy = βy,y, κxy = βx,y + βy,x) y la divergencia del giro (sin restar la media) para la penalización:
kxx_r(a, b, c) = [0; 0; g1x; 0; 0; g2x; 0; 0; g3x; 0; sx1(a, b, c); 0; sx2(a, b, c); 0; sx3(a, b, c)]
kyy_r(a, b, c) = [0; -g1y; 0; 0; -g2y; 0; 0; -g3y; 0; -sy1(a, b, c); 0; -sy2(a, b, c); 0; -sy3(a, b, c); 0]
kxy_r(a, b, c) = [0; -g1x; g1y; 0; -g2x; g2y; 0; -g3x; g3y; -sx1(a, b, c); sy1(a, b, c); -sx2(a, b, c); sy2(a, b, c); -sx3(a, b, c); sy3(a, b, c)]
dv_r(a, b, c) = [0; g1x; g1y; 0; g2x; g2y; 0; g3x; g3y; sx1(a, b, c) + 4*(g2x + g1x)/3; sy1(a, b, c) + 4*(g2y + g1y)/3; sx2(a, b, c) + 4*(g3x + g2x)/3; sy2(a, b, c) + 4*(g3y + g2y)/3; sx3(a, b, c) + 4*(g1x + g3x)/3; sy3(a, b, c) + 4*(g1y + g3y)/3]
#: BᵀDB en un punto y la penalización:
kb_c(a, b, c) = Db(1, 1)*kxx_r(a, b, c)*transpose(kxx_r(a, b, c)) + Db(1, 2)*(kxx_r(a, b, c)*transpose(kyy_r(a, b, c)) + kyy_r(a, b, c)*transpose(kxx_r(a, b, c))) + Db(2, 2)*kyy_r(a, b, c)*transpose(kyy_r(a, b, c)) + Db(3, 3)*kxy_r(a, b, c)*transpose(kxy_r(a, b, c)) + pen*dv_r(a, b, c)*transpose(dv_r(a, b, c))

## 5 · Cortante de lado (Wilson) y cortante constante
G1 = [-1/L1; -s1/2; c1/2; 1/L1; -s1/2; c1/2; 0; 0; 0; -2/3*s1; 2/3*c1; 0; 0; 0; 0]
G2 = [0; 0; 0; -1/L2; -s2/2; c2/2; 1/L2; -s2/2; c2/2; 0; 0; -2/3*s2; 2/3*c2; 0; 0]
G3 = [1/L3; -s3/2; c3/2; 0; 0; 0; -1/L3; -s3/2; c3/2; 0; 0; 0; 0; -2/3*s3; 2/3*c3]
#: γr y γs (covariantes) y γx, γy (cartesianos) como filas sobre los 15 grados de libertad:
gr = 2/3*L1*G1 - 1/3*L2*G2 - 1/3*L3*G3
gs = 1/3*L1*G1 + 1/3*L2*G2 - 2/3*L3*G3
Bsx = Ji(1, 1)*gr + Ji(1, 2)*gs
Bsy = Ji(2, 1)*gr + Ji(2, 2)*gs

## 6 · Rigidez de 15×15 y condensación a 9×9
#: Tres puntos medios de lado, peso A/3 cada uno. El cortante es constante, así que su aporte es A·Bsᵀ·Ds·Bs:
K15 = At/3*(kb_c(0.5, 0.5, 0) + kb_c(0, 0.5, 0.5) + kb_c(0.5, 0, 0.5)) + At*Ds*(Bsx*transpose(Bsx) + Bsy*transpose(Bsy))
#: Se separan los 9 grados de libertad de nodo (Ee) de los 6 internos (Ei) y se condensan los internos: Kt = Knn − KnI·KII⁻¹·KIn. Los seis pivotes son no nulos en este triángulo (el kernel salta los pivotes nulos en otras geometrías).
Ee = submatrix(identity(15), 1, 9, 1, 15)
Ei = submatrix(identity(15), 10, 15, 1, 15)
Knn = Ee*K15*transpose(Ee)
KnI = Ee*K15*transpose(Ei)
KII = Ei*K15*transpose(Ei)
Kt = Knn - KnI*inv(KII)*transpose(KnI)
Kt_11 = Kt(1, 1) [kN/m] 'rigidez a w del nodo 1
Kt_22 = Kt(2, 2) [kN·m] 'rigidez al giro del nodo 1
Kt_33 = Kt(3, 3) [kN·m] 'rigidez al giro del nodo 1
#: Cuerpos rígidos: traslación vertical y giro rígido (w = x) no deben dar fuerza.
u_tras = [1; 0; 0; 1; 0; 0; 1; 0; 0]
f_tras = Kt*u_tras
u_giro = [x1; 0; -1; x2; 0; -1; x3; 0; -1]
f_giro = Kt*u_giro

## 7 · Comparación con SAP2000 y ETABS (reacciones)
#: El campo w = x³/6 + x·y²/2 impuesto como desplazamientos en los tres nodos (w, θx = x·y, θy = −(x²+y²)/2), t = 0.1. Con los 9 grados de libertad restringidos, la reacción es K·u. SAP2000 24: área Shell-Thick; ETABS 22: losa Shell-Thick con OBJMESHTYPE NOAUTOMESH (si no, ETABS remalla el triángulo en cuatro). Unidades kN y m.
wf(x, y) = x^3/6 + x*y^2/2
u_s = [wf(x1, y1); x1*y1; -(x1^2+y1^2)/2; wf(x2, y2); x2*y2; -(x2^2+y2^2)/2; wf(x3, y3); x3*y3; -(x3^2+y3^2)/2]
f_k = Kt*u_s 'reacciones: kN para w y kN·m para θx, θy
f_sap = [1439.386675; -528.210803; 852.730577; -1675.224363; -57.306496; -2838.572066; 235.837688; 1069.372950; -1246.688392]
f_etabs = [1439.386723; -528.210743; 852.730602; -1675.224148; -57.306426; -2838.571893; 235.837425; 1069.373105; -1246.688292]
err_f_sap = 100*sqrt(transpose(f_k - f_sap)*(f_k - f_sap))/sqrt(transpose(f_sap)*f_sap) [%] 'diferencia relativa
err_f_etabs = 100*sqrt(transpose(f_k - f_etabs)*(f_k - f_etabs))/sqrt(transpose(f_etabs)*f_etabs) [%] 'diferencia relativa

## 8 · Momentos en los nodos y cortante V13, V23
#: Los seis giros internos se recuperan de los nodales: u_int = −KII⁻¹·KIn·u. Con ellos, la curvatura en cada nodo (misma B-barra de la rigidez) da el momento Db·κ. SAP2000 y ETABS dan el momento con el signo contrario al de esta hoja (M11 = −Mxx, M22 = −Myy, M12 = −Mxy), así que la suma de los dos debe dar cero.
u_int = -inv(KII)*transpose(KnI)*u_s
u15 = transpose(Ee)*u_s + transpose(Ei)*u_int
Mxx_v(a, b, c) = Db(1, 1)*transpose(kxx_r(a, b, c))*u15 + Db(1, 2)*transpose(kyy_r(a, b, c))*u15
Myy_v(a, b, c) = Db(1, 2)*transpose(kxx_r(a, b, c))*u15 + Db(2, 2)*transpose(kyy_r(a, b, c))*u15
Mxy_v(a, b, c) = Db(3, 3)*transpose(kxy_r(a, b, c))*u15
M_k1 = [Mxx_v(1, 0, 0), Myy_v(1, 0, 0), Mxy_v(1, 0, 0)] [kN·m/m] 'momentos Mxx Myy Mxy del nodo
M_k2 = [Mxx_v(0, 1, 0), Myy_v(0, 1, 0), Mxy_v(0, 1, 0)] [kN·m/m] 'momentos Mxx Myy Mxy del nodo
M_k3 = [Mxx_v(0, 0, 1), Myy_v(0, 0, 1), Mxy_v(0, 0, 1)] [kN·m/m] 'momentos Mxx Myy Mxy del nodo
#: SAP2000 (M11, M22, M12) en los nodos 1 a 3 [SAP2000 OAPI]:
M_sap1 = [-73.268026, -923.355267, 494.199195] [kN·m/m] 'momentos Mxx Myy Mxy del nodo
M_sap2 = [5627.313614, 3070.332005, 166.099293] [kN·m/m] 'momentos Mxx Myy Mxy del nodo
M_sap3 = [946.723825, 1412.268053, 1751.751702] [kN·m/m] 'momentos Mxx Myy Mxy del nodo
n3(v) = sqrt(v(1)^2 + v(2)^2 + v(3)^2)
err_M_sap = 100*sqrt(n3(M_k1 + M_sap1)^2 + n3(M_k2 + M_sap2)^2 + n3(M_k3 + M_sap3)^2)/sqrt(n3(M_sap1)^2 + n3(M_sap2)^2 + n3(M_sap3)^2) [%] 'diferencia relativa
#: ETABS 22 (OAPI), mismos nodos:
M_etabs1 = [-73.267887, -923.355369, 494.199137] [kN·m/m] 'momentos Mxx Myy Mxy del nodo
M_etabs2 = [5627.313203, 3070.331803, 166.099431] [kN·m/m] 'momentos Mxx Myy Mxy del nodo
M_etabs3 = [946.724097, 1412.268357, 1751.751621] [kN·m/m] 'momentos Mxx Myy Mxy del nodo
err_M_etabs = 100*sqrt(n3(M_k1 + M_etabs1)^2 + n3(M_k2 + M_etabs2)^2 + n3(M_k3 + M_etabs3)^2)/sqrt(n3(M_etabs1)^2 + n3(M_etabs2)^2 + n3(M_etabs3)^2) [%] 'diferencia relativa
#: Cortante constante V = Ds·γ (el mismo valor en los tres nodos):
V13_k = Ds*transpose(Bsx)*u15 [kN/m] 'cortante transversal
V23_k = Ds*transpose(Bsy)*u15 [kN/m] 'cortante transversal
#: SAP2000: V13 = −2350.930823, V23 = −351.895018. ETABS: V13 = −2350.930606, V23 = −351.895227.
err_V_sap = 100*sqrt((V13_k + 2350.930823)^2 + (V23_k + 351.895018)^2)/sqrt(2350.930823^2 + 351.895018^2) [%] 'diferencia relativa
err_V_etabs = 100*sqrt((V13_k + 2350.930606)^2 + (V23_k + 351.895227)^2)/sqrt(2350.930606^2 + 351.895227^2) [%] 'diferencia relativa

## 9 · Mapas sobre el triángulo de SAP2000 y ETABS (para comparar con el ratón)
#: El mismo triángulo (0,0), (2,0.5), (0.5,1.5) y el mismo campo. Se pasa de x, y a coordenadas de área con el inverso del Jacobiano: L2 = (x−x1)·J11 + (y−y1)·J21, L3 = (x−x1)·J12 + (y−y1)·J22, L1 = 1 − L2 − L3. Solo vale dentro del triángulo. Pasa el ratón por los nodos: en (0,0), (2,0.5) y (0.5,1.5) debe leer Mxx = −M11 de SAP2000 y ETABS (73.27, −5627.31 y −946.72: el opuesto del signo de SAP). Dentro del elemento el campo es el de la curvatura de los giros con B-barra; los nodos son lo que CSI reporta.
xi_p(x, y) = (x - x1)*Ji(1, 1) + (y - y1)*Ji(2, 1)
eta_p(x, y) = (x - x1)*Ji(1, 2) + (y - y1)*Ji(2, 2)
Mxx_p(x, y) = Mxx_v(1 - xi_p(x, y) - eta_p(x, y), xi_p(x, y), eta_p(x, y))
Myy_p(x, y) = Myy_v(1 - xi_p(x, y) - eta_p(x, y), xi_p(x, y), eta_p(x, y))
Mxy_p(x, y) = Mxy_v(1 - xi_p(x, y) - eta_p(x, y), xi_p(x, y), eta_p(x, y))
#: Mxx (kN·m/m):
#map(Mxx_p(x, y), [0 2], [0 1.5])
#: Myy (kN·m/m):
#map(Myy_p(x, y), [0 2], [0 1.5])
#: Mxy (kN·m/m):
#map(Mxy_p(x, y), [0 2], [0 1.5])

## Los rotulos
