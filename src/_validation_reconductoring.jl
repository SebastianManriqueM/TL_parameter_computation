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



#St clair curve---------------
Pbase = 100
Vbase = 345
Zbase = (Vbase^2) / Pbase



X_s = 0.333*im
X_r = 0.333*im



E2 = 1.0
Es = 1.0

ΔV    = 0.05
Er_L  = Es * (1-ΔV)
θ_1_L = 40.0 * ( π / 180.0 )
Δθ_1  = 0.5  * ( π / 180.0 )

Len = 100.0

Ns = 0
Nr = 0
N = 0

E1 = 0.98

#R  = tl1.parameters.r1 * Len / Zbase
#XL = tl1.parameters.x1 * Len * im / Zbase
R  = 0.00571 * Len / Zbase
XL = 0.06432 * Len * im / Zbase
f_s = (100-Ns)/100
f_r = (100-Nr)/100


B   = (tl1.parameters.b1/1000000) * Len
#B   = 0.6604 * Len
Bms = 0.5*B*f_s
Bmr = 0.5*B*f_r
Xcs= (1/Bms)*-1*im
Xcr= (1/Bmr)*-1*im
Xcs= ( (1/Bms)*-1*im ) / Zbase
Xcr= ( (1/Bmr)*-1*im ) / Zbase



θ_1 = -50.0 * ( π / 180.0 )

Z  = [ X_s+Xcs -Xcs 0 ; Xcs R+XL+Xcr+Xcs -Xcr; 0 -Xcr X_r+Xcr ]
iZ = inv(Z)
E_v = [ E1*cos(θ_1) + E1*sin(θ_1)*im ; 0; -E2 ]
I_v = iZ * E_v

Es_calc = ( I_v[1] - I_v[2] ) * Xcm * f_s
abs(Es_calc)
Er_calc = ( I_v[2] - I_v[3] ) * Xcm * f_r
abs(Er_calc)

Vx2 = I_v[3]*X_r

Er_calc-Vx2
E1_calc = I_v[1]*X_s + Es_calc
atan(imag(E1_calc)/real(E1_calc))

println("Power [pu]")
Sline = Es_calc * conj( I_v[2] )

aa=1

##WORK ON ADD GET CONDUCTOR/GROUND WIRE TYPICAL
## WORK ON THE OPTIONS (RECONDUCTORING, VOLTAGE UPGRADE, ADD CIRCUITS, AC TO DC....) AND THE COST OF EACH ONE