using LinearAlgebra
using Combinatorics

include("definitions.jl")
#include("common_filters.jl")




function get_primitive_z_matrix( 
    combinations::Vector{Vector{Int64}},
    distance_v::Matrix{Float64},
    basicdata::TLBasicData,
    conductor::TLConductor,
    ground_wire::TLGroundWire, 
    )

    rho  = basicdata.gnd_rho
    freq = basicdata.frequency
    res_v, 
    GMR_v, 
    index_c

    n_cond      = length( index_c )
    z_primitive = zeros( ComplexF64, n_cond, n_cond)
    #out diagonal
    j = 1
    for i in combinations
        z_primitive[i[1] , i[2]] = 0.00158836*freq + ( 0.00202237*freq*( log(1/distance_v[j]) + 7.6786 + 0.5*log(rho/freq) ) )*im
        z_primitive[i[2] , i[1]] = z_primitive[i[1] , i[2]]
        j = j + 1
    end
    #diagonal
    for i = 1:n_cond
        z_primitive[i , i] = res_v[ index_c[i] ] + 0.00158836*freq + ( 0.00202237*freq*( log(1/GMR_v[ index_c[i] ]) + 7.6786 + 0.5*log(rho/freq) ) )*im
    end
    return z_primitive
end


function initialization_tl_parameters(
    basicdata::TLBasicData,
    tl_geometry::TLGeometry,
    conductor::TLConductor,
    ground_wire::TLGroundWire, 
    )::ElectricalParameters
    dim_primitive = ( 3 * basicdata.n_circuits ) + basicdata.n_ground_wire
    dim_kron      = dim_primitive - basicdata.n_ground_wire

    combinations
    distances
    Zabcg
    Z_kron
    Z012
    Zabcg_pu
    Z_kron_pu
    Z012_pu

    
    return ElectricalParameters( combinations, distances, Zabcg, Z_kron, Z012, Zabcg_pu, Z_kron_pu, Z012_pu )
end