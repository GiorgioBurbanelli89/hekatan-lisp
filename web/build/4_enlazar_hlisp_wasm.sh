export PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
cd ~/lispwasm/emsdk && source ./emsdk_env.sh >/dev/null 2>&1
E=~/lispwasm/ecl-wasm/ecl-emscripten
W="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd ~/lispwasm/hl
file engine.o | head -1
emcc "$W/hlisp_main.c" -I$E -O0 -DECL_C_COMPATIBLE_VARIADIC_DISPATCH -Demscripten \
  libhlisp.a -L$E -lecl -leclgc -leclgmp -lm \
  -sSTACK_SIZE=1048576 -sBINARYEN_EXTRA_PASSES=--spill-pointers \
  -sINITIAL_MEMORY=402653184 -sALLOW_MEMORY_GROWTH=1 -sMAXIMUM_MEMORY=1073741824 -sMODULARIZE=1 -sEXPORT_NAME=HLisp \
  -sEXPORTED_FUNCTIONS=_main,_hlisp_run -sEXPORTED_RUNTIME_METHODS=cwrap,ccall \
  -sENVIRONMENT=web,worker,node -o hlisp.js 2>&1 | grep -v "^$" | head -30
ls -la hlisp.js hlisp.wasm
