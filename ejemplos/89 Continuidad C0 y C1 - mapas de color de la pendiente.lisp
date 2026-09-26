# Continuidad C0 y C1: el salto de la pendiente, como mapa de color
#numerico
#: Malla de 2×2 elementos sobre la superficie w = sen(πx)·sen(πy): nudos en x = 0, 0.4, 1 y en y = 0, 0.5, 1. **C0**: elemento bilineal (solo la flecha de los nudos). **C1**: elemento bicúbico de Hermite tipo BFS (flecha, giros y torsión en cada nudo).
function v = H1(u)
  v = 1 - 3*u^2 + 2*u^3
end
function v = H2(u, L)
  v = L*(u - 2*u^2 + u^3)
end
function v = H3(u)
  v = 3*u^2 - 2*u^3
end
function v = H4(u, L)
  v = L*(u^3 - u^2)
end
function w = w0(x)
  w = sin(pi*0.4)*(1 - x)/(1 - 0.4)
  if x < 0.4
    w = sin(pi*0.4)*x/0.4
  end
end
function w = w1(x)
  L = 1 - 0.4
  u = (x - 0.4)/L
  w = sin(pi*0.4)*H1(u) + pi*cos(pi*0.4)*H2(u, L) - pi*H4(u, L)
  if x < 0.4
    w = pi*H2(x/0.4, 0.4) + sin(pi*0.4)*H3(x/0.4) + pi*cos(pi*0.4)*H4(x/0.4, 0.4)
  end
end
function v = fw(x, y)
  v = sin(pi*x)*sin(pi*y)
end
function v = fx(x, y)
  v = pi*cos(pi*x)*sin(pi*y)
end
function v = fy(x, y)
  v = pi*sin(pi*x)*cos(pi*y)
end
function v = fxy(x, y)
  v = pi^2*cos(pi*x)*cos(pi*y)
end
function w = wc0(x, y)
  x0 = 0.4
  x1 = 1
  if x < 0.4
    x0 = 0
    x1 = 0.4
  end
  y0 = 0.5
  y1 = 1
  if y < 0.5
    y0 = 0
    y1 = 0.5
  end
  u = (x - x0)/(x1 - x0)
  v = (y - y0)/(y1 - y0)
  w = fw(x0, y0)*(1 - u)*(1 - v) + fw(x1, y0)*u*(1 - v) + fw(x0, y1)*(1 - u)*v + fw(x1, y1)*u*v
end
function w = wc1(x, y)
  x0 = 0.4
  x1 = 1
  if x < 0.4
    x0 = 0
    x1 = 0.4
  end
  y0 = 0.5
  y1 = 1
  if y < 0.5
    y0 = 0
    y1 = 0.5
  end
  Lx = x1 - x0
  Ly = y1 - y0
  u = (x - x0)/Lx
  v = (y - y0)/Ly
  w = fw(x0, y0)*H1(u)*H1(v) + fx(x0, y0)*H2(u, Lx)*H1(v) + fy(x0, y0)*H1(u)*H2(v, Ly) + fxy(x0, y0)*H2(u, Lx)*H2(v, Ly) + fw(x1, y0)*H3(u)*H1(v) + fx(x1, y0)*H4(u, Lx)*H1(v) + fy(x1, y0)*H3(u)*H2(v, Ly) + fxy(x1, y0)*H4(u, Lx)*H2(v, Ly) + fw(x0, y1)*H1(u)*H3(v) + fx(x0, y1)*H2(u, Lx)*H3(v) + fy(x0, y1)*H1(u)*H4(v, Ly) + fxy(x0, y1)*H2(u, Lx)*H4(v, Ly) + fw(x1, y1)*H3(u)*H3(v) + fx(x1, y1)*H4(u, Lx)*H3(v) + fy(x1, y1)*H3(u)*H4(v, Ly) + fxy(x1, y1)*H4(u, Lx)*H4(v, Ly)
end
## La pendiente ∂w/∂x, vista en planta
#: Cada color es un valor de la pendiente en x. En **C0** aparece una **línea de corte vertical** en x = 0.4: el color cambia de golpe al cruzar el borde entre elementos. En **C1** los colores pasan suavemente.
#map((wc0(x + 0.0001, y) - wc0(x - 0.0001, y))/0.0002, [0.05 0.95], [0.02 0.98])
#map((wc1(x + 0.0001, y) - wc1(x - 0.0001, y))/0.0002, [0.05 0.95], [0.02 0.98])
#: Con estos mapas se ve por qué en un modelo de placas con elementos C0 (Q4 de Mindlin, MITC4, DKQ) los **momentos** se dibujan **por elemento** y hay que **promediarlos en los nudos** para verlos suaves: entre elementos la curvatura no es continua.
