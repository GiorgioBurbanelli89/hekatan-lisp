# SAP2000 · Verificación 3-001 · Patch test de membrana con desplazamientos impuestos
#numerico
#: Problema del manual de verificación de SAP2000 (Analysis › Planes › Example 3-001), tomado de **MacNeal y Harder (1985)**. Una placa rectangular de 0.24 × 0.12 in dividida en **5 cuadriláteros irregulares** recibe en sus 4 esquinas unos desplazamientos que, en un sólido continuo, producen **tensión constante en todo el cuerpo**. Si el elemento finito es correcto, cada elemento debe dar exactamente esa tensión, por deformados que estén. Eso es el **patch test**.
#: Orden de la hoja: **símbolos primero** (de dónde sale la respuesta exacta), luego **los elementos finitos** (la réplica de lo que hace SAP2000) y al final **la tabla contra el manual**.

## 1 · Datos (del manual)
E = 1000000 'módulo de elasticidad [lb/in²]
ν = 0.25 'coeficiente de Poisson
t = 0.001 'espesor [in]
#: Desplazamientos impuestos (MacNeal y Harder): u = 10⁻³·(x + y/2), v = 10⁻³·(y + x/2) [in].

## 2 · Símbolos: la respuesta exacta (Timoshenko y Goodier 1951, p. 6)
#: Deformaciones = derivadas de los desplazamientos: ε_{x} = ∂u/∂x, ε_{y} = ∂v/∂y, γ_{xy} = ∂u/∂y + ∂v/∂x.
eps_x = Simplify{Partial{(x + y/2)/1000 @ x}}
eps_y = Simplify{Partial{(y + x/2)/1000 @ y}}
gam_xy = Simplify{Partial{(x + y/2)/1000 @ y} + Partial{(y + x/2)/1000 @ x}}
#: Las tres son **constantes** (no dependen de x ni de y): por eso la tensión también es constante en todo el cuerpo.
#: Tensión plana (Cook y Young 1985, p. 9): σ_{x} = E/(1−ν²)·(ε_{x} + ν·ε_{y}), σ_{y} = E/(1−ν²)·(ε_{y} + ν·ε_{x}), τ_{xy} = G·γ_{xy} con G = E/(2(1+ν)). En símbolos, con ε_{x} = ε_{y} = γ_{xy} = ε:
sx_s = Simplify{E_s/(1 - n_s^2)*(e_s + n_s*e_s)}
txy_s = Simplify{E_s/(2*(1 + n_s))*e_s}
#: σ_{x} = σ_{y} = E·ε/(1−ν) y τ_{xy} = E·ε/(2(1+ν)). Con los números del problema:
σ_x = E*0.001/(1 - ν) 'tensión normal exacta [lb/in²]
σ_y = σ_x
τ_xy = E*0.001/(2*(1 + ν)) 'tensión cortante exacta [lb/in²]

## 3 · La malla: 8 nudos y 5 cuadriláteros irregulares
#: Para resolver fácil se numeran **primero los 4 nudos interiores** (libres) y después los 4 de las esquinas (con desplazamiento impuesto). Equivalencia con la numeración de SAP2000: 1→3, 2→4, 3→5, 4→6 (interiores) y 5→1, 6→2, 7→7, 8→8 (esquinas).
XY = [0.04, 0.02; 0.08, 0.08; 0.18, 0.03; 0.16, 0.08; 0, 0; 0, 0.12; 0.24, 0; 0.24, 0.12]
#: Cada fila es un elemento, con sus nudos en sentido antihorario (áreas 1 a 5 de SAP2000):
C = [5, 1, 2, 6; 5, 7, 3, 1; 1, 3, 4, 2; 3, 7, 8, 4; 2, 4, 8, 6]

## 4 · El elemento: cuadrilátero de 4 nudos (Q4) en tensión plana
#: Es el mismo de la hoja 162: D en tensión plana, funciones de forma bilineales, Jacobiano, B y cuadratura de Gauss 2 × 2. Aquí solo se usa.
Db = E/(1 - ν^2)·[1, ν, 0; ν, 1, 0; 0, 0, (1 - ν)/2]
dN_q(xi, eta) = 0.25*[-(1-eta), (1-eta), (1+eta), -(1+eta); -(1-xi), -(1+xi), (1+xi), (1-xi)]
J_q(xi, eta, X) = dN_q(xi, eta)*X
dJ_q(xi, eta, X) = det(J_q(xi, eta, X))
gx_q(xi, eta, X) = transpose([1; 0])*inv(J_q(xi, eta, X))*dN_q(xi, eta)
gy_q(xi, eta, X) = transpose([0; 1])*inv(J_q(xi, eta, X))*dN_q(xi, eta)
E_u = [1, 0, 0, 0, 0, 0, 0, 0; 0, 0, 1, 0, 0, 0, 0, 0; 0, 0, 0, 0, 1, 0, 0, 0; 0, 0, 0, 0, 0, 0, 1, 0]
E_v = [0, 1, 0, 0, 0, 0, 0, 0; 0, 0, 0, 1, 0, 0, 0, 0; 0, 0, 0, 0, 0, 1, 0, 0; 0, 0, 0, 0, 0, 0, 0, 1]
Bx_q(xi, eta, X) = gx_q(xi, eta, X)*E_u
By_q(xi, eta, X) = gy_q(xi, eta, X)*E_v
Bg_q(xi, eta, X) = gy_q(xi, eta, X)*E_u + gx_q(xi, eta, X)*E_v
k_q(xi, eta, X) = t*dJ_q(xi, eta, X)*(Db(1, 1)*transpose(Bx_q(xi, eta, X))*Bx_q(xi, eta, X) + Db(1, 2)*(transpose(Bx_q(xi, eta, X))*By_q(xi, eta, X) + transpose(By_q(xi, eta, X))*Bx_q(xi, eta, X)) + Db(2, 2)*transpose(By_q(xi, eta, X))*By_q(xi, eta, X) + Db(3, 3)*transpose(Bg_q(xi, eta, X))*Bg_q(xi, eta, X))
g = 1/sqrt(3) 'punto de Gauss

## 5 · Ensamblaje de la rigidez global (16 × 16)
#hide
K_t = zeros(16, 16)
Xn = zeros(4, 2)
for e = 1:5
  for a = 1:4
    Xn(a, 1) = XY(C(e, a), 1)
    Xn(a, 2) = XY(C(e, a), 2)
  end
  K_e = k_q(-g, -g, Xn) + k_q(g, -g, Xn) + k_q(g, g, Xn) + k_q(-g, g, Xn)
  for a = 1:4
    for b = 1:4
      for i = 1:2
        for j = 1:2
          K_t(2*C(e, a) - 2 + i, 2*C(e, b) - 2 + j) = K_t(2*C(e, a) - 2 + i, 2*C(e, b) - 2 + j) + K_e(2*a - 2 + i, 2*b - 2 + j)
        end
      end
    end
  end
end
#show
K_11 = K_t(1, 1) 'rigidez del grado u del nudo interior 1 [lb/in]

## 6 · Desplazamientos impuestos y solución
#: En las esquinas (nudos 5 a 8 de esta hoja) se impone u = 10⁻³·(x + y/2), v = 10⁻³·(y + x/2):
#hide
u_p = zeros(8, 1)
for n = 5:8
  u_p(2*n - 9) = (XY(n, 1) + XY(n, 2)/2)/1000
  u_p(2*n - 8) = (XY(n, 2) + XY(n, 1)/2)/1000
end
#show
#: Los grados libres (u, v de los 4 nudos interiores) salen de K_ff·u_f = −K_fp·u_p. K_ff son las filas y columnas 1 a 8 de K (libres con libres) y K_fp las filas 1 a 8 con las columnas 9 a 16 (libres con impuestos):
#hide
K_ff = zeros(8, 8)
K_fp = zeros(8, 8)
for i = 1:8
  for j = 1:8
    K_ff(i, j) = K_t(i, j)
    K_fp(i, j) = K_t(i, j + 8)
  end
end
#show
u_f = clsolve(K_ff, -K_fp*u_p)
#: Lo que da la fórmula exacta en esos mismos nudos:
#hide
u_ex = zeros(8, 1)
for n = 1:4
  u_ex(2*n - 1) = (XY(n, 1) + XY(n, 2)/2)/1000
  u_ex(2*n) = (XY(n, 2) + XY(n, 1)/2)/1000
end
#show
err_u = norm(u_f - u_ex) 'diferencia [in]: tiene que ser ≈ 0

## 7 · Tensiones en cada elemento (en su centro, ξ = η = 0)
#hide
U_t = zeros(16, 1)
for i = 1:8
  U_t(i) = u_f(i)
  U_t(i + 8) = u_p(i)
end
s_x = zeros(5, 1)
s_y = zeros(5, 1)
s_xy = zeros(5, 1)
u_e = zeros(8, 1)
for e = 1:5
  for a = 1:4
    Xn(a, 1) = XY(C(e, a), 1)
    Xn(a, 2) = XY(C(e, a), 2)
    u_e(2*a - 1) = U_t(2*C(e, a) - 1)
    u_e(2*a) = U_t(2*C(e, a))
  end
  e_x = Bx_q(0, 0, Xn)*u_e
  e_y = By_q(0, 0, Xn)*u_e
  g_xy = Bg_q(0, 0, Xn)*u_e
  s_x(e) = Db(1, 1)*e_x(1) + Db(1, 2)*e_y(1)
  s_y(e) = Db(2, 1)*e_x(1) + Db(2, 2)*e_y(1)
  s_xy(e) = Db(3, 3)*g_xy(1)
end
#show
#tabla("Elemento (área SAP2000)","σ_x [lb/in²]:2","σ_y [lb/in²]:2","τ_xy [lb/in²]:2")({"1","2","3","4","5"}; s_x; s_y; s_xy)
#: Los **cinco elementos dan la misma tensión**, aunque ninguno es rectangular: el Q4 pasa el patch test.

## 7b · El mismo resultado en color
#: **Gráfica 3D.** Lo que calculan los elementos finitos:
#: Color = desplazamiento horizontal u en milésimas de pulgada, **interpolado** dentro de cada elemento con sus funciones de forma; líneas = bordes de los 5 elementos; forma deformada × 100. Como u es lineal en x e y, los colores pasan de un elemento a otro sin saltos: eso es lo que permite que la tensión sea la misma en todos.
#hide
X_m = zeros(9, 3)
u_mil = zeros(9, 1)
U_m = zeros(9, 3)
for n = 1:8
  X_m(n, 1) = XY(n, 1)
  X_m(n, 2) = XY(n, 2)
  u_mil(n) = 1000*U_t(2*n - 1)
  U_m(n, 1) = U_t(2*n - 1)
  U_m(n, 2) = U_t(2*n)
end
X_m(9, 3) = 0.001
e_m = C
e_b = [1, 1]
v_b = [0, 0]
#show
#modelo3d(X_m, e_m, e_b, u_mil, v_b, U_m, 100)
#: **Gráfica 2D · la placa en planta.** Los 5 cuadriláteros irregulares (numerados), los 8 nudos y, en rojo, las 4 esquinas donde se impone el desplazamiento:
#hide
x_j = zeros(8, 1)
y_j = zeros(8, 1)
for n = 1:8
  x_j(n) = XY(n, 1)
  y_j(n) = XY(n, 2)
end
a_j = [5, 6, 7, 8]
#show
#malla(x_j, y_j, C, a_j)
#: **Gráfica 2D · mapa de color en planta.** El desplazamiento horizontal u (en milésimas de pulgada) sobre toda la placa: u = 10³·10⁻³·(x + y/2) = x + y/2. Las bandas de color son **rectas paralelas inclinadas** (u es lineal): como cada elemento reproduce exactamente un campo lineal, el FEM da este mismo mapa en los 5 cuadriláteros, sin saltos entre ellos.
#map(x + y/2, [0 0.24], [0 0.12])
#: Y el desplazamiento vertical v = x/2 + y (milésimas): también lineal. Las bandas de u (u = cte → y = 2·(c − x)) caen con pendiente −2, casi verticales; las de v (v = cte → y = c − x/2) caen con pendiente −1/2, más tendidas.
#map(x/2 + y, [0 0.24], [0 0.12])
#: **Gráfica 2D (corte).** El mismo u cortado a lo largo del borde de abajo (y = 0) y del de arriba (y = 0.12 in), en milésimas: dos rectas paralelas, porque u = 10⁻³·(x + y/2) es lineal; los nudos de las esquinas caen justo sobre ellas.
#fplot(borde_inferior = x, borde_superior = x + 0.06, puntos = [0 0; 0.24 0.24; 0 0.06; 0.24 0.3], [0 0.24])

## 8 · Comparación con el manual de SAP2000
#hide
for i = 1:1
  s_hk = zeros(3, 1)
  s_hk(1) = s_x(3)
  s_hk(2) = s_y(3)
  s_hk(3) = s_xy(3)
  s_sap = zeros(3, 1)
  s_sap(1) = 1333
  s_sap(2) = 1333
  s_sap(3) = 400
  s_ind = zeros(3, 1)
  s_ind(1) = σ_x
  s_ind(2) = σ_y
  s_ind(3) = τ_xy
end
#show
#tabla("Componente","SAP2000 (manual):0","Independiente (exacta):2","Hekatan (FEM):2")({"σ_xx [lb/in²]","σ_yy [lb/in²]","σ_xy [lb/in²]"}; s_sap; s_ind; s_hk)
#: **Conclusión.** La solución exacta da σ_{x} = σ_{y} = 1333.33 lb/in² y τ_{xy} = 400 lb/in². SAP2000 (con y sin modos incompatibles) y Hekatan dan lo mismo: los desplazamientos de los nudos interiores coinciden con la fórmula exacta y la tensión es la misma en los 5 elementos.
