# Placa de Kirchhoff BFS simbólica: Hekatan LISP vs wxMaxima vs Hekatan Lab

Mismo cálculo en los tres: funciones de forma (Hermite), Jacobiano, B, D y
k = ∫∫ Bᵀ·D·B·detJ dξ dη para k11 y k12 en a, b, Dp, ν. Los tres dan lo mismo:

- k11 = (780·a⁴ + 504·a²·b² + 780·b⁴)·Dp / (175·a³·b³)  → con a = b = 1: 2064·Dp/175
- k12 = (210·a²·b²·ν + 110·b⁴ + 42·a²·b² + 390·a⁴)·Dp / (175·a³·b²)

Tiempo por pasada (1 de calentamiento, luego promedio), mismo PC, 19-nov-2026:

| Programa | Tiempo |
|---|---|
| Hekatan LISP escritorio (SBCL nativo) | 4.0 ms |
| wxMaxima 25.04 / Maxima 5.48.1 (SBCL) | 14–45 ms (24.5 ms en la corrida de la captura) |
| Hekatan LISP web (WebAssembly, navegador) | ~69 ms |
| Hekatan Lab (Giac) | 87.5 ms |

Archivos:
- Hekatan LISP: `ejemplos/Placa Kirchhoff BFS simbolica - forma, Jacobiano, B y k contra wxMaxima.lisp` (tic / toc)
- wxMaxima: `bfs_simbolico_wxmaxima.wxm` (Celda → Evaluar todas las celdas)
- Hekatan Lab: `bfs_simbolico_hekatan_lab.m`
