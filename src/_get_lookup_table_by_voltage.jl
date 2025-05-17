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


function get_tl_object( filt_tl1_df )
    println("N TRANSMISSION LINES:\n", nrow(filt_tl1_df))
    tl1_basicdata = get_tl_basicdata( filt_tl1_df )
    tl1_geometry = get_tl_geometry( filt_tl1_df, tl1_basicdata )
    
    #CONDUCTOR - FILTER BY TYPE AND NAME (CODEWORD)
    conductor1_filter = get_struct_conductor_filters( ["Acsr"], ["Drake"] )
    filt_conductor_df = get_tl_conductor( df_conductors, conductor1_filter )
    println(filt_conductor_df)

    tl1_conductor = get_conductor( 
        filt_conductor_df, 
        tl1_basicdata, 
        bundling = 2,
        rowindex = 1
        )
    
    ground_w_filter = get_struct_ground_wire_filters( ["Alumoweld"], [49.53] )
    filt_ground_w_df = get_tl_ground_wire( df_ground_wires, ground_w_filter )  
    tl1_ground_wire = get_ground_wire(filt_ground_w_df, tl1_basicdata) 
    
    tl1_parameters = get_tl_parameters( tl1_basicdata, tl1_geometry, tl1_conductor, tl1_ground_wire )
    
    return get_line_struct( tl1_basicdata, tl1_geometry, tl1_conductor, tl1_ground_wire, tl1_parameters )

end



###########################
#Dict transmission Lines
TL_dict = Dict(
    "voltage"             => [345.0, 345.0, 500.0, 765.0],
    "Structure"              => 2,
    "abreviation"        => 3,
    "bordering_states"   => 4,
    "n_bordering_states" => 5
)




#Set TL filtering options
#tl1_filter        = get_user_filter_tl_geometry( 345.0; 2, 1, ["Ohio"], ["Pole"] )#TLFilters( 345, 2, 2, ["Ohio"], ["Lattice"] )
tl1_filter = get_user_filter_tl_geometry(
                        345.0; #voltage
                        n_circuits=2,
                        n_ground_wires=1,
                        v_str_states=["Ohio"],
                        v_str_structure_types=["Pole"]
                        )
println("TL1 - FILTER ONLY ONE STATE: $(tl1_filter.state)")
filt_tl1_df       = get_tl_df_all_filters(df_tl_geometry, tl1_filter)
tl_1 = get_tl_object( filt_tl1_df )

#Set TL filtering options
tl2_filter = get_user_filter_tl_geometry(
    345.0; #voltage
    n_circuits=2,
    n_ground_wires=2,
    v_str_states=["Utah"],
    v_str_structure_types=["Pole"]
    )

println("TL1 - FILTER ONLY ONE STATE: $(tl2_filter.state)")
filt_tl2_df       = get_tl_df_all_filters(df_tl_geometry, tl2_filter)
tl_2 = get_tl_object( filt_tl2_df )

println("Resistance diferences\n1 GW [ohm/mile] \t\t 2 GW [ohm/mile]\t\t Abs diff [ohm/mile]\t\tRel diff [%]")
println(tl_1.parameters.r1, "\t\t", tl_2.parameters.r1, "\t\t", tl_1.parameters.r1- tl_2.parameters.r1, "\t\t", ((tl_1.parameters.r1- tl_2.parameters.r1)/min(tl_1.parameters.r1, tl_2.parameters.r1))*100 )

println("Inductive reactance\n1 GW [ohm/mile] \t\t 2 GW [ohm/mile]\t\t Abs diff [ohm/mile]\t\tRel diff [%]")
println(tl_1.parameters.x1, "\t\t", tl_2.parameters.x1, "\t\t", tl_1.parameters.x1- tl_2.parameters.x1, "\t\t", ((tl_1.parameters.x1- tl_2.parameters.x1)/min(tl_1.parameters.x1, tl_2.parameters.x1))*100 )

println("Susceptance \n1 GW [uSi/mile] \t\t 2 GW [uSi/mile]\t\t Abs diff [uSi/mile]\t\tRel diff [%]")
println(tl_1.parameters.b1, "\t\t", tl_2.parameters.b1, "\t\t", tl_1.parameters.b1- tl_2.parameters.b1, "\t\t", ((tl_1.parameters.b1- tl_2.parameters.b1)/min(tl_1.parameters.b1, tl_2.parameters.b1))*100 )