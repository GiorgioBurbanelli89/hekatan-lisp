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
        private string _op = "auto";               // operación: "auto" | "simplify" | "expand" | "deriv"
        private bool _autoRun = true;              // AutoRun (en vivo) como Hekatan Lab; si off, se usa ▶/F5
        private string _shot, _ctl;
        private bool _webReady;
        private bool _syntaxLisp = false;          // toggle de ENTRADA: escribo matemática (false) / LISP (true)
        private bool _ranProgram = false;          // el último resultado vino de EJECUTAR un programa (stdout de consola)
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
            _ctl = ValueAfter(args, "--ctl");
            var v = ValueAfter(args, "--view");
            if (v is "render" or "lisp" or "math") _view = v;
            var o = ValueAfter(args, "--op");
            if (o is "auto" or "simplify" or "expand" or "deriv" or "integ") _op = o;

            var profile = Path.Combine(Path.GetTempPath(), $"HekatanLispWV2_{Environment.ProcessId}");
            var env = await CoreWebView2Environment.CreateAsync(userDataFolder: profile);
            await Viewer.EnsureCoreWebView2Async(env);
            Viewer.CoreWebView2.Profile.PreferredColorScheme =
                _dark ? CoreWebView2PreferredColorScheme.Dark : CoreWebView2PreferredColorScheme.Light;
            _webReady = true;

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
            var inFile = ValueAfter(args, "--in");
            if (inFile != null) { try { if (File.Exists(inFile)) Editor.Text = File.ReadAllText(inFile); } catch { } }
            if (string.IsNullOrWhiteSpace(Editor.Text))
            {
                // arranque normal: recupera el trabajo NO guardado del respaldo temporal (si existe)
                string recup = null;
                if (_ctl == null && _shot == null)
                    try { if (File.Exists(AutoSavePath)) recup = File.ReadAllText(AutoSavePath); } catch { }
                Editor.Text = !string.IsNullOrWhiteSpace(recup) ? recup : EJ_MATH;
            }
            ApplyTheme(_dark);   // sincroniza UI + render (LispConverter.Dark) al arrancar; llama SetView/SetOp

            if (_ctl != null) StartCtl();
            if (_shot != null) { await Task.Delay(700); await CaptureAndExit(_shot); }
        }

        // Ctrl + rueda del ratón → zoom del texto (agranda/achica la fuente del editor/salida)
        private void OnCtrlZoom(object sender, System.Windows.Input.MouseWheelEventArgs e)
        {
            if (System.Windows.Input.Keyboard.Modifiers != System.Windows.Input.ModifierKeys.Control) return;
            if (sender is ICSharpCode.AvalonEdit.TextEditor ed)
            {
                ed.FontSize = Math.Max(8, Math.Min(48, ed.FontSize + (e.Delta > 0 ? 1.5 : -1.5)));
                e.Handled = true;
            }
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
            var forms = await System.Threading.Tasks.Task.Run(() => ComputeResult(text, dvar));
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
                    var plots = BuildPlotsOrdered(text, forms, _dark, out bool anySurf);
                    foreach (var ph in plots)
                        html = ReplaceFirst(html, "<div class=\"hk-plotslot\"></div>", ph ?? "");
                    if (anySurf) html = html.Replace("</body>", SurfacePlot.OrbitScript + "</body>");   // motor de orbit, una vez
                }
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

        /// <summary>Vista "expr LISP": una línea de salida (que puede venir como "name = forma" o
        /// "name = operación = resultado") a LISP VÁLIDO:  (setf name forma).  Una expresión suelta
        /// se deja tal cual (ya es una forma LISP). El texto (#) se pasa como comentario ";".</summary>
        private static string ToLispView(string f)
        {
            if (string.IsNullOrEmpty(f)) return null;
            if (f.StartsWith(LispConverter.TxtMark))   // línea de texto (#): comentario LISP
            {
                var pz = f.Split(LispConverter.TxtSep);
                var html = pz.Length > 4 ? string.Join("", pz.Skip(4)) : "";
                var plain = System.Text.RegularExpressions.Regex.Replace(html, @"<[^>]+>", "").Trim();
                return plain.Length > 0 ? "; " + System.Net.WebUtility.HtmlDecode(plain) : null;
            }
            var parts = System.Text.RegularExpressions.Regex.Split(f, @"\s=\s");
            if (parts.Length >= 2 && System.Text.RegularExpressions.Regex.IsMatch(parts[0].Trim(), @"^[A-Za-z]\w*$"))
                return "(setf " + parts[0].Trim() + " " + parts[1].Trim() + ")";   // definición → (setf …)
            return parts[0].Trim();   // expresión suelta: ya es una forma LISP
        }

        // ;grafica en COMENTARIO (LISP lo ignora, la app lo dibuja): ";grafica s -1 1 [N1 N2 …]".
        // Toma las funciones YA deducidas (etiquetas NAME = … = RESULTADO de la salida) y las grafica.
        // línea de comentario que empieza el comando de gráfica; el resto se parsea a mano
        private static readonly System.Text.RegularExpressions.Regex RxGraf = new System.Text.RegularExpressions.Regex(
            @"^\s*[;#]+\s*(fplot|plot|ezplot|graficas?|grafico)\b(.*)$",
            System.Text.RegularExpressions.RegexOptions.IgnoreCase | System.Text.RegularExpressions.RegexOptions.Multiline);

        // separa por comas de PRIMER nivel (respeta [ ] y ( ))
        private static List<string> SplitTop(string s)
        {
            var res = new List<string>(); int depth = 0; var cur = new StringBuilder();
            foreach (char c in s)
            {
                if (c == '[' || c == '(') depth++;
                else if (c == ']' || c == ')') depth--;
                if (c == ',' && depth == 0) { res.Add(cur.ToString()); cur.Clear(); }
                else cur.Append(c);
            }
            if (cur.ToString().Trim().Length > 0) res.Add(cur.ToString());
            return res;
        }

        // Varias asignaciones en UNA línea de matemática, estilo MATLAB:  a = 2; b = 3  →  dos líneas.
        // El ';' separa SOLO a nivel 0 (no dentro de [ ] { } ( ), donde ';' es separador de fila de matriz).
        // No toca líneas de texto (#), LISP/comentario (;) ni MATLAB (%).
        private static string[] ExpandMathSemicolons(string[] lines)
        {
            var res = new List<string>();
            foreach (var raw in lines)
            {
                var t = raw.TrimStart();
                if (t.StartsWith("#") || t.StartsWith(";") || t.StartsWith("%") || raw.IndexOf(';') < 0)
                { res.Add(raw); continue; }
                int depth = 0; var cur = new StringBuilder(); var parts = new List<string>();
                foreach (char c in raw)
                {
                    if (c == '[' || c == '(' || c == '{') depth++;
                    else if (c == ']' || c == ')' || c == '}') depth--;
                    if (c == ';' && depth == 0) { parts.Add(cur.ToString()); cur.Clear(); }
                    else cur.Append(c);
                }
                parts.Add(cur.ToString());
                bool any = false;
                foreach (var p in parts) if (p.Trim().Length > 0) { res.Add(p.Trim()); any = true; }
                if (!any) res.Add(raw);
            }
            return res.ToArray();
        }

        // Reemplaza SOLO la primera aparición (para rellenar los huecos de gráfica en orden).
        private static string ReplaceFirst(string s, string find, string repl)
        {
            int i = s.IndexOf(find, StringComparison.Ordinal);
            return i < 0 ? s : s.Substring(0, i) + repl + s.Substring(i + find.Length);
        }

        // envoltura centrada + leyenda para una gráfica (superficie o mapa)
        private static string PlotWrap(string inner, string caption) =>
            "<div style=\"text-align:center;margin:1.1em 0\">" + inner +
            "<div style=\"color:var(--mut);font-size:.85em;margin-top:.2em\">" + caption + "</div></div>";

        // parsea  expr, [xa xb], [ya yb]  de un #surf/#map → (árbol, texto, rangos)
        private static (LispConverter.N f, string spec, double xa, double xb, double ya, double yb)
            ParseSurfArgs(string inside, Dictionary<string, LispConverter.N> byName, System.Globalization.CultureInfo inv)
        {
            LispConverter.N f = null; string spec = null;
            var ranges = new List<(double lo, double hi)>();
            foreach (var a0 in SplitTop(inside))
            {
                var a = a0.Trim(); if (a.Length == 0) continue;
                var rng = System.Text.RegularExpressions.Regex.Match(a, @"^\[\s*(-?[\d.]+)[\s,]+(-?[\d.]+)\s*\]$");
                if (rng.Success)
                {
                    double.TryParse(rng.Groups[1].Value, System.Globalization.NumberStyles.Any, inv, out var lo);
                    double.TryParse(rng.Groups[2].Value, System.Globalization.NumberStyles.Any, inv, out var hi);
                    ranges.Add((lo, hi)); continue;
                }
                if (f == null) { spec = a; if (!byName.TryGetValue(a, out f)) { try { f = LispConverter.ParseMath(a); } catch { } } }
            }
            double xa = 0, xb = 1, ya = 0, yb = 1;
            if (ranges.Count >= 1) { xa = ranges[0].lo; xb = ranges[0].hi; ya = xa; yb = xb; }
            if (ranges.Count >= 2) { ya = ranges[1].lo; yb = ranges[1].hi; }
            return (f, spec, xa, xb, ya, yb);
        }

        // UN #fplot (o ;grafica) → su SVG. rest = lo que sigue a la palabra clave.
        private static string OneFplotHtml(string rest, Dictionary<string, LispConverter.N> byName,
                                           List<(string, LispConverter.N)> fns, System.Globalization.CultureInfo inv)
        {
            rest = (rest ?? "").Trim();
            double lo = -1, hi = 1; string forcedVar = null;
            var sel = new List<(string, LispConverter.N)>();
            var paren = System.Text.RegularExpressions.Regex.Match(rest, @"^\((.*)\)\s*$", System.Text.RegularExpressions.RegexOptions.Singleline);
            if (paren.Success)   // estilo MATLAB: fplot(N1, N2, [-1 1])
            {
                foreach (var a0 in SplitTop(paren.Groups[1].Value))
                {
                    var a = a0.Trim(); if (a.Length == 0) continue;
                    var rng = System.Text.RegularExpressions.Regex.Match(a, @"^\[\s*(-?[\d.]+)[\s,]+(-?[\d.]+)\s*\]$");
                    if (rng.Success) { double.TryParse(rng.Groups[1].Value, System.Globalization.NumberStyles.Any, inv, out lo); double.TryParse(rng.Groups[2].Value, System.Globalization.NumberStyles.Any, inv, out hi); continue; }
                    AddFn(sel, byName, a);
                }
            }
            else   // forma simple: ;grafica s -1 1 [N1 N2 …]
            {
                var toks = rest.Split(new[] { ' ', ',', '\t' }, StringSplitOptions.RemoveEmptyEntries);
                int k = 0;
                if (toks.Length > 0 && !double.TryParse(toks[0], System.Globalization.NumberStyles.Any, inv, out _)) { forcedVar = toks[0]; k = 1; }
                if (toks.Length >= k + 2 && double.TryParse(toks[k], System.Globalization.NumberStyles.Any, inv, out lo) && double.TryParse(toks[k + 1], System.Globalization.NumberStyles.Any, inv, out hi))
                    for (int j = k + 2; j < toks.Length; j++) AddFn(sel, byName, toks[j]);
            }
            if (sel.Count == 0) sel = new List<(string, LispConverter.N)>(fns);   // sin argumentos → todas
            if (sel.Count == 0) return "";
            string var = forcedVar ?? LispConverter.FreeVar(sel[0].Item2);
            return LispConverter.PlotSvg(var, lo, hi, sel) ?? "";
        }

        // Construye TODAS las gráficas EN ORDEN de aparición (fplot / surf / map mezclados), una por
        // directiva. El resultado va, en ese orden, a rellenar los huecos hk-plotslot del documento.
        private static readonly System.Text.RegularExpressions.Regex RxAnyPlot = new System.Text.RegularExpressions.Regex(
            @"^\s*[;#]+\s*(fplot|plot|ezplot|graficas?|grafico|surf|superficie|plot3d|mesh|map|mapa|heatmap|contourf?|beam|viga|esquema|frame|portico|framedef|porticodef|slice|trozo|elemento|defl|diag|vmd)\b(.*)$",
            System.Text.RegularExpressions.RegexOptions.IgnoreCase);

        private static List<string> BuildPlotsOrdered(string editorText, List<string> forms, bool dark, out bool anySurf)
        {
            anySurf = false;
            var inv = System.Globalization.CultureInfo.InvariantCulture;
            var outList = new List<string>();
            // NOMBRE -> árbol del RESULTADO (permite referir por nombre: #surf(N_1,…), fplot(N1,…))
            var fns = new List<(string name, LispConverter.N tree)>();
            var byName = new Dictionary<string, LispConverter.N>();
            var todas = (forms ?? new List<string>()).SelectMany(f => (f ?? "").Replace("\r", "").Split('\n'));
            foreach (var raw in todas)
            {
                var m = System.Text.RegularExpressions.Regex.Match(raw.Trim(), @"^([A-Za-z][\w']*)\s*=\s*(?![=])(.+)$");
                if (!m.Success) continue;
                var partes = System.Text.RegularExpressions.Regex.Split(m.Groups[2].Value, @"\s=\s");
                try
                {
                    var tree = LispConverter.ParseLisp(partes[partes.Length - 1].Trim());
                    if (!byName.ContainsKey(m.Groups[1].Value)) { byName[m.Groups[1].Value] = tree; fns.Add((m.Groups[1].Value, tree)); }
                }
                catch { }
            }
            int surfId = 0;
            foreach (var lineRaw in (editorText ?? "").Replace("\r", "").Split('\n'))
            {
                var mm = RxAnyPlot.Match(lineRaw);
                if (!mm.Success) continue;
                string kw = mm.Groups[1].Value.ToLowerInvariant();
                string rest = mm.Groups[2].Value.Trim();
                bool isSurf = kw is "surf" or "superficie" or "plot3d" or "mesh";
                bool isMap = kw is "map" or "mapa" or "heatmap" or "contour" or "contourf";
                bool isBeam = kw is "beam" or "viga" or "esquema";
                bool isFrame = kw is "frame" or "portico";
                bool isFrameDef = kw is "framedef" or "porticodef";
                bool isSlice = kw is "slice" or "trozo" or "elemento";
                bool isDefl = kw is "defl";
                bool isDiag = kw is "diag" or "vmd";
                if (isDiag)
                {
                    try { string b64 = BeamSchematic.BeamDiagramsPng(dark); outList.Add(PlotWrap("<img style=\"max-width:100%;height:auto\" src=\"data:image/png;base64," + b64 + "\">", "la viga y sus diagramas (q, V, M, v)")); }
                    catch { outList.Add(""); }
                    continue;
                }
                if (isSlice)
                {
                    try { string b64 = BeamSchematic.SlicePng(dark); outList.Add(PlotWrap("<img style=\"max-width:100%;height:auto\" src=\"data:image/png;base64," + b64 + "\">", "equilibrio del trocito (dx)")); }
                    catch { outList.Add(""); }
                }
                else if (isDefl)
                {
                    try { string b64 = BeamSchematic.DeflPng(dark); outList.Add(PlotWrap("<img style=\"max-width:100%;height:auto\" src=\"data:image/png;base64," + b64 + "\">", "la deflexión v(x)")); }
                    catch { outList.Add(""); }
                }
                else if (isFrameDef)
                {
                    var pm = System.Text.RegularExpressions.Regex.Match(rest, @"^\((.*)\)\s*$", System.Text.RegularExpressions.RegexOptions.Singleline);
                    var a = SplitTop(pm.Success ? pm.Groups[1].Value : rest);
                    double N(int k) { if (k >= a.Count) return 0; var s = a[k].Trim(); var sl = s.Split('/'); return sl.Length == 2 && double.TryParse(sl[0], System.Globalization.NumberStyles.Any, inv, out var n1) && double.TryParse(sl[1], System.Globalization.NumberStyles.Any, inv, out var d1) && d1 != 0 ? n1 / d1 : (double.TryParse(s, System.Globalization.NumberStyles.Any, inv, out var v) ? v : 0); }
                    try { string b64 = BeamSchematic.FrameDeformedPng(N(0), N(1), N(2), dark); outList.Add(PlotWrap("<img style=\"max-width:100%;height:auto\" src=\"data:image/png;base64," + b64 + "\">", "deformada del pórtico (FEM)")); }
                    catch { outList.Add(""); }
                }
                else if (isBeam || isFrame)
                {
                    var pm = System.Text.RegularExpressions.Regex.Match(rest, @"^\((.*)\)\s*$", System.Text.RegularExpressions.RegexOptions.Singleline);
                    string bspec = pm.Success ? pm.Groups[1].Value : rest;
                    try
                    {
                        string b64 = isFrame ? BeamSchematic.FramePng(bspec, dark) : BeamSchematic.BeamPng(bspec, dark);
                        outList.Add(PlotWrap("<img style=\"max-width:100%;height:auto\" src=\"data:image/png;base64," + b64 + "\">",
                                             isFrame ? "esquema del pórtico (sin deformar)" : "esquema de la viga (sin deformar)"));
                    }
                    catch { outList.Add(""); }
                }
                else if (isSurf || isMap)
                {
                    var pm = System.Text.RegularExpressions.Regex.Match(rest, @"^\((.*)\)\s*$", System.Text.RegularExpressions.RegexOptions.Singleline);
                    if (!pm.Success) { outList.Add(""); continue; }
                    var (f, spec, xa, xb, ya, yb) = ParseSurfArgs(pm.Groups[1].Value, byName, inv);
                    if (f == null) { outList.Add(""); continue; }
                    var vs = LispConverter.VarsOf(f);
                    string vx = vs.Count > 0 ? vs[0] : "x", vy = vs.Count > 1 ? vs[1] : "y";
                    string enc = System.Net.WebUtility.HtmlEncode(spec ?? "");
                    try
                    {
                        if (isSurf)
                        {
                            anySurf = true;
                            string cv = SurfacePlot.SurfaceCanvas(f, vx, vy, xa, xb, ya, yb, surfId++);
                            outList.Add(PlotWrap(cv, "z = " + enc + "  ·  <span style=\"opacity:.7\">arrastra para girar</span>"));
                        }
                        else
                        {
                            string b64 = SurfacePlot.MapPng(f, vx, vy, xa, xb, ya, yb, dark);
                            outList.Add(PlotWrap("<img style=\"max-width:100%;height:auto\" src=\"data:image/png;base64," + b64 + "\">", "mapa de  " + enc + "  (planta)"));
                        }
                    }
                    catch { outList.Add(""); }
                }
                else   // familia fplot
                {
                    outList.Add(OneFplotHtml(rest, byName, fns, inv));
                }
            }
            return outList;
        }

        // agrega una función: por NOMBRE ya deducido, o expresión MATLAB inline (1-s^2)
        private static void AddFn(List<(string, LispConverter.N)> sel, Dictionary<string, LispConverter.N> byName, string spec)
        {
            if (byName.TryGetValue(spec, out var t)) { sel.Add((spec, t)); return; }
            try { var t2 = LispConverter.ParseMath(spec); if (t2 != null) sel.Add((spec, t2)); } catch { }
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
            // "A = B = C" → convierte cada tramo a matemática y une con " = " (todo en UNA línea)
            var partes = System.Text.RegularExpressions.Regex.Split(lispForm, @"\s=\s");
            var outp = new List<string>();
            foreach (var p in partes)
            {
                var t = p.Trim();
                if (System.Text.RegularExpressions.Regex.IsMatch(t, @"^[A-Za-z]\w*$")) { outp.Add(t); continue; }  // NAME
                try { outp.Add(LispConverter.ToLab(LispConverter.ParseLisp(t), 0)); } catch { outp.Add(t); }
            }
            return string.Join(" = ", outp);
        }

        /// <summary>El RESULTADO como FORMAS LISP. Autodetecta programa (ejecuta) vs expresiones
        /// (les aplica la operación elegida: auto/simplify/expand/deriv).</summary>
        private List<string> ComputeResult(string text, string dvar)
        {
            _ranProgram = false;
            if (string.IsNullOrWhiteSpace(text)) return new List<string>();

            // CaseMap: recuerda cómo escribió el usuario cada identificador con mayúsculas
            // (L, EI, N1…) para restaurar el case en el render (el motor los devuelve en minúscula).
            // SOLO líneas de matemática (no texto '#'/';'/'%' ni la etiqueta @@), para no cazar
            // palabras de la prosa como «Y», «El», «La».
            LispConverter.CaseMap.Clear();
            foreach (var raw in text.Replace("\r", "").Split('\n'))
            {
                var ln = raw.TrimStart();
                if (ln.Length == 0 || ln[0] == '#' || ln[0] == ';' || ln[0] == '%') continue;
                int at = ln.IndexOf("@@", StringComparison.Ordinal); if (at >= 0) ln = ln.Substring(0, at);
                foreach (System.Text.RegularExpressions.Match idm in
                         System.Text.RegularExpressions.Regex.Matches(ln, @"[A-Za-z_][A-Za-z0-9_]*"))
                {
                    string id = idm.Value; bool hasUp = false;
                    foreach (char c in id) if (c >= 'A' && c <= 'Z') { hasUp = true; break; }
                    if (hasUp) LispConverter.CaseMap[id.ToLowerInvariant()] = id;
                }
            }

            // Programas: LISP (defun/loop/let) o matemática imperativa (for/while) → EJECUTAR.
            if (LooksLikeLisp(text) && IsLispProgram(text))
            {
                if (!Balanced(text)) return new List<string> { "…  (paréntesis sin cerrar)" };
                _ranProgram = true;
                return new List<string> { RunLispClean(text) };
            }
            // Solo EJECUTAR (imperativo) si hay CONTROL DE FLUJO real (for/while/if/function).
            // Las asignaciones simples "N1 = expr" NO se ejecutan: son etiquetas simbólicas.
            if (!LooksLikeLisp(text) &&
                System.Text.RegularExpressions.Regex.IsMatch(text, @"(^|\n)\s*(for|while|if|function)\b"))
            {
                _ranProgram = true;
                try { return new List<string> { RunLispClean(MatlabToLisp.Translate(text).Executable) }; }
                catch (Exception ex) { return new List<string> { "…  (" + ex.Message + ")" }; }
            }

            // DESPEJAR: cada línea "lhs = rhs" (o "expr" que implica expr = 0) → resolver para la variable.
            if (_op == "despejar")
            {
                var disp = new List<string>();
                foreach (var raw in text.Replace("\r", "").Split('\n'))
                {
                    var line = raw.Trim();
                    if (line.Length == 0) { disp.Add(""); continue; }
                    var eq = line.Split(new[] { '=' }, 2);
                    string lhsF = LispFormOfLine(eq[0].Trim()) ?? "0";
                    string rhsF = LispFormOfLine(eq.Length > 1 ? eq[1].Trim() : "0") ?? "0";
                    string v = !string.IsNullOrWhiteSpace(dvar) ? dvar.Trim()
                             : ((lhsF + " " + rhsF).Contains("x") ? "x" : FirstVar(lhsF + " " + rhsF));
                    string sol = LispEngine.RunDespejar(lhsF, rhsF, v);
                    disp.Add(v + " = " + sol);
                }
                return disp;
            }

            // Expresiones (matemática o LISP) → aplicar la operación elegida.
            // Antes: unir las líneas de una MATRIZ multi-línea (el '[' sigue abierto). El salto de
            // línea dentro de [ ] es separador de FILA (MATLAB), así que se une con ';'.
            var lines = ExpandMathSemicolons(JoinBracketLines(text).Split('\n'));
            var formOf = new string[lines.Length];
            var labels = new string[lines.Length];   // nombre que DEFINE cada línea (N1, N2…) si es "NAME = expr"
            var textOf = new (string kind, string align, string text)?[lines.Length];  // directiva de TEXTO (; formato)
            var forms = new List<string>();
            var idx = new List<int>();
            var treeOf = new LispConverter.N[lines.Length];   // árbol de cada línea (para resolver etiquetas)
            var notationOf = new string[lines.Length];        // línea de NOTACIÓN pura (f(x)=…, y=f(x)=…): se dibuja, no se calcula
            var funcMap = new Dictionary<string, (List<string> ps, LispConverter.N body)>();  // f(x)=x²+1 → aplicar f(3)
            var deqTag = new string[lines.Length];             // etiqueta @@(…) que va a la DERECHA (estilo libro)
            // ETIQUETA de ecuación: @@(texto) al FINAL de una línea de MATEMÁTICA → número a la derecha.
            // La VARIABLE queda a la IZQUIERDA (como Calcpad/Hekatan Lab). Compat: acepta el viejo #deq.
            // Las líneas de TEXTO (#: ## #> ; %) y las gráficas no llevan etiqueta.
            for (int i = 0; i < lines.Length; i++)
            {
                var s = lines[i].TrimStart();
                bool textDir = s.StartsWith("#:") || s.StartsWith("##") || s.StartsWith("#>") ||
                               s.StartsWith("#<") || s.StartsWith("#|") || s.StartsWith(";") || s.StartsWith("%") ||
                               System.Text.RegularExpressions.Regex.IsMatch(s,
                                   @"^#\s*(fplot|plot|ezplot|graficas?|grafico|surf|superficie|plot3d|mesh|map|mapa|heatmap|contourf?|beam|viga|esquema|frame|portico|framedef|porticodef|slice|trozo|elemento|defl|diag|vmd)\b",
                                   System.Text.RegularExpressions.RegexOptions.IgnoreCase);
                if (textDir) continue;
                var m = System.Text.RegularExpressions.Regex.Match(lines[i], @"^(.*?)\s*@@\((.*?)\)\s*$");
                if (m.Success)
                {
                    lines[i] = System.Text.RegularExpressions.Regex.Replace(m.Groups[1].Value.Trim(), @"^#deq\s+", "");
                    deqTag[i] = m.Groups[2].Value;
                }
            }
            var isPlot = new bool[lines.Length];   // línea = directiva de gráfica → marca su POSICIÓN en el documento
            // PASO 1: parsear cada línea a árbol + detectar su etiqueta
            for (int i = 0; i < lines.Length; i++)
            {
                var exprText = lines[i];
                if (System.Text.RegularExpressions.Regex.IsMatch(lines[i],
                        @"^\s*[;#]+\s*(fplot|plot|ezplot|graficas?|grafico|surf|superficie|plot3d|mesh|map|mapa|heatmap|contourf?|beam|viga|esquema|frame|portico|framedef|porticodef|slice|trozo|elemento|defl|diag|vmd)\b",
                        System.Text.RegularExpressions.RegexOptions.IgnoreCase)) { isPlot[i] = true; continue; }
                var td = LispConverter.TextDirective(lines[i]);
                if (td != null) { textOf[i] = td; continue; }
                CollectFuncDefs(lines[i], funcMap);   // registra  f(x)=…  para poder aplicar f(3) después
                // NOTACIÓN de función / cadena de igualdades: se RENDERIZA tal cual, sin pasar por el motor.
                //   f(x) = x^2+1   ·   y = f(x) = x^2+1   ·   h(x) = f(G(x))
                // Regla (el porqué): es notación si hay ≥2 signos '=' (cadena), o si ANTES del 1er '='
                // aparece una llamada de función  id(…)  (definición). Un  N1 = (1-s)/2  NO lo es.
                var nt = NotationLine(lines[i]);
                if (nt != null) { notationOf[i] = nt; continue; }
                var lm = System.Text.RegularExpressions.Regex.Match(lines[i].Trim(),
                            @"^([A-Za-z][\w']*)\s*=\s*(?![=])(.+)$");   // NAME = expr  (no ==)
                if (lm.Success) { labels[i] = lm.Groups[1].Value; exprText = lm.Groups[2].Value; }
                treeOf[i] = TreeOfLine(exprText);
            }
            // mapa etiqueta → su árbol (para sustituir  Partial{v@x}  con la definición de v)
            var labelMap = new Dictionary<string, LispConverter.N>();
            for (int i = 0; i < lines.Length; i++)
                if (labels[i] != null && treeOf[i] != null && !labelMap.ContainsKey(labels[i]))
                    labelMap[labels[i]] = treeOf[i];
            // vecMap = etiquetas cuyo valor es un VECTOR o MATRIZ → así v(i)/A(i,j) es ÍNDICE (no función).
            // Es lo que diferencia f(x) de v(i): el NOMBRE está definido como función o como vector.
            var vecMap = new Dictionary<string, LispConverter.N>();
            foreach (var kv in labelMap)
                if (kv.Value != null && (kv.Value.Op == "vec" || kv.Value.Op == "mat"))
                    vecMap[kv.Key] = kv.Value;
            // PASO 2: sustituir etiquetas y pasar a LISP
            for (int i = 0; i < lines.Length; i++)
            {
                if (treeOf[i] == null) continue;
                try
                {
                    var app = (funcMap.Count > 0 || vecMap.Count > 0)
                              ? LispConverter.SubstFuncs(treeOf[i], funcMap, vecMap) : treeOf[i];  // f(3)→3²+1, v(2)→componente
                    var sub = LispConverter.SubstLabels(app, labelMap, labels[i], new HashSet<string>());
                    formOf[i] = LispConverter.ToLisp(sub);
                }
                catch { formOf[i] = null; }
                if (formOf[i] != null) { forms.Add(formOf[i]); idx.Add(i); }
            }
            bool hasVar = !string.IsNullOrWhiteSpace(dvar);   // dvar = variable de la parcial (∂/∂), o null = auto
            var results = LispEngine.EvalOp(forms, _op, dvar);
            var resOf = new string[lines.Length];
            for (int k = 0; k < idx.Count; k++) resOf[idx[k]] = k < results.Count ? results[k].Trim() : "";
            // Integral INDEFINIDA ( Integral{f @ x} sin límites ) → añade la constante  + C  (rigor matemático).
            for (int k = 0; k < idx.Count; k++)
            {
                int i = idx[k]; var t = treeOf[i];
                if (t != null && t.Op == "solver" && t.Atom == "integral" && t.Items != null && t.Items.Count == 2
                    && !string.IsNullOrEmpty(resOf[i]) && !resOf[i].StartsWith("(no-elem"))
                    resOf[i] = "(+ " + resOf[i] + " C)";
            }

            // Muestra el CÁLCULO: la ENTRADA (con nombre N1= y símbolo d/dx ó ∫ si aplica) y "= RESULTADO".
            var display = new List<string>();
            for (int i = 0; i < lines.Length; i++)
            {
                if (isPlot[i]) { display.Add(LispConverter.PlotSlot); continue; }   // gráfica: hueco en su posición
                if (textOf[i] != null)   // texto formateado (directiva ;): sustituye {Var} por su valor (math)
                {
                    var (kind, align, raw2) = textOf[i].Value;
                    string html = LispConverter.FormatInlineText(raw2,
                        name => LookupVarHtml(name, labels, resOf, formOf, funcMap, vecMap),
                        name => vecMap.TryGetValue(name, out var vt) && vt.Op == "vec");   // @v → flecha solo si v es VECTOR
                    display.Add(LispConverter.TxtLine(kind, align, html));
                    continue;
                }
                if (notationOf[i] != null) { display.Add(notationOf[i]); continue; }   // notación: ya viene en forma LISP "a = b = c"
                if (formOf[i] == null) { display.Add(""); continue; }
                // DEFINICIÓN de vector/matriz: es solo el dato, no lleva "= resultado".
                if (labels[i] != null && formOf[i].StartsWith("(vector"))
                { display.Add(labels[i] + " = " + formOf[i]); continue; }
                string lbl = labels[i];
                string v = hasVar ? dvar : FirstVar(formOf[i]);
                var r = resOf[i] ?? "";
                // hasR = hay RESULTADO distinto de la entrada. Comparo NORMALIZANDO (sin comillas ni
                // espacios): si el operador no cerró (devuelve la misma notación), no muestro "= <lo mismo>".
                bool hasR = r.Length > 0 && !r.Equals("nil", StringComparison.OrdinalIgnoreCase) && !SameForm(r, formOf[i]);

                if (_op == "deriv" || _op == "integ")
                {   // d/dv(N1) = …   ó   ∫ N1 dv = …  TODO EN UNA LÍNEA (notación = resultado)
                    string inner = lbl ?? formOf[i];
                    string notation = "(" + (_op == "deriv" ? "deriv" : "integ") + " " + inner + " " + v + ")";
                    // deriv: SIEMPRE muestra el resultado (d/dx(e^x)=e^x, aunque sea = input).
                    // integ: muestra el resultado salvo que el motor marque (no-elem …) = no supo integrarlo.
                    //        Así ∫e^x dx = e^x SÍ se muestra (aunque coincida con el input).
                    bool okR = r.Length > 0 && !r.Equals("nil", StringComparison.OrdinalIgnoreCase);
                    bool unsup = r.StartsWith("(no-elem");
                    bool showR = _op == "deriv" ? okR : (okR && !unsup);
                    display.Add(showR ? notation + " = " + r : notation);
                }
                else if (lbl != null)   // auto/simplify/expand con nombre → "N1 = <expr o resultado>"
                {
                    // si la fórmula tiene TOKENS (Partial, Factor…) muestra TÉRMINO = RESULTADO
                    // (el término entero renderiza a CSS, y al lado su valor simbólico).
                    if (HasOpCall(formOf[i]) && hasR)
                        display.Add(lbl + " = " + formOf[i] + " = " + r);
                    else if (hasR && r.StartsWith("(vector") && r != formOf[i])
                    {
                        // operación de matriz (A', A*B, A^-1…): muestra la OPERACIÓN con etiquetas
                        // (A⁻¹, A·A) Y la matriz resultado, en la misma línea. La forma con etiquetas
                        // viene del árbol ORIGINAL (treeOf), no del sustituido.
                        string opF = treeOf[i] != null ? LispConverter.ToLisp(treeOf[i]) : formOf[i];
                        display.Add(opF.StartsWith("(vector") ? lbl + " = " + r
                                                              : lbl + " = " + opF + " = " + r);
                    }
                    else if (_op == "auto" && hasR &&
                             System.Text.RegularExpressions.Regex.IsMatch(r, @"^-?\d+(\.\d+)?$|^-?\d+/\d+$"))
                        display.Add(lbl + " = " + formOf[i] + " = " + r);   // giro = M·l/(2·EI) = 3/5 (número o racional exacto)
                    else
                    {
                        string rhs = (_op == "auto" || !hasR) ? formOf[i] : r;
                        display.Add(lbl + " = " + rhs);
                    }
                }
                else                    // sin nombre → "entrada = resultado" EN UNA LÍNEA
                {
                    display.Add(hasR ? formOf[i] + " = " + r : formOf[i]);
                }
            }
            // #deq: pega la ETIQUETA (a la derecha) al final de la línea de display correspondiente.
            for (int i = 0; i < lines.Length && i < display.Count; i++)
                if (deqTag[i] != null && display[i].Length > 0 && !display[i].StartsWith(LispConverter.TxtMark))
                    display[i] += LispConverter.DeqSep + deqTag[i];
            return display;
        }

        /// <summary>¿La forma LISP tiene alguna VARIABLE LIBRE? (un identificador que no sea función/
        /// constante conocida). Si no la tiene, es puramente numérica y se puede evaluar sin miedo.</summary>
        private static bool HasFreeVar(string lisp)
        {
            foreach (System.Text.RegularExpressions.Match m in
                     System.Text.RegularExpressions.Regex.Matches(lisp, @"[A-Za-z_]\w*"))
            {
                var w = m.Value.ToLower();
                if (w is "expt" or "sqrt" or "sin" or "cos" or "tan" or "exp" or "log" or "abs"
                    or "pi" or "vector" or "e") continue;
                return true;
            }
            return false;
        }

        /// <summary>Primera variable libre de una forma LISP (para la notación d/dx, ∫…dx).</summary>
        private static string FirstVar(string lispForm)
        {
            foreach (System.Text.RegularExpressions.Match m in
                     System.Text.RegularExpressions.Regex.Matches(lispForm, @"[A-Za-z_]\w*"))
            {
                var w = m.Value.ToLower();
                if (w is "expt" or "sqrt" or "sin" or "cos" or "tan" or "exp" or "log" or "abs"
                    or "vector" or "deriv" or "integ" or "pi") continue;
                return m.Value;
            }
            return "x";
        }

        /// <summary>La línea (matemática o LISP) → su forma LISP; null si está vacía o no parsea.</summary>
        // {Var} en un texto: busca la etiqueta definida en la hoja y devuelve su valor renderizado (math).
        // Si no es una etiqueta, intenta la expresión literal (número/fórmula). null = déjalo tal cual.
        private static string LookupVarHtml(string name, string[] labels, string[] resOf, string[] formOf,
                                            Dictionary<string, (List<string> ps, LispConverter.N body)> funcMap = null,
                                            Dictionary<string, LispConverter.N> vecMap = null)
        {
            // 1) ¿es una ETIQUETA definida en la hoja? → su resultado (ya calculado en el lote)
            for (int j = 0; j < labels.Length; j++)
                if (labels[j] == name)
                {
                    var r = !string.IsNullOrEmpty(resOf[j]) && !resOf[j].Equals("nil", StringComparison.OrdinalIgnoreCase)
                            ? resOf[j] : formOf[j];
                    try { return LispConverter.ToHtml(LispConverter.ParseLisp(r)); } catch { return null; }
                }
            // 2) expresión suelta: aplica funciones (f(3)→3²+1) y, si trae un TOKEN (Factor, Partial,
            //    Simplify…), COMPÚTALA con el motor y renderiza el resultado; si no, tal cual.
            try
            {
                var tree = LispConverter.ParseMath(name);
                if ((funcMap != null && funcMap.Count > 0) || (vecMap != null && vecMap.Count > 0))
                    tree = LispConverter.SubstFuncs(tree, funcMap ?? new Dictionary<string, (List<string>, LispConverter.N)>(), vecMap);
                var lisp = LispConverter.ToLisp(tree);
                // Computa SOLO si hay token (Factor/Partial/…) o si es TOTALMENTE numérico (sin variable
                // libre, ej. N1(-1)=1). Un símbolo como N_i NO se toca: se dibuja tal cual (si lo pasáramos
                // por el motor, una variable libre podría dar 0 o volver en minúscula).
                if (HasOpCall(lisp) || !HasFreeVar(lisp))
                {
                    var res = LispEngine.EvalOp(new List<string> { lisp }, "auto", null);
                    var rr = res.Count > 0 ? res[0].Trim() : "";
                    if (rr.Length > 0 && !rr.Equals("nil", StringComparison.OrdinalIgnoreCase) && rr != lisp)
                        return LispConverter.ToHtml(LispConverter.ParseLisp(rr));
                }
                return LispConverter.ToHtml(tree);
            }
            catch { return null; }
        }

        /// <summary>Si la línea es NOTACIÓN (definición de función o cadena de igualdades), la
        /// convierte a la forma LISP "a = b = c" que RenderPage dibuja lado a lado SIN evaluar.
        /// Devuelve null si no es notación (entonces sigue el camino normal de cálculo).
        /// El porqué: f(x)=x²+1 no es un cálculo, es una definición; hay que DIBUJARLA, no resolverla.</summary>
        /// <summary>Posiciones de los '=' de NIVEL 0 (fuera de { } ( ) [ ]), que no sean == <= >= !=.
        /// Así el '=' de los límites de un token — Slope{f @ x = a} — NO se confunde con una igualdad.</summary>
        private static List<int> TopLevelEquals(string s)
        {
            var pos = new List<int>(); int depth = 0;
            for (int i = 0; i < s.Length; i++)
            {
                char c = s[i];
                if (c == '{' || c == '(' || c == '[') depth++;
                else if (c == '}' || c == ')' || c == ']') { if (depth > 0) depth--; }
                else if (c == '=' && depth == 0
                         && (i == 0 || "=<>!".IndexOf(s[i - 1]) < 0)
                         && (i == s.Length - 1 || s[i + 1] != '='))
                    pos.Add(i);
            }
            return pos;
        }

        private static string NotationLine(string raw)
        {
            var line = raw.Trim();
            if (line.Length == 0 || line.StartsWith("(")) return null;   // LISP crudo no
            var eqs = TopLevelEquals(line);   // solo '=' de NIVEL 0 (el '=' interno de Slope{f@x=a} NO cuenta)
            if (eqs.Count == 0) return null;
            // antes del PRIMER '=' ¿hay una llamada de función  id(  ?  (definición f(x)= …)
            string lhs0 = line.Substring(0, eqs[0]);
            bool funcDef = System.Text.RegularExpressions.Regex.IsMatch(lhs0, @"[A-Za-z_]\w*\s*\(");
            if (eqs.Count < 2 && !funcDef) return null;                  // un solo '=' sin función = cálculo normal
            // partir en segmentos por cada '=' de nivel 0
            var segs = new List<string>(); int prev = 0;
            foreach (var pe in eqs) { segs.Add(line.Substring(prev, pe - prev)); prev = pe + 1; }
            segs.Add(line.Substring(prev));
            var outParts = new List<string>();
            foreach (var s in segs)
            {
                var t = s.Trim();
                if (t.Length == 0) return null;
                var f = LispFormOfLine(t);
                if (f == null) return null;   // si algún lado no parsea, que lo maneje el camino normal
                outParts.Add(f);
            }
            return string.Join(" = ", outParts);
        }

        private static string LispFormOfLine(string line)
        {
            line = line.Trim();
            if (line.Length == 0) return null;
            if (LooksLikeLisp(line)) return line;             // ya es LISP
            try { return LispConverter.MathToLisp(line); } catch { return null; }
        }

        /// <summary>Registra las definiciones de función de una línea:  f(x) = cuerpo  (también dentro de
        /// una cadena  y = f(x) = cuerpo). Guarda nombre → (parámetros, árbol del cuerpo) para luego
        /// APLICAR  f(3), f(a), f(G(x))  por sustitución (β-reducción, el método de la época LISP).</summary>
        private static void CollectFuncDefs(string raw, Dictionary<string, (List<string> ps, LispConverter.N body)> map)
        {
            var line = raw.Trim();
            if (line.Length == 0 || line.StartsWith("(")) return;
            var eqs = TopLevelEquals(line);   // no partir por el '=' interno de un token solver
            if (eqs.Count == 0) return;
            var segs = new List<string>(); int prev = 0;
            foreach (var pe in eqs) { segs.Add(line.Substring(prev, pe - prev)); prev = pe + 1; }
            segs.Add(line.Substring(prev));
            if (segs.Count < 2) return;
            for (int i = 0; i < segs.Count - 1; i++)
            {
                var m = System.Text.RegularExpressions.Regex.Match(segs[i].Trim(), @"^([A-Za-z]\w*)\s*\(([^)]*)\)$");
                if (!m.Success) continue;
                var name = m.Groups[1].Value;
                var ps = new List<string>();
                bool ok = true;
                foreach (var p in m.Groups[2].Value.Split(','))
                {
                    var pn = p.Trim();
                    if (pn.Length == 0) continue;
                    if (!System.Text.RegularExpressions.Regex.IsMatch(pn, @"^[A-Za-z]\w*$")) { ok = false; break; }
                    ps.Add(pn);
                }
                if (!ok || ps.Count == 0 || map.ContainsKey(name)) continue;
                try
                {
                    var body = LispConverter.ParseMath(segs[i + 1].Trim());
                    if (body != null) map[name] = (ps, body);
                }
                catch { }
            }
        }

        // ¿la forma LISP contiene alguna llamada de operación (Partial, Factor, ∫, …)?
        private static readonly string[] OpCalls = {
            "(partial","(derive-x","(factor","(expand*","(integ-var","(integ-x","(area-under","(slope-at",
            "(suma","(producto-op","(root-op","(find-op","(sup-op","(inf-op","(repeat-op","(limite" };
        private static bool HasOpCall(string f) => f != null && System.Array.Exists(OpCalls, s => f.Contains(s));
        // dos formas LISP son "la misma" salvo comillas de quote y espacios (un operador que NO cerró
        // devuelve su propia notación: no debe mostrarse como "entrada = <lo mismo>").
        private static string NormForm(string s) =>
            s == null ? "" : s.Replace("(quote ", "(").Replace("'", "").Replace(" ", "");
        private static bool SameForm(string a, string b) => NormForm(a) == NormForm(b);

        // la línea (matemática o LISP) → su ÁRBOL (para resolver etiquetas antes de pasar a LISP)
        /// <summary>Une las líneas de una MATRIZ que abarca varios renglones (el '[' quedó abierto).
        /// El salto de línea DENTRO de [ ] es separador de FILA en MATLAB → se une con ';' (salvo que
        /// el renglón ya termine en ';' , ',' o '[', para no meter una fila vacía). Fuera de [ ] no toca nada.
        ///   B = [1 2;\n   3 4]   →   B = [1 2; 3 4]      ·      [1 2\n 3 4]  →  [1 2; 3 4]</summary>
        private static string JoinBracketLines(string text)
        {
            var raw = text.Replace("\r", "").Split('\n');
            var outLines = new List<string>();
            string buf = null;
            foreach (var ln in raw)
            {
                if (buf == null) buf = ln;
                else
                {
                    var tb = buf.TrimEnd();
                    // '...' = CONTINUACIÓN MATLAB: se pega el siguiente renglón EN LA MISMA FILA
                    // (el salto NO cuenta como separador). Fuera o dentro de [ ] (aquí, matrices).
                    if (tb.EndsWith("..."))
                        buf = tb.Substring(0, tb.Length - 3).TrimEnd() + " " + ln.Trim();
                    else
                    {
                        char last = tb.Length > 0 ? tb[tb.Length - 1] : ' ';
                        // salto de línea dentro de [ ] = nueva FILA (';'), salvo que ya venga ; , o [
                        buf = (last == ';' || last == ',' || last == '[') ? tb + " " + ln.Trim()
                                                                          : tb + "; " + ln.Trim();
                    }
                }
                int depth = 0;
                foreach (char c in buf) { if (c == '[') depth++; else if (c == ']') depth--; }
                bool cont = buf.TrimEnd().EndsWith("...");   // sigue continuando (dentro o fuera de [ ])
                if (depth <= 0 && !cont) { outLines.Add(buf); buf = null; }   // completa
            }
            if (buf != null) outLines.Add(buf.Replace("...", " "));
            return string.Join("\n", outLines);
        }

        private static LispConverter.N TreeOfLine(string line)
        {
            line = line.Trim();
            if (line.Length == 0) return null;
            try { return LooksLikeLisp(line) ? LispConverter.ParseLisp(line) : LispConverter.ParseMath(line); }
            catch { return null; }
        }

        // ---------- motor: expresiones y programas ----------
        private static bool LooksLikeLisp(string t)
        {
            if (t.TrimStart().StartsWith(";")) return true;
            // (a) una palabra clave LISP tras '(' → seguro es LISP
            if (System.Text.RegularExpressions.Regex.IsMatch(t,
                @"\(\s*(defun|defparameter|defvar|let\*?|setf|setq|loop|format|print|progn|cond|when|unless|lambda|dolist|dotimes|expt|list|vector|deriv|dsimp|simplif|and|or|not)\b"))
                return true;
            // (b) forma prefija de operador  (- 1 2) : el '(' NO va pegado a un identificador
            //     (si no, N1(-1) sería "resta LISP") y el operador lleva ESPACIO detrás (LISP: "(- 1",
            //     no matemática "(-1)").  Así f(-1), sin(-x), (1-s)/2 quedan como MATEMÁTICA.
            return System.Text.RegularExpressions.Regex.IsMatch(t, @"(?<![A-Za-z0-9_.])\(\s*[-+*/=<>]\s");
        }

        private static bool IsLispProgram(string t)
            => System.Text.RegularExpressions.Regex.IsMatch(t,
                @"\(\s*(defun|defparameter|defvar|let\*?|setf|setq|loop|progn|format|print|dolist|dotimes|lambda|cond|when|unless)\b");

        private static string RunLispClean(string code)
        {
            // carga el motor (deriv, simplify, expand*…) para que los PROGRAMAS puedan usarlo:
            // así puedes DEDUCIR (ej. una función lagrange que arma las funciones de forma).
            var engine = System.IO.Path.Combine(AppContext.BaseDirectory, "engine.lisp").Replace("\\", "/");
            // *print-right-margin* grande: que NO parta las formas largas (si no, un (- ... ) se corta
            // en dos líneas y el render lo lee incompleto como una negación).
            string pre = "(setf *print-case* :downcase)\n(setf *print-right-margin* 100000)\n(load \"" + engine + "\")\n";
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

        private static bool Balanced(string code)
        {
            int b = 0;
            foreach (var c in code) { if (c == '(') b++; else if (c == ')') { b--; if (b < 0) return false; } }
            return b == 0;
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

        private static string ConvertEditor(string text, bool toLisp)
        {
            if (string.IsNullOrWhiteSpace(text)) return text;
            // Un PROGRAMA LISP (o el script "LISP completo") YA es LISP: NO convertir línea por
            // línea (mangaría (load …)/(setf …) que MathToLisp no entiende). Se devuelve igual.
            if (toLisp && LooksLikeLisp(text) && IsLispProgram(text)) return text;
            // Solo un PROGRAMA con CONTROL DE FLUJO real (for/while/if/function) va en bloque.
            // "A = x+1" NO es programa: es una ETIQUETA simbólica (se convierte lado a lado).
            if (toLisp && !LooksLikeLisp(text) &&
                System.Text.RegularExpressions.Regex.IsMatch(text, @"(^|\n)\s*(for|while|if|function)\b"))
            {
                try { return MatlabToLisp.Translate(text).Lisp; } catch { return text; }
            }
            var sb = new StringBuilder();
            // varias asignaciones en una línea (a = 2; b = 3) → una por línea, igual que en el render
            foreach (var raw in ExpandMathSemicolons(text.Replace("\r", "").Split('\n')))
            {
                var l = raw.Trim();
                if (l.Length == 0) { sb.AppendLine(); continue; }
                // COMENTARIO/DIRECTIVA ';' (texto, gráfica, ;;): se conserva TAL CUAL en ambos sentidos.
                // (si no, ToLab(ParseLisp(";# título")) leería solo el 1er token y borraría el texto)
                if (l.StartsWith(";")) { sb.AppendLine(l); continue; }
                // DIRECTIVA '#' (markdown #:/##, #fplot, #deq): se conserva. En #deq se convierte SOLO
                // la ecuación interna (dejando el prefijo #deq y la etiqueta @@(…) intactos).
                if (l.StartsWith("#"))
                {
                    var dm = System.Text.RegularExpressions.Regex.Match(l, @"^#deq\s+(.*?)\s*(?:@@\((.*?)\))?\s*$");
                    if (toLisp)
                    {
                        // a expr LISP: #deq → (setf…) + etiqueta como comentario ';' ; el texto markdown (#: ##) → ';'
                        if (dm.Success)
                            sb.AppendLine(ConvertEqLine(dm.Groups[1].Value.Trim(), true) +
                                          (dm.Groups[2].Success ? "   ; " + dm.Groups[2].Value : ""));
                        else
                            sb.AppendLine("; " + l.TrimStart('#', ':', '|', '<', '>', ' '));
                    }
                    else   // a matemática: conserva el markdown (el reverso real llega por _lispBackup)
                    {
                        if (dm.Success)
                            sb.AppendLine("#deq " + ConvertEqLine(dm.Groups[1].Value.Trim(), false) +
                                          (dm.Groups[2].Success ? " @@(" + dm.Groups[2].Value + ")" : ""));
                        else sb.AppendLine(l);
                    }
                    continue;
                }
                // línea de MATEMÁTICA: extrae la etiqueta @@(…) del final (queda como comentario en LISP,
                // y se conserva en matemática). La variable sigue a la izquierda.
                string tg = null; var mt = System.Text.RegularExpressions.Regex.Match(l, @"^(.*?)\s*@@\((.*?)\)\s*$");
                if (mt.Success) { tg = mt.Groups[2].Value; l = mt.Groups[1].Value.Trim(); }
                string conv = ConvertEqLine(l, toLisp);
                if (tg != null) conv += toLisp ? "   ; " + tg : " @@(" + tg + ")";
                sb.AppendLine(conv);
            }
            return sb.ToString().TrimEnd();
        }

        // convierte UNA ecuación entre matemática y LISP:  (setf N f)↔N=math ,  N=expr↔(setf N f) ,  o expr suelta.
        // Si algo no parsea, devuelve la línea TAL CUAL (nunca rompe la conversión global).
        private static string ConvertEqLine(string l, bool toLisp)
        {
            var sm = System.Text.RegularExpressions.Regex.Match(l, @"^\(setf\s+([A-Za-z]\w*)\s+(.+)\)$");
            if (!toLisp && sm.Success)
            {
                try { return sm.Groups[1].Value + " = " + LispConverter.ToLab(LispConverter.ParseLisp(sm.Groups[2].Value.Trim()), 0); }
                catch { return l; }
            }
            // DEFINICIÓN de función  f(x) = expr  (ej. N_1(x) = 1 - x/L): mantiene el LHS, convierte el RHS.
            var fm = System.Text.RegularExpressions.Regex.Match(l, @"^([A-Za-z]\w*)\(([^)]*)\)\s*=\s*(?![=])(.+)$");
            if (fm.Success)
            {
                string rhs = fm.Groups[3].Value.Trim();
                try
                {
                    if (toLisp)
                    {
                        string lispRhs = LooksLikeLisp(rhs) ? rhs : LispConverter.MathToLisp(rhs);
                        return "(defun " + fm.Groups[1].Value + " (" + fm.Groups[2].Value.Replace(",", " ").Trim() + ") " + lispRhs + ")";
                    }
                    string cv = LooksLikeLisp(rhs) ? LispConverter.ToLab(LispConverter.ParseLisp(rhs), 0) : rhs;
                    return fm.Groups[1].Value + "(" + fm.Groups[2].Value + ") = " + cv;
                }
                catch { return l; }
            }
            var lm = System.Text.RegularExpressions.Regex.Match(l, @"^([A-Za-z][\w']*)\s*=\s*(?![=])(.+)$");
            if (lm.Success)
            {
                string rhs = lm.Groups[2].Value.Trim();
                try
                {
                    if (toLisp)
                    {
                        string lispRhs = LooksLikeLisp(rhs) ? rhs : LispConverter.MathToLisp(rhs);
                        return "(setf " + LispConverter.SafeName(lm.Groups[1].Value) + " " + lispRhs + ")";
                    }
                    string conv = LooksLikeLisp(rhs) ? LispConverter.ToLab(LispConverter.ParseLisp(rhs), 0) : rhs;
                    return LispConverter.SafeName(lm.Groups[1].Value) + " = " + conv;
                }
                catch { return l; }
            }
            bool isLisp = LooksLikeLisp(l);
            try
            {
                if (toLisp) return isLisp ? l : LispConverter.MathToLisp(l);
                return isLisp ? LispConverter.ToLab(LispConverter.ParseLisp(l), 0) : l;
            }
            catch { return l; }
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

        // El LISP COMPLETO y EJECUTABLE: carga el motor, cita ('), imprime. Se copia a un .lisp
        // en blanco y CORRE en SBCL tal cual. (La vista "LISP" y el botón "📋 LISP completo" lo usan.)
        private string BuildFullLisp(string text)
        {
            if (string.IsNullOrWhiteSpace(text)) return "";
            var enginePath = Path.Combine(AppContext.BaseDirectory, "engine.lisp").Replace("\\", "/");
            var sb = new StringBuilder();
            var sbclDir = Path.Combine(AppContext.BaseDirectory, "sbcl").Replace("\\", "/");
            sb.AppendLine(";;;; Script LISP ejecutable — generado por Hekatan LISP");
            sb.AppendLine(";;;; CÓMO CORRERLO (PowerShell): primero 'cd' a la carpeta de ESTE archivo, o usa su ruta completa.");
            sb.AppendLine(";;;;   & \"" + sbclDir + "/sbcl.exe\" --core \"" + sbclDir + "/sbcl.core\" --script \"<ruta_completa_de_este_archivo>\"");
            sb.AppendLine(";;;; (OJO: si pasas solo el nombre, SBCL lo busca en la carpeta ACTUAL de la consola, no donde está el .lisp)");
            sb.AppendLine(";;;; (el ' cita las expresiones como DATOS: no evalúa x, las manipula simbólico)");
            sb.AppendLine("(load \"" + enginePath + "\")");
            sb.AppendLine("(setf *print-case* :downcase)");
            sb.AppendLine("(setf *print-right-margin* 100000)   ; no partir formas largas en 2 lineas");
            sb.AppendLine();

            if (LooksLikeLisp(text) && IsLispProgram(text))
            {
                sb.AppendLine(";; es un PROGRAMA: se ejecuta tal cual (ya imprime con format)");
                sb.AppendLine(text.Trim());
            }
            else
            {
                string opfn = _op switch
                {
                    "simplify" => "factor", "expand" => "expand*",
                    "deriv" => "derive-x", "integ" => "integ-x", _ => null
                };
                sb.AppendLine(";; una fórmula por bloque: MATLAB (comentario) + LISP (ejecutable) + resultado (" + _op + ")");
                sb.AppendLine(";; (las líneas ';' de TEXTO/gráfica se conservan como comentario: al correr NO se ven, solo Hekatan LISP las dibuja)");
                int idx = 1;
                foreach (var raw in text.Replace("\r", "").Split('\n'))
                {
                    var line = raw.Trim();
                    if (line.Length == 0) { sb.AppendLine(); continue; }
                    if (line.StartsWith(";")) { sb.AppendLine(line); continue; }   // texto/gráfica/comentario: VERBATIM
                    // etiqueta NOMBRE = expr → usa el lado DERECHO (si no, ParseMath descarta el '=')
                    var lm = System.Text.RegularExpressions.Regex.Match(line, @"^([A-Za-z][\w']*)\s*=\s*(?![=])(.+)$");
                    var f = LispFormOfLine(lm.Success ? lm.Groups[2].Value : line);
                    if (f == null) continue;
                    string matlab; try { matlab = LispConverter.ToLab(LispConverter.ParseLisp(f), 0); } catch { matlab = f; }
                    sb.AppendLine();
                    sb.AppendLine(";; ── fórmula " + idx + " ──");
                    sb.AppendLine(";;    MATLAB:  " + matlab);
                    sb.AppendLine(";;    LISP:    " + f);
                    // operador SOLVER de Calcpad ($Area/$Slope/…): SIEMPRE se EVALÚA (imprime su resultado),
                    // aunque la operación sea "tal cual". Si no, saldría (slope-at …) sin calcular.
                    bool isSolver = System.Text.RegularExpressions.Regex.IsMatch(f,
                        @"^\(\s*(area-under|slope-at|suma|producto-op|root-op|find-op|sup-op|inf-op|repeat-op)\b");
                    if (isSolver)
                        sb.AppendLine("(let ((r (ignore-errors " + f + "))) (format t \"" +
                                      matlab.Replace("\\", "\\\\").Replace("\"", "\\\"") +
                                      "  =>  ~a~%\" (cond ((null r) '?) ((consp r) (or (ignore-errors (infix r)) r)) (t r))))");
                    // imprime en MATEMÁTICA (infix) y también deja ver la forma LISP entre paréntesis
                    else if (opfn == null)
                        sb.AppendLine("(let ((e '" + f + ")) (format t \"~a       (LISP: ~a)~%\" (infix e) e))");
                    else
                        sb.AppendLine("(let* ((e '" + f + ") (r (or (ignore-errors (" + opfn +
                                      " e)) e))) (format t \"~a  =>  ~a       (LISP: ~a)~%\" (infix e) (infix r) r))");
                    idx++;
                }
            }
            return sb.ToString();
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
                        var path = f;
                        var mi = new MenuItem { Header = Path.GetFileNameWithoutExtension(f) };
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
            Title = string.IsNullOrEmpty(path) ? "Hekatan LISP" : "Hekatan LISP — " + Path.GetFileName(path);
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
                Editor.Text = File.ReadAllText(path);
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
                Filter = "LISP (*.lisp)|*.lisp|Todos (*.*)|*.*",
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
                Filter = "LISP (*.lisp)|*.lisp",
                InitialDirectory = !string.IsNullOrEmpty(_currentFile) ? Path.GetDirectoryName(_currentFile) : DocsDir,
                FileName = !string.IsNullOrEmpty(_currentFile) ? Path.GetFileName(_currentFile) : "mi_script.lisp"
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
                System.Linq.Enumerable.Where(LispSymbols, sy => sy.StartsWith(prefix, StringComparison.OrdinalIgnoreCase)));
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

        // MATLAB 2017a REAL (Symbolic Toolbox): syms + diff/int/simplify + tic/toc. Copiable y ejecutable.
        private string BuildRealMatlab(string text)
        {
            if (string.IsNullOrWhiteSpace(text)) return "";
            var vars = new SortedSet<string>(StringComparer.Ordinal);
            var body = new StringBuilder();
            string OpCall(string e) => _op switch
            {
                "simplify" => "factor(" + e + ")",
                "expand" => "expand(" + e + ")",
                "deriv" => "diff(" + e + ")",
                "integ" => "int(" + e + ")",
                _ => e
            };
            // texto de Hekatan LISP → texto de Hekatan Lab: {Var}→@{Var}; quita *negrita*/_cursiva_ inline
            // (el %'... de Hekatan Lab NO procesa markdown inline; dejaría los * y _ visibles).
            string MdVars(string t)
            {
                t = System.Text.RegularExpressions.Regex.Replace(t ?? "", @"\*([^*]+)\*", "$1");
                t = System.Text.RegularExpressions.Regex.Replace(t, @"_([^_]+)_", "$1");
                return System.Text.RegularExpressions.Regex.Replace(t, @"\{([^}]+)\}", "@{$1}");
            }
            foreach (var raw in text.Replace("\r", "").Split('\n'))
            {
                var line = raw.Trim();
                if (line.Length == 0) { body.AppendLine(); continue; }
                // #deq  ecuación  @@(etiqueta)  → ecuación MATLAB + etiqueta como comentario '%'
                var dq = System.Text.RegularExpressions.Regex.Match(line, @"^#deq\s+(.*?)\s*(?:@@\((.*?)\))?\s*$");
                if (dq.Success)
                {
                    string eql = dq.Groups[1].Value.Trim();
                    string tg = dq.Groups[2].Success ? "   % " + dq.Groups[2].Value : "";
                    // LHS puede ser  f(x)=…  (definición) o  N=…  (etiqueta); si no, expr suelta.
                    var fmd = System.Text.RegularExpressions.Regex.Match(eql, @"^([A-Za-z]\w*)\(([^)]*)\)\s*=\s*(?![=])(.+)$");
                    var lmd = System.Text.RegularExpressions.Regex.Match(eql, @"^([A-Za-z][\w']*)\s*=\s*(?![=])(.+)$");
                    string lhs = fmd.Success ? LispConverter.SafeName(fmd.Groups[1].Value) + "(" + fmd.Groups[2].Value + ")"
                               : lmd.Success ? LispConverter.SafeName(lmd.Groups[1].Value) : null;
                    string rh  = fmd.Success ? fmd.Groups[3].Value : lmd.Success ? lmd.Groups[2].Value : eql;
                    string mx;
                    try
                    {
                        var tr = LooksLikeLisp(rh) ? LispConverter.ParseLisp(rh) : LispConverter.ParseMath(rh);
                        LispConverter.LabMatlab = true;
                        try { mx = LispConverter.ToLab(tr, 0); } finally { LispConverter.LabMatlab = false; }
                        foreach (var v in LispConverter.VarsOf(tr)) vars.Add(v);
                    }
                    catch { mx = rh; }
                    body.AppendLine((lhs != null ? lhs + " = " + OpCall(mx) : OpCall(mx)) + tg);
                    continue;
                }
                // GRÁFICA:  ;fplot / #fplot (x^2, [0 1])  →  plot(linspace, arrayfun) (Hekatan Lab NO tiene fplot).
                var fp = System.Text.RegularExpressions.Regex.Match(line,
                    @"^[;#]+\s*(?:fplot|plot|ezplot)\s*\(\s*(.+?)\s*,\s*\[\s*([^\]\s]+)\s+([^\]\s]+)\s*\]\s*\)\s*$",
                    System.Text.RegularExpressions.RegexOptions.IgnoreCase);
                if (fp.Success)
                {
                    string ex = fp.Groups[1].Value.Trim();
                    string pv = "x"; try { pv = LispConverter.FreeVar(LispConverter.ParseMath(ex)) ?? "x"; } catch { }
                    string rng = "linspace(" + fp.Groups[2].Value + ", " + fp.Groups[3].Value + ", 200)";
                    body.AppendLine("plot(" + rng + ", arrayfun(@(" + pv + ") " + ex + ", " + rng + "))");
                    continue;
                }
                // TEXTO con formato:  directiva ';' O '#' (markdown) → markup de Hekatan Lab
                //   (%" título · %'| centro · %'> der · %' texto)
                var td = LispConverter.TextDirective(line);
                if (td != null && (line.StartsWith(";") || line.StartsWith("#")))
                {
                    var (kind, align, txt) = td.Value;
                    txt = MdVars(txt);
                    string pfx = (kind == "h1" || kind == "h2") ? "%\" "
                               : align == "center" ? "%'| "
                               : align == "right" ? "%'> " : "%' ";
                    body.AppendLine(pfx + txt);
                    continue;
                }
                if (line.StartsWith("%")) { body.AppendLine(line); continue; }   // ya es MATLAB
                if (line.StartsWith(";")) continue;                              // comentario LISP suelto
                if (line.StartsWith("#")) { body.AppendLine("%' " + MdVars(line.TrimStart('#', ' '))); continue; }  // '#' suelto → comentario
                // etiqueta @@(…) al final → comentario '%'
                string mtag = "";
                var em = System.Text.RegularExpressions.Regex.Match(line, @"^(.*?)\s*@@\((.*?)\)\s*$");
                if (em.Success) { mtag = "   % " + em.Groups[2].Value; line = em.Groups[1].Value.Trim(); }
                var fmn = System.Text.RegularExpressions.Regex.Match(line, @"^([A-Za-z]\w*)\(([^)]*)\)\s*=\s*(?![=])(.+)$");
                var lm  = System.Text.RegularExpressions.Regex.Match(line, @"^([A-Za-z][\w']*)\s*=\s*(?![=])(.+)$");
                string lhs2 = fmn.Success ? LispConverter.SafeName(fmn.Groups[1].Value) + "(" + fmn.Groups[2].Value + ")"
                            : lm.Success ? LispConverter.SafeName(lm.Groups[1].Value) : null;
                string rhs = fmn.Success ? fmn.Groups[3].Value : lm.Success ? lm.Groups[2].Value : line;
                string mexpr;
                try
                {
                    var tree = LooksLikeLisp(rhs) ? LispConverter.ParseLisp(rhs) : LispConverter.ParseMath(rhs);
                    LispConverter.LabMatlab = true;                 // solver → MATLAB (int, diff, symsum…)
                    try { mexpr = LispConverter.ToLab(tree, 0); } finally { LispConverter.LabMatlab = false; }
                    foreach (var v in LispConverter.VarsOf(tree)) vars.Add(v);
                }
                catch { mexpr = rhs; }
                body.AppendLine((lhs2 != null ? lhs2 + " = " + OpCall(mexpr) : OpCall(mexpr)) + mtag);
            }
            var sb = new StringBuilder();
            sb.AppendLine("% Hekatan Lab / MATLAB (Symbolic) — cópialo a Hekatan Lab: texto, operación y gráfica igual.");
            sb.AppendLine("% Para MEDIR el tiempo, rodéalo con  tic ... toc  (en LISP: get-internal-real-time).");
            if (vars.Count > 0) sb.AppendLine("syms " + string.Join(" ", vars));
            sb.Append(body);
            return sb.ToString().TrimEnd();
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
