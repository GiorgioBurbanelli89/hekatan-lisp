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
                // Los botones LLEVAN tu contenido en vez de borrarlo:
                //  · mismo tipo (matemática 1↔2, LISP 3↔4) → se conserva tal cual.
                //  · cruce matemática↔LISP → se convierte línea por línea (no se pierde).
                //  · editor vacío, o desde/hacia el modo 5 (ejecutar) → se carga el ejemplo.
                bool oldMath = oldMode is 1 or 2, oldLisp = oldMode is 3 or 4;
                bool newLisp = mode is 3 or 4;
                var cur = Editor.Text;

                if (mode == 5)
                    Editor.Text = _syntaxLisp ? EJ_EJEC : EJ_MATH;
                else if (string.IsNullOrWhiteSpace(cur) || oldMode == 5)
                    Editor.Text = newLisp ? EJ_LISP : EJ_MATH;
                else if ((oldMath && mode is 1 or 2) || (oldLisp && mode is 3 or 4))
                    { /* mismo tipo: conservar el texto tal cual */ }
                else if (oldMath && newLisp)
                    Editor.Text = ReconvertLines(cur, toLisp: true);
                else if (oldLisp && mode is 1 or 2)
                    Editor.Text = ReconvertLines(cur, toLisp: false);
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
            if (_syntaxLisp)
            {
                var code = Editor.Text;
                if (string.IsNullOrWhiteSpace(code) || !Balanced(code))
                {
                    Output.Text = "…  (completa el código: paréntesis sin cerrar)";
                    return;
                }
                const string pre = "(setf *print-case* :downcase)\n";
                var res = LispEngine.RunScript(pre + code);
                // Si el código no imprimió nada pero DEVUELVE un valor (un (let* ...), (suma 100), 3+4...)
                // lo mostramos. El "por qué": en LISP el valor no se ve salvo que lo imprimas.
                if (string.IsNullOrWhiteSpace(res))
                    res = LispEngine.RunScript(pre + "(format t \"~a~%\" (progn\n" + code + "))");
                Output.Text = res.TrimEnd();
                return;
            }

            // escribo matemática: si es un PROGRAMA (loop/función), tradúcelo a LISP y EJECÚTALO.
            // El "por qué": Jorge escribe el for como en MATLAB; aquí se corre de verdad en SBCL.
            if (MatlabToLisp.IsImperative(Editor.Text))
            {
                string exec;
                try { exec = MatlabToLisp.Translate(Editor.Text).Executable; }
                catch (Exception ex) { Output.Text = "…  (no se pudo traducir: " + ex.Message + ")"; return; }
                Output.Text = LispEngine.RunScript("(setf *print-case* :downcase)\n" + exec).TrimEnd();
                return;
            }

            // escribo matemática (expresiones sueltas): la deriv ya hecha deriva cada línea
            var lines = Editor.Text.Replace("\r", "").Split('\n');
            var outLines = new string[lines.Length];
            var lisp = new List<string>();
            var idx = new List<int>();
            for (int i = 0; i < lines.Length; i++)
            {
                var line = lines[i].Trim();
                if (line.Length == 0) { outLines[i] = ""; continue; }
                LispConverter.N tree = null;
                try { tree = LispConverter.ParseMath(line); }
                catch { outLines[i] = "…"; continue; }
                if (tree == null) { outLines[i] = ""; continue; }
                lisp.Add(LispConverter.ToLisp(tree));
                idx.Add(i);
            }
            if (lisp.Count > 0)
            {
                var res = LispEngine.DeriveBatch(lisp);
                for (int k = 0; k < idx.Count && k < res.Count; k++)
                {
                    string disp;
                    try { disp = LispConverter.ToLab(LispConverter.ParseLisp(res[k]), 0); }
                    catch { disp = res[k]; }
                    outLines[idx[k]] = "d/dx = " + disp;
                }
            }
            var sb = new StringBuilder();
            foreach (var l in outLines) sb.AppendLine(l ?? "");
            Output.Text = sb.ToString().TrimEnd();
        }

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

        /// <summary>Botón "⇒ a LISP": pasa la matemática (loops, funciones, expresiones) a su
        /// forma LISP en el editor y la ejecuta (modo Calcular). Es el "cambiar a forma LISP".</summary>
        private void OnToLisp(object s, RoutedEventArgs e)
        {
            var text = Editor.Text;
            if (string.IsNullOrWhiteSpace(text)) return;
            string lisp;
            try
            {
                lisp = MatlabToLisp.IsImperative(text)
                     ? MatlabToLisp.Translate(text).Lisp
                     : ReconvertLines(text, toLisp: true);
            }
            catch { return; }
            Editor.Text = lisp;
            _syntaxLisp = true;
            SyntaxToggle.Content = "escribo: LISP";
            SetMode(5, false);   // muestra el LISP a la izquierda y el resultado (SBCL) a la derecha
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
                case "tolisp":   // pulsa el botón "⇒ a LISP"
                    OnToLisp(null, null);
                    return System.Text.Json.JsonSerializer.Serialize(new { input = Editor.Text, output = Output.Text });
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
