# -*- coding: utf-8 -*-
"""El muro de la hoja 92 en SAP2000 por OAPI: elemento PLANE, MISMOS nudos, MISMAS cargas
nodales, base empotrada. Plano XZ; UY fijo en todos los nudos.
   python sap_plane_muro.py muro_q4.json salida.json [inc 0|1] [tipo 1 = tension plana | 2 = deformacion plana]"""
import json, os, sys, time
import comtypes.client
sys.stdout.reconfigure(encoding="utf-8")
src, salida = sys.argv[1], sys.argv[2]; inc = len(sys.argv) > 3 and sys.argv[3] == "1"
tipo = int(sys.argv[4]) if len(sys.argv) > 4 else 1
D = json.load(open(src))
h = comtypes.client.CreateObject("SAP2000v1.Helper")
import comtypes.gen.SAP2000v1 as S
h = h.QueryInterface(S.cHelper); o = h.CreateObjectProgID("CSI.SAP2000.API.SapObject"); o.ApplicationStart(); sm = o.SapModel
t0 = time.time()
sm.InitializeNewModel(12); sm.File.NewBlank(); sm.SetPresentUnits(12)      # tonf, m
sm.PropMaterial.SetMaterial("M", 3); sm.PropMaterial.SetMPIsotropic("M", float(D["E"]), float(D["nu"]), 0.0)
sm.PropMaterial.SetWeightAndMass("M", 1, 0.0)
print("SetPlane ->", sm.PropArea.SetPlane("P", tipo, "M", 0.0, 1.0, inc), "tipo", tipo, flush=True)    # t = 1 m
nm = [sm.PointObj.AddCartesian(float(x), 0.0, float(z), "", "N%d" % i)[0] for i, (x, z) in enumerate(D["nodes"])]
for k, e in enumerate(D["elems"]):
    sm.AreaObj.AddByPoint(4, [nm[i] for i in e], "", "P", "A%d" % k)
base = set(D["base"])
for i in range(len(nm)):
    sm.PointObj.SetRestraint(nm[i], [True, True, True, True, True, True] if i in base else [False, True, False, True, True, True])
sm.LoadPatterns.Add("F", 8, 0)
for i, fx in enumerate(D["Fx"]):
    if fx != 0.0: sm.PointObj.SetLoadForce(nm[i], "F", [float(fx), 0, 0, 0, 0, 0])
print("modelo: %d nudos, %d areas, sumFx %.4f, inc=%s, %.0f s" % (len(nm), len(D["elems"]), sum(D["Fx"]), inc, time.time() - t0), flush=True)
sm.File.Save(os.path.abspath(os.path.splitext(salida)[0] + ".sdb"))
sm.Analyze.SetRunCaseFlag("MODAL", False); sm.Analyze.SetRunCaseFlag("DEAD", False)
print("run ->", sm.Analyze.RunAnalysis(), flush=True)
sm.Results.Setup.DeselectAllCasesAndCombosForOutput(); sm.Results.Setup.SetCaseSelectedForOutput("F")
U = []
for i in range(len(nm)):
    r = sm.Results.JointDispl(nm[i], 0, 0, [], [], [], [], [], [], [], [], [], [], [])
    U.append([float(r[6][0]), float(r[8][0])] if r[0] else [0.0, 0.0])
rb = sm.Results.BaseReact(0, [], [], [], [], [], [], [], [], [], 0.0, 0.0, 0.0)
ref = D["U"]; mx = max(abs(u[0]) for u in ref)
peor = max(abs(U[i][c] - ref[i][c]) / mx * 100 for i in range(len(U)) for c in range(2))
json.dump({"inc": inc, "U": U, "baseFx": float(rb[4][0]) if rb[0] else None, "peor_pct": peor}, open(salida, "w"))
print("SAP2000 inc=%s: ux coronacion %.6f mm (hoja %.6f mm) | base Fx %s | peor nudo %.3e %% del max" %
      (inc, 1000 * U[D["cor"]][0], 1000 * ref[D["cor"]][0], rb[4][0] if rb[0] else None, peor), flush=True)
o.ApplicationExit(False)
