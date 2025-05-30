using Pkg
Pkg.activate("test")
using Test

include( joinpath(pwd(), "src/TransmissionLineParameters.jl") )


df_tl_geometry, df_us_states_info, df_conductors, df_ground_wires, df_tl_examples = load_transmission_line_db( )

tl_basicdata, tl_geometry = get_transmission_line_geometry(
                            33.0,
                            df_tl_geometry;    
                            n_circuits = 1, 
                            n_ground_wires = 1,
                            v_str_states = [""], 
                            v_str_structure_types = [""],
                        )

tl_conductor = get_conductor( 
                        ["Acsr"], 
                        ["Linnet_EX_K4_1"],
                        df_conductors,
                        tl_basicdata;
                        bundling = 1, 
                        rowindex = 1 
                    )

tl_ground_w = get_ground_wire(
                        ["ACSR"], 
                        ["4/0 6/1"],
                        tl_basicdata,
                        df_ground_wires::DataFrame;
                        rowindex = 1 
                    )

tl = get_transmission_line(
                        tl_basicdata,
                        tl_geometry,
                        tl_conductor,
                        tl_ground_w
                    )