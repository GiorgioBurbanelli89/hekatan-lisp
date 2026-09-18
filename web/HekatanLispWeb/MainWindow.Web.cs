using System.Collections.Generic;
using System.Runtime.InteropServices.JavaScript;
using System.Text;

namespace HekatanLisp
{
    /// <summary>
    /// WEB: la parte de MainWindow.RunShowAsync que arma el resultado, sin WPF.
    /// Mismo orden que el escritorio: ComputeResult → RenderPage → gráficas intercaladas.
    /// </summary>
    public partial class MainWindow
    {
        private static readonly MainWindow _app = new MainWindow();

        /// <summary>Resultado de la hoja. view: "render" (HTML) | "lisp" | "math" (texto).</summary>
        [JSExport]
        public static string Compute(string text, string op, string dvar, string view, bool dark)
        {
            LispConverter.Dark = dark;
            _app._op = string.IsNullOrEmpty(op) ? "simplify" : op;
            var forms = _app.ComputeResult(text ?? "", dvar);

            if (view == "render" || view == "learn")
            {
                if (string.IsNullOrWhiteSpace(text)) return LispConverter.HelpPage();
                if (view == "learn") return LispConverter.LearnPage(string.Join("\n", forms), fromLisp: true);
                var html = LispConverter.RenderPage(string.Join("\n", forms), fromLisp: true);
                var plots = BuildPlotsOrdered(_app._srcPrepared ?? text, forms, dark, out bool anySurf);
                foreach (var ph in plots)
                    html = ReplaceFirst(html, "<div class=\"hk-plotslot\"></div>",
                        ph != null && ph.Contains("<svg") ? "<div class=\"hk-plotslot\">" + ph + "</div>" : ph ?? "");
                if (anySurf) html = html.Replace("</body>", SurfacePlot.OrbitScript + SurfacePlot.SolidScript + SurfacePlot.MapScript + "</body>");
                return html;
            }
            var sb = new StringBuilder();
            foreach (var f in forms)
            {
                if (view == "lisp") { var lv = ToLispView(f); if (lv != null) sb.AppendLine(lv); continue; }
                if (f.StartsWith("= ")) sb.AppendLine("= " + ToMathView(f.Substring(2)));
                else sb.AppendLine(ToMathView(f));
            }
            return sb.ToString().TrimEnd();
        }

        // ---- «escribo:» (mismas funciones que los botones del escritorio) ----
        [JSExport] public static string ToExprLisp(string t) => ConvertEditor(t, true);
        [JSExport] public static string ToMath(string t) => ConvertEditor(t, false);
        [JSExport] public static bool IsProgram(string t) => LooksLikeLisp(t) && IsLispProgram(t);
        [JSExport] public static string FullLisp(string t, string op) { _app._op = op; return _app.BuildFullLisp(t); }
        [JSExport] public static string HekatanLab(string t, string op) { _app._op = op; return _app.BuildRealMatlab(t); }
    }

    /// <summary>Puente al motor LISP (ECL en hlisp.wasm), cargado por main.js.</summary>
    internal static partial class WebEngine
    {
        [JSImport("run", "hlisp")]
        internal static partial string Run(string code);
    }
}
