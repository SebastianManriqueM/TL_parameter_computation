
@testset "Validation Kersting example Conductor" begin
    tolerance = 0.005
    tl_basicdata, tl_geometry = get_transmission_line_geometry(
                                33.0,
                                df_geometry;    
                                n_circuits = 1, 
                                n_ground_wires = 1,
                                v_str_states = [""], 
                                v_str_structure_types = [""],
                            )

    tl_conductor = get_conductor( 
                        ["Acsr"], 
                        ["Linnet_EX_K4_1"],
                        df_cond,
                        tl_basicdata;
                        bundling = 1, 
                        rowindex = 1 
                    )
    @test tl_conductor.stranding == "26/7"
    @test tl_conductor.gmr ≈ 0.0244 atol= (0.0244 * tolerance)
    @test tl_conductor.Rac_tnom ≈ 0.306 * FACTOR_MILES_KFT atol= (0.306 * FACTOR_MILES_KFT * tolerance)
    @test tl_conductor.XLinternal ≈ 0.0854 atol= (0.0854 * tolerance)
end


@testset "Validation Stevenson example Bundled Conductor - Filter Type + codename" begin
    tolerance = 0.008
    tl_basicdata, tl_geometry = get_transmission_line_geometry(
                                255.0,
                                df_geometry;    
                                n_circuits = 1, 
                                n_ground_wires = 1,
                                v_str_states = [""], 
                                v_str_structure_types = [""],
                            )

    tl_conductor = get_conductor( 
                            ["Acsr"], 
                            ["Pheasant"],
                            df_cond,
                            tl_basicdata;
                            bundling = 2, 
                            rowindex = 1 
                        )

    @test tl_conductor.stranding == "54/19"
    @test tl_conductor.gmr ≈ 0.04662 atol= (0.04662 * tolerance)
    @test tl_conductor.Rac_tnom ≈ 0.017 atol= (0.017 * tolerance)
    @test tl_conductor.XLinternal ≈ 0.0704 atol= (0.0704 * tolerance)
    @test tl_conductor.bundling == 2
    @test tl_conductor.bundlingspacing == 18.0
    @test tl_conductor.gmr_bundling ≈ 0.08 * FACTOR_FT_MT atol= (0.08 * FACTOR_FT_MT * tolerance)
    @test tl_conductor.XL_bundling ≈ 0.03056 atol= (0.03056 * tolerance)

end


@testset "Validation Stevenson example Bundled Conductor - Filter Type + kcm." begin
    tolerance = 0.008
    tl_basicdata, tl_geometry = get_transmission_line_geometry(
                                255.0,
                                df_geometry;    
                                n_circuits = 1, 
                                n_ground_wires = 1,
                                v_str_states = [""], 
                                v_str_structure_types = [""],
                            )

    tl_conductor = get_conductor( 
                            ["Acsr"], 
                            [1272.0],
                            df_cond,
                            tl_basicdata;
                            bundling = 2, 
                            rowindex = 2
                        )

    @test tl_conductor.stranding == "54/19"
    @test tl_conductor.gmr ≈ 0.04662 atol= (0.04662 * tolerance)
    @test tl_conductor.Rac_tnom ≈ 0.017 atol= (0.017 * tolerance)
    @test tl_conductor.XLinternal ≈ 0.0704 atol= (0.0704 * tolerance)
    @test tl_conductor.bundling == 2
    @test tl_conductor.bundlingspacing == 18.0
    @test tl_conductor.gmr_bundling ≈ 0.08 * FACTOR_FT_MT atol= (0.08 * FACTOR_FT_MT * tolerance)
    @test tl_conductor.XL_bundling ≈ 0.03056 atol= (0.03056 * tolerance)

end