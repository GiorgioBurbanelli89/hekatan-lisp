# La deducción de Gauss: de dónde salen los puntos ±1/√3
## Gauss quiere: integral ≈ w1·f1 + w2·f2, EXACTA para el mayor grado posible
## 4 incógnitas (2 puntos, 2 pesos) → 4 condiciones: exacto para 1, ξ, ξ², ξ³
c1 = w_1 + w_2 = 2
c2 = w_1·xi_1 + w_2·xi_2 = 0
c3 = w_1·xi_1^2 + w_2·xi_2^2 = 2/3
c4 = w_1·xi_1^3 + w_2·xi_2^3 = 0
## por simetría: w_1 = w_2 = 1 y xi_2 = -xi_1. De c3: 2·xi_1^2 = 2/3
despeje = 2·xi_1^2 = 2/3
sol = sqrt(1/3)
