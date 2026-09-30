# -*- coding: utf-8 -*-
"""Muro de Manabi (membrana de Struct) en SAP2000: PLANE deformacion plana, modos incompatibles,
mismos nudos, muelles, apoyos y cargas nodales. kN, m."""
import json, os, sys, time, numpy as np
import comtypes.client
sys.stdout.reconfigure(encoding="utf-8")
h = comtypes.client.CreateObject("SAP2000v1.Helper")
import comtypes.gen.SAP2000v1 as S
h = h.QueryInterface(S.cHelper); o = h.CreateObjectProgID("CSI.SAP2000.API.SapObject"); o.ApplicationStart(); sm = o.SapModel
res = {}
D = json.load(open("muro_membrana_estatico.json")); P = D["params"]
sm.InitializeNewModel(6); sm.File.NewBlank(); sm.SetPresentUnits(6)
sm.PropMaterial.SetMaterial("M", 2); sm.PropMaterial.SetMPIsotropic("M", float(P["EHormigon"]), float(P["nuHormigon"]), 0.0)
sm.PropMaterial.SetWeightAndMass("M", 1, 0.0)
print("SetPlane", sm.PropArea.SetPlane("P", 2, "M", 0.0, 1.0, True), flush=True)
nm = [sm.PointObj.AddCartesian(float(x), 0.0, float(z), "", "N%d" % i)[0] for i, (x, y, z) in enumerate(D["nodes"])]
for k, e in enumerate(D["elements"]): sm.AreaObj.AddByPoint(4, [nm[i] for i in e], "", "P", "A%d" % k)
sup = D["nodeInputs"]["supports"]
for i in range(len(nm)):
    a = sup.get(str(i), [False]*6)
    sm.PointObj.SetRestraint(nm[i], [bool(a[0]), True, bool(a[2]), True, True, True])
for s in D["nodeInputs"]["springs"]:
    k = [0.0]*6; k[s["dof"]] = float(s["k"]); sm.PointObj.SetSpring(nm[s["node"]], k)
for caso in ["estatico", "sismico"]:
    Dc = json.load(open(f"muro_membrana_{caso}.json"))
    sm.LoadPatterns.Add(caso, 8, 0)
    for n, f in Dc["nodeInputs"]["loads"].items():
        sm.PointObj.SetLoadForce(nm[int(n)], caso, [float(f[0]), 0, float(f[2]), 0, 0, 0])
sm.File.Save(os.path.abspath("sap_muro99.sdb"))
sm.Analyze.SetRunCaseFlag("MODAL", False); sm.Analyze.SetRunCaseFlag("DEAD", False)
print("run", sm.Analyze.RunAnalysis(), flush=True)
for caso in ["estatico", "sismico"]:
    sm.Results.Setup.DeselectAllCasesAndCombosForOutput(); sm.Results.Setup.SetCaseSelectedForOutput(caso)
    U = []
    for i in range(len(nm)):
        r = sm.Results.JointDispl(nm[i], 0, 0, [], [], [], [], [], [], [], [], [], [], [])
        U += [float(r[6][0]), float(r[8][0])]
    res[caso] = U
    Uh = np.load(f"U_{caso}_1.npy"); U = np.array(U); c = D["nudoCoronacion"]
    print(caso, "SAP ux cor %.7f mm | python %.7f | peor nudo %.2e %% del max" % (U[2*c]*1e3, Uh[2*c]*1e3, 100*abs(U-Uh).max()/abs(Uh).max()), flush=True)
json.dump(res, open("sap_U.json", "w"))
o.ApplicationExit(False)
