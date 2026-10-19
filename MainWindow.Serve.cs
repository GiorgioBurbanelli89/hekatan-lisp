using System;
using System.IO;
using System.Linq;
using System.Text;
using System.Threading;
using System.Threading.Tasks;
using System.Windows;

namespace HekatanLisp
{
    // MODO RESIDENTE (--serve <carpeta>): Hekatan LISP se queda vivo (motor SBCL, WebView y .NET ya calientes) y atiende peticiones por ARCHIVOS (como --ctl):
    //   <carpeta>\req-0001.txt  con una línea «entrada.lisp<TAB>salida.html»   →   <carpeta>\resp-0001.txt  con «ok» o «error: …»
    // Cada petición hace lo mismo que --html (el pipeline COMPLETO: motor → render → gráficas) pero SIN volver a arrancar el programa (~1.5 s de cada render).
    // «salir» en la petición cierra el programa. (Una tubería con nombre no servía: no la veía otro proceso dentro del entorno de pruebas.)
    public partial class MainWindow
    {
        static void LogServe(string t) { try { File.AppendAllText(Path.Combine(Path.GetTempPath(), "hk_serve.log"), DateTime.Now.ToString("HH:mm:ss.fff") + " " + t + Environment.NewLine); } catch { } }

        private void StartServe(string carpeta)
        {
            Directory.CreateDirectory(carpeta); LogServe("StartServe " + carpeta);
            foreach (var f in Directory.GetFiles(carpeta, "re*-*.txt")) try { File.Delete(f); } catch { }
            File.WriteAllText(Path.Combine(carpeta, "listo.txt"), Environment.ProcessId.ToString());
            var hilo = new Thread(() =>
            {
                while (true)
                {
                    try
                    {
                        var req = Directory.GetFiles(carpeta, "req-*.txt").OrderBy(x => x).FirstOrDefault();
                        if (req == null) { Thread.Sleep(15); continue; }
                        string linea; try { linea = File.ReadAllText(req, Encoding.UTF8).Trim(); } catch { Thread.Sleep(10); continue; }          // aún se está escribiendo
                        if (linea == "") { Thread.Sleep(10); continue; }
                        string resp = "error: petición mal formada"; bool salir = linea == "salir";
                        var partes = linea.Split('\t');
                        if (partes.Length == 2) { var tarea = Dispatcher.Invoke(() => AtiendeServe(partes[0], partes[1])); resp = tarea.GetAwaiter().GetResult(); }
                        string resp1 = Path.Combine(carpeta, Path.GetFileName(req).Replace("req-", "resp-"));
                        File.WriteAllText(resp1 + ".tmp", salir ? "ok" : resp, new UTF8Encoding(false)); File.Move(resp1 + ".tmp", resp1, true);          // la respuesta aparece ENTERA
                        try { File.Delete(req); } catch { }
                        LogServe("respuesta " + resp);
                        if (salir) { Dispatcher.Invoke(() => Application.Current.Shutdown()); return; }
                    }
                    catch (Exception ex) { LogServe("error: " + ex.Message); Thread.Sleep(200); }
                }
            }) { IsBackground = true, Name = "HekatanLisp-serve" };
            hilo.Start();
        }

        private async Task<string> AtiendeServe(string entrada, string salida)
        {
            try
            {
                if (!File.Exists(entrada)) return "error: no existe " + entrada;
                for (int k = 0; k < 600 && !_webReady; k++) await Task.Delay(50);          // el WebView2 del propio programa tarda en estar listo la primera vez
                try { if (_showTask != null) await _showTask; } catch { }
                _debounce.Stop(); _lastHtml = null; Editor.Text = File.ReadAllText(entrada); _debounce.Stop();          // el TextChanged lanza el debounce: aquí se pide UN solo cálculo
                ShowResult(); try { await _showTask; } catch { }
                await Task.Delay(120);
                if (_lastHtml == null) { ShowResult(); try { await _showTask; } catch { } }
                File.WriteAllText(salida, _lastHtml ?? ""); return "ok";
            }
            catch (Exception ex) { return "error: " + ex.Message; }
        }
    }
}
