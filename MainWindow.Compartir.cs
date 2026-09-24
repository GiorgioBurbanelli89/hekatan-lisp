using System;
using System.Diagnostics;
using System.IO;
using System.IO.Compression;
using System.Text;
using System.Windows;

namespace HekatanLisp
{
    /// <summary>
    /// COMPARTIR como en la web: el enlace de Hekatan LISP web lleva la hoja DENTRO
    /// (#h = texto en UTF-8, comprimido deflate-raw y en base64url sin '=', el mismo formato
    /// que comprimir()/descomprimir() de web/HekatanLispWeb/wwwroot/main.js). Quien lo abre ve
    /// la hoja calculada en cualquier navegador, sin instalar nada.
    /// </summary>
    public partial class MainWindow
    {
        public const string WebBase = "https://giorgioburbanelli89.github.io/hekatan-lisp/";

        /// <summary>Enlace web con la hoja: deflate-raw (DeflateStream = deflate SIN cabecera zlib,
        /// igual que CompressionStream('deflate-raw')) + base64url.</summary>
        public static string EnlaceWeb(string hoja)
        {
            using var ms = new MemoryStream();
            using (var ds = new DeflateStream(ms, CompressionLevel.SmallestSize, leaveOpen: true))
            {
                var b = Encoding.UTF8.GetBytes(hoja ?? "");
                ds.Write(b, 0, b.Length);
            }
            var c = Convert.ToBase64String(ms.ToArray()).Replace('+', '-').Replace('/', '_').TrimEnd('=');
            return WebBase + "#h=" + c;
        }

        private void MenuCompartirWeb(object sender, RoutedEventArgs e)
        {
            string url;
            try { url = EnlaceWeb(Editor.Text); }
            catch (Exception ex) { MessageBox.Show(this, "No se pudo crear el enlace: " + ex.Message, "Compartir"); return; }
            try { Clipboard.SetText(url); } catch { /* portapapeles ocupado: igual se abre */ }
            try { Process.Start(new ProcessStartInfo(url) { UseShellExecute = true }); } catch { }
            ctlUltimoEnlace = url;
        }

        /// <summary>Ayuda → Manual. El PDF va instalado junto al programa (carpeta manual\);
        /// si falta, o se pide la versión más reciente, se abre el de la web (se descarga desde ahí).</summary>
        private void MenuManual(object sender, RoutedEventArgs e)
        {
            var nombre = (sender as FrameworkElement)?.Tag as string ?? "Manual_Hekatan_LISP.pdf";
            string destino = WebBase + "manual/" + (nombre == "web" ? "Manual_Hekatan_LISP.pdf" : nombre);
            if (nombre != "web")
            {
                var local = Path.Combine(AppContext.BaseDirectory, "manual", nombre);
                if (File.Exists(local)) destino = local;
            }
            try { Process.Start(new ProcessStartInfo(destino) { UseShellExecute = true }); }
            catch (Exception ex) { MessageBox.Show(this, "No se pudo abrir el manual: " + ex.Message, "Manual"); }
        }

        /// <summary>Último enlace creado (para las pruebas --ctl).</summary>
        internal string ctlUltimoEnlace;
    }
}
