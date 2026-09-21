# El pórtico en el espacio, sin losa
## Ya tenemos la matriz de una barra, de doce por doce. Pero está en los ejes de la barra, y el edificio tiene los suyos.
## Para orientarla hacen falta los cosenos directores: cuánto avanza la barra en cada dirección, dividido para su largo.
dx = 3
dy = 4
dz = 0
L = sqrt(dx^2 + dy^2 + dz^2)
l_1 = dx/L
m_1 = dy/L
n_1 = dz/L
## Con ellos se arma la matriz de giro de tres por tres.
Rot = [0.6, 0.8, 0; -0.8, 0.6, 0; 0, 0, 1]
## Y lo primero que hay que comprobar es que gira sin deformar: por su transpuesta debe dar la identidad.
chk = Rot·transpose(Rot)
## Esa matriz de tres se repite cuatro veces: tres desplazamientos y tres giros, en cada uno de los dos nudos.
bloques = 4·3
## Y la matriz de la barra en ejes del edificio es la transpuesta del giro, por la matriz, por el giro.
## Ahora el pórtico. Tres ejes por tres ejes, y tres plantas más la base.
nudos = 3·3·4
## Cada nudo aporta seis grados de libertad.
gdl_tot = nudos·6
## Los nueve nudos de la base están empotrados, así que sus grados se quitan.
gdl_base = 9·6
gdl_libres = gdl_tot - gdl_base
## Y las barras: nueve columnas por tres plantas, y doce vigas en cada planta.
cols = 9·3
vigas = 12·3
barras = cols + vigas
## Cada barra deja ciento cuarenta y cuatro números repartidos en la matriz global.
aportes = barras·144
## Esa matriz global no se calcula de una fórmula: se arma sumando lo que deja cada barra en los grados de sus dos nudos.
