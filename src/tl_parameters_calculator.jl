using LinearAlgebra
using Combinatorics

include("definitions.jl")
#include("common_filters.jl")

function get_distance_xy( 
    x::Union{Matrix{Float64}, Vector{Float64}},
    y::Union{Matrix{Float64}, Vector{Float64}} 
    )
    return sqrt( ( x[1] - y[2] )^2 + ( y[1] - y[2] )^2 )
end

function get_all_distances(
    t_geometry::TLGeometry
    )
    
    n_dist = round( Int , ( factorial(t_geometry.n_cables) ) / ( factorial(2) * factorial(t_geometry.n_cables - 2) ) )#N distance/combinations
    D_v    = zeros( 1 , n_dist)
    iter   = combinations( collect(1:t_geometry.n_cables), 2 )
    i      = 1
    
    for idx_v in iter
        D_v[i] = get_distance_xy( t_geometry.x_coordinates[idx_v] , t_geometry.y_coordinates[idx_v] )
        i = i+1
    end
    return D_v, iter
end



function initialization_tl_parameters(
    basicdata::TLBasicData
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