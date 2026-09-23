using System;
using System.Collections.Generic;
using System.Globalization;
using System.Linq;
using System.Text;
using System.Text.RegularExpressions;

namespace HekatanLisp
{
    /// <summary>
    /// DIBUJO TÉCNICO 2D (SVG vectorial) para hojas de revisión / memoria: planta, elevación,
    /// sección y ARMADO. Es una directiva de BLOQUE, como #tabla: no pasa por SBCL, pero sus
    /// argumentos pueden usar valores y vectores YA calculados en la hoja (resolver numérico).
    ///
    ///   #dibujo("Planta", ud = m, escala = auto, ancho = 170, cotas = m, dec = 2)
    ///   #  rect(0, 0, 15.225, 9.5, "gruesa")
    ///   #  ejesx(x_ejes, "1")
    ///   #  varillas(0, 0.1, 3.65, 0.1, 7, 16, 20, 90, 90)
    ///   #  obs(1, 15.075, 9.675, "pendiente", "Presión máxima")
    ///   #fin
    ///
    /// El papel se dibuja en MILÍMETROS (viewBox en mm): textos, flechas, burbujas y grosores
    /// tienen tamaño de PAPEL fijo; la geometría va a escala 1:E (automática = la mayor escala
    /// normalizada que cabe en el ancho, o fija con escala = 1:50). Colores del tema (var(--…)).
    /// Compartido escritorio/web (web/HekatanLispWeb.csproj lo enlaza).
    ///
    /// Primitivas de CARGAS y DIAGRAMAS (23-sep-2026, hoja de la placa base):
    ///   carga(x1, y1, x2, y2, q1, q2, "texto", "estilo", n = 9, sentido = 1)
    ///       bloque de carga repartida (trapecio) sobre la cara p1→p2: q1, q2 = alto del bloque en
    ///       unidades de dibujo, a la IZQUIERDA de p1→p2 si es positivo (misma regla que cota);
    ///       las flechas apuntan a la cara (sentido = -1: salen de ella, p.ej. tracción).
    ///   curva(xa, xb, expr_en_x, "estilo", base = y0, n = 64, var = x)
    ///       y = f(x) en coordenadas del dibujo; con base = y0 se cierra contra esa recta y con
    ///       "relleno" queda pintado: DIAGRAMA de momentos, cortantes o presiones.
    ///   empotramiento(x1, y1, x2, y2, lado)
    ///       apoyo empotrado: trazo grueso p1→p2 + rayado a 45° del lado 'lado' (+1 = izquierda).
    ///   circulo(xv, yv, r) acepta VECTORES (un círculo por componente: pernos).
    ///   estilo "denso": relleno más opaco (0.35) · "tenue": más claro (0.08).
    /// </summary>
    public static class LispDibujo
    {
        static readonly CultureInfo Inv = CultureInfo.InvariantCulture;

        public static readonly Regex RxInicio = new Regex(@"^\s*#\s*dibujo\s*(?:\((?<a>.*)\))?\s*$",
            RegexOptions.IgnoreCase | RegexOptions.Singleline);
        static readonly Regex RxFin = new Regex(@"^\s*#\s*(?:fin\s*dibujo|findibujo|fin)\s*$", RegexOptions.IgnoreCase);
        static readonly Regex RxCmd = new Regex(@"^\s*#\s*(?<n>[A-Za-zÁÉÍÓÚáéíóúñÑ_]\w*)\s*\((?<a>.*)\)\s*$", RegexOptions.Singleline);

        public sealed class Bloque { public string Cabecera = ""; public List<string> Cmds = new List<string>(); }

        /// <summary>Busca los bloques #dibujo … #fin. El bloque queda guardado en la línea de
        /// inicio; las demás líneas del bloque se dejan en blanco (consumidas). Sin #fin, el
        /// bloque termina en la primera línea que no sea comentario '#'.</summary>
        public static void ExtractBlocks(string[] lines, Bloque[] outArr)
        {
            for (int i = 0; i < lines.Length; i++)
            {
                var m = RxInicio.Match(lines[i] ?? "");
                if (!m.Success) continue;
                var b = new Bloque { Cabecera = m.Groups["a"].Success ? m.Groups["a"].Value : "" };
                int j = i + 1;
                for (; j < lines.Length; j++)
                {
                    var t = (lines[j] ?? "").Trim();
                    if (RxFin.IsMatch(t)) { lines[j] = ""; j++; break; }
                    if (!t.StartsWith("#")) break;
                    if (RxInicio.IsMatch(t)) break;               // otro #dibujo sin #fin: cierra este
                    var c = t.TrimStart('#').Trim();
                    if (c.Length > 0) b.Cmds.Add(c);
                    lines[j] = "";
                }
                outArr[i] = b;
                i = j - 1;
            }
        }

        // ================= evaluador NUMÉRICO de argumentos (escalares y vectores) =================
        /// <summary>Evalúa un árbol (de ParseMath o ParseLisp) a números. Escalar = arreglo de 1.
        /// Nombres → lookup (valores de la hoja). v(i) = componente i (base 1) si v es un vector.</summary>
        public static double[] Eval(LispConverter.N n, Func<string, double[]> lookup)
        {
            if (n == null) throw new FormatException("expresión vacía");
            if (n.IsAtom)
            {
                var a = (n.Atom ?? "").Trim();
                var fr = Regex.Match(a, @"^(-?\d+)/(\d+)$");
                if (fr.Success) return new[] { double.Parse(fr.Groups[1].Value, Inv) / double.Parse(fr.Groups[2].Value, Inv) };
                if (double.TryParse(a, NumberStyles.Float, Inv, out var d)) return new[] { d };
                if (a == "pi" || a == "π") return new[] { Math.PI };
                var v = lookup?.Invoke(a);
                if (v == null) throw new FormatException("«" + LispConverter.OriginalName(a) + "» no está definida (o no es un número)");
                return v;
            }
            switch (n.Op)
            {
                case "neg": return Eval(n.A, lookup).Select(x => -x).ToArray();
                case "+": return Bin(Eval(n.A, lookup), Eval(n.B, lookup), (p, q) => p + q);
                case "-": return Bin(Eval(n.A, lookup), Eval(n.B, lookup), (p, q) => p - q);
                case "*": return Bin(Eval(n.A, lookup), Eval(n.B, lookup), (p, q) => p * q);
                case "/": return Bin(Eval(n.A, lookup), Eval(n.B, lookup), (p, q) => p / q);
                case "^": return Bin(Eval(n.A, lookup), Eval(n.B, lookup), Math.Pow);
                case "vec":
                case "mat":
                    return n.Items.SelectMany(it => Eval(it, lookup)).ToArray();
                case "fn":
                {
                    string f = (n.Atom ?? "").ToLowerInvariant();
                    var items = n.Items ?? new List<LispConverter.N>();
                    // v(i): índice (base 1) de un vector de la hoja
                    var vv = lookup?.Invoke(n.Atom);
                    if (vv != null && items.Count == 1)
                    {
                        int k = (int)Math.Round(Eval(items[0], lookup)[0]) - 1;
                        if (k < 0 || k >= vv.Length) throw new FormatException("índice fuera de rango: " + n.Atom + "(" + (k + 1) + ")");
                        return new[] { vv[k] };
                    }
                    var args = items.Select(it => Eval(it, lookup)).ToList();
                    double[] U(Func<double, double> g) => args[0].Select(g).ToArray();
                    switch (f)
                    {
                        case "sqrt": return U(Math.Sqrt);
                        case "abs": return U(Math.Abs);
                        case "sin": return U(Math.Sin);
                        case "cos": return U(Math.Cos);
                        case "tan": return U(Math.Tan);
                        case "exp": return U(Math.Exp);
                        case "ceil": return U(x => Math.Ceiling(x - 1e-9));
                        case "floor": return U(x => Math.Floor(x + 1e-9));
                        case "round": return U(x => Math.Floor(x + 0.5));
                        case "max": return args.Count == 1 ? new[] { args[0].Max() } : args.Aggregate((p, q) => Bin(p, q, Math.Max));
                        case "min": return args.Count == 1 ? new[] { args[0].Min() } : args.Aggregate((p, q) => Bin(p, q, Math.Min));
                        case "sum": case "suma": return new[] { args[0].Sum() };
                        case "len": case "length": case "numel": return new[] { (double)args[0].Length };
                        case "dec": return args[0];
                    }
                    throw new FormatException("función desconocida en el dibujo: " + n.Atom);
                }
            }
            throw new FormatException("operación no numérica: " + (n.Op ?? n.Atom));
        }

        static double[] Bin(double[] a, double[] b, Func<double, double, double> f)
        {
            if (a.Length == 1) return b.Select(y => f(a[0], y)).ToArray();
            if (b.Length == 1) return a.Select(x => f(x, b[0])).ToArray();
            if (a.Length != b.Length) throw new FormatException("vectores de distinto largo (" + a.Length + " y " + b.Length + ")");
            return a.Select((x, i) => f(x, b[i])).ToArray();
        }

        // ================= argumentos de un comando =================
        sealed class Arg { public string Raw; public string Str; public List<string> Strs; public string Name; }

        static List<string> SplitTop(string s, char sep)
        {
            var res = new List<string>(); int depth = 0; bool inQ = false; var cur = new StringBuilder();
            foreach (char c in s ?? "")
            {
                if (c == '"') inQ = !inQ;
                if (!inQ) { if (c == '(' || c == '[' || c == '{') depth++; else if (c == ')' || c == ']' || c == '}') depth--; }
                if (c == sep && depth == 0 && !inQ) { res.Add(cur.ToString()); cur.Clear(); }
                else cur.Append(c);
            }
            if (cur.ToString().Trim().Length > 0 || res.Count > 0) res.Add(cur.ToString());
            return res;
        }

        static string Unq(string t) { t = t.Trim(); return t.Length >= 2 && t[0] == '"' && t[t.Length - 1] == '"' ? t.Substring(1, t.Length - 2) : t; }

        static List<Arg> ParseArgs(string inside)
        {
            var list = new List<Arg>();
            foreach (var p0 in SplitTop(inside, ','))
            {
                var p = p0.Trim();
                var a = new Arg();
                var nm = Regex.Match(p, @"^([A-Za-z_]\w*)\s*=(?!=)\s*(.+)$", RegexOptions.Singleline);
                if (nm.Success && !p.StartsWith("\"")) { a.Name = nm.Groups[1].Value.ToLowerInvariant(); p = nm.Groups[2].Value.Trim(); }
                a.Raw = p;
                if (p.Length >= 2 && p[0] == '"' && p[p.Length - 1] == '"') a.Str = p.Substring(1, p.Length - 2);
                else if (p.Length >= 2 && p[0] == '{' && p[p.Length - 1] == '}')
                    a.Strs = SplitTop(p.Substring(1, p.Length - 2), ',').Select(Unq).ToList();
                list.Add(a);
            }
            return list;
        }

        // ================= contexto de dibujo =================
        sealed class Ctx
        {
            public Func<string, double[]> Look;
            public string Ud = "m";          // unidad de la geometría
            public double UdMm = 1000;       // mm por unidad
            public string UdCota = null;     // unidad de las cotas (null = la misma)
            public int Dec = -1;             // decimales de las cotas (-1 = según la unidad)
            public double K;                 // mm de PAPEL por unidad de dibujo
            public double Vy = 1;            // exageración VERTICAL (elevaciones largas y delgadas: vert = 5)
            public double X0, Y1;            // mundo: xmin, ymax (de la caja)
            public double ML, MT;            // márgenes de papel
            public double GxMin, GxMax, GyMin, GyMax;   // caja de la geometría (sin ejes)
            public StringBuilder Sb = new StringBuilder();
            public double PxMin = double.MaxValue, PxMax = double.MinValue, PyMin = double.MaxValue, PyMax = double.MinValue;
            public string Id;
            public double Px(double x) => ML + (x - X0) * K;
            public double Py(double y) => MT + (Y1 - y) * K * Vy;
            public void Ext(double px, double py) { PxMin = Math.Min(PxMin, px); PxMax = Math.Max(PxMax, px); PyMin = Math.Min(PyMin, py); PyMax = Math.Max(PyMax, py); }
        }

        static string F(double v) => Math.Round(v, 3).ToString("0.###", Inv);

        /// <summary>Número bonito para rótulos: entero sin decimales, si no hasta 'dec' cifras.</summary>
        public static string Num(double v, int dec = 2)
        {
            if (Math.Abs(v - Math.Round(v)) < 1e-9) return Math.Round(v).ToString("0", Inv);
            return Math.Round(v, dec).ToString("0." + new string('#', Math.Max(1, dec)), Inv);
        }

        // ---------- estilos: "gruesa rojo", "eje", "trazos", "relleno", "resalte" ----------
        sealed class Sty { public string Col = "var(--fg)"; public double W = 0.25; public string Dash = null; public bool Fill; public double FillOp = 0.15; public bool NoStroke; }
        static Sty Style(string s, double defW = 0.25)
        {
            var st = new Sty { W = defW };
            foreach (var t0 in (s ?? "").ToLowerInvariant().Split(new[] { ' ', ',', '+' }, StringSplitOptions.RemoveEmptyEntries))
            {
                switch (t0)
                {
                    case "fina": st.W = 0.18; break;
                    case "media": st.W = 0.3; break;
                    case "gruesa": st.W = 0.5; break;
                    case "muygruesa": st.W = 0.7; break;
                    case "eje": st.Dash = "7 1.2 1.2 1.2"; st.W = 0.18; st.Col = "var(--mut)"; break;
                    case "trazos": case "oculta": st.Dash = "2.2 1.2"; break;
                    case "puntos": st.Dash = "0.4 0.9"; break;
                    case "relleno": st.Fill = true; break;
                    case "denso": st.Fill = true; st.FillOp = 0.35; break;
                    case "tenue": st.Fill = true; st.FillOp = 0.08; break;
                    case "resalte": st.Fill = true; st.FillOp = 0.18; st.NoStroke = true; break;
                    case "sinborde": st.NoStroke = true; break;
                    case "negro": st.Col = "var(--fg)"; break;
                    case "gris": st.Col = "var(--mut)"; break;
                    case "rojo": st.Col = "var(--dib-rojo)"; break;
                    case "azul": st.Col = "var(--dib-azul)"; break;
                    case "verde": st.Col = "var(--dib-verde)"; break;
                    case "naranja": st.Col = "var(--dib-nar)"; break;
                    case "acero": case "varilla": st.Col = "var(--dib-acero)"; st.W = Math.Max(st.W, 0.55); break;
                }
            }
            return st;
        }
        static string StrokeCss(Sty st) =>
            st.NoStroke ? "stroke:none" :
            "stroke:" + st.Col + ";stroke-width:" + F(st.W) + (st.Dash != null ? ";stroke-dasharray:" + st.Dash : "") + ";stroke-linecap:round;stroke-linejoin:round";
        static string FillCss(Sty st) => st.Fill ? "fill:" + st.Col + ";fill-opacity:" + F(st.FillOp) : "fill:none";

        // ---------- texto SVG: _{sub} ^{sup}, escapado ----------
        static string SvgText(string t)
        {
            var e = System.Net.WebUtility.HtmlEncode(t ?? "");
            e = Regex.Replace(e, @"_\{([^{}]*)\}", "<tspan baseline-shift=\"sub\" font-size=\"72%\">$1</tspan>");
            e = Regex.Replace(e, @"\^\{([^{}]*)\}", "<tspan baseline-shift=\"super\" font-size=\"72%\">$1</tspan>");
            return e;
        }
        static int VisLen(string t) => Regex.Replace(t ?? "", @"[_^]\{([^{}]*)\}", "$1").Length;

        static void Text(Ctx c, double px, double py, string txt, double size, string anchor = "middle", double ang = 0,
                         string col = "var(--fg)", string weight = null)
        {
            c.Sb.Append("<text x=\"").Append(F(px)).Append("\" y=\"").Append(F(py)).Append("\" font-size=\"").Append(F(size))
             .Append("\" text-anchor=\"").Append(anchor).Append("\" dominant-baseline=\"middle\"")
             .Append(" style=\"fill:").Append(col).Append(";stroke:none;font-family:'Segoe UI',Arial,sans-serif").Append(weight != null ? ";font-weight:" + weight : "").Append("\"");
            if (Math.Abs(ang) > 1e-6) c.Sb.Append(" transform=\"rotate(").Append(F(ang)).Append(' ').Append(F(px)).Append(' ').Append(F(py)).Append(")\"");
            c.Sb.Append(">").Append(SvgText(txt)).Append("</text>");
            double w = VisLen(txt) * size * 0.56, h = size;
            double ca = Math.Abs(Math.Cos(ang * Math.PI / 180)), sa = Math.Abs(Math.Sin(ang * Math.PI / 180));
            double bw = w * ca + h * sa, bh = w * sa + h * ca;
            double cx = anchor == "start" ? px + bw / 2 * ca : anchor == "end" ? px - bw / 2 * ca : px;
            c.Ext(cx - bw / 2, py - bh / 2); c.Ext(cx + bw / 2, py + bh / 2);
        }

        static void Line(Ctx c, double x1, double y1, double x2, double y2, Sty st)
        {
            double a = c.Px(x1), b = c.Py(y1), d = c.Px(x2), e = c.Py(y2);
            c.Sb.Append("<line x1=\"").Append(F(a)).Append("\" y1=\"").Append(F(b)).Append("\" x2=\"").Append(F(d)).Append("\" y2=\"").Append(F(e))
             .Append("\" style=\"").Append(StrokeCss(st)).Append("\"/>");
            c.Ext(a, b); c.Ext(d, e);
        }
        static void PLine(Ctx c, double a, double b, double d, double e, string css)
        {
            c.Sb.Append("<line x1=\"").Append(F(a)).Append("\" y1=\"").Append(F(b)).Append("\" x2=\"").Append(F(d)).Append("\" y2=\"").Append(F(e))
             .Append("\" style=\"").Append(css).Append("\"/>");
            c.Ext(a, b); c.Ext(d, e);
        }
        // Punta de flecha RELLENA, orientada según (x0,y0)->(x1,y1) y de tamaño
        // constante en papel. Antes las puntas se dibujaban con poligono() de
        // vértices fijos: quedaban huecas, torcidas y separadas del trazo.
        const double PUNTA_MM = 2.6, PUNTA_ANCHO = 0.40;   // ancho = fracción del largo

        static double PuntaLargo(Ctx c) => PUNTA_MM / c.K;   // mm de papel -> unidades de dibujo

        static void Punta(Ctx c, double x0, double y0, double x1, double y1, Sty st, bool conTrazo)
        {
            double dx = x1 - x0, dy = y1 - y0, n = Math.Sqrt(dx * dx + dy * dy);
            if (n < 1e-12) return;
            double ux = dx / n, uy = dy / n, lg = Math.Min(PuntaLargo(c), n * 0.9), an = lg * PUNTA_ANCHO;
            if (conTrazo) Line(c, x0, y0, x1 - ux * lg * 0.85, y1 - uy * lg * 0.85, st);
            var relleno = new Sty { Col = st.Col, Fill = true, FillOp = 1.0, NoStroke = true };
            Poly(c, new[] { x1, x1 - ux * lg - uy * an, x1 - ux * lg + uy * an },
                    new[] { y1, y1 - uy * lg + ux * an, y1 - uy * lg - ux * an }, true, relleno);
        }

        static void Poly(Ctx c, IList<double> xs, IList<double> ys, bool closed, Sty st, string extraFill = null)
        {
            var sb = new StringBuilder();
            for (int i = 0; i < xs.Count; i++) { double a = c.Px(xs[i]), b = c.Py(ys[i]); sb.Append(F(a)).Append(',').Append(F(b)).Append(' '); c.Ext(a, b); }
            c.Sb.Append(closed ? "<polygon" : "<polyline").Append(" points=\"").Append(sb.ToString().Trim()).Append("\" style=\"")
             .Append(StrokeCss(st)).Append(';').Append(extraFill ?? FillCss(st)).Append("\"/>");
        }

        // flecha rellena con la punta en (px,py) apuntando en la dirección (ux,uy) de PAPEL
        static void Arrow(Ctx c, double px, double py, double ux, double uy, double L = 2.0, double W = 0.7)
        {
            double bx = px - ux * L, by = py - uy * L, nx = -uy, ny = ux;
            c.Sb.Append("<polygon points=\"").Append(F(px)).Append(',').Append(F(py)).Append(' ')
             .Append(F(bx + nx * W)).Append(',').Append(F(by + ny * W)).Append(' ')
             .Append(F(bx - nx * W)).Append(',').Append(F(by - ny * W)).Append("\" style=\"fill:var(--fg);stroke:none\"/>");
        }

        // ================= primitivas =================
        sealed class Prim
        {
            public string Name; public List<Arg> A; public string Src;
            public List<(double x, double y)> Pts = new List<(double, double)>();   // para la caja (mundo)
            public bool IsAxis;
        }

        sealed class Obs { public int N; public string Estado; public string Texto; public double[] X, Y; public double Dx = double.NaN, Dy = double.NaN; }

        static readonly HashSet<string> Known = new HashSet<string> {
            "linea","polilinea","poligono","rect","circulo","arco","flecha","flechamomento","texto","cota","cotas","cotasx","cotasy",
            "ejex","ejey","ejesx","ejesy","hueco","achurado","varilla","varillas","fila","estribo","seccion",
            "leyenda","obs","observacion","carga","curva","empotramiento","empotre"
        };

        /// <summary>Dibuja el bloque. lookup = valores de la hoja (nombre → números).
        /// Devuelve HTML: título + SVG + leyenda + tabla de observaciones + avisos.</summary>
        public static string Render(Bloque blk, Func<string, double[]> lookup)
        {
            var c = new Ctx { Look = lookup, Id = "hkd" + Guid.NewGuid().ToString("N").Substring(0, 6) };
            var errs = new List<string>();
            // ---- cabecera ----
            string titulo = null; double? escFija = null; double anchoMax = 170, altoMax = 150;
            foreach (var a in ParseArgs(blk.Cabecera ?? ""))
            {
                if (a.Name == null && a.Str != null) { titulo = a.Str; continue; }
                string v = (a.Str ?? a.Raw ?? "").Trim();
                switch (a.Name)
                {
                    case "titulo": titulo = v; break;
                    case "ud": case "unidad": c.Ud = v.ToLowerInvariant(); break;
                    case "cotas": c.UdCota = v.ToLowerInvariant(); break;
                    case "dec": int.TryParse(v, out c.Dec); break;
                    case "ancho": double.TryParse(v, NumberStyles.Float, Inv, out anchoMax); break;
                    case "alto": double.TryParse(v, NumberStyles.Float, Inv, out altoMax); break;
                    case "vert": case "exagerar": double.TryParse(v, NumberStyles.Float, Inv, out c.Vy); if (c.Vy <= 0) c.Vy = 1; break;
                    case "escala":
                        var em = Regex.Match(v, @"^1\s*:\s*([\d.]+)$");
                        if (em.Success) escFija = double.Parse(em.Groups[1].Value, Inv);
                        break;
                }
            }
            c.UdMm = c.Ud == "mm" ? 1 : c.Ud == "cm" ? 10 : 1000;
            if (c.UdCota == null) c.UdCota = c.Ud;

            // ---- 1ª pasada: parsear y medir (mundo) ----
            var prims = new List<Prim>();
            var obsList = new List<Obs>();
            var leyenda = new List<(string txt, string sty)>();
            foreach (var src in blk.Cmds)
            {
                var m = RxCmd.Match("#" + src);
                if (!m.Success) { errs.Add("no entiendo «" + src + "» (forma: nombre(argumentos))"); continue; }
                var p = new Prim { Name = m.Groups["n"].Value.ToLowerInvariant(), A = ParseArgs(m.Groups["a"].Value), Src = src };
                if (p.Name == "observacion") p.Name = "obs";
                if (!Known.Contains(p.Name)) { errs.Add("primitiva desconocida «" + p.Name + "» en «" + src + "»"); continue; }
                try { Measure(c, p, obsList, leyenda); prims.Add(p); }
                catch (Exception ex) { errs.Add(ex.Message + "  ← «" + src + "»"); }
            }
            // caja de la geometría
            // la caja de la GEOMETRÍA (hasta donde llegan los ejes) no cuenta cotas, textos ni observaciones
            var geo = prims.Where(p => !p.IsAxis && !(p.Name.StartsWith("cota") || p.Name is "texto" or "obs" or "leyenda")).SelectMany(p => p.Pts).ToList();
            var allX = prims.SelectMany(p => p.Pts).Select(q => q.x).Where(v => !double.IsNaN(v)).ToList();
            var allY = prims.SelectMany(p => p.Pts).Select(q => q.y).Where(v => !double.IsNaN(v)).ToList();
            if (allX.Count == 0 || allY.Count == 0) return "<div class=\"hk-dib-err\">⚠ #dibujo sin nada que dibujar" + ErrHtml(errs) + "</div>";
            var gX = geo.Select(q => q.x).Where(v => !double.IsNaN(v)).ToList();
            var gY = geo.Select(q => q.y).Where(v => !double.IsNaN(v)).ToList();
            c.GxMin = gX.Count > 0 ? gX.Min() : allX.Min(); c.GxMax = gX.Count > 0 ? gX.Max() : allX.Max();
            c.GyMin = gY.Count > 0 ? gY.Min() : allY.Min(); c.GyMax = gY.Count > 0 ? gY.Max() : allY.Max();
            double xmin = Math.Min(c.GxMin, allX.Min()), xmax = Math.Max(c.GxMax, allX.Max());
            double ymin = Math.Min(c.GyMin, allY.Min()), ymax = Math.Max(c.GyMax, allY.Max());
            bool hasX = prims.Any(p => p.Name is "ejex" or "ejesx"), hasY = prims.Any(p => p.Name is "ejey" or "ejesy");
            c.ML = hasY ? 17 : 8; c.MT = hasX ? 17 : 8;
            double mR = 8, mB = 8;
            double wg = Math.Max(xmax - xmin, 1e-9), hg = Math.Max(ymax - ymin, 1e-9);
            // ---- escala ----
            double E;
            string escNota = "";
            if (escFija.HasValue) { E = escFija.Value; }
            else
            {
                double kNeed = Math.Min((anchoMax - c.ML - mR) / wg, (altoMax - c.MT - mB) / (hg * c.Vy));
                double eMin = c.UdMm / kNeed;
                double[] norm = { 1, 2, 2.5, 5, 10, 20, 25, 50, 75, 100, 125, 150, 200, 250, 300, 400, 500, 750, 1000, 1250, 1500, 2000, 2500, 5000, 10000 };
                E = norm.FirstOrDefault(v => v >= eMin - 1e-9);
                if (E == 0) E = Math.Ceiling(eMin);
            }
            c.K = c.UdMm / E;
            if (escFija.HasValue && (wg * c.K + c.ML + mR > anchoMax + 0.5))
                escNota = " (a 1:" + Num(E) + " no cabe en " + Num(anchoMax) + " mm: se reduce en pantalla)";
            c.X0 = xmin; c.Y1 = ymax;

            // ---- 2ª pasada: dibujar ----
            // patrones de achurado (ids únicos por dibujo)
            var defs = new StringBuilder();
            defs.Append("<defs>")
                .Append("<pattern id=\"").Append(c.Id).Append("-diag\" patternUnits=\"userSpaceOnUse\" width=\"1.6\" height=\"1.6\" patternTransform=\"rotate(45)\">")
                .Append("<line x1=\"0\" y1=\"0\" x2=\"0\" y2=\"1.6\" style=\"stroke:var(--mut);stroke-width:.16\"/></pattern>")
                .Append("<pattern id=\"").Append(c.Id).Append("-cruz\" patternUnits=\"userSpaceOnUse\" width=\"1.8\" height=\"1.8\" patternTransform=\"rotate(45)\">")
                .Append("<line x1=\"0\" y1=\"0\" x2=\"0\" y2=\"1.8\" style=\"stroke:var(--mut);stroke-width:.14\"/>")
                .Append("<line x1=\"0\" y1=\"0\" x2=\"1.8\" y2=\"0\" style=\"stroke:var(--mut);stroke-width:.14\"/></pattern>")
                .Append("<pattern id=\"").Append(c.Id).Append("-conc\" patternUnits=\"userSpaceOnUse\" width=\"3\" height=\"3\">")
                .Append("<circle cx=\".7\" cy=\".8\" r=\".16\" style=\"fill:var(--mut)\"/><circle cx=\"2.2\" cy=\"2.1\" r=\".12\" style=\"fill:var(--mut)\"/>")
                .Append("<path d=\"M1.9 .5 l.45 .7 h-.9 z\" style=\"fill:none;stroke:var(--mut);stroke-width:.1\"/></pattern>")
                .Append("</defs>");
            // orden: rellenos/achurados primero, luego líneas, luego ejes/cotas/textos, al final observaciones
            int Order(Prim p) => p.Name switch
            {
                "achurado" or "seccion" or "hueco" => 0,
                "carga" or "curva" => 2,
                "ejex" or "ejey" or "ejesx" or "ejesy" => 1,
                "obs" => 9,
                "texto" or "cota" or "cotas" or "cotasx" or "cotasy" => 5,
                _ => p.A.Any(a => (a.Str ?? "").Contains("resalte")) ? 0 : 3,
            };
            foreach (var p in prims.OrderBy(Order))
            {
                try { Draw(c, p, errs); }
                catch (Exception ex) { errs.Add(ex.Message + "  ← «" + p.Src + "»"); }
            }
            foreach (var o in obsList) DrawObs(c, o);

            double pad = 2;
            double vx = Math.Min(0, c.PxMin - pad), vy = Math.Min(0, c.PyMin - pad);
            double vw = Math.Max(c.PxMax + pad, c.ML + wg * c.K + mR) - vx, vh = Math.Max(c.PyMax + pad, c.MT + hg * c.K * c.Vy + mB) - vy;
            var sb = new StringBuilder();
            sb.Append("<div class=\"hk-dib\">");
            string cotaUd = c.UdCota;
            sb.Append("<div class=\"hk-dib-tit\">");
            if (!string.IsNullOrEmpty(titulo)) sb.Append("<b>").Append(LispConverter.FormatInlineText(titulo, _ => null)).Append("</b> · ");
            sb.Append("<span class=\"hk-dib-esc\">Esc. 1:").Append(Num(E)).Append(c.Vy != 1 ? " (vertical ×" + Num(c.Vy) + ")" : "").Append(escNota).Append(" · geometría en ").Append(c.Ud)
              .Append(prims.Any(p => p.Name.StartsWith("cota")) ? " · cotas en " + cotaUd : "").Append("</span></div>");
            sb.Append("<svg class=\"hk-dib-svg\" xmlns=\"http://www.w3.org/2000/svg\" viewBox=\"").Append(F(vx)).Append(' ').Append(F(vy)).Append(' ')
              .Append(F(vw)).Append(' ').Append(F(vh)).Append("\" width=\"").Append(F(vw)).Append("mm\" height=\"").Append(F(vh))
              .Append("mm\" style=\"max-width:100%;height:auto\">").Append(defs).Append(c.Sb).Append("</svg>");
            if (leyenda.Count > 0)
            {
                sb.Append("<div class=\"hk-dib-ley\">");
                foreach (var (txt, sty) in leyenda) sb.Append("<span class=\"hk-dib-li\">").Append(Swatch(sty, c.Id)).Append(LispConverter.FormatInlineText(txt, _ => null)).Append("</span>");
                sb.Append("</div>");
            }
            if (obsList.Count > 0) sb.Append(ObsTable(c, obsList));
            if (errs.Count > 0) sb.Append("<div class=\"hk-dib-err\">").Append(ErrHtml(errs)).Append("</div>");
            sb.Append("</div>");
            return sb.ToString();
        }

        static string ErrHtml(List<string> errs) =>
            string.Join("", errs.Select(e => "<div>⚠ " + System.Net.WebUtility.HtmlEncode(e) + "</div>"));

        // ---------- helpers de argumentos ----------
        static Arg Pos(Prim p, int i) { var pos = p.A.Where(a => a.Name == null).ToList(); return i < pos.Count ? pos[i] : null; }
        static Arg Named(Prim p, string n) => p.A.FirstOrDefault(a => a.Name == n);
        static double[] Vals(Ctx c, Arg a)
        {
            if (a == null) throw new FormatException("faltan argumentos");
            if (a.Str != null || a.Strs != null) throw new FormatException("se esperaba un número y llegó texto: " + a.Raw);
            LispConverter.N tree;
            try { tree = LispConverter.ParseMath(LispConverter.MangleExpr(a.Raw)); }
            catch { throw new FormatException("no se puede leer «" + a.Raw + "»"); }
            return Eval(tree, c.Look);
        }
        static double V(Ctx c, Arg a) => Vals(c, a)[0];
        static double NumArg(Ctx c, Prim p, int i, double def) { var a = Pos(p, i); return a == null || (a.Str != null) ? def : V(c, a); }
        static double NumNamed(Ctx c, Prim p, string n, double def) { var a = Named(p, n); return a == null ? def : V(c, a); }
        static string StrArg(Prim p, int i, string def = null)
        {
            var a = Pos(p, i); return a == null ? def : a.Str ?? a.Raw;
        }
        /// <summary>Texto con {expr} o {expr:n} sustituidos por su valor (n decimales).</summary>
        static string Interp(Ctx c, string s)
        {
            if (string.IsNullOrEmpty(s)) return s ?? "";
            return Regex.Replace(s, @"(?<![_^])\{([^{}:]+)(?::(\d))?\}", m =>
            {
                try
                {
                    var tree = LispConverter.ParseMath(LispConverter.MangleExpr(m.Groups[1].Value));
                    var v = Eval(tree, c.Look);
                    int d = m.Groups[2].Success ? int.Parse(m.Groups[2].Value) : 3;
                    return string.Join(", ", v.Select(x => m.Groups[2].Success ? x.ToString("F" + d, Inv) : Num(x, d)));
                }
                catch { return m.Value; }
            });
        }
        static string ObsEstado(string e)
        {
            e = (e ?? "").ToLowerInvariant();
            if (e.StartsWith("corr") || e.StartsWith("ok") || e.StartsWith("resuel") || e.StartsWith("cerr")) return "corregida";
            if (e.StartsWith("info") || e.StartsWith("nota")) return "info";
            return "pendiente";
        }
        static string ObsCol(string est) => est == "corregida" ? "var(--dib-verde)" : est == "info" ? "var(--dib-azul)" : "var(--dib-rojo)";

        // lista de rótulos de ejes: {"1","2"} o arranque "1"/"A" que se incrementa
        static List<string> Labels(Prim p, int idx, int n)
        {
            var a = Pos(p, idx);
            if (a?.Strs != null) return a.Strs;
            string s0 = a == null ? "1" : (a.Str ?? a.Raw).Trim();
            var res = new List<string>();
            if (int.TryParse(s0, out int k0)) for (int i = 0; i < n; i++) res.Add((k0 + i).ToString(Inv));
            else if (s0.Length == 1 && char.IsLetter(s0[0])) for (int i = 0; i < n; i++) res.Add(((char)(s0[0] + i)).ToString());
            else for (int i = 0; i < n; i++) res.Add(i == 0 ? s0 : s0 + (i + 1));
            return res;
        }

        // Ø en mm → unidades de dibujo
        static double MmToUd(Ctx c, double mm) => mm / c.UdMm;

        static string BarLabel(double n, double dmm, double s)
        {
            string t = Num(n) + " Ø " + Num(dmm) + " mm";
            if (!double.IsNaN(s) && s > 0) t += " @ " + Num(s, 1) + " cm";
            return t;
        }

        // ================= 1ª pasada: puntos para la caja + recoger obs/leyenda =================
        static void Measure(Ctx c, Prim p, List<Obs> obs, List<(string, string)> ley)
        {
            void Add(double x, double y) => p.Pts.Add((x, y));
            switch (p.Name)
            {
                case "linea": case "cota": case "varilla": case "varillas": case "fila":
                    Add(V(c, Pos(p, 0)), V(c, Pos(p, 1))); Add(V(c, Pos(p, 2)), V(c, Pos(p, 3)));
                    if (p.Name == "cota")
                    {   // la línea de cota desplazada también cuenta
                        double d = NumArg(c, p, 4, 0);
                        double x1 = V(c, Pos(p, 0)), y1 = V(c, Pos(p, 1)), x2 = V(c, Pos(p, 2)), y2 = V(c, Pos(p, 3));
                        double L = Math.Sqrt((x2 - x1) * (x2 - x1) + (y2 - y1) * (y2 - y1)); if (L < 1e-12) break;
                        double nx = -(y2 - y1) / L, ny = (x2 - x1) / L;
                        Add(x1 + nx * d, y1 + ny * d); Add(x2 + nx * d, y2 + ny * d);
                    }
                    break;
                case "polilinea": case "poligono":
                {
                    var (xs, ys) = XY(c, p);
                    for (int i = 0; i < xs.Count; i++) Add(xs[i], ys[i]);
                    break;
                }
                case "achurado":
                    if (Pos(p, 0) != null && Vals(c, Pos(p, 0)).Length > 1) { var (xs, ys) = XY(c, p); for (int i = 0; i < xs.Count; i++) Add(xs[i], ys[i]); break; }
                    goto case "rect";
                case "rect": case "hueco": case "seccion": case "estribo":
                    foreach (var (x, y, b, h) in Rects(c, p)) { Add(x, y); Add(x + b, y + h); }
                    break;
                case "circulo": case "arco":
                {
                    var xs = Vals(c, Pos(p, 0)); var ys = Vals(c, Pos(p, 1)); double r = V(c, Pos(p, 2));
                    for (int i = 0; i < Math.Max(xs.Length, ys.Length); i++)
                    {
                        double x = xs[Math.Min(i, xs.Length - 1)], y = ys[Math.Min(i, ys.Length - 1)];
                        Add(x - r, y - r); Add(x + r, y + r);
                    }
                    break;
                }
                case "carga":
                {
                    double x1 = V(c, Pos(p, 0)), y1 = V(c, Pos(p, 1)), x2 = V(c, Pos(p, 2)), y2 = V(c, Pos(p, 3));
                    double q1 = V(c, Pos(p, 4)), q2 = NumArg(c, p, 5, q1);
                    var (nx, ny) = NormalIzq(x1, y1, x2, y2);
                    Add(x1, y1); Add(x2, y2); Add(x1 + nx * q1, y1 + ny * q1); Add(x2 + nx * q2, y2 + ny * q2);
                    break;
                }
                case "curva":
                {
                    var (xs, ys) = Curva(c, p);
                    for (int i = 0; i < xs.Length; i++) if (!double.IsNaN(ys[i]) && !double.IsInfinity(ys[i])) Add(xs[i], ys[i]);
                    var b = Named(p, "base"); if (b != null) { double y0 = V(c, b); Add(xs[0], y0); Add(xs[xs.Length - 1], y0); }
                    break;
                }
                case "empotramiento": case "empotre":
                    Add(V(c, Pos(p, 0)), V(c, Pos(p, 1))); Add(V(c, Pos(p, 2)), V(c, Pos(p, 3)));
                    break;
                case "texto":
                    Add(V(c, Pos(p, 0)), V(c, Pos(p, 1))); break;
                case "cotas": case "cotasx":
                {
                    var xs = Vals(c, Pos(p, 0)); double y = V(c, Pos(p, 1)), d = NumArg(c, p, 2, 0);
                    foreach (var x in xs) { Add(x, y); Add(x, y + d); }
                    break;
                }
                case "cotasy":
                {
                    var ys = Vals(c, Pos(p, 0)); double x = V(c, Pos(p, 1)), d = NumArg(c, p, 2, 0);
                    foreach (var y in ys) { Add(x, y); Add(x - d, y); }
                    break;
                }
                case "ejex": case "ejesx":   // los ejes X solo aportan su x (la y la da la geometría)
                    p.IsAxis = true;
                    foreach (var x in Vals(c, Pos(p, 0))) p.Pts.Add((x, double.NaN));
                    break;
                case "ejey": case "ejesy":
                    p.IsAxis = true;
                    foreach (var y in Vals(c, Pos(p, 0))) p.Pts.Add((double.NaN, y));
                    break;
                case "obs":
                {
                    var o = new Obs
                    {
                        N = (int)Math.Round(V(c, Pos(p, 0))),
                        X = Vals(c, Pos(p, 1)), Y = Vals(c, Pos(p, 2)),
                        Estado = ObsEstado(StrArg(p, 3, "pendiente")),
                        Texto = Interp(c, StrArg(p, 4, "")),
                    };
                    if (o.X.Length != o.Y.Length && o.X.Length != 1 && o.Y.Length != 1) throw new FormatException("obs: x e y de distinto largo");
                    int n = Math.Max(o.X.Length, o.Y.Length);
                    if (o.X.Length == 1 && n > 1) o.X = Enumerable.Repeat(o.X[0], n).ToArray();
                    if (o.Y.Length == 1 && n > 1) o.Y = Enumerable.Repeat(o.Y[0], n).ToArray();
                    for (int i = 0; i < n; i++) Add(o.X[i], o.Y[i]);
                    o.Dx = NumNamed(c, p, "dx", double.NaN); o.Dy = NumNamed(c, p, "dy", double.NaN);
                    obs.Add(o);
                    break;
                }
                case "leyenda":
                    ley.Add((Interp(c, StrArg(p, 0, "")), StrArg(p, 1, "")));
                    break;
            }
        }

        // x, y, b, h escalares o vectores (broadcast): lista de rectángulos
        static List<(double, double, double, double)> Rects(Ctx c, Prim p)
        {
            var v = Enumerable.Range(0, 4).Select(i => Vals(c, Pos(p, i))).ToArray();
            int n = v.Max(a => a.Length);
            foreach (var a in v) if (a.Length != 1 && a.Length != n) throw new FormatException("x, y, b, h de distinto largo");
            return Enumerable.Range(0, n).Select(i => (v[0][Math.Min(i, v[0].Length - 1)], v[1][Math.Min(i, v[1].Length - 1)],
                                                       v[2][Math.Min(i, v[2].Length - 1)], v[3][Math.Min(i, v[3].Length - 1)])).ToList();
        }

        static (List<double>, List<double>) XY(Ctx c, Prim p)
        {
            var pos = p.A.Where(a => a.Name == null && a.Str == null).ToList();
            if (pos.Count >= 2)
            {
                var v0 = Vals(c, pos[0]);
                if (v0.Length > 1) { var v1 = Vals(c, pos[1]); if (v1.Length != v0.Length) throw new FormatException("x e y de distinto largo"); return (v0.ToList(), v1.ToList()); }
            }
            var flat = pos.SelectMany(a => Vals(c, a)).ToList();
            if (flat.Count < 4 || flat.Count % 2 != 0) throw new FormatException("se esperan pares x, y");
            var xs = new List<double>(); var ys = new List<double>();
            for (int i = 0; i < flat.Count; i += 2) { xs.Add(flat[i]); ys.Add(flat[i + 1]); }
            return (xs, ys);
        }

        // ================= 2ª pasada: dibujar =================
        static string StyS(Prim p) => Named(p, "estilo")?.Str ?? p.A.FirstOrDefault(a => a.Name == null && a.Str != null)?.Str;

        static void Draw(Ctx c, Prim p, List<string> errs)
        {
            switch (p.Name)
            {
                case "linea":
                    Line(c, V(c, Pos(p, 0)), V(c, Pos(p, 1)), V(c, Pos(p, 2)), V(c, Pos(p, 3)), Style(StyS(p)));
                    break;
                case "polilinea": case "poligono":
                {
                    var (xs, ys) = XY(c, p);
                    Poly(c, xs, ys, p.Name == "poligono", Style(StyS(p)));
                    break;
                }
                case "rect":   // rect(x, y, b, h, estilo) — x, y, b, h pueden ser VECTORES (un rectángulo por componente)
                    foreach (var (x, y, b, h) in Rects(c, p))
                        Poly(c, new[] { x, x + b, x + b, x }, new[] { y, y, y + h, y + h }, true, Style(StyS(p)));
                    break;
                case "circulo":   // circulo(x, y, r, estilo) — x, y pueden ser VECTORES (un círculo por componente)
                {
                    var xs = Vals(c, Pos(p, 0)); var ys = Vals(c, Pos(p, 1)); double r = V(c, Pos(p, 2));
                    var st = Style(StyS(p));
                    for (int i = 0; i < Math.Max(xs.Length, ys.Length); i++)
                    {
                        double x = xs[Math.Min(i, xs.Length - 1)], y = ys[Math.Min(i, ys.Length - 1)];
                        c.Sb.Append("<circle cx=\"").Append(F(c.Px(x))).Append("\" cy=\"").Append(F(c.Py(y))).Append("\" r=\"").Append(F(r * c.K))
                         .Append("\" style=\"").Append(StrokeCss(st)).Append(';').Append(FillCss(st)).Append("\"/>");
                        c.Ext(c.Px(x - r), c.Py(y + r)); c.Ext(c.Px(x + r), c.Py(y - r));
                    }
                    break;
                }
                case "carga":   // carga(x1, y1, x2, y2, q1, q2, "texto", "estilo", n = 9, sentido = 1)
                    DrawCarga(c, p);
                    break;
                case "curva":   // curva(xa, xb, expr, "estilo", base = y0, n = 64, var = x)
                {
                    var (xs, ys) = Curva(c, p);
                    var st = Style(StyS(p) ?? "media");
                    var b = Named(p, "base");
                    // la curva se corta en los NaN (raíz de negativo…): cada tramo continuo por separado
                    var tramos = new List<(List<double> x, List<double> y)>();
                    var cx = new List<double>(); var cy = new List<double>();
                    for (int i = 0; i < xs.Length; i++)
                    {
                        if (double.IsNaN(ys[i]) || double.IsInfinity(ys[i])) { if (cx.Count > 1) tramos.Add((cx, cy)); cx = new List<double>(); cy = new List<double>(); continue; }
                        cx.Add(xs[i]); cy.Add(ys[i]);
                    }
                    if (cx.Count > 1) tramos.Add((cx, cy));
                    foreach (var (tx, ty) in tramos)
                    {
                        if (b != null && st.Fill)
                        {   // relleno contra la base, sin borde; el trazo de la curva va encima
                            double y0 = V(c, b);
                            var px = new List<double> { tx[0] }; px.AddRange(tx); px.Add(tx[tx.Count - 1]);
                            var py = new List<double> { y0 }; py.AddRange(ty); py.Add(y0);
                            Poly(c, px, py, true, new Sty { Col = st.Col, Fill = true, FillOp = st.FillOp, NoStroke = true });
                            Line(c, tx[0], y0, tx[0], ty[0], new Sty { Col = st.Col, W = 0.18 });
                            Line(c, tx[tx.Count - 1], y0, tx[tx.Count - 1], ty[ty.Count - 1], new Sty { Col = st.Col, W = 0.18 });
                        }
                        Poly(c, tx, ty, false, new Sty { Col = st.Col, W = st.W, Dash = st.Dash });
                    }
                    break;
                }
                case "empotramiento": case "empotre":   // empotramiento(x1, y1, x2, y2, lado)
                {
                    double x1 = V(c, Pos(p, 0)), y1 = V(c, Pos(p, 1)), x2 = V(c, Pos(p, 2)), y2 = V(c, Pos(p, 3));
                    double lado = NumArg(c, p, 4, 1) < 0 ? -1 : 1;
                    double a = c.Px(x1), b = c.Py(y1), d = c.Px(x2), e = c.Py(y2);
                    double L = Math.Sqrt((d - a) * (d - a) + (e - b) * (e - b)); if (L < 1e-9) break;
                    double ux = (d - a) / L, uy = (e - b) / L;
                    // normal IZQUIERDA de p1→p2: en papel (y hacia abajo) es (uy, −ux)
                    double nx = uy * lado, ny = -ux * lado;
                    const double paso = 1.5, largo = 2.2;
                    string css = "stroke:var(--fg);stroke-width:.2;stroke-linecap:round";
                    for (double s0 = paso * 0.5; s0 <= L + 1e-9; s0 += paso)
                    {
                        double sx = a + ux * s0, sy = b + uy * s0;
                        PLine(c, sx, sy, sx + (nx - ux) * largo * 0.7071, sy + (ny - uy) * largo * 0.7071, css);
                    }
                    PLine(c, a, b, d, e, "stroke:var(--fg);stroke-width:.6;stroke-linecap:round");
                    break;
                }
                case "arco":   // arco(xc, yc, r, a1, a2): de a1 a a2 grados, antihorario (y hacia arriba)
                {
                    double x = V(c, Pos(p, 0)), y = V(c, Pos(p, 1)), r = V(c, Pos(p, 2)), a1 = V(c, Pos(p, 3)), a2 = V(c, Pos(p, 4));
                    var st = Style(StyS(p));
                    double t1 = a1 * Math.PI / 180, t2 = a2 * Math.PI / 180;
                    double sweep = ((a2 - a1) % 360 + 360) % 360; if (sweep == 0 && a2 != a1) sweep = 360;
                    double sx = c.Px(x + r * Math.Cos(t1)), sy = c.Py(y + r * Math.Sin(t1)), ex = c.Px(x + r * Math.Cos(t2)), ey = c.Py(y + r * Math.Sin(t2));
                    c.Sb.Append("<path d=\"M").Append(F(sx)).Append(' ').Append(F(sy)).Append(" A").Append(F(r * c.K)).Append(' ').Append(F(r * c.K))
                     .Append(" 0 ").Append(sweep > 180 ? 1 : 0).Append(" 0 ").Append(F(ex)).Append(' ').Append(F(ey))
                     .Append("\" style=\"").Append(StrokeCss(st)).Append(";fill:none\"/>");
                    c.Ext(c.Px(x - r), c.Py(y + r)); c.Ext(c.Px(x + r), c.Py(y - r));
                    break;
                }
                case "flecha":   // flecha(x0, y0, x1, y1, estilo) — la PUNTA cae exactamente en (x1,y1)
                {
                    double x0 = V(c, Pos(p, 0)), y0 = V(c, Pos(p, 1)), x1 = V(c, Pos(p, 2)), y1 = V(c, Pos(p, 3));
                    var st = Style(StyS(p));
                    Punta(c, x0, y0, x1, y1, st, true);
                    break;
                }
                case "flechamomento":   // flechamomento(xc, yc, r, a1, a2, estilo): arco con la punta TANGENTE en a2
                {
                    double xc = V(c, Pos(p, 0)), yc = V(c, Pos(p, 1)), r = V(c, Pos(p, 2));
                    double a1 = V(c, Pos(p, 3)), a2 = V(c, Pos(p, 4));
                    var st = Style(StyS(p));
                    // el arco se traza por puntos para poder derivar la tangente en el extremo;
                    // con <path A> no se sabe con qué pendiente termina y la punta sale torcida
                    int n = 96;
                    var xs = new double[n]; var ys = new double[n];
                    for (int i = 0; i < n; i++)
                    {
                        double t = (a1 + (a2 - a1) * i / (n - 1.0)) * Math.PI / 180;
                        xs[i] = xc + r * Math.Cos(t); ys[i] = yc + r * Math.Sin(t);
                    }
                    // se corta antes del final: ahí empieza la punta
                    double lg = PuntaLargo(c);
                    int corte = n - 1;
                    while (corte > 1 && Math.Sqrt(Math.Pow(xs[corte] - xs[n - 1], 2) + Math.Pow(ys[corte] - ys[n - 1], 2)) < lg) corte--;
                    Poly(c, xs.Take(corte + 1).ToArray(), ys.Take(corte + 1).ToArray(), false, st);
                    Punta(c, xs[corte], ys[corte], xs[n - 1], ys[n - 1], st, false);
                    break;
                }
                case "texto":   // texto(x, y, "texto", tamaño_mm, ancla "i|c|d", ángulo) — x, y pueden ser vectores
                {
                    var xs = Vals(c, Pos(p, 0)); var ys = Vals(c, Pos(p, 1));
                    var ta = Pos(p, 2);
                    var txts = ta?.Strs ?? new List<string> { ta?.Str ?? ta?.Raw ?? "" };
                    double size = NumArg(c, p, 3, 2.5);
                    string an = (StrArg(p, 4, "c") ?? "c").ToLowerInvariant();
                    string anchor = an.StartsWith("i") || an.StartsWith("l") ? "start" : an.StartsWith("d") || an.StartsWith("r") ? "end" : "middle";
                    double ang = NumArg(c, p, 5, 0);
                    int n = Math.Max(xs.Length, Math.Max(ys.Length, txts.Count));
                    string col = Style(Named(p, "estilo")?.Str ?? "").Col;
                    for (int i = 0; i < n; i++)
                        Text(c, c.Px(xs[Math.Min(i, xs.Length - 1)]), c.Py(ys[Math.Min(i, ys.Length - 1)]),
                             Interp(c, txts[Math.Min(i, txts.Count - 1)]), size, anchor, -ang, col);
                    break;
                }
                case "hueco":   // abertura en planta: contorno + cruz (convención de planos); admite vectores
                foreach (var (x, y, b, h) in Rects(c, p))
                {
                    Poly(c, new[] { x, x + b, x + b, x }, new[] { y, y, y + h, y + h }, true, Style("media"), "fill:var(--bg)");
                    var th = Style("fina gris");
                    Line(c, x, y, x + b, y + h, th); Line(c, x, y + h, x + b, y, th);
                    string t = StrArg(p, 4, null);
                    if (!string.IsNullOrEmpty(t)) Text(c, c.Px(x + b / 2), c.Py(y + h / 2) - 2.2, Interp(c, t), 2.2, "middle", 0, "var(--mut)");
                }
                break;
                case "achurado":   // achurado(x, y, b, h, "diagonal|cruzado|concreto") o achurado(xv, yv, "tipo")
                {
                    string tipo = (p.A.LastOrDefault(a => a.Name == null && a.Str != null)?.Str ?? "diagonal").ToLowerInvariant();
                    string pat = tipo.StartsWith("cruz") ? "cruz" : tipo.StartsWith("conc") ? "conc" : "diag";
                    string fill = "fill:url(#" + c.Id + "-" + pat + ")";
                    var st = Style(tipo.Contains("borde") ? "media" : "sinborde");
                    var v0 = Vals(c, Pos(p, 0));
                    if (v0.Length > 1) { var (xs, ys) = XY(c, p); Poly(c, xs, ys, true, st, fill); }
                    else
                    {
                        double x = v0[0], y = V(c, Pos(p, 1)), b = V(c, Pos(p, 2)), h = V(c, Pos(p, 3));
                        Poly(c, new[] { x, x + b, x + b, x }, new[] { y, y, y + h, y + h }, true, st, fill);
                    }
                    break;
                }
                case "seccion":   // sección de concreto: contorno grueso + achurado de concreto
                {
                    double x = V(c, Pos(p, 0)), y = V(c, Pos(p, 1)), b = V(c, Pos(p, 2)), h = V(c, Pos(p, 3));
                    Poly(c, new[] { x, x + b, x + b, x }, new[] { y, y, y + h, y + h }, true, Style("gruesa"), "fill:url(#" + c.Id + "-conc)");
                    break;
                }
                case "cota":   // cota(x1, y1, x2, y2, d, "texto")
                    DrawCota(c, V(c, Pos(p, 0)), V(c, Pos(p, 1)), V(c, Pos(p, 2)), V(c, Pos(p, 3)), NumArg(c, p, 4, 0),
                             Pos(p, 5)?.Str != null ? Interp(c, Pos(p, 5).Str) : null);
                    break;
                case "cotas": case "cotasx":   // cadena de cotas horizontales: cotas(xv, y, d)
                {
                    var xs = Vals(c, Pos(p, 0)); double y = V(c, Pos(p, 1)), d = NumArg(c, p, 2, 0);
                    for (int i = 0; i + 1 < xs.Length; i++) DrawCota(c, xs[i], y, xs[i + 1], y, d, null);
                    break;
                }
                case "cotasy":   // cadena vertical: cotasy(yv, x, d)  (d > 0 = a la izquierda)
                {
                    var ys = Vals(c, Pos(p, 0)); double x = V(c, Pos(p, 1)), d = NumArg(c, p, 2, 0);
                    for (int i = 0; i + 1 < ys.Length; i++) DrawCota(c, x, ys[i], x, ys[i + 1], d, null);
                    break;
                }
                case "ejex": case "ejesx":
                {
                    var xs = Vals(c, Pos(p, 0)); var lb = Labels(p, 1, xs.Length);
                    double yt = c.Py(c.GyMax) - 4, yb = c.Py(c.GyMin) + 4, R = 3.1;
                    for (int i = 0; i < xs.Length; i++)
                    {
                        double px = c.Px(xs[i]);
                        PLine(c, px, yt, px, yb, StrokeCss(Style("eje")));
                        Bubble(c, px, yt - R, R, i < lb.Count ? lb[i] : "?");
                    }
                    break;
                }
                case "ejey": case "ejesy":
                {
                    var ys = Vals(c, Pos(p, 0)); var lb = Labels(p, 1, ys.Length);
                    double xl = c.Px(c.GxMin) - 4, xr = c.Px(c.GxMax) + 4, R = 3.1;
                    for (int i = 0; i < ys.Length; i++)
                    {
                        double py = c.Py(ys[i]);
                        PLine(c, xl, py, xr, py, StrokeCss(Style("eje")));
                        Bubble(c, xl - R, py, R, i < lb.Count ? lb[i] : "?");
                    }
                    break;
                }
                case "varilla":   // varilla(x1, y1, x2, y2, Ø_mm, gancho1, gancho2, "rótulo", lado)
                {
                    double x1 = V(c, Pos(p, 0)), y1 = V(c, Pos(p, 1)), x2 = V(c, Pos(p, 2)), y2 = V(c, Pos(p, 3));
                    double dmm = NumArg(c, p, 4, 12), g1 = NumArg(c, p, 5, 0), g2 = NumArg(c, p, 6, 0);
                    string rot = Pos(p, 7)?.Str; double lado = NumArg(c, p, 8, 1);
                    DrawBar(c, x1, y1, x2, y2, dmm, g1, g2, Named(p, "estilo")?.Str);
                    if (!string.IsNullOrEmpty(rot)) BarText(c, x1, y1, x2, y2, Interp(c, rot), lado, NumNamed(c, p, "off", 0));
                    break;
                }
                case "varillas":   // varillas(x1, y1, x2, y2, n, Ø_mm, s_cm, gancho1, gancho2, lado) → «n Ø d mm @ s cm»
                {
                    double x1 = V(c, Pos(p, 0)), y1 = V(c, Pos(p, 1)), x2 = V(c, Pos(p, 2)), y2 = V(c, Pos(p, 3));
                    double n = V(c, Pos(p, 4)), dmm = V(c, Pos(p, 5)), s = NumArg(c, p, 6, double.NaN);
                    double g1 = NumArg(c, p, 7, 0), g2 = NumArg(c, p, 8, 0);
                    double lado = NumArg(c, p, 9, Math.Sign(g1 + g2) != 0 ? -Math.Sign(g1 + g2) : 1);
                    DrawBar(c, x1, y1, x2, y2, dmm, g1, g2, Named(p, "estilo")?.Str);
                    BarText(c, x1, y1, x2, y2, BarLabel(n, dmm, s), lado, NumNamed(c, p, "off", 0));
                    break;
                }
                case "fila":   // fila(x1, y1, x2, y2, n, Ø_mm, s_cm, lado): varillas vistas en CORTE (puntos)
                {
                    double x1 = V(c, Pos(p, 0)), y1 = V(c, Pos(p, 1)), x2 = V(c, Pos(p, 2)), y2 = V(c, Pos(p, 3));
                    int n = (int)Math.Round(V(c, Pos(p, 4))); double dmm = V(c, Pos(p, 5)), s = NumArg(c, p, 6, double.NaN), lado = NumArg(c, p, 7, 1);
                    double r = Math.Max(MmToUd(c, dmm) / 2 * c.K, 0.45);
                    string col = Style(Named(p, "estilo")?.Str ?? "acero").Col;
                    for (int i = 0; i < n; i++)
                    {
                        double t = n == 1 ? 0.5 : (double)i / (n - 1);
                        double px = c.Px(x1 + (x2 - x1) * t), py = c.Py(y1 + (y2 - y1) * t);
                        c.Sb.Append("<circle cx=\"").Append(F(px)).Append("\" cy=\"").Append(F(py)).Append("\" r=\"").Append(F(r))
                         .Append("\" style=\"fill:").Append(col).Append(";stroke:none\"/>");
                        c.Ext(px - r, py - r); c.Ext(px + r, py + r);
                    }
                    if (Named(p, "rotulo")?.Str != "no")
                        BarText(c, x1, y1, x2, y2, BarLabel(n, dmm, s), lado, r + 0.6 + NumNamed(c, p, "off", 0));
                    break;
                }
                case "estribo":   // estribo(x, y, b, h, rec, Ø_mm): estribo cerrado con ganchos a 135°
                {
                    double x = V(c, Pos(p, 0)), y = V(c, Pos(p, 1)), b = V(c, Pos(p, 2)), h = V(c, Pos(p, 3));
                    double rec = V(c, Pos(p, 4)), dmm = NumArg(c, p, 5, 10);
                    double db = MmToUd(c, dmm), e = rec + db / 2, rr = 2 * db, L = Math.Max(6 * db, MmToUd(c, 75));
                    double ax = c.Px(x + e), ay = c.Py(y + h - e), bx = c.Px(x + b - e), by = c.Py(y + e);
                    string css = "stroke:var(--dib-acero);stroke-width:" + F(Math.Max(0.35, db * c.K)) + ";fill:none;stroke-linejoin:round;stroke-linecap:round";
                    c.Sb.Append("<rect x=\"").Append(F(ax)).Append("\" y=\"").Append(F(ay)).Append("\" width=\"").Append(F(bx - ax)).Append("\" height=\"").Append(F(by - ay))
                     .Append("\" rx=\"").Append(F(rr * c.K)).Append("\" style=\"").Append(css).Append("\"/>");
                    c.Ext(ax, ay); c.Ext(bx, by);
                    // dos ganchos a 135° en la esquina superior izquierda, hacia adentro (45° hacia abajo-derecha)
                    double k45 = Math.Sqrt(0.5) * L * c.K;
                    double hx1 = ax + rr * c.K, hy1 = ay, hx2 = ax, hy2 = ay + rr * c.K;
                    PLine(c, hx1, hy1, hx1 + k45, hy1 + k45, css); PLine(c, hx2, hy2, hx2 + k45, hy2 + k45, css);
                    if (Named(p, "rotulo")?.Str != "no")
                        Text(c, c.Px(x + b) + 2, (ay + by) / 2, "E Ø " + Num(dmm) + " mm", 2.2, "start", 0, "var(--dib-acero)");
                    break;
                }
            }
        }

        // normal IZQUIERDA (mundo, y hacia arriba) del segmento p1→p2, unitaria
        static (double, double) NormalIzq(double x1, double y1, double x2, double y2)
        {
            double L = Math.Sqrt((x2 - x1) * (x2 - x1) + (y2 - y1) * (y2 - y1));
            if (L < 1e-12) return (0, 1);
            return (-(y2 - y1) / L, (x2 - x1) / L);
        }

        // muestras de curva(xa, xb, expr, …): la variable (x por defecto) es un VECTOR y el
        // evaluador numérico ya opera componente a componente (sqrt, ^, max…)
        static (double[], double[]) Curva(Ctx c, Prim p)
        {
            double xa = V(c, Pos(p, 0)), xb = V(c, Pos(p, 1));
            var ea = Pos(p, 2); if (ea == null || ea.Str != null) throw new FormatException("curva: falta la expresión (sin comillas)");
            int n = (int)Math.Round(NumNamed(c, p, "n", 64)); n = Math.Max(2, Math.Min(n, 2000));
            string var = (Named(p, "var")?.Str ?? Named(p, "var")?.Raw ?? "x").Trim();
            var xs = new double[n + 1];
            for (int i = 0; i <= n; i++) xs[i] = xa + (xb - xa) * i / n;
            LispConverter.N tree;
            try { tree = LispConverter.ParseMath(LispConverter.MangleExpr(ea.Raw)); }
            catch { throw new FormatException("no se puede leer «" + ea.Raw + "»"); }
            string mv = LispConverter.MangleExpr(var).Trim();
            var ys = Eval(tree, nm => nm == var || nm == mv ? xs : c.Look?.Invoke(nm));
            if (ys.Length == 1) ys = Enumerable.Repeat(ys[0], n + 1).ToArray();   // constante
            return (xs, ys);
        }

        // bloque de carga repartida (trapecio) con flechas hacia la cara cargada
        static void DrawCarga(Ctx c, Prim p)
        {
            double x1 = V(c, Pos(p, 0)), y1 = V(c, Pos(p, 1)), x2 = V(c, Pos(p, 2)), y2 = V(c, Pos(p, 3));
            double q1 = V(c, Pos(p, 4)), q2 = NumArg(c, p, 5, q1);
            var strs = p.A.Where(a => a.Name == null && a.Str != null).Select(a => a.Str).ToList();
            string txt = strs.Count > 0 ? strs[0] : null;
            string sty = Named(p, "estilo")?.Str ?? (strs.Count > 1 ? strs[1] : "rojo");
            var st = Style(sty);
            if (st.Col == "var(--fg)") st.Col = "var(--dib-rojo)";
            int n = (int)Math.Round(NumNamed(c, p, "n", 9)); n = Math.Max(2, Math.Min(n, 60));
            double sentido = NumNamed(c, p, "sentido", 1) < 0 ? -1 : 1;
            var (nx, ny) = NormalIzq(x1, y1, x2, y2);
            double ox1 = x1 + nx * q1, oy1 = y1 + ny * q1, ox2 = x2 + nx * q2, oy2 = y2 + ny * q2;
            // el bloque: relleno translúcido + borde exterior
            Poly(c, new[] { x1, x2, ox2, ox1 }, new[] { y1, y2, oy2, oy1 }, true,
                 new Sty { Col = st.Col, Fill = true, FillOp = st.Fill ? st.FillOp : 0.14, NoStroke = true });
            var borde = new Sty { Col = st.Col, W = Math.Max(0.3, st.W) };
            Line(c, ox1, oy1, ox2, oy2, borde);
            if (Math.Abs(q1) > 1e-12) Line(c, x1, y1, ox1, oy1, new Sty { Col = st.Col, W = 0.18 });
            if (Math.Abs(q2) > 1e-12) Line(c, x2, y2, ox2, oy2, new Sty { Col = st.Col, W = 0.18 });
            // flechas: de la orilla del bloque a la cara (o al revés con sentido = -1)
            var fl = new Sty { Col = st.Col, W = 0.3 };
            double minQ = PuntaLargo(c) * 1.2;
            for (int i = 0; i < n; i++)
            {
                double t = (double)i / (n - 1);
                double bx = x1 + (x2 - x1) * t, by = y1 + (y2 - y1) * t;
                double q = q1 + (q2 - q1) * t;
                if (Math.Abs(q) < minQ) continue;                 // tan bajo que no cabe la punta
                double ex = bx + nx * q, ey = by + ny * q;
                if (sentido > 0) Punta(c, ex, ey, bx, by, fl, true); else Punta(c, bx, by, ex, ey, fl, true);
            }
            if (!string.IsNullOrEmpty(txt))
            {   // rótulo por fuera del bloque, en el centro de la orilla, paralelo a la cara
                double mx = (ox1 + ox2) / 2, my = (oy1 + oy2) / 2;
                double qm = (q1 + q2) / 2, sg = qm >= 0 ? 1 : -1;
                double pxm = c.Px(mx) + nx * sg * 2.6, pym = c.Py(my) - ny * sg * 2.6;
                double ang = Math.Atan2(-(y2 - y1), x2 - x1) * 180 / Math.PI;
                if (ang > 90) ang -= 180; else if (ang < -90) ang += 180;
                Text(c, pxm, pym, Interp(c, txt), 2.5, "middle", ang, st.Col);
            }
        }

        static void Bubble(Ctx c, double cx, double cy, double R, string lab)
        {
            c.Sb.Append("<circle cx=\"").Append(F(cx)).Append("\" cy=\"").Append(F(cy)).Append("\" r=\"").Append(F(R))
             .Append("\" style=\"fill:var(--bg);stroke:var(--fg);stroke-width:.25\"/>");
            c.Ext(cx - R, cy - R); c.Ext(cx + R, cy + R);
            Text(c, cx, cy + 0.1, lab, lab.Length > 2 ? 2.4 : 3.0, "middle", 0, "var(--fg)", "600");
        }

        // cota con flechas: línea desplazada d (mundo) a la IZQUIERDA de p1→p2, valor automático
        static void DrawCota(Ctx c, double x1, double y1, double x2, double y2, double d, string txt)
        {
            double L = Math.Sqrt((x2 - x1) * (x2 - x1) + (y2 - y1) * (y2 - y1)); if (L < 1e-12) return;
            double uxw = (x2 - x1) / L, uyw = (y2 - y1) / L, nxw = -uyw, nyw = uxw;
            double qx1 = x1 + nxw * d, qy1 = y1 + nyw * d, qx2 = x2 + nxw * d, qy2 = y2 + nyw * d;
            double P1x = c.Px(x1), P1y = c.Py(y1), P2x = c.Px(x2), P2y = c.Py(y2);
            double Q1x = c.Px(qx1), Q1y = c.Py(qy1), Q2x = c.Px(qx2), Q2y = c.Py(qy2);
            double sg = d >= 0 ? 1 : -1;
            double npx = nxw * sg, npy = -nyw * sg;            // normal en PAPEL, hacia el lado de la cota
            double upx = uxw, upy = -uyw;                      // dirección en PAPEL
            string thin = "stroke:var(--fg);stroke-width:.18";
            if (Math.Abs(d) > 1e-12)
            {
                PLine(c, P1x + npx * 0.8, P1y + npy * 0.8, Q1x + npx * 1.2, Q1y + npy * 1.2, thin);
                PLine(c, P2x + npx * 0.8, P2y + npy * 0.8, Q2x + npx * 1.2, Q2y + npy * 1.2, thin);
            }
            PLine(c, Q1x, Q1y, Q2x, Q2y, thin);
            double Lp = L * c.K;
            if (Lp >= 5.5) { Arrow(c, Q1x, Q1y, -upx, -upy, 1.8, 0.55); Arrow(c, Q2x, Q2y, upx, upy, 1.8, 0.55); }
            else
            {   // cota corta: trazos a 45° (como en arquitectura) en vez de flechas
                double tx = (upx - npx) * 0.9, ty = (upy - npy) * 0.9;
                PLine(c, Q1x - tx, Q1y - ty, Q1x + tx, Q1y + ty, "stroke:var(--fg);stroke-width:.3");
                PLine(c, Q2x - tx, Q2y - ty, Q2x + tx, Q2y + ty, "stroke:var(--fg);stroke-width:.3");
            }
            double udc = c.UdCota == "mm" ? 1 : c.UdCota == "cm" ? 10 : 1000;
            double val = L * c.UdMm / udc;
            int dec = c.Dec >= 0 ? c.Dec : (c.UdCota == "m" ? (Math.Abs(val * 100 - Math.Round(val * 100)) > 1e-6 ? 3 : 2)
                                     : c.UdCota == "cm" ? (Math.Abs(val - Math.Round(val)) < 1e-6 ? 0 : 1) : 0);
            string t = txt ?? val.ToString("F" + dec, Inv);
            double ang = Math.Atan2(upy, upx) * 180 / Math.PI;
            if (ang > 90) ang -= 180; else if (ang < -90) ang += 180;
            double mx = (Q1x + Q2x) / 2 + npx * 1.7, my = (Q1y + Q2y) / 2 + npy * 1.7;
            if (Lp < 5.5) { mx += npx * 0.6; my += npy * 0.6; }
            Text(c, mx, my, t, 2.3, "middle", ang);
        }

        // varilla longitudinal con ganchos (0, 90, 135, 180°; signo = lado: + a la izquierda de p1→p2)
        static void DrawBar(Ctx c, double x1, double y1, double x2, double y2, double dmm, double g1, double g2, string sty)
        {
            double L = Math.Sqrt((x2 - x1) * (x2 - x1) + (y2 - y1) * (y2 - y1)); if (L < 1e-12) return;
            double ux = (x2 - x1) / L, uy = (y2 - y1) / L, db = MmToUd(c, dmm);
            (double, double) Rot(double vx, double vy, double deg) { double t = deg * Math.PI / 180; return (vx * Math.Cos(t) - vy * Math.Sin(t), vx * Math.Sin(t) + vy * Math.Cos(t)); }
            string Hook(double px, double py, double ox, double oy, double g, bool atStart)
            {
                double ga = Math.Abs(g); int s = Math.Sign(g); if (ga < 1) return "";
                if (ga >= 179)   // 180°: media vuelta (diámetro 6Ø) y prolongación de 4Ø (≥ 65 mm)
                {
                    double D = 6 * db, ext = Math.Max(4 * db, MmToUd(c, 65));
                    var (nx, ny) = Rot(ox, oy, atStart ? -90 * s : 90 * s);
                    double ex = px + nx * D, ey = py + ny * D;
                    double fx = ex - ox * ext, fy = ey - oy * ext;
                    // giro en MUNDO: antihorario si (fin: s>0) o (inicio: s<0); en papel (y abajo) eso es sweep=0
                    int sweep = ((atStart ? -s : s) > 0) ? 0 : 1;
                    return " M" + F(c.Px(px)) + " " + F(c.Py(py)) + " A" + F(D / 2 * c.K) + " " + F(D / 2 * c.K) + " 0 0 " + sweep + " " + F(c.Px(ex)) + " " + F(c.Py(ey)) +
                           " L" + F(c.Px(fx)) + " " + F(c.Py(fy));
                }
                double len = ga >= 134 ? Math.Max(6 * db, MmToUd(c, 75)) : 12 * db;   // 135°: 6Ø (≥75 mm) · 90°: 12Ø
                var (dx, dy) = Rot(ox, oy, atStart ? -ga * s : ga * s);
                return " M" + F(c.Px(px)) + " " + F(c.Py(py)) + " L" + F(c.Px(px + dx * len)) + " " + F(c.Py(py + dy * len));
            }
            var st = Style("acero");
            if (!string.IsNullOrEmpty(sty)) { var s2 = Style(sty); if (s2.Col != "var(--fg)") st.Col = s2.Col; if (s2.Dash != null) st.Dash = s2.Dash; }
            string d = "M" + F(c.Px(x1)) + " " + F(c.Py(y1)) + " L" + F(c.Px(x2)) + " " + F(c.Py(y2))
                     + Hook(x1, y1, -ux, -uy, g1, true) + Hook(x2, y2, ux, uy, g2, false);
            c.Sb.Append("<path d=\"").Append(d).Append("\" style=\"").Append(StrokeCss(st)).Append(";fill:none\"/>");
            double hk = Math.Max(Math.Abs(g1), Math.Abs(g2)) > 0 ? 12 * db * c.K : 0;
            c.Ext(Math.Min(c.Px(x1), c.Px(x2)) - hk, Math.Min(c.Py(y1), c.Py(y2)) - hk);
            c.Ext(Math.Max(c.Px(x1), c.Px(x2)) + hk, Math.Max(c.Py(y1), c.Py(y2)) + hk);
        }

        // rótulo a lo largo de una varilla (o fila), del lado 'lado' (+1 izquierda de p1→p2)
        static void BarText(Ctx c, double x1, double y1, double x2, double y2, string txt, double lado, double extraMm = 0)
        {
            double L = Math.Sqrt((x2 - x1) * (x2 - x1) + (y2 - y1) * (y2 - y1));
            double ux = L > 1e-12 ? (x2 - x1) / L : 1, uy = L > 1e-12 ? (y2 - y1) / L : 0;
            int sg = lado < 0 ? -1 : 1;
            double npx = -uy * sg, npy = -ux * sg;             // normal izquierda en PAPEL (y hacia abajo)
            double off = 1.9 + extraMm;
            double mx = (c.Px(x1) + c.Px(x2)) / 2 + npx * off, my = (c.Py(y1) + c.Py(y2)) / 2 + npy * off;
            double ang = Math.Atan2(-uy, ux) * 180 / Math.PI;
            if (ang > 90) ang -= 180; else if (ang < -90) ang += 180;
            Text(c, mx, my, txt, 2.3, "middle", ang, "var(--dib-acero)");
        }

        // marcador de OBSERVACIÓN: círculo con número, color por estado (y línea guía si dx/dy)
        static void DrawObs(Ctx c, Obs o)
        {
            bool multi = o.X.Length > 1;
            double R = multi ? 2.0 : 2.7, fs = multi ? 2.4 : 3.0;
            string col = ObsCol(o.Estado);
            for (int i = 0; i < o.X.Length; i++)
            {
                double px = c.Px(o.X[i]), py = c.Py(o.Y[i]);
                double bx = px, by = py;
                if (!double.IsNaN(o.Dx) || !double.IsNaN(o.Dy))
                {
                    bx = px + (double.IsNaN(o.Dx) ? 0 : o.Dx); by = py - (double.IsNaN(o.Dy) ? 0 : o.Dy);
                    PLine(c, px, py, bx, by, "stroke:" + col + ";stroke-width:.3");
                    c.Sb.Append("<circle cx=\"").Append(F(px)).Append("\" cy=\"").Append(F(py)).Append("\" r=\".6\" style=\"fill:").Append(col).Append("\"/>");
                }
                c.Sb.Append("<circle cx=\"").Append(F(bx)).Append("\" cy=\"").Append(F(by)).Append("\" r=\"").Append(F(R))
                 .Append("\" style=\"fill:").Append(col).Append(";stroke:var(--bg);stroke-width:.35\"/>");
                c.Ext(bx - R, by - R); c.Ext(bx + R, by + R);
                c.Sb.Append("<text x=\"").Append(F(bx)).Append("\" y=\"").Append(F(by + 0.1)).Append("\" font-size=\"").Append(F(fs))
                 .Append("\" text-anchor=\"middle\" dominant-baseline=\"middle\" style=\"fill:#fff;font-weight:700;font-family:'Segoe UI',Arial,sans-serif\">")
                 .Append(o.N).Append("</text>");
            }
        }

        static string ObsTable(Ctx c, List<Obs> list)
        {
            var sb = new StringBuilder();
            sb.Append("<div class=\"ws-tbl-wrap\"><table class=\"ws-table hk-obs\"><thead><tr>")
              .Append("<th class=\"ws-c-center\">N°</th><th class=\"ws-c-txt\">Estado</th><th class=\"ws-c-txt\">Observación</th><th class=\"ws-c-txt\">Ubicación [")
              .Append(c.Ud).Append("]</th></tr></thead><tbody>");
            foreach (var o in list.OrderBy(q => q.N))
            {
                string col = ObsCol(o.Estado);
                string ub = o.X.Length == 1 ? "(" + Num(o.X[0], 3) + "; " + Num(o.Y[0], 3) + ")" : o.X.Length + " puntos (marcados en el dibujo)";
                sb.Append("<tr><td class=\"ws-c-center\"><span class=\"hk-obs-n\" style=\"background:").Append(col).Append("\">").Append(o.N).Append("</span></td>")
                  .Append("<td class=\"ws-c-txt\"><span class=\"hk-obs-e\" style=\"color:").Append(col).Append("\">").Append(o.Estado).Append("</span></td>")
                  .Append("<td class=\"ws-c-txt\">").Append(LispConverter.FormatInlineText(o.Texto, _ => null)).Append("</td>")
                  .Append("<td class=\"ws-c-txt\">").Append(ub).Append("</td></tr>");
            }
            sb.Append("</tbody></table></div>");
            return sb.ToString();
        }

        // muestra de leyenda (SVG en línea, 30×12 px)
        static string Swatch(string sty, string id)
        {
            var s = (sty ?? "").ToLowerInvariant();
            string head = "<svg width=\"30\" height=\"12\" viewBox=\"0 0 30 12\" style=\"vertical-align:middle\">";
            if (s.Contains("pendiente") || s.Contains("corregida") || s.Contains("info"))
            {
                string col = ObsCol(ObsEstado(s.Contains("pendiente") ? "pendiente" : s.Contains("corregida") ? "corregida" : "info"));
                return head + "<circle cx=\"15\" cy=\"6\" r=\"5\" style=\"fill:" + col + "\"/></svg>";
            }
            if (s.Contains("hueco"))
                return head + "<rect x=\"3\" y=\"1\" width=\"24\" height=\"10\" style=\"fill:none;stroke:var(--fg);stroke-width:1\"/><line x1=\"3\" y1=\"1\" x2=\"27\" y2=\"11\" style=\"stroke:var(--mut);stroke-width:.7\"/><line x1=\"3\" y1=\"11\" x2=\"27\" y2=\"1\" style=\"stroke:var(--mut);stroke-width:.7\"/></svg>";
            if (s.Contains("achurado") || s.Contains("seccion") || s.Contains("concreto"))
                return head + "<rect x=\"3\" y=\"1\" width=\"24\" height=\"10\" style=\"fill:url(#" + id + "-" + (s.Contains("conc") || s.Contains("seccion") ? "conc" : "diag") + ");stroke:var(--fg);stroke-width:.6\"/></svg>";
            if (s.Contains("fila") || s.Contains("punto"))
                return head + "<circle cx=\"8\" cy=\"6\" r=\"2.4\" style=\"fill:var(--dib-acero)\"/><circle cx=\"15\" cy=\"6\" r=\"2.4\" style=\"fill:var(--dib-acero)\"/><circle cx=\"22\" cy=\"6\" r=\"2.4\" style=\"fill:var(--dib-acero)\"/></svg>";
            var st = Style(s);
            if (s.Contains("resalte"))
                return head + "<rect x=\"2\" y=\"1\" width=\"26\" height=\"10\" style=\"fill:" + st.Col + ";fill-opacity:" + F(st.FillOp * 1.6) + "\"/></svg>";
            double w = st.W * 3.2;
            string dash = st.Dash != null ? ";stroke-dasharray:" + string.Join(" ", st.Dash.Split(' ').Select(t => F(double.Parse(t, Inv) * 2.2))) : "";
            return head + "<line x1=\"2\" y1=\"6\" x2=\"28\" y2=\"6\" style=\"stroke:" + st.Col + ";stroke-width:" + F(w) + dash + ";stroke-linecap:round\"/></svg>";
        }
    }
}
