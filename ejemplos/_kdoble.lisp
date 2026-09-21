# La matriz de rigidez de la cáscara
## Esta es la fórmula, y no hay ninguna otra: la deformación por la constitutiva por la deformación, integrada en las dos coordenadas del cuadrado patrón, con el jacobiano dentro.
K_e = Area{Area{Bt·D·B·detJ @ xi=-1:1} @ eta=-1:1}
