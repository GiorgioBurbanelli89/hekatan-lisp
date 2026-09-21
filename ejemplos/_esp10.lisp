# De dónde salen t y t al cubo
## La cáscara es plana, pero tiene espesor. Todo lo que hace se calcula sumando a través de ese espesor, de una cara a la otra.
## Para la MEMBRANA, cada capa aporta lo mismo, porque todas se estiran igual.
A_m = Area{1 @ z=-10:10}
## Sale el espesor entero. Por eso la rigidez de membrana va con el espesor a la primera.
## Para la PLACA no: cada capa aporta según el CUADRADO de su distancia al centro, porque cuanto más lejos está, más se estira al flexionar.
I_p = Area{z^2 @ z=-10:10}
## Y esa suma es el espesor al cubo partido para doce. De ahí sale el doce que aparece en todas las fórmulas de placa.
chk = 20^3/12
## Y el cortante transversal vuelve a ser como la membrana: cada capa aporta lo mismo, y por eso va con el espesor a la primera.
