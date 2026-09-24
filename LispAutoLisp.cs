using System;
using System.Collections.Generic;
using System.Globalization;
using System.Linq;
using System.Text;
using System.Text.RegularExpressions;

namespace HekatanLisp
{
    /// <summary>
    /// DIBUJO AL ESTILO AUTOLISP (24-sep-2026). El dibujo lo hace el MOTOR LISP (engine.lisp, sección
    /// «AUTOLISP»: entmake / ssget / entget con listas DXF, y la capa simple punto/linea/curva/ejes…);
    /// aquí solo se LEE lo que el motor imprime al final (hk-al-volcar) y se convierte en:
    ///   · SVG (encuadre automático = extensión de las entidades, colores ACI, capas, tipos de línea),
    ///   · DXF ASCII R12 (guardar-dxf): lo abre AutoCAD sin tablas de clases ni handles.
    /// Compartido escritorio/web (web/HekatanLispWeb.csproj lo enlaza).
    ///
    /// En la hoja:
    ///   #autolisp("Título", ancho = 160, alto = 110, vert = 1, exporta = n A, nuevo = no)
    ///   (setq H 10.0) … código LISP / AutoLISP …
    ///   #fin
    /// Las definiciones de la hoja que van ANTES (L = 6, f(x) = x^2) llegan como (setq …); los nombres
    /// de «exporta» vuelven a la hoja como líneas «n = valor» justo después del dibujo.
    /// </summary>
    public static class LispAutoLisp
    {
        static readonly CultureInfo Inv = CultureInfo.InvariantCulture;
        const char FS = '\u001c', US = '\u001f';

        public static readonly Regex RxInicio = new Regex(@"^\s*#\s*autolisp\s*(?:\((?<a>.*)\))?\s*$", RegexOptions.IgnoreCase);
        static readonly Regex RxFin = new Regex(@"^\s*#\s*(?:fin\s*autolisp|finautolisp|fin)\s*$", RegexOptions.IgnoreCase);
        public static readonly Regex RxMarca = new Regex(@"^\s*#\s*autolispout\s*\(\s*(\d+)\s*\)\s*$", RegexOptions.IgnoreCase);
        static readonly Regex RxUsaDibujo = new Regex(
            @"\(\s*(entmake|entmakex|ssget|entget|entmod|entdel|punto|linea|circulo|arco|poli|polilinea|rect|texto|cota|curva|curva-par|ejes|achurado|guardar-dxf)[\s)]",
            RegexOptions.IgnoreCase);

        /// <summary>¿Un programa LISP entero usa el dibujo? (entonces se pinta al final)</summary>
        public static bool UsaDibujo(string code) => RxUsaDibujo.IsMatch(code ?? "");

        // ================================ modelo ================================
        public sealed class Capa { public string Nombre = "0"; public int Color = 7; public string Tipo = "CONTINUOUS"; public int Grosor = -3; }
        public sealed class Ent
        {
            public readonly List<KeyValuePair<int, string>> D = new List<KeyValuePair<int, string>>();
            public string Get(int c) { foreach (var p in D) if (p.Key == c) return p.Value; return null; }
            public string Tipo => (Get(0) ?? "").ToUpperInvariant();
            public string CapaN => Get(8) ?? "0";
            public double Num(int c, double def) => double.TryParse(Get(c), NumberStyles.Float, Inv, out var v) ? v : def;
            public int Int(int c, int def) => double.TryParse(Get(c), NumberStyles.Float, Inv, out var v) ? (int)Math.Round(v) : def;
            public static double[] ParsePt(string s)
            {
                if (s == null) return null;
                var t = s.Split(',');
                var r = new double[3];
                for (int i = 0; i < Math.Min(3, t.Length); i++) double.TryParse(t[i], NumberStyles.Float, Inv, out r[i]);
                return r;
            }
            public double[] Pt(int c) => ParsePt(Get(c));
            public List<double[]> Pts(int c) => D.Where(p => p.Key == c).Select(p => ParsePt(p.Value)).ToList();
        }
        public sealed class Dibujo
        {
            public string Titulo = "";
            public List<Ent> Ents = new List<Ent>();
            public List<Capa> Capas = new List<Capa>();
            public Dictionary<string, double> Vars = new Dictionary<string, double>(StringComparer.OrdinalIgnoreCase);
            public List<string> Guardar = new List<string>();
            public double Var(string n, double def) => Vars.TryGetValue(n, out var v) ? v : def;
            public Capa CapaDe(string n) => Capas.FirstOrDefault(c => string.Equals(c.Nombre, n, StringComparison.OrdinalIgnoreCase));
        }
        /// <summary>Lo que imprimió un bloque: texto (princ…), el dibujo y los valores exportados.</summary>
        public sealed class Salida
        {
            public StringBuilder Texto = new StringBuilder();
            public Dibujo Dib;
            public List<KeyValuePair<string, string>> Exporta = new List<KeyValuePair<string, string>>();
        }

        /// <summary>Parte la salida del motor por bloques (marcador K) y lee texto, dibujo y exportados.</summary>
        public static Dictionary<int, Salida> ParseBloques(string output)
        {
            var res = new Dictionary<int, Salida>();
            Salida cur = null;
            foreach (var raw in (output ?? "").Replace("\r", "").Split('\n'))
            {
                if (raw.Length >= 2 && raw[0] == FS)
                {
                    var f = raw.Substring(1).Split(US);
                    string k = f[0];
                    if (k == "K") { int.TryParse(f.Length > 1 ? f[1] : "0", out int id); cur = new Salida(); res[id] = cur; continue; }
                    if (cur == null) { cur = new Salida(); res[0] = cur; }
                    switch (k)
                    {
                        case "B": cur.Dib = new Dibujo { Titulo = f.Length > 1 ? f[1] : "" }; break;
                        case "V": if (cur.Dib != null && f.Length > 2 && double.TryParse(f[2], NumberStyles.Float, Inv, out var vv)) cur.Dib.Vars[f[1]] = vv; break;
                        case "L":
                            if (cur.Dib != null && f.Length > 4)
                                cur.Dib.Capas.Add(new Capa { Nombre = f[1], Color = int.TryParse(f[2], out var c) ? c : 7, Tipo = f[3], Grosor = int.TryParse(f[4], out var g) ? g : -3 });
                            break;
                        case "E":
                            if (cur.Dib != null)
                            {
                                var e = new Ent();
                                for (int i = 1; i < f.Length; i++)
                                {
                                    int eq = f[i].IndexOf('=');
                                    if (eq > 0 && int.TryParse(f[i].Substring(0, eq), out int code)) e.D.Add(new KeyValuePair<int, string>(code, f[i].Substring(eq + 1)));
                                }
                                cur.Dib.Ents.Add(e);
                            }
                            break;
                        case "S": if (cur.Dib != null && f.Length > 1) cur.Dib.Guardar.Add(f[1]); break;
                        case "X": if (f.Length > 2) cur.Exporta.Add(new KeyValuePair<string, string>(f[1], f[2])); break;
                    }
                    continue;
                }
                if (cur == null) { cur = new Salida(); res[0] = cur; }
                cur.Texto.Append(raw).Append('\n');
            }
            return res;
        }

        // ================================ colores ACI ================================
        static readonly int[] Grises = { 0x33, 0x50, 0x69, 0x82, 0xBE, 0xFF };
        /// <summary>Color ACI → CSS. 1-9 y 30 afinados al tema (claro/oscuro) como el resto de la hoja;
        /// el resto por la regla de la paleta ACI (tono cada 15°, pares saturados, impares pálidos).</summary>
        public static string AciCss(int c, bool dk)
        {
            const bool svg = true;
            switch (c)
            {
                case 0: case 7: case 256: return svg ? "var(--fg)" : (dk ? "#f0efec" : "#171310");
                case 1: return svg ? "var(--dib-rojo)" : (dk ? "#ff6b5e" : "#c62828");
                case 2: return dk ? "#ffd43b" : "#b08800";
                case 3: return svg ? "var(--dib-verde)" : (dk ? "#4cc38a" : "#2b8a3e");
                case 4: return dk ? "#3bc9db" : "#0b7285";
                case 5: return svg ? "var(--dib-azul)" : (dk ? "#6fa8ff" : "#1c5fbf");
                case 6: return dk ? "#f783ac" : "#a61e8c";
                case 8: return dk ? "#8a8f94" : "#7a7a7a";
                case 9: return dk ? "#5c6166" : "#b8b8b8";
                case 30: return svg ? "var(--dib-nar)" : (dk ? "#ffa94d" : "#d9480f");
            }
            if (c >= 250 && c <= 255) { int g = Grises[c - 250]; return "#" + g.ToString("x2") + g.ToString("x2") + g.ToString("x2"); }
            if (c < 10 || c > 249) return "var(--fg)";
            double hue = (c / 10 - 1) * 15.0, sub = c % 10;
            double[] val = { 1.0, 0.65, 0.5, 0.3, 0.15 };
            double v = val[(int)sub / 2], s = ((int)sub % 2 == 0) ? 1.0 : 0.5;
            return HsvHex(hue, s, v);
        }
        static string HsvHex(double h, double s, double v)
        {
            double cc = v * s, x = cc * (1 - Math.Abs(h / 60 % 2 - 1)), m = v - cc;
            double r = 0, g = 0, b = 0;
            if (h < 60) { r = cc; g = x; } else if (h < 120) { r = x; g = cc; } else if (h < 180) { g = cc; b = x; }
            else if (h < 240) { g = x; b = cc; } else if (h < 300) { r = x; b = cc; } else { r = cc; b = x; }
            int R = (int)Math.Round((r + m) * 255), G = (int)Math.Round((g + m) * 255), B = (int)Math.Round((b + m) * 255);
            return "#" + R.ToString("x2") + G.ToString("x2") + B.ToString("x2");
        }
        static string Dash(string tipo) => (tipo ?? "").ToUpperInvariant() switch
        {
            "DASHED" or "DASHED2" or "DASHEDX2" => "2.5 1.25",
            "HIDDEN" or "HIDDEN2" => "1.25 0.65",
            "CENTER" or "CENTER2" => "6 1.2 1.2 1.2",
            "DOT" or "DOT2" => "0.01 0.9",
            "PHANTOM" => "6 1.2 1.2 1.2 1.2 1.2",
            "DASHDOT" => "3 1 0.01 1",
            _ => null,
        };

        // resuelve PORCAPA: color, tipo de línea y grosor de la entidad
        static (int col, string tipo, double w, bool apagada) Estilo(Dibujo d, Ent e)
        {
            var cp = d.CapaDe(e.CapaN) ?? new Capa();
            int col = e.Int(62, 256);
            bool off = cp.Color < 0;
            if (col == 256) col = Math.Abs(cp.Color);
            if (col == 0) col = 7;
            string tipo = e.Get(6);
            if (tipo == null || tipo.Equals("BYLAYER", StringComparison.OrdinalIgnoreCase)) tipo = cp.Tipo;
            int lw = e.Int(370, -1);
            if (lw < 0) lw = cp.Grosor;
            double w = lw >= 0 ? Math.Max(0.13, lw / 100.0) : 0.25;
            return (col, tipo, w, off);
        }

        // ================================ encuadre ================================
        /// <summary>Transformación mundo → papel (mm): X = pad + (x − x0)·k; Y = pad + (y1 − y·kv)·k.</summary>
        public sealed class Vista
        {
            public double K = 1, Kv = 1, X0, Y1, Pad = 6, W, H;
            public double X(double x) => Pad + (x - X0) * K;
            public double Y(double y) => Pad + (Y1 - y * Kv) * K;
        }

        static IEnumerable<double[]> PuntosExt(Ent e, double kv)
        {
            string t = e.Tipo;
            switch (t)
            {
                case "POLYLINE":
                    foreach (var p in e.Pts(1011)) yield return p;
                    break;
                case "POINT": case "LINE": case "SOLID": case "3DFACE":
                    foreach (var c in new[] { 10, 11, 12, 13 }) { var p = e.Pt(c); if (p != null) yield return p; }
                    break;
                case "CIRCLE":
                {
                    var c = e.Pt(10); double r = e.Num(40, 0);
                    if (c != null) { yield return new[] { c[0] - r, c[1] - r }; yield return new[] { c[0] + r, c[1] + r }; }
                    break;
                }
                case "ARC":
                    foreach (var p in ArcoPuntos(e, 24)) yield return p;
                    break;
                case "LWPOLYLINE":
                    foreach (var p in PoliPuntos(e)) yield return p;
                    break;
                case "HATCH":
                    foreach (var l in Lazos(e)) foreach (var p in l) yield return p;
                    break;
                case "DIMENSION":
                    foreach (var c in new[] { 10, 13, 14 }) { var p = e.Pt(c); if (p != null) yield return p; }
                    break;
                case "TEXT": case "MTEXT":
                {
                    var (x, y, w, h, _, _) = TextoCaja(e);
                    yield return new[] { x, y }; yield return new[] { x + w, y + h };
                    break;
                }
            }
        }

        public static Vista Encuadre(Dibujo d, double anchoMax, double altoMax)
        {
            double kv = d.Var("HKVERT", 1); if (kv <= 0) kv = 1;
            double xmin = double.MaxValue, xmax = double.MinValue, ymin = double.MaxValue, ymax = double.MinValue;
            foreach (var e in d.Ents)
                foreach (var p in PuntosExt(e, kv))
                {
                    if (double.IsNaN(p[0]) || double.IsNaN(p[1])) continue;
                    xmin = Math.Min(xmin, p[0]); xmax = Math.Max(xmax, p[0]);
                    ymin = Math.Min(ymin, p[1] * kv); ymax = Math.Max(ymax, p[1] * kv);
                }
            if (xmin > xmax) { xmin = 0; xmax = 1; ymin = 0; ymax = 1; }
            double wx = Math.Max(xmax - xmin, 1e-9), wy = Math.Max(ymax - ymin, 1e-9);
            if (wx < 1e-6 * Math.Max(1, wy)) { xmin -= 0.5 * wy; wx = wy; }
            if (wy < 1e-6 * Math.Max(1, wx)) { ymin -= 0.5 * wx; wy = wx; }
            bool hayCotas = d.Ents.Any(e => e.Tipo == "DIMENSION");
            var v = new Vista { Kv = kv, X0 = xmin, Y1 = ymax, Pad = hayCotas ? 9 : 5 };
            v.K = Math.Min((anchoMax - 2 * v.Pad) / wx, (altoMax - 2 * v.Pad) / wy);
            v.W = wx * v.K + 2 * v.Pad; v.H = wy * v.K + 2 * v.Pad;
            return v;
        }

        // ================================ geometría ================================
        static List<double[]> ArcoPuntos(Ent e, int nmin)
        {
            var c = e.Pt(10) ?? new double[3]; double r = e.Num(40, 0), a1 = e.Num(50, 0), a2 = e.Num(51, 0);
            double da = a2 - a1; while (da <= 0) da += 2 * Math.PI;
            int n = Math.Max(nmin, (int)Math.Ceiling(da / (Math.PI / 36)));
            var l = new List<double[]>();
            for (int i = 0; i <= n; i++) { double a = a1 + da * i / n; l.Add(new[] { c[0] + r * Math.Cos(a), c[1] + r * Math.Sin(a) }); }
            return l;
        }
        /// <summary>Vértices de la LWPOLYLINE con los tramos con abultamiento (42) muestreados.</summary>
        static List<double[]> PoliPuntos(Ent e) => PoliPuntos(e, out _);
        static List<double[]> PoliPuntos(Ent e, out bool cerrada)
        {
            var vs = new List<double[]>(); var bs = new List<double>();
            foreach (var p in e.D)
            {
                if (p.Key == 10) { vs.Add(Ent.ParsePt(p.Value)); bs.Add(0); }
            }
            // (segunda pasada para los bulges, en orden)
            bs.Clear(); int k = -1;
            foreach (var p in e.D)
            {
                if (p.Key == 10) { bs.Add(0); k++; }
                else if (p.Key == 42 && k >= 0 && double.TryParse(p.Value, NumberStyles.Float, Inv, out var b)) bs[k] = b;
            }
            cerrada = (e.Int(70, 0) & 1) == 1;
            var res = new List<double[]>();
            int n = vs.Count;
            for (int i = 0; i < n; i++)
            {
                res.Add(vs[i]);
                bool ultimo = i == n - 1;
                if (ultimo && !cerrada) break;
                double b = bs[i];
                if (Math.Abs(b) < 1e-12) continue;
                var p = vs[i]; var q = vs[(i + 1) % n];
                double th = 4 * Math.Atan(b), dx = q[0] - p[0], dy = q[1] - p[1], c = Math.Sqrt(dx * dx + dy * dy);
                if (c < 1e-15) continue;
                double r = c / (2 * Math.Sin(Math.Abs(th) / 2));
                double mx = (p[0] + q[0]) / 2, my = (p[1] + q[1]) / 2;
                double h = r * Math.Cos(th / 2) * Math.Sign(b);          // del punto medio al centro, a la izquierda de p→q
                double cx = mx - dy / c * h, cy = my + dx / c * h;
                double a0 = Math.Atan2(p[1] - cy, p[0] - cx);
                int m = Math.Max(4, (int)Math.Ceiling(Math.Abs(th) / (Math.PI / 36)));
                for (int j = 1; j < m; j++) { double a = a0 + th * j / m; res.Add(new[] { cx + r * Math.Cos(a), cy + r * Math.Sin(a) }); }
            }
            return res;
        }
        /// <summary>Contornos de un HATCH: tras cada 93 (nº de vértices) vienen sus 10. Sin 93: todos los 10.</summary>
        public static List<List<double[]>> Lazos(Ent e)
        {
            var lazos = new List<List<double[]>>();
            List<double[]> cur = null; int falta = 0;
            foreach (var p in e.D)
            {
                if (p.Key == 93) { int.TryParse(p.Value, out falta); cur = new List<double[]>(); lazos.Add(cur); continue; }
                if (p.Key == 10 && cur != null && falta > 0) { cur.Add(Ent.ParsePt(p.Value)); falta--; }
            }
            if (lazos.Count == 0) lazos.Add(e.Pts(10));
            return lazos.Where(l => l.Count >= 3).ToList();
        }
        static (double ang, double sep)[] Familias(string patron, double escala, double ang0)
        {
            double s = 3.175 * (escala > 0 ? escala : 1);
            return (patron ?? "").ToUpperInvariant() switch
            {
                "ANSI37" or "NET3" => new[] { (Math.PI / 4 + ang0, s), (3 * Math.PI / 4 + ang0, s) },
                "NET" => new[] { (ang0, s), (Math.PI / 2 + ang0, s) },
                "LINE" => new[] { (ang0, s) },
                _ => new[] { (Math.PI / 4 + ang0, s) },   // ANSI31 y los demás: rayado a 45°
            };
        }
        /// <summary>Líneas del rayado recortadas por los contornos (par-impar), en coordenadas del mundo.</summary>
        public static List<(double[] a, double[] b)> Rayado(Ent e)
        {
            var segs = new List<(double[], double[])>();
            var lazos = Lazos(e);
            foreach (var (ang, sep) in Familias(e.Get(2), e.Num(41, 1), e.Num(52, 0)))
            {
                double dx = Math.Cos(ang), dy = Math.Sin(ang), nx = -dy, ny = dx;
                double smin = double.MaxValue, smax = double.MinValue;
                foreach (var l in lazos) foreach (var p in l) { double s = p[0] * nx + p[1] * ny; smin = Math.Min(smin, s); smax = Math.Max(smax, s); }
                if (smax <= smin || sep <= 0 || (smax - smin) / sep > 4000) continue;
                for (double s = Math.Ceiling(smin / sep) * sep; s <= smax; s += sep)
                {
                    var ts = new List<double>();
                    foreach (var l in lazos)
                        for (int i = 0; i < l.Count; i++)
                        {
                            var a = l[i]; var b = l[(i + 1) % l.Count];
                            double fa = a[0] * nx + a[1] * ny - s, fb = b[0] * nx + b[1] * ny - s;
                            if ((fa > 0) == (fb > 0)) continue;
                            double t = fa / (fa - fb);
                            double x = a[0] + t * (b[0] - a[0]), y = a[1] + t * (b[1] - a[1]);
                            ts.Add(x * dx + y * dy);
                        }
                    ts.Sort();
                    for (int i = 0; i + 1 < ts.Count; i += 2)
                        segs.Add((new[] { ts[i] * dx + s * nx, ts[i] * dy + s * ny }, new[] { ts[i + 1] * dx + s * nx, ts[i + 1] * dy + s * ny }));
                }
            }
            return segs;
        }

        /// <summary>Texto con los códigos de AutoCAD: %%d °, %%c Ø, %%p ±, %%% %.</summary>
        public static string TextoAcad(string s)
        {
            s = (s ?? "").Replace("%%d", "°").Replace("%%D", "°").Replace("%%c", "Ø").Replace("%%C", "Ø")
                         .Replace("%%p", "±").Replace("%%P", "±").Replace("%%%", "%").Replace("%%u", "").Replace("%%o", "");
            return s;
        }
        static List<string> LineasMtext(string s)
        {
            s = Regex.Replace(s ?? "", @"\\[ACFHQTWfhqtwac][^;\\]*;", "");
            s = s.Replace("{", "").Replace("}", "").Replace("\\~", " ");
            return TextoAcad(s).Split(new[] { "\\P", "\\p" }, StringSplitOptions.None).ToList();
        }
        /// <summary>Caja aproximada del texto en el mundo (x, y abajo-izquierda, ancho, alto) + ancla.</summary>
        static (double x, double y, double w, double h, double ax, double ay) TextoCaja(Ent e)
        {
            double h = e.Num(40, 2.5);
            if (e.Tipo == "MTEXT")
            {
                var ls = LineasMtext(e.Get(1));
                double w = ls.Max(l => l.Length) * 0.6 * h, hh = h * (1 + 1.667 * (ls.Count - 1));
                var p = e.Pt(10) ?? new double[3]; int at = e.Int(71, 1);
                double fx = ((at - 1) % 3) * 0.5, fy = ((at - 1) / 3) * 0.5;   // 0 arriba … 1 abajo
                return (p[0] - fx * w, p[1] - hh + fy * hh, w, hh, p[0], p[1]);
            }
            string s = TextoAcad(e.Get(1));
            double ww = s.Length * 0.6 * h;
            int h72 = e.Int(72, 0), v73 = e.Int(73, 0);
            var q = (h72 != 0 || v73 != 0) ? (e.Pt(11) ?? e.Pt(10)) : e.Pt(10);
            q ??= new double[3];
            double gx = h72 == 1 || h72 == 4 ? 0.5 : h72 == 2 ? 1 : 0;
            double gy = h72 == 4 || v73 == 2 ? 0.5 : v73 == 3 ? 1 : 0;
            return (q[0] - gx * ww, q[1] - gy * h - 0.2 * h, ww, 1.2 * h, q[0], q[1]);
        }

        // ================================ SVG ================================
        static string F(double v) => Math.Round(v, 3).ToString("0.###", Inv);
        static string Enc(string s) => System.Net.WebUtility.HtmlEncode(s ?? "");
        /// <summary>Cadena JSON a mano: en la web (WASM recortado) JsonSerializer no tiene reflexión.</summary>
        static string JsonStr(string s)
        {
            var sb = new StringBuilder("\"");
            foreach (char c in s ?? "")
            {
                switch (c)
                {
                    case '"': sb.Append("\\\""); break;
                    case '\\': sb.Append("\\\\"); break;
                    case '\n': sb.Append("\\n"); break;
                    case '\r': sb.Append("\\r"); break;
                    case '\t': sb.Append("\\t"); break;
                    default: if (c < 32) sb.Append("\\u").Append(((int)c).ToString("x4")); else sb.Append(c); break;
                }
            }
            return sb.Append('"').ToString();
        }

        public sealed class Opc { public double Ancho = 160, Alto = 115; public string Titulo; }

        /// <summary>Formato de la medida de una cota: DIMDEC decimales (punto).</summary>
        static string Medida(Dibujo d, Ent e)
        {
            int dec = (int)d.Var("DIMDEC", 2);
            string val = e.Num(42, 0).ToString("F" + Math.Max(0, Math.Min(8, dec)), Inv);
            string t = e.Get(1);
            if (string.IsNullOrEmpty(t) || t == "<>") return val;
            return TextoAcad(t.Replace("<>", val));
        }

        /// <summary>Geometría de una cota en PAPEL (mm): líneas, flechas y texto (sirve al SVG y al DXF).</summary>
        sealed class CotaGeo
        {
            public List<(double x1, double y1, double x2, double y2)> Lineas = new();
            public List<double[]> Flechas = new();   // triángulos: x1,y1,x2,y2,x3,y3
            public double Tx, Ty, TAng, TAlt; public string Txt;
        }
        static CotaGeo Cota(Dibujo d, Ent e, Vista v)
        {
            var p1 = e.Pt(13); var p2 = e.Pt(14); var p0 = e.Pt(10) ?? p2;
            if (p1 == null || p2 == null) return null;
            double ds = d.Var("DIMSCALE", 0), f = ds > 0 ? ds * v.K : 1;   // DIMSCALE 0 = tamaños de papel
            double txt = d.Var("DIMTXT", 2.5) * f, asz = d.Var("DIMASZ", 2.5) * f, exo = d.Var("DIMEXO", 0.625) * f,
                   exe = d.Var("DIMEXE", 1.25) * f, gap = d.Var("DIMGAP", 0.625) * f;
            double X1 = v.X(p1[0]), Y1 = v.Y(p1[1]), X2 = v.X(p2[0]), Y2 = v.Y(p2[1]), Dx = v.X(p0[0]), Dy = v.Y(p0[1]);
            double ux, uy;
            if ((e.Int(70, 0) & 7) == 1) { ux = X2 - X1; uy = Y2 - Y1; }
            else { double a = e.Num(50, 0); ux = Math.Cos(a); uy = -Math.Sin(a) * v.Kv; }
            double L = Math.Sqrt(ux * ux + uy * uy); if (L < 1e-12) { ux = 1; uy = 0; } else { ux /= L; uy /= L; }
            double t1 = (X1 - Dx) * ux + (Y1 - Dy) * uy, t2 = (X2 - Dx) * ux + (Y2 - Dy) * uy;
            double Q1x = Dx + ux * t1, Q1y = Dy + uy * t1, Q2x = Dx + ux * t2, Q2y = Dy + uy * t2;
            var g = new CotaGeo();
            void Ext(double px, double py, double qx, double qy)
            {
                double ex = qx - px, ey = qy - py, el = Math.Sqrt(ex * ex + ey * ey);
                if (el < exo + 1e-6) return;
                ex /= el; ey /= el;
                g.Lineas.Add((px + ex * exo, py + ey * exo, qx + ex * exe, qy + ey * exe));
            }
            Ext(X1, Y1, Q1x, Q1y); Ext(X2, Y2, Q2x, Q2y);
            g.Lineas.Add((Q1x, Q1y, Q2x, Q2y));
            double dl = Math.Sqrt((Q2x - Q1x) * (Q2x - Q1x) + (Q2y - Q1y) * (Q2y - Q1y));
            double sx = dl > 1e-9 ? (Q2x - Q1x) / dl : ux, sy = dl > 1e-9 ? (Q2y - Q1y) / dl : uy;
            bool fuera = dl < 2.6 * asz;
            void Flecha(double tx, double ty, double dirx, double diry)   // punta en (tx,ty), cuerpo hacia dir
            {
                double bx = tx + dirx * asz, by = ty + diry * asz, w = asz / 6;
                g.Flechas.Add(new[] { tx, ty, bx - diry * w, by + dirx * w, bx + diry * w, by - dirx * w });
            }
            if (!fuera) { Flecha(Q1x, Q1y, sx, sy); Flecha(Q2x, Q2y, -sx, -sy); }
            else
            {
                Flecha(Q1x, Q1y, -sx, -sy); Flecha(Q2x, Q2y, sx, sy);
                g.Lineas.Add((Q1x - sx * 2 * asz, Q1y - sy * 2 * asz, Q1x, Q1y));
                g.Lineas.Add((Q2x, Q2y, Q2x + sx * 2 * asz, Q2y + sy * 2 * asz));
            }
            double ang = Math.Atan2(sy, sx) * 180 / Math.PI;           // en papel (y hacia abajo)
            if (ang > 90.001) ang -= 180; else if (ang <= -90.001) ang += 180;
            double ar = ang * Math.PI / 180, nxp = Math.Sin(ar), nyp = -Math.Cos(ar);   // normal "arriba" del texto
            double mx = (Q1x + Q2x) / 2, my = (Q1y + Q2y) / 2;
            var t11 = e.Pt(11);
            if ((e.Int(70, 0) & 128) != 0 && t11 != null) { mx = v.X(t11[0]); my = v.Y(t11[1]); g.Tx = mx; g.Ty = my + txt * 0.35; }
            else { g.Tx = mx + nxp * gap; g.Ty = my + nyp * gap; }
            g.TAng = ang; g.TAlt = txt; g.Txt = Medida(d, e);
            return g;
        }

        // ---------- primitivas de PAPEL (mm): de aquí salen el SVG, el PDF y el PNG ----------
        public sealed class Run { public string T; public bool It; public int Sh; }   // Sh: 1 superíndice, -1 subíndice
        sealed class Prim
        {
            public string K;                                   // "path" | "ell" | "text"
            public List<List<double[]>> Sub = new List<List<double[]>>();   // subtrazos (x,y papel)
            public bool Cerrado, ParImpar;
            public string Stroke, Fill, Dash; public double W = 0.25, FillOp = 1, StrokeOp = 1;
            public double Cx, Cy, Rx, Ry;
            public List<Run> Runs; public double X, Y, Size, Rot; public string Anchor = "start"; public bool Serif;
        }

        static readonly Dictionary<string, string> Griegas = new Dictionary<string, string>
        {
            ["alpha"] = "α", ["beta"] = "β", ["gamma"] = "γ", ["delta"] = "δ", ["epsilon"] = "ε", ["theta"] = "θ",
            ["lambda"] = "λ", ["mu"] = "μ", ["nu"] = "ν", ["xi"] = "ξ", ["pi"] = "π", ["rho"] = "ρ", ["sigma"] = "σ",
            ["tau"] = "τ", ["phi"] = "φ", ["psi"] = "ψ", ["omega"] = "ω", ["kappa"] = "κ", ["eta"] = "η", ["zeta"] = "ζ",
            ["Delta"] = "Δ", ["Sigma"] = "Σ", ["Omega"] = "Ω", ["Phi"] = "Φ",
        };
        static readonly HashSet<string> Funciones = new HashSet<string> { "sin", "cos", "tan", "ln", "log", "exp", "sqrt", "abs", "max", "min", "atan", "asin", "acos", "sinh", "cosh", "tanh" };

        /// <summary>Matemática de una línea («f'(x) = 3*x^2 − 12*x + 9») → tramos con cursiva/exponente,
        /// como la hoja: variables en cursiva, números rectos, 3*x → 3x, x^2 → x², a*b → a·b, - → −.</summary>
        public static List<Run> MathRuns(string s)
        {
            var runs = new List<Run>();
            s = (s ?? "").Replace("′", "'");
            int i = 0, n = s.Length;
            void Add(string t, bool it = false, int sh = 0)
            {
                if (t.Length == 0) return;
                if (runs.Count > 0 && runs[^1].It == it && runs[^1].Sh == sh) runs[^1].T += t; else runs.Add(new Run { T = t, It = it, Sh = sh });
            }
            char Prev() { for (int k = runs.Count - 1; k >= 0; k--) if (runs[k].T.Length > 0) return runs[k].T[^1]; return ' '; }
            // lee un grupo tras ^ o _: (…) balanceado, o un token
            string Grupo()
            {
                if (i < n && s[i] == '(')
                {
                    int dep = 0, st = i;
                    for (; i < n; i++) { if (s[i] == '(') dep++; else if (s[i] == ')' && --dep == 0) { i++; break; } }
                    return s.Substring(st + 1, Math.Max(0, i - st - 2));
                }
                int a = i;
                if (i < n && (s[i] == '-' || s[i] == '+')) i++;
                while (i < n && (char.IsLetterOrDigit(s[i]) || s[i] == '.')) i++;
                return s.Substring(a, i - a);
            }
            void Sub(string g, int sh)
            {
                foreach (var r in MathRuns(g)) Add(r.T, r.It, sh);
            }
            while (i < n)
            {
                char c = s[i];
                if (char.IsWhiteSpace(c)) { Add(" "); i++; continue; }
                if (char.IsDigit(c) || (c == '.' && i + 1 < n && char.IsDigit(s[i + 1])))
                {
                    int a = i; while (i < n && (char.IsDigit(s[i]) || s[i] == '.')) i++;
                    Add(s.Substring(a, i - a)); continue;
                }
                if (char.IsLetter(c))
                {
                    int a = i; while (i < n && (char.IsLetterOrDigit(s[i]) && s[i] != '_')) i++;
                    string w = s.Substring(a, i - a);
                    if (Griegas.TryGetValue(w, out var g)) Add(g, true);
                    else if (Funciones.Contains(w) && i < n && s[i] == '(') Add(w == "sqrt" ? "√" : w);
                    else Add(w, true);
                    continue;
                }
                switch (c)
                {
                    case '^': i++; Sub(Grupo(), 1); continue;
                    case '_': i++; Sub(Grupo(), -1); continue;
                    case '\'': Add("′"); i++; continue;
                    case '*':
                    {
                        i++;
                        while (i < n && s[i] == ' ') i++;
                        char nx = i < n ? s[i] : ' ';
                        bool implicito = char.IsDigit(Prev()) && (char.IsLetter(nx) || nx == '(');
                        if (!implicito) Add("·");
                        continue;
                    }
                    case '-': Add("−"); i++; continue;
                    default: Add(c.ToString()); i++; continue;
                }
            }
            return runs;
        }
        /// <summary>Tramos → texto plano Unicode (DXF): exponentes con ² ³ … cuando se puede.</summary>
        static string RunsPlano(List<Run> runs)
        {
            const string SUP = "⁰¹²³⁴⁵⁶⁷⁸⁹", SUB = "₀₁₂₃₄₅₆₇₈₉";
            var sb = new StringBuilder();
            foreach (var r in runs)
            {
                if (r.Sh == 0) { sb.Append(r.T); continue; }
                string tabla = r.Sh > 0 ? SUP : SUB;
                if (r.T.All(char.IsDigit)) foreach (var ch in r.T) sb.Append(tabla[ch - '0']);
                else sb.Append(r.Sh > 0 ? "^" : "_").Append(r.T.Length > 1 ? "(" + r.T + ")" : r.T);
            }
            return sb.ToString();
        }
        static bool EsMat(Ent e) => string.Equals(e.Get(7), "HKMATH", StringComparison.OrdinalIgnoreCase);

        static List<Prim> Primitivas(Dibujo d, Vista v, bool oscuro)
        {
            var L = new List<Prim>();
            var orden = d.Ents.Where(e => e.Tipo is "HATCH" or "SOLID").Concat(d.Ents.Where(e => !(e.Tipo is "HATCH" or "SOLID")));
            List<double[]> Pap(IEnumerable<double[]> pts) => pts.Select(p => new[] { v.X(p[0]), v.Y(p[1]) }).ToList();
            foreach (var e in orden)
            {
                var (col, tipo, w, off) = Estilo(d, e);
                if (off) continue;
                string css = AciCss(col, oscuro);
                string da = Dash(tipo);
                Prim Trazo(List<double[]> pts, bool cerr) { var p = new Prim { K = "path", Stroke = css, W = w, Dash = da, Cerrado = cerr }; p.Sub.Add(pts); return p; }
                switch (e.Tipo)
                {
                    case "POINT":
                    {
                        var p = e.Pt(10); if (p == null) break;
                        L.Add(new Prim { K = "ell", Cx = v.X(p[0]), Cy = v.Y(p[1]), Rx = 0.65, Ry = 0.65, Fill = css });
                        break;
                    }
                    case "LINE":
                    {
                        var a = e.Pt(10); var b = e.Pt(11); if (a == null || b == null) break;
                        L.Add(Trazo(Pap(new[] { a, b }), false));
                        break;
                    }
                    case "CIRCLE":
                    {
                        var c = e.Pt(10); double r = e.Num(40, 0); if (c == null) break;
                        L.Add(new Prim { K = "ell", Cx = v.X(c[0]), Cy = v.Y(c[1]), Rx = r * v.K, Ry = r * v.K * v.Kv, Stroke = css, W = w, Dash = da });
                        break;
                    }
                    case "ARC": L.Add(Trazo(Pap(ArcoPuntos(e, 24)), false)); break;
                    case "POLYLINE": { var pts = e.Pts(1011); if (pts.Count > 1) L.Add(Trazo(Pap(pts), (e.Int(70, 0) & 1) == 1)); break; }
                    case "3DFACE":
                    {
                        var pr = new Prim { K = "path", Fill = css, FillOp = 0.25, Stroke = css, W = 0.18, Cerrado = true };
                        pr.Sub.Add(Pap(new[] { e.Pt(10), e.Pt(11), e.Pt(12), e.Pt(13) ?? e.Pt(12) })); L.Add(pr);
                        break;
                    }
                    case "LWPOLYLINE":
                    {
                        var pts = PoliPuntos(e, out bool cer);
                        var pr = Trazo(Pap(pts), cer);
                        double cw = e.Num(43, 0); if (cw > 0) pr.W = Math.Max(w, cw * v.K);
                        L.Add(pr);
                        break;
                    }
                    case "SOLID":
                    {
                        var a = e.Pt(10); var b = e.Pt(11); var c = e.Pt(12); var dd = e.Pt(13) ?? c;
                        if (a == null || b == null || c == null) break;
                        var pr = new Prim { K = "path", Fill = css, Cerrado = true };   // orden 10, 11, 13, 12
                        pr.Sub.Add(Pap(new[] { a, b, dd, c })); L.Add(pr);
                        break;
                    }
                    case "HATCH":
                    {
                        bool solido = string.Equals(e.Get(2), "SOLID", StringComparison.OrdinalIgnoreCase);
                        double alfa = 1; int t440 = e.Int(440, -1);
                        if (t440 >= 0 && (t440 >> 24) == 2) alfa = (t440 & 0xFF) / 255.0;
                        if (solido)
                        {
                            var pr = new Prim { K = "path", Fill = css, FillOp = alfa, Cerrado = true, ParImpar = true };
                            foreach (var l in Lazos(e)) pr.Sub.Add(Pap(l));
                            L.Add(pr);
                        }
                        else
                        {
                            var pr = new Prim { K = "path", Stroke = css, W = 0.16, StrokeOp = Math.Max(alfa, 0.4) };
                            foreach (var (a, b) in Rayado(e)) pr.Sub.Add(Pap(new[] { a, b }));
                            if (pr.Sub.Count > 0) L.Add(pr);
                        }
                        break;
                    }
                    case "TEXT":
                    {
                        int h72 = e.Int(72, 0), v73 = e.Int(73, 0);
                        var q = (h72 != 0 || v73 != 0) ? (e.Pt(11) ?? e.Pt(10)) : e.Pt(10);
                        if (q == null) break;
                        double h = e.Num(40, 2.5) * v.K;
                        double dy = h72 == 4 || v73 == 2 ? 0.35 * h : v73 == 3 ? 0.75 * h : v73 == 1 ? -0.2 * h : 0;
                        bool mat = EsMat(e);
                        L.Add(new Prim
                        {
                            K = "text", X = v.X(q[0]), Y = v.Y(q[1]) + dy, Size = h * (mat ? 1.08 : 1), Rot = -e.Num(50, 0) * 180 / Math.PI,
                            Anchor = h72 == 1 || h72 == 4 ? "middle" : h72 == 2 ? "end" : "start", Fill = css, Serif = mat,
                            Runs = mat ? MathRuns(e.Get(1)) : new List<Run> { new Run { T = TextoAcad(e.Get(1)) } },
                        });
                        break;
                    }
                    case "MTEXT":
                    {
                        var p = e.Pt(10); if (p == null) break;
                        double h = e.Num(40, 2.5) * v.K;
                        var ls = LineasMtext(e.Get(1)); int at = e.Int(71, 1);
                        string anc = ((at - 1) % 3) switch { 1 => "middle", 2 => "end", _ => "start" };
                        double total = h * 1.667 * (ls.Count - 1);
                        double y0 = ((at - 1) / 3) switch { 0 => 0.8 * h, 1 => 0.35 * h - total / 2, _ => -total - 0.1 * h };
                        double rot = -e.Num(50, 0) * 180 / Math.PI, X = v.X(p[0]), Y = v.Y(p[1]);
                        for (int i = 0; i < ls.Count; i++)
                        {
                            // girar cada línea alrededor del punto de inserción
                            double dyl = y0 + i * 1.667 * h, ar = rot * Math.PI / 180;
                            L.Add(new Prim { K = "text", X = X - Math.Sin(ar) * dyl, Y = Y + Math.Cos(ar) * dyl, Size = h, Rot = rot, Anchor = anc, Fill = css,
                                             Runs = new List<Run> { new Run { T = ls[i] } } });
                        }
                        break;
                    }
                    case "DIMENSION":
                    {
                        var g = Cota(d, e, v); if (g == null) break;
                        foreach (var (x1, y1, x2, y2) in g.Lineas)
                        { var pr = new Prim { K = "path", Stroke = css, W = 0.18 }; pr.Sub.Add(new List<double[]> { new[] { x1, y1 }, new[] { x2, y2 } }); L.Add(pr); }
                        foreach (var t in g.Flechas)
                        { var pr = new Prim { K = "path", Fill = css, Cerrado = true }; pr.Sub.Add(new List<double[]> { new[] { t[0], t[1] }, new[] { t[2], t[3] }, new[] { t[4], t[5] } }); L.Add(pr); }
                        L.Add(new Prim { K = "text", X = g.Tx, Y = g.Ty, Size = g.TAlt, Rot = g.TAng, Anchor = "middle", Fill = css, Runs = new List<Run> { new Run { T = g.Txt } } });
                        break;
                    }
                }
            }
            return L;
        }

        // ---------- SVG ----------
        const string FuenteSans = "'Segoe UI','Open Sans',system-ui,sans-serif";
        const string FuenteSerif = "Georgia,'Times New Roman',Times,serif";
        static string SvgDe(List<Prim> L)
        {
            var sb = new StringBuilder();
            foreach (var p in L)
            {
                switch (p.K)
                {
                    case "path":
                    {
                        var dsb = new StringBuilder();
                        foreach (var sp in p.Sub)
                        {
                            for (int i = 0; i < sp.Count; i++) dsb.Append(i == 0 ? 'M' : 'L').Append(F(sp[i][0])).Append(' ').Append(F(sp[i][1]));
                            if (p.Cerrado) dsb.Append('Z');
                        }
                        sb.Append("<path d=\"").Append(dsb).Append("\" style=\"");
                        if (p.Fill != null) sb.Append("fill:").Append(p.Fill).Append(p.FillOp < 1 ? ";fill-opacity:" + F(p.FillOp) : "").Append(p.ParImpar ? ";fill-rule:evenodd" : "");
                        else sb.Append("fill:none");
                        if (p.Stroke != null)
                            sb.Append(";stroke:").Append(p.Stroke).Append(";stroke-width:").Append(F(p.W)).Append(p.StrokeOp < 1 ? ";stroke-opacity:" + F(p.StrokeOp) : "")
                              .Append(p.Dash != null ? ";stroke-dasharray:" + p.Dash : "").Append(";stroke-linecap:round;stroke-linejoin:round");
                        else sb.Append(";stroke:none");
                        sb.Append("\"/>");
                        break;
                    }
                    case "ell":
                        sb.Append("<ellipse cx=\"").Append(F(p.Cx)).Append("\" cy=\"").Append(F(p.Cy)).Append("\" rx=\"").Append(F(p.Rx)).Append("\" ry=\"").Append(F(p.Ry))
                          .Append("\" style=\"fill:").Append(p.Fill ?? "none");
                        if (p.Stroke != null) sb.Append(";stroke:").Append(p.Stroke).Append(";stroke-width:").Append(F(p.W)).Append(p.Dash != null ? ";stroke-dasharray:" + p.Dash : "");
                        sb.Append("\"/>");
                        break;
                    case "text":
                    {
                        sb.Append("<text x=\"").Append(F(p.X)).Append("\" y=\"").Append(F(p.Y)).Append("\" text-anchor=\"").Append(p.Anchor).Append('"')
                          .Append(Math.Abs(p.Rot) > 1e-9 ? " transform=\"rotate(" + F(p.Rot) + " " + F(p.X) + " " + F(p.Y) + ")\"" : "")
                          .Append(" style=\"font-family:").Append(p.Serif ? FuenteSerif : FuenteSans).Append(";font-size:").Append(F(p.Size)).Append("px;fill:").Append(p.Fill).Append("\">");
                        int sh = 0;
                        foreach (var r in p.Runs)
                        {
                            double dy = (r.Sh - sh) switch { 0 => 0, _ => 0 };
                            // desplazamiento vertical en unidades absolutas (papel): sube 0.38·h y vuelve
                            double hacia = (r.Sh > 0 ? -0.38 : r.Sh < 0 ? 0.22 : 0) * p.Size, desde = (sh > 0 ? -0.38 : sh < 0 ? 0.22 : 0) * p.Size;
                            dy = hacia - desde;
                            sb.Append("<tspan").Append(Math.Abs(dy) > 1e-9 ? " dy=\"" + F(dy) + "\"" : "")
                              .Append(r.Sh != 0 ? " style=\"font-size:" + F(p.Size * 0.72) + "px" + (r.It ? ";font-style:italic" : "") + "\"" : r.It ? " style=\"font-style:italic\"" : "")
                              .Append('>').Append(Enc(r.T)).Append("</tspan>");
                            sh = r.Sh;
                        }
                        sb.Append("</text>");
                        break;
                    }
                }
            }
            return sb.ToString();
        }

        [ThreadStatic] static bool? _oscuroFijo;
        /// <summary>Colores del tema para los ARCHIVOS (sin las variables CSS de la página).</summary>
        static readonly Dictionary<string, (string claro, string oscuro)> VarsTema = new Dictionary<string, (string, string)>
        {
            ["var(--fg)"] = ("#171310", "#f0efec"), ["var(--mut)"] = ("#544d3a", "#9aa0a6"),
            ["var(--dib-rojo)"] = ("#c62828", "#ff6b5e"), ["var(--dib-azul)"] = ("#1c5fbf", "#6fa8ff"),
            ["var(--dib-verde)"] = ("#2b8a3e", "#4cc38a"), ["var(--dib-nar)"] = ("#d9480f", "#ffa94d"),
        };
        static string ColorReal(string css, bool oscuro) => css != null && VarsTema.TryGetValue(css, out var t) ? (oscuro ? t.oscuro : t.claro) : css;

        // ================================ 3D ================================
        /// <summary>¿Se dibuja en 3D? HKVISTA = 1 (vista "3d"), o automático (-1) si hay z ≠ 0,
        /// 3DFACE o POLYLINE 3D (70 bit 8).</summary>
        public static bool Es3D(Dibujo d)
        {
            int m = (int)d.Var("HKVISTA", -1);
            if (m == 0) return false;
            if (m == 1) return true;
            foreach (var e in d.Ents)
            {
                if (e.Tipo == "3DFACE") return true;
                if (e.Tipo == "POLYLINE" && (e.Int(70, 0) & 8) != 0) return true;
                foreach (var p in e.D)
                    if (p.Key >= 10 && p.Key <= 18 || p.Key == 1011)
                    { var q = Ent.ParsePt(p.Value); if (q != null && Math.Abs(q[2]) > 1e-12) return true; }
            }
            return false;
        }
        sealed class P3
        {
            public string K;                  // "s" trazo · "f" cara · "p" punto · "t" texto
            public List<double[]> P = new List<double[]>();
            public string St, Fi, Da; public double W = 0.25, Fo = 1, Dy, H; public bool C, Serif; public string A = "start"; public List<Run> Runs;
        }
        static double[] Proy(double[] p, double az, double el)
        {
            double a = az * Math.PI / 180, e = el * Math.PI / 180, ca = Math.Cos(a), sa = Math.Sin(a), ce = Math.Cos(e), se = Math.Sin(e);
            double x = p[0], y = p[1], z = p.Length > 2 ? p[2] : 0;
            return new[] { -x * sa + y * ca, -x * se * ca - y * se * sa + z * ce, x * ce * ca + y * ce * sa + z * se };
        }
        static double[] Normal(List<double[]> p)
        {
            double[] a = p[0], b = p[1], c = p[2];
            double ux = b[0] - a[0], uy = b[1] - a[1], uz = b[2] - a[2], vx = c[0] - a[0], vy = c[1] - a[1], vz = c[2] - a[2];
            double nx = uy * vz - uz * vy, ny = uz * vx - ux * vz, nz = ux * vy - uy * vx, n = Math.Sqrt(nx * nx + ny * ny + nz * nz);
            return n < 1e-300 ? new double[] { 0, 0, 1 } : new[] { nx / n, ny / n, nz / n };
        }
        static List<P3> Prims3D(Dibujo d, bool oscuro)
        {
            var L = new List<P3>();
            double Z(double[] p) => p != null && p.Length > 2 ? p[2] : 0;
            List<double[]> ConZ(IEnumerable<double[]> pts, double z) => pts.Select(p => new[] { p[0], p[1], z }).ToList();
            foreach (var e in d.Ents)
            {
                var (col, tipo, w, off) = Estilo(d, e);
                if (off) continue;
                string css = AciCss(col, oscuro), da = Dash(tipo);
                P3 S(List<double[]> pts, bool c = false) => new P3 { K = "s", P = pts, St = css, W = w, Da = da, C = c };
                double alfa = 1; int t440 = e.Int(440, -1); if (t440 >= 0 && (t440 >> 24) == 2) alfa = (t440 & 0xFF) / 255.0;
                switch (e.Tipo)
                {
                    case "POINT": { var p = e.Pt(10); if (p != null) L.Add(new P3 { K = "p", P = { p }, Fi = css }); break; }
                    case "LINE": { var a = e.Pt(10); var b = e.Pt(11); if (a != null && b != null) L.Add(S(new List<double[]> { a, b })); break; }
                    case "CIRCLE":
                    {
                        var c = e.Pt(10); double r = e.Num(40, 0); if (c == null) break;
                        var pts = new List<double[]>(); for (int i = 0; i < 72; i++) { double t = 2 * Math.PI * i / 72; pts.Add(new[] { c[0] + r * Math.Cos(t), c[1] + r * Math.Sin(t), c[2] }); }
                        L.Add(S(pts, true)); break;
                    }
                    case "ARC": L.Add(S(ConZ(ArcoPuntos(e, 24), Z(e.Pt(10))))); break;
                    case "LWPOLYLINE": { var pts = PoliPuntos(e, out bool cer); L.Add(S(ConZ(pts, e.Num(38, 0)), cer)); break; }
                    case "POLYLINE": { var pts = e.Pts(1011); if (pts.Count > 1) L.Add(S(pts, (e.Int(70, 0) & 1) == 1)); break; }
                    case "3DFACE":
                    {
                        var pts = new List<double[]> { e.Pt(10), e.Pt(11), e.Pt(12) }; var p4 = e.Pt(13);
                        if (p4 != null && (Math.Abs(p4[0] - pts[2][0]) + Math.Abs(p4[1] - pts[2][1]) + Math.Abs(p4[2] - pts[2][2])) > 1e-12) pts.Add(p4);
                        L.Add(new P3 { K = "f", P = pts, Fi = css, St = css, Fo = t440 >= 0 ? alfa : 0.3, C = true });
                        break;
                    }
                    case "SOLID":
                    {
                        var a = e.Pt(10); var b = e.Pt(11); var c = e.Pt(12); var dd = e.Pt(13) ?? c;
                        if (a != null && b != null && c != null) L.Add(new P3 { K = "f", P = { a, b, dd, c }, Fi = css, Fo = alfa, C = true });
                        break;
                    }
                    case "HATCH":
                        if (string.Equals(e.Get(2), "SOLID", StringComparison.OrdinalIgnoreCase))
                            foreach (var l in Lazos(e)) L.Add(new P3 { K = "f", P = l, Fi = css, Fo = alfa, C = true });
                        else foreach (var (a, b) in Rayado(e)) L.Add(new P3 { K = "s", P = { new[] { a[0], a[1], 0.0 }, new[] { b[0], b[1], 0.0 } }, St = css, W = 0.16 });
                        break;
                    case "TEXT": case "MTEXT":
                    {
                        int h72 = e.Int(72, 0), v73 = e.Int(73, 0);
                        var q = e.Tipo == "TEXT" && (h72 != 0 || v73 != 0) ? (e.Pt(11) ?? e.Pt(10)) : e.Pt(10);
                        if (q == null) break;
                        double h = e.Num(40, 2.5);
                        bool mat = EsMat(e);
                        string txt = e.Tipo == "MTEXT" ? string.Join(" ", LineasMtext(e.Get(1))) : e.Get(1);
                        L.Add(new P3
                        {
                            K = "t", P = { q }, Fi = css, H = h * (mat ? 1.08 : 1), Serif = mat,
                            A = h72 == 1 || h72 == 4 ? "middle" : h72 == 2 ? "end" : "start",
                            Dy = h72 == 4 || v73 == 2 ? 0.35 : v73 == 3 ? 0.75 : v73 == 1 ? -0.2 : 0,
                            Runs = mat ? MathRuns(txt) : new List<Run> { new Run { T = TextoAcad(txt) } },
                        });
                        break;
                    }
                    case "DIMENSION":
                    {
                        // cota ALINEADA en el espacio: la línea pasa por 10, paralela a 13→14
                        var p1 = e.Pt(13); var p2 = e.Pt(14); var p0 = e.Pt(10) ?? p2; if (p1 == null || p2 == null) break;
                        var dv = new[] { p0[0] - p2[0], p0[1] - p2[1], p0[2] - p2[2] };
                        var q1 = new[] { p1[0] + dv[0], p1[1] + dv[1], p1[2] + dv[2] }; var q2 = p0;
                        string fino = css;
                        L.Add(new P3 { K = "s", P = { p1, q1 }, St = fino, W = 0.18 });
                        L.Add(new P3 { K = "s", P = { p2, q2 }, St = fino, W = 0.18 });
                        L.Add(new P3 { K = "s", P = { q1, q2 }, St = fino, W = 0.18 });
                        L.Add(new P3 { K = "p", P = { q1 }, Fi = css }); L.Add(new P3 { K = "p", P = { q2 }, Fi = css });
                        L.Add(new P3 { K = "t", P = { new[] { (q1[0] + q2[0]) / 2, (q1[1] + q2[1]) / 2, (q1[2] + q2[2]) / 2 } }, Fi = css, H = -d.Var("DIMTXT", 2.5), A = "middle", Dy = -0.3,
                                       Runs = new List<Run> { new Run { T = Medida(d, e) } } });
                        break;
                    }
                }
            }
            return L;
        }
        /// <summary>La escena 3D proyectada (az, el) y encajada en W×H mm, ordenada de atrás hacia delante.
        /// Es el MISMO algoritmo que hace la página al girar (JsVista3D): la primera imagen coincide.</summary>
        static List<Prim> Proyectar(List<P3> L3, double az, double el, double W, double H, double pad, ref double k0)
        {
            var q = L3.Select(it => it.P.Select(p => Proy(p, az, el)).ToList()).ToList();
            double xm = double.MaxValue, xM = double.MinValue, ym = double.MaxValue, yM = double.MinValue;
            foreach (var l in q) foreach (var v in l) { xm = Math.Min(xm, v[0]); xM = Math.Max(xM, v[0]); ym = Math.Min(ym, v[1]); yM = Math.Max(yM, v[1]); }
            if (xm > xM) { xm = ym = 0; xM = yM = 1; }
            double wx = Math.Max(xM - xm, 1e-9), wy = Math.Max(yM - ym, 1e-9);
            double K = Math.Min((W - 2 * pad) / wx, (H - 2 * pad) / wy), ox = (W - wx * K) / 2, oy = (H - wy * K) / 2;
            if (k0 <= 0) k0 = K;
            double kk = k0;
            double X(double[] v) => ox + (v[0] - xm) * K; double Y(double[] v) => oy + (yM - v[1]) * K;
            double a = az * Math.PI / 180, e = el * Math.PI / 180;
            var cv = new[] { Math.Cos(e) * Math.Cos(a), Math.Cos(e) * Math.Sin(a), Math.Sin(e) };
            var orden = Enumerable.Range(0, L3.Count).OrderBy(i => q[i].Average(v => v[2])).ToList();
            var res = new List<Prim>();
            foreach (var i in orden)
            {
                var it = L3[i]; var pts = q[i].Select(v => new[] { X(v), Y(v) }).ToList();
                switch (it.K)
                {
                    case "p": res.Add(new Prim { K = "ell", Cx = pts[0][0], Cy = pts[0][1], Rx = 0.65, Ry = 0.65, Fill = it.Fi }); break;
                    case "t":
                    {
                        double h = it.H < 0 ? -it.H : it.H * kk;   // H < 0: tamaño de papel (cotas)
                        res.Add(new Prim { K = "text", X = pts[0][0], Y = pts[0][1] + it.Dy * h, Size = h, Anchor = it.A, Fill = it.Fi, Serif = it.Serif, Runs = it.Runs });
                        break;
                    }
                    case "f":
                    {
                        var n = Normal(it.P); double lum = Math.Abs(n[0] * cv[0] + n[1] * cv[1] + n[2] * cv[2]);
                        var f1 = new Prim { K = "path", Fill = it.Fi, FillOp = it.Fo, Cerrado = true }; f1.Sub.Add(pts); res.Add(f1);
                        var f2 = new Prim { K = "path", Fill = "#000000", FillOp = Math.Round((1 - lum) * 0.35 * it.Fo, 3), Cerrado = true, Stroke = it.St, W = 0.18 }; f2.Sub.Add(pts); res.Add(f2);
                        break;
                    }
                    default:
                    { var s = new Prim { K = "path", Stroke = it.St, W = it.W, Dash = it.Da, Cerrado = it.C }; s.Sub.Add(pts); res.Add(s); break; }
                }
            }
            return res;
        }
        static string TspansDe(List<Run> runs, double size)
        {
            var sb = new StringBuilder(); int sh = 0;
            foreach (var r in runs)
            {
                double hacia = (r.Sh > 0 ? -0.38 : r.Sh < 0 ? 0.22 : 0) * size, desde = (sh > 0 ? -0.38 : sh < 0 ? 0.22 : 0) * size, dy = hacia - desde;
                sb.Append("<tspan").Append(Math.Abs(dy) > 1e-9 ? " dy=\"" + F(dy) + "\"" : "")
                  .Append(r.Sh != 0 ? " style=\"font-size:" + F(size * 0.72) + "px" + (r.It ? ";font-style:italic" : "") + "\"" : r.It ? " style=\"font-style:italic\"" : "")
                  .Append('>').Append(Enc(r.T)).Append("</tspan>");
                sh = r.Sh;
            }
            return sb.ToString();
        }
        /// <summary>Datos de la escena 3D para la página (JSON): la página la vuelve a proyectar al girar.</summary>
        static string Json3D(List<P3> L3, double az, double el, double W, double H, double pad, double k0)
        {
            string J(string s) => JsonStr(s);
            var sb = new StringBuilder();
            sb.Append("{\"az\":").Append(F(az)).Append(",\"el\":").Append(F(el)).Append(",\"W\":").Append(F(W)).Append(",\"H\":").Append(F(H))
              .Append(",\"pad\":").Append(F(pad)).Append(",\"k0\":").Append(k0.ToString("R", Inv)).Append(",\"it\":[");
            for (int i = 0; i < L3.Count; i++)
            {
                var it = L3[i]; if (i > 0) sb.Append(',');
                sb.Append("{\"k\":\"").Append(it.K).Append("\",\"p\":[").Append(string.Join(",", it.P.Select(p => "[" + p[0].ToString("R", Inv) + "," + p[1].ToString("R", Inv) + "," + (p.Length > 2 ? p[2] : 0).ToString("R", Inv) + "]"))).Append(']');
                if (it.St != null) sb.Append(",\"st\":").Append(J(it.St));
                if (it.Fi != null) sb.Append(",\"fi\":").Append(J(it.Fi));
                if (it.Da != null) sb.Append(",\"da\":").Append(J(it.Da));
                sb.Append(",\"w\":").Append(F(it.W)).Append(",\"fo\":").Append(F(it.Fo)).Append(",\"c\":").Append(it.C ? "1" : "0");
                if (it.K == "t")
                {
                    double size = it.H < 0 ? -it.H : it.H * k0;
                    sb.Append(",\"h\":").Append(F(it.H)).Append(",\"dy\":").Append(F(it.Dy)).Append(",\"a\":\"").Append(it.A).Append("\",\"sf\":").Append(it.Serif ? "1" : "0")
                      .Append(",\"html\":").Append(J(TspansDe(it.Runs, size)));
                }
                sb.Append('}');
            }
            return sb.Append("]}").ToString();
        }
        // la página: proyecta, ordena (pintor) y dibuja; arrastrar = girar; botones de vista
        const string JsVista3D = "<script>if(!window.hkAl3d){window.hkAl3d=function(id,az,el){var box=document.getElementById(id);var D=box.__d||(box.__d=JSON.parse(box.querySelector('script.hk3d').textContent));" +
            "if(az!==undefined){D.az=az;D.el=el}var svg=box.querySelector('svg.hk-dib-svg');var A=D.az*Math.PI/180,E=D.el*Math.PI/180,ca=Math.cos(A),sa=Math.sin(A),ce=Math.cos(E),se=Math.sin(E);" +
            "function pr(p){var x=p[0],y=p[1],z=p[2]||0;return[-x*sa+y*ca,-x*se*ca-y*se*sa+z*ce,x*ce*ca+y*ce*sa+z*se]}" +
            "var xm=1e300,xM=-1e300,ym=1e300,yM=-1e300,L=D.it.map(function(it){var q=it.p.map(pr),s=0;q.forEach(function(v){xm=Math.min(xm,v[0]);xM=Math.max(xM,v[0]);ym=Math.min(ym,v[1]);yM=Math.max(yM,v[1]);s+=v[2]});return{it:it,q:q,d:s/q.length}});" +
            "var wx=Math.max(xM-xm,1e-9),wy=Math.max(yM-ym,1e-9),P=D.pad,K=Math.min((D.W-2*P)/wx,(D.H-2*P)/wy),ox=(D.W-wx*K)/2,oy=(D.H-wy*K)/2;function X(v){return(ox+(v[0]-xm)*K).toFixed(3)}function Y(v){return(oy+(yM-v[1])*K).toFixed(3)}" +
            "L.sort(function(a,b){return a.d-b.d});var cv=[ce*ca,ce*sa,se],s='';" +
            "L.forEach(function(o){var it=o.it,q=o.q;if(it.k==='t'){var h=it.h<0?-it.h:it.h*D.k0;s+='<text x=\"'+X(q[0])+'\" y=\"'+(parseFloat(Y(q[0]))+it.dy*h).toFixed(3)+'\" text-anchor=\"'+it.a+'\" style=\"font-family:'+(it.sf?\"Georgia,'Times New Roman',Times,serif\":\"'Segoe UI','Open Sans',system-ui,sans-serif\")+';font-size:'+(+h.toFixed(3))+'px;fill:'+it.fi+'\">'+it.html+'</text>';return}" +
            "if(it.k==='p'){s+='<ellipse cx=\"'+X(q[0])+'\" cy=\"'+Y(q[0])+'\" rx=\"0.65\" ry=\"0.65\" style=\"fill:'+it.fi+'\"/>';return}" +
            "var d='';q.forEach(function(v,i){d+=(i?'L':'M')+X(v)+' '+Y(v)});if(it.c)d+='Z';" +
            "if(it.k==='f'){var p=it.p,u=[p[1][0]-p[0][0],p[1][1]-p[0][1],p[1][2]-p[0][2]],w=[p[2][0]-p[0][0],p[2][1]-p[0][1],p[2][2]-p[0][2]],n=[u[1]*w[2]-u[2]*w[1],u[2]*w[0]-u[0]*w[2],u[0]*w[1]-u[1]*w[0]],nn=Math.hypot(n[0],n[1],n[2])||1,lum=Math.abs((n[0]*cv[0]+n[1]*cv[1]+n[2]*cv[2])/nn);" +
            "s+='<path d=\"'+d+'\" style=\"fill:'+it.fi+(it.fo<1?';fill-opacity:'+it.fo:'')+';stroke:none\"/><path d=\"'+d+'\" style=\"fill:#000000;fill-opacity:'+(+((1-lum)*0.35*it.fo).toFixed(3))+(it.st?';stroke:'+it.st+';stroke-width:0.18;stroke-linecap:round;stroke-linejoin:round':';stroke:none')+'\"/>';return}" +
            "s+='<path d=\"'+d+'\" style=\"fill:none;stroke:'+it.st+';stroke-width:'+it.w+(it.da?';stroke-dasharray:'+it.da:'')+';stroke-linecap:round;stroke-linejoin:round\"/>'});svg.innerHTML=s};" +
            "window.hkAl3dIni=function(id){var box=document.getElementById(id),svg=box.querySelector('svg.hk-dib-svg'),x0,y0,az0,el0,dn=false;svg.style.cursor='grab';svg.style.touchAction='none';" +
            "svg.addEventListener('pointerdown',function(ev){var D=box.__d||(box.__d=JSON.parse(box.querySelector('script.hk3d').textContent));dn=true;x0=ev.clientX;y0=ev.clientY;az0=D.az;el0=D.el;svg.setPointerCapture(ev.pointerId);svg.style.cursor='grabbing'});" +
            "svg.addEventListener('pointermove',function(ev){if(!dn)return;var el=Math.max(-90,Math.min(90,el0+(ev.clientY-y0)*0.5));hkAl3d(id,az0-(ev.clientX-x0)*0.5,el)});" +
            "svg.addEventListener('pointerup',function(){dn=false;svg.style.cursor='grab'})}}</script>";

        /// <summary>La escena lista para pintar (2D o 3D): primitivas de papel, tamaño y, en 3D, los datos para girarla.</summary>
        sealed class Escena { public List<Prim> L; public double W, H, Kv = 1; public string Json; public double Az, El; }
        static Escena Armar(Dibujo d, Opc o, bool oscuro)
        {
            if (!Es3D(d))
            {
                var v = Encuadre(d, o.Ancho, o.Alto);
                return new Escena { L = Primitivas(d, v, oscuro), W = v.W, H = v.H, Kv = v.Kv };
            }
            double az = d.Var("HKAZ", -60), el = d.Var("HKEL", 25), pad = 6, k0 = 0;
            var L3 = Prims3D(d, oscuro);
            // el tamaño del papel: el de la vista inicial encajada en ancho × alto
            var q = L3.SelectMany(it => it.P).Select(p => Proy(p, az, el)).ToList();
            double wx = q.Count > 0 ? Math.Max(q.Max(v => v[0]) - q.Min(v => v[0]), 1e-9) : 1, wy = q.Count > 0 ? Math.Max(q.Max(v => v[1]) - q.Min(v => v[1]), 1e-9) : 1;
            double K = Math.Min((o.Ancho - 2 * pad) / wx, (o.Alto - 2 * pad) / wy);
            double W = wx * K + 2 * pad, H = wy * K + 2 * pad;
            var L = Proyectar(L3, az, el, W, H, pad, ref k0);
            return new Escena { L = L, W = W, H = H, Json = Json3D(L3, az, el, W, H, pad, k0), Az = az, El = el };
        }

        public static string RenderSvg(Dibujo d, Opc o)
        {
            o ??= new Opc();
            var esc = Armar(d, o, LispConverter.Dark);
            var L = esc.L;
            var html = new StringBuilder();
            html.Append("<div class=\"hk-dib hk-al-dib\">");
            string tit = !string.IsNullOrWhiteSpace(o.Titulo) ? o.Titulo : d.Titulo;
            html.Append("<div class=\"hk-dib-tit\">");
            if (!string.IsNullOrWhiteSpace(tit)) html.Append("<b>").Append(LispConverter.FormatInlineText(tit, _ => null)).Append("</b> · ");
            int n = d.Ents.Count;
            html.Append("<span class=\"hk-dib-esc\">").Append(n).Append(n == 1 ? " entidad" : " entidades")
                .Append(esc.Kv != 1 ? " · escala vertical ×" + F(esc.Kv) : "").Append(esc.Json != null ? " · vista 3D: arrastra para girar" : "").Append("</span></div>");
            html.Append("<svg class=\"hk-dib-svg\" xmlns=\"http://www.w3.org/2000/svg\" viewBox=\"0 0 ").Append(F(esc.W)).Append(' ').Append(F(esc.H))
                .Append("\" width=\"").Append(F(esc.W)).Append("mm\" height=\"").Append(F(esc.H)).Append("mm\" style=\"max-width:100%;height:auto\">")
                .Append(SvgDe(L)).Append("</svg>");
            var usadas = d.Ents.Select(e => e.CapaN).Distinct(StringComparer.OrdinalIgnoreCase).ToList();
            if (usadas.Count > 1 || (usadas.Count == 1 && usadas[0] != "0"))
            {
                html.Append("<div class=\"hk-dib-ley\">");
                foreach (var cn in usadas)
                {
                    var cp = d.CapaDe(cn) ?? new Capa { Nombre = cn };
                    // color de la capa; si es el de fábrica (7) y sus entidades llevan color propio, el de la primera
                    int cc = Math.Abs(cp.Color);
                    var pri = d.Ents.FirstOrDefault(x => string.Equals(x.CapaN, cn, StringComparison.OrdinalIgnoreCase));
                    if (cc == 7 && pri != null && pri.Int(62, 256) != 256) cc = pri.Int(62, 256);
                    string c = AciCss(cc, LispConverter.Dark); string da = Dash(pri?.Get(6) ?? cp.Tipo);
                    html.Append("<span class=\"hk-dib-li\"><svg width=\"26\" height=\"10\" viewBox=\"0 0 26 10\" style=\"vertical-align:middle\"><line x1=\"2\" y1=\"5\" x2=\"24\" y2=\"5\" style=\"stroke:")
                        .Append(c).Append(";stroke-width:1.6").Append(da != null ? ";stroke-dasharray:" + string.Join(" ", da.Split(' ').Select(x => F(double.Parse(x, Inv) * 2.2))) : "")
                        .Append("\"/></svg>").Append(Enc(cp.Nombre)).Append("</span>");
                }
                html.Append("</div>");
            }
            html.Append("</div>");
            return html.ToString();
        }

        /// <summary>SVG autónomo (archivo .svg): colores reales, fondo de papel.</summary>
        public static string SvgArchivo(Dibujo d, Opc o, bool oscuro = false)
        {
            o ??= new Opc();
            var esc = Armar(d, o, oscuro); var L = esc.L;
            var v = new Vista { W = esc.W, H = esc.H };
            foreach (var p in L) { p.Fill = ColorReal(p.Fill, oscuro); p.Stroke = ColorReal(p.Stroke, oscuro); }
            string bg = oscuro ? "#000000" : "#ffffff";
            return "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n<svg xmlns=\"http://www.w3.org/2000/svg\" viewBox=\"0 0 " + F(v.W) + " " + F(v.H) +
                   "\" width=\"" + F(v.W) + "mm\" height=\"" + F(v.H) + "mm\"><rect x=\"0\" y=\"0\" width=\"" + F(v.W) + "\" height=\"" + F(v.H) +
                   "\" style=\"fill:" + bg + "\"/>" + SvgDe(L) + "</svg>\n";
        }

        // ---------- PDF (vectorial, una página del tamaño del dibujo) ----------
        static readonly int[] AnchoHelv = {
            278,278,355,556,556,889,667,191,333,333,389,584,278,333,278,278,556,556,556,556,556,556,556,556,556,556,278,278,584,584,584,556,
            1015,667,667,722,722,667,611,778,722,278,500,667,556,833,722,778,667,778,722,667,611,722,667,944,667,667,611,278,278,278,469,556,
            333,556,556,500,556,556,278,556,556,222,222,500,222,833,556,556,556,556,333,500,278,556,500,722,500,500,500,334,260,334,584 };
        static double AnchoTexto(string t, double size, bool serif)
        {
            double w = 0;
            foreach (char c in t) w += (c >= 32 && c <= 126) ? AnchoHelv[c - 32] : 556;
            return w / 1000 * size * (serif ? 0.93 : 1);
        }
        static byte[] Win1252(string s)
        {
            var b = new List<byte>();
            foreach (char c in s)
            {
                if (c < 128) b.Add((byte)c);
                else if (c >= 0xA0 && c <= 0xFF) b.Add((byte)c);
                else b.Add((byte)(c switch { '−' => '-', '′' => '\'', '·' => 0xB7, '√' => 'v', '…' => 0x85, '–' => 0x96, '—' => 0x97, _ => '?' }));
            }
            return b.ToArray();
        }
        static string PdfStr(string s)
        {
            var sb = new StringBuilder("(");
            foreach (var by in Win1252(s))
            {
                char c = (char)by;
                if (c == '(' || c == ')' || c == '\\') sb.Append('\\').Append(c);
                else if (by < 32 || by > 126) sb.Append('\\').Append(Convert.ToString(by, 8).PadLeft(3, '0'));
                else sb.Append(c);
            }
            return sb.Append(')').ToString();
        }
        static (double r, double g, double b) Rgb(string css)
        {
            css ??= "#000000";
            if (css.StartsWith("#") && css.Length == 7)
                return (Convert.ToInt32(css.Substring(1, 2), 16) / 255.0, Convert.ToInt32(css.Substring(3, 2), 16) / 255.0, Convert.ToInt32(css.Substring(5, 2), 16) / 255.0);
            return (0, 0, 0);
        }
        static string P(double v) => Math.Round(v, 3).ToString("0.###", Inv);

        public static byte[] PdfArchivo(Dibujo d, Opc o)
        {
            o ??= new Opc();
            var esc = Armar(d, o, false); var L = esc.L;
            var v = new Vista { W = esc.W, H = esc.H };
            const double s = 72.0 / 25.4;                       // mm → pt
            double W = v.W * s, H = v.H * s;
            double X(double x) => x * s; double Y(double y) => (v.H - y) * s;
            var c = new StringBuilder();
            var alfas = new List<double>();
            string Gs(double a) { int k = alfas.FindIndex(x => Math.Abs(x - a) < 1e-6); if (k < 0) { alfas.Add(a); k = alfas.Count - 1; } return "/GS" + k + " gs "; }
            c.Append("1 1 1 rg 0 0 ").Append(P(W)).Append(' ').Append(P(H)).Append(" re f\n1 J 1 j\n");
            foreach (var p in L)
            {
                var (fr, fg, fb) = Rgb(ColorReal(p.Fill, false)); var (sr, sg, sbb) = Rgb(ColorReal(p.Stroke, false));
                if (p.K == "path" || p.K == "ell")
                {
                    c.Append("q ");
                    if (p.Fill != null) c.Append(P(fr)).Append(' ').Append(P(fg)).Append(' ').Append(P(fb)).Append(" rg ");
                    if (p.Stroke != null)
                    {
                        c.Append(P(sr)).Append(' ').Append(P(sg)).Append(' ').Append(P(sbb)).Append(" RG ").Append(P(p.W * s)).Append(" w ");
                        if (p.Dash != null) c.Append('[').Append(string.Join(" ", p.Dash.Split(' ').Select(x => P(Math.Max(double.Parse(x, Inv), 0.05) * s)))).Append("] 0 d ");
                    }
                    double op = p.Fill != null ? p.FillOp : p.StrokeOp;
                    if (op < 0.999) c.Append(Gs(op));
                    if (p.K == "path")
                    {
                        foreach (var sp in p.Sub)
                        {
                            for (int i = 0; i < sp.Count; i++) c.Append(P(X(sp[i][0]))).Append(' ').Append(P(Y(sp[i][1]))).Append(i == 0 ? " m " : " l ");
                            if (p.Cerrado) c.Append("h ");
                        }
                    }
                    else
                    {
                        double k = 0.5523, cx = X(p.Cx), cy = Y(p.Cy), rx = p.Rx * s, ry = p.Ry * s;
                        c.Append(P(cx + rx)).Append(' ').Append(P(cy)).Append(" m ");
                        c.Append(P(cx + rx)).Append(' ').Append(P(cy + k * ry)).Append(' ').Append(P(cx + k * rx)).Append(' ').Append(P(cy + ry)).Append(' ').Append(P(cx)).Append(' ').Append(P(cy + ry)).Append(" c ");
                        c.Append(P(cx - k * rx)).Append(' ').Append(P(cy + ry)).Append(' ').Append(P(cx - rx)).Append(' ').Append(P(cy + k * ry)).Append(' ').Append(P(cx - rx)).Append(' ').Append(P(cy)).Append(" c ");
                        c.Append(P(cx - rx)).Append(' ').Append(P(cy - k * ry)).Append(' ').Append(P(cx - k * rx)).Append(' ').Append(P(cy - ry)).Append(' ').Append(P(cx)).Append(' ').Append(P(cy - ry)).Append(" c ");
                        c.Append(P(cx + k * rx)).Append(' ').Append(P(cy - ry)).Append(' ').Append(P(cx + rx)).Append(' ').Append(P(cy - k * ry)).Append(' ').Append(P(cx + rx)).Append(' ').Append(P(cy)).Append(" c h ");
                    }
                    c.Append(p.Fill != null && p.Stroke != null ? (p.ParImpar ? "B*" : "B") : p.Fill != null ? (p.ParImpar ? "f*" : "f") : "S").Append(" Q\n");
                }
                else if (p.K == "text")
                {
                    double size = p.Size * s;
                    double ancho = p.Runs.Sum(r => AnchoTexto(r.T, size * (r.Sh != 0 ? 0.72 : 1), p.Serif));
                    double off = p.Anchor == "middle" ? -ancho / 2 : p.Anchor == "end" ? -ancho : 0;
                    double a = -p.Rot * Math.PI / 180, ca = Math.Cos(a), sa = Math.Sin(a);
                    double x0 = X(p.X) + off * ca, y0 = Y(p.Y) + off * sa;
                    c.Append("BT ").Append(P(fr)).Append(' ').Append(P(fg)).Append(' ').Append(P(fb)).Append(" rg ")
                     .Append(P(ca)).Append(' ').Append(P(sa)).Append(' ').Append(P(-sa)).Append(' ').Append(P(ca)).Append(' ').Append(P(x0)).Append(' ').Append(P(y0)).Append(" Tm ");
                    foreach (var r in p.Runs)
                    {
                        string f = p.Serif ? (r.It ? "/F2" : "/F3") : "/F1";
                        double sz = size * (r.Sh != 0 ? 0.72 : 1), rise = r.Sh > 0 ? 0.38 * size : r.Sh < 0 ? -0.22 * size : 0;
                        c.Append(f).Append(' ').Append(P(sz)).Append(" Tf ").Append(P(rise)).Append(" Ts ").Append(PdfStr(r.T)).Append(" Tj ");
                    }
                    c.Append("ET\n");
                }
            }
            // objetos
            var objs = new List<string>();
            objs.Add("<< /Type /Catalog /Pages 2 0 R >>");
            objs.Add("<< /Type /Pages /Kids [3 0 R] /Count 1 >>");
            var gs = new StringBuilder();
            for (int i = 0; i < alfas.Count; i++) gs.Append("/GS").Append(i).Append(" << /Type /ExtGState /ca ").Append(P(alfas[i])).Append(" /CA ").Append(P(alfas[i])).Append(" >> ");
            objs.Add("<< /Type /Page /Parent 2 0 R /MediaBox [0 0 " + P(W) + " " + P(H) + "] /Contents 4 0 R /Resources << /Font << /F1 5 0 R /F2 6 0 R /F3 7 0 R >>" +
                     (alfas.Count > 0 ? " /ExtGState << " + gs + ">>" : "") + " >> >>");
            byte[] cont = Encoding.ASCII.GetBytes(c.ToString());
            objs.Add(null);   // 4: el flujo, aparte
            objs.Add("<< /Type /Font /Subtype /Type1 /BaseFont /Helvetica /Encoding /WinAnsiEncoding >>");
            objs.Add("<< /Type /Font /Subtype /Type1 /BaseFont /Times-Italic /Encoding /WinAnsiEncoding >>");
            objs.Add("<< /Type /Font /Subtype /Type1 /BaseFont /Times-Roman /Encoding /WinAnsiEncoding >>");
            var ms = new System.IO.MemoryStream();
            void Esc(string t) { var b = Encoding.ASCII.GetBytes(t); ms.Write(b, 0, b.Length); }
            Esc("%PDF-1.4\n%âã\n".Replace("âã", "HK"));
            var offs = new List<long>();
            for (int i = 0; i < objs.Count; i++)
            {
                offs.Add(ms.Position);
                Esc((i + 1) + " 0 obj\n");
                if (objs[i] == null) { Esc("<< /Length " + cont.Length + " >>\nstream\n"); ms.Write(cont, 0, cont.Length); Esc("\nendstream\n"); }
                else Esc(objs[i] + "\n");
                Esc("endobj\n");
            }
            long xref = ms.Position;
            Esc("xref\n0 " + (objs.Count + 1) + "\n0000000000 65535 f \n");
            foreach (var of in offs) Esc(of.ToString("D10") + " 00000 n \n");
            Esc("trailer\n<< /Size " + (objs.Count + 1) + " /Root 1 0 R >>\nstartxref\n" + xref + "\n%%EOF\n");
            return ms.ToArray();
        }


        // ================================ DXF (R12, ASCII) ================================
        static string N(double v) => (Math.Abs(v) < 1e-12 ? 0 : v).ToString("0.##########", Inv);
        /// <summary>Texto a ASCII: lo que no es ASCII va como \U+XXXX (lo leen AutoCAD y ezdxf).</summary>
        static string Ascii(string s)
        {
            var sb = new StringBuilder();
            foreach (char c in s ?? "") { if (c < 128 && c >= 32) sb.Append(c); else if (c >= 128) sb.Append("\\U+").Append(((int)c).ToString("X4")); }
            return sb.ToString();
        }

        /// <summary>El dibujo como DXF R12 (AC1009). LWPOLYLINE → POLYLINE/VERTEX, MTEXT → TEXT por línea,
        /// HATCH lleno → SOLID en triángulos, rayado → LINE, DIMENSION → explotada (LINE, SOLID, TEXT):
        /// R12 no tiene esas entidades (o, las cotas, piden bloques anónimos).</summary>
        public static string EscribirDxf(Dibujo d, Opc o = null)
        {
            o ??= new Opc();
            var v = Encuadre(d, o.Ancho, o.Alto);
            var s = new StringBuilder();
            void G(int c, string val) => s.Append(c).Append("\r\n").Append(val).Append("\r\n");
            void Gn(int c, double val) => G(c, N(val));
            double xmin = double.MaxValue, ymin = double.MaxValue, xmax = double.MinValue, ymax = double.MinValue;
            foreach (var e in d.Ents) foreach (var p in PuntosExt(e, 1)) { xmin = Math.Min(xmin, p[0]); ymin = Math.Min(ymin, p[1]); xmax = Math.Max(xmax, p[0]); ymax = Math.Max(ymax, p[1]); }
            if (xmin > xmax) { xmin = ymin = 0; xmax = ymax = 1; }
            // HEADER mínimo
            G(0, "SECTION"); G(2, "HEADER");
            G(9, "$ACADVER"); G(1, "AC1009");
            G(9, "$DWGCODEPAGE"); G(3, "ANSI_1252");
            G(9, "$INSBASE"); Gn(10, 0); Gn(20, 0); Gn(30, 0);
            G(9, "$EXTMIN"); Gn(10, xmin); Gn(20, ymin); Gn(30, 0);
            G(9, "$EXTMAX"); Gn(10, xmax); Gn(20, ymax); Gn(30, 0);
            G(9, "$LTSCALE"); Gn(40, 0.2 / v.K);   // trazos de ~2.5 mm en el papel del render
            G(0, "ENDSEC");
            // TABLES: LTYPE, LAYER, STYLE
            var tipos = new (string n, string desc, double[] pat)[]
            {
                ("CONTINUOUS", "Solid line", new double[0]),
                ("DASHED", "__ __ __", new[] { 12.7, -6.35 }),
                ("HIDDEN", "_ _ _", new[] { 6.35, -3.175 }),
                ("CENTER", "____ _ ____", new[] { 31.75, -6.35, 6.35, -6.35 }),
                ("DOT", ". . .", new[] { 0.0, -6.35 }),
                ("PHANTOM", "_____ _ _", new[] { 31.75, -6.35, 6.35, -6.35, 6.35, -6.35 }),
                ("DASHDOT", "__ . __", new[] { 12.7, -6.35, 0.0, -6.35 }),
            };
            G(0, "SECTION"); G(2, "TABLES");
            G(0, "TABLE"); G(2, "LTYPE"); G(70, tipos.Length.ToString());
            foreach (var (n, desc, pat) in tipos)
            {
                G(0, "LTYPE"); G(2, n); G(70, "0"); G(3, desc); G(72, "65"); G(73, pat.Length.ToString());
                Gn(40, pat.Sum(x => Math.Abs(x)));
                foreach (var x in pat) Gn(49, x);
            }
            G(0, "ENDTAB");
            bool TipoOk(string t) => tipos.Any(x => x.n.Equals(t, StringComparison.OrdinalIgnoreCase));
            var capas = d.Capas.Count > 0 ? d.Capas : new List<Capa> { new Capa() };
            G(0, "TABLE"); G(2, "LAYER"); G(70, capas.Count.ToString());
            foreach (var c in capas)
            {
                G(0, "LAYER"); G(2, Ascii(c.Nombre)); G(70, "0"); G(62, (c.Color == 0 ? 7 : c.Color).ToString());
                G(6, TipoOk(c.Tipo) ? c.Tipo.ToUpperInvariant() : "CONTINUOUS");
            }
            G(0, "ENDTAB");
            G(0, "TABLE"); G(2, "STYLE"); G(70, "1");
            G(0, "STYLE"); G(2, "STANDARD"); G(70, "0"); Gn(40, 0); Gn(41, 1); Gn(50, 0); G(71, "0"); Gn(42, 2.5); G(3, "txt"); G(4, "");
            G(0, "ENDTAB");
            G(0, "ENDSEC");
            G(0, "SECTION"); G(2, "BLOCKS"); G(0, "ENDSEC");
            // ENTITIES
            G(0, "SECTION"); G(2, "ENTITIES");
            foreach (var e in d.Ents)
            {
                string capa = Ascii(e.CapaN);
                int col = e.Int(62, 256);
                string lt = e.Get(6);
                void Comun(string tipo)
                {
                    G(0, tipo); G(8, capa);
                    if (lt != null && !lt.Equals("BYLAYER", StringComparison.OrdinalIgnoreCase) && TipoOk(lt)) G(6, lt.ToUpperInvariant());
                    if (col != 256) G(62, col.ToString());
                }
                void P(int c, double[] p) { Gn(c, p[0]); Gn(c + 10, p[1]); Gn(c + 20, p.Length > 2 ? p[2] : 0); }
                void Solido(double[] a, double[] b, double[] c, double[] dd) { Comun("SOLID"); P(10, a); P(11, b); P(12, c); P(13, dd); }
                void Texto(double[] p, double h, string t, double angGrados, int h72, int v73)
                {
                    Comun("TEXT"); P(10, p); Gn(40, h); G(1, Ascii(t));
                    if (Math.Abs(angGrados) > 1e-12) Gn(50, angGrados);
                    if (h72 != 0) G(72, h72.ToString());
                    if (h72 != 0 || v73 != 0) P(11, p);
                    if (v73 != 0) G(73, v73.ToString());
                }
                switch (e.Tipo)
                {
                    case "POINT": Comun("POINT"); P(10, e.Pt(10)); break;
                    case "LINE": Comun("LINE"); P(10, e.Pt(10)); P(11, e.Pt(11)); break;
                    case "CIRCLE": Comun("CIRCLE"); P(10, e.Pt(10)); Gn(40, e.Num(40, 0)); break;
                    case "ARC":
                        Comun("ARC"); P(10, e.Pt(10)); Gn(40, e.Num(40, 0));
                        Gn(50, e.Num(50, 0) * 180 / Math.PI); Gn(51, e.Num(51, 0) * 180 / Math.PI);
                        break;
                    case "LWPOLYLINE":
                    {
                        Comun("POLYLINE"); G(66, "1"); Gn(10, 0); Gn(20, 0); Gn(30, 0);
                        G(70, ((e.Int(70, 0) & 1) == 1 ? 1 : 0).ToString());
                        double cw = e.Num(43, 0); if (cw > 0) { Gn(40, cw); Gn(41, cw); }
                        int k = -1; var vs = new List<(double[] p, double b)>();
                        foreach (var p in e.D)
                        {
                            if (p.Key == 10) { vs.Add((Ent.ParsePt(p.Value), 0)); k++; }
                            else if (p.Key == 42 && k >= 0 && double.TryParse(p.Value, NumberStyles.Float, Inv, out var b)) vs[k] = (vs[k].p, b);
                        }
                        foreach (var (p, b) in vs) { G(0, "VERTEX"); G(8, capa); P(10, p); if (Math.Abs(b) > 1e-12) Gn(42, b); }
                        G(0, "SEQEND"); G(8, capa);
                        break;
                    }
                    case "TEXT":
                    {
                        int h72 = e.Int(72, 0), v73 = e.Int(73, 0);
                        var q = (h72 != 0 || v73 != 0) ? (e.Pt(11) ?? e.Pt(10)) : e.Pt(10);
                        Texto(q, e.Num(40, 2.5), EsMat(e) ? RunsPlano(MathRuns(e.Get(1))) : TextoAcad(e.Get(1)), e.Num(50, 0) * 180 / Math.PI, h72, v73);
                        break;
                    }
                    case "MTEXT":
                    {
                        var p = e.Pt(10); double h = e.Num(40, 2.5); int at = e.Int(71, 1);
                        var ls = LineasMtext(e.Get(1));
                        int h72 = ((at - 1) % 3) switch { 1 => 1, 2 => 2, _ => 0 };
                        double total = h * 1.667 * (ls.Count - 1);
                        double y0 = ((at - 1) / 3) switch { 0 => -h, 1 => total / 2 - 0.5 * h, _ => total };
                        for (int i = 0; i < ls.Count; i++) Texto(new[] { p[0], p[1] + y0 - i * 1.667 * h, 0 }, h, ls[i], e.Num(50, 0) * 180 / Math.PI, h72, 0);
                        break;
                    }
                    case "SOLID": Solido(e.Pt(10), e.Pt(11), e.Pt(12), e.Pt(13) ?? e.Pt(12)); break;
                    case "HATCH":
                    {
                        bool solido = string.Equals(e.Get(2), "SOLID", StringComparison.OrdinalIgnoreCase);
                        if (solido)
                            foreach (var l in Lazos(e))
                                foreach (var t in Triangular(l)) Solido(t[0], t[1], t[2], t[2]);
                        else
                            foreach (var (a, b) in Rayado(e)) { Comun("LINE"); P(10, a); P(11, b); }
                        break;
                    }
                    case "DIMENSION":
                    {
                        // la cota se dibuja en papel: se vuelve al mundo con la vista inversa
                        var g = Cota(d, e, v); if (g == null) break;
                        double[] W(double X, double Y) => new[] { (X - v.Pad) / v.K + v.X0, (v.Y1 - (Y - v.Pad) / v.K) / v.Kv, 0 };
                        foreach (var (x1, y1, x2, y2) in g.Lineas) { Comun("LINE"); P(10, W(x1, y1)); P(11, W(x2, y2)); }
                        foreach (var t in g.Flechas) Solido(W(t[0], t[1]), W(t[2], t[3]), W(t[4], t[5]), W(t[4], t[5]));
                        Texto(W(g.Tx, g.Ty), g.TAlt / v.K, g.Txt, -g.TAng, 1, 0);
                        break;
                    }
                }
            }
            G(0, "ENDSEC");
            G(0, "EOF");
            return s.ToString();
        }
        /// <summary>Triangulación por orejas (polígono simple) → para pasar un HATCH lleno a SOLID.</summary>
        static List<double[][]> Triangular(List<double[]> pol)
        {
            var res = new List<double[][]>();
            var idx = Enumerable.Range(0, pol.Count).ToList();
            double area = 0; for (int i = 0; i < pol.Count; i++) { var a = pol[i]; var b = pol[(i + 1) % pol.Count]; area += a[0] * b[1] - b[0] * a[1]; }
            if (area < 0) idx.Reverse();
            int guard = 0;
            while (idx.Count > 3 && guard++ < 10000)
            {
                bool corto = false;
                for (int i = 0; i < idx.Count; i++)
                {
                    var a = pol[idx[(i + idx.Count - 1) % idx.Count]]; var b = pol[idx[i]]; var c = pol[idx[(i + 1) % idx.Count]];
                    double cr = (b[0] - a[0]) * (c[1] - a[1]) - (b[1] - a[1]) * (c[0] - a[0]);
                    if (cr <= 1e-15) continue;
                    bool dentro = false;
                    foreach (var j in idx)
                    {
                        var p = pol[j]; if (p == a || p == b || p == c) continue;
                        double d1 = (b[0] - a[0]) * (p[1] - a[1]) - (b[1] - a[1]) * (p[0] - a[0]);
                        double d2 = (c[0] - b[0]) * (p[1] - b[1]) - (c[1] - b[1]) * (p[0] - b[0]);
                        double d3 = (a[0] - c[0]) * (p[1] - c[1]) - (a[1] - c[1]) * (p[0] - c[0]);
                        if (d1 >= 0 && d2 >= 0 && d3 >= 0) { dentro = true; break; }
                    }
                    if (dentro) continue;
                    res.Add(new[] { a, b, c }); idx.RemoveAt(i); corto = true; break;
                }
                if (!corto) break;
            }
            if (idx.Count == 3) res.Add(new[] { pol[idx[0]], pol[idx[1]], pol[idx[2]] });
            return res;
        }

        // ================================ la hoja ================================
        public sealed class Bloque
        {
            public string Titulo; public double Ancho = 160, Alto = 115, Vert = 1; public bool Nuevo = true;
            public List<string> Exporta = new List<string>(); public List<string> Codigo = new List<string>();
            public List<string> Contexto = new List<string>();
        }
        static Bloque Cabecera(string a)
        {
            var b = new Bloque();
            a ??= "";
            var mt = Regex.Match(a, "^\\s*\"([^\"]*)\"");
            if (mt.Success) b.Titulo = mt.Groups[1].Value;
            var me = Regex.Match(a, @"exporta\s*=\s*(\[[^\]]*\]|[^,]*)", RegexOptions.IgnoreCase);
            if (me.Success)
                b.Exporta = me.Groups[1].Value.Trim('[', ']', ' ').Split(new[] { ',', ' ', ';' }, StringSplitOptions.RemoveEmptyEntries)
                             .Where(x => Regex.IsMatch(x, @"^[A-Za-z_][\w\-]*$")).ToList();
            foreach (Match m in Regex.Matches(a, @"(\w+)\s*=\s*([^,]+)"))
            {
                string k = m.Groups[1].Value.ToLowerInvariant(), val = m.Groups[2].Value.Trim().Trim('"');
                double.TryParse(val, NumberStyles.Float, Inv, out double num);
                switch (k)
                {
                    case "titulo": b.Titulo = val; break;
                    case "ancho": if (num > 0) b.Ancho = num; break;
                    case "alto": if (num > 0) b.Alto = num; break;
                    case "vert": case "exagerar": if (num > 0) b.Vert = num; break;
                    case "nuevo": b.Nuevo = !(val.StartsWith("no", StringComparison.OrdinalIgnoreCase) || val == "0" || val.Equals("false", StringComparison.OrdinalIgnoreCase)); break;
                }
            }
            return b;
        }

        static readonly Regex RxDef = new Regex(@"^([A-Za-z_]\w*)\s*(?:\(\s*([A-Za-z_]\w*)(?:\s*,\s*[A-Za-z_]\w*)*\s*\))?\s*=\s*(?!=)(.+)$");
        /// <summary>Una definición de la hoja (L = 6, f(x) = x^2 − 1) → (setq …) para el LISP.</summary>
        static string SetqDe(string linea, Dictionary<string, double[]> nums)
        {
            var t = linea.Trim();
            if (t.Length == 0 || t[0] == '#' || t[0] == ';' || t[0] == '%' || t[0] == '(') return null;
            if (LispConverter.SepararDescripcion(t, out var sd, out _)) t = sd;
            if (LispConverter.SepararUnidad(t, out var su, out _)) t = su;
            var m = RxDef.Match(t);
            if (!m.Success) return null;
            string name = m.Groups[1].Value, rhs = m.Groups[3].Value.Trim();
            // «A = B = C»: se queda con el último tramo
            int k = rhs.LastIndexOf(" = ", StringComparison.Ordinal); if (k >= 0) rhs = rhs.Substring(k + 3);
            if (!m.Groups[2].Success)
            {
                try
                {
                    var val = LispDibujo.Eval(LispConverter.ParseMath(rhs), n => nums.TryGetValue(n, out var vv) ? vv : null);
                    if (val != null && val.Length > 0 && val.All(x => !double.IsNaN(x) && !double.IsInfinity(x)))
                    {
                        nums[name] = val;
                        string L(double x) => x.ToString("0.0###############", Inv) + "d0";
                        return val.Length == 1 ? "(hk-al-ctx '" + name + " " + L(val[0]) + ")"
                                               : "(hk-al-ctx '" + name + " '(" + string.Join(" ", val.Select(L)) + "))";
                    }
                }
                catch { }
            }
            try
            {
                var lf = LispConverter.MathToLisp(rhs);
                if (!string.IsNullOrWhiteSpace(lf) && Balanceado(lf)) return "(hk-al-ctx '" + name + " '" + lf + ")";
            }
            catch { }
            return null;
        }
        static bool Balanceado(string s) { int b = 0; bool q = false; foreach (var c in s) { if (c == '"') q = !q; if (q) continue; if (c == '(') b++; else if (c == ')') { if (--b < 0) return false; } } return b == 0 && !q; }
        static string LispStr(string s) => "\"" + (s ?? "").Replace("\\", "\\\\").Replace("\"", "\\\"") + "\"";

        /// <summary>
        /// Pliega los bloques #autolisp … #fin de la hoja: los ejecuta TODOS en una sola llamada al motor
        /// (las variables pasan de un bloque al siguiente) y deja en su sitio una línea marcador
        /// «#autolispout(k)» + las líneas «nombre = valor» de lo exportado. htmls[k] = lo que se pinta.
        /// </summary>
        public static string Plegar(string text, Func<string, string> correr, Func<string, byte[], string> guardar, out Dictionary<int, string> htmls)
        {
            htmls = new Dictionary<int, string>();
            var src = (text ?? "").Replace("\r", "").Split('\n');
            if (!src.Any(l => RxInicio.IsMatch(l))) return text;
            var bloques = new List<Bloque>();
            var salida = new List<object>();            // string (línea) o int (índice de bloque)
            var ctx = new List<string>();
            for (int i = 0; i < src.Length; i++)
            {
                var m = RxInicio.Match(src[i]);
                if (!m.Success) { salida.Add(src[i]); ctx.Add(src[i]); continue; }
                var b = Cabecera(m.Groups["a"].Success ? m.Groups["a"].Value : "");
                b.Contexto = ctx; ctx = new List<string>();
                int j = i + 1;
                for (; j < src.Length; j++)
                {
                    if (RxFin.IsMatch(src[j])) break;
                    if (RxInicio.IsMatch(src[j])) { j--; break; }
                    b.Codigo.Add(src[j]);
                }
                i = Math.Min(j, src.Length - 1);
                salida.Add(bloques.Count);
                bloques.Add(b);
            }
            // el programa: contexto de la hoja → código → volcado → exportados, por bloque
            var nums = new Dictionary<string, double[]>();
            var prog = new StringBuilder();
            prog.Append("(hk-al-nuevo)\n");
            for (int k = 0; k < bloques.Count; k++)
            {
                var b = bloques[k];
                prog.Append("(format t \"~&~cK~c").Append(k).Append("~%\" (code-char 28) (code-char 31))\n");
                foreach (var l in b.Contexto) { var sq = SetqDe(l, nums); if (sq != null) prog.Append(sq).Append('\n'); }
                if (b.Nuevo && k > 0) prog.Append("(hk-al-nuevo)\n");
                if (b.Vert != 1) prog.Append("(vertical ").Append(b.Vert.ToString("0.0###", Inv)).Append("d0)\n");
                prog.Append("(hk-al-ejecuta ").Append(LispStr(string.Join("\n", b.Codigo))).Append(")\n");
                prog.Append("(hk-al-volcar ").Append(LispStr(b.Titulo ?? "")).Append(")\n");
                foreach (var x in b.Exporta)
                    prog.Append("(hk-al-exporta \"").Append(x).Append("\" (and (boundp '").Append(x).Append(") (symbol-value '").Append(x).Append(")))\n");
            }
            string outp;
            try { outp = correr(prog.ToString()) ?? ""; }
            catch (Exception ex) { outp = "; error: " + ex.Message; }
            var partes = ParseBloques(outp);
            var res = new StringBuilder();
            bool primera = true;
            foreach (var it in salida)
            {
                if (!primera) res.Append('\n');
                primera = false;
                if (it is string s) { res.Append(s); continue; }
                int k = (int)it;
                partes.TryGetValue(k, out var sal);
                htmls[k] = HtmlBloque(sal, bloques[k], guardar);
                res.Append("#autolispout(").Append(k).Append(')');
                if (sal != null)
                    foreach (var kv in sal.Exporta)
                        if (kv.Value.Length > 0) res.Append('\n').Append(kv.Key).Append(" = ").Append(kv.Value);
            }
            return res.ToString();
        }

        /// <summary>Un programa LISP entero (sin #autolisp) que dibuja: salida + dibujo en un solo bloque HTML.</summary>
        public static string Programa(string code, Func<string, string> correr, Func<string, byte[], string> guardar)
        {
            string prog = "(hk-al-nuevo)\n(format t \"~&~cK~c0~%\" (code-char 28) (code-char 31))\n(hk-al-ejecuta " + LispStr(code) + ")\n(hk-al-volcar \"\")\n";
            string outp;
            try { outp = correr(prog) ?? ""; } catch (Exception ex) { outp = "; error: " + ex.Message; }
            var partes = ParseBloques(outp);
            partes.TryGetValue(0, out var sal);
            return HtmlBloque(sal, new Bloque(), guardar);
        }

        // ================================ DWG (acadrust) ================================
        /// <summary>Escritor de DWG que pone la app: escritorio = Node + acadrust-wasm (pkg-node);
        /// web = null (lo hace la página con pkg-web). Recibe el JSON de DwgJson y devuelve los bytes.</summary>
        public static Func<string, byte[]> EscritorDwg;
        [ThreadStatic] static List<string> _avisosDwg;

        /// <summary>El dibujo en el JSON de hekatan-dwg / acadrust-wasm (pares DXF, como entmake):
        /// {"version":"AC1032","layers":[…],"entities":[[[0,"LINE"],[8,"capa"],[10,[x,y,z]],…]]}.
        /// Tipos que acepta el escritor: POINT, LINE, CIRCLE, ARC, LWPOLYLINE, TEXT, MTEXT (ángulos en GRADOS).
        /// Las cotas se explotan (LINE + TEXT + flechas LWPOLYLINE), el rayado va en LINE; 3DFACE,
        /// POLYLINE 3D y rellenos llenos todavía no → se avisa.</summary>
        public static string DwgJson(Dibujo d, Opc o, List<string> avisos)
        {
            o ??= new Opc();
            var v = Encuadre(d, o.Ancho, o.Alto);
            string J(string s) => JsonStr(s);
            string Pt(double[] p) => "[" + N(p[0]) + "," + N(p[1]) + "," + N(p.Length > 2 ? p[2] : 0) + "]";
            var ents = new List<string>();
            var sinDwg = new Dictionary<string, int>();
            foreach (var e in d.Ents)
            {
                string capa = e.CapaN; int col = e.Int(62, 256);
                string Com(string tipo) => "[0," + J(tipo) + "],[8," + J(capa) + "]" + (col != 256 ? ",[62," + col + "]" : "");
                switch (e.Tipo)
                {
                    case "POINT": ents.Add("[" + Com("POINT") + ",[10," + Pt(e.Pt(10)) + "]]"); break;
                    case "LINE": ents.Add("[" + Com("LINE") + ",[10," + Pt(e.Pt(10)) + "],[11," + Pt(e.Pt(11)) + "]]"); break;
                    case "CIRCLE": ents.Add("[" + Com("CIRCLE") + ",[10," + Pt(e.Pt(10)) + "],[40," + N(e.Num(40, 0)) + "]]"); break;
                    case "ARC":
                        ents.Add("[" + Com("ARC") + ",[10," + Pt(e.Pt(10)) + "],[40," + N(e.Num(40, 0)) + "],[50," + N(e.Num(50, 0) * 180 / Math.PI) + "],[51," + N(e.Num(51, 0) * 180 / Math.PI) + "]]");
                        break;
                    case "LWPOLYLINE":
                    {
                        var sb = new StringBuilder("[" + Com("LWPOLYLINE") + ",[70," + (e.Int(70, 0) & 1) + "]");
                        if (e.Num(43, 0) > 0) sb.Append(",[43,").Append(N(e.Num(43, 0))).Append(']');
                        foreach (var p in e.D)
                        {
                            if (p.Key == 10) { var q = Ent.ParsePt(p.Value); sb.Append(",[10,[").Append(N(q[0])).Append(',').Append(N(q[1])).Append("]]"); }
                            else if (p.Key == 42) sb.Append(",[42,").Append(p.Value).Append(']');
                        }
                        ents.Add(sb.Append(']').ToString());
                        break;
                    }
                    case "POLYLINE":
                    {
                        var pts = e.Pts(1011);
                        if ((e.Int(70, 0) & 8) != 0 || pts.Any(p => Math.Abs(p[2]) > 1e-12)) { sinDwg["POLYLINE 3D"] = sinDwg.GetValueOrDefault("POLYLINE 3D") + 1; break; }
                        ents.Add("[" + Com("LWPOLYLINE") + ",[70," + (e.Int(70, 0) & 1) + "]" + string.Concat(pts.Select(q => ",[10,[" + N(q[0]) + "," + N(q[1]) + "]]")) + "]");
                        break;
                    }
                    case "TEXT":
                    {
                        int h72 = e.Int(72, 0), v73 = e.Int(73, 0);
                        string t = EsMat(e) ? RunsPlano(MathRuns(e.Get(1))) : TextoAcad(e.Get(1));
                        var sb = new StringBuilder("[" + Com("TEXT") + ",[10," + Pt(e.Pt(10)) + "],[40," + N(e.Num(40, 2.5)) + "],[1," + J(t) + "]");
                        if (Math.Abs(e.Num(50, 0)) > 1e-12) sb.Append(",[50,").Append(N(e.Num(50, 0) * 180 / Math.PI)).Append(']');
                        if (h72 != 0 || v73 != 0) sb.Append(",[72,").Append(h72).Append("],[73,").Append(v73).Append("],[11,").Append(Pt(e.Pt(11) ?? e.Pt(10))).Append(']');
                        ents.Add(sb.Append(']').ToString());
                        break;
                    }
                    case "MTEXT":
                        ents.Add("[" + Com("MTEXT") + ",[10," + Pt(e.Pt(10)) + "],[40," + N(e.Num(40, 2.5)) + "],[71," + e.Int(71, 1) + "],[1," + J(e.Get(1)) + "]]");
                        break;
                    case "DIMENSION":
                    {
                        var g = Cota(d, e, v); if (g == null) break;
                        double[] W(double X, double Y) => new[] { (X - v.Pad) / v.K + v.X0, (v.Y1 - (Y - v.Pad) / v.K) / v.Kv, 0 };
                        foreach (var (x1, y1, x2, y2) in g.Lineas) ents.Add("[" + Com("LINE") + ",[10," + Pt(W(x1, y1)) + "],[11," + Pt(W(x2, y2)) + "]]");
                        foreach (var t in g.Flechas)
                            ents.Add("[" + Com("LWPOLYLINE") + ",[70,1]" + string.Concat(new[] { W(t[0], t[1]), W(t[2], t[3]), W(t[4], t[5]) }.Select(q => ",[10,[" + N(q[0]) + "," + N(q[1]) + "]]")) + "]");
                        var tp = W(g.Tx, g.Ty);
                        ents.Add("[" + Com("TEXT") + ",[10," + Pt(tp) + "],[40," + N(g.TAlt / v.K) + "],[1," + J(g.Txt) + "],[50," + N(-g.TAng) + "],[72,1],[73,0],[11," + Pt(tp) + "]]");
                        break;
                    }
                    case "HATCH":
                        if (string.Equals(e.Get(2), "SOLID", StringComparison.OrdinalIgnoreCase))
                        {   // relleno lleno: el DWG lleva su contorno (el relleno todavía no)
                            foreach (var l in Lazos(e)) ents.Add("[" + Com("LWPOLYLINE") + ",[70,1]" + string.Concat(l.Select(q => ",[10,[" + N(q[0]) + "," + N(q[1]) + "]]")) + "]");
                            sinDwg["relleno lleno (va su contorno)"] = sinDwg.GetValueOrDefault("relleno lleno (va su contorno)") + 1;
                        }
                        else foreach (var (a, b) in Rayado(e)) ents.Add("[" + Com("LINE") + ",[10," + Pt(a) + "],[11," + Pt(b) + "]]");
                        break;
                    case "SOLID":
                    {
                        var pts = new[] { e.Pt(10), e.Pt(11), e.Pt(13) ?? e.Pt(12), e.Pt(12) };
                        ents.Add("[" + Com("LWPOLYLINE") + ",[70,1]" + string.Concat(pts.Select(q => ",[10,[" + N(q[0]) + "," + N(q[1]) + "]]")) + "]");
                        break;
                    }
                    default: sinDwg[e.Tipo] = sinDwg.GetValueOrDefault(e.Tipo) + 1; break;
                }
            }
            foreach (var kv in sinDwg) avisos?.Add(kv.Value + " " + kv.Key + " no van en el DWG todavía (el DXF sí los lleva)");
            var capas = d.Capas.Select(c => "{\"name\":" + J(c.Nombre) + ",\"color\":" + Math.Abs(c.Color == 0 ? 7 : c.Color) + "}");
            return "{\"version\":\"AC1032\",\"layers\":[" + string.Join(",", capas) + "],\"entities\":[" + string.Join(",", ents) + "]}";
        }

        /// <summary>El último dibujo pintado (para «Guardar dibujo como…» del menú de escritorio).</summary>
        public static Dibujo UltimoDibujo; public static Opc UltimaOpc; public static string UltimoId;
        static int _idDib;
        public static readonly string[] Formatos = { "dxf", "svg", "png", "pdf", "dwg" };

        /// <summary>El archivo en el formato de la extensión. PNG lo hace la página (canvas) → null aquí;
        /// DWG: pendiente (write_dwg de hekatan-dwg / acadrust) → excepción con el aviso.</summary>
        public static byte[] Archivo(Dibujo d, Opc o, string ext)
        {
            switch ((ext ?? "").TrimStart('.').ToLowerInvariant())
            {
                case "dxf": return Encoding.ASCII.GetBytes(EscribirDxf(d, o));
                case "svg": return Encoding.UTF8.GetBytes(SvgArchivo(d, o));
                case "pdf": return PdfArchivo(d, o);
                case "png": return null;
                case "dwg":
                    if (EscritorDwg == null) throw new NotSupportedException("DWG: en la web se guarda con el botón DWG (acadrust en el navegador)");
                    return EscritorDwg(DwgJson(d, o, null));
                default: throw new NotSupportedException("formato no soportado: «" + ext + "» (usa .dxf .svg .png .pdf)");
            }
        }

        // JS de la página: guardar en cualquier formato (Blob → descarga) y PNG por canvas. Una línea.
        const string JsGuardar = "<script>if(!window.hkAlGuardar){window.hkAlB64=function(id,k){var e=document.getElementById(id+'-'+k);return e?e.textContent.trim():''};" +
            "window.hkAlBajar=function(blob,fn){var u=URL.createObjectURL(blob);var a=document.createElement('a');a.href=u;a.download=fn;document.body.appendChild(a);a.click();a.remove();setTimeout(function(){URL.revokeObjectURL(u)},5000)};" +
            "window.hkAlBytes=function(s){var b=atob(s),u=new Uint8Array(b.length);for(var i=0;i<b.length;i++)u[i]=b.charCodeAt(i);return u};" +
            "window.hkAlPng=function(id,pxmm){return new Promise(function(ok,mal){var box=document.getElementById(id);var w=parseFloat(box.getAttribute('data-w')),h=parseFloat(box.getAttribute('data-h'));" +
            "var img=new Image();img.onload=function(){var c=document.createElement('canvas');c.width=Math.round(w*pxmm);c.height=Math.round(h*pxmm);var g=c.getContext('2d');g.fillStyle='#ffffff';g.fillRect(0,0,c.width,c.height);g.drawImage(img,0,0,c.width,c.height);ok(c.toDataURL('image/png'))};" +
            "img.onerror=function(e){mal(e)};img.src='data:image/svg+xml;base64,'+hkAlB64(id,'svg')})};" +
            "window.hkAlGuardar=function(id,fmt,nom){if(fmt==='dwg'){var js=hkAlB64(id,'dwg'),av=(document.getElementById(id+'-dwg')||{}).getAttribute('data-avisos')||'';" +
            "if(window.chrome&&chrome.webview){chrome.webview.postMessage(JSON.stringify({hkDwg:js,nombre:nom+'.dwg'}));return}" +
            "import(new URL('dwg/acadrust_wasm.mjs',document.baseURI).href).then(function(m){return m.default().then(function(){hkAlBajar(new Blob([m.write_dwg_bytes(js)],{type:'application/acad'}),nom+'.dwg');if(av)setTimeout(function(){alert(av)},300)})}).catch(function(e){alert('DWG: '+e)});return}" +
            "if(fmt==='png'){hkAlPng(id,11.811).then(function(u){hkAlBajar(new Blob([hkAlBytes(u.split(',')[1])],{type:'image/png'}),nom+'.png')});return}" +
            "var mime={dxf:'application/dxf',svg:'image/svg+xml',pdf:'application/pdf'}[fmt];hkAlBajar(new Blob([hkAlBytes(hkAlB64(id,fmt))],{type:mime}),nom+'.'+fmt)}}</script>";

        static string NombreBase(string t)
        {
            var s = Regex.Replace((t ?? "").Trim(), @"[^\w\-]+", "_").Trim('_');
            return s.Length == 0 ? "dibujo" : (s.Length > 40 ? s.Substring(0, 40) : s);
        }

        static string HtmlBloque(Salida sal, Bloque b, Func<string, byte[], string> guardar)
        {
            var h = new StringBuilder("<div class=\"hk-al\">");
            if (sal == null) return h.Append("<div class=\"hk-dib-err\">⚠ #autolisp: el motor no devolvió nada</div></div>").ToString();
            string txt = sal.Texto.ToString().Trim('\n');
            if (txt.Trim().Length > 0)
            {
                h.Append("<pre class=\"hk-al-out\">");
                foreach (var l in txt.Split('\n'))
                {
                    bool err = l.StartsWith("; error");
                    h.Append(err ? "<span class=\"hk-al-errl\">⚠ " + Enc(l.Substring(2)) + "</span>" : Enc(l)).Append("&#10;");
                }
                h.Append("</pre>");
            }
            if (sal.Dib != null && sal.Dib.Ents.Count > 0)
            {
                var o = new Opc { Ancho = b.Ancho, Alto = b.Alto, Titulo = b.Titulo };
                UltimoDibujo = sal.Dib; UltimaOpc = o;
                string id = "hkal" + (++_idDib); UltimoId = id;
                var esc = Armar(sal.Dib, o, LispConverter.Dark);
                h.Append("<div id=\"").Append(id).Append("\" data-w=\"").Append(F(esc.W)).Append("\" data-h=\"").Append(F(esc.H)).Append("\">");
                h.Append(RenderSvg(sal.Dib, o));
                if (esc.Json != null)   // 3D: los datos, el guion que gira y los botones de vista
                {
                    h.Append("<script type=\"application/json\" class=\"hk3d\">").Append(esc.Json).Append("</script>").Append(JsVista3D)
                     .Append("<div class=\"hk-al-bar\"><span>Vista</span>");
                    foreach (var (nv, az, el) in new[] { ("Planta", -90.0, 90.0), ("Frente", -90.0, 0.0), ("Lateral", 0.0, 0.0), ("3D", esc.Az, esc.El) })
                        h.Append("<button type=\"button\" onclick=\"hkAl3d('").Append(id).Append("',").Append(F(az)).Append(',').Append(F(el)).Append(")\">").Append(nv).Append("</button>");
                    h.Append("</div><script>hkAl3dIni('").Append(id).Append("')</script>");
                }
                string nom = NombreBase(!string.IsNullOrWhiteSpace(b.Titulo) ? b.Titulo : sal.Dib.Titulo);
                // los archivos, embebidos (base64) para que los botones funcionen igual en escritorio y web
                foreach (var f in new[] { "dxf", "svg", "pdf" })
                {
                    string b64;
                    try { b64 = Convert.ToBase64String(Archivo(sal.Dib, o, f)); } catch { continue; }
                    h.Append("<script type=\"text/plain\" id=\"").Append(id).Append('-').Append(f).Append("\">").Append(b64).Append("</script>");
                }
                {   // DWG: el JSON de acadrust (lo escribe la ventana o, en la web, el wasm de la página)
                    var av = new List<string>();
                    string dj = DwgJson(sal.Dib, o, av);
                    h.Append("<script type=\"text/plain\" id=\"").Append(id).Append("-dwg\" data-avisos=\"").Append(Enc(string.Join("; ", av))).Append("\">").Append(dj.Replace("</", "<\\/")).Append("</script>");
                }
                h.Append(JsGuardar);
                h.Append("<div class=\"hk-al-bar\"><span>Guardar dibujo como</span>");
                foreach (var f in Formatos)
                    h.Append("<button type=\"button\" onclick=\"hkAlGuardar('").Append(id).Append("','").Append(f).Append("','").Append(nom).Append("')\">")
                     .Append(f.ToUpperInvariant()).Append("</button>");
                h.Append("</div>");
                // (guardar "archivo.ext") pedidos desde el LISP
                foreach (var nombre in sal.Dib.Guardar.Distinct())
                {
                    string ext = System.IO.Path.GetExtension(nombre).TrimStart('.').ToLowerInvariant();
                    if (ext.Length == 0) ext = "dxf";
                    string fn = System.IO.Path.HasExtension(nombre) ? nombre : nombre + ".dxf";
                    string nota;
                    try
                    {
                        var bytes = Archivo(sal.Dib, o, ext);
                        if (guardar == null)
                            nota = "usa el botón " + ext.ToUpperInvariant() + " para descargarlo";
                        else if (bytes == null)   // PNG: lo rasteriza la página y lo manda a la ventana
                        {
                            string ruta = guardar(fn, null);
                            h.Append("<script>(function(){function go(){if(!(window.chrome&&chrome.webview&&window.hkAlPng))return;hkAlPng('").Append(id)
                             .Append("',11.811).then(function(u){chrome.webview.postMessage(JSON.stringify({hkGuardarPng:").Append(JsonStr(ruta))
                             .Append(",datos:u}))})}if(document.readyState==='complete')go();else window.addEventListener('load',go)})();</script>");
                            nota = "guardado en " + Enc(ruta);
                        }
                        else nota = "guardado en " + Enc(guardar(fn, bytes));
                    }
                    catch (Exception ex) { nota = Enc(ex.Message); }
                    h.Append("<div class=\"hk-al-nota\">(guardar \"").Append(Enc(nombre)).Append("\") → ").Append(nota).Append("</div>");
                }
                h.Append("</div>");
            }
            return h.Append("</div>").ToString();
        }
    }
}
