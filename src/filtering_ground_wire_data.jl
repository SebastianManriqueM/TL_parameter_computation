include("definitions.jl")
include("common_filters.jl")

#|------------------------------------------------|
#|----------GET STRUCT FILTERS FUNCTIONS----------|
#|________________________________________________|

function get_struct_ground_wire_filters( 
    type::Union{Vector{String}, Matrix{String}}, 
    awg::Union{Vector{String}, Matrix{String}} 
    )::GroundWireFilterAWG

    return GroundWireFilterAWG( type, awg )
end

function get_struct_ground_wire_filters( 
    type::Union{Vector{String}, Matrix{String}}, 
    kcm::Union{Vector{Float64}, Matrix{Float64}} 
    )::GroundWireFilterKcm

    return GroundWireFilterKcm( type, kcm )
end



#|------------------------------------------------|
#|--------GET FILTERED DATAFRAME FUNCTIONS--------|
#|________________________________________________|

function get_tl_ground_wire( 
    df::DataFrame, 
    user_filter::GroundWireFilterAWG 
    )

    filt_df = get_df_single_str_filter( df, user_filter, "type" )
    if nrow(filt_df) < 2
        @warn( "Currently, there is only one $(user_filter.type) ground wire type. Other filters were neglected." )
        return filt_df
    end

    #Conductor codeword
    filt_df2   = get_df_single_str_filter( filt_df, user_filter, "awg" )
    if nrow(filt_df2) < 1
        @warn( "Currently there is no a ground wire that match all the selected criteria. It was applied just ground wire type filter of $(user_filter.type)." )
        return filt_df
    end
    filt_df = filt_df2

    return filt_df
end



function get_tl_ground_wire( 
    df::DataFrame, 
    user_filter::GroundWireFilterKcm 
    )

    #conductor_type - AAC, ACSR, AAAC, ACAR, ACCC
    filt_df = get_df_single_str_filter( df, user_filter, "type" )
    if nrow(filt_df) < 2
        @warn( "Currently, there is only one $(user_filter.type) ground wire type. Other filters were neglected." )
        return filt_df
    end

    #Conductor codeword
    filt_df2   = get_df_single_str_filter( filt_df, user_filter, "size_kcmil" )
    if nrow(filt_df2) < 1
        @warn( "Currently there is no a ground wire that match all the selected criteria. It was applied just ground wire type filter of $(user_filter.type)." )
        return filt_df
    end
    filt_df = filt_df2

    return filt_df
end



#|------------------------------------------------|
#|-------------GET TL CONDUCTOR STRUCT------------|
#|________________________________________________|

#=struct TLGroundWire
    type::String
    awg::String
    kcmil::Float64
    diameter::Float64
    gmr::Float64
    Rac_75::Float64
    Linternal::Float64
    Cinternal::Float64
end=#

function get_ground_wire_data( 
    df::DataFrame, 
    basicdata::TLBasicData, 
    bundling::Int = 0, 
    bundlingspacing::Float64 = 18.0, 
    rowindex::Int = 1 
    )::TLConductor

    rowindex = check_index_df_rows( rowindex, df, nameof(var"#self#") )
    if bundling == 0
        if basicdata.voltage_kv > 700
            bundling = 4
        elseif basicdata.voltage_kv > 345
            bundling = 3
        elseif basicdata.voltage_kv > 138
            bundling = 2
        else
            bundling = 1
        end
    end

    type            = df[ rowindex, COL_INDEX_CONDUCTOR["type"] ]
    codeword        = df[ rowindex, COL_INDEX_CONDUCTOR["codeword"] ]
    stranding       = df[ rowindex, COL_INDEX_CONDUCTOR["stranding"] ]
    kcmil           = df[ rowindex, COL_INDEX_CONDUCTOR["size_kcmil"] ]
    diameter        = df[ rowindex, COL_INDEX_CONDUCTOR["diameter_inch"] ] 

    if df[ rowindex, COL_INDEX_CONDUCTOR["R_75AC_ohm_kft"] ] > 0
        Rac_tnom    = df[ rowindex, COL_INDEX_CONDUCTOR["R_75AC_ohm_kft"] ]
    elseif df[ rowindex, COL_INDEX_CONDUCTOR["R_50AC_ohm_kft"] ] > 0
        Rac_tnom    = df[ rowindex, COL_INDEX_CONDUCTOR["R_50AC_ohm_kft"] ]
        @warn("There is no resistance data at 75 degrees for the $(df[ rowindex, COL_INDEX_CONDUCTOR["type"] ]) $(df[ rowindex, COL_INDEX_CONDUCTOR["codeword"] ]) conductor. It was used the value at 50 degrees.")
    elseif df[ rowindex, COL_INDEX_CONDUCTOR["R_25AC_ohm_kft"] ] > 0
        Rac_tnom    = df[ rowindex, COL_INDEX_CONDUCTOR["R_25AC_ohm_kft"] ]
        @warn("There is no resistance data at 75 degrees for the $(df[ rowindex, COL_INDEX_CONDUCTOR["type"] ]) $(df[ rowindex, COL_INDEX_CONDUCTOR["codeword"] ]) conductor. It was used the value at 25 degrees.")
    else
        @error("There is no resistance for the $(df[ rowindex, COL_INDEX_CONDUCTOR["type"] ]) $(df[ rowindex, COL_INDEX_CONDUCTOR["codeword"] ]) conductor.")
    end
    
    Lintrenal       = df[ rowindex, COL_INDEX_CONDUCTOR["L_60Hz_ohm_kft"] ]
    gmr             = 1/( ℯ^(Lintrenal) )
    Cinternal       = df[ rowindex, COL_INDEX_CONDUCTOR["C_60Hz_Mohm_kft"] ]
    ampacity        = df[ rowindex, COL_INDEX_CONDUCTOR["ampacity_a"] ]

    return TLConductor( type, codeword, bundling, bundlingspacing, stranding, kcmil, diameter, gmr, Rac_tnom, Lintrenal, Cinternal, ampacity )
end

