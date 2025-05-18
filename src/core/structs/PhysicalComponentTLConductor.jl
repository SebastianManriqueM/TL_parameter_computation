mutable struct TLConductor <: AbstractTLCable
    type::String
    codeword::String
    stranding::String
    kcmil::Float64
    diameter::Float64   #inches
    gmr::Float64        #ft
    Rac_tnom::Float64   #ohm/kft
    XLinternal::Float64 #ohm/kft
    XCinternal::Float64 #Mohm/kft
    ampacity::Float64   #Amperes
    #weight::Float64 #-Could be interesting to add constraints TODO
    #strenght::Float64 #-Could be interesting to add constraints TODO
    bundling::Int
    bundlingspacing::Float64
    bundling_xcoordinates::Matrix{Float64}
    bundling_ycoordinates::Matrix{Float64}
    gmr_bundling::Float64        #ft
    XL_bundling::Float64 #ohm/kft
    r_ft_c_bundling::Float64 #equivalent radius in feet for C calculations
    XC_bundling::Float64 #Mohm*kft
    ampacity_bundling::Float64   #Amperes
end