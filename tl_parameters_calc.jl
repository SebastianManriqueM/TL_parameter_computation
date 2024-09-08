using XLSX
using DataFrames

const DATA_SET_TL_VOLTAGES = [345 500 735]
const US_STATES_LIST_SHORT = ["AL","AK","AZ","AR","CA","CO","CT","DE","FL","GA","HI","ID","IL","IN","IA","KS","KY","LA","ME","MD","MA","MI","MN","MS","MO","MT","NE","NV","NH","NJ","NM","NY","NC","ND","OH","OK","OR","PA","RI","SC","SD","TN","TX","UT","VT","VA","WA","WV","WI","WY"]
const US_STATES_LIST       = ["Alabama", "Alaska", "Arizona", "Arkansas", "California", "Colorado", "Connecticut", "Delaware", "Florida", "Georgia", "Hawaii", "Idaho", "Illinois", "Indiana", "Iowa", "Kansas", "Kentucky", "Louisiana", "Maine", "Maryland", "Massachusetts", "Michigan", "Minnesota", "Mississippi", "Missouri", "Montana", "Nebraska", "Nevada", "New Hampshire", "New Jersey", "New Mexico", "New York", "North Carolina", "North Dakota", "Ohio", "Oklahoma", "Oregon", "Pennsylvania", "Rhode Island", "South Carolina" , "South Dakota", "Tennessee", "Texas", "Utah", "Vermont", "Virginia", "Washington", "West Virginia", "Wisconsin", "Wyoming"]

mutable struct TL_FILTERS
    voltage_kv::Int
    n_circuits::Int
    n_ground_wire::Int
    state::Union{Vector{String}, Matrix{String}}
    structure_type::Union{Vector{String}, Matrix{String}}
end

function check_voltage_availability( value )
    for element in DATA_SET_TL_VOLTAGES
        if element == value
            return true
        end
    end
    return false
end

function clear_string_v_lead_trail_spaces!( string_v )
    i = 1
    for string in string_v
        string_v[i] = strip( string )
        i = i + 1
    end
end

function compare_index_v_dimension( index::Int, vector , function_name)
    
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
function get_bordering_states( df_us_states::DataFrame, user_filter::TL_FILTERS, index::Int = 1 )

    #Check index is between the user_filter.state Vector limits
    index_checked = compare_index_v_dimension( index, user_filter.state, nameof(var"#self#"))
    
    if index != index_checked 
        @warn("Function $(nameof(var"#self#")) is returning the neighboring states of $(user_filter.state[index_checked])")
    end

    if ( user_filter.state[index_checked] == "" )
        @error("Check TL_FILTERS.state[index]. It is not possible to obtain bordering states becuase that filter property has no value.")
    end

    #Find Bordering states using df_us_states
    for row in eachrow(df_us_states)
        if strip( lowercase(user_filter.state[index_checked]) ) == strip( lowercase( row[2] ) )
            bordering_states_v = split(row[4], ',')
            clear_string_v_lead_trail_spaces!( bordering_states_v )
            return bordering_states_v
        end
    end
    @error( "$(user_filter.state[index_checked]) was not found to obtain its bordering states. Check TL_FILTERS.state[index]"  )
end


function get_voltage_filtered_tl_df( df::DataFrame, user_filter::TL_FILTERS )
    if !(check_voltage_availability( user_filter.voltage_kv ))
        error("The current data set does not include information of Tower Geometries for $(user_filter.voltage_kv) kV. The dataset includes information for the following voltage levels (kV): $DATA_SET_TL_VOLTAGES")
    end
    return filter( row -> row[:voltage_kv] == user_filter.voltage_kv, df)
end

function get_filtered_tl_df( df::DataFrame, user_filter::TL_FILTERS )
    # Voltage level
    filt_df  =  get_voltage_filtered_tl_df( df, user_filter )

    if nrow(filt_df) < 2
        @warn( "Currently, there is only one TL geometry for $(user_filter.voltage_kv) kV. Other filters were neglected." )
        return filt_df
    end

    #N circuits
    if user_filter.n_circuits > 2
        error("The current data set include information of Tower Geometries carrying up to 2 circuits. Please reconsider your selection of $(user_filter.n_circuits) circuits.")
    end

    filt_df2   = filter(row -> row[:n_circuits] == user_filter.n_circuits, filt_df)
    if nrow(filt_df2) < 1
        @warn( "Currently there is no data that match all the selected criteria. It was applied just voltage level filter of $(user_filter.voltage_kv) kV." )
        return filt_df
    end
    filt_df = filt_df2

    #N ground wires
    if user_filter.n_ground_wire > 2
        error("The current data set include information of Tower Geometries carrying up to 2 ground wires. Please reconsider your selection of $(user_filter.n_ground_wire) ground wires.")
    end

    filt_df2   = filter(row -> row[:n_ground_w] == user_filter.n_ground_wire, filt_df)
    if nrow(filt_df2) < 1
        @warn( "Currently there is no data that match all the selected criteria. It were applied just voltage level filter of $(user_filter.voltage_kv) kV, and the number of circuits filter of $(user_filter.n_circuits)." )
        return filt_df
    end
    filt_df = filt_df2

    #State
    if !( user_filter.state[1] == "" )
        # Define the filtering function
        # **This filter has a Bug since "Kansas" is a substring or "Arkansas"
        filter_func_state(r) = any(s -> occursin( strip(lowercase(s)), coalesce(strip(lowercase(r[4]))) ), user_filter.state)
        #filter_func(row) = any(s -> occursin( strip(lowercase(s)), coalesce(strip(lowercase(row[2]))) ), user_filter.structure_type)
        # Apply the filter to the DataFrame
        filt_df2 = filter(filter_func_state, filt_df)

        println("---------------------************")
        println(user_filter.state)
        println(filt_df[:,1:7], "\n", filt_df[:,1:7])
        println("---------------------************")

        if nrow( filt_df2 ) < 1
            @warn( "Currently there is no data that match all the selected criteria. The state and structure type filters were ignored." )
            return filt_df
        end
        filt_df = filt_df2
    end
    

    #Structure type
    if !( user_filter.structure_type[1] == "" )
        #filt_df2   = filter(row -> row[:structure_type] == user_filter.structure_type, filt_df)
        # Define the filtering function
        filter_func(row) = any(s -> occursin( strip(lowercase(s)), coalesce(strip(lowercase(row[2]))) ), user_filter.structure_type)
        # Apply the filter to the DataFrame
        filt_df2 = filter(filter_func, filt_df)
        if nrow(filt_df2) < 1
            @warn( "Currently there is no data that match all the selected criteria. The structure type filter was ignored." )
            return filt_df
        end
        filt_df = filt_df2
    end
    
    return filt_df
end




#Read XLSX file with typical US tower Geometries
file_path         = "data/Tower_geometries_DB.xlsx"
sheet_tl_geometry = "TL_Geometry"
sheet_us_states   = "Neighboring"
df_tl_geometry    = DataFrame( XLSX.readtable(file_path, sheet_tl_geometry) )
df_us_states_info = DataFrame( XLSX.readtable(file_path, sheet_us_states) )
tl1_filter        = TL_FILTERS( 345, 2, 2, ["Indiana"], ["Pole"] )

filt_df           = get_filtered_tl_df(df_tl_geometry, tl1_filter)

println(filt_df[:,1:7])
println("N TRANSMISSION LINES:\n", nrow(filt_df))


bordering_states = get_bordering_states( df_us_states_info, tl1_filter, 3 )


for state_i in bordering_states
    println(state_i)
end

