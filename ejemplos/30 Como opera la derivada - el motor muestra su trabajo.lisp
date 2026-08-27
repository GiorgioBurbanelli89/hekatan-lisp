# Cómo opera la derivada — el motor muestra su trabajo
#: El operador Pasos{} deriva MOSTRANDO cada regla —generada por el motor, no escrita a mano—: la regla de la suma reparte la derivada por término, y la regla de la potencia baja el exponente con su aritmética (c·ξⁿ → c·n·ξⁿ⁻¹). Con tic/toc se mide cuánto tarda el motor en hacer todo ese trabajo.

## 1 · La función de forma (lineal)
#: Aquí L/2 es constante, así que la derivada es simple; aun así se ve la regla de la suma (cada término por separado) y que la constante da 0:
tic
dl = Pasos{(1+xi)/2 * L @ xi}
toc

## 2 · Un polinomio con potencias — aquí la regla de la potencia SÍ opera
#: Con potencias reales se ve la aritmética: cada término c·ξⁿ baja su exponente y lo multiplica, quedando c·n·ξⁿ⁻¹. En 3·ξ² el 2 baja (3·2·ξ¹ = 6ξ); en 2·ξ queda 2·1 = 2:
tic
dp = Pasos{3*xi^2 + 2*xi @ xi}
toc

## 3 · Un cúbico
#: El exponente 3 baja y multiplica al coeficiente, y la potencia queda en 2:
tic
dc = Pasos{xi^3 @ xi}
toc
