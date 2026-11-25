# Pruebas del manual de GEO5 FEM: edómetro y triaxial con Drucker-Prager, primero con símbolos y luego con números, contra la solución exacta
#numerico

## 1 · Las pruebas
#: El **manual teórico de GEO5 FEM** (Fine, 2025, cap. 4.6, pp. 39–42) comprueba su Drucker-Prager con dos ensayos de laboratorio que tienen **solución exacta**: el **edómetro** (compresión en una dirección, sin dejar que la muestra se ensanche) y el **triaxial** (presión de cámara fija y se empuja desde arriba). Como el esfuerzo es el mismo en toda la muestra, basta seguir **un punto del material**: el mismo algoritmo que la hoja 190 usa en cada punto de Gauss del talud. Si aquí da lo mismo que el manual, el talud está bien calculado punto por punto.
#dibujo("Edómetro (izquierda) y triaxial (derecha): un punto del suelo", ud = m, escala = auto, alto = 70)
#  achurado([0, 10, 10, 0], [0, 0, 6, 6], "suelo")
#  poligono(-1, -1, 11, -1, 11, 7, 10, 7, 10, 0, 0, 0, 0, 7, -1, 7, "gruesa")
#  flecha(5, 10, 5, 6.2, "gruesa rojo")
#  texto(5, 11, "σ_z (se empuja)", 2.2, "c")
#  texto(5, -2.6, "anillo rígido: ε_x = 0", 2.2, "c")
#  achurado([20, 28, 28, 20], [0, 0, 8, 8], "suelo")
#  poligono(20, 0, 28, 0, 28, 8, 20, 8, "gruesa")
#  flecha(24, 12, 24, 8.2, "gruesa rojo")
#  flecha(16, 4, 19.8, 4, "azul")
#  flecha(32, 4, 28.2, 4, "azul")
#  texto(24, 13, "σ₃ (se empuja)", 2.2, "c")
#  texto(24, -2.6, "cámara: σ₁ = σ₂ = −50 kPa", 2.2, "c")
#fin

## 2 · Primero con símbolos
#: **El esfuerzo medio y el desviador** (compresión negativa, como en GEO5): σ_m = (σ₁ + σ₂ + σ₃)/3 y J = √J₂. En el edómetro y el triaxial dos esfuerzos son iguales (σ_x = σ_y), así que:
s_m = Simplify{(2*s_x + s_z)/3}
J_2 = Simplify{((s_x - s_m)^2 + (s_x - s_m)^2 + (s_z - s_m)^2)/2}
#: es decir J = |σ_z − σ_x|/√3. **Drucker-Prager de GEO5** (manual ec. 4.1): f = J + (σ_m − c·cot φ)·M_φ. El suelo aguanta mientras f ≤ 0. La pendiente M_φ (ec. 4.2 y 4.3), ajustando el cono a Mohr-Coulomb en compresión (θ = +30°) o en extensión (θ = −30°):
M_c = Simplify{2*sqrt(3)*sin(phi)/(3 - sin(phi))}
M_x = Simplify{2*sqrt(3)*sin(phi)/(3 + sin(phi))}
f_DP = Simplify{J + (s_m - c*cos(phi)/sin(phi))*M}
#: Las pruebas del manual usan el cono de **compresión** (M_φ = 0.6928 con φ = 30°; con el de extensión los números de las figuras no salen). **Elasticidad** (Hooke, manual §1.8): las constantes de Lamé y el módulo volumétrico:
l_a = Simplify{E*nu/((1 + nu)*(1 - 2*nu))}
G_s = Simplify{E/(2*(1 + nu))}
K_s = Simplify{E/(3*(1 - 2*nu))}
#: **Edómetro, tramo elástico.** Con ε_x = ε_y = 0 y un acortamiento Δε_z: Δσ_x = λ·Δε_z y Δσ_z = (λ + 2G)·Δε_z. Entonces J sube 2G·|Δε_z|/√3 y −σ_m sube (3λ + 2G)·|Δε_z|/3. La pendiente del camino en el plano (−σ_m, J):
r_oed = Simplify{(2*E/(2*(1 + nu))/sqrt(3))/((3*E*nu/((1 + nu)*(1 - 2*nu)) + 2*E/(2*(1 + nu)))/3)}
#: (manual ec. 4.52: J = 3(1 − 2ν)/(√3(1 + ν))·(−σ_m + σ_m^in)). Sale de una presión inicial σ_m^in = −50 kPa (J = 0). Con c = 0 el cono es J = M_φ·(−σ_m), y el camino lo toca cuando r·(p − 50) = M_φ·p, con p = −σ_m:
p_y = Simplify{50*r/(r - M)}
#: **Edómetro, tramo plástico.** Sin dilatancia (ψ = 0) el flujo plástico solo cambia el desviador: el punto se queda SOBRE el cono, J = M_φ·(−σ_m) (manual ec. 4.53). Solo hay fluencia si r > M_φ: con ν = 0.3 y φ = 30°, r = 0.533 < 0.693 y el edómetro NUNCA fluye.
#: **Triaxial.** La cámara fija σ_x = −50 kPa y se empuja σ_z: el camino es J + √3·(50 + σ_m) = 0 (ec. 4.55). Con c = 0 toca el cono J = −M_φ·σ_m en (ec. 4.56):
s_me = Simplify{50*sqrt(3)/(M - sqrt(3))}
J_e = Simplify{-M*50*sqrt(3)/(M - sqrt(3))}
#: y el esfuerzo axial en la falla, σ₃ = −√3·J_e + σ₁ (ec. 4.57), con la deformación desviadora E_d = J/G en el tramo elástico (ec. 4.56).
#: **El algoritmo de un punto (el de la hoja 190 y de GEO5):** 1) predictor elástico, σ ← σ + D·Δε; 2) si f > 0, retorno al cono: con ψ = 0, σ_m no cambia y el desviador se escala hasta J = −(σ_m − c·cot φ)·M_φ:
J_ret = Simplify{-(s_m - c*cos(phi)/sin(phi))*M}

## 3 · Ahora con números (con unidades)
#: Tabla 4.3 del manual: E = 10 MPa, ν = 0.3, c = 10 kPa, φ = 30°, ψ = 0. Las figuras usan c = 0 (lo dice el texto para el triaxial). En el edómetro, la Fig. 4.6 (pendiente elástica 0.866 y fluencia en (250.3, 173.5)) solo sale con **ν = 0.2**: con el ν = 0.3 de la tabla el edómetro no llega a fluir (ver arriba). Se usan los datos que reproducen las figuras:
E = 10000 'módulo de elasticidad [kPa]
fi = 30·pi/180 'ángulo de fricción φ = 30° [rad]
c_0 = 0 'cohesión de las figuras [kPa]
p_0 = 50 'presión inicial σ_m^in = −50 kPa (compresión) [kPa]
M_p = 2·sqrt(3)·sin(fi)/(3 - sin(fi)) 'M_φ del cono de compresión [-]
M_e = 2·sqrt(3)·sin(fi)/(3 + sin(fi)) 'M_φ del cono de extensión (el que usa GEO5 por defecto) [-]

### 3.1 · Edómetro (ν = 0.2)
n_o = 0.2 'coeficiente de Poisson del edómetro [-]
l_o = E·n_o/((1 + n_o)·(1 - 2·n_o)) 'λ de Lamé [kPa]
G_o = E/(2·(1 + n_o)) 'módulo de corte G [kPa]
r_o = 2·sqrt(3)·G_o/(3·l_o + 2·G_o) 'pendiente elástica J/(−Δσ_m) [-]
p_yo = p_0·r_o/(r_o - M_p) 'fluencia: −σ_m [kPa]
J_yo = M_p·p_yo 'fluencia: J [kPa]
#: La Fig. 4.6 del manual marca su punto FEM en (250.3, 173.5); la intersección exacta es (250.0, 173.2): el manual queda 0.1 % arriba. **El algoritmo, paso a paso** (acortamiento Δε_z = −0.001 por paso, 100 pasos):
#hide
n_p = 100
d_e = -0.001
P_o = zeros(n_p + 1, 2)
s_xo = -p_0
s_zo = -p_0
P_o(1, 1) = p_0
P_o(1, 2) = 0
i_y = 0
for i = 1:n_p
  s_xo = s_xo + l_o·d_e
  s_zo = s_zo + (l_o + 2·G_o)·d_e
  s_mo = (2·s_xo + s_zo)/3
  J_o = abs(s_zo - s_xo)/sqrt(3)
  f_o = J_o + (s_mo - c_0)·M_p
  if f_o > 0
    J_n = -(s_mo - c_0)·M_p
    d_o = (s_zo - s_xo)·J_n/J_o
    s_xo = s_mo - d_o/3
    s_zo = s_mo + 2·d_o/3
    J_o = J_n
    if i_y == 0
      i_y = i
    end
  end
  P_o(i + 1, 1) = -s_mo
  P_o(i + 1, 2) = J_o
end
E_o = zeros(12, 2)
C_o = zeros(13, 2)
for k = 1:12
  E_o(k, 1) = p_0 + 50·(k - 1)
  E_o(k, 2) = r_o·50·(k - 1)
end
for k = 1:13
  C_o(k, 1) = 50·(k - 1)
  C_o(k, 2) = M_p·50·(k - 1)
end
#show
p_1 = P_o(i_y, 1) 'último punto elástico del algoritmo: −σ_m [kPa]
p_2 = P_o(i_y + 1, 1) 'primer punto plástico: −σ_m [kPa]
J_2o = P_o(i_y + 1, 2) 'primer punto plástico: J [kPa]
r_2 = J_2o/p_2 'en la rama plástica J/(−σ_m) = M_φ [-]
J_fin = P_o(n_p + 1, 2) 'J al final (100 pasos) [kPa]
p_fin = P_o(n_p + 1, 1) '−σ_m al final [kPa]
#: **Camino de esfuerzos del edómetro** (en la leyenda: «algoritmo», un punto por paso; «elastica», la recta exacta; «cono», el cono de Drucker-Prager). Pasa el cursor para leer J y −σ_m:
#fplot(algoritmo = P_o, elastica = E_o, cono = C_o, [0 600])

### 3.2 · Triaxial (ν = 0.3, c = 0)
n_t = 0.3 'coeficiente de Poisson del triaxial [-]
G_t = E/(2·(1 + n_t)) 'módulo de corte G [kPa]
s_mt = p_0·sqrt(3)/(M_p - sqrt(3)) 'fluencia: σ_m (manual: −83.33) [kPa]
J_et = -M_p·s_mt 'fluencia: J (manual: 57.73) [kPa]
E_de = J_et/G_t 'deformación desviadora al fluir (manual: 0.015) [-]
s_3t = -sqrt(3)·J_et - p_0 'σ₃ axial en la falla (manual: −150) [kPa]
#: **El algoritmo, con desplazamiento impuesto** (como en el manual: con fuerza impuesta Newton se vuelve singular al fluir): Δε_z = −0.0002 por paso, 150 pasos, la cámara fija σ_x = −50 kPa. Elástico: Δσ_z = E·Δε_z; si f > 0 el punto vuelve a f = 0 sobre su camino y el resto de Δε_z es plástico (con ψ = 0 solo desviador: ΔE_d^pl = √3·Δε_z^pl):
#hide
n_q = 150
d_t = -0.0002
T_r = zeros(n_q + 1, 2)
s_xt = -p_0
s_zt = -p_0
E_dp = 0
for i = 1:n_q
  s_zn = s_zt + E·d_t
  s_m2 = (2·s_xt + s_zn)/3
  J_t = abs(s_zn - s_xt)/sqrt(3)
  f_t = J_t + (s_m2 - c_0)·M_p
  if f_t > 0
    s_zn = (s_xt/sqrt(3) + (2·s_xt/3 - c_0)·M_p)/(1/sqrt(3) - M_p/3)
    E_dp = E_dp + sqrt(3)·abs(d_t - (s_zn - s_zt)/E)
    s_m2 = (2·s_xt + s_zn)/3
    J_t = abs(s_zn - s_xt)/sqrt(3)
  end
  s_zt = s_zn
  T_r(i + 1, 1) = J_t/G_t + E_dp
  T_r(i + 1, 2) = J_t
end
T_e = zeros(7, 2)
for k = 1:7
  T_e(k, 1) = 0.0025·(k - 1)
  T_e(k, 2) = G_t·0.0025·(k - 1)
end
#show
J_tf = T_r(n_q + 1, 2) 'J al final del algoritmo [kPa]
s_3f = s_zt 'σ₃ al final del algoritmo [kPa]
E_df = T_r(n_q + 1, 1) 'E_d al final [-]
#: **Curva J – E_d del triaxial** («algoritmo» y la recta exacta «elastica», J = G·E_d). Sube con pendiente G hasta J_e = 57.73 kPa y E_d = 0.015 y luego queda plana: plástico perfecto, como la Fig. 4.10(b) del manual:
#fplot(algoritmo = T_r, elastica = T_e, [0 0.03])

## 4 · El cono en 2D y en 3D
#: El valor de f en el plano (−σ_m, J) con el cono de compresión y c = 0: f < 0 es elástico (el suelo aguanta), f = 0 es el cono y f > 0 no está permitido (el algoritmo lo devuelve al cono). Pasa el cursor:
f_c(x, y) = y - M_p·x
#map(f_c(x, y), [0 600], [0 400])
#: La misma función como superficie (arrastra para girar). El borde donde cruza cero es el cono de Drucker-Prager:
#surf(f_c(x, y), [0 600], [0 400])

## 5 · Hoja contra el manual
t_m = [250.3, 173.5, -83.33, 57.73, 0.015, -150] 'manual de GEO5 FEM (Fig. 4.6: su punto FEM; ec. 4.56 y 4.57: exactas)
t_h = [p_yo, J_yo, s_mt, J_et, E_de, s_3t] 'esta hoja, fórmula exacta
t_a = [p_2, J_2o, (2·(-p_0) + s_3f)/3, J_tf, E_de, s_3f] 'esta hoja, algoritmo paso a paso
#tabla("Valor","Manual:3","Fórmula:4","Algoritmo:4")({"edómetro −σ_m fluencia [kPa]","edómetro J fluencia [kPa]","triaxial σ_m [kPa]","triaxial J [kPa]","triaxial E_d [-]","triaxial σ₃ [kPa]"}; t_m; t_h; t_a)
#: **Triaxial:** fórmula y algoritmo dan las ecuaciones 4.56 y 4.57 del manual a todas sus cifras (−83.33, 57.73, 0.015, −150). **Edómetro:** la fluencia exacta es (250.0, 173.2) y el algoritmo cae justo ahí (el paso de 5.56 kPa llega exacto); el (250.3, 173.5) de la figura del manual es su punto de elementos finitos, 0.1 % arriba. Después el algoritmo sigue el cono, J/(−σ_m) = M_φ = 0.6928, sin error. Es el mismo retorno al cono que usa la hoja 190 en cada punto de Gauss del talud.
