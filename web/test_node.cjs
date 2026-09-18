// test_node.cjs — carga hlisp.wasm (motor compilado ANTES) y corre prueba_formas.lisp
const fs = require('fs'), path = require('path');
const dir = process.argv[2];                       // carpeta con hlisp.js/.wasm
const HLisp = require(path.join(dir, 'hlisp.js'));
const t0 = Date.now();
HLisp().then(m => {
  const t1 = Date.now();
  const run = m.cwrap('hlisp_run', 'string', ['string']);
  const code = fs.readFileSync(path.join(__dirname, 'prueba_formas.lisp'), 'utf8');
  const out = run(code);
  const t2 = Date.now();
  fs.writeFileSync(path.join(__dirname, 'wasm.out'), out);
  process.stdout.write(out);
  const tk = Date.now(); for (let i = 0; i < 100; i++) run("(print (dsimp '(* (sin x) (exp (* 2 x))) 'x))"); const tk2 = Date.now();
  console.log(`\n@@ arranque ${t1 - t0} ms | prueba ${t2 - t1} ms | 1 derivada ${(tk2 - tk) / 100} ms | UTF-8: ${run('(princ "∂ ∇ ñ α")')}`);
});
