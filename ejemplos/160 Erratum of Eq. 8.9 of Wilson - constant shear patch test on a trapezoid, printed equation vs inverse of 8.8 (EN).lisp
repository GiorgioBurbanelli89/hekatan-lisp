# Possible misprint in Eq. (8.9) of Wilson's book (Chapter 8) · constant-shear patch test on a trapezoid: the printed equation against the inverse of (8.8)
#numerico
#: **What is tested.** In Wilson's discrete shear element (E. L. Wilson, *Three-Dimensional Static and Dynamic Analysis of Structures*, Chapter 8, p. 8-6 of the 2005 edition and p. 8-7 of the paginated PDF) the shear at each node is obtained from the shears along the two sides that meet at that node. Eq. (8.8) says [γij; γki] = M·[γxz; γyz] with M = [cos αij, sin αij; cos αki, sin αki]. Eq. (8.9) should be M⁻¹, but the printed one has the off-diagonal terms interchanged.
#: **Correct inverse:** M⁻¹ = 1/det·[sin αki, −sin αij; −cos αki, cos αij]. **Printed (8.9):** 1/det·[sin αki, −cos αki; −sin αij, cos αij]. With det = cos αij·sin αki − cos αki·sin αij.
#: **Test (constant shear patch):** w = 0.3·x + 0.7·y at the nodes, zero rotations. The true shear is γ = (0.3, 0.7) over the whole element. If the nodal formula is correct, the four nodes give exactly (0.3, 0.7). On a rectangle the two forms coincide (that is why the book's tables do not reveal it); on a trapezoid they do not.

## 1 · Data and the nodal formula
#: With w = a_x·x + a_y·y and zero rotations, the shear along each side is exactly the projection of the true shear: [γij; γki] = M·[a_x; a_y]. Applying the nodal formula T to it must give back (a_x, a_y). The function **ep** applies the **printed** (8.9) and **ec** the **inverse of (8.8)**; the arguments are the direction cosines of side ij (c_i, s_i) and of side ki (c_k, s_k) at the node. The result is the largest absolute error at that node.
a_x = 0.3 'slope of w in x (= true γxz)
a_y = 0.7 'slope of w in y (= true γyz)
g_v = [a_x; a_y]
ep(c_i, s_i, c_k, s_k) = max(abs(([s_k, -c_k; -s_i, c_i]/(c_i*s_k - c_k*s_i))*([c_i, s_i; c_k, s_k]*g_v) - g_v)) 'printed (8.9)
ec(c_i, s_i, c_k, s_k) = max(abs(([s_k, -s_i; -c_k, c_i]/(c_i*s_k - c_k*s_i))*([c_i, s_i; c_k, s_k]*g_v) - g_v)) 'inverse of (8.8)
#: **Rectangle** (0,0) (2,0) (2,1) (0,1): the sides have directions (1,0), (0,1), (−1,0), (0,−1).
cr_1 = 1
sr_1 = 0
cr_2 = 0
sr_2 = 1
cr_3 = -1
sr_3 = 0
cr_4 = 0
sr_4 = -1
#: **Trapezoid** (0,0) (2,0) (1.5,1) (0.25,1): the sides are (2,0), (−0.5,1), (−1.25,0), (−0.25,−1), normalised to unit length.
ct_1 = 1
st_1 = 0
ct_2 = -0.5/sqrt(1.25)
st_2 = 1/sqrt(1.25)
ct_3 = -1
st_3 = 0
ct_4 = -0.25/sqrt(1.0625)
st_4 = -1/sqrt(1.0625)

## 2 · Result: error of the nodal shear with respect to (0.3, 0.7)
#: Node i uses side i (ij) and the previous side (ki). Zero = the patch test passes at that node.
#: **Rectangle, printed (8.9):**
Er_p1 = ep(cr_1, sr_1, cr_4, sr_4)
Er_p2 = ep(cr_2, sr_2, cr_1, sr_1)
Er_p3 = ep(cr_3, sr_3, cr_2, sr_2)
Er_p4 = ep(cr_4, sr_4, cr_3, sr_3)
#: **Rectangle, inverse of (8.8):**
Er_c1 = ec(cr_1, sr_1, cr_4, sr_4)
Er_c2 = ec(cr_2, sr_2, cr_1, sr_1)
Er_c3 = ec(cr_3, sr_3, cr_2, sr_2)
Er_c4 = ec(cr_4, sr_4, cr_3, sr_3)
#: **Trapezoid, printed (8.9):**
Et_p1 = ep(ct_1, st_1, ct_4, st_4)
Et_p2 = ep(ct_2, st_2, ct_1, st_1)
Et_p3 = ep(ct_3, st_3, ct_2, st_2)
Et_p4 = ep(ct_4, st_4, ct_3, st_3)
#: **Trapezoid, inverse of (8.8):**
Et_c1 = ec(ct_1, st_1, ct_4, st_4)
Et_c2 = ec(ct_2, st_2, ct_1, st_1)
Et_c3 = ec(ct_3, st_3, ct_2, st_2)
Et_c4 = ec(ct_4, st_4, ct_3, st_3)
#: **Largest error of the trapezoid with the printed (8.9):**
E_max = max(max(Et_p1, Et_p2), max(Et_p3, Et_p4))

## 3 · The 2 × 2 inverse formula and why the printed (8.9) fails (symbolic linear algebra)
#: **Formula.** For M = [m_a, m_b; m_c, m_d] with det M = m_a·m_d − m_b·m_c ≠ 0: **M⁻¹ = 1/det · [m_d, −m_b; −m_c, m_a]**. Rule: the main-diagonal terms are **swapped** (m_a ↔ m_d) and the off-diagonal terms **change sign**, without moving (m_b stays in row 1, m_c in row 2). The printed equation moves them: that is the misprint.
M_g = Simplify{[m_a, m_b; m_c, m_d]}
M_gi = Simplify{inv(M_g)}
#: **Same inverse written with the determinant:** M⁻¹ = (1/det M) · adj(M), where adj(M) = [m_d, −m_b; −m_c, m_a] is the adjugate matrix.
d_g = Simplify{m_a*m_d - m_b*m_c} 'determinant of M_g
A_g = Simplify{[m_d, -m_b; -m_c, m_a]} 'adjugate of M_g
M_gd = Simplify{A_g/d_g} 'inverse = adjugate / determinant (same as M_gi)
#: **Applied to (8.8)** with m_a = cos α_ij, m_b = sin α_ij, m_c = cos α_ki, m_d = sin α_ki:
M_w = Simplify{[cos(a_ij), sin(a_ij); cos(a_ki), sin(a_ki)]}
d_w = Simplify{cos(a_ij)*sin(a_ki) - cos(a_ki)*sin(a_ij)}
T_correct = Simplify{[sin(a_ki), -sin(a_ij); -cos(a_ki), cos(a_ij)]/d_w}
T_printed = Simplify{[sin(a_ki), -cos(a_ki); -sin(a_ij), cos(a_ij)]/d_w}
#: **Check:** M_w·T_correct = I. M_w·T_printed ≠ I.
P_correct = Simplify{M_w*T_correct}
P_printed = Simplify{M_w*T_printed}

## 4 · Numerical example
#: Side ij horizontal (α_ij = 0°), side ki at 60° (α_ki = π/3). Then det = sin 60° = 0.866 (the two sides are not parallel, the inverse exists; if the sides were parallel, det = 0).
a_ij = 0 'angle of side ij [rad]
a_ki = pi/3 'angle of side ki [rad]
M_a = [cos(a_ij), sin(a_ij); cos(a_ki), sin(a_ki)]
d_a = cos(a_ij)·sin(a_ki) - cos(a_ki)·sin(a_ij) 'determinant = sin(α_ki − α_ij)
W_correct = [sin(a_ki), -sin(a_ij); -cos(a_ki), cos(a_ij)]/d_a 'inverse of (8.8): 1/det · [sin α_ki, −sin α_ij; −cos α_ki, cos α_ij]
W_printed = [sin(a_ki), -cos(a_ki); -sin(a_ij), cos(a_ij)]/d_a 'Eq. (8.9) as printed: 1/det · [sin α_ki, −cos α_ki; −sin α_ij, cos α_ij]
#: **Check:** M·T must give the identity.
W_ok = M_a·W_correct 'identity [1, 0; 0, 1]: good
W_bad = M_a·W_printed 'NOT the identity: bad
#: The two forms differ by [0, (sin α_ij − cos α_ki)/det; −(sin α_ij − cos α_ki)/det, 0], so they coincide only when cos α_ki = sin α_ij, i.e. when the two sides are perpendicular (as in a rectangle).

## 5 · Reading
#: **What changes in the computation.** With the inverse of (8.8), the constant-shear patch (γ = 0.3, 0.7) is **exact** at the four nodes, both on the rectangle and on the trapezoid (error ≈ 1e-16, see section 2). With the printed equation the rectangle is still exact, but on the **trapezoid the nodal shear deviates by up to 0.246** (section 2, E_max) from 0.3 and 0.7. So, **if the printed equation is followed, on an element with non-perpendicular sides the nodal shear is wrong**. On rectangles this is not noticeable, which is why the book's tables do not reveal it. This sheet does not measure how much the stiffness or the deflection of a complete plate changes: that depends on the mesh.
#: I may be misreading the equation; please correct me if so.
