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


c_type_v   = [["Acsr"]    , ["ACCC"]    , ["ACCC"]  , ["ACCC"]  , ["ACCC"]  , ["Acsr"]  , ["ACCC"]  , ["ACCC"]  , ["ACCC"]  ]
c_name_v   = [["Bluebird"], ["BLUEBIRD"], ["ELPASO"], ["ELPASO"], ["ELPASO"], ["FALCON"], ["FALCON"], ["LUBBOCK"], ["LUBBOCK"]  ]
bundling_v = [1           , 1           , 2         ,   3       , 4         , 2         , 2         , 3          , 4]
idx_error_v= [1,1,1,1,1,6,6,6,6]

conductor_filter_v  = []
conductor_df_filt_v = []
tl_conductor_v      = []
tl_parameters_v     = []
tl_v                = []

df = DataFrame(Voltage = Float64[], 
                C_type = String[],
                C_name = String[],
                kcmil  = Float64[],
                bundling = Int64[],
                r1 = Float64[],
                x1 = Float64[],
                b1 = Float64[],
                Zsil = Float64[],
                sil = Float64[],
                r1_rel_err = Float64[],
                x1_rel_err = Float64[],
                b1_rel_err = Float64[], 
                sil_ratio = Float64[])

for i in eachindex(c_type_v)
    push!( conductor_filter_v , get_struct_conductor_filters( c_type_v[i], c_name_v[i] ) )
    push!( conductor_df_filt_v,  get_tl_conductor( df_conductors, conductor_filter_v[i] ) )

    push!( tl_conductor_v, get_conductor( 
                                conductor_df_filt_v[i], 
                                tl1_basicdata, 
                                bundling = bundling_v[i],
                                rowindex = 1
                                ) )
    push!( tl_parameters_v, get_tl_parameters( tl1_basicdata, tl1_geometry, tl_conductor_v[i], tl1_ground_wire ) )
    push!(tl_v, get_line_struct( tl1_basicdata, tl1_geometry, tl_conductor_v[i], tl1_ground_wire, tl_parameters_v[i] ) )

    

    push!( df, (
            Voltage  = 345.0, 
            C_type   = c_type_v[i][1],
            C_name   = c_name_v[i][1],
            kcmil    = tl_conductor_v[i].kcmil,
            bundling = bundling_v[i],
            r1   = tl_parameters_v[i].r1,
            x1   = tl_parameters_v[i].x1,
            b1   = tl_parameters_v[i].b1,
            Zsil = tl_parameters_v[i].Z_sil,
            sil  = tl_parameters_v[i].sil, 
            r1_rel_err = ( tl_parameters_v[i].r1 - tl_parameters_v[idx_error_v[i]].r1 ) / tl_parameters_v[idx_error_v[i]].r1,
            x1_rel_err = ( tl_parameters_v[i].x1 - tl_parameters_v[idx_error_v[i]].x1 ) / tl_parameters_v[idx_error_v[i]].x1,
            b1_rel_err = ( tl_parameters_v[i].b1 - tl_parameters_v[idx_error_v[i]].b1 ) / tl_parameters_v[idx_error_v[i]].b1, 
            sil_ratio  = tl_parameters_v[i].sil  / tl_parameters_v[idx_error_v[i]].sil )
            ) 
end

using CSV
#using Filesystem
rel_path = "output_examples/"
if !isdir(rel_path) 
     mkdir(rel_path) 
end
CSV.write( rel_path * "Comparison_reconductoring_345kv.csv", df )




##WORK ON ADD GET CONDUCTOR/GROUND WIRE TYPICAL
## WORK ON THE OPTIONS (RECONDUCTORING, VOLTAGE UPGRADE, ADD CIRCUITS, AC TO DC....) AND THE COST OF EACH ONE