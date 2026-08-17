using System;
using System.Collections.Generic;
using System.Text;
using System.Text.RegularExpressions;

namespace HekatanLisp
{
    /// <summary>
    /// Convertidor con ARBOL (parser propio, sin CAS). Desde el mismo arbol produce:
    ///   - LISP:   (+ (expt x 2) (* 3 x))
    ///   - MATLAB: x^2 + 3*x                (script, ANTES de renderizar)
    ///   - HTML:   x² + 3·x  con fraccion/superindice (estilo Hekatan Lab, render)
    /// </summary>
    public static class LispConverter
    {
        // ---------- arbol ----------
        public class N
        {
            public string Op;    // + - * / ^ neg  | null = atomo
            public string Atom;
            public N A, B;
            public bool IsAtom => Op == null;
            public static N Leaf(string s) => new N { Atom = s };
            public static N Make(string op, N a, N b = null) => new N { Op = op, A = a, B = b };
        }

        static bool IsNum(string s) => Regex.IsMatch(s, @"^\d");
        static int Prec(string op) => op switch { "^" => 4, "*" or "/" => 2, "+" or "-" => 1, _ => 0 };

        // ---------- parse: MATEMATICA -> arbol ----------
        static readonly Regex Tok = new Regex(@"\d+\.?\d*|[A-Za-z_]\w*|[-+*/^()]");

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
                if (t0 == "(") { Eat(); var n = Expr(); Eat(); return n; }
                if (t0 == "-") { Eat(); return N.Make("neg", Base()); }
                if (t0 == null) throw new Exception("fin inesperado");
                return N.Leaf(Eat());
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

        static N ReadLisp(List<string> toks, ref int i)
        {
            var t = toks[i++];
            if (t != "(") return N.Leaf(t);
            var op = toks[i++];                       // operador
            var args = new List<N>();
            while (toks[i] != ")") args.Add(ReadLisp(toks, ref i));
            i++;                                       // descarta ')'
            var o = op == "expt" ? "^" : op;
            if (args.Count == 1) return o == "-" ? N.Make("neg", args[0]) : args[0];
            var acc = args[0];
            for (int k = 1; k < args.Count; k++) acc = N.Make(o, acc, args[k]);  // n-ario -> binario izq
            return acc;
        }

        // ---------- render: arbol -> LISP ----------
        public static string ToLisp(N n)
        {
            if (n == null) return "";
            if (n.IsAtom) return n.Atom;
            if (n.Op == "neg") return "(- " + ToLisp(n.A) + ")";
            var o = n.Op == "^" ? "expt" : n.Op;
            return "(" + o + " " + ToLisp(n.A) + " " + ToLisp(n.B) + ")";
        }

        // ---------- render: arbol -> MATLAB (texto) ----------
        public static string ToLab(N n, int outer = 0)
        {
            if (n == null) return "";
            if (n.IsAtom) return n.Atom;
            if (n.Op == "neg") return "-" + ToLab(n.A, 3);
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

        // ---------- pagina HTML completa (worksheet, tema oscuro) ----------
        // CSS calcado del worksheet de Hekatan Lab (Symbolic.Server/Core/template.html):
        // body 11pt, math en <var> 11.5pt serif Georgia/Times, párrafos margin 0.3em,
        // line-height 150%, sin caja: es un documento, no una tarjeta.
        const string CSS = @"
:root{--bg:#14161a;--fg:#e8e8e8;--mut:#9aa0a6;--var:#8ab4f8;--num:#9ecbff;}
*{box-sizing:border-box;}
body{margin:0;padding:10px 1.5em;background:var(--bg);color:var(--fg);
  font-family:'Segoe UI','Arial Nova',Helvetica,sans-serif;font-size:11pt;line-height:150%;}
.ws-eq{margin:0.3em 0;
  font-family:'Georgia Pro','Century Schoolbook','Times New Roman',Times,serif;font-size:11.5pt;}
.m-var{font-style:italic;color:var(--var);} .m-num{color:var(--num);}
.m-op{color:var(--mut);padding:0 .08em;}
.m-frac{display:inline-flex;flex-direction:column;vertical-align:middle;text-align:center;margin:0 .15em;}
.m-frn{border-bottom:1px solid currentColor;padding:0 .35em;}
.m-frd{padding:0 .35em;}
.m-sup{font-size:.70em;vertical-align:super;line-height:0;}";

        /// <summary>Convierte cada linea (math o lisp) y arma la pagina HTML renderizada.</summary>
        public static string RenderPage(string text, bool fromLisp)
        {
            var body = new StringBuilder();
            foreach (var raw in text.Replace("\r", "").Split('\n'))
            {
                var line = raw.Trim();
                if (line.Length == 0) continue;
                string html;
                try
                {
                    var tree = fromLisp ? ParseLisp(line) : ParseMath(line);
                    html = "<span class=\"m-expr\">" + ToHtml(tree) + "</span>";
                }
                catch { html = "<span class=\"m-op\">…</span>"; }
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
