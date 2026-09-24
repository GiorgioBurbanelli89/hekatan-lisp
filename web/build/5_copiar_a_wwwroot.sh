# Copia a la web lo que se genera fuera de ella (correr desde hekatan-lisp/, en Git Bash):
#   motor compilado (WSL ~/lispwasm/hl) + engine.lisp (menú Motor) + ejemplos.
set -e
W=web/HekatanLispWeb/wwwroot
wsl -d Ubuntu -- bash -c "cp ~/lispwasm/hl/hlisp.js ~/lispwasm/hl/hlisp.wasm '$(wslpath -a "$PWD" 2>/dev/null || echo /mnt/c/Users/j-b-j/Documents/Hekatan\ Calc\ 1.0.0/hekatan-lisp)/$W/'"
cp engine.lisp $W/
rm -rf $W/ejemplos && mkdir -p $W/ejemplos && cp ejemplos/*.lisp $W/ejemplos/ && rm -f $W/ejemplos/_*.lisp
( cd $W/ejemplos && python -c "import os,json; json.dump(sorted(os.listdir('.')),open('../ejemplos.json','w',encoding='utf-8'),ensure_ascii=False)" )
# DWG del dibujo AutoLISP (botón DWG): el escritor de acadrust-wasm para navegador (pkg-web)
if [ -d /c/Users/j-b-j/acadrust-wasm/pkg-web ]; then mkdir -p $W/dwg && cp /c/Users/j-b-j/acadrust-wasm/pkg-web/acadrust_wasm_bg.wasm $W/dwg/ && cp /c/Users/j-b-j/acadrust-wasm/pkg-web/acadrust_wasm.js $W/dwg/acadrust_wasm.mjs; fi   # .mjs: el .js lo renombra la huella de publish
echo "listo: dotnet publish -c Release en web/HekatanLispWeb"
