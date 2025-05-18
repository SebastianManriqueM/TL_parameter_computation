using Pkg
Pkg.activate("test")
using Test

include( joinpath(pwd(), "src/TransmissionLineParameters.jl") )

df_geometry, df_us_states_, df_cond, df_ground_w, df_tl_ex = load_transmission_line_db( )

include( joinpath(pwd(), "test/ground_wire_filters.jl") )
include( joinpath(pwd(), "test/conductor_filters.jl") )

include( joinpath(pwd(), "test/line_parameters.jl") )