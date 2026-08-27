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
                        psi.EnvironmentVariables["LANG"] = "en_US.UTF-8";
                        psi.EnvironmentVariables["LC_ALL"] = "en_US.UTF-8";
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
            "partial","derive-x","deriv-steps","integ-var","integ-x","factor","expand*","limite"
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
                // ¿MATRIZ? (vector/transpuesta/rango) → evaluar con meval e imprimir como (vector …)
                bool hasMat = ex.Contains("(vector") || ex.Contains("(mtransp") || ex.Contains("(mrange") || ex.Contains("(ngauss");
                // ¿la forma tiene ALGÚN token de operación (aunque sea anidado)? → evaluar con evops
                bool hasOp = System.Array.Exists(OpCallNames, nm => ex.Contains("(" + nm));
                if (hasMat)  // álgebra de matrices simbólica/numérica
                    sb.Append("(format t \"~a~%\" (or (ignore-errors (mprint (meval '").Append(ex).Append("))) '").Append(ex).Append("))\n");
                else if (hasOp)   // tokens (Partial, Factor, …) puros o mezclados con aritmética → resultado simbólico
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

        /// <summary>CRONÓMETRO (tic/toc): corre las formas de operación N veces en SBCL y devuelve
        /// los MICROSEGUNDOS por operación. Mide el cálculo puro, como el tic/toc de Hekatan Lab.</summary>
        public static double TimeOps(List<string> forms, int n)
        {
            if (forms == null || forms.Count == 0 || n <= 0) return 0;
            var sb = new StringBuilder();
            sb.Append("(setf *print-case* :downcase)\n");
            sb.Append("(load \"").Append(Lib.Replace("\\", "/")).Append("\")\n");
            sb.Append("(let ((t0 (get-internal-real-time)))\n  (dotimes (i ").Append(n).Append(")\n");
            foreach (var f in forms)
                sb.Append("    (ignore-errors (evops '").Append(f).Append("))\n");
            sb.Append("  )\n  (format t \"~,4f~%\" (/ (* 1000000.0 (- (get-internal-real-time) t0)) (* internal-time-units-per-second ")
              .Append(n).Append("))))\n");
            foreach (var l in Run(sb.ToString()).Replace("\r", "").Split('\n'))
                if (double.TryParse(l.Trim(), System.Globalization.NumberStyles.Float,
                                    System.Globalization.CultureInfo.InvariantCulture, out var v) && v > 0)
                    return v;
            return 0;
        }

        private static string Run(string code)
        {
            // si el motor está HORNEADO en el core, quita los (load "…engine.lisp") — recargarlo sería lento
            if (EngineCore() != null)
                code = System.Text.RegularExpressions.Regex.Replace(
                    code, @"(?im)^\s*\(load\s+""[^""]*engine\.lisp""\)\s*$", "");
            // 1) SERVIDOR PERSISTENTE (rápido: sin arranque). Solo con core horneado.
            if (EngineCore() != null)
            {
                try { var r = RunServer(code); if (r != null) return r; }
                catch { KillServer(); }   // si algo falla, reinicia y cae a proceso-por-eval
            }
            // 2) fallback: proceso-por-eval (como antes)
            return RunOnce(code);
        }

        // ---------- servidor SBCL vivo: read→eval→print sobre stdin/stdout (elimina el arranque por eval) ----------
        private static Process _server;
        private static StreamWriter _sin;
        private static StreamReader _sout;
        private static readonly object _srvLock = new object();

        private static string RunServer(string code)
        {
            lock (_srvLock)
            {
                EnsureServer();
                if (_server == null || _server.HasExited) return null;
                _sin.Write(code);
                _sin.Write("\n(hlisp-done)\n");   // marcador: fin del bloque de entrada
                _sin.Flush();
                // lee stdout hasta \x1e (fin de respuesta), con timeout
                var readTask = System.Threading.Tasks.Task.Run(() =>
                {
                    var buf = new StringBuilder();
                    int c;
                    while ((c = _sout.Read()) != -1)
                    {
                        if (c == 30) break;   // \x1e
                        buf.Append((char)c);
                    }
                    return buf.ToString();
                });
                if (!readTask.Wait(30000)) { KillServer(); throw new Exception("timeout server"); }
                return readTask.Result.TrimEnd('\n', '\r');
            }
        }

        private static void EnsureServer()
        {
            if (_server != null && !_server.HasExited) return;
            KillServer();
            var core = EngineCore();
            if (core == null) return;
            var psi = new ProcessStartInfo(Sbcl)
            {
                RedirectStandardInput = true,
                RedirectStandardOutput = true,
                RedirectStandardError = true,
                UseShellExecute = false,
                CreateNoWindow = true,
                StandardInputEncoding = new UTF8Encoding(false),
                StandardOutputEncoding = new UTF8Encoding(false),
                StandardErrorEncoding = new UTF8Encoding(false),
            };
            psi.ArgumentList.Add("--core"); psi.ArgumentList.Add(core);
            psi.ArgumentList.Add("--non-interactive");
            psi.ArgumentList.Add("--eval"); psi.ArgumentList.Add("(hlisp-server)");
            psi.EnvironmentVariables["LANG"] = "en_US.UTF-8";
            psi.EnvironmentVariables["LC_ALL"] = "en_US.UTF-8";
            _server = Process.Start(psi);
            _sin = _server.StandardInput;
            _sout = _server.StandardOutput;
            var srv = _server;   // drena stderr en background para que no bloquee el pipe
            System.Threading.Tasks.Task.Run(() => { try { srv.StandardError.ReadToEnd(); } catch { } });
            // WARM-UP: descarta cualquier banner inicial hasta el primer \x1e → sincroniza el pipe.
            try
            {
                _sin.Write("(hlisp-done)\n"); _sin.Flush();
                var t = System.Threading.Tasks.Task.Run(() => { int c; while ((c = _sout.Read()) != -1 && c != 30) { } });
                if (!t.Wait(8000)) KillServer();
            }
            catch { KillServer(); }
        }

        private static void KillServer()
        {
            try { if (_server != null && !_server.HasExited) _server.Kill(); } catch { }
            try { _server?.Dispose(); } catch { }
            _server = null; _sin = null; _sout = null;
        }

        // proceso-por-eval (lanza-calcula-cierra): fallback si el servidor no está o falla.
        private static string RunOnce(string code)
        {
            var tmp = Path.Combine(Path.GetTempPath(), $"hlisp_run_{Environment.ProcessId}.lisp");
            File.WriteAllText(tmp, code, new UTF8Encoding(false));   // UTF-8 sin BOM (para ∂, ∇, letras)
            try
            {
                var psi = new ProcessStartInfo(Sbcl, $"{CoreArg()}--script \"{tmp}\"")
                {
                    RedirectStandardOutput = true,
                    RedirectStandardError = true,
                    UseShellExecute = false,
                    CreateNoWindow = true,
                    StandardOutputEncoding = new UTF8Encoding(false),
                    StandardErrorEncoding = new UTF8Encoding(false),
                };
                psi.EnvironmentVariables["LANG"] = "en_US.UTF-8";
                psi.EnvironmentVariables["LC_ALL"] = "en_US.UTF-8";
                using var p = Process.Start(psi);
                var o = p.StandardOutput.ReadToEnd();
                var e = p.StandardError.ReadToEnd();
                p.WaitForExit(30000);
                return string.IsNullOrWhiteSpace(e) ? o : o + e;
            }
            catch (Exception ex) { return "; error motor SBCL: " + ex.Message; }
        }
    }
}
