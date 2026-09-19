# Publica la web en GitHub Pages (rama gh-pages de GiorgioBurbanelli89/hekatan-lisp).
# Correr desde hekatan-lisp/ en Git Bash:  bash web/build/6_publicar_gh_pages.sh
set -e
RAIZ="$PWD"
# publicación LIMPIA: la incremental a veces deja los marcadores main#[.{fingerprint}].js sin reemplazar
# (pasó el 2026-09-18: el sitio pedía «main» y «hlisp» → 404 y la página no cargaba)
cd web/HekatanLispWeb && rm -rf bin/Release obj/Release && dotnet publish -c Release > /dev/null && cd "$RAIZ"
PUB="$RAIZ/web/HekatanLispWeb/bin/Release/net10.0/publish/wwwroot"
if grep -q '{fingerprint}' "$PUB/index.html"; then echo "ERROR: index.html con marcadores sin reemplazar; NO se publica"; exit 1; fi
T=$(mktemp -d)
git clone -q --branch gh-pages --single-branch https://github.com/GiorgioBurbanelli89/hekatan-lisp.git "$T"
cd "$T"
git config user.name "$(git -C "$RAIZ" log -1 --format=%an)"; git config user.email "$(git -C "$RAIZ" log -1 --format=%ae)"
git config core.autocrlf false          # .NET verifica los archivos con hashes: NO tocar los fin de línea
git rm -q -r --cached . > /dev/null
find . -mindepth 1 -maxdepth 1 ! -name .git -exec rm -rf {} +
cp -r "$PUB"/. .
touch .nojekyll                         # sin esto GitHub Pages ignora la carpeta _framework
find . -name "*.br" -delete; find . -name "*.gz" -delete
for f in hlisp.*.js main.*.js; do grep -q "$f" index.html || rm "$f"; done
# el CSS no lleva huella en el nombre → versión por contenido, para que el navegador no use el viejo
V=$(sha1sum app.css | cut -c1-10)
sed -i "s|href=\"app.css\"|href=\"app.css?v=$V\"|" index.html
git add -A
git commit -q -m "Publicar Hekatan LISP web ($(date +%F))" || { echo "sin cambios"; exit 0; }
git push -q origin gh-pages
echo "publicado: https://giorgioburbanelli89.github.io/hekatan-lisp/  (css v=$V)"
