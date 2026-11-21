# Ejemplo 6.10 de Braja Das, completo: excentricidad en dos sentidos

#: El ejemplo tal cual el libro, de la primera línea al resultado. Aquí no se resume nada: cada ecuación está con su número y cada número se vuelve a calcular.
#: **Ojo con la edición: el ejemplo cambia de número, y las ecuaciones también.** Es el mismo problema, los mismos datos y el mismo resultado, pero si se busca por el número equivocado no aparece:
#tabla("Libro","Ejemplo","Páginas","Figura","Tablas")({"Das, Principles of Foundation Engineering, 9.ª ed. (inglés, 2019)","Das, Fundamentos de ingeniería de cimentaciones, 7.ª ed. (español)"}; {"6.10","3.8"}; {"247-248","170-172"}; {"6.31","3.25"}; {"6.2 y 6.3","3.3 y 3.4"})
#: Y las ecuaciones, una por una:
#tabla("Qué calcula","En la 9.ª ed. inglesa","En la 7.ª ed. española")({"capacidad última q'_u","área efectiva A' (caso II)","ancho efectivo B' = A'/L'","largo efectivo L' = L_1","ábaco de L_1 y L_2"}; {"ec. 6.55","ec. 6.75","ec. 6.76","ec. 6.77","fig. 6.27b"}; {"ec. 3.40","ec. 3.58","ec. 3.59","ec. 3.60","fig. 3.21b"})
#: En esta hoja se citan **las dos numeraciones** en cada paso: primero la inglesa y, entre paréntesis, la española.
#: **El enunciado.** Zapata cuadrada, carga vertical con excentricidad en las DOS direcciones. Se pide la carga última.
B = 1.5 'lado corto de la zapata [m] ; L = 1.5 'lado largo de la zapata [m] ; D_f = 0.7 'desplante [m]
γ = 18 'peso unitario de la arena [kN/m³] ; φ = 30 'ángulo de fricción [°] ; c = 0 'cohesión [kPa]
e_L = 0.3 'excentricidad, dirección larga [m] ; e_B = 0.15 'excentricidad, dirección corta [m]

## 1 · La zapata del enunciado (figura 6.31 del libro)

#: Arriba el corte, con la arena y el desplante; abajo la planta, con el punto de aplicación de la resultante corrido en las dos direcciones.
#dibujo("Figura 6.31 inglesa = 3.25 española · cimentación cargada excéntricamente", ud = m, escala = 1:28, cotas = m, alto = 230)
#  linea(-0.35, 3.0, 2.15, 3.0, "media")
#  rect(0, 2.2, 1.5, 0.25, "gruesa")
#  achurado(0, 2.2, 1.5, 0.25, "diagonal")
#  rect(0.6, 2.45, 0.3, 0.95, "gruesa")
#  achurado(0.6, 2.45, 0.3, 0.95, "diagonal")
#  flecha(0.75, 3.95, 0.75, 3.46, "rojo")
#  texto(0.9, 3.8, "Q", 3, "i")
#  texto(0.75, 2.3, "1.5 × 1.5 m", 2.4, "c")
#  texto(1.75, 2.92, "Arena", 2.5, "i")
#  texto(1.75, 2.72, "γ = 18 kN/m³", 2.4, "i")
#  texto(1.75, 2.54, "φ' = 30°", 2.4, "i")
#  texto(1.75, 2.36, "c' = 0", 2.4, "i")
#  cota(-0.12, 2.2, -0.12, 3.0, 0.22, "D_{f} = 0.7")
#  linea(0.75, 2.2, 0.75, 1.75, "eje")
#  rect(0, 0, 1.5, 1.5, "gruesa")
#  linea(0.75, -0.25, 0.75, 1.75, "eje")
#  linea(-0.25, 0.75, 1.75, 0.75, "eje")
#  circulo(0.6, 1.05, 0.045)
#  circulo(0.6, 1.05, 0.022)
#  cota(0.6, 1.28, 0.75, 1.28, 0.1, "e_{B} = 0.15")
#  cota(0.95, 0.75, 0.95, 1.05, -0.12, "e_{L} = 0.30")
#  cota(0, -0.28, 1.5, -0.28, -0.12, "B = 1.50")
#  cota(-0.28, 0, -0.28, 1.5, 0.12, "L = 1.50")
#fin

## 2 · Las dos relaciones de excentricidad

#: El libro empieza por ahí, porque son las que eligen el caso del ábaco:
r_L = dec(0.3/1.5, 3) [-] 'excentricidad relativa, dirección larga
r_B = dec(0.15/1.5, 3) [-] 'excentricidad relativa, dirección corta
#: r_L = 0.2 y r_B = 0.1. Como r_L pasa de un sexto (0.167) y r_B no, la resultante sale del núcleo central en una dirección: **un borde se levanta**. Es el caso de la figura 6.27a inglesa, que es la 3.21a española.

## 2-bis · Qué es exactamente esa carga corrida

#: Aquí se atasca todo el mundo, y con razón: en la planta el punto de la carga aparece FUERA del eje de la columna, a veces incluso fuera de la sección de la columna. **Por ahí no baja nada.**
#: La carga axial baja por la columna, centrada en su sección, siempre. Lo que además baja es un MOMENTO. El libro podría haber escrito el enunciado con momentos en vez de excentricidades, y sería el mismo problema:
M_L = dec(606*0.3, 1) [kN·m] 'momento, dirección larga
M_B = dec(606*0.15, 1) [kN·m] 'momento, dirección corta
#: Es decir: «carga de 606 kN centrada, más 181.8 y 90.9 kN·m» es **exactamente** lo mismo que «carga de 606 kN corrida 0.30 y 0.15 m». Se elige la segunda forma porque se dibuja y se reparte más fácil.
#: Entonces la flecha corrida **no es una carga: es la RESULTANTE**, el punto por el que pasa la suma de la carga centrada y el momento. Como no hay nada aplicado ahí, puede caer fuera de la sección de la columna sin que eso signifique nada raro: con 0.30 m de excentricidad y una columna de 0.30 m, cae justo en su borde.
#: **Y la trampa está en la letra.** En los dos dibujos la flecha se rotula igual, con la misma letra de la carga axial, y eso hace pensar que hay DOS cargas: una en la columna y otra fuera. **No hay dos: hay una sola, y es la misma.** Mismo valor, misma dirección vertical; lo único distinto es dónde se traza su línea de acción.
#tabla("Cómo se dibuja","Fuerza vertical [kN]:0","Momento respecto al centro [kN·m]:1")({"carga axial en el eje de la columna, más el momento","la MISMA carga axial, corrida 0.30 m"}; [606, 606]; [181.8, 181.8])
#: Las dos filas son el mismo sistema de fuerzas: misma suma vertical y mismo momento. Por eso se puede usar la misma letra. Cuando se ve la carga corrida no se está viendo otra fuerza puesta fuera de la columna: es **la carga axial de siempre, dibujada donde hay que dibujarla para no tener que dibujar el momento aparte**.
#: Lo que sí significa algo es hasta dónde llega esa resultante:
e_nucleo = dec(1.5/6, 3) [m] 'límite del núcleo central
e_vuelco = dec(1.5/2, 3) [m] 'medio lado de la zapata
#: Con 0.30 m se pasa del núcleo (0.25 m) y **un borde se despega**; para volcar harían falta 0.75 m. Por eso este ejemplo es no lineal pero no es inestable.

#: **Y cuando la dibujan fuera de la columna, ¿qué cambia?** Nada de concepto: solo que el momento es mayor. La resultante no se coloca, se CALCULA: es el momento dividido para la carga. Si el momento crece, el cociente crece y el punto se aleja. Estas son las tres distancias que importan, medidas desde el centro:
#dibujo("Hasta dónde puede llegar la resultante (medido desde el centro)", ud = m, escala = 1:18, cotas = m, alto = 150)
#  rect(0, 0, 1.5, 0.3, "gruesa")
#  achurado(0, 0, 1.5, 0.3, "diagonal")
#  rect(0.6, 0.3, 0.3, 0.75, "gruesa")
#  achurado(0.6, 0.3, 0.3, 0.75, "diagonal")
#  linea(0.75, -0.75, 0.75, 1.45, "eje")
#  linea(0.9, 1.15, 0.9, 1.4, "media")
#  linea(1.0, 1.15, 1.0, 1.4, "media")
#  linea(1.5, 1.15, 1.5, 1.4, "media")
#  cota(0.75, 1.32, 0.9, 1.32, 0.1, "0.15 · borde de la columna")
#  cota(0.75, -0.30, 1.0, -0.30, -0.1, "0.25 · núcleo central, B/6")
#  cota(0.75, -0.62, 1.5, -0.62, -0.1, "0.75 · borde de la zapata, B/2")
#  flecha(1.05, 1.62, 1.05, 1.12, "rojo")
#  texto(1.2, 1.55, "la resultante de este ejemplo: 0.30", 2.3, "i")
#fin
#: Con 0.30 m la resultante ya pasó el borde de la columna (0.15) **y** el del núcleo (0.25), pero está lejos del borde de la zapata (0.75). Traducido: hay despegue, no hay vuelco. Pasar el borde de la columna no tiene ninguna consecuencia estructural; pasar el del núcleo sí, y pasar el de la zapata es la ruina.

## 3 · El ábaco: L₁ y L₂ (ecs. 6.75 a 6.77 inglesas = 3.58 a 3.60 españolas)

#: Con esas dos relaciones, la figura 6.27b inglesa (3.21b española) da los dos lados del trapecio que trabaja. El libro lee L₁/L ≈ 0.85 y L₂/L ≈ 0.21:
L_1 = dec(0.85*1.5, 4) [m] 'lado largo del trapecio
L_2 = dec(0.21*1.5, 4) [m] 'lado corto del trapecio
#: **Ecuación 6.75 (española 3.58)**, el área efectiva: el trapecio de bases L₁ y L₂ y altura B.
A_ef = dec(0.5*(1.275 + 0.315)*1.5, 4) [m^2]
#: **Ecuación 6.77 (española 3.60)**, el largo efectivo es el lado mayor del trapecio; y **ecuación 6.76 (española 3.59)**, el ancho efectivo sale de dividir el área entre ese largo:
L_ef = 1.275 [m] 'largo efectivo
B_ef = dec(1.193/1.275, 4) [m] 'ancho efectivo
#: A' = 1.193 m², L' = 1.275 m y B' = 0.936 m: los tres números del libro.
#: El trapecio, dibujado sobre la zapata. La parte rayada es la que el cálculo de capacidad cuenta; la de abajo, no.
#dibujo("El área efectiva A' del caso II (ec. 6.75)", ud = m, escala = 1:20, cotas = m, alto = 150)
#  poligono(0, 1.5, 1.5, 1.5, 1.5, 0.225, 0, 1.185, "azul")
#  linea(0.15, 1.5, 0.15, 1.153, "azul")
#  linea(0.35, 1.5, 0.35, 1.025, "azul")
#  linea(0.55, 1.5, 0.55, 0.897, "azul")
#  linea(0.75, 1.5, 0.75, 0.769, "azul")
#  linea(0.95, 1.5, 0.95, 0.641, "azul")
#  linea(1.15, 1.5, 1.15, 0.513, "azul")
#  linea(1.35, 1.5, 1.35, 0.385, "azul")
#  rect(0, 0, 1.5, 1.5, "gruesa")
#  linea(0.75, -0.2, 0.75, 1.7, "eje")
#  linea(-0.2, 0.75, 1.7, 0.75, "eje")
#  circulo(0.6, 1.05, 0.04)
#  circulo(0.6, 1.05, 0.018)
#  texto(0.66, 1.14, "Q", 2.8, "i")
#  cota(1.5, 0.225, 1.5, 1.5, -0.28, "L_{1} = 1.275")
#  cota(0, 1.185, 0, 1.5, 0.28, "L_{2} = 0.315")
#  cota(0, -0.26, 1.5, -0.26, -0.12, "B = 1.50")
#  texto(0.75, 0.30, "esta parte NO cuenta", 2.3, "c")
#fin

## 4 · La sobrecarga y los factores de capacidad (tabla 6.2 inglesa = tabla 3.3 española)

#: La sobrecarga a la cota de apoyo es el peso de la tierra que quedó encima:
q_sob = dec(0.7*18, 1) [kPa] 'peso de la tierra encima
#: Para φ' = 30° la tabla 6.2 da N_q = 18.4 y N_γ = 22.4. No hace falta la tabla: salen de la solución de Reissner, con el ángulo en radianes.
φ_r = dec(30*pi/180, 4) [rad] '30° en radianes
N_q = dec(exp(pi*tan(0.5236))*tan(pi/4 + 0.5236/2)^2, 3) [-]
N_γ = dec(2*(18.401 + 1)*tan(0.5236), 3) [-]
#: 18.401 y 22.402 contra los 18.4 y 22.4 de la tabla.

## 5 · Los factores de forma y de profundidad (tabla 6.3 inglesa = tabla 3.4 española)

#: Los de FORMA llevan la relación de lados EFECTIVOS, porque la zapata que falla es la efectiva. El de PROFUNDIDAD lleva la B real, porque la cuña arranca del ancho verdadero. Y el de profundidad del término de peso propio vale uno:
F_qs = dec(1 + (0.936/1.275)*tan(0.5236), 3) [-] 'ec. 6.56
F_γs = dec(1 - 0.4*(0.936/1.275), 3) [-] 'ec. 6.57
F_qd = dec(1 + 2*tan(0.5236)*(1 - sin(0.5236))^2*0.7/1.5, 3) [-] 'ec. 6.60
F_γd = 1 [-] 'ec. 6.61
#: 1.424, 0.706 y 1.135: los tres del libro.

## 6 · La capacidad última (ec. 6.55 inglesa = ec. 3.40 española, con c' = 0)

#: Con la cohesión nula, el primer sumando desaparece y quedan la sobrecarga y el peso propio del suelo. La presión última sobre el área efectiva:
q_u = dec(12.6*18.4*1.424*1.135 + 0.5*18*0.936*22.4*0.706, 1) [kPa]
#: Y la carga última es esa presión por el área que trabaja:
Q_u = dec(1.193*508.0, 0) [kN]
#: **606 kN**, el resultado del libro. El primer sumando aporta 374.5 kPa y el segundo 133.4: **tres cuartas partes vienen de estar enterrada 0.7 m**, no del suelo de debajo.

## 7 · Lo que el libro no dice, y esta hoja sí

#: Todo lo anterior es CAPACIDAD DE CARGA: si el suelo revienta o no. Nada de eso dice cómo se reparte la presión bajo la zapata en servicio, que es lo que arma el hormigón.
#: Para eso hay que resolver el contacto: la zapata sobre muelles que solo trabajan a compresión. Con el mismo modelo, Hekatan Struct, SAP2000, SAFE, ETABS y OpenSees dan **81.915 tonf/m²** en la esquina cargada, con 798 de 961 nudos tocando el suelo. Si se deja que el suelo tire, el cálculo lineal da **76.670**: un 6.4 % menos, del lado inseguro.
#: La deducción de esa parte está en la hoja 48; de dónde sale el módulo de balasto y por qué la presión se puede repartir con una recta, en la hoja 54; y por qué la carga se dibuja desplazada, en la 56.
