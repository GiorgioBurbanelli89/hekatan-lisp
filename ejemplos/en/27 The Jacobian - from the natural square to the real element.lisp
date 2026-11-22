# The Jacobian: from the natural square (ξ, η) to the real element (x, y)
#: All symbolic. The idea: in FEM each element is integrated over a fixed reference SQUARE, and the Jacobian is the bridge between that square and the real element.

## 1 · Why natural coordinates
#: A real finite element is any quadrilateral, skewed. Integrating over it directly is a mess: each one has a different shape. The FEM trick: think of EVERY element as a deformation of the same reference SQUARE —the "natural square"— whose sides ξ and η go from −1 to 1.
#: That way the stiffness integral is always done over the SAME domain [−1, 1]×[−1, 1], no matter the real shape. The key question: how are the natural coordinates (ξ, η) of the square related to the physical ones (x, y) of the element? That relation —and its "stretching"— is the Jacobian.

## 2 · The map: the physical (x, y) as a function of the natural (ξ, η)
#: The physical coordinates are a BILINEAR interpolation of the natural ones. The coefficients come from where the 4 nodes of the element are; here I leave them as letters a₀…a₃ (for x) and b₀…b₃ (for y):
x = a0 + a1*xi + a2*eta + a3*xi*eta
y = b0 + b1*xi + b2*eta + b3*xi*eta
#: Note: if ξ and η run over the square [−1,1]², the point (x, y) runs over the real quadrilateral. The mixed term ξ·η is what allows the sides not to be parallel (a skewed quadrilateral, not just a rectangle).

## 3 · The Jacobian: how much a small step in (ξ, η) moves (x, y)
#: The Jacobian collects, in a 2×2 matrix, how each physical coordinate changes when each natural one is pushed. Each entry is a PARTIAL derivative —the partial treats the other variable as a constant:
J11 = Partial{x @ xi}
J12 = Partial{y @ xi}
J21 = Partial{x @ eta}
J22 = Partial{y @ eta}
#: Put in their places, they form the Jacobian J (row 1 = derivatives with respect to ξ; row 2 = with respect to η):
J = [J11, J12; J21, J22]
#: Each column says where and how much the physical point moves when you advance in ξ (column 1) or in η (column 2). It is the local "stretching matrix" of the map.

## 4 · The determinant: the area factor
#: The determinant of the Jacobian is the area SCALE factor: a small square du·dη of the natural square becomes a small piece of area detJ·dξ·dη in the real element. That is why detJ appears in the stiffness integral:
detJ = det(J)
#: NOTE the result: detJ came out LINEAR in ξ, η (the ξ·η term cancels by itself). That is, for a general quadrilateral the area factor is NOT constant: it changes from point to point. Only in a rectangle (without the skew term) is detJ constant. That is the underlying reason why the integral is done with numerical Gauss and not by hand.

## 5 · The inverse: to take the derivatives to the physical world
#: The Jacobian converts derivatives in ξ, η into derivatives in x, y THE OTHER WAY AROUND: to go to ∂/∂x and ∂/∂y (which the strain matrix B needs) the INVERSE of the Jacobian is used. In one sentence: the physical derivatives are J⁻¹ times the natural derivatives.
Ji = inv(J)
#: There is the whole chain: the map (x, y)←(ξ, η) gives the Jacobian J; its determinant detJ scales the area in the integral; and its inverse J⁻¹ translates the derivatives to the real element. With those three —J, detJ, J⁻¹— the whole element stiffness is built over the natural square.
