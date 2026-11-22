# The membrane in ETABS and SAP2000: what it carries, how it distributes and what mass it gives the modal analysis

#: A shed **is not a building**. It has no slab, no rigid diaphragm, and the roof is a sheet that does not bend. Everything taken for granted in a building changes here.
#: Four questions, with what the programs really do — not from memory: what follows is taken from the `.e2k` that **ETABS itself writes**.

## 0 · The data

E_s = 200000000 'steel modulus [kN/m²] ; ν = 0.3 'Poisson's ratio of steel [—] ; t_z = 0.0008 'zinc thickness [m]
E_c = 21000000 'concrete modulus [kN/m²] ; ν_c = 0.2 'Poisson's ratio of concrete [—] ; t_c = 0.20 'slab depth [m]
q = 0.5 'roof load [kN/m²] ; s = 1.5 'purlin spacing [m] ; γ = 78.5 'unit weight of steel [kN/m³]

## 1 · What stresses a membrane has (and which it does NOT have)

#: A full shell has eight stress resultants per unit length. A **membrane** has only the first three:

#| Esfuerzo | Qué es | Membrana | Cáscara completa |
#|---|---|---|---|
#| F_{11}, F_{22} | axiles en el plano [kN/m] | **sí** | sí |
#| F_{12} | cortante en el plano [kN/m] | **sí** | sí |
#| M_{11}, M_{22} | flectores [kN·m/m] | **NO** | sí |
#| M_{12} | torsor [kN·m/m] | **NO** | sí |
#| V_{13}, V_{23} | cortantes fuera del plano [kN/m] | **NO** | sí |

#: That is: the membrane works **by stretching and shearing in its own plane**. Out of its plane it has no stiffness at all.

## 2 · And it is not an arbitrary criterion: it is measured

#: The two stiffnesses of a plate, per unit width. The membrane one goes with `t`, the bending one with `t³`:
#: K_{m} = E·t / (1 − ν²)      and      D = E·t³ / (12·(1 − ν²))

K_m = dec(200000000*0.0008/(1 - 0.3^2), 1) [kN/m] 'membrane stiffness of the 0.8 mm zinc
D_z = dec(200000000*0.0008^3/(12*(1 - 0.3^2)), 6) [kN·m] 'bending stiffness of the same zinc
D_h = dec(21000000*0.20^3/(12*(1 - 0.2^2)), 1) [kN·m] 'that of a 20 cm concrete slab
razon = dec(14583.3/0.009377, 0) [—] 'how many times stiffer the slab is

#: The zinc has a bending stiffness of {D_z} kN·m against the {D_h} kN·m of the slab: **{razon} times less**. Setting its bending to zero removes nothing that existed.
#: And you can see it in the formula: going from 20 cm to 0.8 mm the thickness is divided by 250, but **bending goes with the cube**, so it is divided by 250³.

#fplot(21000000*x^3/(12*(1 - 0.04)), [0.001 0.2])
#: The horizontal axis is the thickness in metres and the vertical one `D` in kN·m. At the far left is the zinc: stuck to zero.

## 3 · So, how does it pass the load to the purlins?

#: If the membrane has no bending, **it cannot carry load perpendicular to its plane by stiffness**. So the program does not compute it: it **distributes** it.
#: ETABS writes this in the `.e2k`, literally:

#| Lo que escribe ETABS | Qué significa |
#|---|---|
#| `MODELINGTYPE "Membrane"` | solo esfuerzos en el plano |
#| `ONEWAYLOADDIST "Yes"` | la carga baja **en una dirección**, a las correas |

#: `ONEWAYLOADDIST` is the key: the load is distributed **by tributary area** to the edge members, not by stiffness. The same as is done by hand, because each purlin picks up half a span on each side:
#: w = q · s

w = dec(0.5*1.5, 3) [kN/m] 'line load received by each purlin
w_2 = dec(0.5*3.0, 3) [kN/m] 'the same with the purlins at double the spacing

#: With {s} m of spacing each purlin receives {w} kN/m; doubling the spacing, {w_2} kN/m. It is a straight line — it is tributary area, nothing more:
#fplot(0.5*x, [0.5 3])

#: **Modelling consequence:** if instead of a membrane the roof is left as a slab (`Shell`), the sheet starts to **bend** and takes load that in the field it does not take. The purlins come out less loaded than they really are.

## 4 · The modal mass: what ETABS sets by default

#: This is the question that produces the most false periods. What ETABS writes **if nothing is touched**:

#| Opción de ETABS | Por defecto | Qué hace |
#|---|---|---|
#| `INCLUDEELEMENTS` | **Yes** | el peso propio SÍ es masa |
#| `INCLUDEADDEDMASS` | **Yes** | la masa añadida SÍ |
#| `INCLUDELOADS` | **No** | **las cargas NO son masa** |
#| `INCLUDELATERALMASS` | **Yes** | masa horizontal sí |
#| `INCLUDEVERTICALMASS` | **No** | **masa vertical no** |
#| `LUMPATSTORIES` | **Yes** | la concentra en los niveles |

#: These are two implicit assumptions in a row:
#: **Warning 1 — `INCLUDELOADS "No"`.** If the roof is entered as a distributed load and not put into the *Mass Source*, for the modal analysis **that load does not exist**. The structure weighs only its sections: it comes out lighter and therefore **faster**. Short, false periods.
#: **Warning 2 — `INCLUDEVERTICALMASS "No"`.** ETABS does not count the vertical mass. SAP2000 **does** count it by default. Same model, two programs, different periods — and neither is wrong.

#| Programa | Masa de las cargas | Masa vertical |
#|---|---|---|
#| ETABS | no, salvo que se añada | **no** |
#| SAP2000 | no, salvo que se añada | **sí** |
#| Hekatan Struct | la del `.heks` | sí |

#: And now the number that closes it. The sheet **does** weigh, because it is self-weight:

p_z = dec(78.5*0.0008, 4) [kN/m²] 'self-weight of the zinc sheet
p_tot = dec(0.0628 + 0.5, 4) [kN/m²] 'what is really on the roof
pct = dec(100*0.0628/0.5628, 1) [%] 'percentage that DOES enter the modal analysis by default

#: Of the {p_tot} kN/m² on the roof, only **{pct} %** enters the modal analysis: the {p_z} kN/m² of the sheet. The {q} kN/m² of load stay out.
#: **That is the problem**, and nobody warns you.

## 5 · And the modal analysis of a shed: there is no diaphragm here

#: In a building the slab forces all the nodes of a floor to move together: three degrees of freedom per storey and that is it.
#: **In a shed there is no slab.** The roof is a membrane: it has stiffness in its plane, but it does not concentrate mass like a slab. Each node goes its own way.
#: So the modal analysis of a shed **is not done with a storey matrix**: it is done with **lumped masses at the nodes**, in the three directions. That is what Aguiar does in the thin-shell structures chapter:

#| Bloque de la matriz de masas | Cuándo actúa |
#|---|---|
#| M_{HT} | sismo en sentido transversal |
#| M_{HL} | sismo en sentido longitudinal |
#| M_{V} | sismo vertical |

#: With six columns there are 18 degrees of freedom: the transverse ones are numbered first, then the longitudinal ones and finally the vertical ones, and the mass matrix ends up in three blocks along the diagonal.
#: **And then the vertical mass matters.** In a building it can be ignored without guilt, because the slab is rigid in its plane. In a shed, the 20 m span arch **does** have real vertical modes.
#: That is why in the shed modal table, mode 4 shows a `U_z` of 38 %: **that mode is the roof bouncing**. ETABS, with `INCLUDEVERTICALMASS "No"`, does not show it.

## 6 · Summary

#| Pregunta | Respuesta corta |
#|---|---|
#| ¿Qué lleva la membrana? | solo F_{11}, F_{22}, F_{12} [kN/m] — nada de flexión |
#| ¿Cómo pasa la carga a las correas? | por área tributaria, w = q·s, no por rigidez |
#| ¿Qué masa usa el modal por defecto? | solo el peso propio, y sin masa vertical en ETABS |
#| ¿Y en un galpón? | masas puntuales por nudo, no matriz de piso |
