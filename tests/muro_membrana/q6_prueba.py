# Q4 simple y Q4 con modos incompatibles (Wilson-Taylor), tension plana y deformacion plana, misma malla
import numpy as np, json
def run(nx, ny, plana="tension", inc=False, H=4.0, t=0.4, gam=1.8, phi=30.0, fc=210.0, nu=0.2):
    E = 10*15100*np.sqrt(fc); Ka = np.tan(np.pi/4 - np.radians(phi)/2)**2
    if plana == "tension": D = E/(1-nu**2)*np.array([[1,nu,0],[nu,1,0],[0,0,(1-nu)/2]])
    else: D = E/((1+nu)*(1-2*nu))*np.array([[1-nu,nu,0],[nu,1-nu,0],[0,0,(1-2*nu)/2]])
    a, b = t/nx, H/ny; g = 1/np.sqrt(3)
    def B(xi, et):
        return np.array([
         [-(1-et)/(2*a),0,(1-et)/(2*a),0,(1+et)/(2*a),0,-(1+et)/(2*a),0],
         [0,-(1-xi)/(2*b),0,-(1+xi)/(2*b),0,(1+xi)/(2*b),0,(1-xi)/(2*b)],
         [-(1-xi)/(2*b),-(1-et)/(2*a),-(1+xi)/(2*b),(1-et)/(2*a),(1+xi)/(2*b),(1+et)/(2*a),(1-xi)/(2*b),-(1+et)/(2*a)]])
    def G(xi, et):   # modos 1-xi^2 y 1-eta^2 en u y en v: d/dx = (2/a) d/dxi, d/dy = (2/b) d/deta
        return np.array([[-4*xi/a, 0, -0*1, 0],[0, 0, 0, -4*et/b],[0, -4*xi/a, -4*et/b, 0]]) if False else \
               np.array([[-4*xi/a, 0, 0, 0],[0, 0, 0, -4*et/b],[0, -4*xi/a, -4*et/b, 0]])
    # columnas: a1 = u(1-xi^2), a2 = v(1-xi^2), a3 = u(1-eta^2), a4 = v(1-eta^2)
    Kuu = np.zeros((8,8)); Kua = np.zeros((8,4)); Kaa = np.zeros((4,4))
    for xi in (-g,g):
        for et in (-g,g):
            Bm, Gm = B(xi,et), G(xi,et); w = a*b/4
            Kuu += Bm.T@D@Bm*w; Kua += Bm.T@D@Gm*w; Kaa += Gm.T@D@Gm*w
    Ke = Kuu - Kua@np.linalg.solve(Kaa, Kua.T) if inc else Kuu
    nj = (nx+1)*(ny+1); K = np.zeros((2*nj,2*nj)); F = np.zeros(2*nj)
    nid = lambda i,k: i*(ny+1)+k
    for i in range(nx):
        for k in range(ny):
            ns = [nid(i,k), nid(i+1,k), nid(i+1,k+1), nid(i,k+1)]
            dof = sum([[2*n,2*n+1] for n in ns], [])
            K[np.ix_(dof,dof)] += Ke
    p = lambda z: Ka*gam*z
    for k in range(ny):
        pa, pb = p(H-k*b), p(H-(k+1)*b)
        F[2*nid(0,k)] += b*(2*pa+pb)/6; F[2*nid(0,k+1)] += b*(pa+2*pb)/6
    free = [d for n in range(nj) if n%(ny+1)!=0 for d in (2*n,2*n+1)]
    U = np.zeros(2*nj); U[free] = np.linalg.solve(K[np.ix_(free,free)], F[free])
    return U, nid
s = json.load(open('struct_completa.json'))['deformations']
for pl in ("tension","deformacion"):
    for inc in (False, True):
        U, nid = run(4, 40, pl, inc)
        peor = max(abs(U[2*n] - s[str(n)][0]) for n in range(205))/abs(s['40'][0])*100
        print("%-12s inc=%-5s  ux cor %.6f  media %.6f  uy cor %.6f | peor nudo vs Struct %.4f %%" % (pl, inc, 1000*U[2*40], 1000*U[2*20], 1000*U[2*40+1], peor))
print("Struct               ux cor %.6f  media %.6f  uz cor %.6f" % (1000*s['40'][0], 1000*s['20'][0], 1000*s['40'][2]))
