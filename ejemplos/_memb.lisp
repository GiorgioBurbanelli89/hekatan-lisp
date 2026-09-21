# La MEMBRANA: primero simbólico, después los números
## PARTE UNO, TODO SIMBÓLICO. El elemento tiene cuatro nudos y dos grados por nudo, los del plano.
n_gdl = 4·2
## Sus funciones de forma son las bilineales que ya dedujimos.
N_1 = (1-xi)·(1-eta)/4
## La deformación de membrana es la PRIMERA derivada parcial. Ésta respecto a la primera coordenada.
dNx = Partial{(1-xi)·(1-eta)/4 @ xi}
## Y ésta respecto a la segunda.
dNy = Partial{(1-xi)·(1-eta)/4 @ eta}
## Para un elemento de lado a por lado b, el Jacobiano es la mitad de cada lado, y su determinante el producto.
J_x = a/2
J_y = b/2
dJ = a·b/4
## Y la derivada respecto al elemento real se saca dividiendo por el Jacobiano.
dNdx = dNxi·(2/a)
## La constitutiva de la membrana es la del capítulo anterior por el ESPESOR, y sigue con el uno menos Poisson al cuadrado.
D_m = E·t/(1 - nu^2)
## Con eso, el primer término de la rigidez es la doble integral del cuadrado de la derivada, por la constitutiva y por el Jacobiano.
## La parte geométrica de esa integral, sola, vale un tercio.
I_g = Area{Area{((1-eta)/2)^2·(1/4) @ xi=-1:1} @ eta=-1:1}
## Así que, simbólicamente, ese término es la constitutiva partida para tres.
k_sim = E·t/(3·(1 - nu^2))
## PARTE DOS, AHORA SE REEMPLAZA. El módulo del hormigón del ejemplo, en kilogramo fuerza por centímetro cuadrado.
E_kg = 35000·10.19716
## Un kilogramo por centímetro cuadrado son diez toneladas por metro cuadrado, así que en toneladas queda esto.
E_t = 356900·10
## El espesor es de diez centímetros, y uno menos Poisson al cuadrado vale trescientos noventa y uno cuatrocientos avos.
p_nu = 400/391
## La constitutiva de membrana, en toneladas por metro.
D_num = 3569000·0.10·400/391
## Y el primer término de la rigidez del elemento, también en toneladas por metro.
k_num = 365115/3
## Sesenta y cuatro términos como ése forman la matriz del elemento.
n_ter = 8·8
