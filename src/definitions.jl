using Parameters
using XLSX
using DataFrames

FACTOR_FT_INCH = 1.0 / 12.0
FACTOR_MILES_KFT = 1.0 / 5.28

DATA_SET_TL_VOLTAGES = [345 500 735]
US_STATES_LIST_SHORT = ["AL","AK","AZ","AR","CA","CO","CT","DE","FL","GA","HI","ID","IL","IN","IA","KS","KY","LA","ME","MD","MA","MI","MN","MS","MO","MT","NE","NV","NH","NJ","NM","NY","NC","ND","OH","OK","OR","PA","RI","SC","SD","TN","TX","UT","VT","VA","WA","WV","WI","WY"]
US_STATES_LIST       = ["Alabama", "Alaska", "Arizona", "Arkansas", "California", "Colorado", "Connecticut", "Delaware", "Florida", "Georgia", "Hawaii", "Idaho", "Illinois", "Indiana", "Iowa", "Kansas", "Kentucky", "Louisiana", "Maine", "Maryland", "Massachusetts", "Michigan", "Minnesota", "Mississippi", "Missouri", "Montana", "Nebraska", "Nevada", "New Hampshire", "New Jersey", "New Mexico", "New York", "North Carolina", "North Dakota", "Ohio", "Oklahoma", "Oregon", "Pennsylvania", "Rhode Island", "South Carolina" , "South Dakota", "Tennessee", "Texas", "Utah", "Vermont", "Virginia", "Washington", "West Virginia", "Wisconsin", "Wyoming"]

#Dictionary for mapping Transmission Lines Geometry Dataframe Columns
COL_INDEX_MAP_TL = Dict(
    "code"           => 1,
    "structure_type" => 2,
    "company"        => 3,
    "state"          => 4,
    "n_circuits"     => 5,
    "n_ground_w"     => 6,
    "voltage_kv"     => 7,
    "Creep_Dist_mm_kv" => 8,
    "Insul_Creep_Dist_mm" => 9,
    "Insul_Spac_mm"    => 10,
    "L_Ins_String_ft"  => 11,
    #Coordinates Conductors circuit 1
    "ya1_ft"           => 12,
    "yb1_ft"           => 13,
    "yc1_ft"           => 14,
    "xa1_ft"           => 15,
    "xb1_ft"           => 16,
    "xc1_ft"           => 17,
    #Coordinates Ground wires
    "yg1_ft"           => 18,
    "xg1_ft"           => 19,
    "yg2_ft"           => 20,
    "xg2_ft"           => 21,
    #Coordinates Conductors circuit 2
    "ya2_ft"           => 22,
    "yb2_ft"           => 23,
    "yc2_ft"           => 24,
    "xa2_ft"           => 25,
    "xb2_ft"           => 26,
    "xc2_ft"           => 27
)

COL_INDEX_BORDERING_STATES = Dict(
    "number"             => 1,
    "state"              => 2,
    "abreviation"        => 3,
    "bordering_states"   => 4,
    "n_bordering_states" => 5
)

COL_INDEX_CONDUCTOR = Dict(
    "type"           => 1,
    "codeword"       => 2,
    "size_kcmil"     => 3,
    "stranding"      => 4,
    "diameter_inch"  => 5,
    "R_20dc_ohm_kft" => 6,
    "R_25ac_ohm_kft" => 7,
    "R_50ac_ohm_kft" => 8,
    "R_75AC_ohm_kft" => 9,
    "C_60Hz_Mohm_kft"=> 10,
    "L_60Hz_ohm_kft" => 11,
    "ampacity_a"     => 12
)


COL_INDEX_GROUND_WIRE = Dict(
    "type"               => 1,
    "awg"                => 2,
    "size_kcmil"         => 3,
    "wire_diameter_inch" => 4,
    "diameter_inch"      => 5,
    "breaking_load_lb"   => 6,
    "weight_lb_kft"      => 7,
    "R_20dc_ohm_kft"     => 8,
    "area_inches"        => 9
)



abstract type FiltersStructs end

abstract type FilterTLGeometry <: FiltersStructs end

abstract type FilterCables <: FiltersStructs end

abstract type FilterConductor <: FilterCables end

abstract type FilterGroundWire <: FilterCables end

#Struct for user filter of transmission lines geometries
mutable struct TLFilters <: FilterTLGeometry
    voltage_kv::Int
    n_circuits::Int
    n_ground_wire::Int
    state::Union{Vector{String}, Matrix{String}}
    structure_type::Union{Vector{String}, Matrix{String}}

 end

mutable struct ConductorFilterName <: FilterConductor
    type::Union{Vector{String}, Matrix{String}}
    codeword::Union{Vector{String}, Matrix{String}}
end

mutable struct ConductorFilterKcm <: FilterConductor
    type::Union{Vector{String}, Matrix{String}}
    kcmil::Union{Vector{Float64}, Matrix{Float64}}
end

mutable struct GroundWireFilterAWG <: FilterGroundWire
    type::Union{Vector{String}, Matrix{String}}
    awg::Union{Vector{String}, Matrix{String}}
end

mutable struct GroundWireFilterKcm <: FilterGroundWire
    type::Union{Vector{String}, Matrix{String}}
    kcmil::Union{Vector{Float64}, Matrix{Float64}}
end



#Structs part of Abstact type TransmissionLine
mutable struct TLBasicData
    voltage_kv::Float64
    n_circuits::Int
    n_ground_wire::Int
    state::String
    structure_type::String
    structure_code::String
    S_rated::Float64
    frequency::Float64
    distance::Float64
end

mutable struct TLGeometry
    n_cables::Int
    x_coordinates::Matrix{Float64}
    y_coordinates::Matrix{Float64}
end

mutable struct TLConductor
    type::String
    codeword::String
    bundling::Int
    bundlingspacing::Float64
    stranding::String
    kcmil::Float64
    diameter::Float64
    gmr::Float64
    Rac_tnom::Float64
    XLinternal::Float64
    XCinternal::Float64
    ampacity::Float64
    #weight::Float64 #-Could be interesting to add constraints
    #strenght::Float64 #-Could be interesting to add constraints
end

mutable struct TLGroundWire
    type::String
    awg::String
    kcmil::Float64
    diameter::Float64
    gmr::Float64
    Rdc_20::Float64
    XLinternal::Float64
    XCinternal::Float64
end

mutable struct ElectricalParameters
    combinations::Vector{Vector{Int64}}
    distances::Matrix{Float64}
    Zabcg::Matrix{Float64}          #Primitive Matrix
    Z_kron::Matrix{Float64}         #Kron reduced matrix
    Z012::Matrix{Float64}           #Sequence Matrix
    Zabcg_pu::Matrix{Float64}       #Primitive Matrix
    Z_kron_pu::Matrix{Float64}      #Kron reduced matrix
    Z012_pu::Matrix{Float64}        #Sequence Matrix
end

abstract type TransmissionLine end

mutable struct Line <: TransmissionLine
    basicdata::TLBasicData
    geometry::TLGeometry
    conductor::TLConductor
    groundw::TLGroundWire
    eparameters::ElectricalParameters
end