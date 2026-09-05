# Las tres formulaciones sobre la MISMA losa
## Una losa de seis por cuatro metros, veinte centímetros de espesor, apoyada en los cuatro bordes, con diez kilonewton por metro cuadrado encima.
## Con Shell-Thin, la de Kirchhoff, la flecha máxima sale así, en milímetros.
w_thin = 1.1351
## Con Shell-Thick, la de Mindlin, sale un poco más: es el cortante que Kirchhoff no cuenta.
w_thick = 1.1553
## La diferencia es esta, en tanto por ciento.
dif = (1.1553/1.1351 - 1)·100
## Menos del dos por ciento. En una losa delgada da casi igual cuál uses.
## Ahora la MISMA losa, pero de un metro de espesor.
g_thin = 0.0091
g_thick = 0.0122
## Y aquí la diferencia ya no es pequeña.
dif_g = (0.0122/0.0091 - 1)·100
## Treinta y cuatro por ciento. Con una losa gruesa, elegir mal la formulación cambia el resultado.
## Y con Membrane, que no tiene rigidez a flexión, la losa de veinte centímetros baja esto.
w_mem = 1135125
## Un millón de veces más. No es que sea flexible: es que no aguanta nada.
veces = 1135125/1.1351
