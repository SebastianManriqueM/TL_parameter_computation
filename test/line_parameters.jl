@testset "Validation Kersting example Primitive Non-Transposed Z Matrix" begin
    tl_kersting = get_example_line( df_geometry, df_cond, df_ground_w, AbstractExampleKersting_4_1 )
    tolerance = 0.005

    Zabcg_calc = tl_kersting.parameters.Zabcg
    Zabcg_book = [0.4013 + 1.4133im   0.0953 + 0.8515im   0.0953 + 0.7266im   0.0953 + 0.7524im; 
                  0.0953 + 0.8515im   0.4013 + 1.4133im   0.0953 + 0.7802im   0.0953 + 0.7865im; 
                  0.0953 + 0.7266im   0.0953 + 0.7802im   0.4013 + 1.4133im   0.0953 + 0.7674im;
                  0.0953 + 0.7524im   0.0953 + 0.7865im   0.0953 + 0.7674im   0.6873 + 1.5465im]
    for i in 1:4
        for j in 1:4
            @test abs(Zabcg_calc[i,j] - Zabcg_book[i,j]) < abs(Zabcg_book[i,j]) * tolerance
        end
    end
end


@testset "Validation Kersting example Non-Transposed Z Kron Matrix" begin
    tl_kersting = get_example_line( df_geometry, df_cond, df_ground_w, AbstractExampleKersting_4_1 )
    tolerance = 0.005

    Zabc_calc = tl_kersting.parameters.Z_kron_nt
    Zabc_book = [0.4576 + 1.0780im   0.1560 + 0.5017im   0.1535 + 0.3849im; 
                 0.1560 + 0.5017im   0.4666 + 1.0482im   0.1580 + 0.4236im; 
                 0.1535 + 0.3849im   0.1580 + 0.4236im   0.4615 + 1.0651im]
    for i in 1:3
        for j in 1:3
            @test abs(Zabc_calc[i,j] - Zabc_book[i,j]) < abs(Zabc_book[i,j]) * tolerance
        end
    end
end


@testset "Validation Kersting example Transposed Z Kron Matrix" begin
    tl_kersting = get_example_line( df_geometry, df_cond, df_ground_w, AbstractExampleKersting_4_1 )
    tolerance = 0.005

    Zabc_calc = tl_kersting.parameters.Z_kron_ft
    Zabc_book = [0.4619 + 1.0638im   0.1558 + 0.4368im   0.1558 + 0.4368im; 
                 0.1558 + 0.4368im   0.4619 + 1.0638im   0.1558 + 0.4368im; 
                 0.1558 + 0.4368im   0.1558 + 0.4368im   0.4619 + 1.0638im]
    for i in 1:3
        for j in 1:3
            @test abs(Zabc_calc[i,j] - Zabc_book[i,j]) < abs(Zabc_book[i,j]) * tolerance
        end
    end
end


@testset "Validation Kersting example Transposed Z Sequence Matrix" begin
    tl_kersting = get_example_line( df_geometry, df_cond, df_ground_w, AbstractExampleKersting_4_1 )
    tolerance = 0.005

    Z012_calc = tl_kersting.parameters.Z012_ft
    Z012_book = [0.7735 + 1.9373im   0.0                 0.0; 
                 0.0                 0.3061 + 0.6270im   0.0; 
                 0.0                 0.0                 0.3061 + 0.6270im]
    for i in 1:3
        for j in 1:3
            if i == j
                @test abs(Z012_calc[i,j] - Z012_book[i,j]) < abs(Z012_calc[i,j]) * tolerance
            else
                @test abs(Z012_calc[i,j]) < 1e-9
            end
        end
    end
end

@testset "Validation Kersting example Non-Transposed Y Kron Matrix" begin
    tl_kersting = get_example_line( df_geometry, df_cond, df_ground_w, AbstractExampleKersting_4_1 )
    tolerance = 0.028

    Yabc_calc = tl_kersting.parameters.Y_kron_nt
    Yabc_book = [5.6711im  -1.8362im  -0.7033im; 
                -1.8362im   5.9774im  -1.169im; 
                -0.7033im  -1.1690im   5.3911im]
    for i in 1:3
        for j in 1:3
            @test abs(Yabc_calc[i,j] - Yabc_book[i,j]) < abs(Yabc_book[i,j]) * tolerance
        end
    end
end