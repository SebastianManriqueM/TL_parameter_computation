#St clair curve---------------
Pbase = 100
Vbase = 345
Zbase = (Vbase^2) / Pbase



X_s = 0.333*im
X_r = 0.333*im



E2 = 1.0
Es = 1.0

ΔV    = 0.05
Er_L  = Es * (1-ΔV)
θ_1_L = 40.0 * ( π / 180.0 )
Δθ_1  = 0.5  * ( π / 180.0 )

Len = 100.0

Ns = 0
Nr = 0
N = 0

E1 = 0.98

#R  = tl1.parameters.r1 * Len / Zbase
#XL = tl1.parameters.x1 * Len * im / Zbase
R  = 0.00571 * Len / Zbase
XL = 0.06432 * Len * im / Zbase
f_s = (100-Ns)/100
f_r = (100-Nr)/100


B   = (tl1.parameters.b1/1000000) * Len
#B   = 0.6604 * Len
Bms = 0.5*B*f_s
Bmr = 0.5*B*f_r
Xcs= (1/Bms)*-1*im
Xcr= (1/Bmr)*-1*im
Xcs= ( (1/Bms)*-1*im ) / Zbase
Xcr= ( (1/Bmr)*-1*im ) / Zbase



θ_1 = -50.0 * ( π / 180.0 )

Z  = [ X_s+Xcs -Xcs 0 ; Xcs R+XL+Xcr+Xcs -Xcr; 0 -Xcr X_r+Xcr ]
iZ = inv(Z)
E_v = [ E1*cos(θ_1) + E1*sin(θ_1)*im ; 0; -E2 ]
I_v = iZ * E_v

Es_calc = ( I_v[1] - I_v[2] ) * Xcm * f_s
abs(Es_calc)
Er_calc = ( I_v[2] - I_v[3] ) * Xcm * f_r
abs(Er_calc)

Vx2 = I_v[3]*X_r

Er_calc-Vx2
E1_calc = I_v[1]*X_s + Es_calc
atan(imag(E1_calc)/real(E1_calc))

println("Power [pu]")
Sline = Es_calc * conj( I_v[2] )

aa=1
