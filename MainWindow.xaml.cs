using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Windows;
using System.Windows.Controls;
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
        private bool _autoRun = true;              // AutoRun (en vivo) como Hekatan Lab; si off, se usa ▶/F5
        private string _shot, _ctl, _pdf, _html, _latex;
        private string _lastHtml;   // último HTML renderizado (para --html: Hekatan School)
        private bool _webReady;
        private bool _syntaxLisp = false;          // toggle de ENTRADA: escribo matemática (false) / LISP (true)
        private bool _dark = false;                // tema: oscuro (true) / claro (false). Arranca CLARO, como la UI XAML
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
            _pdf = ValueAfter(args, "--pdf");
            _ctl = ValueAfter(args, "--ctl");
            _html = ValueAfter(args, "--html");   // vuelca el HTML REAL del render (para Hekatan School)
            // --latex: las MISMAS expresiones, en LaTeX. Manim necesita las letras como
            // vectores para transformar una formula en la siguiente; un PNG solo se funde.
            _latex = ValueAfter(args, "--latex");
            if (_pdf != null || _html != null || _latex != null) _view = "render";
            var v = ValueAfter(args, "--view");
            if (v is "render" or "lisp" or "math") _view = v;
            var o = ValueAfter(args, "--op");
            if (o is "auto" or "simplify" or "expand" or "deriv" or "integ") _op = o;
            // el botón dorado tiene que decir la verdad desde el primer segundo
            try { SetOp(_op); } catch { }

            var profile = Path.Combine(Path.GetTempPath(), $"HekatanLispWV2_{Environment.ProcessId}");
            var env = await CoreWebView2Environment.CreateAsync(userDataFolder: profile);
            await Viewer.EnsureCoreWebView2Async(env);
            Viewer.CoreWebView2.Profile.PreferredColorScheme =
                _dark ? CoreWebView2PreferredColorScheme.Dark : CoreWebView2PreferredColorScheme.Light;
            _webReady = true;
            InstalarDibujo();   // guardar dibujo: DWG con acadrust (Node), PNG desde la página

            Editor.TextChanged += (s, ev) =>
            {
                if (_reprSwitch) return;   // solo cambió la REPRESENTACIÓN izquierda → NO recalcular la derecha
                _transliterated = false;
                if (LblIn != null && LblIn.Text.Contains("aprox"))   // quita la etiqueta pegada de "MATLAB aprox"
                    LblIn.Text = _syntaxLisp ? "escribes: expresión LISP (símbolo — NO ejecutable; para correr usa «LISP completo»)" : "escribes: texto plano";
                _debounce.Stop(); _debounce.Start();
            };
            _debounce.Tick += (s, ev) => { _debounce.Stop(); if (_autoRun) ShowResult(); AutoSaveTemp(); };
            KeyDown += (s, ev) =>
            {
                if (ev.Key == System.Windows.Input.Key.F5) { ShowResult(); ev.Handled = true; }
                // Ctrl+S = Guardar (al archivo actual, sin volver a preguntar)
                else if (ev.Key == System.Windows.Input.Key.S
                         && (System.Windows.Input.Keyboard.Modifiers & System.Windows.Input.ModifierKeys.Control) != 0)
                { MenuGuardar(this, null); ev.Handled = true; }
            };

            LoadHighlighting();
            HighlightSyntax();
            Editor.TextArea.TextEntered += OnTextEntered;   // autocompletar símbolos LISP
            Editor.PreviewMouseWheel += OnCtrlZoom;          // Ctrl+rueda = zoom (como el render)
            Output.PreviewMouseWheel += OnCtrlZoom;
            PoblarEjemplos();                                // menú Ejemplos ← carpeta ejemplos/
            // --in <archivo>: carga ese .lisp en el editor (útil con --shot para capturar un contenido dado)
            // --dark / --oscuro: saca el render en TEMA OSCURO (hace falta para los
            // videos de fondo oscuro; sin esto solo se podia cambiar desde la ventana).
            if (System.Array.Exists(args, x => string.Equals(x, "--dark", StringComparison.OrdinalIgnoreCase)
                                            || string.Equals(x, "--oscuro", StringComparison.OrdinalIgnoreCase)))
            { _dark = true; LispConverter.Dark = true; }
            // El fichero puede venir con `--in ruta` o SUELTO (`HekatanLisp.exe hoja.lisp`,
            // que es lo que pasa al abrirlo con doble clic o al arrastrarlo encima).
            var inFile = ValueAfter(args, "--in");
            if (inFile == null)
                for (int i = 1; i < args.Length; i++)
                {
                    var a_ = args[i];
                    if (a_.StartsWith("-")) { if (ValueAfter(args, a_) != null) i++; continue; }
                    var ex_ = Path.GetExtension(a_).ToLowerInvariant();
                    if ((ex_ == ".lisp" || ex_ == ".hlisp" || ex_ == ".m" || ex_ == ".txt") && File.Exists(a_))
                    { inFile = a_; break; }
                }
            if (inFile != null) { try { if (File.Exists(inFile)) { var it = File.ReadAllText(inFile); if (string.Equals(Path.GetExtension(inFile), ".m", StringComparison.OrdinalIgnoreCase)) it = LispConverter.MatlabToHlisp(it); Editor.Text = it; SetCurrentFile(inFile); } } catch { } }
            if (string.IsNullOrWhiteSpace(Editor.Text))
            {
                // arranque normal: recupera el trabajo NO guardado del respaldo temporal (si existe)
                string recup = null;
                if (_ctl == null && _shot == null)
                    try { if (File.Exists(AutoSavePath)) recup = File.ReadAllText(AutoSavePath); } catch { }
                Editor.Text = !string.IsNullOrWhiteSpace(recup) ? recup : EJ_MATH;
            }
            ApplyTheme(_dark);   // sincroniza UI + render (LispConverter.Dark) al arrancar; llama SetView/SetOp

            // Abrir una hoja YA LA CORRE, sin tocar el ▶ (Jorge, 16-sep-2026: «pongo un
            // script y no ejecuta»). Hekatan Lab y Hekatan Py ya lo hacían al abrir un
            // fichero por línea de órdenes; aquí solo se cargaba el texto en el editor y
            // se quedaba esperando. Se respeta el interruptor AutoRun.
            // También en --shot/--pdf/--html: son los modos con los que se COMPRUEBA que
            // la hoja sale bien, y sin calcular salía la página en blanco.
            if (inFile != null && _autoRun)
                ShowResult();

            if (_ctl != null) StartCtl();
            // --shot espera el CÁLCULO (como --pdf): una hoja larga (ejemplo 82, ~5 s) salía «calculando…»
            //  (el TextChanged del editor relanza el cálculo tras el debounce: se espera también ese)
            if (_shot != null)
            {
                for (int k = 0; k < 3; k++) { try { if (_showTask != null) await _showTask; } catch { } await Task.Delay(k == 0 ? 700 : 400); }
                await CaptureAndExit(_shot);
            }
            if (_pdf != null)
            {   // espera el CÁLCULO (hojas largas tardan más de 1 s: salía el PDF de la hoja anterior/vacía)
                try { if (_showTask != null) await _showTask; } catch { }
                await Task.Delay(1500);
                await PrintPdfAndExit(Path.GetFullPath(_pdf));   // WebView2 exige ruta absoluta
            }
            if (_latex != null) {  // --latex: las expresiones en LaTeX (Hekatan School / Manim)
                await WriteLatexAndExit(_latex);
            }
            if (_html != null) {   // --html: vuelca el HTML REAL del motor (Hekatan School). Sin leer el DOM.
                await Task.Delay(300);
                await WriteHtmlAndExit(_html);
            }
        }

        // Ctrl + rueda del ratón → zoom del texto del editor (o de la salida de texto), igual que
        // Hekatan Lab: ±2 puntos entre 6 y 40. Tunelado (PreviewMouseWheel): el ScrollViewer de
        // AvalonEdit se come la rueda si se escucha el evento burbuja.
        private void OnCtrlZoom(object sender, System.Windows.Input.MouseWheelEventArgs e)
        {
            if ((System.Windows.Input.Keyboard.Modifiers & System.Windows.Input.ModifierKeys.Control) == 0) return;
            if (sender is ICSharpCode.AvalonEdit.TextEditor ed)
            {
                ZoomTexto(ed, Math.Sign(e.Delta));
                e.Handled = true;
            }
        }

        /// <summary>+2 / −2 puntos, entre 6 y 40 (los pasos y topes de Hekatan Lab). Devuelve el tamaño.</summary>
        private static double ZoomTexto(ICSharpCode.AvalonEdit.TextEditor ed, int sentido)
        {
            var d = ed.FontSize + 2 * sentido;
            if (d >= 6 && d <= 40) ed.FontSize = d;
            return ed.FontSize;
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
        private void OnViewLearn(object s, RoutedEventArgs e) => SetView("learn");
        private void OnViewMath(object s, RoutedEventArgs e) => SetView("math");

        private void SetView(string view)
        {
            _view = view;
            // seleccionado = morado (claro en tema claro, oscuro en tema oscuro); resto = fondo temático del botón.
            // Antes el 'off' estaba FIJO en oscuro → en modo claro los botones se veían negros e ilegibles.
            var on = (Color)ColorConverter.ConvertFromString(_dark ? "#4B42AD" : "#C7C0F2");
            var off = (Resources["ThemeButtonBg"] as SolidColorBrush)?.Color
                      ?? (Color)ColorConverter.ConvertFromString("#262016");
            BtnRender.Background = new SolidColorBrush(view == "render" ? on : off);
            BtnLisp.Background = new SolidColorBrush(view == "lisp" ? on : off);
            BtnLearn.Background = new SolidColorBrush(view == "learn" ? on : off);
            BtnMath.Background = new SolidColorBrush(view == "math" ? on : off);

            LblIn.Text = _syntaxLisp ? "escribes: expresión LISP (símbolo — NO ejecutable; para correr usa «LISP completo»)" : "escribes: texto plano";
            LblOut.Text = view switch
            {
                "render" => "resultado — render CSS",
                "lisp" => "resultado — forma LISP",
                "learn" => "resultado — 3 formas (Renderizado · LISP · Texto plano)",
                _ => "resultado — texto plano",
            };
            ShowResult();
        }

        // ---------- calcula el RESULTADO y lo muestra en el formato elegido ----------
        // El resultado es SIEMPRE una forma LISP canónica (o número/mensaje); la DERECHA
        // la muestra como render / LISP / matemática. La OPERACIÓN (auto/simplify/expand/deriv)
        // es SEPARADA: 'auto' NO simplifica, deja la expresión tal cual (o su valor si es número).
        private bool IsRenderView => _view == "render" || _view == "learn";

        // vista MATLAB 2017a REAL: muestra el código MATLAB (syms + tic/toc) en el panel, para copiar.

        private int _showGen = 0;
        private System.Threading.Tasks.Task _showTask = System.Threading.Tasks.Task.CompletedTask;

        // Lanza el cálculo. El SBCL corre en SEGUNDO PLANO → la UI nunca se congela.
        private void ShowResult() { _showTask = RunShowAsync(); }

        private async System.Threading.Tasks.Task RunShowAsync()
        {
            int gen = ++_showGen;                          // marca esta petición (la última gana)
            // La DERECHA siempre muestra el RESULTADO del ORIGINAL, aunque la izquierda muestre
            // el LISP completo o el código Hekatan Lab (esos solo cambian la representación de copia).
            var text = SourceText();
            var dvar = TxtVar?.Text?.Trim();
            Output.Visibility = IsRenderView ? Visibility.Collapsed : Visibility.Visible;
            Viewer.Visibility = IsRenderView ? Visibility.Visible : Visibility.Collapsed;

            // el cálculo pesado (SBCL) fuera del hilo de UI
            var calc = System.Threading.Tasks.Task.Run(() => ComputeResult(text, dvar));
            // Si tarda (hojas con mallas grandes: 1–3 s), un aviso «calculando…» sobre lo que se ve;
            // antes el panel se quedaba quieto (o en blanco) sin decir nada. Lo borra la página nueva.
            if (IsRenderView && _webReady && Viewer.CoreWebView2 is not null)
            {
                var avisa = System.Threading.Tasks.Task.Delay(350);
                if (await System.Threading.Tasks.Task.WhenAny(calc, avisa) == avisa && gen == _showGen)
                {
                    try
                    {
                        _ = Viewer.ExecuteScriptAsync("(function(){var d=document.getElementById('hk-calc');if(!d){d=document.createElement('div');d.id='hk-calc';" +
                            "d.style.cssText='position:fixed;top:8px;right:12px;z-index:9999;background:#b08a2e;color:#fff;font:600 13px Segoe UI,sans-serif;padding:4px 10px;border-radius:12px;opacity:.92';" +
                            "(document.body||document.documentElement).appendChild(d);}d.textContent='calculando…';})();");
                    }
                    catch { }
                }
            }
            var forms = await calc;
            if (gen != _showGen) return;                   // llegó algo más nuevo → descarta este

            if (IsRenderView)
            {
                if (!_webReady) return;
                // SIN SCRIPT → muestra la guía (help.html), como Hekatan Lab en la ventana derecha.
                if (string.IsNullOrWhiteSpace(text)) { Viewer.NavigateToString(LispConverter.HelpPage()); return; }
                // Programa: su salida (N1 = …, texto…) se RENDERIZA (RenderPage dibuja "N1 = fórmula"
                // bonito y deja el texto suelto como está). Así la DEDUCCIÓN se ve como matemática.
                string html;
                if (_view == "learn")   // 3 formas: Matemática · LISP · MATLAB (para aprender)
                    html = LispConverter.LearnPage(string.Join("\n", forms), fromLisp: true);
                else
                {
                    html = LispConverter.RenderPage(string.Join("\n", forms), fromLisp: true);
                    // Gráficas INTERCALADAS: cada una en su posición del documento (marcador → HTML), en orden.
                    var plots = BuildPlotsOrdered(_srcPrepared ?? text, forms, _dark, out bool anySurf);
                    // La gráfica va DENTRO de su hk-plotslot: antes el hueco se reemplazaba entero, la
                    // regla de impresión (alto ≤ 300 px, no partir) no la encontraba y en el PDF la gráfica
                    // ocupaba casi una hoja → saltaba a la siguiente y dejaba media página en blanco.
                    foreach (var ph in plots)
                        html = ReplaceFirst(html, "<div class=\"hk-plotslot\"></div>",
                            ph != null && ph.Contains("<svg") ? "<div class=\"hk-plotslot\">" + ph + "</div>" : ph ?? "");
                    html = LispAnim.PostProcesar(html);   // #anim(n = a:b) … #finanim: los cuadros en su reproductor
                    if (anySurf) html = html.Replace("</body>", SurfacePlot.OrbitScript + SurfacePlot.SolidScript + SurfacePlot.MapScript + "</body>");   // orbit + hover de mapas, una vez
                }
                _lastHtml = html;   // --html: guardar el HTML REAL del motor (para Hekatan School)
                Viewer.NavigateToString(html);
                return;
            }
            var sb = new StringBuilder();
            foreach (var f in forms)
            {
                if (_view == "lisp") { var lv = ToLispView(f); if (lv != null) sb.AppendLine(lv); continue; }   // (setf name form)
                if (f.StartsWith("= ")) sb.AppendLine("= " + ToMathView(f.Substring(2)));
                else sb.AppendLine(ToMathView(f));
            }
            Output.Text = sb.ToString().TrimEnd();
        }

        // ---------- ▶ Ejecutar (manual) + AutoRun (en vivo), como Hekatan Lab ----------
        private void OnRun(object s, RoutedEventArgs e) => ShowResult();   // ejecuta ahora (también F5)

        private void OnAutoRun(object s, RoutedEventArgs e)
        {
            if (!IsLoaded) { _autoRun = ChkAutoRun.IsChecked == true; return; }  // durante InitializeComponent, no tocar UI
            _autoRun = ChkAutoRun.IsChecked == true;
            if (_autoRun) ShowResult();   // al reactivar, refresca ya
        }

        // al cambiar la variable de la parcial (∂/∂: s, t…), recalcula en vivo
        private void OnVarChanged(object s, System.Windows.Controls.TextChangedEventArgs e)
        {
            if (IsLoaded && _autoRun) ShowResult();
        }

        // ---------- selector de OPERACIÓN (separada del formato) ----------
        private void OnOpAuto(object s, RoutedEventArgs e) => SetOp("auto");
        private void OnOpSimplify(object s, RoutedEventArgs e) => SetOp("simplify");
        private void OnOpExpand(object s, RoutedEventArgs e) => SetOp("expand");
        private void OnOpDeriv(object s, RoutedEventArgs e) => SetOp("deriv");
        private void OnOpInteg(object s, RoutedEventArgs e) => SetOp("integ");
        private void OnOpDespejar(object s, RoutedEventArgs e) => SetOp("despejar");

        private void SetOp(string op)
        {
            _op = op;
            var on = (Color)ColorConverter.ConvertFromString(_dark ? "#6B551E" : "#E3D08A");  // dorado activo
            var off = (Resources["ThemeButtonBg"] as SolidColorBrush)?.Color
                      ?? (Color)ColorConverter.ConvertFromString("#262016");                  // fondo del tema
            OpAuto.Background = new SolidColorBrush(op == "auto" ? on : off);
            OpSimplify.Background = new SolidColorBrush(op == "simplify" ? on : off);
            OpExpand.Background = new SolidColorBrush(op == "expand" ? on : off);
            OpDeriv.Background = new SolidColorBrush(op == "deriv" ? on : off);
            OpInteg.Background = new SolidColorBrush(op == "integ" ? on : off);
            if (OpDespejar != null) OpDespejar.Background = new SolidColorBrush(op == "despejar" ? on : off);
            ShowResult();
        }

        // ---------- mostrar/ocultar calculadora + tema claro/oscuro (como Hekatan Lab) ----------
        private void OnToggleKeypad(object s, RoutedEventArgs e)
        {
            if (KeypadPanel == null) return;
            KeypadPanel.Visibility = KeypadPanel.Visibility == Visibility.Visible
                ? Visibility.Collapsed : Visibility.Visible;
        }

        private void OnToggleTheme(object s, RoutedEventArgs e) { _dark = !_dark; ApplyTheme(_dark); ShowResult(); }

        private void ApplyTheme(bool dark)
        {
            void B(string key, string hex) =>
                Resources[key] = new SolidColorBrush((Color)ColorConverter.ConvertFromString(hex));
            if (dark)
            {
                B("ThemeWindowBg", "#141109"); B("ThemePanelBg", "#1C1810"); B("ThemeEditorBg", "#1A1712");
                B("ThemeText", "#E8E2D4"); B("ThemeTextMuted", "#A89F8C");
                B("ThemeAccentRed", "#E5382B"); B("ThemeAccentGold", "#E6C463");
                B("ThemeButtonBg", "#262016"); B("ThemeButtonBorder", "#3A3226"); B("ThemeHoverBg", "#33E5382B");
                if (BtnTheme != null) BtnTheme.Content = "☾";
            }
            else
            {
                B("ThemeWindowBg", "#EDE6D3"); B("ThemePanelBg", "#E3DBC5"); B("ThemeEditorBg", "#FBF7EC");
                B("ThemeText", "#2A2418"); B("ThemeTextMuted", "#6E664F");
                B("ThemeAccentRed", "#C0392B"); B("ThemeAccentGold", "#A9791C");
                B("ThemeButtonBg", "#E9E1CD"); B("ThemeButtonBorder", "#C7BC9F"); B("ThemeHoverBg", "#22E5382B");
                if (BtnTheme != null) BtnTheme.Content = "☀";
            }
            LispConverter.Dark = dark;
            HighlightSyntax();
            SetView(_view);   // reaplica el fondo de los botones "resultado como" con el color del tema
            SetOp(_op);   // reaplica el resaltado de operación con el fondo del nuevo tema (y refresca render)
        }

        private bool _synFull = false;   // el editor muestra el LISP COMPLETO (ejecutable)

        // izquierda: MATLAB · expresión LISP · LISP (completo). El activo se resalta.
        // OJO: NO poner _synFull=false aquí — SetSyntax necesita saber que veníamos de «LISP completo»
        // para restaurar el ORIGINAL (matemática) antes de convertir. SetSyntax ya lo pone en false.
        private void OnSynMath(object s, RoutedEventArgs e) => SetSyntax(false);
        private void OnSynLisp(object s, RoutedEventArgs e) => SetSyntax(true);

        // LISP COMPLETO en la VENTANA IZQUIERDA: vuelca el script ejecutable en el editor,
        // para verlo entero y copiarlo (Ctrl+A → Ctrl+C) a un .lisp en blanco.
        private void OnSynLispFull(object s, RoutedEventArgs e)
        {
            var text = SourceText();         // parte del ORIGINAL, no del contenido derivado
            if (string.IsNullOrWhiteSpace(text)) return;
            var script = BuildFullLisp(text);
            if (string.IsNullOrWhiteSpace(script)) return;
            _reprSwitch = true;
            try
            {
                _lispBackup = text;              // guarda el original para restaurar/derivar
                Editor.Text = script;            // el LISP completo, aquí a la izquierda
                _synFull = true; _syntaxLisp = true; _transliterated = false;
                HighlightSyntax();
                LblIn.Text = "escribes: LISP completo (cópialo entero a un .lisp y córrelo)";
            }
            finally { _reprSwitch = false; }   // la derecha no cambia (misma expresión)
        }

        // Hekatan Lab / MATLAB en la VENTANA IZQUIERDA: pone el código (syms + diff/int + tic/toc)
        // en el editor para copiarlo a Hekatan Lab y comparar tiempos. AQUÍ no corre (es motor LISP).
        private void OnSynHekLab(object s, RoutedEventArgs e)
        {
            var text = SourceText();         // parte del ORIGINAL, no del contenido derivado
            if (string.IsNullOrWhiteSpace(text)) return;
            if (LooksLikeLisp(text) && IsLispProgram(text))   // Hekatan Lab es para EXPRESIONES, no programas
            {
                MessageBox.Show("«Hekatan Lab» convierte EXPRESIONES a MATLAB (syms, diff, int).\nNo aplica a un programa LISP.", "Hekatan LISP");
                return;
            }
            var code = BuildRealMatlab(text);
            if (string.IsNullOrWhiteSpace(code)) return;
            _reprSwitch = true;
            try
            {
                _lispBackup = text;
                Editor.Text = code;
                _transliterated = true;
                _synFull = false; _syntaxLisp = false;
                HighlightSyntax();
                LblIn.Text = "escribes: Hekatan Lab / MATLAB (cópialo a Hekatan Lab; aquí no corre)";
            }
            finally { _reprSwitch = false; }   // la derecha no cambia (misma expresión)
        }

        /// <summary>Pone la IZQUIERDA en LISP o MATLAB y CONVIERTE el contenido a esa forma.
        /// Pulsar el botón LISP deja el editor en LISP; el botón MATLAB, en MATLAB.</summary>
        private string _lispBackup = null;    // LISP original antes de traducir a MATLAB/Hekatan Lab
        private bool _transliterated = false; // el editor muestra código NO-LISP (no se ejecuta aquí)
        private string _transNote = "";       // nota que se muestra a la derecha en ese estado
        private bool _reprSwitch = false;     // true = solo cambia la representación izquierda (no recalcular)

        // El texto ORIGINAL del usuario (no el derivado). Detecta el derivado por su ENCABEZADO,
        // así es robusto aunque las banderas se desincronicen.
        private string SourceText()
        {
            var t = Editor.Text ?? "";
            var ts = t.TrimStart();
            // expr-LISP: el editor muestra (setf …); el ORIGINAL matemática vive en _lispBackup
            if (_syntaxLisp && !_synFull && !_transliterated && _lispBackup != null) return _lispBackup;
            bool derivado = ts.StartsWith(";;;; Script LISP") || ts.StartsWith("% Hekatan Lab") || ts.StartsWith("% =====");
            return (derivado && _lispBackup != null) ? _lispBackup : t;
        }

        private void SetSyntax(bool toLisp)
        {
            _reprSwitch = true;   // solo cambia la representación izquierda → la derecha NO se recalcula
            try
            {
                // veníamos de contenido DERIVADO (completo / Hekatan Lab / expr-LISP) → restaura el ORIGINAL
                if ((_synFull || _transliterated || (_syntaxLisp && !toLisp)) && _lispBackup != null) { Editor.Text = _lispBackup; }
                _synFull = false;
                _transliterated = false;
                // BLINDAJE: un PROGRAMA LISP (defun/loop/format…) NO se convierte a texto plano por línea.
                if (!toLisp && LooksLikeLisp(Editor.Text) && IsLispProgram(Editor.Text))
                {
                    _syntaxLisp = true; HighlightSyntax();
                    LblIn.Text = "escribes: LISP (programa — no se convierte a texto plano por línea)";
                    return;
                }
                // al ENTRAR a expr-LISP guardo el matemática original: el editor mostrará (setf …)
                // pero el panel derecho debe seguir computando del ORIGINAL (vía SourceText).
                if (toLisp && !_syntaxLisp) _lispBackup = Editor.Text;
                Editor.Text = ConvertEditor(Editor.Text, toLisp);
                _syntaxLisp = toLisp;
                HighlightSyntax();
                LblIn.Text = toLisp ? "escribes: expresión LISP (símbolo — NO ejecutable; para correr usa «LISP completo»)" : "escribes: texto plano";
            }
            finally { _reprSwitch = false; }
            // NO ShowResult: cambiar la representación no cambia el resultado (solo la forma de copiar).
        }

        /// <summary>Resalta en dorado el botón de sintaxis activo (MATLAB o LISP).</summary>
        private void HighlightSyntax()
        {
            if (BtnSynMath == null || BtnSynLisp == null) return;
            var on = (Color)ColorConverter.ConvertFromString(_dark ? "#6B551E" : "#E3D08A");
            var off = (Resources["ThemeButtonBg"] as SolidColorBrush)?.Color
                      ?? (Color)ColorConverter.ConvertFromString("#262016");
            BtnSynMath.Background = new SolidColorBrush((!_syntaxLisp && !_synFull && !_transliterated) ? on : off);
            BtnSynLisp.Background = new SolidColorBrush((_syntaxLisp && !_synFull && !_transliterated) ? on : off);
            if (BtnSynLispFull != null) BtnSynLispFull.Background = new SolidColorBrush(_synFull ? on : off);
            if (BtnSynHekLab != null) BtnSynHekLab.Background = new SolidColorBrush(_transliterated ? on : off);
        }

        private void MenuEjemploLoop(object s, RoutedEventArgs e)
        {
            _syntaxLisp = false;
            HighlightSyntax();
            LblIn.Text = "escribes: texto plano";
            Editor.Text = EJ_LOOP;
            SetView(_view);
        }

        // ---------- canal de control --ctl (tests desde terminal) ----------
        private void StartCtl()
        {
            Directory.CreateDirectory(_ctl);
            // aviso de "ya estoy vivo" para el guion de pruebas (igual que Lab y Py)
            try { File.WriteAllText(Path.Combine(_ctl, "ready.txt"), System.Environment.ProcessId.ToString()); } catch { }
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
                case "js":       // ejecutar JS en el WebView2 (p.ej. arrastrar la manija de una matriz)
                    string jr = "null";
                    try { jr = await Viewer.ExecuteScriptAsync(doc.RootElement.GetProperty("code").GetString()); }
                    catch { }
                    return "{\"ok\":true,\"result\":" + (string.IsNullOrEmpty(jr) ? "null" : jr) + "}";
                case "capture":  // PNG de la ventana SIN cerrar la app (frames de una secuencia)
                    await Capture(doc.RootElement.GetProperty("path").GetString());
                    return "{\"ok\":true}";
                // Escribir SIN forzar el cálculo: es el camino del usuario (TextChanged →
                // debounce → AutoRun). `settext` llama a ShowResult a mano, así que sirve
                // para probar el motor pero NUNCA para probar el AutoRun: con él el test
                // pasa aunque el AutoRun esté muerto.
                case "escribe":
                    Editor.Text = doc.RootElement.GetProperty("text").GetString();
                    return "{\"ok\":true,\"autorun\":" + (_autoRun ? "true" : "false") + "}";
                case "view":     // formato de la derecha: render|lisp|math
                    SetView(doc.RootElement.GetProperty("name").GetString());
                    return "{\"ok\":true,\"view\":\"" + _view + "\"}";
                case "op":       // operación: auto|simplify|expand|deriv
                    SetOp(doc.RootElement.GetProperty("name").GetString());
                    return "{\"ok\":true,\"op\":\"" + _op + "\"}";
                case "setvar":   // fija la variable del cuadro var: (deriv/integ/despejar)
                    if (TxtVar != null) TxtVar.Text = doc.RootElement.GetProperty("var").GetString();
                    ShowResult();
                    return "{\"ok\":true}";
                case "autorun":  // enciende/apaga AutoRun (en vivo)
                    ChkAutoRun.IsChecked = doc.RootElement.GetProperty("on").GetBoolean();
                    return "{\"ok\":true,\"autorun\":" + (_autoRun ? "true" : "false") + "}";
                case "run":      // pulsa ▶ Ejecutar (o F5)
                    ShowResult();
                    return "{\"ok\":true}";
                case "getoutput":
                    try { await _showTask; } catch { }          // espera al cálculo async
                    await System.Threading.Tasks.Task.Delay(60); // deja asentar el render del WebView
                    if (IsRenderView && _webReady && Viewer.CoreWebView2 is not null)
                    {
                        var t = await Viewer.ExecuteScriptAsync("(document.body?document.body.innerText:'')");
                        return "{\"ok\":true,\"output\":" + (string.IsNullOrEmpty(t) ? "\"\"" : t) + "}";
                    }
                    return System.Text.Json.JsonSerializer.Serialize(new { output = Output.Text });
                case "gettext":
                    return System.Text.Json.JsonSerializer.Serialize(new { input = Editor.Text });
                case "theme":    // tema claro/oscuro (para verificar el render en ambos)
                    _dark = doc.RootElement.GetProperty("dark").GetBoolean();
                    ApplyTheme(_dark);
                    ShowResult();
                    return "{\"ok\":true,\"dark\":" + (_dark ? "true" : "false") + "}";
                case "gethtml":   // vuelca el HTML del render (para PNG con render_html.py)
                    try { await _showTask; } catch { }
                    await System.Threading.Tasks.Task.Delay(60);
                    if (IsRenderView && _webReady && Viewer.CoreWebView2 is not null)
                    {
                        var h = await Viewer.ExecuteScriptAsync("document.documentElement.outerHTML");
                        return "{\"ok\":true,\"html\":" + (string.IsNullOrEmpty(h) ? "\"\"" : h) + "}";
                    }
                    return "{\"ok\":false}";
                case "syntax":   // cambia la IZQUIERDA a LISP/matemática (convierte el contenido)
                    SetSyntax(doc.RootElement.GetProperty("lisp").GetBoolean());
                    return "{\"ok\":true,\"lisp\":" + (_syntaxLisp ? "true" : "false") + "}";
                case "synfull":  // pulsa el botón "LISP completo" (izquierda)
                    OnSynLispFull(this, null);
                    return "{\"ok\":true}";
                case "synheklab": // pulsa el botón "Hekatan Lab" (izquierda)
                    OnSynHekLab(this, null);
                    return "{\"ok\":true}";
                case "vermotor": // Menú Motor → Ver funciones (carga engine.lisp)
                    MenuVerMotor(this, null);
                    return "{\"ok\":true}";
                // Autocompletado medible: que ofreceria el popup para un prefijo. El popup es
                // otra ventana y no sale en --shot, asi que sin esto no habia forma de
                // comprobarlo sin mirar la pantalla.
                case "complete":
                    {
                        var pre = doc.RootElement.TryGetProperty("prefix", out var pp) ? (pp.GetString() ?? "") : "";
                        var m = System.Linq.Enumerable.ToArray(System.Linq.Enumerable.Take(
                            System.Linq.Enumerable.Where(Catalogo(),
                                sy => sy.StartsWith(pre, StringComparison.OrdinalIgnoreCase)), 12));
                        return System.Text.Json.JsonSerializer.Serialize(new {
                            ok = true, prefijo = pre,
                            total = System.Linq.Enumerable.Count(System.Linq.Enumerable.Where(
                                Catalogo(), sy => sy.StartsWith(pre, StringComparison.OrdinalIgnoreCase))),
                            catalogo = Catalogo().Length,
                            primeros = m,
                        });
                    }

                case "state":
                    return System.Text.Json.JsonSerializer.Serialize(new { view = _view, op = _op, lisp = _syntaxLisp, autorun = _autoRun });
                // Zoom del editor como Ctrl+rueda: {"op":"zoom","steps":+1|-1} -> tamaño de letra
                case "zoom":
                    {
                        int pasos = doc.RootElement.TryGetProperty("steps", out var sp) ? sp.GetInt32() : 1;
                        double fs = Editor.FontSize;
                        for (int k = 0; k < Math.Abs(pasos); k++) fs = ZoomTexto(Editor, Math.Sign(pasos));
                        return "{\"ok\":true,\"fontSize\":" + fs.ToString(System.Globalization.CultureInfo.InvariantCulture) + "}";
                    }
                // Anchos editor | divisor | resultado y DÓNDE está el divisor en pantalla (px físicos),
                // para arrastrarlo con el ratón de verdad desde un test.
                case "layout":
                    {
                        var inv = System.Globalization.CultureInfo.InvariantCulture;
                        var p0 = MainSplitter.PointToScreen(new Point(0, 0));
                        var p1 = MainSplitter.PointToScreen(new Point(MainSplitter.ActualWidth, MainSplitter.ActualHeight));
                        var pe = Editor.PointToScreen(new Point(Editor.ActualWidth / 2, Editor.ActualHeight / 2));   // centro del editor
                        return string.Format(inv,
                            "{{\"ok\":true,\"editor\":{0},\"splitter\":{1},\"web\":{2},\"sx0\":{3},\"sy0\":{4},\"sx1\":{5},\"sy1\":{6},\"ecx\":{7},\"ecy\":{8},\"fontSize\":{9}}}",
                            EditorCol.ActualWidth, MainSplitter.ActualWidth, WebCol.ActualWidth,
                            (int)p0.X, (int)p0.Y, (int)p1.X, (int)p1.Y, (int)pe.X, (int)pe.Y, Editor.FontSize);
                    }
                // zoom del RESULTADO (como Ctrl+rueda sobre él): {"op":"webzoom","factor":1.3}. Se queda
                // entre recálculos (es del WebView2, no de la página). Para grabar vídeos legibles a 1280×720.
                case "webzoom":
                    try { Viewer.ZoomFactor = doc.RootElement.GetProperty("factor").GetDouble(); } catch { }
                    return "{\"ok\":true}";
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
        // Vuelca el HTML REAL que produjo el motor (_lastHtml: EVALUADO + RenderPage + gráficas),
        // SIN leer el DOM del WebView (aquello era frágil). Para Hekatan School.
        /// <summary>Corre la hoja y vuelca sus expresiones en LaTeX (una por linea).</summary>
        private async Task WriteLatexAndExit(string path)
        {
            try
            {
                ShowResult();                        // el mismo pipeline de siempre
                try { await _showTask; } catch { }   // esperar a que el motor termine
                LispLatex.Vuelca(path);              // y volcar lo que se fue apuntando
            }
            catch (Exception ex) { File.WriteAllText(Path.ChangeExtension(path, ".error.txt"), ex.ToString()); }
            finally { Application.Current.Shutdown(); }
        }

        private async Task WriteHtmlAndExit(string path)
        {
            try
            {
                // Si al abrir la hoja ya se lanzó el cálculo (AutoRun), se ESPERA ese; lanzar otro
                // hacía correr la hoja dos veces (el doble de tiempo) y a la vez.
                if (_showTask == null || (_showTask.IsCompleted && _lastHtml == null)) ShowResult();
                try { await _showTask; } catch { }   // espera a que el cálculo/render termine
                if (_lastHtml == null) { ShowResult(); try { await _showTask; } catch { } }
                File.WriteAllText(path, _lastHtml ?? "");
            }
            catch (Exception ex) { File.WriteAllText(Path.ChangeExtension(path, ".error.txt"), ex.ToString()); }
            finally { Application.Current.Shutdown(); }
        }

        private async Task CaptureAndExit(string path)
        {
            await Capture(path);
            Application.Current.Shutdown();
        }

        /// <summary>Igual que CaptureAndExit pero SIN cerrar: sirve para tomar varios frames.</summary>
        private async Task Capture(string path)
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
        }

        // Imprime la HOJA renderizada a PDF (WebView2). Respeta los saltos de página (#salto) y los fondos.
        private async Task PrintPdfAndExit(string path)
        {
            try { await ExportPdf(path); }
            catch (Exception ex) { File.WriteAllText(Path.ChangeExtension(path, ".error.txt"), ex.ToString()); }
            finally { Application.Current.Shutdown(); }
        }

        private async Task ExportPdf(string path)
        {
            await Task.Delay(300);
            var st = Viewer.CoreWebView2.Environment.CreatePrintSettings();
            st.ShouldPrintBackgrounds = true;                 // conserva el fondo crema y los colores
            st.MarginTop = 0.4; st.MarginBottom = 0.4; st.MarginLeft = 0.55; st.MarginRight = 0.55;
            await Viewer.CoreWebView2.PrintToPdfAsync(path, st);
        }

        // Botón/menu «Exportar PDF»: pregunta dónde guardar y escribe el PDF de la hoja.
        private async void MenuPdf(object sender, RoutedEventArgs e)
        {
            if (!IsRenderView || !_webReady || Viewer.CoreWebView2 is null)
            { MessageBox.Show("Cambia a la vista renderizada (Matemática) antes de exportar el PDF."); return; }
            var dlg = new Microsoft.Win32.SaveFileDialog { Filter = "PDF (*.pdf)|*.pdf", DefaultExt = ".pdf",
                FileName = Path.GetFileNameWithoutExtension(_currentFile ?? "hoja") + ".pdf" };
            if (dlg.ShowDialog() != true) return;
            try { await ExportPdf(dlg.FileName); MessageBox.Show("PDF guardado:\n" + dlg.FileName); }
            catch (Exception ex) { MessageBox.Show("No se pudo exportar el PDF:\n" + ex.Message); }
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

        private void MenuNuevo(object s, RoutedEventArgs e) { Editor.Text = ""; SetCurrentFile(null); }
        private void MenuEjemplo(object s, RoutedEventArgs e) => Editor.Text = _syntaxLisp ? EJ_LISP : EJ_MATH;
        private void MenuSalir(object s, RoutedEventArgs e) => Close();

        /// <summary>Genera un script LISP COMPLETO y EJECUTABLE a partir de lo que hay en el editor:
        /// detecta si es programa o expresiones y le pone lo que necesita (cargar el motor, quote,
        /// format para imprimir). Lo guarda y lo abre en el bloc de notas.</summary>
        private void OnExportLisp(object s, RoutedEventArgs e)
        {
            var text = Editor.Text;
            if (string.IsNullOrWhiteSpace(text)) return;
            var script = BuildFullLisp(text);
            // (1) copia el script completo al portapapeles  (2) lo abre en el bloc de notas para VERLO todo
            try { Clipboard.SetText(script); } catch { }
            try
            {
                var tmp = Path.Combine(Path.GetTempPath(), "hekatan_script.lisp");
                File.WriteAllText(tmp, script);
                System.Diagnostics.Process.Start(new System.Diagnostics.ProcessStartInfo(tmp) { UseShellExecute = true });
            }
            catch { }
        }

        // Guardar el LISP EJECUTABLE (script completo, corre en SBCL) a un archivo .lisp.
        private void MenuGuardarLisp(object s, RoutedEventArgs e)
        {
            var text = Editor.Text;
            if (string.IsNullOrWhiteSpace(text)) return;
            var script = BuildFullLisp(text);
            var dlg = new Microsoft.Win32.SaveFileDialog
            {
                Filter = "LISP ejecutable (*.lisp)|*.lisp",
                InitialDirectory = !string.IsNullOrEmpty(_currentFile) ? Path.GetDirectoryName(_currentFile) : DocsDir,
                FileName = (!string.IsNullOrEmpty(_currentFile) ? Path.GetFileNameWithoutExtension(_currentFile) : "mi_script") + "_ejecutable.lisp"
            };
            if (dlg.ShowDialog() == true)
            {
                try { File.WriteAllText(dlg.FileName, script); }
                catch (Exception ex) { MessageBox.Show(ex.Message); }
            }
        }

        // ---------- carpeta de ejemplos (para practicar) ----------
        private static string EjemplosDir => Path.Combine(AppContext.BaseDirectory, "ejemplos");

        private void PoblarEjemplos()
        {
            if (MnuEjemplos == null) return;
            MnuEjemplos.Items.Clear();
            try
            {
                if (Directory.Exists(EjemplosDir))
                    foreach (var f in System.Linq.Enumerable.OrderBy(Directory.GetFiles(EjemplosDir, "*.lisp"), x => x))
                    {
                        // «_nombre.lisp» son hojas de prueba (las leen los guiones de Hekatan School),
                        // no ejemplos para practicar: no van al menú
                        if (Path.GetFileName(f).StartsWith("_")) continue;
                        var path = f;
                        // el '_' de un Header de WPF es la tecla de acceso (se come la letra): se dobla
                        var mi = new MenuItem { Header = Path.GetFileNameWithoutExtension(f).Replace("_", "__") };
                        mi.Click += (s, e) => CargarArchivo(path);
                        MnuEjemplos.Items.Add(mi);
                    }
            }
            catch { }
            if (MnuEjemplos.Items.Count == 0)
                MnuEjemplos.Items.Add(new MenuItem { Header = "(no hay ejemplos)", IsEnabled = false });
        }

        // ---------- documento actual (para que Guardar/Ctrl+S no vuelva a preguntar) ----------
        private string _currentFile = null;   // ruta del archivo abierto/guardado; null = sin guardar aún
        // carpeta propia del usuario (NO dentro del programa, NO en %temp%): Documentos\Hekatan LISP
        private static string DocsDir
        {
            get
            {
                var d = Path.Combine(Environment.GetFolderPath(Environment.SpecialFolder.MyDocuments), "Hekatan LISP");
                try { Directory.CreateDirectory(d); } catch { }
                return d;
            }
        }
        private void SetCurrentFile(string path)
        {
            _currentFile = path;
            string name = string.IsNullOrEmpty(path) ? "(sin guardar)" : Path.GetFileName(path);
            Title = string.IsNullOrEmpty(path) ? "Hekatan LISP" : "Hekatan LISP — " + name;
            if (LblFile != null) LblFile.Text = name;   // nombre visible arriba (como Hekatan Lab)
            // ya hay archivo REAL → el respaldo temporal sobra (bórralo)
            if (!string.IsNullOrEmpty(path))
                try { if (File.Exists(AutoSavePath)) File.Delete(AutoSavePath); } catch { }
        }

        // respaldo del trabajo NO guardado: mientras no haya archivo real, se vuelca a %temp%.
        private static string AutoSavePath => Path.Combine(Path.GetTempPath(), "hekatan_lisp_autosave.lisp");
        private void AutoSaveTemp()
        {
            if (!string.IsNullOrEmpty(_currentFile)) return;   // hay archivo real → no usa temporal
            if (_ctl != null || _shot != null) return;         // en pruebas headless no respalda
            try
            {
                var t = Editor.Text ?? "";
                if (t.Trim().Length == 0) { if (File.Exists(AutoSavePath)) File.Delete(AutoSavePath); }
                else File.WriteAllText(AutoSavePath, t);
            }
            catch { }
        }

        private void CargarArchivo(string path)
        {
            try
            {
                string txt = File.ReadAllText(path);
                // .m (MATLAB / Hekatan Lab) → se CONVIERTE a notación de Hekatan LISP al abrir
                if (string.Equals(Path.GetExtension(path), ".m", StringComparison.OrdinalIgnoreCase))
                    txt = LispConverter.MatlabToHlisp(txt);
                Editor.Text = txt;
                _synFull = false; _transliterated = false;
                _syntaxLisp = LooksLikeLisp(Editor.Text);
                HighlightSyntax();
                LblIn.Text = _syntaxLisp ? "escribes: expresión LISP (símbolo — NO ejecutable; para correr usa «LISP completo»)" : "escribes: texto plano";
                SetCurrentFile(path);     // recuerda el archivo abierto
                ShowResult();
            }
            catch (Exception ex) { MessageBox.Show("No pude abrir: " + ex.Message); }
        }

        private void MenuAbrir(object s, RoutedEventArgs e)
        {
            var dlg = new Microsoft.Win32.OpenFileDialog
            {
                Filter = "Hekatan LISP (*.hlisp;*.lisp)|*.hlisp;*.lisp|MATLAB / Hekatan Lab (*.m)|*.m|Todos (*.*)|*.*",
                InitialDirectory = DocsDir
            };
            if (dlg.ShowDialog() == true) CargarArchivo(dlg.FileName);
        }

        // Guardar (Ctrl+S): si YA hay archivo, escribe ahí SIN preguntar. Si no, actúa como "Guardar como".
        private void MenuGuardar(object s, RoutedEventArgs e)
        {
            if (!string.IsNullOrEmpty(_currentFile))
            {
                try { File.WriteAllText(_currentFile, Editor.Text); }
                catch (Exception ex) { MessageBox.Show(ex.Message); }
            }
            else MenuGuardarComo(s, e);
        }

        // Guardar como…: siempre pregunta ubicación; la recuerda para los próximos Ctrl+S.
        private void MenuGuardarComo(object s, RoutedEventArgs e)
        {
            var dlg = new Microsoft.Win32.SaveFileDialog
            {
                Filter = "Hekatan LISP (*.hlisp)|*.hlisp|LISP (*.lisp)|*.lisp",
                InitialDirectory = !string.IsNullOrEmpty(_currentFile) ? Path.GetDirectoryName(_currentFile) : DocsDir,
                FileName = !string.IsNullOrEmpty(_currentFile) ? Path.GetFileName(_currentFile) : "mi_script.hlisp"
            };
            if (dlg.ShowDialog() == true)
            {
                try { File.WriteAllText(dlg.FileName, Editor.Text); SetCurrentFile(dlg.FileName); }
                catch (Exception ex) { MessageBox.Show(ex.Message); }
            }
        }

        // ---------- autocompletar: al escribir, lista los símbolos LISP que empiezan igual ----------
        private static readonly string[] LispSymbols =
        {
            "derive-x","integ-x","integ-var","defint-x","partial","simplify","expand*","infix",
            "deriv","diff","integ","expt","sqrt","sin","cos","tan","exp","log","abs",
            "vector","list","cons","car","cdr","first","second","third","rest","length","reverse",
            "append","nth","mapcar","member","null","atom","consp","numberp","integerp","rationalp",
            "symbolp","let","let*","cond","if","when","unless","and","or","not","defun","lambda",
            "dotimes","dolist","setf","format","funcall","progn","quote","prod","factores"
        };
        private ICSharpCode.AvalonEdit.CodeCompletion.CompletionWindow _completion;

        // ── El catálogo REAL: lo que el motor sabe, no una lista copiada a mano ──────
        //
        // Jorge (17-sep-2026), viendo que «de» solo ofrecía cuatro: «¿esa es toda la
        // lista?». Lo era: 59 símbolos escritos a mano aquí arriba, mientras que
        // `engine.lisp` —el motor— define 175 funciones. Una lista copiada envejece a la
        // primera función nueva; esta se lee del propio motor al arrancar, así que lo que
        // se ofrece es siempre lo que de verdad se puede llamar.
        private static string[] _catalogo;
        private static string[] Catalogo()
        {
            if (_catalogo is not null) return _catalogo;
            var nombres = new SortedSet<string>(StringComparer.OrdinalIgnoreCase);
            foreach (var s in LispSymbols) nombres.Add(s);          // los de Common Lisp, a mano
            try
            {
                var ruta = Path.Combine(AppContext.BaseDirectory, "engine.lisp");
                if (File.Exists(ruta))
                    foreach (System.Text.RegularExpressions.Match m in
                             System.Text.RegularExpressions.Regex.Matches(
                                 File.ReadAllText(ruta),
                                 @"^\((?:defun|defmacro|defparameter|defconstant|defvar)\s+([^\s\)\(]+)",
                                 System.Text.RegularExpressions.RegexOptions.Multiline))
                        nombres.Add(m.Groups[1].Value);
            }
            catch { }                                               // sin motor, quedan los de siempre
            _catalogo = System.Linq.Enumerable.ToArray(nombres);
            return _catalogo;
        }

        private void OnTextEntered(object sender, System.Windows.Input.TextCompositionEventArgs e)
        {
            if (e.Text.Length != 1) return;
            char c = e.Text[0];
            if (!char.IsLetter(c)) return;
            var doc = Editor.Document; int caret = Editor.CaretOffset; int start = caret;
            while (start > 0) { char p = doc.GetCharAt(start - 1); if (char.IsLetterOrDigit(p) || p == '-' || p == '*') start--; else break; }
            string prefix = doc.GetText(start, caret - start);
            if (prefix.Length < 1) return;
            var matches = System.Linq.Enumerable.ToList(
                System.Linq.Enumerable.Where(Catalogo(), sy => sy.StartsWith(prefix, StringComparison.OrdinalIgnoreCase)));
            if (matches.Count == 0) { return; }
            _completion = new ICSharpCode.AvalonEdit.CodeCompletion.CompletionWindow(Editor.TextArea) { StartOffset = start };
            foreach (var m in matches) _completion.CompletionList.CompletionData.Add(new LispCompletion(m));
            _completion.Show();
            _completion.Closed += (s2, e2) => _completion = null;
        }

        // Ver motor: carga engine.lisp en el editor para VER las funciones (derive-x, simplify, infix…)
        private void MenuVerMotor(object s, RoutedEventArgs e)
        {
            try
            {
                var p = Path.Combine(AppContext.BaseDirectory, "engine.lisp");
                Editor.Text = File.ReadAllText(p);
                _synFull = false; _syntaxLisp = true; _transliterated = false;
                HighlightSyntax();
                LblIn.Text = "MOTOR — funciones LISP (derive-x, simplify, expand*, integ-x, infix…)";
            }
            catch (Exception ex) { MessageBox.Show("No pude leer engine.lisp: " + ex.Message); }
        }

        // Ver el motor (o el programa actual) TRADUCIDO a MATLAB aprox — solo para ENTENDER.
        private void MenuVerMotorMat(object s, RoutedEventArgs e)
        {
            try
            {
                var src = Editor.Text;
                if (string.IsNullOrWhiteSpace(src) || !(LooksLikeLisp(src) && IsLispProgram(src)))
                    src = File.ReadAllText(Path.Combine(AppContext.BaseDirectory, "engine.lisp"));
                _lispBackup = src;
                Editor.Text = LispPseudoMat.Translate(src);
                _transliterated = true; _synFull = false; _syntaxLisp = false;
                _transNote = "PSEUDOCÓDIGO estilo MATLAB — traducido del LISP solo para ENTENDER. NO es MATLAB real (falta 'syms'), no lo copies para correr. Menú Motor → Ver funciones (LISP) para volver.";
                HighlightSyntax();
                LblIn.Text = "PSEUDOCÓDIGO estilo MATLAB (no corre; para entender). Menú Motor → Ver funciones (LISP) para volver.";
            }
            catch (Exception ex) { MessageBox.Show(ex.Message); }
        }

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

    // Elemento de la lista de autocompletado (AvalonEdit).
    public class LispCompletion : ICSharpCode.AvalonEdit.CodeCompletion.ICompletionData
    {
        public LispCompletion(string text) { Text = text; }
        public System.Windows.Media.ImageSource Image => null;
        public string Text { get; }
        public object Content => Text;
        public object Description => "LISP · " + Text;
        public double Priority => 0;
        public void Complete(ICSharpCode.AvalonEdit.Editing.TextArea textArea,
                             ICSharpCode.AvalonEdit.Document.ISegment completionSegment, EventArgs e)
            => textArea.Document.Replace(completionSegment, Text);
    }
}
