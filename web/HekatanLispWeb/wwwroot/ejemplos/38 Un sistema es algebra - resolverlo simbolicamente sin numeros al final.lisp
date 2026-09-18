# Un sistema es álgebra — resolverlo SIMBÓLICAMENTE (sin números al final)
#: Un sistema tiene INCÓGNITAS, así que es álgebra —igual que 2x+2y=0 es álgebra aunque los coeficientes sean números—. Aquí lo resolvemos con **operaciones simbólicas**, dejando TODO en letras: no sustituimos ni un número.

## 1 · El sistema (coeficientes números; lado derecho en letras p, q)
#|  2x +  y = p
#:   x + 3y = q
#: Los coeficientes son 2, 1, 1, 3, pero p, q y las incógnitas x, y son LETRAS. Resolver = hallar x, y en función de p, q.

## 2 · Forma matricial: A · X = b
A = [2, 1; 1, 3]
xy = [x; y]
b = [p; q]
#: El producto A·X reproduce el sistema:
AX = A * xy
#: A·X = {AX}, igualado a b = [p; q].

## 3 · El determinante (decide si hay solución única)
detA = det(A)
#: |A| = 5. Como no es cero, hay solución única y podemos invertir.

## 4 · Solución por la INVERSA: X = A⁻¹·b (simbólica)
sol = inv(A) * b
#: X = [ (3p − q)/5 ; (2q − p)/5 ]. Es decir **x = (3p−q)/5, y = (2q−p)/5** — la solución en LETRAS, sin un solo número puesto.

## 5 · La misma solución por REGLA DE CRAMER (determinantes)
#: Cramer: cada incógnita es un cociente de determinantes. Para **x**, se cambia la 1ª columna de A por b, y se calcula su determinante:
Ax = [p, 1; q, 3]
detAx = det(Ax)
xc = detAx * (1/detA)
#: |Ax| = 3p−q, así que x = |Ax|/|A| = (3p−q)/5. Para **y**, se cambia la 2ª columna por b:
Ay = [2, p; 1, q]
detAy = det(Ay)
yc = detAy * (1/detA)
#: |Ay| = 2q−p, así que y = (2q−p)/5. **Igual que por la inversa.**

## 6 · Comprobación simbólica: A·(solución) = b
#: Multiplico A por la solución hallada; debe volver al lado derecho [p; q]:
verif = A * sol
#: A·X = {verif}. Vuelve a **[p; q]** exacto — la solución es correcta, y todo quedó en letras.

## 7 · El caso homogéneo: 2x + 2y = 0
#: Si el lado derecho es cero y una ecuación es múltiplo de la otra, el determinante se anula y NO hay solución única. Por ejemplo 2x + 2y = 0 se reduce a x + y = 0, o sea **y = −x**: infinitas soluciones (toda una recta). El álgebra lo muestra: sin |A| ≠ 0, no se puede despejar un único punto.

## Cierre
#: · Un sistema con incógnitas es **álgebra**, tengan los coeficientes letras o números.
#: · Se resuelve con operaciones **simbólicas**: inversa (X=A⁻¹·b) o Cramer (cocientes de determinantes), dando x, y en función de p, q.
#: · Solo cuando quieras un punto concreto pones números en p, q — pero el MÉTODO es puro álgebra.
