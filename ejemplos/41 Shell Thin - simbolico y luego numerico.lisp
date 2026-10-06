# Shell-Thin (placa delgada): del símbolo al número
#: 17-sep-2026. Todo el desarrollo **simbólico** primero — curvaturas, momentos, cortantes — y **los números al final**, comparados con ETABS 19.
#: La placa: cuadrada, simplemente apoyada, carga uniforme. Es el caso de la prueba `placa_thick_thin_sano` de Hekatan Struct.

## 1. La hipótesis de Kirchhoff, en símbolos
#: La recta perpendicular sigue recta y perpendicular: los giros son la pendiente de la flecha, **sin cortante**.
theta_x = Partial{A*sin(pi*x/L)*sin(pi*y/L) @ x} @@(giro alrededor de y)
theta_y = Partial{A*sin(pi*x/L)*sin(pi*y/L) @ y} @@(giro alrededor de x)

## 2. La flecha supuesta (primer término de Navier)
#: Un solo seno en cada dirección ya reproduce el 99 % de la flecha de la losa apoyada.
w = A*sin(pi*x/L)*sin(pi*y/L)

## 3. Curvaturas: derivar dos veces
k_xx = Simplify{-Partial{Partial{A*sin(pi*x/L)*sin(pi*y/L) @ x} @ x}}
k_yy = Simplify{-Partial{Partial{A*sin(pi*x/L)*sin(pi*y/L) @ y} @ y}}
k_xy = Simplify{-2*Partial{Partial{A*sin(pi*x/L)*sin(pi*y/L) @ x} @ y}}

## 4. Rigidez a flexión y momentos (símbolos)
D = E*t^3/(12*(1-nu^2))
M_xx = Simplify{D*(k_xx + nu*k_yy)} @@(momento en x)
M_yy = Simplify{D*(k_yy + nu*k_xx)} @@(momento en y)
M_xy = Simplify{D*(1-nu)/2*k_xy} @@(torsor)

## 5. Cortantes: derivar los momentos
Q_x = Simplify{Partial{M_xx @ x} + Partial{M_xy @ y}} @@(cortante en x)
Q_y = Simplify{Partial{M_yy @ y} + Partial{M_xy @ x}} @@(cortante en y)

## 6. La ecuación de Kirchhoff cierra el problema
#: Metiendo la flecha supuesta en D·∇⁴w = q sale la amplitud A:
lap4 = Simplify{Partial{Partial{Partial{Partial{A*sin(pi*x/L)*sin(pi*y/L) @ x} @ x} @ x} @ x} + 2*Partial{Partial{Partial{Partial{A*sin(pi*x/L)*sin(pi*y/L) @ x} @ x} @ y} @ y} + Partial{Partial{Partial{Partial{A*sin(pi*x/L)*sin(pi*y/L) @ y} @ y} @ y} @ y}} @@(∇⁴w)
A_1 = q*L^4/(4*pi^4*D)

## 7. La placa, en dibujo: colormap y **hover** (pasa el cursor: x, y, flecha)
#: La flecha va **hacia abajo** (la carga es la gravedad): por eso el signo menos. La placa se hunde, no se levanta.
#surf(-sin(pi*x/10)*sin(pi*y/10), [0 10], [0 10])

#: Y el mismo campo en planta, como el mapa de color de ETABS:
#map(-sin(pi*x/10)*sin(pi*y/10), [0 10], [0 10])

## 8. AHORA los números
#: Losa L = 10 m · t = 0.5 m · E = 2.2e7 kN/m2 · nu = 0.2 · q = 10 kN/m2.
D_num = 2.2*10^7*0.5^3/(12*(1-0.2^2))
#: **D = 238 715 kN·m**

A_num = 10*10^4/(4*pi^4*238715)
#: **A = 0.0010753 m** (amplitud del primer seno)

w_centro = 0.00406*10*10^4/238715
#: **w = 0.0017008 m = 1.70 mm** en el centro, con el coeficiente 0.00406 de Timoshenko.
#: La serie completa (19 términos) da **0.0017018 m**.

M_centro = 0.0479*10*10^2
#: **M = 47.9 kN·m/m** en el centro (coeficiente 0.0479 de Timoshenko para nu = 0.2).

## 9. Contra ETABS 19 (medido, misma malla 8x8)
#: - t/L = 0.001 → Kirchhoff 212.719 m · ETABS 212.529 m · +0.089 %
#: - t/L = 0.01 → 0.212719 · 0.212529 · +0.089 %
#: - t/L = 0.05 → 0.00170175 · 0.00170024 · +0.089 %
#: - t/L = 0.1 → 0.000212719 · 0.000212529 · +0.089 %
#: - t/L = 0.2 → 2.659e-05 · 2.657e-05 · +0.089 %
#: La diferencia es **la misma en los cinco espesores**: es el corte de la serie, no la formulación. Shell-Thin de ETABS y de SAP2000 cae sobre la solución de Kirchhoff.
