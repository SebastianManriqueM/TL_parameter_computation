using LinearAlgebra
using Combinatorics

include("definitions.jl")
#include("common_filters.jl")




function get_primitive_z_matrix( 
    basicdata::TLBasicData,
    geometry::TLGeometry,
    conductor::TLConductor,
    ground_wire::TLGroundWire, 
    )

    rho  = basicdata.gnd_rho
    freq = basicdata.frequency
    #res_v, 
    #GMR_v, 
    #index_c

    n_cond      = geometry.n_cables
    z_primitive = zeros( ComplexF64, n_cond, n_cond)
    #out diagonal
    j = 1
    for i in geometry.combinations
        z_primitive[i[1] , i[2]] = 0.00158836*freq + ( 0.00202237*freq*( log(1/geometry.distances[j]) + 7.6786 + 0.5*log(rho/freq) ) )*im
        z_primitive[i[2] , i[1]] = z_primitive[i[1] , i[2]]
        j = j + 1
    end
    
    #diagonal - Conductors
    for i = 1:n_cond
        #TODO Add capability to represent 2 different conductors in different circuits - change Rac_tnom and gmr at elseif
        if i <= 3  #Circuit 1
            z_primitive[i , i] = conductor.Rac_tnom + 0.00158836*freq + ( 0.00202237*freq*( log(1/conductor.gmr) + 7.6786 + 0.5*log(rho/freq) ) )*im
        elseif  basicdata.n_circuits == 2 && i <= basicdata.n_circuits * 3  #Circuit 2
            z_primitive[i , i] = conductor.Rac_tnom + 0.00158836*freq + ( 0.00202237*freq*( log(1/conductor.gmr) + 7.6786 + 0.5*log(rho/freq) ) )*im
        else #Ground wire
            z_primitive[i , i] = ground_wire.Rdc_20 + 0.00158836*freq + ( 0.00202237*freq*( log(1/ground_wire.gmr) + 7.6786 + 0.5*log(rho/freq) ) )*im
        end

    end
    return z_primitive
end


function get_kron_reduced_z_matrix(
    basicdata::TLBasicData, 
    geometry::TLGeometry,
    z_primitive:: Matrix{ComplexF64}
    )
    n_cond = geometry.n_cables - basicdata.n_ground_wire
    #n_ct   = length( index_c )
    #n_ph1  = count(x -> x == 1, index_c)
    n_gc   = basicdata.n_ground_wire#count(x -> x == 2, index_c)
    #n_ph2  = count(x -> x == 3, index_c)

    Zph_ph = z_primitive[ 1          : n_cond       , 1          : n_cond ]
    Zph_g  = z_primitive[ 1          : n_cond       , n_cond + 1 : n_cond + n_gc ]
    Zg_ph  = z_primitive[ n_cond + 1 : n_cond + n_gc, 1          : n_cond ]
    Zg_g   = z_primitive[ n_cond + 1 : n_cond + n_gc, n_cond + 1 : n_cond + n_gc ]

    return Zph_ph - ( Zph_g * inv(Zg_g) * Zg_ph )
end


function initialization_tl_parameters(
    basicdata::TLBasicData,
    geometry::TLGeometry,
    conductor::TLConductor,
    ground_wire::TLGroundWire, 
    )::ElectricalParameters
    dim_primitive = ( 3 * basicdata.n_circuits ) + basicdata.n_ground_wire
    dim_kron      = dim_primitive - basicdata.n_ground_wire

    Zabcg = get_primitive_z_matrix( basicdata, geometry, conductor, ground_wire)

    Z_kron
    Z012
    Zabcg_pu
    Z_kron_pu
    Z012_pu

    
    return ElectricalParameters( combinations, distances, Zabcg, Z_kron, Z012, Zabcg_pu, Z_kron_pu, Z012_pu )
end