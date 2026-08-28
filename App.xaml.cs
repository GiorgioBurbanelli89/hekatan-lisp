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
                string.Equals(a, "--html", StringComparison.OrdinalIgnoreCase));
            if (!headless)
            {
                _mutex = new System.Threading.Mutex(true, "HekatanLisp_SingleInstance_v1", out bool creada);
                if (!creada) { Shutdown(0); return; }   // ya existe una → cerrar esta
            }

            base.OnStartup(e);   // muestra MainWindow normal
        }

        private System.Threading.Mutex _mutex;
    }
}
