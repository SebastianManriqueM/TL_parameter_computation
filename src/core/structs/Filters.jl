mutable struct TLFilters <: AbstractFilterTLGeometry
    voltage_kv::Int
    n_circuits::Int
    n_ground_wire::Int
    state::Union{Vector{String}, Matrix{String}}
    structure_type::Union{Vector{String}, Matrix{String}}
 end

mutable struct ConductorFilterName <: ConductorFilter
    type::Union{Vector{String}, Matrix{String}}
    codeword::Union{Vector{String}, Matrix{String}}
end

mutable struct ConductorFilterKcm <: ConductorFilter
    type::Union{Vector{String}, Matrix{String}}
    kcmil::Union{Vector{Float64}, Matrix{Float64}}
end

mutable struct GroundWireFilterAWG <: GroundWireFilter
    type::Union{Vector{String}, Matrix{String}}
    awg::Union{Vector{String}, Matrix{String}}
end

mutable struct GroundWireFilterKcm <: GroundWireFilter
    type::Union{Vector{String}, Matrix{String}}
    kcmil::Union{Vector{Float64}, Matrix{Float64}}
end