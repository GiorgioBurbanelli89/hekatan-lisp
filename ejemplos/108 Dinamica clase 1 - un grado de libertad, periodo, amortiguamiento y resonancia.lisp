# Dinámica de estructuras, clase 1: un grado de libertad — masa, rigidez, periodo, amortiguamiento y resonancia
#numerico

#: **Para qué sirve esta clase.** Es la primera de tres (hojas 108, 109 y 110). Lleva de cero hasta el análisis modal de un edificio (clase 2, hoja 109) y de ahí a los temas de la masa sísmica, los tipos de losa y el tiempo-historia (clase 3, hoja 110). Va **antes** del vídeo del cortante basal y el análisis modal espectral (cpp06), que da por sabido lo que aquí se deduce.
#: **Fuentes.** A. K. Chopra, *Dinámica de Estructuras*, 4.ª ed.: ec. 1.3.2 (rigidez lateral del pórtico), 2.2.4 a 2.2.13 (vibración libre amortiguada), 3.2.4 a 3.2.8 (carga armónica y resonancia). NEC-SE-DS 2015 §6.2.2 c (pág. 57: ξ = 0.05) y §6.1.6 b (pág. 54: inercia agrietada 0.8·I_{g} en columnas). ACI 318-19 §19.2.2.1 (módulo del hormigón).
#: **Unidades.** Las de Ecuador: tonf, m, s; f′c en kgf/cm². Donde importa se da también el SI (kN, kg, MPa). Masa en tonf·s²/m (= 1 t de masa ·9.80665).

## 1 · El modelo más simple: una masa sobre un resorte

#: Una masa m apoyada sin rozamiento y unida a una pared por un resorte de rigidez k. Se la aparta una distancia u_{0} y se la suelta. Nada más la empuja: es **vibración libre**.
#dibujo("Oscilador de un grado de libertad: masa m, resorte k, desplazamiento u", ud = m, alto = 90)
#  linea(0, -0.2, 0, 1.4, "gruesa")
#  achurado(-0.3, -0.2, 0.3, 1.6, "concreto")
#  linea(-0.3, -0.2, 5.0, -0.2, "gruesa")
#  polilinea(0, 0.6, 0.4, 0.6, 0.6, 0.9, 0.9, 0.3, 1.2, 0.9, 1.5, 0.3, 1.8, 0.9, 2.1, 0.3, 2.3, 0.6, 2.6, 0.6, "media azul")
#  rect(2.6, -0.2, 1.2, 1.2, "gruesa")
#  texto(3.05, 0.35, "m", 4, "i")
#  texto(1.25, 1.05, "k", 4, "i")
#  flecha(2.6, 1.3, 3.6, 1.3, "rojo")
#  texto(3.0, 1.45, "u(t)", 3, "i")
#fin
#: Un **pórtico de un piso** es el mismo sistema: la losa es la masa y las columnas son el resorte. Por eso todo lo que sigue vale para un edificio.

## 2 · El equilibrio, deducido

#: **Newton.** La suma de fuerzas sobre la masa es su masa por su aceleración: ΣF = m·ü.
#: **El resorte.** Empuja hacia atrás, proporcional a lo que se le estira: F_{r} = −k·u (ley de Hooke).
#: Igualando: m·ü = −k·u, o sea, la **ecuación del movimiento libre**:
#: **m·ü + k·u = 0**
#: Es «inercia + fuerza elástica = 0». No hay carga a la derecha: la masa se mueve por lo que se le dio al soltarla.
#: **Se prueba una solución** u(t) = u_{0}·cos(ω·t), que arranca en u_{0} y en reposo. Su velocidad y su aceleración:
v_t = Diff{u_0·cos(w·t) @ t} 'velocidad u̇(t)
a_t = Diff{Diff{u_0·cos(w·t) @ t} @ t} 'aceleración ü(t)
#: La aceleración es −ω² por el desplazamiento. Se sustituye en m·ü + k·u:
r_t = Simplify{m·Diff{Diff{u_0·cos(w·t) @ t} @ t} + k·u_0·cos(w·t)} 'lo que sobra al sustituir
#: Para que sobre **cero en todo instante**, el paréntesis (k − m·ω²) tiene que valer cero. De ahí salen las tres magnitudes de la vibración:
#: **ω = √(k/m)** (frecuencia circular, rad/s) · **T = 2·π/ω** (periodo, s: lo que tarda un ciclo) · **f = 1/T** (frecuencia, ciclos por segundo, Hz)
#: ω no depende de u_{0}: el periodo es **de la estructura**, no de cuánto se la empuje.

## 3 · El periodo y la masa, como y = m·x + b

#: Despejando: T = 2·π·√(m/k). Doblar la masa **no dobla** el periodo: lo multiplica por √2 = 1.414. Para doblar T hay que **cuadruplicar** la masa.
#: Tomando logaritmos sale una recta:
#: **log T = ½·log m + log(2·π/√k)** → y = m·x + b con y = log T, x = log m, pendiente **½**, ordenada b = log(2·π/√k).
#: La pendiente ½ es la raíz cuadrada. Más rigidez solo baja la recta (cambia b), no la inclina. Con la masa multiplicada por n (1 = la del pórtico de la sección 4):
#fplot(T_n = 0.128198*sqrt(x), T_lineal = 0.128198*x, [1 4])
#: Eje horizontal: n, veces la masa; eje vertical: T en s. La curva de abajo es la de verdad (√n); la recta de arriba es lo que pasaría si T fuera proporcional a m. Con n = 4 el periodo solo se dobla (0.256 s), no se cuadruplica.
#: La misma oscilación con la masa ×1, ×2, ×3 y ×4 (eje horizontal: t en s; vertical: u/u_{0}):
#anim fplot(u = cos(2*pi*x/(0.128198*sqrt(n))), [0 0.5]), n = 1:0.05:4

## 4 · Un pórtico de un piso, con números

#: Planta de 6 × 6 m, cuatro columnas de 40 × 50 cm (40 cm en la dirección X), 3 m de altura, losa que se supone **infinitamente rígida** frente a las columnas (cota alta de la rigidez: Chopra ec. 1.3.2).
f_c = 240 'resistencia del hormigón f′c [kgf/cm²]
f_cM = f_c·9.80665/100 'la misma en el SI [MPa]
E_cM = 4700·sqrt(f_cM) 'módulo del hormigón, ACI 318-19 §19.2.2.1 [MPa]
E_c = E_cM·1000/9.80665 'el mismo en tonf/m² (1 MPa = 101.97 tonf/m²)
b_x = 0.40 'lado de la columna en X [m]
b_y = 0.50 'lado de la columna en Y [m]
h_p = 3.0 'altura del piso [m]
#: Para que la losa se vaya en X la columna se dobla alrededor de su eje Y: el lado que trabaja es b_{x}. La NEC-15 §6.1.6 b pide inercia agrietada: 0.8·I_{g} en columnas.
I_x = 0.8·b_y·b_x^3/12 'inercia agrietada para el movimiento en X [m⁴]
#: **Rigidez de una columna empotrada arriba y abajo** (la losa no gira): la fuerza que la desplaza una unidad. Sale de la viga de Euler-Bernoulli con los dos extremos sin giro:
#: **k_{c} = 12·E·I/h³**
k_c = 12·E_c·I_x/h_p^3 'rigidez lateral de una columna en X [tonf/m]
k_x = 4·k_c 'rigidez lateral del piso en X: 4 columnas en paralelo [tonf/m]
k_xSI = k_x·9.80665 'la misma en el SI [kN/m]
#: **La masa.** Sale del peso: m = W/g. Con 1.0 tonf/m² de carga muerta sobre 36 m²:
q_D = 1.0 'peso por metro cuadrado de losa (carga muerta) [tonf/m²]
W_p = q_D·6·6 'peso del piso [tonf]
g = 9.80665 'gravedad [m/s²]
m_p = W_p/g 'masa del piso [tonf·s²/m]
m_SI = W_p·1000 'la misma masa en el SI: 36 t de masa [kg]
#: **Periodo**, primero la fórmula y luego los números:
#: ω = √(k/m) · T = 2·π/ω · f = 1/T
omega_n = sqrt(k_x/m_p) 'frecuencia circular [rad/s]
T_n = 2·pi/omega_n 'periodo propio en X [s]
f_n = 1/T_n 'frecuencia propia [Hz]
#: **0.128 s**: el pórtico va y vuelve casi ocho veces por segundo. Es un periodo corto porque la losa se tomó rígida; con vigas reales la rigidez baja (Chopra ec. 1.3.5) y T sube.
#: Soltado desde u_{0} = 1 cm (eje horizontal: t en s; vertical: u en cm):
#fplot(u = cos(omega_n*x), [0 0.5])

#dibujo("El pórtico de un piso es un oscilador: la losa es m, las columnas son k", ud = m, alto = 110)
#  linea(-0.5, 0, 6.5, 0, "gruesa")
#  achurado(-0.5, -0.3, 7.0, 0.3, "terreno")
#  linea(0, 0, 0, 3, "trazos")
#  linea(6, 0, 6, 3, "trazos")
#  polilinea(0, 0, 0.15, 1.0, 0.45, 2.0, 0.6, 3.0, "gruesa azul")
#  polilinea(6, 0, 6.15, 1.0, 6.45, 2.0, 6.6, 3.0, "gruesa azul")
#  rect(0.6, 3.0, 6.0, 0.3, "gruesa")
#  achurado(0.6, 3.0, 6.0, 0.3, "concreto")
#  flecha(6.8, 3.15, 7.6, 3.15, "rojo")
#  texto(6.9, 3.4, "u(t)", 3, "i")
#  texto(3.2, 3.55, "m = W/g", 3, "i")
#  texto(2.2, 1.4, "k = 4·12·E·I/h³", 3, "i")
#  cota(-0.4, 0, -0.4, 3, -0.2, "h = 3.00")
#fin

## 5 · El amortiguamiento: la vibración se apaga

#: Un pórtico real no vibra para siempre: fisuras, juntas y tabiques disipan energía. Se representa con un amortiguador viscoso c·u̇ y la ecuación queda **m·ü + c·u̇ + k·u = 0**.
#: Se mide con la **fracción del amortiguamiento crítico** ξ = c/(2·m·ω). La NEC-15 (§6.2.2 c, pág. 57) construye su espectro con **ξ = 0.05** (5 %).
xi = 0.05 'fracción de amortiguamiento crítico de la NEC-15
omega_D = omega_n·sqrt(1 - xi^2) 'frecuencia amortiguada, Chopra ec. 2.2.5 [rad/s]
#: Con 5 % ω_{D} es casi igual a ω: el amortiguamiento **no cambia el periodo**, apaga la amplitud. La respuesta (Chopra ec. 2.2.4, soltada desde u_{0} sin velocidad):
#: u(t) = u_{0}·e^{−ξ·ω·t}·[cos(ω_{D}·t) + ξ/√(1 − ξ²)·sen(ω_{D}·t)]
#fplot(u = exp(-xi*omega_n*x)*(cos(omega_D*x) + xi*omega_n/omega_D*sin(omega_D*x)), envolvente = exp(-xi*omega_n*x), [0 1])
#: Eje horizontal: t en s; vertical: u/u_{0}. La curva de arriba es la **envolvente** e^{−ξ·ω·t}: los picos caen sobre ella.
#: **Otra recta y = m·x + b.** El logaritmo de la envolvente es ln(u) = ln(u_{0}) − ξ·ω·t: una recta con pendiente **−ξ·ω**. Por eso, midiendo en obra dos picos sucesivos, se saca ξ (decremento logarítmico, Chopra ec. 2.2.11: δ ≈ 2·π·ξ).
p_env = -xi·omega_n 'pendiente de ln(amplitud) contra t [1/s]
N_50 = 0.11/xi 'ciclos para que la amplitud caiga a la mitad, Chopra ec. 2.2.13
#: Con ξ = 0 a 20 % (n·5 %), el mismo pórtico:
#anim fplot(u = exp(-(n/20)*omega_n*x)*cos(omega_n*x), [0 0.5]), n = 0:0.05:4

## 6 · La resonancia: cuando la carga va al ritmo de la estructura

#: Ahora una carga armónica p(t) = p_{0}·sen(Ω·t) (una máquina, o un sismo con un periodo dominante). La ecuación es **m·ü + c·u̇ + k·u = p_{0}·sen(Ω·t)**.
#: Pasado el arranque, la estructura vibra al ritmo de la carga con una amplitud u_{0} = (p_{0}/k)·R_{d}, donde p_{0}/k es lo que se movería con la carga quieta y R_{d} es el **factor de amplificación dinámica** (Chopra ec. 3.2.4 y 3.2.10):
#: **R_{d} = 1/√[(1 − r²)² + (2·ξ·r)²]**, con r = Ω/ω (la razón de frecuencias)
#fplot(xi_2 = 1/sqrt((1 - x^2)^2 + (2*0.02*x)^2), xi_5 = 1/sqrt((1 - x^2)^2 + (2*0.05*x)^2), xi_10 = 1/sqrt((1 - x^2)^2 + (2*0.10*x)^2), xi_20 = 1/sqrt((1 - x^2)^2 + (2*0.20*x)^2), [0 3])
#: Eje horizontal: r = Ω/ω; vertical: R_{d}. Tres zonas:
#: · **r ≪ 1** (carga lenta): R_{d} ≈ 1, la estructura la sigue como si fuera estática.
#: · **r ≈ 1** (resonancia): la carga empuja siempre a favor y solo el amortiguamiento frena. El pico vale 1/(2·ξ) (Chopra ec. 3.2.7).
#: · **r ≫ 1** (carga rápida): R_{d} → 0, la masa no alcanza a seguirla.
R_res = 1/(2·xi) 'amplificación en resonancia con ξ = 5 %
T_res = T_n 'periodo de la carga que hace entrar en resonancia al pórtico [s]
#: **Con 5 % el pórtico se mueve 10 veces lo estático.** Por eso importa el periodo del edificio frente al del suelo: un sismo con energía cerca de 0.128 s castiga a este pórtico.
#: Y no llega de golpe: arrancando del reposo, la amplitud crece ciclo a ciclo hasta ese tope (Chopra ec. 3.2.8). Eje vertical: u/(p_{0}/k); horizontal: t en s.
#fplot(u = R_res*(exp(-xi*omega_n*x) - 1)*cos(omega_n*x), envolvente = R_res*(1 - exp(-xi*omega_n*x)), [0 1.5])

## 7 · Lo que hay que llevarse

#hide
r_k = round(k_x, 2)
r_m = round(m_p, 4)
r_w = round(omega_n, 3)
r_T = round(T_n, 4)
r_R = round(R_res, 1)
#show
#| Magnitud | Fórmula | Pórtico de 1 piso |
#|---|---|---:|
#| rigidez lateral | k = Σ 12·E·I/h³ | @{r_k} tonf/m |
#| masa | m = W/g | @{r_m} tonf·s²/m |
#| frecuencia circular | ω = √(k/m) | @{r_w} rad/s |
#| periodo | T = 2·π/ω | @{r_T} s |
#| amplificación en resonancia | 1/(2·ξ) | @{r_R} |

#: 1 · **m·ü + k·u = 0** no se memoriza: es Newton más Hooke.
#: 2 · **T crece con √m y baja con √k**: es la recta de pendiente ½ en escala logarítmica.
#: 3 · **ξ = 5 %** no cambia el periodo; limita la resonancia a 10 veces lo estático.
#: **Clase 2 (hoja 109):** el mismo razonamiento con tres pisos: tres masas, una matriz de rigidez, tres periodos y tres formas de vibrar.
