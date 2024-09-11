const DATA_SET_TL_VOLTAGES = [345 500 735]
const US_STATES_LIST_SHORT = ["AL","AK","AZ","AR","CA","CO","CT","DE","FL","GA","HI","ID","IL","IN","IA","KS","KY","LA","ME","MD","MA","MI","MN","MS","MO","MT","NE","NV","NH","NJ","NM","NY","NC","ND","OH","OK","OR","PA","RI","SC","SD","TN","TX","UT","VT","VA","WA","WV","WI","WY"]
const US_STATES_LIST       = ["Alabama", "Alaska", "Arizona", "Arkansas", "California", "Colorado", "Connecticut", "Delaware", "Florida", "Georgia", "Hawaii", "Idaho", "Illinois", "Indiana", "Iowa", "Kansas", "Kentucky", "Louisiana", "Maine", "Maryland", "Massachusetts", "Michigan", "Minnesota", "Mississippi", "Missouri", "Montana", "Nebraska", "Nevada", "New Hampshire", "New Jersey", "New Mexico", "New York", "North Carolina", "North Dakota", "Ohio", "Oklahoma", "Oregon", "Pennsylvania", "Rhode Island", "South Carolina" , "South Dakota", "Tennessee", "Texas", "Utah", "Vermont", "Virginia", "Washington", "West Virginia", "Wisconsin", "Wyoming"]

#Dictionary for mapping Transmission Lines Geometry Dataframe Columns
const COL_INDEX_MAP_TL = Dict(
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

#Struct for user filter of transmission lines geometries
mutable struct TLFilters
    voltage_kv::Int
    n_circuits::Int
    n_ground_wire::Int
    state::Union{Vector{String}, Matrix{String}}
    structure_type::Union{Vector{String}, Matrix{String}}
end

struct TLBasicData
    voltage_kv::Int
    n_circuits::Int
    n_ground_wire::Int
    state::String
    structure_type::String
end
struct TLGeometry
    x_coordinates::Matrix{Float64}
    y_coordinates::Matrix{Float64}
end

struct TLConductor
    type::String
    name::String
    stranding::String
    diameter::Float64
    gmr::Float64
    #conductor_selfL::Float64
    bundling::Int
    bundlingspacing::Float64
end

struct TLGroundWire
    type::String
    stranding::String
    diameter::Float64
    gmr::Float64
    #conductor_selfL::Float64
end

struct ElectricalParameters
end

abstract type TransmissionLine end

struct Line <: TransmissionLine
    basicdata::TLBasicData
    geometry::TLGeometry
    conductor::TLConductor
    groundw::TLGroundWire
    eparameters::ElectricalParameters
end