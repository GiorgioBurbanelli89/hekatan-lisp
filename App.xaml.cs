using System;
using System.IO;
using System.Windows;

namespace HekatanLisp
{
    public partial class App : System.Windows.Application
    {
        protected override void OnStartup(StartupEventArgs e)
        {
            var args = Environment.GetCommandLineArgs();

            // Modo headless: genera el HTML renderizado y sale (para verificar el render).
            //   HekatanLisp.exe --html out.html --mode 2|4 --in "x^2+3*x\n(x+1)^2"
            var html = Val(args, "--html");
            if (html != null)
            {
                int mode = 2;
                var m = Val(args, "--mode");
                if (m != null) int.TryParse(m, out mode);
                var input = (Val(args, "--in") ?? "x^2 + 3*x\\n(x+1)^2\\nx/2\\nx^2 - 2*x + 1").Replace("\\n", "\n");
                File.WriteAllText(html, LispConverter.RenderPage(input, fromLisp: mode == 4));
                Shutdown(0);
                return;
            }

            // INSTANCIA ÚNICA: si ya hay una ventana abierta, NO abrir otra (evita 2 WPF).
            // Se salta en modos de automatización (--ctl, --shot): pueden coexistir con la ventana abierta.
            bool headless = Array.Exists(args, a =>
                string.Equals(a, "--ctl", StringComparison.OrdinalIgnoreCase) ||
                string.Equals(a, "--shot", StringComparison.OrdinalIgnoreCase) ||
                string.Equals(a, "--pdf", StringComparison.OrdinalIgnoreCase));
            if (!headless)
            {
                _mutex = new System.Threading.Mutex(true, "HekatanLisp_SingleInstance_v1", out bool creada);
                if (!creada) { Shutdown(0); return; }   // ya existe una → cerrar esta
            }

            base.OnStartup(e);   // muestra MainWindow normal
        }

        private System.Threading.Mutex _mutex;

        static string Val(string[] a, string flag)
        {
            for (int i = 1; i < a.Length - 1; i++)
                if (string.Equals(a[i], flag, StringComparison.OrdinalIgnoreCase))
                    return a[i + 1];
            return null;
        }
    }
}
