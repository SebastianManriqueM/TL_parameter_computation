include("definitions.jl")

#|------------------------------------------------|
#|--------------GET DF COL FUNCTIONS--------------|
#|________________________________________________|
function get_df_col_index( 
    user_filter::Union{ConductorFilterKcm, ConductorFilterName},
    key_df_column::String
    )
    return COL_INDEX_CONDUCTOR[ key_df_column ]
end

function get_df_col_index( 
    user_filter::Union{GroundWireFilterKcm, GroundWireFilterAWG},
    key_df_column::String
    )
    return COL_INDEX_GROUND_WIRE[ key_df_column ]
end


#|------------------------------------------------|
#|-----------CHECK INDEX AND DIMENSSIONS----------|
#|________________________________________________|
function check_index_df_rows( 
    index::Int, 
    df::DataFrame, 
    function_name 
    )
    n_rows_df = nrow(df)
    if n_rows_df < 1
        error( "Please review DataFrame argument provided to $function_name() function, it has no data." )
    elseif index > n_rows_df
        @warn( "rowindex=$index provided to $function_name() function, exceeds dataframe index. It was changed to $n_rows_df" )
        index = n_rows_df
    end
    return index
end


#|------------------------------------------------|
#|------------SINGLE FILTERS FUNCTIONS------------|
#|________________________________________________|

function get_df_single_str_filter( 
    df::DataFrame, 
    user_filter::TLFilters, 
    key_df_column::String="state" 
    )
    index_df = COL_INDEX_MAP_TL[ key_df_column ]
    if occursin( strip( lowercase("state") ) , strip( lowercase(key_df_column) ) )
        user_filter_str_v = user_filter.state
    elseif occursin( strip( lowercase("structure_type") ) , strip( lowercase(key_df_column) ) )
        user_filter_str_v = user_filter.structure_type
    else
        @error("Please arguments provided to $(nameof(var"#self#")) function. In this case, it was expected a TL Geometry DataFrame and you can set 'key_df_column' argument as 'state' or 'structure_type'.")
    end
    # Define the filtering function
    # **This filter has a Bug for STATES since "Kansas" is a substring of "Arkansas"
    filter_func( row ) = any( s -> occursin( strip( lowercase(s) ), coalesce( strip(lowercase(row[index_df])) ) ), user_filter_str_v )
    return filter(filter_func, df)
end


function get_df_single_str_filter( 
    df::DataFrame, 
    user_filter::Union{ConductorFilterName, GroundWireFilterAWG},
    key_df_column::String = "type" 
    )
    index_df = get_df_col_index( user_filter, key_df_column )
    if occursin( strip( lowercase("type") ) , strip( lowercase(key_df_column) ) )
        user_filter_str_v = user_filter.type
    elseif occursin( strip( lowercase("codeword") ) , strip( lowercase(key_df_column) ) )
        user_filter_str_v = user_filter.codeword
    elseif occursin( strip( lowercase("awg") ) , strip( lowercase(key_df_column) ) )
        user_filter_str_v = user_filter.awg
    else
        @error("Please arguments provided to $(nameof(var"#self#")) function. In this case, it was expected a Conductors DataFrame and you can set 'key_df_column' argument as 'type' or 'name'.")
    end
    # Define the filtering function
    filter_func( row ) = any( s -> strip( lowercase(s) ) == coalesce( strip(lowercase(row[index_df])) ) , user_filter_str_v )
    return filter(filter_func, df)
end



function get_df_single_str_filter( 
    df::DataFrame, 
    user_filter::Union{ConductorFilterKcm, GroundWireFilterKcm },
    key_df_column::String = "type" 
    )
    index_df = get_df_col_index( user_filter, key_df_column )

    if occursin( strip( lowercase("type") ) , strip( lowercase(key_df_column) ) )
        user_filter_v = user_filter.type
        filter_func( row ) = any( s -> strip( lowercase(s) ) == coalesce( strip(lowercase(row[index_df])) ) , user_filter_v )
        filtered_df = filter(filter_func, df)
    elseif occursin( strip( lowercase(key_df_column) ) , strip( lowercase("size_kcmil") ) )
        user_filter_v = user_filter.kcmil
        filter_func2( row ) = any( s -> s == row[index_df] , user_filter_v )
        filtered_df = filter(filter_func2, df)
    else
        @error("Please arguments provided to $(nameof(var"#self#")) function. In this case, it was expected a Conductors DataFrame and you can set 'key_df_column' argument as 'type' or 'size_kcmil'.")
    end
    
    return filtered_df
end



function get_gmr_from_diameter_inch(
    diameter_inch::Float64, 
    )
    return ℯ^(-1/4) * (0.5 * diameter_inch) * FACTOR_FT_INCH
end

#GMR RETURNS IN FEET, AND XL SHOULD BE GIVEN IN OHM/KFT AND FREQUENCY IN HZ
function get_gmr_from_XL(
    XL::Float64, 
    frequency::Float64
    )
    return 1/ℯ^( (XL / FACTOR_MILES_KFT) / (L_CONST_OHM_MILE*frequency) )
end

#XL RETURN IN OHM/KFT AND GMR SHOULD BE GIVEN IN FT.
function get_XL_from_gmr(
    gmr::Float64,
    frequency::Float64 
    )
    return frequency * L_CONST_OHM_MILE * log(1/gmr) * FACTOR_MILES_KFT #Ohm/kft
end

#r equivalent for Capacitance calc. RETURNS IN FEET, AND XL SHOULD BE GIVEN IN OHM/KFT AND FREQUENCY IN HZ
function get_req_from_XC(
    XC::Float64, 
    frequency::Float64
    )
    return 1/ℯ^( ( XC * frequency * FACTOR_MILES_KFT )/( XC_FACTOR_MOHM_MILE ) )
end

function get_distance_xy( 
    x::Union{Matrix{Float64}, Vector{Float64}},
    y::Union{Matrix{Float64}, Vector{Float64}} 
    )
    return sqrt( ( x[1] - x[2] )^2 + ( y[1] - y[2] )^2 )
end