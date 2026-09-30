using System;
using System.Collections.Generic;
using System.IO;
using System.Threading.Tasks;
using System.Windows;
using System.Windows.Controls;
using System.Windows.Controls.Primitives;
using System.Windows.Media;
using System.Windows.Media.Imaging;

namespace HekatanLisp
{
    /// <summary>
    /// Canal --ctl: pulsar CUALQUIER botón o menú de la ventana y ver qué pasó (27-sep-2026, Jorge:
    /// «prueba todos los botones»). Antes el canal solo tenía una orden por cada botón que alguien
    /// se acordó de añadir; la calculadora, las griegas, los menús y el tema no se podían probar.
    ///   botones  → la lista de todo lo que se puede pulsar (índice, nombre, texto, etiqueta)
    ///   pulsa    → pulsa uno por índice, nombre o texto; "diferido" para los que abren un cuadro
    ///   estado   → lo que se ve: editor, modos, tema, rótulos
    ///   fuera    → lo que la app habría abierto o copiado (en pruebas no se abre nada de verdad)
    /// </summary>
    public partial class MainWindow
    {
        /// <summary>Lo que en una prueba se habría abierto fuera (navegador, PDF, bloc de notas) o copiado.</summary>
        private readonly List<string> _ctlFuera = new List<string>();

        /// <summary>Abre un enlace o un fichero con el programa del sistema. En --ctl solo se apunta.</summary>
        private void AbrirFuera(string destino)
        {
            if (_ctl != null) { _ctlFuera.Add("abrir\t" + destino); return; }
            System.Diagnostics.Process.Start(new System.Diagnostics.ProcessStartInfo(destino) { UseShellExecute = true });
        }

        /// <summary>Copia al portapapeles. En --ctl solo se apunta (no se pisa lo que el usuario tenga copiado).</summary>
        private void AlPortapapeles(string texto)
        {
            if (_ctl != null) { _ctlFuera.Add("copiar\t" + (texto ?? "").Length + "\t" + (texto ?? "")); return; }
            Clipboard.SetText(texto);
        }

        private static void Recorrer(object raiz, List<FrameworkElement> sal)
        {
            if (raiz is not DependencyObject d) return;
            if (d is FrameworkElement fe && (fe is ButtonBase || fe is MenuItem)) sal.Add(fe);
            foreach (var h in LogicalTreeHelper.GetChildren(d)) Recorrer(h, sal);
        }

        private List<FrameworkElement> Pulsables()
        {
            var l = new List<FrameworkElement>();
            Recorrer(this, l);
            return l;
        }

        private static string TextoDe(FrameworkElement fe) => fe switch
        {
            MenuItem mi => mi.Header as string ?? mi.Header?.ToString() ?? "",
            ContentControl cc => cc.Content as string ?? cc.Content?.ToString() ?? "",
            _ => "",
        };

        private static string TipoDe(FrameworkElement fe) => fe switch
        {
            MenuItem mi => mi.HasItems ? "menu" : "opcion",
            CheckBox => "casilla",
            _ => "boton",
        };

        private string CtlBotones()
        {
            var l = Pulsables();
            var filas = new List<object>();
            for (int i = 0; i < l.Count; i++)
            {
                var fe = l[i];
                string padre = (fe as MenuItem)?.Parent is MenuItem pm ? (pm.Header as string ?? "") : "";
                filas.Add(new
                {
                    i,
                    tipo = TipoDe(fe),
                    nombre = fe.Name ?? "",
                    texto = TextoDe(fe),
                    etiqueta = fe.Tag as string ?? "",
                    padre,
                    activo = fe.IsEnabled,
                    visible = fe.IsVisible,
                    ayuda = fe.ToolTip as string ?? "",
                });
            }
            return System.Text.Json.JsonSerializer.Serialize(new { ok = true, total = l.Count, botones = filas });
        }

        private string CtlEstado() => System.Text.Json.JsonSerializer.Serialize(new
        {
            ok = true,
            editor = Editor.Text ?? "",
            cursor = Editor.CaretOffset,
            vista = _view,
            operar = _op,
            lisp = _syntaxLisp,
            lispCompleto = _synFull,
            heklab = _transliterated,
            oscuro = _dark,
            autorun = _autoRun,
            calculadora = KeypadPanel != null && KeypadPanel.Visibility == Visibility.Visible,
            escribes = LblIn?.Text ?? "",
            resultado = LblOut?.Text ?? "",
            titulo = Title ?? "",
            archivo = _currentFile ?? "",
            letra = Editor.FontSize,
        });

        private string CtlPulsa(System.Text.Json.JsonElement r)
        {
            var l = Pulsables();
            FrameworkElement fe = null;
            if (r.TryGetProperty("indice", out var pi)) { int i = pi.GetInt32(); if (i >= 0 && i < l.Count) fe = l[i]; }
            else if (r.TryGetProperty("nombre", out var pn)) fe = l.Find(x => x.Name == pn.GetString());
            else if (r.TryGetProperty("texto", out var pt)) fe = l.Find(x => TextoDe(x) == pt.GetString());
            if (fe == null) return "{\"error\":\"no hay ese botón\"}";
            if (!fe.IsEnabled) return "{\"error\":\"el botón está desactivado\"}";
            bool diferido = r.TryGetProperty("diferido", out var pd) && pd.GetBoolean();
            void Pulsar()
            {
                if (fe is ToggleButton tb) tb.IsChecked = !(tb.IsChecked == true);   // dispara Checked/Unchecked
                else if (fe is ButtonBase b) b.RaiseEvent(new RoutedEventArgs(ButtonBase.ClickEvent, b));
                else if (fe is MenuItem mi) mi.RaiseEvent(new RoutedEventArgs(MenuItem.ClickEvent, mi));
            }
            // los que abren un cuadro (Abrir, Guardar como, Acerca de) no vuelven hasta que se cierra:
            // se pulsan DESPUÉS de contestar, y el guion cierra el cuadro desde fuera
            if (diferido) Dispatcher.BeginInvoke(new Action(Pulsar), System.Windows.Threading.DispatcherPriority.Background);
            else Pulsar();
            return System.Text.Json.JsonSerializer.Serialize(new { ok = true, texto = TextoDe(fe), nombre = fe.Name ?? "", diferido });
        }

        private int _ctlNavs, _ctlNavsHechas;
        private bool _ctlNavVigilada;

        /// <summary>Espera a que la ventana esté EN REPOSO: sin recálculo pendiente (el AutoRun espera un
        /// momento tras el último cambio), sin cálculo en marcha y con la página del resultado ya cargada.
        /// `getoutput` solo espera al cálculo que hay en ese instante: tras abrir un ejemplo leía la página
        /// de la hoja ANTERIOR.</summary>
        private async Task<string> CtlReposo(int topeMs)
        {
            if (!_ctlNavVigilada && _webReady && Viewer.CoreWebView2 is not null)
            {
                Viewer.CoreWebView2.NavigationStarting += (s, e) => _ctlNavs++;
                Viewer.CoreWebView2.NavigationCompleted += (s, e) => _ctlNavsHechas++;
                _ctlNavVigilada = true;
            }
            var reloj = System.Diagnostics.Stopwatch.StartNew();
            int quieto = 0;
            while (reloj.ElapsedMilliseconds < topeMs)
            {
                bool ocupado = _debounce.IsEnabled || (_showTask != null && !_showTask.IsCompleted) || _ctlNavs != _ctlNavsHechas;
                quieto = ocupado ? 0 : quieto + 1;
                if (quieto >= 4) break;            // 4 miradas seguidas en calma (~0.5 s)
                await Task.Delay(120);
            }
            return System.Text.Json.JsonSerializer.Serialize(new { ok = quieto >= 4, ms = reloj.ElapsedMilliseconds });
        }

        private string CtlFuera(bool vaciar)
        {
            var r = System.Text.Json.JsonSerializer.Serialize(new { ok = true, fuera = _ctlFuera.ToArray() });
            if (vaciar) _ctlFuera.Clear();
            return r;
        }

        /// <summary>PNG de la VENTANA ENTERA: los botones y el editor (WPF) con el resultado (WebView2) puesto
        /// en su sitio. El WebView2 no sale en un RenderTargetBitmap, así que se pide aparte y se compone.</summary>
        private async Task CapturaVentana(string path, double esc = 1)
        {
            try
            {
                if (Content is not FrameworkElement raiz) return;
                BitmapImage web = null;
                if (IsRenderView && _webReady && Viewer.CoreWebView2 is not null && Viewer.IsVisible)
                {
                    await Task.Delay(300);
                    var json = await Viewer.CoreWebView2.CallDevToolsProtocolMethodAsync("Page.captureScreenshot", "{\"format\":\"png\"}");
                    using var doc = System.Text.Json.JsonDocument.Parse(json);
                    var bytes = Convert.FromBase64String(doc.RootElement.GetProperty("data").GetString() ?? "");
                    web = new BitmapImage();
                    web.BeginInit(); web.CacheOption = BitmapCacheOption.OnLoad; web.StreamSource = new MemoryStream(bytes); web.EndInit();
                }
                int w = Math.Max(1, (int)raiz.ActualWidth), h = Math.Max(1, (int)raiz.ActualHeight);
                // esc > 1: la ventana a más resolución (para vídeo: se reduce después, nunca se amplía)
                int W = Math.Max(1, (int)Math.Round(w * esc)), H = Math.Max(1, (int)Math.Round(h * esc));
                var wpf = new RenderTargetBitmap(W, H, 96 * esc, 96 * esc, PixelFormats.Pbgra32);
                wpf.Render(raiz);
                var dv = new DrawingVisual();
                using (var dc = dv.RenderOpen())
                {
                    dc.DrawImage(wpf, new Rect(0, 0, w, h));
                    if (web != null)
                    {
                        var p = Viewer.TranslatePoint(new Point(0, 0), raiz);
                        dc.DrawImage(web, new Rect(p.X, p.Y, Viewer.ActualWidth, Viewer.ActualHeight));
                    }
                }
                var fin = new RenderTargetBitmap(W, H, 96 * esc, 96 * esc, PixelFormats.Pbgra32);
                fin.Render(dv);
                var enc = new PngBitmapEncoder();
                enc.Frames.Add(BitmapFrame.Create(fin));
                using var fs = File.Create(path);
                enc.Save(fs);
            }
            catch (Exception ex) { File.WriteAllText(Path.ChangeExtension(path, ".error.txt"), ex.ToString()); }
        }
    }
}
