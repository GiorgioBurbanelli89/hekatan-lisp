# Dinámica de estructuras, clase 3: del modelo de clase al edificio real — la masa, el tipo de losa y el tiempo-historia
#numerico

#: **Qué se hace.** Las clases 1 y 2 (hojas 108 y 109) dejaron dos números por modo: la masa m y la rigidez k. Esta clase dice **de dónde salen en un edificio real** y **qué los cambia**: la fuente de masa, la losa repartida a nudos, la masa vertical y el tipo de losa. No los desarrolla: cada tema tiene su hoja o su estudio, citados en cada sección. Cierra con el tiempo-historia.
#: **Fuentes.** NEC-SE-DS 2015 §6.1.7 (pág. 55: W = D). Chopra, *Dinámica de Estructuras*, 4.ª ed., ec. 13.1.1 y 13.1.2 (sismo como carga efectiva −m·ι·ü_{g}). CSI Analysis Reference Manual §10.8 a §10.11 (espesores, modificadores y masa del shell; leídos en la bitácora «Losa WAFFLE: qué es en SAP2000, qué es en ETABS» de la carpeta registros, 18-sep-2026).
#: **Unidades.** tonf, m, s.

## 1 · Todo se resume en T = 2·π·√(m/k)

#: Lo que cambie un modelo (más masa, una losa que rigidiza) se lee en el periodo con esta fórmula, modo a modo. Con factores f_{m} sobre la masa y f_{k} sobre la rigidez:
#: **T = T₁·√(f_{m}/f_{k})**   →   log T = ½·log f_{m} − ½·log f_{k} + log T₁
#: Otra vez y = m·x + b: pendiente **+½** para la masa y **−½** para la rigidez.
T_1 = 0.272179 'periodo fundamental del edificio de 3 pisos de la clase 2 [s]
f_m = 1.25 'ejemplo: un 25 % más de masa (acabados o tabiques más pesados)
f_k = 1.5 'ejemplo: un 50 % más de rigidez lateral (una losa que trabaja con las vigas)
T_m = T_1·sqrt(f_m) 'solo más masa: el periodo SUBE [s]
T_k = T_1/sqrt(f_k) 'solo más rigidez: el periodo BAJA [s]
T_mk = T_1·sqrt(f_m/f_k) 'las dos a la vez [s]
#: El periodo en función de los dos factores (x: f_{m}; y: f_{k}; altura: T en s):
#surf(0.272179*sqrt(x/y), [0.5 2], [0.5 2])
#: Cortes de esa superficie: T contra f_{m} para la rigidez original, ×1.5 y ×2 (eje horizontal: f_{m}; vertical: T en s):
#fplot(k_x1 = 0.272179*sqrt(x), k_x15 = 0.272179*sqrt(x/1.5), k_x2 = 0.272179*sqrt(x/2), [0.5 2])

## 2 · De dónde sale m en un edificio real

#: **La fuente de masa (Mass Source).** La NEC-15 §6.1.7 (pág. 55) fija la **carga sísmica reactiva W = D**, la carga muerta total (bodegas y almacenaje: W = D + 0.25·L_{i}). La masa es W/g. En ETABS y SAP2000 eso se declara en el *Mass Source*: de qué patrones de carga y con qué factor sale la masa.
#: **La losa repartida a nudos.** Un programa de elementos finitos no guarda «la masa de la losa»: cada elemento reparte la suya a sus nudos (masa concentrada por área tributaria). Para la traslación da igual (la suma es la misma), pero **para el giro no**: el momento polar J = Σ m_{i}·r_{i}² depende de dónde quedan las masas. Para una losa a × b partida en n × n elementos, la regla del trapecio da exactamente:
#: J_{n} = m·(a² + b²)/12 · (1 + 2/n²)
a_l = 6 'lado de la losa en X [m]
b_l = 6 'lado de la losa en Y [m]
m_l = 36/9.80665 'masa de la losa de 36 tonf [tonf·s²/m]
J_ex = m_l·(a_l^2 + b_l^2)/12 'momento polar de la losa continua [tonf·s²·m]
#: Comprobación con las masas puestas nudo a nudo (malla de 4 × 4 elementos, 25 nudos, cada nudo con su área tributaria):
#hide
n_e = 4
J_4 = 0
#show
for i = 0:n_e
  for j = 0:n_e
    w_i = 0.5 + 0.5·min(i, 1)·min(n_e - i, 1)
    w_j = 0.5 + 0.5·min(j, 1)·min(n_e - j, 1)
    J_4 = J_4 + m_l/n_e^2·w_i·w_j·((a_l·i/n_e - a_l/2)^2 + (b_l·j/n_e - b_l/2)^2)
  end
end
J_4n = J_4 'J sumando los 25 nudos [tonf·s²·m]
J_4f = J_ex·(1 + 2/n_e^2) 'J con la fórmula, n = 4 [tonf·s²·m]
r_J1 = sqrt(1 + 2/1^2) 'cuánto se alarga el periodo de giro con 1 solo elemento por losa (masa en las 4 esquinas)
#: Con un solo elemento por losa la masa queda en las esquinas: J sale **3 veces** el real y el periodo de giro **√3 = 1.73 veces** más largo. Con 4 × 4 el error baja a 12.5 % en J. Eje horizontal: n elementos por lado; vertical: J_{n}/J:
#fplot(J_rel = 1 + 2/x^2, [1 10])
#: **Con o sin masa vertical.** ETABS, por defecto, solo da masa horizontal a los nudos; SAP2000 da masa en las tres direcciones. Eso mueve la columna U_{z} de las sumatorias (clase 2) y puede cambiar el orden de los modos. **Se desarrolla en la hoja 107** (cómo se reparte la masa para el sismo: masa 3D contra solo horizontal), bitácora «Hoja Hekatan LISP: cómo se reparte la masa para el sismo» (carpeta registros, 4-oct-2026).

## 3 · Qué cambia cada tipo de losa en m y en k

#| Losa | Rigidez que aporta | Masa | T |
#|---|---|---|---|
#| **Membrana** | solo en su plano (diafragma); a flexión cero | su peso | el más largo |
#| **Shell Thin** | en su plano **y** a flexión: trabaja con las vigas | su peso | más corto |
#| **Slab 1 dirección** | en ETABS, un reparto de carga a vigas de una dirección | misma total, otro reparto | casi igual |
#| **Slab 2 direcciones** | reparto a vigas de las dos direcciones | misma total | casi igual |
#| **Waffle** | loseta + nervios; en el análisis, shell con modificadores | **menos** que maciza | baja |
#| **Deck** | lámina de acero + hormigón: ortótropa, diafragma en su plano | lámina + relleno | cerca de membrana |

#: La tabla dice **hacia dónde** se mueve T, no cuánto. **Cuánto** lo mide el estudio de tiempo-historia con el mismo pórtico 3D y las seis losas (Shell Thin, Membrana, Slab 1 y 2 direcciones, Waffle y Deck), con modos 1-3, las seis sumatorias, techo, cortante basal y deriva: bitácora «Pórtico 3D con losa: tiempo-historia y tipo de losa» (carpeta registros, 4-oct-2026).
#: La membrana en ETABS y SAP2000 (a qué reparte la carga y qué masa da al modal) está en la **hoja 64**; el diafragma rígido contra el flexible, en la **hoja 102**.

## 4 · El tiempo-historia: ver el edificio moverse segundo a segundo

#: El espectro (vídeo cpp06, hoja 101) da **el máximo** de cada modo y los combina. El tiempo-historia resuelve la ecuación **instante a instante** con un registro real.
#: **El sismo como carga, deducido.** El suelo se mueve u_{g}(t). La fuerza en las columnas depende de cuánto se deforman respecto al suelo (u), pero la inercia depende del movimiento total u + u_{g}:
#: m·(ü + ü_{g}) + c·u̇ + k·u = 0   →   **m·ü + c·u̇ + k·u = −m·ü_{g}(t)**
#: El sismo entra como una fuerza −m·ü_{g}: **por eso la masa manda**. En varios pisos es −M·ι·ü_{g} (Chopra ec. 13.1.2), con ι = r, el mismo vector de la clase 2.
#: **Un ejemplo que se hace a mano:** el pórtico de 1 piso de la clase 1 con un suelo que vibra en armónico a su mismo periodo (resonancia), 0.10 g de amplitud. Lo estático equivalente es p₀/k = m·a_{g}/k = a_{g}/ω²:
omega_1 = 49.011586 'pórtico de 1 piso, clase 1 [rad/s]
a_g = 0.10·9.80665 'amplitud de la aceleración del suelo, 0.10 g [m/s²]
u_st = a_g/omega_1^2 'desplazamiento estático equivalente [m]
u_max = u_st/(2·0.05) 'tope en resonancia con ξ = 5 %, Chopra ec. 3.2.7 [m]
u_mm = 1000·u_max 'el mismo en mm
d_r = u_max/3 'deriva de piso, sobre 3 m de altura
#: 4 mm y una deriva elástica de 0.14 %. Solo como orden de magnitud: la NEC-15 (§4.2.2, Tabla 7, pág. 40) limita a 0.02 la deriva **inelástica** ante el sismo de diseño, que es otro cálculo (vídeo de derivas). El pórtico es rígido. La columna, segundo a segundo (eje horizontal: altura relativa z/h; vertical: desplazamiento en mm; cada fotograma avanza 0.02 s):
#anim fplot(u = 4.0825*(exp(-0.05*49.011586*0.02*n) - 1)*cos(49.011586*0.02*n)*(3*x^2 - 2*x^3), tope = 4.0825 + 0*x, fondo = -4.0825 + 0*x, [0 1]), n = 1:60
#: La forma 3·(z/h)² − 2·(z/h)³ es la de una columna empotrada abajo y con la losa sin giro arriba. La amplitud crece hacia el tope de 4.08 mm (la envolvente de la clase 1, sección 6).
#: **Con un registro real** (El Centro 1940 escalado a la NEC-15, Portoviejo) el mismo cálculo paso a paso está en la **hoja 100** (contra SAP2000: 0.004 % en 1559 pasos) y el método de Newmark en la **hoja 97** (columna de suelo contra Abaqus).

## 5 · Lo que hay que llevarse

#: 1 · **Más masa → T mayor** (con √m). La masa sale de W = D (NEC-15 §6.1.7) y la reparte el programa a los nudos.
#: 2 · **Losa que rigidiza → T menor** (con 1/√k). Shell Thin rigidiza más que membrana; waffle pesa menos.
#: 3 · **El giro depende de dónde queda la masa**: con una malla gruesa el periodo de torsión sale largo.
#: 4 · **El tiempo-historia** es la misma ecuación m·ü + c·u̇ + k·u, con −m·ü_{g}(t) a la derecha, resuelta cada Δt.
#: **Orden de estudio:** hoja 108 (1 GDL) → hoja 109 (modos) → hoja 110 (esta) → hoja 107 (masa sísmica) → estudio TH con losas → vídeo cpp06 (cortante modal espectral) → hoja 101 (combinación modal) → hoja 102 (diafragma) → hoja 100 (tiempo-historia con El Centro).
