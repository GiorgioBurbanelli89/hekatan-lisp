using System;
using System.Collections.Generic;
using System.Diagnostics;
using System.IO;
using System.Text;

namespace HekatanLisp
{
    /// <summary>
    /// Motor real: ejecuta LISP con SBCL (como Hekatan Fortran usa su interprete).
    /// deriva y simplifica de verdad, corriendo engine.lisp.
    /// </summary>
    public static class LispEngine
    {
        private static string _sbcl;
        private static string Sbcl => _sbcl ??= Find();

        private static string Find()
        {
            // 1) SBCL EMPAQUETADO dentro del app (autocontenido, sin instalar nada)
            var bundled = Path.Combine(AppContext.BaseDirectory, "sbcl", "sbcl.exe");
            if (File.Exists(bundled)) return bundled;
            // 2) instalado en el sistema (fallback)
            foreach (var p in new[]
            {
                @"C:\Program Files\Steel Bank Common Lisp\sbcl.exe",
                @"C:\Program Files\SBCL\sbcl.exe",
            })
                if (File.Exists(p)) return p;
            return "sbcl";   // en el PATH
        }

        /// <summary>El core va junto al exe; se lo pasamos explícito por si acaso.
        /// Si existe un core CON EL MOTOR HORNEADO (engine.core), usamos ese → sin recargar → ~3× más rápido.</summary>
        private static string CoreArg()
        {
            var ec = EngineCore();
            if (ec != null) return $"--core \"{ec}\" ";
            var dir = Path.GetDirectoryName(Sbcl);
            var core = dir == null ? null : Path.Combine(dir, "sbcl.core");
            return (core != null && File.Exists(core)) ? $"--core \"{core}\" " : "";
        }

        // ---------- core con engine.lisp PRECARGADO (save-lisp-and-die) ----------
        private static string _engineCore;      // ruta del core horneado (null = no disponible)
        private static bool _coreTried;
        private static readonly object _coreLock = new object();
        private static string EngineCore()
        {
            lock (_coreLock)
            {
                if (_coreTried) return _engineCore;
                _coreTried = true;
                try
                {
                    var dir = Path.GetDirectoryName(Sbcl);
                    var baseCore = dir == null ? null : Path.Combine(dir, "sbcl.core");
                    if (baseCore == null || !File.Exists(baseCore)) return null;
                    var eng = Lib;
                    if (!File.Exists(eng)) return null;
                    var core = Path.Combine(dir, "engine.core");
                    // (re)hornear si falta o si engine.lisp es MÁS NUEVO (cambió el motor)
                    if (!File.Exists(core) || File.GetLastWriteTimeUtc(eng) > File.GetLastWriteTimeUtc(core))
                    {
                        var e = eng.Replace("\\", "/"); var c = core.Replace("\\", "/");
                        var args = $"--core \"{baseCore}\" --non-interactive " +
                                   $"--eval \"(setf *print-case* :downcase)\" " +
                                   $"--eval \"(setf *print-right-margin* 100000)\" " +
                                   $"--eval \"(load \\\"{e}\\\")\" " +
                                   $"--eval \"(sb-ext:save-lisp-and-die \\\"{c}\\\")\"";
                        var psi = new ProcessStartInfo(Sbcl, args)
                        { RedirectStandardOutput = true, RedirectStandardError = true, UseShellExecute = false, CreateNoWindow = true };
                        using var p = Process.Start(psi);
                        p.StandardOutput.ReadToEnd(); p.StandardError.ReadToEnd();
                        p.WaitForExit(20000);
                    }
                    if (File.Exists(core)) _engineCore = core;
                }
                catch { _engineCore = null; }
                return _engineCore;
            }
        }

        private static string Lib => Path.Combine(AppContext.BaseDirectory, "engine.lisp");

        /// <summary>Deriva y simplifica cada expresion LISP con SBCL, en UNA sola llamada.
        /// Cada linea del resultado corresponde a una expresion (o "?" si fallo).</summary>
        public static List<string> DeriveBatch(List<string> lispExprs)
        {
            var sb = new StringBuilder();
            sb.Append("(setf *print-case* :downcase)\n");   // SBCL imprime en minuscula (x, expt), no MAYUS
            sb.Append("(setf *print-right-margin* 100000)\n");   // no partir formas largas en 2 lineas
            sb.Append("(load \"").Append(Lib.Replace("\\", "/")).Append("\")\n");
            foreach (var ex in lispExprs)
                sb.Append("(format t \"~a~%\" (or (ignore-errors (dsimp '")
                  .Append(ex).Append(" 'x)) '?))\n");

            var outp = Run(sb.ToString());
            var res = new List<string>();
            foreach (var l in outp.Replace("\r", "").Split('\n'))
                if (l.Length > 0) res.Add(l);
            return res;
        }

        /// <summary>Ejecuta código LISP arbitrario (lo que el usuario escribió) en SBCL.
        /// Aquí es donde el usuario define SUS funciones, las llama, y se ejecutan.</summary>
        public static string RunScript(string code) => Run(code);

        /// <summary>Despeja 'var' de la ecuación  lhs = rhs. Devuelve la forma LISP de la solución.</summary>
        public static string RunDespejar(string lhs, string rhs, string var)
        {
            var sb = new StringBuilder();
            sb.Append("(setf *print-case* :downcase)\n(setf *print-right-margin* 100000)\n");
            sb.Append("(load \"").Append(Lib.Replace("\\", "/")).Append("\")\n");
            sb.Append("(format t \"~a~%\" (or (ignore-errors (despejar '").Append(lhs)
              .Append(" '").Append(rhs).Append(" '").Append(var).Append(")) '?))\n");
            foreach (var l in Run(sb.ToString()).Replace("\r", "").Split('\n'))
                if (l.Trim().Length > 0) return l.Trim();
            return "?";
        }

        /// <summary>Aplica una OPERACIÓN a cada expresión LISP y devuelve el resultado como forma LISP:
        ///   op="auto"     → el VALOR numérico si se puede; si no, la expresión TAL CUAL (no toca).
        ///   op="simplify" → junta términos semejantes.
        ///   op="expand"   → distribuye productos/potencias.
        ///   op="deriv"    → derivada respecto a x (simplificada).
        /// Una sola llamada a SBCL. Cada línea del resultado = una expresión.</summary>
        // nombres de las llamadas de operación del motor (para detectarlas dentro de una expresión)
        static readonly string[] OpCallNames = {
            "area-under","slope-at","suma","producto-op","root-op","find-op","sup-op","inf-op","repeat-op",
            "partial","derive-x","integ-var","integ-x","factor","expand*"
        };
        public static List<string> EvalOp(List<string> lispExprs, string op, string var = null)
        {
            // Si hay VARIABLE elegida (∂ respecto a v), usa la PARCIAL / integral con esa v.
            bool hasVar = !string.IsNullOrWhiteSpace(var);
            string fn = op switch { "simplify" => "factor", "expand" => "expand*",
                                    "deriv" => hasVar ? "partial" : "derive-x",
                                    "integ" => hasVar ? "integ-var" : "integ-x", _ => null };
            bool twoArg = hasVar && (op == "deriv" || op == "integ");
            var sb = new StringBuilder();
            sb.Append("(setf *print-case* :downcase)\n");
            sb.Append("(setf *print-right-margin* 100000)\n");   // no partir formas largas
            sb.Append("(load \"").Append(Lib.Replace("\\", "/")).Append("\")\n");
            foreach (var ex in lispExprs)
            {
                // ¿la forma tiene ALGÚN token de operación (aunque sea anidado)? → evaluar con evops
                bool hasOp = System.Array.Exists(OpCallNames, nm => ex.Contains("(" + nm));
                if (hasOp)   // tokens (Partial, Factor, …) puros o mezclados con aritmética → resultado simbólico
                    sb.Append("(format t \"~a~%\" (or (ignore-errors (evops '").Append(ex).Append(")) '").Append(ex).Append("))\n");
                else if (fn == null)   // auto: valor si evalúa a número; si no, la forma tal cual
                    sb.Append("(format t \"~a~%\" (or (ignore-errors (let ((v ").Append(ex)
                      .Append(")) (if (numberp v) v nil))) '").Append(ex).Append("))\n");
                else if (twoArg)  // partial / integ-var con la variable elegida
                    sb.Append("(format t \"~a~%\" (or (ignore-errors (").Append(fn).Append(" '")
                      .Append(ex).Append(" '").Append(var.Trim()).Append(")) '").Append(ex).Append("))\n");
                else
                    sb.Append("(format t \"~a~%\" (or (ignore-errors (").Append(fn).Append(" '")
                      .Append(ex).Append(")) '").Append(ex).Append("))\n");
            }
            var res = new List<string>();
            foreach (var l in Run(sb.ToString()).Replace("\r", "").Split('\n'))
                res.Add(l);
            return res;
        }

        private static string Run(string code)
        {
            // si el motor está HORNEADO en el core, quita los (load "…engine.lisp") — recargarlo sería lento
            if (EngineCore() != null)
                code = System.Text.RegularExpressions.Regex.Replace(
                    code, @"(?im)^\s*\(load\s+""[^""]*engine\.lisp""\)\s*$", "");
            var tmp = Path.Combine(Path.GetTempPath(), $"hlisp_run_{Environment.ProcessId}.lisp");
            File.WriteAllText(tmp, code);
            try
            {
                var psi = new ProcessStartInfo(Sbcl, $"{CoreArg()}--script \"{tmp}\"")
                {
                    RedirectStandardOutput = true,
                    RedirectStandardError = true,
                    UseShellExecute = false,
                    CreateNoWindow = true,
                };
                using var p = Process.Start(psi);
                var o = p.StandardOutput.ReadToEnd();
                var e = p.StandardError.ReadToEnd();
                p.WaitForExit(5000);
                return string.IsNullOrWhiteSpace(e) ? o : o + e;
            }
            catch (Exception ex) { return "; error motor SBCL: " + ex.Message; }
        }
    }
}
