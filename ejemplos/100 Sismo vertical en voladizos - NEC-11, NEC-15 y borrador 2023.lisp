# Sismo vertical en voladizos — NEC-11, NEC-15 y borrador NEC-SE-DS 2023
#: El voladizo es rígido en vertical: se diseña para una **fuerza neta vertical reversible** (hacia arriba y hacia abajo) que es una fracción de su peso. Cada norma la escribe distinto; aquí las tres con el edificio del curso (Portoviejo, suelo D) y el peso del volado que mide Hekatan Struct.

#numerico
## 1 · Datos
Z = 0.5 @@(zona sísmica, Portoviejo)
Fa = 1.12 @@(suelo D, NEC-15 Tabla 3)
eta = 1.8 @@(η, Costa, NEC-15 §3.3.1)
I = 1 @@(importancia, otras estructuras)
Wp = 212.0 @@(peso del volado de un piso, kN — Hekatan Struct, capa NEC)

## 2 · NEC-11 §2.7.6.1, ec. (2-28)
#: **F_ver = ⅔·(Z·I·Fa)·Wp**. Sin η: el texto (§2.7.6.2) dice que el voladizo, por rígido, usa un espectro **plano de valor Z·Fa**.
c11 = 2/3*Z*I*Fa @@(coeficiente NEC-11)
F11 = c11*Wp @@(F_ver, kN, ± vertical)

## 3 · NEC-15 §3.4.4
#: **F_rev = ⅔·I·(η·Z·Fa)·Wp**. La meseta del espectro de la NEC-15 es η·Z·Fa: la NEC-15 sí multiplica por η.
c15 = 2/3*I*eta*Z*Fa @@(coeficiente NEC-15)
F15 = c15*Wp @@(F_rev, kN, ± vertical)

## 4 · Borrador NEC-SE-DS 2023 §3.4.2.4, ec. (3.9)
#: **F_rev = ⅔·Ie·(2.4·Z·Fa)·W_vol**: la meseta del borrador es 2.4·Z·Fa (con los Fa del borrador; aquí, para comparar, el mismo Fa).
c23 = 2/3*I*2.4*Z*Fa @@(coeficiente borrador)
F23 = c23*Wp @@(F_rev, kN, ± vertical)

## 5 · Comparación
r15 = F15/F11 @@(NEC-15 / NEC-11 = η)
r23 = F23/F11 @@(borrador / NEC-11 = 2.4)
#: La NEC-15 da **η = 1.8 veces** la NEC-11 y el borrador **2.4 veces**. En las tres, además, la componente vertical general es **Ev ≥ ⅔·Eh** (NEC-11 §2.7.7.3, NEC-15 §3.4.2, borrador ec. 3.8). Hekatan Struct calcula F_rev en el panel 🌎 Sismo NEC con la norma elegida y muestra al lado el valor de la NEC-11.
