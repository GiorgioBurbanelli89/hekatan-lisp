# Algebra lineal para YouTube - las piezas que cita el video
#: Todo simbolico: cada resultado lo calcula el motor.

## 1 - Los objetos
u = [u1; u2]
v = [v1; v2]
A = [a11, a12; a21, a22]

## 2 - Operaciones con vectores
suma = u + v
esc = k * u
dot = transpose(u) * v

## 3 - La matriz transforma
Au = A * u

## 4 - Encadenar transformaciones
Bm = [b11, b12; b21, b22]
AB = A * Bm
BA = Bm * A

## 5 - El determinante
dA = det(A)
dLap = a11*menor(A, 1, 1) - a12*menor(A, 1, 2)

## 6 - Cuando no hay vuelta atras
Asing = [a11, a12; k*a11, k*a12]
dSing = det(Asing)

## 7 - La inversa
Cf = cof(A)
adjA = adj(A)
iA = adj(A) * (1/det(A))
chk = A * inv(A)

## 8 - El sistema
bb = [b1; b2]
x = inv(A) * bb
