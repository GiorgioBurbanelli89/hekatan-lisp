using System;
using System.Collections.Generic;
using System.Globalization;
using System.Linq;
using SkiaSharp;

namespace HekatanLisp
{
    // Dibuja z = f(x,y) como superficie 3D (proyección isométrica, colormap jet_r) con SkiaSharp,
    // off-screen → PNG en base64 que se embebe en el render (WebView2). Sin ventana ni GPU.
    static class SurfacePlot
    {
        // ---- evaluador NUMÉRICO del árbol en un punto (sustituye las variables por valores) ----
        public static double Eval(LispConverter.N n, Dictionary<string, double> v)
        {
            if (n == null) return 0;
            if (n.IsAtom)
            {
                var s = n.Atom ?? "";
                if (double.TryParse(s, NumberStyles.Any, CultureInfo.InvariantCulture, out var d)) return d;
                if (v.TryGetValue(s, out var vv)) return vv;
                return s == "pi" ? Math.PI : s == "e" ? Math.E : 0;
            }
            switch (n.Op)
            {
                case "+": return Eval(n.A, v) + Eval(n.B, v);
                case "-": return Eval(n.A, v) - Eval(n.B, v);
                case "*": return Eval(n.A, v) * Eval(n.B, v);
                case "/": { var dd = Eval(n.B, v); return dd == 0 ? 0 : Eval(n.A, v) / dd; }
                case "^": case "expt": return Math.Pow(Eval(n.A, v), Eval(n.B, v));
                case "neg": return -Eval(n.A, v);
                case "fn":
                    double a = n.Items != null && n.Items.Count > 0 ? Eval(n.Items[0], v) : 0;
                    return n.Atom switch
                    {
                        "sin" => Math.Sin(a), "cos" => Math.Cos(a), "tan" => Math.Tan(a),
                        "sqrt" => Math.Sqrt(a), "exp" => Math.Exp(a), "log" or "ln" => Math.Log(a),
                        "abs" => Math.Abs(a), _ => a
                    };
                default: return 0;
            }
        }

        // ---- malla numérica z=f(x,y) sobre [xa,xb]×[ya,yb] (nn+1 × nn+1 puntos) ----
        static (double[,] Z, double zmin, double zmax) Sample(LispConverter.N f, string vx, string vy,
                                                              double xa, double xb, double ya, double yb, int nn)
        {
            var Z = new double[nn + 1, nn + 1];
            double zmin = double.MaxValue, zmax = double.MinValue;
            for (int i = 0; i <= nn; i++)
                for (int j = 0; j <= nn; j++)
                {
                    double x = xa + (xb - xa) * i / nn, y = ya + (yb - ya) * j / nn;
                    double z = Eval(f, new Dictionary<string, double> { { vx, x }, { vy, y } });
                    if (double.IsNaN(z) || double.IsInfinity(z)) z = 0;
                    Z[i, j] = z; zmin = Math.Min(zmin, z); zmax = Math.Max(zmax, z);
                }
            if (zmax - zmin < 1e-9) zmax = zmin + 1;
            return (Z, zmin, zmax);
        }

        /// <summary>#anim surf: UN lienzo con todos los cuadros (data-frames). Así el giro con el ratón se
        /// conserva de un cuadro al siguiente. escalaComun: la misma escala z en todos (se VE crecer la
        /// amplitud); si no, cada cuadro ocupa toda la altura (funciones de tamaños muy distintos).
        /// zr devuelve el [zmin, zmax] REAL de cada cuadro (para el rótulo).</summary>
        public static string SurfaceCanvasFrames(List<LispConverter.N> fs, string vx, string vy,
                                                 double xa, double xb, double ya, double yb, int id, bool escalaComun,
                                                 out List<(double lo, double hi)> zr)
        {
            const int nn = 32;
            var inv = CultureInfo.InvariantCulture;
            var muestras = fs.Select(f => Sample(f, vx, vy, xa, xb, ya, yb, nn)).ToList();
            zr = muestras.Select(m => (m.zmin, m.zmax)).ToList();
            double gmin = muestras.Min(m => m.zmin), gmax = muestras.Max(m => m.zmax);
            string Arr(double[,] Z)
            {
                var sb = new System.Text.StringBuilder("[");
                for (int j = 0; j <= nn; j++)
                    for (int i = 0; i <= nn; i++)
                    {
                        if (i + j > 0) sb.Append(',');
                        sb.Append(Math.Round(Z[i, j], 4).ToString("0.####", inv));
                    }
                return sb.Append(']').ToString();
            }
            string F(double v) => v.ToString("0.######", inv);
            var fr = "[" + string.Join(",", muestras.Select(m => Arr(m.Z))) + "]";
            var zrs = "[" + string.Join(",", muestras.Select(m => escalaComun ? "[" + F(gmin) + "," + F(gmax) + "]"
                                                                                : "[" + F(m.zmin) + "," + F(m.zmax) + "]")) + "]";
            double z0 = escalaComun ? gmin : muestras[0].zmin, z1 = escalaComun ? gmax : muestras[0].zmax;
            return "<canvas class=\"hk-surf\" width=\"560\" height=\"420\" style=\"max-width:100%;touch-action:none;cursor:grab\""
                 + " data-id=\"" + id + "\" data-nn=\"" + nn + "\""
                 + " data-xa=\"" + F(xa) + "\" data-xb=\"" + F(xb) + "\" data-ya=\"" + F(ya) + "\" data-yb=\"" + F(yb) + "\""
                 + " data-vx=\"" + System.Net.WebUtility.HtmlEncode(vx) + "\" data-vy=\"" + System.Net.WebUtility.HtmlEncode(vy) + "\""
                 + " data-zmin=\"" + F(z0) + "\" data-zmax=\"" + F(z1) + "\""
                 + " data-z='" + Arr(muestras[0].Z) + "' data-frames='" + fr + "' data-zr='" + zrs + "'></canvas>";
        }

        // ---- <canvas> ORBITABLE: la malla la calcula C# una vez; el JS la rota con el mouse ----
        // El script hkSurfOrbit (una sola vez en la página) proyecta y gira; aquí solo va el canvas + datos.
        public static string SurfaceCanvas(LispConverter.N f, string vx, string vy,
                                           double xa, double xb, double ya, double yb, int id)
        {
            const int nn = 32;
            var (Z, zmin, zmax) = Sample(f, vx, vy, xa, xb, ya, yb, nn);
            var inv = CultureInfo.InvariantCulture;
            var sb = new System.Text.StringBuilder();
            sb.Append('[');
            for (int j = 0; j <= nn; j++)
                for (int i = 0; i <= nn; i++)
                {
                    if (i + j > 0) sb.Append(',');
                    sb.Append(Math.Round(Z[i, j], 4).ToString("0.####", inv));
                }
            sb.Append(']');
            // 17-sep-2026, Jorge: «con gráfica color map y cursor hover». Los rangos reales van al
            // canvas para que el hover pueda decir la x y la y del punto, no solo el índice.
            return "<canvas class=\"hk-surf\" width=\"560\" height=\"420\" style=\"max-width:100%;touch-action:none;cursor:grab\""
                 + " data-id=\"" + id + "\" data-nn=\"" + nn + "\""
                 + " data-xa=\"" + xa.ToString("0.######", inv) + "\" data-xb=\"" + xb.ToString("0.######", inv) + "\""
                 + " data-ya=\"" + ya.ToString("0.######", inv) + "\" data-yb=\"" + yb.ToString("0.######", inv) + "\""
                 + " data-vx=\"" + System.Net.WebUtility.HtmlEncode(vx) + "\" data-vy=\"" + System.Net.WebUtility.HtmlEncode(vy) + "\""
                 + " data-zmin=\"" + zmin.ToString("0.####", inv) + "\" data-zmax=\"" + zmax.ToString("0.####", inv) + "\""
                 + " data-z='" + sb + "'></canvas>";
        }

        // Script del ORBIT (se emite UNA vez). jet_r + proyección 3/4 + arrastre con el mouse.
        public const string OrbitScript = @"<script>
(function(){
 function jetr(t){t=Math.max(0,Math.min(1,t));
   var r=Math.max(0,Math.min(1,1.5-Math.abs(4*t-3))),g=Math.max(0,Math.min(1,1.5-Math.abs(4*t-2))),b=Math.max(0,Math.min(1,1.5-Math.abs(4*t-1)));
   return 'rgb('+(r*255|0)+','+(g*255|0)+','+(b*255|0)+')';}
 function setup(cv){
   var nn=+cv.dataset.nn, zmin=+cv.dataset.zmin, zmax=+cv.dataset.zmax, z=JSON.parse(cv.dataset.z);
   var W=cv.width,H=cv.height,ctx=cv.getContext('2d'),az=-0.9,el=0.5,rng=(zmax-zmin)||1;
   function Z(i,j){return z[j*(nn+1)+i];}
   function proj(i,j,zz){var ca=Math.cos(az),sa=Math.sin(az),ce=Math.cos(el),se=Math.sin(el);
     var X=i/nn-0.5,Y=j/nn-0.5,Zn=(zz-zmin)/rng;
     var rx=-X*sa+Y*ca,up=-se*ca*X-se*sa*Y+ce*Zn;
     return [W*0.5+rx*W*0.62,H*0.58-up*H*0.60];}
   function dep(i,j,zz){var ca=Math.cos(az),sa=Math.sin(az),ce=Math.cos(el),se=Math.sin(el);
     var X=i/nn-0.5,Y=j/nn-0.5,Zn=(zz-zmin)/rng;return ce*ca*X+ce*sa*Y+se*Zn;}
   function draw(){ctx.clearRect(0,0,W,H);var c=[];
     for(var i=0;i<nn;i++)for(var j=0;j<nn;j++){var zc=(Z(i,j)+Z(i+1,j)+Z(i+1,j+1)+Z(i,j+1))/4;c.push([dep(i,j,zc),i,j,zc]);}
     c.sort(function(a,b){return a[0]-b[0];});
     for(var k=0;k<c.length;k++){var i=c[k][1],j=c[k][2],zc=c[k][3];
       var p0=proj(i,j,Z(i,j)),p1=proj(i+1,j,Z(i+1,j)),p2=proj(i+1,j+1,Z(i+1,j+1)),p3=proj(i,j+1,Z(i,j+1));
       ctx.beginPath();ctx.moveTo(p0[0],p0[1]);ctx.lineTo(p1[0],p1[1]);ctx.lineTo(p2[0],p2[1]);ctx.lineTo(p3[0],p3[1]);ctx.closePath();
       ctx.fillStyle=jetr((zc-zmin)/rng);ctx.fill();ctx.strokeStyle='rgba(0,0,0,0.15)';ctx.lineWidth=0.5;ctx.stroke();}}
   // #anim surf: varios cuadros en el MISMO lienzo; el reproductor llama cv.hkFrame(k)
   if(cv.dataset.frames){var FR=JSON.parse(cv.dataset.frames),ZR=JSON.parse(cv.dataset.zr||'[]');
     cv.hkFrame=function(k){if(!FR[k])return;z=FR[k];if(ZR[k]){zmin=ZR[k][0];zmax=ZR[k][1];}rng=(zmax-zmin)||1;cv.dataset.frame=k;draw();};
     if(cv.dataset.frame&&+cv.dataset.frame>0)cv.hkFrame(+cv.dataset.frame);}
   draw();cv.style.cursor='grab';
   // ---- HOVER: el nudo mas cercano al cursor, con su x, y, z (17-sep-2026, Jorge) ----
   var xa=+cv.dataset.xa,xb=+cv.dataset.xb,ya=+cv.dataset.ya,yb=+cv.dataset.yb;
   var vx=cv.dataset.vx||'x',vy=cv.dataset.vy||'y';
   var tip=document.createElement('div');
   tip.style.cssText='position:fixed;z-index:9999;display:none;pointer-events:none;background:#fffffff2;'+
     'border:1px solid #888;border-radius:4px;padding:3px 6px;font:12px/1.35 Consolas,monospace;color:#111;'+
     'box-shadow:0 2px 6px rgba(0,0,0,.25);white-space:pre';
   document.body.appendChild(tip);
   function num(v){var a=Math.abs(v);return (a>=1e5||(a>0&&a<1e-3))?v.toExponential(3):v.toFixed(4);}
   function cerca(e){                     // nudo (i,j) cuya proyeccion queda mas cerca del cursor
     var r=cv.getBoundingClientRect(),mx=(e.clientX-r.left)*W/r.width,my=(e.clientY-r.top)*H/r.height;
     var mej=null,d2m=1e18;
     for(var i=0;i<=nn;i++)for(var j=0;j<=nn;j++){
       var p=proj(i,j,Z(i,j)),dx=p[0]-mx,dy=p[1]-my,d2=dx*dx+dy*dy;
       if(d2<d2m){d2m=d2;mej=[i,j,d2];}}
     return (mej&&mej[2]<400)?mej:null;    // 20 px de tolerancia
   }
   function mostrar(e){
     var m=cerca(e);
     if(!m){tip.style.display='none';return;}
     var i=m[0],j=m[1];
     tip.textContent=vx+' = '+num(xa+(xb-xa)*i/nn)+'\n'+vy+' = '+num(ya+(yb-ya)*j/nn)+'\nz = '+num(Z(i,j));
     tip.style.display='block';tip.style.left=(e.clientX+14)+'px';tip.style.top=(e.clientY+14)+'px';
   }
   cv.addEventListener('pointerleave',function(){tip.style.display='none';});
   var drag=false,px=0,py=0;
   cv.addEventListener('pointerdown',function(e){drag=true;px=e.clientX;py=e.clientY;cv.style.cursor='grabbing';tip.style.display='none';cv.setPointerCapture(e.pointerId);});
   cv.addEventListener('pointerup',function(e){drag=false;cv.style.cursor='grab';});
   cv.addEventListener('pointermove',function(e){if(!drag){mostrar(e);return;}az-=(e.clientX-px)*0.01;el+=(e.clientY-py)*0.01;
     el=Math.max(0.05,Math.min(1.5,el));px=e.clientX;py=e.clientY;draw();});
 }
 function init(){var cs=document.querySelectorAll('canvas.hk-surf');for(var i=0;i<cs.length;i++)setup(cs[i]);}
 if(document.readyState==='loading')document.addEventListener('DOMContentLoaded',init);else init();
})();
</script>";

        // 20-sep-2026, Jorge: «azul es donde no hay esfuerzos y rojo donde si».
        // En un resultado (presion de contacto, tension, momento) el MAXIMO tiene que
        // ser rojo: es la convencion de ETABS/SAFE y la que lee cualquier ingeniero.
        // Antes era jet_r y pintaba de ROJO la zona DESPEGADA, que vale cero.
        static SKColor JetR(double t)   // jet normal: 0 = azul ... 1 = rojo
        {
            t = Math.Max(0, Math.Min(1, t));
            double r = Math.Max(0, Math.Min(1, 1.5 - Math.Abs(4 * t - 3)));
            double g = Math.Max(0, Math.Min(1, 1.5 - Math.Abs(4 * t - 2)));
            double b = Math.Max(0, Math.Min(1, 1.5 - Math.Abs(4 * t - 1)));
            return new SKColor((byte)(r * 255), (byte)(g * 255), (byte)(b * 255));
        }


        // Colormap de CSI — el MISMO de ETABS, SAFE y SAP2000. Copiado de la replica ya
        // comprobada contra la leyenda real de ETABS (hekatan-struct, getColorMap.ts):
        // t=0 el MAXIMO (magenta) y t=1 el minimo (azul oscuro), pasando por rojo,
        // naranja, amarillo, verde y cian. 14 paradas.
        static readonly (double t, byte r, byte g, byte b)[] CSI_PAL = {
            (0.000, 255,   0, 255), (0.077, 255,   0, 180), (0.154, 255,   0,   0),
            (0.231, 255,  80,   0), (0.308, 255, 140,   0), (0.385, 255, 190,   0),
            (0.462, 255, 255,   0), (0.538, 180, 255,   0), (0.615,   0, 255,   0),
            (0.692,   0, 255, 180), (0.769,   0, 255, 255), (0.846,   0, 180, 255),
            (0.923,   0,   0, 255), (1.000,   0,   0, 180),
        };

        // t = 0 minimo … 1 maximo (se invierte dentro para casar con la leyenda de CSI)
        static SKColor Csi(double t)
        {
            t = 1.0 - Math.Max(0, Math.Min(1, t));
            for (int i = 0; i < CSI_PAL.Length - 1; i++)
            {
                var (t0, r0, g0, b0) = CSI_PAL[i];
                var (t1, r1, g1, b1) = CSI_PAL[i + 1];
                if (t <= t1)
                {
                    double u = t1 > t0 ? (t - t0) / (t1 - t0) : 0;
                    return new SKColor((byte)(r0 + (r1 - r0) * u),
                                       (byte)(g0 + (g1 - g0) * u),
                                       (byte)(b0 + (b1 - b0) * u));
                }
            }
            var last = CSI_PAL[CSI_PAL.Length - 1];
            return new SKColor(last.r, last.g, last.b);
        }

        // Cuantiza a bandas, como los contours de ETABS: nlev = 0 -> gradiente continuo.
        static SKColor Banda(double t, int nlev, bool csi)
        {
            if (nlev > 0)
            {
                t = Math.Max(0, Math.Min(0.999999, t));
                t = (Math.Floor(t * nlev) + 0.5) / nlev;
            }
            return csi ? Csi(t) : JetR(t);
        }


        // ---- MALLADO: la rejilla de elementos con sus nudos ----------------------
        // Dibuja nx x ny elementos sobre [xa,xb]x[ya,yb], numerando los nudos cuando
        // caben. Es lo que hace falta para ENSEÑAR una malla de elementos finitos
        // antes de pintar cualquier campo encima.
        public static string MeshPng(int nx, int ny, double xa, double xb,
                                     double ya, double yb, bool dark, bool numerar = true)
        {
            const int W = 560, H = 430;
            var inv = CultureInfo.InvariantCulture;
            float pL = 52, pR = 30, pT = 40, pB = 44;   // pT deja sitio al titulo
            float pw = W - pL - pR, ph = H - pT - pB;
            SKColor bg = dark ? new SKColor(0x14, 0x16, 0x1a) : new SKColor(0xFB, 0xF7, 0xEC);
            SKColor fg = dark ? new SKColor(0xC8, 0xCC, 0xD0) : new SKColor(0x33, 0x33, 0x33);
            SKColor lin = dark ? new SKColor(0x6E, 0x86, 0xA8) : new SKColor(0x7A, 0x8A, 0xA0);
            SKColor nod = new SKColor(0xC0, 0x39, 0x2B);
            using var surf = SKSurface.Create(new SKImageInfo(W, H));
            var cv = surf.Canvas;
            cv.Clear(bg);
            float X(double u) => pL + (float)((u - xa) / (xb - xa)) * pw;
            float Y(double v) => pT + ph - (float)((v - ya) / (yb - ya)) * ph;

            var gl = new SKPaint { IsAntialias = true, Style = SKPaintStyle.Stroke,
                                   Color = lin, StrokeWidth = 1.2f };
            for (int i = 0; i <= nx; i++)
            {
                double u = xa + (xb - xa) * i / nx;
                cv.DrawLine(X(u), Y(ya), X(u), Y(yb), gl);
            }
            for (int j = 0; j <= ny; j++)
            {
                double v = ya + (yb - ya) * j / ny;
                cv.DrawLine(X(xa), Y(v), X(xb), Y(v), gl);
            }
            // el contorno, mas grueso
            var bo = new SKPaint { IsAntialias = true, Style = SKPaintStyle.Stroke,
                                   Color = fg, StrokeWidth = 2.4f };
            cv.DrawRect(X(xa), Y(yb), X(xb) - X(xa), Y(ya) - Y(yb), bo);

            var dot = new SKPaint { IsAntialias = true, Style = SKPaintStyle.Fill, Color = nod };
            var txt = new SKPaint { Typeface = HkFont.Ui, IsAntialias = true, Color = fg, TextSize = 10,
                                    TextAlign = SKTextAlign.Center };
            int nJ = (nx + 1) * (ny + 1);
            bool num = numerar && nJ <= 80;
            int id = 0;
            for (int j = 0; j <= ny; j++)
                for (int i = 0; i <= nx; i++)
                {
                    id++;
                    float fx = X(xa + (xb - xa) * i / nx), fy = Y(ya + (yb - ya) * j / ny);
                    cv.DrawCircle(fx, fy, 3.2f, dot);
                    if (num) cv.DrawText(id.ToString(inv), fx + 9, fy - 6, txt);
                }
            // numero de elemento en el centro de cada celda
            if (nx * ny <= 60)
            {
                var et = new SKPaint { Typeface = HkFont.Ui, IsAntialias = true, Color = lin, TextSize = 10,
                                       TextAlign = SKTextAlign.Center };
                int e = 0;
                for (int j = 0; j < ny; j++)
                    for (int i = 0; i < nx; i++)
                    {
                        e++;
                        float fx = X(xa + (xb - xa) * (i + 0.5) / nx);
                        float fy = Y(ya + (yb - ya) * (j + 0.5) / ny);
                        cv.DrawText(e.ToString(inv), fx, fy + 4, et);
                    }
            }
            var ax = new SKPaint { Typeface = HkFont.Ui, IsAntialias = true, Color = fg, TextSize = 11 };
            string N(double v) => (Math.Abs(v) < 1e-9 ? 0 : v).ToString("0.###", inv);
            for (int k = 0; k <= 4; k++)
            {
                float fx = pL + pw * k / 4; double v0 = xa + (xb - xa) * k / 4;
                ax.TextAlign = SKTextAlign.Center; cv.DrawText(N(v0), fx, pT + ph + 17, ax);
                float fy = pT + ph - ph * k / 4; double w0 = ya + (yb - ya) * k / 4;
                ax.TextAlign = SKTextAlign.Right; cv.DrawText(N(w0), pL - 7, fy + 4, ax);
            }
            ax.TextAlign = SKTextAlign.Center; ax.TextSize = 12;
            cv.DrawText($"{nx} x {ny} = {nx * ny} elementos   ·   {nJ} nudos",
                        W / 2f, 14, ax);
            using var img = surf.Snapshot();
            using var data = img.Encode(SKEncodedImageFormat.Png, 100);
            return Convert.ToBase64String(data.ToArray());
        }

        /// <summary>La malla DE UN MODELO (hoja numérica): nudos (x, y), elementos (lista de nudos, 1-based)
        /// y nudos apoyados, con la numeración que de verdad usa el cálculo. #malla(nx, ny, …) dibuja una
        /// rejilla ideal numerada a su manera; esta dibuja la del modelo, sea cual sea su orden.</summary>
        public static string MeshPngData(double[] xs, double[] ys, int[][] elems, int[] apoyos, bool dark, int[][] restr = null)
        {
            const int W = 560, H = 430;
            var inv = CultureInfo.InvariantCulture;
            float pL = 52, pR = 30, pT = 40, pB = 44;
            double xa = xs.Min(), xb = xs.Max(), ya = ys.Min(), yb = ys.Max();
            if (xb - xa < 1e-12) xb = xa + 1; if (yb - ya < 1e-12) yb = ya + 1;
            // misma escala en x y en y: la losa se ve con su proporción real
            double k = Math.Min((W - pL - pR) / (xb - xa), (H - pT - pB) / (yb - ya));
            float pw = (float)(k * (xb - xa)), ph = (float)(k * (yb - ya));
            float ox = pL + (W - pL - pR - pw) / 2, oy = pT + (H - pT - pB - ph) / 2;
            float X(double u) => ox + (float)((u - xa) * k);
            float Y(double v) => oy + ph - (float)((v - ya) * k);
            SKColor bg = dark ? new SKColor(0x14, 0x16, 0x1a) : new SKColor(0xFB, 0xF7, 0xEC);
            SKColor fg = dark ? new SKColor(0xC8, 0xCC, 0xD0) : new SKColor(0x33, 0x33, 0x33);
            SKColor lin = dark ? new SKColor(0x6E, 0xA8, 0x86) : new SKColor(0x2E, 0x8B, 0x57);
            SKColor nod = new SKColor(0xE0, 0x4B, 0x1B);
            using var surf = SKSurface.Create(new SKImageInfo(W, H));
            var cv = surf.Canvas;
            cv.Clear(bg);
            var fill = new SKPaint { IsAntialias = true, Style = SKPaintStyle.Fill, Color = new SKColor(0x32, 0xCD, 0x32, 0x1A) };
            var gl = new SKPaint { IsAntialias = true, Style = SKPaintStyle.Stroke, Color = lin, StrokeWidth = 1.2f };
            var et = new SKPaint { Typeface = HkFont.Ui, IsAntialias = true, Color = fg, TextSize = 10, TextAlign = SKTextAlign.Center };
            bool numE = elems.Length <= 80;
            for (int e = 0; e < elems.Length; e++)
            {
                var ns = elems[e].Where(j => j >= 1 && j <= xs.Length).ToArray();
                if (ns.Length < 2) continue;
                using var path = new SKPath();
                path.MoveTo(X(xs[ns[0] - 1]), Y(ys[ns[0] - 1]));
                for (int q = 1; q < ns.Length; q++) path.LineTo(X(xs[ns[q] - 1]), Y(ys[ns[q] - 1]));
                path.Close();
                cv.DrawPath(path, fill); cv.DrawPath(path, gl);
                if (numE)
                {
                    double cx = ns.Average(j => xs[j - 1]), cy = ns.Average(j => ys[j - 1]);
                    cv.DrawText((e + 1).ToString(inv), X(cx), Y(cy) + 4, et);
                }
            }
            var sup = new SKPaint { IsAntialias = true, Style = SKPaintStyle.Fill, Color = new SKColor(0xFF, 0xB6, 0xC1) };
            var supB = new SKPaint { IsAntialias = true, Style = SKPaintStyle.Stroke, Color = new SKColor(0xD0, 0x20, 0x20), StrokeWidth = 1.2f };
            // restricciones (opcional, una fila por apoyo: [w θx θy ψ], 1 = fijo), como en Calcpad:
            //   solo w → círculo (apoyo puntual, columna) · θx fijo → raya a lo largo de x (borde paralelo
            //   a x) · θy fijo → raya a lo largo de y · todo fijo → cuadrado relleno (empotramiento)
            var supL = new SKPaint { IsAntialias = true, Style = SKPaintStyle.Stroke, Color = new SKColor(0xD0, 0x20, 0x20), StrokeWidth = 2.2f };
            var supE = new SKPaint { IsAntialias = true, Style = SKPaintStyle.Fill, Color = new SKColor(0xB0, 0x18, 0x18) };
            bool hayEmp = false, hayRaya = false, hayPunto = false;
            var apo = apoyos ?? Array.Empty<int>();
            for (int s = 0; s < apo.Length; s++)
            {
                int j = apo[s];
                if (j < 1 || j > xs.Length) continue;
                float px = X(xs[j - 1]), py = Y(ys[j - 1]);
                int[] r = restr != null && s < restr.Length ? restr[s] : null;
                bool f(int k) => r != null && r.Length > k && r[k] != 0;
                if (r != null && r.Length >= 3 && r.All(v => v != 0))
                {
                    cv.DrawRect(px - 5.5f, py - 5.5f, 11f, 11f, supE); hayEmp = true;
                    continue;
                }
                if (f(1)) { cv.DrawLine(px - 11, py, px + 11, py, supL); hayRaya = true; }
                if (f(2)) { cv.DrawLine(px, py - 11, px, py + 11, supL); hayRaya = true; }
                if (r != null && !f(1) && !f(2)) hayPunto = true;
                cv.DrawCircle(px, py, 6.5f, sup);
                cv.DrawCircle(px, py, 6.5f, supB);
            }
            var dot = new SKPaint { IsAntialias = true, Style = SKPaintStyle.Fill, Color = nod };
            var txt = new SKPaint { Typeface = HkFont.Ui, IsAntialias = true, Color = fg, TextSize = 10, TextAlign = SKTextAlign.Left };
            bool numJ = xs.Length <= 120;
            for (int j = 0; j < xs.Length; j++)
            {
                cv.DrawCircle(X(xs[j]), Y(ys[j]), 3.2f, dot);
                if (numJ) cv.DrawText((j + 1).ToString(inv), X(xs[j]) + 5, Y(ys[j]) - 5, txt);
            }
            var ax = new SKPaint { Typeface = HkFont.Ui, IsAntialias = true, Color = fg, TextSize = 11 };
            string N(double v) => (Math.Abs(v) < 1e-9 ? 0 : v).ToString("0.###", inv);
            for (int q = 0; q <= 4; q++)
            {
                double v0 = xa + (xb - xa) * q / 4, w0 = ya + (yb - ya) * q / 4;
                ax.TextAlign = SKTextAlign.Center; cv.DrawText(N(v0), X(v0), oy + ph + 17, ax);
                ax.TextAlign = SKTextAlign.Right; cv.DrawText(N(w0), ox - 7, Y(w0) + 4, ax);
            }
            ax.TextAlign = SKTextAlign.Center; ax.TextSize = 12;
            cv.DrawText($"{elems.Length} elementos   ·   {xs.Length} nudos" + (apoyos != null && apoyos.Length > 0 ? $"   ·   {apoyos.Length} apoyados" : ""), W / 2f, 16, ax);
            if (restr != null)   // leyenda de los apoyos, abajo
            {
                var ley = new List<string>();
                if (hayPunto) ley.Add("○ apoyo puntual: w = 0");
                if (hayRaya) ley.Add("○— borde apoyado: w = 0 y giro a lo largo del borde = 0");
                if (hayEmp) ley.Add("■ empotrado: w = θx = θy = ψ = 0");
                ax.TextSize = 10.5f;
                cv.DrawText(string.Join("    ", ley), W / 2f, H - 8, ax);
            }
            using var img = surf.Snapshot();
            using var data = img.Encode(SKEncodedImageFormat.Png, 100);
            return Convert.ToBase64String(data.ToArray());
        }

        // Devuelve el PNG (base64) de la superficie z=f(x,y) sobre [xa,xb]×[ya,yb].
        public static string SurfacePng(LispConverter.N f, string vx, string vy,
                                        double xa, double xb, double ya, double yb, bool dark)
        {
            const int nx = 40, ny = 40, W = 560, H = 420;
            var Z = new double[nx + 1, ny + 1];
            double zmin = double.MaxValue, zmax = double.MinValue;
            for (int i = 0; i <= nx; i++)
                for (int j = 0; j <= ny; j++)
                {
                    double x = xa + (xb - xa) * i / nx, y = ya + (yb - ya) * j / ny;
                    double z = Eval(f, new Dictionary<string, double> { { vx, x }, { vy, y } });
                    if (double.IsNaN(z) || double.IsInfinity(z)) z = 0;
                    Z[i, j] = z; zmin = Math.Min(zmin, z); zmax = Math.Max(zmax, z);
                }
            if (zmax - zmin < 1e-9) zmax = zmin + 1;

            // Cámara ortográfica 3/4 (azimut + elevación), como matplotlib elev≈28° azim≈-51°.
            // Los ejes right/up/depth son ortonormales → ninguna diagonal se colapsa (el bug del isométrico puro).
            const double az = -0.90, el = 0.50;
            double ca = Math.Cos(az), sa = Math.Sin(az), ce = Math.Cos(el), se = Math.Sin(el);
            SKPoint Proj(int i, int j, double z)
            {
                double X = (double)i / nx - 0.5, Y = (double)j / ny - 0.5, Z2 = (z - zmin) / (zmax - zmin);
                double rx = -X * sa + Y * ca;                          // eje derecha
                double up = -se * ca * X - se * sa * Y + ce * Z2;      // eje arriba (Z sube en pantalla)
                return new SKPoint((float)(W * 0.5 + rx * W * 0.66), (float)(H * 0.60 - up * H * 0.62));
            }
            double Depth(int i, int j, double z)                       // distancia a la cámara (para pintar atrás→frente)
            {
                double X = (double)i / nx - 0.5, Y = (double)j / ny - 0.5, Z2 = (z - zmin) / (zmax - zmin);
                return ce * ca * X + ce * sa * Y + se * Z2;
            }

            var info = new SKImageInfo(W, H);
            using var surf = SKSurface.Create(info);
            var cv = surf.Canvas;
            cv.Clear(dark ? new SKColor(0x14, 0x16, 0x1a) : new SKColor(0xFB, 0xF7, 0xEC));
            var fill = new SKPaint { IsAntialias = true, Style = SKPaintStyle.Fill };
            var edge = new SKPaint { IsAntialias = true, Style = SKPaintStyle.Stroke,
                                     Color = new SKColor(0, 0, 0, dark ? (byte)30 : (byte)45), StrokeWidth = 0.5f };
            // painter's algorithm: ordenar las celdas por profundidad (lejos primero) y pintar
            var cells = new List<(double d, int i, int j)>(nx * ny);
            for (int i = 0; i < nx; i++)
                for (int j = 0; j < ny; j++)
                {
                    double zc = (Z[i, j] + Z[i + 1, j] + Z[i + 1, j + 1] + Z[i, j + 1]) / 4;
                    cells.Add((Depth(i, j, zc), i, j));
                }
            cells.Sort((p, q) => p.d.CompareTo(q.d));   // menor profundidad = más lejos = se pinta primero
            foreach (var (_, i, j) in cells)
            {
                var p0 = Proj(i, j, Z[i, j]); var p1 = Proj(i + 1, j, Z[i + 1, j]);
                var p2 = Proj(i + 1, j + 1, Z[i + 1, j + 1]); var p3 = Proj(i, j + 1, Z[i, j + 1]);
                double zavg = (Z[i, j] + Z[i + 1, j] + Z[i + 1, j + 1] + Z[i, j + 1]) / 4;
                fill.Color = JetR((zavg - zmin) / (zmax - zmin));
                using var path = new SKPath();
                path.MoveTo(p0); path.LineTo(p1); path.LineTo(p2); path.LineTo(p3); path.Close();
                cv.DrawPath(path, fill); cv.DrawPath(path, edge);
            }
            using var img = surf.Snapshot();
            using var data = img.Encode(SKEncodedImageFormat.Png, 90);
            return Convert.ToBase64String(data.ToArray());
        }

        // ---- MAPA DE COLOR 2D (planta, visto desde arriba) con SkiaSharp → PNG base64 ----
        // Es la gráfica FEM clásica: la función pintada sobre el dominio con jet_r + barra de color.
        // Estático (2D no gira), por eso va con SkiaSharp y no con canvas.
        public static string MapPng(LispConverter.N f, string vx, string vy,
                                    double xa, double xb, double ya, double yb, bool dark)
            => MapPng(f, vx, vy, xa, xb, ya, yb, dark, false, 0);

        // 17-sep-2026, Jorge: «en el hover cursor». El mapa es un PNG (rapido y con ejes), asi que el
        // valor no se puede sacar del pixel: se envia APARTE una rejilla de z y se interpola al vuelo.
        // Los margenes del PNG (pL, pR, pT, pB de MapPng) van tambien, para saber donde empieza la placa.
        public static string MapHover(LispConverter.N f, string vx, string vy,
                                      double xa, double xb, double ya, double yb, string img)
        {
            const int nh = 64;
            var (Z, _, _) = Sample(f, vx, vy, xa, xb, ya, yb, nh);
            return MapHoverGrid(Z, nh, vx, vy, xa, xb, ya, yb, img);
        }

        /// <summary>El hover de un mapa cuya rejilla YA viene calculada (hoja numérica: la calcula el motor).</summary>
        public static string MapHoverGrid(double[,] Z, int nh, string vx, string vy,
                                          double xa, double xb, double ya, double yb, string img, int H = 430)
        {
            var inv = CultureInfo.InvariantCulture;
            var sb = new System.Text.StringBuilder("[");
            for (int j = 0; j <= nh; j++)
                for (int i = 0; i <= nh; i++)
                {
                    if (i + j > 0) sb.Append(',');
                    sb.Append(Math.Round(Z[i, j], 5).ToString("0.#####", inv));
                }
            sb.Append(']');
            return "<span class=\"hk-map\" style=\"display:inline-block;position:relative\""
                 + " data-nn=\"" + nh + "\" data-w=\"560\" data-h=\"" + H + "\""
                 + " data-pl=\"50\" data-pr=\"84\" data-pt=\"16\" data-pb=\"42\""
                 + " data-xa=\"" + xa.ToString("0.######", inv) + "\" data-xb=\"" + xb.ToString("0.######", inv) + "\""
                 + " data-ya=\"" + ya.ToString("0.######", inv) + "\" data-yb=\"" + yb.ToString("0.######", inv) + "\""
                 + " data-vx=\"" + System.Net.WebUtility.HtmlEncode(vx) + "\" data-vy=\"" + System.Net.WebUtility.HtmlEncode(vy) + "\""
                 + " data-z='" + sb + "'>" + img + "</span>";
        }

        // Script del hover de los MAPAS (se emite una vez, como el del orbit).
        public const string MapScript = @"<script>
(function(){
 function setup(sp){
   var nn=+sp.dataset.nn, z=JSON.parse(sp.dataset.z), im=sp.querySelector('img');
   var W=+sp.dataset.w,H=+sp.dataset.h,pL=+sp.dataset.pl,pR=+sp.dataset.pr,pT=+sp.dataset.pt,pB=+sp.dataset.pb;
   var xa=+sp.dataset.xa,xb=+sp.dataset.xb,ya=+sp.dataset.ya,yb=+sp.dataset.yb;
   var vx=sp.dataset.vx||'x',vy=sp.dataset.vy||'y';
   if(!im) return;
   var tip=document.createElement('div');
   tip.style.cssText='position:fixed;z-index:9999;display:none;pointer-events:none;background:#fffffff2;'+
     'border:1px solid #888;border-radius:4px;padding:3px 6px;font:12px/1.35 Consolas,monospace;color:#111;'+
     'box-shadow:0 2px 6px rgba(0,0,0,.25);white-space:pre';
   document.body.appendChild(tip);
   function num(v){var a=Math.abs(v);return (a>=1e5||(a>0&&a<1e-3))?v.toExponential(3):v.toFixed(4);}
   function Zi(i,j){return z[j*(nn+1)+i];}
   im.addEventListener('pointermove',function(e){
     var r=im.getBoundingClientRect();
     var px=(e.clientX-r.left)*W/r.width, py=(e.clientY-r.top)*H/r.height;   // pixel del PNG original
     var u=(px-pL)/(W-pL-pR), v=1-(py-pT)/(H-pT-pB);                        // 0..1 dentro de la placa
     if(u<0||u>1||v<0||v>1){tip.style.display='none';return;}
     var fi=u*nn, fj=v*nn, i=Math.min(nn-1,Math.floor(fi)), j=Math.min(nn-1,Math.floor(fj));
     var a=fi-i,b=fj-j;
     var zz=Zi(i,j)*(1-a)*(1-b)+Zi(i+1,j)*a*(1-b)+Zi(i,j+1)*(1-a)*b+Zi(i+1,j+1)*a*b;   // bilineal
     tip.textContent=vx+' = '+num(xa+(xb-xa)*u)+'\n'+vy+' = '+num(ya+(yb-ya)*v)+'\nz = '+num(zz);
     tip.style.display='block';tip.style.left=(e.clientX+14)+'px';tip.style.top=(e.clientY+14)+'px';
   });
   im.addEventListener('pointerleave',function(){tip.style.display='none';});
   im.style.cursor='crosshair';
 }
 function init(){var m=document.querySelectorAll('span.hk-map');for(var i=0;i<m.length;i++)setup(m[i]);}
 if(document.readyState==='loading')document.addEventListener('DOMContentLoaded',init);else init();
})();
</script>";

        // csi = colormap de ETABS/CSI · nlev = bandas de contorno (0 = gradiente)
        public static string MapPng(LispConverter.N f, string vx, string vy,
                                    double xa, double xb, double ya, double yb, bool dark,
                                    bool csi, int nlev)
        {
            // con bandas hace falta MAS resolucion: si no, el borde de cada banda sale
            // escalonado (en ETABS/Lab el relleno es por pixel).
            int nn = nlev > 0 ? 240 : 90;
            var (Z, zmin, zmax) = Sample(f, vx, vy, xa, xb, ya, yb, nn);
            return MapPngGrid(Z, nn, zmin, zmax, xa, xb, ya, yb, dark, csi, nlev, 430);
        }

        /// <summary>Alto del PNG para que la planta salga con su proporción real (una losa de 6 × 4 no
        /// es un cuadrado). El ancho del dibujo es fijo (426 px): alto = 426·(yb − ya)/(xb − xa).</summary>
        public static int AltoProporcional(double xa, double xb, double ya, double yb)
        {
            double r = Math.Abs(xb - xa) < 1e-12 ? 1 : Math.Abs((yb - ya) / (xb - xa));
            return (int)Math.Round(Math.Max(160, Math.Min(640, 426 * r)) + 16 + 42);
        }

        /// <summary>Mapa de color de una rejilla ya calculada: Z[i, j] con i por x (nn+1 puntos por lado).</summary>
        public static string MapPngGrid(double[,] Z, int nn, double xa, double xb, double ya, double yb,
                                        bool dark, bool csi, int nlev)
        {
            double zmin = double.MaxValue, zmax = double.MinValue;
            foreach (var z in Z) { if (double.IsNaN(z) || double.IsInfinity(z)) continue; zmin = Math.Min(zmin, z); zmax = Math.Max(zmax, z); }
            if (zmax - zmin < 1e-9) zmax = zmin + 1;
            return MapPngGrid(Z, nn, zmin, zmax, xa, xb, ya, yb, dark, csi, nlev, AltoProporcional(xa, xb, ya, yb));
        }

        static string MapPngGrid(double[,] Z, int nn, double zmin, double zmax, double xa, double xb, double ya, double yb,
                                 bool dark, bool csi, int nlev, int H)
        {
            const int W = 560;
            var inv = CultureInfo.InvariantCulture;
            float pL = 50, pR = 84, pT = 16, pB = 42;
            float pw = W - pL - pR, ph = H - pT - pB;
            SKColor bg = dark ? new SKColor(0x14, 0x16, 0x1a) : new SKColor(0xFB, 0xF7, 0xEC);
            SKColor fg = dark ? new SKColor(0xC8, 0xCC, 0xD0) : new SKColor(0x33, 0x33, 0x33);
            var info = new SKImageInfo(W, H);
            using var surf = SKSurface.Create(info);
            var cv = surf.Canvas;
            cv.Clear(bg);
            // celdas de color (j hacia ARRIBA en pantalla)
            var cell = new SKPaint { IsAntialias = false, Style = SKPaintStyle.Fill };
            float cw = pw / nn, chh = ph / nn;
            for (int i = 0; i < nn; i++)
                for (int j = 0; j < nn; j++)
                {
                    double zc = (Z[i, j] + Z[i + 1, j] + Z[i, j + 1] + Z[i + 1, j + 1]) / 4;
                    cell.Color = Banda((zc - zmin) / (zmax - zmin), nlev, csi);
                    cv.DrawRect(pL + i * cw, pT + (nn - 1 - j) * chh, cw + 1, chh + 1, cell);
                }
            var axis = new SKPaint { IsAntialias = true, Style = SKPaintStyle.Stroke, Color = fg, StrokeWidth = 1 };
            cv.DrawRect(pL, pT, pw, ph, axis);
            var txt = new SKPaint { Typeface = HkFont.Ui, IsAntialias = true, Color = fg, TextSize = 11 };
            string N(double v) => (Math.Abs(v) < 1e-9 ? 0 : v).ToString("0.###", inv);
            // ticks X (abajo) y Y (izquierda), 5 divisiones
            for (int k = 0; k <= 4; k++)
            {
                float fx = pL + pw * k / 4; double vx0 = xa + (xb - xa) * k / 4;
                cv.DrawLine(fx, pT + ph, fx, pT + ph + 4, axis);
                txt.TextAlign = SKTextAlign.Center; cv.DrawText(N(vx0), fx, pT + ph + 17, txt);
                float fy = pT + ph - ph * k / 4; double vy0 = ya + (yb - ya) * k / 4;
                cv.DrawLine(pL - 4, fy, pL, fy, axis);
                txt.TextAlign = SKTextAlign.Right; cv.DrawText(N(vy0), pL - 7, fy + 4, txt);
            }
            // BARRA DE COLOR a la derecha
            float cbx = W - pR + 22, cbw = 15, cbTop = pT, cbH = ph;
            var bar = new SKPaint { Style = SKPaintStyle.Fill };
            for (int k = 0; k < (int)cbH; k++)
            {
                bar.Color = Banda(1.0 - k / cbH, nlev, csi);   // arriba = máximo
                cv.DrawRect(cbx, cbTop + k, cbw, 1.2f, bar);
            }
            cv.DrawRect(cbx, cbTop, cbw, cbH, axis);
            txt.TextAlign = SKTextAlign.Left;
            cv.DrawText(N(zmax), cbx + cbw + 4, cbTop + 9, txt);
            cv.DrawText(N(zmin), cbx + cbw + 4, cbTop + cbH, txt);
            cv.DrawText(N((zmin + zmax) / 2), cbx + cbw + 4, cbTop + cbH / 2 + 4, txt);
            using var img = surf.Snapshot();
            using var data = img.Encode(SKEncodedImageFormat.Png, 92);
            return Convert.ToBase64String(data.ToArray());
        }

        // ================= SOLIDOS 3D (hexaedros), orbitables =================
        // Hekatan Lab tiene `solidmesh`; aqui va el equivalente. Se malla un prisma
        // de a x b x h en nx*ny*nz hexaedros, se pueden QUITAR unos cuantos (corte)
        // y se dibujan solo las caras EXTERIORES: las que no comparte con otro
        // hexaedro presente. Por eso el corte se ve RELLENO y no hueco.
        public static string SolidCanvas(double a, double b, double h,
                                         int nx, int ny, int nz, int corte, int id)
        {
            nx = Math.Max(1, Math.Min(nx, 24));
            ny = Math.Max(1, Math.Min(ny, 24));
            nz = Math.Max(1, Math.Min(nz, 24));
            bool Vivo(int i, int j, int k)
            {
                if (corte == 1) return !(i >= nx / 2 && j >= ny / 2);          // cuarto quitado
                if (corte == 2) return j < (ny + 1) / 2;                        // media pieza
                if (corte == 3) return !(i >= nx / 2 && j >= ny / 2 && k >= nz / 2);
                return true;
            }
            double dx = a / nx, dy = b / ny, dz = h / nz;
            var inv = CultureInfo.InvariantCulture;
            var sb = new System.Text.StringBuilder();
            sb.Append('[');
            bool primero = true;
            // las 6 caras de un hexaedro: indices del vertice (di,dj,dk) en orden de giro
            int[][][] CARAS = new int[][][] {
                new[]{ new[]{0,0,0}, new[]{0,1,0}, new[]{0,1,1}, new[]{0,0,1} },   // -x
                new[]{ new[]{1,0,0}, new[]{1,0,1}, new[]{1,1,1}, new[]{1,1,0} },   // +x
                new[]{ new[]{0,0,0}, new[]{0,0,1}, new[]{1,0,1}, new[]{1,0,0} },   // -y
                new[]{ new[]{0,1,0}, new[]{1,1,0}, new[]{1,1,1}, new[]{0,1,1} },   // +y
                new[]{ new[]{0,0,0}, new[]{1,0,0}, new[]{1,1,0}, new[]{0,1,0} },   // -z
                new[]{ new[]{0,0,1}, new[]{0,1,1}, new[]{1,1,1}, new[]{1,0,1} },   // +z
            };
            int[][] VEC = new int[][] { new[]{-1,0,0}, new[]{1,0,0}, new[]{0,-1,0},
                                        new[]{0,1,0}, new[]{0,0,-1}, new[]{0,0,1} };
            for (int i = 0; i < nx; i++)
                for (int j = 0; j < ny; j++)
                    for (int k = 0; k < nz; k++)
                    {
                        if (!Vivo(i, j, k)) continue;
                        for (int c = 0; c < 6; c++)
                        {
                            int vi = i + VEC[c][0], vj = j + VEC[c][1], vk = k + VEC[c][2];
                            bool dentro = vi >= 0 && vi < nx && vj >= 0 && vj < ny && vk >= 0 && vk < nz;
                            if (dentro && Vivo(vi, vj, vk)) continue;      // cara interior: no se dibuja
                            if (!primero) sb.Append(',');
                            primero = false;
                            for (int v = 0; v < 4; v++)
                            {
                                var d = CARAS[c][v];
                                double X = (i + d[0]) * dx, Y = (j + d[1]) * dy, Z = (k + d[2]) * dz;
                                sb.Append(Math.Round(X, 4).ToString("0.####", inv)).Append(',');
                                sb.Append(Math.Round(Y, 4).ToString("0.####", inv)).Append(',');
                                sb.Append(Math.Round(Z, 4).ToString("0.####", inv)).Append(',');
                            }
                            double t = nz > 0 ? (k + 0.5) / nz : 0.5;      // color por ALTURA
                            sb.Append(Math.Round(t, 4).ToString("0.####", inv));
                        }
                    }
            sb.Append(']');
            return "<canvas class=\"hk-sol\" width=\"560\" height=\"430\" style=\"max-width:100%;touch-action:none;cursor:grab\""
                 + " data-id=\"" + id + "\""
                 + " data-a=\"" + a.ToString("0.####", inv) + "\""
                 + " data-b=\"" + b.ToString("0.####", inv) + "\""
                 + " data-h=\"" + h.ToString("0.####", inv) + "\""
                 + " data-f='" + sb + "'></canvas>";
        }

        // Orbit de los SOLIDOS: mismo pintor que la superficie, pero sobre caras
        // sueltas (13 numeros por cara: 4 vertices xyz + el valor de color).
        public const string SolidScript = @"<script>
(function(){
 var CSI=[[255,0,255],[255,0,0],[255,140,0],[255,255,0],[0,255,0],[0,255,255],[0,0,255],[0,0,180]];
 function csi(t){t=1-Math.max(0,Math.min(1,t));var u=t*(CSI.length-1),k=Math.min(CSI.length-2,Math.floor(u)),f=u-k;
   var A=CSI[k],B=CSI[k+1];
   return 'rgb('+((A[0]+(B[0]-A[0])*f)|0)+','+((A[1]+(B[1]-A[1])*f)|0)+','+((A[2]+(B[2]-A[2])*f)|0)+')';}
 function setup(cv){
   var F=JSON.parse(cv.dataset.f),a=+cv.dataset.a,b=+cv.dataset.b,h=+cv.dataset.h;
   var W=cv.width,H=cv.height,ctx=cv.getContext('2d'),az=-0.75,el=0.42;
   var m=Math.max(a,Math.max(b,h))||1;
   function proj(X,Y,Z){var ca=Math.cos(az),sa=Math.sin(az),ce=Math.cos(el),se=Math.sin(el);
     var x=X/m-a/m/2,y=Y/m-b/m/2,z=Z/m-h/m/2;
     var rx=-x*sa+y*ca,up=-se*ca*x-se*sa*y+ce*z;
     return [W*0.5+rx*W*0.60,H*0.52-up*H*0.58];}
   function dep(X,Y,Z){var ca=Math.cos(az),sa=Math.sin(az),ce=Math.cos(el),se=Math.sin(el);
     var x=X/m-a/m/2,y=Y/m-b/m/2,z=Z/m-h/m/2;return ce*ca*x+ce*sa*y+se*z;}
   function draw(){ctx.clearRect(0,0,W,H);var n=F.length/13,ord=[];
     for(var q=0;q<n;q++){var o=q*13,d=0;
       for(var v=0;v<4;v++)d+=dep(F[o+v*3],F[o+v*3+1],F[o+v*3+2]);
       ord.push([d/4,q]);}
     ord.sort(function(p,r){return p[0]-r[0];});
     for(var s=0;s<ord.length;s++){var o=ord[s][1]*13;
       ctx.beginPath();
       for(var v=0;v<4;v++){var P=proj(F[o+v*3],F[o+v*3+1],F[o+v*3+2]);
         if(v===0)ctx.moveTo(P[0],P[1]);else ctx.lineTo(P[0],P[1]);}
       ctx.closePath();ctx.fillStyle=csi(F[o+12]);ctx.fill();
       ctx.strokeStyle='rgba(0,0,0,0.35)';ctx.lineWidth=0.8;ctx.stroke();}}
   var drag=false,px=0,py=0;
   cv.addEventListener('pointerdown',function(e){drag=true;px=e.clientX;py=e.clientY;cv.setPointerCapture(e.pointerId);cv.style.cursor='grabbing';});
   cv.addEventListener('pointermove',function(e){if(!drag)return;az-=(e.clientX-px)*0.01;el+=(e.clientY-py)*0.01;
     el=Math.max(-1.4,Math.min(1.4,el));px=e.clientX;py=e.clientY;draw();});
   cv.addEventListener('pointerup',function(e){drag=false;cv.style.cursor='grab';});
   draw();}
 function todos(){var l=document.querySelectorAll('canvas.hk-sol');for(var i=0;i<l.length;i++)if(!l[i].__hk){l[i].__hk=1;setup(l[i]);}}
 if(document.readyState==='loading')document.addEventListener('DOMContentLoaded',todos);else todos();
})();
</script>";
    
        // ================= #modelo3d: el modelo en 3D con hover (hoja numérica) =================
        // 24-sep-2026, Jorge: «como Python que tiene el 3D y con un cursor del mouse hacer hover».
        // Datos (literales del motor numérico): X (n×3), cáscaras (m×4, nudos desde 1), barras (b×2),
        // valor por nudo (n) para colorear la losa, valor en los extremos de cada barra (b×2) para su
        // diagrama, y opcionales U (n×3 o n×6, desplazamientos) y escala de la deformada.
        static readonly System.Text.RegularExpressions.Regex RxNum3 =
            new(@"(?<![\w.])-?\d+(?:\.\d+)?(?:[eE][-+]?\d+)?(?![\w.])");
        static double[] Nums3(string lit) => RxNum3.Matches(lit ?? "").Select(m => double.Parse(m.Value, NumberStyles.Float, CultureInfo.InvariantCulture)).ToArray();
        static double[][] Rows3(string lit)
        {
            var ms = System.Text.RegularExpressions.Regex.Matches(lit ?? "", @"\(vector ([^()]*)\)");
            return ms.Select(m => Nums3(m.Groups[1].Value)).ToArray();
        }
        static string J3(double v) => double.IsFinite(v) ? Math.Round(v, 6).ToString("0.######", CultureInfo.InvariantCulture) : "0";

        public static string Modelo3DHtml(List<string> lits, List<string> nombres, int id)
        {
            var X = Rows3(lits[0]); var S = Rows3(lits[1]); var B = Rows3(lits[2]);
            var vN = Nums3(lits[3]);
            var vB = Rows3(lits[4]);
            if (vB.Length != B.Length || vB.Any(r => r.Length < 2))
            {   // venía como vector plano: 2 valores por barra
                var f = Nums3(lits[4]);
                vB = Enumerable.Range(0, B.Length).Select(k => new[] { 2 * k + 1 < f.Length ? f[2 * k] : 0, 2 * k + 1 < f.Length ? f[2 * k + 1] : 0 }).ToArray();
            }
            var U = lits.Count > 5 ? Rows3(lits[5]) : new double[0][];
            double esc = lits.Count > 6 && Nums3(lits[6]).Length > 0 ? Nums3(lits[6])[0] : 0;
            string M(IEnumerable<double[]> rows) => "[" + string.Join(",", rows.Select(r => "[" + string.Join(",", r.Select(J3)) + "]")) + "]";
            var sb = new System.Text.StringBuilder("{");
            sb.Append("\"X\":").Append(M(X));
            sb.Append(",\"S\":").Append(M(S)).Append(",\"B\":").Append(M(B));
            sb.Append(",\"vN\":[").Append(string.Join(",", vN.Select(J3))).Append("]");
            sb.Append(",\"vB\":").Append(M(vB));
            if (U.Length == X.Length) sb.Append(",\"U\":").Append(M(U.Select(r => r.Take(3).ToArray())));
            sb.Append(",\"esc\":").Append(J3(esc));
            string nS = nombres.Count > 3 ? nombres[3] : "", nB = nombres.Count > 4 ? nombres[4] : "";
            sb.Append(",\"nS\":\"").Append(System.Web.HttpUtility.JavaScriptStringEncode(nS)).Append("\"");
            sb.Append(",\"nB\":\"").Append(System.Web.HttpUtility.JavaScriptStringEncode(nB)).Append("\"}");
            string json = System.Net.WebUtility.HtmlEncode(sb.ToString());
            return "<div class=\"hk-m3d\" style=\"position:relative;display:inline-block;max-width:100%\">" +
                   "<canvas id=\"hkm3d" + id + "\" width=\"900\" height=\"600\" style=\"max-width:100%;height:auto;cursor:grab;touch-action:none\" data-m3d=\"" + json + "\"></canvas>" +
                   "<div class=\"hk-m3d-tip\" style=\"position:absolute;display:none;pointer-events:none;background:rgba(255,255,255,.95);color:#111;border:1px solid #888;border-radius:4px;padding:3px 7px;font:12px monospace;white-space:pre\"></div></div>";
        }

        // Script del visor 3D (una vez por página): arrastrar = girar, rueda = zoom, cursor = valor.
        public const string Modelo3DScript = @"<script>
(function(){
function jet(t){t=Math.max(0,Math.min(1,t));var r=Math.min(Math.max(1.5-Math.abs(4*t-3),0),1),g=Math.min(Math.max(1.5-Math.abs(4*t-2),0),1),b=Math.min(Math.max(1.5-Math.abs(4*t-1),0),1);return [r*255|0,g*255|0,b*255|0];}
function css(c,a){return 'rgba('+c[0]+','+c[1]+','+c[2]+','+a+')';}
function fmt(v){var a=Math.abs(v);return (a!==0&&(a<1e-3||a>=1e5))?v.toExponential(3):v.toFixed(4);}
function init(cv){
 if(cv._m3d)return;cv._m3d=1;
 var D=JSON.parse(cv.getAttribute('data-m3d'));
 var g=cv.getContext('2d'),W=cv.width,H=cv.height,tip=cv.parentNode.querySelector('.hk-m3d-tip');
 var n=D.X.length,P=[],i,k;
 for(i=0;i<n;i++){var u=(D.U&&D.U[i])?D.U[i]:[0,0,0],e=D.esc||0;P.push([D.X[i][0]+e*u[0],D.X[i][1]+e*u[1],D.X[i][2]+e*u[2]]);}
 var lo=[1e99,1e99,1e99],hi=[-1e99,-1e99,-1e99];
 for(i=0;i<n;i++)for(k=0;k<3;k++){lo[k]=Math.min(lo[k],D.X[i][k]);hi[k]=Math.max(hi[k],D.X[i][k]);}
 var c=[(lo[0]+hi[0])/2,(lo[1]+hi[1])/2,(lo[2]+hi[2])/2],R=Math.max(hi[0]-lo[0],hi[1]-lo[1],hi[2]-lo[2])/2||1;
 var used={},smin=1e99,smax=-1e99;D.S.forEach(function(q){q.forEach(function(j){used[j-1]=1;});});
 for(i in used){var v=D.vN[i]||0;smin=Math.min(smin,v);smax=Math.max(smax,v);}
 if(!(smax>smin)){smax=smin+1;}
 var bmax=0;D.vB.forEach(function(r){bmax=Math.max(bmax,Math.abs(r[0]),Math.abs(r[1]));});
 var bs=bmax>0?0.22*R/bmax:0;
 var yaw=-0.65,pitch=0.5,zoom=1,drag=null,hov=null,prims=[],samp=[];
 function pr(p){var x=p[0]-c[0],y=p[1]-c[1],z=p[2]-c[2];var cy=Math.cos(yaw),sy=Math.sin(yaw),cp=Math.cos(pitch),sp=Math.sin(pitch);
  var x1=x*cy-y*sy,y1=x*sy+y*cy;var y2=y1*cp-z*sp,z2=y1*sp+z*cp;var s=0.42*Math.min(W,H)/R*zoom;return [W/2-40+x1*s,H/2-z2*s,y2];}
 function lerp(a,b,t){return [a[0]+(b[0]-a[0])*t,a[1]+(b[1]-a[1])*t,a[2]+(b[2]-a[2])*t];}
 function build(){prims=[];samp=[];var ns=4;
  D.S.forEach(function(q,e){var a=P[q[0]-1],b=P[q[1]-1],cc=P[q[2]-1],d=P[q[3]-1],va=D.vN[q[0]-1]||0,vb=D.vN[q[1]-1]||0,vc=D.vN[q[2]-1]||0,vd=D.vN[q[3]-1]||0;
   function pt(r,s){return lerp(lerp(a,b,r),lerp(d,cc,r),s);}
   function vl(r,s){return (1-r)*(1-s)*va+r*(1-s)*vb+r*s*vc+(1-r)*s*vd;}
   var ii,jj;
   for(ii=0;ii<ns;ii++)for(jj=0;jj<ns;jj++){var r0=ii/ns,r1=(ii+1)/ns,s0=jj/ns,s1=(jj+1)/ns;
    prims.push({t:'s',p:[pt(r0,s0),pt(r1,s0),pt(r1,s1),pt(r0,s1)],v:(vl(r0,s0)+vl(r1,s0)+vl(r1,s1)+vl(r0,s1))/4});}
   var o=D.X[q[0]-1],o2=D.X[q[2]-1];
   for(ii=0;ii<=ns;ii++)for(jj=0;jj<=ns;jj++){var r=ii/ns,s=jj/ns;
    samp.push({p:pt(r,s),txt:D.nS+' = '+fmt(vl(r,s))+'\nx = '+fmt(o[0]+(o2[0]-o[0])*r)+'   y = '+fmt(o[1]+(o2[1]-o[1])*s)+'\ncascara '+(e+1)});}
  });
  D.B.forEach(function(br,e){var a=P[br[0]-1],b=P[br[1]-1],v0=D.vB[e][0],v1=D.vB[e][1];
   var dv=[b[0]-a[0],b[1]-a[1],b[2]-a[2]],L=Math.hypot(dv[0],dv[1],dv[2])||1,o;
   if(Math.abs(dv[2])>0.9*L){var mx=(a[0]+b[0])/2-c[0],my=(a[1]+b[1])/2-c[1],h=Math.hypot(mx,my)||1;o=[mx/h,my/h,0];}else o=[0,0,-1];
   var q0=[a[0]+o[0]*v0*bs,a[1]+o[1]*v0*bs,a[2]+o[2]*v0*bs],q1=[b[0]+o[0]*v1*bs,b[1]+o[1]*v1*bs,b[2]+o[2]*v1*bs];
   prims.push({t:'b',p:[a,b,q1,q0],v:(v0+v1)/2});prims.push({t:'l',p:[a,b]});
   for(var t=0;t<=10;t++){var tt=t/10,vv=v0+(v1-v0)*tt,lab=D.nB+' = '+fmt(vv)+'\nbarra '+(e+1)+' (nudos '+br[0]+' a '+br[1]+'), '+Math.round(tt*100)+' %';
    samp.push({p:lerp(a,b,tt),txt:lab});samp.push({p:lerp(q0,q1,tt),txt:lab});}
  });}
 function draw(){g.clearRect(0,0,W,H);var fg=getComputedStyle(cv.parentNode).color||'#222';
  var L=prims.map(function(p){var sc=p.p.map(pr),d=0;sc.forEach(function(q){d+=q[2];});return {p:p,sc:sc,d:d/sc.length};});
  L.sort(function(a,b){return b.d-a.d;});
  L.forEach(function(o){var p=o.p,sc=o.sc,m;g.beginPath();g.moveTo(sc[0][0],sc[0][1]);for(m=1;m<sc.length;m++)g.lineTo(sc[m][0],sc[m][1]);
   if(p.t==='s'){g.closePath();var col=jet((p.v-smin)/(smax-smin));g.fillStyle=css(col,1);g.fill();g.strokeStyle=css(col,1);g.lineWidth=0.6;g.stroke();}
   else if(p.t==='b'){g.closePath();var cb=jet(bmax>0?(p.v/bmax+1)/2:0.5);g.fillStyle=css(cb,0.55);g.fill();g.strokeStyle=css(cb,0.9);g.lineWidth=1;g.stroke();}
   else{g.strokeStyle=fg;g.lineWidth=2.5;g.stroke();}});
  D.S.forEach(function(q){var sc=q.map(function(j){return pr(P[j-1]);}),m;g.beginPath();g.moveTo(sc[0][0],sc[0][1]);for(m=1;m<4;m++)g.lineTo(sc[m][0],sc[m][1]);g.closePath();g.strokeStyle='rgba(0,0,0,.35)';g.lineWidth=0.7;g.stroke();});
  var x0=W-62,y0=60,hh=H-140,m;for(m=0;m<hh;m++){g.fillStyle=css(jet(1-m/hh),1);g.fillRect(x0,y0+m,18,1);}
  g.strokeStyle=fg;g.lineWidth=1;g.strokeRect(x0,y0,18,hh);g.fillStyle=fg;g.font='12px sans-serif';g.textAlign='right';
  g.fillText(fmt(smax),x0+44,y0-6);g.fillText(fmt(smin),x0+44,y0+hh+16);g.fillText(D.nS,x0+44,y0-22);
  g.textAlign='left';g.fillText('barras: '+D.nB+'   max |valor| = '+fmt(bmax),12,H-12);
  if(hov){var q=pr(hov.p);g.beginPath();g.arc(q[0],q[1],5,0,7);g.fillStyle='#fff';g.fill();g.strokeStyle='#000';g.lineWidth=1.5;g.stroke();}}
 function pos(ev){var r=cv.getBoundingClientRect();return [(ev.clientX-r.left)*W/r.width,(ev.clientY-r.top)*H/r.height,r];}
 cv.addEventListener('pointerdown',function(ev){drag=[ev.clientX,ev.clientY,yaw,pitch];try{cv.setPointerCapture(ev.pointerId);}catch(x){}cv.style.cursor='grabbing';});
 cv.addEventListener('pointerup',function(){drag=null;cv.style.cursor='grab';});
 cv.addEventListener('pointermove',function(ev){
  if(drag){yaw=drag[2]+(ev.clientX-drag[0])*0.01;pitch=Math.max(-1.5,Math.min(1.5,drag[3]+(ev.clientY-drag[1])*0.01));tip.style.display='none';hov=null;draw();return;}
  var m=pos(ev),best=null,bd=14;samp.forEach(function(s){var q=pr(s.p),d=Math.hypot(q[0]-m[0],q[1]-m[1]);if(d<bd){bd=d;best=s;}});
  hov=best;draw();
  if(best){var r=m[2];tip.textContent=best.txt;tip.style.display='block';tip.style.left=(m[0]*r.width/W+14)+'px';tip.style.top=(m[1]*r.height/H+14)+'px';}else tip.style.display='none';});
 cv.addEventListener('pointerleave',function(){hov=null;tip.style.display='none';draw();});
 cv.addEventListener('wheel',function(ev){ev.preventDefault();zoom*=ev.deltaY<0?1.1:1/1.1;draw();},{passive:false});
 build();draw();}
function todos(){document.querySelectorAll('canvas[data-m3d]').forEach(init);}
if(document.readyState==='loading')document.addEventListener('DOMContentLoaded',todos);else todos();
})();
</script>";
    }
}
