# Quadratic shape functions: deriving and plotting them
#: An element with 3 nodes, at x = −1, 0 and 1. Each node's shape function equals **1 at its own node and 0 at the other two**. It is built with the Lagrange product: multiply by (x − x_j) for every other node j and divide by the same product evaluated at the node itself.

## 1 · The three functions
N_1 = Expand{(x - 0)*(x - 1)/((-1 - 0)*(-1 - 1))}
N_2 = Expand{(x + 1)*(x - 1)/((0 + 1)*(0 - 1))}
N_3 = Expand{(x + 1)*(x - 0)/((1 + 1)*(1 - 0))}

## 2 · What they guarantee
#: They add up to 1 at any point (partition of unity): a rigid-body displacement is reproduced with no deformation.
Simplify{N_1 + N_2 + N_3}

## 3 · The plot
#: Each curve rises to 1 at its node and crosses zero at the other two:
#fplot(N_1 = x^2/2 - x/2, N_2 = 1 - x^2, N_3 = x^2/2 + x/2, [-1 1])
