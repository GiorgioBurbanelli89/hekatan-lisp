# Mesh convergence: what happens when refining
#: A bar of length 1, fixed at the left and free at the right, with a uniform distributed axial load. Everything normalized (load = axial stiffness = length = 1) so that only the shape is seen. The EXACT solution is compared with the linear FINITE ELEMENT one, for 1, 2, 3 … 8 elements.

## 1 · The exact solution
#: The exact displacement of the bar is a parabola:
u = x - x^2/2
#: The stress (the axial stress) is the slope of the displacement, its derivative:
sigma = Diff{u @ x}
#: It is a straight line: it equals 1 at the support and 0 at the free end.

## 2 · What the linear finite element does
#: With {n} elements, each one measures {h} (the length 1 divided into {n}).
#: In the bar, the linear element gives the EXACT NODE displacements, and between node and node it draws a STRAIGHT LINE. The stress inside an element that goes from {a} to {a} + {h} is the slope of that line:
sigma_EF = Expand{((a + h) - (a + h)^2/2 - (a - a^2/2))/h}
#: It is a CONSTANT in each element: the finite element stress is a staircase, not a straight line.

## 3 · The animation: the displacement
#: Exact parabola (blue) against the finite element (orange). With 1 element it is a single straight line; when refining, the straight segments hug the parabola. With ⏸ it stops, and the bar picks the frame.
#anim fplot(u = x - x^2/2, u_EF = floor(n*x)/n - (floor(n*x)/n)^2/2 + (1 - floor(n*x)/n - 1/(2*n))*(x - floor(n*x)/n), [0 0.999]), n = 1:8
h = 1/n
#: At the nodes they always coincide. Between nodes, the largest error is at the center of each element and equals:
e_u = h^2/8
#: If {n} doubles, {h} halves and the error drops to a QUARTER: that is CONVERGING.

## 4 · The animation: the stress (why CSI averages)
#: Exact line (blue) against the finite element staircase (orange):
#anim fplot(sigma = 1 - x, sigma_EF = 1 - floor(n*x)/n - 1/(2*n), [0 0.999]), n = 1:8
#: Look at an interior node: the element on the left gives one stress and the one on the right gives ANOTHER. The jump between the two is the difference of two consecutive steps:
salto = (1 - (a - h) - h/2) - (1 - a - h/2)
#: The jump equals {h}. It is the third equation, point-by-point EQUILIBRIUM, which the finite element does not satisfy: it only satisfies it at the nodes. That is why SAP2000, ETABS and SAFE offer to view the stresses "Unaveraged" (with a jump) or "Averaged" (the mean of the two elements at the node). Average at an interior node:
sigma_nudo = Expand{((1 - (a - h) - h/2) + (1 - a - h/2))/2}
#: It comes out 1 − {a}: exactly the EXACT stress at that node. Averaging is not a trick: here it returns the exact value.

## 5 · Convergence and divergence
#: The displacement error as a function of the number of elements. The curve is the formula; the points are the error MEASURED in the animations above (the largest distance between the parabola and the straight segments) with 1, 2, 4 and 8 elements:
#fplot(e_u = 1/(8*n^2), medido = [1 0.125; 2 0.03125; 4 0.0078125; 8 0.001953125], [1 8])
#: The points fall right on the curve: each time {n} doubles, the error is divided by 4.
#: CONVERGES: when refining, the curve drops toward zero and the two programs (or the program and the exact solution) get closer. DIVERGES: when refining, the difference does not drop or it grows; that indicates the two models are NOT the same (another element, another theory —Shell-Thin against Shell-Thick— or another error).
#: And when two programs give a difference close to 0 %, with the same mesh and the same element, it means they do the SAME calculation.
