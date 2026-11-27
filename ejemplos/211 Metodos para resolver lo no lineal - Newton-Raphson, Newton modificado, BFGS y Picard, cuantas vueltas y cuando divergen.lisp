# Métodos para resolver lo no lineal - Newton-Raphson, Newton modificado, BFGS y Picard, cuántas vueltas y cuándo divergen
#numerico

## 1 · De dónde partimos
#: **¿Qué sé?** Newton-Raphson: cambiar la curva por su recta tangente, resolver la recta y repetir (hojas 196, 198 y 203). **¿Qué quiero?** Conocer los otros métodos que aparecen en OpenSees y en los programas comerciales: Newton modificado, BFGS y Picard. **¿Qué exijo?** La misma barra y el mismo criterio para todos (residuo |R| < 10⁻⁹ kN) y cada número comprobado con otro programa (SciPy). **¿Qué sale?** Una tabla de vueltas por método y los casos en que divergen. **¿Para qué?** Saber qué cambiar cuando un cálculo no converge.

## 2 · El objeto: una barra empotrada que se ablanda
#dibujo("Barra empotrada con carga axial P en la punta", ud = m, escala = auto, alto = 60)
#  achurado([-0.4, 0, 0, -0.4], [-0.8, -0.8, 0.8, 0.8], "empotre")
#  linea(0, 0, 3, 0, "gruesa")
#  flecha(3.05, 0, 4.3, 0, "gruesa rojo")
#  texto(3.9, 0.45, "P", 2.6, "c")
#  texto(1.5, -0.55, "L = 3 m, EA = 60 000 kN", 2.2, "c")
#fin
#: El material se ablanda (curva hiperbólica): empieza con la rigidez lineal k₀ = EA/L y nunca pasa de N_u, el **techo**:
N = Simplify{k_0*d/(1 + k_0*d/N_u)}
#: Su pendiente, la **rigidez tangente**:
k_T = Simplify{Diff{k_0*d/(1 + k_0*d/N_u) @ d}}
#: Hay que encontrar el alargamiento d donde el residuo R = P − N(d) vale cero. La solución exacta se despeja a mano:
d_x = Simplify{P/(k_0*(1 - P/N_u))}

## 3 · Los cuatro métodos son la MISMA fórmula
#: Todos dan el paso **d_nuevo = d + R/k**: solo cambia **qué pendiente k** se usa. Newton-Raphson usa la tangente de ESTE punto:
d_NR = Simplify{d + (P - k_0*d/(1 + k_0*d/N_u))/(k_0/(1 + k_0*d/N_u)^2)}
#: Newton modificado usa SIEMPRE la pendiente del principio, k₀ (no recalcula ni refactoriza la matriz):
d_NM = Simplify{d + (P - k_0*d/(1 + k_0*d/N_u))/k_0}
#: BFGS (Broyden, Fletcher, Goldfarb, Shanno) es un **cuasi-Newton**: no recalcula la tangente, la corrige con lo que ya midió. Con una incógnita es la pendiente de la **secante** entre las dos últimas vueltas, a y b. En esta ley sale muy limpia:
k_S = Simplify{(k_0*a/(1 + k_0*a/N_u) - k_0*b/(1 + k_0*b/N_u))/(a - b)}
#: Con muchas incógnitas, BFGS corrige la matriz con dos términos de rango 1 (rango 2): K ← K + y·yᵀ/(yᵀ·s) − K·s·sᵀ·K/(sᵀ·K·s), con s = Δu e y = el cambio del residuo. Picard (iteración directa) usa la rigidez **secante desde el origen**, N(d)/d, y despeja d = P/(N/d):
d_PI = Simplify{P/((k_0*d/(1 + k_0*d/N_u))/d)}

## 4 · Con números: cuántas vueltas
E_A = 60000 'rigidez axial EA [kN]
L_b = 3 'largo [m]
k_0 = E_A/L_b 'rigidez lineal k₀ [kN/m]
N_u = 300 'techo [kN]
P = 240 'carga [kN]
d_e = P/(k_0·(1 - P/N_u)) 'solución exacta [m]
k_F = k_0/(1 + k_0·d_e/N_u)^2 'tangente en la solución [kN/m]
r_k = k_0/k_F 'cuántas veces es más empinada la pendiente inicial [-]
#hide
T_A = zeros(12, 3)
T_B = zeros(12, 3)
T_M = zeros(200, 3)
T_P = zeros(200, 3)
Z_A = zeros(60, 2)
Z_M = zeros(60, 2)
Z_B = zeros(60, 2)
d_k = 0
for k = 1:12
  N_k = k_0·d_k/(1 + k_0·d_k/N_u)
  T_A(k, 1) = k - 1
  T_A(k, 2) = 1000·d_k
  T_A(k, 3) = P - N_k
  d_k = d_k + (P - N_k)/(k_0/(1 + k_0·d_k/N_u)^2)
end
d_k = 0
for k = 1:200
  N_k = k_0·d_k/(1 + k_0·d_k/N_u)
  T_M(k, 1) = k - 1
  T_M(k, 2) = 1000·d_k
  T_M(k, 3) = P - N_k
  d_k = d_k + (P - N_k)/k_0
end
d_k = 1/1000000
for k = 1:200
  N_k = k_0·d_k/(1 + k_0·d_k/N_u)
  T_P(k, 1) = k
  T_P(k, 2) = 1000·d_k
  T_P(k, 3) = P - N_k
  d_k = P·d_k/N_k
end
d_a = 0
R_a = P
k_s = k_0
for k = 1:12
  T_B(k, 1) = k - 1
  T_B(k, 2) = 1000·d_a
  T_B(k, 3) = R_a
  d_b = d_a + R_a/k_s
  R_b = P - k_0·d_b/(1 + k_0·d_b/N_u)
  k_s = -(R_b - R_a)/(d_b - d_a + 0.000000000000000001)
  d_a = d_b
  R_a = R_b
end
for k = 1:6
  for j = 1:6
    Z_A(10·(k - 1) + j, 1) = T_A(k, 2) + (T_A(k + 1, 2) - T_A(k, 2))·(j - 1)/5
    Z_A(10·(k - 1) + j, 2) = P - T_A(k, 3) + T_A(k, 3)·(j - 1)/5
    Z_M(10·(k - 1) + j, 1) = T_M(k, 2) + (T_M(k + 1, 2) - T_M(k, 2))·(j - 1)/5
    Z_M(10·(k - 1) + j, 2) = P - T_M(k, 3) + T_M(k, 3)·(j - 1)/5
    Z_B(10·(k - 1) + j, 1) = T_B(k, 2) + (T_B(k + 1, 2) - T_B(k, 2))·(j - 1)/5
    Z_B(10·(k - 1) + j, 2) = P - T_B(k, 3) + T_B(k, 3)·(j - 1)/5
  end
  for j = 1:4
    Z_A(10·(k - 1) + 6 + j, 1) = T_A(k + 1, 2)
    Z_A(10·(k - 1) + 6 + j, 2) = P - T_A(k + 1, 3)·j/4
    Z_M(10·(k - 1) + 6 + j, 1) = T_M(k + 1, 2)
    Z_M(10·(k - 1) + 6 + j, 2) = P - T_M(k + 1, 3)·j/4
    Z_B(10·(k - 1) + 6 + j, 1) = T_B(k + 1, 2)
    Z_B(10·(k - 1) + 6 + j, 2) = P - T_B(k + 1, 3)·j/4
  end
end
C_b = zeros(61, 2)
for j = 1:61
  C_b(j, 1) = 2·(j - 1)
  C_b(j, 2) = k_0·0.002·(j - 1)/(1 + k_0·0.002·(j - 1)/N_u)
end
#show
#: **Newton-Raphson** (tangente nueva en cada vuelta). Mira la columna R: 106,7 → 41,6 → … → menos de 10⁻⁹ en la vuelta 7: los decimales correctos se **duplican** en cada vuelta (convergencia cuadrática).
#tabla("vuelta:0","d [mm]:6","R = P − N [kN]:10")(T_A(1:9, 1); T_A(1:9, 2); T_A(1:9, 3))
#: **BFGS / secante** (la pendiente se corrige con lo medido): un poco más lenta, **10 vueltas**, cada una sin recalcular la tangente (en un modelo grande, sin refactorizar la matriz).
#tabla("vuelta:0","d [mm]:6","R = P − N [kN]:10")(T_B(1:12, 1); T_B(1:12, 2); T_B(1:12, 3))
#: **Newton modificado** (siempre k₀): como la pendiente inicial es r_k = 25 veces la de la solución, cada vuelta solo quita un 4 % del error. Las 8 primeras y la 200:
#tabla("vuelta:0","d [mm]:6","R = P − N [kN]:10")(T_M(1:8, 1); T_M(1:8, 2); T_M(1:8, 3))
d_200 = T_M(200, 2) 'Newton modificado después de 199 vueltas [mm]
R_200 = T_M(200, 3) 'residuo que le queda: todavía > 10⁻⁹ [kN]
#: **Picard** (secante desde el origen): estable pero lento. Las vueltas 110, 111 y 112 (en la 111 baja de 10⁻⁹):
#tabla("vuelta:0","d [mm]:6","R = P − N [kN]:12")(T_P(110:112, 1); T_P(110:112, 2); T_P(110:112, 3))
#: **Los zigzag sobre la curva** (eje horizontal d en mm, vertical N en kN): Newton se pega en pocas vueltas; el modificado sube siempre con la misma pendiente empinada y avanza a pasitos; BFGS va entre los dos. Pasa el cursor por los puntos:
#fplot(barra = C_b, Newton = Z_A, modificado = Z_M, BFGS = Z_B, P = 240 + 0*x, [0 120])
#hide
H_A = zeros(9, 2)
H_B = zeros(12, 2)
H_M = zeros(60, 2)
H_P = zeros(60, 2)
for k = 1:9
  H_A(k, 1) = k - 1
  H_A(k, 2) = log10(max(abs(T_A(k, 3)), 0.00000000000001))
end
for k = 1:12
  H_B(k, 1) = k - 1
  H_B(k, 2) = log10(max(abs(T_B(k, 3)), 0.00000000000001))
end
for k = 1:60
  H_M(k, 1) = k - 1
  H_M(k, 2) = log10(abs(T_M(k, 3)))
  H_P(k, 1) = k - 1
  H_P(k, 2) = log10(abs(T_P(k, 3)))
end
#show
#: **Los cuatro lado a lado:** log₁₀|R| contra la vuelta. Newton cae en picada (cuadrática), BFGS un poco más lento (superlineal), el modificado y Picard bajan en **línea recta** (lineal: un factor fijo por vuelta). La línea −9 es la tolerancia:
#fplot(Newton = H_A, BFGS = H_B, modificado = H_M, Picard = H_P, tolerancia = -9 + 0*x, [0 60])

## 5 · ¿Cuándo divergen?
### (1) Empezar lejos
#: Si Newton parte de d₀ = 200 mm, la tangente allí es casi horizontal (k_T = 20 000/(1 + 13,3)² ≈ 97 kN/m) y lo lanza al otro lado:
#hide
T_L = zeros(5, 3)
d_k = 0.2
for k = 1:5
  N_k = k_0·d_k/(1 + k_0·abs(d_k)/N_u)
  T_L(k, 1) = k - 1
  T_L(k, 2) = 1000·d_k
  T_L(k, 3) = P - N_k
  d_k = d_k + (P - N_k)/(k_0/(1 + k_0·abs(d_k)/N_u)^2)
end
#show
#tabla("vuelta:0","d [mm]:3","R [kN]:3")(T_L(1:4, 1); T_L(1:4, 2); T_L(1:4, 3))
#: 200 → −201 → 5 198 → −351 975 mm: **diverge**. Desde el mismo punto, BFGS sí llega (17 vueltas) y Newton con la carga en **10 escalones** (cada escalón parte del anterior, nunca lejos) llega con 42 vueltas en total. Por eso todos los programas cargan por escalones.
### (2) El techo
#: Con P = N_u = 300 kN no hay solución: N(d) se acerca a 300 pero nunca lo alcanza (la barra fluye). **Todos** los métodos fallan, y no es culpa del método: la estructura no puede tomar esa carga. A veces, no converger ES la respuesta.
### (3) El pico: control de carga contra control de desplazamiento
#: Si el material, después del máximo, **baja** (como un concreto), la curva tiene un pico. Con la ley N = k₀·d/(1 + (d/d₀)²):
N_p = Simplify{k_i*d/(1 + (d/d_0)^2)}
k_Tp = Simplify{Diff{k_i*d/(1 + (d/d_0)^2) @ d}}
#: La pendiente vale **cero en d = d₀** (el numerador k_i·(d₀² − d²) se anula): ahí está el pico, N_max = k_i·d₀/2.
d_0 = 0.03 'desplazamiento del pico [m]
N_max = k_0·d_0/2 'fuerza del pico [kN]
#hide
T_C = zeros(10, 3)
d_k = 0
for i = 1:10
  P_i = 30·i
  for k = 1:30
    N_k = k_0·d_k/(1 + (d_k/d_0)^2)
    d_k = d_k + (P_i - N_k)/(k_0·(1 - (d_k/d_0)^2)/(1 + (d_k/d_0)^2)^2 + 0.000000001)
  end
  T_C(i, 1) = P_i
  T_C(i, 2) = 1000·d_k
  T_C(i, 3) = P_i - k_0·d_k/(1 + (d_k/d_0)^2)
end
C_c = zeros(10, 2)
for i = 1:10
  C_c(i, 1) = T_C(i, 2)
  C_c(i, 2) = T_C(i, 1)
end
C_d = zeros(21, 2)
for j = 1:21
  C_d(j, 1) = 6·(j - 1)
  C_d(j, 2) = k_0·0.006·(j - 1)/(1 + (0.006·(j - 1)/d_0)^2)
end
C_p = zeros(61, 2)
for j = 1:61
  C_p(j, 1) = 2·(j - 1)
  C_p(j, 2) = k_0·0.002·(j - 1)/(1 + (0.002·(j - 1)/d_0)^2)
end
#show
#: **Control de carga** (P sube de 30 en 30 kN, Newton en cada escalón): llega al pico de 300 kN en 30 mm (con cada vez más vueltas, porque la tangente se aplana) y en 330 kN ya no hay solución:
#tabla("P [kN]:0","d [mm]:4","R [kN]:8")(T_C(1:10, 1); T_C(1:10, 2); T_C(1:10, 3))
#: **Control de desplazamiento**: se impone d y se lee la fuerza, así se recorre también la **rama que baja**. Con muchas incógnitas, eso es la **longitud de arco** (arc-length):
#fplot(curva_con_pico = C_p, control_de_carga = C_c, control_de_desplazamiento = C_d, P_330 = 330 + 0*x, [0 120])

## 6 · El residuo en 3D: dónde vale cero
#: Cada método busca el cero de R(d, P) = P − N(d). En la superficie, la línea donde R = 0 es la curva de la barra; cada carga P es un corte horizontal (eje x: d en mm; eje y: P en kN):
R_s(x, y) = y - k_0·x/1000/(1 + k_0·x/1000/N_u)
#surf(R_s(x, y), [0 120], [0 300])
#map(R_s(x, y), [0 120], [0 300])

## 7 · En los programas y qué hacer si no converge
#: **OpenSees:** el método es el *algorithm* (Newton, ModifiedNewton, BFGS, Broyden, KrylovNewton, NewtonLineSearch) y el control es el *integrator* (LoadControl, DisplacementControl, ArcLength). **Si no converge:** (1) escalones de carga más chicos; (2) un método más robusto, BFGS o Newton con búsqueda lineal; (3) si hay un pico, control de desplazamiento o longitud de arco; (4) si nada funciona, revisar si la carga pasa del techo: entonces la respuesta es que la estructura falla.

## 8 · Verificación con otro programa
#: Los mismos métodos escritos en Python y la raíz comprobada con **SciPy** (scipy.optimize: newton con derivada, secante y brentq), un programa independiente:
#tabla("método:0","d [mm]:6","vueltas:0")(["Newton (hoja)"; "BFGS (hoja)"; "SciPy newton"; "SciPy secante"; "SciPy brentq (exacta)"]; [T_A(8, 2); T_B(11, 2); 60.000000; 60.000000; 60.000000]; [7; 10; 7; 9; 0])
#: Pico de la ley con ablandamiento (brentq sobre k_T = 0): **300,000 kN en 30,000 mm** = N_max y d₀ de la hoja. Video: «Newton-Raphson, Newton modificado, BFGS y Picard: cuántas vueltas y cuándo divergen» (Hekatan Engineers).
