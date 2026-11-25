using System;

namespace HekatanLisp
{
    /// <summary>
    /// #campo(x, y, elementos, valores): un campo de elementos finitos pintado SOBRE su malla (25-nov-2026, Jorge: los mapas del
    /// talud tenían que verse como en los programas de FEM). T6 → 4 subtriángulos con sus nudos medios (esquinas 1-2-3, medios
    /// 12-23-31); T3 → 1; Q4/Q8/Q9 → 2 con las esquinas. Dentro de cada subtriángulo el valor es lineal. Se muestrea en una rejilla
    /// fina (NaN fuera de la malla, que MapPngGrid deja en blanco) y se dibuja con el MISMO mapa de bandas, isolíneas y cursor de #contourf.
    /// </summary>
    public static class CampoPlot
    {
        public static string Html(double[] X, double[] Y, int[][] E, double[] V, bool dark, int nn = 300)
        {
            int n = X.Length;
            if (n == 0 || Y.Length != n || V.Length != n) throw new ArgumentException("#campo: x, y y valores deben tener un dato por nudo");
            var tris = new System.Collections.Generic.List<(int, int, int)>();
            foreach (var el in E)
            {
                var q = Array.ConvertAll(el, j => j - 1);
                if (Array.Exists(q, j => j < 0 || j >= n)) continue;
                if (q.Length >= 6 && q.Length < 8) { tris.Add((q[0], q[3], q[5])); tris.Add((q[3], q[1], q[4])); tris.Add((q[5], q[4], q[2])); tris.Add((q[3], q[4], q[5])); }
                else if (q.Length == 3) tris.Add((q[0], q[1], q[2]));
                else if (q.Length >= 4) { tris.Add((q[0], q[1], q[2])); tris.Add((q[0], q[2], q[3])); }
            }
            double xa = double.MaxValue, xb = double.MinValue, ya = double.MaxValue, yb = double.MinValue;
            for (int i = 0; i < n; i++) { xa = Math.Min(xa, X[i]); xb = Math.Max(xb, X[i]); ya = Math.Min(ya, Y[i]); yb = Math.Max(yb, Y[i]); }
            if (xb - xa < 1e-12) xb = xa + 1; if (yb - ya < 1e-12) yb = ya + 1;
            var Z = new double[nn + 1, nn + 1];
            for (int i = 0; i <= nn; i++) for (int j = 0; j <= nn; j++) Z[i, j] = double.NaN;
            double hx = (xb - xa) / nn, hy = (yb - ya) / nn;
            foreach (var (a, b, c) in tris)
            {
                double det = (Y[b] - Y[c]) * (X[a] - X[c]) + (X[c] - X[b]) * (Y[a] - Y[c]);
                if (Math.Abs(det) < 1e-14) continue;
                int i0 = Math.Max(0, (int)Math.Floor((Math.Min(X[a], Math.Min(X[b], X[c])) - xa) / hx)), i1 = Math.Min(nn, (int)Math.Ceiling((Math.Max(X[a], Math.Max(X[b], X[c])) - xa) / hx));
                int j0 = Math.Max(0, (int)Math.Floor((Math.Min(Y[a], Math.Min(Y[b], Y[c])) - ya) / hy)), j1 = Math.Min(nn, (int)Math.Ceiling((Math.Max(Y[a], Math.Max(Y[b], Y[c])) - ya) / hy));
                for (int i = i0; i <= i1; i++)
                    for (int j = j0; j <= j1; j++)
                    {
                        double x = xa + hx * i, y = ya + hy * j;
                        double l1 = ((Y[b] - Y[c]) * (x - X[c]) + (X[c] - X[b]) * (y - Y[c])) / det;
                        double l2 = ((Y[c] - Y[a]) * (x - X[c]) + (X[a] - X[c]) * (y - Y[c])) / det, l3 = 1 - l1 - l2;
                        if (l1 >= -1e-9 && l2 >= -1e-9 && l3 >= -1e-9) Z[i, j] = l1 * V[a] + l2 * V[b] + l3 * V[c];
                    }
            }
            string b64 = SurfacePlot.MapPngGrid(Z, nn, xa, xb, ya, yb, dark, true, 12);
            string img = "<img style=\"max-width:100%;height:auto\" src=\"data:image/png;base64," + b64 + "\">";
            // el cursor: rejilla de 150 (la del hover de #contourf) sin NaN (fuera de la malla: 0)
            const int nh = 150;
            var Zh = new double[nh + 1, nh + 1];
            for (int i = 0; i <= nh; i++)
                for (int j = 0; j <= nh; j++)
                {
                    double v = Z[(int)Math.Round((double)i * nn / nh), (int)Math.Round((double)j * nn / nh)];
                    Zh[i, j] = double.IsNaN(v) ? 0 : v;
                }
            return SurfacePlot.MapHoverGrid(Zh, nh, "x", "y", xa, xb, ya, yb, img, SurfacePlot.AltoProporcional(xa, xb, ya, yb));
        }
    }
}
