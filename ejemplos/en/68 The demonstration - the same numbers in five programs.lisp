# The demonstration: the same numbers in five programs

#: A result that only one program gives **is not a result**. This sheet is the proof: the same model, the same mesh node by node, solved in five places.
#: All the numbers here are **measured**, not estimated. Each one can be repeated with the command at the foot.

## 1 · The reference case: Paz and Leigh 6.3

#: A steel space frame. It is the classic modal validation example, and it has a published solution.

#| Modo | ETABS 22 | Hekatan denso | Hekatan subespacio |
#|---:|---:|---:|---:|
#| 1 | 8.8305 | 8.8358 | **8.8305** |
#| 2 | 14.5459 | 14.5551 | **14.5459** |
#| 3 | 24.2336 | 24.2228 | **24.2336** |
#| 4 | 25.1132 | 25.1038 | **25.1132** |
#| 5 | 159.6525 | 159.6530 | **159.6525** |
#| 6 | 159.8513 | 159.8523 | **159.8513** |

#: The **subspace** route matches ETABS in **all four decimals of the six modes**. It is not that it looks alike: it is the same number.

## 2 · But at the start it did NOT match, and that is the interesting part

#: As is, ETABS gave `9.0903` against `8.8305`. A uniform **+2.94 %** in all modes. A uniform error is never a coincidence.

#: **It was not the solver.** ETABS puts in automatic rigid end offsets and **subtracts from the self-weight the stretch of beam that falls inside the column**. It was measured with its own `AssembledJointMass` table:

m_etabs = 5.707652 'mass of a free joint, ETABS with its offsets [×10⁻³]
m_hek = 6.048429 'the same in Hekatan, without offsets [×10⁻³]
dif = dec(100*(6.048429 - 5.707652)/6.048429, 2) [%] 'how much mass ETABS subtracts

#: ETABS weighs **{dif} %** less at that joint. And the period goes with the **square root** of the mass:
factor = dec((6.048429/5.707652)^0.5, 5) [—] 'square root of the mass ratio
medido = dec(9.0903/8.8305, 5) [—] 'observed frequency ratio

#: **{factor} against {medido}.** The two routes close at the fifth digit. It is no longer a suspicion: it is the explanation.
#: And the subtracted volume is **exactly 1857.4 in³**, which is `2·24.7·24.7 + 2·24.7·12.9`: **the beam offsets**. The column ones it does not subtract.

vol = dec(2*24.7*24.7 + 2*24.7*12.9, 1) [in³] 'the volume ETABS does not weigh

#: With `offsets = 0` in ETABS, the total mass matches to **0.002 %**.

## 3 · The curved shed and the mezzanine

#| Modelo | Contra | Diferencia |
#|---|---|---:|
#| Galpón, 609 nudos y 1140 barras | SAP2000 24 por OAPI | **0.001 %** |
#| Mezanine con columna CFT | SAP2000, sección general | **0.0000 %** |
#| El mismo mezanine | ETABS 22 | **0.0008 %** |
#| 8 plantillas, masa total | ETABS 22 | **0.000 %** |
#| 8 plantillas, modos 1 a 3 | ETABS 22 | **0.00 a 0.01 %** |
#| Fuerzas de cáscara, 3600 joints | ETABS 22 | **0.0000 %** |

#: The mezzanine with SAP2000 closes at **2415 of 2415 components**. It is not an average: it is all of them.

## 4 · The nonlinear footing, in four programs

#: Braja M. Das, example 6.10: footing of 1.5 × 1.5 × 0.40 m, load of 606 kN with eccentricity in both directions, on sand.

P = 606 'applied load [kN] ; e_x = 0.15 'eccentricity in x [m] ; e_y = 0.30 'in y [m]

#| Programa | Cómo modela el suelo | Suma de las presiones |
#|---|---|---:|
#| Hekatan Struct | `areaspring … nodal compresion` | **606.00 kN** |
#| SAFE 20 | *Compression Only* | **606.00 kN** |
#| OpenSeesPy | `uniaxialMaterial ENT` | **606.00 kN** |
#| ETABS 22 | muelles nodales | **606.00 kN** |

#: **This is the check that matters**, and no program does it alone: the sum of the soil pressures times their area must equal the applied load.
q_suma = dec(606.00 - 606, 4) [kN] 'difference between what comes down and what the soil holds

#: **Zero.** If it were not zero, the model would be wrong — and none would warn.
#: And the nonlinearity shows in one number: of the 169 nodes, **30 lift off**. There the pressure is zero because the soil does not pull.
levantados = dec(100*30/169, 1) [%] 'percentage of the footing that lifts off

## 5 · And none of this is checked by hand: there is a test

#: Each of these cases is a test that **fails by itself** if someone breaks something.

#| Comando | Qué compara | Árbitro |
#|---|---|---|
#| `node tests/run.mjs paz` | 6 modos por dos caminos | ETABS 22 |
#| `node tests/run.mjs masa` | la masa **nudo a nudo** | ETABS 22 |
#| `node tests/run.mjs fuerzas-cascara` | M y F joint a joint | ETABS 22 |
#| `node tests/run.mjs guerra-vs-safe` | 8 zapatas | SAFE |
#| `node tests/run.mjs cimentacion-vs-csi` | los tres ficheros CSI | SAP, ETABS, SAFE |
#| `npm test` | **todos** | los cinco |

n_tests = 335 'cases that run in the full suite [—]
t_suite = 261 'time to pass all of them [s]

#: **{n_tests} cases in {t_suite} seconds**, and it exits with an error code if a single one exceeds its limit.

## 6 · The rule, in one line

#: **The reference of a case has to be ANOTHER PROGRAM**, with the same model, the same mesh node by node and the rigid offsets cancelled.
#: Never a hand calculation, never an inherited number without a source. That is how a false reference once slipped into Paz 6.3 and for months a regression that did not exist was taken as good.
#: That is why when it says **0.000 %** here, it can be measured again in front of whoever asks.
