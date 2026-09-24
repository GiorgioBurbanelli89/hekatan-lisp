# Hoja numérica: prueba de lo básico
#numerico
n = 5
s = 0
for i = 1:n
  s = s + i
end
s
#: palabras de Calcpad
p = 1
#for k = 1 : 4
  p = p·k
#loop
p
#: if / elseif / else con && y ||
c = 0
for i = 1:10
  if mod(i, 2) == 0 && i > 4
    c = c + 1
  elseif i == 1 || i == 3
    c = c + 100
  else
    c = c + 0
  end
end
c
#: vectores, matrices, índices, rangos
v = zeros(4, 1)
for i = 1:4
  v(i) = i^2
end
v
A = [4, 1; 2, 3]
x = A\[1; 2]
B = zeros(3, 3)
B(2:3, 2:3) = B(2:3, 2:3) + A
B(:, 1) = [7; 8; 9]
B
#: funciones de la hoja, anónimas e integrales
f(x) = x^2 + 1
f(3)
g = @(x, y) x·y
integral2(g, 0, 1, 0, 1)
I = integral(@(t) sin(t), 0, pi)
#: nombres que distinguen mayúsculas
e = 2
E = 3
e·E
#hide
oculta = 99
#show
oculta + 1
#: B = A es una COPIA (semántica de valor, como MATLAB)
M = [1, 2; 3, 4]
N = M
N(1, 1) = 100
m_11 = M(1, 1)
function s = copia_local(A)
  C = A
  C(1, 1) = 0
  s = A(1, 1)
end
q_11 = copia_local([5, 6; 7, 8])
function y = pon_cero(X)
  X(1, 1) = 0
  y = X(2, 2)
end
r_22 = pon_cero(M)
m_11b = M(1, 1)
#: un error no tumba la hoja
malo = zz + 1
sigue = 42
