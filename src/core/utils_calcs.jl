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