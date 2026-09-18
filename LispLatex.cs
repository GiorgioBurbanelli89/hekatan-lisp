// LispLatex.cs — el mismo arbol de LispConverter, escrito en LaTeX.
//
// POR QUE HACE FALTA
// El render de siempre (ToHtml) devuelve HTML, y School lo captura como PNG.
// Una imagen se puede fundir, pero no se puede TRANSFORMAR simbolo a simbolo:
// para que una expresion se convierta en la siguiente delante del espectador,
// Manim necesita las letras como VECTORES, y eso lo da LaTeX.
//
// Es un archivo APARTE y una clase parcial: no toca ni una linea del render
// existente. Si esto falla, el HTML de siempre sigue igual.
//
// La estructura calca a ToHtml a proposito (mismos casos, mismas precedencias):
// asi, cuando uno cambie, se ve enseguida que le falta al otro.

using System;
using System.Collections.Generic;
using System.Linq;
using System.Text.RegularExpressions;

namespace HekatanLisp
{
    public static class LispLatex
    {
        // ------------------------------------------------- el cuaderno de apuntes
        // Cada linea de la hoja que se dibuja, tambien apuntada en LaTeX. El render
        // no cambia: solo se guarda una copia por si se pidio --latex.
        static readonly List<(string nombre, string latex)> _apuntes = new();

        /// <summary>Apunta una linea: el nombre y la forma LISP que se dibuja.
        ///
        /// Se intento guardar la OPERACION y el RESULTADO por separado, para que
        /// la linea saliera entera como en el render del motor. No salio: en las
        /// derivadas las dos piezas se quedaban vacias y la linea perdia todo su
        /// contenido. Se deja como estaba —una sola forma— y queda pendiente.
        /// </summary>
        public static void Apunta(string nombre, string formaLisp, string resultado = null)
        {
            var forma = string.IsNullOrWhiteSpace(resultado) ? formaLisp : resultado;
            if (string.IsNullOrWhiteSpace(forma)) return;
            try
            {
                var tex = ToLatex(LispConverter.ParseLisp(forma));
                if (!string.IsNullOrWhiteSpace(tex)) _apuntes.Add((nombre, tex));
            }
            catch { /* lo que no se sepa pasar a LaTeX, sencillamente no se apunta */ }
        }

        /// <summary>Vuelca los apuntes: una linea `nombre@@latex` por expresion.</summary>
        public static void Vuelca(string ruta)
        {
            var lineas = _apuntes.Select(a =>
                (string.IsNullOrEmpty(a.nombre) ? "" : a.nombre) + "@@" + a.latex);
            System.IO.File.WriteAllLines(ruta, lineas);
        }

        // ---------------------------------------------------------- simbolos
        static readonly Dictionary<string, string> Griegas = new Dictionary<string, string>
        {
            {"alpha",@"\alpha"},{"beta",@"\beta"},{"gamma",@"\gamma"},{"delta",@"\delta"},
            {"epsilon",@"\varepsilon"},{"zeta",@"\zeta"},{"eta",@"\eta"},{"theta",@"\theta"},
            {"iota",@"\iota"},{"kappa",@"\kappa"},{"lambda",@"\lambda"},{"mu",@"\mu"},
            {"nu",@"\nu"},{"xi",@"\xi"},{"omicron","o"},{"rho",@"\rho"},{"sigma",@"\sigma"},
            {"tau",@"\tau"},{"upsilon",@"\upsilon"},{"phi",@"\varphi"},{"chi",@"\chi"},
            {"psi",@"\psi"},{"omega",@"\omega"},
            {"eps",@"\varepsilon"},{"varepsilon",@"\varepsilon"},{"varphi",@"\varphi"},
            {"pi",@"\pi"},
            {"Alpha","A"},{"Beta","B"},{"Gamma",@"\Gamma"},{"Delta",@"\Delta"},
            {"Theta",@"\Theta"},{"Lambda",@"\Lambda"},{"Xi",@"\Xi"},{"Sigma",@"\Sigma"},
            {"Phi",@"\Phi"},{"Psi",@"\Psi"},{"Omega",@"\Omega"},{"Pi",@"\Pi"},{"Upsilon",@"\Upsilon"},
            {"Epsilon","E"},{"Zeta","Z"},{"Eta","H"},{"Iota","I"},{"Kappa","K"},{"Mu","M"},{"Nu","N"},
            {"Omicron","O"},{"Rho","P"},{"Tau","T"},{"Chi","X"},
        };

        static bool EsNumero(string s) => Regex.IsMatch(s ?? "", @"^-?[\d.]");

        static string Escapa(string s) =>
            (s ?? "").Replace(@"\", @"\backslash ").Replace("{", @"\{").Replace("}", @"\}")
                     .Replace("%", @"\%").Replace("&", @"\&").Replace("#", @"\#")
                     .Replace("_", @"\_");

        /// <summary>Un nombre de variable -> LaTeX: theta_1 -> \theta_{1}, EI -> EI, v' -> v'.</summary>
        public static string Var(string name)
        {
            if (string.IsNullOrEmpty(name)) return "";
            // el motor devuelve todo en minuscula; MainWindow guarda el case original
            if (LispConverter.CaseMap.Count > 0 &&
                LispConverter.CaseMap.TryGetValue(name, out var orig)) name = orig;

            // primas: el apostrofo no sobrevive al viaje por LISP y llega como token
            string primas = "";
            while (name.Length > 1 && name[name.Length - 1] == '\'')
            { primas += "'"; name = name.Substring(0, name.Length - 1); }

            string baseN, sub;
            int us = name.IndexOf('_');
            if (us > 0 && us < name.Length - 1)
            { baseN = name.Substring(0, us); sub = name.Substring(us + 1); }
            else
            {
                int i = name.Length;
                while (i > 1 && char.IsDigit(name[i - 1])) i--;
                baseN = name.Substring(0, i); sub = name.Substring(i);
            }
            if (sub.Length > 0 && !(baseN.Length > 0 && char.IsLetter(baseN[0])))
            { baseN = name; sub = ""; }

            // los tokens de prima, tanto pegados al nombre como al subindice
            for (bool sigue = true; sigue; )
            {
                sigue = false;
                foreach (var (tk, n) in new[] { ("tprime", 3), ("pprime", 2), ("prime", 1) })
                {
                    if (baseN.Length > tk.Length && baseN.EndsWith(tk, StringComparison.Ordinal))
                    { baseN = baseN.Substring(0, baseN.Length - tk.Length); primas = new string('\'', n) + primas; sigue = true; break; }
                    if (sub.Length > tk.Length && sub.EndsWith(tk, StringComparison.Ordinal))
                    { sub = sub.Substring(0, sub.Length - tk.Length); primas = new string('\'', n) + primas; sigue = true; break; }
                }
            }

            string b = Griegas.TryGetValue(baseN, out var g) ? g
                     : (baseN.Length > 1 ? @"\mathrm{" + Escapa(baseN) + "}" : Escapa(baseN));
            if (sub.Length > 0) b += "_{" + Escapa(sub) + "}";
            if (primas.Length > 0) b += "^{" + primas + "}";
            return b;
        }

        static string Par(string s) => @"\left(" + s + @"\right)";

        static bool EsMenosUno(LispConverter.N n) =>
            n != null && n.IsAtom && (n.Atom == "-1" || n.Atom == "−1");

        // ------------------------------------------------------------- arbol
        /// <summary>El arbol en LaTeX. `parentPrec` decide los parentesis, igual que ToHtml.</summary>
        public static string ToLatex(LispConverter.N n, int parentPrec = 0)
        {
            if (n == null) return "";
            if (n.IsAtom) return EsNumero(n.Atom) ? Escapa(n.Atom) : Var(n.Atom);

            if (n.Op == "neg")
            {
                var r = "-" + ToLatex(n.A, 3);
                return parentPrec > 3 ? Par(r) : r;
            }
            if (n.Op == "trans") return "{" + ToLatex(n.A, 5) + "}^{T}";
            if (n.Op == "range")
                return string.Join(":", n.Items.Select(x => ToLatex(x, 2)));
            if (n.Op == "fn") return Fn(n);
            if (n.Op == "vec")
            {
                if (n.Items.Count == 1) return ToLatex(n.Items[0], parentPrec);
                return Rejilla(new List<List<LispConverter.N>> { n.Items });
            }
            if (n.Op == "mat")
            {
                if (n.Items.Count == 1 && n.Items[0].Items != null && n.Items[0].Items.Count == 1)
                    return ToLatex(n.Items[0].Items[0], parentPrec);
                return Rejilla(n.Items.Select(r => r.Items).ToList());
            }
            if (n.Op == "solver") return Operador(n);

            switch (n.Op)
            {
                case "^":
                    return "{" + ToLatex(n.A, 5) + "}^{" + ToLatex(n.B, 0) + "}";
                case "/":
                    // fraccion de verdad, apilada: es la mitad de la gracia de LaTeX
                    return @"\frac{" + ToLatex(n.A, 0) + "}{" + ToLatex(n.B, 0) + "}";
                case "*":
                {
                    if (EsMenosUno(n.A)) { var r0 = "-" + ToLatex(n.B, 2); return parentPrec > 2 ? Par(r0) : r0; }
                    if (EsMenosUno(n.B)) { var r0 = "-" + ToLatex(n.A, 2); return parentPrec > 2 ? Par(r0) : r0; }
                    // \, = espacio fino: "q\,L\,x" se lee como producto, "qLx" parece una variable
                    var r = ToLatex(n.A, 2) + @"\," + ToLatex(n.B, 2);
                    return parentPrec > 2 ? Par(r) : r;
                }
                default:
                {
                    if (n.Op == "-" && n.A != null && n.A.IsAtom && n.A.Atom == "0")
                    {
                        var r0 = "-" + ToLatex(n.B, 2);
                        return parentPrec > 2 ? Par(r0) : r0;
                    }
                    var sym = n.Op == "-" ? " - " : " + ";
                    var r = ToLatex(n.A, 1) + sym + ToLatex(n.B, n.Op == "-" ? 2 : 1);
                    return parentPrec > 1 ? Par(r) : r;
                }
            }
        }

        /// <summary>Los OPERADORES con su simbolo: integral, sumatorio, derivada...
        ///
        /// Antes salian con su nombre en letra —`area(E A 1/L^2, x, 0, L)`— en vez de
        /// con el simbolo, y no se parecian en nada a lo que dibuja el motor
        /// (comparado lado a lado, formula a formula). Aqui se calca el mismo
        /// reparto que hace `SolverToHtml`, para que las dos salidas digan lo mismo.
        /// </summary>
        static string Operador(LispConverter.N n)
        {
            var it = n.Items ?? new List<LispConverter.N>();
            string f = it.Count > 0 ? ToLatex(it[0], 0) : "";
            string v = it.Count > 1 ? ToLatex(it[1], 0) : "x";
            string a = it.Count > 2 ? ToLatex(it[2], 0) : "0";
            string b = it.Count > 3 ? ToLatex(it[3], 0) : null;
            string dv = @"\,\mathrm{d}" + v;

            switch ((n.Atom ?? "").ToLowerInvariant())
            {
                case "despejar":
                    return it.Count >= 2 ? ToLatex(it[0], 0) + " = " + ToLatex(it[1], 0) : f;
                case "area":
                    return @"\int_{" + a + "}^{" + (b ?? "") + "}" + f + dv;
                case "integral":
                    return b != null ? @"\int_{" + a + "}^{" + b + "}" + f + dv
                                     : @"\int " + f + dv;
                case "sum":
                    return @"\sum_{" + v + " = " + a + "}^{" + (b ?? "") + "}" + f;
                case "product":
                    return @"\prod_{" + v + " = " + a + "}^{" + (b ?? "") + "}" + f;
                case "lim": case "limit": case "limite":
                    return @"\lim_{" + v + @" 	o " + a + "}" + Par(f);
                case "slope": case "derivative":
                    return @"\left.rac{\mathrm{d}}{\mathrm{d}" + v + "}" + Par(f)
                         + @"
ight|_{" + v + " = " + a + "}";
                case "partial":
                    return @"rac{\partial}{\partial " + v + "}" + Par(f);
                case "derivate": case "diff": case "pasos": case "diffpasos":
                    return @"rac{\mathrm{d}}{\mathrm{d}" + v + "}" + Par(f);
                // simplificar/factorizar/expandir no tienen simbolo: se ve la expresion
                case "simplify": case "factor": case "expand":
                    return f;
                case "root":
                    return @"\mathrm{root}\left\{" + f + " = 0" + @"
ight\}";
                default:
                    return @"\mathrm{" + Escapa(n.Atom ?? "op") + "}"
                         + Par(string.Join(",", it.Select(x => ToLatex(x, 0))));
            }
        }

        static string Fn(LispConverter.N n)
        {
            var nombre = (n.Atom ?? "").ToLowerInvariant();
            var args = n.Items ?? new List<LispConverter.N>();
            string A(int i) => i < args.Count ? ToLatex(args[i], 0) : "";

            switch (nombre)
            {
                case "sqrt": return @"\sqrt{" + A(0) + "}";
                case "exp":  return "e^{" + A(0) + "}";
                case "abs":  return @"\left|" + A(0) + @"\right|";
                case "sin": case "cos": case "tan": case "log": case "ln":
                case "sinh": case "cosh": case "tanh":
                    return "\\" + nombre + @"\left(" + A(0) + @"\right)";
                default:
                    return @"\mathrm{" + Escapa(nombre) + "}" +
                           Par(string.Join(",", args.Select(x => ToLatex(x, 0))));
            }
        }

        static string Rejilla(List<List<LispConverter.N>> filas)
        {
            var cuerpo = string.Join(@" \\ ",
                filas.Select(f => string.Join(" & ", f.Select(x => ToLatex(x, 0)))));
            return @"\begin{bmatrix}" + cuerpo + @"\end{bmatrix}";
        }
    }
}
