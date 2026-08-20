using System;
using System.Collections.Generic;
using System.Globalization;
using System.Text;

namespace HekatanLisp
{
    /// <summary>
    /// Traductor APROXIMADO LISP -> MATLAB (pseudocódigo), para APRENDER cómo se verían
    /// las funciones del motor en MATLAB. No pretende correr: convierte la ESTRUCTURA
    /// (defun->function, cond->if/elseif, car->{1}, list->cell, mapcar->cellfun, …).
    /// Las expresiones simbólicas LISP (listas) se representan como CELL arrays de MATLAB.
    /// </summary>
    public static class LispPseudoMat
    {
        // ---------- 1) parser de s-expresiones (general) ----------
        static List<object> ParseAll(string src)
        {
            int i = 0; var forms = new List<object>();
            while (true) { SkipWs(src, ref i); if (i >= src.Length) break; forms.Add(Read(src, ref i)); }
            return forms;
        }
        static void SkipWs(string s, ref int i)
        {
            while (i < s.Length)
            {
                char c = s[i];
                if (char.IsWhiteSpace(c)) i++;
                else if (c == ';') { while (i < s.Length && s[i] != '\n') i++; }
                else break;
            }
        }
        static object Read(string s, ref int i)
        {
            SkipWs(s, ref i);
            if (i >= s.Length) return "";
            char c = s[i];
            if (c == '(')
            {
                i++; var lst = new List<object>();
                while (true) { SkipWs(s, ref i); if (i >= s.Length || s[i] == ')') { if (i < s.Length) i++; break; } lst.Add(Read(s, ref i)); }
                return lst;
            }
            if (c == '\'' || c == '`') { i++; return new List<object> { "quote", Read(s, ref i) }; }
            if (c == '#')
            {
                i++;
                if (i < s.Length && s[i] == '\'') { i++; return new List<object> { "function", Read(s, ref i) }; }
                // otros # : trátalo como parte de un átomo
            }
            if (c == '"')
            {
                i++; var sb = new StringBuilder("\"");
                while (i < s.Length && s[i] != '"') { if (s[i] == '\\' && i + 1 < s.Length) { sb.Append(s[i]); i++; } sb.Append(s[i]); i++; }
                if (i < s.Length) i++;
                sb.Append('"'); return sb.ToString();
            }
            int st = i;
            while (i < s.Length && !char.IsWhiteSpace(s[i]) && s[i] != '(' && s[i] != ')' && s[i] != ';') i++;
            return s.Substring(st, i - st);
        }

        static bool IsAtom(object o) => o is string;
        static string A(object o) => o as string;
        static List<object> L(object o) => o as List<object>;
        static string Head(object o) { var l = L(o); return (l != null && l.Count > 0 && l[0] is string h) ? h : null; }

        // ---------- 2) traductor ----------
        public static string Translate(string lispSrc)
        {
            var sb = new StringBuilder();
            sb.AppendLine("% ===== PSEUDOCODIGO estilo MATLAB (desde LISP, solo para ENTENDER) =====");
            sb.AppendLine("% OJO: NO es MATLAB real (faltaria 'syms x' y mas). No lo copies para correr.");
            sb.AppendLine("% Las expresiones simbolicas (listas LISP) se ven como CELL arrays: {'+', a, b}");
            sb.AppendLine("% car->x{1}  second->x{2}  cdr->x(2:end)  list->{...}  cond->if/elseif");
            sb.AppendLine();
            List<object> forms;
            try { forms = ParseAll(lispSrc); } catch (Exception ex) { return sb + "% (no pude parsear: " + ex.Message + ")"; }
            foreach (var f in forms)
            {
                if (Head(f) == "defun") { EmitDefun(L(f), sb); sb.AppendLine(); }
                else if (IsAtom(f) && A(f).StartsWith(";")) { }        // comentario suelto
                else { sb.AppendLine("% " + Compact(f)); }              // top-level no-defun: como comentario
            }
            return sb.ToString().TrimEnd();
        }

        static void EmitDefun(List<object> d, StringBuilder sb)
        {
            // (defun name (args...) "doc"? body...)
            string name = A(d[1]);
            var argl = L(d[2]);
            var args = new List<string>();
            if (argl != null) foreach (var a in argl) args.Add(A(a));
            int bi = 3;
            string doc = null;
            if (bi < d.Count && d[bi] is string s0 && s0.StartsWith("\"")) { doc = s0.Trim('"'); bi++; }
            sb.AppendLine("function r = " + name + "(" + string.Join(", ", args) + ")");
            if (doc != null) sb.AppendLine("  % " + doc.Replace("\n", " "));
            // cuerpo: todas las formas menos la última son sentencias; la última devuelve r
            for (int k = bi; k < d.Count; k++)
                EmitStmt(d[k], (k == d.Count - 1) ? "r" : null, 1, sb);
            sb.AppendLine("end");
        }

        static string Ind(int n) => new string(' ', n * 2);

        // Emite SENTENCIAS que dejan el valor de 'node' en 'target' (o null = solo efecto).
        static void EmitStmt(object node, string target, int ind, StringBuilder sb)
        {
            string h = Head(node);
            var l = L(node);
            if (h == "cond")
            {
                bool first = true;
                for (int k = 1; k < l.Count; k++)
                {
                    var cl = L(l[k]); if (cl == null || cl.Count == 0) continue;
                    string test = A(cl[0]);
                    if (test == "t" || test == "else")
                        sb.AppendLine(Ind(ind) + "else");
                    else { sb.AppendLine(Ind(ind) + (first ? "if " : "elseif ") + Expr(cl[0])); first = false; }
                    EmitBody(cl, 1, target, ind + 1, sb);
                }
                sb.AppendLine(Ind(ind) + "end");
            }
            else if (h == "if")
            {
                sb.AppendLine(Ind(ind) + "if " + Expr(l[1]));
                EmitStmt(l[2], target, ind + 1, sb);
                if (l.Count > 3) { sb.AppendLine(Ind(ind) + "else"); EmitStmt(l[3], target, ind + 1, sb); }
                sb.AppendLine(Ind(ind) + "end");
            }
            else if (h == "when" || h == "unless")
            {
                sb.AppendLine(Ind(ind) + "if " + (h == "unless" ? "~(" : "") + Expr(l[1]) + (h == "unless" ? ")" : ""));
                EmitBody(l, 2, target, ind + 1, sb);
                sb.AppendLine(Ind(ind) + "end");
            }
            else if (h == "let" || h == "let*")
            {
                var binds = L(l[1]);
                if (binds != null)
                    foreach (var b in binds)
                    {
                        var bl = L(b);
                        if (bl != null && bl.Count >= 2) sb.AppendLine(Ind(ind) + A(bl[0]) + " = " + Expr(bl[1]) + ";");
                        else sb.AppendLine(Ind(ind) + A(b) + " = [];");
                    }
                EmitBody(l, 2, target, ind, sb);
            }
            else if (h == "dolist")
            {
                var spec = L(l[1]);   // (x lista)
                sb.AppendLine(Ind(ind) + "for " + A(spec[0]) + " = " + Expr(spec[1]));
                EmitBody(l, 2, null, ind + 1, sb);
                sb.AppendLine(Ind(ind) + "end");
            }
            else if (h == "dotimes")
            {
                var spec = L(l[1]);   // (i n)
                sb.AppendLine(Ind(ind) + "for " + A(spec[0]) + " = 0:(" + Expr(spec[1]) + ")-1");
                EmitBody(l, 2, null, ind + 1, sb);
                sb.AppendLine(Ind(ind) + "end");
            }
            else if (h == "setf" && l.Count >= 3)
            {
                sb.AppendLine(Ind(ind) + Expr(l[1]) + " = " + Expr(l[2]) + ";");
                if (target != null) sb.AppendLine(Ind(ind) + target + " = " + Expr(l[1]) + ";");
            }
            else if (h == "format")
            {
                sb.AppendLine(Ind(ind) + EmitFormat(l) + ";");
            }
            else if (h == "progn")
            {
                EmitBody(l, 1, target, ind, sb);
            }
            else
            {
                // expresión simple → asigna o ejecuta
                if (target != null) sb.AppendLine(Ind(ind) + target + " = " + Expr(node) + ";");
                else sb.AppendLine(Ind(ind) + Expr(node) + ";");
            }
        }

        // Emite las formas de 'list' desde 'from'; la última va a 'target', el resto son efectos.
        static void EmitBody(List<object> list, int from, string target, int ind, StringBuilder sb)
        {
            for (int k = from; k < list.Count; k++)
                EmitStmt(list[k], (k == list.Count - 1) ? target : null, ind, sb);
        }

        // ---------- expresiones inline ----------
        static string Expr(object node)
        {
            if (IsAtom(node)) return AtomExpr(A(node));
            var l = L(node);
            if (l == null || l.Count == 0) return "{}";
            string h = Head(node);
            List<object> args = l.GetRange(1, l.Count - 1);
            switch (h)
            {
                case "quote": return QuoteExpr(l[1]);
                case "function": return "@" + Expr(l[1]);
                case "lambda":
                    {
                        var pl = L(l[1]); var ps = new List<string>();
                        if (pl != null) foreach (var p in pl) ps.Add(A(p));
                        string body = l.Count > 2 ? Expr(l[l.Count - 1]) : "[]";
                        return "@(" + string.Join(", ", ps) + ") " + body;
                    }
                case "+": case "-": case "*": case "/":
                    if (args.Count == 1 && h == "-") return "(-" + Expr(args[0]) + ")";
                    return "(" + Join(args, " " + h + " ") + ")";
                case "=": case "eq": case "eql": case "equal":
                    return "isequal(" + Expr(args[0]) + ", " + Expr(args[1]) + ")";
                case "<": case ">": case "<=": case ">=":
                    return "(" + Expr(args[0]) + " " + h + " " + Expr(args[1]) + ")";
                case "and": return "(" + Join(args, " && ") + ")";
                case "or": return "(" + Join(args, " || ") + ")";
                case "not": case "null": return "isempty(" + Expr(args[0]) + ")";
                case "list": return "{" + Join(args, ", ") + "}";
                case "cons": return "[{" + Expr(args[0]) + "}, " + Expr(args[1]) + "]";
                case "append": return "[" + Join(args, ", ") + "]";
                case "car": case "first": return Expr(args[0]) + "{1}";
                case "second": case "cadr": return Expr(args[0]) + "{2}";
                case "third": case "caddr": return Expr(args[0]) + "{3}";
                case "cdr": case "rest": return Expr(args[0]) + "(2:end)";
                case "nth": return Expr(args[1]) + "{" + Expr(args[0]) + "+1}";
                case "length": return "numel(" + Expr(args[0]) + ")";
                case "reverse": return "fliplr(" + Expr(args[0]) + ")";
                case "consp": return "iscell(" + Expr(args[0]) + ")";
                case "atom": return "~iscell(" + Expr(args[0]) + ")";
                case "numberp": return "isnumeric(" + Expr(args[0]) + ")";
                case "integerp": return "(isnumeric(" + Expr(args[0]) + ") && mod(" + Expr(args[0]) + ",1)==0)";
                case "rationalp": return "isnumeric(" + Expr(args[0]) + ")";
                case "symbolp": return "ischar(" + Expr(args[0]) + ")";
                case "member": return "ismember(" + Expr(args[0]) + ", " + Expr(args[1]) + ")";
                case "mapcar":
                    return "cellfun(" + Expr(args[0]) + ", " + Expr(args[1]) + ", 'UniformOutput', false)";
                case "concatenate":   // (concatenate 'string a b …) → [a, b, …]
                    return "[" + Join(args.GetRange(1, args.Count - 1), ", ") + "]";
                case "funcall":
                    return Expr(args[0]) + "(" + Join(args.GetRange(1, args.Count - 1), ", ") + ")";
                case "expt": return "(" + Expr(args[0]) + "^" + Expr(args[1]) + ")";
                case "if":   // if como expresión → helper iif (aprox.)
                    return "iif(" + Expr(args[0]) + ", " + Expr(args[1]) + ", " + (args.Count > 2 ? Expr(args[2]) : "[]") + ")";
                case "error": return "error(" + Expr(args.Count > 0 ? args[0] : "\"\"") + ")";
                default:
                    // llamada a función:  name(a, b, …)
                    return h + "(" + Join(args, ", ") + ")";
            }
        }

        static string Join(List<object> args, string sep)
        {
            var parts = new List<string>();
            foreach (var a in args) parts.Add(Expr(a));
            return string.Join(sep, parts);
        }

        static string AtomExpr(string a)
        {
            if (a == "t") return "true";
            if (a == "nil") return "{}";
            if (a == "pi") return "pi";
            if (a.StartsWith("\"")) return "'" + a.Trim('"').Replace("'", "''") + "'";   // string → 'texto'
            // número
            if (double.TryParse(a, NumberStyles.Any, CultureInfo.InvariantCulture, out _)) return a;
            return a;   // variable
        }

        // (quote X): símbolo → 'X' ; lista → cell {…} de elementos citados
        static string QuoteExpr(object x)
        {
            if (IsAtom(x))
            {
                string a = A(x);
                if (a == "nil") return "{}";
                if (double.TryParse(a, NumberStyles.Any, CultureInfo.InvariantCulture, out _)) return a;
                return "'" + a + "'";
            }
            var l = L(x);
            var parts = new List<string>();
            if (l != null) foreach (var e in l) parts.Add(QuoteExpr(e));
            return "{" + string.Join(", ", parts) + "}";
        }

        static string EmitFormat(List<object> l)
        {
            // (format t "fmt" args…) → fprintf('fmt', args…)   (~a→%s aprox)
            string fmt = "''";
            int ai = 2;
            if (l.Count > 2 && l[2] is string s && s.StartsWith("\""))
            { fmt = "'" + s.Trim('"').Replace("~a", "%s").Replace("~%", "\\n").Replace("~d", "%d") + "'"; ai = 3; }
            var rest = new List<string>();
            for (int k = ai; k < l.Count; k++) rest.Add(Expr(l[k]));
            return "fprintf(" + fmt + (rest.Count > 0 ? ", " + string.Join(", ", rest) : "") + ")";
        }

        static string Compact(object o)
        {
            if (IsAtom(o)) return A(o);
            var l = L(o); var parts = new List<string>();
            if (l != null) foreach (var e in l) parts.Add(Compact(e));
            return "(" + string.Join(" ", parts) + ")";
        }
    }
}
