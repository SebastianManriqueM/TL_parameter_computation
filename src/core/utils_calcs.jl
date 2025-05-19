function get_gmr_from_diameter_inch(
    diameter_inch::Float64, 
    )
    return ℯ^(-1/4) * (0.5 * diameter_inch * FACTOR_FT_INCH) 
end

#GMR RETURNS IN FEET, AND XL SHOULD BE GIVEN IN OHM/KFT AND FREQUENCY IN HZ
function get_gmr_from_XL(
    XL::Float64, 
    frequency::Float64
    )
    return 1/ℯ^( (XL / FACTOR_MILES_KFT) / (L_CONST_OHM_MILE*frequency) )
end

#XL RETURN IN OHM/KFT AND GMR SHOULD BE GIVEN IN FT.
function get_XL_from_gmr(
    gmr::Float64,
    frequency::Float64 
    )
    return frequency * L_CONST_OHM_MILE * log(1/gmr) * FACTOR_MILES_KFT #Ohm/kft
end

#r equivalent for Capacitance calc. RETURNS IN FEET, AND XL SHOULD BE GIVEN IN OHM/KFT AND FREQUENCY IN HZ
function get_req_from_XC(
    XC::Float64, 
    frequency::Float64
    )
    return 1/ℯ^( ( XC * frequency * FACTOR_MILES_KFT )/( XC_FACTOR_MOHM_MILE ) )
end

function get_distance_xy( 
    x::Union{Matrix{Float64}, Vector{Float64}},
    y::Union{Matrix{Float64}, Vector{Float64}} 
    )
    return sqrt( ( x[1] - x[2] )^2 + ( y[1] - y[2] )^2 )
end

function get_all_distances(
    n_cables::Int,
    x_coordinates::Matrix{Float64},
    y_coordinates::Matrix{Float64}
    )
    n_dist    = round( Int , ( factorial(n_cables) ) / ( factorial(2) * factorial(n_cables - 2) ) )#N distance/combinations
    distances = zeros( 1 , n_dist)
    iter      = combinations( collect(1:n_cables), 2 )
    i         = 1
    
    for idx_v in iter
        distances[i] = get_distance_xy( x_coordinates[idx_v] , y_coordinates[idx_v] )
        i = i+1
    end
    return distances, collect(iter)
end



#|------------------------------------------------|
#|-------------GET TL CONDUCTOR STRUCT------------|
#|________________________________________________|

function get_regpoly_xy_coord( 
    n_bundling::Int,
    bundlingspacing::Float64
    )

    x_coords = zeros(Float64, 1, n_bundling)
    y_coords = zeros(Float64, 1, n_bundling)

    radius = bundlingspacing / ( 2 * sin( π/n_bundling ) )
    angle_increment = 2 * π / n_bundling

    for i in 0:( n_bundling - 1 )
        angle         = i * angle_increment
        x_coords[i+1] = radius * cos(angle)
        y_coords[i+1] = radius * sin(angle)
    end

    return x_coords, y_coords, radius
end

function get_gmr_bundling_xy( 
    X1::Matrix{Float64}, 
    Y1::Matrix{Float64},
    r::Float64, 
    gmr_cable::Float64 = r * 1/exp(1/4) #K_gmr = 1/exp(1/4)    # This is for solid/compact conductors. For Stranded see IEC 60287-1-3
    )
    
    GMR_bundle = 1
    n     = length( X1 )
    for i = 1 : n
        for j = 1 : n
            if i == j 
                GMR_bundle = GMR_bundle * gmr_cable
                continue
            end
            GMR_bundle = GMR_bundle * get_distance_xy( [ X1[i] X1[j] ], [ Y1[i] Y1[j] ] )#get_distance_p1p2( [ X1[i] Y1[i] ], [ X1[j] Y1[j] ] )
        end
    end
    return GMR_bundle^( 1 / (n * n) )
end