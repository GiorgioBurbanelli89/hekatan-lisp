export PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
cd ~/lispwasm/emsdk && source ./emsdk_env.sh >/dev/null 2>&1
export HL_SRC="/mnt/c/Users/j-b-j/Documents/Hekatan Calc 1.0.0/hekatan-lisp"
export HL_OUT=$HOME/lispwasm/hl; rm -rf $HL_OUT; mkdir -p $HL_OUT
cd $HL_OUT
time ~/lispwasm/host/bin/ecl -norc -load "$HL_SRC/web/build_aot.lisp" > aot.log 2>&1
grep -c -i "warning" aot.log; grep -i -B2 -A6 "error" aot.log | head -40; tail -5 aot.log; ls -la
