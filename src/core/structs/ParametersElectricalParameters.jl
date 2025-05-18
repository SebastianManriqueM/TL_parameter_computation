mutable struct ElectricalParameters <: AbstractTLParameters
    Zabcg::Matrix{ComplexF64}       #Series impedance Primitive Matrix                          ohm/mile
    Z_kron_nt::Matrix{ComplexF64}   #Series impedance Kron reduced matrix - non transposed      ohm/mile
    Z012_nt::Matrix{ComplexF64}     #Series impedance Sequence Matrix - non transposed          ohm/mile
    Z_kron_ft::Matrix{ComplexF64}   #Series impedance Kron reduced matrix - fully transposed    ohm/mile
    Z012_ft::Matrix{ComplexF64}     #Series impedance Sequence Matrix - fully transposed        ohm/mile
    Y_kron_nt::Matrix{ComplexF64}   #Shunt admittance Kron reduced matrix - non transposed      ohm/mile
    Y012_nt::Matrix{ComplexF64}     #Shunt admittance Sequence Matrix - non transposed          ohm/mile
    Y_kron_ft::Matrix{ComplexF64}   #Shunt admittance Kron reduced matrix - fully transposed    ohm/mile
    Y012_ft::Matrix{ComplexF64}     #Shunt admittance Sequence Matrix - fully transposed        ohm/mile
    r1::Float64                     #Positive/negative sequence series resistance Ohms/mile              ohm/mile
    x1::Float64                     #Positive/negative sequence series reactance  Ohms/mile              ohm/mile
    b1::Float64                     #Positive/negative sequence shunt suceptance  uS/mile              uS/mile
    r0::Float64                     #Zero sequence series resistance
    x0::Float64                     #Zero sequence series reactance
    b0::Float64                     #Zero sequence shunt suceptance                             uS/mile
    r0m::Float64                    #Zero sequence mutual resistance (Between circuits)
    x0m::Float64                    #Zero sequence mutual reactance (Between circuits)
    b0m::Float64                    #Zero sequence mutual suceptance (Between circuits)
    Z_sil::Float64                  #Surge impedance in Ohms
    sil::Float64                    # Surge Impedance Load in MW
    #Zabcg_pu::Matrix{Float64}       #Primitive Matrix
    #Z_kron_pu::Matrix{Float64}      #Kron reduced matrix
    #Z012_pu::Matrix{Float64}        #Sequence Matrix
end