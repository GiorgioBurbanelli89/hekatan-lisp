# De un trozo de viga hasta M sobre EI
## Se corta un trozo de viga de largo pequeño y se le pone todo lo que lo sostiene: a cada lado un cortante y un momento, y encima la carga repartida.
## De dónde sale la primera ecuación: se suman las fuerzas verticales del trozo. Entra el cortante de la izquierda, sale el de la derecha, y la carga empuja hacia abajo.
suma_V = V - (V + dV) - w·dx = 0
## Se simplifica y queda que el cambio del cortante es menos la carga.
eq_V = V_p = -w
## De dónde sale la segunda: se suman los momentos respecto a la cara derecha. El momento de la izquierda, el que hace el cortante con su brazo, y el momento de la derecha.
suma_M = M + V·dx - (M + dM) = 0
## Se simplifica y queda que el cambio del momento es el cortante.
eq_M = M_p = V
## Con eso ya está todo el equilibrio. Ahora falta la geometría, y ahí entra Bernoulli con dos hipótesis.
## Primera hipótesis: la sección se mantiene PLANA. Segunda: se mantiene PERPENDICULAR al eje doblado.
## De la perpendicularidad sale que el giro de la sección es la pendiente de la curva.
bernoulli = theta = Diff{v_x @ x}
## Y la curvatura es la derivada del giro: la segunda derivada de la flecha.
curva = kappa = Diff{theta @ x}
## De dónde sale la deformación: al doblarse, la viga toma un radio, y ese radio es el inverso de la curvatura.
radio = rho = 1/kappa
## La fibra del eje no cambia de largo. Una fibra que está a una distancia del eje sí, porque su radio es distinto. La razón entre las dos es esta.
razon = L_y/L_0 = (rho - y)/rho
## La deformación es cuánto cambió el largo partido para el largo original. Se cancela el radio y queda una semejanza de triángulos limpia.
deform = epsilon = -y/rho
## Y como el radio es el inverso de la curvatura, queda proporcional a la distancia al eje.
deform2 = epsilon = -y·kappa
## Ahora el material: la ley de Hooke dice que el esfuerzo es el módulo por la deformación.
hooke = sigma = E·epsilon
## Reemplazando, el esfuerzo también reparte en triángulo: máximo arriba y abajo, cero en el eje.
esfuerzo = sigma = -E·y·kappa
## De dónde sale el momento: en un pedacito de área, el esfuerzo hace una fuerza.
fuerza = dF = sigma·dA
## Y el momento flector es esa fuerza por su brazo, sumada en toda la sección.
mom_int = M = Integral{-sigma·y @ A}
## Al meter el esfuerzo dentro, sale afuera todo lo que no depende de la sección y queda una integral sola.
mom_paso = M = E·kappa·Integral{y^2 @ A}
## Esa integral ya tiene nombre: es la inercia de la sección.
inercia = I = Integral{y^2 @ A}
## Así que el momento es el módulo por la inercia por la curvatura.
momento = M = E·I·kappa
## Y despejando la curvatura sale la fórmula que todo el mundo conoce. Ya no es un dato que hay que creerse: está deducida.
elastica = kappa = M/EI
## Y como la curvatura es la segunda derivada de la deformada, la misma fórmula se escribe así.
elastica2 = v_pp = M/EI
## Timoshenko suelta la segunda hipótesis: deja que la sección se ladee respecto a la perpendicular.
timoshenko = theta = Diff{v_x @ x} - gamma
## Ese ladeo es la distorsión por cortante.
distorsion = gamma = V/(G·A_c)
