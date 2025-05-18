#|------------------------------------------------|
#|-----------API FOR USER GET CONDUCTOR-----------|
#|________________________________________________|
function get_transmission_line_geometry(
    voltage::Float64,
    df_tl_geometry::DataFrame;
    n_circuits::Int=1, 
    n_ground_wires::Int=2, 
    v_str_states::Union{Vector{String}, Matrix{String}}=[""], 
    v_str_structure_types::Union{Vector{String}, Matrix{String}}=[""],
)
     #Set TL filtering options
    tl_filter = get_user_filter_tl_geometry(
                            voltage; #voltage
                            n_circuits = n_circuits,
                            n_ground_wires = n_ground_wires,
                            v_str_states = v_str_states,
                            v_str_structure_types = v_str_structure_types
                            )

    #println("FILTER ONLY ONE STATE: $(tl_filter.state)")
    filt_tl_df = get_tl_df_all_filters(df_tl_geometry, tl_filter)

    tl_basicdata = get_tl_basicdata( filt_tl_df )
    tl_geometry = get_tl_geometry( filt_tl_df, tl_basicdata )

    return tl_basicdata, tl_geometry
end


#|------------------------------------------------|
#|----------GET STRUCT FILTERS FUNCTIONS----------|
#|________________________________________________|
function get_user_filter_tl_geometry( 
    voltage::Float64; 
    n_circuits::Int=1, 
    n_ground_wires::Int=2, 
    v_str_states::Union{Vector{String}, Matrix{String}}=[""], 
    v_str_structure_types::Union{Vector{String}, Matrix{String}}=[""]
    )::TLFilters
    return TLFilters( voltage, n_circuits, n_ground_wires, v_str_states, v_str_structure_types )
end


#|------------------------------------------------|
#|--------GET FILTERED DATAFRAME FUNCTIONS--------|
#|________________________________________________|
function check_voltage_availability( value )
    for element in DATA_SET_TL_VOLTAGES
        if element == value
            return true
        end
    end
    return false
end

function clear_string_v_lead_trail_spaces!( 
    string_v::Union{Vector{String}, Matrix{String}, Vector{SubString{String}}} 
    )
    i = 1
    for string in string_v
        string_v[i] = strip( string )
        i = i + 1
    end
end

function compare_index_v_dimension( 
    index::Int, 
    vector , 
    function_name
    )
    if index > length( vector )
        len = length( vector )
        @warn("Index given for $(function_name) was modified from $index to $len because it exceeds the dimension of the vector.")
        index = len
    elseif index < 1
        @warn("Index given for $(function_name) was modified from $index to 1 because it exceeds the dimension of the vector.")
        index = 1
    end
    return index
end

#For now it only works for one position
function get_bordering_states( 
    df_us_states::DataFrame, 
    user_filter::TLFilters, 
    index::Int = 1 
    )

    #Check index is between the user_filter.state Vector limits
    index_checked = compare_index_v_dimension( index, user_filter.state, nameof(var"#self#"))
    
    if index != index_checked 
        @warn("Function $(nameof(var"#self#")) is returning the neighboring states of $(user_filter.state[index_checked])")
    end

    if ( user_filter.state[index_checked] == "" )
        @error("Check TLFilters.state[index]. It is not possible to obtain bordering states becuase that filter property has no value.")
    end

    #Find Bordering states using df_us_states
    for row in eachrow(df_us_states)
        if strip( lowercase(user_filter.state[index_checked]) ) == strip( lowercase( row[ COL_INDEX_BORDERING_STATES["state"] ] ) )
            bordering_states_v = split( row[ COL_INDEX_BORDERING_STATES["bordering_states"] ], ',')
            clear_string_v_lead_trail_spaces!( bordering_states_v )
            return bordering_states_v
        end
    end
    @error( "$(user_filter.state[index_checked]) was not found to obtain its bordering states. Check TLFilters.state[index]"  )
end

function get_filter_with_neighboring_states!( 
    user_filter::TLFilters, 
    df_us_states::DataFrame, 
    index::Int = 1 
    )
    bord_states = get_bordering_states( df_us_states, user_filter, index )
    append!( user_filter.state, bord_states )
end


function get_voltage_filtered_tl_df( 
    df::DataFrame, 
    user_filter::TLFilters 
    )
    if !(check_voltage_availability( user_filter.voltage_kv ))
        error("The current data set does not include information of Tower Geometries for $(user_filter.voltage_kv) kV. The dataset includes information for the following voltage levels (kV): $DATA_SET_TL_VOLTAGES")
    end
    return filter( row -> row[:voltage_kv] == user_filter.voltage_kv, df)
end




"""
get_tl_df_all_filters(df::DataFrame, user_filter::TLFilters) -> DataFrame

Apply multiple filters to a DataFrame containing transmission line (TL) geometries based on user-defined criteria.

# Arguments
- `df::DataFrame`: The input DataFrame containing TL geometries.
- `user_filter::TLFilters`: A struct containing the filter criteria, including voltage level, number of circuits, number of ground wires, and state.

    mutable struct TLFilters
        voltage_kv::Int
        n_circuits::Int
        n_ground_wire::Int
        state::Union{Vector{String}, Matrix{String}}
        structure_type::Union{Vector{String}, Matrix{String}}
    end

# Returns
- `DataFrame`: A filtered DataFrame that matches the specified criteria.

# Filtering Process
1. **voltage_kv::Int**: Filters the DataFrame based on the specified voltage level in kV. Currently accepts voltage levels of 345, 500 and 735 kv. No null values are accepted.
2. **n_circuits::Int**: Ensures the number of circuits is either 1 or 2, an error is raised if the specified number is outside this range. In case there is no data matching voltage and number of circuits criteria, a warning is raised and it returns the obtained dataframe considering only the voltage level filter. No null values are accepted.
3. **n_ground_wire::Int**: Ensures the number of ground wires is either 1 or 2. Raises an error if the specified number is outside this range. In case there is no data matching voltage, number of circuits criteria and number of Ground wires filters, a warning is raised and it returns the obtained dataframe considering only the voltage level and N circuits filter. No null values are accepted.
4. **state::Union{Vector{String}, Matrix{String}}**: Optionally filters the DataFrame based on the specified state(s). It ignores upper/lower case differences and leading or trail spaces in the state string.
5. **structure_type::Union{Vector{String}, Matrix{String}}**: Optionally filters the DataFrame based on the specified structure type(s) (Lattice, Pole, H frame or Y). It ignores upper/lower case differences and leading or trail spaces in the structure_type string.

# Example 1
#Load Data
df_tl_geometry    = DataFrame( XLSX.readtable(file_rel_path, sheet_tl_geometry) )
df_us_states_info = DataFrame( XLSX.readtable(file_rel_path, sheet_us_states) )

#Set filtering options, 345 kV, 2 circuits, 2 ground wires, State = Indiana, Structure type = Lattice 
tl1_filter        = TLFilters( 345, 2, 2, ["Indiana"], ["Lattice"] )

#Apply filters and obtain filtered data frame
filt_df           = get_tl_df_all_filters(df_tl_geometry, tl1_filter)

#Print obtained dataframe
println(filt_df[:,1:7])


# Example 2
#Load Data

df_tl_geometry    = DataFrame( XLSX.readtable(file_rel_path, sheet_tl_geometry) )

df_us_states_info = DataFrame( XLSX.readtable(file_rel_path, sheet_us_states) )

#Set filtering options, 345 kV, 2 circuits, 2 ground wires, State = Indiana, Structure type = Lattice

tl1_filter        = TLFilters( 345, 2, 2, ["Indiana"], ["Lattice"] )

#Include bordering states in the filter

get_filter_with_neighboring_states!( tl1_filter, df_us_states_info  )

#Apply filters and obtain filtered data frame

filt_df           = get_tl_df_all_filters(df_tl_geometry, tl1_filter)

#Print obtained dataframe that includes the selected state and its bordering states

println(filt_df[:,1:7])
"""
function get_tl_df_all_filters( 
    df::DataFrame, 
    user_filter::TLFilters 
    )
    # Voltage level
    filt_df  =  get_voltage_filtered_tl_df( df, user_filter )

    if nrow(filt_df) < 2
        @warn( "Currently, there is only one TL geometry for $(user_filter.voltage_kv) kV. Other filters were neglected." )
        return filt_df
    end

    #N circuits
    if user_filter.n_circuits > 2 || user_filter.n_circuits < 1
        error("The current data set include information of Tower Geometries carrying up to 2 circuits. Please reconsider your selection of $(user_filter.n_circuits) circuits.")
    end

    filt_df2   = filter(row -> row[:n_circuits] == user_filter.n_circuits, filt_df)
    if nrow(filt_df2) < 1
        @warn( "Currently, there is no data that match all the selected criteria. It was applied just voltage level filter of $(user_filter.voltage_kv) kV." )
        return filt_df
    end
    filt_df = filt_df2

    #N ground wires
    if user_filter.n_ground_wire > 2 || user_filter.n_ground_wire < 1
        error("The current data set include information of Tower Geometries carrying up to 2 ground wires. Please reconsider your selection of $(user_filter.n_ground_wire) ground wires.")
    end

    filt_df2   = filter(row -> row[:n_ground_w] == user_filter.n_ground_wire, filt_df)
    if nrow(filt_df2) < 1
        @warn( "Currently, there is no data that match all the selected criteria. It were applied just voltage level filter of $(user_filter.voltage_kv) kV, and the number of circuits filter of $(user_filter.n_circuits)." )
        return filt_df
    end
    filt_df = filt_df2

    #State
    if !( user_filter.state[1] == "" )
        filt_df2 = get_df_single_str_filter( filt_df, user_filter, "state" )
        if nrow( filt_df2 ) < 1
            @warn( "Currently, there is no data that match all the selected criteria. The state filter was ignored." )
        else
            filt_df = filt_df2
        end
    end
    
    #Structure type
    if !( user_filter.structure_type[1] == "" )
        filt_df2 = get_df_single_str_filter( filt_df, user_filter, "structure_type" )
        if nrow(filt_df2) < 1
            @warn( "Currently, there is no data that match all the selected criteria. The structure type filter was ignored." )
            return filt_df
        end
        filt_df = filt_df2
    end
    
    return filt_df
end


#|------------------------------------------------|
#|-------------GET TL BASICDATA STRUCT------------|
#|________________________________________________|
function get_tl_basicdata( 
    df::DataFrame; 
    name::String = "",
    S_rated::Float64 = 0.0,
    frequency::Float64 = 60.0,
    distance::Float64 = 0.0,
    gnd_rho::Float64 = 100.0,
    rowindex::Int = 1 
    )::TLBasicData

    rowindex = check_index_df_rows( rowindex, df, nameof(var"#self#") )

    return TLBasicData( name, df[ rowindex, COL_INDEX_MAP_TL["voltage_kv"] ], df[ rowindex, COL_INDEX_MAP_TL["n_circuits"] ], df[ rowindex, COL_INDEX_MAP_TL["n_ground_w"] ], df[ rowindex, COL_INDEX_MAP_TL["state"] ], df[ rowindex, COL_INDEX_MAP_TL["structure_type"] ], df[ rowindex, COL_INDEX_MAP_TL["code"] ], distance, S_rated, frequency, gnd_rho )
end


#|------------------------------------------------|
#|-------------GET TL GEOMETRY STRUCT-------------|
#|________________________________________________|


function get_all_distances(
    n_cables::Int,
    x_coordinates::Matrix{Float64},
    y_coordinates::Matrix{Float64}
    )
    n_dist    = round( Int , ( factorial(n_cables) ) / ( factorial(2) * factorial(n_cables - 2) ) )#N distance/combinations
    distances = zeros( 1 , n_dist)
    iter      = combinations( collect(1:n_cables), 2 )
    i         = 1
    
    for idx_v in iter
        distances[i] = get_distance_xy( x_coordinates[idx_v] , y_coordinates[idx_v] )
        i = i+1
    end
    return distances, collect(iter)
end



function get_tl_geometry( 
    df::DataFrame, 
    basicdata::TLBasicData; 
    rowindex::Int = 1 
    )::TLGeometry
    rowindex = check_index_df_rows( rowindex, df, nameof(var"#self#") )

    n_cables = ( basicdata.n_circuits * 3 ) + basicdata.n_ground_wire
    x_coord  = zeros( 1 , n_cables )
    y_coord  = zeros( 1 , n_cables )
    yindex_01 = COL_INDEX_MAP_TL[ "ya1_ft" ] - 1
    yindex_02 = COL_INDEX_MAP_TL[ "ya2_ft" ] - 1
    xindex_01 = COL_INDEX_MAP_TL[ "xa1_ft" ] - 1
    xindex_02 = COL_INDEX_MAP_TL[ "xa2_ft" ] - 1
    #Phase Conductors
    for i = 1 : 3
        y_coord[ i ]       = df[ rowindex , yindex_01 + i ]
        x_coord[ i ]       = df[ rowindex , xindex_01 + i ]
        if basicdata.n_circuits == 2   
            y_coord[ 3+i ] = df[ rowindex , yindex_02 + i ]
            x_coord[ 3+i ] = df[ rowindex , xindex_02 + i ]
        end
    end

    #Ground wires
    if basicdata.n_circuits == 1
        y_coord[4] = df[ rowindex , COL_INDEX_MAP_TL[ "yg1_ft" ] ] 
        x_coord[4] = df[ rowindex , COL_INDEX_MAP_TL[ "xg1_ft" ] ] 
        if basicdata.n_ground_wire == 2
            y_coord[5] = df[ rowindex , COL_INDEX_MAP_TL[ "yg2_ft" ] ]
            x_coord[5] = df[ rowindex , COL_INDEX_MAP_TL[ "xg2_ft" ] ]
        end
    elseif basicdata.n_circuits == 2
        y_coord[7] = df[ rowindex , COL_INDEX_MAP_TL[ "yg1_ft" ] ] 
        x_coord[7] = df[ rowindex , COL_INDEX_MAP_TL[ "xg1_ft" ] ] 
        if basicdata.n_ground_wire == 2
            y_coord[8] = df[ rowindex , COL_INDEX_MAP_TL[ "yg2_ft" ] ]
            x_coord[8] = df[ rowindex , COL_INDEX_MAP_TL[ "xg2_ft" ] ]
        end
    end

    distances, combinations = get_all_distances( n_cables, x_coord, y_coord )
    #println(  "distances: ", D_v, "\nCombinations: ", collect(comb) )

    return TLGeometry( n_cables, x_coord, y_coord, combinations, distances )
end


