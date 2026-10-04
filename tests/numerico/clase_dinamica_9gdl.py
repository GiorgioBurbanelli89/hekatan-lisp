"""Comprobación independiente de las hojas 108-110 (clase introductoria de dinámica).
Edificio de 3 pisos 6x6 m, columnas 40x50, 9 gdl (Ux, Uy, Rz por piso), scipy eigh.
Periodos y masa participativa en Ux, Uy, Rz, Rx, Ry (origen: centro de planta en la base)."""
import numpy as np
g=9.80665
Ec=4700*np.sqrt(240*g/100)*1000/g
bx,by,h=0.4,0.5,3.0
kcx=12*Ec*0.8*by*bx**3/12/h**3; kcy=12*Ec*0.8*bx*by**3/12/h**3
ms=np.array([36,36,28.8])/g; z=np.array([3,6,9.])
# full 3D 9-dof model: dofs per floor [ux,uy,rz], columns at (+-3,+-3)
cols=[(3,3),(-3,3),(-3,-3),(3,-3)]
def kfloor():
    k=np.zeros((3,3))
    for (x,y) in cols:
        # column displacement: ux_c = ux - rz*y, uy_c = uy + rz*x
        a=np.array([[1,0,-y],[0,1,x]])
        k+=a.T@np.diag([kcx,kcy])@a
    return k
kf=kfloor()
K=np.zeros((9,9))
for s in range(3):
    i=slice(3*s,3*s+3)
    K[i,i]+=kf
    if s+1<3:
        j=slice(3*s+3,3*s+6); K[i,i]+=kf; K[i,j]-=kf; K[j,i]-=kf
M=np.zeros((9,9))
for s in range(3):
    M[3*s,3*s]=ms[s]; M[3*s+1,3*s+1]=ms[s]; M[3*s+2,3*s+2]=ms[s]*(36+36)/12
from scipy.linalg import eigh
lam,V=eigh(K,M)
T=2*np.pi/np.sqrt(lam)
# influence vectors about origin at base center
R={}
R['Ux']=np.tile([1,0,0],3).astype(float)
R['Uy']=np.tile([0,1,0],3).astype(float)
R['Rz']=np.tile([0,0,1],3).astype(float)
rx=np.zeros(9); ry=np.zeros(9)
for s in range(3): rx[3*s+1]=-z[s]; ry[3*s]=z[s]
R['Rx']=rx; R['Ry']=ry
print("T",np.round(T,6))
cum={k:0 for k in R}
for n in range(9):
    f=V[:,n]; Mn=f@M@f; row=[]
    for k,r in R.items():
        p=(f@M@r)**2/Mn/(r@M@r); cum[k]+=p; row.append('%s %6.2f/%6.2f'%(k,100*p,100*cum[k]))
    print(n+1,'%.4f'%T[n],' '.join(row))
