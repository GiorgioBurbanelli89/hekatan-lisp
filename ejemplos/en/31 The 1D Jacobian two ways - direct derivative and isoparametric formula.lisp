# The 1D Jacobian two ways: direct derivative and isoparametric formula
#: The Jacobian of the linear element can be obtained in two different ways that give the same result. The first, by differentiating the mapping directly. The second, with the isoparametric formula —a dot product of the derivatives of the shape functions with the node coordinates—, which is the one that generalizes to 2D and 3D. All symbolic.

## 1 · The element and its mapping
#: The linear element has node 1 at {xi} = −1 and node 2 at {xi} = +1, with shape functions:
N1 = (1-xi)/2; N2 = (1+xi)/2
#: In the physical world node 1 is at x = 0 and node 2 at x = {L}. The physical coordinate is interpolated with the same shape functions; with node 1 at the origin, only the {N2} term survives:
x = N2 * L

## 2 · Form 1 — The direct derivative
#: The Jacobian is, by definition, the derivative of the physical coordinate {x} with respect to the natural one {xi}. The mapping is differentiated, timed with tic/toc:
tic
J1 = Diff{(1+xi)/2 * L @ xi}
toc
#: The result is {J1}: constant, because the mapping is linear.

## 3 · Form 2 — The isoparametric formula (manual)
#: The same Jacobian comes out without differentiating the whole mapping: since {x} = Σ Nᵢ·xᵢ, its derivative is the sum of the derivatives of each shape function times the coordinate of its node, J = Σ (dNᵢ/dξ)·xᵢ. First the derivatives of the shape functions:
dN1 = Diff{(1-xi)/2 @ xi}; dN2 = Diff{(1+xi)/2 @ xi}
#: {dN1} and {dN2} come out, constants. The isoparametric formula is the dot product of the vector of those derivatives with the vector of nodal coordinates [x₁; x₂] = [0; {L}], also timed:
tic
J2 = [dN1, dN2] * [0; L]
toc
#: Node 1 (at x = 0) contributes nothing; only node 2 (at x = {L}) contributes with {dN2}·{L}.

## 4 · Both coincide
#: Both give {J1}. The direct derivative is shorter in 1D; the isoparametric formula J = Σ (dNᵢ/dξ)·xᵢ is the one used in practice, because it generalizes unchanged to 2D and 3D (where the Jacobian is a matrix and the nodal coordinates, several). At bottom they are the same thing: differentiating the interpolated mapping amounts to adding the derivatives of the shape functions weighted by the nodes.
