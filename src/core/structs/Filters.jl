mutable struct TLFilters <: AbstractFilterTLGeometry
    voltage_kv::Int
    n_circuits::Int
    n_ground_wire::Int
    state::StringArrayFilteringData
    structure_type::StringArrayFilteringData
 end

mutable struct ConductorFilterName <: ConductorFilter
    type::StringArrayFilteringData
    codeword::StringArrayFilteringData
end

mutable struct ConductorFilterKcm <: ConductorFilter
    type::StringArrayFilteringData
    kcmil::FloatArrayFilteringData
end

mutable struct GroundWireFilterAWG <: GroundWireFilter
    type::StringArrayFilteringData
    awg::StringArrayFilteringData
end

mutable struct GroundWireFilterKcm <: GroundWireFilter
    type::StringArrayFilteringData
    kcmil::FloatArrayFilteringData
end