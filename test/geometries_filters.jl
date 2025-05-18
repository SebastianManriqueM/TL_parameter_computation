@testset "Pole Structure 33kv - Example 4.1 Kersting." begin
    tolerance = 0.0025
    tl_basicdata, tl_geometry = get_transmission_line_geometry(
                                33.0,
                                df_geometry;    
                                n_circuits = 1, 
                                n_ground_wires = 1,
                                v_str_states = [""], 
                                v_str_structure_types = [""],
                            )

    @test tl_basicdata.structure_code == "EX_K4_1"
    @test tl_basicdata.state == "Example"
    @test tl_basicdata.voltage_kv ≈ 33.0 atol= (33.0 * tolerance)
    @test tl_basicdata.n_ground_wire == 1
    @test tl_basicdata.n_circuits == 1

    @test tl_geometry.distances[1] ≈ 2.5 atol= (2.5 * tolerance)
    @test tl_geometry.distances[2] ≈ 7.0 atol= (7.0 * tolerance)
    @test tl_geometry.distances[3] ≈ 5.65685 atol= (5.65685 * tolerance)
    @test tl_geometry.distances[4] ≈ 4.5 atol= (4.5 * tolerance)
    @test tl_geometry.distances[5] ≈ 4.272  atol= (4.272 * tolerance)
    @test tl_geometry.distances[6] ≈ 5.0 atol= (5.0 * tolerance)
end


@testset "Structure Example 4.14 Stevenson." begin
    tolerance = 0.0025
    tl_basicdata, tl_geometry = get_transmission_line_geometry(
                                255.0,
                                df_geometry;    
                                n_circuits = 1, 
                                n_ground_wires = 1,
                                v_str_states = [""], 
                                v_str_structure_types = [""],
                            )

    @test tl_basicdata.structure_code == "EX_ST4_14"
    @test tl_basicdata.state == "Example"
    @test tl_basicdata.voltage_kv ≈ 255.0 atol= (255.0 * tolerance)
    @test tl_basicdata.n_ground_wire == 1
    @test tl_basicdata.n_circuits == 1

    @test tl_geometry.distances[1] ≈ 26.2467 atol= (26.2467 * tolerance)
    @test tl_geometry.distances[2] ≈ 52.4934 atol= (52.4934 * tolerance)
    @test tl_geometry.distances[3] ≈ 1000.34 atol= (1000.34 * tolerance)
    @test tl_geometry.distances[4] ≈ 26.2467 atol= (26.2467 * tolerance)
    @test tl_geometry.distances[5] ≈ 1000.0  atol= (1000.0 * tolerance)
    @test tl_geometry.distances[6] ≈ 1000.34 atol= (1000.34 * tolerance)
end

@testset "Lattice structure 345 kV - Single Circuit Lattice." begin
    tolerance = 0.0025
    tl_basicdata, tl_geometry = get_transmission_line_geometry(
                                345.0,
                                df_geometry;    
                                n_circuits = 1, 
                                n_ground_wires = 2,
                                v_str_states = ["Pennsylvania"], 
                                v_str_structure_types = ["Lattice"],
                            )

    @test tl_basicdata.structure_code == "3L4"
    @test tl_basicdata.state == "Pennsylvania"
    @test tl_basicdata.voltage_kv ≈ 345.0 atol= (345.0 * tolerance)
    @test tl_basicdata.n_ground_wire == 2
    @test tl_basicdata.n_circuits == 1

    @test tl_geometry.distances[1] ≈ 22.6667 atol= (22.6667 * tolerance)
    @test tl_geometry.distances[2] ≈ 45.3333 atol= (45.3333 * tolerance)
    @test tl_geometry.distances[3] ≈ 29.1283 atol= (29.1283 * tolerance)
    @test tl_geometry.distances[4] ≈ 50.3323 atol= (50.3323 * tolerance)
    @test tl_geometry.distances[5] ≈ 22.6667 atol= (22.6667 * tolerance)
    @test tl_geometry.distances[6] ≈ 34.3092 atol= (34.3092 * tolerance)
    @test tl_geometry.distances[7] ≈ 34.3092 atol= (34.3092 * tolerance)
    @test tl_geometry.distances[8] ≈ 50.3323 atol= (50.3323 * tolerance)
    @test tl_geometry.distances[9] ≈ 29.1283 atol= (29.1283 * tolerance)
    @test tl_geometry.distances[10] ≈ 37.1667 atol= (37.1667 * tolerance)
end


@testset "Lattice structure 345 kV - Single Circuit ." begin
    tolerance = 0.0025
    tl_basicdata, tl_geometry = get_transmission_line_geometry(
                                345.0,
                                df_geometry;    
                                n_circuits = 2, 
                                n_ground_wires = 2,
                                v_str_states = ["Massachusetts"], 
                                v_str_structure_types = ["H frame"],
                            )

    @test tl_basicdata.structure_code == "3H10"
    @test tl_basicdata.state == "Massachusetts"
    @test tl_basicdata.voltage_kv ≈ 345.0 atol= (345.0 * tolerance)
    @test tl_basicdata.n_ground_wire == 2
    @test tl_basicdata.n_circuits == 2

    @test tl_geometry.distances[1] ≈ 34.548 atol= (34.548 * tolerance)
    @test tl_geometry.distances[2] ≈ 26.0   atol= (26.0 * tolerance)
    @test tl_geometry.distances[3] ≈ 20.0   atol= (20.0 * tolerance)
    @test tl_geometry.distances[4] ≈ 32.8024 atol= (32.8024 * tolerance)
    @test tl_geometry.distances[5] ≈ 50.0356 atol= (50.0356 * tolerance)
    @test tl_geometry.distances[6] ≈ 22.8596 atol= (22.8596 * tolerance)
    @test tl_geometry.distances[7] ≈ 40.1567 atol= (40.1567 * tolerance)
    @test tl_geometry.distances[8] ≈ 22.75   atol= (22.75 * tolerance)
    @test tl_geometry.distances[9] ≈ 50.0356 atol= (50.0356 * tolerance)
    @test tl_geometry.distances[10] ≈ 42.75  atol= (42.75 * tolerance)

    @test tl_geometry.distances[11] ≈ 65.5   atol= (65.5 * tolerance)
    @test tl_geometry.distances[12] ≈ 41.3673 atol= (41.3673 * tolerance)
    @test tl_geometry.distances[13] ≈ 72.6705 atol= (72.6705 * tolerance)
    @test tl_geometry.distances[14] ≈ 32.8024 atol= (32.8024* tolerance)
    @test tl_geometry.distances[15] ≈ 20.0    atol= (20.0 * tolerance)
    @test tl_geometry.distances[16] ≈ 42.75   atol= (42.75 * tolerance)
    @test tl_geometry.distances[17] ≈ 44.481  atol= (44.481 * tolerance)
    @test tl_geometry.distances[18] ≈ 55.3946 atol= (55.3946 * tolerance)
    @test tl_geometry.distances[19] ≈ 26.0    atol= (26.0 * tolerance)
    @test tl_geometry.distances[20] ≈ 34.548  atol= (34.548 * tolerance)

    @test tl_geometry.distances[21] ≈ 40.1567 atol= (40.1567 * tolerance)
    @test tl_geometry.distances[22] ≈ 22.8596 atol= (22.8596 * tolerance)
    @test tl_geometry.distances[23] ≈ 22.75   atol= (22.75 * tolerance)
    @test tl_geometry.distances[24] ≈ 55.3946 atol= (55.3946* tolerance)
    @test tl_geometry.distances[25] ≈ 44.481  atol= (44.481 * tolerance)
    @test tl_geometry.distances[26] ≈ 72.6705 atol= (72.6705 * tolerance)
    @test tl_geometry.distances[27] ≈ 41.3673  atol= (41.3673 * tolerance)
    @test tl_geometry.distances[28] ≈ 54.5    atol= (54.5 * tolerance)
end