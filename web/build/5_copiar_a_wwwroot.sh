# Copia a la web lo que se genera fuera de ella (correr desde hekatan-lisp/, en Git Bash):
#   motor compilado (WSL ~/lispwasm/hl) + engine.lisp (menú Motor) + ejemplos.
set -e
W=web/HekatanLispWeb/wwwroot
wsl -d Ubuntu -- bash -c "cp ~/lispwasm/hl/hlisp.js ~/lispwasm/hl/hlisp.wasm '$(wslpath -a "$PWD" 2>/dev/null || echo "$PWD")/$W/'"
cp engine.lisp $W/
# solo los ejemplos que están en git (una hoja suelta de Jorge, p. ej. la 68, no se publica)
rm -rf $W/ejemplos && mkdir -p $W/ejemplos && git ls-files -z 'ejemplos/*.lisp' | xargs -0 -I{} cp "{}" $W/ejemplos/ && rm -f $W/ejemplos/_*.lisp
( cd $W/ejemplos && python -c "import os,json; json.dump(sorted(os.listdir('.')),open('../ejemplos.json','w',encoding='utf-8'),ensure_ascii=False)" )
# DWG del dibujo AutoLISP (botón DWG): el escritor de acadrust-wasm para navegador (pkg-web)
if [ -d $HOME/acadrust-wasm/pkg-web ]; then mkdir -p $W/dwg && cp $HOME/acadrust-wasm/pkg-web/acadrust_wasm_bg.wasm $W/dwg/ && cp $HOME/acadrust-wasm/pkg-web/acadrust_wasm.js $W/dwg/acadrust_wasm.mjs; fi   # .mjs: el .js lo renombra la huella de publish
echo "listo: dotnet publish -c Release en web/HekatanLispWeb"
