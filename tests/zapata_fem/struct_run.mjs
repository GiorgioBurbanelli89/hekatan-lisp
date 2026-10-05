// Corre el cliModeler de la rama zapata-levantamiento (sin tocar su codigo) sobre cada .heks
import { writeFileSync, readFileSync, mkdtempSync, copyFileSync, rmSync } from "node:fs";
import { join } from "node:path";
import { pathToFileURL } from "node:url";
const BASE = "C:/Users/j-b-j/Documents/Hekatan Calc 1.0.0";
const Z = BASE + "/hekatan-struct-zapata";
const NM = BASE + "/hekatan-struct-limpio/node_modules";
const { build } = await import(pathToFileURL(NM + "/esbuild/lib/main.js").href);
const dir = mkdtempSync(join(process.cwd(), "hkb-"));
process.on("exit", () => { try { rmSync(dir, { recursive: true, force: true }); } catch {} });
writeFileSync(join(dir, "entry.ts"), `export { cliModeler } from "${Z}/examples/src/cli-modeler/cliModeler";\n`);
copyFileSync(Z + "/hekatan-fem/src/cpp/built/deform.wasm", join(dir, "deform.wasm"));
await build({ entryPoints: [join(dir, "entry.ts")], bundle: true, format: "esm", platform: "node",
  outfile: join(dir, "bundle.mjs"), logLevel: "error", nodePaths: [NM, BASE + "/hekatan-struct-limpio/hekatan-fem/node_modules"],
  alias: { "hekatan-fem": Z + "/hekatan-fem" } });
const mod = await import(pathToFileURL(join(dir, "bundle.mjs")).href);
const st = (v) => ({ val: v });
const out = {};
for (const f of process.argv.slice(2)) {
  globalThis.window = { __hekatanCliScript: readFileSync(f, "utf-8") };
  const states = { nodes: st([]), elements: st([]), nodeInputs: st({}), elementInputs: st({}), deformOutputs: st({}), analyzeOutputs: st({}), objects3D: st([]) };
  const t0 = Date.now();
  mod.cliModeler.build({}, states);
  const U = states.deformOutputs.val.deformations;
  const nodes = states.nodes.val;
  const u = nodes.map((_, i) => U.get(i));
  out[f] = { u, contacto: globalThis.window.__hekatanCliContacto ?? null, eq: globalThis.window.__hekatanCliEquilibrio ?? null,
             errors: globalThis.window.__hekatanCliErrors ?? null, ms: Date.now() - t0 };
  console.log(f, "nodos", nodes.length, "ms", Date.now() - t0, "hist", out[f].contacto?.historial?.join(">"), "eq", JSON.stringify(out[f].eq)?.slice(0, 200));
}
writeFileSync("struct.json", JSON.stringify(out));
