mutable struct TLBasicData <: AbstractTLPhysicalComponent
    name::String
    voltage_kv::Float64
    n_circuits::Int
    n_ground_wire::Int
    state::String
    structure_type::String
    structure_code::String
    distance::Float64       #Miles
    S_rated::Float64        #MVA
    frequency::Float64      #Hz
    gnd_rho::Float64        #ohm/m
end

mutable struct TLGeometry <: AbstractTLPhysicalComponent
    n_cables::Int
    x_coordinates::Matrix{Float64}  #ft
    y_coordinates::Matrix{Float64}  #ft
    combinations::Vector{Vector{Int64}}
    distances::Matrix{Float64}      #ft
end