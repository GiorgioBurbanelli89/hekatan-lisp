using System;
using System.Diagnostics;
using System.IO;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Windows;
using Microsoft.Web.WebView2.Core;

namespace HekatanLisp
{
    /// <summary>
    /// ESCRITORIO: guardar el dibujo AutoLISP (#autolisp) en archivo.
    ///   · DWG: acadrust-wasm (pkg-node, copiado a bin/…/dwg) corrido con Node. Es el mismo escritor
    ///     que usa la web (pkg-web) y que se validó con AutoCAD 2027 (hekatan-dwg/pruebas/juez_autocad.py).
    ///     Requiere Node (C:\Program Files\nodejs o en el PATH); sin Node, avisa y ofrece DXF.
    ///   · PNG: lo rasteriza la página (canvas) y lo manda con chrome.webview.postMessage.
    ///   · Menú Archivo → «Guardar dibujo como…»: elige el tipo (DXF, SVG, PNG, PDF, DWG).
    /// </summary>
    public partial class MainWindow
    {
        static string NodeExe()
        {
            var p = @"C:\Program Files\nodejs\node.exe";
            if (File.Exists(p)) return p;
            foreach (var d in (Environment.GetEnvironmentVariable("PATH") ?? "").Split(';'))
                try { var f = Path.Combine(d.Trim(), "node.exe"); if (File.Exists(f)) return f; } catch { }
            return null;
        }

        /// <summary>JSON de hekatan-dwg → bytes .dwg con acadrust-wasm en Node.</summary>
        static byte[] DwgConNode(string json)
        {
            var node = NodeExe() ?? throw new InvalidOperationException("DWG: hace falta Node.js (acadrust-wasm corre en Node); guarda en DXF");
            var pkg = Path.Combine(AppContext.BaseDirectory, "dwg", "acadrust_wasm.js");
            if (!File.Exists(pkg)) throw new InvalidOperationException("DWG: falta dwg/acadrust_wasm.js junto al programa (pkg-node de acadrust-wasm)");
            var tmp = Path.Combine(Path.GetTempPath(), "hkal_dwg_" + Environment.ProcessId);
            Directory.CreateDirectory(tmp);
            string fj = Path.Combine(tmp, "d.json"), fo = Path.Combine(tmp, "d.dwg");
            File.WriteAllText(fj, json, new UTF8Encoding(false));
            if (File.Exists(fo)) File.Delete(fo);
            var psi = new ProcessStartInfo(node) { UseShellExecute = false, CreateNoWindow = true, RedirectStandardError = true, RedirectStandardOutput = true };
            psi.ArgumentList.Add("-e");
            psi.ArgumentList.Add("const m=require(process.argv[1]);const fs=require('fs');fs.writeFileSync(process.argv[3],m.write_dwg_bytes(fs.readFileSync(process.argv[2],'utf8')))");
            psi.ArgumentList.Add(pkg); psi.ArgumentList.Add(fj); psi.ArgumentList.Add(fo);
            using var p = Process.Start(psi);
            var te = p.StandardError.ReadToEndAsync(); var to = p.StandardOutput.ReadToEndAsync();
            if (!p.WaitForExit(60000)) { try { p.Kill(true); } catch { } throw new TimeoutException("DWG: Node no terminó"); }
            if (!File.Exists(fo)) throw new InvalidOperationException("DWG: " + (te.Result ?? "").Trim());
            return File.ReadAllBytes(fo);
        }

        void InstalarDibujo()
        {
            LispAutoLisp.EscritorDwg = DwgConNode;
            Viewer.CoreWebView2.WebMessageReceived += OnMensajeDibujo;
        }

        async void OnMensajeDibujo(object s, CoreWebView2WebMessageReceivedEventArgs e)
        {
            try
            {
                using var doc = System.Text.Json.JsonDocument.Parse(e.TryGetWebMessageAsString());
                var r = doc.RootElement;
                if (r.TryGetProperty("hkGuardarPng", out var ruta))   // (guardar "x.png") de la hoja
                {
                    string url = r.GetProperty("datos").GetString();
                    File.WriteAllBytes(ruta.GetString(), Convert.FromBase64String(url.Substring(url.IndexOf(',') + 1)));
                }
                else if (r.TryGetProperty("hkDwg", out var js))       // botón DWG de la página
                {
                    string nombre = r.TryGetProperty("nombre", out var n) ? n.GetString() : "dibujo.dwg";
                    var dlg = new Microsoft.Win32.SaveFileDialog { FileName = nombre, Filter = "DWG (AutoCAD 2018)|*.dwg", InitialDirectory = CarpetaDibujos() };
                    if (dlg.ShowDialog(this) != true) return;
                    var bytes = await Task.Run(() => DwgConNode(js.GetString()));
                    File.WriteAllBytes(dlg.FileName, bytes);
                }
            }
            catch (Exception ex) { MessageBox.Show(this, ex.Message, "Guardar dibujo", MessageBoxButton.OK, MessageBoxImage.Warning); }
        }

        string CarpetaDibujos()
        {
            var d = Path.Combine(DocsDir, "dibujos");
            try { Directory.CreateDirectory(d); } catch { }
            return d;
        }

        /// <summary>Menú Archivo → Guardar dibujo como… (el último dibujo #autolisp de la hoja).</summary>
        async void MenuGuardarDibujo(object s, RoutedEventArgs e)
        {
            var dib = LispAutoLisp.UltimoDibujo;
            if (dib == null) { MessageBox.Show(this, "La hoja no tiene ningún dibujo #autolisp.", "Guardar dibujo", MessageBoxButton.OK, MessageBoxImage.Information); return; }
            var dlg = new Microsoft.Win32.SaveFileDialog
            {
                Filter = "DXF (AutoCAD R12)|*.dxf|SVG (vectorial)|*.svg|PNG (imagen)|*.png|PDF (vectorial)|*.pdf|DWG (AutoCAD 2018)|*.dwg",
                FileName = "dibujo", InitialDirectory = CarpetaDibujos(),
            };
            if (dlg.ShowDialog(this) != true) return;
            string ext = Path.GetExtension(dlg.FileName).TrimStart('.').ToLowerInvariant();
            if (ext.Length == 0) { ext = LispAutoLisp.Formatos[Math.Max(0, dlg.FilterIndex - 1)]; dlg.FileName += "." + ext; }
            try
            {
                if (ext == "png")
                {
                    var res = await Viewer.CoreWebView2.CallDevToolsProtocolMethodAsync("Runtime.evaluate",
                        "{\"expression\":\"hkAlPng('" + LispAutoLisp.UltimoId + "',11.811)\",\"awaitPromise\":true,\"returnByValue\":true}");
                    using var doc = System.Text.Json.JsonDocument.Parse(res);
                    string url = doc.RootElement.GetProperty("result").GetProperty("value").GetString();
                    File.WriteAllBytes(dlg.FileName, Convert.FromBase64String(url.Substring(url.IndexOf(',') + 1)));
                }
                else
                {
                    var o = LispAutoLisp.UltimaOpc;
                    var bytes = await Task.Run(() => LispAutoLisp.Archivo(dib, o, ext));
                    File.WriteAllBytes(dlg.FileName, bytes);
                }
            }
            catch (Exception ex) { MessageBox.Show(this, ex.Message, "Guardar dibujo", MessageBoxButton.OK, MessageBoxImage.Warning); }
        }
    }
}
