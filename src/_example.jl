include("filtering_tl_data.jl")
include("filtering_conductor_data.jl")
include("filtering_ground_wire_data.jl")
include("tl_parameters_calculator.jl")

using Revise

#Read data from XLSX file (Geometries, T Lines, Conductors, etc) 
file_rel_path      = "src/data/Tower_geometries_DB.xlsx"
sheet_tl_geometry  = "TL_Geometry"
sheet_us_states    = "Neighboring"
sheet_conductors   = "Conductors"
sheet_ground_wires = "G_wire"
sheet_tl_dataset   = "TL_dataset"

#Load Data
df_tl_geometry     = DataFrame( XLSX.readtable(file_rel_path, sheet_tl_geometry) )
df_us_states_info  = DataFrame( XLSX.readtable(file_rel_path, sheet_us_states) )
df_conductors      = DataFrame( XLSX.readtable(file_rel_path, sheet_conductors) )
df_ground_wires    = DataFrame( XLSX.readtable(file_rel_path, sheet_ground_wires) )
df_tl_examples     = DataFrame( XLSX.readtable(file_rel_path, sheet_tl_dataset) )



#Set TL filtering options
tl1_filter = get_user_filter_tl_geometry(
                        345.0; #voltage
                        n_circuits=2,
                        n_ground_wires=2,
                        v_str_states=["Iowa"],
                        v_str_structure_types=["Lattice"]
                        )


println("FILTER ONLY ONE STATE: $(tl1_filter.state)")
filt_tl_df = get_tl_df_all_filters(df_tl_geometry, tl1_filter)

println(filt_tl_df[:,1:7])
println("N TRANSMISSION LINES:\n", nrow(filt_tl_df))


get_filter_with_neighboring_states!( tl1_filter, df_us_states_info )
println("FILTER INCLUDING NEIGHBORING STATES: $(tl1_filter.state)")
filt_tl_df_neigh_states = get_tl_df_all_filters(df_tl_geometry, tl1_filter)

println(filt_tl_df_neigh_states[:,1:7])
println("N TRANSMISSION LINES:\n", nrow(filt_tl_df_neigh_states))




tl1_basicdata = get_tl_basicdata( filt_tl_df_neigh_states )
tl1_geometry = get_tl_geometry( filt_tl_df_neigh_states, tl1_basicdata )

#CONDUCTOR - FILTER BY TYPE AND NAME (CODEWORD)
conductor1_filter = get_struct_conductor_filters( ["Acsr"], ["Drake"] )
filt_conductor_df = get_tl_conductor( df_conductors, conductor1_filter )

#CONDUCTOR - FILTER BY TYPE AND SIZE IN KCMIL
conductor2_filter  = get_struct_conductor_filters( ["Acsr"], [954.0] )
filt_conductor2_df = get_tl_conductor( df_conductors, conductor2_filter )
println(filt_conductor2_df)

tl1_conductor = get_conductor( 
                filt_conductor2_df, 
                tl1_basicdata, 
                bundling = 2,
                rowindex = 2
                )



#GROUND WIRE - FILTER BY TYPE AND AWG
ground_w1_filter = get_struct_ground_wire_filters( ["Alumoweld"], ["3/8"] )
filt_ground_w1_df = get_tl_ground_wire( df_ground_wires, ground_w1_filter )

ground_w2_filter = get_struct_ground_wire_filters( ["Alumoweld"], [49.53] )
filt_ground_w2_df = get_tl_ground_wire( df_ground_wires, ground_w2_filter )

tl1_ground_wire = get_ground_wire(
                    filt_ground_w2_df, 
                    tl1_basicdata,
                    rowindex = 1
                    )

tl1_parameters = get_tl_parameters( tl1_basicdata, tl1_geometry, tl1_conductor, tl1_ground_wire )


tl1 = get_line_struct( tl1_basicdata, tl1_geometry, tl1_conductor, tl1_ground_wire, tl1_parameters )


##WORK ON ADD GET CONDUCTOR/GROUND WIRE TYPICAL
## WORK ON THE OPTIONS (RECONDUCTORING, VOLTAGE UPGRADE, ADD CIRCUITS, AC TO DC....) AND THE COST OF EACH ONE