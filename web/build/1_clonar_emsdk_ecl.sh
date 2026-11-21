set -e
# Ubuntu limpio (WSL): lo que hace falta antes (m4 lo pide el GMP de ECL; sin el, configure falla)
#   apt-get install -y build-essential git python3 xz-utils m4
mkdir -p ~/lispwasm && cd ~/lispwasm
[ -d emsdk ] || git clone --depth 1 https://github.com/emscripten-core/emsdk.git
cd emsdk && ./emsdk install 4.0.12 >/dev/null && ./emsdk activate 4.0.12 >/dev/null && cd ..
[ -d ecl ] || git clone --depth 1 --branch 26.5.5 https://gitlab.com/embeddable-common-lisp/ecl.git   # la version con la que se midio la web
cd ecl
ls src/util | grep -i cross
git log -1 --format='%h %cd'
