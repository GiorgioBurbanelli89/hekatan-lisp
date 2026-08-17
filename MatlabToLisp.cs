using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Text.RegularExpressions;

namespace HekatanLisp
{
    /// <summary>
    /// Traductor de un mini-MATLAB (la "matemática" que Jorge YA conoce) a LISP.
    /// El "por qué": Jorge piensa en MATLAB (for i=1:n, s=s+i, [1 2 3], function y=f(x)),
    /// pero SIN nombres de funciones de MATLAB — las operaciones se escriben con el loop,
    /// que es justo la filosofía de LISP (tú construyes la función). Un botón lo pasa a LISP.
    ///
    /// Soporta:  asignaciones (s = expr)     -> (setf s expr)
    ///           for i = a:b [ :c ]          -> (loop for i from a to b [by c] do ...)
    ///           for x = [ .. ]              -> (loop for x across (vector ..) do ...)
    ///           while cond                  -> (loop while cond do ...)
    ///           if / elseif / else / end    -> (cond (c ..) (t ..))
    ///           function y = f(a,b) .. end  -> (defun f (a b) (let* (..) .. y))
    ///           expresiones: + - * / ^, comparaciones, f(x), vectores [..], matrices [..;..]
    /// </summary>
    public static class MatlabToLisp
    {
        public sealed class Result { public string Lisp = ""; public string Executable = ""; }

        // ¿El texto es un PROGRAMA (loops/funciones/asignaciones) y no solo una expresión?
        public static bool IsImperative(string text)
        {
            if (string.IsNullOrWhiteSpace(text)) return false;
            if (Regex.IsMatch(text, @"(^|\n)\s*(for|while|if|function)\b")) return true;
            // una asignación 'v = ...' (pero no comparación ==, <=, >=, ~=)
            return Regex.IsMatch(text, @"(^|\n)\s*[A-Za-z_]\w*\s*=(?![=])");
        }

        // ---------- statements ----------
        private sealed class Stmt { public string Kind; public string Lisp; public string Lhs; }

        private sealed class Scope
        {
            public readonly List<string> Vars = new();     // variables a declarar en el let*
            public readonly HashSet<string> Seen = new();
            public readonly HashSet<string> Bound = new();  // contadores de loop y parámetros
            public void Declare(string v)
            {
                if (!Bound.Contains(v) && Seen.Add(v)) Vars.Add(v);
            }
        }

        public static Result Translate(string program)
        {
            var lines = Clean(program);
            int i = 0;
            var funcs = new List<string>();
            var main = new List<Stmt>();
            var scope = new Scope();

            while (i < lines.Count)
            {
                var line = lines[i].Trim();
                if (line.Length == 0) { i++; continue; }
                if (Kw(line) == "function") funcs.Add(ParseFunction(lines, ref i));
                else main.Add(ParseStatement(lines, ref i, scope));
            }

            // cuerpo principal
            string bodyDisplay, bodyExec;
            BuildMain(scope, main, out bodyDisplay, out bodyExec);

            var disp = new StringBuilder();
            foreach (var f in funcs) disp.Append(f).Append("\n\n");
            if (!string.IsNullOrEmpty(bodyDisplay)) disp.Append(bodyDisplay);

            var exec = new StringBuilder();
            exec.Append("(defun range (a b) (loop for i from a to b collect i))\n");
            exec.Append("(defun range3 (a s b) (loop for i from a to b by s collect i))\n");
            foreach (var f in funcs) exec.Append(f).Append("\n");
            if (!string.IsNullOrEmpty(bodyExec)) exec.Append(bodyExec).Append("\n");

            return new Result { Lisp = disp.ToString().TrimEnd(), Executable = exec.ToString() };
        }

        // arma el (let* ...) principal y su versión que IMPRIME el resultado
        private static void BuildMain(Scope sc, List<Stmt> main, out string display, out string exec)
        {
            display = ""; exec = "";
            if (main.Count == 0) return;

            var forms = main.Select(s => s.Lisp).ToList();
            var last = main[main.Count - 1];

            // valor de retorno: última expresión suelta, o la variable recién asignada
            string result = null;
            if (last.Kind == "expr") result = last.Lisp;
            else if (last.Kind == "assign") { result = last.Lhs; forms.Add(last.Lhs); }

            string body;
            if (sc.Vars.Count > 0)
            {
                var decls = string.Join(" ", sc.Vars.Select(v => $"({v} 0)"));
                body = "(let* (" + decls + ")\n" + Indent(forms, 1) + ")";
            }
            else body = forms.Count == 1 ? forms[0] : "(progn\n" + Indent(forms, 1) + ")";

            display = body;
            exec = result != null ? "(format t \"~a~%\" " + body + ")" : body;
        }

        private static string ParseFunction(List<string> lines, ref int i)
        {
            var header = lines[i].Trim(); i++;
            var m = Regex.Match(header,
                @"^function\s+(?:(?<ret>[A-Za-z_]\w*)\s*=\s*)?(?<name>[A-Za-z_]\w*)\s*\((?<args>[^)]*)\)");
            string ret = m.Groups["ret"].Success ? m.Groups["ret"].Value : null;
            string name = m.Groups["name"].Success ? m.Groups["name"].Value : "f";
            var args = m.Groups["args"].Value.Split(',')
                        .Select(a => a.Trim()).Where(a => a.Length > 0).ToList();

            var sc = new Scope();
            foreach (var a in args) sc.Bound.Add(a);
            var body = ParseBody(lines, ref i, StopEnd, sc);
            ConsumeEnd(lines, ref i);

            var forms = body.Select(s => s.Lisp).ToList();
            if (ret != null) { sc.Declare(ret); forms.Add(ret); }   // el valor de retorno

            var sb = new StringBuilder();
            sb.Append("(defun ").Append(name).Append(" (").Append(string.Join(" ", args)).Append(")\n");
            if (sc.Vars.Count > 0)
            {
                var decls = string.Join(" ", sc.Vars.Select(v => $"({v} 0)"));
                sb.Append("  (let* (").Append(decls).Append(")\n").Append(Indent(forms, 2)).Append("))");
            }
            else sb.Append(Indent(forms, 1)).Append(")");
            return sb.ToString();
        }

        private static readonly HashSet<string> StopEnd = new() { "end" };
        private static readonly HashSet<string> StopIf = new() { "elseif", "else", "end" };

        private static List<Stmt> ParseBody(List<string> lines, ref int i, HashSet<string> stops, Scope sc)
        {
            var res = new List<Stmt>();
            while (i < lines.Count)
            {
                var line = lines[i].Trim();
                if (line.Length == 0) { i++; continue; }
                if (stops.Contains(Kw(line))) break;
                res.Add(ParseStatement(lines, ref i, sc));
            }
            return res;
        }

        private static Stmt ParseStatement(List<string> lines, ref int i, Scope sc)
        {
            var line = lines[i].Trim();
            var kw = Kw(line);

            if (kw == "for")
            {
                i++;
                var m = Regex.Match(line, @"^for\s+(?<v>[A-Za-z_]\w*)\s*=\s*(?<r>.+)$");
                var v = m.Groups["v"].Value;
                sc.Bound.Add(v);
                var body = ParseBody(lines, ref i, StopEnd, sc);
                ConsumeEnd(lines, ref i);
                var head = ForHead(v, m.Groups["r"].Value);
                return new Stmt { Kind = "loop", Lisp = head + " do\n" + Indent(body, 1) + ")" };
            }
            if (kw == "while")
            {
                i++;
                var cond = ExprToLisp(line.Substring(5).Trim());
                var body = ParseBody(lines, ref i, StopEnd, sc);
                ConsumeEnd(lines, ref i);
                return new Stmt { Kind = "while", Lisp = "(loop while " + cond + " do\n" + Indent(body, 1) + ")" };
            }
            if (kw == "if")
            {
                i++;
                var clauses = new List<(string cond, List<Stmt> body)>();
                clauses.Add((ExprToLisp(line.Substring(2).Trim()), ParseBody(lines, ref i, StopIf, sc)));
                while (i < lines.Count)
                {
                    var l2 = lines[i].Trim(); var k2 = Kw(l2);
                    if (k2 == "elseif")
                    { i++; clauses.Add((ExprToLisp(l2.Substring(6).Trim()), ParseBody(lines, ref i, StopIf, sc))); }
                    else if (k2 == "else")
                    { i++; clauses.Add(("t", ParseBody(lines, ref i, StopEnd, sc))); break; }
                    else break;
                }
                ConsumeEnd(lines, ref i);
                var sb = new StringBuilder("(cond\n");
                foreach (var (c, b) in clauses)
                    sb.Append(Ind(1)).Append("(").Append(c).Append("\n").Append(Indent(b, 2)).Append(")\n");
                sb.Append(Ind(0)).Append(")");
                return new Stmt { Kind = "cond", Lisp = sb.ToString() };
            }

            // asignación  v = expr   (no comparación)
            var a = Regex.Match(line, @"^(?<lhs>[A-Za-z_]\w*)\s*=(?![=])\s*(?<rhs>.+)$");
            if (a.Success)
            {
                i++;
                var lhs = a.Groups["lhs"].Value;
                sc.Declare(lhs);
                return new Stmt { Kind = "assign", Lhs = lhs, Lisp = "(setf " + lhs + " " + ExprToLisp(a.Groups["rhs"].Value) + ")" };
            }

            // expresión suelta (posible resultado)
            i++;
            return new Stmt { Kind = "expr", Lisp = ExprToLisp(line) };
        }

        // for i = a:b  |  a:s:b  |  [vector]
        private static string ForHead(string v, string range)
        {
            var parts = SplitTop(range, ':');
            if (parts.Count == 2)
                return $"(loop for {v} from {ExprToLisp(parts[0])} to {ExprToLisp(parts[1])}";
            if (parts.Count == 3)
                return $"(loop for {v} from {ExprToLisp(parts[0])} to {ExprToLisp(parts[2])} by {ExprToLisp(parts[1])}";
            // sin ':' -> iterar una secuencia (vector)
            return $"(loop for {v} across {ExprToLisp(range)}";
        }

        // ---------- expresiones (parser por caracteres, produce LISP) ----------
        public static string ExprToLisp(string expr)
        {
            var e = new Ex(expr);
            var r = e.ParseFull();
            return r;
        }

        private sealed class Ex
        {
            private readonly string s; private int i;
            public Ex(string str) { s = str ?? ""; }
            private char P => i < s.Length ? s[i] : '\0';
            private void Ws() { while (i < s.Length && char.IsWhiteSpace(s[i])) i++; }
            private bool Is(char c) { Ws(); return P == c; }
            private bool Eat(char c) { Ws(); if (P == c) { i++; return true; } return false; }

            public string ParseFull() { var r = Cmp(); return r; }

            private string Cmp()
            {
                var a = Add();
                while (true)
                {
                    Ws();
                    string op = null;
                    if (P == '<' && Nx() == '=') { op = "<="; i += 2; }
                    else if (P == '>' && Nx() == '=') { op = ">="; i += 2; }
                    else if (P == '=' && Nx() == '=') { op = "="; i += 2; }
                    else if (P == '~' && Nx() == '=') { op = "/="; i += 2; }
                    else if (P == '<') { op = "<"; i++; }
                    else if (P == '>') { op = ">"; i++; }
                    else break;
                    a = "(" + op + " " + a + " " + Add() + ")";
                }
                return a;
            }
            private char Nx() => (i + 1) < s.Length ? s[i + 1] : '\0';

            private string Add()
            {
                var a = Mul();
                while (true)
                {
                    Ws();
                    if (P == '+') { i++; a = "(+ " + a + " " + Mul() + ")"; }
                    else if (P == '-') { i++; a = "(- " + a + " " + Mul() + ")"; }
                    else break;
                }
                return a;
            }
            private string Mul()
            {
                var a = Pow();
                while (true)
                {
                    Ws();
                    if (P == '*') { i++; a = "(* " + a + " " + Pow() + ")"; }
                    else if (P == '/') { i++; a = "(/ " + a + " " + Pow() + ")"; }
                    else break;
                }
                return a;
            }
            private string Pow()
            {
                var a = Unary();
                Ws();
                if (P == '^') { i++; return "(expt " + a + " " + Pow() + ")"; }   // asociativo a la derecha
                return a;
            }
            private string Unary()
            {
                Ws();
                if (P == '-') { i++; return "(- " + Unary() + ")"; }
                if (P == '+') { i++; return Unary(); }
                return Primary();
            }
            private string Primary()
            {
                Ws();
                if (P == '(') { i++; var r = Cmp(); Eat(')'); return r; }
                if (P == '[') return Vector();
                if (char.IsDigit(P) || (P == '.' && char.IsDigit(Nx()))) return Number();
                if (char.IsLetter(P) || P == '_') return IdentOrCall();
                if (P != '\0') i++;   // carácter raro: sáltalo
                return "0";
            }
            private string Number()
            {
                int st = i;
                while (i < s.Length && (char.IsDigit(s[i]) || s[i] == '.')) i++;
                // notación científica 1e-3
                if (i < s.Length && (s[i] == 'e' || s[i] == 'E'))
                {
                    i++;
                    if (i < s.Length && (s[i] == '+' || s[i] == '-')) i++;
                    while (i < s.Length && char.IsDigit(s[i])) i++;
                }
                return s.Substring(st, i - st);
            }
            private string IdentOrCall()
            {
                int st = i;
                while (i < s.Length && (char.IsLetterOrDigit(s[i]) || s[i] == '_')) i++;
                var id = s.Substring(st, i - st);
                Ws();
                if (P == '(')
                {
                    i++;
                    var args = new List<string>();
                    Ws();
                    if (P != ')')
                    {
                        args.Add(Cmp());
                        while (Eat(',')) args.Add(Cmp());
                    }
                    Eat(')');
                    return args.Count == 0 ? "(" + id + ")" : "(" + id + " " + string.Join(" ", args) + ")";
                }
                return id;
            }
            private string Vector()
            {
                Eat('[');
                var rows = new List<List<string>>();
                var cur = new List<string>();
                while (true)
                {
                    Ws();
                    if (P == ']' || P == '\0') { i++; break; }
                    if (P == ';') { i++; rows.Add(cur); cur = new List<string>(); continue; }
                    if (P == ',') { i++; continue; }
                    cur.Add(Add());   // elemento (sin comparaciones dentro)
                }
                rows.Add(cur);
                if (rows.Count == 1) return "(vector " + string.Join(" ", rows[0]) + ")";
                return "(vector " + string.Join(" ", rows.Select(r => "(vector " + string.Join(" ", r) + ")")) + ")";
            }
        }

        // ---------- utilidades ----------
        private static List<string> Clean(string program)
        {
            var res = new List<string>();
            foreach (var raw in (program ?? "").Replace("\r", "").Split('\n'))
            {
                var t = raw;
                int c = t.IndexOf('%');           // comentario MATLAB
                if (c >= 0) t = t.Substring(0, c);
                res.Add(t.TrimEnd());
            }
            return res;
        }

        private static string Kw(string line)
        {
            var m = Regex.Match(line, @"^(for|while|if|elseif|else|end|function)\b");
            return m.Success ? m.Groups[1].Value : "";
        }

        private static void ConsumeEnd(List<string> lines, ref int i)
        {
            if (i < lines.Count && Kw(lines[i].Trim()) == "end") i++;
        }

        // parte 'a:b:c' en el nivel superior (respeta paréntesis y corchetes)
        private static List<string> SplitTop(string s, char sep)
        {
            var res = new List<string>(); var sb = new StringBuilder(); int depth = 0;
            foreach (var c in s)
            {
                if (c == '(' || c == '[') depth++;
                else if (c == ')' || c == ']') depth--;
                if (c == sep && depth == 0) { res.Add(sb.ToString()); sb.Clear(); }
                else sb.Append(c);
            }
            res.Add(sb.ToString());
            return res;
        }

        private static string Ind(int n) => new string(' ', n * 2);
        private static string Indent(IEnumerable<Stmt> stmts, int level)
            => Indent(stmts.Select(s => s.Lisp), level);
        private static string Indent(IEnumerable<string> forms, int level)
        {
            var pad = Ind(level);
            return string.Join("\n", forms.Select(f =>
                pad + string.Join("\n" + pad, f.Split('\n'))));
        }
    }
}
