

using XLSX
using DataFrames

const DATA_SET_TL_VOLTAGES = [345 500 735]
const US_STATES_LIST = []

mutable struct TL_FILTERS
    voltage_kv::Int
    n_circuits::Int
    n_ground_wire::Int
    state::String
    structure_type::String
end

function check_voltage_availability( value )
    for element in DATA_SET_TL_VOLTAGES
        if element == value
            return true
        end
    end
    return false
end

function get_filtered_tl_dataframe(df::DataFrame, user_filter::TL_FILTERS)
    # Voltage level
    if !(check_voltage_availability( user_filter.voltage_kv ))
        error("The current data set does not include information of Tower Geometries for $(user_filter.voltage_kv) kV. The dataset includes information for the following voltage levels (kV): $DATA_SET_TL_VOLTAGES")
    end
    filt_df  = filter( row -> row[:voltage_kv] == user_filter.voltage_kv, df) 

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
        @warn( "Currently there are no data that match ll the criteria selected. It was applied just voltage level filter of $(user_filter.voltage_kv) kV." )
        return filt_df
    end
    filt_df = filt_df2

    #N ground wires
    if user_filter.n_ground_wire > 2
        error("The current data set include information of Tower Geometries carrying up to 2 ground wires. Please reconsider your selection of $(user_filter.n_ground_wire) ground wires.")
    end

    filt_df2   = filter(row -> row[:n_ground_w] == user_filter.n_ground_wire, filt_df)
    if nrow(filt_df) < 2
        @warn( "Currently there are no data that match all the criteria selected. It were applied just voltage level filter of $(user_filter.voltage_kv) kV, and the number of circuits filter of $(user_filter.n_circuits)." )
        return filt_df
    end
    filt_df = filt_df2

    #VERIFICAR QUE O STRING DO ESTADO ESTEJA DENTRO DA LISTA -  PREENCHER US STATES LIST VECTOR AT THE BEGINING
    #State
    if !(user_filter.state == "")
        filt_df2   = filter(row -> occursin( user_filter.state, coalesce(row[:state], "") ), filt_df)
    end

    #Structure type
    if !(user_filter.structure_type == "")
        filt_df2   = filter(row -> row[:structure_type] == user_filter.structure_type, filt_df)
    end

    return filt_df
end




#Read XLSX file with typical US tower Geometries
file_path  = "Tower_geometries_DB.xlsx"
sheet_name = "TL_Geometry"
df         = DataFrame( XLSX.readtable(file_path, sheet_name) )
tl1_filter = TL_FILTERS( 345, 2, 2, "Indiana", "" )

filt_df    = get_filtered_tl_dataframe(df, tl1_filter)

println(filt_df)
println("\n", nrow(filt_df))
