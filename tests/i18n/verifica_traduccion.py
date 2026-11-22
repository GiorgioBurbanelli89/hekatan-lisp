# -*- coding: utf-8 -*-
"""Verifica que la hoja en inglés (ejemplos/en/…) sea la MISMA hoja que la española, solo con la prosa traducida.
Reglas (línea a línea, mismo número de líneas):
  · prosa libre: líneas «# título», «## sección», «#: párrafo» y vacías
  · cálculo (no empieza por #): idéntico salvo el comentario final « 'texto»
  · directivas (#numerico, #hide, #tabla(…), #dibujo(…), «#  linea(…)», #contourf…): idénticas salvo el texto entre comillas
Uso: python verifica_traduccion.py ES.lisp EN.lisp   |   python verifica_traduccion.py --mapa ejemplos/en/mapa.json
"""
import json, os, re, sys

def sin_comentario(l):
    cad = False
    for i, c in enumerate(l):
        if c == '"': cad = not cad
        elif not cad and c == "'" and i > 0 and l[i - 1].isspace() and i + 1 < len(l) and not l[i + 1].isspace():
            return l[:i].rstrip()
    return l.rstrip()

def sin_cadenas(l): return re.sub(r'"[^"]*"', '""', l)

def es_prosa(t): return t == '' or (t.startswith('# ') and not t.startswith('#  ')) or t == '#' or t.startswith('##') or t.startswith('#:')          # «#  linea(…)» (dos espacios) es una primitiva de #dibujo, NO prosa

def compara(es_txt, en_txt):
    a = es_txt.replace('\r', '').split('\n'); b = en_txt.replace('\r', '').split('\n')
    if len(a) != len(b): return ['distinto número de líneas: %d (es) vs %d (en)' % (len(a), len(b))]
    err = []
    for k, (x, y) in enumerate(zip(a, b), 1):
        tx, ty = x.strip(), y.strip()
        if re.match(r'^;[#|<>]', tx):          # «;## título», «;| texto», «;< …»: texto con formato (directiva «;»), prosa traducible; mismo prefijo
            if tx[:2] != ty[:2]: err.append('línea %d: cambió el prefijo de texto «;»' % k)
            continue
        if es_prosa(tx):
            if not es_prosa(ty): err.append('línea %d: era prosa y en inglés no: %r' % (k, ty[:60]))
            elif (tx.startswith('##') != ty.startswith('##')) or (tx.startswith('#:') != ty.startswith('#:')): err.append('línea %d: cambió el tipo de prosa' % k)
            continue
        if tx.startswith('#'):
            if sin_cadenas(sin_comentario(x)).strip() != sin_cadenas(sin_comentario(y)).strip(): err.append('línea %d: directiva distinta:\n   es: %s\n   en: %s' % (k, x.strip()[:110], y.strip()[:110]))
            continue
        if sin_cadenas(sin_comentario(x)).strip() != sin_cadenas(sin_comentario(y)).strip(): err.append('línea %d: cálculo distinto:\n   es: %s\n   en: %s' % (k, x.strip()[:110], y.strip()[:110]))
    return err

if __name__ == '__main__':
    if sys.argv[1] == '--mapa':
        mp = sys.argv[2]; base = os.path.dirname(os.path.dirname(os.path.abspath(mp))); m = json.load(open(mp, encoding='utf-8')); mal = 0
        for es, en in m.items():
            e = compara(open(os.path.join(base, es), encoding='utf-8').read(), open(os.path.join(base, 'en', en), encoding='utf-8').read())
            if e: mal += 1; print('✗', es, '\n  ' + '\n  '.join(e[:4]))
        print('hojas: %d, con problemas: %d' % (len(m), mal)); sys.exit(1 if mal else 0)
    e = compara(open(sys.argv[1], encoding='utf-8').read(), open(sys.argv[2], encoding='utf-8').read())
    print('OK' if not e else '\n'.join(e[:20])); sys.exit(1 if e else 0)
