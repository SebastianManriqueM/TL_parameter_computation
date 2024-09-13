include("definitions.jl")
include("tl_data_filtering.jl")

#Read XLSX file with typical US tower Geometries
file_rel_path     = "src/data/Tower_geometries_DB.xlsx"
sheet_tl_geometry = "TL_Geometry"
sheet_us_states   = "Neighboring"
sheet_conductors  = "Conductors"
sheet_tl_dataset  = "TL_dataset"

#Load Data
df_tl_geometry    = DataFrame( XLSX.readtable(file_rel_path, sheet_tl_geometry) )
df_us_states_info = DataFrame( XLSX.readtable(file_rel_path, sheet_us_states) )

#Set filtering options
tl1_filter        = TLFilters( 345, 2, 2, ["Ohio"], ["Lattice"] )

println("FILTER ONLY ONE STATE: $(tl1_filter.state)")
filt_df           = get_tl_df_all_filters(df_tl_geometry, tl1_filter)

println(filt_df[:,1:7])
println("N TRANSMISSION LINES:\n", nrow(filt_df))


get_filter_with_neighboring_states!( tl1_filter, df_us_states_info )
println("FILTER INCLUDING NEIGHBORING STATES: $(tl1_filter.state)")
filt_df_neigh_states = get_tl_df_all_filters(df_tl_geometry, tl1_filter)

println(filt_df_neigh_states[:,1:7])
println("N TRANSMISSION LINES:\n", nrow(filt_df_neigh_states))

tl1_basicdata = get_tl_basicdata( filt_df_neigh_states )

tl1_geometry = get_tl_geometry( filt_df_neigh_states, tl1_basicdata )
