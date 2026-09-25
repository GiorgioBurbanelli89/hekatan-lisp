using System;
using System.Collections.Generic;
using System.Globalization;
using System.Linq;
using System.Text;
using System.Text.RegularExpressions;

namespace HekatanLisp
{
    /// <summary>
    /// HOJA NUMÉRICA (#numerico): la hoja entera —sus asignaciones, sus funciones y sus bloques
    /// for / while / if— se traduce a UN programa LISP con estado y se corre de una vez en SBCL,
    /// con el motor numérico de engine.lisp (hn-*, hnb-*). Es lo que hace Calcpad: las variables
    /// que un bucle modifica las leen las líneas siguientes.
    ///
    /// El porqué de un programa y no línea a línea: la hoja simbólica sustituye cada etiqueta por
    /// su fórmula (y = m·x + b se lee con m y b dentro). Con K de 140×140 armada en un bucle eso no
    /// existe: K es ESTADO, no una fórmula. Aquí cada nombre es una variable LISP de verdad.
    ///
    /// Lenguaje (el de MATLAB, más nombres de Calcpad):
    ///   a = expr · A(i, j) = expr · f(x, y) = expr (función de la hoja) · f = @(x) expr
    ///   for i = a:b / a:s:b / vector · while c · if / elseif / else · end · break
    ///   (también las palabras de Calcpad: #for … #loop, #if … #else if … #else … #end if)
    ///   + − * / \ ^ .* ./ .^ '  ·  == ~= &lt; &gt; &lt;= &gt;= &amp;&amp; || ~  ·  a:b  ·  [a, b; c, d]
    /// Los nombres distinguen mayúsculas (e ≠ E), como en Calcpad y MATLAB.
    /// </summary>
    public static class HojaNumerica
    {
        public sealed class Linea
        {
            public int Idx;          // índice de la línea en la hoja (el del array del pipeline)
            public string Texto;     // la línea ya limpia (sin unidad visible, descripción ni @@)
            public bool Visible;     // si se muestra, su valor vuelve a la hoja
            public int Bloque = -1;  // ≥0: la línea es el marcador de un bloque plegado
            public string Mapa;      // #map(...): lo de dentro de los paréntesis
            public string Malla;     // #malla(x, y, elementos[, apoyos]) con datos del modelo
            public string Modelo3D;  // #modelo3d(X, cascaras, barras, valor_nudo, valor_barra[, U, escala])
        }

        public sealed class Rejilla { public double Xa, Xb, Ya, Yb; public int N; public double[,] Z; }
        public sealed class MallaDatos { public double[] X, Y; public int[][] Elem; public int[] Apoyos; public int[][] Restr; }

        public sealed class Resultado
        {
            public readonly Dictionary<int, string> Valor = new();          // línea → literal LISP
            public readonly Dictionary<int, string> Nombre = new();         // línea → nombre asignado ("" = expresión)
            public readonly Dictionary<int, string> Error = new();          // línea → mensaje
            public readonly Dictionary<int, List<string>> Salida = new();   // línea (bloque) → disp(...)
            public readonly Dictionary<int, Rejilla> Mapa = new();          // línea #map → rejilla
            public readonly Dictionary<int, MallaDatos> Malla = new();      // línea #malla → nudos y elementos
            public readonly Dictionary<int, List<string>> Modelo3D = new(); // línea #modelo3d → literales de sus datos
            public readonly HashSet<int> Calculada = new();                 // líneas que entraron al programa
            public double Segundos;          // todo: traducir, compilar (SBCL), correr y leer
            public double SegundosMotor;     // solo correr el programa ya compilado
            public string Programa = "";
        }

        // ================= biblioteca: nombres que el motor sabe (engine.lisp, hnb-*) =================
        static readonly HashSet<string> Builtins = new(StringComparer.Ordinal)
        {
            "zeros","ones","eye","vector","matrix","identity","symmetric","utriang","ltriang",
            "size","n_rows","n_cols","length","len","numel","transpose","transp","sum","max","min",
            "sqrt","exp","ln","log","log10","sin","cos","tan","asin","acos","atan","atan2","sinh","cosh","tanh",
            "abs","round","floor","ceil","ceiling","fix","trunc","sign","mod","rem","dot","norm","trace",
            "linspace","row","col","submatrix","slice","extract","take","add","fill","disp",
            "solve","lsolve","clsolve","slsolve","mldivide","inv","inverse","det",
            "integral","integral2","spline"
        };

        static readonly Regex RxFuncDef = new(@"^([A-Za-z_]\w*)\s*\(([^()]*)\)\s*=(?!=)\s*(.+)$");
        static readonly Regex RxAsig = new(@"^([A-Za-z_]\w*)\s*=(?!=)\s*(.+)$");
        static readonly Regex RxIdxAsig = new(@"^([A-Za-z_]\w*)\s*\((.*)\)\s*=(?!=)\s*(.+)$");
        static readonly Regex RxKw = new(@"^(for|while|if|elseif|else|end|function|break|continue)\b");

        /// <summary>Normaliza la escritura de la hoja (·, ², −, ≡, ∨ …) a la del traductor.</summary>
        public static string Normaliza(string s)
        {
            if (s == null) return "";
            var sb = new StringBuilder(s.Length + 8);
            foreach (var c in s)
                switch (c)
                {
                    case '·': case '×': case '⋅': sb.Append('*'); break;
                    case '−': case '–': sb.Append('-'); break;
                    case '²': sb.Append("^2"); break;
                    case '³': sb.Append("^3"); break;
                    case '≤': sb.Append("<="); break;
                    case '≥': sb.Append(">="); break;
                    case '≠': sb.Append("~="); break;
                    case '≡': sb.Append("=="); break;
                    case '∧': sb.Append("&&"); break;
                    case '∨': sb.Append("||"); break;
                    case '√': sb.Append("sqrt"); break;
                    default: sb.Append(c); break;
                }
            return sb.ToString();
        }

        /// <summary>Palabras de bloque de Calcpad → las de MATLAB (#for → for, #loop → end …).</summary>
        public static string PalabraCalcpad(string line)
        {
            var t = line.TrimStart();
            var ind = line.Substring(0, line.Length - t.Length);
            var m = Regex.Match(t, @"^#\s*(end\s*if|else\s*if|else|if|for|while|repeat|loop|break|continue)\b(.*)$", RegexOptions.IgnoreCase);
            if (!m.Success) return line;
            string kw = Regex.Replace(m.Groups[1].Value.ToLowerInvariant(), @"\s+", " ");
            string rest = m.Groups[2].Value;
            return ind + kw switch
            {
                "end if" or "loop" => "end",
                "else if" => "elseif" + rest,
                "repeat" => "while 1" + rest,
                _ => kw + rest,
            };
        }

        /// <summary>¿Abre un bloque? (for / while / if / function, o su forma Calcpad)</summary>
        public static bool AbreBloque(string line)
        {
            var t = PalabraCalcpad(line).TrimStart();
            return Regex.IsMatch(t, @"^(for|while|if|function)\b");
        }
        public static bool CierraBloque(string line)
        {
            var t = PalabraCalcpad(line).Trim();
            return Regex.IsMatch(t, @"^end\s*;?$");
        }

        // ============================== ejecución ==============================
        public static Resultado Ejecutar(List<Linea> lineas, List<List<string>> bloques)
        {
            var res = new Resultado();
            var ctx = new Ctx();

            // ---- pasada 1: nombres. Variables (lo que se asigna), funciones de la hoja, de bloque ----
            foreach (var ln in lineas)
            {
                if (ln.Bloque >= 0) { RecogeBloque(bloques[ln.Bloque], ctx); continue; }
                if (ln.Mapa != null || ln.Malla != null || ln.Modelo3D != null) continue;
                var t = Normaliza(ln.Texto).Trim();
                if (!EsNumerica(t)) continue;
                var fd = RxFuncDef.Match(t);
                var asg = RxAsig.Match(t);
                if (asg.Success) ctx.Vars.Add(asg.Groups[1].Value);
                else if (fd.Success && ParamsSimples(fd.Groups[2].Value)) ctx.PorDefinir.Add(fd.Groups[1].Value);
            }
            foreach (var f in ctx.PorDefinir) if (!ctx.Vars.Contains(f)) ctx.SheetFuncs.Add(f);
            foreach (var ln in lineas)                     // A(i) = … con A ya variable: asignación indexada
            {
                if (ln.Bloque >= 0 || ln.Mapa != null || ln.Malla != null || ln.Modelo3D != null) continue;
                var t = Normaliza(ln.Texto).Trim();
                var fd = RxFuncDef.Match(t);
                if (fd.Success && ctx.Vars.Contains(fd.Groups[1].Value)) ctx.SheetFuncs.Remove(fd.Groups[1].Value);
            }

            // ---- pasada 2: traducir ----
            var items = new StringBuilder();
            var defuns = new StringBuilder();
            foreach (var ln in lineas)
            {
                string code;
                try
                {
                    if (ln.Bloque >= 0) code = TraduceBloque(bloques[ln.Bloque], ctx, defuns, ln.Idx);
                    else if (ln.Mapa != null) code = TraduceMapa(ln.Mapa, ctx, ln.Idx);
                    else if (ln.Modelo3D != null)
                    {
                        // 24-sep, Jorge: «como Python que tiene el 3D … con el cursor del mouse hover».
                        // Los datos salen como literales separados por ;: la losa, las barras y sus valores.
                        var tr = new Tr(ctx);
                        var args = PartirNivel0(Normaliza(ln.Modelo3D), ',').Select(a => tr.Expr(a)).ToList();
                        if (args.Count < 5) throw new FormatException("#modelo3d(X, cascaras, barras, valor_nudo, valor_barra[, U, escala]): faltan datos");
                        code = "(hn-emit " + ln.Idx + " \"#m3d\" (format nil \"~{~a~^;~}\" (mapcar #'hn-lit (list " + string.Join(" ", args) + "))))";
                    }
                    else if (ln.Malla != null)
                    {
                        var tr = new Tr(ctx);
                        var args = PartirNivel0(Normaliza(ln.Malla), ',').Select(a => tr.Expr(a)).ToList();
                        if (args.Count < 3) throw new FormatException("#malla(x, y, elementos, apoyos[, restricciones]): faltan datos");
                        code = "(hn-emit " + ln.Idx + " \"#mesh\" (format nil \"~{~a~^;~}\" (mapcar #'hn-lit (list " + string.Join(" ", args) + "))))";
                    }
                    else code = TraduceLinea(Normaliza(ln.Texto).Trim(), ctx, ln.Idx, ln.Visible);
                }
                catch (Exception ex) { res.Error[ln.Idx] = ex.Message; continue; }
                if (code == null) continue;
                res.Calculada.Add(ln.Idx);
                items.Append("    (handler-case (progn (setf *hn-line* ").Append(ln.Idx).Append(") ").Append(code)
                     .Append(") (error (c) (hn-fail ").Append(ln.Idx).Append(" c)))\n");
            }
            var decl = ctx.Vars.Select(Sym).Concat(ctx.SheetFuncs.Select(FSym)).Distinct().ToList();
            var prog = new StringBuilder();
            prog.Append(defuns);
            // compilar rápido: el programa corre una vez (el trabajo pesado está en el motor ya compilado)
            prog.Append("(let ((*hn-line* 0) (hn-t0 (get-internal-real-time)))\n  (declare (optimize (compilation-speed 3) (speed 0) (debug 0) (safety 1)))\n  (let* (");
            prog.Append(string.Join(" ", decl.Select(d => "(" + d + " 0)")));
            prog.Append(")\n");
            if (decl.Count > 0) prog.Append("    (declare (ignorable ").Append(string.Join(" ", decl)).Append("))\n");
            prog.Append(items);
            prog.Append("    nil)\n  (hn-emit 0 \"#t\" (format nil \"~,4f\" (/ (- (get-internal-real-time) hn-t0) internal-time-units-per-second))))\n");
            res.Programa = prog.ToString();

            var sw = System.Diagnostics.Stopwatch.StartNew();
            string outp;
            try { outp = LispEngine.RunScript(res.Programa); }
            catch (Exception ex) { outp = "\x1d0\x1f!\x1f" + ex.Message; }
            sw.Stop();
            res.Segundos = sw.Elapsed.TotalSeconds;
            Lee(outp ?? "", res);
            return res;
        }

        static bool ParamsSimples(string ps)
            => ps.Trim().Length == 0 || ps.Split(',').All(p => Regex.IsMatch(p.Trim(), @"^[A-Za-z_]\w*$"));

        /// <summary>Una línea de la hoja entra al programa numérico si es matemática: nada de operadores
        /// simbólicos {…} (Diff, Area…), ni cadenas de igualdades, ni texto.</summary>
        static bool EsNumerica(string t)
        {
            if (t.Length == 0) return false;
            if (t[0] == '#' || t[0] == ';' || t[0] == '%' || t[0] == '\'') return false;
            if (t.IndexOf('{') >= 0 || t.IndexOf('}') >= 0 || t.Contains("@@") || t.Contains("→")) return false;
            if (Regex.IsMatch(t, @"(?<!\|)\|(?!\|)")) return false;   // 3m|cm: la barra de unidades va por su motor
            // dos '=' de asignación (a = b = c) → notación
            int eqs = Regex.Matches(t, @"(?<![=<>~!])=(?!=)").Count;
            return eqs <= 1;
        }

        static void RecogeBloque(List<string> src, Ctx ctx)
        {
            foreach (var raw in src)
                foreach (var st in Sentencias(raw))
                {
                    var t = st.Trim();
                    var fh = Regex.Match(t, @"^function\s+(?:(?:\[[^\]]*\]|[A-Za-z_]\w*)\s*=\s*)?([A-Za-z_]\w*)\s*\(");
                    if (fh.Success) { ctx.UserFuncs.Add(fh.Groups[1].Value); continue; }
                    var fr = Regex.Match(t, @"^for\s+([A-Za-z_]\w*)\s*=");
                    if (fr.Success) { ctx.Vars.Add(fr.Groups[1].Value); continue; }
                    var a = RxAsig.Match(t);
                    if (a.Success && !RxKw.IsMatch(t)) { ctx.Vars.Add(a.Groups[1].Value); continue; }
                    var ia = RxIdxAsig.Match(t);
                    if (ia.Success && !RxKw.IsMatch(t)) ctx.Vars.Add(ia.Groups[1].Value);
                }
        }

        /// <summary>Una línea física → sentencias: quita el comentario % y parte por ';' de nivel 0.</summary>
        static IEnumerable<string> Sentencias(string raw)
        {
            var line = PalabraCalcpad(Normaliza(raw ?? ""));
            int pc = IndiceComentario(line);
            if (pc >= 0) line = line.Substring(0, pc);
            int depth = 0; var cur = new StringBuilder();
            foreach (var c in line)
            {
                if (c == '(' || c == '[') depth++;
                else if (c == ')' || c == ']') depth--;
                if (c == ';' && depth == 0) { if (cur.ToString().Trim().Length > 0) yield return cur.ToString(); cur.Clear(); }
                else cur.Append(c);
            }
            if (cur.ToString().Trim().Length > 0) yield return cur.ToString();
        }
        static int IndiceComentario(string s)
        {
            for (int i = 0; i < s.Length; i++) if (s[i] == '%') return i;
            return -1;
        }

        // ---------------------------- líneas de la hoja ----------------------------
        static string TraduceLinea(string t, Ctx ctx, int idx, bool visible)
        {
            if (!EsNumerica(t)) return null;
            var fd = RxFuncDef.Match(t);
            if (fd.Success && ctx.SheetFuncs.Contains(fd.Groups[1].Value))
            {
                var ps = fd.Groups[2].Value.Split(',').Select(p => p.Trim()).Where(p => p.Length > 0).ToList();
                var body = new Tr(ctx, ps).Expr(fd.Groups[3].Value);
                return "(setf " + FSym(fd.Groups[1].Value) + " (lambda (" + string.Join(" ", ps.Select(Sym)) + ") " + body + "))";
            }
            var asg = RxAsig.Match(t);
            if (asg.Success)
            {
                var n = asg.Groups[1].Value;
                var e = Valor(new Tr(ctx).Expr(asg.Groups[2].Value));
                return "(setf " + Sym(n) + " " + e + ")" + (visible ? " (hn-out " + idx + " \"" + n + "\" " + Sym(n) + ")" : "");
            }
            var ia = RxIdxAsig.Match(t);
            if (ia.Success && ctx.Vars.Contains(ia.Groups[1].Value))
            {
                var n = ia.Groups[1].Value;
                return IdxAsig(n, ia.Groups[2].Value, ia.Groups[3].Value, new Tr(ctx)) +
                       (visible ? " (hn-out " + idx + " \"" + n + "\" " + Sym(n) + ")" : "");
            }
            if (t.Contains('=') && !Regex.IsMatch(t, @"[=<>~!]=|=[=]")) return null;   // otra cosa con '=' (notación)
            // expresión suelta: se calcula y se muestra
            var ex = new Tr(ctx).Expr(t);
            return visible ? "(hn-out " + idx + " \"\" " + ex + ")" : ex;
        }

        // SEMÁNTICA DE VALOR (MATLAB): «B = A» es una COPIA. Las matrices del motor son vectores de
        // filas que hn-set modifica en sitio; si B = A solo copiara la referencia, B(i, j) = … cambiaría
        // también A. Solo el nombre suelto comparte: A + 0, A', A(:, :), [A] … ya dan un arreglo nuevo.
        static readonly Regex RxSoloNombre = new(@"^\|[^|]+\|$");
        static string Valor(string e) => RxSoloNombre.IsMatch(e) ? "(hn-copy " + e + ")" : e;

        static string IdxAsig(string name, string args, string rhs, Tr tr)
        {
            var ai = tr.Args(args);
            return "(setf " + Sym(name) + " (hn-set " + Sym(name) + " " + tr.Expr(rhs) + " " + string.Join(" ", ai) + "))";
        }

        // #map(expr, [xa xb], [ya yb])  → la rejilla la calcula el motor numérico
        static string TraduceMapa(string inside, Ctx ctx, int idx)
        {
            var partes = PartirNivel0(Normaliza(inside), ',');
            if (partes.Count < 1) return null;
            string f = partes[0].Trim();
            var rangos = new List<(string, string)>();
            for (int k = 1; k < partes.Count; k++)
            {
                var m = Regex.Match(partes[k].Trim(), @"^\[(.*)\]$");
                if (!m.Success) continue;
                var ab = PartirEspacios(m.Groups[1].Value);
                if (ab.Count == 2) rangos.Add((ab[0], ab[1]));
            }
            // las dos variables del mapa: las dos primeras letras libres (no variables ni funciones)
            var libres = new List<string>();
            foreach (Match m in Regex.Matches(f, @"(?<![\w.])[A-Za-z_]\w*"))
            {
                var id = m.Value;
                if (ctx.Vars.Contains(id) || ctx.SheetFuncs.Contains(id) || ctx.UserFuncs.Contains(id) || Builtins.Contains(id) || id == "pi") continue;
                if (!libres.Contains(id)) libres.Add(id);
            }
            if (libres.Count == 0) libres.Add("x");
            if (libres.Count == 1) libres.Add(libres[0] == "y" ? "x" : "y");
            var tr = new Tr(ctx, libres.Take(2).ToList());
            var body = tr.Expr(f);
            var tr0 = new Tr(ctx);
            string xa = rangos.Count > 0 ? tr0.Expr(rangos[0].Item1) : "0", xb = rangos.Count > 0 ? tr0.Expr(rangos[0].Item2) : "1";
            string ya = rangos.Count > 1 ? tr0.Expr(rangos[1].Item1) : xa, yb = rangos.Count > 1 ? tr0.Expr(rangos[1].Item2) : xb;
            return "(hn-grid " + idx + " (lambda (" + Sym(libres[0]) + " " + Sym(libres[1]) + ") " + body + ") " +
                   xa + " " + xb + " " + ya + " " + yb + " 90)";
        }

        static List<string> PartirEspacios(string s)
        {
            // "0 a" · "0, a" · "0 a/2" → trozos a nivel 0
            var res = new List<string>(); var cur = new StringBuilder(); int d = 0;
            foreach (var c in s)
            {
                if (c == '(' || c == '[') d++; else if (c == ')' || c == ']') d--;
                if ((c == ' ' || c == ',') && d == 0) { if (cur.Length > 0) { res.Add(cur.ToString()); cur.Clear(); } }
                else cur.Append(c);
            }
            if (cur.Length > 0) res.Add(cur.ToString());
            return res;
        }
        static List<string> PartirNivel0(string s, char sep)
        {
            var res = new List<string>(); var cur = new StringBuilder(); int d = 0;
            foreach (var c in s)
            {
                if (c == '(' || c == '[' || c == '{') d++; else if (c == ')' || c == ']' || c == '}') d--;
                if (c == sep && d == 0) { res.Add(cur.ToString()); cur.Clear(); } else cur.Append(c);
            }
            res.Add(cur.ToString());
            return res;
        }

        // ---------------------------- bloques ----------------------------
        static string TraduceBloque(List<string> src, Ctx ctx, StringBuilder defuns, int idx)
        {
            var sts = new List<string>();
            foreach (var raw in src) sts.AddRange(Sentencias(raw).Select(s => s.Trim()).Where(s => s.Length > 0));
            int i = 0;
            var forms = new List<string>();
            while (i < sts.Count)
            {
                if (Kw(sts[i]) == "function") { defuns.Append(Funcion(sts, ref i, ctx)).Append('\n'); continue; }
                forms.Add(Sentencia(sts, ref i, ctx, new List<string>()));
            }
            return forms.Count == 0 ? "nil" : string.Join("\n      ", forms);
        }

        static string Kw(string s) { var m = RxKw.Match(s); return m.Success ? m.Groups[1].Value : ""; }

        static string Sentencia(List<string> sts, ref int i, Ctx ctx, List<string> bound)
        {
            var s = sts[i]; var kw = Kw(s);
            var tr = new Tr(ctx, bound);
            if (kw == "for")
            {
                i++;
                var m = Regex.Match(s, @"^for\s+([A-Za-z_]\w*)\s*=\s*(.+)$");
                if (!m.Success) throw new FormatException("for: se esperaba  for i = a:b");
                var v = m.Groups[1].Value;
                var body = Cuerpo(sts, ref i, ctx, bound, "end");
                Fin(sts, ref i);
                var r = PartirNivel0(m.Groups[2].Value, ':');
                string head;
                if (r.Count == 2) head = "(loop for " + Sym(v) + " from " + tr.Expr(r[0]) + " to " + tr.Expr(r[1]);
                else if (r.Count == 3 && Regex.IsMatch(r[1].Trim(), @"^-\s*[\d.]+$"))
                    head = "(loop for " + Sym(v) + " from " + tr.Expr(r[0]) + " downto " + tr.Expr(r[2]) + " by " + tr.Expr(r[1].Trim().Substring(1));
                else if (r.Count == 3 && Regex.IsMatch(r[1].Trim(), @"^[\d.]+$"))
                    head = "(loop for " + Sym(v) + " from " + tr.Expr(r[0]) + " to " + tr.Expr(r[2]) + " by " + tr.Expr(r[1]);
                else head = "(loop for " + Sym(v) + " across (let ((hn-v " + tr.Expr(m.Groups[2].Value) + ")) (if (vectorp hn-v) hn-v (vector hn-v)))";
                return head + " do " + body + ")";
            }
            if (kw == "while")
            {
                i++;
                var c = tr.Expr(s.Substring(5));
                var body = Cuerpo(sts, ref i, ctx, bound, "end");
                Fin(sts, ref i);
                return "(loop while (hn-true " + c + ") do " + body + ")";
            }
            if (kw == "if")
            {
                i++;
                var sb = new StringBuilder("(cond ((hn-true " + tr.Expr(s.Substring(2)) + ") " + Cuerpo(sts, ref i, ctx, bound, "elseif", "else", "end") + ")");
                while (i < sts.Count)
                {
                    var k2 = Kw(sts[i]);
                    if (k2 == "elseif") { var c = tr.Expr(sts[i].Substring(6)); i++; sb.Append(" ((hn-true " + c + ") " + Cuerpo(sts, ref i, ctx, bound, "elseif", "else", "end") + ")"); }
                    else if (k2 == "else") { i++; sb.Append(" (t " + Cuerpo(sts, ref i, ctx, bound, "end") + ")"); break; }
                    else break;
                }
                Fin(sts, ref i);
                return sb.Append(")").ToString();
            }
            if (kw == "break") { i++; return "(return)"; }
            if (kw == "continue") throw new FormatException("continue todavía no está: usa if … end");
            if (kw == "end") throw new FormatException("«end» sin bloque que cerrar");
            i++;
            var a = RxAsig.Match(s);
            if (a.Success) return "(setf " + Sym(a.Groups[1].Value) + " " + Valor(tr.Expr(a.Groups[2].Value)) + ")";
            var ia = RxIdxAsig.Match(s);
            if (ia.Success) return IdxAsig(ia.Groups[1].Value, ia.Groups[2].Value, ia.Groups[3].Value, tr);
            return tr.Expr(s);   // expresión suelta: se evalúa (disp(x) imprime)
        }

        static string Cuerpo(List<string> sts, ref int i, Ctx ctx, List<string> bound, params string[] stops)
        {
            var forms = new List<string>();
            while (i < sts.Count && !stops.Contains(Kw(sts[i])))
                forms.Add(Sentencia(sts, ref i, ctx, bound));
            return forms.Count == 0 ? "nil" : "(progn " + string.Join(" ", forms) + ")";
        }
        static void Fin(List<string> sts, ref int i)
        {
            if (i < sts.Count && Kw(sts[i]) == "end") i++;
            else throw new FormatException("falta el «end» de un bloque");
        }

        static string Funcion(List<string> sts, ref int i, Ctx ctx)
        {
            var m = Regex.Match(sts[i], @"^function\s+(?:([A-Za-z_]\w*)\s*=\s*)?([A-Za-z_]\w*)\s*\(([^)]*)\)");
            if (!m.Success) throw new FormatException("function: se esperaba  function y = f(a, b)");
            i++;
            string ret = m.Groups[1].Success ? m.Groups[1].Value : null, name = m.Groups[2].Value;
            var ps = m.Groups[3].Value.Split(',').Select(p => p.Trim()).Where(p => p.Length > 0).ToList();
            // la función ve SOLO sus argumentos y sus variables (como MATLAB)
            var fctx = new Ctx(); fctx.UserFuncs.UnionWith(ctx.UserFuncs);
            foreach (var p in ps) fctx.Vars.Add(p);
            int j = i, depth = 1; var cuerpo = new List<string>();
            for (; j < sts.Count; j++)
            {
                var k = Kw(sts[j]);
                if (k is "for" or "while" or "if" or "function") depth++;
                else if (k == "end") { depth--; if (depth == 0) break; }
                cuerpo.Add(sts[j]);
            }
            RecogeBloque(cuerpo, fctx);
            if (ret != null) fctx.Vars.Add(ret);
            int q = 0; var forms = new List<string>();
            while (q < cuerpo.Count) forms.Add(Sentencia(cuerpo, ref q, fctx, new List<string>()));
            i = j + 1;
            var locals = fctx.Vars.Where(v => !ps.Contains(v)).Select(Sym).ToList();
            // un argumento que la función cambia por índice se copia al entrar (MATLAB: paso por valor)
            var cambiados = ps.Where(p => cuerpo.Any(c => Regex.IsMatch(c, @"^\s*" + Regex.Escape(p) + @"\s*\(.*\)\s*=(?!=)"))).ToList();
            forms.InsertRange(0, cambiados.Select(p => "(setf " + Sym(p) + " (hn-copy " + Sym(p) + "))"));
            return "(defun " + USym(name) + " (" + string.Join(" ", ps.Select(Sym)) + ")\n  (let* (" +
                   string.Join(" ", locals.Select(l => "(" + l + " 0)")) + ")" +
                   (locals.Count > 0 ? " (declare (ignorable " + string.Join(" ", locals) + "))" : "") + "\n    " +
                   string.Join("\n    ", forms) + (ret != null ? "\n    " + Sym(ret) : "") + "))";
        }

        // nombres LISP: |a| distingue mayúsculas (e ≠ E) y no choca con T, PI, …
        static string Sym(string n) => "|" + n + "|";
        static string FSym(string n) => "|f." + n + "|";
        static string USym(string n) => "|u." + n + "|";

        sealed class Ctx
        {
            public readonly HashSet<string> Vars = new(StringComparer.Ordinal);
            public readonly HashSet<string> SheetFuncs = new(StringComparer.Ordinal);
            public readonly HashSet<string> UserFuncs = new(StringComparer.Ordinal);
            public readonly HashSet<string> PorDefinir = new(StringComparer.Ordinal);
        }

        // ============================== expresiones ==============================
        sealed class Tk { public char K; public string S; public bool SpB; public bool SpA; }   // K: n=num i=id o=op

        sealed class Tr
        {
            readonly Ctx ctx; readonly HashSet<string> bound;
            List<Tk> ts; int p;
            public Tr(Ctx c, IEnumerable<string> b = null) { ctx = c; bound = new HashSet<string>(b ?? Enumerable.Empty<string>(), StringComparer.Ordinal); }

            public string Expr(string s)
            {
                ts = Lex(s); p = 0;
                if (ts.Count == 0) throw new FormatException("expresión vacía");
                var r = Or(true);
                if (p < ts.Count) throw new FormatException("sobra «" + ts[p].S + "» en: " + s.Trim());
                return r;
            }
            public List<string> Args(string s)
            {
                ts = Lex(s); p = 0;
                var r = ArgList(')', false);
                return r;
            }

            static List<Tk> Lex(string s)
            {
                var r = new List<Tk>(); int i = 0;
                bool Sp(int k) => k >= 0 && k < s.Length && char.IsWhiteSpace(s[k]);
                while (i < s.Length)
                {
                    char c = s[i];
                    if (char.IsWhiteSpace(c)) { i++; continue; }
                    int st = i;
                    if (char.IsDigit(c) || (c == '.' && i + 1 < s.Length && char.IsDigit(s[i + 1])))
                    {
                        while (i < s.Length && (char.IsDigit(s[i]) || (s[i] == '.' && !(i + 1 < s.Length && (s[i + 1] == '*' || s[i + 1] == '/' || s[i + 1] == '^' || s[i + 1] == '\''))))) i++;
                        if (i < s.Length && (s[i] == 'e' || s[i] == 'E') && i + 1 < s.Length &&
                            (char.IsDigit(s[i + 1]) || ((s[i + 1] == '-' || s[i + 1] == '+') && i + 2 < s.Length && char.IsDigit(s[i + 2]))))
                        { i += 2; while (i < s.Length && char.IsDigit(s[i])) i++; }
                        r.Add(new Tk { K = 'n', S = s.Substring(st, i - st), SpB = Sp(st - 1), SpA = Sp(i) });
                        continue;
                    }
                    if (char.IsLetter(c) || c == '_')
                    {
                        while (i < s.Length && (char.IsLetterOrDigit(s[i]) || s[i] == '_')) i++;
                        r.Add(new Tk { K = 'i', S = s.Substring(st, i - st), SpB = Sp(st - 1), SpA = Sp(i) });
                        continue;
                    }
                    string two = i + 1 < s.Length ? s.Substring(i, 2) : "";
                    if (two is "==" or "~=" or "!=" or "<=" or ">=" or "&&" or "||" or ".*" or "./" or ".^" or ".'")
                    { r.Add(new Tk { K = 'o', S = two, SpB = Sp(i - 1), SpA = Sp(i + 2) }); i += 2; continue; }
                    if ("+-*/\\^()[],;:'<>~!&|@=".IndexOf(c) >= 0)
                    { r.Add(new Tk { K = 'o', S = c.ToString(), SpB = Sp(i - 1), SpA = Sp(i + 1) }); i++; continue; }
                    throw new FormatException("carácter no válido «" + c + "»");
                }
                return r;
            }

            Tk Cur => p < ts.Count ? ts[p] : null;
            bool IsOp(string o) => Cur != null && Cur.K == 'o' && Cur.S == o;
            bool Eat(string o) { if (IsOp(o)) { p++; return true; } return false; }
            void Need(string o) { if (!Eat(o)) throw new FormatException("falta «" + o + "»"); }

            string Or(bool rng)
            {
                var a = And(rng);
                while (IsOp("||") || IsOp("|")) { p++; a = "(or (hn-true " + a + ") (hn-true " + And(rng) + "))"; }
                return a;
            }
            string And(bool rng)
            {
                var a = Cmp(rng);
                while (IsOp("&&") || IsOp("&")) { p++; a = "(and (hn-true " + a + ") (hn-true " + Cmp(rng) + "))"; }
                return a;
            }
            string Cmp(bool rng)
            {
                var a = Range(rng);
                while (Cur != null && Cur.K == 'o' && (Cur.S is "==" or "~=" or "!=" or "<" or ">" or "<=" or ">="))
                {
                    var o = Cur.S; p++;
                    var b = Range(rng);
                    string op = o switch { "==" => "=", "~=" or "!=" => "/=", _ => o };
                    a = "(" + op + " " + a + " " + b + ")";
                }
                return a;
            }
            string Range(bool rng)
            {
                var a = Add();
                if (!rng || !IsOp(":")) return a;
                p++;
                var b = Add();
                if (IsOp(":")) { p++; var c = Add(); return "(hn-range " + a + " " + c + " " + b + ")"; }
                return "(hn-range " + a + " " + b + ")";
            }
            bool inMat;   // dentro de [ ]: «1 -2» son dos elementos
            string Add()
            {
                var a = Mul();
                while (Cur != null && Cur.K == 'o' && (Cur.S == "+" || Cur.S == "-"))
                {
                    if (inMat && Cur.SpB && !Cur.SpA) break;     // [a -b] → otro elemento
                    var o = Cur.S; p++;
                    a = "(hn" + o + " " + a + " " + Mul() + ")";
                }
                return a;
            }
            string Mul()
            {
                var a = Unary();
                while (Cur != null && Cur.K == 'o' && (Cur.S is "*" or "/" or "\\" or ".*" or "./"))
                {
                    var o = Cur.S; p++;
                    var b = Unary();
                    a = o switch
                    {
                        "*" => "(hn* " + a + " " + b + ")",
                        "/" => "(hn/ " + a + " " + b + ")",
                        "\\" => "(hnb-solve " + a + " " + b + ")",
                        ".*" => "(hn.* " + a + " " + b + ")",
                        _ => "(hn./ " + a + " " + b + ")",
                    };
                }
                return a;
            }
            string Unary()
            {
                if (IsOp("-")) { p++; return "(hn- " + Unary() + ")"; }
                if (IsOp("+")) { p++; return Unary(); }
                if (IsOp("~") || IsOp("!")) { p++; return "(not (hn-true " + Unary() + "))"; }
                return Pow();
            }
            string Pow()
            {
                var a = Postfix();
                while (IsOp("^") || IsOp(".^"))
                {
                    var o = Cur.S; p++;
                    var b = PowArg();
                    a = (o == "^" ? "(hn^ " : "(hn.^ ") + a + " " + b + ")";
                }
                return a;
            }
            string PowArg()
            {
                if (IsOp("-")) { p++; return "(hn- " + PowArg() + ")"; }
                if (IsOp("+")) { p++; return PowArg(); }
                return Postfix();
            }
            string Postfix()
            {
                var a = Primary();
                while (IsOp("'") || IsOp(".'")) { p++; a = "(hn-tr " + a + ")"; }
                return a;
            }
            string Primary()
            {
                var t = Cur;
                if (t == null) throw new FormatException("expresión incompleta");
                if (t.K == 'n') { p++; return Num(t.S); }
                if (t.K == 'i') { p++; return Ident(t.S); }
                if (t.S == "(") { p++; bool m0 = inMat; inMat = false; var r = Or(true); inMat = m0; Need(")"); return r; }
                if (t.S == "[") { p++; return Matriz(); }
                if (t.S == "@")
                {
                    p++; Need("(");
                    var ps = new List<string>();
                    while (!IsOp(")"))
                    {
                        if (Cur == null || Cur.K != 'i') throw new FormatException("@(…): se esperaba el nombre de un argumento");
                        ps.Add(Cur.S); p++;
                        if (!Eat(",")) break;
                    }
                    Need(")");
                    var saved = new HashSet<string>(bound);
                    foreach (var q in ps) bound.Add(q);
                    bool m0 = inMat; inMat = false;
                    var body = Or(true);
                    inMat = m0;
                    bound.Clear(); bound.UnionWith(saved);
                    return "(lambda (" + string.Join(" ", ps.Select(Sym)) + ") " + body + ")";
                }
                throw new FormatException("no se esperaba «" + t.S + "»");
            }
            static string Num(string s)
            {
                if (s.StartsWith(".")) s = "0" + s;
                if (s.EndsWith(".")) s += "0";
                return s;
            }
            string Ident(string id)
            {
                bool call = IsOp("(") && !(inMat && ts[p].SpB);   // [a (b)] en matriz = dos elementos
                if (!call)
                {
                    if (bound.Contains(id) || ctx.Vars.Contains(id)) return Sym(id);
                    if (id == "pi") return "pi";
                    if (ctx.SheetFuncs.Contains(id)) return FSym(id);
                    if (ctx.UserFuncs.Contains(id)) return "#'" + USym(id);
                    if (Builtins.Contains(id)) return "#'hnb-" + id;
                    throw new FormatException("«" + id + "» no tiene valor (no se asigna en ninguna parte)");
                }
                p++;
                var args = ArgList(')', true);
                Need(")");
                string a = string.Join(" ", args);
                string sp = args.Count > 0 ? " " : "";
                if (bound.Contains(id) || ctx.Vars.Contains(id)) return "(hn-ref " + Sym(id) + sp + a + ")";
                if (ctx.SheetFuncs.Contains(id)) return "(funcall " + FSym(id) + sp + a + ")";
                if (ctx.UserFuncs.Contains(id)) return "(" + USym(id) + sp + a + ")";
                if (Builtins.Contains(id)) return "(hnb-" + id + sp + a + ")";
                throw new FormatException("función desconocida «" + id + "»");
            }
            List<string> ArgList(char close, bool inCall)
            {
                var args = new List<string>();
                bool m0 = inMat; inMat = false;
                if (!IsOp(close.ToString()))
                {
                    while (true)
                    {
                        if (IsOp(":") && (p + 1 >= ts.Count || ts[p + 1].S == "," || ts[p + 1].S == close.ToString()))
                        { p++; args.Add(":all"); }
                        else args.Add(Or(true));
                        if (!Eat(",")) break;
                    }
                }
                inMat = m0;
                return args;
            }
            string Matriz()
            {
                var rows = new List<List<string>>(); var cur = new List<string>();
                bool m0 = inMat; inMat = true;
                while (true)
                {
                    if (Cur == null) throw new FormatException("falta «]»");
                    if (IsOp("]")) { p++; break; }
                    if (IsOp(";")) { p++; rows.Add(cur); cur = new List<string>(); continue; }
                    if (IsOp(",")) { p++; continue; }
                    cur.Add(Or(true));
                }
                inMat = m0;
                rows.Add(cur);
                rows = rows.Where(r => r.Count > 0).ToList();
                if (rows.Count == 0) return "(vector)";
                return "(hn-cat (list " + string.Join(" ", rows.Select(r => "(list " + string.Join(" ", r) + ")")) + "))";
            }
        }

        // ============================== lectura de la salida ==============================
        static void Lee(string outp, Resultado res)
        {
            var inv = CultureInfo.InvariantCulture;
            foreach (var raw in outp.Replace("\r", "").Split('\n'))
            {
                int k = raw.IndexOf('\x1d');
                if (k < 0) continue;
                var parts = raw.Substring(k + 1).Split('\x1f');
                if (parts.Length < 3 || !int.TryParse(parts[0], out var idx)) continue;
                string tag = parts[1], text = string.Join("\x1f", parts.Skip(2));
                if (tag == "#t") { double.TryParse(text, NumberStyles.Float, inv, out res.SegundosMotor); continue; }
                if (tag == "!") res.Error[idx] = Mensaje(text);
                else if (tag == ">")
                {
                    if (!res.Salida.TryGetValue(idx, out var l)) res.Salida[idx] = l = new List<string>();
                    l.Add(text);
                }
                else if (tag == "#m3d")
                    res.Modelo3D[idx] = text.Split(';').ToList();
                else if (tag == "#mesh")
                {
                    var ps = text.Split(';');
                    double[] Nums(string lit) => RxNum.Matches(lit).Select(m => double.Parse(m.Value, NumberStyles.Float, inv)).ToArray();
                    var md = new MallaDatos { X = Nums(ps[0]), Y = ps.Length > 1 ? Nums(ps[1]) : new double[0] };
                    // elementos: cada (vector …) interior es un elemento
                    var el = ps.Length > 2 ? Regex.Matches(ps[2], @"\(vector ([^()]*)\)").Select(m => Nums(m.Groups[1].Value).Select(v => (int)Math.Round(v)).ToArray()).ToArray() : new int[0][];
                    md.Elem = el;
                    md.Apoyos = ps.Length > 3 ? Nums(ps[3]).Select(v => (int)Math.Round(v)).ToArray() : new int[0];
                    // 5.º dato opcional: qué grados de libertad fija cada apoyo (una fila por apoyo: 1 = fijo),
                    // p. ej. [w θx θy ψ] en la placa. El dibujo distingue apoyo puntual, borde apoyado y empotramiento.
                    if (ps.Length > 4)
                    {
                        var filas = Regex.Matches(ps[4], @"\(vector ([^()]*)\)").Select(m => Nums(m.Groups[1].Value).Select(v => (int)Math.Round(v)).ToArray()).ToArray();
                        if (filas.Length == 0) filas = Nums(ps[4]).Select(v => new[] { (int)Math.Round(v) }).ToArray();   // un código por apoyo
                        if (filas.Length == md.Apoyos.Length) md.Restr = filas;
                    }
                    if (md.X.Length == md.Y.Length && md.X.Length > 0) res.Malla[idx] = md;
                }
                else if (tag == "#grid")
                {
                    var nums = text.Split(' ', StringSplitOptions.RemoveEmptyEntries);
                    if (nums.Length < 5) continue;
                    var g = new Rejilla
                    {
                        Xa = double.Parse(nums[0], inv), Xb = double.Parse(nums[1], inv),
                        Ya = double.Parse(nums[2], inv), Yb = double.Parse(nums[3], inv), N = int.Parse(nums[4], inv)
                    };
                    g.Z = new double[g.N + 1, g.N + 1];
                    int q = 5;
                    for (int i = 0; i <= g.N; i++)
                        for (int j = 0; j <= g.N; j++)
                            g.Z[i, j] = q < nums.Length && double.TryParse(nums[q++], NumberStyles.Float, inv, out var z) ? z : 0;
                    res.Mapa[idx] = g;
                }
                else { res.Valor[idx] = text; res.Nombre[idx] = tag; }
            }
        }

        /// <summary>El error de SBCL, en palabras de la hoja.</summary>
        static string Mensaje(string m)
        {
            m = m.Replace("|", "");
            var u = Regex.Match(m, @"The variable (\S+) is unbound", RegexOptions.IgnoreCase);
            if (u.Success) return "«" + u.Groups[1].Value + "» no tiene valor";
            var f = Regex.Match(m, @"The function (?:COMMON-LISP-USER::)?(\S+) is undefined", RegexOptions.IgnoreCase);
            if (f.Success) return "función desconocida «" + f.Groups[1].Value.Replace("hnb-", "").Replace("f.", "").Replace("u.", "") + "»";
            if (Regex.IsMatch(m, @"is not of type NUMBER", RegexOptions.IgnoreCase))
                return "se esperaba un número y llegó un vector o una matriz (" + m + ")";
            return m;
        }

        // ============================== formato de números (como Calcpad) ==============================
        /// <summary>Calcpad muestra 6 decimales, y en |x| &lt; 1 siete cifras significativas.</summary>
        public static string Formato(double x)
        {
            var inv = CultureInfo.InvariantCulture;
            if (double.IsNaN(x) || double.IsInfinity(x)) return "0";
            if (x == 0) return "0";
            double ax = Math.Abs(x);
            if (ax >= 1e15 || ax < 1e-6)
            {
                // como Calcpad: 1.5·10²⁰ (se escribe como forma LISP para que el render ponga el exponente)
                int ex = (int)Math.Floor(Math.Log10(ax));
                double man = Math.Round(x / Math.Pow(10, ex), 6);
                if (Math.Abs(man) >= 10) { man /= 10; ex++; }
                string ms = man.ToString("0.######", inv);
                return ms == "1" ? "(expt 10 " + ex + ")" : ms == "-1" ? "(- (expt 10 " + ex + "))" : "(* " + ms + " (expt 10 " + ex + "))";
            }
            int dec = ax >= 1 ? 6 : Math.Min(15, 6 - (int)Math.Floor(Math.Log10(ax)));
            var s = Math.Round(x, dec).ToString("F" + dec, inv);
            if (s.Contains('.')) s = s.TrimEnd('0').TrimEnd('.');
            return s == "-0" ? "0" : s;
        }
        static readonly Regex RxNum = new(@"(?<![\w.])-?\d+(?:\.\d+)?(?:[eE][-+]?\d+)?(?![\w.])");
        /// <summary>El literal que devuelve el motor, con los números en formato Calcpad. Como Calcpad
        /// (Output/HtmWriter.cs: FormatMatrix/FormatVector), en una matriz se escribe 0 lo que es menor
        /// que 10⁻¹⁴ × el mayor valor; en un vector, lo menor que min(10⁻¹⁴ × el mayor, 10⁻¹⁴). Así el
        /// ruido de redondeo (2·10⁻¹⁴ donde vale 0) no se confunde con un resultado.</summary>
        public static string FormatoLiteral(string lit)
        {
            if (lit == null) return null;
            var inv = CultureInfo.InvariantCulture;
            double thr = 0;
            if (lit.StartsWith("(vector"))
            {
                double mx = 0;
                foreach (Match m in RxNum.Matches(lit))
                    if (double.TryParse(m.Value, NumberStyles.Float, inv, out var v0)) mx = Math.Max(mx, Math.Abs(v0));
                thr = lit.StartsWith("(vector (vector") ? mx * 1e-14 : Math.Min(mx * 1e-14, 1e-14);
            }
            return RxNum.Replace(lit, m =>
                !double.TryParse(m.Value, NumberStyles.Float, inv, out var v) ? m.Value
                : Math.Abs(v) < thr && Math.Abs(v) < 1e-6 ? "0" : Formato(v));   // solo lo que Calcpad escribiría ×10⁻ⁿ
        }
    }
}
