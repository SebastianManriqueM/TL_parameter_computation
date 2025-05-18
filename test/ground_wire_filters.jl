
@testset "Validation Kersting example Ground wire. " begin
    tolerance = 0.005
    tl_basicdata, tl_geometry = get_transmission_line_geometry(
                                33.0,
                                df_geometry;    
                                n_circuits = 1, 
                                n_ground_wires = 1,
                                v_str_states = [""], 
                                v_str_structure_types = [""],
                            )

    tl_ground_w = get_ground_wire(
                            ["ACSR"], 
                            ["4/0 6/1"],
                            tl_basicdata,
                            df_ground_w::DataFrame;
                            rowindex = 1 
                        )

    @test tl_ground_w.gmr ≈ 0.00814 atol= (0.00814 * tolerance)
    @test tl_ground_w.Rdc_20 ≈ 0.5920 * FACTOR_MILES_KFT atol= (0.5920 * FACTOR_MILES_KFT * tolerance)
    @test tl_ground_w.XLinternal ≈ 0.11054 atol= (0.11054 * tolerance)
end

@testset "Alumoweld Ground wire.  - Filter Type + awg str." begin
    tolerance = 0.001
    ground_w_filter = get_struct_ground_wire_filters( ["Alumoweld"], ["19/7"] )
    filt_ground_w_df = get_tl_ground_wire( df_ground_w, ground_w_filter )

    @test filt_ground_w_df[ !, COL_INDEX_GROUND_WIRE["size_kcmil"] ][1] ≈ 395.5 atol = (395.5 * tolerance)
    @test filt_ground_w_df[ !, COL_INDEX_GROUND_WIRE["wire_diameter_inch"] ][1] ≈ 0.1443 atol = (0.1443 * tolerance)
    @test filt_ground_w_df[ !, COL_INDEX_GROUND_WIRE["R_20dc_ohm_kft"] ][1] ≈ 0.1308 atol = (0.1308 * tolerance)
end


@testset "Alumoweld Ground wire.  - Filter Type + awg." begin
    tolerance = 0.005
    tl_basicdata, tl_geometry = get_transmission_line_geometry(
                                33.0,
                                df_geometry;    
                                n_circuits = 1, 
                                n_ground_wires = 1,
                                v_str_states = [""], 
                                v_str_structure_types = [""],
                            )

    tl_ground_w = get_ground_wire(
                            ["Alumoweld"], 
                            ["19/7"],
                            tl_basicdata,
                            df_ground_w::DataFrame;
                            rowindex = 1 
                        )
    
    @test tl_ground_w.kcmil ≈ 395.5 atol= (395.5 * tolerance)
    @test tl_ground_w.diameter ≈ 0.721 atol= (0.721 * tolerance)
    @test tl_ground_w.gmr ≈ 0.023396 atol= (0.023396 * tolerance)
    @test tl_ground_w.Rdc_20 ≈ 0.1308 atol= (0.1308 * tolerance)
    @test tl_ground_w.XLinternal ≈ 0.086299 atol= (0.086299 * tolerance)
end

@testset "Alumoweld Ground wire.  - Filter Type + kcmil." begin
    tolerance = 0.005
    tl_basicdata, tl_geometry = get_transmission_line_geometry(
                                33.0,
                                df_geometry;    
                                n_circuits = 1, 
                                n_ground_wires = 1,
                                v_str_states = [""], 
                                v_str_structure_types = [""],
                            )

    tl_ground_w = get_ground_wire(
                            ["Alumoweld"], 
                            [395.5],
                            tl_basicdata,
                            df_ground_w::DataFrame;
                            rowindex = 1 
                        )
    
    @test tl_ground_w.kcmil ≈ 395.5 atol= (395.5 * tolerance)
    @test tl_ground_w.diameter ≈ 0.721 atol= (0.721 * tolerance)
    @test tl_ground_w.gmr ≈ 0.023396 atol= (0.023396 * tolerance)
    @test tl_ground_w.Rdc_20 ≈ 0.1308 atol= (0.1308 * tolerance)
    @test tl_ground_w.XLinternal ≈ 0.086299 atol= (0.086299 * tolerance)
end