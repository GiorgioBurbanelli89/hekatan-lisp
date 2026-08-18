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

        static bool IsNum(string s) => Regex.IsMatch(s, @"^[\d.]");
        static int Prec(string op) => op switch { "^" => 4, "*" or "/" => 2, "+" or "-" => 1, _ => 0 };

        // ---------- parse: MATEMATICA -> arbol ----------
        static readonly Regex Tok = new Regex(@"\d+\.?\d*|[A-Za-z_]\w*|[-+*/^(),;\[\]]");

        public static N ParseMath(string s)
        {
            var toks = new List<string>();
            foreach (Match m in Tok.Matches(s)) toks.Add(m.Value);
            if (toks.Count == 0) return null;
            var p = new MP(toks);
            return p.Expr();
        }

        class MP
        {
            readonly List<string> t; int i;
            public MP(List<string> toks) { t = toks; }
            string Peek() => i < t.Count ? t[i] : null;
            string Eat() => t[i++];
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
                var n = Base();
                if (Peek() == "^") { Eat(); n = N.Make("^", n, Factor()); }
                return n;
            }
            N Base()
            {
                var t0 = Peek();
                if (t0 == "(") { Eat(); var n = Expr(); if (Peek() == ")") Eat(); return n; }
                if (t0 == "[") return VecMat();
                if (t0 == "-") { Eat(); return N.Make("neg", Base()); }
                if (t0 == null) throw new Exception("fin inesperado");
                var id = Eat();
                // función: identificador (letra) seguido de '('
                if (id.Length > 0 && (char.IsLetter(id[0]) || id[0] == '_') && Peek() == "(")
                {
                    Eat();  // '('
                    var args = new List<N>();
                    if (Peek() != ")") { args.Add(Expr()); while (Peek() == ",") { Eat(); args.Add(Expr()); } }
                    if (Peek() == ")") Eat();
                    return new N { Op = "fn", Atom = id, Items = args };
                }
                return N.Leaf(id);
            }
            N VecMat()
            {
                Eat();  // '['
                var rows = new List<List<N>>();
                var cur = new List<N>();
                while (Peek() != "]" && Peek() != null)
                {
                    if (Peek() == ";") { Eat(); rows.Add(cur); cur = new List<N>(); continue; }
                    if (Peek() == ",") { Eat(); continue; }
                    cur.Add(Expr());   // cada elemento es una expresión
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

        static N ReadLisp(List<string> toks, ref int i)
        {
            var t = toks[i++];
            if (t != "(") return N.Leaf(t);
            var op = toks[i++];
            var args = new List<N>();
            while (i < toks.Count && toks[i] != ")") args.Add(ReadLisp(toks, ref i));
            if (i < toks.Count) i++;   // descarta ')'

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

        // ---------- render: arbol -> LISP ----------
        public static string ToLisp(N n)
        {
            if (n == null) return "";
            if (n.IsAtom) return n.Atom;
            if (n.Op == "neg") return "(- " + ToLisp(n.A) + ")";
            if (n.Op == "fn") return "(" + n.Atom + " " + string.Join(" ", n.Items.Select(ToLisp)) + ")";
            if (n.Op == "vec" || n.Op == "mat") return "(vector " + string.Join(" ", n.Items.Select(ToLisp)) + ")";
            var o = n.Op == "^" ? "expt" : n.Op;
            return "(" + o + " " + ToLisp(n.A) + " " + ToLisp(n.B) + ")";
        }

        // ---------- render: arbol -> MATLAB (texto) ----------
        public static string ToLab(N n, int outer = 0)
        {
            if (n == null) return "";
            if (n.IsAtom) return n.Atom;
            if (n.Op == "neg") return "-" + ToLab(n.A, 3);
            if (n.Op == "fn") return n.Atom + "(" + string.Join(", ", n.Items.Select(x => ToLab(x, 0))) + ")";
            if (n.Op == "vec") return "[" + string.Join(" ", n.Items.Select(x => ToLab(x, 0))) + "]";
            if (n.Op == "mat")
                return "[" + string.Join("; ", n.Items.Select(r => string.Join(" ", r.Items.Select(x => ToLab(x, 0))))) + "]";
            int p = Prec(n.Op);
            string sep = n.Op switch { "+" => " + ", "-" => " - ", "*" => "*", "/" => "/", "^" => "^", _ => n.Op };
            string s = ToLab(n.A, p) + sep + ToLab(n.B, p);
            return p < outer ? "(" + s + ")" : s;
        }

        // ---------- render: arbol -> HTML matematico (estilo Hekatan Lab) ----------
        static string Paren(string s) => "<span class=\"m-op\">(</span>" + s + "<span class=\"m-op\">)</span>";

        public static string ToHtml(N n, int parentPrec = 0)
        {
            if (n == null) return "";
            if (n.IsAtom)
                return IsNum(n.Atom) ? $"<span class=\"m-num\">{n.Atom}</span>"
                                     : $"<span class=\"m-var\">{n.Atom}</span>";
            if (n.Op == "neg")
            {
                var r = "<span class=\"m-op\">−</span>" + ToHtml(n.A, 3);
                return parentPrec > 3 ? Paren(r) : r;
            }
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
                default:
                    var args = string.Join("<span class=\"m-op\">, </span>", n.Items.Select(x => ToHtml(x, 0)));
                    return "<span class=\"m-fn\">" + name + "</span>" + Paren(args);
            }
        }

        // vector/matriz: cuadrícula con corchetes grandes
        static string GridHtml(List<List<N>> rows)
        {
            int ncols = rows.Count == 0 ? 0 : rows.Max(r => r.Count);
            var cells = new StringBuilder();
            foreach (var row in rows)
                foreach (var cell in row)
                    cells.Append("<span class=\"m-cell\">").Append(ToHtml(cell, 0)).Append("</span>");
            return "<span class=\"m-mat\"><span class=\"m-brk m-brl\"></span>" +
                   "<span class=\"m-mgrid\" style=\"grid-template-columns:repeat(" + ncols + ",auto)\">" +
                   cells + "</span><span class=\"m-brk m-brr\"></span></span>";
        }

        // ---------- pagina HTML completa (worksheet, tema oscuro) ----------
        const string CSS = @"
:root{--bg:#14161a;--fg:#e8e8e8;--mut:#9aa0a6;--var:#8ab4f8;--num:#9ecbff;}
*{box-sizing:border-box;}
body{margin:0;padding:10px 1.5em;background:var(--bg);color:var(--fg);
  font-family:'Segoe UI','Arial Nova',Helvetica,sans-serif;font-size:11pt;line-height:150%;}
.ws-eq{margin:0.4em 0;
  font-family:'Georgia Pro','Century Schoolbook','Times New Roman',Times,serif;font-size:11.5pt;}
.m-var{font-style:italic;color:var(--var);} .m-num{color:var(--num);}
.m-op{color:var(--mut);padding:0 .08em;}
.m-fn{font-style:normal;color:var(--fg);padding-right:.05em;}
.m-frac{display:inline-flex;flex-direction:column;vertical-align:middle;text-align:center;margin:0 .15em;}
.m-frn{border-bottom:1px solid currentColor;padding:0 .35em;}
.m-frd{padding:0 .35em;}
.m-sup{font-size:.70em;vertical-align:super;line-height:0;}
.m-sqrt{display:inline-flex;align-items:flex-start;}
.m-rad{font-size:1.05em;}
.m-radarg{border-top:1.2px solid currentColor;padding:0 .2em;margin-left:-.05em;}
.m-mat{display:inline-flex;align-items:stretch;vertical-align:middle;margin:0 .2em;}
.m-brk{width:.32em;}
.m-brl{border:1.4px solid currentColor;border-right:none;}
.m-brr{border:1.4px solid currentColor;border-left:none;}
.m-mgrid{display:inline-grid;padding:.15em .35em;gap:.15em .7em;text-align:center;align-items:center;}
.m-cell{color:var(--num);}";

        public static string RenderPage(string text, bool fromLisp)
        {
            var body = new StringBuilder();
            foreach (var raw in text.Replace("\r", "").Split('\n'))
            {
                var line = raw.Trim();
                if (line.Length == 0) continue;
                string prefix = "";
                var expr = line;
                if (line.StartsWith("= ") || line.StartsWith("→ ")) { prefix = line.Substring(0, 2); expr = line.Substring(2).Trim(); }
                string html;
                try
                {
                    var tree = fromLisp ? ParseLisp(expr) : ParseMath(expr);
                    html = "<span class=\"m-expr\">" + ToHtml(tree) + "</span>";
                    if (prefix.Length > 0)
                        html = "<span class=\"m-op\">" + System.Net.WebUtility.HtmlEncode(prefix) + "</span>" + html;
                }
                catch { html = System.Net.WebUtility.HtmlEncode(line); }
                body.Append("<div class=\"ws-eq\">").Append(html).Append("</div>");
            }
            return "<!doctype html><html><head><meta charset=\"utf-8\"><style>" + CSS +
                   "</style></head><body>" + body + "</body></html>";
        }

        // ---------- atajos por linea (para los modos de TEXTO) ----------
        public static string MathToLisp(string line) => ToLisp(ParseMath(line));
        public static string LispToLab(string line) => ToLab(ParseLisp(line), 0);
    }
}
