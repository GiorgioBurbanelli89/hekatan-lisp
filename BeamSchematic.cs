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
    }
}
