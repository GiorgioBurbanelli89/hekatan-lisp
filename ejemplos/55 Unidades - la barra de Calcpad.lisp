# Unidades: la barra dice en qué quieres VER el resultado

#: Se escribe la cantidad con su unidad pegada y, después de la barra, la unidad en la que se quiere leer: **`3m|cm`**. La conversión y la comprobación de dimensiones las hace el motor, no la hoja.
L = 3m|cm
e = 2.5in|mm
t = 1.5h|min

## De dónde sale cada unidad

#: Las bases (kg, m, s, A, K, mol, cd, rad) valen 1 y las demás son su FÓRMULA física: el newton es m·kg/s², el pascal es N/m², el joule es N·m. Los prefijos son funciones: kilo, centi, mili. Así no hay tabla de factores que mantener, y una unidad compuesta se arma sola:
F = 2.5MN|kgf
P = 30kW*2h|kJ

## El caso de la zapata (hojas 48 y 54)

#: La carga última del ejemplo 3.8 de Braja Das repartida en su área efectiva, leída en las tres unidades con las que se trabaja: la del libro, la del estudio de suelos y la del hormigón.
q = 606kN/1.193m^2|kPa
q_t = 606kN/1.193m^2|tonf/m2
q_c = 606kN/1.193m^2|kgf/cm2
#: Y el módulo de balasto que usó el modelo de elementos finitos, pasado del sistema de obra al SI:
k_s = 2000tonf/m^3|kN/m^3

## Lo que NO deja hacer

#: Si las dimensiones no cuadran, avisa en vez de dar un número que parece bueno. Sumar metros con segundos no significa nada, y pedir una longitud en segundos tampoco:
mal = 3m+2s|m
mal_2 = 3m|s

## En una línea

#: Una cantidad se guarda como número y ocho exponentes (masa, longitud, tiempo, corriente, temperatura, sustancia, luminosidad, ángulo). Multiplicar suma exponentes, dividir los resta, y sumar exige que sean los mismos: de ahí salen tanto la conversión como el aviso.
