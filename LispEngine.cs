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

        /// <summary>El core va junto al exe; se lo pasamos explícito por si acaso.</summary>
        private static string CoreArg()
        {
            var dir = Path.GetDirectoryName(Sbcl);
            var core = dir == null ? null : Path.Combine(dir, "sbcl.core");
            return (core != null && File.Exists(core)) ? $"--core \"{core}\" " : "";
        }

        private static string Lib => Path.Combine(AppContext.BaseDirectory, "engine.lisp");

        /// <summary>Deriva y simplifica cada expresion LISP con SBCL, en UNA sola llamada.
        /// Cada linea del resultado corresponde a una expresion (o "?" si fallo).</summary>
        public static List<string> DeriveBatch(List<string> lispExprs)
        {
            var sb = new StringBuilder();
            sb.Append("(setf *print-case* :downcase)\n");   // SBCL imprime en minuscula (x, expt), no MAYUS
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

        private static string Run(string code)
        {
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
