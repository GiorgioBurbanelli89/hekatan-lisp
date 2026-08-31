using System;
using System.Collections.Generic;
using System.Globalization;
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
            return "<canvas class=\"hk-surf\" width=\"560\" height=\"420\" style=\"max-width:100%;touch-action:none;cursor:grab\""
                 + " data-id=\"" + id + "\" data-nn=\"" + nn + "\""
                 + " data-zmin=\"" + zmin.ToString("0.####", inv) + "\" data-zmax=\"" + zmax.ToString("0.####", inv) + "\""
                 + " data-z='" + sb + "'></canvas>";
        }

        // Script del ORBIT (se emite UNA vez). jet_r + proyección 3/4 + arrastre con el mouse.
        public const string OrbitScript = @"<script>
(function(){
 function jetr(t){t=1-Math.max(0,Math.min(1,t));
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
   draw();cv.style.cursor='grab';
   var drag=false,px=0,py=0;
   cv.addEventListener('pointerdown',function(e){drag=true;px=e.clientX;py=e.clientY;cv.style.cursor='grabbing';cv.setPointerCapture(e.pointerId);});
   cv.addEventListener('pointerup',function(e){drag=false;cv.style.cursor='grab';});
   cv.addEventListener('pointermove',function(e){if(!drag)return;az-=(e.clientX-px)*0.01;el+=(e.clientY-py)*0.01;
     el=Math.max(0.05,Math.min(1.5,el));px=e.clientX;py=e.clientY;draw();});
 }
 function init(){var cs=document.querySelectorAll('canvas.hk-surf');for(var i=0;i<cs.length;i++)setup(cs[i]);}
 if(document.readyState==='loading')document.addEventListener('DOMContentLoaded',init);else init();
})();
</script>";

        static SKColor JetR(double t)   // colormap jet_r (jet invertido): 0=rojo … 1=azul
        {
            t = 1 - Math.Max(0, Math.Min(1, t));
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
            var txt = new SKPaint { IsAntialias = true, Color = fg, TextSize = 10,
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
                var et = new SKPaint { IsAntialias = true, Color = lin, TextSize = 10,
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
            var ax = new SKPaint { IsAntialias = true, Color = fg, TextSize = 11 };
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

        // csi = colormap de ETABS/CSI · nlev = bandas de contorno (0 = gradiente)
        public static string MapPng(LispConverter.N f, string vx, string vy,
                                    double xa, double xb, double ya, double yb, bool dark,
                                    bool csi, int nlev)
        {
            // con bandas hace falta MAS resolucion: si no, el borde de cada banda sale
            // escalonado (en ETABS/Lab el relleno es por pixel).
            int nn = nlev > 0 ? 240 : 90;
            const int W = 560, H = 430;
            var (Z, zmin, zmax) = Sample(f, vx, vy, xa, xb, ya, yb, nn);
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
            var txt = new SKPaint { IsAntialias = true, Color = fg, TextSize = 11 };
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
    }
}
