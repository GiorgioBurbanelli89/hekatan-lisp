# Combinación MODAL y DIRECCIONAL del espectral — el cuadro «Load Case Data» de ETABS, con números
#: En ETABS el caso espectral tiene dos combinaciones: **Modal Combination Method** (CQC, SRSS, ABS) junta los modos, y **Directional Combination Type** (SRSS, CQC3, ABS con factor de escala) junta el sismo en X con el sismo en Y. Aquí las fórmulas aplicadas al edificio del curso (12 modos, NEC-15, R = 8): cortante basal FX de cada modo, sacado de Hekatan Struct. Juez: SAP2000.

#numerico
## 1 · Datos: los 12 modos del edificio del curso (Hekatan Struct, sismo en X)
#| Modo | T, periodo [s] | V, cortante basal FX que aporta el modo [kN] |
#|---:|---:|---:|
#| 1 | 0.5659 | 141.5282 |
#| 2 | 0.5556 | 280.5435 |
#| 3 | 0.4837 | 46.7308 |
#| 4 | 0.1827 | 13.1977 |
#| 5 | 0.1792 | 23.3321 |
#| 6 | 0.1561 | 4.4258 |
#| 7 | 0.1052 | 2.9608 |
#| 8 | 0.1027 | 4.2030 |
#| 9 | 0.0898 | 1.0646 |
#| 10 | 0.0762 | 0.5946 |
#| 11 | 0.0741 | 0.6655 |
#| 12 | 0.0686 | 0.0141 |
#: En las fórmulas, Tᵢ es el periodo del modo i y Vᵢ su cortante basal (las dos columnas de la tabla).
#hide
T1 = 0.5659 @@(periodo del modo 1, s)
T2 = 0.5556 @@(periodo del modo 2, s)
T3 = 0.4837 @@(periodo del modo 3, s)
V1 = 141.5282 @@(cortante basal FX que aporta el modo 1, kN)
V2 = 280.5435 @@(cortante basal FX que aporta el modo 2, kN)
V3 = 46.7308 @@(cortante basal FX que aporta el modo 3, kN)
V4 = 13.1977 @@(cortante basal FX que aporta el modo 4, kN)
V5 = 23.3321 @@(cortante basal FX que aporta el modo 5, kN)
V6 = 4.4258 @@(cortante basal FX que aporta el modo 6, kN)
V7 = 2.9608 @@(cortante basal FX que aporta el modo 7, kN)
V8 = 4.2030 @@(cortante basal FX que aporta el modo 8, kN)
V9 = 1.0646 @@(cortante basal FX que aporta el modo 9, kN)
V10 = 0.5946 @@(cortante basal FX que aporta el modo 10, kN)
V11 = 0.6655 @@(cortante basal FX que aporta el modo 11, kN)
V12 = 0.0141 @@(cortante basal FX que aporta el modo 12, kN)
#show

## 2 · Combinación modal SRSS: raíz de la suma de los cuadrados
SRSS = sqrt(V1^2 + V2^2 + V3^2 + V4^2 + V5^2 + V6^2 + V7^2 + V8^2 + V9^2 + V10^2 + V11^2 + V12^2) @@(cortante basal X combinado con SRSS, kN — SAP2000: 318.88)

## 3 · Combinación modal ABS: suma de los valores absolutos
ABS = V1 + V2 + V3 + V4 + V5 + V6 + V7 + V8 + V9 + V10 + V11 + V12 @@(cortante basal X combinado con ABS, kN — SAP2000: 519.26)

## 4 · Combinación modal CQC: con la correlación ρ entre modos
#: CQC² = Σᵢ Σⱼ ρᵢⱼ·Vᵢ·Vⱼ, con ρᵢⱼ de Der Kiureghian (ζ = 5 %, β = ωⱼ/ωᵢ = Tᵢ/Tⱼ). Si dos modos tienen periodos cercanos, ρ ≈ 1 y sus respuestas casi se SUMAN; si están lejos, ρ ≈ 0 y es como SRSS.
z = 0.05 @@(ζ, amortiguamiento de los modos: 5 %)
b12 = T2/T1 @@(β₁₂, cociente de periodos de los modos 1 y 2)
r12 = 8*z^2*(1 + b12)*b12^1.5/((1 - b12^2)^2 + 4*z^2*b12*(1 + b12)^2) @@(ρ₁₂, correlación de los modos 1 y 2: casi 1, periodos muy cercanos)
b13 = T3/T1 @@(β₁₃, cociente de periodos de los modos 1 y 3)
r13 = 8*z^2*(1 + b13)*b13^1.5/((1 - b13^2)^2 + 4*z^2*b13*(1 + b13)^2) @@(ρ₁₃, correlación de los modos 1 y 3)
b23 = T3/T2 @@(β₂₃, cociente de periodos de los modos 2 y 3)
r23 = 8*z^2*(1 + b23)*b23^1.5/((1 - b23^2)^2 + 4*z^2*b23*(1 + b23)^2) @@(ρ₂₃, correlación de los modos 2 y 3)
CQC3m = sqrt(V1^2 + V2^2 + V3^2 + 2*r12*V1*V2 + 2*r13*V1*V3 + 2*r23*V2*V3) @@(cortante basal X combinado con CQC usando solo los modos 1, 2 y 3, kN)
#: Con los 3 primeros modos ya da 436.4 kN; con los 12, Hekatan Struct da **438.50 kN = SAP2000** (el resto de los ρ son casi 0). Por eso CQC sale mucho más alto que SRSS aquí: los modos 1 y 2 (0.566 y 0.556 s) tienen ρ ≈ 0.97.

## 5 · Combinación direccional (sismo X y sismo Y en el mismo caso)
#: Cada dirección ya combinada modalmente con CQC (SAP2000): FX con el sismo en X y FX con el sismo en Y.
RX = 438.4999 @@(FX con el sismo en X, ya combinado CQC — SAP2000, kN)
RY = 55.7651 @@(FX con el sismo en Y, ya combinado CQC — SAP2000, kN: el modo acoplado también empuja en X)
D_SRSS = sqrt(RX^2 + RY^2) @@(FX con la combinación direccional SRSS, kN — SAP2000 442.03; CQC3 da lo mismo con el mismo espectro en X e Y)
SF = 1 @@(factor de escala de la combinación direccional ABS en ETABS: 1 = suma completa)
D_ABS = RX + SF*RY @@(FX con la combinación direccional ABS, kN — SAP2000 494.26)
SF3 = 0.3 @@(factor de escala 0.3: convierte la ABS en la regla 100 % + 30 %)
D_100_30 = RX + SF3*RY @@(FX con la regla 100 % + 30 % (borrador §5.5.1.2a, NEC-11 §2.7.3), kN — SAP2000 455.23)
#: En Hekatan Struct: panel 🌎 Sismo NEC › «Combinación modal» (CQC / SRSS / ABS) y «Combinación direccional» (independiente NEC-15 / 100 % + 30 % / SRSS = CQC3 / ABS). Validadas con SAP2000 a 0.000 % nudo a nudo.
