# El muro: el programa contra la clásica
## Un muro de tres metros de ancho y seis de alto, de diez centímetros, empotrado abajo, con diez coma dos toneladas fuerza empujando en la punta.
## Por resistencia de materiales, el desplazamiento tiene dos partes. La de flexión, en milímetros.
d_f = 0.9143
## Y la de cortante.
d_c = 0.1577
## Que suman esto.
d_cl = 0.9143 + 0.1577
## Y ahora el programa, refinando la malla. Con seis por doce elementos.
w_6 = 0.9183
## Con doce por veinticuatro.
w_12 = 0.9962
## Y con veinticuatro por cuarenta y ocho.
w_24 = 1.0389
## Que ya es el noventa y siete por ciento de la clásica.
r_24 = 1.0389/1.0720
## Con la malla gruesa el elemento sale RÍGIDO, y al refinar converge. No es un error: es que hacen falta elementos.
