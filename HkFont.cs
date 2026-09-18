using SkiaSharp;

namespace HekatanLisp
{
    /// <summary>
    /// Fuente de los textos de las gráficas (SkiaSharp).
    /// Escritorio: null = la fuente por defecto de Skia en Windows (Segoe UI), como siempre.
    /// Web (WASM): Skia no tiene fuentes del sistema y los textos saldrían vacíos; se usa
    /// hekatan-plot.ttf = Open Sans (OFL) + → ₓ de DejaVu Sans: cubre lo mismo que Segoe UI
    /// en las gráficas (griego, ×, ·, −, √, ∫, ∂…). Selawik se probó y NO trae griego (ξ).
    /// </summary>
    public static class HkFont
    {
#if HEKATAN_WEB
        private static SKTypeface _ui;
        public static SKTypeface Ui => _ui ??= SKTypeface.FromStream(
            typeof(HkFont).Assembly.GetManifestResourceStream("hekatan-plot.ttf"));
#else
        public static SKTypeface Ui => null;
#endif
    }
}
