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