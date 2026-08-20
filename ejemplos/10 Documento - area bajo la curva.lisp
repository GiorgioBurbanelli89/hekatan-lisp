;# El área bajo una parábola
;| Un documento de Hekatan LISP: *texto*, _operación simbólica_ y gráfica juntos.

;## 1. La función
;< Estudiamos la parábola  f = {f}  en el intervalo [0, 1].
f = x^2

;## 2. Operaciones simbólicas
;< Su pendiente (derivada) evaluada en  x = 1  vale:
$slope{x^2 @ x = 1}
;< El área exacta bajo la curva entre 0 y 1 (integral definida):
$area{x^2 @ x = 0 : 1}

;## 3. La gráfica
;< La curva  f = x²  cuya área acabamos de calcular:
;fplot(x^2, [0 1])

;## 4. Conclusión
;| El área bajo  *f = x²*  entre 0 y 1 es exactamente  1/3.
