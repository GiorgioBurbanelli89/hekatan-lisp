using System;
using System.Collections.Generic;
using System.Globalization;
using System.Text;

namespace HekatanLisp
{
    /// <summary>
    /// La barra de Calcpad en la hoja:  L = 3m|cm  ·  q = 606kN/1.193m^2|tonf/m2
    /// Lo de después de la barra es la unidad en la que se QUIERE VER el resultado.
    ///
    /// Aquí solo se traduce el texto a la forma que entiende el motor:
    ///     (qshow '(/ (* 606 "kN") (* 1.193 (expt "m" 2))) "tonf/m2" 4)
    /// El catálogo, la conversión y el aviso por dimensiones incompatibles viven en
    /// engine.lisp (sección UNIDADES), que es lo único que se hornea en el core de
    /// SBCL y se compila dentro de hlisp.wasm — así la web hereda lo mismo.
    ///
    /// Se usa un parser propio, pequeño, en vez de ParseMath: en una línea con barra
    /// las letras son UNIDADES, no variables de la hoja, y mezclar las dos reglas en
    /// el parser general rompería cualquier hoja que llame `m` a una masa.
    /// </summary>
    public static class LispUnidades
    {
        // Los nombres que el motor reconoce como unidad. Una unidad compuesta
        // (kN/m^2, kgf/cm2) la arma el propio motor a partir de éstos.
        static readonly HashSet<string> Unidades = new HashSet<string>(StringComparer.Ordinal)
        {
            "m","cm","mm","km","in","ft",
            "kg","g","t",
            "s","min","h",
            "A","K","mol","cd","rad",
            "N","kN","MN","Pa","kPa","MPa","GPa","J","kJ","W","kW",
            "kgf","tonf"
        };

        /// <summary>¿La línea lleva barra de unidad al final? Devuelve cuerpo y destino.</summary>
        public static bool SepararBarra(string linea, out string cuerpo, out string destino)
        {
            cuerpo = linea; destino = null;
            if (linea == null) return false;
            int prof = 0;
            int barra = -1;
            for (int i = 0; i < linea.Length; i++)
            {
                char c = linea[i];
                if (c == '(' || c == '[' || c == '{') prof++;
                else if (c == ')' || c == ']' || c == '}') prof--;
                else if (c == '|' && prof == 0) barra = i;   // la ÚLTIMA de nivel cero
            }
            if (barra < 0) return false;
            var u = linea.Substring(barra + 1).Trim();
            if (u.Length == 0) return false;
            // el destino es una unidad: letras, dígitos, ^, / y *  (kN/m^2, kgf/cm2)
            foreach (char c in u)
                if (!(char.IsLetterOrDigit(c) || c == '^' || c == '/' || c == '*' || c == '-')) return false;
            cuerpo = linea.Substring(0, barra).Trim();
            destino = u;
            return cuerpo.Length > 0;
        }

        /// <summary>Texto de la expresión → forma (qshow '… "u" dec), o null si no se puede.</summary>
        public static string Forma(string expr, string destino, int dec = 4)
        {
            try
            {
                var p = new Mini(expr);
                var lisp = p.Expr();
                p.SaltarEspacios();
                if (!p.Fin) return null;
                return "(qval '" + lisp + " \"" + destino + "\" " + dec.ToString(CultureInfo.InvariantCulture) + ")";
            }
            catch { return null; }
        }

        // ── parser de bolsillo: número, unidad, + - * / ^ y paréntesis ──
        sealed class Mini
        {
            readonly string _s; int _i;
            public Mini(string s) { _s = s; _i = 0; }
            public bool Fin => _i >= _s.Length;
            public void SaltarEspacios() { while (_i < _s.Length && char.IsWhiteSpace(_s[_i])) _i++; }
            char Actual { get { SaltarEspacios(); return _i < _s.Length ? _s[_i] : '\0'; } }

            public string Expr()
            {
                var izq = Termino();
                while (true)
                {
                    char c = Actual;
                    if (c != '+' && c != '-') return izq;
                    _i++;
                    var der = Termino();
                    izq = "(" + c + " " + izq + " " + der + ")";
                }
            }

            string Termino()
            {
                var izq = Implicito();
                while (true)
                {
                    char c = Actual;
                    if (c == '*' || c == '/') { _i++; izq = "(" + c + " " + izq + " " + Implicito() + ")"; }
                    else return izq;
                }
            }

            /// «1.193m^2» es UN factor, no dos. Si no, 606kN/1.193m^2 se leería
            /// (606·kN/1.193)·m² y la dimensión saldría longitud³ en vez de presión.
            string Implicito()
            {
                var izq = Potencia();
                while (true)
                {
                    char c = Actual;
                    if (char.IsLetter(c) || c == '(') izq = "(* " + izq + " " + Potencia() + ")";
                    else return izq;
                }
            }

            string Potencia()
            {
                var b = Atomo();
                if (Actual == '^')
                {
                    _i++;
                    var e = Potencia();
                    return "(expt " + b + " " + e + ")";
                }
                return b;
            }

            string Atomo()
            {
                char c = Actual;
                if (c == '-') { _i++; return "(- 0 " + Atomo() + ")"; }
                if (c == '(')
                {
                    _i++;
                    var e = Expr();
                    if (Actual != ')') throw new FormatException("falta )");
                    _i++;
                    return e;
                }
                if (char.IsDigit(c) || c == '.')
                {
                    int ini = _i;
                    while (_i < _s.Length && (char.IsDigit(_s[_i]) || _s[_i] == '.')) _i++;
                    return _s.Substring(ini, _i - ini);
                }
                if (char.IsLetter(c))
                {
                    int ini = _i;
                    while (_i < _s.Length && (char.IsLetterOrDigit(_s[_i]) || _s[_i] == '_')) _i++;
                    var id = _s.Substring(ini, _i - ini);
                    if (!Unidades.Contains(id)) throw new FormatException("no es unidad: " + id);
                    return "\"" + id + "\"";
                }
                throw new FormatException("símbolo raro: " + c);
            }
        }
    }
}
