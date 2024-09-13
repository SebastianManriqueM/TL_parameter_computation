include("definitions.jl")

function get_struct_conductorfilters( type::Union{Vector{String}, Matrix{String}}, name::Union{Vector{String}, Matrix{String}} )::ConductorFilterName
    return ConductorFilterName( type, name )
end

function get_struct_conductorfilters( type::Union{Vector{String}, Matrix{String}}, kcm::Union{Vector{Float64}, Matrix{Float64}} )::ConductorFilterKcm
    return ConductorFilterKcm( type, kcm )
end

function get_df_single_str_filter( df::DataFrame, user_filter::ConductorFilterName, key_df_column::String="type" )
    index_df = COL_INDEX_CONDUCTOR[ key_df_column ]
    if occursin( strip( lowercase("type") ) , strip( lowercase(key_df_column) ) )
        user_filter_str_v = user_filter.type
    elseif occursin( strip( lowercase("codeword") ) , strip( lowercase(key_df_column) ) )
        user_filter_str_v = user_filter.codeword
    else
        @error("Please arguments provided to $(nameof(var"#self#")) function. In this case, it was expected a Conductors DataFrame and you can set 'key_df_column' argument as 'type' or 'name'.")
    end
    # Define the filtering function
    filter_func( row ) = any( s -> strip( lowercase(s) ) == coalesce( strip(lowercase(row[index_df])) ) , user_filter_str_v )
    return filter(filter_func, df)
end

function get_df_single_str_filter( df::DataFrame, user_filter::ConductorFilterKcm, key_df_column::String="type" )
    index_df = COL_INDEX_CONDUCTOR[ key_df_column ]
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


function get_tl_conductor( df::DataFrame, user_filter::ConductorFilterName )
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

function get_tl_conductor( df::DataFrame, user_filter::ConductorFilterKcm )
    #conductor_type - AAC, ACSR, AAAC, ACAR, ACCC
    filt_df = get_df_single_str_filter( df, user_filter, "type" )
    if nrow(filt_df) < 2
        @warn( "Currently, there is only one $(user_filter.conductor_type) conductor type. Other filters were neglected." )
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
