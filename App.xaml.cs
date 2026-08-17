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

            base.OnStartup(e);   // muestra MainWindow normal
        }

        static string Val(string[] a, string flag)
        {
            for (int i = 1; i < a.Length - 1; i++)
                if (string.Equals(a[i], flag, StringComparison.OrdinalIgnoreCase))
                    return a[i + 1];
            return null;
        }
    }
}
