# Algebra lineal en 90 segundos
#: Las piezas que cita el video. Todo simbolico: el motor las calcula.

## 1 · Los objetos
u = [u1; u2]
A = [a11, a12; a21, a22]

## 2 · La matriz transforma
Au = A * u

## 3 · El orden importa
Bm = [b11, b12; b21, b22]
AB = A * Bm
BA = Bm * A

## 4 · Determinante
dA = det(A)

## 5 · La inversa deshace
iA = inv(A)
chk = A * inv(A)

## 6 · El sistema
bb = [b1; b2]
x = Simplify{inv(A) * bb}
