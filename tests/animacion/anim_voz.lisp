# Animación y voz: prueba
#: Hoja de prueba de tests/animacion (escritorio con --ctl y web con Playwright).

## 1 · Gráfica de x animada
#anim fplot(u = x^n, [0 1]), n = 1:4
#voz: La potencia {n} de x.

## 2 · Superficie animada: la amplitud crece
#anim surf(A*sin(pi*x)*sin(pi*y), [0 1], [0 1]), A = 0.25:0.25:1
#voz: Amplitud un cuarto.
#voz: Amplitud un medio.
#voz: Amplitud tres cuartos.
#voz: Amplitud completa.

## 3 · Componentes de una matriz
M = [x*y, x*(1 - y); (1 - x)*y, (1 - x)*(1 - y)]
#anim surf(M, [0 1], [0 1])

## 4 · Mapa animado
#anim map(sin(k*pi*x)*sin(pi*y), [0 1], [0 1]), k = 1:3

## 5 · Bloque de dibujo animado
L = 6
#anim(j = 1:5)
#dibujo("Viga con {j} tramos", ud = m, ancho = 120, alto = 50)
#  rect(0, -0.15, L, 0.3, "gruesa")
#  carga(0, 0.15, L, 0.15, 0.8, 0.8, "q", "azul", n = j + 1)
#fin
#voz: Con {j} tramos de carga.

## 6 · Bloque con texto y fórmula
#anim(h = 1:3)
#: Con h = {h} el error es:
e_h = 1/(8*h^2)
#voz: Cuadro {h}.
#finanim

## 7 · Voz suelta
#voz: Esta frase va sola, con su botón para escucharla.
