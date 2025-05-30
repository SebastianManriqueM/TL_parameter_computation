#|------------------------------------------------|
#|-----------API FOR USER GET CONDUCTOR-----------|
#|________________________________________________|


"""
    get_conductor( 
        type_v::StringArrayFilteringData, 
        codename_or_kcm_v::CableSpecificFilteringData,
        df_conductors::DataFrame,
        tl_basicdata::TLBasicData;
        bundling::Int = 0, 
        bundlingspacing::Float64 = 18.0, 
        rowindex::Int = 1 
    ) -> Conductor

Retrieve phase conductor data based on specified filtering criteria and transmission line characteristics.

# Arguments
- `type_v`: Filtering data specifying the conductor type(s).
- `codename_or_kcm_v`: Filtering data for conductor codename or kcmil rating.
- `df_conductors`: DataFrame containing available conductor records.
- `tl_basicdata`: Struct with fundamental transmission line data.
- `bundling`: (Optional) Integer specifying the number of bundled conductors per phase, defaults to `0` (single conductor).
- `bundlingspacing`: (Optional) Spacing between bundled conductors in inches, defaults to `18.0`.
- `rowindex`: (Optional) Integer index specifying which row to extract from the filtered data, defaults to `1`.

# Returns
- `Conductor`: A struct containing the selected phase conductor data.

# Description
This function filters `df_conductors` using `type_v` (AAC, AAAC, ACSR ACAR, etc) and `codename_or_kcm_v` (Codename-Bluejay,Kiwi...- or kcm). It returns the struct with the relevant conductor records.

"""
function get_conductor( 
    type_v::StringArrayFilteringData, 
    codename_or_kcm_v::CableSpecificFilteringData,
    df_conductors::DataFrame,
    tl_basicdata::TLBasicData;
    bundling::Int = 0, 
    bundlingspacing::Float64 = 18.0, 
    rowindex::Int = 1 
 )
    conductor_filter = get_struct_conductor_filters( type_v, codename_or_kcm_v )
    filt_conductor_df = get_tl_conductor( df_conductors, conductor_filter )
    tl_conductor = get_phase_conductor( 
                    filt_conductor_df, 
                    tl_basicdata; 
                    bundling = bundling,
                    bundlingspacing = bundlingspacing,
                    rowindex = rowindex
                     )
                   
    return tl_conductor
end
#|------------------------------------------------|
#|----------GET STRUCT FILTERS FUNCTIONS----------|
#|________________________________________________|

function get_struct_conductor_filters( 
    type::StringArrayFilteringData, 
    name::StringArrayFilteringData 
    )::ConductorFilterName

    return ConductorFilterName( type, name )
end

function get_struct_conductor_filters( 
    type::StringArrayFilteringData, 
    kcm::FloatArrayFilteringData 
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



function get_phase_conductor( 
    df::DataFrame, 
    basicdata::TLBasicData; 
    bundling::Int = 0, 
    bundlingspacing::Float64 = 18.0, 
    rowindex::Int = 1 
    )::TLConductor

    rowindex = check_index_df_rows( rowindex, df, nameof(var"#self#") )
    if bundling == 0
        if basicdata.voltage_kv > 700.0
            bundling = 4
        elseif basicdata.voltage_kv > 345.0
            bundling = 3
        elseif basicdata.voltage_kv > 138.0
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
    
    XLinternal      = df[ rowindex, COL_INDEX_CONDUCTOR["L_60Hz_ohm_kft"] ]
    gmr             = get_gmr_from_XL(XLinternal, basicdata.frequency)
    XCinternal      = df[ rowindex, COL_INDEX_CONDUCTOR["C_60Hz_Mohm_kft"] ]
    ampacity        = df[ rowindex, COL_INDEX_CONDUCTOR["ampacity_a"] ]

    #   BUNDLING TREATMENT
    bundling_xcoord, bundling_ycoord, radius = get_regpoly_xy_coord( bundling , bundlingspacing * FACTOR_FT_INCH )
    
    gmr_bundling = get_gmr_bundling_xy( bundling_xcoord, bundling_ycoord, radius, gmr )
    XL_bundling  = L_CONST_OHM_MILE * basicdata.frequency * log( 1/gmr_bundling ) * FACTOR_MILES_KFT #ohm/kft

    r_ft_c          = get_req_from_XC(XCinternal, basicdata.frequency )#diameter * 0.5 * FACTOR_FT_INCH
    r_ft_c_bundling = get_gmr_bundling_xy( bundling_xcoord, bundling_ycoord, radius, r_ft_c )
   
    XC_bundling     = ( XC_FACTOR_MOHM_MILE / basicdata.frequency ) * log( 1 / r_ft_c_bundling ) / FACTOR_MILES_KFT #Mohm*kft

    ampacity_bundling = bundling * ampacity   #Amperes
    
    return TLConductor( type, codeword, stranding, kcmil, diameter, gmr, Rac_tnom, XLinternal, XCinternal, ampacity, bundling, bundlingspacing, bundling_xcoord, bundling_ycoord, gmr_bundling, XL_bundling, r_ft_c_bundling, XC_bundling, ampacity_bundling )
end

