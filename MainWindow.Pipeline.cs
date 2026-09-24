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

        // separa por 'sep' de PRIMER nivel — respeta { } [ ] ( ) Y comillas "…" (para tablas:
        // encabezados "D, DNE [t]" con coma dentro de comillas, columnas {"A-1","A-2"} literales).
        private static List<string> SplitTopQ(string s, char sep)
        {
            var res = new List<string>(); int depth = 0; bool inQ = false; var cur = new StringBuilder();
            foreach (char c in s)
            {
                if (c == '"') inQ = !inQ;
                if (!inQ)
                {
                    if (c == '{' || c == '[' || c == '(') depth++;
                    else if (c == '}' || c == ']' || c == ')') depth--;
                }
                if (c == sep && depth == 0 && !inQ) { res.Add(cur.ToString()); cur.Clear(); }
                else cur.Append(c);
            }
            res.Add(cur.ToString());
            return res;
        }

        // ---------- TABLAS de RESULTADOS calculados:  #tabla("Nudo","Uz [mm]:3")( nudos ; uz ) ----------
        // headers: lista entre comillas, con ":N" opcional al FINAL = decimales de esa columna (num. 2).
        // columnas: separadas por ';' — nombre de un VECTOR ya definido en la hoja (D = [12,8,5])·
        //   vector LITERAL [12,8,5]  ·  o texto literal {"A-1","A-2","B-1"} (columnas no numericas,
        //   p.ej. "Eje"). No pasa por el motor SBCL (como #beam/#fplot): es un RENDER, no una operacion.
        private sealed class TablaHeader { public string Text; public int Decimals = 2; }
        private sealed class TablaSpec { public List<TablaHeader> Headers; public List<string> ColTokens; }
        private sealed class TablaCol { public bool IsText; public List<string> Text; public List<string> RawNum; }

        private static readonly System.Text.RegularExpressions.Regex RxTabla = new System.Text.RegularExpressions.Regex(
            @"^\s*#\s*(?:tabla|table)\s*\((?<h>.*)\)\s*\((?<c>.*)\)\s*$",
            System.Text.RegularExpressions.RegexOptions.IgnoreCase | System.Text.RegularExpressions.RegexOptions.Singleline);

        private static TablaSpec ParseTablaDirective(string line)
        {
            var m = RxTabla.Match((line ?? "").Trim());
            if (!m.Success) return null;
            var headers = new List<TablaHeader>();
            foreach (var raw0 in SplitTopQ(m.Groups["h"].Value, ','))
            {
                var t = raw0.Trim();
                if (t.Length == 0) continue;
                if (t.Length >= 2 && t[0] == '"' && t[t.Length - 1] == '"') t = t.Substring(1, t.Length - 2);
                var dm = System.Text.RegularExpressions.Regex.Match(t, @"^(.*):(\d{1,2})$");
                var h = new TablaHeader();
                if (dm.Success) { h.Text = dm.Groups[1].Value.Trim(); h.Decimals = int.Parse(dm.Groups[2].Value); }
                else h.Text = t.Trim();
                headers.Add(h);
            }
            var cols = SplitTopQ(m.Groups["c"].Value, ';').Select(s => s.Trim()).Where(s => s.Length > 0).ToList();
            if (headers.Count == 0 || cols.Count == 0) return null;
            return new TablaSpec { Headers = headers, ColTokens = cols };
        }

        // resuelve UN token de columna: {"a","b"} texto · [1,2,3] vector literal · nombre = variable
        // YA definida en la hoja (busca la PRIMERA línea etiquetada con ese nombre y su resOf).
        private static TablaCol ResolveTablaColumn(string tok, string[] labels, string[] resOf)
        {
            tok = (tok ?? "").Trim();
            if (tok.Length >= 2 && tok[0] == '{' && tok[tok.Length - 1] == '}')
            {
                var items = SplitTopQ(tok.Substring(1, tok.Length - 2), ',')
                    .Select(s => { var v = s.Trim(); if (v.Length >= 2 && v[0] == '"' && v[v.Length - 1] == '"') v = v.Substring(1, v.Length - 2); return v; })
                    .ToList();
                return new TablaCol { IsText = true, Text = items };
            }
            LispConverter.N tree = null;
            if (tok.StartsWith("["))
            {
                try { tree = LispConverter.ParseMath(tok); } catch { }
            }
            else
            {
                for (int j = 0; j < labels.Length; j++)
                    if (labels[j] != null && string.Equals(labels[j], tok, StringComparison.OrdinalIgnoreCase) && !string.IsNullOrEmpty(resOf[j]))
                    { try { tree = LispConverter.ParseLisp(resOf[j]); } catch { } break; }
            }
            if (tree == null)   // no se encontro/parseo: se muestra el token TAL CUAL (visible, no revienta)
                return new TablaCol { IsText = true, Text = new List<string> { tok } };
            var items2 = tree.Op == "vec" ? tree.Items : new List<LispConverter.N> { tree };
            var raws = items2.Select(it => it != null && it.IsAtom ? it.Atom : LispConverter.ToLisp(it)).ToList();
            return new TablaCol { IsText = false, RawNum = raws };
        }

        // arma la tabla de resultados completa (columnas resueltas + broadcast de escalares + HTML).
        private static string BuildTablaResultados(TablaSpec spec, string[] labels, string[] resOf)
        {
            if (spec == null) return "";
            var cols = spec.ColTokens.Select(t => ResolveTablaColumn(t, labels, resOf)).ToList();
            int nCols = Math.Min(spec.Headers.Count, cols.Count);
            int nRows = 0;
            for (int c = 0; c < nCols; c++)
                nRows = Math.Max(nRows, cols[c].IsText ? cols[c].Text.Count : cols[c].RawNum.Count);
            // broadcast: una columna de UN solo valor (escalar) se repite en todas las filas
            for (int c = 0; c < nCols; c++)
            {
                var col = cols[c];
                if (col.IsText && col.Text.Count == 1 && nRows > 1) col.Text = Enumerable.Repeat(col.Text[0], nRows).ToList();
                if (!col.IsText && col.RawNum != null && col.RawNum.Count == 1 && nRows > 1) col.RawNum = Enumerable.Repeat(col.RawNum[0], nRows).ToList();
            }
            var aligns = new List<string>();
            var headerHtml = new List<string>();
            for (int c = 0; c < nCols; c++)
            {
                aligns.Add(cols[c].IsText ? "txt" : "num");
                headerHtml.Add(LispConverter.FormatInlineText(spec.Headers[c].Text, _ => null));
            }
            var rows = new List<List<string>>();
            for (int r = 0; r < nRows; r++)
            {
                var row = new List<string>();
                for (int c = 0; c < nCols; c++)
                {
                    var col = cols[c];
                    if (col.IsText)
                        row.Add(LispConverter.FormatInlineText(r < col.Text.Count ? col.Text[r] : "", _ => null));
                    else
                        row.Add(r < col.RawNum.Count ? LispConverter.FormatNumCell(col.RawNum[r], spec.Headers[c].Decimals) : "");
                }
                rows.Add(row);
            }
            return LispConverter.BuildTable(null, aligns, headerHtml, rows);
        }

        // ---------- TABLAS de TEXTO escritas a mano en comentarios:  #| A | B |  /  #|---|---:| ----------
        // Fila de encabezado #|…|…| SEGUIDA de una fila separadora #|---|---:| (markdown): las filas
        // de abajo, también #|…|…|, son los datos. Alineación por columna, estándar markdown:
        // ':---' o '---' = izquierda (texto) · '---:' = derecha (número, con el color de m-num) ·
        // ':---:' = centro. Una línea "#| texto centrado" SUELTA (sin más '|' ni separadora detrás)
        // sigue siendo la prosa centrada de siempre — no se toca.
        private static readonly System.Text.RegularExpressions.Regex RxTablaSep = new System.Text.RegularExpressions.Regex(
            @"^\s*:?-{1,}:?\s*(\|\s*:?-{1,}:?\s*)*\|?\s*$");

        private static void ExtractManualTables(string[] lines, string[] manualTables)
        {
            for (int i = 0; i < lines.Length - 1; i++)
            {
                var l0 = lines[i].TrimStart();
                if (!l0.StartsWith("#|")) continue;
                var rest0 = l0.Substring(2);
                if (!rest0.Contains('|')) continue;              // "#| texto centrado" suelto: no es tabla
                var l1 = lines[i + 1].TrimStart();
                if (!l1.StartsWith("#|")) continue;
                var rest1 = l1.Substring(2);
                if (!RxTablaSep.IsMatch(rest1)) continue;         // la 2a fila no es la separadora ---|---
                var header = rest0.Split('|').Select(c => c.Trim()).ToList();
                while (header.Count > 0 && header[header.Count - 1].Length == 0) header.RemoveAt(header.Count - 1);
                var sepCells = rest1.Split('|').Select(c => c.Trim()).ToList();
                var alignKinds = new List<string>();
                for (int c = 0; c < header.Count; c++)
                {
                    var a = c < sepCells.Count ? sepCells[c] : "-";
                    bool lft = a.StartsWith(":"); bool rgt = a.EndsWith(":");
                    alignKinds.Add(lft && rgt ? "center" : rgt ? "num" : "txt");
                }
                var rows = new List<List<string>>();
                int j = i + 2;
                for (; j < lines.Length; j++)
                {
                    var lj = lines[j].TrimStart();
                    if (!lj.StartsWith("#|")) break;
                    var restj = lj.Substring(2);
                    if (!restj.Contains('|')) break;
                    var celdas = restj.Split('|').Select(c => c.Trim()).ToList();
                    while (celdas.Count > 0 && celdas[celdas.Count - 1].Length == 0) celdas.RemoveAt(celdas.Count - 1);   // pipe final -> celda vacia de mas
                    rows.Add(celdas);
                }
                // serializa (se re-arma en RebuildManualTable, DESPUES de FormatInlineText por celda):
                //   aligns\x05aligns... \x04 header\x05header... \x04 fila1\x05fila1... \x04 fila2...
                var payload = string.Join("\x05", alignKinds) + "\x04" + string.Join("\x05", header) + "\x04"
                            + string.Join("\x04", rows.Select(r => string.Join("\x05", r)));
                manualTables[i] = payload;
                for (int k = i + 1; k < j; k++) lines[k] = "";   // separadora + filas: consumidas, quedan en blanco
                i = j - 1;                                        // continua DESPUES del bloque
            }
        }

        // reconstruye la tabla ya con cada celda pasada por FormatInlineText (negrita/@var/sub-sup).
        private static string RebuildManualTable(string payloadFormateado)
        {
            var parts = payloadFormateado.Split('\x04');
            if (parts.Length < 2) return payloadFormateado;
            var aligns = parts[0].Split('\x05').ToList();
            var header = parts[1].Split('\x05').ToList();
            var rows = parts.Skip(2).Select(r => r.Split('\x05').ToList()).ToList();
            return LispConverter.BuildTable(null, aligns, header, rows);
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
            var dots = new List<(string name, double[] xs, double[] ys)>();
            var paren = System.Text.RegularExpressions.Regex.Match(rest, @"^\((.*)\)\s*$", System.Text.RegularExpressions.RegexOptions.Singleline);
            if (paren.Success)   // estilo MATLAB: fplot(N1, N2, [-1 1])
            {
                foreach (var a0 in SplitTop(paren.Groups[1].Value))
                {
                    var a = a0.Trim(); if (a.Length == 0) continue;
                    // PUNTOS sueltos:  SAP2000 = [x1 y1; x2 y2]  (datos encima de las curvas)
                    var dm = System.Text.RegularExpressions.Regex.Match(a, @"^([A-Za-z][\w']*)\s*=\s*\[([^\[\]]*)\]$");
                    if (dm.Success && TryPuntos(dm.Groups[2].Value, inv, out var pxs, out var pys)) { dots.Add((dm.Groups[1].Value, pxs, pys)); continue; }
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
            if (sel.Count == 0 && dots.Count == 0) sel = new List<(string, LispConverter.N)>(fns);   // sin argumentos → todas
            if (sel.Count == 0 && dots.Count == 0) return "";
            string var = forcedVar ?? (sel.Count > 0 ? LispConverter.FreeVar(sel[0].Item2) : "x");
            return LispConverter.PlotSvg(var, lo, hi, sel, dots) ?? "";
        }

        // "x1 y1; x2 y2" (o con comas) → dos vectores. Admite fracciones a/b. Cada fila = un punto.
        private static bool TryPuntos(string body, System.Globalization.CultureInfo inv, out double[] xs, out double[] ys)
        {
            var lx = new List<double>(); var ly = new List<double>();
            xs = ys = null;
            foreach (var fila in body.Split(';'))
            {
                var t = fila.Trim(); if (t.Length == 0) continue;
                var nums = System.Text.RegularExpressions.Regex.Split(t, @"[\s,]+");
                if (nums.Length != 2) return false;
                var v = new double[2];
                for (int k = 0; k < 2; k++)
                {
                    var q = nums[k].Split('/');
                    if (q.Length == 2 && double.TryParse(q[0], System.Globalization.NumberStyles.Any, inv, out var q1)
                        && double.TryParse(q[1], System.Globalization.NumberStyles.Any, inv, out var q2) && q2 != 0) v[k] = q1 / q2;
                    else if (!double.TryParse(nums[k], System.Globalization.NumberStyles.Any, inv, out v[k])) return false;
                }
                lx.Add(v[0]); ly.Add(v[1]);
            }
            if (lx.Count == 0) return false;
            xs = lx.ToArray(); ys = ly.ToArray(); return true;
        }

        // Construye TODAS las gráficas EN ORDEN de aparición (fplot / surf / map mezclados), una por
        // directiva. El resultado va, en ese orden, a rellenar los huecos hk-plotslot del documento.
        private static readonly System.Text.RegularExpressions.Regex RxAnyPlot = new System.Text.RegularExpressions.Regex(
            @"^\s*[;#]+\s*(anim|animar|animacion|slider|barra_deslizante|deslizador|gauss|cuadratura|gausslegendre|fila|finfila|fplot|plot|ezplot|graficas?|grafico|surf|superficie|plot3d|mesh|malla|mallado|map|mapa|heatmap|contourf?|beam|viga|esquema|frame|portico|framedef|porticodef|slice|trozo|elemento|defl|diag|vmd|bar1d|barra|elem1d|punto|dotprod|producto|dot|recta|ab|interceptopendiente|mapa1d|xdexi|mapnatural|salto|pagebreak|nuevapagina|pagina|solido|solid|hexa|solidmesh|newpage)\b(.*)$",
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
            bool enFila = false; int idxFila = -1;   // #fila … #finfila: gráficas lado a lado
            void CerrarFila()
            {
                if (idxFila >= 0 && idxFila < outList.Count && !string.IsNullOrEmpty(outList[idxFila]))
                    outList[idxFila] = "<div class=\"hk-lado\">" + outList[idxFila] + "</div>";
                idxFila = -1;
            }
            foreach (var lineRaw in (editorText ?? "").Replace("\r", "").Split('\n'))
            {
                var mm = RxAnyPlot.Match(lineRaw);
                if (!mm.Success) continue;
                CerrarFila();
                string kw = mm.Groups[1].Value.ToLowerInvariant();
                if (kw is "fila" or "finfila") { enFila = kw == "fila"; outList.Add(""); continue; }
                if (enFila) idxFila = outList.Count;
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
                if (kw is "anim" or "animar" or "animacion")
                {
                    try { outList.Add(AnimHtml(rest, byName, fns, inv)); } catch { outList.Add(""); }
                    continue;
                }
                // #slider: lo MISMO que #anim, pero el cuadro lo elige el usuario con una barra.
                // 20-sep-2026, Jorge: «no usas gráficas con slider». En una clase hace falta PARAR
                // en un valor y hablar de él; la animación automática no deja.
                if (kw is "slider" or "barra_deslizante" or "deslizador")
                {
                    try { outList.Add(SliderHtml(rest, byName, fns, inv)); } catch { outList.Add(""); }
                    continue;
                }
                // #gauss / #gauss(porque): la cuadratura de Gauss, interactiva.
                if (kw is "gauss" or "cuadratura" or "gausslegendre")
                {
                    try { outList.Add(GaussHtml(rest)); } catch { outList.Add(""); }
                    continue;
                }
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
                    // hoja numérica: #malla(x_j, y_j, e_j, s_j) con los datos del modelo
                    var pmz = System.Text.RegularExpressions.Regex.Match(rest, @"^\((.*)\)\s*$", System.Text.RegularExpressions.RegexOptions.Singleline);
                    if (pmz.Success && _numMeshes != null && _numMeshes.TryGetValue(pmz.Groups[1].Value.Trim(), out var mdat))
                    {
                        try
                        {
                            string b64m = SurfacePlot.MeshPngData(mdat.X, mdat.Y, mdat.Elem, mdat.Apoyos, dark);
                            outList.Add(PlotWrap("<img src=\"data:image/png;base64," + b64m + "\" style=\"max-width:100%\">",
                                                 "malla del modelo: nudos, elementos y apoyos"));
                        }
                        catch { outList.Add(""); }
                        continue;
                    }
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
                    // hoja numérica: la rejilla ya la calculó el motor numérico (funciones de la hoja,
                    // spline de una matriz de resultados…) — aquí solo se pinta
                    if (isMap && _numGrids != null && _numGrids.TryGetValue(pm.Groups[1].Value.Trim(), out var rej))
                    {
                        try
                        {
                            string b64 = SurfacePlot.MapPngGrid(rej.Z, rej.N, rej.Xa, rej.Xb, rej.Ya, rej.Yb, dark, isCont, isCont ? 12 : 0);
                            anySurf = true;
                            string img = "<img style=\"max-width:100%;height:auto\" src=\"data:image/png;base64," + b64 + "\">";
                            string spec0 = System.Net.WebUtility.HtmlEncode(SplitTop(pm.Groups[1].Value).FirstOrDefault()?.Trim() ?? "");
                            outList.Add(PlotWrap(SurfacePlot.MapHoverGrid(rej.Z, rej.N, "x", "y", rej.Xa, rej.Xb, rej.Ya, rej.Yb, img,
                                                                           SurfacePlot.AltoProporcional(rej.Xa, rej.Xb, rej.Ya, rej.Yb)),
                                                 "mapa de  " + spec0 + "  (planta)"));
                        }
                        catch { outList.Add(""); }
                        continue;
                    }
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
            CerrarFila();
            return outList;
        }

        // #anim fplot(u = expr(x,n), [0 1]), n = 1:8   → la MISMA gráfica para cada valor del
        // parámetro, una tras otra (animación CSS pura: sin JS, funciona igual en la web y en la
        // app local). Pasar el ratón por encima la PAUSA. Paso opcional: n = 1:2:15.
        private static int _animId;
        private static string AnimHtml(string rest, Dictionary<string, LispConverter.N> byName,
                                       List<(string, LispConverter.N)> fns, System.Globalization.CultureInfo inv)
        {
            var R = System.Text.RegularExpressions.Regex.Match((rest ?? "").Trim(),
                @"^(.*),\s*([A-Za-z]\w*)\s*=\s*(-?[\d.]+)\s*:\s*(-?[\d.]+)\s*(?::\s*(-?[\d.]+))?\s*$",
                System.Text.RegularExpressions.RegexOptions.Singleline);
            if (!R.Success) return "";
            string plot = R.Groups[1].Value.Trim(), par = R.Groups[2].Value;
            double a = double.Parse(R.Groups[3].Value, inv), b = double.Parse(R.Groups[4].Value, inv), st = 1;
            if (R.Groups[5].Success) { st = b; b = double.Parse(R.Groups[5].Value, inv); }
            if (st <= 0 || b < a) return "";
            // se admite "fplot(...)" o directamente "(...)"
            plot = System.Text.RegularExpressions.Regex.Replace(plot, @"^(?:fplot|plot|ezplot)\s*(?=\()", "",
                System.Text.RegularExpressions.RegexOptions.IgnoreCase);
            var vals = new List<double>();
            for (double v = a; v <= b + st * 1e-9 && vals.Count < 60; v += st) vals.Add(v);
            if (vals.Count == 0) return "";
            int id = System.Threading.Interlocked.Increment(ref _animId);
            double dt = 1.2, T = dt * vals.Count;
            string P(double v) => v.ToString("0.####", inv);
            double on = 100.0 / vals.Count;
            var sb = new StringBuilder();
            sb.Append("<style>@keyframes hkan").Append(id).Append("{0%{opacity:1}")
              .Append(P(on - 0.01)).Append("%{opacity:1}").Append(P(on)).Append("%{opacity:0}100%{opacity:0}}")
              .Append(".hkan").Append(id).Append(":hover .hkfr{animation-play-state:paused}</style>");
            sb.Append("<div class=\"hkan").Append(id).Append("\" style=\"display:grid;margin:1.1em 0\" title=\"ratón encima = pausa\">");
            for (int i = 0; i < vals.Count; i++)
            {
                string sv = P(vals[i]);
                string sub = System.Text.RegularExpressions.Regex.Replace(plot,
                    @"(?<![\w.])" + System.Text.RegularExpressions.Regex.Escape(par) + @"(?![\w(])", "(" + sv + ")");
                sb.Append("<div class=\"hkfr\" style=\"grid-area:1/1;opacity:").Append(i == 0 ? "1" : "0")
                  .Append(";animation:hkan").Append(id).Append(' ').Append(P(T)).Append("s linear infinite;animation-delay:")
                  .Append(P(i * dt)).Append("s;text-align:center\">")
                  .Append(OneFplotHtml(sub, byName, fns, inv))
                  .Append("<div style=\"color:var(--fg);font-size:1em;margin-top:.2em\"><i>")
                  .Append(System.Net.WebUtility.HtmlEncode(par)).Append("</i> = ").Append(sv)
                  .Append("  <span style=\"color:var(--mut);font-size:.85em\">(").Append(i + 1).Append('/').Append(vals.Count)
                  .Append(")</span></div></div>");
            }
            sb.Append("</div>");
            return sb.ToString();
        }

        private static int _sliderId;
        private static int _gaussId;

        /// <summary>#slider fplot(u = expr(x,n), [a b]), n = 1:8  → los MISMOS cuadros que #anim,
        /// pero el usuario elige cuál ver con una barra. Los cuadros los calcula el motor una vez
        /// (no hay matemática en JS): la barra solo enseña uno y esconde los demás.</summary>
        private static string SliderHtml(string rest, Dictionary<string, LispConverter.N> byName,
                                         List<(string, LispConverter.N)> fns, System.Globalization.CultureInfo inv)
        {
            var R = System.Text.RegularExpressions.Regex.Match((rest ?? "").Trim(),
                @"^(.*),\s*([A-Za-z]\w*)\s*=\s*(-?[\d.]+)\s*:\s*(-?[\d.]+)\s*(?::\s*(-?[\d.]+))?\s*$",
                System.Text.RegularExpressions.RegexOptions.Singleline);
            if (!R.Success) return "";
            string plot = R.Groups[1].Value.Trim(), par = R.Groups[2].Value;
            double a = double.Parse(R.Groups[3].Value, inv), b = double.Parse(R.Groups[4].Value, inv), st = 1;
            if (R.Groups[5].Success) { st = b; b = double.Parse(R.Groups[5].Value, inv); }
            if (st <= 0 || b < a) return "";
            plot = System.Text.RegularExpressions.Regex.Replace(plot, @"^(?:fplot|plot|ezplot)\s*(?=\()", "",
                System.Text.RegularExpressions.RegexOptions.IgnoreCase);
            var vals = new List<double>();
            for (double v = a; v <= b + st * 1e-9 && vals.Count < 60; v += st) vals.Add(v);
            if (vals.Count == 0) return "";
            int id = System.Threading.Interlocked.Increment(ref _sliderId);
            string P(double v) => v.ToString("0.####", inv);
            var sb = new StringBuilder();
            int ini = vals.Count / 2;       // se entra por el cuadro de en medio, no por el primero
            sb.Append("<div class=\"hksl\" id=\"hksl").Append(id).Append("\" style=\"margin:1.1em 0;text-align:center\">");
            sb.Append("<div style=\"display:grid\">");
            for (int i = 0; i < vals.Count; i++)
            {
                string sv = P(vals[i]);
                string sub = System.Text.RegularExpressions.Regex.Replace(plot,
                    @"(?<![\w.])" + System.Text.RegularExpressions.Regex.Escape(par) + @"(?![\w(])", "(" + sv + ")");
                sb.Append("<div class=\"hkfr\" style=\"grid-area:1/1;visibility:").Append(i == ini ? "visible" : "hidden")
                  .Append("\">").Append(OneFplotHtml(sub, byName, fns, inv)).Append("</div>");
            }
            sb.Append("</div>");
            // El título va en su propio div (NO un <label> alrededor del input): envolviendo el
            // input, el arrastre de la barra se rompe en algunos navegadores.
            sb.Append("<div style=\"max-width:520px;margin:.5em auto 0\">")
              .Append("<div style=\"color:var(--fg);font-size:1em;margin-bottom:.15em\"><i>")
              .Append(System.Net.WebUtility.HtmlEncode(par)).Append("</i> = <b class=\"hkval\">").Append(P(vals[0]))
              .Append("</b></div>")
              .Append("<input type=\"range\" min=\"0\" max=\"").Append(vals.Count - 1)
              .Append("\" value=\"").Append(ini).Append("\" step=\"1\" style=\"display:block;width:100%\">")
              .Append("<div style=\"display:flex;justify-content:space-between;color:var(--mut);font-size:.85em\"><span>")
              .Append(P(vals[0])).Append("</span><span>arrastra</span><span>").Append(P(vals[vals.Count - 1]))
              .Append("</span></div></div>");
            sb.Append("<script>(function(){var c=document.getElementById('hksl").Append(id).Append("');")
              .Append("var f=c.querySelectorAll('.hkfr'),r=c.querySelector('input'),v=c.querySelector('.hkval');")
              .Append("var V=[").Append(string.Join(",", vals.ConvertAll(x => "'" + P(x) + "'"))).Append("];")
              .Append("function u(){var i=+r.value;for(var k=0;k<f.length;k++)f[k].style.visibility=(k===i?'visible':'hidden');v.textContent=V[i];}")
              .Append("r.addEventListener('input',u);r.addEventListener('change',u);u();})();</script>");
            sb.Append("</div>");
            return sb.ToString();
        }

        /// <summary>#gauss  ·  #gauss(porque)  — la cuadratura de Gauss, para tocarla.
        ///
        /// Integrar = área. Gauss dice: el área es una SUMA de pesos por alturas, w·f(ξ), donde
        /// los ξ y los w no se eligen a ojo: se eligen para que la fórmula sea EXACTA con los
        /// polinomios más altos posibles (grado 2n−1 con n puntos).
        ///  · modo normal: barras para n (puntos) y para el grado del polinomio; se ve dónde deja
        ///    de ser exacta.
        ///  · modo «porque»: de dónde sale el ±0.5774 — se mueve el punto y se ve el error caer a 0.
        /// El dibujo es un canvas con JS propio (no SkiaSharp): tiene que responder al arrastre.</summary>
        private static string GaussHtml(string rest)
        {
            string arg = (rest ?? "").ToLowerInvariant();
            bool porque = arg.Contains("porque") || arg.Contains("por que") || arg.Contains("deduc");
            // 21-sep-2026, Jorge: «la posicion de cada rectangulo y sus valores: necesito
            // entender todas las variables» y «las 4 incognitas para encontrar xi con dos
            // puntos no esta». De ahi estos dos modos.
            bool vars = arg.Contains("vars") || arg.Contains("variables") || arg.Contains("tabla");
            bool sist = arg.Contains("sistema") || arg.Contains("incognita");
            int id = System.Threading.Interlocked.Increment(ref _gaussId);
            string q = "g" + id;
            var sb = new StringBuilder();
            sb.Append("<div id=\"").Append(q).Append("\" style=\"margin:1.1em auto;max-width:1260px;text-align:center\">");
            sb.Append("<canvas class=\"cv\" width=\"1400\" height=\"470\" style=\"width:100%;height:auto\"></canvas>");
            if (sist)
            {
                // CUATRO barras para CUATRO incognitas: se ve que solo una combinacion
                // cumple las cuatro condiciones a la vez.
                sb.Append(Fila("x1", "<i>&xi;</i><sub>1</sub> = <b class=\"vx1\">-0.300</b>",
                               "-990", "990", "-300", "-0.99", "0.99"));
                sb.Append(Fila("x2", "<i>&xi;</i><sub>2</sub> = <b class=\"vx2\">0.300</b>",
                               "-990", "990", "300", "-0.99", "0.99"));
                sb.Append(Fila("w1", "<i>w</i><sub>1</sub> = <b class=\"vw1\">0.60</b>",
                               "1", "200", "60", "0.01", "2.00"));
                sb.Append(Fila("w2", "<i>w</i><sub>2</sub> = <b class=\"vw2\">0.60</b>",
                               "1", "200", "60", "0.01", "2.00"));
                sb.Append("<div class=\"rd\"></div>");
            }
            else if (porque)
            {
                sb.Append(Fila("a", "posición de los dos puntos &nbsp;<i>&xi;</i> = &plusmn;<b class=\"va\">0.300</b>",
                               "10", "990", "300", "0.01", "0.99"));
                sb.Append("<div class=\"rd\"></div>");
            }
            else
            {
                sb.Append(Fila("n", "puntos de Gauss &nbsp;n = <b class=\"vn\">2</b>", "1", "5", "2", "1", "5"));
                sb.Append(Fila("g", "grado del polinomio &nbsp;p = <b class=\"vg\">3</b>", "0", "7", "3", "0", "7"));
                if (vars)   // mover los rectángulos: 1.00 = donde los coloca Gauss
                    sb.Append(Fila("d", "mover los puntos &nbsp;&times;<b class=\"vd\">1.00</b>",
                                   "0", "170", "100", "0.00", "1.70"));
                sb.Append("<div class=\"rd\"></div>");
            }
            sb.Append("<style>#").Append(q).Append(" input{display:block;width:100%}")
              .Append("#").Append(q).Append(" .ttl{color:var(--fg);font-size:1em;margin:.45em 0 .1em}")
              .Append("#").Append(q).Append(" .ext{display:flex;justify-content:space-between;color:var(--mut);font-size:.85em}")
              .Append("#").Append(q).Append(" .rd{margin:.6em auto 0;max-width:1150px;background:#1d2333;color:#e8ecf5;")
              .Append("border-radius:9px;padding:.6em 1em;font:600 24px/1.4 Consolas,monospace;text-align:left}")
              .Append("#").Append(q).Append(" .ok{color:#7ee2a8}#").Append(q).Append(" .no{color:#ff9d7a}</style>");
            sb.Append("<script>")
              .Append(sist ? GaussJsSistema(q)
                     : porque ? GaussJsPorque(q)
                     : vars ? GaussJsVars(q) : GaussJsNormal(q))
              .Append("</script>");
            sb.Append("</div>");
            return sb.ToString();
        }

        private static string Fila(string cls, string titulo, string min, string max, string val, string ini, string fin) =>
            "<div style=\"max-width:520px;margin:0 auto\"><div class=\"ttl\">" + titulo + "</div>" +
            "<input class=\"s" + cls + "\" type=\"range\" min=\"" + min + "\" max=\"" + max + "\" value=\"" + val + "\" step=\"1\">" +
            "<div class=\"ext\"><span>" + ini + "</span><span>arrastra</span><span>" + fin + "</span></div></div>";

        // tabla de Gauss-Legendre n = 1..5 (puntos y pesos en [-1, 1]), compartida por los dos widgets
        private const string GaussTabla =
            "var GX=[[0],[-0.5773502692,0.5773502692],[-0.7745966692,0,0.7745966692]," +
            "[-0.8611363116,-0.3399810436,0.3399810436,0.8611363116]," +
            "[-0.9061798459,-0.5384693101,0,0.5384693101,0.9061798459]];" +
            "var GW=[[2],[1,1],[0.5555555556,0.8888888889,0.5555555556]," +
            "[0.3478548451,0.6521451549,0.6521451549,0.3478548451]," +
            "[0.2369268851,0.4786286705,0.5688888889,0.4786286705,0.2369268851]];";

        // dibujo común: ejes de ξ ∈ [−1,1] y de f, con la curva
        private const string GaussComun = @"
var C=c.querySelector('.cv'),X=C.getContext('2d');
var css=getComputedStyle(document.documentElement);
function col(n,d){var v=css.getPropertyValue(n).trim();return v||d;}
var FG=col('--fg','#171310'),MUT=col('--mut','#544d3a'),AZ=col('--dib-azul','#1c5fbf'),
    NAR=col('--dib-nar','#d9480f'),VER=col('--dib-verde','#2b8a3e');
var L=150,R=1330,T=22,B=316;                      // marco del dibujo en pixeles
function px(x){return L+(x+1.25)/2.5*(R-L);}          // xi (-1..1)  -> pixel
function py(y,ymin,ymax){return B-(y-ymin)/(ymax-ymin)*(B-T);}
function ejes(ymin,ymax,rot){
  X.clearRect(0,0,C.width,C.height);
  X.strokeStyle=MUT;X.lineWidth=2.5;X.font='30px Segoe UI';X.fillStyle=MUT;X.textAlign='center';
  var y0=py(0,ymin,ymax);
  X.beginPath();X.moveTo(L,y0);X.lineTo(R,y0);X.stroke();
  X.beginPath();X.moveTo(L,T);X.lineTo(L,B);X.stroke();
  [-1,-0.5,0,0.5,1].forEach(function(t){
    X.beginPath();X.moveTo(px(t),y0-7);X.lineTo(px(t),y0+7);X.stroke();
    X.fillText(t.toFixed(1),px(t),y0+34);});
  X.fillText(rot||'ξ',(L+R)/2,B+120);
}
function curva(f,ymin,ymax){
  X.strokeStyle=AZ;X.lineWidth=4;X.beginPath();
  for(var i=0;i<=400;i++){var t=-1+2*i/400,Y=py(f(t),ymin,ymax);
    if(i===0)X.moveTo(px(t),Y);else X.lineTo(px(t),Y);}
  X.stroke();
}
function area(f,ymin,ymax){                       // el area EXACTA, sombreada
  X.fillStyle='rgba(28,95,191,.13)';X.beginPath();X.moveTo(px(-1),py(0,ymin,ymax));
  for(var i=0;i<=400;i++){var t=-1+2*i/400;X.lineTo(px(t),py(f(t),ymin,ymax));}
  X.lineTo(px(1),py(0,ymin,ymax));X.closePath();X.fill();
}";

        private static string GaussJsNormal(string q) => "(function(){var c=document.getElementById('" + q + "');" +
            GaussTabla + GaussComun + @"
var sn=c.querySelector('.sn'),sg=c.querySelector('.sg'),rd=c.querySelector('.rd'),
    vn=c.querySelector('.vn'),vg=c.querySelector('.vg');
function dib(){
  var n=+sn.value, g=+sg.value;
  vn.textContent=n; vg.textContent=g;
  var f=function(t){return Math.pow((1+t)/2,g);};   // polinomio de grado g, entre 0 y 1
  var ex=2/(g+1);                                   // su integral exacta en [-1,1]
  var ap=0,xs=GX[n-1],ws=GW[n-1];
  for(var i=0;i<n;i++) ap+=ws[i]*f(xs[i]);
  var ymin=-0.12,ymax=1.15;
  ejes(ymin,ymax);
  area(f,ymin,ymax);
  // cada punto de Gauss = un RECTANGULO de ancho w_i y alto f(xi_i): su area ES w_i*f(xi_i),
  // por eso la suma de los rectangulos y el area bajo la curva se parecen tanto.
  for(var i=0;i<n;i++){
    var x0=xs[i]-ws[i]/2, x1=xs[i]+ws[i]/2, h=f(xs[i]);
    X.fillStyle='rgba(217,72,15,.22)';X.strokeStyle=NAR;X.lineWidth=3;
    var yt=py(h,ymin,ymax), yb=py(0,ymin,ymax);
    X.fillRect(px(x0),yt,px(x1)-px(x0),yb-yt);
    X.strokeRect(px(x0),yt,px(x1)-px(x0),yb-yt);
    X.beginPath();X.arc(px(xs[i]),yt,12,0,7);X.fillStyle=NAR;X.fill();
    X.fillStyle=FG;X.font='28px Segoe UI';X.textAlign='center';
    X.fillText('w='+ws[i].toFixed(3),px(xs[i]),yb+70);
    X.fillText('ξ='+xs[i].toFixed(4),px(xs[i]),yb+96);
  }
  curva(f,ymin,ymax);
  var err=Math.abs(ap-ex), exacto=(err<1e-9);
  rd.innerHTML='f(ξ) = ((1+ξ)/2)<sup>'+g+'</sup> &nbsp; grado '+g+
    '<br>exacta &nbsp;∫ f dξ = '+ex.toFixed(6)+
    '<br>Gauss &nbsp;Σ w<sub>i</sub>·f(ξ<sub>i</sub>) = '+ap.toFixed(6)+
    '<br>error = '+err.toFixed(6)+' &nbsp; '+
    (exacto?'<span class=""ok"">EXACTO</span>':'<span class=""no"">ya no alcanza</span>')+
    '<br>con n = '+n+' puntos es exacto hasta grado 2n−1 = '+(2*n-1);
}
sn.addEventListener('input',dib);sn.addEventListener('change',dib);
sg.addEventListener('input',dib);sg.addEventListener('change',dib);dib();})();";

        private static string GaussJsPorque(string q) => "(function(){var c=document.getElementById('" + q + "');" +
            GaussComun + @"
var sa=c.querySelector('.sa'),rd=c.querySelector('.rd'),va=c.querySelector('.va');
function dib(){
  var a=+sa.value/1000;                       // los dos puntos, en -a y +a, con peso 1 cada uno
  va.textContent=a.toFixed(3);
  var ymin=-0.12,ymax=1.15, f=function(t){return t*t;};
  ejes(ymin,ymax);
  area(f,ymin,ymax);
  [-a,a].forEach(function(xi){
    var x0=xi-0.5,x1=xi+0.5,h=f(xi);
    var yt=py(h,ymin,ymax),yb=py(0,ymin,ymax);
    X.fillStyle='rgba(217,72,15,.22)';X.strokeStyle=NAR;X.lineWidth=3;
    X.fillRect(px(x0),yt,px(x1)-px(x0),yb-yt);X.strokeRect(px(x0),yt,px(x1)-px(x0),yb-yt);
    X.beginPath();X.arc(px(xi),yt,12,0,7);X.fillStyle=NAR;X.fill();
    X.fillStyle=FG;X.font='28px Segoe UI';X.textAlign='center';
    X.fillText('ξ='+xi.toFixed(4),px(xi),yb+70);
  });
  curva(f,ymin,ymax);
  var s2=2*a*a, e2=Math.abs(s2-2/3);          // la unica condicion que no sale sola
  function fila(t,ex,ap){var ok=Math.abs(ex-ap)<1.5e-3;
    return '<br>'+t+' : exacta '+ex.toFixed(4)+' &nbsp; Gauss '+ap.toFixed(4)+' &nbsp; '+
      (ok?'<span class=""ok"">&#10003;</span>':'<span class=""no"">&#10007;</span>');}
  rd.innerHTML='dos puntos en ±'+a.toFixed(4)+', pesos 1 y 1 → cuatro condiciones:'+
    fila('f = 1 &nbsp;&nbsp;',2,2)+
    fila('f = ξ &nbsp;&nbsp;',0,0)+
    fila('f = ξ² &nbsp;',2/3,s2)+
    fila('f = ξ³ &nbsp;',0,0)+
    '<br>error en ξ² = '+e2.toFixed(6)+
    (e2<1.5e-3?' &nbsp;<span class=""ok"">2a² = 2/3 → a = 1/√3 = 0.5774</span>':'');
}
sa.addEventListener('input',dib);sa.addEventListener('change',dib);dib();})();";

        /// <summary>#gauss(vars): la misma cuadratura, pero enseñando TODAS las variables de
        /// cada punto: dónde empieza y acaba su rectángulo, su peso, su altura y su aporte.</summary>
        /// <summary>#gauss(vars): la cuadratura con TODAS sus variables a la vista —el ancho
        /// de cada rectángulo (su peso), su altura (la función) y su aporte— y con los puntos
        /// movibles, para ver que solo en el sitio de Gauss el número sale exacto.</summary>
        private static string GaussJsVars(string q) => "(function(){var c=document.getElementById('" + q + "');" +
            GaussTabla + GaussComun + @"
var sn=c.querySelector('.sn'),sg=c.querySelector('.sg'),sd=c.querySelector('.sd'),
    rd=c.querySelector('.rd'),vn=c.querySelector('.vn'),vg=c.querySelector('.vg'),
    vd=c.querySelector('.vd');
function cota(x0,x1,y,txt){            // la cota del ancho, con sus flechas y el numero
  var a=px(x0), b=px(x1);
  X.strokeStyle=VER;X.fillStyle=VER;X.lineWidth=3;
  X.beginPath();X.moveTo(a,y);X.lineTo(b,y);X.stroke();
  [[a,1],[b,-1]].forEach(function(p){
    X.beginPath();X.moveTo(p[0],y);X.lineTo(p[0]+12*p[1],y-7);X.lineTo(p[0]+12*p[1],y+7);
    X.closePath();X.fill();});
  X.font='26px Segoe UI';X.textAlign='center';
  X.fillText(txt,(a+b)/2,y-14);
}
function dib(){
  var n=+sn.value, g=+sg.value, k=(sd? +sd.value/100 : 1);
  vn.textContent=n; vg.textContent=g; if(vd) vd.textContent=k.toFixed(2);
  var f=function(t){return Math.pow((1+t)/2,g);};
  var ex=2/(g+1), ap=0, xs0=GX[n-1], ws=GW[n-1];
  // los puntos, movidos por la barra: k = 1 es donde los pone Gauss
  var xs=xs0.map(function(x){ return n===1 ? (k-1)*0.9 : x*k; });
  var ymin=-0.12,ymax=1.15;
  ejes(ymin,ymax); area(f,ymin,ymax);
  var filas='<table style=""width:100%;border-collapse:collapse;font-size:24px"">'+
    '<tr style=""color:#9fb0d0""><td>i</td><td>xi_i</td><td>ancho w_i</td>'+
    '<td>alto f(xi_i)</td><td>area w_i*f</td><td>su tramo</td></tr>';
  // Cada punto representa un TRAMO del intervalo, de ancho igual a su peso. Los
  // tramos van uno detrás de otro desde -1, así que cubren [-1, 1] y el dibujo
  // nunca se sale del elemento (antes el rectángulo iba centrado en el punto y
  // al moverlo sobrepasaba el +1).
  var borde=-1;
  for(var i=0;i<n;i++){
    var x0=borde, x1=borde+ws[i]; borde=x1;
    var h=f(xs[i]), apo=ws[i]*h; ap+=apo;
    var yt=py(h,ymin,ymax), yb=py(0,ymin,ymax);
    X.fillStyle='rgba(217,72,15,.22)';X.strokeStyle=NAR;X.lineWidth=3;
    X.fillRect(px(x0),yt,px(x1)-px(x0),yb-yt);
    X.strokeRect(px(x0),yt,px(x1)-px(x0),yb-yt);
    // el punto, sobre la curva, y su plomada hasta el eje
    X.strokeStyle=NAR;X.lineWidth=2;X.setLineDash([7,6]);
    X.beginPath();X.moveTo(px(xs[i]),yb);X.lineTo(px(xs[i]),yt);X.stroke();X.setLineDash([]);
    X.beginPath();X.arc(px(xs[i]),yt,12,0,7);X.fillStyle=NAR;X.fill();
    X.fillStyle=FG;X.font='28px Segoe UI';X.textAlign='center';
    X.fillText('xi='+xs[i].toFixed(4),px(xs[i]),yb+62);
    cota(x0,x1,yb+96,'ancho = '+ws[i].toFixed(4));
    filas+='<tr><td>'+(i+1)+'</td><td>'+xs[i].toFixed(4)+'</td><td>'+ws[i].toFixed(4)+
           '</td><td>'+h.toFixed(4)+'</td><td>'+apo.toFixed(4)+'</td><td>'+x0.toFixed(3)+
           ' a '+x1.toFixed(3)+'</td></tr>';
  }
  filas+='</table>';
  curva(f,ymin,ymax);
  var err=Math.abs(ap-ex), anchos=0;
  for(var j=0;j<n;j++) anchos+=ws[j];
  var sitio=Math.abs(k-1)<0.005
    ? '<span class=""ok"">los puntos están donde los pone Gauss</span>'
    : '<span class=""no"">los has movido (x'+k.toFixed(2)+'): ya no es el sitio de Gauss</span>';
  rd.innerHTML='f(xi) = ((1+xi)/2)^'+g+filas+
    'suma de las areas = '+ap.toFixed(6)+' &nbsp; exacta = '+ex.toFixed(6)+
    ' &nbsp; error = '+err.toFixed(6)+' '+
    (err<1e-9?'<span class=""ok"">EXACTO</span>':'<span class=""no"">no cuadra</span>')+
    '<br>'+sitio+' &nbsp;·&nbsp; los anchos suman '+anchos.toFixed(4)+' = el ancho del intervalo';
}
[sn,sg,sd].forEach(function(e){ if(e){ e.addEventListener('input',dib); e.addEventListener('change',dib);} });
dib();})();";

        /// <summary>#gauss(sistema): las CUATRO incógnitas de dos puntos —xi1, xi2, w1, w2—,
        /// una barra por incógnita, y las cuatro condiciones que deben cumplirse a la vez.</summary>
        private static string GaussJsSistema(string q) => "(function(){var c=document.getElementById('" + q + "');" +
            GaussComun + @"
var s1=c.querySelector('.sx1'),s2=c.querySelector('.sx2'),
    q1=c.querySelector('.sw1'),q2=c.querySelector('.sw2'),rd=c.querySelector('.rd'),
    v1=c.querySelector('.vx1'),v2=c.querySelector('.vx2'),
    u1=c.querySelector('.vw1'),u2=c.querySelector('.vw2');
function dib(){
  var x1=+s1.value/1000, x2=+s2.value/1000, w1=+q1.value/100, w2=+q2.value/100;
  v1.textContent=x1.toFixed(3); v2.textContent=x2.toFixed(3);
  u1.textContent=w1.toFixed(2); u2.textContent=w2.toFixed(2);
  var ymin=-0.12,ymax=1.15, f=function(t){return t*t;};
  ejes(ymin,ymax); area(f,ymin,ymax);
  var P=[[x1,w1],[x2,w2]], borde=-1;
  for(var i=0;i<2;i++){
    var xi=P[i][0], w=P[i][1], h=f(xi);
    var a0=borde, a1=borde+w; borde=a1;      // su tramo, de ancho = su peso
    var yt=py(h,ymin,ymax), yb=py(0,ymin,ymax);
    X.fillStyle='rgba(217,72,15,.22)';X.strokeStyle=NAR;X.lineWidth=3;
    X.fillRect(px(a0),yt,px(a1)-px(a0),yb-yt);
    X.strokeRect(px(a0),yt,px(a1)-px(a0),yb-yt);
    X.strokeStyle=NAR;X.lineWidth=2;X.setLineDash([7,6]);
    X.beginPath();X.moveTo(px(xi),yb);X.lineTo(px(xi),yt);X.stroke();X.setLineDash([]);
    X.beginPath();X.arc(px(xi),yt,12,0,7);X.fillStyle=NAR;X.fill();
    X.fillStyle=FG;X.font='28px Segoe UI';X.textAlign='center';
    X.fillText('xi'+(i+1)+'='+xi.toFixed(3),px(xi),yb+62);
    X.fillText('w'+(i+1)+'='+w.toFixed(2),px(xi),yb+108);
  }
  curva(f,ymin,ymax);
  var S=[w1+w2, w1*x1+w2*x2, w1*x1*x1+w2*x2*x2, w1*Math.pow(x1,3)+w2*Math.pow(x2,3)];
  var E=[2, 0, 2/3, 0];
  var N=['f = 1 &nbsp;&nbsp;','f = xi &nbsp;','f = xi^2','f = xi^3'];
  var txt='4 incógnitas: xi1, xi2, w1, w2 &nbsp;&rarr;&nbsp; 4 condiciones:', bien=0;
  for(var k=0;k<4;k++){
    var ok=Math.abs(S[k]-E[k])<2e-3; if(ok) bien++;
    txt+='<br>'+N[k]+' : suma = '+S[k].toFixed(4)+' &nbsp; debe ser '+E[k].toFixed(4)+' &nbsp; '+
         (ok?'<span class=""ok"">OK</span>':'<span class=""no"">no</span>');
  }
  txt+='<br>'+(bien===4
      ? '<span class=""ok"">LAS CUATRO A LA VEZ: xi = -+0.5774 y w = 1, 1</span>'
      : '<span class=""no"">cumples '+bien+' de 4</span>');
  rd.innerHTML=txt;
}
[s1,s2,q1,q2].forEach(function(s){s.addEventListener('input',dib);s.addEventListener('change',dib);});
dib();})();";

        // agrega una función: por NOMBRE ya deducido, o expresión MATLAB inline (1-s^2)
        private static void AddFn(List<(string, LispConverter.N)> sel, Dictionary<string, LispConverter.N> byName, string spec)
        {
            // etiqueta = expresión  →  la leyenda muestra la ETIQUETA (u_EF = …), no la fórmula larga
            var nm = System.Text.RegularExpressions.Regex.Match(spec, @"^([A-Za-z][\w']*)\s*=\s*(.+)$");
            if (nm.Success)
            {
                try { var tn = LispConverter.ParseMath(nm.Groups[2].Value); if (tn != null) { sel.Add((nm.Groups[1].Value, tn)); return; } } catch { }
            }
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
        /// Salida de cada bloque de control plegado, por numero de linea (ver PlegarBloques).
        private Dictionary<int, string> _salidasProg = new Dictionary<int, string>();

        /// <summary>
        /// Trocea una hoja que MEZCLA texto y bloques de control (for/while/if/function).
        ///
        /// Jorge, 21-sep-2026: «el for de MATLAB en la hoja no funciona». Y no era el
        /// `for`: era que en cuanto aparecia uno, TODA la hoja se traducia y se ejecutaba
        /// como un programa, devolviendo un solo valor. Titulo, textos y formulas
        /// desaparecian.
        ///
        /// Aqui se hace como Mathcad Prime (medido en un .mcdx real: `ml:program` con
        /// `ml:for` dentro): el bloque de control es UNA COSA dentro de la hoja, no un
        /// modo aparte. Cada bloque se pliega a una sola linea marcador, se ejecuta con
        /// las asignaciones que venian antes (para que vea sus variables) y su salida se
        /// guarda para pintarla en ese sitio. El resto de la hoja sigue su camino de
        /// siempre, linea a linea.
        /// </summary>
        // ------------------------- HOJA NUMÉRICA (#numerico) -------------------------
        private static readonly System.Text.RegularExpressions.Regex RxNumerico = new System.Text.RegularExpressions.Regex(
            @"(?im)^[ \t]*#[ \t]*(numerico|numérico|numeric|calcpad)[ \t]*\r?$");
        private static readonly System.Text.RegularExpressions.Regex RxMarcaBloque = new System.Text.RegularExpressions.Regex(
            @"^\s*#hkbloque:(\d+)\s*$");
        private static readonly System.Text.RegularExpressions.Regex RxVis = new System.Text.RegularExpressions.Regex(
            @"^\s*#\s*(hide|show|noc|equ|val|ocultar|mostrar|formula|valor)\s*$", System.Text.RegularExpressions.RegexOptions.IgnoreCase);
        private bool _numMode;
        private HojaNumerica.Resultado _numRes;
        private List<List<string>> _numBlocks;
        private static Dictionary<string, HojaNumerica.Rejilla> _numGrids;   // #map de la hoja numérica: texto → rejilla
        private static Dictionary<string, HojaNumerica.MallaDatos> _numMeshes;   // #malla(x, y, e, s) → datos del modelo
        private const string NumOculta = "\u0002hkoculta";                   // línea #hide: no se dibuja

        /// <summary>Hoja numérica: cada bloque for/while/if/function (y su forma Calcpad) se pliega en
        /// UNA línea marcador «#hkbloque:k». Su texto (ya con los nombres preparados) va a <paramref name="bloques"/>;
        /// NO se ejecuta aquí: lo corre HojaNumerica junto con el resto de la hoja, en orden.</summary>
        private static string PlegarNumerico(string text, out List<List<string>> bloques)
        {
            bloques = new List<List<string>>();
            var src = text.Replace("\r", "").Split('\n');
            var salida = new List<string>();
            for (int i = 0; i < src.Length; i++)
            {
                if (!HojaNumerica.AbreBloque(src[i])) { salida.Add(src[i]); continue; }
                var cuerpo = new List<string>();
                int nivel = 0, j = i;
                for (; j < src.Length; j++)
                {
                    if (HojaNumerica.AbreBloque(src[j])) nivel++;
                    else if (HojaNumerica.CierraBloque(src[j])) nivel--;
                    cuerpo.Add(src[j]);
                    if (nivel == 0) break;
                }
                i = j;
                salida.Add("#hkbloque:" + bloques.Count);
                bloques.Add(cuerpo);
            }
            return string.Join("\n", salida);
        }

        /// <summary>Una línea de la hoja numérica: «nombre = fórmula = valor» con el valor que dio el
        /// programa (doble precisión, números como los muestra Calcpad). null = no es numérica.</summary>
        private string NumDisplay(int i, string texto, string lbl, LispConverter.N tree, char modo)
        {
            if (_numRes == null) return null;
            var enc = new Func<string, string>(System.Net.WebUtility.HtmlEncode);
            if (_numRes.Error.TryGetValue(i, out var err))
                return LispConverter.TxtLine("p", "left", "<span style=\"color:#c0392b\">⚠ <code>" + enc((texto ?? "").Trim()) + "</code> → " + enc(err) + "</span>");
            if (modo == 'n') return tree == null ? null : (lbl != null ? lbl + " = " : "") + LispConverter.ToLisp(tree);
            if (!_numRes.Valor.TryGetValue(i, out var v)) return null;
            v = HojaNumerica.FormatoLiteral(v);
            string f = null;
            try { f = tree != null ? LispConverter.ToLisp(tree) : null; } catch { }
            bool trivial = f == null || f == v || f == lbl || modo == 'v' ||
                           System.Text.RegularExpressions.Regex.IsMatch(f, @"^-?[\d.]+(e-?\d+)?$");
            if (lbl != null) return trivial ? lbl + " = " + v : lbl + " = " + f + " = " + v;
            return f != null && f != v ? f + " = " + v : v;
        }

        /// <summary>El bloque en la hoja: el código plegable (como Calcpad lo esconde con #hide, pero a
        /// un clic), lo que imprimió con disp(…) y, si falló, por qué.</summary>
        private string BloqueHtml(int k, int linea)
        {
            var enc = new Func<string, string>(System.Net.WebUtility.HtmlEncode);
            var src = _numBlocks != null && k < _numBlocks.Count ? _numBlocks[k] : new List<string>();
            string primera = src.Count > 0 ? src[0].Trim() : "";
            // los nombres preparados (nu, ehkq1…) vuelven a como se escribieron (ν, E)
            string Orig(string s) => System.Text.RegularExpressions.Regex.Replace(s, @"[A-Za-z_]\w*", m => LispConverter.OriginalName(m.Value) is string o && o != m.Value && !o.Contains(' ') ? o : m.Value);
            var sb = new StringBuilder();
            sb.Append("<details class=\"hk-bloque\" style=\"margin:.35em 0;border-left:3px solid var(--acc,#b08a2e);padding:.1em .6em;background:rgba(127,127,127,.06)\">");
            sb.Append("<summary style=\"cursor:pointer;font-family:Consolas,monospace;font-size:.9em;color:var(--mut)\">")
              .Append(enc(Orig(primera))).Append(src.Count > 1 ? "  … (" + src.Count + " líneas)" : "").Append("</summary>");
            sb.Append("<pre style=\"margin:.3em 0;font:12.5px/1.45 Consolas,monospace;white-space:pre\">");
            foreach (var l in src) sb.Append(enc(Orig(l))).Append("&#10;");   // sin saltos reales: la hoja se parte por líneas
            sb.Append("</pre></details>");
            if (_numRes != null && _numRes.Salida.TryGetValue(linea, out var outs))
                foreach (var o in outs)
                    sb.Append("<div style=\"font-family:Consolas,monospace\">").Append(enc(HojaNumerica.FormatoLiteral(o))).Append("</div>");
            if (_numRes != null && _numRes.Error.TryGetValue(linea, out var err))
                sb.Append("<div style=\"color:#c0392b\">⚠ ").Append(enc(err)).Append("</div>");
            return sb.ToString();
        }

        private string PlegarBloques(string text, out Dictionary<int, string> salidas)
        {
            salidas = new Dictionary<int, string>();
            var src = text.Replace("\r", "").Split('\n');
            var abre = new System.Text.RegularExpressions.Regex(
                @"^\s*(for|while|if|function)\b", System.Text.RegularExpressions.RegexOptions.IgnoreCase);
            var cierra = new System.Text.RegularExpressions.Regex(
                @"^\s*end\s*$", System.Text.RegularExpressions.RegexOptions.IgnoreCase);
            // una asignacion simple: «s = 0», «E = 2.1e8». Es el contexto que ve el bloque.
            var asigna = new System.Text.RegularExpressions.Regex(@"^\s*([A-Za-z_]\w*)\s*=\s*[^=].*$");

            var salida = new List<string>();
            var contexto = new List<string>();
            for (int i = 0; i < src.Length; i++)
            {
                if (!abre.IsMatch(src[i]))
                {
                    if (asigna.IsMatch(src[i]) && !src[i].TrimStart().StartsWith("#")) contexto.Add(src[i]);
                    salida.Add(src[i]);
                    continue;
                }
                // el bloque: hasta su `end`, contando los anidados
                var cuerpo = new List<string>();
                int nivel = 0, j = i;
                for (; j < src.Length; j++)
                {
                    if (abre.IsMatch(src[j])) nivel++;
                    else if (cierra.IsMatch(src[j])) nivel--;
                    cuerpo.Add(src[j]);
                    if (nivel == 0) break;
                }
                i = j;
                // se ejecuta con el contexto delante, para que vea las variables de la hoja
                string prog = string.Join("\n", contexto) + (contexto.Count > 0 ? "\n" : "") +
                              string.Join("\n", cuerpo);
                string res;
                try { res = RunLispClean(MatlabToLisp.Translate(prog).Executable); }
                catch (Exception ex) { res = "(" + ex.Message + ")"; }
                salidas[salida.Count] = (res ?? "").TrimEnd();
                // marcador: una linea de TEXTO, que el resto del pipeline ya sabe pintar
                salida.Add("#: " + Esc(res));
            }
            return string.Join("\n", salida);
        }

        /// El resultado de un bloque, como texto de una sola linea para la hoja.
        private static string Esc(string s)
        {
            if (string.IsNullOrWhiteSpace(s)) return "(sin salida)";
            return "`" + s.Replace("\r", "").Replace("\n", " · ").Trim() + "`";
        }

        /// <summary>La HOJA puede fijar su operación con una línea  #modo auto  (o simplify / expand / memoria).
        /// Una memoria de cálculo quiere ver las fórmulas COMO SE ESCRIBEN (m = (N − 0.95·d)/2), y el
        /// modo por defecto (simplify) las reescribe (N/2 − 19·d/40). La línea queda en blanco para no
        /// descuadrar los índices por línea; derivar/integrar/despejar mandan sobre la hoja.</summary>
        // UN cálculo a la vez. ComputeResult corre en Task.Run y usa campos de la ventana (_op,
        // _sinSustituir, _srcPrepared, _numRes…): dos a la vez (AutoRun mientras aún calcula, o
        // --html, que calculaba al abrir Y al exportar) se pisaban. Visto en la hoja 69: con
        // #modo memoria salía unas veces sustituida y otras no, según quién terminara último.
        private readonly object _computeLock = new object();
        private List<string> ComputeResult(string text, string dvar)
        {
            lock (_computeLock) return ComputeResultUno(text, dvar);
        }
        private List<string> ComputeResultUno(string text, string dvar)
        {
            var mm = System.Text.RegularExpressions.Regex.Match(text ?? "",
                @"(?im)^[ \t]*#[ \t]*modo[ \t]*\(?[ \t]*(auto|simplify|expand|memoria)[ \t]*\)?[ \t]*\r?$");
            if (!mm.Success || _op is "deriv" or "integ" or "despejar") return ComputeResultCore(text, dvar);
            var prev = _op;
            string modo = mm.Groups[1].Value.ToLowerInvariant();
            // memoria = auto + SIN sustituir las definiciones anteriores: t_p = m·√(…) se lee con su m,
            // no con (N − 0.95·d)/2 metida dentro (los valores van aparte, con dec(números))
            _op = modo == "memoria" ? "auto" : modo;
            _sinSustituir = modo == "memoria";
            try { return ComputeResultCore(text.Remove(mm.Index, mm.Length), dvar); }
            finally { _op = prev; _sinSustituir = false; }
        }
        private bool _sinSustituir;

        private List<string> ComputeResultCore(string text, string dvar)
        {
            _ranProgram = false;
            if (string.IsNullOrWhiteSpace(text)) return new List<string>();

            // CaseMap: recuerda cómo escribió el usuario cada identificador con mayúsculas
            // (L, EI, N1…) para restaurar el case en el render (el motor los devuelve en minúscula).
            // SOLO líneas de matemática (no texto '#'/';'/'%' ni la etiqueta @@), para no cazar
            // palabras de la prosa como «Y», «El», «La».
            // Además: griegas Unicode (λ) → nombre, y los nombres que chocarían en LISP (m/M, T, Pi)
            // renombrados a una forma única. Ver LispConverter.PrepareNames.
            // Los bloques de control se pliegan ANTES de preparar nombres: plegar
            // cambia el numero de lineas, y de aqui para abajo todo el pipeline
            // trabaja con arrays indexados por linea. Plegar despues los descuadra
            // (probado el 21-sep-2026: salia el CSS volcado como contenido).
            // HOJA NUMÉRICA (#numerico): toda la hoja es UN programa con estado (como Calcpad).
            // Aquí los nombres se preparan ANTES de plegar, para que los bloques usen los mismos
            // nombres que la hoja (ν → nu, E/e distintos…); el plegado deja una línea marcador.
            _numMode = RxNumerico.IsMatch(text);
            _numRes = null; _numBlocks = null; _numGrids = null; _numMeshes = null;
            if (_numMode)
            {
                text = RxNumerico.Replace(text, "");
                // palabras de bloque de Calcpad (#for … #loop) → MATLAB, antes de preparar nombres
                text = string.Join("\n", text.Replace("\r", "").Split('\n').Select(HojaNumerica.PalabraCalcpad));
                text = LispConverter.PrepareNames(text);
                text = PlegarNumerico(text, out _numBlocks);
                _srcPrepared = text;
            }
            else
            {
            // (antes esta regex llevaba un RETROCESO (0x08) literal donde iba \b: no casaba nunca y
            //  los bloques for/if de una hoja se pintaban como texto, sin ejecutarse)
            if (!LooksLikeLisp(text) &&
                System.Text.RegularExpressions.Regex.IsMatch(text, @"(?m)^\s*(for|while|if|function)\b"))
            {
                bool hayHoja = System.Text.RegularExpressions.Regex.IsMatch(
                    text, @"(?m)^\s*(#[:#>|<]|#\s*(dibujo|map|mapa|fplot|surf|tabla|graf))",
                    System.Text.RegularExpressions.RegexOptions.IgnoreCase);
                if (!hayHoja)
                {
                    _ranProgram = true;
                    try { return new List<string> { RunLispClean(MatlabToLisp.Translate(text).Executable) }; }
                    catch (Exception ex) { return new List<string> { "...  (" + ex.Message + ")" }; }
                }
                text = PlegarBloques(text, out _salidasProg);
            }
            text = LispConverter.PrepareNames(text);
            _srcPrepared = text;
            }

            // Programas: LISP (defun/loop/let) o matemática imperativa (for/while) → EJECUTAR.
            if (LooksLikeLisp(text) && IsLispProgram(text))
            {
                if (!Balanced(text)) return new List<string> { "…  (paréntesis sin cerrar)" };
                _ranProgram = true;
                return new List<string> { RunLispClean(text) };
            }
            // Solo EJECUTAR (imperativo) si hay CONTROL DE FLUJO real (for/while/if/function).
            // Las asignaciones simples "N1 = expr" NO se ejecutan: son etiquetas simbólicas.
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
            // TABLAS de TEXTO escritas a mano (markdown, comentario #|…|):  #| Iteración | Residuo |
            // seguida de la fila separadora #|---|---:| → tabla; consume las filas y las deja en
            // blanco (las demás líneas del bloque quedan vacías, como cualquier hueco de la hoja).
            var manualTables = new string[lines.Length];
            ExtractManualTables(lines, manualTables);
            // DIBUJOS técnicos (#dibujo … #fin): el bloque queda en su 1ª línea, el resto en blanco.
            var dibujos = new LispDibujo.Bloque[lines.Length];
            LispDibujo.ExtractBlocks(lines, dibujos);
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
            var unitOf = new string[lines.Length];             // unidad VISIBLE [kN] del final de la línea (solo dibujo)
            var descOf = new string[lines.Length];             // descripción 'texto del final de la línea (estilo Calcpad)
            var barraOf = new string[lines.Length];            // forma (qshow …) de una línea con barra de unidad: 3m|cm
            var aliasOf = new List<string>[lines.Length];      // Fx = F_1 = Expand{…}: los nombres del medio (F_1)
            // ETIQUETA de ecuación: @@(texto) al FINAL de una línea de MATEMÁTICA → número a la derecha.
            // La VARIABLE queda a la IZQUIERDA (como Calcpad/Hekatan Lab). Compat: acepta el viejo #deq.
            // Las líneas de TEXTO (#: ## #> ; %) y las gráficas no llevan etiqueta.
            for (int i = 0; i < lines.Length; i++)
            {
                if (isTic[i] || isToc[i]) continue;   // tic/toc: no son expresiones
                if (dibujos[i] != null) continue;     // #dibujo: bloque de dibujo, no es expresión
                var s = lines[i].TrimStart();
                bool textDir = s.StartsWith("#:") || s.StartsWith("##") || s.StartsWith("#>") ||
                               s.StartsWith("#<") || s.StartsWith("#|") || s.StartsWith(";") || s.StartsWith("%") ||
                               System.Text.RegularExpressions.Regex.IsMatch(s,
                                   @"^#\s*(anim|animar|animacion|slider|barra_deslizante|deslizador|gauss|cuadratura|gausslegendre|fila|finfila|fplot|plot|ezplot|graficas?|grafico|surf|superficie|plot3d|mesh|malla|mallado|map|mapa|heatmap|contourf?|beam|viga|esquema|frame|portico|framedef|porticodef|slice|trozo|elemento|defl|diag|vmd|bar1d|barra|elem1d|punto|dotprod|producto|dot|recta|ab|interceptopendiente|mapa1d|xdexi|mapnatural|solido|solid|hexa|solidmesh|salto|pagebreak|nuevapagina|pagina|newpage)\b",
                                   System.Text.RegularExpressions.RegexOptions.IgnoreCase) ||
                               System.Text.RegularExpressions.Regex.IsMatch(s, @"^#\s*(?:tabla|table)\s*\(",
                                   System.Text.RegularExpressions.RegexOptions.IgnoreCase);
                if (textDir) continue;
                var m = System.Text.RegularExpressions.Regex.Match(lines[i], @"^(.*?)\s*@@\((.*?)\)\s*$");
                if (m.Success)
                {
                    lines[i] = System.Text.RegularExpressions.Regex.Replace(m.Groups[1].Value.Trim(), @"^#deq\s+", "");
                    deqTag[i] = m.Groups[2].Value;
                }
                // DESCRIPCIÓN al lado:  h = 6m|m 'Altura del objeto   (la comilla, como en Calcpad)
                if (LispConverter.SepararDescripcion(lines[i].TrimEnd(), out var sinDesc, out var descVis)) { lines[i] = sinDesc; descOf[i] = descVis; }
                // UNIDAD visible al final:  P_1 = 35 [kN]  → se quita ANTES de calcular y se dibuja después
                if (LispConverter.SepararUnidad(lines[i].TrimEnd(), out var sinUnidad, out var unidadVis)) { lines[i] = sinUnidad; unitOf[i] = unidadVis; }
            }
            // HOJA NUMÉRICA: visibilidad (#hide/#show) y modo de ecuación (#noc/#equ/#val) de Calcpad,
            // y el PROGRAMA: todas las líneas de cálculo + los bloques, en orden, de una vez en SBCL.
            var numOculta = new bool[lines.Length];   // no se dibuja (#hide, o la propia directiva)
            var numModo = new char[lines.Length];     // 'e' fórmula = valor · 'n' solo fórmula · 'v' solo valor
            var numBloque = new int[lines.Length];    // ≥0: marcador de bloque
            if (_numMode)
            {
                bool oculta = false; char modo = 'e';
                var progLines = new List<HojaNumerica.Linea>();
                var rxMap = new System.Text.RegularExpressions.Regex(@"^\s*#\s*(map|mapa|heatmap|contourf?)\s*\((.*)\)\s*$",
                    System.Text.RegularExpressions.RegexOptions.IgnoreCase | System.Text.RegularExpressions.RegexOptions.Singleline);
                for (int i = 0; i < lines.Length; i++)
                {
                    numBloque[i] = -1;
                    var s = lines[i].Trim();
                    var vm = RxVis.Match(s);
                    if (vm.Success)
                    {
                        switch (vm.Groups[1].Value.ToLowerInvariant())
                        {
                            case "hide": case "ocultar": oculta = true; break;
                            case "show": case "mostrar": oculta = false; break;
                            case "noc": case "formula": modo = 'n'; break;
                            case "equ": modo = 'e'; break;
                            case "val": case "valor": modo = 'v'; break;
                        }
                        lines[i] = ""; numOculta[i] = true; continue;
                    }
                    numModo[i] = modo;
                    var mb = RxMarcaBloque.Match(s);
                    if (mb.Success)
                    {
                        numBloque[i] = int.Parse(mb.Groups[1].Value);
                        numOculta[i] = oculta;
                        progLines.Add(new HojaNumerica.Linea { Idx = i, Texto = s, Bloque = numBloque[i], Visible = !oculta });
                        continue;
                    }
                    var mz = System.Text.RegularExpressions.Regex.Match(lines[i], @"^\s*#\s*(malla|mallado)\s*\((.*)\)\s*$", System.Text.RegularExpressions.RegexOptions.IgnoreCase);
                    if (mz.Success && !System.Text.RegularExpressions.Regex.IsMatch(mz.Groups[2].Value, @"^\s*\d+\s*,"))
                    { progLines.Add(new HojaNumerica.Linea { Idx = i, Texto = s, Malla = mz.Groups[2].Value, Visible = true }); continue; }
                    var mm = rxMap.Match(lines[i]);
                    if (mm.Success) { progLines.Add(new HojaNumerica.Linea { Idx = i, Texto = s, Mapa = mm.Groups[2].Value, Visible = true }); continue; }
                    if (s.Length == 0 || s.StartsWith("#") || s.StartsWith(";") || s.StartsWith("%")) continue;   // texto
                    numOculta[i] = oculta;
                    if (modo == 'n') continue;                 // #noc: se dibuja, no se calcula (Calcpad)
                    progLines.Add(new HojaNumerica.Linea { Idx = i, Texto = lines[i], Visible = !oculta });
                }
                _numRes = HojaNumerica.Ejecutar(progLines, _numBlocks ?? new List<List<string>>());
                _numGrids = new Dictionary<string, HojaNumerica.Rejilla>();
                foreach (var pl in progLines)
                    if (pl.Mapa != null && _numRes.Mapa.TryGetValue(pl.Idx, out var g)) _numGrids[pl.Mapa.Trim()] = g;
                _numMeshes = new Dictionary<string, HojaNumerica.MallaDatos>();
                foreach (var pl in progLines)
                    if (pl.Malla != null && _numRes.Malla.TryGetValue(pl.Idx, out var md)) _numMeshes[pl.Malla.Trim()] = md;
                if (Environment.GetEnvironmentVariable("HK_NUM_DEBUG") is string dbg && dbg.Length > 0)
                    try
                    {
                        System.IO.File.WriteAllText(dbg, ";; " + _numRes.Segundos.ToString("0.000", System.Globalization.CultureInfo.InvariantCulture) +
                            " s total, " + _numRes.SegundosMotor.ToString("0.000", System.Globalization.CultureInfo.InvariantCulture) +
                            " s calculo\n" + _numRes.Programa + "\n;; ---- valores ----\n" +
                            string.Join("\n", _numRes.Valor.OrderBy(kv => kv.Key).Select(kv => ";; " + kv.Key + " [" +
                                LispConverter.OriginalName(_numRes.Nombre.TryGetValue(kv.Key, out var nm) ? nm : "") + "] " +
                                System.Text.RegularExpressions.Regex.Replace((lines[kv.Key] ?? "").Trim(), @"[A-Za-z_]\w*", mo => LispConverter.OriginalName(mo.Value)) +
                                " => " + kv.Value)) +
                            "\n;; ---- errores ----\n" + string.Join("\n", _numRes.Error.Select(kv => ";; " + kv.Key + " " + kv.Value)));
                    }
                    catch { }
            }
            var isPlot = new bool[lines.Length];   // línea = directiva de gráfica → marca su POSICIÓN en el documento
            var isTabla = new bool[lines.Length];   // línea = #tabla(…)(…) de RESULTADOS calculados
            var tablaSpecOf = new TablaSpec[lines.Length];
            // PASO 1: parsear cada línea a árbol + detectar su etiqueta
            for (int i = 0; i < lines.Length; i++)
            {
                if (isTic[i] || isToc[i]) continue;   // tic/toc: no se parsean como expresión
                if (_numMode && (numBloque[i] >= 0 || (numOculta[i] && !RxAnyPlot.IsMatch(lines[i])))) continue;   // hoja numérica: bloque u oculta
                if (dibujos[i] != null) continue;     // #dibujo: se dibuja en el display (necesita los resultados)
                if (manualTables[i] != null) { textOf[i] = ("table", "left", manualTables[i]); continue; }   // tabla de TEXTO (#|…|)
                var exprText = lines[i];
                if (System.Text.RegularExpressions.Regex.IsMatch(lines[i],
                        @"^\s*[;#]+\s*(anim|animar|animacion|slider|barra_deslizante|deslizador|gauss|cuadratura|gausslegendre|fila|finfila|fplot|plot|ezplot|graficas?|grafico|surf|superficie|plot3d|mesh|malla|mallado|map|mapa|heatmap|contourf?|beam|viga|esquema|frame|portico|framedef|porticodef|slice|trozo|elemento|defl|diag|vmd|bar1d|barra|elem1d|punto|dotprod|producto|dot|recta|ab|interceptopendiente|mapa1d|xdexi|mapnatural|solido|solid|hexa|solidmesh|salto|pagebreak|nuevapagina|pagina|newpage)\b",
                        System.Text.RegularExpressions.RegexOptions.IgnoreCase)) { isPlot[i] = true; continue; }
                var tspec = ParseTablaDirective(lines[i]);
                if (tspec != null) { isTabla[i] = true; tablaSpecOf[i] = tspec; continue; }
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
                // BARRA de Calcpad: 3m|cm → el resultado se quiere ver en cm. Las letras
                // de esa línea son UNIDADES, así que no pasa por el parser general.
                if (LispUnidades.SepararBarra(exprText, out var cuerpoU, out var destU))
                {
                    var f = LispUnidades.Forma(cuerpoU, destU);
                    // la unidad de destino se dibuja con el MISMO mecanismo del [kN]
                    // visible: si va dentro del texto del resultado, el render la pierde
                    // al volver a leer «300.0000 cm» como matemática.
                    if (f != null) { barraOf[i] = f; exprText = cuerpoU; unitOf[i] = destU; }
                }
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
                // hoja numérica: lo calculado por el programa (o #noc) no pasa por el motor simbólico
                if (_numMode && (numOculta[i] || numModo[i] == 'n' || (_numRes != null && _numRes.Calculada.Contains(i)))) continue;
                try
                {
                    var app = (funcMap.Count > 0 || vecMap.Count > 0)
                              ? LispConverter.SubstFuncs(treeOf[i], funcMap, vecMap) : treeOf[i];  // f(3)→3²+1, v(2)→componente
                    var sub = _sinSustituir ? app : LispConverter.SubstLabels(app, prevLabels, labels[i], new HashSet<string>());
                    formOf[i] = barraOf[i] ?? LispConverter.ToLisp(sub);
                }
                catch { formOf[i] = barraOf[i]; }
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
                if (_numMode)
                {
                    bool conError = _numRes != null && _numRes.Error.ContainsKey(i);
                    if (numBloque[i] >= 0) { display.Add(numOculta[i] && !conError ? NumOculta : LispConverter.TxtLine("table", "left", BloqueHtml(numBloque[i], i))); continue; }
                    if (numOculta[i] && !conError) { display.Add(NumOculta); continue; }
                    var nd = NumDisplay(i, lines[i], labels[i], treeOf[i], numModo[i]);
                    if (nd != null) { display.Add(nd); continue; }
                }
                if (dibujos[i] != null)   // #dibujo … #fin: SVG técnico con los valores YA calculados de la hoja
                {
                    string svg;
                    try { svg = LispDibujo.Render(dibujos[i], name => NumLookup(name, labels, resOf, formOf, 0)); }
                    catch (Exception ex) { svg = "<div class=\"hk-dib-err\">⚠ #dibujo: " + System.Net.WebUtility.HtmlEncode(ex.Message) + "</div>"; }
                    display.Add(LispConverter.TxtLine("table", "left", svg));
                    continue;
                }
                if (isTabla[i])   // #tabla(headers)(cols): resuelve las columnas YA calculadas (labels/resOf)
                {
                    string tblHtml = BuildTablaResultados(tablaSpecOf[i], labels, resOf);
                    display.Add(LispConverter.TxtLine("table", "left", tblHtml));
                    continue;
                }
                if (textOf[i] != null)   // texto formateado (directiva ;): sustituye {Var} por su valor (math)
                {
                    var (kind, align, raw2) = textOf[i].Value;
                    string html = LispConverter.FormatInlineText(raw2,
                        name => LookupVarHtml(name, labels, resOf, formOf, funcMap, vecMap),
                        name => vecMap.TryGetValue(name, out var vt) && vt.Op == "vec");   // @v → flecha solo si v es VECTOR
                    if (kind == "table") html = RebuildManualTable(html);   // tabla de TEXTO: rearma <table> ya con cada celda formateada
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
                        // la forma LISP directamente. Con ceil/max/… o un dec anidado dentro, la
                        // sustitución de etiquetas deja un chorizo ilegible: se muestra con SÍMBOLOS.
                        string decSrc = formOf[i];
                        if (treeOf[i] != null && (HasNumFn(formOf[i]) || formOf[i].IndexOf("(dec ", 1, StringComparison.Ordinal) > 0))
                            decSrc = LispConverter.ToLisp(treeOf[i]);
                        var ar = LispConverter.TopLevelArgs(decSrc);
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
                        bool refsVec = opF != formOf[i] && (ReferencesVecVar(opF, vecMap) || HasNumFn(formOf[i]));   // ceil/max…: n = ⌈As/Ab⌉, con símbolos
                        display.Add(lbl + " = " + (refsVec ? opF : formOf[i]) + " = " + r);
                    }
                    // un NÚMERO escrito por el usuario (q = 13.48, x0 = -0.15) es un DATO: se muestra tal
                    // cual, no como la fracción exacta del motor (337/25).
                    else if (System.Text.RegularExpressions.Regex.IsMatch(formOf[i], @"^-?\d+\.\d+$") ||
                             (treeOf[i] != null && treeOf[i].Op == "neg" && treeOf[i].A != null && treeOf[i].A.IsAtom &&
                              System.Text.RegularExpressions.Regex.IsMatch(treeOf[i].A.Atom ?? "", @"^\d+\.\d+$")))
                    {
                        display.Add(lbl + " = " + (treeOf[i].Op == "neg" ? "-" + treeOf[i].A.Atom : formOf[i]));
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
            // UNIDAD visible: va pegada a la ecuación, ANTES de la etiqueta de la derecha.
            for (int i = 0; i < lines.Length && i < display.Count; i++)
                // con un aviso de dimensiones no hay número, así que tampoco unidad que dibujar
                if (unitOf[i] != null && display[i].Length > 0 && !display[i].Contains('⚠')
                    && !display[i].StartsWith(LispConverter.TxtMark, StringComparison.Ordinal) && display[i] != LispConverter.PlotSlot)
                    display[i] += LispConverter.UnitSep + unitOf[i];
            // DESCRIPCIÓN al lado ('texto), como en Calcpad: detrás de la unidad.
            for (int i = 0; i < lines.Length && i < display.Count; i++)
                if (descOf[i] != null && display[i].Length > 0 && !display[i].StartsWith(LispConverter.TxtMark, StringComparison.Ordinal) && display[i] != LispConverter.PlotSlot)
                    display[i] += LispConverter.DescSep + descOf[i];
            // #deq: pega la ETIQUETA (a la derecha) al final de la línea de display correspondiente.
            for (int i = 0; i < lines.Length && i < display.Count; i++)
                if (deqTag[i] != null && display[i].Length > 0 && !display[i].StartsWith(LispConverter.TxtMark, StringComparison.Ordinal))
                    display[i] += LispConverter.DeqSep + deqTag[i];
            // Lado a lado: las asignaciones que venían de la MISMA línea (a=2; b=3) van en UNA fila.
            bool Mergeable(string s) => s.Length > 0 && !s.StartsWith(LispConverter.TxtMark, StringComparison.Ordinal) && s != LispConverter.PlotSlot;
            var merged = new List<string>();
            for (int i = 0; i < display.Count; i++)
            {
                if (display[i].StartsWith(NumOculta, StringComparison.Ordinal)) continue;   // #hide
                bool cont = i < contLine.Count && contLine[i];
                if (cont && merged.Count > 0 && Mergeable(display[i]) && Mergeable(merged[merged.Count - 1]))
                    merged[merged.Count - 1] += LispConverter.SbsSep + display[i];
                else
                    merged.Add(display[i]);
            }
            return merged;
        }

        // VALOR NUMÉRICO de un nombre de la hoja (para #dibujo): el resultado del motor (resOf) o, si
        // no es numérico, su forma (formOf). Escalar = arreglo de 1; vector/matriz = sus números en fila.
        // null = no existe o no reduce a número (el dibujo lo avisa en rojo).
        private static double[] NumLookup(string name, string[] labels, string[] resOf, string[] formOf, int depth)
        {
            if (string.IsNullOrEmpty(name) || depth > 8) return null;
            string mn = LispConverter.MangleExpr(name);
            int j = Array.FindIndex(labels, l => l != null && l == mn);
            if (j < 0) j = Array.FindIndex(labels, l => l != null && string.Equals(l, mn, StringComparison.OrdinalIgnoreCase));
            if (j < 0) return null;
            foreach (var src in new[] { resOf[j], formOf[j] })
            {
                if (string.IsNullOrWhiteSpace(src) || src.Equals("nil", StringComparison.OrdinalIgnoreCase)) continue;
                try
                {
                    var tree = LispConverter.ParseLisp(src.Trim());
                    return LispDibujo.Eval(tree, n2 => string.Equals(n2, labels[j], StringComparison.OrdinalIgnoreCase) ? null
                                                         : NumLookup(n2, labels, resOf, formOf, depth + 1));
                }
                catch { }
            }
            return null;
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
            "(suma","(producto-op","(root-op","(find-op","(sup-op","(inf-op","(repeat-op","(limite","(despejar",
            "(ceil ","(floor ","(round ","(max ","(min " };   // numéricas: se muestra  n = ⌈As/Ab⌉ = 7
        private static bool HasNumFn(string f) => f != null &&
            (f.Contains("(ceil ") || f.Contains("(floor ") || f.Contains("(round ") || f.Contains("(max ") || f.Contains("(min "));
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
                string un = null; if (LispConverter.SepararUnidad(l, out var lSinU, out var uLinea)) { un = uLinea; l = lSinU; }
                string conv = ConvertEqLine(l, toLisp);
                if (un != null) conv += toLisp ? "   ; [" + un + "]" : " [" + un + "]";
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
