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

        /// <summary>Menú Dibujo / botón ✏: inserta el bloque en el cursor y, si es una ventana de dibujo,
        /// la ABRE (el botón «✏ Dibujar / Editar» que la hoja pone en el resultado). 3D: el mismo bloque
        /// con vista=3d (la ventana arranca en isométrica).</summary>
        private async void MenuDibujoCad(object sender, RoutedEventArgs e)
        {
            var tipo = (sender as FrameworkElement)?.Tag as string ?? "2d";
            int k = 1; while (Editor.Text.Contains("#dibujar(dibujo" + k)) k++;
            string nombre = "dibujo" + k;
            string bloque = tipo switch
            {
                "3d" => "#dibujar(" + nombre + ", ud = m, cuadricula = 0.5, vista = 3d)\n#fin\n",
                "autolisp" => "#autolisp(\"Dibujo\", ancho = 120, alto = 90)\n(linea '(0 0) '(4 3))\n(circulo '(4 3) 1)\n#fin\n",
                "dibujo" => "#dibujo(\"Dibujo\", ud = m, ancho = 120, alto = 90)\n#  linea(0, 0, 4, 0, \"gruesa\")\n#fin\n",
                _ => "#dibujar(" + nombre + ", ud = m, cuadricula = 0.1)\n#fin\n",
            };
            var doc = Editor.Document; int pos = Editor.CaretOffset;
            var linea = doc.GetLineByOffset(pos);
            if (pos != linea.Offset) { pos = linea.EndOffset; bloque = "\n" + bloque; }   // en una línea nueva
            doc.Insert(pos, bloque);
            if (tipo != "2d" && tipo != "3d") { ShowResult(); return; }
            ShowResult();
            try { await _showTask; } catch { }
            for (int i = 0; i < 40; i++)   // espera a que la página nueva tenga el botón y lo pulsa
            {
                await System.Threading.Tasks.Task.Delay(150);
                string r = await Viewer.ExecuteScriptAsync("(function(){var b=[...document.querySelectorAll('.hk-cad-btn')].find(function(x){return (x.textContent||'').indexOf('«" + nombre + "»')>=0})||[...document.querySelectorAll('.hk-cad-btn')].pop();if(!b)return 0;b.scrollIntoView({block:'center'});b.click();" + (tipo == "3d" ? "setTimeout(function(){try{hkCad.vista('ISOSO')}catch(e){}},300);" : "") + "return 1})()");
                if (r == "1") break;
            }
        }

        /// <summary>Último enlace creado (para las pruebas --ctl).</summary>
        internal string ctlUltimoEnlace;
    }
}
