#|------------------------------------------------|
#|-----------API FOR USER GET CONDUCTOR-----------|
#|________________________________________________|

"""
    get_ground_wire(
        type_v::StringArrayFilteringData, 
        codename_or_kcm_v::CableSpecificFilteringData,
        tl_basicdata::TLBasicData,
        df_ground_wires::DataFrame;
        rowindex::Int = 1
    ) -> GroundWire

Retrieve the ground wire data for a given transmission line based on specified type and name filters.

# Arguments
- `type_v`: Vector or Matrix of strings specifying the type(s) of ground wire.
- `codename_or_kcm_v`: Vector or Matrix containing wire names as strings or numerical identifiers.
- `tl_basicdata`: Struct containing basic transmission line data.
- `df_ground_wires`: DataFrame containing available ground wire data.
- `rowindex`: (Optional) Integer index specifying the row to extract, defaults to `1`.

# Returns
- `GroundWire`: A struct containing the selected ground wire data.

# Description
This function applies filtering criteria based on `type_v` (Alumoweld, ACSR, etc) and `codename_or_kcm_v` (Codename or kcm). It returns a struct with the relevan ground wire records from `df_ground_wires`.

"""
function get_ground_wire(
    type_v::StringArrayFilteringData, 
    codename_or_kcm_v::CableSpecificFilteringData,
    tl_basicdata::TLBasicData,
    df_ground_wires::DataFrame;
    rowindex::Int = 1 
)
    ground_w_filter = get_struct_ground_wire_filters( type_v, codename_or_kcm_v )
    filt_ground_w_df = get_tl_ground_wire( df_ground_wires, ground_w_filter )


    tl_ground_wire = get_ground_w(
                        filt_ground_w_df, 
                        tl_basicdata,
                        rowindex = rowindex
                        )
                        
    return tl_ground_wire
end

#|------------------------------------------------|
#|----------GET STRUCT FILTERS FUNCTIONS----------|
#|________________________________________________|

function get_struct_ground_wire_filters( 
    type::StringArrayFilteringData, 
    awg::StringArrayFilteringData 
    )::GroundWireFilterAWG

    return GroundWireFilterAWG( type, awg )
end

function get_struct_ground_wire_filters( 
    type::StringArrayFilteringData, 
    kcm::FloatArrayFilteringData 
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
#|------------GET TL GROUND WIRE STRUCT-----------|
#|________________________________________________|

function get_ground_w( 
    df::DataFrame,
    basicdata::TLBasicData;
    rowindex::Int = 1 
    )::TLGroundWire

    rowindex = check_index_df_rows( rowindex, df, nameof(var"#self#") )

    type      = df[ rowindex, COL_INDEX_GROUND_WIRE["type"] ]
    awg       = df[ rowindex, COL_INDEX_GROUND_WIRE["awg"] ]
    kcmil     = df[ rowindex, COL_INDEX_GROUND_WIRE["size_kcmil"] ]
    diameter  = df[ rowindex, COL_INDEX_GROUND_WIRE["diameter_inch"] ]
    gmr       = get_gmr_from_diameter_inch(diameter)                    #GMR in feet
    Rdc_20    = df[ rowindex, COL_INDEX_GROUND_WIRE["R_20dc_ohm_kft"] ]
    XLinternal = get_XL_from_gmr(gmr, basicdata.frequency)                                   #XLinternal in ohm/kfeet
    XCinternal = 0

    return TLGroundWire( type, awg, kcmil, diameter, gmr, Rdc_20, XLinternal, XCinternal )
end

