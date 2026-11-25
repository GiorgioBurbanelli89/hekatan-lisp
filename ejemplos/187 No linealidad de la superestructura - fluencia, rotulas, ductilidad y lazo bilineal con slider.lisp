# No linealidad de la superestructura: fluencia, rótulas y ductilidad
#: **La idea.** Un pórtico es un resorte lateral: V = k·u (la recta). Cuando la fuerza llega a **F_y** (fluencia) se forman **rótulas plásticas** en los extremos de las columnas: el acero fluye y la pendiente cae a **α·k**.
#: En un sismo el pórtico va y viene: cada ciclo dibuja un **lazo**. Igual que en el suelo, el área del lazo es energía disipada (el daño «paga» la energía del sismo).
#: **Ductilidad μ = u/u_y**: cuántas veces se deforma más allá de la fluencia sin colapsar. Las normas reducen la fuerza de diseño (factor R) **contando** con esa ductilidad.

## 1 · El objeto: pórtico de un piso deformado, con sus rótulas
#dibujo("Pórtico de un piso con desplazamiento u (exagerado): rótulas plásticas en rojo", ud = m, escala = auto, cotas = m, alto = 170)
#  linea(-4, 0, 4, 0, "media verde")
#  rect(-2.2, 3.4, 4.4, 0.35, "trazos")
#  rect(-1.5, 3.4, 4.4, 0.35, "gruesa")
#  polilinea([-2, -1.95, -1.6, -1.3], [0, 1.2, 2.4, 3.4], "gruesa")
#  polilinea([2, 2.05, 2.4, 2.7], [0, 1.2, 2.4, 3.4], "gruesa")
#  rect(0.2, 3.75, 1.0, 0.6, "media azul")
#  texto(0.3, 4.05, "m", 3, "i")
#  circulo(-2, 0.05, 0.12, "rojo")
#  circulo(2, 0.05, 0.12, "rojo")
#  circulo(-1.3, 3.35, 0.12, "rojo")
#  circulo(2.7, 3.35, 0.12, "rojo")
#  flecha(-3.8, 3.57, -1.6, 3.57, "rojo")
#  texto(-3.8, 3.8, "V", 3, "i")
#  cota(2.2, 4.0, 2.9, 4.0, 0.2, "u")
#fin

## 2 · Con letras
u_y = F_y/k @@(desplazamiento de fluencia)
V_1 = k*u @@(antes de fluir: la recta)
V_2 = F_y + alpha*k*(u - u_y) @@(después de fluir: pendiente α·k)
mu = u_a/u_y @@(ductilidad)
xi_eq = 2*(1 - alpha)*(mu - 1)/(pi*mu*(1 + alpha*mu - alpha)) @@(amortiguamiento equivalente del lazo bilineal)
T_n = 2*pi*sqrt(m/k) @@(periodo)

## 3 · Con números: pórtico de concreto, ciclo de 5 cm
m = 100 @@(t)
k = 20000 @@(kN/m)
F_y = 400 @@(kN)
alpha = 0.05
u_a = 0.05 @@(m)
T_n = dec(2*pi*sqrt(m/k), 4) @@(s)
u_y = dec(F_y/k, 4) @@(m)
mu = dec(u_a/u_y, 4) @@(ductilidad)
V_a = dec(F_y + alpha*k*(u_a - u_y), 4) @@(kN: la fuerza casi no sube)
xi_eq = dec(2*(1 - alpha)*(mu - 1)/(pi*mu*(1 + alpha*mu - alpha)), 4) @@(≈ 34 %, además del 5 % viscoso)
#: El desplazamiento creció 2,5 veces más allá de la fluencia, pero la fuerza solo subió de 400 a 430 kN. **El precio**: rótulas dañadas y deriva permanente.

## 4 · Vista 3D: amortiguamiento ξ_eq según la ductilidad μ y α
#: Eje x = μ, eje y = α. Sube rápido hasta μ ≈ 3 y después se aplana: fluir más ya no disipa mucho más, solo daña más.
#surf(2*(x - 1)*(1 - y)/(pi*x*(1 + y*x - y)), [1 10], [0 0.2])

## 5 · Corte 2D con slider: el lazo V–u, mueve la amplitud u_a = n cm
#: Eje x = u/u_a (de −1 a 1). Bajada: V = máx(V_a − k·d, V_a − 2F_y − α·k·(d − 2u_y)), con d = u_a − u. Subida: igual, al revés. Con n = 1 (u_a < u_y = 2 cm) no fluye y el lazo es una recta; con n = 10 el lazo es ancho.
#slider fplot(bajada = max(min(20000*0.01*n, 400 + 0.05*20000*max(0.01*n - 0.02, 0)) - 20000*(0.01*n - (0.01*n*x)), min(20000*0.01*n, 400 + 0.05*20000*max(0.01*n - 0.02, 0)) - 2*400 - 0.05*20000*(0.01*n - (0.01*n*x) - 0.04)), subida = min(-min(20000*0.01*n, 400 + 0.05*20000*max(0.01*n - 0.02, 0)) + 20000*((0.01*n*x) + 0.01*n), -min(20000*0.01*n, 400 + 0.05*20000*max(0.01*n - 0.02, 0)) + 2*400 + 0.05*20000*((0.01*n*x) + 0.01*n - 0.04)), lineal = 20000*(0.01*n*x), [-1 1]), n = 1:10
