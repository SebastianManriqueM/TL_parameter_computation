include("definitions.jl")
include("common_filters.jl")

#|------------------------------------------------|
#|----------GET STRUCT FILTERS FUNCTIONS----------|
#|________________________________________________|

function get_struct_conductor_filters( 
    type::Union{Vector{String}, Matrix{String}}, 
    name::Union{Vector{String}, Matrix{String}} 
    )::ConductorFilterName

    return ConductorFilterName( type, name )
end

function get_struct_conductor_filters( 
    type::Union{Vector{String}, Matrix{String}}, 
    kcm::Union{Vector{Float64}, Matrix{Float64}} 
    )::ConductorFilterKcm

    return ConductorFilterKcm( type, kcm )
end


#|------------------------------------------------|
#|--------GET FILTERED DATAFRAME FUNCTIONS--------|
#|________________________________________________|
function get_tl_conductor( 
    df::DataFrame, 
    user_filter::ConductorFilterName 
    )

    #conductor_type - AAC, ACSR, AAAC, ACAR, ACCC
    filt_df = get_df_single_str_filter( df, user_filter, "type" )
    if nrow(filt_df) < 2
        @warn( "Currently, there is only one $(user_filter.conductor_type) conductor type. Other filters were neglected." )
        return filt_df
    end

    #Conductor codeword
    filt_df2   = get_df_single_str_filter( filt_df, user_filter, "codeword" )
    if nrow(filt_df2) < 1
        @warn( "Currently there is no a conductor that match all the selected criteria. It was applied just conductor type filter of $(user_filter.type)." )
        return filt_df
    end
    filt_df = filt_df2

    return filt_df
end

function get_tl_conductor( 
    df::DataFrame, 
    user_filter::ConductorFilterKcm 
    )

    #conductor_type - AAC, ACSR, AAAC, ACAR, ACCC
    filt_df = get_df_single_str_filter( df, user_filter, "type" )
    if nrow(filt_df) < 2
        @warn( "Currently, there is only one $(user_filter.type) conductor type. Other filters were neglected." )
        return filt_df
    end

    #Conductor codeword
    filt_df2   = get_df_single_str_filter( filt_df, user_filter, "size_kcmil" )
    if nrow(filt_df2) < 1
        @warn( "Currently there is no a conductor that match all the selected criteria. It was applied just conductor type filter of $(user_filter.type)." )
        return filt_df
    end
    filt_df = filt_df2

    return filt_df
end




#|------------------------------------------------|
#|-------------GET TL CONDUCTOR STRUCT------------|
#|________________________________________________|

function get_regpoly_xy_coord( 
    n_bundling::Int,
    bundlingspacing::Float64
    )

    x_coords = zeros(Float64, 1, n_bundling)
    y_coords = zeros(Float64, 1, n_bundling)

    radius = bundlingspacing / ( 2 * sin( π/n_bundling ) )
    angle_increment = 2 * π / n_bundling

    for i in 0:( n_bundling - 1 )
        angle         = i * angle_increment
        x_coords[i+1] = radius * cos(angle)
        y_coords[i+1] = radius * sin(angle)
    end

    return x_coords, y_coords, radius
end

function get_gmr_bundling_xy( 
    X1::Matrix{Float64}, 
    Y1::Matrix{Float64},
    r::Float64, 
    gmr_cable::Float64 = r * 1/exp(1/4) #K_gmr = 1/exp(1/4)    # This is for solid/compact conductors. For Stranded see IEC 60287-1-3
    )
    
    GMR_bundle = 1
    n     = length( X1 )
    for i = 1 : n
        for j = 1 : n
            if i == j 
                GMR_bundle = GMR_bundle * gmr_cable
                continue
            end
            GMR_bundle = GMR_bundle * get_distance_xy( [ X1[i] X1[j] ], [ Y1[i] Y1[j] ] )#get_distance_p1p2( [ X1[i] Y1[i] ], [ X1[j] Y1[j] ] )
        end
    end
    return GMR_bundle^( 1 / (n * n) )
end

function get_conductor( 
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
    
    XLintrenal      = df[ rowindex, COL_INDEX_CONDUCTOR["L_60Hz_ohm_kft"] ]
    gmr             = get_gmr_from_XL(XLintrenal, basicdata.frequency)
    XCinternal      = df[ rowindex, COL_INDEX_CONDUCTOR["C_60Hz_Mohm_kft"] ]
    ampacity        = df[ rowindex, COL_INDEX_CONDUCTOR["ampacity_a"] ]

    #   BUNDLING TREATMENT
    bundling_xcoord, bundling_ycoord, radius = get_regpoly_xy_coord( bundling , bundlingspacing * FACTOR_FT_INCH )
    gmr_bundling = get_gmr_bundling_xy( bundling_xcoord, bundling_ycoord, radius, gmr )
    XL_bundling = L_CONST_OHM_MILE * basicdata.frequency * log( 1/gmr_bundling ) * FACTOR_MILES_KFT #ohm/kft
    XC_bundling = 0.0 #ohm/kft
    ampacity_bundling = bundling * ampacity   #Amperes
    
    return TLConductor( type, codeword, stranding, kcmil, diameter, gmr, Rac_tnom, XLintrenal, XCinternal, ampacity, bundling, bundlingspacing, bundling_xcoord, bundling_ycoord, gmr_bundling, XL_bundling, XC_bundling, ampacity_bundling )
end

