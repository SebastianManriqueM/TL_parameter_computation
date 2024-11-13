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


n_bundling = 1

#Set TL filtering options
tl1_filter = get_user_filter_tl_geometry(
                        345.0; #voltage
                        n_circuits=1,
                        n_ground_wires=2,
                        v_str_states=["Michigan"],
                        v_str_structure_types=["Lattice"]
                        )


println("FILTER ONLY ONE STATE: $(tl1_filter.state)")
filt_tl_df = get_tl_df_all_filters(df_tl_geometry, tl1_filter)

println(filt_tl_df[:,1:7])
println("N TRANSMISSION LINES:\n", nrow(filt_tl_df))

tl1_basicdata = get_tl_basicdata( 
                    filt_tl_df,
                    S_rated   = 100.0,
                    frequency = 60.0,
                    distance  = 253.0,
                    gnd_rho   = 100.0,
                    rowindex  = 1  )
tl1_geometry = get_tl_geometry( 
                    filt_tl_df, 
                    tl1_basicdata,
                    rowindex  = 1 )

#CONDUCTOR - FILTER BY TYPE AND NAME (CODEWORD)
conductor1_filter  = get_struct_conductor_filters( ["Acsr"], ["Bluebird"] )
filt1_conductor_df = get_tl_conductor( df_conductors, conductor1_filter )

tl1_conductor = get_conductor( 
                filt1_conductor_df, 
                tl1_basicdata, 
                bundling = n_bundling,
                rowindex = 1
                )


#GROUND WIRE - FILTER BY TYPE AND AWG
ground_w1_filter = get_struct_ground_wire_filters( ["Alumoweld"], ["7/7"] )
filt_ground_w1_df = get_tl_ground_wire( df_ground_wires, ground_w1_filter )


tl1_ground_wire = get_ground_wire(
                    filt_ground_w1_df, 
                    tl1_basicdata,
                    rowindex = 1
                    )

tl1_parameters = get_tl_parameters( tl1_basicdata, tl1_geometry, tl1_conductor, tl1_ground_wire )


tl1 = get_line_struct( tl1_basicdata, tl1_geometry, tl1_conductor, tl1_ground_wire, tl1_parameters )



#Conductor 2
conductor2_filter  = get_struct_conductor_filters( ["ACCC"], ["BLUEBIRD"] )
filt2_conductor_df = get_tl_conductor( df_conductors, conductor2_filter )

tl2_conductor = get_conductor( 
                filt2_conductor_df, 
                tl1_basicdata, 
                bundling = n_bundling,
                rowindex = 1
                )

tl2_parameters = get_tl_parameters( tl1_basicdata, tl1_geometry, tl2_conductor, tl1_ground_wire )

tl2 = get_line_struct( tl1_basicdata, tl1_geometry, tl2_conductor, tl1_ground_wire, tl2_parameters )
                
abs_err_r1 = tl1.parameters.r1 - tl2.parameters.r1
rel_err_r1 = abs_err_r1 / tl1.parameters.r1

abs_err_x1 = tl1.parameters.x1 - tl2.parameters.x1
rel_err_x1 = abs_err_x1 / tl1.parameters.x1

abs_err_b1 = tl1.parameters.b1 - tl2.parameters.b1
rel_err_b1 = abs_err_b1 / tl1.parameters.b1

r1          = tl1.conductor.diameter * 0.5 * FACTOR_FT_INCH
Xc1_Mohm_mi = (1.779/60) * log(1/r1)




#Conductor 3
conductor3_filter  = get_struct_conductor_filters( ["ACCC"], ["DOVE"] )
filt3_conductor_df = get_tl_conductor( df_conductors, conductor3_filter )

tl3_conductor = get_conductor( 
                filt3_conductor_df, 
                tl1_basicdata, 
                bundling = n_bundling+1,
                rowindex = 1
                )

tl3_parameters = get_tl_parameters( tl1_basicdata, tl1_geometry, tl3_conductor, tl1_ground_wire )

tl3 = get_line_struct( tl1_basicdata, tl1_geometry, tl3_conductor, tl1_ground_wire, tl3_parameters )
                
abs_err_r1_2 = tl1.parameters.r1 - tl3.parameters.r1
rel_err_r1_2 = abs_err_r1_2 / tl1.parameters.r1

abs_err_x1_2 = tl1.parameters.x1 - tl3.parameters.x1
rel_err_x1_2 = abs_err_x1_2 / tl1.parameters.x1

abs_err_b1_2 = tl1.parameters.b1 - tl3.parameters.b1
rel_err_b1_2 = abs_err_b1_2 / tl1.parameters.b1



##WORK ON ADD GET CONDUCTOR/GROUND WIRE TYPICAL
## WORK ON THE OPTIONS (RECONDUCTORING, VOLTAGE UPGRADE, ADD CIRCUITS, AC TO DC....) AND THE COST OF EACH ONE