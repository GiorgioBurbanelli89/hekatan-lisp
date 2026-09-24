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
                if (!creada) { Shutdown(0); return; }   // ya existe una → cerrar esta
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
    }
}
