# El Jacobiano: del cuadrado natural (ξ, η) al elemento real (x, y)
#: Todo simbólico. La idea: en FEM cada elemento se integra sobre un CUADRADO de referencia fijo, y el Jacobiano es el puente entre ese cuadrado y el elemento real.

## 1 · Por qué coordenadas naturales
#: Un elemento finito real es un cuadrilátero cualquiera, torcido. Integrar sobre él directamente es un lío: cada uno tiene otra forma. El truco de FEM: pensar TODO elemento como una deformación de un mismo CUADRADO de referencia —el "cuadrado natural"— cuyos lados ξ y η van de −1 a 1.
#: Así la integral de la rigidez siempre se hace sobre el MISMO dominio [−1, 1]×[−1, 1], sin importar la forma real. La pregunta clave: ¿cómo se relacionan las coordenadas naturales (ξ, η) del cuadrado con las físicas (x, y) del elemento? Esa relación —y su "estiramiento"— es el Jacobiano.

## 2 · El mapa: las físicas (x, y) en función de las naturales (ξ, η)
#: Las coordenadas físicas son una interpolación BILINEAL de las naturales. Los coeficientes salen de dónde están los 4 nudos del elemento; aquí los dejo como letras a₀…a₃ (para x) y b₀…b₃ (para y):
x = a0 + a1*xi + a2*eta + a3*xi*eta
y = b0 + b1*xi + b2*eta + b3*xi*eta
#: Fíjate: si ξ y η recorren el cuadrado [−1,1]², el punto (x, y) recorre el cuadrilátero real. El término mixto ξ·η es el que permite que los lados no sean paralelos (un cuadrilátero torcido, no solo un rectángulo).

## 3 · El Jacobiano: cuánto mueve a (x, y) un pasito en (ξ, η)
#: El Jacobiano recoge, en una matriz 2×2, cómo cambia cada coordenada física al empujar cada natural. Cada entrada es una derivada PARCIAL —la parcial trata a la otra variable como constante:
J11 = Partial{x @ xi}
J12 = Partial{y @ xi}
J21 = Partial{x @ eta}
J22 = Partial{y @ eta}
#: Puestas en su lugar, forman el Jacobiano J (fila 1 = derivadas respecto a ξ; fila 2 = respecto a η):
J = [J11, J12; J21, J22]
#: Cada columna dice hacia dónde y cuánto se mueve el punto físico cuando avanzas en ξ (columna 1) o en η (columna 2). Es la "matriz de estiramiento" local del mapa.

## 4 · El determinante: el factor de área
#: El determinante del Jacobiano es el factor de ESCALA de área: un cuadradito du·dη del cuadrado natural se convierte en un pedacito de área detJ·dξ·dη en el elemento real. Por eso en la integral de la rigidez aparece el detJ:
detJ = det(J)
#: OJO al resultado: detJ salió LINEAL en ξ, η (el término ξ·η se cancela solo). O sea, para un cuadrilátero general el factor de área NO es constante: cambia de punto a punto. Solo en un rectángulo (sin el término torcido) detJ es constante. Ese es el motivo de fondo por el que la integral se hace con Gauss numérico y no a mano.

## 5 · La inversa: para llevar las derivadas al mundo físico
#: El Jacobiano convierte derivadas en ξ, η a derivadas en x, y AL REVÉS: para pasar ∂/∂x y ∂/∂y (que necesita la matriz B de deformación) se usa la INVERSA del Jacobiano. En una frase: las derivadas físicas son J⁻¹ por las derivadas naturales.
Ji = inv(J)
#: Ahí está la cadena completa: el mapa (x, y)←(ξ, η) da el Jacobiano J; su determinante detJ escala el área en la integral; y su inversa J⁻¹ traduce las derivadas al elemento real. Con esos tres —J, detJ, J⁻¹— se arma toda la rigidez del elemento sobre el cuadrado natural.
