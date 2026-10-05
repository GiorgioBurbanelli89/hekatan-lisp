using System;
using System.Windows;

namespace HekatanLisp
{
    public partial class App : System.Windows.Application
    {
        protected override void OnStartup(StartupEventArgs e)
        {
            var args = Environment.GetCommandLineArgs();

            // INSTANCIA ÚNICA: si ya hay una ventana abierta, NO abrir otra (evita 2 WPF).
            // Se salta en modos de automatización (--ctl, --shot, --pdf, --html): pueden coexistir con la ventana abierta.
            // NOTA: --html lo maneja MainWindow (pipeline COMPLETO: motor SBCL → RenderPage → gráficas),
            // no aquí. Antes App lo interceptaba y renderizaba el texto CRUDO de --in sin evaluar
            // (por eso salía "C:/": renderizaba la RUTA del archivo como si fuera la hoja).
            bool headless = Array.Exists(args, a =>
                string.Equals(a, "--ctl", StringComparison.OrdinalIgnoreCase) ||
                string.Equals(a, "--shot", StringComparison.OrdinalIgnoreCase) ||
                string.Equals(a, "--pdf", StringComparison.OrdinalIgnoreCase) ||
                string.Equals(a, "--html", StringComparison.OrdinalIgnoreCase) ||
                string.Equals(a, "--latex", StringComparison.OrdinalIgnoreCase));
            if (!headless)
            {
                _mutex = new System.Threading.Mutex(true, "HekatanLisp_SingleInstance_v1", out bool creada);
                if (!creada)
                {
                    // ya existe una → se le ENTREGA el archivo (doble clic en un .lisp con la app abierta:
                    // antes esta copia se cerraba y el archivo no se abría en ninguna parte)
                    var archivo = Array.Find(args, a => !a.StartsWith("--") && !a.EndsWith(".dll", StringComparison.OrdinalIgnoreCase) && !a.EndsWith(".exe", StringComparison.OrdinalIgnoreCase) && System.IO.File.Exists(a));
                    if (archivo != null)
                        try
                        {
                            using var cli = new System.IO.Pipes.NamedPipeClientStream(".", TuboAbrir, System.IO.Pipes.PipeDirection.Out);
                            cli.Connect(3000);
                            using var w = new System.IO.StreamWriter(cli) { AutoFlush = true };
                            w.WriteLine(System.IO.Path.GetFullPath(archivo));
                        }
                        catch { }
                    Shutdown(0); return;
                }
                EscucharOtrasCopias();
            }

            // Un error sin atrapar cerraba la ventana SIN AVISO (Jorge: «al rato la app ya no estaba»).
            // Ahora queda escrito en %LOCALAPPDATA%\HekatanLisp\errores.log y la ventana sigue viva.
            DispatcherUnhandledException += (s, ev) =>
            {
                Registra("UI", ev.Exception);
                ev.Handled = true;
                try { MessageBox.Show("Error interno (la hoja sigue abierta):\n" + ev.Exception.Message + "\n\nDetalle en " + LogPath, "Hekatan LISP"); } catch { }
            };
            AppDomain.CurrentDomain.UnhandledException += (s, ev) => Registra("dominio", ev.ExceptionObject as Exception);
            System.Threading.Tasks.TaskScheduler.UnobservedTaskException += (s, ev) => { Registra("tarea", ev.Exception); ev.SetObserved(); };

            base.OnStartup(e);   // muestra MainWindow normal
        }

        private static string LogPath => System.IO.Path.Combine(
            Environment.GetFolderPath(Environment.SpecialFolder.LocalApplicationData), "HekatanLisp", "errores.log");

        private static void Registra(string donde, Exception ex)
        {
            try
            {
                System.IO.Directory.CreateDirectory(System.IO.Path.GetDirectoryName(LogPath));
                System.IO.File.AppendAllText(LogPath, $"=== {DateTime.Now:yyyy-MM-dd HH:mm:ss} [{donde}] pid {Environment.ProcessId}\n{ex}\n");
            }
            catch { }
        }

        private System.Threading.Mutex _mutex;
        private const string TuboAbrir = "HekatanLisp_Abrir_v1";

        /// <summary>La primera copia escucha: otra copia que se abra con un archivo se lo manda por esta
        /// tubería y aquí se carga en la ventana, que pasa al frente.</summary>
        private void EscucharOtrasCopias()
        {
            System.Threading.Tasks.Task.Run(async () =>
            {
                while (true)
                {
                    try
                    {
                        using var srv = new System.IO.Pipes.NamedPipeServerStream(TuboAbrir, System.IO.Pipes.PipeDirection.In, 1,
                            System.IO.Pipes.PipeTransmissionMode.Byte, System.IO.Pipes.PipeOptions.Asynchronous);
                        await srv.WaitForConnectionAsync();
                        using var r = new System.IO.StreamReader(srv);
                        var ruta = (await r.ReadLineAsync())?.Trim();
                        if (!string.IsNullOrEmpty(ruta) && System.IO.File.Exists(ruta))
                            await Dispatcher.InvokeAsync(() => (MainWindow as HekatanLisp.MainWindow)?.AbrirDesdeOtraCopia(ruta));
                    }
                    catch { await System.Threading.Tasks.Task.Delay(500); }
                }
            });
        }
    }
}
