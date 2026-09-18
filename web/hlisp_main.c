/* hlisp_main.c — arranca ECL dentro de WASM, carga el motor (compilado ANTES a C)
   y exporta hlisp_run(texto) para JavaScript. */
#include <ecl/ecl.h>
#include <emscripten.h>
#include <stdlib.h>
#include <string.h>

extern void init_hlisp(cl_object);      /* módulo del motor: engine.lisp + hlisp_web.lisp */

/* límites de la zona de datos estáticos de WASM (los define wasm-ld) */
extern char __global_base[], __data_end[];
extern void GC_add_roots(void *low, void *high_plus_1);   /* bdwgc (libeclgc.a) */

static char *g_out = NULL;

int main(int argc, char **argv) {
  /* TOPE DEL HEAP de Lisp (bdwgc). Sin tope, bdwgc prefiere AGRANDAR el heap antes que
     recolectar; en WASM, cuando la memoria ya no puede crecer, Emscripten ABORTA (no devuelve
     NULL) y el recolector nunca llega a correr: 26 formas seguidas de la hoja 34 → OOM.
     Con tope, al llegar a él bdwgc RECOLECTA. Debe quedar por debajo de INITIAL_MEMORY. */
  ecl_set_option(ECL_OPT_HEAP_SIZE, 160u * 1024u * 1024u);
  cl_boot(argc, argv);
  /* RAÍCES ESTÁTICAS. El código Lisp compilado guarda sus constantes (listas citadas, símbolos)
     en arreglos C estáticos VV[]. En Linux bdwgc escanea toda la zona de datos estáticos; en
     Emscripten NO (gcconfig.h: DATASTART = DATAEND) y ECL tampoco la registra → el recolector
     liberaba esas constantes y el motor leía memoria reutilizada: (a11 a22) en vez de 0.
     Se registra aquí, DESPUÉS de cl_boot (init_alloc hace GC_clear_roots). */
  GC_add_roots(__global_base, __data_end);
  ecl_init_module(NULL, init_hlisp);
  return 0;                              /* el runtime sigue vivo (EXIT_RUNTIME=0) */
}

/* UTF-8 (C) → string de Lisp. Se hace aquí a mano: ext:octets-to-string de ECL en WASM
   falla con más de 4096 bytes ("Memory limit reached") y las hojas largas pasan de eso. */
static cl_object utf8_a_lisp(const unsigned char *s) {
  size_t n = 0;
  for (const unsigned char *p = s; *p; p++) if ((*p & 0xC0) != 0x80) n++;   /* cuenta caracteres */
  cl_object str = ecl_alloc_simple_extended_string(n);
  size_t i = 0;
  while (*s && i < n) {
    unsigned c = *s++; int extra = 0;
    if (c >= 0xF0) { c &= 0x07; extra = 3; } else if (c >= 0xE0) { c &= 0x0F; extra = 2; }
    else if (c >= 0xC0) { c &= 0x1F; extra = 1; }
    while (extra-- > 0 && (*s & 0xC0) == 0x80) c = (c << 6) | (*s++ & 0x3F);
    ecl_char_set(str, i++, (ecl_character)c);
  }
  return str;
}

/* string de Lisp → UTF-8 en g_out (memoria de C, la lee JS). */
static const char *lisp_a_utf8(cl_object str) {
  size_t n = (size_t)ecl_length(str), k = 0;
  free(g_out);
  g_out = malloc(n * 4 + 1);
  for (size_t i = 0; i < n; i++) {
    unsigned c = (unsigned)ecl_char(str, i);
    if (c < 0x80) g_out[k++] = (char)c;
    else if (c < 0x800) { g_out[k++] = 0xC0 | (c >> 6); g_out[k++] = 0x80 | (c & 0x3F); }
    else if (c < 0x10000) { g_out[k++] = 0xE0 | (c >> 12); g_out[k++] = 0x80 | ((c >> 6) & 0x3F); g_out[k++] = 0x80 | (c & 0x3F); }
    else { g_out[k++] = 0xF0 | (c >> 18); g_out[k++] = 0x80 | ((c >> 12) & 0x3F); g_out[k++] = 0x80 | ((c >> 6) & 0x3F); g_out[k++] = 0x80 | (c & 0x3F); }
  }
  g_out[k] = 0;
  return g_out;
}

/* texto UTF-8 → Lisp → evalúa → devuelve lo impreso (UTF-8). */
EMSCRIPTEN_KEEPALIVE const char *hlisp_run(const char *code) {
  cl_env_ptr env = ecl_process_env();
  cl_object out = ECL_NIL;
  ECL_CATCH_ALL_BEGIN(env) {
    out = cl_funcall(2, ecl_make_symbol("HLISP-WEB-RUN", "CL-USER"), utf8_a_lisp((const unsigned char *)code));
  } ECL_CATCH_ALL_IF_CAUGHT {
    out = ECL_NIL;
  } ECL_CATCH_ALL_END;
  if (out == ECL_NIL) { free(g_out); g_out = strdup("; error: fallo interno del motor\n"); return g_out; }
  return lisp_a_utf8(out);
}
