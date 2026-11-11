# Un talud como lo hace GeoFEM: de la malla al factor de seguridad (contra GEO5)
#numerico
#: **GeoFEM no resuelve un bloque: resuelve un TALUD.** Esta hoja sigue el camino real de GEO5 (FRGeoFEM 2024) para un talud: **malla de T6 → etapa 1 (peso propio) → etapa 2 (reducción de resistencia por escalones) → factor de seguridad**. Los elementos T6, la matriz B, la matriz D, la cuadratura y el retorno de Mohr-Coulomb son los de la hoja anterior («Los elementos finitos de Hekatan Geotechnic paso a paso»); aquí se ve cómo se usan en un talud.
#: **Los números vienen del solver real de GEO5.** El talud se corrió en GEO5 y en Geotechnic con la **misma malla** (275 nudos, 120 T6); los registros de las dos escaleras de escalones se comparan aquí. Como en la otra hoja, **primero van las operaciones simbólicas y después las numéricas.**

## 1 · El talud y su malla
#: En símbolos. La altura del talud es la diferencia de cotas entre la corona y el pie, y su ángulo sale de la altura y el avance horizontal:
H_s = Simplify{zc - zp}
beta_s = Simplify{atan((zc - zp)/(xc - xp))}
#: **Mira la Figura 1:** el talud con su malla de 120 T6, sus apoyos y sus cargas. GEO5 y Geotechnic recibieron exactamente esta malla.
#dibujo("Figura 1. El talud y su malla: 275 nudos y 120 elementos T6 (12 × 5 columnas; cada celda son 2 triángulos de 6 nudos). Es la MISMA malla que se le dio a GEO5", ud = m, ancho = 200, alto = 100)
#  poligono([0, 45, 45, 21.0091, 11, 0, 0], [-24, -24, -2.5, -2.5, -9, -9, -24], "azul tenue")
#  polilinea([0, 3.75, 3.75, 0], [-24, -24, -21, -24], "fina")
#  polilinea([0, 3.75, 0, 0], [-24, -21, -21, -24], "fina")
#  polilinea([0, 3.75, 3.75, 0], [-21, -21, -18, -21], "fina")
#  polilinea([0, 3.75, 0, 0], [-21, -18, -18, -21], "fina")
#  polilinea([0, 3.75, 3.75, 0], [-18, -18, -15, -18], "fina")
#  polilinea([0, 3.75, 0, 0], [-18, -15, -15, -18], "fina")
#  polilinea([0, 3.75, 3.75, 0], [-15, -15, -12, -15], "fina")
#  polilinea([0, 3.75, 0, 0], [-15, -12, -12, -15], "fina")
#  polilinea([0, 3.75, 3.75, 0], [-12, -12, -9, -12], "fina")
#  polilinea([0, 3.75, 0, 0], [-12, -9, -9, -12], "fina")
#  polilinea([3.75, 7.5, 7.5, 3.75], [-24, -24, -21, -24], "fina")
#  polilinea([3.75, 7.5, 3.75, 3.75], [-24, -21, -21, -24], "fina")
#  polilinea([3.75, 7.5, 7.5, 3.75], [-21, -21, -18, -21], "fina")
#  polilinea([3.75, 7.5, 3.75, 3.75], [-21, -18, -18, -21], "fina")
#  polilinea([3.75, 7.5, 7.5, 3.75], [-18, -18, -15, -18], "fina")
#  polilinea([3.75, 7.5, 3.75, 3.75], [-18, -15, -15, -18], "fina")
#  polilinea([3.75, 7.5, 7.5, 3.75], [-15, -15, -12, -15], "fina")
#  polilinea([3.75, 7.5, 3.75, 3.75], [-15, -12, -12, -15], "fina")
#  polilinea([3.75, 7.5, 7.5, 3.75], [-12, -12, -9, -12], "fina")
#  polilinea([3.75, 7.5, 3.75, 3.75], [-12, -9, -9, -12], "fina")
#  polilinea([7.5, 11.25, 11.25, 7.5], [-24, -24, -20.9675, -24], "fina")
#  polilinea([7.5, 11.25, 7.5, 7.5], [-24, -20.9675, -21, -24], "fina")
#  polilinea([7.5, 11.25, 11.25, 7.5], [-21, -20.9675, -17.9351, -21], "fina")
#  polilinea([7.5, 11.25, 7.5, 7.5], [-21, -17.9351, -18, -21], "fina")
#  polilinea([7.5, 11.25, 11.25, 7.5], [-18, -17.9351, -14.9026, -18], "fina")
#  polilinea([7.5, 11.25, 7.5, 7.5], [-18, -14.9026, -15, -18], "fina")
#  polilinea([7.5, 11.25, 11.25, 7.5], [-15, -14.9026, -11.8701, -15], "fina")
#  polilinea([7.5, 11.25, 7.5, 7.5], [-15, -11.8701, -12, -15], "fina")
#  polilinea([7.5, 11.25, 11.25, 7.5], [-12, -11.8701, -8.8376, -12], "fina")
#  polilinea([7.5, 11.25, 7.5, 7.5], [-12, -8.8376, -9, -12], "fina")
#  polilinea([11.25, 15, 15, 11.25], [-24, -24, -20.4805, -24], "fina")
#  polilinea([11.25, 15, 11.25, 11.25], [-24, -20.4805, -20.9675, -24], "fina")
#  polilinea([11.25, 15, 15, 11.25], [-20.9675, -20.4805, -16.961, -20.9675], "fina")
#  polilinea([11.25, 15, 11.25, 11.25], [-20.9675, -16.961, -17.9351, -20.9675], "fina")
#  polilinea([11.25, 15, 15, 11.25], [-17.9351, -16.961, -13.4414, -17.9351], "fina")
#  polilinea([11.25, 15, 11.25, 11.25], [-17.9351, -13.4414, -14.9026, -17.9351], "fina")
#  polilinea([11.25, 15, 15, 11.25], [-14.9026, -13.4414, -9.9219, -14.9026], "fina")
#  polilinea([11.25, 15, 11.25, 11.25], [-14.9026, -9.9219, -11.8701, -14.9026], "fina")
#  polilinea([11.25, 15, 15, 11.25], [-11.8701, -9.9219, -6.4024, -11.8701], "fina")
#  polilinea([11.25, 15, 11.25, 11.25], [-11.8701, -6.4024, -8.8376, -11.8701], "fina")
#  polilinea([15, 18.75, 18.75, 15], [-24, -24, -19.9934, -24], "fina")
#  polilinea([15, 18.75, 15, 15], [-24, -19.9934, -20.4805, -24], "fina")
#  polilinea([15, 18.75, 18.75, 15], [-20.4805, -19.9934, -15.9868, -20.4805], "fina")
#  polilinea([15, 18.75, 15, 15], [-20.4805, -15.9868, -16.961, -20.4805], "fina")
#  polilinea([15, 18.75, 18.75, 15], [-16.961, -15.9868, -11.9802, -16.961], "fina")
#  polilinea([15, 18.75, 15, 15], [-16.961, -11.9802, -13.4414, -16.961], "fina")
#  polilinea([15, 18.75, 18.75, 15], [-13.4414, -11.9802, -7.9737, -13.4414], "fina")
#  polilinea([15, 18.75, 15, 15], [-13.4414, -7.9737, -9.9219, -13.4414], "fina")
#  polilinea([15, 18.75, 18.75, 15], [-9.9219, -7.9737, -3.9671, -9.9219], "fina")
#  polilinea([15, 18.75, 15, 15], [-9.9219, -3.9671, -6.4024, -9.9219], "fina")
#  polilinea([18.75, 22.5, 22.5, 18.75], [-24, -24, -19.7, -24], "fina")
#  polilinea([18.75, 22.5, 18.75, 18.75], [-24, -19.7, -19.9934, -24], "fina")
#  polilinea([18.75, 22.5, 22.5, 18.75], [-19.9934, -19.7, -15.4, -19.9934], "fina")
#  polilinea([18.75, 22.5, 18.75, 18.75], [-19.9934, -15.4, -15.9868, -19.9934], "fina")
#  polilinea([18.75, 22.5, 22.5, 18.75], [-15.9868, -15.4, -11.1, -15.9868], "fina")
#  polilinea([18.75, 22.5, 18.75, 18.75], [-15.9868, -11.1, -11.9802, -15.9868], "fina")
#  polilinea([18.75, 22.5, 22.5, 18.75], [-11.9802, -11.1, -6.8, -11.9802], "fina")
#  polilinea([18.75, 22.5, 18.75, 18.75], [-11.9802, -6.8, -7.9737, -11.9802], "fina")
#  polilinea([18.75, 22.5, 22.5, 18.75], [-7.9737, -6.8, -2.5, -7.9737], "fina")
#  polilinea([18.75, 22.5, 18.75, 18.75], [-7.9737, -2.5, -3.9671, -7.9737], "fina")
#  polilinea([22.5, 26.25, 26.25, 22.5], [-24, -24, -19.7, -24], "fina")
#  polilinea([22.5, 26.25, 22.5, 22.5], [-24, -19.7, -19.7, -24], "fina")
#  polilinea([22.5, 26.25, 26.25, 22.5], [-19.7, -19.7, -15.4, -19.7], "fina")
#  polilinea([22.5, 26.25, 22.5, 22.5], [-19.7, -15.4, -15.4, -19.7], "fina")
#  polilinea([22.5, 26.25, 26.25, 22.5], [-15.4, -15.4, -11.1, -15.4], "fina")
#  polilinea([22.5, 26.25, 22.5, 22.5], [-15.4, -11.1, -11.1, -15.4], "fina")
#  polilinea([22.5, 26.25, 26.25, 22.5], [-11.1, -11.1, -6.8, -11.1], "fina")
#  polilinea([22.5, 26.25, 22.5, 22.5], [-11.1, -6.8, -6.8, -11.1], "fina")
#  polilinea([22.5, 26.25, 26.25, 22.5], [-6.8, -6.8, -2.5, -6.8], "fina")
#  polilinea([22.5, 26.25, 22.5, 22.5], [-6.8, -2.5, -2.5, -6.8], "fina")
#  polilinea([26.25, 30, 30, 26.25], [-24, -24, -19.7, -24], "fina")
#  polilinea([26.25, 30, 26.25, 26.25], [-24, -19.7, -19.7, -24], "fina")
#  polilinea([26.25, 30, 30, 26.25], [-19.7, -19.7, -15.4, -19.7], "fina")
#  polilinea([26.25, 30, 26.25, 26.25], [-19.7, -15.4, -15.4, -19.7], "fina")
#  polilinea([26.25, 30, 30, 26.25], [-15.4, -15.4, -11.1, -15.4], "fina")
#  polilinea([26.25, 30, 26.25, 26.25], [-15.4, -11.1, -11.1, -15.4], "fina")
#  polilinea([26.25, 30, 30, 26.25], [-11.1, -11.1, -6.8, -11.1], "fina")
#  polilinea([26.25, 30, 26.25, 26.25], [-11.1, -6.8, -6.8, -11.1], "fina")
#  polilinea([26.25, 30, 30, 26.25], [-6.8, -6.8, -2.5, -6.8], "fina")
#  polilinea([26.25, 30, 26.25, 26.25], [-6.8, -2.5, -2.5, -6.8], "fina")
#  polilinea([30, 33.75, 33.75, 30], [-24, -24, -19.7, -24], "fina")
#  polilinea([30, 33.75, 30, 30], [-24, -19.7, -19.7, -24], "fina")
#  polilinea([30, 33.75, 33.75, 30], [-19.7, -19.7, -15.4, -19.7], "fina")
#  polilinea([30, 33.75, 30, 30], [-19.7, -15.4, -15.4, -19.7], "fina")
#  polilinea([30, 33.75, 33.75, 30], [-15.4, -15.4, -11.1, -15.4], "fina")
#  polilinea([30, 33.75, 30, 30], [-15.4, -11.1, -11.1, -15.4], "fina")
#  polilinea([30, 33.75, 33.75, 30], [-11.1, -11.1, -6.8, -11.1], "fina")
#  polilinea([30, 33.75, 30, 30], [-11.1, -6.8, -6.8, -11.1], "fina")
#  polilinea([30, 33.75, 33.75, 30], [-6.8, -6.8, -2.5, -6.8], "fina")
#  polilinea([30, 33.75, 30, 30], [-6.8, -2.5, -2.5, -6.8], "fina")
#  polilinea([33.75, 37.5, 37.5, 33.75], [-24, -24, -19.7, -24], "fina")
#  polilinea([33.75, 37.5, 33.75, 33.75], [-24, -19.7, -19.7, -24], "fina")
#  polilinea([33.75, 37.5, 37.5, 33.75], [-19.7, -19.7, -15.4, -19.7], "fina")
#  polilinea([33.75, 37.5, 33.75, 33.75], [-19.7, -15.4, -15.4, -19.7], "fina")
#  polilinea([33.75, 37.5, 37.5, 33.75], [-15.4, -15.4, -11.1, -15.4], "fina")
#  polilinea([33.75, 37.5, 33.75, 33.75], [-15.4, -11.1, -11.1, -15.4], "fina")
#  polilinea([33.75, 37.5, 37.5, 33.75], [-11.1, -11.1, -6.8, -11.1], "fina")
#  polilinea([33.75, 37.5, 33.75, 33.75], [-11.1, -6.8, -6.8, -11.1], "fina")
#  polilinea([33.75, 37.5, 37.5, 33.75], [-6.8, -6.8, -2.5, -6.8], "fina")
#  polilinea([33.75, 37.5, 33.75, 33.75], [-6.8, -2.5, -2.5, -6.8], "fina")
#  polilinea([37.5, 41.25, 41.25, 37.5], [-24, -24, -19.7, -24], "fina")
#  polilinea([37.5, 41.25, 37.5, 37.5], [-24, -19.7, -19.7, -24], "fina")
#  polilinea([37.5, 41.25, 41.25, 37.5], [-19.7, -19.7, -15.4, -19.7], "fina")
#  polilinea([37.5, 41.25, 37.5, 37.5], [-19.7, -15.4, -15.4, -19.7], "fina")
#  polilinea([37.5, 41.25, 41.25, 37.5], [-15.4, -15.4, -11.1, -15.4], "fina")
#  polilinea([37.5, 41.25, 37.5, 37.5], [-15.4, -11.1, -11.1, -15.4], "fina")
#  polilinea([37.5, 41.25, 41.25, 37.5], [-11.1, -11.1, -6.8, -11.1], "fina")
#  polilinea([37.5, 41.25, 37.5, 37.5], [-11.1, -6.8, -6.8, -11.1], "fina")
#  polilinea([37.5, 41.25, 41.25, 37.5], [-6.8, -6.8, -2.5, -6.8], "fina")
#  polilinea([37.5, 41.25, 37.5, 37.5], [-6.8, -2.5, -2.5, -6.8], "fina")
#  polilinea([41.25, 45, 45, 41.25], [-24, -24, -19.7, -24], "fina")
#  polilinea([41.25, 45, 41.25, 41.25], [-24, -19.7, -19.7, -24], "fina")
#  polilinea([41.25, 45, 45, 41.25], [-19.7, -19.7, -15.4, -19.7], "fina")
#  polilinea([41.25, 45, 41.25, 41.25], [-19.7, -15.4, -15.4, -19.7], "fina")
#  polilinea([41.25, 45, 45, 41.25], [-15.4, -15.4, -11.1, -15.4], "fina")
#  polilinea([41.25, 45, 41.25, 41.25], [-15.4, -11.1, -11.1, -15.4], "fina")
#  polilinea([41.25, 45, 45, 41.25], [-11.1, -11.1, -6.8, -11.1], "fina")
#  polilinea([41.25, 45, 41.25, 41.25], [-11.1, -6.8, -6.8, -11.1], "fina")
#  polilinea([41.25, 45, 45, 41.25], [-6.8, -6.8, -2.5, -6.8], "fina")
#  polilinea([41.25, 45, 41.25, 41.25], [-6.8, -2.5, -2.5, -6.8], "fina")
#  polilinea([0, 45, 45, 21.0091, 11, 0, 0], [-24, -24, -2.5, -2.5, -9, -9, -24], "gruesa")
#  achurado(-1.5, -25.4, 48, 1.4, "terreno")
#  texto(5.5, -4.2, "talud:  H = 6.5 m,  β = 33°", 2.8, "c", estilo = "rojo")
#  cota(9.4, -9, 9.4, -2.5, 0, "H = 6.5 m")
#  texto(30, -0.6, "superficie plana", 2.6, "c")
#  flecha(26, 0.2, 26, -1.9, "rojo")
#  flecha(30, 0.2, 30, -1.9, "rojo")
#  flecha(34, 0.2, 34, -1.9, "rojo")
#  texto(38.5, -0.6, "peso propio  γ = 18 kN/m³", 2.6, "i", estilo = "rojo")
#  texto(22.5, -27.4, "base fija (u = v = 0); en los lados solo se impide el movimiento horizontal (rodillos)", 2.6, "c")
#  cota(-1.5, -24, -1.5, -9, 0.6, "15 m")
#  cota(46.5, -24, 46.5, -2.5, -0.6, "21.5 m")
#  cota(11, -10.6, 21.0091, -10.6, 0, "10.0 m (pie a corona)")
#fin
#: Con números. Pie del talud en (11, −9), corona en (21.009, −2.5), suelo uniforme (Mohr-Coulomb en el modelo de GEO5):
x_p = 11 [m]
z_p = -9 [m]
x_c = 21.009122 [m]
z_c = -2.5 [m]
H_t = z_c - z_p [m]
beta_g = atan(H_t/(x_c - x_p))*180/pi 'ángulo del talud en grados
E_s = 60000 [kPa] 'módulo de elasticidad
ν = 0.3 'coeficiente de Poisson
γ = 18 [kN/m³] 'peso unitario
c = 12 [kPa] 'cohesión
phi_g = 28 'ángulo de fricción en grados
phi = phi_g*pi/180
n_nudos = 275 'nudos de la malla
n_T6 = 120 'elementos T6
n_gdl = 2*n_nudos 'grados de libertad (antes de los apoyos)

## 2 · Etapa 1: el peso propio
#: En símbolos. En la **primera etapa** GeoFEM carga el terreno con su propio peso y guarda el **estado de tensiones**; los desplazamientos de esta etapa se ponen en cero al terminar (solo cuentan los de las etapas siguientes). Lejos del talud, con terreno llano y los lados sin poder moverse en horizontal, la tensión vertical crece con la profundidad d y la horizontal es una fracción de ella:
sigy_s = Expand{-gam_m*d_m}
K0_s = Simplify{nu_m/(1 - nu_m)}
sigx_s = Expand{nu_m/(1 - nu_m)*(-gam_m*d_m)}
#: **Mira la Figura 2:** las dos tensiones en función de la profundidad (compresión negativa), para este suelo:
#dibujo("Figura 2. Tensiones del peso propio contra la profundidad (terreno llano): crecen en línea recta con z; la horizontal es K0 = 0.4286 de la vertical", ud = , ancho = 190, alto = 115)
#  flecha(0, 0.5, 0, -16.5, "negro")
#  texto(0, 1.4, "profundidad z [m]", 2.6, "c")
#  flecha(-0.5, 0, 17, 0, "negro")
#  texto(17.3, 0, "|σ| [kPa]", 2.6, "i")
#  linea(3.75, 0, 3.75, -15, "fina trazos")
#  texto(3.75, 1, "100", 2.4, "c")
#  linea(7.5, 0, 7.5, -15, "fina trazos")
#  texto(7.5, 1, "200", 2.4, "c")
#  linea(11.25, 0, 11.25, -15, "fina trazos")
#  texto(11.25, 1, "300", 2.4, "c")
#  linea(15, 0, 15, -15, "fina trazos")
#  texto(15, 1, "400", 2.4, "c")
#  linea(-0.4, -3.4884, 0, -3.4884, "media")
#  texto(-0.7, -3.8884, "5", 2.4, "d")
#  linea(-0.4, -6.9767, 0, -6.9767, "media")
#  texto(-0.7, -7.3767, "10", 2.4, "d")
#  linea(-0.4, -10.4651, 0, -10.4651, "media")
#  texto(-0.7, -10.8651, "15", 2.4, "d")
#  linea(-0.4, -13.9535, 0, -13.9535, "media")
#  texto(-0.7, -14.3535, "20", 2.4, "d")
#  polilinea([0, 14.5125], [0, -15], "media rojo")
#  polilinea([0, 6.2197], [0, -15], "media azul")
#  texto(7.95, -6.9767, "σy = −γ·z = −18 z (vertical)", 2.5, "i", estilo = "rojo")
#  texto(7.0198, -14.7, "σx = K0·σy (horizontal)", 2.5, "i", estilo = "azul")
#fin
#: Con números. Bajo el terreno llano de la derecha, a 21.5 m de profundidad (la base del modelo):
d_b = 21.5 [m]
K0 = ν/(1 - ν)
sig_y = -γ*d_b [kPa]
sig_x = K0*sig_y [kPa]

## 3 · Etapa 2: reducir la resistencia
#: En símbolos. El factor de seguridad es el número SRF por el que hay que dividir la resistencia para que el talud deje de ser estable. En cada escalón GeoFEM trabaja con un suelo **más débil**: cohesión c/SRF y ángulo de fricción φ_{F} tal que tanφ_{F} = tanφ/SRF.
cF_s = Simplify{c_m/SRF}
phiF_s = Simplify{atan(tan(phi_m)/SRF)}
#: Con números. El mismo suelo en cuatro escalones (el último es el factor de seguridad final de GEO5, 2.613848):
cF(F) = c/F
phiF(F) = atan(tan(phi)/F)*180/pi
c_1 = cF(1) [kPa]
c_2 = cF(1.5) [kPa]
c_3 = cF(2) [kPa]
c_4 = cF(2.613848) [kPa]
f_1 = phiF(1)
f_2 = phiF(1.5)
f_3 = phiF(2)
f_4 = phiF(2.613848)

## 4 · La escalera de escalones: la regla de GeoFEM
#: En símbolos. GEO5 sube el SRF en pasos de **reduction_step = p₀ = 0.9**: cada escalón divide la resistencia entre 0.9 más, o sea SRF_{k} = SRF_{k−1}/p₀. Empezando en 1, después de k escalones:
SRFk_s = Simplify{(1/p_m)^k_m}
#: Cuando un escalón **diverge**, GeoFEM no se rinde: **relaja** el paso con el factor 2, acercándolo a 1: p_{j} = 1 − (1 − p₀)/2^{j}. Así prueba 0.9, 0.95, 0.975, 0.9875…, y se detiene cuando p llega a **min_reduction_step = 0.99**; el último SRF que convergió es el factor de seguridad.
pj_s = Simplify{1 - (1 - p_m)/2^j_m}
#: Con números. Primero los 9 escalones normales, y se compara cada uno con el registro de GEO5 (columna de la derecha):
p0 = 0.9
srf_g5 = [1.0, 1.111111, 1.234568, 1.371742, 1.524158, 1.693509, 1.881676, 2.090752, 2.323057, 2.581175]
#hide
T_esc = zeros(10, 3)
for k = 0:9
  T_esc(k + 1, 1) = k
  T_esc(k + 1, 2) = 1/p0^k
  T_esc(k + 1, 3) = srf_g5(k + 1)
end
#show
T_esc
srf_9 = 1/p0^9 'último escalón normal que converge
dif_esc = abs(srf_9 - srf_g5(10)) 'diferencia con GEO5
#: **El siguiente escalón diverge.** Aquí se aplica la regla de relajación completa. El solver decide si un intento converge; en esta hoja se reemplaza por un umbral (lim = 2.62, cualquier valor entre 2.6138 y 2.6469 da las mismas decisiones que el solver real):
lim = 2.62
p_min = 0.99
#hide
tray = zeros(8, 1)
okv = zeros(8, 1)
conv = srf_9
rel = 0
p = p0
seguir = 1
for i = 1:8
  if seguir == 1
    tr = conv/p
    tray(i) = tr
    if tr <= lim
      okv(i) = 1
      conv = tr
    else
      okv(i) = 0
      rel = rel + 1
      p = 1 - (1 - p0)/2^rel
      if p >= p_min
        seguir = 0
      end
    end
  end
end
#show
#: Intentos de la relajación (el SRF probado y si convergió: 1 = sí, 0 = no):
tray
okv
#: **Mira la Figura 3:** la escalera completa que hizo GEO5 (los círculos son sus intentos) y la que reproduce esta hoja con la regla de arriba son la misma.
#dibujo("Figura 3. La escalera de GEO5 (el registro del solver real): cada círculo es un intento de SRF; verde = converge, rojo = diverge", ud = , ancho = 190, alto = 115)
#  flecha(-0.8, 0, 15.5, 0, "negro")
#  texto(15.8, 0, "intento", 2.6, "i")
#  flecha(-0.8, 0, -0.8, 7.04, "negro")
#  texto(-0.8, 7.34, "SRF", 2.8, "c")
#  linea(-0.8, 0.64, 15.2, 0.64, "fina trazos")
#  texto(-1, 0.64, "1.0", 2.4, "d")
#  linea(-0.8, 2.24, 15.2, 2.24, "fina trazos")
#  texto(-1, 2.24, "1.5", 2.4, "d")
#  linea(-0.8, 3.84, 15.2, 3.84, "fina trazos")
#  texto(-1, 3.84, "2.0", 2.4, "d")
#  linea(-0.8, 5.44, 15.2, 5.44, "fina trazos")
#  texto(-1, 5.44, "2.5", 2.4, "d")
#  linea(-0.8, 7.04, 15.2, 7.04, "fina trazos")
#  texto(-1, 7.04, "3.0", 2.4, "d")
#  polilinea([0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 13], [0.64, 0.9956, 1.3906, 1.8296, 2.3173, 2.8592, 3.4614, 4.1304, 4.8738, 5.6998, 5.8042], "media verde")
#  circulo(0, 0.64, 0.14, "verde relleno")
#  circulo(1, 0.9956, 0.14, "verde relleno")
#  circulo(2, 1.3906, 0.14, "verde relleno")
#  circulo(3, 1.8296, 0.14, "verde relleno")
#  circulo(4, 2.3173, 0.14, "verde relleno")
#  circulo(5, 2.8592, 0.14, "verde relleno")
#  circulo(6, 3.4614, 0.14, "verde relleno")
#  circulo(7, 4.1304, 0.14, "verde relleno")
#  circulo(8, 4.8738, 0.14, "verde relleno")
#  circulo(9, 5.6998, 0.14, "verde relleno")
#  circulo(10, 6.6176, 0.14, "rojo relleno")
#  circulo(11, 6.1344, 0.14, "rojo relleno")
#  circulo(12, 5.9117, 0.14, "rojo relleno")
#  circulo(13, 5.8042, 0.14, "verde relleno")
#  circulo(14, 5.9101, 0.14, "rojo relleno")
#  texto(4.5, -0.9, "9 escalones de 1/0.9: todos convergen", 2.5, "c", estilo = "verde")
#  texto(12.5, -0.9, "relajaciones: p = 0.9, 0.95, 0.975, 0.9875", 2.5, "c", estilo = "rojo")
#  texto(14, 4.9042, "FS = 2.6138", 3, "c", estilo = "azul")
#  linea(-0.8, 5.8042, 15.2, 5.8042, "media azul")
#fin
#: El resultado de esta hoja contra GEO5 y contra Geotechnic (misma malla):
FS_hoja = conv
FS_geo5 = 2.613848
FS_geotechnic = 2.613848
dif_FS = FS_hoja - FS_geo5
#: Los intentos de Geotechnic en la relajación fueron 2.8680, 2.7170, 2.6474 (los tres divergen), 2.6138 (converge) y 2.6469 (diverge): **los mismos de la lista tray**.

## 5 · Lo que pasa en el talud al reducir la resistencia
#: Al ir debilitando el suelo, los desplazamientos crecen despacio mientras el talud aguanta y **se disparan cuando se acerca a la falla**. En Geotechnic, el desplazamiento máximo en mm de cada escalón convergido es:
srf_conv = [1.1111, 1.2346, 1.3717, 1.5242, 1.6935, 1.8817, 2.0908, 2.3231, 2.5812, 2.6138]
umax_mm = [55.1, 57.0, 59.1, 61.6, 64.0, 66.6, 69.3, 72.3, 134.0, 1455.9]
#: **Mira la Figura 4:** el desplazamiento máximo contra el SRF. A SRF ≈ 2.32 mueve 72 mm; a 2.58, 134 mm; y en el último escalón que converge, 1456 mm: el talud ya está fallando.
#dibujo("Figura 4. Desplazamiento máximo contra SRF: casi plano mientras el talud resiste y se dispara al llegar a la falla", ud = , ancho = 190, alto = 115)
#  flecha(-1, 0, 15.5, 0, "negro")
#  texto(15.8, 0, "SRF", 2.6, "i")
#  flecha(0, -1, 0, 27, "negro")
#  texto(0, 28, "|u| máx [mm]", 2.6, "c")
#  linea(0, 6, 15.2, 6, "fina trazos")
#  texto(-0.4, 5.6, "400", 2.4, "d")
#  linea(0, 12, 15.2, 12, "fina trazos")
#  texto(-0.4, 11.6, "800", 2.4, "d")
#  linea(0, 18, 15.2, 18, "fina trazos")
#  texto(-0.4, 17.6, "1200", 2.4, "d")
#  linea(0, 24, 15.2, 24, "fina trazos")
#  texto(-0.4, 23.6, "1600", 2.4, "d")
#  linea(0.8, 0, 0.8, -0.6, "media")
#  texto(0.8, -2.2, "1.0", 2.4, "c")
#  linea(4.8, 0, 4.8, -0.6, "media")
#  texto(4.8, -2.2, "1.5", 2.4, "c")
#  linea(8.8, 0, 8.8, -0.6, "media")
#  texto(8.8, -2.2, "2.0", 2.4, "c")
#  linea(12.8, 0, 12.8, -0.6, "media")
#  texto(12.8, -2.2, "2.5", 2.4, "c")
#  polilinea([1.6889, 2.6765, 3.7739, 4.9933, 6.3481, 7.8534, 9.526, 11.3845, 13.4494, 13.7108], [0.8265, 0.8556, 0.8864, 0.9235, 0.96, 0.9987, 1.0398, 1.084, 2.0107, 21.8381], "media azul")
#  circulo(1.6889, 0.8265, 0.2, "azul relleno")
#  circulo(2.6765, 0.8556, 0.2, "azul relleno")
#  circulo(3.7739, 0.8864, 0.2, "azul relleno")
#  circulo(4.9933, 0.9235, 0.2, "azul relleno")
#  circulo(6.3481, 0.96, 0.2, "azul relleno")
#  circulo(7.8534, 0.9987, 0.2, "azul relleno")
#  circulo(9.526, 1.0398, 0.2, "azul relleno")
#  circulo(11.3845, 1.084, 0.2, "azul relleno")
#  circulo(13.4494, 2.0107, 0.2, "azul relleno")
#  circulo(13.7108, 21.8381, 0.2, "azul relleno")
#  texto(13.2108, 23.0381, "1456 mm: el talud falla", 2.5, "d", estilo = "rojo")
#fin
#: **Mira la Figura 5:** dónde se mueve el suelo en ese último escalón: la zona roja es la masa que se desliza, o sea **la superficie de falla**, que GeoFEM encuentra sola (no se le dice dónde está).
#dibujo("Figura 5. Desplazamiento total |u| en el último escalón que converge: la zona que más se mueve es la superficie de falla", ud = m, ancho = 200, alto = 100)
#  polilinea([0, 45, 45, 21.0091, 11, 0, 0], [-24, -24, -2.5, -2.5, -9, -9, -24], "gruesa")
#  poligono([0, 3.75, 3.75], [-24, -24, -21], "azul tenue")
#  poligono([0, 3.75, 0], [-24, -21, -21], "azul tenue")
#  poligono([0, 3.75, 3.75], [-21, -21, -18], "azul tenue")
#  poligono([0, 3.75, 0], [-21, -18, -18], "azul tenue")
#  poligono([0, 3.75, 3.75], [-18, -18, -15], "azul tenue")
#  poligono([0, 3.75, 0], [-18, -15, -15], "azul tenue")
#  poligono([0, 3.75, 3.75], [-15, -15, -12], "azul tenue")
#  poligono([0, 3.75, 0], [-15, -12, -12], "azul tenue")
#  poligono([0, 3.75, 3.75], [-12, -12, -9], "azul tenue")
#  poligono([0, 3.75, 0], [-12, -9, -9], "azul tenue")
#  poligono([3.75, 7.5, 7.5], [-24, -24, -21], "azul tenue")
#  poligono([3.75, 7.5, 3.75], [-24, -21, -21], "azul tenue")
#  poligono([3.75, 7.5, 7.5], [-21, -21, -18], "azul tenue")
#  poligono([3.75, 7.5, 3.75], [-21, -18, -18], "azul tenue")
#  poligono([3.75, 7.5, 7.5], [-18, -18, -15], "azul tenue")
#  poligono([3.75, 7.5, 3.75], [-18, -15, -15], "azul tenue")
#  poligono([3.75, 7.5, 7.5], [-15, -15, -12], "azul tenue")
#  poligono([3.75, 7.5, 3.75], [-15, -12, -12], "azul tenue")
#  poligono([3.75, 7.5, 7.5], [-12, -12, -9], "azul tenue")
#  poligono([3.75, 7.5, 3.75], [-12, -9, -9], "azul tenue")
#  poligono([7.5, 11.25, 11.25], [-24, -24, -20.9675], "azul tenue")
#  poligono([7.5, 11.25, 7.5], [-24, -20.9675, -21], "azul tenue")
#  poligono([7.5, 11.25, 11.25], [-21, -20.9675, -17.9351], "azul tenue")
#  poligono([7.5, 11.25, 7.5], [-21, -17.9351, -18], "azul tenue")
#  poligono([7.5, 11.25, 11.25], [-18, -17.9351, -14.9026], "azul tenue")
#  poligono([7.5, 11.25, 7.5], [-18, -14.9026, -15], "azul tenue")
#  poligono([7.5, 11.25, 11.25], [-15, -14.9026, -11.8701], "azul tenue")
#  poligono([7.5, 11.25, 7.5], [-15, -11.8701, -12], "azul tenue")
#  poligono([7.5, 11.25, 11.25], [-12, -11.8701, -8.8376], "verde relleno")
#  poligono([7.5, 11.25, 7.5], [-12, -8.8376, -9], "verde relleno")
#  poligono([11.25, 15, 15], [-24, -24, -20.4805], "azul tenue")
#  poligono([11.25, 15, 11.25], [-24, -20.4805, -20.9675], "azul tenue")
#  poligono([11.25, 15, 15], [-20.9675, -20.4805, -16.961], "azul tenue")
#  poligono([11.25, 15, 11.25], [-20.9675, -16.961, -17.9351], "azul tenue")
#  poligono([11.25, 15, 15], [-17.9351, -16.961, -13.4414], "azul tenue")
#  poligono([11.25, 15, 11.25], [-17.9351, -13.4414, -14.9026], "azul tenue")
#  poligono([11.25, 15, 15], [-14.9026, -13.4414, -9.9219], "verde relleno")
#  poligono([11.25, 15, 11.25], [-14.9026, -9.9219, -11.8701], "verde relleno")
#  poligono([11.25, 15, 15], [-11.8701, -9.9219, -6.4024], "naranja relleno")
#  poligono([11.25, 15, 11.25], [-11.8701, -6.4024, -8.8376], "naranja relleno")
#  poligono([15, 18.75, 18.75], [-24, -24, -19.9934], "azul tenue")
#  poligono([15, 18.75, 15], [-24, -19.9934, -20.4805], "azul tenue")
#  poligono([15, 18.75, 18.75], [-20.4805, -19.9934, -15.9868], "azul tenue")
#  poligono([15, 18.75, 15], [-20.4805, -15.9868, -16.961], "azul tenue")
#  poligono([15, 18.75, 18.75], [-16.961, -15.9868, -11.9802], "azul tenue")
#  poligono([15, 18.75, 15], [-16.961, -11.9802, -13.4414], "azul tenue")
#  poligono([15, 18.75, 18.75], [-13.4414, -11.9802, -7.9737], "verde relleno")
#  poligono([15, 18.75, 15], [-13.4414, -7.9737, -9.9219], "verde relleno")
#  poligono([15, 18.75, 18.75], [-9.9219, -7.9737, -3.9671], "naranja relleno")
#  poligono([15, 18.75, 15], [-9.9219, -3.9671, -6.4024], "rojo relleno")
#  poligono([18.75, 22.5, 22.5], [-24, -24, -19.7], "azul tenue")
#  poligono([18.75, 22.5, 18.75], [-24, -19.7, -19.9934], "azul tenue")
#  poligono([18.75, 22.5, 22.5], [-19.9934, -19.7, -15.4], "azul tenue")
#  poligono([18.75, 22.5, 18.75], [-19.9934, -15.4, -15.9868], "azul tenue")
#  poligono([18.75, 22.5, 22.5], [-15.9868, -15.4, -11.1], "azul tenue")
#  poligono([18.75, 22.5, 18.75], [-15.9868, -11.1, -11.9802], "azul tenue")
#  poligono([18.75, 22.5, 22.5], [-11.9802, -11.1, -6.8], "verde relleno")
#  poligono([18.75, 22.5, 18.75], [-11.9802, -6.8, -7.9737], "verde relleno")
#  poligono([18.75, 22.5, 22.5], [-7.9737, -6.8, -2.5], "naranja relleno")
#  poligono([18.75, 22.5, 18.75], [-7.9737, -2.5, -3.9671], "rojo relleno")
#  poligono([22.5, 26.25, 26.25], [-24, -24, -19.7], "azul tenue")
#  poligono([22.5, 26.25, 22.5], [-24, -19.7, -19.7], "azul tenue")
#  poligono([22.5, 26.25, 26.25], [-19.7, -19.7, -15.4], "azul tenue")
#  poligono([22.5, 26.25, 22.5], [-19.7, -15.4, -15.4], "azul tenue")
#  poligono([22.5, 26.25, 26.25], [-15.4, -15.4, -11.1], "azul tenue")
#  poligono([22.5, 26.25, 22.5], [-15.4, -11.1, -11.1], "azul tenue")
#  poligono([22.5, 26.25, 26.25], [-11.1, -11.1, -6.8], "azul tenue")
#  poligono([22.5, 26.25, 22.5], [-11.1, -6.8, -6.8], "verde relleno")
#  poligono([22.5, 26.25, 26.25], [-6.8, -6.8, -2.5], "verde relleno")
#  poligono([22.5, 26.25, 22.5], [-6.8, -2.5, -2.5], "naranja relleno")
#  poligono([26.25, 30, 30], [-24, -24, -19.7], "azul tenue")
#  poligono([26.25, 30, 26.25], [-24, -19.7, -19.7], "azul tenue")
#  poligono([26.25, 30, 30], [-19.7, -19.7, -15.4], "azul tenue")
#  poligono([26.25, 30, 26.25], [-19.7, -15.4, -15.4], "azul tenue")
#  poligono([26.25, 30, 30], [-15.4, -15.4, -11.1], "azul tenue")
#  poligono([26.25, 30, 26.25], [-15.4, -11.1, -11.1], "azul tenue")
#  poligono([26.25, 30, 30], [-11.1, -11.1, -6.8], "azul tenue")
#  poligono([26.25, 30, 26.25], [-11.1, -6.8, -6.8], "azul tenue")
#  poligono([26.25, 30, 30], [-6.8, -6.8, -2.5], "azul tenue")
#  poligono([26.25, 30, 26.25], [-6.8, -2.5, -2.5], "verde relleno")
#  poligono([30, 33.75, 33.75], [-24, -24, -19.7], "azul tenue")
#  poligono([30, 33.75, 30], [-24, -19.7, -19.7], "azul tenue")
#  poligono([30, 33.75, 33.75], [-19.7, -19.7, -15.4], "azul tenue")
#  poligono([30, 33.75, 30], [-19.7, -15.4, -15.4], "azul tenue")
#  poligono([30, 33.75, 33.75], [-15.4, -15.4, -11.1], "azul tenue")
#  poligono([30, 33.75, 30], [-15.4, -11.1, -11.1], "azul tenue")
#  poligono([30, 33.75, 33.75], [-11.1, -11.1, -6.8], "azul tenue")
#  poligono([30, 33.75, 30], [-11.1, -6.8, -6.8], "azul tenue")
#  poligono([30, 33.75, 33.75], [-6.8, -6.8, -2.5], "azul tenue")
#  poligono([30, 33.75, 30], [-6.8, -2.5, -2.5], "azul tenue")
#  poligono([33.75, 37.5, 37.5], [-24, -24, -19.7], "azul tenue")
#  poligono([33.75, 37.5, 33.75], [-24, -19.7, -19.7], "azul tenue")
#  poligono([33.75, 37.5, 37.5], [-19.7, -19.7, -15.4], "azul tenue")
#  poligono([33.75, 37.5, 33.75], [-19.7, -15.4, -15.4], "azul tenue")
#  poligono([33.75, 37.5, 37.5], [-15.4, -15.4, -11.1], "azul tenue")
#  poligono([33.75, 37.5, 33.75], [-15.4, -11.1, -11.1], "azul tenue")
#  poligono([33.75, 37.5, 37.5], [-11.1, -11.1, -6.8], "azul tenue")
#  poligono([33.75, 37.5, 33.75], [-11.1, -6.8, -6.8], "azul tenue")
#  poligono([33.75, 37.5, 37.5], [-6.8, -6.8, -2.5], "azul tenue")
#  poligono([33.75, 37.5, 33.75], [-6.8, -2.5, -2.5], "azul tenue")
#  poligono([37.5, 41.25, 41.25], [-24, -24, -19.7], "azul tenue")
#  poligono([37.5, 41.25, 37.5], [-24, -19.7, -19.7], "azul tenue")
#  poligono([37.5, 41.25, 41.25], [-19.7, -19.7, -15.4], "azul tenue")
#  poligono([37.5, 41.25, 37.5], [-19.7, -15.4, -15.4], "azul tenue")
#  poligono([37.5, 41.25, 41.25], [-15.4, -15.4, -11.1], "azul tenue")
#  poligono([37.5, 41.25, 37.5], [-15.4, -11.1, -11.1], "azul tenue")
#  poligono([37.5, 41.25, 41.25], [-11.1, -11.1, -6.8], "azul tenue")
#  poligono([37.5, 41.25, 37.5], [-11.1, -6.8, -6.8], "azul tenue")
#  poligono([37.5, 41.25, 41.25], [-6.8, -6.8, -2.5], "azul tenue")
#  poligono([37.5, 41.25, 37.5], [-6.8, -2.5, -2.5], "azul tenue")
#  poligono([41.25, 45, 45], [-24, -24, -19.7], "azul tenue")
#  poligono([41.25, 45, 41.25], [-24, -19.7, -19.7], "azul tenue")
#  poligono([41.25, 45, 45], [-19.7, -19.7, -15.4], "azul tenue")
#  poligono([41.25, 45, 41.25], [-19.7, -15.4, -15.4], "azul tenue")
#  poligono([41.25, 45, 45], [-15.4, -15.4, -11.1], "azul tenue")
#  poligono([41.25, 45, 41.25], [-15.4, -11.1, -11.1], "azul tenue")
#  poligono([41.25, 45, 45], [-11.1, -11.1, -6.8], "azul tenue")
#  poligono([41.25, 45, 41.25], [-11.1, -6.8, -6.8], "azul tenue")
#  poligono([41.25, 45, 45], [-6.8, -6.8, -2.5], "azul tenue")
#  poligono([41.25, 45, 41.25], [-6.8, -2.5, -2.5], "azul tenue")
#  polilinea([0, 45, 45, 21.0091, 11, 0, 0], [-24, -24, -2.5, -2.5, -9, -9, -24], "gruesa")
#  texto(34, -12, "rojo: |u| > 60 % del máximo (la masa que se desliza)", 2.6, "c", estilo = "rojo")
#  texto(34, -14, "naranja: 30–60 %    verde: 8–30 %    azul: casi quieto", 2.6, "c")
#  texto(22.5, -27.4, "|u| máximo = 1456 mm en el escalón de falla (SRF = 2.6138); la zona roja marca el mecanismo", 2.6, "c")
#fin

## 6 · Qué es lo mismo y qué cambia respecto del bloque
#: **Lo mismo:** el elemento (T6, 7 puntos de Gauss), las matrices B y D, el ensamblaje, el peso propio y el retorno de Mohr-Coulomb. En cada punto de cada elemento del talud corre el mismo cálculo de la hoja anterior.
#: **Lo que cambia con un talud:** (1) hay que resolver el problema NO LINEAL completo en cada escalón (Newton-Raphson con la tangente, búsqueda lineal), no un solo punto; (2) la regla de escalones y relajaciones de arriba decide el factor de seguridad; (3) la superficie de falla aparece sola como la zona donde se concentra el desplazamiento.
#: **Comprobado contra GEO5:** el mismo talud, con la misma malla, da FS = 2.613848 en GEO5 y 2.613848 en Geotechnic, con la misma escalera de escalones. En la malla completa del talud «simple» (1440 T6) la coincidencia con GEO5 es 2.117217 contra 2.1172, y en el talud con bermas 2.445323 contra 2.4453.
