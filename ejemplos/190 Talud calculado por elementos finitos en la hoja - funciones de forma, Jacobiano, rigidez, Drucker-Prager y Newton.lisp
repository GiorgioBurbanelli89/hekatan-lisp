# Talud calculado por elementos finitos en la hoja: funciones de forma, Jacobiano, rigidez, Drucker-Prager y Newton, igual que Hekatan Geotechnic
#numerico

## 1 · El talud y su malla
#: Talud de Griffiths y Lane (1999), ejemplo 2: cara 2:1 de H = 15.24 m sobre una cimentación de H/2, c = 15 kPa, φ = 20°, γ = 19.64 kN/m³, E = 100 MPa, ν = 0.3, Drucker-Prager de GEO5 sin dilatancia (ψ = 0). Esta hoja NO copia resultados: arma la rigidez de cada triángulo, la ensambla, carga el peso propio e itera con Newton-Raphson, como el solver de Hekatan Geotechnic. Malla GRUESA (triángulos de ~5 m) para que corra en la hoja: 144 triángulos de 6 nudos (T6), 333 nudos, 666 incógnitas.
#dibujo("El talud y la malla de 144 triángulos T6 (lados de ~5 m)", ud = m, escala = auto, cotas = m, alto = 110)
#  achurado([0, 91.44, 91.44, 60.96, 30.48, 0], [0, 0, 22.86, 22.86, 7.62, 7.62], "suelo")
#  poligono(0, 0, 91.44, 0, 91.44, 22.86, 60.96, 22.86, 30.48, 7.62, 0, 7.62, "gruesa")
#  cota(93.5, 7.62, 93.5, 22.86, 0, "H = 15.24 m")
#  cota(30.48, 24.5, 60.96, 24.5, 0, "cara 2:1")
#  texto(45, 3, "base fija · lados con rodillo", 2.4, "c")
#fin

## 2 · Las operaciones, primero con símbolos
#: **Funciones de forma del T6** en las coordenadas de área L₁, L₂ y L₃ = 1 − L₁ − L₂ (esquinas 1-2-3, nudos medios 12-23-31, el orden de Geotechnic):
N_1 = Simplify{L_1*(2*L_1 - 1)}
N_2 = Simplify{L_2*(2*L_2 - 1)}
N_3 = Simplify{(1 - L_1 - L_2)*(2*(1 - L_1 - L_2) - 1)}
N_4 = Simplify{4*L_1*L_2}
N_5 = Simplify{4*L_2*(1 - L_1 - L_2)}
N_6 = Simplify{4*(1 - L_1 - L_2)*L_1}
S_N = Simplify{L_1*(2*L_1 - 1) + L_2*(2*L_2 - 1) + (1 - L_1 - L_2)*(2*(1 - L_1 - L_2) - 1) + 4*L_1*L_2 + 4*L_2*(1 - L_1 - L_2) + 4*(1 - L_1 - L_2)*L_1}
#: **Sus derivadas** (dan la deformación):
dN3_dL1 = Simplify{Partial{(1 - L_1 - L_2)*(2*(1 - L_1 - L_2) - 1) @ L_1}}
dN5_dL1 = Simplify{Partial{4*L_2*(1 - L_1 - L_2) @ L_1}}
dN6_dL1 = Simplify{Partial{4*(1 - L_1 - L_2)*L_1 @ L_1}}
#: **El Jacobiano** J = [Σ ∂N/∂L₁·x, Σ ∂N/∂L₁·y; Σ ∂N/∂L₂·x, Σ ∂N/∂L₂·y] y las derivadas reales con su inversa:
dN_dx = Simplify{(J_22*a_1 - J_12*a_2)/(J_11*J_22 - J_12*J_21)}
dN_dy = Simplify{(-J_21*a_1 + J_11*a_2)/(J_11*J_22 - J_12*J_21)}
#: (a₁ = ∂N/∂L₁, a₂ = ∂N/∂L₂). Con ellas la matriz **B** (4 × 12): fila xx = ∂N/∂x en u, fila yy = ∂N/∂y en v, fila zz = 0 (deformación plana), fila xy = ∂N/∂y en u y ∂N/∂x en v. **La rigidez del triángulo** se integra con los 7 puntos de Hammer (pesos w_q):
#: K_e = Σ_q B_qᵀ · D · B_q · det J_q · w_q        F_e = −Σ_q N_q · γ · det J_q · w_q  (peso propio, hacia abajo)
#: **La matriz D elástica** (deformación plana) con λ y G:
l_D = Simplify{E*nu/((1 + nu)*(1 - 2*nu))}
G_D = Simplify{E/(2*(1 + nu))}
D_11 = Simplify{E*nu/((1 + nu)*(1 - 2*nu)) + E/(1 + nu)}
#: **El suelo: Drucker-Prager de GEO5**, f = J + α·I₁ − k con la resistencia ya dividida por F:
a_DP = Simplify{2*sin(phi)/(sqrt(3)*(3 + sin(phi)))}
k_DP = Simplify{6*c*cos(phi)/(sqrt(3)*(3 + sin(phi)))}
#: Si f > 0 el esfuerzo vuelve a la superficie (retorno radial, ψ = 0): el desviador baja a J − f y el punto queda sobre el cono:
J_r = Simplify{J - (J + alpha*I_1 - k)}
#: y la rigidez de ese punto ya no es D sino la **tangente consistente** D_T = Ξ − (Ξ·m)(nᵀ·Ξ)/(nᵀ·Ξ·m), con Ξ = K·1·1ᵀ + 2·G·β·P_dev, β = (J − f)/J, m = s/(2J) y n = m + α·1.
#: **Newton-Raphson como GEO5:** K_T·Δu = F_ext − F_int; el esfuerzo se ACTUALIZA en cada iteración desde el último aceptado; búsqueda lineal η (una pasada de secante); se acepta cuando las tres normas bajan de 0.01:
#: DNorm = |Δu|   ·   OBFNorm = |R| / |F_ext|   ·   ENorm = √|Δu·R| / √|U·F_ext|   (U = suma de los Δu de la iteración)

## 3 · Los números: la malla
#hide
X_n = [0, 5.08, 10.16, 15.24, 20.32, 25.4, 30.48, 35.56, 40.64, 45.72, 50.8, 55.88, 60.96, 66.04, 71.12, 76.2, 81.28, 86.36, 91.44, 91.44, 91.44, 91.44, 91.44, 91.44, 86.36, 81.28, 76.2, 71.12, 66.04, 60.96, 56.605714, 52.251429, 47.897143, 43.542857, 39.188571, 34.834286, 30.48, 25.4, 20.32, 15.24, 10.16, 5.08, 0, 0, 80.1878, 68.496755, 58.241527, 50.104659, 74.342277, 74.342277, 62.699408, 63.941444, 43.42838, 84.983187, 84.983187, 37.966176, 53.353959, 54.9704, 68.570921, 79.601053, 79.601053, 69.239864, 57.619746, 86.838058, 59.601227, 75.630669, 45.996243, 63.753908, 47.590215, 33.465077, 87.608691, 87.608691, 49.337432, 22.86, 27.94, 7.62, 17.78, 12.7, 64.963932, 73.66, 73.66, 40.058991, 51.457188, 66.230349, 70.83368, 60.202449, 70.872359, 43.18, 63.5, 67.157596, 81.735499, 81.735499, 54.505768, 82.926398, 82.926398, 2.54, 2.54, 0, 2.54, 0, 2.54, 38.1, 39.303088, 36.763088, 68.58, 67.30546, 69.84546, 78.74, 80.440527, 77.900527, 78.74, 77.900527, 80.440527, 68.58, 70.179932, 67.639932, 54.428571, 54.935587, 57.11273, 52.802694, 55.486853, 60.470467, 60.159577, 57.930637, 55.797743, 91.44, 89.139029, 89.139029, 88.211593, 85.910622, 88.211593, 85.910622, 58.42, 60.280613, 57.740613, 55.4252, 57.285813, 61.091485, 58.921377, 61.771335, 56.605964, 76.971665, 77.615861, 74.986473, 79.894427, 77.909234, 79.894427, 77.615861, 76.971665, 74.986473, 60.997717, 63.226658, 63.847676, 48.26, 49.195108, 46.655108, 48.050451, 46.793229, 48.847437, 44.712312, 45.509298, 33.02, 34.512539, 31.972539, 32.657143, 31.972539, 34.149681, 36.400231, 35.715627, 91.44, 89.524346, 89.524346, 88.9, 86.984346, 91.44, 89.524346, 86.295939, 88.9, 89.524346, 86.984346, 91.44, 89.524346, 91.44, 89.524346, 86.295939, 50.074286, 48.617287, 50.79443, 51.345695, 45.72, 46.440144, 44.76955, 47.666837, 51.729309, 49.721045, 22.86, 24.13, 21.59, 22.86, 21.59, 24.13, 27.94, 29.21, 26.67, 27.94, 26.67, 29.21, 30.702539, 25.4, 7.62, 8.89, 6.35, 7.62, 6.35, 8.89, 3.81, 17.78, 19.05, 16.51, 17.78, 16.51, 19.05, 20.32, 12.7, 13.97, 11.43, 12.7, 11.43, 13.97, 10.16, 15.24, 63.5, 62.961966, 65.501966, 66.767427, 73.66, 72.39, 74.93, 71.11546, 76.630527, 74.001139, 73.66, 74.93, 72.39, 76.630527, 74.001139, 71.79107, 71.449932, 37.011429, 37.446638, 39.623781, 39.012584, 40.697278, 41.743686, 41.365714, 41.800924, 43.027617, 53.34, 53.668594, 51.128594, 53.213794, 49.523702, 52.53753, 50.780924, 64.992129, 64.464878, 66.125331, 67.363552, 65.597141, 67.400635, 63.83167, 72.587978, 73.232174, 72.24684, 69.7023, 68.532015, 69.665217, 58.782857, 58.404082, 60.581224, 58.911098, 61.450928, 62.583191, 72.607318, 70.056111, 73.251514, 70.853019, 69.684557, 43.18, 44.45, 41.91, 40.573088, 43.30419, 45.385108, 63.5, 64.77, 62.23, 66.369932, 66.590654, 63.720722, 61.550613, 68.19873, 65.54952, 65.455752, 67.827175, 69.014977, 80.961649, 80.668276, 83.512929, 84.286778, 83.359343, 80.668276, 80.961649, 84.286778, 83.359343, 53.929864, 56.373647, 54.738084, 52.305214, 81.263725, 82.103199, 83.82, 84.643199, 85.267544, 83.954792, 82.330948, 82.103199, 81.263725, 83.82, 84.643199, 85.267544, 83.954792, 82.330948] 'x de los nudos [m]
Y_n = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 4.572, 9.144, 13.716, 18.288, 22.86, 22.86, 22.86, 22.86, 22.86, 22.86, 22.86, 20.682857, 18.505714, 16.328571, 14.151429, 11.974286, 9.797143, 7.62, 7.62, 7.62, 7.62, 7.62, 7.62, 7.62, 3.81, 11.43, 11.43, 10.071644, 8.298701, 15.801212, 7.058788, 15.807131, 6.430088, 6.518467, 16.221985, 6.638015, 5.103685, 12.944563, 5.525955, 17.424968, 5.28861, 17.57139, 5.123132, 15.704378, 11.43, 4.536272, 11.43, 10.297294, 11.176026, 4.319541, 4.106718, 19.139213, 3.720787, 12.559435, 3.81, 3.81, 3.81, 3.81, 3.81, 19.052109, 19.754623, 3.105377, 8.275381, 3.840688, 14.455981, 14.399031, 18.932245, 8.512694, 2.769095, 2.728525, 8.075, 14.676591, 8.183409, 9.310123, 19.426519, 3.433481, 0, 1.905, 1.905, 7.62, 5.715, 5.715, 0, 2.551842, 2.551842, 22.86, 20.142484, 20.142484, 0, 2.644305, 2.644305, 22.86, 20.215695, 20.215695, 0, 2.561566, 2.561566, 19.594286, 17.105046, 18.193618, 15.725139, 14.32447, 12.939387, 15.755754, 12.888011, 11.508103, 11.43, 12.573, 10.287, 7.891007, 9.034007, 14.968993, 13.825993, 0, 2.268136, 2.268136, 2.762978, 5.031114, 8.250866, 7.303958, 5.48318, 7.7988, 6.173699, 8.359305, 9.244394, 8.359305, 11.43, 14.500695, 14.500695, 16.686301, 13.615606, 10.623835, 13.491578, 8.803057, 0, 2.159771, 2.159771, 9.297998, 7.308418, 6.309121, 8.407881, 5.419004, 0, 2.053359, 2.053359, 8.708571, 5.863359, 6.95193, 7.450414, 4.605202, 20.574, 20.999606, 18.713606, 22.86, 20.999606, 16.002, 16.427606, 17.680599, 0, 1.860394, 1.860394, 2.286, 4.146394, 6.858, 6.432394, 5.179401, 17.417143, 14.444003, 15.532575, 12.751999, 15.24, 13.355432, 12.224361, 11.428365, 10.621632, 10.429068, 0, 1.905, 1.905, 7.62, 5.715, 5.715, 0, 1.905, 1.905, 7.62, 5.715, 5.715, 3.958359, 3.81, 0, 1.905, 1.905, 7.62, 5.715, 5.715, 3.81, 0, 1.905, 1.905, 7.62, 5.715, 5.715, 3.81, 0, 1.905, 1.905, 7.62, 5.715, 5.715, 3.81, 3.81, 22.86, 20.956054, 20.956054, 18.238538, 22.86, 21.307312, 21.307312, 18.589795, 18.663007, 17.777917, 0, 1.552688, 1.552688, 4.196993, 5.082083, 6.09096, 4.114254, 10.885714, 9.036262, 10.124833, 6.689533, 5.811076, 7.396924, 13.062857, 11.213405, 9.286337, 0, 1.920344, 1.920344, 4.683322, 4.080115, 6.912328, 6.069695, 12.816004, 15.131556, 11.303013, 12.942991, 16.754045, 15.940474, 17.42962, 15.100122, 12.914516, 17.076827, 15.912, 14.427506, 12.914516, 21.771429, 19.807551, 20.896123, 17.318311, 17.369688, 18.992177, 7.785741, 6.817913, 9.971347, 11.455863, 9.971347, 0, 1.384547, 1.384547, 3.93639, 4.643781, 3.544318, 0, 1.364262, 1.364262, 3.925828, 5.77661, 4.579306, 3.632398, 6.599066, 7.252544, 9.625513, 9.7525, 8.293847, 13.053295, 16.12399, 11.43, 13.053295, 15.449288, 6.73601, 9.806705, 9.806705, 7.410712, 11.127343, 9.690884, 7.418039, 8.804412, 18.498955, 21.143259, 22.86, 21.143259, 19.282866, 17.824252, 17.051555, 1.716741, 4.361045, 0, 1.716741, 3.577134, 5.035748, 5.808445] 'y de los nudos [m]
E_t = [1, 2, 44, 96, 97, 98; 42, 43, 44, 99, 100, 101; 8, 9, 56, 102, 103, 104; 28, 29, 59, 105, 106, 107; 16, 17, 60, 108, 109, 110; 26, 27, 61, 111, 112, 113; 14, 15, 62, 114, 115, 116; 31, 32, 63, 117, 118, 119; 32, 57, 63, 120, 121, 118; 47, 51, 63, 122, 123, 124; 57, 47, 63, 125, 124, 121; 21, 22, 64, 126, 127, 128; 55, 21, 64, 129, 128, 130; 22, 54, 64, 131, 132, 127; 12, 13, 65, 133, 134, 135; 58, 12, 65, 136, 135, 137; 52, 47, 65, 138, 139, 140; 47, 58, 65, 141, 137, 139; 50, 60, 66, 142, 143, 144; 60, 45, 66, 145, 146, 143; 45, 61, 66, 147, 148, 146; 61, 49, 66, 149, 150, 148; 51, 47, 68, 122, 151, 152; 47, 52, 68, 138, 153, 151; 10, 11, 69, 154, 155, 156; 48, 67, 69, 157, 158, 159; 67, 53, 69, 160, 161, 158; 7, 8, 70, 162, 163, 164; 36, 37, 70, 165, 166, 167; 56, 36, 70, 168, 167, 169; 8, 56, 70, 104, 169, 163; 23, 24, 71, 170, 171, 172; 24, 25, 71, 173, 174, 171; 22, 23, 71, 175, 172, 176; 54, 22, 71, 131, 176, 177; 18, 19, 72, 178, 179, 180; 19, 20, 72, 181, 182, 179; 20, 21, 72, 183, 184, 182; 21, 55, 72, 129, 185, 184; 32, 33, 73, 186, 187, 188; 57, 32, 73, 120, 188, 189; 33, 34, 73, 190, 191, 187; 34, 67, 73, 192, 193, 191; 48, 57, 73, 194, 189, 195; 67, 48, 73, 157, 195, 193; 5, 6, 74, 196, 197, 198; 38, 39, 74, 199, 200, 201; 6, 7, 75, 202, 203, 204; 37, 38, 75, 205, 206, 207; 7, 70, 75, 164, 208, 203; 70, 37, 75, 166, 207, 208; 38, 74, 75, 201, 209, 206; 74, 6, 75, 197, 204, 209; 2, 3, 76, 210, 211, 212; 41, 42, 76, 213, 214, 215; 42, 44, 76, 101, 216, 214; 44, 2, 76, 97, 212, 216; 4, 5, 77, 217, 218, 219; 39, 40, 77, 220, 221, 222; 5, 74, 77, 198, 223, 218; 74, 39, 77, 200, 222, 223; 3, 4, 78, 224, 225, 226; 40, 41, 78, 227, 228, 229; 41, 76, 78, 215, 230, 228; 76, 3, 78, 211, 226, 230; 4, 77, 78, 219, 231, 225; 77, 40, 78, 221, 229, 231; 29, 30, 79, 232, 233, 234; 59, 29, 79, 106, 234, 235; 27, 28, 80, 236, 237, 238; 28, 59, 80, 107, 239, 237; 49, 61, 80, 149, 240, 241; 61, 27, 80, 112, 238, 240; 15, 16, 81, 242, 243, 244; 16, 60, 81, 110, 245, 243; 60, 50, 81, 142, 246, 245; 50, 62, 81, 247, 248, 246; 62, 15, 81, 115, 244, 248; 35, 36, 82, 249, 250, 251; 36, 56, 82, 168, 252, 250; 56, 53, 82, 253, 254, 252; 34, 35, 82, 255, 251, 256; 67, 34, 82, 192, 256, 257; 53, 67, 82, 160, 257, 254; 11, 12, 83, 258, 259, 260; 12, 58, 83, 136, 261, 259; 69, 11, 83, 155, 260, 262; 58, 48, 83, 263, 264, 261; 48, 69, 83, 159, 262, 264; 51, 68, 84, 152, 265, 266; 68, 46, 84, 267, 268, 265; 59, 79, 84, 235, 269, 270; 79, 51, 84, 271, 266, 269; 66, 49, 85, 150, 272, 273; 49, 80, 85, 241, 274, 272; 80, 59, 85, 239, 275, 274; 59, 84, 85, 270, 276, 275; 84, 46, 85, 268, 277, 276; 30, 31, 86, 278, 279, 280; 31, 63, 86, 119, 281, 279; 63, 51, 86, 123, 282, 281; 51, 79, 86, 271, 283, 282; 79, 30, 86, 233, 280, 283; 62, 50, 87, 247, 284, 285; 50, 66, 87, 144, 286, 284; 66, 85, 87, 273, 287, 286; 85, 46, 87, 277, 288, 287; 9, 10, 88, 289, 290, 291; 53, 56, 88, 253, 292, 293; 56, 9, 88, 103, 291, 292; 10, 69, 88, 156, 294, 290; 69, 53, 88, 161, 293, 294; 13, 14, 89, 295, 296, 297; 14, 62, 89, 116, 298, 296; 62, 52, 89, 299, 300, 298; 52, 65, 89, 140, 301, 300; 65, 13, 89, 134, 297, 301; 52, 62, 90, 299, 302, 303; 46, 68, 90, 267, 304, 305; 68, 52, 90, 153, 303, 304; 62, 87, 90, 285, 306, 302; 87, 46, 90, 288, 305, 306; 61, 45, 91, 147, 307, 308; 45, 64, 91, 309, 310, 307; 64, 54, 91, 132, 311, 310; 45, 60, 92, 145, 312, 313; 55, 64, 92, 130, 314, 315; 64, 45, 92, 309, 313, 314; 47, 57, 93, 125, 316, 317; 58, 47, 93, 141, 317, 318; 57, 48, 93, 194, 319, 316; 48, 58, 93, 263, 318, 319; 26, 61, 94, 113, 320, 321; 25, 26, 94, 322, 321, 323; 71, 25, 94, 174, 323, 324; 54, 71, 94, 177, 324, 325; 61, 91, 94, 308, 326, 320; 91, 54, 94, 311, 325, 326; 60, 17, 95, 109, 327, 328; 17, 18, 95, 329, 330, 327; 18, 72, 95, 180, 331, 330; 72, 55, 95, 185, 332, 331; 55, 92, 95, 315, 333, 332; 92, 60, 95, 312, 328, 333] 'nudos de cada triángulo (esquinas 1-2-3, medios 12-23-31)
L_g = [40, 42, 44, 46, 48, 49, 50, 51, 52, 53, 54, 55, 56, 57, 58, 59, 60, 61, 62, 63, 64, 65, 66, 67, 68, 69, 70, 71, 72, 73, 74, 75, 76, 77, 78, 79, 80, 81, 82, 83, 84, 86, 88, 89, 90, 91, 92, 93, 94, 95, 96, 97, 98, 99, 100, 101, 102, 103, 104, 105, 106, 107, 108, 109, 110, 111, 112, 113, 114, 115, 116, 117, 118, 119, 120, 121, 122, 123, 124, 125, 126, 127, 128, 129, 130, 131, 132, 133, 134, 135, 136, 137, 138, 139, 140, 141, 142, 143, 144, 145, 146, 147, 148, 149, 150, 151, 152, 153, 154, 155, 156, 157, 158, 159, 160, 161, 162, 163, 164, 165, 166, 167, 168, 169, 170, 171, 172, 173, 174, 175, 176, 177, 178, 179, 180, 181, 182, 183, 184, 185, 186, 187, 188, 189, 190, 193, 194, 196, 197, 198, 200, 201, 202, 205, 206, 207, 208, 209, 210, 211, 212, 213, 214, 217, 218, 219, 220, 221, 222, 223, 224, 225, 226, 229, 230, 231, 232, 233, 234, 235, 236, 237, 238, 239, 240, 241, 242, 243, 244, 245, 246, 247, 248, 249, 250, 252, 253, 254, 255, 256, 257, 258, 259, 260, 261, 262, 263, 264, 267, 268, 269, 270, 271, 272, 273, 274, 275, 276, 277, 278, 279, 280, 281, 282, 283, 284, 285, 286, 287, 288, 289, 290, 291, 292, 293, 294, 295, 296, 297, 298, 299, 300, 301, 302, 303, 304, 305, 306, 309, 310, 311, 312, 313, 314, 315, 316, 317, 318, 319, 320, 321, 322, 325, 326, 327, 328, 329, 330, 331, 332, 333, 334, 335, 336, 337, 338, 340, 341, 342, 343, 344, 345, 346, 347, 348, 350, 351, 352, 353, 354, 357, 358, 359, 360, 362, 363, 364, 366, 367, 368, 369, 370, 371, 372, 373, 374, 375, 376, 377, 378, 379, 380, 381, 382, 383, 384, 385, 386, 387, 388, 389, 390, 393, 394, 395, 396, 397, 398, 399, 400, 401, 402, 405, 406, 407, 408, 409, 410, 411, 412, 413, 414, 415, 416, 417, 418, 421, 422, 423, 424, 425, 426, 427, 428, 429, 430, 431, 432, 435, 436, 437, 438, 439, 440, 441, 442, 443, 444, 445, 446, 449, 450, 451, 452, 453, 454, 455, 456, 457, 458, 459, 460, 461, 462, 463, 464, 465, 466, 467, 468, 469, 470, 471, 472, 473, 474, 475, 476, 477, 478, 479, 480, 481, 482, 485, 486, 487, 488, 489, 490, 491, 492, 493, 494, 495, 496, 497, 498, 499, 500, 501, 502, 503, 504, 505, 506, 507, 508, 509, 510, 511, 512, 513, 514, 517, 518, 519, 520, 521, 522, 523, 524, 525, 526, 527, 528, 529, 530, 531, 532, 533, 534, 535, 536, 537, 538, 539, 540, 541, 542, 543, 544, 545, 546, 547, 548, 549, 550, 551, 552, 553, 554, 555, 556, 557, 558, 559, 560, 561, 562, 563, 564, 565, 566, 567, 568, 569, 570, 571, 572, 573, 574, 575, 576, 579, 580, 581, 582, 583, 584, 585, 586, 587, 588, 591, 592, 593, 594, 595, 596, 597, 598, 599, 600, 601, 602, 603, 604, 605, 606, 607, 608, 609, 610, 611, 612, 613, 614, 615, 616, 617, 618, 619, 620, 621, 622, 623, 624, 625, 626, 627, 628, 629, 630, 631, 632, 633, 634, 635, 636, 637, 638, 639, 640, 641, 642, 643, 644, 645, 646, 647, 648, 649, 650, 651, 652, 653, 654, 655, 656, 659, 660, 661, 662, 663, 664, 665, 666] 'grados de libertad libres
E_s = 100000
nu = 0.3
gam = 19.6363
l_a = E_s·nu/((1 + nu)·(1 - 2·nu))
G_s = E_s/(2·(1 + nu))
D_e = [l_a + 2·G_s, l_a, l_a, 0; l_a, l_a + 2·G_s, l_a, 0; l_a, l_a, l_a + 2·G_s, 0; 0, 0, 0, G_s]
c_7 = 0.1012865073235
C_7 = 0.7974269853531
e_7 = 0.4701420641051
E_7 = 0.0597158717898
P_g = [1/3, 1/3; c_7, c_7; C_7, c_7; c_7, C_7; e_7, e_7; E_7, e_7; e_7, E_7]
W_g = [0.225/2, 0.1259391805448/2, 0.1259391805448/2, 0.1259391805448/2, 0.1323941527885/2, 0.1323941527885/2, 0.1323941527885/2]
n_n = 333
n_e = 144
#show
n_nudos = n_n
n_triangulos = n_e
n_libres = length(L_g)
#: **3 · bis · El primer triángulo, a mano** (el de la esquina izquierda), en su primer punto de Hammer (L₁ = L₂ = 1/3):
#hide
x_e1 = zeros(6, 1)
y_e1 = zeros(6, 1)
for a = 1:6
  x_e1(a) = X_n(E_t(1, a))
  y_e1(a) = Y_n(E_t(1, a))
end
#show
x_e1
y_e1
J_11n = (4/3 - 1)·x_e1(1) - (4/3 - 1)·x_e1(3) + (4/3)·x_e1(4) - (4/3)·x_e1(5) + (4/3 - 4/3)·x_e1(6)
J_12n = (4/3 - 1)·y_e1(1) - (4/3 - 1)·y_e1(3) + (4/3)·y_e1(4) - (4/3)·y_e1(5) + (4/3 - 4/3)·y_e1(6)
J_21n = (4/3 - 1)·x_e1(2) - (4/3 - 1)·x_e1(3) + (4/3)·x_e1(4) + (4/3 - 4/3)·x_e1(5) - (4/3)·x_e1(6)
J_22n = (4/3 - 1)·y_e1(2) - (4/3 - 1)·y_e1(3) + (4/3)·y_e1(4) + (4/3 - 4/3)·y_e1(5) - (4/3)·y_e1(6)
det_J1 = J_11n·J_22n - J_12n·J_21n 'det J = 2·área [m²]

## 4 · Parte LINEAL: K·u = F una sola vez
#hide
K = zeros(2·n_n, 2·n_n)
B_s = zeros(4·7·n_e, 12)
w_s = zeros(7·n_e, 1)
G_e = zeros(n_e, 12)
F = zeros(2·n_n, 1)
for e = 1:n_e
  x_e = zeros(6, 1)
  y_e = zeros(6, 1)
  g = zeros(12, 1)
  for a = 1:6
    x_e(a) = X_n(E_t(e, a))
    y_e(a) = Y_n(E_t(e, a))
    g(2·a - 1) = 2·E_t(e, a) - 1
    g(2·a) = 2·E_t(e, a)
  end
  Kel = zeros(12, 12)
  for q = 1:7
    L_1 = P_g(q, 1)
    L_2 = P_g(q, 2)
    L_3 = 1 - L_1 - L_2
    N_v = [L_1·(2·L_1 - 1), L_2·(2·L_2 - 1), L_3·(2·L_3 - 1), 4·L_1·L_2, 4·L_2·L_3, 4·L_3·L_1]
    d_1 = [4·L_1 - 1, 0, -(4·L_3 - 1), 4·L_2, -4·L_2, 4·L_3 - 4·L_1]
    d_2 = [0, 4·L_2 - 1, -(4·L_3 - 1), 4·L_1, 4·L_3 - 4·L_2, -4·L_1]
    j_11 = 0
    j_12 = 0
    j_21 = 0
    j_22 = 0
    for a = 1:6
      j_11 = j_11 + d_1(a)·x_e(a)
      j_12 = j_12 + d_1(a)·y_e(a)
      j_21 = j_21 + d_2(a)·x_e(a)
      j_22 = j_22 + d_2(a)·y_e(a)
    end
    d_J = j_11·j_22 - j_12·j_21
    B = zeros(4, 12)
    for a = 1:6
      B(1, 2·a - 1) = (j_22·d_1(a) - j_12·d_2(a))/d_J
      B(2, 2·a) = (-j_21·d_1(a) + j_11·d_2(a))/d_J
      B(4, 2·a - 1) = B(2, 2·a)
      B(4, 2·a) = B(1, 2·a - 1)
    end
    Kel = Kel + transpose(B)·D_e·B·d_J·W_g(q)
    i_g = 7·(e - 1) + q
    B_s(4·(i_g - 1) + 1:4·i_g, 1:12) = B
    w_s(i_g) = d_J·W_g(q)
    for a = 1:6
      F(g(2·a)) = F(g(2·a)) - N_v(a)·gam·d_J·W_g(q)
    end
  end
  K(g, g) = K(g, g) + Kel
  G_e(e, 1:12) = transpose(g)
end
u_el = zeros(2·n_n, 1)
u_el(L_g) = lsolve(K(L_g, L_g), F(L_g))
m_el = 0
for i = 1:n_n
  m_el = max(m_el, sqrt(u_el(2·i - 1)^2 + u_el(2·i)^2))
end
#show
peso_total = -sum(F) 'kN por metro de talud
u_lineal = 1000·m_el 'mm (Hekatan Geotechnic con el suelo elástico: 38.82 mm)
#: Lo lineal da un número, pero no sabe si el suelo aguanta: con cualquier F daría lo mismo.

## 5 · Parte NO LINEAL: Drucker-Prager y Newton para cada F
#: Para cada F se divide la resistencia (c/F, tan φ/F) y se arranca de cero con el peso propio completo, como hace Geotechnic en cada peldaño. Si en 12 iteraciones las normas no bajan de 0.01 (crecen), NO hay equilibrio: el talud se cayó.
#hide
F_l = [1; 1.4; 1.52; 1.55]
n_F = 4
U_F = zeros(2·n_n, n_F)
C_F = zeros(n_F, 1)
I_F = zeros(n_F, 1)
M_F = zeros(n_F, 1)
H_1 = zeros(40, 4)
for i_F = 1:n_F
  F_r = F_l(i_F)
  p_r = atan(tan(20·pi/180)/F_r)
  c_r = 14.9625/F_r
  a_l = 2·sin(p_r)/(sqrt(3)·(3 + sin(p_r)))
  k_d = 6·c_r·cos(p_r)/(sqrt(3)·(3 + sin(p_r)))
  K_b = E_s/(3·(1 - 2·nu))
  O_n = [1; 1; 1; 0]
  P_d = [2/3, -1/3, -1/3, 0; -1/3, 2/3, -1/3, 0; -1/3, -1/3, 2/3, 0; 0, 0, 0, 1]
  n_g = 7·n_e
  S_g = zeros(4·n_g, 1)
  P_l = zeros(n_g, 1)
  D_g = zeros(4·n_g, 4)
  for i = 1:n_g
    D_g(4·(i - 1) + 1:4·i, 1:4) = D_e
  end
  u = zeros(2·n_n, 1)
  A_d = zeros(length(L_g), 1)
  F_f = F(L_g)
  Fint = zeros(2·n_n, 1)
  c_v = 0
  i_t = 0
  H_n = zeros(40, 4)
  while c_v == 0
    i_t = i_t + 1
    K_t = zeros(2·n_n, 2·n_n)
    for e = 1:n_e
      g = zeros(12, 1)
      for a = 1:6
        g(2·a - 1) = 2·E_t(e, a) - 1
        g(2·a) = 2·E_t(e, a)
      end
      Kel = zeros(12, 12)
      for q = 1:7
        i_g = 7·(e - 1) + q
        B = B_s(4·(i_g - 1) + 1:4·i_g, 1:12)
        Kel = Kel + transpose(B)·D_g(4·(i_g - 1) + 1:4·i_g, 1:4)·B·w_s(i_g)
      end
      K_t(g, g) = K_t(g, g) + Kel
    end
    R = F - Fint
    d_u = zeros(2·n_n, 1)
    d_u(L_g) = lsolve(K_t(L_g, L_g), R(L_g))
    e_t = 1
    for p_s = 1:2
      F_n = zeros(2·n_n, 1)
      for e = 1:n_e
        g = zeros(12, 1)
        for a = 1:6
          g(2·a - 1) = 2·E_t(e, a) - 1
          g(2·a) = 2·E_t(e, a)
        end
        for q = 1:7
          i_g = 7·(e - 1) + q
          B = B_s(4·(i_g - 1) + 1:4·i_g, 1:12)
          s_t = S_g(4·(i_g - 1) + 1:4·i_g) + D_e·B·d_u(g)·e_t
          I_1 = s_t(1) + s_t(2) + s_t(3)
          s_m = I_1/3
          s_d = s_t - s_m·O_n
          J_2 = sqrt(max(0.5·(s_d(1)^2 + s_d(2)^2 + s_d(3)^2) + s_d(4)^2, 0))
          f_y = J_2 + a_l·I_1 - k_d
          D_p = D_e
          if f_y > 1e-12
            a_p = k_d/(3·a_l)
            o_k = 0
            if s_m < a_p
              if J_2 > 1e-12
                if J_2 - f_y >= 1e-12
                  o_k = 1
                end
              end
            end
            if o_k == 1
              b_t = (J_2 - f_y)/J_2
              s_t = s_m·O_n + b_t·s_d
              p_m = (s_t(1) + s_t(2) + s_t(3))/3
              d_v = s_t - p_m·O_n
              s_j = sqrt(max(0.5·(d_v(1)^2 + d_v(2)^2 + d_v(3)^2) + d_v(4)^2, 0))
              w_v = [d_v(1); d_v(2); d_v(3); 2·d_v(4)]/(2·s_j)
              n_v = w_v + a_l·O_n
              X_i = K_b·O_n·transpose(O_n) + b_t·2·G_s·P_d
              X_i(4, 4) = b_t·G_s
              X_m = X_i·w_v
              d_n = sum(n_v.*X_m)
              D_p = X_i - X_m·(transpose(n_v)·X_i)/d_n
            else
              s_t = [a_p; a_p; a_p; 0]
            end
          end
          if p_s == 2
            P_l(i_g) = 0
            if f_y > 1e-12
              P_l(i_g) = 1
            end
            S_g(4·(i_g - 1) + 1:4·i_g) = s_t
            D_g(4·(i_g - 1) + 1:4·i_g, 1:4) = D_p
          end
          F_n(g) = F_n(g) + transpose(B)·s_t·w_s(i_g)
        end
      end
      if p_s == 1
        R_1 = F(L_g) - F_n(L_g)
        s_0 = sum(d_u(L_g).*R(L_g))
        s_1 = sum(d_u(L_g).*R_1)
        n_0 = sqrt(sum((R(L_g)).*(R(L_g))))
        n_1 = sqrt(sum((R_1).*(R_1)))
        a_c = 1
        if min(min(n_0, n_1), abs(s_0 - s_1)) > 1e-10
          if n_1/n_0 >= 0.8
            a_c = s_0/(s_0 - s_1)
          end
        end
        e_t = min(max(a_c, 0.1), 1)
      end
    end
    Fint = F_n
    u = u + e_t·d_u
    d_f = e_t·d_u(L_g)
    A_d = A_d + d_f
    R_f = F(L_g) - Fint(L_g)
    e_u = sqrt(sum((d_f).*(d_f)))
    e_f = sqrt(sum((R_f).*(R_f)))/sqrt(sum((F_f).*(F_f)))
    e_e = sqrt(abs(sum(d_f.*R_f)))/sqrt(abs(sum(A_d.*F_f)))
    H_n(i_t, 1) = e_t
    H_n(i_t, 2) = e_u
    H_n(i_t, 3) = e_f
    H_n(i_t, 4) = e_e
    if max(max(e_u, e_f), e_e) < 0.01
      c_v = 1
    end
    if i_t >= 12
      c_v = 2
    end
  end
  u_max = 0
  for i = 1:n_n
    u_max = max(u_max, sqrt(u(2·i - 1)^2 + u(2·i)^2))
  end
  U_F(1:2·n_n, i_F) = u
  if i_F == 1
    P_10 = P_l
  end
  if i_F == 3
    P_15 = P_l
  end
  C_F(i_F) = c_v
  I_F(i_F) = i_t
  M_F(i_F) = 1000·u_max
  if i_F == 1
    H_1 = H_n
    n_h = i_t
  end
end
#show
#: **Newton con F = 1** (cada fila es una iteración: η de la búsqueda lineal y las tres normas de GEO5):
Hist = H_1(1:n_h, 1:4) 'columnas: η, DNorm, OBFNorm, ENorm
#: **Resultado para cada F** (1 = converge, 2 = NO converge en 12 iteraciones: las normas crecen) y |u| máximo en mm:
#tabla("F:2","¿converge?:0","iteraciones:0","|u| máx [mm]:4")(F_l; C_F; I_F; M_F)
#: Hekatan Geotechnic con la MISMA malla (y el programa de referencia en Python, línea por línea) da |u| máx = 45.3220 mm con F = 1, 59.5693 mm con F = 1.4 y 96.844 mm con F = 1.52: la hoja da lo mismo a cuatro decimales. Con F = 1.55 la iteración se dispara: el factor de seguridad está entre 1.52 y 1.55 (Geotechnic con su escalera de GEO5: 1.524).

## 6 · Mapas de Δu = |u(F) − u(1)| (pasa el cursor: valor en cada punto)
#hide
d_14 = zeros(n_n, 1)
d_15 = zeros(n_n, 1)
for i = 1:n_n
  d_14(i) = 1000·sqrt((U_F(2·i - 1, 2) - U_F(2·i - 1, 1))^2 + (U_F(2·i, 2) - U_F(2·i, 1))^2)
  d_15(i) = 1000·sqrt((U_F(2·i - 1, 3) - U_F(2·i - 1, 1))^2 + (U_F(2·i, 3) - U_F(2·i, 1))^2)
end
p_n = zeros(n_n, 1)
c_n = zeros(n_n, 1)
for e = 1:n_e
  p_e = 0
  for q = 1:7
    p_e = p_e + max(P_15(7·(e - 1) + q) - P_10(7·(e - 1) + q), 0)/7
  end
  for a = 1:6
    p_n(E_t(e, a)) = p_n(E_t(e, a)) + p_e
    c_n(E_t(e, a)) = c_n(E_t(e, a)) + 1
  end
end
for i = 1:n_n
  p_n(i) = p_n(i)/c_n(i)
end
#show
#: **La superficie de falla:** los puntos de Gauss que PASAN a plásticos al debilitar el suelo de F = 1 a F = 1.52 (fracción de los 7 de cada triángulo; promedio en los nudos). Con F = 1 el peso propio ya hace fluir algunos puntos en la base (confinados, no fallan): se restan. Lo que queda es la banda que une el PIE con la CORONA: el mecanismo de falla. Pasa el cursor para ver el valor.
#campo(X_n, Y_n, E_t, p_n)
#: **Sobre los triángulos de la malla** (como los programas de elementos finitos): el valor de cada nudo, interpolado dentro de cada triángulo. **F = 1.4** (Δu en mm):
#campo(X_n, Y_n, E_t, d_14)
#: **F = 1.52** (el último que converge): la cuña que desliza une el pie con la corona.
#campo(X_n, Y_n, E_t, d_15)
#: **Lo mismo pasado a una rejilla** (para el mapa 2D clásico y el 3D):
#: El campo de cada triángulo se interpola con sus MISMAS funciones de forma N₁…N₆ en una rejilla de 0.381 m (91.44/240: cae justo en los bordes del talud); entre los puntos de la rejilla, interpolación bilineal.
#hide
h_g = 91.44/240
n_x = 241
n_y = 61
M_14 = zeros(n_x, n_y)
M_15 = zeros(n_x, n_y)
Z_m = zeros(n_x, n_y)
for i = 1:n_x
  for j = 1:n_y
    M_14(i, j) = 0
    M_15(i, j) = 0
  end
end
for e = 1:n_e
  x_1 = X_n(E_t(e, 1))
  y_1 = Y_n(E_t(e, 1))
  x_2 = X_n(E_t(e, 2))
  y_2 = Y_n(E_t(e, 2))
  x_3 = X_n(E_t(e, 3))
  y_3 = Y_n(E_t(e, 3))
  d_t = (x_2 - x_1)·(y_3 - y_1) - (x_3 - x_1)·(y_2 - y_1)
  i_a = max(1, floor(min(min(x_1, x_2), x_3)/h_g) + 1)
  i_b = min(n_x, ceil(max(max(x_1, x_2), x_3)/h_g) + 1)
  j_a = max(1, floor(min(min(y_1, y_2), y_3)/h_g) + 1)
  j_b = min(n_y, ceil(max(max(y_1, y_2), y_3)/h_g) + 1)
  for i = i_a:i_b
    for j = j_a:j_b
      x_p = (i - 1)·h_g
      y_p = (j - 1)·h_g
      L_2 = ((x_p - x_1)·(y_3 - y_1) - (x_3 - x_1)·(y_p - y_1))/d_t
      L_3 = ((x_2 - x_1)·(y_p - y_1) - (x_p - x_1)·(y_2 - y_1))/d_t
      L_1 = 1 - L_2 - L_3
      if min(min(L_1, L_2), L_3) > -1e-9
        N_v = [L_1·(2·L_1 - 1), L_2·(2·L_2 - 1), L_3·(2·L_3 - 1), 4·L_1·L_2, 4·L_2·L_3, 4·L_3·L_1]
        x_u = zeros(2, 1)
        y_u = zeros(2, 1)
        for a = 1:6
          n_d = E_t(e, a)
          x_u(1) = x_u(1) + N_v(a)·(U_F(2·n_d - 1, 2) - U_F(2·n_d - 1, 1))
          y_u(1) = y_u(1) + N_v(a)·(U_F(2·n_d, 2) - U_F(2·n_d, 1))
          x_u(2) = x_u(2) + N_v(a)·(U_F(2·n_d - 1, 3) - U_F(2·n_d - 1, 1))
          y_u(2) = y_u(2) + N_v(a)·(U_F(2·n_d, 3) - U_F(2·n_d, 1))
        end
        M_14(i, j) = 1000·sqrt(x_u(1)^2 + y_u(1)^2)
        M_15(i, j) = 1000·sqrt(x_u(2)^2 + y_u(2)^2)
        Z_m(i, j) = 1
      end
    end
  end
end
for i = 1:n_x
  for j = 2:n_y
    if Z_m(i, j) == 0
      M_14(i, j) = M_14(i, j - 1)
      M_15(i, j) = M_15(i, j - 1)
    end
  end
end
#show
#: El terreno: y_s(x) es la superficie del talud; m_s(x, y) vale 1 dentro del suelo y 0 fuera (fuera el mapa queda vacío: 0/0).
y_s(x) = 7.62 + min(max(x - 30.48, 0), 30.48)/2
m_s(x, y) = min(1, max(0, (y_s(x) - y)·1000 + 1))
#: Entre los puntos de la rejilla, interpolación bilineal con sus 4 vecinos: u(x, y) = Σ (1 − fx o fx)·(1 − fy o fy)·M(i, j), con fx, fy la parte fraccionaria de x/h, y/h.
#hide
u_14(x, y) = (1 - (x/h_g - floor(x/h_g)))·(1 - (y/h_g - floor(y/h_g)))·M_14(floor(x/h_g) + 1, floor(y/h_g) + 1) + (x/h_g - floor(x/h_g))·(1 - (y/h_g - floor(y/h_g)))·M_14(min(floor(x/h_g) + 2, n_x), floor(y/h_g) + 1) + (1 - (x/h_g - floor(x/h_g)))·(y/h_g - floor(y/h_g))·M_14(floor(x/h_g) + 1, min(floor(y/h_g) + 2, n_y)) + (x/h_g - floor(x/h_g))·(y/h_g - floor(y/h_g))·M_14(min(floor(x/h_g) + 2, n_x), min(floor(y/h_g) + 2, n_y)) + 0/m_s(x, y)
u_15(x, y) = (1 - (x/h_g - floor(x/h_g)))·(1 - (y/h_g - floor(y/h_g)))·M_15(floor(x/h_g) + 1, floor(y/h_g) + 1) + (x/h_g - floor(x/h_g))·(1 - (y/h_g - floor(y/h_g)))·M_15(min(floor(x/h_g) + 2, n_x), floor(y/h_g) + 1) + (1 - (x/h_g - floor(x/h_g)))·(y/h_g - floor(y/h_g))·M_15(floor(x/h_g) + 1, min(floor(y/h_g) + 2, n_y)) + (x/h_g - floor(x/h_g))·(y/h_g - floor(y/h_g))·M_15(min(floor(x/h_g) + 2, n_x), min(floor(y/h_g) + 2, n_y)) + 0/m_s(x, y)
#show
#: **F = 1.4** (Δu en mm):
#contourf(u_14(x, y), [0 91.44], [0 22.86])
#: **F = 1.52** (el último que converge): la cuña que desliza une el pie con la corona.
#contourf(u_15(x, y), [0 91.44], [0 22.86])
#: **3D** del mismo campo con F = 1.52 (arrastra para girar):
#surf(u_15(x, y), [0 91.44], [0 22.86])

## 7 · La curva no lineal
#hide
C_s = zeros(3, 2)
for i_F = 1:3
  C_s(i_F, 1) = F_l(i_F)
  C_s(i_F, 2) = M_F(i_F) - M_F(1)
end
#show
C_s
#: Δu máximo (mm) contra F, calculado AQUÍ (la recta lineal sería Δu = 0 siempre):
c_14 = C_s(2, 2) 'Δu con F = 1.4 [mm]
c_15 = C_s(3, 2) 'Δu con F = 1.52 [mm]
h_x = [100; 140; 152] 'F × 100 (eje del dibujo)
h_y = [0; c_14; c_15] 'Δu [mm]
h_F = [1; 1.4; 1.52] 'F
#dibujo("Δu máximo contra F, calculado en esta hoja (pasa el cursor por los puntos)", ud = m, escala = auto, alto = 90)
#  linea(100, 0, 160, 0, "gruesa azul")
#  texto(156, 2.5, "lineal: Δu = 0", 2.2, "c")
#  polilinea([100, 140, 152], [0, c_14, c_15], "gruesa rojo")
#  circulo(140, c_14, 0.8, "rojo")
#  circulo(152, c_15, 0.8, "rojo")
#  linea(155, 0, 155, 58, "trazos rojo")
#  texto(155, 60, "F = 1.55: no converge", 2.2, "c")
#  linea(100, 0, 100, 58, "fina")
#  texto(100, -4, "F = 1", 2.2, "c")
#  texto(140, -4, "1.4", 2.2, "c")
#  texto(152, -4, "1.52", 2.2, "c")
#  texto(95, 50, "Δu [mm]", 2.2, "c")
#  hover(h_x, h_y, "F = {#1:2}: Δu = {#2:2} mm", h_F, h_y)
#fin
#: (eje horizontal: F; la recta azul es lo LINEAL, que no cambia con F; la roja es lo NO LINEAL que calcula la hoja; con F = 1.55 ya no hay equilibrio)

## 8 · ¿Está bien? Comparación con XSLOPE
#: XSLOPE (Jones y Williams 2026, SoftwareX 36, código abierto) publica su verificación con los MISMOS taludes de Griffiths y Lane (1999), usando Mohr-Coulomb sin dilatancia y reducción de resistencia por elementos finitos. Para comparar con justicia hay que usar el MISMO modelo de suelo y una malla fina:
FS_xs1 = 1.37 'XSLOPE, ejemplo 1 (sin cimentación)
FS_xs2 = 1.35 'XSLOPE, ejemplo 2 (este talud)
FS_gl = 1.40 'Griffiths y Lane, elementos finitos, ejemplos 1 y 2
FS_hk1 = 1.3717 'Hekatan Geotechnic, ej. 1, Mohr-Coulomb ψ = φ, malla 0.6 m
FS_hk2 = 1.3717 'Hekatan Geotechnic, ej. 2, Mohr-Coulomb ψ = φ, malla 1.2 m
FS_te2 = 1.349 'Tellus, ej. 2, Mohr-Coulomb ψ = 0 (otro programa)
p_1 = 100·(FS_hk1 - FS_xs1)/FS_xs1 'Hekatan contra XSLOPE, ej. 1 [%]
p_2 = 100·(FS_hk2 - FS_xs2)/FS_xs2 'Hekatan contra XSLOPE, ej. 2 [%]
p_3 = 100·(FS_te2 - FS_xs2)/FS_xs2 'Tellus contra XSLOPE, ej. 2 [%]
t_1 = [FS_xs1; FS_gl; FS_hk1; 0] 'FS ejemplo 1
t_2 = [FS_xs2; FS_gl; FS_hk2; FS_te2] 'FS ejemplo 2
#tabla("Programa","Modelo","Ej. 1:3","Ej. 2:3")({"XSLOPE","Griffiths y Lane","Hekatan Geotechnic","Tellus"}; {"Mohr-Coulomb ψ=0","Mohr-Coulomb","Mohr-Coulomb ψ=φ","Mohr-Coulomb ψ=0"}; t_1; t_2)
#: Con el mismo modelo (Mohr-Coulomb) Hekatan queda a +0.1 % y +1.6 % de XSLOPE, dentro de la banda XSLOPE–Griffiths y Lane (1.35–1.40). (Tellus no publica el ej. 1: 0 en la tabla.)
#: **¿Y por qué esta hoja da 1.52–1.55?** Por dos razones que se pueden medir por separado, no por un error:
#: • **El modelo:** el Drucker-Prager de GEO5 (cono redondo) resiste algo más que Mohr-Coulomb (cono hexagonal). Con la malla fina: Drucker-Prager 1.425 (Hekatan) y 1.44 (GEO5) contra Mohr-Coulomb 1.35–1.37.
#: • **La malla:** con triángulos de ~5 m la cuña de falla se dibuja con pocos elementos y la malla es más rígida: el mismo Drucker-Prager pasa de 1.425 (malla de 1.2 m) a 1.524 (malla de 5 m). Por eso esta hoja se compara NUDO A NUDO con Geotechnic en la MISMA malla gruesa (sección 5: idéntica a cuatro decimales), y el valor de diseño sale de la malla fina.
r_DP = 1.425/1.35 'Drucker-Prager / Mohr-Coulomb (malla fina)
r_M = 1.524/1.425 'malla gruesa / malla fina (mismo Drucker-Prager)
#: **Lineal** te dice cuánto se deforma el talud. **No lineal** (la iteración de esta hoja) te dice si se cae.
