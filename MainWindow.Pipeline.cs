using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Text;

namespace HekatanLisp
{
    /// <summary>
    /// PIPELINE del resultado (sin WPF): texto de la hoja → motor LISP → líneas de salida.
    /// Lo comparten la app de escritorio (MainWindow.xaml.cs) y la web (web/HekatanLispWeb):
    /// el MISMO código, así la web dibuja idéntico al escritorio.
    /// </summary>
    public partial class MainWindow
    {
        // Arranca en SIMPLIFY, no en «tal cual» (Jorge, 16-sep-2026: escribió `x+x`, vio
        // `x + x` y dio por roto el programa — dos veces). Quien teclea una suma espera el
        // resultado, como en Mathcad o Symbolab; «tal cual» sigue a un clic, para cuando lo
        // que quieres es la fórmula escrita bonita SIN que te la reescriban.
        private string _op = "simplify";           // operación: "auto" | "simplify" | "expand" | "deriv"
        private string _srcPrepared;   // la hoja con los nombres preparados (griegas, choques de case): la usan las gráficas
        private bool _ranProgram = false;          // el último resultado vino de EJECUTAR un programa (stdout de consola)

        /// <summary>Vista "expr LISP": una línea de salida (que puede venir como "name = forma" o
        /// "name = operación = resultado") a LISP VÁLIDO:  (setf name forma).  Una expresión suelta
        /// se deja tal cual (ya es una forma LISP). El texto (#) se pasa como comentario ";".</summary>
        private static string ToLispView(string f)
        {
            if (string.IsNullOrEmpty(f)) return null;
            if (f.StartsWith(LispConverter.TxtMark, StringComparison.Ordinal))   // línea de texto (#): comentario LISP (ordinal: la cultura ignora el \x01)
            {
                var pz = f.Split(LispConverter.TxtSep);
                var html = pz.Length > 4 ? string.Join("", pz.Skip(4)) : "";
                var plain = System.Text.RegularExpressions.Regex.Replace(html, @"<[^>]+>", "").Trim();
                return plain.Length > 0 ? "; " + System.Net.WebUtility.HtmlDecode(plain) : null;
            }
            var parts = System.Text.RegularExpressions.Regex.Split(f, @"\s=\s");
            if (parts.Length >= 2 && System.Text.RegularExpressions.Regex.IsMatch(parts[0].Trim(), @"^[A-Za-z]\w*$"))
                return "(setf " + parts[0].Trim() + " " + parts[1].Trim() + ")";   // definición → (setf …)
            return parts[0].Trim();   // expresión suelta: ya es una forma LISP
        }

        // ;grafica en COMENTARIO (LISP lo ignora, la app lo dibuja): ";grafica s -1 1 [N1 N2 …]".
        // Toma las funciones YA deducidas (etiquetas NAME = … = RESULTADO de la salida) y las grafica.
        // línea de comentario que empieza el comando de gráfica; el resto se parsea a mano
        private static readonly System.Text.RegularExpressions.Regex RxGraf = new System.Text.RegularExpressions.Regex(
            @"^\s*[;#]+\s*(fplot|plot|ezplot|graficas?|grafico)\b(.*)$",
            System.Text.RegularExpressions.RegexOptions.IgnoreCase | System.Text.RegularExpressions.RegexOptions.Multiline);

        // separa por comas de PRIMER nivel (respeta [ ] y ( ))
        private static List<string> SplitTop(string s)
        {
            var res = new List<string>(); int depth = 0; var cur = new StringBuilder();
            foreach (char c in s)
            {
                if (c == '[' || c == '(') depth++;
                else if (c == ']' || c == ')') depth--;
                if (c == ',' && depth == 0) { res.Add(cur.ToString()); cur.Clear(); }
                else cur.Append(c);
            }
            if (cur.ToString().Trim().Length > 0) res.Add(cur.ToString());
            return res;
        }

        // Varias asignaciones en UNA línea de matemática, estilo MATLAB:  a = 2; b = 3  →  dos líneas.
        // El ';' separa SOLO a nivel 0 (no dentro de [ ] { } ( ), donde ';' es separador de fila de matriz).
        // No toca líneas de texto (#), LISP/comentario (;) ni MATLAB (%).
        private static string[] ExpandMathSemicolons(string[] lines)
            => ExpandMathSemicolons(lines, out _);

        // 'cont[k]' = true si la línea de salida k es CONTINUACIÓN (2ª parte en adelante) de una línea con ';'
        // → se dibuja en la MISMA fila que la anterior (lado a lado, estilo Hekatan Lab).
        private static string[] ExpandMathSemicolons(string[] lines, out List<bool> cont)
        {
            var res = new List<string>(); cont = new List<bool>();
            foreach (var raw in lines)
            {
                var t = raw.TrimStart();
                if (t.StartsWith("#") || t.StartsWith(";") || t.StartsWith("%") || raw.IndexOf(';') < 0)
                { res.Add(raw); cont.Add(false); continue; }
                int depth = 0; var cur = new StringBuilder(); var parts = new List<string>();
                foreach (char c in raw)
                {
                    if (c == '[' || c == '(' || c == '{') depth++;
                    else if (c == ']' || c == ')' || c == '}') depth--;
                    if (c == ';' && depth == 0) { parts.Add(cur.ToString()); cur.Clear(); }
                    else cur.Append(c);
                }
                parts.Add(cur.ToString());
                bool first = true;
                foreach (var p in parts) if (p.Trim().Length > 0) { res.Add(p.Trim()); cont.Add(!first); first = false; }
                if (first) { res.Add(raw); cont.Add(false); }   // no hubo ninguna parte no vacía
            }
            return res.ToArray();
        }

        // Reemplaza SOLO la primera aparición (para rellenar los huecos de gráfica en orden).
        private static string ReplaceFirst(string s, string find, string repl)
        {
            int i = s.IndexOf(find, StringComparison.Ordinal);
            return i < 0 ? s : s.Substring(0, i) + repl + s.Substring(i + find.Length);
        }

        // envoltura centrada + leyenda para una gráfica (superficie o mapa)
        private static string PlotWrap(string inner, string caption) =>
            "<div style=\"text-align:center;margin:1.1em 0\">" + inner +
            "<div style=\"color:var(--mut);font-size:.85em;margin-top:.2em\">" + caption + "</div></div>";

        // parsea  expr, [xa xb], [ya yb]  de un #surf/#map → (árbol, texto, rangos)
        private static (LispConverter.N f, string spec, double xa, double xb, double ya, double yb)
            ParseSurfArgs(string inside, Dictionary<string, LispConverter.N> byName, System.Globalization.CultureInfo inv)
        {
            LispConverter.N f = null; string spec = null;
            var ranges = new List<(double lo, double hi)>();
            foreach (var a0 in SplitTop(inside))
            {
                var a = a0.Trim(); if (a.Length == 0) continue;
                var rng = System.Text.RegularExpressions.Regex.Match(a, @"^\[\s*(-?[\d.]+)[\s,]+(-?[\d.]+)\s*\]$");
                if (rng.Success)
                {
                    double.TryParse(rng.Groups[1].Value, System.Globalization.NumberStyles.Any, inv, out var lo);
                    double.TryParse(rng.Groups[2].Value, System.Globalization.NumberStyles.Any, inv, out var hi);
                    ranges.Add((lo, hi)); continue;
                }
                if (f == null) { spec = a; if (!byName.TryGetValue(a, out f)) { try { f = LispConverter.ParseMath(a); } catch { } } }
            }
            double xa = 0, xb = 1, ya = 0, yb = 1;
            if (ranges.Count >= 1) { xa = ranges[0].lo; xb = ranges[0].hi; ya = xa; yb = xb; }
            if (ranges.Count >= 2) { ya = ranges[1].lo; yb = ranges[1].hi; }
            return (f, spec, xa, xb, ya, yb);
        }

        // UN #fplot (o ;grafica) → su SVG. rest = lo que sigue a la palabra clave.
        private static string OneFplotHtml(string rest, Dictionary<string, LispConverter.N> byName,
                                           List<(string, LispConverter.N)> fns, System.Globalization.CultureInfo inv)
        {
            rest = (rest ?? "").Trim();
            double lo = -1, hi = 1; string forcedVar = null;
            var sel = new List<(string, LispConverter.N)>();
            var paren = System.Text.RegularExpressions.Regex.Match(rest, @"^\((.*)\)\s*$", System.Text.RegularExpressions.RegexOptions.Singleline);
            if (paren.Success)   // estilo MATLAB: fplot(N1, N2, [-1 1])
            {
                foreach (var a0 in SplitTop(paren.Groups[1].Value))
                {
                    var a = a0.Trim(); if (a.Length == 0) continue;
                    var rng = System.Text.RegularExpressions.Regex.Match(a, @"^\[\s*(-?[\d.]+)[\s,]+(-?[\d.]+)\s*\]$");
                    if (rng.Success) { double.TryParse(rng.Groups[1].Value, System.Globalization.NumberStyles.Any, inv, out lo); double.TryParse(rng.Groups[2].Value, System.Globalization.NumberStyles.Any, inv, out hi); continue; }
                    AddFn(sel, byName, a);
                }
            }
            else if (rest.Contains("=") && rest.Contains(":"))   // #fplot f(x), g(x), x = 0 : 2
            {
                foreach (var a0 in SplitTop(rest))
                {
                    var a = a0.Trim(); if (a.Length == 0) continue;
                    var vr = System.Text.RegularExpressions.Regex.Match(a, @"^([A-Za-z]\w*)\s*=\s*(-?[\d.]+)\s*:\s*(-?[\d.]+)$");
                    if (vr.Success)
                    {
                        forcedVar = vr.Groups[1].Value;
                        double.TryParse(vr.Groups[2].Value, System.Globalization.NumberStyles.Any, inv, out lo);
                        double.TryParse(vr.Groups[3].Value, System.Globalization.NumberStyles.Any, inv, out hi);
                        continue;
                    }
                    AddFn(sel, byName, a);
                }
            }
            else   // forma simple: ;grafica s -1 1 [N1 N2 …]
            {
                var toks = rest.Split(new[] { ' ', ',', '\t' }, StringSplitOptions.RemoveEmptyEntries);
                int k = 0;
                if (toks.Length > 0 && !double.TryParse(toks[0], System.Globalization.NumberStyles.Any, inv, out _)) { forcedVar = toks[0]; k = 1; }
                if (toks.Length >= k + 2 && double.TryParse(toks[k], System.Globalization.NumberStyles.Any, inv, out lo) && double.TryParse(toks[k + 1], System.Globalization.NumberStyles.Any, inv, out hi))
                    for (int j = k + 2; j < toks.Length; j++) AddFn(sel, byName, toks[j]);
            }
            if (sel.Count == 0) sel = new List<(string, LispConverter.N)>(fns);   // sin argumentos → todas
            if (sel.Count == 0) return "";
            string var = forcedVar ?? LispConverter.FreeVar(sel[0].Item2);
            return LispConverter.PlotSvg(var, lo, hi, sel) ?? "";
        }

        // Construye TODAS las gráficas EN ORDEN de aparición (fplot / surf / map mezclados), una por
        // directiva. El resultado va, en ese orden, a rellenar los huecos hk-plotslot del documento.
        private static readonly System.Text.RegularExpressions.Regex RxAnyPlot = new System.Text.RegularExpressions.Regex(
            @"^\s*[;#]+\s*(fplot|plot|ezplot|graficas?|grafico|surf|superficie|plot3d|mesh|malla|mallado|map|mapa|heatmap|contourf?|beam|viga|esquema|frame|portico|framedef|porticodef|slice|trozo|elemento|defl|diag|vmd|bar1d|barra|elem1d|punto|dotprod|producto|dot|recta|ab|interceptopendiente|mapa1d|xdexi|mapnatural|salto|pagebreak|nuevapagina|pagina|solido|solid|hexa|solidmesh|newpage)\b(.*)$",
            System.Text.RegularExpressions.RegexOptions.IgnoreCase);

        private static List<string> BuildPlotsOrdered(string editorText, List<string> forms, bool dark, out bool anySurf)
        {
            anySurf = false;
            var inv = System.Globalization.CultureInfo.InvariantCulture;
            var outList = new List<string>();
            // NOMBRE -> árbol del RESULTADO (permite referir por nombre: #surf(N_1,…), fplot(N1,…))
            var fns = new List<(string name, LispConverter.N tree)>();
            var byName = new Dictionary<string, LispConverter.N>();
            var todas = (forms ?? new List<string>()).SelectMany(f => (f ?? "").Replace("\r", "").Split('\n'));
            foreach (var raw in todas)
            {
                // `N_1(xi) = …` también es una definición: el motor la devuelve como
                // `(N_1 xi) = …` (la llamada en LISP). El nombre es N_1; sin esto
                // #fplot no la encontraba y dibujaba la recta y = ξ.
                var m = System.Text.RegularExpressions.Regex.Match(raw.Trim(),
                    @"^(?:\(([A-Za-z][\w']*)\s[^()]*\)|([A-Za-z][\w']*)(?:\s*\([^()=]*\))?)\s*=\s*(?![=])(.+)$");
                if (!m.Success) continue;
                var nom = m.Groups[1].Success ? m.Groups[1].Value : m.Groups[2].Value;
                var partes = System.Text.RegularExpressions.Regex.Split(m.Groups[3].Value, @"\s=\s");
                try
                {
                    var tree = LispConverter.ParseLisp(partes[partes.Length - 1].Trim());
                    if (!byName.ContainsKey(nom)) { byName[nom] = tree; fns.Add((nom, tree)); }
                }
                catch { }
            }
            int surfId = 0;
            foreach (var lineRaw in (editorText ?? "").Replace("\r", "").Split('\n'))
            {
                var mm = RxAnyPlot.Match(lineRaw);
                if (!mm.Success) continue;
                string kw = mm.Groups[1].Value.ToLowerInvariant();
                string rest = mm.Groups[2].Value.Trim();
                bool isSurf = kw is "surf" or "superficie" or "plot3d" or "mesh";
                bool isMap = kw is "map" or "mapa" or "heatmap" or "contour" or "contourf";
                bool isCont = kw is "contour" or "contourf";   // estilo ETABS: bandas + colormap CSI
                bool isBeam = kw is "beam" or "viga" or "esquema";
                bool isFrame = kw is "frame" or "portico";
                bool isFrameDef = kw is "framedef" or "porticodef";
                bool isSlice = kw is "slice" or "trozo" or "elemento";
                bool isDefl = kw is "defl";
                bool isBar1d = kw is "bar1d" or "barra" or "natural" or "elem1d";
                bool isDot = kw is "punto" or "dotprod" or "producto" or "dot";
                bool isRecta = kw is "recta" or "ab" or "interceptopendiente";
                bool isMapXi = kw is "mapa1d" or "xdexi" or "mapnatural";
                bool isSalto = kw is "salto" or "pagebreak" or "nuevapagina" or "pagina" or "newpage";
                bool isSolido = kw is "solido" or "solid" or "hexa" or "solidmesh";
                bool isDiag = kw is "diag" or "vmd";
                if (isDiag)
                {
                    var pmd = System.Text.RegularExpressions.Regex.Match(rest, @"^\((.*)\)\s*$", System.Text.RegularExpressions.RegexOptions.Singleline);
                    string dspec = pmd.Success ? pmd.Groups[1].Value.Trim() : rest.Trim();
                    try { string b64 = BeamSchematic.BeamDiagramsPng(dark, dspec); outList.Add(PlotWrap("<img style=\"max-width:100%;height:auto\" src=\"data:image/png;base64," + b64 + "\">", "la viga y su diagrama")); }
                    catch { outList.Add(""); }
                    continue;
                }
                if (isSolido)
                {
                    // #solido(a, b, h, nx, ny, nz [, corte])  corte: 0 entero, 1 cuarto,
                    // 2 mitad, 3 esquina. El corte se ve RELLENO porque solo se dibujan
                    // las caras que el hexaedro NO comparte con otro hexaedro presente.
                    var pms = System.Text.RegularExpressions.Regex.Match(rest, @"^\((.*)\)\s*$", System.Text.RegularExpressions.RegexOptions.Singleline);
                    var ag = SplitTop(pms.Success ? pms.Groups[1].Value : rest);
                    double G(int k, double def)
                    {
                        if (k >= ag.Count) return def;
                        var t = ag[k].Trim();
                        var sl = t.Split('/');
                        if (sl.Length == 2 && double.TryParse(sl[0], System.Globalization.NumberStyles.Any, inv, out var q1)
                            && double.TryParse(sl[1], System.Globalization.NumberStyles.Any, inv, out var q2) && q2 != 0) return q1 / q2;
                        return double.TryParse(t, System.Globalization.NumberStyles.Any, inv, out var vv) ? vv : def;
                    }
                    try
                    {
                        string cvs = SurfacePlot.SolidCanvas(G(0, 1), G(1, 1), G(2, 1),
                            (int)G(3, 6), (int)G(4, 6), (int)G(5, 6), (int)G(6, 0), surfId++);
                        outList.Add(PlotWrap(cvs, "sólido de hexaedros (se gira con el ratón)"));
                        anySurf = true;
                    }
                    catch { outList.Add(""); }
                    continue;
                }
                if (isSlice)
                {
                    try { string b64 = BeamSchematic.SlicePng(dark); outList.Add(PlotWrap("<img style=\"max-width:100%;height:auto\" src=\"data:image/png;base64," + b64 + "\">", "equilibrio del trocito (dx)")); }
                    catch { outList.Add(""); }
                }
                else if (isDefl)
                {
                    try { string b64 = BeamSchematic.DeflPng(dark); outList.Add(PlotWrap("<img style=\"max-width:100%;height:auto\" src=\"data:image/png;base64," + b64 + "\">", "la deflexión v(x)")); }
                    catch { outList.Add(""); }
                }
                else if (isBar1d)
                {
                    try { string b64 = BeamSchematic.Bar1DPng(dark); outList.Add(PlotWrap("<img style=\"max-width:100%;height:auto\" src=\"data:image/png;base64," + b64 + "\">", "coordenada natural ξ → barra real")); }
                    catch { outList.Add(""); }
                }
                else if (isDot)
                {
                    try { string b64 = BeamSchematic.DotProductPng(dark); outList.Add(PlotWrap("<img style=\"max-width:100%;height:auto\" src=\"data:image/png;base64," + b64 + "\">", "producto punto: emparejar, multiplicar, sumar")); }
                    catch { outList.Add(""); }
                }
                else if (isRecta)
                {
                    try { string b64 = BeamSchematic.RectaAbPng(dark); outList.Add(PlotWrap("<img style=\"max-width:100%;height:auto\" src=\"data:image/png;base64," + b64 + "\">", "a = intercepto (altura en ξ=0), b = pendiente")); }
                    catch { outList.Add(""); }
                }
                else if (isMapXi)
                {
                    try { string b64 = BeamSchematic.MapXiPng(dark); outList.Add(PlotWrap("<img style=\"max-width:100%;height:auto\" src=\"data:image/png;base64," + b64 + "\">", "la coordenada física x en función de la natural ξ")); }
                    catch { outList.Add(""); }
                }
                else if (isSalto)   // salto de PÁGINA (para el PDF): fuerza empezar en página nueva al imprimir
                {
                    outList.Add("<div class=\"pagebreak\"></div>");
                }
                else if (isFrameDef)
                {
                    var pm = System.Text.RegularExpressions.Regex.Match(rest, @"^\((.*)\)\s*$", System.Text.RegularExpressions.RegexOptions.Singleline);
                    var a = SplitTop(pm.Success ? pm.Groups[1].Value : rest);
                    double N(int k) { if (k >= a.Count) return 0; var s = a[k].Trim(); var sl = s.Split('/'); return sl.Length == 2 && double.TryParse(sl[0], System.Globalization.NumberStyles.Any, inv, out var n1) && double.TryParse(sl[1], System.Globalization.NumberStyles.Any, inv, out var d1) && d1 != 0 ? n1 / d1 : (double.TryParse(s, System.Globalization.NumberStyles.Any, inv, out var v) ? v : 0); }
                    try { string b64 = BeamSchematic.FrameDeformedPng(N(0), N(1), N(2), dark); outList.Add(PlotWrap("<img style=\"max-width:100%;height:auto\" src=\"data:image/png;base64," + b64 + "\">", "deformada del pórtico (FEM)")); }
                    catch { outList.Add(""); }
                }
                else if (isBeam || isFrame)
                {
                    var pm = System.Text.RegularExpressions.Regex.Match(rest, @"^\((.*)\)\s*$", System.Text.RegularExpressions.RegexOptions.Singleline);
                    string bspec = pm.Success ? pm.Groups[1].Value : rest;
                    try
                    {
                        string b64 = isFrame ? BeamSchematic.FramePng(bspec, dark) : BeamSchematic.BeamPng(bspec, dark);
                        outList.Add(PlotWrap("<img style=\"max-width:100%;height:auto\" src=\"data:image/png;base64," + b64 + "\">",
                                             isFrame ? "esquema del pórtico (sin deformar)" : "esquema de la viga (sin deformar)"));
                    }
                    catch { outList.Add(""); }
                }
                else if (kw is "malla" or "mallado")
                {
                    // #malla(nx, ny, [xa xb], [ya yb])  — la rejilla de elementos finitos
                    var mg = System.Text.RegularExpressions.Regex.Match(rest,
                        @"^\(\s*(\d+)\s*,\s*(\d+)\s*,\s*\[([^\]]*)\]\s*,\s*\[([^\]]*)\]\s*\)\s*$");
                    if (!mg.Success) { outList.Add(""); continue; }
                    double[] Rg(string g) => System.Text.RegularExpressions.Regex
                        .Split(g.Trim(), @"[\s,]+")
                        .Select(t => double.Parse(t, System.Globalization.NumberStyles.Any, inv)).ToArray();
                    try
                    {
                        int nx = int.Parse(mg.Groups[1].Value, inv), ny = int.Parse(mg.Groups[2].Value, inv);
                        var rx = Rg(mg.Groups[3].Value); var ry = Rg(mg.Groups[4].Value);
                        string b64 = SurfacePlot.MeshPng(nx, ny, rx[0], rx[1], ry[0], ry[1], dark);
                        outList.Add(PlotWrap("<img src=\"data:image/png;base64," + b64 + "\" style=\"max-width:100%\">",
                                             "mallado " + nx + " x " + ny));
                    }
                    catch { outList.Add(""); }
                }
                else if (isSurf || isMap)
                {
                    var pm = System.Text.RegularExpressions.Regex.Match(rest, @"^\((.*)\)\s*$", System.Text.RegularExpressions.RegexOptions.Singleline);
                    if (!pm.Success) { outList.Add(""); continue; }
                    var (f, spec, xa, xb, ya, yb) = ParseSurfArgs(pm.Groups[1].Value, byName, inv);
                    if (f == null) { outList.Add(""); continue; }
                    var vs = LispConverter.VarsOf(f);
                    string vx = vs.Count > 0 ? vs[0] : "x", vy = vs.Count > 1 ? vs[1] : "y";
                    string enc = System.Net.WebUtility.HtmlEncode(spec ?? "");
                    try
                    {
                        if (isSurf)
                        {
                            anySurf = true;
                            string cv = SurfacePlot.SurfaceCanvas(f, vx, vy, xa, xb, ya, yb, surfId++);
                            outList.Add(PlotWrap(cv, "z = " + enc + "  ·  <span style=\"opacity:.7\">arrastra para girar</span>"));
                        }
                        else
                        {
                            string b64 = SurfacePlot.MapPng(f, vx, vy, xa, xb, ya, yb, dark,
                                                           isCont, isCont ? 12 : 0);
                            // 17-sep, Jorge: «en el hover cursor» también en los mapas → el PNG va envuelto
                            // con la rejilla de valores, y MapScript muestra x, y, z al pasar el ratón.
                            anySurf = true;   // así se inyectan los scripts (orbit + hover de mapas)
                            string img = "<img style=\"max-width:100%;height:auto\" src=\"data:image/png;base64," + b64 + "\">";
                            outList.Add(PlotWrap(SurfacePlot.MapHover(f, vx, vy, xa, xb, ya, yb, img),
                                                 "mapa de  " + enc + "  (planta)"));
                        }
                    }
                    catch { outList.Add(""); }
                }
                else   // familia fplot
                {
                    outList.Add(OneFplotHtml(rest, byName, fns, inv));
                }
            }
            return outList;
        }

        // agrega una función: por NOMBRE ya deducido, o expresión MATLAB inline (1-s^2)
        private static void AddFn(List<(string, LispConverter.N)> sel, Dictionary<string, LispConverter.N> byName, string spec)
        {
            if (byName.TryGetValue(spec, out var t)) { sel.Add((spec, t)); return; }
            // #fplot(N_1(xi), …): el nombre sin su (xi)
            var fm = System.Text.RegularExpressions.Regex.Match(spec, @"^([A-Za-z][\w']*)\s*\([^()]*\)$");
            if (fm.Success && byName.TryGetValue(fm.Groups[1].Value, out var tf)) { sel.Add((fm.Groups[1].Value, tf)); return; }
            try { var t2 = LispConverter.ParseMath(spec); if (t2 != null) sel.Add((spec, t2)); } catch { }
        }

        /// <summary>Salida de un PROGRAMA (stdout) como página de consola (monospace), tema oscuro.</summary>
        private static string ConsolePage(string text)
        {
            var esc = (text ?? "").Replace("&", "&amp;").Replace("<", "&lt;").Replace(">", "&gt;");
            return "<!doctype html><html><head><meta charset='utf-8'><style>" +
                   "html,body{margin:0;background:#1e1e1e;color:#d4d4d4}" +
                   "pre{margin:0;padding:14px 16px;white-space:pre-wrap;word-break:break-word;" +
                   "font-family:Consolas,'Cascadia Code',monospace;font-size:14px;line-height:1.5}" +
                   "</style></head><body><pre>" + esc + "</pre></body></html>";
        }

        /// <summary>Una forma LISP del resultado → matemática legible (o tal cual si no parsea).</summary>
        private static string ToMathView(string lispForm)
        {
            if (string.IsNullOrWhiteSpace(lispForm)) return "";
            if (lispForm.StartsWith("⚠") || lispForm.StartsWith("…")) return lispForm;
            // "A = B = C" → convierte cada tramo a matemática y une con " = " (todo en UNA línea).
            // También parte por ≈ (lo pone `dec`: 1/3 ≈ 0.33) y conserva el signo que había:
            // sin esto, el tramo "1/3 ≈ 0.33" se intentaba parsear ENTERO como una expresión
            // LISP, fallaba, y se perdía todo lo que venía detrás del ≈.
            var trozos = System.Text.RegularExpressions.Regex.Split(lispForm, @"(\s=\s|\s≈\s)");
            var outp = new List<string>();
            foreach (var p in trozos)
            {
                var t = p.Trim();
                if (t == "=" || t == "≈") { outp.Add(t); continue; }        // el signo, tal cual
                if (t.Length == 0) continue;
                if (System.Text.RegularExpressions.Regex.IsMatch(t, @"^[A-Za-z]\w*$")) { outp.Add(t); continue; }  // NAME
                try { outp.Add(LispConverter.ToLab(LispConverter.ParseLisp(t), 0)); } catch { outp.Add(t); }
            }
            return string.Join(" ", outp);
        }

        /// <summary>El RESULTADO como FORMAS LISP. Autodetecta programa (ejecuta) vs expresiones
        /// (les aplica la operación elegida: auto/simplify/expand/deriv).</summary>
        private List<string> ComputeResult(string text, string dvar)
        {
            _ranProgram = false;
            if (string.IsNullOrWhiteSpace(text)) return new List<string>();

            // CaseMap: recuerda cómo escribió el usuario cada identificador con mayúsculas
            // (L, EI, N1…) para restaurar el case en el render (el motor los devuelve en minúscula).
            // SOLO líneas de matemática (no texto '#'/';'/'%' ni la etiqueta @@), para no cazar
            // palabras de la prosa como «Y», «El», «La».
            // Además: griegas Unicode (λ) → nombre, y los nombres que chocarían en LISP (m/M, T, Pi)
            // renombrados a una forma única. Ver LispConverter.PrepareNames.
            text = LispConverter.PrepareNames(text);
            _srcPrepared = text;

            // Programas: LISP (defun/loop/let) o matemática imperativa (for/while) → EJECUTAR.
            if (LooksLikeLisp(text) && IsLispProgram(text))
            {
                if (!Balanced(text)) return new List<string> { "…  (paréntesis sin cerrar)" };
                _ranProgram = true;
                return new List<string> { RunLispClean(text) };
            }
            // Solo EJECUTAR (imperativo) si hay CONTROL DE FLUJO real (for/while/if/function).
            // Las asignaciones simples "N1 = expr" NO se ejecutan: son etiquetas simbólicas.
            if (!LooksLikeLisp(text) &&
                System.Text.RegularExpressions.Regex.IsMatch(text, @"(^|\n)\s*(for|while|if|function)\b"))
            {
                _ranProgram = true;
                try { return new List<string> { RunLispClean(MatlabToLisp.Translate(text).Executable) }; }
                catch (Exception ex) { return new List<string> { "…  (" + ex.Message + ")" }; }
            }

            // DESPEJAR: cada línea "lhs = rhs" (o "expr" que implica expr = 0) → resolver para la variable.
            if (_op == "despejar")
            {
                var disp = new List<string>();
                foreach (var raw in text.Replace("\r", "").Split('\n'))
                {
                    var line = raw.Trim();
                    if (line.Length == 0) { disp.Add(""); continue; }
                    var eq = line.Split(new[] { '=' }, 2);
                    string lhsF = LispFormOfLine(eq[0].Trim()) ?? "0";
                    string rhsF = LispFormOfLine(eq.Length > 1 ? eq[1].Trim() : "0") ?? "0";
                    string v = !string.IsNullOrWhiteSpace(dvar) ? dvar.Trim()
                             : ((lhsF + " " + rhsF).Contains("x") ? "x" : FirstVar(lhsF + " " + rhsF));
                    string sol = LispEngine.RunDespejar(lhsF, rhsF, v);
                    disp.Add(v + " = " + sol);
                }
                return disp;
            }

            // Expresiones (matemática o LISP) → aplicar la operación elegida.
            // Antes: unir las líneas de una MATRIZ multi-línea (el '[' sigue abierto). El salto de
            // línea dentro de [ ] es separador de FILA (MATLAB), así que se une con ';'.
            var lines = ExpandMathSemicolons(JoinBracketLines(text).Split('\n'), out var contLine);
            // tic / toc (cronómetro, estilo Hekatan Lab): 'toc' mide el tiempo de las operaciones desde 'tic'.
            var isTic = new bool[lines.Length];
            var isToc = new bool[lines.Length];
            var tocOps = new Dictionary<int, List<int>>();   // índice del 'toc' → índices de líneas a cronometrar
            {
                int ticStart = -1; var pend = new List<int>();
                for (int i = 0; i < lines.Length; i++)
                {
                    var tl = lines[i].Trim().ToLowerInvariant();
                    if (tl == "tic") { isTic[i] = true; ticStart = i; pend = new List<int>(); }
                    else if (tl == "toc") { isToc[i] = true; tocOps[i] = pend; pend = new List<int>(); ticStart = -1; }
                    else if (ticStart >= 0) pend.Add(i);
                }
            }
            var formOf = new string[lines.Length];
            var labels = new string[lines.Length];   // nombre que DEFINE cada línea (N1, N2…) si es "NAME = expr"
            var textOf = new (string kind, string align, string text)?[lines.Length];  // directiva de TEXTO (; formato)
            var forms = new List<string>();
            var idx = new List<int>();
            var treeOf = new LispConverter.N[lines.Length];   // árbol de cada línea (para resolver etiquetas)
            var notationOf = new string[lines.Length];        // línea de NOTACIÓN pura (f(x)=…, y=f(x)=…): se dibuja, no se calcula
            var funcMap = new Dictionary<string, (List<string> ps, LispConverter.N body)>();  // f(x)=x²+1 → aplicar f(3)
            var deqTag = new string[lines.Length];             // etiqueta @@(…) que va a la DERECHA (estilo libro)
            var aliasOf = new List<string>[lines.Length];      // Fx = F_1 = Expand{…}: los nombres del medio (F_1)
            // ETIQUETA de ecuación: @@(texto) al FINAL de una línea de MATEMÁTICA → número a la derecha.
            // La VARIABLE queda a la IZQUIERDA (como Calcpad/Hekatan Lab). Compat: acepta el viejo #deq.
            // Las líneas de TEXTO (#: ## #> ; %) y las gráficas no llevan etiqueta.
            for (int i = 0; i < lines.Length; i++)
            {
                if (isTic[i] || isToc[i]) continue;   // tic/toc: no son expresiones
                var s = lines[i].TrimStart();
                bool textDir = s.StartsWith("#:") || s.StartsWith("##") || s.StartsWith("#>") ||
                               s.StartsWith("#<") || s.StartsWith("#|") || s.StartsWith(";") || s.StartsWith("%") ||
                               System.Text.RegularExpressions.Regex.IsMatch(s,
                                   @"^#\s*(fplot|plot|ezplot|graficas?|grafico|surf|superficie|plot3d|mesh|malla|mallado|map|mapa|heatmap|contourf?|beam|viga|esquema|frame|portico|framedef|porticodef|slice|trozo|elemento|defl|diag|vmd|bar1d|barra|elem1d|punto|dotprod|producto|dot|recta|ab|interceptopendiente|mapa1d|xdexi|mapnatural|solido|solid|hexa|solidmesh|salto|pagebreak|nuevapagina|pagina|newpage)\b",
                                   System.Text.RegularExpressions.RegexOptions.IgnoreCase);
                if (textDir) continue;
                var m = System.Text.RegularExpressions.Regex.Match(lines[i], @"^(.*?)\s*@@\((.*?)\)\s*$");
                if (m.Success)
                {
                    lines[i] = System.Text.RegularExpressions.Regex.Replace(m.Groups[1].Value.Trim(), @"^#deq\s+", "");
                    deqTag[i] = m.Groups[2].Value;
                }
            }
            var isPlot = new bool[lines.Length];   // línea = directiva de gráfica → marca su POSICIÓN en el documento
            // PASO 1: parsear cada línea a árbol + detectar su etiqueta
            for (int i = 0; i < lines.Length; i++)
            {
                if (isTic[i] || isToc[i]) continue;   // tic/toc: no se parsean como expresión
                var exprText = lines[i];
                if (System.Text.RegularExpressions.Regex.IsMatch(lines[i],
                        @"^\s*[;#]+\s*(fplot|plot|ezplot|graficas?|grafico|surf|superficie|plot3d|mesh|malla|mallado|map|mapa|heatmap|contourf?|beam|viga|esquema|frame|portico|framedef|porticodef|slice|trozo|elemento|defl|diag|vmd|bar1d|barra|elem1d|punto|dotprod|producto|dot|recta|ab|interceptopendiente|mapa1d|xdexi|mapnatural|solido|solid|hexa|solidmesh|salto|pagebreak|nuevapagina|pagina|newpage)\b",
                        System.Text.RegularExpressions.RegexOptions.IgnoreCase)) { isPlot[i] = true; continue; }
                var td = LispConverter.TextDirective(lines[i]);
                if (td != null) { textOf[i] = td; continue; }
                CollectFuncDefs(lines[i], funcMap);   // registra  f(x)=…  para poder aplicar f(3) después
                // NOTACIÓN de función / cadena de igualdades: se RENDERIZA tal cual, sin pasar por el motor.
                //   f(x) = x^2+1   ·   y = f(x) = x^2+1   ·   h(x) = f(G(x))
                // Regla (el porqué): es notación si hay ≥2 signos '=' (cadena), o si ANTES del 1er '='
                // aparece una llamada de función  id(…)  (definición). Un  N1 = (1-s)/2  NO lo es.
                // NOMBRES ENCADENADOS con algo que CALCULAR:  Fx = F_1 = Expand{…}  ·  A = a = 2·3.
                // Antes iba entera a notación (se dibujaba sin pasar por el motor: no expandía).
                // Ahora el primero es la etiqueta, los del medio alias, y el último se calcula.
                var ali = AliasChain(lines[i]);
                if (ali != null)
                {
                    labels[i] = ali.Value.names[0];
                    aliasOf[i] = ali.Value.names.Skip(1).ToList();
                    treeOf[i] = TreeOfLine(ali.Value.expr);
                    continue;
                }
                var nt = NotationLine(lines[i]);
                if (nt != null) { notationOf[i] = nt; continue; }
                var lm = System.Text.RegularExpressions.Regex.Match(lines[i].Trim(),
                            @"^([A-Za-z][\w']*)\s*=\s*(?![=])(.+)$");   // NAME = expr  (no ==)
                if (lm.Success) { labels[i] = lm.Groups[1].Value; exprText = lm.Groups[2].Value; }
                treeOf[i] = TreeOfLine(exprText);
            }
            // mapa etiqueta → su árbol (para sustituir  Partial{v@x}  con la definición de v)
            var labelMap = new Dictionary<string, LispConverter.N>();
            for (int i = 0; i < lines.Length; i++)
                if (labels[i] != null && treeOf[i] != null && !labelMap.ContainsKey(labels[i]))
                    labelMap[labels[i]] = treeOf[i];
            // vecMap = etiquetas cuyo valor es un VECTOR o MATRIZ → así v(i)/A(i,j) es ÍNDICE (no función).
            // Es lo que diferencia f(x) de v(i): el NOMBRE está definido como función o como vector.
            var vecMap = new Dictionary<string, LispConverter.N>();
            foreach (var kv in labelMap)
                if (kv.Value != null && (kv.Value.Op == "vec" || kv.Value.Op == "mat"))
                    vecMap[kv.Key] = kv.Value;
            // PASO 2: sustituir etiquetas y pasar a LISP.
            // Solo las etiquetas definidas ANTES (como en papel y en Calcpad): antes se usaba el mapa
            // de TODA la hoja y «g1 = alpha + …» salía «3² + …» por un «alpha = lambda^2» de más abajo.
            var prevLabels = new Dictionary<string, LispConverter.N>();
            for (int i = 0; i < lines.Length; i++)
            {
                if (treeOf[i] == null) continue;
                try
                {
                    var app = (funcMap.Count > 0 || vecMap.Count > 0)
                              ? LispConverter.SubstFuncs(treeOf[i], funcMap, vecMap) : treeOf[i];  // f(3)→3²+1, v(2)→componente
                    var sub = LispConverter.SubstLabels(app, prevLabels, labels[i], new HashSet<string>());
                    formOf[i] = LispConverter.ToLisp(sub);
                }
                catch { formOf[i] = null; }
                if (formOf[i] != null) { forms.Add(formOf[i]); idx.Add(i); }
                if (labels[i] != null && !prevLabels.ContainsKey(labels[i])) prevLabels[labels[i]] = treeOf[i];
                if (aliasOf[i] != null) foreach (var a in aliasOf[i]) if (!prevLabels.ContainsKey(a)) prevLabels[a] = treeOf[i];
            }
            bool hasVar = !string.IsNullOrWhiteSpace(dvar);   // dvar = variable de la parcial (∂/∂), o null = auto
            var results = LispEngine.EvalOp(forms, _op, dvar);
            var resOf = new string[lines.Length];
            for (int k = 0; k < idx.Count; k++) resOf[idx[k]] = k < results.Count ? results[k].Trim() : "";
            // Integral INDEFINIDA ( Integral{f @ x} sin límites ) → añade la constante  + C  (rigor matemático).
            for (int k = 0; k < idx.Count; k++)
            {
                int i = idx[k]; var t = treeOf[i];
                if (t != null && t.Op == "solver" && t.Atom == "integral" && t.Items != null && t.Items.Count == 2
                    && !string.IsNullOrEmpty(resOf[i]) && !resOf[i].StartsWith("(no-elem"))
                    resOf[i] = "(+ " + resOf[i] + " C)";
            }

            // Muestra el CÁLCULO: la ENTRADA (con nombre N1= y símbolo d/dx ó ∫ si aplica) y "= RESULTADO".
            var display = new List<string>();
            for (int i = 0; i < lines.Length; i++)
            {
                if (isTic[i]) { display.Add(""); continue; }   // tic: solo marca el inicio, no dibuja
                if (isToc[i])                                   // toc: cronometra las operaciones desde el tic
                {
                    var opForms = new List<string>();
                    if (tocOps.TryGetValue(i, out var ops))
                        foreach (var oi in ops) if (formOf[oi] != null) opForms.Add(formOf[oi]);
                    string html;
                    if (opForms.Count == 0)
                        html = "<span style=\"color:var(--mut)\">⏱ tic/toc sin operaciones que medir</span>";
                    else
                    {
                        double us = LispEngine.TimeOps(opForms, 10000);
                        html = "<span style=\"color:var(--var);font-weight:600\">⏱ " +
                               us.ToString("0.000", System.Globalization.CultureInfo.InvariantCulture) +
                               " µs</span> por operación <span style=\"color:var(--mut)\">(10 000 iteraciones, motor de polinomios en SBCL)</span>";
                    }
                    display.Add(LispConverter.TxtLine("p", "left", html));
                    continue;
                }
                if (isPlot[i]) { display.Add(LispConverter.PlotSlot); continue; }   // gráfica: hueco en su posición
                if (textOf[i] != null)   // texto formateado (directiva ;): sustituye {Var} por su valor (math)
                {
                    var (kind, align, raw2) = textOf[i].Value;
                    string html = LispConverter.FormatInlineText(raw2,
                        name => LookupVarHtml(name, labels, resOf, formOf, funcMap, vecMap),
                        name => vecMap.TryGetValue(name, out var vt) && vt.Op == "vec");   // @v → flecha solo si v es VECTOR
                    display.Add(LispConverter.TxtLine(kind, align, html));
                    continue;
                }
                if (notationOf[i] != null) { display.Add(notationOf[i]); continue; }   // notación: ya viene en forma LISP "a = b = c"
                if (formOf[i] == null) { display.Add(""); continue; }
                // DEFINICIÓN de vector/matriz: es solo el dato, no lleva "= resultado".
                // EXCEPCIÓN: si las entradas tienen OPERADORES (Partial, det, inv…), la matriz
                // NO es un dato — se evalúa y se muestra la matriz RESULTADO (limpia), no las ∂.
                if (labels[i] != null && formOf[i].StartsWith("(vector"))
                {
                    var rm = resOf[i];
                    if (HasOpCall(formOf[i]) && rm != null && rm.StartsWith("(vector") && !SameForm(rm, formOf[i]))
                        display.Add(labels[i] + " = " + rm);
                    else
                        display.Add(labels[i] + " = " + formOf[i]);
                    continue;
                }
                string lbl = labels[i];
                string v = hasVar ? dvar : FirstVar(formOf[i]);
                var r = resOf[i] ?? "";
                // --latex: la MISMA expresion que se va a dibujar, tambien en LaTeX.
                // Solo se apunta; no cambia nada de lo que ya hacia el render.
                LispLatex.Apunta(lbl, formOf[i], r);
                // Pasos{f @ x}: la derivada MOSTRANDO su trabajo. El motor devuelve (steps s0 s1 s2 s3),
                // una cadena de igualdades que se dibuja como  lbl = d/dx[f] = Σd/dx[tᵢ] = c·n·xⁿ⁻¹ = resultado.
                if (r.StartsWith("(steps"))
                {
                    var pasos = LispConverter.TopLevelArgs(r);
                    if (pasos.Count > 0)
                    {
                        display.Add((lbl != null ? lbl + " = " : "") + string.Join(" = ", pasos));
                        continue;
                    }
                }
                // hasR = hay RESULTADO distinto de la entrada. Comparo NORMALIZANDO (sin comillas ni
                // espacios): si el operador no cerró (devuelve la misma notación), no muestro "= <lo mismo>".
                bool hasR = r.Length > 0 && !r.Equals("nil", StringComparison.OrdinalIgnoreCase) && !SameForm(r, formOf[i])
                            && !ResultadoSinSentido(formOf[i], treeOf[i]);

                if (_op == "deriv" || _op == "integ")
                {   // d/dv(N1) = …   ó   ∫ N1 dv = …  TODO EN UNA LÍNEA (notación = resultado)
                    string inner = lbl ?? formOf[i];
                    string notation = "(" + (_op == "deriv" ? "deriv" : "integ") + " " + inner + " " + v + ")";
                    // deriv: SIEMPRE muestra el resultado (d/dx(e^x)=e^x, aunque sea = input).
                    // integ: muestra el resultado salvo que el motor marque (no-elem …) = no supo integrarlo.
                    //        Así ∫e^x dx = e^x SÍ se muestra (aunque coincida con el input).
                    bool okR = r.Length > 0 && !r.Equals("nil", StringComparison.OrdinalIgnoreCase);
                    bool unsup = r.StartsWith("(no-elem");
                    bool showR = _op == "deriv" ? okR : (okR && !unsup);
                    display.Add(showR ? notation + " = " + r : notation);
                }
                else if (lbl != null)   // auto/simplify/expand con nombre → "N1 = <expr o resultado>"
                {
                    // Operación de MATRIZ sobre una etiqueta: det(J)/inv(J)/transpose(J) se muestran
                    // con el SÍMBOLO (|J|, J⁻¹, Jᵀ) —como Hekatan Lab—, NO la matriz expandida. Se usa
                    // treeOf (que conserva la etiqueta J), no formOf (que la sustituyó por su matriz).
                    var tp = treeOf[i];
                    bool matOp = tp != null && (tp.Op == "trans" ||
                        (tp.Op == "fn" && tp.Items != null && tp.Items.Count == 1 &&
                         (tp.Atom == "det" || tp.Atom == "inv" || tp.Atom == "transpose" || tp.Atom == "trace" || tp.Atom == "adj" || tp.Atom == "cof")));
                    if (matOp && hasR && (tp.A?.IsAtom == true || (tp.Items != null && tp.Items.Count == 1 && tp.Items[0].IsAtom)))
                    {
                        display.Add(lbl + " = " + LispConverter.ToLisp(tp) + " = " + r);
                    }
                    // DESPEJAR: "ecuación → solución" con FLECHA (como los libros; hay >2 pasos, el
                    // último no es una igualdad sino el resultado del despeje).
                    else if (tp != null && tp.Atom == "despejar" && hasR)
                    {
                        display.Add(lbl + " = " + formOf[i] + " → " + r);
                    }
                    // dec(x) / dec(x, n): la palabra `dec` es fontaneria, no matematica, y no
                    // debe aparecer. Se muestra el ARGUMENTO y el valor unido con ≈, que es el
                    // signo correcto para un redondeo:   1/3 ≈ 0.33
                    else if (formOf[i] != null && formOf[i].StartsWith("(dec ") && hasR)
                    {
                        // se coge el PRIMER argumento (el segundo son las cifras) y se une
                        // con ≈ al valor. El nodo puede no llegar en treeOf, asi que se mira
                        // la forma LISP directamente.
                        var ar = LispConverter.TopLevelArgs(formOf[i]);
                        string arg = ar.Count > 0 ? ar[0] : formOf[i];
                        display.Add(lbl + " = " + arg + " ≈ " + r);
                    }
                    else
                    // si la fórmula tiene TOKENS (Partial, Factor…) muestra TÉRMINO = RESULTADO
                    // (el término entero renderiza a CSS, y al lado su valor simbólico).
                    if (HasOpCall(formOf[i]) && hasR)
                    {
                        // Si la operación (∫, Diff…) referencia una variable VECTOR/MATRIZ (B),
                        // muéstrala con el SÍMBOLO (∫ EI·Bᵀ·B dx), NO con B sustituida por su
                        // definición (la cadena de d/dx[d/dx[…]]), que llena la integral de
                        // operadores y la parte en varias líneas. treeOf conserva el símbolo B.
                        string opF = treeOf[i] != null ? LispConverter.ToLisp(treeOf[i]) : formOf[i];
                        bool refsVec = opF != formOf[i] && ReferencesVecVar(opF, vecMap);
                        display.Add(lbl + " = " + (refsVec ? opF : formOf[i]) + " = " + r);
                    }
                    else if (hasR && r.StartsWith("(vector") && r != formOf[i])
                    {
                        // operación de matriz (A', A*B, A^-1…): muestra la OPERACIÓN con etiquetas
                        // (A⁻¹, A·A) Y la matriz resultado, en la misma línea. La forma con etiquetas
                        // viene del árbol ORIGINAL (treeOf), no del sustituido.
                        string opF = treeOf[i] != null ? LispConverter.ToLisp(treeOf[i]) : formOf[i];
                        display.Add(opF.StartsWith("(vector") ? lbl + " = " + r
                                                              : lbl + " = " + opF + " = " + r);
                    }
                    else if (_op == "auto" && hasR &&
                             System.Text.RegularExpressions.Regex.IsMatch(r, @"^-?\d+(\.\d+)?$|^-?\d+/\d+$"))
                    {
                        // giro = M·l/(2·EI) = 3/5. Si la operación referencia un vector/matriz
                        // (p.ej. √(uᵀ·u)), muéstrala con el SÍMBOLO, no con el vector expandido bajo la raíz.
                        string opF = treeOf[i] != null ? LispConverter.ToLisp(treeOf[i]) : formOf[i];
                        bool refsVec = opF != formOf[i] && ReferencesVecVar(opF, vecMap);
                        display.Add(lbl + " = " + (refsVec ? opF : formOf[i]) + " = " + r);
                    }
                    else
                    {
                        string rhs = (_op == "auto" || !hasR) ? formOf[i] : r;
                        display.Add(lbl + " = " + rhs);
                    }
                }
                else                    // sin nombre → "entrada = resultado" EN UNA LÍNEA
                {
                    display.Add(hasR ? formOf[i] + " = " + r : formOf[i]);
                }
            }
            // alias del medio:  Fx = <F_1 = > expresión = resultado
            for (int i = 0; i < lines.Length && i < display.Count; i++)
                if (aliasOf[i] != null && aliasOf[i].Count > 0 && labels[i] != null && display[i].StartsWith(labels[i] + " = "))
                    display[i] = labels[i] + " = " + string.Join(" = ", aliasOf[i]) + display[i].Substring(labels[i].Length);
            // #deq: pega la ETIQUETA (a la derecha) al final de la línea de display correspondiente.
            for (int i = 0; i < lines.Length && i < display.Count; i++)
                if (deqTag[i] != null && display[i].Length > 0 && !display[i].StartsWith(LispConverter.TxtMark, StringComparison.Ordinal))
                    display[i] += LispConverter.DeqSep + deqTag[i];
            // Lado a lado: las asignaciones que venían de la MISMA línea (a=2; b=3) van en UNA fila.
            bool Mergeable(string s) => s.Length > 0 && !s.StartsWith(LispConverter.TxtMark, StringComparison.Ordinal) && s != LispConverter.PlotSlot;
            var merged = new List<string>();
            for (int i = 0; i < display.Count; i++)
            {
                bool cont = i < contLine.Count && contLine[i];
                if (cont && merged.Count > 0 && Mergeable(display[i]) && Mergeable(merged[merged.Count - 1]))
                    merged[merged.Count - 1] += LispConverter.SbsSep + display[i];
                else
                    merged.Add(display[i]);
            }
            return merged;
        }

        // ¿La forma LISP referencia el nombre de alguna variable VECTOR/MATRIZ (de vecMap)?
        // Decide si una operación (∫, Diff) se muestra con el SÍMBOLO del vector (Bᵀ·B) en vez
        // de con el vector expandido a su definición (la cadena de d/dx[d/dx[…]]).
        private static bool ReferencesVecVar(string lispExpr, Dictionary<string, LispConverter.N> vecMap)
        {
            if (vecMap == null || string.IsNullOrEmpty(lispExpr)) return false;
            foreach (var k in vecMap.Keys)
                if (k.Length > 0 && System.Text.RegularExpressions.Regex.IsMatch(
                        lispExpr, @"(?<![A-Za-z0-9_])" + System.Text.RegularExpressions.Regex.Escape(k) + @"(?![A-Za-z0-9_])"))
                    return true;
            return false;
        }

        /// <summary>¿La forma LISP tiene alguna VARIABLE LIBRE? (un identificador que no sea función/
        /// constante conocida). Si no la tiene, es puramente numérica y se puede evaluar sin miedo.</summary>
        private static bool HasFreeVar(string lisp)
        {
            foreach (System.Text.RegularExpressions.Match m in
                     System.Text.RegularExpressions.Regex.Matches(lisp, @"[A-Za-z_]\w*"))
            {
                var w = m.Value.ToLower();
                if (w is "expt" or "sqrt" or "sin" or "cos" or "tan" or "exp" or "log" or "abs"
                    or "pi" or "vector" or "e") continue;
                return true;
            }
            return false;
        }

        /// <summary>Primera variable libre de una forma LISP (para la notación d/dx, ∫…dx).</summary>
        private static string FirstVar(string lispForm)
        {
            foreach (System.Text.RegularExpressions.Match m in
                     System.Text.RegularExpressions.Regex.Matches(lispForm, @"[A-Za-z_]\w*"))
            {
                var w = m.Value.ToLower();
                if (w is "expt" or "sqrt" or "sin" or "cos" or "tan" or "exp" or "log" or "abs"
                    or "vector" or "deriv" or "integ" or "pi") continue;
                return m.Value;
            }
            return "x";
        }

        /// <summary>La línea (matemática o LISP) → su forma LISP; null si está vacía o no parsea.</summary>
        // {Var} en un texto: busca la etiqueta definida en la hoja y devuelve su valor renderizado (math).
        // Si no es una etiqueta, intenta la expresión literal (número/fórmula). null = déjalo tal cual.
        private static string LookupVarHtml(string name, string[] labels, string[] resOf, string[] formOf,
                                            Dictionary<string, (List<string> ps, LispConverter.N body)> funcMap = null,
                                            Dictionary<string, LispConverter.N> vecMap = null)
        {
            name = LispConverter.MangleExpr(name);   // la prosa usa los nombres tal cual; la hoja, los preparados
            // 1) ¿es una ETIQUETA definida en la hoja? → su resultado (ya calculado en el lote)
            for (int j = 0; j < labels.Length; j++)
                if (labels[j] == name)
                {
                    var r = !string.IsNullOrEmpty(resOf[j]) && !resOf[j].Equals("nil", StringComparison.OrdinalIgnoreCase)
                            ? resOf[j] : formOf[j];
                    try { return LispConverter.ToHtml(LispConverter.ParseLisp(r)); } catch { return null; }
                }
            // 2) expresión suelta: aplica funciones (f(3)→3²+1) y, si trae un TOKEN (Factor, Partial,
            //    Simplify…), COMPÚTALA con el motor y renderiza el resultado; si no, tal cual.
            try
            {
                var tree = LispConverter.ParseMath(name);
                if ((funcMap != null && funcMap.Count > 0) || (vecMap != null && vecMap.Count > 0))
                    tree = LispConverter.SubstFuncs(tree, funcMap ?? new Dictionary<string, (List<string>, LispConverter.N)>(), vecMap);
                var lisp = LispConverter.ToLisp(tree);
                // Computa SOLO si hay token (Factor/Partial/…) o si es TOTALMENTE numérico (sin variable
                // libre, ej. N1(-1)=1). Un símbolo como N_i NO se toca: se dibuja tal cual (si lo pasáramos
                // por el motor, una variable libre podría dar 0 o volver en minúscula).
                if (HasOpCall(lisp) || !HasFreeVar(lisp))
                {
                    var res = LispEngine.EvalOp(new List<string> { lisp }, "auto", null);
                    var rr = res.Count > 0 ? res[0].Trim() : "";
                    if (rr.Length > 0 && !rr.Equals("nil", StringComparison.OrdinalIgnoreCase) && rr != lisp)
                        return LispConverter.ToHtml(LispConverter.ParseLisp(rr));
                }
                return LispConverter.ToHtml(tree);
            }
            catch { return null; }
        }

        /// <summary>Si la línea es NOTACIÓN (definición de función o cadena de igualdades), la
        /// convierte a la forma LISP "a = b = c" que RenderPage dibuja lado a lado SIN evaluar.
        /// Devuelve null si no es notación (entonces sigue el camino normal de cálculo).
        /// El porqué: f(x)=x²+1 no es un cálculo, es una definición; hay que DIBUJARLA, no resolverla.</summary>
        /// <summary>Posiciones de los '=' de NIVEL 0 (fuera de { } ( ) [ ]), que no sean == <= >= !=.
        /// Así el '=' de los límites de un token — Slope{f @ x = a} — NO se confunde con una igualdad.</summary>
        private static List<int> TopLevelEquals(string s)
        {
            var pos = new List<int>(); int depth = 0;
            for (int i = 0; i < s.Length; i++)
            {
                char c = s[i];
                if (c == '{' || c == '(' || c == '[') depth++;
                else if (c == '}' || c == ')' || c == ']') { if (depth > 0) depth--; }
                else if (c == '=' && depth == 0
                         && (i == 0 || "=<>!".IndexOf(s[i - 1]) < 0)
                         && (i == s.Length - 1 || s[i + 1] != '='))
                    pos.Add(i);
            }
            return pos;
        }

        private static string NotationLine(string raw)
        {
            var line = raw.Trim();
            if (line.Length == 0 || line.StartsWith("(")) return null;   // LISP crudo no
            var eqs = TopLevelEquals(line);   // solo '=' de NIVEL 0 (el '=' interno de Slope{f@x=a} NO cuenta)
            if (eqs.Count == 0) return null;
            // antes del PRIMER '=' ¿hay una llamada de función  id(  ?  (definición f(x)= …)
            string lhs0 = line.Substring(0, eqs[0]);
            bool funcDef = System.Text.RegularExpressions.Regex.IsMatch(lhs0, @"[A-Za-z_]\w*\s*\(");
            // un solo '=' con un NOMBRE a la izquierda = cálculo normal (N1 = (1-s)/2).
            // Con una EXPRESIÓN a la izquierda (K·u = F) es una ECUACIÓN: se dibuja tal cual.
            // Antes se calculaba solo el lado izquierdo y salía «K·u = K·u».
            bool lhsNombre = System.Text.RegularExpressions.Regex.IsMatch(lhs0.Trim(), @"^[A-Za-z][\w']*$");
            if (eqs.Count < 2 && !funcDef && lhsNombre) return null;
            // partir en segmentos por cada '=' de nivel 0
            var segs = new List<string>(); int prev = 0;
            foreach (var pe in eqs) { segs.Add(line.Substring(prev, pe - prev)); prev = pe + 1; }
            segs.Add(line.Substring(prev));
            var outParts = new List<string>();
            foreach (var s in segs)
            {
                var t = s.Trim();
                if (t.Length == 0) return null;
                var f = LispFormOfLine(t);
                if (f == null) return null;   // si algún lado no parsea, que lo maneje el camino normal
                outParts.Add(f);
            }
            return string.Join(" = ", outParts);
        }

        /// <summary>Fx = F_1 = Expand{…}: nombres encadenados y al final algo que el motor CALCULA
        /// (un operador, o una cuenta sin variables). Devuelve los nombres y la expresión; null si no.
        /// Una cadena solo simbólica (Ul = u_l = G·u_g) sigue siendo notación.</summary>
        private static (List<string> names, string expr)? AliasChain(string raw)
        {
            var line = raw.Trim();
            if (line.Length == 0 || line.StartsWith("(")) return null;
            var eqs = TopLevelEquals(line);
            if (eqs.Count < 2) return null;
            var segs = new List<string>(); int prev = 0;
            foreach (var pe in eqs) { segs.Add(line.Substring(prev, pe - prev).Trim()); prev = pe + 1; }
            var expr = line.Substring(prev).Trim();
            if (expr.Length == 0) return null;
            foreach (var s in segs)
                if (!System.Text.RegularExpressions.Regex.IsMatch(s, @"^[A-Za-z][\w']*$")) return null;
            var f = LispFormOfLine(expr);
            if (f == null || !(HasOpCall(f) || !HasFreeVar(f))) return null;
            return (segs, expr);
        }

        /// <summary>Resultados del motor que NO son matemática válida y no se deben escribir:
        ///  · transpuesta de un SÍMBOLO (Tₑᵀ, L·D·Lᵀ): el motor trata la letra como un escalar y
        ///    daba «Tₑᵀ = Tₑ», «L·D·Lᵀ = D·L²» (las matrices no conmutan).
        ///  · Σ/∏ de símbolos que dependen del índice (σᵢ·λᵢ, i = 1…n): los tomaba como constantes.</summary>
        private static bool ResultadoSinSentido(string form, LispConverter.N tree)
        {
            if (form != null && System.Text.RegularExpressions.Regex.IsMatch(form, @"\(mtransp [^()\s]+\)")) return true;
            bool malo = false;
            void Rec(LispConverter.N n)
            {
                if (n == null || malo) return;
                if (n.Op == "solver" && (n.Atom == "sum" || n.Atom == "product") && n.Items != null && n.Items.Count > 1
                    && n.Items[1] != null && n.Items[1].IsAtom)
                {
                    string v = n.Items[1].Atom;
                    void Ind(LispConverter.N x)
                    {
                        if (x == null || malo) return;
                        if (x.IsAtom && x.Atom != null)
                        {
                            int us = x.Atom.IndexOf('_');
                            if (us > 0)
                            {
                                var sub = x.Atom.Substring(us + 1);
                                if (sub == v || (v.Length == 1 && sub.Length <= 3 && sub.Contains(v))) malo = true;
                            }
                            return;
                        }
                        Ind(x.A); Ind(x.B); if (x.Items != null) foreach (var y in x.Items) Ind(y);
                    }
                    Ind(n.Items[0]);
                }
                Rec(n.A); Rec(n.B); if (n.Items != null) foreach (var y in n.Items) Rec(y);
            }
            Rec(tree);
            return malo;
        }

        private static string LispFormOfLine(string line)
        {
            line = line.Trim();
            if (line.Length == 0) return null;
            if (LooksLikeLisp(line)) return line;             // ya es LISP
            try { return LispConverter.MathToLisp(line); } catch { return null; }
        }

        /// <summary>Registra las definiciones de función de una línea:  f(x) = cuerpo  (también dentro de
        /// una cadena  y = f(x) = cuerpo). Guarda nombre → (parámetros, árbol del cuerpo) para luego
        /// APLICAR  f(3), f(a), f(G(x))  por sustitución (β-reducción, el método de la época LISP).</summary>
        private static void CollectFuncDefs(string raw, Dictionary<string, (List<string> ps, LispConverter.N body)> map)
        {
            var line = raw.Trim();
            if (line.Length == 0 || line.StartsWith("(")) return;
            var eqs = TopLevelEquals(line);   // no partir por el '=' interno de un token solver
            if (eqs.Count == 0) return;
            var segs = new List<string>(); int prev = 0;
            foreach (var pe in eqs) { segs.Add(line.Substring(prev, pe - prev)); prev = pe + 1; }
            segs.Add(line.Substring(prev));
            if (segs.Count < 2) return;
            for (int i = 0; i < segs.Count - 1; i++)
            {
                var m = System.Text.RegularExpressions.Regex.Match(segs[i].Trim(), @"^([A-Za-z]\w*)\s*\(([^)]*)\)$");
                if (!m.Success) continue;
                var name = m.Groups[1].Value;
                var ps = new List<string>();
                bool ok = true;
                foreach (var p in m.Groups[2].Value.Split(','))
                {
                    var pn = p.Trim();
                    if (pn.Length == 0) continue;
                    if (!System.Text.RegularExpressions.Regex.IsMatch(pn, @"^[A-Za-z]\w*$")) { ok = false; break; }
                    ps.Add(pn);
                }
                if (!ok || ps.Count == 0 || map.ContainsKey(name)) continue;
                try
                {
                    var body = LispConverter.ParseMath(segs[i + 1].Trim());
                    if (body != null) map[name] = (ps, body);
                }
                catch { }
            }
        }

        // ¿la forma LISP contiene alguna llamada de operación (Partial, Factor, ∫, …)?
        private static readonly string[] OpCalls = {
            "(partial","(derive-x","(factor","(expand*","(integ-var","(integ-x","(area-under","(slope-at",
            "(suma","(producto-op","(root-op","(find-op","(sup-op","(inf-op","(repeat-op","(limite","(despejar" };
        private static bool HasOpCall(string f) => f != null && System.Array.Exists(OpCalls, s => f.Contains(s));
        // dos formas LISP son "la misma" salvo comillas de quote y espacios (un operador que NO cerró
        // devuelve su propia notación: no debe mostrarse como "entrada = <lo mismo>").
        private static string NormForm(string s) =>
            s == null ? "" : s.Replace("(quote ", "(").Replace("'", "").Replace(" ", "");
        private static bool SameForm(string a, string b) => NormForm(a) == NormForm(b);

        // la línea (matemática o LISP) → su ÁRBOL (para resolver etiquetas antes de pasar a LISP)
        /// <summary>Une las líneas de una MATRIZ que abarca varios renglones (el '[' quedó abierto).
        /// El salto de línea DENTRO de [ ] es separador de FILA en MATLAB → se une con ';' (salvo que
        /// el renglón ya termine en ';' , ',' o '[', para no meter una fila vacía). Fuera de [ ] no toca nada.
        ///   B = [1 2;\n   3 4]   →   B = [1 2; 3 4]      ·      [1 2\n 3 4]  →  [1 2; 3 4]</summary>
        private static string JoinBracketLines(string text)
        {
            var raw = text.Replace("\r", "").Split('\n');
            var outLines = new List<string>();
            string buf = null;
            foreach (var ln in raw)
            {
                if (buf == null) buf = ln;
                else
                {
                    var tb = buf.TrimEnd();
                    // '...' = CONTINUACIÓN MATLAB: se pega el siguiente renglón EN LA MISMA FILA
                    // (el salto NO cuenta como separador). Fuera o dentro de [ ] (aquí, matrices).
                    if (tb.EndsWith("..."))
                        buf = tb.Substring(0, tb.Length - 3).TrimEnd() + " " + ln.Trim();
                    else
                    {
                        char last = tb.Length > 0 ? tb[tb.Length - 1] : ' ';
                        // salto de línea dentro de [ ] = nueva FILA (';'), salvo que ya venga ; , o [
                        buf = (last == ';' || last == ',' || last == '[') ? tb + " " + ln.Trim()
                                                                          : tb + "; " + ln.Trim();
                    }
                }
                int depth = 0;
                foreach (char c in buf) { if (c == '[') depth++; else if (c == ']') depth--; }
                bool cont = buf.TrimEnd().EndsWith("...");   // sigue continuando (dentro o fuera de [ ])
                if (depth <= 0 && !cont) { outLines.Add(buf); buf = null; }   // completa
            }
            if (buf != null) outLines.Add(buf.Replace("...", " "));
            return string.Join("\n", outLines);
        }

        private static LispConverter.N TreeOfLine(string line)
        {
            line = line.Trim();
            if (line.Length == 0) return null;
            try { return LooksLikeLisp(line) ? LispConverter.ParseLisp(line) : LispConverter.ParseMath(line); }
            catch { return null; }
        }

        // ---------- motor: expresiones y programas ----------
        private static bool LooksLikeLisp(string t)
        {
            if (t.TrimStart().StartsWith(";")) return true;
            // (a) una palabra clave LISP tras '(' → seguro es LISP
            // La palabra va tras un '(' que NO está pegado a un nombre, y le sigue un espacio y un
            // argumento (no un operador): así «sqrt(lambda^2 + mu^2)» o «(lambda + mu)/2» son
            // MATEMÁTICA. Antes esa línea convertía la hoja ENTERA en un programa LISP («⚠ = 2»).
            if (System.Text.RegularExpressions.Regex.IsMatch(t,
                @"(?<![A-Za-z0-9_.])\(\s*(defun|defparameter|defvar|let\*?|setf|setq|loop|format|print|progn|cond|when|unless|lambda|dolist|dotimes|expt|list|vector|deriv|dsimp|simplif|and|or|not)\s+(?=[^\s\-+*/^=)·,])"))
                return true;
            // (b) forma prefija de operador  (- 1 2) : el '(' NO va pegado a un identificador
            //     (si no, N1(-1) sería "resta LISP") y el operador lleva ESPACIO detrás (LISP: "(- 1",
            //     no matemática "(-1)").  Así f(-1), sin(-x), (1-s)/2 quedan como MATEMÁTICA.
            return System.Text.RegularExpressions.Regex.IsMatch(t, @"(?<![A-Za-z0-9_.])\(\s*[-+*/=<>]\s");
        }

        private static bool IsLispProgram(string t)
            => System.Text.RegularExpressions.Regex.IsMatch(t,
                @"(?<![A-Za-z0-9_.])\(\s*(defun|defparameter|defvar|let\*?|setf|setq|loop|progn|format|print|dolist|dotimes|lambda|cond|when|unless)\s+(?=[^\s\-+*/^=)·,])");

        private static string RunLispClean(string code)
        {
            // carga el motor (deriv, simplify, expand*…) para que los PROGRAMAS puedan usarlo:
            // así puedes DEDUCIR (ej. una función lagrange que arma las funciones de forma).
            var engine = System.IO.Path.Combine(AppContext.BaseDirectory, "engine.lisp").Replace("\\", "/");
            // *print-right-margin* grande: que NO parta las formas largas (si no, un (- ... ) se corta
            // en dos líneas y el render lo lee incompleto como una negación).
            string pre = "(setf *print-case* :downcase)\n(setf *print-right-margin* 100000)\n(load \"" + engine + "\")\n";
            var res = LispEngine.RunScript(pre + code);
            if (string.IsNullOrWhiteSpace(res))
                res = LispEngine.RunScript(pre + "(format t \"~a~%\" (progn\n" + code + "))");
            return CleanSbcl(res).TrimEnd();
        }

        private static string CleanSbcl(string s)
        {
            if (string.IsNullOrEmpty(s)) return s;
            var m = System.Text.RegularExpressions.Regex.Match(s, @"variable (\w+) is unbound",
                System.Text.RegularExpressions.RegexOptions.IgnoreCase);
            if (m.Success)
                return "⚠ la variable «" + m.Groups[1].Value.ToLower() +
                       "» no tiene valor. Asígnale un número (ej.: " + m.Groups[1].Value.ToLower() + " = 2).";
            int bt = s.IndexOf("Backtrace for:", StringComparison.Ordinal);
            if (bt >= 0)
            {
                foreach (var l in s.Substring(0, bt).Replace("\r", "").Split('\n'))
                {
                    var t = l.Trim();
                    if (t.Length > 0 && !t.StartsWith("Unhandled") && !t.Contains("thread")) return "⚠ " + t;
                }
                return "⚠ error en el código LISP.";
            }
            return s;
        }

        private static bool Balanced(string code)
        {
            int b = 0;
            foreach (var c in code) { if (c == '(') b++; else if (c == ')') { b--; if (b < 0) return false; } }
            return b == 0;
        }

        // ---------- «escribo:» matemática / expr LISP / LISP completo / Hekatan Lab ----------
        private static string ConvertEditor(string text, bool toLisp)
        {
            if (string.IsNullOrWhiteSpace(text)) return text;
            // Un PROGRAMA LISP (o el script "LISP completo") YA es LISP: NO convertir línea por
            // línea (mangaría (load …)/(setf …) que MathToLisp no entiende). Se devuelve igual.
            if (toLisp && LooksLikeLisp(text) && IsLispProgram(text)) return text;
            // Solo un PROGRAMA con CONTROL DE FLUJO real (for/while/if/function) va en bloque.
            // "A = x+1" NO es programa: es una ETIQUETA simbólica (se convierte lado a lado).
            if (toLisp && !LooksLikeLisp(text) &&
                System.Text.RegularExpressions.Regex.IsMatch(text, @"(^|\n)\s*(for|while|if|function)\b"))
            {
                try { return MatlabToLisp.Translate(text).Lisp; } catch { return text; }
            }
            var sb = new StringBuilder();
            // varias asignaciones en una línea (a = 2; b = 3) → una por línea, igual que en el render
            foreach (var raw in ExpandMathSemicolons(text.Replace("\r", "").Split('\n')))
            {
                var l = raw.Trim();
                if (l.Length == 0) { sb.AppendLine(); continue; }
                // COMENTARIO/DIRECTIVA ';' (texto, gráfica, ;;): se conserva TAL CUAL en ambos sentidos.
                // (si no, ToLab(ParseLisp(";# título")) leería solo el 1er token y borraría el texto)
                if (l.StartsWith(";")) { sb.AppendLine(l); continue; }
                // DIRECTIVA '#' (markdown #:/##, #fplot, #deq): se conserva. En #deq se convierte SOLO
                // la ecuación interna (dejando el prefijo #deq y la etiqueta @@(…) intactos).
                if (l.StartsWith("#"))
                {
                    var dm = System.Text.RegularExpressions.Regex.Match(l, @"^#deq\s+(.*?)\s*(?:@@\((.*?)\))?\s*$");
                    if (toLisp)
                    {
                        // a expr LISP: #deq → (setf…) + etiqueta como comentario ';' ; el texto markdown (#: ##) → ';'
                        if (dm.Success)
                            sb.AppendLine(ConvertEqLine(dm.Groups[1].Value.Trim(), true) +
                                          (dm.Groups[2].Success ? "   ; " + dm.Groups[2].Value : ""));
                        else
                            sb.AppendLine("; " + l.TrimStart('#', ':', '|', '<', '>', ' '));
                    }
                    else   // a matemática: conserva el markdown (el reverso real llega por _lispBackup)
                    {
                        if (dm.Success)
                            sb.AppendLine("#deq " + ConvertEqLine(dm.Groups[1].Value.Trim(), false) +
                                          (dm.Groups[2].Success ? " @@(" + dm.Groups[2].Value + ")" : ""));
                        else sb.AppendLine(l);
                    }
                    continue;
                }
                // línea de MATEMÁTICA: extrae la etiqueta @@(…) del final (queda como comentario en LISP,
                // y se conserva en matemática). La variable sigue a la izquierda.
                string tg = null; var mt = System.Text.RegularExpressions.Regex.Match(l, @"^(.*?)\s*@@\((.*?)\)\s*$");
                if (mt.Success) { tg = mt.Groups[2].Value; l = mt.Groups[1].Value.Trim(); }
                string conv = ConvertEqLine(l, toLisp);
                if (tg != null) conv += toLisp ? "   ; " + tg : " @@(" + tg + ")";
                sb.AppendLine(conv);
            }
            return sb.ToString().TrimEnd();
        }

        // convierte UNA ecuación entre matemática y LISP:  (setf N f)↔N=math ,  N=expr↔(setf N f) ,  o expr suelta.
        // Si algo no parsea, devuelve la línea TAL CUAL (nunca rompe la conversión global).
        private static string ConvertEqLine(string l, bool toLisp)
        {
            var sm = System.Text.RegularExpressions.Regex.Match(l, @"^\(setf\s+([A-Za-z]\w*)\s+(.+)\)$");
            if (!toLisp && sm.Success)
            {
                try { return sm.Groups[1].Value + " = " + LispConverter.ToLab(LispConverter.ParseLisp(sm.Groups[2].Value.Trim()), 0); }
                catch { return l; }
            }
            // DEFINICIÓN de función  f(x) = expr  (ej. N_1(x) = 1 - x/L): mantiene el LHS, convierte el RHS.
            var fm = System.Text.RegularExpressions.Regex.Match(l, @"^([A-Za-z]\w*)\(([^)]*)\)\s*=\s*(?![=])(.+)$");
            if (fm.Success)
            {
                string rhs = fm.Groups[3].Value.Trim();
                try
                {
                    if (toLisp)
                    {
                        string lispRhs = LooksLikeLisp(rhs) ? rhs : LispConverter.MathToLisp(rhs);
                        return "(defun " + fm.Groups[1].Value + " (" + fm.Groups[2].Value.Replace(",", " ").Trim() + ") " + lispRhs + ")";
                    }
                    string cv = LooksLikeLisp(rhs) ? LispConverter.ToLab(LispConverter.ParseLisp(rhs), 0) : rhs;
                    return fm.Groups[1].Value + "(" + fm.Groups[2].Value + ") = " + cv;
                }
                catch { return l; }
            }
            var lm = System.Text.RegularExpressions.Regex.Match(l, @"^([A-Za-z][\w']*)\s*=\s*(?![=])(.+)$");
            if (lm.Success)
            {
                string rhs = lm.Groups[2].Value.Trim();
                try
                {
                    if (toLisp)
                    {
                        string lispRhs = LooksLikeLisp(rhs) ? rhs : LispConverter.MathToLisp(rhs);
                        return "(setf " + LispConverter.SafeName(lm.Groups[1].Value) + " " + lispRhs + ")";
                    }
                    string conv = LooksLikeLisp(rhs) ? LispConverter.ToLab(LispConverter.ParseLisp(rhs), 0) : rhs;
                    return LispConverter.SafeName(lm.Groups[1].Value) + " = " + conv;
                }
                catch { return l; }
            }
            bool isLisp = LooksLikeLisp(l);
            try
            {
                if (toLisp) return isLisp ? l : LispConverter.MathToLisp(l);
                return isLisp ? LispConverter.ToLab(LispConverter.ParseLisp(l), 0) : l;
            }
            catch { return l; }
        }

        // El LISP COMPLETO y EJECUTABLE: carga el motor, cita ('), imprime. Se copia a un .lisp
        // en blanco y CORRE en SBCL tal cual. (La vista "LISP" y el botón "📋 LISP completo" lo usan.)
        private string BuildFullLisp(string text)
        {
            if (string.IsNullOrWhiteSpace(text)) return "";
            var enginePath = Path.Combine(AppContext.BaseDirectory, "engine.lisp").Replace("\\", "/");
            var sb = new StringBuilder();
            var sbclDir = Path.Combine(AppContext.BaseDirectory, "sbcl").Replace("\\", "/");
            sb.AppendLine(";;;; Script LISP ejecutable — generado por Hekatan LISP");
            sb.AppendLine(";;;; CÓMO CORRERLO (PowerShell): primero 'cd' a la carpeta de ESTE archivo, o usa su ruta completa.");
            sb.AppendLine(";;;;   & \"" + sbclDir + "/sbcl.exe\" --core \"" + sbclDir + "/sbcl.core\" --script \"<ruta_completa_de_este_archivo>\"");
            sb.AppendLine(";;;; (OJO: si pasas solo el nombre, SBCL lo busca en la carpeta ACTUAL de la consola, no donde está el .lisp)");
            sb.AppendLine(";;;; (el ' cita las expresiones como DATOS: no evalúa x, las manipula simbólico)");
            sb.AppendLine("(load \"" + enginePath + "\")");
            sb.AppendLine("(setf *print-case* :downcase)");
            sb.AppendLine("(setf *print-right-margin* 100000)   ; no partir formas largas en 2 lineas");
            sb.AppendLine();

            if (LooksLikeLisp(text) && IsLispProgram(text))
            {
                sb.AppendLine(";; es un PROGRAMA: se ejecuta tal cual (ya imprime con format)");
                sb.AppendLine(text.Trim());
            }
            else
            {
                string opfn = _op switch
                {
                    "simplify" => "factor", "expand" => "expand*",
                    "deriv" => "derive-x", "integ" => "integ-x", _ => null
                };
                sb.AppendLine(";; una fórmula por bloque: MATLAB (comentario) + LISP (ejecutable) + resultado (" + _op + ")");
                sb.AppendLine(";; (las líneas ';' de TEXTO/gráfica se conservan como comentario: al correr NO se ven, solo Hekatan LISP las dibuja)");
                int idx = 1;
                foreach (var raw in text.Replace("\r", "").Split('\n'))
                {
                    var line = raw.Trim();
                    if (line.Length == 0) { sb.AppendLine(); continue; }
                    if (line.StartsWith(";")) { sb.AppendLine(line); continue; }   // texto/gráfica/comentario: VERBATIM
                    // etiqueta NOMBRE = expr → usa el lado DERECHO (si no, ParseMath descarta el '=')
                    var lm = System.Text.RegularExpressions.Regex.Match(line, @"^([A-Za-z][\w']*)\s*=\s*(?![=])(.+)$");
                    var f = LispFormOfLine(lm.Success ? lm.Groups[2].Value : line);
                    if (f == null) continue;
                    string matlab; try { matlab = LispConverter.ToLab(LispConverter.ParseLisp(f), 0); } catch { matlab = f; }
                    sb.AppendLine();
                    sb.AppendLine(";; ── fórmula " + idx + " ──");
                    sb.AppendLine(";;    MATLAB:  " + matlab);
                    sb.AppendLine(";;    LISP:    " + f);
                    // operador SOLVER de Calcpad ($Area/$Slope/…): SIEMPRE se EVALÚA (imprime su resultado),
                    // aunque la operación sea "tal cual". Si no, saldría (slope-at …) sin calcular.
                    bool isSolver = System.Text.RegularExpressions.Regex.IsMatch(f,
                        @"^\(\s*(area-under|slope-at|suma|producto-op|root-op|find-op|sup-op|inf-op|repeat-op)\b");
                    if (isSolver)
                        sb.AppendLine("(let ((r (ignore-errors " + f + "))) (format t \"" +
                                      matlab.Replace("\\", "\\\\").Replace("\"", "\\\"") +
                                      "  =>  ~a~%\" (cond ((null r) '?) ((consp r) (or (ignore-errors (infix r)) r)) (t r))))");
                    // imprime en MATEMÁTICA (infix) y también deja ver la forma LISP entre paréntesis
                    else if (opfn == null)
                        sb.AppendLine("(let ((e '" + f + ")) (format t \"~a       (LISP: ~a)~%\" (infix e) e))");
                    else
                        sb.AppendLine("(let* ((e '" + f + ") (r (or (ignore-errors (" + opfn +
                                      " e)) e))) (format t \"~a  =>  ~a       (LISP: ~a)~%\" (infix e) (infix r) r))");
                    idx++;
                }
            }
            return sb.ToString();
        }

        // MATLAB 2017a REAL (Symbolic Toolbox): syms + diff/int/simplify + tic/toc. Copiable y ejecutable.
        private string BuildRealMatlab(string text)
        {
            if (string.IsNullOrWhiteSpace(text)) return "";
            var vars = new SortedSet<string>(StringComparer.Ordinal);
            var body = new StringBuilder();
            string OpCall(string e) => _op switch
            {
                "simplify" => "factor(" + e + ")",
                "expand" => "expand(" + e + ")",
                "deriv" => "diff(" + e + ")",
                "integ" => "int(" + e + ")",
                _ => e
            };
            // texto de Hekatan LISP → texto de Hekatan Lab: {Var}→@{Var}; quita *negrita*/_cursiva_ inline
            // (el %'... de Hekatan Lab NO procesa markdown inline; dejaría los * y _ visibles).
            string MdVars(string t)
            {
                t = System.Text.RegularExpressions.Regex.Replace(t ?? "", @"\*([^*]+)\*", "$1");
                t = System.Text.RegularExpressions.Regex.Replace(t, @"_([^_]+)_", "$1");
                return System.Text.RegularExpressions.Regex.Replace(t, @"\{([^}]+)\}", "@{$1}");
            }
            foreach (var raw in text.Replace("\r", "").Split('\n'))
            {
                var line = raw.Trim();
                if (line.Length == 0) { body.AppendLine(); continue; }
                // #deq  ecuación  @@(etiqueta)  → ecuación MATLAB + etiqueta como comentario '%'
                var dq = System.Text.RegularExpressions.Regex.Match(line, @"^#deq\s+(.*?)\s*(?:@@\((.*?)\))?\s*$");
                if (dq.Success)
                {
                    string eql = dq.Groups[1].Value.Trim();
                    string tg = dq.Groups[2].Success ? "   % " + dq.Groups[2].Value : "";
                    // LHS puede ser  f(x)=…  (definición) o  N=…  (etiqueta); si no, expr suelta.
                    var fmd = System.Text.RegularExpressions.Regex.Match(eql, @"^([A-Za-z]\w*)\(([^)]*)\)\s*=\s*(?![=])(.+)$");
                    var lmd = System.Text.RegularExpressions.Regex.Match(eql, @"^([A-Za-z][\w']*)\s*=\s*(?![=])(.+)$");
                    string lhs = fmd.Success ? LispConverter.SafeName(fmd.Groups[1].Value) + "(" + fmd.Groups[2].Value + ")"
                               : lmd.Success ? LispConverter.SafeName(lmd.Groups[1].Value) : null;
                    string rh  = fmd.Success ? fmd.Groups[3].Value : lmd.Success ? lmd.Groups[2].Value : eql;
                    string mx;
                    try
                    {
                        var tr = LooksLikeLisp(rh) ? LispConverter.ParseLisp(rh) : LispConverter.ParseMath(rh);
                        LispConverter.LabMatlab = true;
                        try { mx = LispConverter.ToLab(tr, 0); } finally { LispConverter.LabMatlab = false; }
                        foreach (var v in LispConverter.VarsOf(tr)) vars.Add(v);
                    }
                    catch { mx = rh; }
                    body.AppendLine((lhs != null ? lhs + " = " + OpCall(mx) : OpCall(mx)) + tg);
                    continue;
                }
                // GRÁFICA:  ;fplot / #fplot (x^2, [0 1])  →  plot(linspace, arrayfun) (Hekatan Lab NO tiene fplot).
                var fp = System.Text.RegularExpressions.Regex.Match(line,
                    @"^[;#]+\s*(?:fplot|plot|ezplot)\s*\(\s*(.+?)\s*,\s*\[\s*([^\]\s]+)\s+([^\]\s]+)\s*\]\s*\)\s*$",
                    System.Text.RegularExpressions.RegexOptions.IgnoreCase);
                if (fp.Success)
                {
                    string ex = fp.Groups[1].Value.Trim();
                    string pv = "x"; try { pv = LispConverter.FreeVar(LispConverter.ParseMath(ex)) ?? "x"; } catch { }
                    string rng = "linspace(" + fp.Groups[2].Value + ", " + fp.Groups[3].Value + ", 200)";
                    body.AppendLine("plot(" + rng + ", arrayfun(@(" + pv + ") " + ex + ", " + rng + "))");
                    continue;
                }
                // TEXTO con formato:  directiva ';' O '#' (markdown) → markup de Hekatan Lab
                //   (%" título · %'| centro · %'> der · %' texto)
                var td = LispConverter.TextDirective(line);
                if (td != null && (line.StartsWith(";") || line.StartsWith("#")))
                {
                    var (kind, align, txt) = td.Value;
                    txt = MdVars(txt);
                    string pfx = (kind == "h1" || kind == "h2") ? "%\" "
                               : align == "center" ? "%'| "
                               : align == "right" ? "%'> " : "%' ";
                    body.AppendLine(pfx + txt);
                    continue;
                }
                if (line.StartsWith("%")) { body.AppendLine(line); continue; }   // ya es MATLAB
                if (line.StartsWith(";")) continue;                              // comentario LISP suelto
                if (line.StartsWith("#")) { body.AppendLine("%' " + MdVars(line.TrimStart('#', ' '))); continue; }  // '#' suelto → comentario
                // etiqueta @@(…) al final → comentario '%'
                string mtag = "";
                var em = System.Text.RegularExpressions.Regex.Match(line, @"^(.*?)\s*@@\((.*?)\)\s*$");
                if (em.Success) { mtag = "   % " + em.Groups[2].Value; line = em.Groups[1].Value.Trim(); }
                var fmn = System.Text.RegularExpressions.Regex.Match(line, @"^([A-Za-z]\w*)\(([^)]*)\)\s*=\s*(?![=])(.+)$");
                var lm  = System.Text.RegularExpressions.Regex.Match(line, @"^([A-Za-z][\w']*)\s*=\s*(?![=])(.+)$");
                string lhs2 = fmn.Success ? LispConverter.SafeName(fmn.Groups[1].Value) + "(" + fmn.Groups[2].Value + ")"
                            : lm.Success ? LispConverter.SafeName(lm.Groups[1].Value) : null;
                string rhs = fmn.Success ? fmn.Groups[3].Value : lm.Success ? lm.Groups[2].Value : line;
                string mexpr;
                try
                {
                    var tree = LooksLikeLisp(rhs) ? LispConverter.ParseLisp(rhs) : LispConverter.ParseMath(rhs);
                    LispConverter.LabMatlab = true;                 // solver → MATLAB (int, diff, symsum…)
                    try { mexpr = LispConverter.ToLab(tree, 0); } finally { LispConverter.LabMatlab = false; }
                    foreach (var v in LispConverter.VarsOf(tree)) vars.Add(v);
                }
                catch { mexpr = rhs; }
                body.AppendLine((lhs2 != null ? lhs2 + " = " + OpCall(mexpr) : OpCall(mexpr)) + mtag);
            }
            var sb = new StringBuilder();
            sb.AppendLine("% Hekatan Lab / MATLAB (Symbolic) — cópialo a Hekatan Lab: texto, operación y gráfica igual.");
            sb.AppendLine("% Para MEDIR el tiempo, rodéalo con  tic ... toc  (en LISP: get-internal-real-time).");
            if (vars.Count > 0) sb.AppendLine("syms " + string.Join(" ", vars));
            sb.Append(body);
            return sb.ToString().TrimEnd();
        }
    }
}
