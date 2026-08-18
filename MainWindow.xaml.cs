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
    /// Modelo simple: IZQUIERDA = lo que escribes (matemática, o LISP con el toggle).
    /// DERECHA = el RESULTADO, mostrado en el formato que elijas:
    ///   · Render CSS (por defecto)  · LISP  · Matemática.
    /// El resultado = la expresión evaluada (números), el valor del loop, o la forma
    /// simplificada si es simbólica. Vive en vivo (autorun).
    /// Headless: --shot out.png [--view render|lisp|math] | --ctl carpeta (tests).
    /// </summary>
    public partial class MainWindow : Window
    {
        private readonly DispatcherTimer _debounce =
            new DispatcherTimer { Interval = TimeSpan.FromMilliseconds(280) };
        private string _view = "render";           // formato DERECHA: "render" | "lisp" | "math"
        private string _op = "auto";               // operación: "auto" | "simplify" | "expand" | "deriv"
        private bool _autoRun = true;              // AutoRun (en vivo) como Hekatan Lab; si off, se usa ▶/F5
        private string _shot, _ctl;
        private bool _webReady;
        private bool _syntaxLisp = false;          // toggle de ENTRADA: escribo matemática (false) / LISP (true)
        private bool _ranProgram = false;          // el último resultado vino de EJECUTAR un programa (stdout de consola)
        private readonly HashSet<string> _ctlSeen = new HashSet<string>();

        private const string EJ_MATH = "x^2 + 3*x\r\nsqrt(x) + sin(x)\r\n[1 2 3]\r\n[1 2; 3 4]\r\n3*x/2";
        private const string EJ_LOOP =
            "n = 100\r\ns = 0\r\nfor i = 1:n\r\n  s = s + i\r\nend\r\ns";
        private const string EJ_LISP = "(+ (expt x 2) (* 3 x))\r\n(* 2 (expt x 2))\r\n(+ 2 (* 3 4))";

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
            var v = ValueAfter(args, "--view");
            if (v is "render" or "lisp" or "math") _view = v;
            var o = ValueAfter(args, "--op");
            if (o is "auto" or "simplify" or "expand" or "deriv") _op = o;

            var profile = Path.Combine(Path.GetTempPath(), $"HekatanLispWV2_{Environment.ProcessId}");
            var env = await CoreWebView2Environment.CreateAsync(userDataFolder: profile);
            await Viewer.EnsureCoreWebView2Async(env);
            Viewer.CoreWebView2.Profile.PreferredColorScheme = CoreWebView2PreferredColorScheme.Dark;
            _webReady = true;

            Editor.TextChanged += (s, ev) => { _debounce.Stop(); _debounce.Start(); };
            _debounce.Tick += (s, ev) => { _debounce.Stop(); if (_autoRun) ShowResult(); };
            KeyDown += (s, ev) => { if (ev.Key == System.Windows.Input.Key.F5) { ShowResult(); ev.Handled = true; } };

            LoadHighlighting();
            SyntaxToggle.Content = _syntaxLisp ? "escribo: LISP" : "escribo: matemática";
            if (string.IsNullOrWhiteSpace(Editor.Text)) Editor.Text = EJ_MATH;
            SetView(_view);
            SetOp(_op);

            if (_ctl != null) StartCtl();
            if (_shot != null) { await Task.Delay(700); await CaptureAndExit(_shot); }
        }

        /// <summary>Resaltado de sintaxis AvalonEdit (embebido, como Hekatan Fortran/Lab).</summary>
        private void LoadHighlighting()
        {
            try
            {
                using var stream = typeof(MainWindow).Assembly.GetManifestResourceStream("HekatanLisp.Lisp.xshd");
                if (stream is null) return;
                using var reader = XmlReader.Create(stream);
                Editor.SyntaxHighlighting = HighlightingLoader.Load(reader, HighlightingManager.Instance);
            }
            catch { }
        }

        // ---------- selector de formato de la DERECHA ----------
        private void OnViewRender(object s, RoutedEventArgs e) => SetView("render");
        private void OnViewLisp(object s, RoutedEventArgs e) => SetView("lisp");
        private void OnViewMath(object s, RoutedEventArgs e) => SetView("math");

        private void SetView(string view)
        {
            _view = view;
            var on = (Color)ColorConverter.ConvertFromString("#4B42AD");
            var off = (Color)ColorConverter.ConvertFromString("#232833");
            BtnRender.Background = new SolidColorBrush(view == "render" ? on : off);
            BtnLisp.Background = new SolidColorBrush(view == "lisp" ? on : off);
            BtnMath.Background = new SolidColorBrush(view == "math" ? on : off);

            LblIn.Text = _syntaxLisp ? "escribes: LISP" : "escribes: matemática";
            LblOut.Text = view switch
            {
                "render" => "resultado — render CSS",
                "lisp" => "resultado — forma LISP",
                _ => "resultado — matemática",
            };
            ShowResult();
        }

        // ---------- calcula el RESULTADO y lo muestra en el formato elegido ----------
        // El resultado es SIEMPRE una forma LISP canónica (o número/mensaje); la DERECHA
        // la muestra como render / LISP / matemática. La OPERACIÓN (auto/simplify/expand/deriv)
        // es SEPARADA: 'auto' NO simplifica, deja la expresión tal cual (o su valor si es número).
        private bool IsRenderView => _view == "render";

        private void ShowResult()
        {
            var forms = ComputeResult();   // formas LISP canónicas (o números/mensajes)
            Output.Visibility = IsRenderView ? Visibility.Collapsed : Visibility.Visible;
            Viewer.Visibility = IsRenderView ? Visibility.Visible : Visibility.Collapsed;

            if (IsRenderView)
            {
                if (!_webReady) return;
                // Un PROGRAMA imprime texto de consola (format/print) -> no es una fórmula:
                // se muestra como consola (<pre>), no se pasa por el renderizador de expresiones.
                if (_ranProgram) Viewer.NavigateToString(ConsolePage(string.Join("\n", forms)));
                else Viewer.NavigateToString(LispConverter.RenderPage(string.Join("\n", forms), fromLisp: true));
                return;
            }
            var sb = new StringBuilder();
            foreach (var f in forms)
            {
                if (_view == "lisp") { sb.AppendLine(f); continue; }   // LISP tal cual (incluye "= …")
                if (f.StartsWith("= ")) sb.AppendLine("= " + ToMathView(f.Substring(2)));
                else sb.AppendLine(ToMathView(f));
            }
            Output.Text = sb.ToString().TrimEnd();
        }

        /// <summary>Salida de un PROGRAMA (stdout) como página de consola (monospace), tema oscuro.</summary>
        private static string ConsolePage(string text)
        {
            var esc = (text ?? "").Replace("&", "&amp;").Replace("<", "&lt;").Replace(">", "&gt;");
            return "<!doctype html><html><head><meta charset='utf-8'><style>" +
                   "html,body{margin:0;background:#1e1e1e;color:#d4d4d4}" +
                   "pre{margin:0;padding:14px 16px;white-space:pre-wrap;word-break:break-word;" +
                   "font-family:Consolas,'Cascadia Code',monospace;font-size:14px;line-height:1.5}" +
                   "</style></head><body><pre>" + esc + "</pre></body></html>";
        }

        /// <summary>Una forma LISP del resultado → matemática legible (o tal cual si no parsea).</summary>
        private static string ToMathView(string lispForm)
        {
            if (string.IsNullOrWhiteSpace(lispForm)) return "";
            if (lispForm.StartsWith("⚠") || lispForm.StartsWith("…")) return lispForm;
            try { return LispConverter.ToLab(LispConverter.ParseLisp(lispForm), 0); } catch { return lispForm; }
        }

        /// <summary>El RESULTADO como FORMAS LISP. Autodetecta programa (ejecuta) vs expresiones
        /// (les aplica la operación elegida: auto/simplify/expand/deriv).</summary>
        private List<string> ComputeResult()
        {
            var text = Editor.Text;
            _ranProgram = false;
            if (string.IsNullOrWhiteSpace(text)) return new List<string>();

            // Programas: LISP (defun/loop/let) o matemática imperativa (for/while) → EJECUTAR.
            if (LooksLikeLisp(text) && IsLispProgram(text))
            {
                if (!Balanced(text)) return new List<string> { "…  (paréntesis sin cerrar)" };
                _ranProgram = true;
                return new List<string> { RunLispClean(text) };
            }
            if (!LooksLikeLisp(text) && MatlabToLisp.IsImperative(text))
            {
                _ranProgram = true;
                try { return new List<string> { RunLispClean(MatlabToLisp.Translate(text).Executable) }; }
                catch (Exception ex) { return new List<string> { "…  (" + ex.Message + ")" }; }
            }

            // Expresiones (matemática o LISP) → aplicar la operación elegida.
            var lines = text.Replace("\r", "").Split('\n');
            var formOf = new string[lines.Length];
            var forms = new List<string>();
            var idx = new List<int>();
            for (int i = 0; i < lines.Length; i++)
            {
                formOf[i] = LispFormOfLine(lines[i]);
                if (formOf[i] != null) { forms.Add(formOf[i]); idx.Add(i); }
            }
            var results = LispEngine.EvalOp(forms, _op);
            var resOf = new string[lines.Length];
            for (int k = 0; k < idx.Count; k++) resOf[idx[k]] = k < results.Count ? results[k].Trim() : "";

            // Muestra el CÁLCULO: la ENTRADA y, debajo, "= RESULTADO" (solo si cambió).
            var display = new List<string>();
            for (int i = 0; i < lines.Length; i++)
            {
                if (formOf[i] == null) { display.Add(""); continue; }
                display.Add(formOf[i]);
                var r = resOf[i] ?? "";
                if (r.Length > 0 && !r.Equals("nil", StringComparison.OrdinalIgnoreCase) && r != formOf[i])
                    display.Add("= " + r);
            }
            return display;
        }

        /// <summary>La línea (matemática o LISP) → su forma LISP; null si está vacía o no parsea.</summary>
        private static string LispFormOfLine(string line)
        {
            line = line.Trim();
            if (line.Length == 0) return null;
            if (LooksLikeLisp(line)) return line;             // ya es LISP
            try { return LispConverter.MathToLisp(line); } catch { return null; }
        }

        // ---------- motor: expresiones y programas ----------
        private static bool LooksLikeLisp(string t)
        {
            if (t.TrimStart().StartsWith(";")) return true;
            return System.Text.RegularExpressions.Regex.IsMatch(t,
                @"\(\s*((defun|defparameter|defvar|let\*?|setf|setq|loop|format|print|progn|cond|when|unless|lambda|dolist|dotimes|expt|list|vector|deriv|dsimp|simplif|and|or|not)\b|[-+*/=<>])");
        }

        private static bool IsLispProgram(string t)
            => System.Text.RegularExpressions.Regex.IsMatch(t,
                @"\(\s*(defun|defparameter|defvar|let\*?|setf|setq|loop|progn|format|print|dolist|dotimes|lambda|cond|when|unless)\b");

        private static string RunLispClean(string code)
        {
            const string pre = "(setf *print-case* :downcase)\n";
            var res = LispEngine.RunScript(pre + code);
            if (string.IsNullOrWhiteSpace(res))
                res = LispEngine.RunScript(pre + "(format t \"~a~%\" (progn\n" + code + "))");
            return CleanSbcl(res).TrimEnd();
        }

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
                    if (t.Length > 0 && !t.StartsWith("Unhandled") && !t.Contains("thread")) return "⚠ " + t;
                }
                return "⚠ error en el código LISP.";
            }
            return s;
        }

        // ---------- ▶ Ejecutar (manual) + AutoRun (en vivo), como Hekatan Lab ----------
        private void OnRun(object s, RoutedEventArgs e) => ShowResult();   // ejecuta ahora (también F5)

        private void OnAutoRun(object s, RoutedEventArgs e)
        {
            if (!IsLoaded) { _autoRun = ChkAutoRun.IsChecked == true; return; }  // durante InitializeComponent, no tocar UI
            _autoRun = ChkAutoRun.IsChecked == true;
            if (_autoRun) ShowResult();   // al reactivar, refresca ya
        }

        // ---------- selector de OPERACIÓN (separada del formato) ----------
        private void OnOpAuto(object s, RoutedEventArgs e) => SetOp("auto");
        private void OnOpSimplify(object s, RoutedEventArgs e) => SetOp("simplify");
        private void OnOpExpand(object s, RoutedEventArgs e) => SetOp("expand");
        private void OnOpDeriv(object s, RoutedEventArgs e) => SetOp("deriv");

        private void SetOp(string op)
        {
            _op = op;
            var on = (Color)ColorConverter.ConvertFromString("#4B42AD");
            var off = (Color)ColorConverter.ConvertFromString("#1B1E24");
            OpAuto.Background = new SolidColorBrush(op == "auto" ? on : off);
            OpSimplify.Background = new SolidColorBrush(op == "simplify" ? on : off);
            OpExpand.Background = new SolidColorBrush(op == "expand" ? on : off);
            OpDeriv.Background = new SolidColorBrush(op == "deriv" ? on : off);
            ShowResult();
        }

        private static bool Balanced(string code)
        {
            int b = 0;
            foreach (var c in code) { if (c == '(') b++; else if (c == ')') { b--; if (b < 0) return false; } }
            return b == 0;
        }

        private void OnToggleSyntax(object s, RoutedEventArgs e) => SetSyntax(!_syntaxLisp);

        /// <summary>Cambia la forma de la IZQUIERDA y CONVIERTE el contenido a esa forma
        /// (matemática ↔ LISP). El "por qué": si eliges "escribo: LISP", la ventana izquierda
        /// debe verse en LISP, no seguir en matemática.</summary>
        private void SetSyntax(bool toLisp)
        {
            Editor.Text = ConvertEditor(Editor.Text, toLisp);
            _syntaxLisp = toLisp;
            SyntaxToggle.Content = toLisp ? "escribo: LISP" : "escribo: matemática";
            LblIn.Text = toLisp ? "escribes: LISP" : "escribes: matemática";
            ShowResult();
        }

        private static string ConvertEditor(string text, bool toLisp)
        {
            if (string.IsNullOrWhiteSpace(text)) return text;
            if (toLisp && !LooksLikeLisp(text) && MatlabToLisp.IsImperative(text))
            {   // programa matemático (for/while) → LISP en bloque
                try { return MatlabToLisp.Translate(text).Lisp; } catch { return text; }
            }
            var sb = new StringBuilder();
            foreach (var raw in text.Replace("\r", "").Split('\n'))
            {
                var l = raw.Trim();
                if (l.Length == 0) { sb.AppendLine(); continue; }
                bool isLisp = LooksLikeLisp(l);
                try
                {
                    if (toLisp) sb.AppendLine(isLisp ? l : LispConverter.MathToLisp(l));
                    else sb.AppendLine(isLisp ? LispConverter.ToLab(LispConverter.ParseLisp(l), 0) : l);
                }
                catch { sb.AppendLine(l); }
            }
            return sb.ToString().TrimEnd();
        }

        private void MenuEjemploLoop(object s, RoutedEventArgs e)
        {
            _syntaxLisp = false;
            SyntaxToggle.Content = "escribo: matemática";
            Editor.Text = EJ_LOOP;
            SetView(_view);
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
                    ShowResult();
                    return "{\"ok\":true}";
                case "view":     // formato de la derecha: render|lisp|math
                    SetView(doc.RootElement.GetProperty("name").GetString());
                    return "{\"ok\":true,\"view\":\"" + _view + "\"}";
                case "op":       // operación: auto|simplify|expand|deriv
                    SetOp(doc.RootElement.GetProperty("name").GetString());
                    return "{\"ok\":true,\"op\":\"" + _op + "\"}";
                case "autorun":  // enciende/apaga AutoRun (en vivo)
                    ChkAutoRun.IsChecked = doc.RootElement.GetProperty("on").GetBoolean();
                    return "{\"ok\":true,\"autorun\":" + (_autoRun ? "true" : "false") + "}";
                case "run":      // pulsa ▶ Ejecutar (o F5)
                    ShowResult();
                    return "{\"ok\":true}";
                case "getoutput":
                    if (IsRenderView && _webReady && Viewer.CoreWebView2 is not null)
                    {
                        var t = await Viewer.ExecuteScriptAsync("(document.body?document.body.innerText:'')");
                        return "{\"ok\":true,\"output\":" + (string.IsNullOrEmpty(t) ? "\"\"" : t) + "}";
                    }
                    return System.Text.Json.JsonSerializer.Serialize(new { output = Output.Text });
                case "gettext":
                    return System.Text.Json.JsonSerializer.Serialize(new { input = Editor.Text });
                case "syntax":   // cambia la IZQUIERDA a LISP/matemática (convierte el contenido)
                    SetSyntax(doc.RootElement.GetProperty("lisp").GetBoolean());
                    return "{\"ok\":true,\"lisp\":" + (_syntaxLisp ? "true" : "false") + "}";
                case "state":
                    return System.Text.Json.JsonSerializer.Serialize(new { view = _view, op = _op, lisp = _syntaxLisp, autorun = _autoRun });
                case "hashl":
                    return System.Text.Json.JsonSerializer.Serialize(new { hl = Editor.SyntaxHighlighting?.Name });
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
                if (IsRenderView)
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
        private void OnInsert(object sender, RoutedEventArgs e)
        {
            var tag = (sender as FrameworkElement)?.Tag as string;
            if (string.IsNullOrEmpty(tag)) return;
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
            else { Editor.Document.Insert(caret, tag); Editor.CaretOffset = caret + tag.Length; }
            Editor.Focus();
        }

        private void MenuReglas(object s, RoutedEventArgs e) =>
            MessageBox.Show(
                "REGLAS DEL LENGUAJE LISP (para tus comentarios)\n\n" +
                "1. TODO es una lista:  (operador  arg1  arg2)\n" +
                "     (+ 2 3) = 2+3 = 5      (* (+ 1 2) 3) = 9\n" +
                "2. Notación PREFIJA: el operador va PRIMERO (no 2 + 3, sino (+ 2 3)).\n" +
                "3. Los PARÉNTESIS mandan: no hay precedencia ambigua.\n" +
                "4. CÓDIGO = DATOS (homoiconicidad): '(+ 2 3) es una LISTA que puedes tocar.\n" +
                "5. quote (')  CONGELA:  'x = el símbolo x sin evaluar.\n" +
                "6. eval  ejecuta datos como código:  (eval '(+ 2 3)) = 5.\n" +
                "7. REPL = Read (lee texto→lista) · Eval (calcula) · Print (muestra).\n" +
                "8. MOSTRAR:  (print x)   (format t \"~a~%\" x)   (write x)\n" +
                "9. Definir función:  (defun f (x)  cuerpo )\n" +
                "10. Variables locales:  (let ((x 1) (y 2))  ... )\n" +
                "11. Listas:  car = primero · cdr = resto · cons = agrega.\n" +
                "12. La RECURSIÓN es la forma natural de iterar (además de loop).\n" +
                "13. Los símbolos NO distinguen mayúsculas por defecto:  x = X.\n\n" +
                "Por eso LISP es ideal para lo simbólico: la fórmula ES una lista y las\n" +
                "operaciones (derivar, simplificar) sólo recorren y reescriben esa lista.",
                "Reglas de LISP");

        private void MenuNuevo(object s, RoutedEventArgs e) => Editor.Text = "";
        private void MenuEjemplo(object s, RoutedEventArgs e) => Editor.Text = _syntaxLisp ? EJ_LISP : EJ_MATH;
        private void MenuSalir(object s, RoutedEventArgs e) => Close();
        private void MenuAbout(object s, RoutedEventArgs e) =>
            MessageBox.Show(
                "Hekatan LISP\n\nEscribes matemática a la izquierda; el resultado sale a la derecha\nen render CSS, LISP o matemática. Motor SBCL embebido.",
                "Acerca de Hekatan LISP");

        private static string ValueAfter(string[] a, string flag)
        {
            for (int i = 1; i < a.Length - 1; i++)
                if (string.Equals(a[i], flag, StringComparison.OrdinalIgnoreCase)) return a[i + 1];
            return null;
        }
    }
}
