# La ventana «Carga móvil» de Hekatan Struct, rótulo a rótulo (hoja del vídeo cm_ventana)
#: De dónde sale cada número del panel. Caso en pantalla: alcantarilla cajón de 2 celdas de 9.50 m y 6.00 m de alto, camión de diseño con separación trasera de 4.30 m.

## 1 · La posición
#: El tablero se malla con un nudo cada 0.10 m y el camión avanza ese mismo paso. Las posiciones van desde que entra el primer eje hasta que sale el último, o sea el largo del tablero más el largo del camión:
n_pos = dec((19 + 8.6)/0.1 + 1, 0)
#: Por eso el panel dice 277. Y la abscisa del eje delantero en la posición número 60:
x_F = dec((60 - 1)*0.1, 2)

## 2 · La suma de los ejes que están dentro
#: En esa posición los ejes están en 5.90, en 1.60 y en menos 2.70 m. El tercero todavía rueda por la calzada, así que solo cargan dos:
P_dentro = dec(35 + 145, 0)
P_tonf = dec(P_dentro/9.80665, 2)

#salto
## 3 · El control de equilibrio
#: La suma de las reacciones menos la suma de las cargas tiene que dar cero. Lo que queda es el error del solver, no una fuerza:
relativo = dec(4.6*10^-10/P_dentro, 14)
#: Y ese desequilibrio, en micronewtons:
error_uN = dec(4.6*10^-10*10^9, 2)

## 4 · La escala de la deformada
#: El mayor desplazamiento de todo el cruce se dibuja como el 1.5 % de la diagonal del modelo. La diagonal de un cajón de 19.00 por 6.00 m:
diag = dec(sqrt(19^2 + 6^2), 3)
#: Y el mayor desplazamiento de todo el cruce, que es el tope de la barra de color:
u_max = 0.00984
esc_def = dec(0.015*diag/u_max, 1)
#: Por eso el panel dice por treinta con cuatro y la barra de color acaba en 9.84 milímetros.

#salto
## 5 · La envolvente del panel
#: La separación trasera del camión de diseño va de 4.30 a 9.00 m de diez en diez centímetros:
n_sep = dec((9.0 - 4.3)/0.1 + 1, 0)
n_barrido = dec(n_sep*277, 0)
#: Por eso el bloque de envolvente dice 13296 posiciones. Y sus picos, en toneladas fuerza por metro:
M_3max = 30.35
M_3min = -35.38
U_zmin = -12.323
