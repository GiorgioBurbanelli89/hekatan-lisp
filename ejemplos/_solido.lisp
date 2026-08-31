# Sólidos 3D en Hekatan LISP
## Un dado de hormigón, mallado en hexaedros
#solido(1, 1, 1, 6, 6, 6)
## El mismo, con un cuarto quitado: el corte se ve RELLENO
#solido(1, 1, 1, 6, 6, 6, 1)
## Una zapata: 2 x 2 m de planta, 0.5 m de canto
#solido(2, 2, 0.5, 8, 8, 3)
## Y media pieza, para ver el interior
#solido(2, 1, 1, 8, 6, 6, 2)
