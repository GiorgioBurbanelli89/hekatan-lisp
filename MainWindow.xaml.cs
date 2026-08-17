using System;
using System.Collections.Generic;
using System.IO;
using System.Text;
using System.Threading.Tasks;
using System.Windows;
using System.Windows.Media;
using System.Windows.Media.Imaging;
using System.Windows.Threading;
using System.Xml;
using ICSharpCode.AvalonEdit.Highlighting;
using ICSharpCode.AvalonEdit.Highlighting.Xshd;
using Microsoft.Web.WebView2.Core;

namespace HekatanLisp
{
    /// <summary>
    /// Hekatan LISP (WPF + AvalonEdit + WebView2 + motor SBCL), estilo Hekatan Lab.
    /// Autorun (Mathcad-style): convierte/ejecuta en vivo, pero SOLO cuando la linea
    /// esta completa y valida; si esta a medias, no ejecuta ni tira error, solo espera.
    /// 5 modos:
    ///   1 code->LISP  2 code->render  3 LISP->MATLAB  4 LISP->render  5 derivar (motor SBCL)
    /// Headless: --shot out.png [--mode N] | --html out.html --mode 2|4 | --ctl carpeta (tests)
    /// </summary>
    public partial class MainWindow : Window
    {
        private readonly DispatcherTimer _debounce =
            new DispatcherTimer { Interval = TimeSpan.FromMilliseconds(250) };
        private int _mode = 1;
        private string _shot, _ctl;
        private bool _webReady;
        private bool _syntaxLisp = true;   // toggle "escribo: LISP" (true) / "matemática" (false)
        private readonly HashSet<string> _ctlSeen = new HashSet<string>();

        private const string EJ_MATH = "x^2 + 3*x\r\nx + 1\r\n(x+1)^2\r\nx^2 - 2*x + 1\r\n3*x/2";

        // Ejemplo de LOOP en "matemática" estilo MATLAB (sin nombres de funciones de MATLAB):
        // la suma 1..n se hace con el for, que es la forma que se pasa a LISP.
        private const string EJ_LOOP =
            "n = 100\r\n" +
            "s = 0\r\n" +
            "for i = 1:n\r\n" +
            "  s = s + i\r\n" +
            "end\r\n" +
            "s";
        private const string EJ_LISP = "(+ (expt x 2) (* 3 x))\r\n(+ x 1)\r\n(expt (+ x 1) 2)\r\n(/ (* 3 x) 2)";

        // Modo 5 escribiendo LISP: la función COMPLETA (cómo se hace), y se llama.
        private const string EJ_EJEC =
            ";; Tú escribes la función deriv, la llamas, y SBCL la ejecuta.\r\n" +
            "(defun deriv (e x)\r\n" +
            "  (cond ((numberp e) 0)\r\n" +
            "        ((symbolp e) (if (eq e x) 1 0))\r\n" +
            "        ((eq (car e) '+)\r\n" +
            "         (list '+ (deriv (second e) x) (deriv (third e) x)))\r\n" +
            "        ((eq (car e) '*)\r\n" +
            "         (list '+ (list '* (second e) (deriv (third e) x))\r\n" +
            "                  (list '* (deriv (second e) x) (third e))))))\r\n" +
            "\r\n" +
            "(format t \"d/dx(x*x + 3x) = ~a~%\" (deriv '(+ (* x x) (* 3 x)) 'x))";

        public MainWindow()
        {
            InitializeComponent();
            Loaded += OnLoaded;
        }

        private async void OnLoaded(object sender, RoutedEventArgs e)
        {
            var args = Environment.GetCommandLineArgs();
            _shot = ValueAfter(args, "--shot");
            _ctl = ValueAfter(args, "--ctl");
            var m = ValueAfter(args, "--mode");
            if (m != null && int.TryParse(m, out var mm) && mm >= 1 && mm <= 5) _mode = mm;

            var profile = Path.Combine(Path.GetTempPath(), $"HekatanLispWV2_{Environment.ProcessId}");
            var env = await CoreWebView2Environment.CreateAsync(userDataFolder: profile);
            await Viewer.EnsureCoreWebView2Async(env);
            Viewer.CoreWebView2.Profile.PreferredColorScheme = CoreWebView2PreferredColorScheme.Dark;
            _webReady = true;

            Editor.TextChanged += (s, ev) => { _debounce.Stop(); _debounce.Start(); };
            _debounce.Tick += (s, ev) => { _debounce.Stop(); Convert(); };

            LoadHighlighting();   // resaltado AvalonEdit (LISP + matemática)
            SetMode(_mode, loadExample: true);

            if (_ctl != null) StartCtl();

            if (_shot != null)
            {
                await Task.Delay(700);
                await CaptureAndExit(_shot);
            }
        }

        /// <summary>Resaltado de sintaxis AvalonEdit (embebido, como Hekatan Fortran/Lab).</summary>
        private void LoadHighlighting()
        {
            try
            {
                using var stream = typeof(MainWindow).Assembly
                    .GetManifestResourceStream("HekatanLisp.Lisp.xshd");
                if (stream is null) return;
                using var reader = XmlReader.Create(stream);
                Editor.SyntaxHighlighting = HighlightingLoader.Load(reader, HighlightingManager.Instance);
            }
            catch { /* sin resaltado no es crítico */ }
        }

        private void OnMode1(object s, RoutedEventArgs e) => SetMode(1, true);
        private void OnMode2(object s, RoutedEventArgs e) => SetMode(2, true);
        private void OnMode3(object s, RoutedEventArgs e) => SetMode(3, true);
        private void OnMode4(object s, RoutedEventArgs e) => SetMode(4, true);
        private void OnMode5(object s, RoutedEventArgs e) => SetMode(5, true);

        private bool IsRender => _mode == 2 || _mode == 4;
        private bool FromLisp => _mode == 3 || _mode == 4;   // el modo 5 recibe matematica

        private void SetMode(int mode, bool loadExample)
        {
            int oldMode = _mode;
            _mode = mode;

            var on = (Color)ColorConverter.ConvertFromString("#4B42AD");
            var off = (Color)ColorConverter.ConvertFromString("#232833");
            Btn1.Background = new SolidColorBrush(mode == 1 ? on : off);
            Btn2.Background = new SolidColorBrush(mode == 2 ? on : off);
            Btn3.Background = new SolidColorBrush(mode == 3 ? on : off);
            Btn4.Background = new SolidColorBrush(mode == 4 ? on : off);
            Btn5.Background = new SolidColorBrush(mode == 5 ? on : off);

            LblIn.Text = (mode == 5) ? (_syntaxLisp ? "LISP (define tu función y llámala)" : "matemática")
                       : FromLisp ? "LISP" : "matemática";
            LblOut.Text = mode switch
            {
                1 => "LISP",
                2 => "render (estilo Hekatan Lab)",
                3 => "matemática",
                4 => "render (estilo Hekatan Lab)",
                _ => "resultado (ejecutado por SBCL)",
            };

            Output.Visibility = IsRender ? Visibility.Collapsed : Visibility.Visible;
            Viewer.Visibility = IsRender ? Visibility.Visible : Visibility.Collapsed;

            if (loadExample)
            {
                // REGLA: los botones NUNCA borran lo que escribiste.
                //  · editor con texto → se conserva (Calcular ejecuta ESO, no un ejemplo).
                //  · editor vacío     → se carga un ejemplo apropiado al modo.
                // Para cruzar matemática↔LISP conservando contenido, usa el botón "⇒ a LISP".
                if (string.IsNullOrWhiteSpace(Editor.Text))
                    Editor.Text = (mode == 5) ? (_syntaxLisp ? EJ_EJEC : EJ_MATH)
                                : (mode is 3 or 4) ? EJ_LISP : EJ_MATH;
            }
            Convert();   // siempre reconvierte con el texto actual (inmediato)
        }

        private void Convert()
        {
            if (IsRender)
            {
                if (_webReady)
                    Viewer.NavigateToString(LispConverter.RenderPage(Editor.Text, FromLisp));
                return;
            }
            if (_mode == 5) { ConvertCalcular(); return; }

            // Programa MATLAB (loops/funciones) -> LISP en bloque, no linea por linea
            if (_mode == 1 && MatlabToLisp.IsImperative(Editor.Text))
            {
                try { Output.Text = MatlabToLisp.Translate(Editor.Text).Lisp; }
                catch { Output.Text = "…"; }
                return;
            }

            var sb = new StringBuilder();
            foreach (var raw in Editor.Text.Replace("\r", "").Split('\n'))
            {
                var line = raw.Trim();
                if (line.Length == 0) { sb.AppendLine(); continue; }
                try
                {
                    sb.AppendLine(_mode == 1 ? LispConverter.MathToLisp(line)
                                             : LispConverter.LispToLab(line));
                }
                catch { sb.AppendLine("…"); }
            }
            Output.Text = sb.ToString().TrimEnd();
        }

        /// <summary>Modo 5 "Calcular LISP". Con el toggle:
        ///  · escribo LISP  -> ejecuta lo que YO escribí (defun + llamada) en SBCL.
        ///  · escribo matemática -> la deriv YA hecha calcula (por su nombre).
        /// Autorun inteligente: solo ejecuta si está completo (parens balanceados / línea parsea).</summary>
        private void ConvertCalcular()
        {
            var text = Editor.Text;
            if (string.IsNullOrWhiteSpace(text)) { Output.Text = ""; return; }

            // AUTODETECTA (no depende del toggle → así no hay "errores" por desajuste):
            // 1) ¿Ya es LISP?            -> ejecútalo como LISP.
            // 2) ¿Es un loop/programa?   -> tradúcelo a LISP y ejecútalo.
            // 3) Si no, son expresiones  -> pásalas a LISP y evalúalas (número si se puede).

            if (LooksLikeLisp(text))
            {
                if (!Balanced(text)) { Output.Text = "…  (completa el código: paréntesis sin cerrar)"; return; }
                if (IsLispProgram(text)) Output.Text = RunLispClean(text);   // defun/loop/let... → ejecutar
                else EvalOneLispExpr(text);                                   // una expresión → valor o simplificado
                return;
            }

            if (MatlabToLisp.IsImperative(text))
            {
                string exec;
                try { exec = MatlabToLisp.Translate(text).Executable; }
                catch (Exception ex) { Output.Text = "…  (no se pudo traducir: " + ex.Message + ")"; return; }
                Output.Text = RunLispClean(exec);
                return;
            }

            // Expresiones/operaciones: cada línea -> LISP, y su valor si es calculable.
            EvalExpressions(text);
        }

        /// <summary>¿El texto es LISP? (un '(' seguido de un operador conocido, o un comentario ';').</summary>
        private static bool LooksLikeLisp(string t)
        {
            if (t.TrimStart().StartsWith(";")) return true;
            // '(' seguido de un operador LISP conocido: una palabra (defun/let/loop/…)
            // o un símbolo de operación ( + - * / = < > ). '(x+1)' NO matchea porque tras '(' va 'x'.
            return System.Text.RegularExpressions.Regex.IsMatch(t,
                @"\(\s*((defun|defparameter|defvar|let\*?|setf|setq|loop|format|print|progn|cond|when|unless|lambda|dolist|dotimes|expt|list|vector|deriv|dsimp|simplif|and|or|not)\b|[-+*/=<>])");
        }

        /// <summary>¿El LISP es un PROGRAMA (defun/loop/let/…) y no una simple expresión?</summary>
        private static bool IsLispProgram(string t)
            => System.Text.RegularExpressions.Regex.IsMatch(t,
                @"\(\s*(defun|defparameter|defvar|let\*?|setf|setq|loop|progn|format|print|dolist|dotimes|lambda|cond|when|unless)\b");

        /// <summary>Ejecuta un PROGRAMA LISP; si no imprime nada, muestra su valor; si SBCL
        /// falla (p.ej. variable sin valor), muestra un mensaje LIMPIO, no el backtrace.</summary>
        private static string RunLispClean(string code)
        {
            const string pre = "(setf *print-case* :downcase)\n";
            var res = LispEngine.RunScript(pre + code);
            if (string.IsNullOrWhiteSpace(res))
                res = LispEngine.RunScript(pre + "(format t \"~a~%\" (progn\n" + code + "))");
            return CleanSbcl(res).TrimEnd();
        }

        /// <summary>Convierte el vólcado de error de SBCL en un mensaje corto y claro.</summary>
        private static string CleanSbcl(string s)
        {
            if (string.IsNullOrEmpty(s)) return s;
            var m = System.Text.RegularExpressions.Regex.Match(s, @"variable (\w+) is unbound",
                System.Text.RegularExpressions.RegexOptions.IgnoreCase);
            if (m.Success)
                return "⚠ la variable «" + m.Groups[1].Value.ToLower() +
                       "» no tiene valor. Asígnale un número (ej.: " + m.Groups[1].Value.ToLower() + " = 2).";
            int bt = s.IndexOf("Backtrace for:", StringComparison.Ordinal);
            if (bt >= 0)
            {
                foreach (var l in s.Substring(0, bt).Replace("\r", "").Split('\n'))
                {
                    var t = l.Trim();
                    if (t.Length > 0 && !t.StartsWith("Unhandled") && !t.Contains("thread"))
                        return "⚠ " + t;
                }
                return "⚠ error en el código LISP.";
            }
            return s;
        }

        /// <summary>Una expresión LISP (aritmética): su VALOR si es numérica, o su forma
        /// SIMPLIFICADA (matemática) si tiene incógnitas. Nunca revienta.</summary>
        private void EvalOneLispExpr(string lisp)
        {
            var r = LispEngine.EvalOrSimplify(new List<string> { lisp.Trim() });
            var v = r.Count > 0 ? r[0].Trim() : "";
            if (v.Length == 0 || v == "?") { Output.Text = lisp.Trim(); return; }
            if (IsNumber(v)) { Output.Text = v; return; }
            try { Output.Text = LispConverter.ToLab(LispConverter.ParseLisp(v), 0); }
            catch { Output.Text = v; }
        }

        /// <summary>Cada línea de matemática -> su forma LISP; y "= valor" si SBCL puede calcularlo
        /// (números). Si tiene incógnitas (x), muestra solo la forma LISP.</summary>
        private void EvalExpressions(string text)
        {
            var lines = text.Replace("\r", "").Split('\n');
            var formOf = new string[lines.Length];
            var forms = new List<string>();
            var idx = new List<int>();
            for (int i = 0; i < lines.Length; i++)
            {
                var t = lines[i].Trim();
                if (t.Length == 0) { formOf[i] = null; continue; }
                try { formOf[i] = LispConverter.MathToLisp(t); }
                catch { formOf[i] = "?"; }
                if (formOf[i] != "?") { forms.Add(formOf[i]); idx.Add(i); }
            }

            var results = LispEngine.EvalOrSimplify(forms);
            var outLine = new string[lines.Length];
            for (int k = 0; k < idx.Count; k++)
            {
                int i = idx[k];
                var r = k < results.Count ? results[k].Trim() : "";
                var mathIn = lines[i].Trim();
                if (r.Length == 0 || r == "?") { outLine[i] = formOf[i]; continue; }
                if (IsNumber(r))                       // números -> el valor
                    outLine[i] = mathIn + "   =   " + r;
                else                                    // simbólico -> forma simplificada (matemática)
                {
                    string simp;
                    try { simp = LispConverter.ToLab(LispConverter.ParseLisp(r), 0); }
                    catch { simp = r; }
                    outLine[i] = (simp == mathIn) ? mathIn : (mathIn + "   →   " + simp);
                }
            }

            var sb = new StringBuilder();
            for (int i = 0; i < lines.Length; i++)
                if (formOf[i] == null) sb.AppendLine();
                else sb.AppendLine(outLine[i] ?? formOf[i]);
            Output.Text = sb.ToString().TrimEnd();
        }

        private static bool IsNumber(string s)
            => System.Text.RegularExpressions.Regex.IsMatch(s, @"^-?\d+(/\d+)?(\.\d+)?$");

        /// <summary>Convierte cada línea entre matemática y LISP (para llevar el contenido
        /// al cambiar de botón). Las líneas que no convierten se dejan tal cual.</summary>
        private static string ReconvertLines(string text, bool toLisp)
        {
            var sb = new StringBuilder();
            foreach (var raw in text.Replace("\r", "").Split('\n'))
            {
                var line = raw.Trim();
                if (line.Length == 0) { sb.AppendLine(); continue; }
                try { sb.AppendLine(toLisp ? LispConverter.MathToLisp(line) : LispConverter.LispToLab(line)); }
                catch { sb.AppendLine(line); }
            }
            return sb.ToString().TrimEnd();
        }

        private static bool Balanced(string code)
        {
            int b = 0;
            foreach (var c in code)
            {
                if (c == '(') b++;
                else if (c == ')') { b--; if (b < 0) return false; }
            }
            return b == 0;
        }

        private void OnToggleSyntax(object s, RoutedEventArgs e)
        {
            _syntaxLisp = !_syntaxLisp;
            SyntaxToggle.Content = _syntaxLisp ? "escribo: LISP" : "escribo: matemática";
            if (_mode == 5) SetMode(5, true);   // recarga el ejemplo apropiado
            else Convert();
        }

        private void MenuEjemploLoop(object s, RoutedEventArgs e)
        {
            _syntaxLisp = false;
            SyntaxToggle.Content = "escribo: matemática";
            Editor.Text = EJ_LOOP;
            SetMode(1, false);
        }

        // ---------- canal de control --ctl (tests desde terminal) ----------
        private void StartCtl()
        {
            Directory.CreateDirectory(_ctl);
            var t = new DispatcherTimer { Interval = TimeSpan.FromMilliseconds(100) };
            t.Tick += (s, e) => PollCtl();
            t.Start();
        }

        private async void PollCtl()
        {
            foreach (var f in Directory.GetFiles(_ctl, "cmd-*.json"))
            {
                if (_ctlSeen.Contains(f)) continue;
                _ctlSeen.Add(f);
                string resp;
                try { resp = await HandleCtl(File.ReadAllText(f)); }
                catch (Exception ex) { resp = "{\"error\":\"" + ex.Message.Replace("\"", "'") + "\"}"; }
                File.WriteAllText(f.Replace("cmd-", "resp-"), resp);
            }
        }

        private async Task<string> HandleCtl(string json)
        {
            using var doc = System.Text.Json.JsonDocument.Parse(json);
            var op = doc.RootElement.GetProperty("op").GetString();
            switch (op)
            {
                case "settext":
                    Editor.Text = doc.RootElement.GetProperty("text").GetString();
                    Convert();
                    return "{\"ok\":true}";
                case "mode":
                    SetMode(doc.RootElement.GetProperty("n").GetInt32(), false);
                    return "{\"ok\":true,\"mode\":" + _mode + "}";
                case "clickmode":   // como pulsar el botón de modo (SetMode con loadExample=true)
                    SetMode(doc.RootElement.GetProperty("n").GetInt32(), true);
                    return "{\"ok\":true,\"mode\":" + _mode + "}";
                case "getoutput":
                    // en modos de render la salida vive en el WebView2, no en Output
                    if (IsRender && _webReady && Viewer.CoreWebView2 is not null)
                    {
                        var t = await Viewer.ExecuteScriptAsync("(document.body?document.body.innerText:'')");
                        return "{\"ok\":true,\"output\":" + (string.IsNullOrEmpty(t) ? "\"\"" : t) + "}";
                    }
                    return System.Text.Json.JsonSerializer.Serialize(new { output = Output.Text });
                case "gettext":
                    return System.Text.Json.JsonSerializer.Serialize(new { input = Editor.Text });
                case "syntax":   // elige escribir LISP (true) o matemática/MATLAB (false)
                    _syntaxLisp = doc.RootElement.GetProperty("lisp").GetBoolean();
                    SyntaxToggle.Content = _syntaxLisp ? "escribo: LISP" : "escribo: matemática";
                    Convert();
                    return "{\"ok\":true,\"lisp\":" + (_syntaxLisp ? "true" : "false") + "}";
                case "state":
                    return System.Text.Json.JsonSerializer.Serialize(new { mode = _mode, lisp = _syntaxLisp });
                case "hashl":   // ¿está cargado el resaltado AvalonEdit?
                    return System.Text.Json.JsonSerializer.Serialize(new
                    { hl = Editor.SyntaxHighlighting?.Name });
                case "quit":
                    Application.Current.Shutdown();
                    return "{\"ok\":true}";
                default:
                    return "{\"error\":\"op desconocida\"}";
            }
        }

        // ---------- captura headless ----------
        private async Task CaptureAndExit(string path)
        {
            try
            {
                if (IsRender)
                {
                    await Task.Delay(400);
                    var json = await Viewer.CoreWebView2.CallDevToolsProtocolMethodAsync(
                        "Page.captureScreenshot", "{\"format\":\"png\",\"captureBeyondViewport\":true}");
                    using var doc = System.Text.Json.JsonDocument.Parse(json);
                    var b64 = doc.RootElement.GetProperty("data").GetString() ?? "";
                    File.WriteAllBytes(path, System.Convert.FromBase64String(b64));
                }
                else
                {
                    var rtb = new RenderTargetBitmap((int)ActualWidth, (int)ActualHeight, 96, 96, PixelFormats.Pbgra32);
                    rtb.Render(this);
                    var enc = new PngBitmapEncoder();
                    enc.Frames.Add(BitmapFrame.Create(rtb));
                    using var fs = File.Create(path);
                    enc.Save(fs);
                }
            }
            catch (Exception ex) { File.WriteAllText(Path.ChangeExtension(path, ".error.txt"), ex.ToString()); }
            finally { Application.Current.Shutdown(); }
        }

        // ---------- calculadora de simbolos + menus ----------
        /// <summary>Inserta el Tag del boton en el editor. "§§" marca donde queda el cursor.</summary>
        private void OnInsert(object sender, RoutedEventArgs e)
        {
            var tag = (sender as FrameworkElement)?.Tag as string;
            if (string.IsNullOrEmpty(tag)) return;
            // Tag "formaLISP|formaMatemática": elige según el toggle.
            if (tag.Contains("|"))
            {
                var alt = tag.Split('|');
                tag = (_syntaxLisp || alt.Length < 2) ? alt[0] : alt[1];
            }
            var caret = Editor.CaretOffset;
            if (tag.Contains("§§"))
            {
                var parts = tag.Split(new[] { "§§" }, StringSplitOptions.None);
                Editor.Document.Insert(caret, parts[0] + parts[1]);
                Editor.CaretOffset = caret + parts[0].Length;
            }
            else
            {
                Editor.Document.Insert(caret, tag);
                Editor.CaretOffset = caret + tag.Length;
            }
            Editor.Focus();
        }

        private void MenuNuevo(object s, RoutedEventArgs e) => Editor.Text = "";
        private void MenuEjemplo(object s, RoutedEventArgs e) => Editor.Text = FromLisp ? EJ_LISP : EJ_MATH;
        private void MenuSalir(object s, RoutedEventArgs e) => Close();
        private void MenuAbout(object s, RoutedEventArgs e) =>
            MessageBox.Show(
                "Hekatan LISP\n\nEditor simbólico para practicar: matemática ↔ LISP ↔ MATLAB,\ncon render estilo Hekatan Lab y motor SBCL que deriva de verdad.",
                "Acerca de Hekatan LISP");

        private static string ValueAfter(string[] a, string flag)
        {
            for (int i = 1; i < a.Length - 1; i++)
                if (string.Equals(a[i], flag, StringComparison.OrdinalIgnoreCase))
                    return a[i + 1];
            return null;
        }
    }
}
