using Pkg
Pkg.activate("test")
#Pkg.instantiate()
using CSV

include( joinpath(pwd(), "src/TransmissionLineParameters.jl") )

df_geometry, df_us_states_, df_cond, df_ground_w, df_tl_ex = load_transmission_line_db( )

#tl_designs_df = CSV.read("examples/tl_designs.csv", DataFrame)
tl_designs_df = CSV.read("examples/tl_designs_ieee.csv", DataFrame)

df_parameters = DataFrame(r1_ohm_mile=Float64[], x1_ohm_mile=Float64[], b1_us_mile=Float64[], sil_MW=Float64[])

for row in eachrow(tl_designs_df)
    @show row["struct_code"]
    @show row["Conductor_code"]
    tl_basicdata, tl_geometry = get_transmission_line_geometry(
                                row["struct_code"],
                                df_geometry
                            )

    tl_conductor = get_conductor( 
                                [ row["Conductor_type"] ], 
                                [ row["Conductor_code"] ],
                                df_cond,
                                tl_basicdata;
                                bundling = row["bundling"], 
                                rowindex = 1 
                            )

    tl_ground_w = get_ground_wire(
                                [ row["Groundwire_type"] ], 
                                [ row["Groundwire_code"] ],
                                tl_basicdata,
                                df_ground_w;
                                rowindex = 1 
                            )

    tl = get_transmission_line(
                                tl_basicdata,
                                tl_geometry,
                                tl_conductor,
                                tl_ground_w
                            )
    r1 = tl.parameters.r1
    x1 = tl.parameters.x1
    b1 = tl.parameters.b1
    sil = tl.parameters.sil

    # Append the parameters to the DataFrame
    push!(df_parameters, (r1, x1, b1, sil))
end
# Concatenate tl_designs_df and df_parameters horizontally
df_result = hcat(tl_designs_df, df_parameters)
@show df_result

CSV.write("examples/tl_designs_with_parameters2.csv", df_result)
