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
tl1_filter        = get_user_filter_tl_geometry( 345.0, 2, 2, ["Iowa"], ["Lattice"] )#TLFilters( 345, 2, 2, ["Ohio"], ["Lattice"] )

println("FILTER ONLY ONE STATE: $(tl1_filter.state)")
filt_tl_df           = get_tl_df_all_filters(df_tl_geometry, tl1_filter)

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


tl1_conductor = get_conductor_data( filt_conductor2_df, tl1_basicdata)



#GROUND WIRE - FILTER BY TYPE AND AWG
ground_w1_filter = get_struct_ground_wire_filters( ["Alumoweld"], ["3/8"] )
filt_ground_w1_df = get_tl_ground_wire( df_ground_wires, ground_w1_filter )

ground_w2_filter = get_struct_ground_wire_filters( ["Alumoweld"], [49.53] )
filt_ground_w2_df = get_tl_ground_wire( df_ground_wires, ground_w2_filter )

tl1_ground_wire = get_ground_wire_data(filt_ground_w2_df, tl1_basicdata)


##WORK ON ADD GET CONDUCTOR/GROUND WIRE TYPICAL

z_prim = get_primitive_z_matrix( tl1_basicdata, tl1_geometry, tl1_conductor, tl1_ground_wire)
println("Primitive\n:",z_prim)

z_kron_nt = get_kron_reduced_z_matrix( tl1_basicdata, tl1_geometry, z_prim )
println("z_kron_nt\n:",z_kron_nt)

z_seq_nt  = get_sequence_z_matrix( tl1_basicdata, z_kron_nt )
println("z_seq_nt\n:",z_seq_nt)

z_kron_ft = get_fully_transposed_z( tl1_basicdata, z_kron_nt )
println("z_kron_ft\n:",z_kron_ft)

z_seq_ft  = get_sequence_z_matrix( tl1_basicdata, z_kron_ft )
println("z_seq_ft\n:",z_seq_ft)


#TODO get transposed line parameters


## WORK ON THE OPTIONS (RECONDUCTORING, VOLTAGE UPGRADE, ADD CIRCUITS, AC TO DC....) AND THE COST OF EACH ONE