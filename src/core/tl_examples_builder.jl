abstract type AbstractTLExamples end

abstract type AbstractExampleKersting_4_1 <: AbstractTLExamples end
abstract type AbstractExampleStevenson_4_14 <: AbstractTLExamples end

function get_example_line( 
    df_tl_geometry::DataFrame, 
    df_conductors::DataFrame, 
    df_ground_wires::DataFrame,
    ::Type{AbstractExampleKersting_4_1} 
    )

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
    return tl
end

function get_example_line( 
    df_tl_geometry::DataFrame, 
    df_conductors::DataFrame, 
    df_ground_wires::DataFrame,
    ::Type{AbstractExampleStevenson_4_14} 
    )

    tl_basicdata, tl_geometry = get_transmission_line_geometry(
                                255.0,
                                df_tl_geometry;    
                                n_circuits = 1, 
                                n_ground_wires = 1,
                                v_str_states = [""], 
                                v_str_structure_types = [""],
                            )

    tl_conductor = get_conductor( 
                            ["Acsr"], 
                            ["Pheasant"],
                            df_conductors,
                            tl_basicdata;
                            bundling = 2, 
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
    return tl
end