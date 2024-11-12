include("definitions.jl")
include("common_filters.jl")



#|------------------------------------------------|
#|------------GET TL PARAMETERS STRUCT------------|
#|________________________________________________|

function get_primitive_z_matrix( 
    basicdata::TLBasicData,
    geometry::TLGeometry,
    conductor::TLConductor,
    ground_wire::TLGroundWire, 
    )#::Zprimitive

    rho  = basicdata.gnd_rho
    freq = basicdata.frequency

    Rac_tnom  = conductor.Rac_tnom
    Rdc_20_gw = ground_wire.Rdc_20
    gmr_bund  = conductor.gmr_bundling
    gmr_gw    = ground_wire.gmr
    n_bund    = conductor.bundling
    
    n_cond      = geometry.n_cables
    z_primitive = zeros( ComplexF64, n_cond, n_cond)

    #TODO Handling with different units
    L_FACTOR  = L_FACTOR_OHM_MILE
    L_CONST   = L_CONST_OHM_MILE
    R_CONST   = R_CONST_OHM_MILE

    #out diagonal
    j = 1
    for i in geometry.combinations
        z_primitive[i[1] , i[2]] = R_CONST*freq + ( L_CONST*freq*( log(1/geometry.distances[j]) + L_FACTOR + 0.5*log(rho/freq) ) )*im
        z_primitive[i[2] , i[1]] = z_primitive[i[1] , i[2]]
        j = j + 1
    end
    
    #diagonal - Conductors
    for i = 1:n_cond
        #TODO Add capability to represent 2 different conductors in different circuits - change Rac_tnom and gmr at elseif
        if i <= 3  #Circuit 1
            z_primitive[i , i] = ( (Rac_tnom/n_bund) / FACTOR_MILES_KFT ) + R_CONST*freq + ( L_CONST*freq*( log(1/gmr_bund) + L_FACTOR + 0.5*log(rho/freq) ) )*im
        elseif  basicdata.n_circuits == 2 && i <= basicdata.n_circuits * 3  #Circuit 2
            z_primitive[i , i] = ( (Rac_tnom/n_bund) / FACTOR_MILES_KFT ) + R_CONST*freq + ( L_CONST*freq*( log(1/gmr_bund) + L_FACTOR + 0.5*log(rho/freq) ) )*im
        else #Ground wire
            z_primitive[i , i] = ( Rdc_20_gw / FACTOR_MILES_KFT ) + R_CONST*freq + ( L_CONST*freq*( log(1/gmr_gw) + L_FACTOR + 0.5*log(rho/freq) ) )*im
        end

    end
    return z_primitive#Zprimitive(z_primitive)
end

function get_primitive_potential_matrix( 
    basicdata::TLBasicData,
    geometry::TLGeometry,
    conductor::TLConductor,
    ground_wire::TLGroundWire, 
    )#::Pprimitive
    gmr_bund  = conductor.gmr_bundling
    gmr_gw    = ground_wire.gmr
    
    n_cond      = geometry.n_cables
    p_primitive = zeros( ComplexF64, n_cond, n_cond)

    #TODO Handling with different units

    #out diagonal
    j = 1
    for i in geometry.combinations
        #get_distance_xy( x_coordinates[idx_v] , y_coordinates[idx_v] )
        #get_distance_xy( [ geometry.x_coordinates[ i[1] ] , geometry.x_coordinates[ i[2] ] ] , [ geometry.y_coordinates[ i[1] ] , -geometry.y_coordinates[ i[2] ] ] )
        Sij = get_distance_xy( [ geometry.x_coordinates[ i[1] ] , geometry.x_coordinates[ i[2] ] ] , [ geometry.y_coordinates[ i[1] ] , -geometry.y_coordinates[ i[2] ] ] )

        p_primitive[i[1] , i[2]] = ( 1 / (2*π*ϵ_AIR_μF_MILE) ) * ( log( Sij / geometry.distances[j] ) )
        p_primitive[i[2] , i[1]] = p_primitive[i[1] , i[2]]
        j = j + 1
    end
    
    #diagonal - Conductors
    for i = 1:n_cond
        #TODO Add capability to represent 2 different conductors in different circuits - change Rac_tnom and gmr at elseif
        Sii = get_distance_xy( [ geometry.x_coordinates[ i ] , geometry.x_coordinates[ i ] ] , [ geometry.y_coordinates[ i ] , -geometry.y_coordinates[ i ] ] )

        if i <= 3  #Circuit 1
            p_primitive[i , i] = ( 1 / (2*π*ϵ_AIR_μF_MILE) ) * ( log( Sii / gmr_bund ) )
        elseif  basicdata.n_circuits == 2 && i <= basicdata.n_circuits * 3  #Circuit 2
            p_primitive[i , i] = ( 1 / (2*π*ϵ_AIR_μF_MILE) ) * ( log( Sii / gmr_bund ) )
        else #Ground wire
            p_primitive[i , i] = ( 1 / (2*π*ϵ_AIR_μF_MILE) ) * ( log( Sii / gmr_gw ) )
        end

    end
    return p_primitive#Zprimitive(z_primitive)
end

function get_kron_reduced_z_matrix(
    basicdata::TLBasicData, 
    geometry::TLGeometry,
    z_primitive::Matrix{ComplexF64}
    )#::Zkron
    n_cond = geometry.n_cables - basicdata.n_ground_wire
    n_gc   = basicdata.n_ground_wire
    
    Zph_ph = z_primitive[ 1          : n_cond       , 1          : n_cond ]
    Zph_g  = z_primitive[ 1          : n_cond       , n_cond + 1 : n_cond + n_gc ]
    Zg_ph  = z_primitive[ n_cond + 1 : n_cond + n_gc, 1          : n_cond ]
    Zg_g   = z_primitive[ n_cond + 1 : n_cond + n_gc, n_cond + 1 : n_cond + n_gc ]

    return Zph_ph - ( Zph_g * inv(Zg_g) * Zg_ph )#Zkron( Zph_ph - ( Zph_g * inv(Zg_g) * Zg_ph ) )
end

function get_off_diagonal_average( 
    z_kron_nt::Matrix{ComplexF64}
    )
    return ( z_kron_nt[1,2] + z_kron_nt[1,3] + z_kron_nt[2,3] ) / 3
end

function get_diagonal_average( 
    z_kron_nt::Matrix{ComplexF64}
    )
    return ( z_kron_nt[1,1] + z_kron_nt[2,2] + z_kron_nt[3,3] ) / 3
end

function update_off_diagonal_fully_transposed(  
    average_diagonal::ComplexF64,
    average_off_diagonal::ComplexF64
    )
    z_kron_ft = zeros(ComplexF64, 3, 3)
    j=1
    for i in collect( combinations( collect(1:3), 2 ) )
        z_kron_ft[ i[1] , i[2] ] = average_off_diagonal
        z_kron_ft[ i[2] , i[1] ] = average_off_diagonal
        z_kron_ft[ j , j ]       = average_diagonal
        j=j+1
    end
    return z_kron_ft
end

function get_fully_transposed_z( 
    basicdata::TLBasicData, 
    z_kron_nt::Matrix{ComplexF64} 
    )
    dim                  = size(z_kron_nt)[1]
    z_kron_ft            = zeros(Complex{Float64}, dim, dim)
    average_off_diagonal = get_off_diagonal_average( z_kron_nt[1:3 , 1:3] )
    average_diagonal     = get_diagonal_average( z_kron_nt[1:3 , 1:3] )
    z_kron_ft[1:3 , 1:3] = update_off_diagonal_fully_transposed( average_diagonal, average_off_diagonal)

    if basicdata.n_circuits == 2
        average_off_diagonal = get_off_diagonal_average( z_kron_nt[4:6 , 4:6] )
        average_diagonal     = get_diagonal_average( z_kron_nt[4:6 , 4:6] )
        z_kron_ft[4:6 , 4:6] = update_off_diagonal_fully_transposed( average_diagonal, average_off_diagonal)
        
        average_couplings    = mean( z_kron_nt[1:3 , 4:6] )
        z_kron_ft[1:3 , 4:6] = fill(average_couplings, 3, 3)
        z_kron_ft[4:6 , 1:3] = z_kron_ft[1:3 , 4:6]
    end
    return z_kron_ft
end

function get_sequence_z_matrix( 
    basicdata::TLBasicData,
    z_kron::Matrix{ComplexF64}
    )#::Zsequence
    a      = cos(2*π/3)  + sin(2*π/3)im
    a2     = cos(-2*π/3) + sin(-2*π/3)im

    T_SEQ  = [ 1  1  1;
               1 a2  a;
               1  a  a2 ]
    #IT_SEQ = (1/3)* [ 1  1  1;
    #                  1  a  a2;
    #                  1 a2  a ]
    if basicdata.n_circuits == 2
        off_diagonal = zeros(3,3)
        T_SEQ = [ T_SEQ off_diagonal; off_diagonal T_SEQ ]
    end

    
    return inv(T_SEQ) * z_kron * T_SEQ#Zsequence( inv(T_SEQ) * z_kron * T_SEQ)

end


function get_tl_parameters(
    basicdata::TLBasicData,
    geometry::TLGeometry,
    conductor::TLConductor,
    ground_wire::TLGroundWire 
    )::ElectricalParameters
    dim_primitive = ( 3 * basicdata.n_circuits ) + basicdata.n_ground_wire
    dim_kron      = dim_primitive - basicdata.n_ground_wire

    Zabcg     = get_primitive_z_matrix( basicdata, geometry, conductor, ground_wire)
    Z_kron_nt = get_kron_reduced_z_matrix( basicdata, geometry, Zabcg )
    Z012_nt   = get_sequence_z_matrix( basicdata, Z_kron_nt )

    Z_kron_ft = get_fully_transposed_z( basicdata, Z_kron_nt )
    Z012_ft   = get_sequence_z_matrix( basicdata, Z_kron_ft )

    Pabcg     = get_primitive_potential_matrix( basicdata, geometry, conductor, ground_wire )
    @show Pabcg
    P_kron_nt = get_kron_reduced_z_matrix( basicdata, geometry, Pabcg )
    @show P_kron_nt
    Y_kron_nt = 2 * π * basicdata.frequency * inv(P_kron_nt) * im
    Y012_nt   = get_sequence_z_matrix( basicdata, Y_kron_nt )

    Y_kron_ft = get_fully_transposed_z( basicdata, Y_kron_nt )
    Y012_ft   = get_sequence_z_matrix( basicdata, Y_kron_ft )

    r1 = real( Z012_ft[2,2] )                       #Positive/negative sequence resistance
    x1 = imag( Z012_ft[2,2] )
    b1 = imag( Y012_ft[2,2] )
    r0 = real( Z012_ft[1,1] )                       #Zero sequence resistance
    x0 = imag( Z012_ft[1,1] )
    b0 = imag( Y012_ft[1,1] )

    if basicdata.n_circuits > 1
        r0m = real( Z012_ft[4,1] )                       #Zero sequence resistance
        x0m = imag( Z012_ft[4,1] )
        b0m = imag( Y012_ft[4,1] )
    else
        r0m = 0                       #Zero sequence resistance
        x0m = 0
        b0m = 0
    end
    
    return ElectricalParameters( Zabcg, Z_kron_nt, Z012_nt, Z_kron_ft, Z012_ft, Y_kron_nt, Y012_nt, Y_kron_ft, Y012_ft, r1, x1, b1, r0, x0, b0, r0m, x0m, b0m )
end

function get_line_struct(
    basicdata::TLBasicData,
    geometry::TLGeometry,
    conductor::TLConductor,
    ground_wire::TLGroundWire,
    parameters::ElectricalParameters
    )::Line
    return Line( basicdata, geometry, conductor, ground_wire, parameters )
end