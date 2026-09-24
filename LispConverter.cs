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
        static readonly Regex Tok = new Regex(@"\d+\.?\d*|\$?[A-Za-z_∂∇][\w∂∇]*'*|[-+*/^(),;\[\]{}@:'=]");
        // operadores solver de Calcpad → función del motor
        static readonly Dictionary<string, string> SolverOps = new Dictionary<string, string>
        {
            { "area", "area-under" }, { "integral", "area-under" },
            { "slope", "slope-at" }, { "derivative", "slope-at" },
            { "sum", "suma-op" }, { "product", "producto-op" }, { "root", "root-op" },
            { "find", "find-op" }, { "sup", "sup-op" }, { "inf", "inf-op" }, { "repeat", "repeat-op" },
            { "lim", "limite" }, { "limit", "limite" }, { "limite", "limite" },   // límite  lim_{x→a} f
            { "ngauss", "ngauss" },   // integral de Gauss 2x2 NUMERICA de una matriz: NGauss{ M @ xi, eta }
            // tokens de operación simbólica (nuestra notación): computan inline
            { "partial", "partial" }, { "derivate", "derive-x" }, { "diff", "derive-x" },
            { "pasos", "deriv-steps" }, { "diffpasos", "deriv-steps" },   // derivada MOSTRANDO el trabajo (regla de la potencia)
            { "simplify", "factor" }, { "factor", "factor" }, { "expand", "expand*" },
            { "despejar", "despejar" }, { "solve", "despejar" },   // Despejar{ lhs = rhs @ x } → resuelve la ecuación
            { "inverse", "inv" }, { "inversa", "inv" },            // Inverse{K} → se dibuja K⁻¹
        };

        public static N ParseMath(string s)
        {
            // multiplicación escrita a la Jorge: ·  ∙  ⋅  ×  → *  (el tokenizer solo conoce '*').
            //   menos/'/' unicode → ASCII.  Sin esto "12·10^6" se leía como 12 (se perdía el operador).
            s = s.Replace('·', '*').Replace('∙', '*').Replace('⋅', '*').Replace('×', '*')
                 .Replace('−', '-').Replace('∕', '/').Replace('⁄', '/');
            s = GreekToAscii(s);   // λ, σ_x, Δ tecleadas en Unicode: el tokenizer solo conoce A-Z
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
                    // DESPEJAR: la sintaxis es  Despejar{ lhs = rhs @ x }  — el '=' es la ecuación
                    // (no límites). Items = [lhs, rhs, var]. Si no hay '=', se resuelve lhs = 0.
                    if (solverKey == "despejar")
                    {
                        var lhsD = Expr();
                        var itemsD = new List<N> { lhsD };
                        if (Peek() == "=") { Eat(); itemsD.Add(Expr()); } else itemsD.Add(N.Leaf("0"));
                        N varD = null;
                        if (Peek() == "@") { Eat(); varD = N.Leaf(Peek()); Eat(); }
                        itemsD.Add(varD ?? N.Leaf("x"));
                        if (Peek() == "}") Eat();
                        return new N { Op = "solver", Atom = "despejar", Items = itemsD };
                    }
                    // INVERSE: no lleva '@' ni límites. Se convierte en POTENCIA -1, que ya se
                    // dibuja como K⁻¹ y que el motor sabe invertir. Antes, al no interceptarlo
                    // aquí, la palabra "Inverse" acababa escrita en el render.
                    if (solverKey == "inverse" || solverKey == "inversa")
                    {
                        var fInv = Expr();
                        if (Peek() == "}") Eat();
                        return N.Make("^", fInv, N.Leaf("-1"));
                    }
                    var f = Expr();
                    var items = new List<N> { f };
                    if (Peek() == "@")
                    {
                        Eat();
                        string vv = Peek(); Eat();               // variable
                        items.Add(N.Leaf(vv));
                        // 2ª variable tras coma → operadores 2D (NGauss{ M @ xi , eta })
                        if (Peek() == ",") { Eat(); items.Add(N.Leaf(Peek())); Eat(); }
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
                    // transpose(X) → nodo TRANS: se muestra Xᵀ (forma de libro), no la palabra
                    // "transpose"; y ToLisp lo emite como (mtransp X), que el motor computa.
                    if (fname0.Equals("transpose", System.StringComparison.OrdinalIgnoreCase) && args.Count == 1)
                        return new N { Op = "trans", A = args[0] };
                    // Inverse{X} / Inversa{X} / inv(X) → POTENCIA -1: se dibuja X⁻¹, como en los
                    // libros, y el motor la invierte. Antes salía la palabra "Inverse" escrita.
                    if (args.Count == 1 &&
                        (fname0.Equals("inverse", System.StringComparison.OrdinalIgnoreCase) ||
                         fname0.Equals("inversa", System.StringComparison.OrdinalIgnoreCase) ||
                         fname0.Equals("inv", System.StringComparison.OrdinalIgnoreCase)))
                        return N.Make("^", args[0], N.Leaf("-1"));
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
            { "despejar", "despejar" },   // (despejar lhs rhs var) → se renderiza como  lhs = rhs
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
            if ((op == "mtransp" || op == "transpose") && args.Count == 1) return new N { Op = "trans", A = args[0] };
            if (op == "mrange") return new N { Op = "range", Items = args };
            if (op == "ngauss" && args.Count == 3) return new N { Op = "solver", Atom = "ngauss", Items = args };

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
            // Despejar{ lhs = rhs @ x } → (despejar 'lhs 'rhs 'x). Items = [lhs, rhs, var].
            if (n.Atom == "despejar" && n.Items != null && n.Items.Count >= 3)
                return $"(despejar '{ToLisp(n.Items[0])} '{ToLisp(n.Items[1])} '{ToLisp(n.Items[2])})";
            var (f, v, a, b) = SolverParts(n, x => ToLisp(x));
            return n.Atom switch
            {
                "area" => $"(area-under '{f} '{v} {a} {b})",
                "integral" => b != null ? $"(area-under '{f} '{v} {a} {b})" : $"(integ-var '{f} '{v})",
                "slope" or "derivative" => $"(slope-at '{f} '{v} {a})",
                "partial" => $"(partial '{f} '{v})",
                "derivate" or "diff" => n.Items.Count > 1 ? $"(derive-x '{f} '{v})" : $"(derive-x '{f})",
                "pasos" or "diffpasos" => $"(deriv-steps '{f} '{v})",
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
                "ngauss" => $"(ngauss '{f} '{v} '{a})",   // a = 2ª variable (v2); Gauss 2x2 numerico
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
            // Despejar{ lhs = rhs @ x } → se muestra la ECUACIÓN  lhs = rhs  (y el display agrega "= solución").
            if (n.Atom == "despejar" && n.Items != null && n.Items.Count >= 2)
                return ToHtml(n.Items[0]) + " <span class=\"m-op\">=</span> " + ToHtml(n.Items[1]);
            var (f, v, a, b) = SolverParts(n, x => ToHtml(x));
            // n-ario apilado como Calcpad: <dvr><small>sup</small><nary>Σ</nary><small>sub</small></dvr> expr
            string Nary(string sym, string sub, string sup, string expr) =>
                "<span class=\"m-dvr\"><small>" + sup + "</small><span class=\"m-nary\">" + sym +
                "</span><small>" + sub + "</small></span>" + expr;
            // ∫ APILADO — estructura EXACTA de Hekatan Lab: dvr[ small(sup) nary(<em>∫</em>) small(sub) ] f dx.
            // El <em> lleva scaleX(0.7) rotate(7deg) → ∫ delgado e inclinado. &emsp;/&nbsp; empujan los límites.
            string IntSym(string lo, string hi, string body)
            {
                string su = string.IsNullOrEmpty(hi) ? "" : "&emsp; " + hi;
                string sb = string.IsNullOrEmpty(lo) ? "" : lo + "&nbsp;";
                return "<span class=\"m-dvr\"><small>" + su + "</small><span class=\"m-nary\"><em>∫</em></span><small>" + sb + "</small></span>" + body;
            }
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
                "area" => IntSym(a, b ?? "", "&hairsp;" + f + dx),
                "integral" => b != null ? IntSym(a, b, "&hairsp;" + f + dx) : IntSym("", "", "&hairsp;" + f + dx),
                "sum" => Nary("Σ", idx, b ?? "", "&hairsp;" + f),
                "product" => Nary("∏", idx, b ?? "", "&hairsp;" + f),
                "lim" or "limit" or "limite" =>
                    "<span class=\"m-lim\"><span class=\"m-lim-op\">lim</span><small class=\"m-lim-sub\">" + v +
                    "→" + LimTarget(n.Items.Count > 2 ? n.Items[2] : null, a) + "</small></span>&hairsp;" + Paren(f),
                "slope" or "derivative" => ddv + Paren(f) + "<span class=\"m-op\"> │</span><sub class=\"m-sub\">" + v + "=" + a + "</sub>",
                "partial" => pdv + Paren(f),                           // ∂/∂x (f) — derivada PARCIAL
                "derivate" or "diff" or "pasos" or "diffpasos" => ddv + Paren(f),   // d/dx (f) — derivada total (pasos = mostrando el trabajo)
                // simplify/factor/expand NO tienen símbolo matemático: se muestra solo la EXPRESIÓN,
                // y el " = resultado" (que agrega el display) ya dice que se operó. Matemática pura.
                "simplify" or "factor" or "expand" => f,
                "root" => Kw("root", f + " <span class=\"m-op\">=</span> 0"),   // simbólico: TODAS las raíces (sin intervalo)
                "find" => Kw("find", f + "<span class=\"m-op\">;</span> " + interval),
                "sup" => Kw("sup", f + "<span class=\"m-op\">;</span> " + interval),
                "inf" => Kw("inf", f + "<span class=\"m-op\">;</span> " + interval),
                "repeat" => Kw("repeat", f + " <span class=\"m-cond\">para</span> " + vv + " <span class=\"m-op\">=</span> " + a + "…" + (b ?? "")),
                // NGauss: doble integral por Gauss 2x2 sobre [-1,1]^2 → ∬ f dξ dη
                "ngauss" => IntSym("−1", "1", IntSym("−1", "1",
                    "&hairsp;" + f + " <span class=\"m-fn\">d</span>" + v + "<span class=\"m-fn\">d</span>" + a)),
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
        // ---- MATLAB / Hekatan Lab (.m) → notación de Hekatan LISP (worksheet matemática) ----
        // %% → encabezado #, % → prosa #:, int()/diff() → Integral{}/Diff{}/Area{}, se omiten
        // syms y comandos sin salida (clc, plot setup); se quita el ; final y el comentario inline.
        public static string MatlabToHlisp(string matlab)
        {
            var sb = new System.Text.StringBuilder();
            foreach (var raw in (matlab ?? "").Replace("\r", "").Split('\n'))
            {
                string t = raw.TrimStart();
                if (t.Length == 0) { sb.Append('\n'); continue; }
                if (t.StartsWith("%%")) { sb.Append("# ").Append(t.Substring(2).Trim()).Append('\n'); continue; }
                if (t.StartsWith("%")) { sb.Append("#: ").Append(t.Substring(1).Trim()).Append('\n'); continue; }
                if (Regex.IsMatch(t, @"^(syms|clc|clear|close|format|hold|grid|legend|xlabel|ylabel|title|figure|axis|set|colormap|colorbar|disp|fprintf|printf|sprintf|pretty|end|function)\b"))
                    continue;
                string line = raw;
                int pc = TopLevelPercent(line);
                if (pc >= 0) line = line.Substring(0, pc);
                line = Regex.Replace(line, @"\s*;\s*$", "");
                if (line.Trim().Length == 0) continue;
                line = ConvMatlabCalls(line);
                sb.Append(line.TrimEnd()).Append('\n');
            }
            return sb.ToString().TrimEnd('\n');
        }

        static int TopLevelPercent(string s)
        {
            bool inStr = false;
            for (int i = 0; i < s.Length; i++)
            {
                if (s[i] == '\'') inStr = !inStr;
                else if (s[i] == '%' && !inStr) return i;
            }
            return -1;
        }

        static string ConvMatlabCalls(string s)
        {
            s = ConvCall(s, "int", a => a.Count == 2 ? $"Integral{{{a[0]} @ {a[1]}}}" : a.Count == 4 ? $"Area{{{a[0]} @ {a[1]}={a[2]}:{a[3]}}}" : null);
            s = ConvCall(s, "diff", a => a.Count == 2 ? $"Diff{{{a[0]} @ {a[1]}}}" : a.Count == 1 ? $"Diff{{{a[0]} @ x}}" : null);
            return s;
        }

        // reemplaza name(a,b,…) balanceado por conv(args); si conv da null (firma no soportada) se deja igual
        static string ConvCall(string s, string name, System.Func<System.Collections.Generic.List<string>, string> conv)
        {
            var re = new Regex(@"\b" + name + @"\s*\(");
            int from = 0;
            for (int guard = 0; guard < 100; guard++)
            {
                var m = re.Match(s, from);
                if (!m.Success) break;
                int open = m.Index + m.Length - 1, depth = 0, close = -1, start = open + 1;
                var args = new System.Collections.Generic.List<string>();
                for (int i = open; i < s.Length; i++)
                {
                    char c = s[i];
                    if (c == '(') depth++;
                    else if (c == ')') { depth--; if (depth == 0) { args.Add(s.Substring(start, i - start).Trim()); close = i; break; } }
                    else if (c == ',' && depth == 1) { args.Add(s.Substring(start, i - start).Trim()); start = i + 1; }
                }
                if (close < 0) break;
                string repl = conv(args);
                if (repl == null) { from = close + 1; continue; }   // no soportada: sigue tras ella
                s = s.Substring(0, m.Index) + repl + s.Substring(close + 1);
                from = m.Index + repl.Length;
            }
            return s;
        }

        // nombre SEGURO para LISP/MATLAB: la prima ' (cita en LISP, transpuesta en MATLAB) → 'p'.
        // Así  H1' → H1p,  H1'' → H1pp  al convertir; en matemática se sigue viendo H₁′.
        // Nombre válido para LISP/MATLAB. La PRIMA usa el MISMO token que Hekatan Lab
        // (sufijo de letras que su HtmlWriter dibuja como ′/″/‴): 'prime'/'pprime'/'tprime'.
        // Así H1' → H1prime (válido en MATLAB y, al pegar en Hekatan Lab, se ve H1′).
        public static string SafeName(string s)
        {
            if (string.IsNullOrEmpty(s) || s.IndexOf('\'') < 0) return s;
            int i = s.Length; while (i > 0 && s[i - 1] == '\'') i--;
            int n = s.Length - i;
            string suf = n switch { 0 => "", 1 => "prime", 2 => "pprime", 3 => "tprime",
                                    _ => string.Concat(System.Linq.Enumerable.Repeat("prime", n)) };
            return (s.Substring(0, i) + suf).Replace("'", "");
        }

        public static string ToLisp(N n)
        {
            if (n == null) return "";
            if (n.Op == "solver") return SolverToLisp(n);
            if (n.IsAtom) return SafeName(n.Atom);
            if (n.Op == "neg") return "(- 0 " + ToLisp(n.A) + ")";   // menos BINARIO: el motor (deriv/simp) trata (- a b), no el unario (- a) (perdía el signo al derivar)
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
            if (n.IsAtom) return SafeName(n.Atom);
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
        /// <summary>¿Este trozo empieza por un signo menos? Sirve para no escribir
        /// nunca dos signos seguidos: «1 − −1» se compone «1 − (−1)».</summary>
        static bool EsNegativo(N n)
        {
            if (n == null) return false;
            if (n.Op == "neg") return true;
            // el menos unario viaja como (- 0 x)
            if (n.Op == "-" && n.A != null && n.A.IsAtom && n.A.Atom == "0") return true;
            if (n.IsAtom && n.Atom != null && n.Atom.Length > 1 && n.Atom[0] == '-'
                && char.IsDigit(n.Atom[1])) return true;
            return false;
        }

        static string Paren(string s) =>
            "<span class=\"m-paren\"><span class=\"m-pl\"></span>" + FlexSafe(s) + "<span class=\"m-pr\"></span></span>";

        /// <summary>Dentro de un inline-flex (paréntesis, transpuesta) cada hijo es una CAJA: el
        /// &lt;sub&gt; de u₁ dejaba de bajar y salía «u1» (y en Tₑᵀ la e quedaba arriba). Con un span
        /// que lo envuelva, el subíndice vuelve a vivir en su línea de texto.</summary>
        static string FlexSafe(string s) =>
            s != null && s.Contains("<sub") ? "<span class=\"m-pin\">" + s + "</span>" : s;

        /// <summary>Un índice (1, 2, i, j) como texto plano, para ponerlo de subíndice en M_ij.</summary>
        static string PlainIdx(N n)
        {
            if (n == null) return "";
            var s = n.Atom ?? "";
            if (s.Length == 0) s = System.Text.RegularExpressions.Regex.Replace(ToHtml(n, 0), "<[^>]+>", "");
            return System.Net.WebUtility.HtmlEncode(s.Trim());
        }

        // nombre con SUBÍNDICE: "N1" -> N con 1 abajo · "sigma_x" -> sigma con x abajo.
        // Convención ingenieril: dígitos finales (o lo que sigue a "_") es subíndice.
        // nombres de letras griegas → su símbolo (como Hekatan Lab): theta→θ, gamma→γ, sigma→σ…
        static readonly Dictionary<string, string> Greek = new Dictionary<string, string>
        {
            {"alpha","α"},{"beta","β"},{"gamma","γ"},{"delta","δ"},{"epsilon","ε"},{"zeta","ζ"},
            {"eta","η"},{"theta","θ"},{"iota","ι"},{"kappa","κ"},{"lambda","λ"},{"mu","μ"},
            {"nu","ν"},{"xi","ξ"},{"omicron","ο"},{"rho","ρ"},{"sigma","σ"},{"tau","τ"},
            {"upsilon","υ"},{"phi","φ"},{"chi","χ"},{"psi","ψ"},{"omega","ω"},
            {"eps","ε"},{"varepsilon","ε"},{"varphi","φ"},  // alias cortos frecuentes
            {"pi","π"},   // solo el RENDER: el motor la sigue tratando como su constante

            {"Alpha","Α"},{"Beta","Β"},{"Gamma","Γ"},{"Delta","Δ"},{"Theta","Θ"},{"Lambda","Λ"},
            {"Xi","Ξ"},{"Sigma","Σ"},{"Phi","Φ"},{"Psi","Ψ"},{"Omega","Ω"},
            // las que faltaban: «Pi» salía escrito con letras, y el resto de mayúsculas
            {"Pi","Π"},{"Epsilon","Ε"},{"Zeta","Ζ"},{"Eta","Η"},{"Iota","Ι"},{"Kappa","Κ"},
            {"Mu","Μ"},{"Nu","Ν"},{"Omicron","Ο"},{"Rho","Ρ"},{"Tau","Τ"},{"Upsilon","Υ"},{"Chi","Χ"},
        };

        // ---------- griegas escritas en Unicode (λ, σ_x, Δ) ----------
        // El tokenizer y los regex de la hoja solo conocen [A-Za-z]: una λ tecleada DESAPARECÍA
        // («u = λ + σ_x» salía «u = +»). Se traduce cada letra a su nombre (λ → lambda) ANTES de
        // todo, y el render la vuelve a dibujar como λ.
        static readonly Dictionary<char, string> GreekUni = new Dictionary<char, string>
        {
            {'α',"alpha"},{'β',"beta"},{'γ',"gamma"},{'δ',"delta"},{'ε',"epsilon"},{'ϵ',"epsilon"},
            {'ζ',"zeta"},{'η',"eta"},{'θ',"theta"},{'ϑ',"theta"},{'ι',"iota"},{'κ',"kappa"},
            {'λ',"lambda"},{'μ',"mu"},{'ν',"nu"},{'ξ',"xi"},{'ο',"omicron"},{'π',"pi"},{'ρ',"rho"},
            {'σ',"sigma"},{'ς',"sigma"},{'τ',"tau"},{'υ',"upsilon"},{'φ',"phi"},{'ϕ',"phi"},
            {'χ',"chi"},{'ψ',"psi"},{'ω',"omega"},
            {'Α',"Alpha"},{'Β',"Beta"},{'Γ',"Gamma"},{'Δ',"Delta"},{'Ε',"Epsilon"},{'Ζ',"Zeta"},
            {'Η',"Eta"},{'Θ',"Theta"},{'Ι',"Iota"},{'Κ',"Kappa"},{'Λ',"Lambda"},{'Μ',"Mu"},
            {'Ν',"Nu"},{'Ξ',"Xi"},{'Ο',"Omicron"},{'Π',"Pi"},{'Ρ',"Rho"},{'Σ',"Sigma"},{'Τ',"Tau"},
            {'Υ',"Upsilon"},{'Φ',"Phi"},{'Χ',"Chi"},{'Ψ',"Psi"},{'Ω',"Omega"},
        };
        static bool HasGreekUni(string s) { foreach (char c in s ?? "") if (GreekUni.ContainsKey(c)) return true; return false; }
        public static string GreekToAscii(string s)
        {
            if (!HasGreekUni(s)) return s;
            var sb = new StringBuilder();
            foreach (char c in s) { if (GreekUni.TryGetValue(c, out var nm)) sb.Append(nm); else sb.Append(c); }
            return sb.ToString();
        }

        // ---------- nombres que CHOCAN al pasar por LISP ----------
        // El lector de LISP no distingue mayúsculas: m y M, l y L, g_x y G_x, lambda_1 y Lambda_1
        // son EL MISMO símbolo, y CaseMap (minúscula → como se escribió) solo recuerda uno, así que
        // «m + M» salía «M + M» (y el motor lo sumaba como 2·M). Tampoco sirven como variables
        // T (verdadero en LISP) ni Pi (la constante π). Esos nombres se RENOMBRAN antes de ir al
        // motor a una forma única en minúscula (m + "hkq" + n) y CaseMap la devuelve a su letra.
        public const string MangleTag = "hkq";
        static readonly Dictionary<string, string> _mangle = new Dictionary<string, string>(StringComparer.Ordinal);
        static readonly Regex RxIdent = new Regex(@"(?<![A-Za-z0-9_])[A-Za-z_][A-Za-z0-9_]*(?![A-Za-z0-9_])");
        static readonly Regex RxIdentUni = new Regex(@"(?<![\p{L}0-9_])[\p{L}_][\p{L}0-9_]*(?![\p{L}0-9_])");
        // palabras de la notación que NUNCA se renombran (operadores y funciones conocidas)
        static readonly HashSet<string> NoMangle = new HashSet<string>(StringComparer.OrdinalIgnoreCase)
        {
            "transpose","inv","inverse","inversa","det","trace","sqrt","sin","cos","tan","exp","log","ln","abs",
            "sinh","cosh","tanh","asin","acos","atan","norm","cross","dot","menor","minor","cofactor","adj","cof",
            "dec","max","min","mod","floor","ceil","round","sign","tic","toc",
        };
        static readonly HashSet<string> LispReserved = new HashSet<string> { "t", "nil", "pi" };

        /// <summary>Prepara los NOMBRES de la hoja: griegas Unicode → nombre ASCII, y renombra
        /// los identificadores que chocarían en LISP. Llena CaseMap para volver a dibujarlos
        /// como se escribieron. Solo toca líneas de matemática y los argumentos de #fplot/#surf/#map
        /// (la prosa #:, los comentarios ; y la etiqueta @@ quedan igual).</summary>
        // [unidad] en medio de la línea: tras ) o número, y antes de ; o ' (la columna siguiente o la descripción)
        static readonly Regex RxUnidadMedio = new Regex(@"([\)\d]\s*)\[([^\[\];,=]*[A-Za-z°][^\[\];,=]*)\](?=\s*[;'])");
        public static string PrepareNames(string text)
        {
            CaseMap.Clear(); _mangle.Clear();
            var lines = (text ?? "").Replace("\r", "").Split('\n');
            var uniOrig = new Dictionary<string, string>(StringComparer.Ordinal);   // ascii → como se tecleó (Δu)
            var groups = new Dictionary<string, List<string>>(StringComparer.Ordinal);
            var cuerpo = new string[lines.Length]; var cola = new string[lines.Length];
            var unidMedio = new List<string>();
            for (int k = 0; k < lines.Length; k++)
            {
                var ln = lines[k]; var t = ln.TrimStart();
                // NOTA: "tabla"/"table" NO entra aqui aposta. Este bloque sustituye griegas Unicode
                // por su nombre ASCII (φ->"phi") para que el tokenizer las lea — pero en #tabla(...)
                // los encabezados citados son TEXTO a mostrar (pueden llevar φ, σ, Ø...) y esa sustitucion
                // los dejaba mangled ("phiV_c" en vez de "φV_c"), sin CaseMap que lo deshaga (no son
                // variables). Efecto secundario aceptado: una referencia de columna en #tabla(...) que
                // choque de mayuscula/minuscula con otra igual en el resto de la hoja no se renombra
                // (ResolveTablaColumn no la encuentra y la muestra literal, no revienta).
                bool plotDir = Regex.IsMatch(t, @"^#\s*(fplot|plot|ezplot|surf|superficie|plot3d|mesh|map|mapa|heatmap|contourf?)\b", RegexOptions.IgnoreCase);
                if (t.Length == 0 || ((t[0] == '#' || t[0] == ';' || t[0] == '%') && !plotDir)) continue;
                int at = ln.IndexOf("@@", StringComparison.Ordinal);
                string body = at >= 0 ? ln.Substring(0, at) : ln, tail = at >= 0 ? ln.Substring(at) : "";
                // la DESCRIPCIÓN ('texto al final) es prosa: sus letras no son nombres (con g y G en la hoja,
                // «'rigidez G (kN/m)» salía «ghkq2»). Se aparta y vuelve intacta tras la unidad.
                if (SepararDescripcion(body.TrimEnd(), out var sinDesc, out var descTxt)) { body = sinDesc; tail = " '" + descTxt + " " + tail; }
                // la UNIDAD visible [kN] tampoco es matemática: sus letras no son nombres de la hoja
                if (SepararUnidad(body.TrimEnd(), out var cuerpoSinU, out var uVis)) { tail = " [" + uVis + "] " + tail; body = cuerpoSinU; }
                // y las unidades de las COLUMNAS de en medio  (a = dec(…) [N/mm] ; b = …): SepararUnidad solo ve
                // la del final. Sin esto, con N y n en la hoja, «[N/mm]» salía «nhkq1/mm». Se tapan y se reponen al final.
                body = RxUnidadMedio.Replace(body, m => { unidMedio.Add(m.Groups[2].Value); return m.Groups[1].Value + "[\u0001" + (unidMedio.Count - 1) + "]"; });
                if (HasGreekUni(body))
                    body = RxIdentUni.Replace(body, m =>
                    {
                        if (!HasGreekUni(m.Value)) return m.Value;
                        var a = GreekToAscii(m.Value);
                        if (!uniOrig.ContainsKey(a)) uniOrig[a] = m.Value;
                        return a;
                    });
                int skip = plotDir ? body.IndexOf(Regex.Match(t, @"^#\s*\w+").Value.TrimStart('#').Trim(), StringComparison.Ordinal) : -1;
                foreach (Match m in RxIdent.Matches(body))
                {
                    if (plotDir && m.Index <= skip) continue;       // la palabra fplot/surf no es un nombre
                    var id = m.Value;
                    if (NoMangle.Contains(id) || SolverOps.ContainsKey(id.ToLowerInvariant())) continue;
                    var lo = id.ToLowerInvariant();
                    if (!groups.TryGetValue(lo, out var g)) groups[lo] = g = new List<string>();
                    if (!g.Contains(id)) g.Add(id);
                }
                cuerpo[k] = body; cola[k] = tail;
            }
            int n = 0;
            foreach (var kv in groups)
            {
                var lo = kv.Key; var sp = kv.Value;
                bool choque = sp.Count > 1;
                foreach (var id in sp)
                {
                    bool renombra = (choque && id != lo && (sp.Contains(lo) || id != sp[0]))
                                    || (LispReserved.Contains(lo) && id != lo);
                    if (renombra)
                    {
                        var nuevo = lo + MangleTag + (++n);
                        _mangle[id] = nuevo;
                        CaseMap[nuevo] = uniOrig.TryGetValue(id, out var u0) ? u0 : id;
                    }
                    else if (uniOrig.TryGetValue(id, out var u1)) { CaseMap[lo] = u1; CaseMap[id] = u1; }   // Δu: la etiqueta llega sin bajar a minúscula
                    else if (id != lo) CaseMap[lo] = id;
                }
            }
            for (int k = 0; k < lines.Length; k++)
            {
                if (cuerpo[k] == null) continue;
                var body = _mangle.Count == 0 ? cuerpo[k] : RxIdent.Replace(cuerpo[k], m => _mangle.TryGetValue(m.Value, out var r) ? r : m.Value);
                lines[k] = body + cola[k];
            }
            if (unidMedio.Count > 0)
                for (int k = 0; k < lines.Length; k++)
                    if (lines[k].IndexOf('\u0001') >= 0)
                        lines[k] = Regex.Replace(lines[k], @"\[\u0001(\d+)\]", m => "[" + unidMedio[int.Parse(m.Groups[1].Value)] + "]");
            return string.Join("\n", lines);
        }

        /// <summary>Un trozo suelto (un {nombre} de la prosa) con los MISMOS nombres que la hoja preparada.</summary>
        public static string MangleExpr(string s)
        {
            if (string.IsNullOrEmpty(s)) return s;
            s = GreekToAscii(s);
            return _mangle.Count == 0 ? s : RxIdent.Replace(s, m => _mangle.TryGetValue(m.Value, out var r) ? r : m.Value);
        }

        /// <summary>El nombre como lo escribió el usuario (deshace el renombrado y la minúscula del motor).</summary>
        public static string OriginalName(string s)
        {
            if (string.IsNullOrEmpty(s) || CaseMap.Count == 0) return s;
            return CaseMap.TryGetValue(s, out var o) ? o : s;
        }
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

        // Mapa mayúsculas: el motor LISP devuelve los nombres en minúscula (*print-case* :downcase),
        // así "L" o "EI" del usuario vuelven como "l"/"ei". MainWindow lo llena con los identificadores
        // TAL CUAL los escribió el usuario (lower→original) para restaurar el case en el render.
        public static readonly System.Collections.Generic.Dictionary<string, string> CaseMap =
            new(StringComparer.Ordinal);

        static string VarHtml(string name, bool vecArrow = false)
        {
            // restaura el case original (el motor bajó "L"→"l", "EI"→"ei", …)
            if (CaseMap.Count > 0 && CaseMap.TryGetValue(name, out var orig)) name = orig;
            // primas: apóstrofos al FINAL del nombre → ′ ″ ‴ (superíndice).  H1' = H₁′,  H1'' = H₁″
            string primes = "";
            while (name.Length > 1 && name[name.Length - 1] == '\'') { primes += "&prime;"; name = name.Substring(0, name.Length - 1); }
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
            // El apóstrofo no sobrevive al viaje por LISP (allí ' es quote), así que llega
            // convertido en el token `prime` — como en Hekatan Lab. Aquí se deshace: el token
            // puede venir pegado al SUBÍNDICE (Phi_1prime) o al nombre (Phiprime).
            // En TEXTO PLANO la prima se escribe con TOKEN, como en Hekatan Lab, porque el
            // apostrofo no sobrevive al viaje por LISP (alli ' es quote). Se admiten las dos
            // colocaciones: pegado al NOMBRE (Phiprime_1a -> Φ′₁ₐ, la de Lab) y pegado al
            // SUBINDICE (Phi_1prime -> Φ′₁). Mas especificos primero: tprime, pprime, prime.
            bool primaEnBase = false;
            // en BUCLE: `w''''` llega como wprimeprimeprime + ' y hay que deshacer TODOS
            // los tokens seguidos, no solo el ultimo (antes salia "wprimeprime′").
            for (bool sigue = true; sigue; )
            {
                sigue = false;
                foreach (var (tk, nprime) in new[] { ("tprime", 3), ("pprime", 2), ("prime", 1) })
                {
                    if (baseN.Length > tk.Length && baseN.EndsWith(tk, StringComparison.Ordinal))
                    { baseN = baseN.Substring(0, baseN.Length - tk.Length); primes = string.Concat(Enumerable.Repeat("&prime;", nprime)) + primes; primaEnBase = true; sigue = true; break; }
                    if (sub.Length > tk.Length && sub.EndsWith(tk, StringComparison.Ordinal))
                    { sub = sub.Substring(0, sub.Length - tk.Length); primes = string.Concat(Enumerable.Repeat("&prime;", nprime)) + primes; primaEnBase = true; sigue = true; break; }
                }
            }
            // vecArrow: la variable ES un vector/matriz → flecha automática sobre el nombre (v → v⃗).
            var deco = vecArrow ? Over("&#8594;", DecorateBase(baseN)) : DecorateBase(baseN);   // theta→θ, Fvec→F⃗…
            var h = "<span class=\"m-var\">" + deco + "</span>";
            if (primaEnBase && primes.Length > 0) { h += "<sup class=\"m-sup\">" + primes + "</sup>"; primes = ""; }
            if (sub.Length > 0) h += "<sub class=\"m-sub\">" + System.Net.WebUtility.HtmlEncode(sub) + "</sub>";
            if (primes.Length > 0) h += "<sup class=\"m-sup\">" + primes + "</sup>";
            return h;
        }

        // Factor escalar común de una matriz: si toda entrada es (* factor x) con el MISMO factor
        // (los 0 valen como factor·0), devuelve (factor, filas reducidas). factor=null si no hay.
        static (N factor, List<List<N>> rows) MatCommonFactor(N mat)
        {
            N factor = null; string facStr = null;
            var rows = new List<List<N>>();
            foreach (var row in mat.Items)
            {
                var cells = new List<N>();
                foreach (var c in row.Items)
                {
                    if (c != null && c.IsAtom && c.Atom == "0") { cells.Add(c); continue; }   // 0 = factor·0
                    if (c == null || c.Op != "*" || c.A == null || c.B == null) return (null, null);
                    string fs = ToLisp(c.A);
                    if (factor == null) { factor = c.A; facStr = fs; }
                    else if (fs != facStr) return (null, null);
                    cells.Add(c.B);
                }
                rows.Add(cells);
            }
            if (factor == null || facStr == "1") return (null, null);   // sin factor común no trivial
            return (factor, rows);
        }

        static bool IsMinusOne(N n) => n != null && n.IsAtom && (n.Atom == "-1" || n.Atom == "−1");

        /// <summary>De  (steps f0 f1 f2 …)  → la lista [f0, f1, f2, …] (formas LISP de nivel superior).
        /// Para la derivada que muestra su trabajo (deriv-steps): cada forma es un paso de la cadena.</summary>
        public static List<string> TopLevelArgs(string s)
        {
            var res = new List<string>();
            if (string.IsNullOrEmpty(s)) return res;
            s = s.Trim();
            if (!s.StartsWith("(")) return res;
            int i = 1;
            while (i < s.Length && !char.IsWhiteSpace(s[i]) && s[i] != ')') i++;   // salta el nombre "steps"
            while (i < s.Length)
            {
                while (i < s.Length && char.IsWhiteSpace(s[i])) i++;
                if (i >= s.Length || s[i] == ')') break;
                int start = i;
                if (s[i] == '(')
                {
                    int depth = 1; i++;
                    while (i < s.Length && depth > 0) { if (s[i] == '(') depth++; else if (s[i] == ')') depth--; i++; }
                }
                else while (i < s.Length && !char.IsWhiteSpace(s[i]) && s[i] != ')' && s[i] != '(') i++;
                res.Add(s.Substring(start, i - start));
            }
            return res;
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
                return "<span class=\"m-transp-wrap\">" + FlexSafe(ToHtml(n.A, 5)) + "<span class=\"m-transp\">T</span></span>";
            if (n.Op == "range")   // rango a:b  ó  a:s:b
                return string.Join("<span class=\"m-op\">:</span>", n.Items.Select(x => ToHtml(x, 2)));
            if (n.Op == "fn") return FnHtml(n);
            if (n.Op == "vec")
            {
                // Un vector de UN solo elemento es un escalar (resultado típico de un producto punto
                // fila·columna): se dibuja sin corchetes.
                if (n.Items.Count == 1) return ToHtml(n.Items[0], parentPrec);
                return GridHtml(new List<List<N>> { n.Items });
            }
            if (n.Op == "mat")
            {
                // Matriz 1×1 = ESCALAR: un producto fila·columna (producto punto) da un 1×1; se dibuja
                // como escalar, sin corchetes (p.ej. N₁ = [1 ξ]·c₁ = ½ − ξ/2, no [ ½ − ξ/2 ]).
                if (n.Items.Count == 1 && n.Items[0].Items != null && n.Items[0].Items.Count == 1)
                    return ToHtml(n.Items[0].Items[0], parentPrec);
                // FACTORIZAR escalar común: si toda entrada es (factor · x) con el MISMO factor
                // (los ceros valen como factor·0), se saca afuera: factor · [x…]. Forma de libro y
                // MUCHO más angosto (J⁻¹ = 1/detJ·[adj], D = E/(1−ν²)·[…]).
                var fac = MatCommonFactor(n);
                if (fac.factor != null)
                    return ToHtml(fac.factor, 3) + "<span class=\"m-op\">·</span>" + GridHtml(fac.rows);
                return GridHtml(n.Items.Select(r => r.Items).ToList());
            }
            switch (n.Op)
            {
                case "^":
                    return ToHtml(n.A, 5) + "<sup class=\"m-sup\">" + ToHtml(n.B, 0) + "</sup>";
                case "/":
                    return "<span class=\"m-frac\"><span class=\"m-frn\">" + ToHtml(n.A, 0) +
                           "</span><span class=\"m-frd\">" + ToHtml(n.B, 0) + "</span></span>";
                case "*":
                {
                    // −1·x  o  x·−1  →  −x  (evita el feo "-1·b" en la adjunta del inverso 2×2)
                    if (IsMinusOne(n.A)) { var rn = "<span class=\"m-op\">−</span>" + ToHtml(n.B, 2); return parentPrec > 2 ? Paren(rn) : rn; }
                    if (IsMinusOne(n.B)) { var rn = "<span class=\"m-op\">−</span>" + ToHtml(n.A, 2); return parentPrec > 2 ? Paren(rn) : rn; }
                    // tampoco en un producto: «−0.5·−1» se compone «−0.5·(−1)».
                    var derM = ToHtml(n.B, 2);
                    if (EsNegativo(n.B)) derM = Paren(derM);
                    var r = ToHtml(n.A, 2) + "<span class=\"m-op\">·</span>" + derM;
                    return parentPrec > 2 ? Paren(r) : r;
                }
                default: // + o -
                {
                    // 0 − x  →  −x  (el menos unario se guarda como (- 0 x); no mostrar el 0)
                    if (n.Op == "-" && n.A != null && n.A.IsAtom && n.A.Atom == "0")
                    {
                        var rn = "<span class=\"m-op\">−</span>" + ToHtml(n.B, 2);
                        return parentPrec > 2 ? Paren(rn) : rn;
                    }
                    var sym = n.Op == "-" ? "−" : "+";
                    // DOS SIGNOS SEGUIDOS NO SE ESCRIBEN. «1 − −1» no es notación
                    // matemática: el operando negativo va entre paréntesis,
                    // «1 − (−1)». Salía al evaluar una función de forma en ξ = −1.
                    var der = ToHtml(n.B, n.Op == "-" ? 2 : 1);
                    if (EsNegativo(n.B)) der = Paren(der);
                    var r = ToHtml(n.A, 1) + " <span class=\"m-op\">" + sym + "</span> " + der;
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
                case "det":   // determinante en notación matemática: |M| (barras verticales)
                {
                    var a = n.Items.Count > 0 ? n.Items[0] : null;
                    if (a != null && a.Op == "mat")
                        return GridHtml(a.Items.Select(r => r.Items).ToList(), true);
                    if (a != null && a.Op == "vec")
                        return GridHtml(new List<List<N>> { a.Items }, true);
                    // escalar o variable J → |J|
                    return "<span class=\"m-detbar\">|</span>" + arg0 + "<span class=\"m-detbar\">|</span>";
                }
                case "inv":   // inversa en notación matemática: J⁻¹ (superíndice −1, arriba-derecha)
                    return "<span class=\"m-transp-wrap\">" + FlexSafe(ToHtml(n.Items.Count > 0 ? n.Items[0] : null, 5)) +
                           "<span class=\"m-transp\">−1</span></span>";
                // --- operadores de matriz en la notación de los LIBROS, no en la del teclado ---
                // "menor(A,1,1)" y "trace(A)" se leían como código fuente, no como matemática.
                case "trace":   // la traza es tr(A)
                    return "<span class=\"m-fn\">tr</span>" + Paren(arg0);
                case "menor":
                case "minor":   // el menor de la posición i,j es M_ij — y la matriz, entre paréntesis
                    if (n.Items.Count >= 3)
                        return "<span class=\"m-fn\">M</span><sub class=\"m-sub\">" +
                               PlainIdx(n.Items[1]) + PlainIdx(n.Items[2]) + "</sub>" + Paren(arg0);
                    goto default;
                case "cofactor":  // y el cofactor, C_ij (menor CON su signo)
                    if (n.Items.Count >= 3)
                        return "<span class=\"m-fn\">C</span><sub class=\"m-sub\">" +
                               PlainIdx(n.Items[1]) + PlainIdx(n.Items[2]) + "</sub>" + Paren(arg0);
                    goto default;
                case "cross":   // producto cruz: u × v, con el aspa de siempre
                    if (n.Items.Count >= 2)
                        return ToHtml(n.Items[0], 5) + "<span class=\"m-op\"> × </span>" + ToHtml(n.Items[1], 5);
                    goto default;
                case "ceil":    // techo ⌈x⌉ (n = ⌈As/Ab⌉, regla de SAFE para el número de varillas)
                    return "<span class=\"m-detbar\">⌈</span>" + arg0 + "<span class=\"m-detbar\">⌉</span>";
                case "floor":   // piso ⌊x⌋
                    return "<span class=\"m-detbar\">⌊</span>" + arg0 + "<span class=\"m-detbar\">⌋</span>";
                case "abs":     // valor absoluto / módulo: |x|
                    return "<span class=\"m-detbar\">|</span>" + arg0 + "<span class=\"m-detbar\">|</span>";
                case "norm":    // norma: ‖v‖
                    return "<span class=\"m-detbar\">‖</span>" + arg0 + "<span class=\"m-detbar\">‖</span>";
                default:
                    var args = string.Join("<span class=\"m-op\">, </span>", n.Items.Select(x => ToHtml(x, 0)));
                    return FnNameHtml(name) + Paren(args);
            }
        }

        // nombre de FUNCIÓN con subíndice: N_1 → N₁ , N1 → N₁ , f → f (mismo split que las variables,
        // pero en estilo función m-fn). Así N_1(x) renderiza N₁(x), no "N_1(x)".
        static string FnNameHtml(string name)
        {
            name = OriginalName(name);   // f/F renombrados por choque, y su case original
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
            // primas con TOKEN (Φprime_1a → Φ′₁ₐ, Φpprime_1a → Φ″₁ₐ), igual que en VarHtml: una función
            // derivada se llama como la variable derivada. Antes el nombre de la FUNCIÓN no lo deshacía
            // y la definición  Φprime_1a(ξ) = …  salía «Φprime₁ₐ».
            string primas = "";
            for (bool sigue = true; sigue; )
            {
                sigue = false;
                foreach (var (tk, np) in new[] { ("tprime", 3), ("pprime", 2), ("prime", 1) })
                {
                    if (baseN.Length > tk.Length && baseN.EndsWith(tk, StringComparison.Ordinal))
                    { baseN = baseN.Substring(0, baseN.Length - tk.Length); primas = string.Concat(Enumerable.Repeat("&prime;", np)) + primas; sigue = true; break; }
                    if (sub.Length > tk.Length && sub.EndsWith(tk, StringComparison.Ordinal))
                    { sub = sub.Substring(0, sub.Length - tk.Length); primas = string.Concat(Enumerable.Repeat("&prime;", np)) + primas; sigue = true; break; }
                }
            }
            var h = "<span class=\"m-fn\">" + GreekSym(baseN) + "</span>";
            if (primas.Length > 0) h += "<sup class=\"m-sup\">" + primas + "</sup>";
            if (sub.Length > 0) h += "<sub class=\"m-sub\">" + System.Net.WebUtility.HtmlEncode(sub) + "</sub>";
            return h;
        }

        // vector/matriz: cuadrícula con corchetes grandes.
        // GRANDE (>9 col ó >11 filas): índices de fila/columna en los bordes y el centro
        //   COLAPSADO con … ⋮ ⋱ (como el MathCanvas de Hekatan Calc y como NumPy/MATLAB).
        //   Chica: cuadrícula simple, sin índices.
        // Un número (también negativo, o 1.5·10²⁰ de la hoja numérica) NO pide separador de columnas:
        // el separador es para distinguir EXPRESIONES. Antes un solo −0.41 ponía rayas en toda la matriz.
        static bool EsNumeroSimple(N c)
        {
            if (c.IsAtom) return true;
            if (c.Op == "neg" && c.A != null) return EsNumeroSimple(c.A);
            if ((c.Op == "^" || c.Op == "expt") && c.A != null && c.B != null && c.A.IsAtom && c.A.Atom == "10") return EsNumeroSimple(c.B);
            if (c.Op == "*" && c.A != null && c.B != null && c.A.IsAtom && double.TryParse(c.A.Atom, System.Globalization.NumberStyles.Float, System.Globalization.CultureInfo.InvariantCulture, out _))
                return EsNumeroSimple(c.B);
            return false;
        }

        static string GridHtml(List<List<N>> rows, bool bars = false)
        {
            // bars = true → delimitadores de DETERMINANTE (barras verticales |…|) en vez de
            // corchetes [ ]. Notación matemática de det(M).
            string BRL = bars ? "m-brk m-detl" : "m-brk m-brl";
            string BRR = bars ? "m-brk m-detr" : "m-brk m-brr";
            int nrows = rows.Count;
            int ncols = nrows == 0 ? 0 : rows.Max(r => r.Count);
            const int CMAX = 8, RMAX = 10;              // cuántas primeras se muestran antes de colapsar
            bool colBig = ncols > CMAX + 1;             // >9 columnas → colapsa horizontal
            bool rowBig = nrows > RMAX + 1;             // >11 filas   → colapsa vertical
            if (!colBig && !rowBig)                     // ---- matriz chica: como siempre ----
            {
                // separador vertical entre columnas si los elementos son SIMBÓLICOS (expresiones),
                // como Hekatan Lab: distingue dónde termina cada elemento. Números/variables solos, no.
                bool symSep = ncols > 1 && rows.Any(r => r.Any(c => c != null && !EsNumeroSimple(c)));
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
                return "<span class=\"m-mat\"><span class=\"" + BRL + "\"></span>" +
                       "<span class=\"m-mgrid\" style=\"grid-template-columns:repeat(" + ncols + ",auto)\">" +
                       sc + "</span><span class=\"" + BRR + "\"></span></span>";
            }
            // ---- matriz grande: COLAPSABLE con índices + … ⋮ ⋱ y el MISMO corchete [ ] de siempre ----
            //   (limpia, sin barras ni marcos: como NumPy/MATLAB).
            var cols = new List<int>();
            if (colBig) { for (int j = 0; j < CMAX; j++) cols.Add(j); cols.Add(-1); cols.Add(ncols - 1); }
            else        { for (int j = 0; j < ncols; j++) cols.Add(j); }
            var rws = new List<int>();
            if (rowBig) { for (int i = 0; i < RMAX; i++) rws.Add(i); rws.Add(-1); rws.Add(nrows - 1); }
            else        { for (int i = 0; i < nrows; i++) rws.Add(i); }
            return IndexedGrid(rows, cols, rws, ncols, nrows,
                               colBig ? CMAX : ncols, rowBig ? RMAX : nrows);
        }

        // Carga util para ARRASTRAR la matriz: el HTML de TODAS las celdas, en JSON.
        // Sin esto el JS solo veria lo ya truncado y arrastrar no mostraria nada nuevo.
        // Tope de seguridad: matrices enormes no se serializan (se quedan solo truncadas).
        const int HK_MAX_CELDAS = 4000;
        static string CeldasJson(List<List<N>> rows, int ncols, int nrows)
        {
            if ((long)ncols * nrows > HK_MAX_CELDAS) return null;
            var sb = new StringBuilder("[");
            for (int r = 0; r < nrows; r++)
            {
                if (r > 0) sb.Append(',');
                sb.Append('[');
                for (int c = 0; c < ncols; c++)
                {
                    if (c > 0) sb.Append(',');
                    string h = c < rows[r].Count ? ToHtml(rows[r][c], 0) : "";
                    sb.Append('"');
                    foreach (char ch in h)
                    {
                        if (ch == '"') sb.Append("\\\"");
                        else if (ch == '\\') sb.Append("\\\\");
                        else if (ch == '<') sb.Append("\\u003c");
                        else if (ch == '>') sb.Append("\\u003e");
                        else if (ch == '&') sb.Append("\\u0026");
                        else if (ch < ' ') sb.Append("\\u").Append(((int)ch).ToString("x4"));
                        else sb.Append(ch);
                    }
                    sb.Append('"');
                }
                sb.Append(']');
            }
            return sb.Append(']').ToString();
        }

        // dibuja UNA cuadrícula con índices en los bordes; cols/rws son los índices a mostrar (-1 = hueco … ⋮ ⋱)
        static string IndexedGrid(List<List<N>> rows, List<int> cols, List<int> rws, int ncols, int nrows,
                                  int visC = -1, int visR = -1)
        {
            bool showCol = ncols > 1, showRow = nrows > 1;
            // separador vertical entre columnas de DATOS si la matriz es simbólica (como Hekatan Lab).
            bool symSep = ncols > 1 && rows.Any(r => r.Any(c => c != null && !EsNumeroSimple(c)));
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
            // Datos para ARRASTRAR (hkMat en MAT_JS): totales, cuantas se ven ahora y todas las celdas.
            string arrastre = "";
            if (visC > 0 && visR > 0)
            {
                string celdas = CeldasJson(rows, ncols, nrows);
                if (celdas != null)
                    arrastre = " data-hk-r=\"" + nrows + "\" data-hk-c=\"" + ncols + "\""
                             + " data-vis-rows=\"" + visR + "\" data-vis-cols=\"" + visC + "\""
                             + " data-hk-sep=\"" + (symSep ? 1 : 0) + "\""
                             + " data-hk-cells='" + celdas + "'";
            }
            sb.Append("<span class=\"m-matx\"").Append(arrastre).Append(shift).Append(">");
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
            if (arrastre.Length > 0) sb.Append("<span class=\"mat-grip\" title=\"Arrastrar para ver mas o menos celdas\"></span>");
            sb.Append("</span>");
            return sb.ToString();
        }

        // ---------- pagina HTML completa (worksheet) — tema claro/oscuro como Hekatan Lab ----------
        public static bool Dark = true;
                // El separador daba 1.83 sobre el fondo oscuro: no se veia. Subido a 5.1.
        const string ROOT_DARK  = ":root{--bg:#000000;--fg:#f0efec;--mut:#9aa0a6;--var:#8ab4f8;--num:#9ecbff;--nary:#c080f0;--sep:#8f7fb0;--dib-rojo:#ff6b5e;--dib-azul:#6fa8ff;--dib-verde:#4cc38a;--dib-nar:#ffa94d;--dib-acero:#ff7a6e;}";
                // Contraste MEDIDO (WCAG) sobre el crema del video, con la marca de agua
        // encima: el separador estaba en 1.6 (invisible) y las variables e integrales
        // se quedaban justas en 4.8. Subidos a 7 o mas; el texto, a 16.8.
        const string ROOT_LIGHT = ":root{--bg:#FBF7EC;--fg:#171310;--mut:#544d3a;--var:#0b4fa8;--num:#08306b;--nary:#7a1fa8;--sep:#9c86b8;--dib-rojo:#c62828;--dib-azul:#1c5fbf;--dib-verde:#2b8a3e;--dib-nar:#d9480f;--dib-acero:#b3141c;}";
        const string CSS = @"
*{box-sizing:border-box;}
.pagebreak{break-before:page;page-break-before:always;height:0;margin:0;border:0;}
@media print{ body{background:#fff;} .pagebreak{break-before:page;page-break-before:always;}
  /* al imprimir la columna es mas angosta que la pantalla: fit() se calculo para pantalla, asi
     que una ecuacion ancha (K = integral BtB) puede desbordar y overflow-x:auto imprime la barra.
     En papel NUNCA queremos barra: se oculta (el contenido ya cabe, la barra sobraba). */
  .ws-eq,.deq-body{overflow-x:hidden !important;overflow-y:hidden !important;}
  /* el título y la frase que PRESENTA una fórmula no se quedan solos al pie de la hoja */
  .ws-h1,.ws-h2,.ws-h3,.ws-fmt:has(+ .ws-eq),.ws-fmt:has(+ .ws-deq),.ws-fmt:has(+ .hk-plotslot){break-after:avoid;page-break-after:avoid;}
  .ws-eq,.ws-deq{break-inside:avoid;page-break-inside:avoid;}
  .ws-tbl-wrap{break-inside:avoid;page-break-inside:avoid;overflow-x:visible;}
  /* en papel una tabla ancha NO debe salir con barra de desplazamiento: las celdas se parten */
  table.ws-table td,table.ws-table th{white-space:normal;} }
body{margin:0;padding:10px 1.5em;background:var(--bg);color:var(--fg);
  font-family:'Segoe UI','Arial Nova',Helvetica,sans-serif;font-size:11pt;line-height:150%;overflow-x:hidden;}
.ws-eq{margin:0.4em 0;padding:.4em 0 .25em;
  font-family:Georgia,'Times New Roman',Times,serif;font-size:11.5pt;
  font-variant-numeric:lining-nums;font-feature-settings:'lnum' 1;
  overflow-x:auto;overflow-y:hidden;max-width:100%;}   /* padding = aire para glifos altos (∫ Σ) que overflow-y:hidden recortaría; overflow-x:auto = scroll para matrices anchas */
/* gráficas: alto acotado para que NO ocupen una hoja entera en el PDF, y no partirlas entre páginas */
.hk-plotslot{break-inside:avoid;page-break-inside:avoid;}
.hk-plotslot:has(> .hk-lado){display:inline-block;width:49%;vertical-align:top;}
.hk-lado svg,.hk-lado img{max-width:100% !important;}
.hk-lado > div[class^=hkan]{margin-top:0 !important;}
@media print{ .hk-plotslot img,.hk-plotslot svg{max-height:300px;width:auto;max-width:100%;height:auto;} }
.ws-eq::-webkit-scrollbar{height:8px;} .ws-eq::-webkit-scrollbar-thumb{background:var(--mut);border-radius:4px;}
.ws-txt{font-family:'Segoe UI',sans-serif;font-size:10.5pt;color:var(--mut);font-weight:600;margin-top:1em;}
.ws-prosa{font-family:'Segoe UI','Arial Nova',Helvetica,sans-serif;font-style:normal;margin-right:.45em;}
/* #deq: ecuación con ETIQUETA a la derecha, estilo libro/paper — «… (2.3.4)» */
.ws-unit{font-family:'Segoe UI',Arial,sans-serif;font-style:normal;font-weight:normal;margin-left:.35em;white-space:nowrap;}\n.ws-desc{font-family:'Segoe UI',Arial,sans-serif;font-style:normal;font-weight:normal;color:#6b6257;margin-left:1.6em;}
.ws-deq{display:flex;flex-wrap:wrap;align-items:center;gap:.3em 1.2em;overflow:visible;}
.ws-deq>.deq-body{flex:0 1 auto;max-width:100%;min-width:0;overflow-x:auto;overflow-y:hidden;padding:.4em 0 .25em;}
.ws-deq>.deq-tag{flex:0 0 auto;margin-left:auto;color:var(--mut);font-size:.85em;white-space:nowrap;font-family:'Segoe UI',sans-serif;}
/* texto con formato (directivas ; estilo Hekatan Lab) */
.ws-fmt{font-family:'Segoe UI','Arial Nova',Helvetica,sans-serif;margin:.35em 0;color:var(--fg);}
.ws-h1{font-weight:700;font-size:15pt;margin:.7em 0 .35em;}
.ws-h2{font-weight:600;font-size:12.5pt;margin:.55em 0 .3em;}
.ws-h3{font-weight:600;font-size:11pt;margin:.45em 0 .25em;color:var(--mut);}
.al-left{text-align:left;} .al-center{text-align:center;} .al-right{text-align:right;}
/* TABLAS (texto escrito a mano #|…|…| o resultados calculados #tabla(…)): estilo libro tecnico,
   sin lineas verticales (booktabs) — regla arriba/abajo del encabezado, filita fina entre datos. */
.ws-tbl-wrap{margin:.5em 0 .9em;overflow-x:auto;}
table.ws-table{border-collapse:collapse;font-family:'Segoe UI','Arial Nova',Helvetica,sans-serif;
  font-size:10.3pt;margin:0;}
table.ws-table caption{caption-side:top;text-align:left;font-weight:600;color:var(--fg);margin-bottom:.3em;}
table.ws-table thead tr{border-top:1.4px solid var(--fg);}
table.ws-table th{font-weight:700;color:var(--fg);border-bottom:1.4px solid var(--fg);
  padding:.3em .85em;white-space:nowrap;text-align:left;}
table.ws-table td{padding:.26em .85em;border-bottom:.75px solid var(--sep);color:var(--fg);white-space:nowrap;}
table.ws-table tbody tr:last-child td{border-bottom:1.4px solid var(--fg);}
table.ws-table th.ws-c-num,table.ws-table td.ws-c-num{text-align:right;font-variant-numeric:tabular-nums;color:var(--num);}
table.ws-table th.ws-c-txt,table.ws-table td.ws-c-txt{text-align:left;}
table.ws-table th.ws-c-center,table.ws-table td.ws-c-center{text-align:center;}
table.ws-table sub{font-size:.72em;} table.ws-table sup{font-size:.72em;}
/* DIBUJO TÉCNICO (#dibujo … #fin): SVG en mm de papel, colores del tema; no se parte entre páginas */
.hk-dib{margin:.6em 0 1em;break-inside:avoid;page-break-inside:avoid;}
.hk-dib-tit{font-family:'Segoe UI',sans-serif;font-size:10pt;color:var(--fg);margin-bottom:.3em;}
.hk-dib-esc{color:var(--mut);font-size:.92em;}
.hk-dib-svg{display:block;margin:0 auto;}
.hk-dib-ley{display:flex;flex-wrap:wrap;gap:.2em 1.3em;font-family:'Segoe UI',sans-serif;font-size:9.5pt;color:var(--fg);margin:.35em 0 .2em;}
.hk-dib-li{display:inline-flex;align-items:center;gap:.35em;}
.hk-dib-err{color:var(--dib-rojo);font-family:'Segoe UI',sans-serif;font-size:9.5pt;margin:.3em 0;}
/* DIBUJO AUTOLISP (#autolisp … #fin): salida del programa (como la línea de órdenes) + dibujo + guardar */
.hk-al{margin:.5em 0 1em;}
.hk-al-out{margin:.3em 0 .6em;padding:.45em .8em;border-left:2px solid var(--sep);background:transparent;color:var(--mut);font-family:Consolas,'Cascadia Code',monospace;font-size:9.5pt;line-height:1.45;white-space:pre-wrap;}
.hk-al-errl{color:var(--dib-rojo);}
.hk-al-bar{display:flex;flex-wrap:wrap;align-items:center;justify-content:center;gap:.35em;margin:.35em 0 .2em;font-family:'Segoe UI',sans-serif;font-size:8.5pt;color:var(--mut);}
.hk-al-bar span{margin-right:.3em;}
.hk-al-bar button{font:inherit;color:var(--fg);background:transparent;border:1px solid var(--sep);border-radius:3px;padding:.05em .6em;cursor:pointer;}
.hk-al-bar button:hover{border-color:var(--var);color:var(--var);}
.hk-al-nota{font-family:'Segoe UI',sans-serif;font-size:8.5pt;color:var(--mut);text-align:center;}
@media print{.hk-al-bar{display:none;}}
table.hk-obs td{white-space:normal;vertical-align:top;}
table.hk-obs td:nth-child(3){min-width:22em;}
.hk-obs-n{display:inline-block;width:1.7em;height:1.7em;line-height:1.7em;border-radius:50%;color:#fff;text-align:center;font-weight:700;font-size:.88em;}
.hk-obs-e{font-weight:600;}
.m-var{font-style:italic;color:var(--var);font-size:105%;} .m-num{color:var(--num);}
.m-op{color:var(--mut);padding:0 .08em;}
.m-link{color:var(--var);text-decoration:none;border-bottom:1px solid currentColor;}
.m-link:hover{background:rgba(127,127,127,.18);}
@media print{.m-link{color:inherit;border-bottom:1px dotted currentColor;}}
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
.m-transp-wrap{display:inline-flex;align-items:flex-start;vertical-align:middle;}
.m-transp{font-size:.72em;font-style:normal;line-height:1;margin-left:1px;}
.m-detl{border-left:1.4px solid currentColor;}
.m-detr{border-right:1.4px solid currentColor;}
.m-detbar{color:currentColor;margin:0 .08em;}
.m-mgrid{display:inline-grid;padding:.15em .35em;gap:.15em .7em;text-align:center;align-items:center;}
.m-cell{color:var(--num);white-space:nowrap;}
/* matriz GRANDE: índices en los bordes + centro colapsado (… ⋮ ⋱), como Hekatan Calc */
.m-matx{display:inline-grid;position:relative;vertical-align:middle;margin:0 .25em;row-gap:.05em;column-gap:0;align-items:center;justify-items:center;}
/* manija para ARRASTRAR la matriz y ver mas/menos celdas (igual que Hekatan Calc web) */
.mat-grip{position:absolute;right:-2px;bottom:-2px;width:16px;height:16px;cursor:nwse-resize;opacity:.4;transition:opacity .15s;z-index:3;}
.mat-grip::before{content:'';position:absolute;right:2px;bottom:2px;width:11px;height:11px;border-right:2.5px solid #4a90d9;border-bottom:2.5px solid #4a90d9;}
.m-matx:hover>.mat-grip,.mat-resizing>.mat-grip{opacity:1;}
.mat-resizing{outline:1.5px dashed #4a90d9 !important;outline-offset:3px;}
.m-mh{color:var(--mut);font-family:Calibri,Candara,Corbel,sans-serif;font-size:.72em;padding:0 .45em .1em;}
.m-mrh{color:var(--mut);font-family:Calibri,Candara,Corbel,sans-serif;font-size:.72em;padding:0 .35em 0 0;justify-self:end;}
.m-mc{color:var(--num);padding:.12em .45em;text-align:center;white-space:nowrap;}
.m-matx>.m-brl{min-width:.3em;margin-right:.18em;align-self:stretch;}
.m-matx>.m-brr{min-width:.3em;margin-left:.18em;align-self:stretch;}
.m-ell{color:var(--mut);}
/* n-ario apilado (Σ Π) — medidas EXACTAS de Hekatan Lab (.dvr/.nary) */
.m-dvr{display:inline-block;vertical-align:middle;text-align:center;line-height:110%;white-space:nowrap;position:relative;top:-3pt;margin:0 .12em;}
.m-dvr small{font-family:Calibri,Candara,Corbel,sans-serif;font-size:70%;display:block;}
.m-nary{display:block;font-size:240%;line-height:70%;font-weight:200;color:var(--nary);font-family:'Georgia Pro Light','Georgia Pro','Century Schoolbook',serif;margin:0 1pt 2.5pt 1pt;}
/* ∫ inclinado y delgado (como Hekatan Lab .nary em): scaleX 0.7 + rotate 7deg */
.m-nary em{display:block;font-style:normal;transform:scaleX(0.7) rotate(7deg);}
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

        // ---------- TABLAS (texto escrito a mano #|…|…| y resultados calculados #tabla(…)) ----------
        // Un solo constructor de HTML para las dos: filas y encabezado YA vienen en HTML (negrita,
        // subindices @{…} ya resueltos) — aqui solo se arma la <table>, estilo libro tecnico (sin
        // lineas verticales, regla arriba/abajo del encabezado). aligns[c]: "num"|"txt"|"center".
        public static string BuildTable(string caption, List<string> aligns, List<string> headerHtml, List<List<string>> rowsHtml)
        {
            string ClsOf(int c) => "ws-c-" + (c < aligns.Count && aligns[c] != null ? aligns[c] : "txt");
            var sb = new StringBuilder();
            sb.Append("<div class=\"ws-tbl-wrap\"><table class=\"ws-table\">");
            if (!string.IsNullOrEmpty(caption)) sb.Append("<caption>").Append(caption).Append("</caption>");
            if (headerHtml != null && headerHtml.Count > 0)
            {
                sb.Append("<thead><tr>");
                for (int c = 0; c < headerHtml.Count; c++)
                    sb.Append("<th class=\"").Append(ClsOf(c)).Append("\">").Append(headerHtml[c]).Append("</th>");
                sb.Append("</tr></thead>");
            }
            sb.Append("<tbody>");
            // nº de columnas = el encabezado (si hay); una fila corta rellena en blanco, una larga se recorta —
            // así una fila de datos con menos celdas que el encabezado no desplaza las columnas siguientes.
            int nCols = headerHtml != null && headerHtml.Count > 0 ? headerHtml.Count
                      : (rowsHtml != null ? rowsHtml.Select(r => r.Count).DefaultIfEmpty(0).Max() : 0);
            if (rowsHtml != null)
                foreach (var row in rowsHtml)
                {
                    sb.Append("<tr>");
                    for (int c = 0; c < nCols; c++)
                        sb.Append("<td class=\"").Append(ClsOf(c)).Append("\">").Append(c < row.Count ? row[c] : "").Append("</td>");
                    sb.Append("</tr>");
                }
            sb.Append("</tbody></table></div>");
            return sb.ToString();
        }

        // numero de un atomo LISP  ("12.5"·"-3"·"3/4")  →  double, o null si es simbolico (no numero).
        public static double? NumFromAtom(string a)
        {
            a = a?.Trim();
            if (string.IsNullOrEmpty(a)) return null;
            if (double.TryParse(a, System.Globalization.NumberStyles.Any, System.Globalization.CultureInfo.InvariantCulture, out var d)) return d;
            var mm = Regex.Match(a, @"^(-?\d+)\s*/\s*(\d+)$");
            if (mm.Success
                && double.TryParse(mm.Groups[1].Value, System.Globalization.NumberStyles.Any, System.Globalization.CultureInfo.InvariantCulture, out var num)
                && double.TryParse(mm.Groups[2].Value, System.Globalization.NumberStyles.Any, System.Globalization.CultureInfo.InvariantCulture, out var den)
                && den != 0)
                return num / den;
            return null;
        }

        // celda NUMERICA de una tabla de resultados: "decimales" cifras fijas. Si el atomo NO es
        // numerico (quedo simbolico: x, EI/L…) se dibuja con el motor de ecuaciones, no como texto
        // plano — ver feedback_hekatan_lisp_solo_operaciones_no_texto.
        public static string FormatNumCell(string atomOrExpr, int decimales)
        {
            var v = NumFromAtom(atomOrExpr);
            if (v.HasValue) return v.Value.ToString("F" + Math.Max(0, decimales), System.Globalization.CultureInfo.InvariantCulture);
            try { var t = ParseLisp(atomOrExpr); return t != null ? ToHtml(t) : System.Net.WebUtility.HtmlEncode(atomOrExpr ?? ""); }
            catch { return System.Net.WebUtility.HtmlEncode(atomOrExpr ?? ""); }
        }

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
                if (!EsTitulo(s0) && Regex.IsMatch(s0, @"^#+\s*(anim|animar|animacion|slider|barra_deslizante|deslizador|gauss|cuadratura|gausslegendre|fila|finfila|fplot|plot|ezplot|graficas?|grafico|surf|superficie|plot3d|mesh|map|mapa|heatmap|contourf?|beam|viga|esquema|frame|portico|framedef|porticodef|slice|trozo|elemento|defl|diag|vmd|bar1d|barra|elem1d|punto|dotprod|producto|dot|recta|ab|interceptopendiente|mapa1d|xdexi|mapnatural|salto|pagebreak|nuevapagina|pagina|newpage)\b", RegexOptions.IgnoreCase)) return null;
                // #tabla(…)/#table(…): directiva de TABLA (headers)(cols) — no es prosa, se procesa aparte.
                if (Regex.IsMatch(s0, @"^#+\s*(?:tabla|table)\s*\(", RegexOptions.IgnoreCase)) return null;
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
            if (Regex.IsMatch(s, @"^(anim|animar|animacion|slider|barra_deslizante|deslizador|gauss|cuadratura|gausslegendre|fila|finfila|fplot|plot|ezplot|graficas?|grafico|surf|superficie|plot3d|mesh|map|mapa|heatmap|contourf?|beam|viga|esquema|frame|portico|framedef|porticodef|slice|trozo|elemento|defl|diag|vmd|bar1d|barra|elem1d|punto|dotprod|producto|dot|recta|ab|interceptopendiente|mapa1d|xdexi|mapnatural|salto|pagebreak|nuevapagina|pagina|newpage)\b", RegexOptions.IgnoreCase)) return null;
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
            // subindice/superindice EXPLICITOS:  x^{2}  ·  N_{1}  — ANTES que @{expr}/{expr}: si no,
            // "{2}" (sin @ ni ^/_ real) se confunde con el alias de VALOR de abajo y {2} se sustituye
            // por el numero 2 renderizado (m-expr), comiendose las llaves antes de llegar aqui.
            t = Regex.Replace(t, @"\^\{([^{}]+)\}", "<sup>$1</sup>");
            t = Regex.Replace(t, @"_\{([^{}]+)\}", "<sub>$1</sub>");
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
            // markdown: [texto](url) → enlace. VA PRIMERO: una URL lleva _ y * y, si se
            // procesa despues, la cursiva se come el enlace. Se admite http(s) y el #ej=
            // de las hojas publicadas; cualquier otro esquema se deja como texto.
            t = Regex.Replace(t, @"\[([^\]]+)\]\(([^)\s]+)\)", m =>
            {
                var txt = m.Groups[1].Value;
                var url = m.Groups[2].Value;
                var ok = url.StartsWith("http://", StringComparison.OrdinalIgnoreCase)
                      || url.StartsWith("https://", StringComparison.OrdinalIgnoreCase)
                      || url.StartsWith("#");
                if (!ok) return m.Value;
                var u = url.Replace("&", "&amp;").Replace("\"", "&quot;");
                return "<a class=\"m-link\" href=\"" + u + "\" target=\"_blank\" rel=\"noopener\">" + txt + "</a>";
            });
            // y una URL suelta tambien se enlaza sola
            t = Regex.Replace(t, @"(?<![""'>=])https?://[^\s<)]+", m =>
            {
                var u = m.Value.Replace("&", "&amp;");
                return "<a class=\"m-link\" href=\"" + u + "\" target=\"_blank\" rel=\"noopener\">" + m.Value + "</a>";
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

        // ── UNIDAD VISIBLE ──  P_1 = 35 [kN]   ·   w = dec(P_2/kB, 3) [mm]   ·   k_s = 19613.3 [kN/m^3]
        // La unidad va entre corchetes al FINAL de una línea de matemática y se DIBUJA pegada al último número de la
        // línea (el dato o el resultado), en letra recta. Es solo dibujo: el cálculo sigue con números puros, así que
        // no convierte ni comprueba dimensiones (eso sería el paso 2). La línea de display trae "...ecuación...\x04kN".
        public const char UnitSep = '\x04';
        // DESCRIPCION de una variable, como en Calcpad:  h = 6m|m 'Altura del objeto
        // Va a la derecha de la linea, en texto normal. Solo dibujo.
        public const char DescSep = '\x05';
        static readonly Regex RxDescFinal = new Regex(@"^(?<cuerpo>.*?)\s+'(?<d>[^']*)$", RegexOptions.Compiled);
        /// <summary>«# Elemento ShellMITC4 …», «# Cuadratura de Gauss»: '#', espacio, palabra, espacio y otra
        /// palabra = TÍTULO, aunque la primera palabra sea el nombre de una directiva (elemento, gauss, punto…).
        /// Las directivas van pegadas (#elemento(…)) o con paréntesis (#  fila(…)).</summary>
        public static bool EsTitulo(string linea) => Regex.IsMatch(linea ?? "", @"^\s*#+[ \t]+\w+[ \t]+[^\s(]");
        public static bool SepararDescripcion(string linea, out string cuerpo, out string desc)
        {
            cuerpo = linea; desc = null;
            if (string.IsNullOrEmpty(linea)) return false;
            var m = RxDescFinal.Match(linea);
            if (!m.Success) return false;
            var c = m.Groups["cuerpo"].Value.TrimEnd();
            if (c.Length == 0) return false;
            cuerpo = c; desc = m.Groups["d"].Value.Trim();
            return desc.Length > 0;
        }
        static string InjectDesc(string div, string desc)
        {
            int end = div.LastIndexOf("</div>");
            if (end < 0 || string.IsNullOrEmpty(desc)) return div;
            return div.Substring(0, end) + "<span class=\"ws-desc\" style=\"font-family:'Segoe UI',Arial,sans-serif;font-style:normal;font-weight:400;color:#6b6257;margin-left:1.8em;\">" + System.Net.WebUtility.HtmlEncode(desc) + "</span>" + div.Substring(end);
        }
        static string QuitarDesc(ref string raw)
        {
            int ds = raw.IndexOf(DescSep);
            if (ds < 0) return null;
            var d = raw.Substring(ds + 1);
            raw = raw.Substring(0, ds);
            return d;
        }
        // No es una matriz: empieza por letra (o ° % µ Ω), sin espacios, comas ni punto y coma dentro, y lo de antes
        // no acaba en un operador ni en '=' (así  v = [a]  y  K = [1 2; 3 4]  siguen siendo matrices).
        static readonly Regex RxUnidadFinal = new Regex(@"^(?<cuerpo>.*\S)\s+\[(?<u>[A-Za-zµμΩ°º%‰][^\[\]\s;,]*)\]\s*$", RegexOptions.Compiled);
        public static bool SepararUnidad(string linea, out string cuerpo, out string unidad)
        {
            cuerpo = linea; unidad = null;
            if (string.IsNullOrEmpty(linea)) return false;
            var m = RxUnidadFinal.Match(linea);
            if (!m.Success) return false;
            string c = m.Groups["cuerpo"].Value;
            if ("=+-*/^(,·".IndexOf(c[c.Length - 1]) >= 0) return false;
            cuerpo = c; unidad = m.Groups["u"].Value;
            return true;
        }
        /// <summary>kN/m^3 → kN/m³ · kN*m → kN·m · m^-1 → m⁻¹ (texto ya codificado para HTML).</summary>
        public static string FormatearUnidad(string u)
        {
            const string SUP = "⁰¹²³⁴⁵⁶⁷⁸⁹";
            u = Regex.Replace(u ?? "", @"\^\(?(-?)(\d)\)?", m => (m.Groups[1].Value == "-" ? "⁻" : "") + SUP[m.Groups[2].Value[0] - '0']);
            // «m2» y «cm2» (como se escriben en obra) también son m² y cm²: un dígito
            // pegado detrás de letras es un exponente, no parte del nombre de la unidad.
            u = Regex.Replace(u, @"(?<=[A-Za-zµμΩ°º])(\d)(?![A-Za-z0-9])", m => SUP[m.Value[0] - '0'].ToString());
            // como Calcpad (HtmWriter.cs: UnitDivision / UnitProduct): el producto va
            // con punto medio y espacio fino, y la división con el SLASH de división
            // (U+2215), no la barra de teclado — es la que no se confunde con un 1.
            u = u.Replace("*", " · ").Replace("/", " ∕ ");
            return System.Net.WebUtility.HtmlEncode(u);
        }
        // mete la unidad al final del contenido del <div> de la ecuación (después del último número)
        static string InjectUnit(string div, string unidad)
        {
            int end = div.LastIndexOf("</div>");
            if (end < 0 || string.IsNullOrEmpty(unidad)) return div;
            return div.Substring(0, end) + "<span class=\"ws-unit\">" + FormatearUnidad(unidad) + "</span>" + div.Substring(end);
        }
        static string QuitarUnidad(ref string raw)
        {
            int us = raw.IndexOf(UnitSep);
            if (us < 0) return null;
            string u = raw.Substring(us + 1); raw = raw.Substring(0, us);
            return u;
        }

        // Separa asignaciones que venían de la MISMA línea (a=2; b=3) → se dibujan LADO A LADO en una fila.
        public const char SbsSep = '\x03';

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
                string div;
                if (raw.IndexOf(SbsSep) >= 0) div = RenderSideBySide(raw, fromLisp);
                else
                {
                    string desc = QuitarDesc(ref raw);
                    string unidad = QuitarUnidad(ref raw);
                    div = RenderLineHtml(raw, fromLisp);
                    if (unidad != null && div.StartsWith("<div class=\"ws-eq")) div = InjectUnit(div, unidad);
                    if (desc != null && div.StartsWith("<div class=\"ws-eq")) div = InjectDesc(div, desc);
                }
                if (deqTag != null && div.StartsWith("<div class=\"ws-eq")) div = InjectDeqTag(div, deqTag);
                body.Append(div);
            }
            return "<!doctype html><html><head><meta charset=\"utf-8\"><style>" +
                   (Dark ? ROOT_DARK : ROOT_LIGHT) + CSS +
                   "</style></head><body>" + body + MAT_JS + HK_MAT_JS + "</body></html>";
        }

        // Varias asignaciones de la MISMA línea (a=2; b=3) → una sola fila .ws-eq con las celdas lado a lado,
        // igual que Hekatan Lab. Renderiza cada parte como ecuación y le quita su envoltura <div> para meterlas
        // en una fila flex.
        static string RenderSideBySide(string raw, bool fromLisp)
        {
            var cells = new System.Text.StringBuilder();
            foreach (var part in raw.Split(SbsSep))
            {
                if (part.Trim().Length == 0) continue;
                string parte = part;
                string dParte = QuitarDesc(ref parte);
                string uParte = QuitarUnidad(ref parte);
                string d = RenderLineHtml(parte, fromLisp);
                if (uParte != null && d.StartsWith("<div class=\"ws-eq")) d = InjectUnit(d, uParte);
                if (dParte != null && d.StartsWith("<div class=\"ws-eq")) d = InjectDesc(d, dParte);
                int gt = d.IndexOf('>'); int end = d.LastIndexOf("</div>");
                string inner = (gt >= 0 && end > gt) ? d.Substring(gt + 1, end - gt - 1) : d;
                cells.Append("<span class=\"sbs-cell\">").Append(inner).Append("</span>");
            }
            // El flex va en un span INTERNO (hijo único), no en el .ws-eq: el auto-fit (MAT_JS) mete todos
            // los hijos del .ws-eq en un solo span y colapsaría el flex si estuviera en el .ws-eq.
            // REJILLA, no flex: con flex cada celda se ajusta a su contenido y dos filas
            // seguidas no alinean sus columnas — no parecía una tabla. Con columnas de
            // ancho igual (1fr), dos filas con el mismo número de celdas alinean.
            return "<div class=\"ws-eq\"><span style=\"display:grid;grid-auto-flow:column;"
                   + "grid-auto-columns:minmax(0,1fr);gap:.4em 2em;align-items:baseline;width:100%;justify-items:start\">"
                   + cells + "</span></div>";
        }

        // renderiza UNA línea de display (texto formateado o ecuación) a su <div>. "" si es vacía/omitida.
        static string RenderLineHtml(string raw, bool fromLisp)
        {
            {
                // GRÁFICA en su posición: un hueco que MainWindow rellena con el HTML de la gráfica.
                if (raw == PlotSlot) return "<div class=\"hk-plotslot\"></div>";
                // marcador de TEXTO con formato (viene de una directiva ; procesada en ComputeResult)
                // ORDINAL: TxtMark es "\x01T" y StartsWith(string) compara con la CULTURA, que IGNORA el
                // \x01 → toda fórmula cuya cabecera empezaba por T (Tz = …, T_1 = …) se tomaba por
                // texto y DESAPARECÍA de la hoja.
                if (raw.StartsWith(TxtMark, StringComparison.Ordinal))
                {
                    var pz = raw.Split(TxtSep);   // ["","T",kind,align,html…]
                    string kind = pz.Length > 2 ? pz[2] : "p";
                    string align = pz.Length > 3 ? pz[3] : "left";
                    string htmlC = pz.Length > 4 ? string.Join(TxtSep.ToString(), pz.Skip(4)) : "";
                    // TABLA (texto a mano #|…|…| o #tabla(…) de resultados): htmlC YA es el <div><table>…
                    // completo (armado por BuildTable) — se pega tal cual, sin envolver en ws-fmt/al-*.
                    if (kind == "table") return htmlC;
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
                        // "N1 = A = B → C": pasos separados por " = " (igualdad) o " → " (flecha, como
                        // los libros cuando hay más de 2 pasos: ecuación → solución). Se conserva cuál va.
                        // separadores de paso: '=' (igualdad), '→' (despeje) y '≈' (lo pone `dec`,
                        // para un valor redondeado: 1/3 ≈ 0.33). Sin el ≈ aquí, "X ≈ Y" se parseaba
                        // ENTERO como una expresión, fallaba, y el valor no llegaba a dibujarse.
                        var toks = System.Text.RegularExpressions.Regex.Split(lblM.Groups[2].Value, @"(\s=\s|\s→\s|\s≈\s)");
                        // Salida de programa con prosa/infija en algún tramo ("h = 1  ->  pendiente = 3"):
                        // ParseLisp truncaba en silencio ("1 -> pendiente" → 1). Lectura mixta, como abajo.
                        bool mixta = false;
                        for (int pi = 0; fromLisp && pi < toks.Length; pi += 2)
                            if (!EsFormaLispLimpia(toks[pi].Trim())) mixta = true;
                        if (mixta)
                        {
                            var sm = new System.Text.StringBuilder(VarHtml(lblM.Groups[1].Value, false));
                            for (int pi = 0; pi < toks.Length; pi += 2)
                            {
                                string sep = pi == 0 ? " = " : toks[pi - 1].Contains("→") ? " → " : toks[pi - 1].Contains("≈") ? " ≈ " : " = ";
                                sm.Append("<span class=\"m-op\">" + sep + "</span>").Append(TramoMixtoHtml(toks[pi].Trim()));
                            }
                            return "<div class=\"ws-eq\">" + sm + "</div>";
                        }
                        var trees = new List<N>();
                        var seps = new List<string>();   // separador ANTES de cada parte (desde la 2ª)
                        for (int pi = 0; pi < toks.Length; pi++)
                        {
                            if (pi % 2 == 0) trees.Add(fromLisp ? ParseLisp(toks[pi].Trim()) : ParseMath(toks[pi].Trim()));
                            else seps.Add(toks[pi].Contains("→") ? " → "
                                        : toks[pi].Contains("≈") ? " ≈ " : " = ");
                        }
                        bool isVec = trees.Count > 0 && trees[0] != null && trees[0].Op == "vec";
                        var sb = new System.Text.StringBuilder(VarHtml(lblM.Groups[1].Value, isVec));
                        for (int ti = 0; ti < trees.Count; ti++)
                        {
                            string sep = ti == 0 ? " = " : seps[ti - 1];
                            sb.Append("<span class=\"m-op\">" + sep + "</span><span class=\"m-expr\">").Append(ToHtml(trees[ti])).Append("</span>");
                        }
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
                        // Salida de un PROGRAMA que mezcla prosa y matemática infija, p. ej.
                        // (format t "Hola. Deriva x^2: ~a = ~a" (infix …) (infix …)). ParseLisp/ParseMath
                        // NO fallan: TRUNCAN en silencio ("Hola. Deriva x^2: x^2" → «Hola.»; "2*x" quedaba
                        // crudo). Solo si algún tramo no es una forma LISP limpia se usa la lectura mixta.
                        bool mixta = fromLisp && System.Array.Exists(partes, p => !EsFormaLispLimpia(p.Trim()));
                        var sb = new System.Text.StringBuilder();
                        for (int pi = 0; pi < partes.Length; pi++)
                        {
                            if (pi > 0) sb.Append("<span class=\"m-op\"> = </span>");
                            if (mixta) { sb.Append(TramoMixtoHtml(partes[pi].Trim())); continue; }
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

        // ¿El tramo es UNA forma LISP entera? Lista balanceada que cierra al final, o un átomo
        // suelto SIN operadores infijos (x, 5, 1/3, -1). "x^2", "2*x" o prosa → no.
        static bool EsFormaLispLimpia(string s)
        {
            if (s.Length == 0) return false;
            if (s[0] == '(')
            {
                int d = 0;
                for (int i = 0; i < s.Length; i++)
                {
                    if (s[i] == '(') d++;
                    else if (s[i] == ')' && --d == 0) return i == s.Length - 1;
                }
                return false;
            }
            return !s.Contains(' ') && !System.Text.RegularExpressions.Regex.IsMatch(s, @"[\^*]|\w[+\-]\w");
        }

        static readonly System.Collections.Generic.HashSet<string> FuncionesMat = new System.Collections.Generic.HashSet<string>(
            new[] { "sin", "cos", "tan", "exp", "log", "ln", "sqrt", "abs", "pi", "asin", "acos", "atan", "sinh", "cosh", "tanh" });

        // ¿Es matemática infija (lo que imprime `infix`) y no prosa? Prosa = puntuación de frase
        // (':' o '. ') o una palabra de 3+ letras que no es función conocida («Deriva», «Hola»).
        static bool EsMatInfija(string s)
        {
            if (s.Length == 0 || s.Contains(':') || s.Contains(". ") || s.EndsWith(".")) return false;
            foreach (System.Text.RegularExpressions.Match w in System.Text.RegularExpressions.Regex.Matches(s, @"[A-Za-zÀ-ÿ]{3,}"))
                if (!FuncionesMat.Contains(w.Value.ToLowerInvariant())) return false;
            return true;
        }

        // Un tramo de una línea mixta: forma LISP → como antes; infija → ParseMath (x² , 2·x);
        // prosa → TEXTO, y lo que va tras el último ':' vuelve a leerse (suele ser la fórmula).
        static string TramoMixtoHtml(string s)
        {
            if (EsFormaLispLimpia(s)) return "<span class=\"m-expr\">" + ToHtml(ParseLisp(s)) + "</span>";
            if (EsMatInfija(s)) return "<span class=\"m-expr\">" + ToHtml(ParseMath(s)) + "</span>";
            int k = s.LastIndexOf(':');
            if (k >= 0 && k < s.Length - 1)
                return "<span class=\"ws-prosa\">" + System.Net.WebUtility.HtmlEncode(RestaurarNombres(s.Substring(0, k + 1))) + "</span>"
                     + TramoMixtoHtml(s.Substring(k + 1).Trim());
            return "<span class=\"ws-prosa\">" + System.Net.WebUtility.HtmlEncode(RestaurarNombres(s)) + "</span>";
        }

        // AUTO-FIT: una ecuación más ancha que la página se ESCALA para caber entera (sin scroll,
        // sin recorte). Antes las matrices anchas (p.ej. J⁻¹ de un quad general) se cortaban y había
        // que usar la barra. Se envuelve el contenido en un span y se le aplica transform:scale.
        const string MAT_JS =
            "<script>(function(){function fit(){document.querySelectorAll('.ws-eq,.deq-body').forEach(function(eq){try{" +
            "if(eq.dataset.fit||eq.classList.contains('ws-deq'))return;var w=eq.clientWidth;if(w<8)return;" +
            "var inner=eq.querySelector(':scope>.ws-fit');if(!inner){inner=document.createElement('span');inner.className='ws-fit';" +
            "inner.style.display='inline-block';inner.style.transformOrigin='left top';while(eq.firstChild)inner.appendChild(eq.firstChild);eq.appendChild(inner);}" +
            "var cw=inner.scrollWidth;if(cw>w+2){var s=w/cw;inner.style.transform='scale('+s+')';eq.style.height=(inner.offsetHeight*s)+'px';eq.style.overflowX='hidden';}" +
            "eq.dataset.fit='1';}catch(e){}});}" +
            "window.addEventListener('load',function(){setTimeout(fit,40);setTimeout(fit,250);});" +
            "if(document.readyState!=='loading')setTimeout(fit,40);})();</script>";

        // ARRASTRAR matrices/vectores grandes: la manija de abajo-derecha cambia cuantas filas y
        // columnas se ven. El HTML ya trae TODAS las celdas en data-hk-cells (ver CeldasJson), asi
        // que aqui solo se vuelve a dibujar la rejilla con el MISMO algoritmo de IndexedGrid.
        // Portado de hekatan-web/hekatan-ui/src/mathcanvas/main.ts (_buildTruncatedMatrixHTML).
        const string HK_MAT_JS = @"<script>(function(){
var arr=null;
function lista(total,vis){var a=[],i;
  if(vis>=total-1){for(i=0;i<total;i++)a.push(i);return a;}
  for(i=0;i<vis;i++)a.push(i); a.push(-1); a.push(total-1); return a;}
function pinta(el){
  var cells=el.__hkCells, nrows=+el.dataset.hkR, ncols=+el.dataset.hkC;
  var visR=+el.dataset.visRows, visC=+el.dataset.visCols, sep=el.dataset.hkSep==='1';
  var cols=lista(ncols,visC), rws=lista(nrows,visR);
  var showCol=ncols>1, showRow=nrows>1;
  var brkCol=showRow?2:1, dataCol0=brkCol+1, brkRCol=dataCol0+cols.length, dataRow0=showCol?2:1;
  var h='',ci,ri;
  if(showCol&&showRow) h+='<span class=""m-mh"" style=""grid-row:1;grid-column:1""></span>';
  if(showCol) for(ci=0;ci<cols.length;ci++)
    h+='<span class=""m-mh"" style=""grid-row:1;grid-column:'+(dataCol0+ci)+'"">'+(cols[ci]<0?'⋯':cols[ci])+'</span>';
  if(showRow) for(ri=0;ri<rws.length;ri++)
    h+='<span class=""m-mrh"" style=""grid-row:'+(dataRow0+ri)+';grid-column:1"">'+(rws[ri]<0?'⋮':rws[ri])+'</span>';
  h+='<span class=""m-brk m-brl"" style=""grid-row:'+dataRow0+' / span '+rws.length+';grid-column:'+brkCol+'""></span>';
  h+='<span class=""m-brk m-brr"" style=""grid-row:'+dataRow0+' / span '+rws.length+';grid-column:'+brkRCol+'""></span>';
  for(ri=0;ri<rws.length;ri++)for(ci=0;ci<cols.length;ci++){
    var r=rws[ri],c=cols[ci];
    var txt=(r<0&&c<0)?'<span class=""m-ell"">⋱</span>':c<0?'<span class=""m-ell"">⋯</span>':
            r<0?'<span class=""m-ell"">⋮</span>':((cells[r]&&cells[r][c]!==undefined)?cells[r][c]:'');
    var bl=(sep&&ci>0)?';border-left:1px solid var(--sep)':'';
    h+='<span class=""m-mc"" style=""grid-row:'+(dataRow0+ri)+';grid-column:'+(dataCol0+ci)+bl+'"">'+txt+'</span>';}
  h+='<span class=""mat-grip"" title=""Arrastrar para ver mas o menos celdas""></span>';
  el.innerHTML=h; manija(el);}
/* El auto-fit encoge TODO el bloque con transform:scale, y con el la manija: en una matriz
   ancha quedaba de 8 px pegada al borde y no habia como agarrarla. Aqui se le aplica la
   escala inversa para que siempre mida lo mismo en pantalla. */
function manija(el){
  var g=el.querySelector('.mat-grip'); if(!g)return;
  var eq=el.closest('.ws-eq,.deq-body'); var inner=eq?eq.querySelector(':scope>.ws-fit'):null;
  var s=1; if(inner&&inner.style.transform){var m=/scale\(([\d.]+)\)/.exec(inner.style.transform); if(m)s=parseFloat(m[1])||1;}
  g.style.transformOrigin='bottom right';
  g.style.transform=(s&&s!==1)?'scale('+(1/s)+')':'';}
function manijas(){document.querySelectorAll('.m-matx[data-hk-cells]').forEach(manija);}
window.addEventListener('load',function(){setTimeout(manijas,120);setTimeout(manijas,420);});
if(document.readyState!=='loading')setTimeout(manijas,120);
function celdas(el){ if(!el.__hkCells){ try{el.__hkCells=JSON.parse(el.dataset.hkCells);}catch(e){return null;} } return el.__hkCells; }
document.addEventListener('mousedown',function(e){
  var g=e.target.closest?e.target.closest('.mat-grip'):null; if(!g)return;
  var el=g.closest('.m-matx'); if(!el||!el.dataset.hkCells)return;
  if(!celdas(el))return;
  e.preventDefault(); e.stopPropagation();
  var cel=el.querySelector('.m-mc'), rc=cel?cel.getBoundingClientRect():null;
  arr={el:el,x:e.clientX,y:e.clientY,r0:+el.dataset.visRows,c0:+el.dataset.visCols,
       w:(rc&&rc.width)||26,h:(rc&&rc.height)||20};
  el.classList.add('mat-resizing');},true);
document.addEventListener('mousemove',function(e){
  if(!arr)return; e.preventDefault();
  var el=arr.el, nrows=+el.dataset.hkR, ncols=+el.dataset.hkC;
  var nr=Math.max(1,Math.min(nrows,arr.r0+Math.round((e.clientY-arr.y)/arr.h)));
  var nc=Math.max(1,Math.min(ncols,arr.c0+Math.round((e.clientX-arr.x)/arr.w)));
  if(nr===+el.dataset.visRows&&nc===+el.dataset.visCols)return;
  el.dataset.visRows=nr; el.dataset.visCols=nc; pinta(el);},true);
document.addEventListener('mouseup',function(){
  if(!arr)return; arr.el.classList.remove('mat-resizing');
  // al crecer la matriz hay que rehacer el auto-fit del bloque, si no se sale de la pagina
  var eq=arr.el.closest('.ws-eq,.deq-body');
  if(eq){var inner=eq.querySelector(':scope>.ws-fit');
    if(inner){inner.style.transform='';eq.style.height='';
      var w=eq.clientWidth,cw=inner.scrollWidth;
      if(cw>w+2){var s=w/cw;inner.style.transform='scale('+s+')';eq.style.height=(inner.offsetHeight*s)+'px';eq.style.overflowX='hidden';}}}
  arr=null;},true);
})();</script>";

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
<tr><td><code>P = 35 [kN]</code> · <code>w = P/k [mm]</code></td><td>unidad VISIBLE: entre corchetes al final de la línea; se dibuja pegada al número (dato o resultado) sin perder la fórmula. Solo dibujo: no convierte ni comprueba dimensiones. <code>^3</code>→³, <code>*</code>→·</td></tr>
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
                // max/min de DOS argumentos (curvas por tramos: la placa base, Y ≥ m o Y < m)
                if ((n.Atom == "max" || n.Atom == "min") && n.Items != null && n.Items.Count == 2)
                {
                    double b2 = Eval(n.Items[1], var, x);
                    return n.Atom == "max" ? Math.Max(a, b2) : Math.Min(a, b2);
                }
                return n.Atom switch
                {
                    "sqrt" => Math.Sqrt(a), "sin" => Math.Sin(a), "cos" => Math.Cos(a), "tan" => Math.Tan(a),
                    "exp" => Math.Exp(a), "log" => Math.Log(a), "abs" => Math.Abs(a),
                    "floor" => Math.Floor(a + 1e-12), "ceil" => Math.Ceiling(a - 1e-12), "round" => Math.Round(a),
                    "sign" => Math.Sign(a), "sinh" => Math.Sinh(a), "cosh" => Math.Cosh(a), "tanh" => Math.Tanh(a),
                    _ => double.NaN
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

        // Texto libre (prosa de un programa, leyendas): los nombres que el motor recibió renombrados
        // por choque de mayúsculas (DEFINICION → definicionhkq3) vuelven a como se escribieron.
        static string RestaurarNombres(string s)
        {
            if (string.IsNullOrEmpty(s) || CaseMap.Count == 0) return s;
            return RxIdent.Replace(s, m => m.Value.Contains(MangleTag) && CaseMap.TryGetValue(m.Value.ToLowerInvariant(), out var o) ? o : m.Value);
        }

        // etiqueta bonita para la leyenda del plot:  3*x^2-2*x^3 → 3·x²−2·x³  (·, superíndices, − real)
        static string PrettyLabel(string s)
        {
            if (string.IsNullOrEmpty(s)) return s ?? "";
            const string sup = "⁰¹²³⁴⁵⁶⁷⁸⁹", sub = "₀₁₂₃₄₅₆₇₈₉";
            // nombres renombrados por choque (fhkq1) → como se escribieron (F)
            s = RestaurarNombres(s);
            // griegas por su nombre (palabra entera): el eje salía «xi» y no «ξ»
            s = Regex.Replace(s, @"\b(xi|eta|zeta|theta|phi|psi|alpha|beta|gamma|delta|epsilon|sigma|tau|omega|lambda|mu|nu|rho)\b",
                m => m.Value switch
                {
                    "xi" => "ξ", "eta" => "η", "zeta" => "ζ", "theta" => "θ", "phi" => "φ", "psi" => "ψ",
                    "alpha" => "α", "beta" => "β", "gamma" => "γ", "delta" => "δ", "epsilon" => "ε",
                    "sigma" => "σ", "tau" => "τ", "omega" => "ω", "lambda" => "λ", "mu" => "μ", "nu" => "ν", _ => "ρ"
                });
            var o = new StringBuilder();
            for (int i = 0; i < s.Length; i++)
            {
                char c = s[i];
                if (c == '*') o.Append('·');
                else if (c == '-') o.Append('−');
                else if (c == '^' || (c == '_' && i + 1 < s.Length && char.IsDigit(s[i + 1])))
                {
                    string tabla = c == '^' ? sup : sub;   // N_1 → N₁ (la leyenda salía «N_1»)
                    i++;
                    while (i < s.Length && char.IsDigit(s[i])) { o.Append(tabla[s[i] - '0']); i++; }
                    i--;
                }
                else o.Append(c);
            }
            return o.ToString();
        }

        // ---------- grafica SVG de una o varias funciones f(var) sobre [lo,hi] ----------
        public static string PlotSvg(string var, double lo, double hi, List<(string name, N tree)> fns,
                                     List<(string name, double[] xs, double[] ys)> dots = null)
        {
            dots ??= new List<(string name, double[] xs, double[] ys)>();
            fns ??= new List<(string name, N tree)>();
            if ((fns.Count == 0 && dots.Count == 0) || hi <= lo) return "";
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
            // PUNTOS sueltos (datos: resultados de SAP2000, ensayos...) también entran en el rango Y
            foreach (var d in dots)
                for (int k = 0; k < d.ys.Length; k++)
                    if (!double.IsNaN(d.ys[k]) && !double.IsInfinity(d.ys[k])) { ymin = Math.Min(ymin, d.ys[k]); ymax = Math.Max(ymax, d.ys[k]); }
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
              .Append("\" xmlns=\"http://www.w3.org/2000/svg\" font-family=\"'Segoe UI',Arial,sans-serif\" style=\"width:100%;max-width:540px;height:auto;display:block;margin:0 auto\">");
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
            sb.Append("<text x=\"").Append((pL + W - pR) / 2).Append("\" y=\"").Append(H - 6).Append("\" fill=\"var(--fg)\" font-size=\"12\" font-style=\"italic\" text-anchor=\"middle\">").Append(System.Net.WebUtility.HtmlEncode(PrettyLabel(var))).Append("</text>");
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
            for (int d = 0; d < dots.Count; d++)
            {
                string col = PlotColors[(series.Count + d) % PlotColors.Length];
                var (_, dxs, dys) = dots[d];
                for (int k = 0; k < dxs.Length; k++)
                {
                    if (double.IsNaN(dys[k]) || dxs[k] < lo || dxs[k] > hi) continue;
                    sb.Append("<circle cx=\"").Append(Num(SX(dxs[k]))).Append("\" cy=\"").Append(Num(SY(dys[k])))
                      .Append("\" r=\"4.5\" fill=\"").Append(col).Append("\" stroke=\"var(--bg)\" stroke-width=\"1.2\"><title>(")
                      .Append(Num(dxs[k])).Append("; ").Append(Num(dys[k])).Append(")</title></circle>");
                }
            }
            // leyenda en CAJA, arriba-derecha DENTRO de los ejes. Ancho SEGÚN la etiqueta más larga
            // (antes era fijo 78 y el texto se salía del cuadro) y etiquetas BONITAS (·, superíndices).
            var pretty = series.ConvertAll(se => PrettyLabel(se.name));
            foreach (var d in dots) pretty.Add(PrettyLabel(d.name));
            int llen = 0; foreach (var p in pretty) llen = Math.Max(llen, p.Length);
            int lw = 40 + llen * 7, lh = 8 + pretty.Count * 17;
            int lx = W - pR - lw - 6; if (lx < pL + 4) lx = pL + 4;
            int lyTop = pT + 8;
            sb.Append("<rect x=\"").Append(lx).Append("\" y=\"").Append(lyTop).Append("\" width=\"").Append(lw).Append("\" height=\"").Append(lh)
              .Append("\" fill=\"var(--bg)\" fill-opacity=\".9\" stroke=\"var(--mut)\" stroke-width=\"1\"/>");
            for (int s = 0; s < pretty.Count; s++)
            {
                int ly = lyTop + 14 + s * 17; string col = PlotColors[s % PlotColors.Length];
                if (s >= series.Count)   // punto: marcador circular
                    sb.Append("<circle cx=\"").Append(lx + 17).Append("\" cy=\"").Append(ly).Append("\" r=\"4.5\" fill=\"").Append(col).Append("\"/>");
                else
                sb.Append("<line x1=\"").Append(lx + 8).Append("\" y1=\"").Append(ly).Append("\" x2=\"").Append(lx + 26).Append("\" y2=\"").Append(ly).Append("\" stroke=\"").Append(col).Append("\" stroke-width=\"2.5\"/>");
                sb.Append("<text x=\"").Append(lx + 32).Append("\" y=\"").Append(ly + 4).Append("\" fill=\"var(--fg)\" font-size=\"12\" font-style=\"italic\">").Append(System.Net.WebUtility.HtmlEncode(pretty[s])).Append("</text>");
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
                   "</style></head><body>" + body + MAT_JS + HK_MAT_JS + "</body></html>";
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
