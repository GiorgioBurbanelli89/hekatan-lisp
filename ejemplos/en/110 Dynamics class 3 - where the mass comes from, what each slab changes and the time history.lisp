# Structural dynamics, class 3: from the classroom model to the real building — the mass, the slab type and the time history
#numerico

#: **What is done.** Classes 1 and 2 (sheets 108 and 109) left two numbers per mode: the mass m and the stiffness k. This class says **where they come from in a real building** and **what changes them**: the mass source, the slab distributed to nodes, the vertical mass and the slab type. It does not develop them: each topic has its own sheet or study, cited in each section. It closes with the time history.
#: **Sources.** NEC-SE-DS 2015 §6.1.7 (p. 55: W = D). Chopra, *Dynamics of Structures*, 4th ed., eq. 13.1.1 and 13.1.2 (earthquake as effective load −m·ι·ü_{g}). CSI Analysis Reference Manual §10.8 to §10.11 (shell thicknesses, modifiers and mass; read in the log "WAFFLE slab: what it is in SAP2000, what it is in ETABS" in the registros folder, 18-Sep-2026).
#: **Units.** tonf, m, s.

## 1 · Everything boils down to T = 2·π·√(m/k)

#: Whatever changes in a model (more mass, a slab that stiffens) is read in the period with this formula, mode by mode. With factors f_{m} on the mass and f_{k} on the stiffness:
#: **T = T₁·√(f_{m}/f_{k})**   →   log T = ½·log f_{m} − ½·log f_{k} + log T₁
#: Once again y = m·x + b: slope **+½** for the mass and **−½** for the stiffness.
T_1 = 0.272179 'fundamental period of the 3-story building of class 2 [s]
f_m = 1.25 'example: 25 % more mass (heavier finishes or partitions)
f_k = 1.5 'example: 50 % more lateral stiffness (a slab that works with the beams)
T_m = T_1·sqrt(f_m) 'only more mass: the period GOES UP [s]
T_k = T_1/sqrt(f_k) 'only more stiffness: the period GOES DOWN [s]
T_mk = T_1·sqrt(f_m/f_k) 'both at once [s]
#: The period as a function of the two factors (x: f_{m}; y: f_{k}; height: T in s):
#surf(0.272179*sqrt(x/y), [0.5 2], [0.5 2])
#: Cuts of that surface: T against f_{m} for the original stiffness, ×1.5 and ×2 (horizontal axis: f_{m}; vertical: T in s):
#fplot(k_x1 = 0.272179*sqrt(x), k_x15 = 0.272179*sqrt(x/1.5), k_x2 = 0.272179*sqrt(x/2), [0.5 2])

## 2 · Where m comes from in a real building

#: **The mass source (Mass Source).** NEC-15 §6.1.7 (p. 55) sets the **reactive seismic load W = D**, the total dead load (warehouses and storage: W = D + 0.25·L_{i}). The mass is W/g. In ETABS and SAP2000 this is declared in the *Mass Source*: from which load patterns and with what factor the mass is taken.
#: **The slab distributed to nodes.** A finite element program does not store "the mass of the slab": each element distributes its own to its nodes (lumped mass by tributary area). For translation it makes no difference (the sum is the same), but **for rotation it does**: the polar moment J = Σ m_{i}·r_{i}² depends on where the masses end up. For an a × b slab split into n × n elements, the trapezoidal rule gives exactly:
#: J_{n} = m·(a² + b²)/12 · (1 + 2/n²)
a_l = 6 'slab side in X [m]
b_l = 6 'slab side in Y [m]
m_l = 36/9.80665 'mass of the 36 tonf slab [tonf·s²/m]
J_ex = m_l·(a_l^2 + b_l^2)/12 'polar moment of the continuous slab [tonf·s²·m]
#: Check with the masses placed node by node (4 × 4 element mesh, 25 nodes, each node with its tributary area):
#hide
n_e = 4
J_4 = 0
#show
for i = 0:n_e
  for j = 0:n_e
    w_i = 0.5 + 0.5·min(i, 1)·min(n_e - i, 1)
    w_j = 0.5 + 0.5·min(j, 1)·min(n_e - j, 1)
    J_4 = J_4 + m_l/n_e^2·w_i·w_j·((a_l·i/n_e - a_l/2)^2 + (b_l·j/n_e - b_l/2)^2)
  end
end
J_4n = J_4 'J summing the 25 nodes [tonf·s²·m]
J_4f = J_ex·(1 + 2/n_e^2) 'J with the formula, n = 4 [tonf·s²·m]
r_J1 = sqrt(1 + 2/1^2) 'how much the torsional period lengthens with only 1 element per slab (mass at the 4 corners)
#: With a single element per slab the mass sits at the corners: J comes out **3 times** the real value and the torsional period **√3 = 1.73 times** longer. With 4 × 4 the error drops to 12.5 % in J. Horizontal axis: n elements per side; vertical: J_{n}/J:
#fplot(J_rel = 1 + 2/x^2, [1 10])
#: **With or without vertical mass.** ETABS, by default, gives only horizontal mass to the nodes; SAP2000 gives mass in all three directions. That moves the U_{z} column of the sums (class 2) and can change the order of the modes. **It is developed in sheet 107** (how the mass is distributed for the earthquake: 3D mass versus horizontal only), log "Hekatan LISP sheet: how the mass is distributed for the earthquake" (registros folder, 4-Oct-2026).

## 3 · What each slab type changes in m and in k

#| Losa | Rigidez que aporta | Masa | T |
#|---|---|---|---|
#| **Membrana** | solo en su plano (diafragma); a flexión cero | su peso | el más largo |
#| **Shell Thin** | en su plano **y** a flexión: trabaja con las vigas | su peso | más corto |
#| **Slab 1 dirección** | en ETABS, un reparto de carga a vigas de una dirección | misma total, otro reparto | casi igual |
#| **Slab 2 direcciones** | reparto a vigas de las dos direcciones | misma total | casi igual |
#| **Waffle** | loseta + nervios; en el análisis, shell con modificadores | **menos** que maciza | baja |
#| **Deck** | lámina de acero + hormigón: ortótropa, diafragma en su plano | lámina + relleno | cerca de membrana |

#: The table says **which way** T moves, not how much. **How much** is measured by the time-history study with the same 3D frame and the six slabs (Shell Thin, Membrane, Slab 1 and 2 directions, Waffle and Deck), with modes 1-3, the six sums, roof, base shear and drift: log "3D frame with slab: time history and slab type" (registros folder, 4-Oct-2026).
#: The membrane in ETABS and SAP2000 (what it distributes the load to and what mass it gives the modal analysis) is in **sheet 64**; the rigid diaphragm versus the flexible one, in **sheet 102**.

## 4 · The time history: watching the building move second by second

#: The spectrum (video cpp06, sheet 101) gives **the maximum** of each mode and combines them. The time history solves the equation **instant by instant** with a real record.
#: **The earthquake as a load, derived.** The ground moves u_{g}(t). The force in the columns depends on how much they deform relative to the ground (u), but the inertia depends on the total motion u + u_{g}:
#: m·(ü + ü_{g}) + c·u̇ + k·u = 0   →   **m·ü + c·u̇ + k·u = −m·ü_{g}(t)**
#: The earthquake enters as a force −m·ü_{g}: **that is why the mass rules**. In several stories it is −M·ι·ü_{g} (Chopra eq. 13.1.2), with ι = r, the same vector as in class 2.
#: **An example done by hand:** the 1-story frame of class 1 with a ground that vibrates harmonically at its own period (resonance), 0.10 g amplitude. The equivalent static value is p₀/k = m·a_{g}/k = a_{g}/ω²:
omega_1 = 49.011586 '1-story frame, class 1 [rad/s]
a_g = 0.10·9.80665 'amplitude of the ground acceleration, 0.10 g [m/s²]
u_st = a_g/omega_1^2 'equivalent static displacement [m]
u_max = u_st/(2·0.05) 'peak at resonance with ξ = 5 %, Chopra eq. 3.2.7 [m]
u_mm = 1000·u_max 'the same in mm
d_r = u_max/3 'story drift, over 3 m height
#: 4 mm and an elastic drift of 0.14 %. Only as an order of magnitude: NEC-15 (§4.2.2, Table 7, p. 40) limits the **inelastic** drift under the design earthquake to 0.02, which is another calculation (drift video). The frame is stiff. The column, second by second (horizontal axis: relative height z/h; vertical: displacement in mm; each frame advances 0.02 s):
#anim fplot(u = 4.0825*(exp(-0.05*49.011586*0.02*n) - 1)*cos(49.011586*0.02*n)*(3*x^2 - 2*x^3), tope = 4.0825 + 0*x, fondo = -4.0825 + 0*x, [0 1]), n = 1:60
#: The shape 3·(z/h)² − 2·(z/h)³ is that of a column fixed at the bottom and with the slab without rotation at the top. The amplitude grows toward the peak of 4.08 mm (the envelope of class 1, section 6).
#: **With a real record** (El Centro 1940 scaled to NEC-15, Portoviejo) the same step-by-step calculation is in **sheet 100** (against SAP2000: 0.004 % in 1559 steps) and the Newmark method in **sheet 97** (soil column against Abaqus).

## 5 · What to take away

#: 1 · **More mass → larger T** (with √m). The mass comes from W = D (NEC-15 §6.1.7) and the program distributes it to the nodes.
#: 2 · **A slab that stiffens → smaller T** (with 1/√k). Shell Thin stiffens more than membrane; waffle weighs less.
#: 3 · **Rotation depends on where the mass ends up**: with a coarse mesh the torsional period comes out long.
#: 4 · **The time history** is the same equation m·ü + c·u̇ + k·u, with −m·ü_{g}(t) on the right, solved at each Δt.
#: **Study order:** sheet 108 (1 DOF) → sheet 109 (modes) → sheet 110 (this one) → sheet 107 (seismic mass) → TH study with slabs → video cpp06 (spectral modal shear) → sheet 101 (modal combination) → sheet 102 (diaphragm) → sheet 100 (time history with El Centro).
