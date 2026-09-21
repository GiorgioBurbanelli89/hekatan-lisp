# Cómo se discretiza la malla bajo el camión (hoja del vídeo cm_malla)
#: Respuesta con lo que hace el motor, sacada del código: examples/src/shared/cargaMovil.ts, funciones pesosEnPosicion, posiciones, tributario y lineasDeInfluenciaFranja.

## 1 · La malla del tablero es el paso del camión
#: El tablero se malla con un nudo cada 0.10 m y el camión avanza ese mismo paso, así que cada eje cae siempre EN un nudo. Con la separación de la norma:
paso = 0.1
a_1 = 4.3
n_1 = dec(a_1/paso, 0)
#: Un número entero de pasos: el segundo eje cae en nudo igual que el primero.

## 2 · Si un eje cae entre dos nudos: regla de la palanca
#: Sean s_{i} y s_{j} los dos nudos que lo encierran y x la abscisa del eje. La fracción del tramo es:
t = (x - s_i)/(s_j - s_i)
#: Y la carga del eje se reparte entre los dos nudos:
w_i = P*(1 - t)
w_j = P*t

#salto
## 3 · Un ejemplo de reparto
s_i = 3.2
s_j = 3.3
x = 3.27
P = 145
t = dec((x - s_i)/(s_j - s_i), 2)
w_i = dec(P*(1 - t), 2)
w_j = dec(P*t, 2)
#: La suma sigue siendo la carga del eje, así que el equilibrio no se pierde:
w_tot = dec(w_i + w_j, 2)

## 4 · La carga que entra al modelo
#: Cada eje se divide por el ancho de reparto E, para dar kilonewtons por metro de franja, y lleva el factor dinámico:
P_k = P_norma*(1 + IM_x/100)/E_x
#: Con el ancho por defecto de un metro y sin factor dinámico, el eje entero va sobre la franja de un metro, que es el lado seguro:
E_x = 1
P_eje = dec(145*(1 + 0/100)/E_x, 1)

#salto
## 5 · Ancho tributario de cada nudo
#: La carga de carril se reparte por el medio tramo de cada lado:
b_k = (s_k - s_anterior)/2 + (s_siguiente - s_k)/2
#: Con nudos cada 0.10 m, el ancho tributario de un nudo interior:
b_int = dec(0.1/2 + 0.1/2, 2)

## 6 · En la franja de placas
#: Cuando el tablero son placas y no barras, el kilonewton del caso unitario entra mitad y mitad en la pareja de nudos del ancho de la franja:
q_1 = 0.5
q_2 = 0.5
q_tot = dec(q_1 + q_2, 1)
