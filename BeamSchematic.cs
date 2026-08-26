using System;
using System.Globalization;
using SkiaSharp;

namespace HekatanLisp
{
    // Esquema de una VIGA sin deformar: la barra, sus apoyos y sus cargas. SkiaSharp → PNG.
    // Sintaxis:  #beam(apoyoIzq-apoyoDer, carga, carga, ...)
    //   apoyos: fixed (empotrado) · pin (articulado) · roller (rodillo) · free (libre)
    //   cargas: P@pos (puntual hacia abajo en la fracción pos∈[0,1]) · q (repartida) · M@pos (momento)
    static class BeamSchematic
    {
        public static string BeamPng(string spec, bool dark)
        {
            const int W = 560, H = 190;
            var bg = dark ? new SKColor(0x14, 0x16, 0x1a) : new SKColor(0xFB, 0xF7, 0xEC);
            var fg = dark ? new SKColor(0xC8, 0xCC, 0xD0) : new SKColor(0x33, 0x33, 0x33);
            var acc = dark ? new SKColor(0xE8, 0x82, 0x5A) : new SKColor(0xD8, 0x5A, 0x30);
            var info = new SKImageInfo(W, H);
            using var surf = SKSurface.Create(info);
            var cv = surf.Canvas; cv.Clear(bg);
            var beam = new SKPaint { Color = fg, IsAntialias = true, Style = SKPaintStyle.Stroke, StrokeWidth = 4 };
            var thin = new SKPaint { Color = fg, IsAntialias = true, Style = SKPaintStyle.Stroke, StrokeWidth = 1.6f };
            var lpen = new SKPaint { Color = acc, IsAntialias = true, Style = SKPaintStyle.Stroke, StrokeWidth = 2.2f };
            var lfill = new SKPaint { Color = acc, IsAntialias = true, Style = SKPaintStyle.Fill };
            var tfg = new SKPaint { Color = fg, IsAntialias = true, TextSize = 15 };
            var tac = new SKPaint { Color = acc, IsAntialias = true, TextSize = 16, FakeBoldText = true };

            float bx0 = 80, bx1 = W - 55, by = H * 0.55f;
            var parts = (spec ?? "").Split(',');
            var sup = (parts.Length > 0 ? parts[0] : "fixed-free").Trim().ToLowerInvariant().Split('-');
            string sL = sup.Length > 0 ? sup[0].Trim() : "free";
            string sR = sup.Length > 1 ? sup[1].Trim() : "free";

            cv.DrawLine(bx0, by, bx1, by, beam);            // la viga
            Support(cv, sL, bx0, by, true, thin);
            Support(cv, sR, bx1, by, false, thin);
            for (int i = 1; i < parts.Length; i++)
            {
                var t = parts[i].Trim(); if (t.Length == 0) continue;
                char c = char.ToLowerInvariant(t[0]);
                if (c == 'q' || c == 'w') Uniform(cv, bx0, bx1, by, lpen, lfill, tac, t);
                else if (c == 'm') Moment(cv, bx0, bx1, by, lpen, tac, t);
                else Point(cv, bx0, bx1, by, t, lpen, lfill, tac);
            }
            using var img = surf.Snapshot();
            using var data = img.Encode(SKEncodedImageFormat.Png, 92);
            return Convert.ToBase64String(data.ToArray());
        }

        static float Pos(string t)   // fracción tras '@' (default 1.0 = extremo derecho)
        {
            int at = t.IndexOf('@');
            if (at < 0) return 1f;
            return float.TryParse(t.Substring(at + 1), NumberStyles.Any, CultureInfo.InvariantCulture, out var p)
                ? Math.Max(0f, Math.Min(1f, p)) : 1f;
        }
        static string Label(string t) { int at = t.IndexOf('@'); return (at < 0 ? t : t.Substring(0, at)).Trim(); }

        static void Support(SKCanvas cv, string kind, float x, float by, bool left, SKPaint p)
        {
            switch (kind)
            {
                case "fixed":   // empotrado: muro con rayado en el lado exterior
                    cv.DrawLine(x, by - 26, x, by + 26, p);
                    for (float y = by - 24; y <= by + 24; y += 9)
                        cv.DrawLine(x, y, x + (left ? -12 : 12), y + 9, p);
                    break;
                case "pin":     // articulado: triángulo + suelo rayado
                    using (var tri = new SKPath())
                    {
                        tri.MoveTo(x, by); tri.LineTo(x - 13, by + 22); tri.LineTo(x + 13, by + 22); tri.Close();
                        cv.DrawPath(tri, p);
                    }
                    cv.DrawLine(x - 18, by + 22, x + 18, by + 22, p);
                    for (float xx = x - 16; xx <= x + 14; xx += 8) cv.DrawLine(xx, by + 22, xx - 7, by + 30, p);
                    break;
                case "roller":  // rodillo: triángulo + círculos
                    using (var tri = new SKPath())
                    {
                        tri.MoveTo(x, by); tri.LineTo(x - 13, by + 18); tri.LineTo(x + 13, by + 18); tri.Close();
                        cv.DrawPath(tri, p);
                    }
                    cv.DrawCircle(x - 7, by + 23, 4, p); cv.DrawCircle(x + 7, by + 23, 4, p);
                    cv.DrawLine(x - 18, by + 28, x + 18, by + 28, p);
                    break;
                // free: nada
            }
        }

        static void Arrow(SKCanvas cv, float x, float y0, float y1, SKPaint pen, SKPaint fill)
        {
            cv.DrawLine(x, y0, x, y1, pen);          // vertical, y1 = punta (abajo)
            using var head = new SKPath();
            head.MoveTo(x, y1); head.LineTo(x - 5, y1 - 10); head.LineTo(x + 5, y1 - 10); head.Close();
            cv.DrawPath(head, fill);
        }

        static void Point(SKCanvas cv, float bx0, float bx1, float by, string t, SKPaint pen, SKPaint fill, SKPaint txt)
        {
            float x = bx0 + Pos(t) * (bx1 - bx0);
            Arrow(cv, x, by - 48, by - 3, pen, fill);
            cv.DrawText(Label(t), x - 5, by - 54, txt);
        }

        static void Uniform(SKCanvas cv, float bx0, float bx1, float by, SKPaint pen, SKPaint fill, SKPaint txt, string t)
        {
            float top = by - 40;
            cv.DrawLine(bx0, top, bx1, top, pen);
            for (float x = bx0; x <= bx1 + 0.1f; x += (bx1 - bx0) / 8f) Arrow(cv, x, top, by - 3, pen, fill);
            cv.DrawText(Label(t), (bx0 + bx1) / 2 - 6, top - 8, txt);
        }

        static void Moment(SKCanvas cv, float bx0, float bx1, float by, SKPaint pen, SKPaint txt, string t)
        {
            float x = bx0 + Pos(t) * (bx1 - bx0);
            using var arc = new SKPath();
            arc.AddArc(new SKRect(x - 20, by - 20, x + 20, by + 20), 40, 260);
            cv.DrawPath(arc, pen);
            cv.DrawText(Label(t), x + 22, by - 14, txt);
        }

        // ---------- PÓRTICO plano: 2 columnas + viga ----------
        public static string FramePng(string spec, bool dark)
        {
            const int W = 520, H = 320;
            var bg = dark ? new SKColor(0x14, 0x16, 0x1a) : new SKColor(0xFB, 0xF7, 0xEC);
            var fg = dark ? new SKColor(0xC8, 0xCC, 0xD0) : new SKColor(0x33, 0x33, 0x33);
            var acc = dark ? new SKColor(0xE8, 0x82, 0x5A) : new SKColor(0xD8, 0x5A, 0x30);
            var info = new SKImageInfo(W, H);
            using var surf = SKSurface.Create(info);
            var cv = surf.Canvas; cv.Clear(bg);
            var mem = new SKPaint { Color = fg, IsAntialias = true, Style = SKPaintStyle.Stroke, StrokeWidth = 4 };
            var thin = new SKPaint { Color = fg, IsAntialias = true, Style = SKPaintStyle.Stroke, StrokeWidth = 1.6f };
            var lpen = new SKPaint { Color = acc, IsAntialias = true, Style = SKPaintStyle.Stroke, StrokeWidth = 2.2f };
            var lfill = new SKPaint { Color = acc, IsAntialias = true, Style = SKPaintStyle.Fill };
            var tac = new SKPaint { Color = acc, IsAntialias = true, TextSize = 16, FakeBoldText = true };

            var parts = (spec ?? "").Split(',');
            var sup = (parts.Length > 0 ? parts[0] : "fixed-fixed").Trim().ToLowerInvariant().Split('-');
            string sL = sup.Length > 0 ? sup[0].Trim() : "fixed";
            string sR = sup.Length > 1 ? sup[1].Trim() : "fixed";

            float cxL = 110, cxR = W - 110, yTop = 70, yBase = H - 70;
            // pórtico: columna izq, viga, columna der
            cv.DrawLine(cxL, yBase, cxL, yTop, mem);
            cv.DrawLine(cxR, yBase, cxR, yTop, mem);
            cv.DrawLine(cxL, yTop, cxR, yTop, mem);
            Ground(cv, sL, cxL, yBase, thin);
            Ground(cv, sR, cxR, yBase, thin);
            // COTAS: luz L (abajo) y altura h (derecha), + nudos B, C — para leer la geometría
            var dim = new SKPaint { Color = fg, IsAntialias = true, Style = SKPaintStyle.Stroke, StrokeWidth = 1.1f };
            var tcen = new SKPaint { Color = fg, IsAntialias = true, TextSize = 15, TextAlign = SKTextAlign.Center };
            var tlft = new SKPaint { Color = fg, IsAntialias = true, TextSize = 15, TextAlign = SKTextAlign.Left };
            var tjt = new SKPaint { Color = fg, IsAntialias = true, TextSize = 14, FakeBoldText = true };
            float yL = yBase + 40;
            cv.DrawLine(cxL, yBase + 18, cxL, yL, dim);
            cv.DrawLine(cxR, yBase + 18, cxR, yL, dim);
            cv.DrawLine(cxL, yL, cxR, yL, dim);
            cv.DrawLine(cxL, yL - 4, cxL, yL + 4, dim);
            cv.DrawLine(cxR, yL - 4, cxR, yL + 4, dim);
            cv.DrawText("L", (cxL + cxR) / 2, yL - 5, tcen);
            float xh = cxR + 40;
            cv.DrawLine(cxR + 6, yTop, xh, yTop, dim);
            cv.DrawLine(cxR + 6, yBase, xh, yBase, dim);
            cv.DrawLine(xh, yTop, xh, yBase, dim);
            cv.DrawLine(xh - 4, yTop, xh + 4, yTop, dim);
            cv.DrawLine(xh - 4, yBase, xh + 4, yBase, dim);
            cv.DrawText("h", xh + 6, (yTop + yBase) / 2 + 5, tlft);
            cv.DrawText("B", cxL + 8, yTop - 9, tjt);
            cv.DrawText("C", cxR - 20, yTop - 9, tjt);
            // cargas
            for (int i = 1; i < parts.Length; i++)
            {
                var t = parts[i].Trim(); if (t.Length == 0) continue;
                char c = char.ToLowerInvariant(t[0]);
                if (c == 'h')   // carga lateral H → flecha horizontal en la esquina sup izq
                {
                    cv.DrawLine(cxL - 48, yTop, cxL - 4, yTop, lpen);
                    using var head = new SKPath();
                    head.MoveTo(cxL - 4, yTop); head.LineTo(cxL - 14, yTop - 5); head.LineTo(cxL - 14, yTop + 5); head.Close();
                    cv.DrawPath(head, lfill);
                    cv.DrawText(Label(t), cxL - 66, yTop + 5, tac);
                }
                else if (c == 'q' || c == 'w') Uniform(cv, cxL, cxR, yTop, lpen, lfill, tac, t);
                else Point(cv, cxL, cxR, yTop, t, lpen, lfill, tac);
            }
            using var img = surf.Snapshot();
            using var data = img.Encode(SKEncodedImageFormat.Png, 92);
            return Convert.ToBase64String(data.ToArray());
        }

        // PÓRTICO DEFORMADO: columnas y viga curvadas (Hermite) con el ladeo Δ y los giros θ, amplificado.
        public static string FrameDeformedPng(double dx, double tB, double tC, bool dark)
        {
            const int W = 520, H = 320;
            var bg = dark ? new SKColor(0x14, 0x16, 0x1a) : new SKColor(0xFB, 0xF7, 0xEC);
            var fg = dark ? new SKColor(0xC8, 0xCC, 0xD0) : new SKColor(0x33, 0x33, 0x33);
            var acc = dark ? new SKColor(0x37, 0x8A, 0xDD) : new SKColor(0x18, 0x5F, 0xA5);
            var info = new SKImageInfo(W, H);
            using var surf = SKSurface.Create(info);
            var cv = surf.Canvas; cv.Clear(bg);
            var thin = new SKPaint { Color = fg, IsAntialias = true, Style = SKPaintStyle.Stroke, StrokeWidth = 1.6f };
            var dash = new SKPaint { Color = fg, IsAntialias = true, Style = SKPaintStyle.Stroke, StrokeWidth = 1.5f, PathEffect = SKPathEffect.CreateDash(new float[] { 5, 4 }, 0) };
            var def = new SKPaint { Color = acc, IsAntialias = true, Style = SKPaintStyle.Stroke, StrokeWidth = 3.5f };
            var tf = new SKPaint { Color = fg, IsAntialias = true, TextSize = 13 };

            float cxL = 120, cxR = W - 120, yTop = 75, yBase = H - 65;
            float hpx = yBase - yTop, Lpx = cxR - cxL;
            double amp = 45.0 / Math.Max(Math.Abs(dx), 1e-6);
            double H3(double s) => 3 * s * s - 2 * s * s * s;
            double H4(double s) => -s * s + s * s * s;
            double H2(double s) => s - 2 * s * s + s * s * s;

            // pórtico SIN deformar (punteado)
            cv.DrawLine(cxL, yBase, cxL, yTop, dash); cv.DrawLine(cxR, yBase, cxR, yTop, dash); cv.DrawLine(cxL, yTop, cxR, yTop, dash);
            // columnas deformadas
            SKPath Col(float cx, double t) { var p = new SKPath(); for (int i = 0; i <= 30; i++) { double s = i / 30.0; double lat = dx * H3(s) + t * H4(s); float px = (float)(cx + amp * lat); float py = (float)(yBase - s * hpx); if (i == 0) p.MoveTo(px, py); else p.LineTo(px, py); } return p; }
            using (var p = Col(cxL, tB)) cv.DrawPath(p, def);
            using (var p = Col(cxR, tC)) cv.DrawPath(p, def);
            // viga deformada (trasladada por el ladeo + flexión por los giros)
            float bx0 = (float)(cxL + amp * dx), bx1 = (float)(cxR + amp * dx);
            using (var p = new SKPath())
            {
                for (int i = 0; i <= 30; i++) { double t = i / 30.0; double w = tB * H2(t) + tC * H4(t); float px = (float)(bx0 + t * Lpx); float py = (float)(yTop + amp * w); if (i == 0) p.MoveTo(px, py); else p.LineTo(px, py); }
                cv.DrawPath(p, def);
            }
            Ground(cv, "fixed", cxL, yBase, thin); Ground(cv, "fixed", cxR, yBase, thin);
            cv.DrawText("- - -  sin deformar   —  deformada (amplificada ×" + Math.Round(amp) + ")", 20, H - 14, tf);
            using var img = surf.Snapshot();
            using var data = img.Encode(SKEncodedImageFormat.Png, 92);
            return Convert.ToBase64String(data.ToArray());
        }

        static void Ground(SKCanvas cv, string kind, float x, float y, SKPaint p)   // apoyo en la base (suelo abajo)
        {
            switch (kind)
            {
                case "fixed":
                    cv.DrawLine(x - 26, y, x + 26, y, p);
                    for (float xx = x - 24; xx <= x + 22; xx += 9) cv.DrawLine(xx, y, xx + 9, y + 10, p);
                    break;
                case "pin":
                    using (var tri = new SKPath())
                    { tri.MoveTo(x, y); tri.LineTo(x - 13, y + 22); tri.LineTo(x + 13, y + 22); tri.Close(); cv.DrawPath(tri, p); }
                    cv.DrawLine(x - 20, y + 22, x + 20, y + 22, p);
                    for (float xx = x - 16; xx <= x + 16; xx += 8) cv.DrawLine(xx, y + 22, xx - 7, y + 30, p);
                    break;
                case "roller":
                    using (var tri = new SKPath())
                    { tri.MoveTo(x, y); tri.LineTo(x - 13, y + 18); tri.LineTo(x + 13, y + 18); tri.Close(); cv.DrawPath(tri, p); }
                    cv.DrawCircle(x - 7, y + 23, 4, p); cv.DrawCircle(x + 7, y + 23, 4, p);
                    cv.DrawLine(x - 20, y + 28, x + 20, y + 28, p);
                    break;
            }
        }

        // ---- Trocito diferencial de viga: el EQUILIBRIO de donde salen dM/dx=V y dV/dx=-q ----
        // Sintaxis:  #slice   (sin argumentos)
        public static string SlicePng(bool dark)
        {
            const int W = 640, H = 300;
            var bg  = dark ? new SKColor(0x14, 0x16, 0x1a) : new SKColor(0xFB, 0xF7, 0xEC);
            var fg  = dark ? new SKColor(0xC8, 0xCC, 0xD0) : new SKColor(0x33, 0x33, 0x33);
            var acc = dark ? new SKColor(0xE8, 0x82, 0x5A) : new SKColor(0xD8, 0x5A, 0x30);  // carga q (externa)
            var blu = dark ? new SKColor(0x6E, 0xA8, 0xE8) : new SKColor(0x2B, 0x66, 0xC4);  // fuerzas internas V, M
            var faint = dark ? new SKColor(0x22, 0x26, 0x2c) : new SKColor(0xEC, 0xE4, 0xD2);
            using var surf = SKSurface.Create(new SKImageInfo(W, H));
            var cv = surf.Canvas; cv.Clear(bg);

            var body  = new SKPaint { Color = fg,  IsAntialias = true, Style = SKPaintStyle.Stroke, StrokeWidth = 3 };
            var fill  = new SKPaint { Color = faint, IsAntialias = true, Style = SKPaintStyle.Fill };
            var qpen  = new SKPaint { Color = acc, IsAntialias = true, Style = SKPaintStyle.Stroke, StrokeWidth = 2 };
            var qfill = new SKPaint { Color = acc, IsAntialias = true, Style = SKPaintStyle.Fill };
            var fpen  = new SKPaint { Color = blu, IsAntialias = true, Style = SKPaintStyle.Stroke, StrokeWidth = 2.6f };
            var ffill = new SKPaint { Color = blu, IsAntialias = true, Style = SKPaintStyle.Fill };
            var dim   = new SKPaint { Color = fg,  IsAntialias = true, Style = SKPaintStyle.Stroke, StrokeWidth = 1.2f };
            var tfg   = new SKPaint { Color = fg,  IsAntialias = true, TextSize = 15 };
            var tblu  = new SKPaint { Color = blu, IsAntialias = true, TextSize = 16, FakeBoldText = true };
            var tacc  = new SKPaint { Color = acc, IsAntialias = true, TextSize = 16, FakeBoldText = true };

            float x0 = 245, x1 = 400, yT = 120, yB = 205, cy = (yT + yB) / 2;

            // el trocito
            cv.DrawRect(new SKRect(x0, yT, x1, yB), fill);
            cv.DrawRect(new SKRect(x0, yT, x1, yB), body);

            // carga repartida q: flechas hacia abajo sobre el techo
            float qy = yT - 36;
            cv.DrawLine(x0, qy, x1, qy, qpen);
            for (float x = x0; x <= x1 + 0.1f; x += (x1 - x0) / 6f) ArrowV(cv, x, qy, yT - 3, qpen, qfill);
            cv.DrawText("q", (x0 + x1) / 2 - 4, qy - 8, tacc);

            // cara IZQUIERDA: cortante V (arriba) y momento M
            ArrowV(cv, x0, yB + 20, yT + 18, fpen, ffill);
            cv.DrawText("V", x0 - 34, cy + 4, tblu);
            MomentArc(cv, x0, cy, 17, true, fpen, ffill);
            cv.DrawText("M", x0 - 40, cy - 26, tblu);

            // cara DERECHA: cortante V+dV (abajo) y momento M+dM
            ArrowV(cv, x1, yT + 18, yB + 20, fpen, ffill);
            cv.DrawText("V + dV", x1 + 24, cy + 4, tblu);
            MomentArc(cv, x1, cy, 17, false, fpen, ffill);
            cv.DrawText("M + dM", x1 + 12, cy - 26, tblu);

            // cota dx
            float dy = yB + 40;
            cv.DrawLine(x0, dy - 6, x0, dy + 6, dim);
            cv.DrawLine(x1, dy - 6, x1, dy + 6, dim);
            cv.DrawLine(x0, dy, x1, dy, dim);
            cv.DrawText("dx", (x0 + x1) / 2 - 9, dy - 8, tfg);

            // eje x
            cv.DrawLine(70, cy, 165, cy, dim);
            ArrowH(cv, 165, cy, dim, new SKPaint { Color = fg, IsAntialias = true, Style = SKPaintStyle.Fill });
            cv.DrawText("x", 168, cy + 5, tfg);

            using var img = surf.Snapshot();
            using var data = img.Encode(SKEncodedImageFormat.Png, 92);
            return Convert.ToBase64String(data.ToArray());
        }

        // flecha vertical: línea de y0 a y1, punta en y1 (en el sentido del recorrido)
        static void ArrowV(SKCanvas cv, float x, float y0, float y1, SKPaint pen, SKPaint fill)
        {
            cv.DrawLine(x, y0, x, y1, pen);
            float d = y1 > y0 ? 1 : -1;
            using var h = new SKPath();
            h.MoveTo(x, y1); h.LineTo(x - 5, y1 - d * 11); h.LineTo(x + 5, y1 - d * 11); h.Close();
            cv.DrawPath(h, fill);
        }

        // flecha horizontal hacia la derecha, punta en (x,y)
        static void ArrowH(SKCanvas cv, float x, float y, SKPaint pen, SKPaint fill)
        {
            using var h = new SKPath();
            h.MoveTo(x, y); h.LineTo(x - 10, y - 4); h.LineTo(x - 10, y + 4); h.Close();
            cv.DrawPath(h, fill);
        }

        // arco de momento (~270°) con punta; ccw=true gira antihorario
        static void MomentArc(SKCanvas cv, float cx, float cy, float r, bool ccw, SKPaint pen, SKPaint fill)
        {
            var rect = new SKRect(cx - r, cy - r, cx + r, cy + r);
            float start = ccw ? 45 : 135;
            float sweep = ccw ? 270 : -270;
            using (var p = new SKPath()) { p.AddArc(rect, start, sweep); cv.DrawPath(p, pen); }
            double a = (start + sweep) * Math.PI / 180.0;
            float ex = cx + r * (float)Math.Cos(a), ey = cy + r * (float)Math.Sin(a);
            // tangente en el extremo (sentido del giro)
            float s = ccw ? 1 : -1;
            float tx = -(float)Math.Sin(a) * s, ty = (float)Math.Cos(a) * s;
            using var h = new SKPath();
            h.MoveTo(ex, ey);
            h.LineTo(ex - tx * 11 - ty * 5, ey - ty * 11 + tx * 5);
            h.LineTo(ex - tx * 11 + ty * 5, ey - ty * 11 - tx * 5);
            h.Close();
            cv.DrawPath(h, fill);
        }

        // ---- Qué es v: la DEFLEXIÓN (cuánto baja el eje de la viga en cada x) ----
        // Sintaxis:  #defl   (sin argumentos)
        public static string DeflPng(bool dark)
        {
            const int W = 620, H = 250;
            var bg  = dark ? new SKColor(0x14, 0x16, 0x1a) : new SKColor(0xFB, 0xF7, 0xEC);
            var fg  = dark ? new SKColor(0xC8, 0xCC, 0xD0) : new SKColor(0x33, 0x33, 0x33);
            var blu = dark ? new SKColor(0x6E, 0xA8, 0xE8) : new SKColor(0x2B, 0x66, 0xC4);  // la deformada v
            var gray = dark ? new SKColor(0x6A, 0x6E, 0x74) : new SKColor(0x9A, 0x8F, 0x7C);
            using var surf = SKSurface.Create(new SKImageInfo(W, H));
            var cv = surf.Canvas; cv.Clear(bg);

            var axis = new SKPaint { Color = gray, IsAntialias = true, Style = SKPaintStyle.Stroke, StrokeWidth = 1.6f, PathEffect = SKPathEffect.CreateDash(new float[] { 7, 5 }, 0) };
            var sup  = new SKPaint { Color = fg, IsAntialias = true, Style = SKPaintStyle.Stroke, StrokeWidth = 1.8f };
            var curve= new SKPaint { Color = blu, IsAntialias = true, Style = SKPaintStyle.Stroke, StrokeWidth = 3.2f };
            var vpen = new SKPaint { Color = blu, IsAntialias = true, Style = SKPaintStyle.Stroke, StrokeWidth = 1.8f };
            var vfill= new SKPaint { Color = blu, IsAntialias = true, Style = SKPaintStyle.Fill };
            var dim  = new SKPaint { Color = fg, IsAntialias = true, Style = SKPaintStyle.Stroke, StrokeWidth = 1.2f };
            var tfg  = new SKPaint { Color = fg, IsAntialias = true, TextSize = 15 };
            var tblu = new SKPaint { Color = blu, IsAntialias = true, TextSize = 17, FakeBoldText = true };
            var tgr  = new SKPaint { Color = gray, IsAntialias = true, TextSize = 14 };

            float x0 = 70, x1 = W - 60, y0 = 80, amp = 62;
            // eje sin deformar (línea de puntos) + apoyos
            cv.DrawLine(x0, y0, x1, y0, axis);
            Support(cv, "pin", x0, y0, true, sup);
            Support(cv, "roller", x1, y0, false, sup);

            // la deformada v(x): forma de viga simplemente apoyada (seno), hacia ABAJO
            using (var p = new SKPath())
            {
                p.MoveTo(x0, y0);
                for (float t = 0; t <= 1.0001f; t += 0.02f)
                {
                    float x = x0 + t * (x1 - x0);
                    float y = y0 + amp * (float)Math.Sin(Math.PI * t);
                    p.LineTo(x, y);
                }
                cv.DrawPath(p, curve);
            }
            cv.DrawText("deformada v(x)", x1 - 150, y0 + amp + 26, tblu);

            // en un x concreto, la flecha vertical = v (cuánto bajó el eje)
            float tx = 0.32f;
            float xx = x0 + tx * (x1 - x0);
            float yy = y0 + amp * (float)Math.Sin(Math.PI * tx);
            cv.DrawLine(xx, y0, xx, yy, vpen);                 // del eje a la curva
            var hh = new SKPath(); hh.MoveTo(xx, yy); hh.LineTo(xx - 4, yy - 10); hh.LineTo(xx + 4, yy - 10); hh.Close(); cv.DrawPath(hh, vfill);
            cv.DrawText("v", xx + 7, (y0 + yy) / 2 + 5, tblu);
            // marca de x
            cv.DrawLine(xx, y0, xx, y0 - 4, dim);
            cv.DrawText("x", xx - 4, y0 - 8, tgr);

            // eje x hacia la derecha (abajo)
            float yx = H - 22;
            cv.DrawLine(x0, yx, x1 - 20, yx, dim);
            ArrowH(cv, x1 - 20, yx, dim, new SKPaint { Color = fg, IsAntialias = true, Style = SKPaintStyle.Fill });
            cv.DrawText("x", x1 - 16, yx + 5, tfg);

            using var img = surf.Snapshot();
            using var data = img.Encode(SKEncodedImageFormat.Png, 92);
            return Convert.ToBase64String(data.ToArray());
        }

        // ---- La viga (voladizo con carga P) y, debajo, sus diagramas alineados ----
        // Sintaxis: #diag  (los 4)  ·  #diag(carga|cortante|momento|deflexion)  (uno, con su viga)
        public static string BeamDiagramsPng(bool dark, string which)
        {
            which = (which ?? "all").Trim().ToLowerInvariant();
            var panels = new System.Collections.Generic.List<string>();
            if (which is "q" or "carga") panels.Add("q");
            else if (which is "cortante" or "cortante v") panels.Add("cortante");
            else if (which is "m" or "momento") panels.Add("momento");
            else if (which is "v" or "deflexion" or "deflexión" or "elastica" or "elástica") panels.Add("deflexion");
            else panels.AddRange(new[] { "q", "cortante", "momento", "deflexion" });

            const int W = 660;
            float x0 = 170, x1 = W - 55;
            float yBeam = 70, yFirst = 195, dy = 118;
            int H = (int)(yFirst + panels.Count * dy + 15);

            var bg   = dark ? new SKColor(0x14, 0x16, 0x1a) : new SKColor(0xFB, 0xF7, 0xEC);
            var fg   = dark ? new SKColor(0xC8, 0xCC, 0xD0) : new SKColor(0x33, 0x33, 0x33);
            var acc  = dark ? new SKColor(0xE8, 0x82, 0x5A) : new SKColor(0xD8, 0x5A, 0x30);
            var blu  = dark ? new SKColor(0x6E, 0xA8, 0xE8) : new SKColor(0x2B, 0x66, 0xC4);
            var fillc = dark ? new SKColor(0x6E, 0xA8, 0xE8, 0x40) : new SKColor(0x2B, 0x66, 0xC4, 0x33);
            using var surf = SKSurface.Create(new SKImageInfo(W, H));
            var cv = surf.Canvas; cv.Clear(bg);

            var beam = new SKPaint { Color = fg, IsAntialias = true, Style = SKPaintStyle.Stroke, StrokeWidth = 4 };
            var thin = new SKPaint { Color = fg, IsAntialias = true, Style = SKPaintStyle.Stroke, StrokeWidth = 1.6f };
            var curve = new SKPaint { Color = blu, IsAntialias = true, Style = SKPaintStyle.Stroke, StrokeWidth = 2.6f };
            var fillp = new SKPaint { Color = fillc, IsAntialias = true, Style = SKPaintStyle.Fill };
            var lpen = new SKPaint { Color = acc, IsAntialias = true, Style = SKPaintStyle.Stroke, StrokeWidth = 2.2f };
            var lfill = new SKPaint { Color = acc, IsAntialias = true, Style = SKPaintStyle.Fill };
            var baseln = new SKPaint { Color = fg, IsAntialias = true, Style = SKPaintStyle.Stroke, StrokeWidth = 1.2f };
            var guide = new SKPaint { Color = fg, IsAntialias = true, Style = SKPaintStyle.Stroke, StrokeWidth = 1f, PathEffect = SKPathEffect.CreateDash(new float[] { 5, 5 }, 0) };
            var tlab = new SKPaint { Color = fg, IsAntialias = true, TextSize = 15, FakeBoldText = true };
            var tsub = new SKPaint { Color = fg, IsAntialias = true, TextSize = 13 };
            var tblu = new SKPaint { Color = blu, IsAntialias = true, TextSize = 15, FakeBoldText = true };
            var tacc = new SKPaint { Color = acc, IsAntialias = true, TextSize = 16, FakeBoldText = true };

            // guías verticales (los dos nudos), para ver que todo alinea con la viga
            cv.DrawLine(x0, 45, x0, H - 25, guide);
            cv.DrawLine(x1, 45, x1, H - 25, guide);

            // LA VIGA (voladizo empotrado izq, carga P en la punta) — siempre arriba
            cv.DrawText("viga (voladizo)", 8, yBeam - 22, tlab);
            for (float yy = yBeam - 24; yy <= yBeam + 24; yy += 8) cv.DrawLine(x0, yy, x0 - 10, yy + 8, thin);
            cv.DrawLine(x0, yBeam - 26, x0, yBeam + 26, thin);
            cv.DrawLine(x0, yBeam, x1, yBeam, beam);
            cv.DrawLine(x1, yBeam - 46, x1, yBeam - 4, lpen);
            using (var h = new SKPath()) { h.MoveTo(x1, yBeam - 4); h.LineTo(x1 - 5, yBeam - 15); h.LineTo(x1 + 5, yBeam - 15); h.Close(); cv.DrawPath(h, lfill); }
            cv.DrawText("P", x1 + 6, yBeam - 30, tacc);
            cv.DrawText("L", (x0 + x1) / 2 - 4, 40, tsub);

            // cada panel pedido, debajo, alineado
            for (int i = 0; i < panels.Count; i++)
            {
                float yb = yFirst + i * dy;
                cv.DrawLine(x0, yb, x1, yb, baseln);   // línea base (cero)
                string t = panels[i];
                if (t == "q")
                {
                    cv.DrawText("q = 0", 8, yb + 4, tblu); cv.DrawText("(sin carga)", 8, yb + 22, tsub);
                    using var p = new SKPaint { Color = blu, IsAntialias = true, Style = SKPaintStyle.Stroke, StrokeWidth = 3 };
                    cv.DrawLine(x0, yb, x1, yb, p);
                }
                else if (t == "cortante")
                {
                    cv.DrawText("V", 8, yb + 4, tblu); cv.DrawText("(constante)", 8, yb + 22, tsub);
                    float top = yb - 42;
                    using (var rect = new SKPath()) { rect.MoveTo(x0, yb); rect.LineTo(x0, top); rect.LineTo(x1, top); rect.LineTo(x1, yb); rect.Close(); cv.DrawPath(rect, fillp); }
                    cv.DrawLine(x0, top, x1, top, curve); cv.DrawLine(x0, yb, x0, top, curve);
                }
                else if (t == "momento")
                {
                    cv.DrawText("M", 8, yb + 4, tblu); cv.DrawText("(recta)", 8, yb + 22, tsub);
                    float bot = yb + 44;
                    using (var tri = new SKPath()) { tri.MoveTo(x0, yb); tri.LineTo(x0, bot); tri.LineTo(x1, yb); tri.Close(); cv.DrawPath(tri, fillp); }
                    cv.DrawLine(x0, bot, x1, yb, curve);
                }
                else // deflexion
                {
                    cv.DrawText("v", 8, yb + 4, tblu); cv.DrawText("(cúbica)", 8, yb + 22, tsub);
                    using var p = new SKPath();
                    p.MoveTo(x0, yb);
                    for (float tt = 0; tt <= 1.0001f; tt += 0.02f)
                    {
                        float xx = x0 + tt * (x1 - x0);
                        float sh = (3 * tt * tt - tt * tt * tt) / 2f;
                        p.LineTo(xx, yb + 48 * sh);
                    }
                    cv.DrawPath(p, curve);
                }
            }
            cv.DrawText("x", x1 + 6, yFirst + (panels.Count - 1) * dy + 4, tsub);

            using var img = surf.Snapshot();
            using var data = img.Encode(SKEncodedImageFormat.Png, 92);
            return Convert.ToBase64String(data.ToArray());
        }
    }
}
