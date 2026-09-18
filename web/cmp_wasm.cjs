const fs=require('fs'),path=require('path');
require(path.join(__dirname,'HekatanLispWeb','wwwroot','hlisp.js'))({print(){},printErr(){}}).then(m=>{
  const run=m.cwrap('hlisp_run','string',['string']); const d=path.join(__dirname,'HekatanLispWeb','wwwroot','ejemplos');
  for(const f of fs.readdirSync(d)){ const t=Date.now(); const o=run(fs.readFileSync(path.join(d,f),'utf8'));
    fs.writeFileSync(path.join(__dirname,'cmp',f.replace(/\.lisp$/,'')+'.wasm'),o); console.log((Date.now()-t)+' ms  '+f); }
});
