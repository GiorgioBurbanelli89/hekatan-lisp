set -e
mkdir -p ~/lispwasm && cd ~/lispwasm
[ -d emsdk ] || git clone --depth 1 https://github.com/emscripten-core/emsdk.git
cd emsdk && ./emsdk install latest >/dev/null && ./emsdk activate latest >/dev/null && cd ..
[ -d ecl ] || git clone --depth 1 https://gitlab.com/embeddable-common-lisp/ecl.git
cd ecl
ls src/util | grep -i cross
git log -1 --format='%h %cd'
