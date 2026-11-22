# The shed by the force method — and the FEM gives the same

#: The same 20 m arch that appears in the modal analysis, solved **by hand**, with the classical
#: force method. And at the end it is compared with what the finite element gives.
#: That is the point: **two paths that look nothing alike and the same number**.

## 1 · The problem

#| Dato | Valor |
#|---|---|
#| luz | L = 20 m |
#| flecha | f = 2.5 m |
#| carga repartida | q = 3 kN/m sobre la proyección horizontal |
#| apoyos | los dos articulados |

#: The arch axis is a parabola. Measured from the springing line:
#: y(x) = 4·f·x·(L−x) / L²
L = 20
f = 2.5
q = 3

## 2 · How many unknowns are left over

#: An arch with **two pinned supports** has four reactions (two per support) and
#: statics gives only three equations. **One** is left over: it is statically indeterminate to degree 1.
GH = 4 - 3

#: That one left over is called the **redundant**. The **horizontal thrust** `H` is chosen,
#: which is what the arch does to its supports outwards.

## 3 · The primary system

#: The redundant is **released**: the right-hand horizontal support is removed and a
#: roller support is left. What remains is already statically determinate — it is solved with statics alone.
#: On that system **two states** are placed:

#| Estado | Qué lleva | Momento |
#|---|---|---|
#| **0** | la carga real `q`, sin el empuje | M_{0}(x) = q·x·(L−x)/2 |
#| **1** | un empuje **unitario** H = 1, sin carga | m_{1}(x) = −y(x) |

#: `M_0` is that of a simple beam of span L: the released arch does not arch at all.
#: And `m_1` is **minus** the height of the axis, because an inward thrust lifts the arch.

## 4 · The condition that closes the problem

#: The support that was removed **does not move** in reality. So the total horizontal
#: displacement at that point must be zero:
#: delta_{10} + delta_{11}·X_{1} = 0
#: and from there the redundant comes out:
#: X_{1} = −delta_{10} / delta_{11}

#: The two deltas come from the **Mohr integrals** — virtual work:
#: delta_{10} = ∫ M_{0}·m_{1} / (E·I) ds
#: delta_{11} = ∫ m_{1}² / (E·I) ds

## 5 · The two integrals, solved

#: With constant E·I, and substituting `y = 4f·x(L−x)/L²`, both lead to the same
#: base integral:
#: ∫ x²·(L−x)² dx = L⁵/30   between 0 and L

#: **The first one**, with M_{0} = q·x(L−x)/2:
#: ∫ M_{0}·y dx = (2·q·f/L²)·∫ x²(L−x)² dx = (2·q·f/L²)·(L⁵/30) = q·f·L³/15
I.a = dec(q*f*L^3/15, 2)

#: **The second one**, with y²:
#: ∫ y² dx = (16·f²/L⁴)·(L⁵/30) = 8·f²·L/15
I.b = dec(8*f^2*L/15, 4)

#: The `E·I` is in both and **cancels in the division**. That is why the thrust of a
#: parabolic arch **does not depend on the stiffness**: it comes from the geometry and the load.
H = dec((q*f*L^3/15)/(8*f^2*L/15), 3)

## 6 · And the resulting formula

#: Doing the division in symbols, before plugging in numbers:
#: X_{1} = (q·f·L³/15) / (8·f²·L/15) = **q·L² / (8·f)**

#: This is the classical formula for the thrust of a two-hinged parabolic arch.
#: It is not learned by heart: it **comes out**, and it comes out of two integrals.
H.formula = dec(q*L^2/(8*f), 3)

#: With the shed data:
comprobacion = dec(q*L^2/(8*f) - H, 10)
#: Zero, as it had to be.

## 7 · How much the rise weighs

#: In the formula, `f` is in the **denominator**. A shallower arch pushes more:
#fplot(3*20^2/(8*x), [0.8 5])
#: The horizontal axis is the rise in metres. On the left, an almost flat arch:
#: the thrust shoots up. That is why a shallow roof asks much more of the supports.
H.rebajado = dec(q*L^2/(8*1.0), 1)
H.peraltado = dec(q*L^2/(8*5.0), 1)

## 8 · The moment at the crown

#: With the redundant now known, the moment at any point is
#: M(x) = M_{0}(x) − H·y(x). At the crown, x = L/2:
M.0.clave = dec(q*L^2/8, 2)
M.arco.clave = dec(q*L^2/8 - (q*L^2/(8*f))*f, 6)

#: **Zero.** And it is no coincidence: under uniform load, the parabola is
#: **the funicular shape** of that load. The arch does not bend: it works in **pure compression**.
#: That is what lets a curved roof span so far with so little material.

## 9 · And now the finite element

#: The FEM knows nothing of all this. It does not choose redundants, does not integrate Mohr, does not
#: know the formula. It does something else:

#| Método de las fuerzas | Elemento finito |
#|---|---|
#| elige **una** incógnita: el empuje | monta **todos** los grados de libertad |
#| integra M·m/EI a lo largo del eje | integra B^{T}·D·B por Gauss en cada barra |
#| resuelve **una** ecuación | resuelve K·u = F, de tamaño n |
#| sale la fórmula en símbolos | salen números |

#: And they give **the same**. Because both impose the same condition: equilibrium and
#: compatibility. The force method imposes it **on one unknown chosen by
#: hand**; the FEM imposes it **at all the nodes at once**.

#: **That is why a program is checked with this.** If the FEM does not reproduce the
#: thrust of a parabolic arch, the problem is not in the arch.

## 10 · What to take away

#| | |
#|---|---|
#| El empuje | H = q·L²/(8·f) — no depende de E·I |
#| Rebajar el arco | empuje mayor, en proporción inversa a la flecha |
#| Parábola con carga uniforme | momento **cero**: compresión pura |
#| El FEM | el mismo resultado, sin elegir nada a mano |
