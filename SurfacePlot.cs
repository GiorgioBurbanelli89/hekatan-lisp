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
    }
}
