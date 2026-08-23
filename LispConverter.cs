using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Text.RegularExpressions;

namespace HekatanLisp
{
    /// <summary>
    /// Convertidor con ARBOL (parser propio, sin CAS). Del mismo arbol produce:
    ///   - LISP:   (+ (expt x 2) (* 3 x))   ·   (vector 1 2 3)   ·   (sqrt x)
    ///   - MATLAB: x^2 + 3*x   ·   [1 2 3]   ·   sqrt(x)
    ///   - HTML:   x² + 3·x  ·  vector/matriz con corchetes  ·  √x  (estilo Hekatan Lab)
    /// </summary>
    public static class LispConverter
    {
        // ---------- arbol ----------
        public class N
        {
            public string Op;          // + - * / ^ neg | fn | vec | mat | null = atomo
            public string Atom;        // atomo, o nombre de función (si Op=="fn")
            public N A, B;             // hijos binarios
            public List<N> Items;      // elementos (vec), filas (mat), argumentos (fn)
            public bool IsAtom => Op == null;
            public static N Leaf(string s) => new N { Atom = s };
            public static N Make(string op, N a, N b = null) => new N { Op = op, A = a, B = b };
        }

        static bool IsNum(string s) => Regex.IsMatch(s, @"^-?[\d.]");
        static int Prec(string op) => op switch { "^" => 4, "*" or "/" => 2, "+" or "-" => 1, _ => 0 };

        // ---------- parse: MATEMATICA -> arbol ----------
        // $Nombre = operadores estilo Calcpad; {} = paréntesis; @ y : = bloque solver ($Op{f @ x = a : b}).
        // ∂ y ∇ cuentan como parte del identificador → así {∂N/∂s} renderiza la parcial en comentarios.
        // el '=' es necesario para los límites del solver:  Area{f @ x = a : b}  (antes se perdía)
        static readonly Regex Tok = new Regex(@"\d+\.?\d*|\$?[A-Za-z_∂∇][\w∂∇]*|[-+*/^(),;\[\]{}@:'=]");
        // operadores solver de Calcpad → función del motor
        static readonly Dictionary<string, string> SolverOps = new Dictionary<string, string>
        {
            { "area", "area-under" }, { "integral", "area-under" },
            { "slope", "slope-at" }, { "derivative", "slope-at" },
            { "sum", "suma-op" }, { "product", "producto-op" }, { "root", "root-op" },
            { "find", "find-op" }, { "sup", "sup-op" }, { "inf", "inf-op" }, { "repeat", "repeat-op" },
            { "lim", "limite" }, { "limit", "limite" }, { "limite", "limite" },   // límite  lim_{x→a} f
            // tokens de operación simbólica (nuestra notación): computan inline
            { "partial", "partial" }, { "derivate", "derive-x" }, { "diff", "derive-x" },
            { "simplify", "factor" }, { "factor", "factor" }, { "expand", "expand*" },
        };

        public static N ParseMath(string s)
        {
            // multiplicación escrita a la Jorge: ·  ∙  ⋅  ×  → *  (el tokenizer solo conoce '*').
            //   menos/'/' unicode → ASCII.  Sin esto "12·10^6" se leía como 12 (se perdía el operador).
            s = s.Replace('·', '*').Replace('∙', '*').Replace('⋅', '*').Replace('×', '*')
                 .Replace('−', '-').Replace('∕', '/').Replace('⁄', '/');
            var toks = new List<string>();
            foreach (Match m in Tok.Matches(s)) toks.Add(m.Value);
            if (toks.Count == 0) return null;
            var p = new MP(toks);
            return p.Range();
        }

        class MP
        {
            readonly List<string> t; int i;
            public MP(List<string> toks) { t = toks; }
            string Peek() => i < t.Count ? t[i] : null;
            string Eat() => t[i++];
            // RANGO estilo MATLAB:  a:b  (paso 1)  ·  a:s:b  (paso s).  Precedencia más baja.
            public N Range()
            {
                var a = Expr();
                if (Peek() != ":") return a;
                Eat();
                var b = Expr();
                if (Peek() == ":") { Eat(); var c = Expr(); return new N { Op = "range", Items = new List<N> { a, b, c } }; }
                return new N { Op = "range", Items = new List<N> { a, b } };
            }
            public N Expr()
            {
                var n = Term();
                while (Peek() == "+" || Peek() == "-") { var op = Eat(); n = N.Make(op, n, Term()); }
                return n;
            }
            N Term()
            {
                var n = Factor();
                while (Peek() == "*" || Peek() == "/") { var op = Eat(); n = N.Make(op, n, Factor()); }
                return n;
            }
            N Factor()
            {
                // menos unario liga MENOS que la potencia: -x^2 = -(x^2), -(x-1)^2 = -((x-1)^2)
                if (Peek() == "-") { Eat(); return N.Make("neg", Factor()); }
                var n = Base();
                while (Peek() == "'") { Eat(); n = new N { Op = "trans", A = n }; }   // A' = transpuesta (postfija)
                if (Peek() == "^") { Eat(); n = N.Make("^", n, Factor()); }
                return n;
            }
            N Base()
            {
                var t0 = Peek();
                if (t0 == "(") { Eat(); var n = Expr(); if (Peek() == ")") Eat(); return n; }
                if (t0 == "[") return VecMat();
                if (t0 == null) throw new Exception("fin inesperado");
                var id = Eat();
                bool isName = id.Length > 0 && (char.IsLetter(id[0]) || id[0] == '_' || id[0] == '$');
                var fname0 = id.StartsWith("$") ? id.Substring(1) : id;
                // OPERADOR SOLVER: matemática es NUESTRA notación → acepta  Area{…}  con o sin '$',
                // y sin importar mayúsculas ($Area, Area, area, AREA…).
                var solverKey = fname0.ToLower();
                if (isName && SolverOps.ContainsKey(solverKey) && Peek() == "{")
                {
                    Eat();  // {
                    var f = Expr();
                    var items = new List<N> { f };
                    if (Peek() == "@")
                    {
                        Eat();
                        string vv = Peek(); Eat();               // variable
                        items.Add(N.Leaf(vv));
                        // 'a' (y 'b') SOLO si hay '=' — así Partial{f @ x} queda con 2 campos (sin comerse el '}')
                        if (Peek() == "=")
                        {
                            Eat();
                            items.Add(Expr());                        // a (punto o límite inferior)
                            if (Peek() == ":") { Eat(); items.Add(Expr()); }   // b (límite superior)
                        }
                    }
                    if (Peek() == "}") Eat();
                    return new N { Op = "solver", Atom = solverKey, Items = items };   // atom = area|slope|sum|...
                }
                // función normal: identificador seguido de '(' o '{'
                if (isName && (Peek() == "(" || Peek() == "{"))
                {
                    string close = Peek() == "(" ? ")" : "}";
                    Eat();
                    var args = new List<N>();
                    if (Peek() != close) { args.Add(Expr()); while (Peek() == ",") { Eat(); args.Add(Expr()); } }
                    if (Peek() == close) Eat();
                    return new N { Op = "fn", Atom = fname0, Items = args };
                }
                return N.Leaf(fname0);
            }
            N VecMat()
            {
                // Sintaxis MATLAB: dentro de [ ] la COMA (o el espacio) separa columnas y el
                // PUNTO Y COMA separa filas. El '|' NO va en el script (es OR en MATLAB); las filas
                // con '|' son solo cosa del RENDER. Los elementos separados por espacio funcionan
                // porque Expr() se detiene al no ver un operador (así "[2 3 4]" da 3 columnas).
                Eat();  // '['
                var rows = new List<List<N>>();
                var cur = new List<N>();
                while (Peek() != "]" && Peek() != null)
                {
                    if (Peek() == ";") { Eat(); rows.Add(cur); cur = new List<N>(); continue; }   // fila
                    if (Peek() == ",") { Eat(); continue; }                                        // columna
                    cur.Add(Range());   // cada elemento es una expresión o rango (espacio = siguiente columna)
                }
                if (Peek() == "]") Eat();
                rows.Add(cur);
                if (rows.Count == 1) return new N { Op = "vec", Items = rows[0] };   // fila
                return new N { Op = "mat", Items = rows.Select(r => new N { Op = "vec", Items = r }).ToList() };
            }
        }

        // ---------- parse: LISP -> arbol ----------
        public static N ParseLisp(string s)
        {
            var toks = new List<string>();
            foreach (var part in s.Replace("(", " ( ").Replace(")", " ) ")
                     .Split(new[] { ' ', '\t' }, StringSplitOptions.RemoveEmptyEntries))
                toks.Add(part);
            if (toks.Count == 0) return null;
            int i = 0;
            return ReadLisp(toks, ref i);
        }

        static readonly HashSet<string> Bin = new HashSet<string> { "+", "-", "*", "/", "expt" };

        static readonly Dictionary<string, string> SolverFn = new Dictionary<string, string>
        {
            { "area-under", "area" }, { "slope-at", "slope" }, { "suma", "sum" },
            { "producto-op", "product" }, { "root-op", "root" },
            { "find-op", "find" }, { "sup-op", "sup" }, { "inf-op", "inf" }, { "repeat-op", "repeat" },
            { "partial", "partial" }, { "derive-x", "derivate" }, { "integ-var", "integral" },
            { "factor", "factor" }, { "expand*", "expand" }, { "limite", "lim" },
        };

        static N ReadLisp(List<string> toks, ref int i)
        {
            var t = toks[i++];
            if (t == "'" || t == "`") return ReadLisp(toks, ref i);   // quote suelto (antes de lista) → transparente
            if (t.Length > 1 && (t[0] == '\'' || t[0] == '`')) t = t.Substring(1);   // 'x → x
            if (t != "(") return N.Leaf(t);
            var op = toks[i++];
            var args = new List<N>();
            while (i < toks.Count && toks[i] != ")") args.Add(ReadLisp(toks, ref i));
            if (i < toks.Count) i++;   // descarta ')'

            // reconstruye el nodo SOLVER ($area, $slope…) para que se muestre con su notación
            if (SolverFn.TryGetValue(op, out var sv)) return new N { Op = "solver", Atom = sv, Items = args };
            // operaciones de matriz: se vuelven a mostrar como Aᵀ y a:b (no "mtransp(A)")
            if (op == "mtransp" && args.Count == 1) return new N { Op = "trans", A = args[0] };
            if (op == "mrange") return new N { Op = "range", Items = args };

            if (op == "vector")
            {
                if (args.Count > 0 && args.All(a => a.Op == "vec")) return new N { Op = "mat", Items = args };
                return new N { Op = "vec", Items = args };
            }
            if (!Bin.Contains(op))   // función: (sqrt x), (sin x), (deriv ...)
                return new N { Op = "fn", Atom = op, Items = args };

            var o = op == "expt" ? "^" : op;
            if (args.Count == 1) return o == "-" ? N.Make("neg", args[0]) : args[0];
            var acc = args[0];
            for (int k = 1; k < args.Count; k++) acc = N.Make(o, acc, args[k]);
            return acc;
        }

        // ---------- operadores solver de Calcpad ($Op) en las 4 formas ----------
        static (string f, string v, string a, string b) SolverParts(N n, Func<N, string> conv)
        {
            string f = conv(n.Items[0]);
            string v = n.Items.Count > 1 ? conv(n.Items[1]) : "x";
            string a = n.Items.Count > 2 ? conv(n.Items[2]) : "0";
            string b = n.Items.Count > 3 ? conv(n.Items[3]) : null;
            return (f, v, a, b);
        }
        // destino del límite: infinito (inf/∞) se muestra como ∞; si no, el valor tal cual.
        static string LimTarget(N node, string aHtml)
        {
            if (node != null && node.IsAtom && node.Atom != null)
            {
                var s = node.Atom.ToLower();
                if (s == "inf" || s == "infinity" || s == "infty" || s == "∞") return "∞";
                if (s == "-inf" || s == "-infinity") return "−∞";
            }
            return aHtml;
        }
        static string SolverToLisp(N n)   // → llamada al motor (f y var CITADOS)
        {
            var (f, v, a, b) = SolverParts(n, x => ToLisp(x));
            return n.Atom switch
            {
                "area" => $"(area-under '{f} '{v} {a} {b})",
                "integral" => b != null ? $"(area-under '{f} '{v} {a} {b})" : $"(integ-var '{f} '{v})",
                "slope" or "derivative" => $"(slope-at '{f} '{v} {a})",
                "partial" => $"(partial '{f} '{v})",
                "derivate" or "diff" => n.Items.Count > 1 ? $"(partial '{f} '{v})" : $"(derive-x '{f})",
                "simplify" or "factor" => $"(factor '{f})",
                "expand" => $"(expand* '{f})",
                "sum" => $"(suma '{f} '{v} {a} {b})",
                "product" => $"(producto-op '{f} '{v} {a} {b})",
                "lim" or "limit" or "limite" => $"(limite '{f} '{v} {a})",   // lím  x→a  f

                "root" => $"(root-op '{f} '{v})",
                "find" => $"(find-op '{f} '{v} {a} {b})",
                "sup" => $"(sup-op '{f} '{v} {a} {b})",
                "inf" => $"(inf-op '{f} '{v} {a} {b})",
                "repeat" => $"(repeat-op '{f} '{v} {a} {b})",
                _ => $"({n.Atom} '{f} '{v} {a})",
            };
        }
        public static bool LabMatlab = false;   // true = render de solver como MATLAB (Hekatan Lab); false = Calcpad
        static string SolverToLab(N n)
        {
            var (f, v, a, b) = SolverParts(n, x => ToLab(x, 0));
            if (LabMatlab)   // Hekatan Lab / MATLAB 2017a
                return n.Atom switch
                {
                    "area" => "int(" + f + ", " + v + ", " + a + ", " + b + ")",
                    "integral" => b != null ? "int(" + f + ", " + v + ", " + a + ", " + b + ")" : "int(" + f + ", " + v + ")",
                    "slope" or "derivative" => "subs(diff(" + f + ", " + v + "), " + v + ", " + a + ")",
                    "partial" or "derivate" or "diff" => "diff(" + f + ", " + v + ")",
                    "simplify" => "simplify(" + f + ")",
                    "factor" => "factor(" + f + ")",
                    "expand" => "expand(" + f + ")",
                    "sum" => "symsum(" + f + ", " + v + ", " + a + ", " + b + ")",
                    "product" => "symprod(" + f + ", " + v + ", " + a + ", " + b + ")",
                    "root" => "solve(" + f + " == 0, " + v + ")",
                    "find" => "fzero(@(" + v + ") " + f + ", [" + a + " " + b + "])",
                    "sup" => "max(arrayfun(@(" + v + ") " + f + ", linspace(" + a + ", " + b + ", 1e5)))",
                    "inf" => "min(arrayfun(@(" + v + ") " + f + ", linspace(" + a + ", " + b + ", 1e5)))",
                    "repeat" => "subs(" + f + ", " + v + ", " + b + ")",
                    _ => n.Atom + "(" + f + ", " + v + ", " + a + ")",
                };
            // matemática = NUESTRA notación (no Calcpad): sin '$'. La forma la decide cuántos campos hay:
            //   1 → Op{f}   ·   2 → Op{f @ v}   ·   3 → Op{f @ v = a}   ·   4 → Op{f @ v = a : b}
            string cap = char.ToUpper(n.Atom[0]) + n.Atom.Substring(1);
            int nc = n.Items.Count;
            string inside = nc <= 1 ? f
                          : nc == 2 ? f + " @ " + v
                          : nc == 3 ? f + " @ " + v + " = " + a
                          : f + " @ " + v + " = " + a + " : " + b;
            return cap + "{" + inside + "}";
        }
        static string SolverToHtml(N n)   // → render IGUAL a Hekatan Lab/Calcpad (dvr/nary: límites apilados)
        {
            var (f, v, a, b) = SolverParts(n, x => ToHtml(x));
            // n-ario apilado como Calcpad: <dvr><small>sup</small><nary>Σ</nary><small>sub</small></dvr> expr
            string Nary(string sym, string sub, string sup, string expr) =>
                "<span class=\"m-dvr\"><small>" + sup + "</small><span class=\"m-nary\">" + sym +
                "</span><small>" + sub + "</small></span>" + expr;
            string idx = "<span class=\"m-var\">" + v + "</span><span class=\"m-op\">=</span>" + a;
            // d/dv (derivada total) como fracción vertical
            string ddv = "<span class=\"m-frac\"><span class=\"m-frn\"><span class=\"m-fn\">d</span></span>" +
                         "<span class=\"m-frd\"><span class=\"m-fn\">d</span><span class=\"m-var\">" + v + "</span></span></span>";
            // ∂/∂v (derivada PARCIAL) — el símbolo ∂, no la 'd'
            string pdv = "<span class=\"m-frac\"><span class=\"m-frn\"><span class=\"m-fn\">∂</span></span>" +
                         "<span class=\"m-frd\"><span class=\"m-fn\">∂</span><span class=\"m-var\">" + v + "</span></span></span>";
            // palabra clave + llaves (find/sup/inf/root/repeat) como Calcpad: name{ ... }
            string vv = "<span class=\"m-var\">" + v + "</span>";
            string interval = vv + " <span class=\"m-op\">∈</span> [" + a + "<span class=\"m-op\">;</span> " + (b ?? "") + "]";
            string Kw(string name, string inside) =>
                "<span class=\"m-cond\">" + name + "</span><span class=\"m-op\">{</span>" + inside + "<span class=\"m-op\">}</span>";
            string dx = " <span class=\"m-fn\">d</span><span class=\"m-var\">" + v + "</span>";
            return n.Atom switch
            {
                "area" => Nary("∫", a, b ?? "", "&hairsp;" + f + dx),
                "integral" => b != null ? Nary("∫", a, b, "&hairsp;" + f + dx) : Nary("∫", "", "", "&hairsp;" + f + dx),
                "sum" => Nary("Σ", idx, b ?? "", "&hairsp;" + f),
                "product" => Nary("∏", idx, b ?? "", "&hairsp;" + f),
                "lim" or "limit" or "limite" =>
                    "<span class=\"m-lim\"><span class=\"m-lim-op\">lim</span><small class=\"m-lim-sub\">" + v +
                    "→" + LimTarget(n.Items.Count > 2 ? n.Items[2] : null, a) + "</small></span>&hairsp;" + Paren(f),
                "slope" or "derivative" => ddv + Paren(f) + "<span class=\"m-op\"> │</span><sub class=\"m-sub\">" + v + "=" + a + "</sub>",
                "partial" => pdv + Paren(f),                           // ∂/∂x (f) — derivada PARCIAL
                "derivate" or "diff" => ddv + Paren(f),                // d/dx (f) — derivada total
                // simplify/factor/expand NO tienen símbolo matemático: se muestra solo la EXPRESIÓN,
                // y el " = resultado" (que agrega el display) ya dice que se operó. Matemática pura.
                "simplify" or "factor" or "expand" => f,
                "root" => Kw("root", f + " <span class=\"m-op\">=</span> 0"),   // simbólico: TODAS las raíces (sin intervalo)
                "find" => Kw("find", f + "<span class=\"m-op\">;</span> " + interval),
                "sup" => Kw("sup", f + "<span class=\"m-op\">;</span> " + interval),
                "inf" => Kw("inf", f + "<span class=\"m-op\">;</span> " + interval),
                "repeat" => Kw("repeat", f + " <span class=\"m-cond\">para</span> " + vv + " <span class=\"m-op\">=</span> " + a + "…" + (b ?? "")),
                _ => "<span class=\"m-fn\">" + n.Atom + "</span>" + Paren(f),
            };
        }

        // Sustituye en el árbol los átomos que son ETIQUETAS de la hoja por su definición.
        // Ej: si v = w*x, entonces  Partial{v @ x}  →  Partial{(w*x) @ x}.  'self' = la etiqueta
        // de la propia línea (no se auto-sustituye); 'active' evita ciclos.
        public static N SubstLabels(N n, Dictionary<string, N> map, string self, HashSet<string> active)
        {
            if (n == null) return null;
            if (n.IsAtom)
            {
                if (n.Atom != self && !active.Contains(n.Atom) && map.TryGetValue(n.Atom, out var def))
                {
                    active.Add(n.Atom);
                    var r = SubstLabels(def, map, self, active);
                    active.Remove(n.Atom);
                    return r;
                }
                return n;
            }
            return new N
            {
                Op = n.Op, Atom = n.Atom,
                A = SubstLabels(n.A, map, self, active),
                B = SubstLabels(n.B, map, self, active),
                Items = n.Items?.Select(x => SubstLabels(x, map, self, active)).ToList()
            };
        }

        // β-REDUCCIÓN: aplica las funciones definidas por el usuario.  f(x)=x²+1 y luego f(3) → 3²+1.
        // Es el mismo mecanismo de la época LISP/Macsyma: una función es un cuerpo con parámetros, y
        // "aplicarla" es SUSTITUIR el argumento en el parámetro (subst). Recursivo: reduce composiciones
        // f(G(x)) reduciendo primero los argumentos. `active` evita bucle si una def se llama a sí misma.
        public static N SubstFuncs(N n, Dictionary<string, (List<string> ps, N body)> fns,
                                   Dictionary<string, N> vecs = null, HashSet<string> active = null)
        {
            if (n == null) return null;
            active ??= new HashSet<string>();
            if (n.Op == "fn" && n.Items != null)
            {
                // (a) LLAMADA DE FUNCIÓN  f(x) → β-reducción (si f está definida como función)
                if (fns.TryGetValue(n.Atom, out var def) && def.ps.Count == n.Items.Count && !active.Contains(n.Atom))
                {
                    var pmap = new Dictionary<string, N>();
                    for (int i = 0; i < def.ps.Count; i++)
                        pmap[def.ps[i]] = SubstFuncs(n.Items[i], fns, vecs, active);   // reduce args (composición)
                    var body = SubstLabels(def.body, pmap, null, new HashSet<string>());   // param → argumento
                    active.Add(n.Atom);
                    var r = SubstFuncs(body, fns, vecs, active);                   // reduce funciones anidadas
                    active.Remove(n.Atom);
                    return r;
                }
                // (b) ÍNDICE de vector/matriz  v(i), A(i,j) → componente (estilo MATLAB 2017a),
                //     SOLO si el nombre es un vector/matriz definido y los índices son enteros.
                if (vecs != null && vecs.TryGetValue(n.Atom, out var cont))
                {
                    var args = n.Items.Select(x => SubstFuncs(x, fns, vecs, active)).ToList();
                    var hit = TryIndex(cont, args);
                    if (hit != null) return hit;
                }
            }
            if (n.IsAtom) return n;
            return new N
            {
                Op = n.Op, Atom = n.Atom,
                A = SubstFuncs(n.A, fns, vecs, active),
                B = SubstFuncs(n.B, fns, vecs, active),
                Items = n.Items?.Select(x => SubstFuncs(x, fns, vecs, active)).ToList()
            };
        }

        // v(k) → k-ésima componente (1-based, MATLAB) · A(i,j) → elemento fila i, columna j.
        // Devuelve null si los índices no son enteros o se salen de rango (se deja como v(i) simbólico).
        static N TryIndex(N cont, List<N> args)
        {
            int? IntOf(N x) => x != null && x.IsAtom && int.TryParse(x.Atom, out var v) ? v : (int?)null;
            if (cont == null) return null;
            if (cont.Op == "vec" && args.Count == 1)
            {
                var k = IntOf(args[0]);
                if (k >= 1 && k <= cont.Items.Count) return cont.Items[k.Value - 1];
            }
            if (cont.Op == "mat" && args.Count == 2)
            {
                int? i = IntOf(args[0]), j = IntOf(args[1]);
                if (i >= 1 && i <= cont.Items.Count)
                {
                    var row = cont.Items[i.Value - 1];
                    if (row?.Op == "vec" && j >= 1 && j <= row.Items.Count) return row.Items[j.Value - 1];
                }
            }
            return null;
        }

        // ---------- render: arbol -> LISP ----------
        public static string ToLisp(N n)
        {
            if (n == null) return "";
            if (n.Op == "solver") return SolverToLisp(n);
            if (n.IsAtom) return n.Atom;
            if (n.Op == "neg") return "(- " + ToLisp(n.A) + ")";
            if (n.Op == "trans") return "(mtransp " + ToLisp(n.A) + ")";
            if (n.Op == "range") return "(mrange " + string.Join(" ", n.Items.Select(ToLisp)) + ")";
            if (n.Op == "fn") return "(" + n.Atom + " " + string.Join(" ", n.Items.Select(ToLisp)) + ")";
            if (n.Op == "vec" || n.Op == "mat") return "(vector " + string.Join(" ", n.Items.Select(ToLisp)) + ")";
            var o = n.Op == "^" ? "expt" : n.Op;
            return "(" + o + " " + ToLisp(n.A) + " " + ToLisp(n.B) + ")";
        }

        // ---------- render: arbol -> MATLAB (texto) ----------
        public static string ToLab(N n, int outer = 0)
        {
            if (n == null) return "";
            if (n.Op == "solver") return SolverToLab(n);
            if (n.IsAtom) return n.Atom;
            if (n.Op == "neg") return "-" + ToLab(n.A, 3);
            if (n.Op == "fn")
            {
                if (n.Atom == "deriv") return "diff(" + string.Join(", ", n.Items.Select(x => ToLab(x, 0))) + ")";
                if (n.Atom == "integ" || n.Atom == "int") return "int(" + string.Join(", ", n.Items.Select(x => ToLab(x, 0))) + ")";
                return n.Atom + "(" + string.Join(", ", n.Items.Select(x => ToLab(x, 0))) + ")";
            }
            if (n.Op == "vec") return "[" + string.Join(" ", n.Items.Select(x => ToLab(x, 0))) + "]";
            if (n.Op == "mat")
                return "[" + string.Join("; ", n.Items.Select(r => string.Join(" ", r.Items.Select(x => ToLab(x, 0))))) + "]";
            int p = Prec(n.Op);
            string sep = n.Op switch { "+" => " + ", "-" => " - ", "*" => "*", "/" => "/", "^" => "^", _ => n.Op };
            // en - / ^ (no conmutativos) el lado DERECHO necesita más paréntesis: a/(2*b), a-(b+c)
            int pr = (n.Op == "-" || n.Op == "/" || n.Op == "^") ? p + 1 : p;
            string s = ToLab(n.A, p) + sep + ToLab(n.B, pr);
            return p < outer ? "(" + s + ")" : s;
        }

        // ---------- render: arbol -> HTML matematico (estilo Hekatan Lab) ----------
        // paréntesis que CRECEN con el contenido (arcos CSS, como los corchetes de matriz):
        // así "( fracción )²" queda con los paréntesis del alto de la fracción, no pequeños.
        static string Paren(string s) =>
            "<span class=\"m-paren\"><span class=\"m-pl\"></span>" + s + "<span class=\"m-pr\"></span></span>";

        // nombre con SUBÍNDICE: "N1" -> N con 1 abajo · "sigma_x" -> sigma con x abajo.
        // Convención ingenieril: dígitos finales (o lo que sigue a "_") es subíndice.
        // nombres de letras griegas → su símbolo (como Hekatan Lab): theta→θ, gamma→γ, sigma→σ…
        static readonly Dictionary<string, string> Greek = new Dictionary<string, string>
        {
            {"alpha","α"},{"beta","β"},{"gamma","γ"},{"delta","δ"},{"epsilon","ε"},{"zeta","ζ"},
            {"eta","η"},{"theta","θ"},{"iota","ι"},{"kappa","κ"},{"lambda","λ"},{"mu","μ"},
            {"nu","ν"},{"xi","ξ"},{"omicron","ο"},{"rho","ρ"},{"sigma","σ"},{"tau","τ"},
            {"upsilon","υ"},{"phi","φ"},{"chi","χ"},{"psi","ψ"},{"omega","ω"},
            {"Alpha","Α"},{"Beta","Β"},{"Gamma","Γ"},{"Delta","Δ"},{"Theta","Θ"},{"Lambda","Λ"},
            {"Xi","Ξ"},{"Sigma","Σ"},{"Phi","Φ"},{"Psi","Ψ"},{"Omega","Ω"},
        };
        // (πi lo maneja el motor como constante; no lo meto aquí para no chocar con 'pi' numérico)
        static string GreekSym(string s) => Greek.TryGetValue(s, out var g) ? g : System.Net.WebUtility.HtmlEncode(s);

        // acento centrado ARRIBA del contenido (flecha, sombrero, punto, tilde) — como Hekatan Lab.
        static string Over(string acc, string inner) =>
            "<span style=\"display:inline-block;position:relative;text-align:center;\">" + inner +
            "<span style=\"position:absolute;left:0;right:0;top:-.52em;font-size:.72em;font-style:normal;font-weight:400;line-height:1;\">"
            + acc + "</span></span>";
        // DECORA la base con sufijos de NOMBRE (válidos porque ⃗ ̄ ̂ no se teclean), igual que Hekatan Lab:
        //   Fvec → F⃗   ·   xbar → x̄   ·   xhat → x̂   ·   xdot → ẋ   ·   xtilde → x̃
        // La flecha del VECTOR es de Hekatan Lab (Calcpad no la tiene). Recursivo + griegas al final.
        static readonly (string tok, string acc)[] Decos =
            { ("vec", "&#8594;"), ("hat", "^"), ("tilde", "~"), ("dot", "&#183;") };
        static string DecorateBase(string b)
        {
            if (string.IsNullOrEmpty(b)) return "";
            if (b.Length > 3 && b.EndsWith("bar"))
                return "<span style=\"display:inline-block;border-top:.08em solid currentColor;line-height:1.05;padding:0 .04em;\">"
                     + DecorateBase(b.Substring(0, b.Length - 3)) + "</span>";
            foreach (var (tok, acc) in Decos)
                if (b.Length > tok.Length && b.EndsWith(tok))
                    return Over(acc, DecorateBase(b.Substring(0, b.Length - tok.Length)));
            return GreekSym(b);
        }

        static string VarHtml(string name, bool vecArrow = false)
        {
            string baseN, sub;
            int us = name.IndexOf('_');
            if (us > 0 && us < name.Length - 1) { baseN = name.Substring(0, us); sub = name.Substring(us + 1); }
            else
            {
                int i = name.Length;
                while (i > 1 && char.IsDigit(name[i - 1])) i--;
                baseN = name.Substring(0, i); sub = name.Substring(i);
            }
            // subíndice SOLO si el nombre empieza por letra (no en "-1", que es un número)
            if (sub.Length > 0 && !(baseN.Length > 0 && char.IsLetter(baseN[0]))) { baseN = name; sub = ""; }
            // vecArrow: la variable ES un vector/matriz → flecha automática sobre el nombre (v → v⃗).
            var deco = vecArrow ? Over("&#8594;", DecorateBase(baseN)) : DecorateBase(baseN);   // theta→θ, Fvec→F⃗…
            var h = "<span class=\"m-var\">" + deco + "</span>";
            if (sub.Length > 0) h += "<sub class=\"m-sub\">" + System.Net.WebUtility.HtmlEncode(sub) + "</sub>";
            return h;
        }

        public static string ToHtml(N n, int parentPrec = 0)
        {
            if (n == null) return "";
            if (n.Op == "solver") return SolverToHtml(n);
            if (n.IsAtom)
                return IsNum(n.Atom) ? $"<span class=\"m-num\">{n.Atom}</span>"
                                     : VarHtml(n.Atom);
            if (n.Op == "neg")
            {
                var r = "<span class=\"m-op\">−</span>" + ToHtml(n.A, 3);
                return parentPrec > 3 ? Paren(r) : r;
            }
            if (n.Op == "trans")   // transpuesta: Aᵀ
                return ToHtml(n.A, 5) + "<sup class=\"m-sup\">T</sup>";
            if (n.Op == "range")   // rango a:b  ó  a:s:b
                return string.Join("<span class=\"m-op\">:</span>", n.Items.Select(x => ToHtml(x, 2)));
            if (n.Op == "fn") return FnHtml(n);
            if (n.Op == "vec") return GridHtml(new List<List<N>> { n.Items });
            if (n.Op == "mat") return GridHtml(n.Items.Select(r => r.Items).ToList());
            switch (n.Op)
            {
                case "^":
                    return ToHtml(n.A, 5) + "<sup class=\"m-sup\">" + ToHtml(n.B, 0) + "</sup>";
                case "/":
                    return "<span class=\"m-frac\"><span class=\"m-frn\">" + ToHtml(n.A, 0) +
                           "</span><span class=\"m-frd\">" + ToHtml(n.B, 0) + "</span></span>";
                case "*":
                {
                    var r = ToHtml(n.A, 2) + "<span class=\"m-op\">·</span>" + ToHtml(n.B, 2);
                    return parentPrec > 2 ? Paren(r) : r;
                }
                default: // + o -
                {
                    var sym = n.Op == "-" ? "−" : "+";
                    var r = ToHtml(n.A, 1) + " <span class=\"m-op\">" + sym + "</span> " +
                            ToHtml(n.B, n.Op == "-" ? 2 : 1);
                    return parentPrec > 1 ? Paren(r) : r;
                }
            }
        }

        // funciones: √ con radical, eˣ, y nombre(args) para el resto
        static string FnHtml(N n)
        {
            var name = n.Atom;
            var arg0 = n.Items.Count > 0 ? ToHtml(n.Items[0], 0) : "";
            switch (name)
            {
                case "sqrt":
                    return "<span class=\"m-sqrt\"><span class=\"m-rad\">√</span>" +
                           "<span class=\"m-radarg\">" + arg0 + "</span></span>";
                case "exp":
                    return "<span class=\"m-var\">e</span><sup class=\"m-sup\">" + arg0 + "</sup>";
                case "deriv":   // d/dx( expr )  — notación de derivada, como Hekatan Lab
                {
                    var v = n.Items.Count > 1 ? ToHtml(n.Items[1], 0) : "<span class=\"m-var\">x</span>";
                    return "<span class=\"m-frac\"><span class=\"m-frn\"><span class=\"m-op\">d</span></span>" +
                           "<span class=\"m-frd\"><span class=\"m-op\">d</span>" + v + "</span></span>" + Paren(arg0);
                }
                case "integ":
                case "int":     // ∫ expr dx  — notación de integral
                {
                    var v = n.Items.Count > 1 ? ToHtml(n.Items[1], 0) : "<span class=\"m-var\">x</span>";
                    return "<span class=\"m-op\" style=\"font-size:1.35em;vertical-align:-0.15em\">∫</span>&hairsp;" +
                           arg0 + "&thinsp;<span class=\"m-op\">d</span>" + v;
                }
                default:
                    var args = string.Join("<span class=\"m-op\">, </span>", n.Items.Select(x => ToHtml(x, 0)));
                    return FnNameHtml(name) + Paren(args);
            }
        }

        // nombre de FUNCIÓN con subíndice: N_1 → N₁ , N1 → N₁ , f → f (mismo split que las variables,
        // pero en estilo función m-fn). Así N_1(x) renderiza N₁(x), no "N_1(x)".
        static string FnNameHtml(string name)
        {
            string baseN, sub;
            int us = name.IndexOf('_');
            if (us > 0 && us < name.Length - 1) { baseN = name.Substring(0, us); sub = name.Substring(us + 1); }
            else
            {
                int i = name.Length;
                while (i > 1 && char.IsDigit(name[i - 1])) i--;
                baseN = name.Substring(0, i); sub = name.Substring(i);
            }
            if (sub.Length > 0 && !(baseN.Length > 0 && char.IsLetter(baseN[0]))) { baseN = name; sub = ""; }
            var h = "<span class=\"m-fn\">" + GreekSym(baseN) + "</span>";
            if (sub.Length > 0) h += "<sub class=\"m-sub\">" + System.Net.WebUtility.HtmlEncode(sub) + "</sub>";
            return h;
        }

        // vector/matriz: cuadrícula con corchetes grandes.
        // GRANDE (>9 col ó >11 filas): índices de fila/columna en los bordes y el centro
        //   COLAPSADO con … ⋮ ⋱ (como el MathCanvas de Hekatan Calc y como NumPy/MATLAB).
        //   Chica: cuadrícula simple, sin índices.
        static string GridHtml(List<List<N>> rows)
        {
            int nrows = rows.Count;
            int ncols = nrows == 0 ? 0 : rows.Max(r => r.Count);
            const int CMAX = 8, RMAX = 10;              // cuántas primeras se muestran antes de colapsar
            bool colBig = ncols > CMAX + 1;             // >9 columnas → colapsa horizontal
            bool rowBig = nrows > RMAX + 1;             // >11 filas   → colapsa vertical
            if (!colBig && !rowBig)                     // ---- matriz chica: como siempre ----
            {
                // separador vertical entre columnas si los elementos son SIMBÓLICOS (expresiones),
                // como Hekatan Lab: distingue dónde termina cada elemento. Números/variables solos, no.
                bool symSep = ncols > 1 && rows.Any(r => r.Any(c => c != null && !c.IsAtom));
                var sc = new StringBuilder();
                foreach (var row in rows)
                {
                    int cj = 0;
                    foreach (var cell in row)
                    {
                        string st = symSep && cj > 0 ? " style=\"border-left:1px solid var(--sep);padding-left:.55em\"" : "";
                        sc.Append("<span class=\"m-cell\"").Append(st).Append(">").Append(ToHtml(cell, 0)).Append("</span>");
                        cj++;
                    }
                }
                return "<span class=\"m-mat\"><span class=\"m-brk m-brl\"></span>" +
                       "<span class=\"m-mgrid\" style=\"grid-template-columns:repeat(" + ncols + ",auto)\">" +
                       sc + "</span><span class=\"m-brk m-brr\"></span></span>";
            }
            // ---- matriz grande: COLAPSABLE con índices + … ⋮ ⋱ y el MISMO corchete [ ] de siempre ----
            //   (limpia, sin barras ni marcos: como NumPy/MATLAB).
            var cols = new List<int>();
            if (colBig) { for (int j = 0; j < CMAX; j++) cols.Add(j); cols.Add(-1); cols.Add(ncols - 1); }
            else        { for (int j = 0; j < ncols; j++) cols.Add(j); }
            var rws = new List<int>();
            if (rowBig) { for (int i = 0; i < RMAX; i++) rws.Add(i); rws.Add(-1); rws.Add(nrows - 1); }
            else        { for (int i = 0; i < nrows; i++) rws.Add(i); }
            return IndexedGrid(rows, cols, rws, ncols, nrows);
        }

        // dibuja UNA cuadrícula con índices en los bordes; cols/rws son los índices a mostrar (-1 = hueco … ⋮ ⋱)
        static string IndexedGrid(List<List<N>> rows, List<int> cols, List<int> rws, int ncols, int nrows)
        {
            bool showCol = ncols > 1, showRow = nrows > 1;
            // separador vertical entre columnas de DATOS si la matriz es simbólica (como Hekatan Lab).
            bool symSep = ncols > 1 && rows.Any(r => r.Any(c => c != null && !c.IsAtom));
            int brkCol   = showRow ? 2 : 1;
            int dataCol0 = brkCol + 1;
            int brkRCol  = dataCol0 + cols.Count;
            int dataRow0 = showCol ? 2 : 1;

            var sb = new StringBuilder();
            // la fila de índices de columna añade altura ARRIBA → el centro del bloque sube y el '='
            // exterior queda alto. Compenso con padding-bottom = altura de esa fila: así el centro del
            // bloque baja hasta la MITAD del corchete (sobre los datos) SIN mover los índices hacia
            // arriba (un translate los sacaría del área y .ws-eq los recortaría).
            string shift = showCol ? " style=\"padding-bottom:1.15em\"" : "";
            sb.Append("<span class=\"m-matx\"").Append(shift).Append(">");
            if (showCol && showRow)
                sb.Append("<span class=\"m-mh\" style=\"grid-row:1;grid-column:1\"></span>");
            if (showCol)
                for (int ci = 0; ci < cols.Count; ci++)
                    sb.Append("<span class=\"m-mh\" style=\"grid-row:1;grid-column:").Append(dataCol0 + ci)
                      .Append("\">").Append(cols[ci] < 0 ? "⋯" : cols[ci].ToString()).Append("</span>");
            if (showRow)
                for (int ri = 0; ri < rws.Count; ri++)
                    sb.Append("<span class=\"m-mrh\" style=\"grid-row:").Append(dataRow0 + ri)
                      .Append(";grid-column:1\">").Append(rws[ri] < 0 ? "⋮" : rws[ri].ToString()).Append("</span>");
            sb.Append("<span class=\"m-brk m-brl\" style=\"grid-row:").Append(dataRow0).Append(" / span ")
              .Append(rws.Count).Append(";grid-column:").Append(brkCol).Append("\"></span>");
            sb.Append("<span class=\"m-brk m-brr\" style=\"grid-row:").Append(dataRow0).Append(" / span ")
              .Append(rws.Count).Append(";grid-column:").Append(brkRCol).Append("\"></span>");
            for (int ri = 0; ri < rws.Count; ri++)
                for (int ci = 0; ci < cols.Count; ci++)
                {
                    int r = rws[ri], c = cols[ci];
                    string txt = (r < 0 && c < 0) ? "<span class=\"m-ell\">⋱</span>"
                               : c < 0 ? "<span class=\"m-ell\">⋯</span>"
                               : r < 0 ? "<span class=\"m-ell\">⋮</span>"
                               : (c < rows[r].Count ? ToHtml(rows[r][c], 0) : "");
                    string bl = symSep && ci > 0 ? ";border-left:1px solid var(--sep)" : "";
                    sb.Append("<span class=\"m-mc\" style=\"grid-row:").Append(dataRow0 + ri)
                      .Append(";grid-column:").Append(dataCol0 + ci).Append(bl).Append("\">").Append(txt).Append("</span>");
                }
            sb.Append("</span>");
            return sb.ToString();
        }

        // ---------- pagina HTML completa (worksheet) — tema claro/oscuro como Hekatan Lab ----------
        public static bool Dark = true;
        const string ROOT_DARK  = ":root{--bg:#14161a;--fg:#e8e8e8;--mut:#9aa0a6;--var:#8ab4f8;--num:#9ecbff;--nary:#c080f0;--sep:#463f5c;}";
        const string ROOT_LIGHT = ":root{--bg:#FBF7EC;--fg:#2a2418;--mut:#6E664F;--var:#0066dd;--num:#0a3d91;--nary:#9b30d0;--sep:#c9b8dd;}";
        const string CSS = @"
*{box-sizing:border-box;}
body{margin:0;padding:10px 1.5em;background:var(--bg);color:var(--fg);
  font-family:'Segoe UI','Arial Nova',Helvetica,sans-serif;font-size:11pt;line-height:150%;overflow-x:hidden;}
.ws-eq{margin:0.4em 0;
  font-family:'Georgia Pro','Century Schoolbook','Times New Roman',Times,serif;font-size:11.5pt;
  overflow-x:auto;overflow-y:hidden;max-width:100%;}   /* matriz muy ancha (12×12): recorta al panel y hace scroll interno */
.ws-eq::-webkit-scrollbar{height:8px;} .ws-eq::-webkit-scrollbar-thumb{background:var(--mut);border-radius:4px;}
.ws-txt{font-family:'Segoe UI',sans-serif;font-size:10.5pt;color:var(--mut);font-weight:600;margin-top:1em;}
/* #deq: ecuación con ETIQUETA a la derecha, estilo libro/paper — «… (2.3.4)» */
.ws-deq{display:flex;align-items:center;gap:1.2em;}
.ws-deq>.deq-body{flex:1 1 auto;min-width:0;overflow-x:auto;overflow-y:hidden;}
.ws-deq>.deq-tag{flex:0 0 auto;color:var(--mut);font-size:.85em;white-space:nowrap;font-family:'Segoe UI',sans-serif;}
/* texto con formato (directivas ; estilo Hekatan Lab) */
.ws-fmt{font-family:'Segoe UI','Arial Nova',Helvetica,sans-serif;margin:.35em 0;color:var(--fg);}
.ws-h1{font-weight:700;font-size:15pt;margin:.7em 0 .35em;}
.ws-h2{font-weight:600;font-size:12.5pt;margin:.55em 0 .3em;}
.ws-h3{font-weight:600;font-size:11pt;margin:.45em 0 .25em;color:var(--mut);}
.al-left{text-align:left;} .al-center{text-align:center;} .al-right{text-align:right;}
.m-var{font-style:italic;color:var(--var);font-size:105%;} .m-num{color:var(--num);}
.m-op{color:var(--mut);padding:0 .08em;}
.m-fn{font-style:normal;font-weight:600;color:var(--fg);padding-right:.05em;}
.m-frac{display:inline-flex;flex-direction:column;vertical-align:middle;text-align:center;margin:0 .15em;line-height:110%;}
.m-frn{border-bottom:1pt solid currentColor;padding:0 .35em .5pt;}
.m-frd{padding:.5pt .35em 0;}
/* potencia y subindice — reglas EXACTAS de Calcpad (.eq sup/.eq sub) */
.m-sup{display:inline-block;margin-left:1pt;margin-top:-3pt;font-size:75%;}
.m-sub{font-family:Calibri,Candara,Corbel,sans-serif;font-size:80%;vertical-align:-18%;margin-left:1pt;}
.m-sqrt{display:inline-flex;align-items:flex-start;}
.m-rad{font-size:1.05em;}
.m-radarg{border-top:1.2px solid currentColor;padding:0 .2em;margin-left:-.05em;}
/* paréntesis que crecen (arcos): inline-flex + border-radius, se estiran al alto del contenido */
.m-paren{display:inline-flex;align-items:stretch;vertical-align:middle;}
.m-paren>.m-pl,.m-paren>.m-pr{width:.26em;flex:0 0 auto;border:.075em solid var(--mut);border-radius:50%;}
.m-paren>.m-pl{border-right:0;border-top-right-radius:0;border-bottom-right-radius:0;margin-right:.14em;}
.m-paren>.m-pr{border-left:0;border-top-left-radius:0;border-bottom-left-radius:0;margin-left:.14em;}
.m-mat{display:inline-flex;align-items:stretch;vertical-align:middle;margin:0 .2em;}
.m-brk{width:.32em;}
.m-brl{border:1.4px solid currentColor;border-right:none;}
.m-brr{border:1.4px solid currentColor;border-left:none;}
.m-mgrid{display:inline-grid;padding:.15em .35em;gap:.15em .7em;text-align:center;align-items:center;}
.m-cell{color:var(--num);}
/* matriz GRANDE: índices en los bordes + centro colapsado (… ⋮ ⋱), como Hekatan Calc */
.m-matx{display:inline-grid;vertical-align:middle;margin:0 .25em;row-gap:.05em;column-gap:0;align-items:center;justify-items:center;}
.m-mh{color:var(--mut);font-family:Calibri,Candara,Corbel,sans-serif;font-size:.72em;padding:0 .45em .1em;}
.m-mrh{color:var(--mut);font-family:Calibri,Candara,Corbel,sans-serif;font-size:.72em;padding:0 .35em 0 0;justify-self:end;}
.m-mc{color:var(--num);padding:.12em .45em;text-align:center;}
.m-matx>.m-brl{min-width:.3em;margin-right:.18em;align-self:stretch;}
.m-matx>.m-brr{min-width:.3em;margin-left:.18em;align-self:stretch;}
.m-ell{color:var(--mut);}
/* n-ario (∫ Σ Π) apilado — geometria exacta de Calcpad/Hekatan Lab */
.m-dvr{display:inline-block;vertical-align:middle;text-align:center;line-height:110%;white-space:nowrap;position:relative;top:-2pt;margin:0 .12em;}
.m-dvr small{font-family:Calibri,Candara,Corbel,sans-serif;font-size:70%;display:block;}
.m-nary{display:block;font-size:235%;line-height:70%;font-weight:200;color:var(--nary);font-family:'Georgia Pro','Century Schoolbook','Times New Roman',serif;margin:0 1pt 2pt 1pt;}
.m-cond{color:#e000d0;font-style:italic;padding:0 .05em;}
/* límite:  lim  apilado con  x→a  debajo */
.m-lim{display:inline-flex;flex-direction:column;align-items:center;vertical-align:middle;line-height:1;margin:0 .12em;}
.m-lim-op{font-style:normal;}
.m-lim-sub{font-family:Calibri,Candara,Corbel,sans-serif;font-size:.66em;margin-top:1px;color:var(--mut);}";

        // ---------- texto con FORMATO en un comentario ';' (Hekatan Lab/Calcpad-style) ----------
        // SBCL ignora la línea (es ';'); Hekatan LISP la DIBUJA. Al ejecutar el .lisp no se ve (es comentario).
        //   ;# Título      encabezado centrado   ·   ;## Subtítulo
        //   ;< texto  izquierda   ·   ;> texto  derecha   ·   ;| ó ;= texto  centrado   ·   ; texto  párrafo
        // inline:  *negrita*   _cursiva_   {Variable}=su valor
        public const string TxtMark = "T";   // prefijo interno de línea de texto formateado
        public const char TxtSep = '';
        // arma el marcador que RenderPage dibuja como texto formateado
        public static string TxtLine(string kind, string align, string html) =>
            TxtMark + TxtSep + kind + TxtSep + align + TxtSep + html;
        public static (string kind, string align, string text)? TextDirective(string raw)
        {
            var s0 = raw.TrimStart();
            if (s0.Length == 0) return null;
            char mk = s0[0];
            if (mk != '#' && mk != ';') return null;
            if (mk == '#')
            {
                // MATEMÁTICA: '#' estilo MARKDOWN.  encabezados por nº de '#':  # H1 · ## H2 · ### H3.
                // Alineación (la "forma"), con UN solo #:  #: izq · #| ó #= centro · #> der · #< izq.
                if (Regex.IsMatch(s0, @"^#+\s*(fplot|plot|ezplot|graficas?|grafico|surf|superficie|plot3d|mesh|map|mapa|heatmap|contourf?)\b", RegexOptions.IgnoreCase)) return null;
                if (s0.Length >= 2 && s0[1] != '#' && ":|=><".IndexOf(s0[1]) >= 0)
                {
                    var txt = s0.Substring(2).Trim();
                    return s0[1] == '|' || s0[1] == '=' ? ("p", "center", txt)
                         : s0[1] == '>' ? ("p", "right", txt) : ("p", "left", txt);   // ':' o '<'
                }
                int h = 0; while (h < s0.Length && s0[h] == '#') h++;
                var body = s0.Substring(h).Trim();
                return h >= 3 ? ("h3", "center", body) : h == 2 ? ("h2", "center", body) : ("h1", "center", body);
            }
            // LISP: ';' — esquema previo (compatibilidad)
            var s = s0.Substring(1).Trim();
            if (Regex.IsMatch(s, @"^(fplot|plot|ezplot|graficas?|grafico|surf|superficie|plot3d|mesh|map|mapa|heatmap|contourf?)\b", RegexOptions.IgnoreCase)) return null;
            if (s.StartsWith("##")) return ("h2", "center", s.Substring(2).Trim());
            if (s.StartsWith("#"))  return ("h1", "center", s.Substring(1).Trim());
            if (s.StartsWith("|") || s.StartsWith("=")) return ("p", "center", s.Substring(1).Trim());
            if (s.StartsWith(">")) return ("p", "right", s.Substring(1).Trim());
            if (s.StartsWith("<")) return ("p", "left", s.Substring(1).Trim());
            if (s.StartsWith(":") || s.StartsWith("-")) return ("p", "left", s.Substring(1).Trim());   // párrafo normal
            return ("p", "left", s);
        }
        // convierte el texto a HTML mezclando texto + variable/valor inline. MISMOS TOKENS que Hekatan Lab:
        //   @nombre   → "nombre = valor"   (el nombre Y su valor, renderizados a CSS)
        //   @{expr}   → solo el VALOR       (evalúa la expresión/etiqueta, aun con tokens anidados)
        //   {expr}    → solo el VALOR       (alias antiguo)   ·   *negrita*   _cursiva_
        // el resto del texto se escapa normal. Una @ suelta queda literal.
        // (bal) = una llave con UN nivel de anidamiento: así @{Factor{x^2+3*x}} agarra todo el interior.
        const string Bal = @"(?:[^{}]|\{[^{}]*\})*";
        public static string FormatInlineText(string t, Func<string, string> varLookup, Func<string, bool> isVec = null)
        {
            t = System.Net.WebUtility.HtmlEncode(t ?? "");
            // @{expr} → SOLO el valor
            t = Regex.Replace(t, @"@\{(" + Bal + @")\}", m =>
            {
                var v = varLookup?.Invoke(m.Groups[1].Value.Trim());
                return string.IsNullOrEmpty(v) ? m.Value : "<span class=\"m-expr\">" + v + "</span>";
            });
            // @nombre → "nombre = valor"
            t = Regex.Replace(t, @"@([A-Za-z_]\w*)", m =>
            {
                var name = m.Groups[1].Value;
                var v = varLookup?.Invoke(name);
                return string.IsNullOrEmpty(v) ? m.Value
                    : "<span class=\"m-expr\">" + VarHtml(name, isVec?.Invoke(name) ?? false) + "<span class=\"m-op\"> = </span>" + v + "</span>";
            });
            // {expr} → SOLO el valor (alias antiguo)
            t = Regex.Replace(t, @"\{(" + Bal + @")\}", m =>
            {
                var v = varLookup?.Invoke(m.Groups[1].Value.Trim());
                return string.IsNullOrEmpty(v) ? m.Value : "<span class=\"m-expr\">" + v + "</span>";
            });
            // markdown: **negrita** o __negrita__ ; *cursiva* o _cursiva_ (doble antes que simple)
            t = Regex.Replace(t, @"\*\*([^*]+)\*\*", "<b>$1</b>");
            t = Regex.Replace(t, @"__([^_]+)__", "<b>$1</b>");
            t = Regex.Replace(t, @"\*([^*]+)\*", "<i>$1</i>");
            t = Regex.Replace(t, @"_([^_]+)_", "<i>$1</i>");
            return t;
        }

        // separador del tag de #deq: la línea de display trae  "...ecuación...\x02(etiqueta)".
        public const char DeqSep = '\x02';

        // marcador de una GRÁFICA en su posición dentro del documento (se reemplaza por el HTML de la gráfica).
        public const string PlotSlot = "\x01PLOT\x01";

        // convierte  <div class="ws-eq…">CONTENIDO</div>  en la versión con ETIQUETA a la derecha (#deq).
        static string InjectDeqTag(string div, string tag)
        {
            int gt = div.IndexOf('>');
            int end = div.LastIndexOf("</div>");
            if (gt < 0 || end < 0 || end <= gt) return div;
            string open = div.Substring(0, gt);
            string content = div.Substring(gt + 1, end - gt - 1);
            if (!open.Contains("ws-deq")) open = open.Replace("class=\"ws-eq", "class=\"ws-eq ws-deq");
            return open + "><span class=\"deq-body\">" + content + "</span>" +
                   "<span class=\"deq-tag\">(" + System.Net.WebUtility.HtmlEncode(tag) + ")</span></div>";
        }

        public static string RenderPage(string text, bool fromLisp)
        {
            var body = new StringBuilder();
            foreach (var raw0 in text.Replace("\r", "").Split('\n'))
            {
                // #deq: la línea trae la ecuación y, tras \x02, la ETIQUETA que va a la derecha.
                string raw = raw0, deqTag = null;
                int ds = raw0.IndexOf(DeqSep);
                if (ds >= 0) { deqTag = raw0.Substring(ds + 1); raw = raw0.Substring(0, ds); }
                string div = RenderLineHtml(raw, fromLisp);
                if (deqTag != null && div.StartsWith("<div class=\"ws-eq")) div = InjectDeqTag(div, deqTag);
                body.Append(div);
            }
            return "<!doctype html><html><head><meta charset=\"utf-8\"><style>" +
                   (Dark ? ROOT_DARK : ROOT_LIGHT) + CSS +
                   "</style></head><body>" + body + MAT_JS + "</body></html>";
        }

        // renderiza UNA línea de display (texto formateado o ecuación) a su <div>. "" si es vacía/omitida.
        static string RenderLineHtml(string raw, bool fromLisp)
        {
            {
                // GRÁFICA en su posición: un hueco que MainWindow rellena con el HTML de la gráfica.
                if (raw == PlotSlot) return "<div class=\"hk-plotslot\"></div>";
                // marcador de TEXTO con formato (viene de una directiva ; procesada en ComputeResult)
                if (raw.StartsWith(TxtMark))
                {
                    var pz = raw.Split(TxtSep);   // ["","T",kind,align,html…]
                    string kind = pz.Length > 2 ? pz[2] : "p";
                    string align = pz.Length > 3 ? pz[3] : "left";
                    string htmlC = pz.Length > 4 ? string.Join(TxtSep.ToString(), pz.Skip(4)) : "";
                    string cls = kind == "h1" ? "ws-h1" : kind == "h2" ? "ws-h2" : kind == "h3" ? "ws-h3" : "";
                    return "<div class=\"ws-fmt " + cls + " al-" + align + "\">" + htmlC + "</div>";
                }
                var line = raw.Trim();
                if (line.Length == 0) return "";
                string prefix = "";
                var expr = line;
                if (line.StartsWith("= ") || line.StartsWith("→ ")) { prefix = line.Substring(0, 2); expr = line.Substring(2).Trim(); }
                // etiqueta "NAME = expr" (nombre que define la línea, ej. N1 = (1-s)/2)
                var lblM = prefix.Length == 0
                    ? System.Text.RegularExpressions.Regex.Match(line, @"^([A-Za-z]\w*)\s*=\s*(?![=])(.+)$")
                    : System.Text.RegularExpressions.Match.Empty;
                string html;
                if (lblM.Success)
                {
                    try
                    {
                        // "N1 = OPERACIÓN = RESULTADO": varios pasos separados por " = ".
                        var partes = System.Text.RegularExpressions.Regex.Split(lblM.Groups[2].Value, @"\s=\s");
                        var trees = new N[partes.Length];
                        for (int pi = 0; pi < partes.Length; pi++)
                            trees[pi] = fromLisp ? ParseLisp(partes[pi].Trim()) : ParseMath(partes[pi].Trim());
                        bool isVec = trees.Length > 0 && trees[0] != null && trees[0].Op == "vec";
                        var sb = new System.Text.StringBuilder(VarHtml(lblM.Groups[1].Value, isVec));
                        foreach (var rt in trees)
                            sb.Append("<span class=\"m-op\"> = </span><span class=\"m-expr\">").Append(ToHtml(rt)).Append("</span>");
                        html = sb.ToString();
                    }
                    catch { html = System.Net.WebUtility.HtmlEncode(line); }
                    return "<div class=\"ws-eq\">" + html + "</div>";
                }
                // "forma = resultado" (sin NOMBRE): parte por " = " y lo renderiza TODO en UNA línea.
                if (System.Text.RegularExpressions.Regex.IsMatch(expr, @"\s=\s"))
                {
                    try
                    {
                        var partes = System.Text.RegularExpressions.Regex.Split(expr, @"\s=\s");
                        var sb = new System.Text.StringBuilder();
                        for (int pi = 0; pi < partes.Length; pi++)
                        {
                            if (pi > 0) sb.Append("<span class=\"m-op\"> = </span>");
                            var rt = fromLisp ? ParseLisp(partes[pi].Trim()) : ParseMath(partes[pi].Trim());
                            sb.Append("<span class=\"m-expr\">").Append(ToHtml(rt)).Append("</span>");
                        }
                        return "<div class=\"ws-eq\">" + sb + "</div>";
                    }
                    catch { }   // si algún tramo no parsea, cae al manejo normal de abajo
                }
                // Prosa suelta de un programa (ej. "1D LINEAL (2 nodos):") no es UNA forma LISP.
                if (fromLisp && !expr.StartsWith("(") && expr.Contains(' '))
                    return "<div class=\"ws-eq ws-txt\">" + System.Net.WebUtility.HtmlEncode(line) + "</div>";
                try
                {
                    var tree = fromLisp ? ParseLisp(expr) : ParseMath(expr);
                    html = "<span class=\"m-expr\">" + ToHtml(tree) + "</span>";
                    if (prefix.Length > 0)
                        html = "<span class=\"m-op\">" + System.Net.WebUtility.HtmlEncode(prefix) + "</span>" + html;
                }
                catch { html = System.Net.WebUtility.HtmlEncode(line); }
                return "<div class=\"ws-eq\">" + html + "</div>";
            }
        }

        // el marco de la matriz es redimensionable con CSS (resize:both) — no hace falta JS.
        const string MAT_JS = "";

        // ---------- página de AYUDA (se muestra a la derecha cuando no hay script, como Hekatan Lab) ----------
        public static string HelpPage()
        {
            const string help = @"
<style>
.hp{max-width:760px;margin:0 auto;}
.hp h1{font-weight:700;font-size:20pt;text-align:center;margin:.2em 0 .1em;}
.hp .sub{text-align:center;color:var(--mut);margin:0 0 1.4em;font-size:11pt;}
.hp h2{font-weight:600;font-size:13pt;color:var(--var);border-bottom:1px solid var(--mut);
  padding-bottom:.2em;margin:1.4em 0 .5em;}
.hp table{border-collapse:collapse;width:100%;margin:.3em 0 .8em;font-size:10.5pt;}
.hp td{padding:.28em .6em;border-bottom:1px solid var(--mut);vertical-align:top;}
.hp td:first-child{white-space:nowrap;width:40%;}
.hp code{font-family:Consolas,'Cascadia Code',monospace;background:var(--bg);
  border:1px solid var(--mut);border-radius:4px;padding:.05em .35em;color:var(--num);font-size:.95em;}
.hp .rule{text-align:center;color:var(--mut);font-style:italic;margin:1.6em 0 .4em;}
.hp .foot{text-align:center;color:var(--mut);margin-top:1.8em;font-size:10pt;}
</style>
<div class='hp'>
<h1>Hekatan&nbsp;LISP</h1>
<div class='sub'>Calculadora simbólica — escribe a la izquierda y el resultado aparece aquí.</div>

<div class='rule'>La regla madre:&nbsp; <code>#</code> = texto (markdown) &nbsp;·&nbsp; sin <code>#</code> = matemática &nbsp;·&nbsp; <code>;</code> = LISP</div>

<h2>Texto (markdown, con #)</h2>
<table>
<tr><td><code># Título</code> · <code>## Sub</code> · <code>### Sub-sub</code></td><td>encabezados H1 / H2 / H3</td></tr>
<tr><td><code>#: texto</code></td><td>párrafo (izquierda)</td></tr>
<tr><td><code>#| texto</code> · <code>#&gt; texto</code> · <code>#&lt; texto</code></td><td>centrado · derecha · izquierda</td></tr>
<tr><td><code>**negrita**</code> · <code>*cursiva*</code></td><td>inline (también <code>__</code> y <code>_</code>)</td></tr>
<tr><td><code>@var</code> · <code>@{expr}</code></td><td>combinar texto + variable: “var = valor” · valor</td></tr>
</table>

<h2>Matemática (sin #)</h2>
<table>
<tr><td><code>A = [1 2; 3 4]</code></td><td>definir matriz / vector / número</td></tr>
<tr><td><code>Inv = A^-1</code></td><td>operación visible: <code>Inv = A⁻¹ = [resultado]</code></td></tr>
<tr><td><code>A'</code> · <code>A*B</code> · <code>A+B</code> · <code>1:5</code></td><td>transpuesta · producto · suma · rango</td></tr>
<tr><td><code>f(x)=x^2+1</code> → <code>f(3)</code></td><td>función y su aplicación (= 10)</td></tr>
<tr><td><code>v(i)</code> · <code>A(i,j)</code> · <code>N_1</code></td><td>índice de vector · de matriz · subíndice</td></tr>
<tr><td><code>Simplify{…}</code> · <code>Factor{…}</code> · <code>Partial{f @ x}</code></td><td>operaciones simbólicas</td></tr>
</table>

<div class='foot'>Botones de arriba: <b>Ejecutar</b> · <b>simplify / expand / diff / ∫</b> · copiar a <b>LISP</b> o <b>Hekatan&nbsp;Lab</b>.</div>
</div>";
            return "<!doctype html><html><head><meta charset=\"utf-8\"><style>" +
                   (Dark ? ROOT_DARK : ROOT_LIGHT) + CSS +
                   "</style></head><body>" + help + "</body></html>";
        }

        // ---------- evaluador NUMERICO del arbol (para graficar) ----------
        // sustituye la variable por un numero y calcula. Devuelve NaN si hay algo que no sabe evaluar.
        public static double Eval(N n, string var, double x)
        {
            if (n == null) return double.NaN;
            if (n.IsAtom)
            {
                if (IsNum(n.Atom)) return double.TryParse(n.Atom, System.Globalization.NumberStyles.Any,
                                        System.Globalization.CultureInfo.InvariantCulture, out var d) ? d : double.NaN;
                if (n.Atom == var) return x;
                if (n.Atom == "pi") return Math.PI;
                if (n.Atom == "e") return Math.E;
                return double.NaN;
            }
            if (n.Op == "neg") return -Eval(n.A, var, x);
            if (n.Op == "fn")
            {
                double a = (n.Items != null && n.Items.Count > 0) ? Eval(n.Items[0], var, x) : double.NaN;
                return n.Atom switch
                {
                    "sqrt" => Math.Sqrt(a), "sin" => Math.Sin(a), "cos" => Math.Cos(a), "tan" => Math.Tan(a),
                    "exp" => Math.Exp(a), "log" => Math.Log(a), "abs" => Math.Abs(a), _ => double.NaN
                };
            }
            double l = Eval(n.A, var, x), r = Eval(n.B, var, x);
            return n.Op switch { "+" => l + r, "-" => l - r, "*" => l * r, "/" => l / r, "^" => Math.Pow(l, r), _ => double.NaN };
        }

        // paleta por defecto de MATLAB (orden de colores de las líneas)
        static readonly string[] PlotColors = { "#0072BD", "#D95319", "#EDB120", "#7E2F8E", "#77AC30", "#4DBEEE", "#A2142F" };

        // TODAS las variables (símbolos) de una expresión, sin repetir (para 'syms x y' de MATLAB)
        public static List<string> VarsOf(N n)
        {
            var found = new List<string>();
            void Rec(N x)
            {
                if (x == null) return;
                if (x.IsAtom) { if (!IsNum(x.Atom) && x.Atom != "pi" && x.Atom != "e" && !found.Contains(x.Atom)) found.Add(x.Atom); return; }
                Rec(x.A); Rec(x.B);
                if (x.Items != null) foreach (var it in x.Items) Rec(it);
            }
            Rec(n);
            return found;
        }

        // variable LIBRE de una expresión (para fplot estilo MATLAB, que no pide la variable)
        public static string FreeVar(N n)
        {
            var found = new List<string>();
            void Rec(N x)
            {
                if (x == null) return;
                if (x.IsAtom) { if (!IsNum(x.Atom) && x.Atom != "pi" && x.Atom != "e" && !found.Contains(x.Atom)) found.Add(x.Atom); return; }
                Rec(x.A); Rec(x.B);
                if (x.Items != null) foreach (var it in x.Items) Rec(it);
            }
            Rec(n);
            if (found.Contains("s")) return "s";
            if (found.Contains("x")) return "x";
            return found.Count > 0 ? found[0] : "x";
        }

        // paso "bonito" para los ticks (1,2,5 ×10^n), estilo MATLAB
        static double NiceStep(double range, int target)
        {
            if (range <= 0) return 1;
            double raw = range / Math.Max(1, target);
            double mag = Math.Pow(10, Math.Floor(Math.Log10(raw)));
            double norm = raw / mag;
            double step = norm < 1.5 ? 1 : norm < 3 ? 2 : norm < 7 ? 5 : 10;
            return step * mag;
        }

        // ---------- grafica SVG de una o varias funciones f(var) sobre [lo,hi] ----------
        public static string PlotSvg(string var, double lo, double hi, List<(string name, N tree)> fns)
        {
            if (fns == null || fns.Count == 0 || hi <= lo) return "";
            const int W = 540, H = 360, pL = 56, pR = 18, pT = 18, pB = 44, NS = 200;
            var C = System.Globalization.CultureInfo.InvariantCulture;
            // muestrear
            var series = new List<(string name, double[] xs, double[] ys)>();
            double ymin = double.PositiveInfinity, ymax = double.NegativeInfinity;
            foreach (var (name, tree) in fns)
            {
                var xs = new double[NS + 1]; var ys = new double[NS + 1];
                for (int k = 0; k <= NS; k++)
                {
                    double xx = lo + (hi - lo) * k / NS;
                    double yy = Eval(tree, var, xx);
                    xs[k] = xx; ys[k] = yy;
                    if (!double.IsNaN(yy) && !double.IsInfinity(yy)) { ymin = Math.Min(ymin, yy); ymax = Math.Max(ymax, yy); }
                }
                series.Add((name, xs, ys));
            }
            if (double.IsInfinity(ymin) || double.IsInfinity(ymax)) return "";
            if (ymax - ymin < 1e-9) { ymin -= 1; ymax += 1; }
            // límites Y "bonitos" (como MATLAB): redondea a múltiplos del paso
            double ystep = NiceStep(ymax - ymin, 5);
            ymin = Math.Floor(ymin / ystep) * ystep; ymax = Math.Ceiling(ymax / ystep) * ystep;
            double xstep = NiceStep(hi - lo, 6);
            double SX(double x) => pL + (W - pL - pR) * (x - lo) / (hi - lo);
            double SY(double y) => H - pB - (H - pT - pB) * (y - ymin) / (ymax - ymin);
            string Num(double v) => (Math.Abs(v) < 1e-9 ? 0 : v).ToString("0.###", C);
            var sb = new StringBuilder();
            sb.Append("<div class=\"ws-plot\"><svg viewBox=\"0 0 ").Append(W).Append(' ').Append(H)
              .Append("\" xmlns=\"http://www.w3.org/2000/svg\" font-family=\"'Segoe UI',Arial,sans-serif\" style=\"max-width:100%;height:auto\">");
            // GRID (líneas tenues en cada tick) — estilo MATLAB
            for (double gx = Math.Ceiling(lo / xstep) * xstep; gx <= hi + xstep * 1e-6; gx += xstep)
                sb.Append("<line x1=\"").Append(Num(SX(gx))).Append("\" y1=\"").Append(pT).Append("\" x2=\"").Append(Num(SX(gx))).Append("\" y2=\"").Append(H - pB).Append("\" stroke=\"var(--mut)\" stroke-opacity=\".22\" stroke-width=\"1\"/>");
            for (double gy = ymin; gy <= ymax + ystep * 1e-6; gy += ystep)
                sb.Append("<line x1=\"").Append(pL).Append("\" y1=\"").Append(Num(SY(gy))).Append("\" x2=\"").Append(W - pR).Append("\" y2=\"").Append(Num(SY(gy))).Append("\" stroke=\"var(--mut)\" stroke-opacity=\".22\" stroke-width=\"1\"/>");
            // ejes cero (más marcados)
            if (ymin < 0 && ymax > 0) sb.Append("<line x1=\"").Append(pL).Append("\" y1=\"").Append(Num(SY(0))).Append("\" x2=\"").Append(W - pR).Append("\" y2=\"").Append(Num(SY(0))).Append("\" stroke=\"var(--mut)\" stroke-opacity=\".6\"/>");
            if (lo < 0 && hi > 0) sb.Append("<line x1=\"").Append(Num(SX(0))).Append("\" y1=\"").Append(pT).Append("\" x2=\"").Append(Num(SX(0))).Append("\" y2=\"").Append(H - pB).Append("\" stroke=\"var(--mut)\" stroke-opacity=\".6\"/>");
            // ticks con números
            for (double gx = Math.Ceiling(lo / xstep) * xstep; gx <= hi + xstep * 1e-6; gx += xstep)
            {
                sb.Append("<line x1=\"").Append(Num(SX(gx))).Append("\" y1=\"").Append(H - pB).Append("\" x2=\"").Append(Num(SX(gx))).Append("\" y2=\"").Append(H - pB + 4).Append("\" stroke=\"var(--mut)\"/>");
                sb.Append("<text x=\"").Append(Num(SX(gx))).Append("\" y=\"").Append(H - pB + 16).Append("\" fill=\"var(--mut)\" font-size=\"11\" text-anchor=\"middle\">").Append(Num(gx)).Append("</text>");
            }
            for (double gy = ymin; gy <= ymax + ystep * 1e-6; gy += ystep)
            {
                sb.Append("<line x1=\"").Append(pL - 4).Append("\" y1=\"").Append(Num(SY(gy))).Append("\" x2=\"").Append(pL).Append("\" y2=\"").Append(Num(SY(gy))).Append("\" stroke=\"var(--mut)\"/>");
                sb.Append("<text x=\"").Append(pL - 7).Append("\" y=\"").Append(Num(SY(gy) + 4)).Append("\" fill=\"var(--mut)\" font-size=\"11\" text-anchor=\"end\">").Append(Num(gy)).Append("</text>");
            }
            // caja
            sb.Append("<rect x=\"").Append(pL).Append("\" y=\"").Append(pT).Append("\" width=\"").Append(W - pL - pR)
              .Append("\" height=\"").Append(H - pT - pB).Append("\" fill=\"none\" stroke=\"var(--mut)\" stroke-width=\"1.2\"/>");
            // etiqueta eje X
            sb.Append("<text x=\"").Append((pL + W - pR) / 2).Append("\" y=\"").Append(H - 6).Append("\" fill=\"var(--fg)\" font-size=\"12\" font-style=\"italic\" text-anchor=\"middle\">").Append(System.Net.WebUtility.HtmlEncode(var)).Append("</text>");
            // curvas
            for (int s = 0; s < series.Count; s++)
            {
                var (name, xs, ys) = series[s];
                string col = PlotColors[s % PlotColors.Length];
                var pts = new StringBuilder();
                for (int k = 0; k < xs.Length; k++)
                {
                    if (double.IsNaN(ys[k]) || double.IsInfinity(ys[k])) continue;
                    if (pts.Length > 0) pts.Append(' ');
                    pts.Append(Num(SX(xs[k]))).Append(',').Append(Num(SY(ys[k])));
                }
                sb.Append("<polyline points=\"").Append(pts).Append("\" fill=\"none\" stroke=\"").Append(col).Append("\" stroke-width=\"2\"/>");
            }
            // leyenda en CAJA (estilo MATLAB), arriba-derecha dentro de los ejes
            int lw = 78, lh = 8 + series.Count * 17, lx = W - pR - lw - 8, lyTop = pT + 8;
            sb.Append("<rect x=\"").Append(lx).Append("\" y=\"").Append(lyTop).Append("\" width=\"").Append(lw).Append("\" height=\"").Append(lh)
              .Append("\" fill=\"var(--bg)\" fill-opacity=\".85\" stroke=\"var(--mut)\" stroke-width=\"1\"/>");
            for (int s = 0; s < series.Count; s++)
            {
                int ly = lyTop + 14 + s * 17; string col = PlotColors[s % PlotColors.Length];
                sb.Append("<line x1=\"").Append(lx + 8).Append("\" y1=\"").Append(ly).Append("\" x2=\"").Append(lx + 26).Append("\" y2=\"").Append(ly).Append("\" stroke=\"").Append(col).Append("\" stroke-width=\"2.5\"/>");
                sb.Append("<text x=\"").Append(lx + 32).Append("\" y=\"").Append(ly + 4).Append("\" fill=\"var(--fg)\" font-size=\"12\" font-style=\"italic\">").Append(System.Net.WebUtility.HtmlEncode(series[s].name)).Append("</text>");
            }
            sb.Append("</svg></div>");
            return sb.ToString();
        }

        // ---------- vista APRENDER: cada fórmula en 3 formas (Matemática · LISP · MATLAB) ----------
        public static string LearnPage(string text, bool fromLisp)
        {
            var body = new StringBuilder();
            foreach (var raw in (text ?? "").Replace("\r", "").Split('\n'))
            {
                var line = raw.Trim();
                if (line.Length == 0) continue;
                string label = null, exprStr = line;
                var lbl = System.Text.RegularExpressions.Regex.Match(line, @"^([A-Za-z]\w*)\s*=\s*(?![=])(.+)$");
                if (lbl.Success)
                {
                    label = lbl.Groups[1].Value;
                    var partes = System.Text.RegularExpressions.Regex.Split(lbl.Groups[2].Value, @"\s=\s");
                    exprStr = partes[partes.Length - 1].Trim();   // el RESULTADO (último tramo)
                }
                // prosa (encabezado como "1D CUADRATICA"): texto, no fórmula
                if (fromLisp && !exprStr.StartsWith("(") && exprStr.Contains(' ') && label == null)
                {
                    body.Append("<div class=\"lp-hdr\">").Append(System.Net.WebUtility.HtmlEncode(line)).Append("</div>");
                    continue;
                }
                N tree; try { tree = fromLisp ? ParseLisp(exprStr) : ParseMath(exprStr); }
                catch { body.Append("<div class=\"lp-hdr\">").Append(System.Net.WebUtility.HtmlEncode(line)).Append("</div>"); continue; }
                string mat = System.Net.WebUtility.HtmlEncode(ToLab(tree, 0));
                string lsp = System.Net.WebUtility.HtmlEncode(ToLisp(tree));
                body.Append("<div class=\"lp-card\">");
                if (label != null) body.Append("<div class=\"lp-name\">").Append(VarHtml(label)).Append("</div>");
                body.Append("<div class=\"lp-row\"><span class=\"lp-tag\">Renderizado</span><span class=\"lp-math\">").Append(ToHtml(tree)).Append("</span></div>");
                body.Append("<div class=\"lp-row\"><span class=\"lp-tag\">LISP</span><code class=\"lp-code\">").Append(lsp).Append("</code></div>");
                body.Append("<div class=\"lp-row\"><span class=\"lp-tag\">Texto plano</span><code class=\"lp-code\">").Append(mat).Append("</code></div>");
                body.Append("</div>");
            }
            return "<!doctype html><html><head><meta charset=\"utf-8\"><style>" +
                   (Dark ? ROOT_DARK : ROOT_LIGHT) + CSS + LEARN_CSS +
                   "</style></head><body>" + body + MAT_JS + "</body></html>";
        }

        const string LEARN_CSS =
            ".lp-card{border:1px solid var(--mut);border-radius:8px;padding:8px 12px;margin:10px 0;}" +
            ".lp-name{font-style:italic;color:var(--var);font-size:13pt;margin-bottom:4px;}" +
            ".lp-row{display:flex;align-items:baseline;gap:10px;margin:5px 0;}" +
            ".lp-tag{flex:0 0 78px;font-family:'Segoe UI',sans-serif;font-size:9.5pt;color:var(--mut);text-transform:uppercase;letter-spacing:.04em;}" +
            ".lp-math{font-family:'Georgia Pro',serif;font-size:12pt;}" +
            ".lp-code{font-family:Consolas,monospace;font-size:11pt;color:var(--fg);white-space:pre-wrap;}" +
            ".lp-hdr{font-family:'Segoe UI',sans-serif;font-weight:600;color:var(--mut);margin-top:1em;}";

        // ---------- atajos por linea (para los modos de TEXTO) ----------
        public static string MathToLisp(string line) => ToLisp(ParseMath(line));
        public static string LispToLab(string line) => ToLab(ParseLisp(line), 0);
    }
}
