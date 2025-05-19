#|------------------------------------------------|
#|--------------ALIAS FOR INPUT DATA--------------|
#|________________________________________________|
StringArrayFilteringData = Union{Vector{<:AbstractString}, Matrix{<:AbstractString}}
FloatArrayFilteringData = Union{Vector{Float64}, Matrix{Float64}}
CableSpecificFilteringData = Union{StringArrayFilteringData, FloatArrayFilteringData}


#|------------------------------------------------|
#|-------------CONSTANTS AND FACTORS--------------|
#|________________________________________________|

FACTOR_FT_MT         = 3.2808399
FACTOR_FT_INCH       = 1.0 / 12.0
FACTOR_MILES_KFT     = 1.0 / 5.28
FACTOR_KFT_FT        = 1 / 1000

R_CONST_OHM_MILE     = 0.00158836
L_CONST_OHM_MILE     = 0.00202237
L_FACTOR_OHM_MILE    = 7.6786
XC_FACTOR_MOHM_MILE  = 1.779 #Stevenson p.176
XC_FACTOR_MOHM_KFT   = 9.39312 #Stevenson p.176

ϵ_REL_AIR_F_m        = 1
ϵ_0_F_METER          = 8.85e-12
ϵ_AIR_μF_MILE        = 1.4240e-2

#|------------------------------------------------|
#|---------------CONSTANT VECTORS-----------------|
#|________________________________________________|
DATA_SET_TL_VOLTAGES = [33 230 255 345 500 765]
US_STATES_LIST_SHORT = ["AL","AK","AZ","AR","CA","CO","CT","DE","FL","GA","HI","ID","IL","IN","IA","KS","KY","LA","ME","MD","MA","MI","MN","MS","MO","MT","NE","NV","NH","NJ","NM","NY","NC","ND","OH","OK","OR","PA","RI","SC","SD","TN","TX","UT","VT","VA","WA","WV","WI","WY"]
US_STATES_LIST       = ["Alabama", "Alaska", "Arizona", "Arkansas", "California", "Colorado", "Connecticut", "Delaware", "Florida", "Georgia", "Hawaii", "Idaho", "Illinois", "Indiana", "Iowa", "Kansas", "Kentucky", "Louisiana", "Maine", "Maryland", "Massachusetts", "Michigan", "Minnesota", "Mississippi", "Missouri", "Montana", "Nebraska", "Nevada", "New Hampshire", "New Jersey", "New Mexico", "New York", "North Carolina", "North Dakota", "Ohio", "Oklahoma", "Oregon", "Pennsylvania", "Rhode Island", "South Carolina" , "South Dakota", "Tennessee", "Texas", "Utah", "Vermont", "Virginia", "Washington", "West Virginia", "Wisconsin", "Wyoming"]

#|------------------------------------------------|
#|----------------CONSTANT DICTS------------------|
#|________________________________________________|
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
    "R_25AC_ohm_kft" => 7,
    "R_50AC_ohm_kft" => 8,
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


#|------------------------------------------------|
#|--------------------SRUCTS----------------------|
#|________________________________________________|

#----FILTERS----
abstract type AbstractFiltersStructs end

abstract type AbstractFilterTLGeometry <: AbstractFiltersStructs end

abstract type AbstractCablesFilter <: AbstractFiltersStructs end

abstract type ConductorFilter <: AbstractCablesFilter end

abstract type GroundWireFilter <: AbstractCablesFilter end

#----TRANSMISSION LINE COMPONENT, CATA AND PARAMETERS----
abstract type AbstractTLPhysicalComponent end
abstract type AbstractTLCable <: AbstractTLPhysicalComponent end
abstract type AbstractTLParameters end

abstract type AbstractTransmissionLine end

abstract type AbstractTLExamples end