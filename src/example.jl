include("filtering_tl_data.jl")
include("filtering_conductor_data.jl")

#Read data from XLSX file (Geometries, T Lines, Conductors, etc) 
file_rel_path     = "src/data/Tower_geometries_DB.xlsx"
sheet_tl_geometry = "TL_Geometry"
sheet_us_states   = "Neighboring"
sheet_conductors  = "Conductors"
sheet_tl_dataset  = "TL_dataset"

#Load Data
df_tl_geometry    = DataFrame( XLSX.readtable(file_rel_path, sheet_tl_geometry) )
df_us_states_info = DataFrame( XLSX.readtable(file_rel_path, sheet_us_states) )
df_conductors     = DataFrame( XLSX.readtable(file_rel_path, sheet_conductors) )
df_tl_examples    = DataFrame( XLSX.readtable(file_rel_path, sheet_tl_dataset) )

#Set filtering options
tl1_filter        = TLFilters( 345, 2, 2, ["Ohio"], ["Lattice"] )

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
conductor1_filter = get_struct_conductorfilters( ["Acsr"], ["Drake"] )
#filt_conductor_df  = get_df_single_str_filter( df_conductors, conductor1_filter, ["type"] )
filt_conductor_df = get_tl_conductor( df_conductors, conductor1_filter )

#CONDUCTOR - FILTER BY TYPE AND SIZE IN KCMIL
conductor2_filter  = get_struct_conductorfilters( ["Acsr"], [954.0] )
#filt_conductor2_df  = get_df_single_str_filter( df_conductors, conductor2_filter, "size_kcmil" )
filt_conductor2_df = get_tl_conductor( df_conductors, conductor2_filter )

bundling = 2
bundl_spacing = 18

tl1_conductor = get_conductor_data( filt_conductor2_df, tl1_basicdata, 2, 18, 1)


##WORK ON ADD GET CONDUCTOR TYPICAL