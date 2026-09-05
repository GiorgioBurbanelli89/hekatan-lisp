# La cáscara: membrana y placa
## Con las funciones de forma, el Jacobiano y Gauss en dos dimensiones ya se puede integrar el elemento de área. Falta decir QUÉ se integra.
## Cada nudo de una cáscara tiene seis grados de libertad, igual que el nudo de una barra.
gdl_n = 6
gdl_el = 4·6
## Y dentro conviven dos comportamientos distintos, que no se mezclan.
## El primero es MEMBRANA: las fuerzas actúan en el plano de la cáscara y dan esfuerzos axiales y rasante.
## Su rigidez va con el espesor a la primera.
Dm = E·t/(1 - nu^2)
## El segundo es PLACA: la carga es perpendicular y da momentos flectores y torsor.
## Su rigidez va con el espesor al CUBO.
Df = E·t^3/(12·(1 - nu^2))
## Esa es la matriz constitutiva de flexión, con el coeficiente de Poisson acoplando las dos direcciones.
Db = Df·[1, nu, 0; nu, 1, 0; 0, 0, (1-nu)/2]
## Y además está el cortante transversal, que va con el espesor a la primera y lleva el factor de cinco sextos.
Ds = 5/6·G·t
## Aquí está la clave de las formulaciones. Compara la flexión con el cortante: la flexión va con el cubo y el cortante con la primera.
r = Expand{(t^3/12)·(6/(5·t))}
## Eso significa que cuanto más delgada es la losa, menos pesa el cortante. En una losa de veinte centímetros con seis metros de luz vale esto.
r_del = 20·20/(10·600·600)
## Y en una de un metro, el cortante pesa veinticinco veces más.
veces = (100·100)/(20·20)
r_gru = 100·100/(10·600·600)
## Por eso ETABS tiene tres formulaciones, y la única diferencia entre las dos primeras está en la flexión: la membrana es la misma.
n_form = 3
