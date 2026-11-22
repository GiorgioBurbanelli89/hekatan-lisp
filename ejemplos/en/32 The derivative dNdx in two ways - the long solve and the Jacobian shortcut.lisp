# The derivative dN/dx in two ways: the long solve and the Jacobian shortcut
#: To build the strain (the B matrix) we need the derivative of the shape function with respect to the PHYSICAL coordinate {x}, not the natural one {xi}. There are two ways to get it, and they give the same result. The first, manual, is long: it forces us to solve for {xi}. The second uses the Jacobian —which was invented precisely to avoid that solve—. All symbolic.

## 1 · The starting point
#: The shape function {N1} = (1−{xi})/2 is written in the natural coordinate {xi}, but the strain needs its derivative in the physical one {x}. Two pieces are known: the natural derivative of the shape function, and the Jacobian of the mapping {x} = (1+{xi})/2·{L}:
dN1_dxi = Diff{(1-xi)/2 @ xi}
J = Diff{(1+xi)/2 * L @ xi}
#: This gives {dN1_dxi} and the Jacobian {J}.

## 2 · Manual way — the long solve
#: Solve for {xi} from the mapping: from {x} = (1+{xi})/2·{L} we get {xi} = 2{x}/{L} − 1. Substitute that {xi} into the shape function to have it written in {x}:
N1x = Simplify{(1 - (2*x/L - 1))/2}
#: This gives {N1x}. Now we differentiate with respect to the physical coordinate {x}:
dN1_dx_manual = Diff{(1 - (2*x/L - 1))/2 @ x}
#: The result is {dN1_dx_manual}. It is correct, but we had to solve for {xi} and rewrite the function —a step that is easy in 1D but practically impossible by hand in 2D and 3D.

## 3 · Jacobian way — the shortcut
#: Instead of solving, use the chain rule: dN/d{x} = dN/d{xi} · d{xi}/d{x}. And since the Jacobian is d{x}/d{xi} = {J}, its reciprocal is d{xi}/d{x} = 1/{J}. First the inverse of the Jacobian:
Jinv = Simplify{1/J}
#: This gives {Jinv}. Then the physical derivative is the natural one {dN1_dxi} multiplied by that inverse —without solving anything—:
dN1_dx_jac = Simplify{dN1_dxi * Jinv}
#: The result is {dN1_dx_jac}.

## 4 · They match — and that is why the Jacobian exists
#: Both give {dN1_dx_jac}. The manual way forces us to solve for {xi} and rewrite the function; the Jacobian way only differentiates in {xi} and multiplies by 1/{J}. That is why the finite element method ALWAYS works in natural coordinates and uses the Jacobian to move to physical ones: it avoids the solve, which in several dimensions would be unworkable.
