import json, numpy as np, sys
caso = sys.argv[1] if len(sys.argv)>1 else 'sismico'
inc = (sys.argv[2] if len(sys.argv)>2 else '1')=='1'
d=json.load(open(f'muro_membrana_{caso}.json'))
P=d['params']; E=P['EHormigon']; nu=P['nuHormigon']; t=P['L']
X=np.array(d['nodes'])[:,[0,2]]; els=np.array(d['elements']); nn=len(X)
# deformacion plana
Dm=E/((1+nu)*(1-2*nu))*np.array([[1-nu,nu,0],[nu,1-nu,0],[0,0,(1-2*nu)/2]])
g=1/np.sqrt(3); GP=[(-g,-g),(g,-g),(g,g),(-g,g)]
def dN(xi,eta): return 0.25*np.array([[-(1-eta),(1-eta),(1+eta),-(1+eta)],[-(1-xi),-(1+xi),(1+xi),(1-xi)]])
def ke(xy):
    J0=dN(0,0)@xy; dJ0=np.linalg.det(J0); J0i=np.linalg.inv(J0)
    Kuu=np.zeros((8,8));Kua=np.zeros((8,4));Kaa=np.zeros((4,4))
    for xi,eta in GP:
        J=dN(xi,eta)@xy; dJ=np.linalg.det(J); dx=np.linalg.solve(J,dN(xi,eta))
        B=np.zeros((3,8)); B[0,0::2]=dx[0]; B[1,1::2]=dx[1]; B[2,0::2]=dx[1]; B[2,1::2]=dx[0]
        dn=np.array([[-2*xi,0],[0,-2*eta]])  # d(1-xi^2), d(1-eta^2) respecto xi,eta
        dPx=(J0i@dn)*dJ0/dJ   # Taylor: J0 y factor detJ0/detJ
        Gm=np.zeros((3,4)); Gm[0,0:2]=dPx[0]; Gm[1,2:4]=dPx[1]; Gm[2,0:2]=dPx[1]; Gm[2,2:4]=dPx[0]
        w=dJ*t
        Kuu+=B.T@Dm@B*w; Kua+=B.T@Dm@Gm*w; Kaa+=Gm.T@Dm@Gm*w
    return Kuu-Kua@np.linalg.solve(Kaa,Kua.T) if inc else Kuu
K=np.zeros((2*nn,2*nn)); F=np.zeros(2*nn)
for e in els:
    dof=np.ravel([[2*n,2*n+1] for n in e]); K[np.ix_(dof,dof)]+=ke(X[e])
for s in d['nodeInputs']['springs']: K[2*s['node']+1,2*s['node']+1]+=s['k']
for n,f in d['nodeInputs']['loads'].items(): F[2*int(n)]+=f[0]; F[2*int(n)+1]+=f[2]
fix=[2*int(n)+i for n,a in d['nodeInputs']['supports'].items() for i,ai in zip([0,1],[a[0],a[2]]) if ai]
free=np.setdiff1d(np.arange(2*nn),fix); U=np.zeros(2*nn); U[free]=np.linalg.solve(K[np.ix_(free,free)],F[free])
S=np.array([[d['deformations'][str(n)][0],d['deformations'][str(n)][2]] for n in range(nn)]).ravel()
c=d['nudoCoronacion']
print(caso,'inc' if inc else 'Q4', 'ux cor %.7f mm  Struct %.7f'%(U[2*c]*1e3,S[2*c]*1e3), ' peor nudo %% max: %.4f'%(100*np.abs(U-S).max()/np.abs(S).max()))
np.save(f'U_{caso}_{int(inc)}.npy',U)
