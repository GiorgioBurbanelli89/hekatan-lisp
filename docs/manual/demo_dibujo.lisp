# Dibujo sencillo: geometrías comunes con medidas calculadas

#: Cada medida del dibujo sale de un cálculo de la hoja: si cambias un dato, cambian el cálculo y el dibujo.

## 1 · Placa con agujero y esquina redondeada
B = 8 'ancho de la placa
H = 5 'alto de la placa
A_h = 3 'área que debe tener el agujero
r = sqrt(A_h/pi) 'radio que da esa área
R = 1.5 'radio de la esquina redondeada
xc = B/2 'centro del agujero en x
yc = H/2 'centro del agujero en y

#dibujo("Placa B × H con agujero de área A_{h} y esquina redondeada R", ud = m, cotas = m, ancho = 150, alto = 110, dec = 2)
#  linea(0, 0, B, 0, "gruesa")
#  linea(B, 0, B, H - R, "gruesa")
#  arco(B - R, H - R, R, 0, 90, "gruesa")
#  linea(B - R, H, 0, H, "gruesa")
#  linea(0, H, 0, 0, "gruesa")
#  circulo(xc, yc, r, "azul denso")
#  linea(xc - 1.6, yc, xc + 1.6, yc, "eje")
#  linea(xc, yc - 1.6, xc, yc + 1.6, "eje")
#  linea(B - R, H - R, B - R + R*cos(pi/4), H - R + R*sin(pi/4), "rojo")
#  texto(B - R - 0.1, H - R - 0.35, "R = 1.50", 2.3, "c", estilo = "rojo")
#  texto(xc, yc - r - 0.4, "r = 0.98 (A_{h} = 3)", 2.3, "c", estilo = "azul")
#  cota(0, 0, B, 0, -0.8, "B = 8.00")
#  cota(0, 0, 0, H, 0.8, "H = 5.00")
#fin

## 2 · Una función, su tangente y un triángulo
x_0 = 2 'punto de tangencia
y_0 = x_0^2/4 'altura de la curva y = x²/4 en x_0
m = x_0/2 'pendiente: derivada de x²/4 es x/2
x_1 = x_0 - y_0/m 'donde la tangente corta el eje x

#dibujo("y = x²/4, su tangente en x_{0} = 2 (pendiente m = 1) y un triángulo", ud = m, ancho = 150, alto = 100, dec = 2)
#  linea(-4.5, 0, 4.5, 0, "fina")
#  linea(0, -1, 0, 5, "fina")
#  curva(-4, 4, x^2/4, "azul media")
#  linea(x_0 - 3, y_0 - 3*m, x_0 + 2, y_0 + 2*m, "rojo")
#  circulo(x_0, y_0, 0.12, "rojo relleno")
#  poligono([-3.5, -1.5, -2.5], [2.5, 2.5, 4.2], "verde tenue")
#  arco(x_1, 0, 0.9, 0, 45, "naranja")
#  texto(x_1 + 1.0, 0.3, "45°", 2.2, "i", estilo = "naranja")
#  texto(x_0 + 0.2, y_0 - 0.35, "(x_{0}, y_{0}) = (2, 1)", 2.3, "i", estilo = "rojo")
#  texto(3.6, 3.9, "y = x²/4", 2.4, "i", estilo = "azul")
#  texto(-2.5, 4.5, "triángulo", 2.2, "c", estilo = "verde")
#  texto(4.5, -0.35, "x", 2.6, "c")
#  texto(-0.3, 5, "y", 2.6, "c")
#fin

## 3 · En 3D: la deformada de la losa (Navier, primer término)
#: La losa del ejemplo de Calcpad (6 × 4 m, t = 0.1 m, E = 35000 MPa, q = 10 kN/m²) simplemente apoyada. El primer término de la serie de Navier da la forma w(x, y) = w_0·sin(πx/a)·sin(πy/b). Arrastra la superficie con el mouse para girarla.
a = 6 'largo de la losa
b = 4 'ancho de la losa
D = 35000000*0.1^3/(12*(1 - 0.15^2)) 'rigidez a flexión en kN·m
w_0 = 16*10/(pi^6*D)/(1/a^2 + 1/b^2)^2*1000 'flecha máxima en mm (primer término)
#surf(-w_0*sin(pi*x/a)*sin(pi*y/b), [0 6], [0 4])
#: Vista en planta del mismo campo (mapa de color):
#map(w_0*sin(pi*x/a)*sin(pi*y/b), [0 6], [0 4])
