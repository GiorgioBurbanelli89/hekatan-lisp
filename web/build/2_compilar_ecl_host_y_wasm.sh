set -e
export PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
cd ~/lispwasm
# 1) ECL host (x86_64, con compilador) -> ~/lispwasm/host
rm -rf ecl-host && cp -r ecl ecl-host && cd ecl-host
./configure --prefix=$HOME/lispwasm/host > ../host_conf.log 2>&1
make -j20 > ../host_make.log 2>&1 || { echo HOST_FAIL; exit 1; }
make install >> ../host_make.log 2>&1 || { echo HOST_FAIL; exit 1; }
echo HOST_OK; $HOME/lispwasm/host/bin/ecl --version
cd ~/lispwasm/emsdk && ./emsdk install 4.0.12 >/dev/null && ./emsdk activate 4.0.12 >/dev/null
source ./emsdk_env.sh >/dev/null 2>&1; emcc --version | head -1
# 2) ECL wasm32
cd ~/lispwasm && rm -rf ecl-wasm && cp -r ecl ecl-wasm && cd ecl-wasm
export ECL_TO_RUN=$HOME/lispwasm/host/bin/ecl
# 26-nov-2026: ECL trae -O0 fijo para emscripten (src/aclocal.m4) y setjmp/longjmp por trampolines JS (invoke_*):
# 4-5x mas lento. Se compila con -O2 y setjmp/longjmp nativos de wasm (Chrome/Edge/Firefox/Safari actuales).
EH="-fwasm-exceptions -sSUPPORT_LONGJMP=wasm"
sed -i "s/-DECL_C_COMPATIBLE_VARIADIC_DISPATCH -O0/-DECL_C_COMPATIBLE_VARIADIC_DISPATCH -O2 $EH/" src/configure
export LDFLAGS="$EH"
emconfigure ./configure --host=wasm32-unknown-emscripten --build=x86_64-pc-linux-gnu \
  --with-cross-config=`pwd`/src/util/wasm32-unknown-emscripten.cross_config \
  --prefix=`pwd`/ecl-emscripten --disable-shared --with-tcp=no --with-cmp=no > ../wasm_conf.log 2>&1
emmake make > ../wasm_make.log 2>&1 || { echo WASM_FAIL; exit 1; }
emmake make install >> ../wasm_make.log 2>&1 || { echo WASM_FAIL; exit 1; }
cp build/bin/ecl.js build/bin/ecl.wasm ecl-emscripten/
echo WASM_OK; ls -la ecl-emscripten ecl-emscripten/lib
