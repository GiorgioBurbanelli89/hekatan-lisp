# Dibujo técnico: cargas repartidas, diagramas y empotramientos

#: Tres primitivas nuevas del bloque #dibujo … #fin (23-sep-2026), hechas para la hoja 69 de la placa base. Van igual en la app de escritorio y en la web: el dibujo lo hace el mismo código.
#| Primitiva | Qué dibuja |
#|---|---|
#| carga(x1, y1, x2, y2, q1, q2, "texto", "estilo", n = 9, sentido = 1) | bloque de carga repartida (trapecio) sobre la cara p1→p2, con flechas hacia la cara |
#| curva(xa, xb, expresión en x, "estilo", base = y0, n = 64) | y = f(x); con base y "relleno" queda un DIAGRAMA pintado |
#| empotramiento(x1, y1, x2, y2, lado) | trazo grueso con el rayado del apoyo empotrado |
#: Reglas: q1 y q2 son el alto del bloque en unidades del dibujo; positivo = a la IZQUIERDA de p1→p2 (la misma regla de cota). Con sentido = -1 las flechas salen de la cara (tracción). La curva se corta sola donde la expresión no existe (raíz de un negativo). Además circulo(x, y, r) acepta vectores, y hay dos estilos de relleno: «denso» y «tenue».
#: Y una directiva de hoja: **#modo memoria** hace que las fórmulas se vean como se escriben (sin simplificar ni meter dentro las definiciones anteriores), que es lo que pide una memoria de cálculo. También vale #modo auto, #modo simplify y #modo expand.

## Un voladizo con carga repartida

#dibujo("Voladizo de 6 m con carga uniforme y su diagrama de momento", ud = m, cotas = m, ancho = 150, alto = 120)
#  rect(0, -0.15, 6, 0.3, "gruesa")
#  empotramiento(0, -0.6, 0, 0.6, 1)
#  carga(0, 0.15, 6, 0.15, 0.8, 0.8, "q = 20 kN/m", "azul", n = 13)
#  linea(0, -2.2, 6, -2.2, "media")
#  curva(0, 6, -2.2 - 1.3*(1 - x/6)^2, "rojo relleno", base = -2.2)
#  texto(3, -1.9, "M(x) = q·(L − x)^{2}/2: máximo en el empotramiento", 2.4, "c", estilo = "rojo")
#  cota(0, -3.6, 6, -3.6, -0.3, "L = 6.00")
#fin

## Tracción: las flechas hacia fuera

#dibujo("Una placa colgada de dos pernos", ud = mm, cotas = mm, ancho = 120, alto = 80)
#  rect(0, 0, 300, 25, "gruesa")
#  achurado(0, 0, 300, 25, "cruzado")
#  carga(0, 25, 300, 25, 60, 60, "succión uniforme", "verde", sentido = -1, n = 7)
#  circulo([50, 250], [12.5, 12.5], 8, "acero denso")
#fin
