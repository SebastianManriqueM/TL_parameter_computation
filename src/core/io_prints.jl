
# mutable struct Line <: AbstractTransmissionLine
#     basicdata::TLBasicData
#     geometry::TLGeometry
#     conductor::TLConductor
#     groundw::TLGroundWire
#     parameters::ElectricalParameters
# end

Base.show(io::IO, tl::AbstractTransmissionLine) = print(io, 
                                                    "    basic_data: ", typeof(tl.basicdata),
                                                    "\n    geometry: ", typeof(tl.geometry),
                                                    "\n    conductor: ", typeof(tl.conductor),
                                                    "\n    ground_w: ", typeof(tl.groundw),
                                                    "\n    parameters: ", typeof(tl.parameters),
                                                    "\n"
                                                     )
# mutable struct TLBasicData
#     name::String
#     voltage_kv::Float64
#     n_circuits::Int
#     n_ground_wire::Int
#     state::String
#     structure_type::String
#     structure_code::String
#     distance::Float64       #Miles
#     S_rated::Float64        #MVA
#     frequency::Float64      #Hz
#     gnd_rho::Float64        #ohm/m
# end
Base.show(io::IO, basic_data::TLBasicData) = print(io, 
                                                    "Transmission Line Basic Data:",
                                                    "\n    name: ", basic_data.name,
                                                    "\n    voltage_kv: ", basic_data.voltage_kv,
                                                    "\n    n_circuits: ", basic_data.n_circuits,
                                                    "\n    n_ground_wire: ", basic_data.n_ground_wire,
                                                    "\n    state: ", basic_data.state,
                                                    "\n    structure_type: ", basic_data.structure_type,
                                                    "\n    structure_code: ", basic_data.structure_code,
                                                    "\n    distance: ", basic_data.distance,
                                                    "\n    S_rated: ", basic_data.S_rated,
                                                    "\n    frequency: ", basic_data.frequency,
                                                    "\n    gnd_rho: ", basic_data.gnd_rho,
                                                    "\n"
                                                     )



# mutable struct TLGeometry
#     n_cables::Int
#     x_coordinates::Matrix{Float64}  #ft
#     y_coordinates::Matrix{Float64}  #ft
#     combinations::Vector{Vector{Int64}}
#     distances::Matrix{Float64}      #ft
# end
Base.show(io::IO, geometry::TLGeometry) = print(io, 
                                                    "Transmission Line Geometry Data:",
                                                    "\n    n_cables: ", geometry.n_cables,
                                                    "\n    x_coordinates: ", geometry.x_coordinates,
                                                    "\n    y_coordinates: ", geometry.y_coordinates,
                                                    "\n    combinations: ", geometry.combinations,
                                                    "\n    distances: ", geometry.distances,
                                                    "\n"
                                                     )

# mutable struct TLConductor
#     type::String
#     codeword::String
#     stranding::String
#     kcmil::Float64
#     diameter::Float64   #inches
#     gmr::Float64        #ft
#     Rac_tnom::Float64   #ohm/kft
#     XLinternal::Float64 #ohm/kft
#     XCinternal::Float64 #Mohm/kft
#     ampacity::Float64   #Amperes
#     #weight::Float64 #-Could be interesting to add constraints TODO
#     #strenght::Float64 #-Could be interesting to add constraints TODO
#     bundling::Int
#     bundlingspacing::Float64
#     bundling_xcoordinates::Matrix{Float64}
#     bundling_ycoordinates::Matrix{Float64}
#     gmr_bundling::Float64        #ft
#     XL_bundling::Float64 #ohm/kft
#     r_ft_c_bundling::Float64 #equivalent radius in feet for C calculations
#     XC_bundling::Float64 #Mohm*kft
#     ampacity_bundling::Float64   #Amperes
# end
Base.show(io::IO, conductor::TLConductor) = print(io, 
                                                    "Transmission Conductor Data:",
                                                    "\n    type: ", conductor.type,
                                                    "\n    codeword: ", conductor.codeword,
                                                    "\n    stranding: ", conductor.stranding,
                                                    "\n    kcmil: ", conductor.kcmil,
                                                    "\n    diameter: ", conductor.diameter,
                                                    "\n    gmr: ", conductor.gmr,
                                                    "\n    Rac_tnom: ", conductor.Rac_tnom,
                                                    "\n    XLinternal: ", conductor.XLinternal,
                                                    "\n    XCinternal: ", conductor.XCinternal,
                                                    "\n    ampacity: ", conductor.ampacity,
                                                    "\n    bundling: ", conductor.bundling,
                                                    "\n    bundlingspacing: ", conductor.bundlingspacing,
                                                    "\n    bundling_xcoordinates: ", conductor.bundling_xcoordinates,
                                                    "\n    bundling_ycoordinates: ", conductor.bundling_ycoordinates,
                                                    "\n    gmr_bundling: ", conductor.gmr_bundling,
                                                    "\n    XL_bundling: ", conductor.XL_bundling,
                                                    "\n    r_ft_c_bundling: ", conductor.r_ft_c_bundling,
                                                    "\n    XC_bundling: ", conductor.XC_bundling,
                                                    "\n    ampacity_bundling: ", conductor.ampacity_bundling,
                                                    "\n"
                                                     )

# mutable struct TLGroundWire
#     type::String
#     awg::String
#     kcmil::Float64
#     diameter::Float64 #inches
#     gmr::Float64      #inches
#     Rdc_20::Float64
#     XLinternal::Float64
#     XCinternal::Float64
# end
Base.show(io::IO, ground_wire::TLGroundWire) = print(io, 
                                                    "Transmission Line Ground Wire Data:",
                                                    "\n    type: ", ground_wire.type,
                                                    "\n    awg: ", ground_wire.awg,
                                                    "\n    kcmil: ", ground_wire.kcmil,
                                                    "\n    diameter: ", ground_wire.diameter,
                                                    "\n    gmr: ", ground_wire.gmr,
                                                    "\n    Rdc_20: ", ground_wire.Rdc_20,
                                                    "\n    XLinternal: ", ground_wire.XLinternal,
                                                    "\n    XCinternal: ", ground_wire.XCinternal,
                                                    "\n"
                                                     )

# mutable struct ElectricalParameters
#     Zabcg::Matrix{ComplexF64}       #Series impedance Primitive Matrix                          ohm/mile
#     Z_kron_nt::Matrix{ComplexF64}   #Series impedance Kron reduced matrix - non transposed      ohm/mile
#     Z012_nt::Matrix{ComplexF64}     #Series impedance Sequence Matrix - non transposed          ohm/mile
#     Z_kron_ft::Matrix{ComplexF64}   #Series impedance Kron reduced matrix - fully transposed    ohm/mile
#     Z012_ft::Matrix{ComplexF64}     #Series impedance Sequence Matrix - fully transposed        ohm/mile
#     Y_kron_nt::Matrix{ComplexF64}   #Shunt admittance Kron reduced matrix - non transposed      ohm/mile
#     Y012_nt::Matrix{ComplexF64}     #Shunt admittance Sequence Matrix - non transposed          ohm/mile
#     Y_kron_ft::Matrix{ComplexF64}   #Shunt admittance Kron reduced matrix - fully transposed    ohm/mile
#     Y012_ft::Matrix{ComplexF64}     #Shunt admittance Sequence Matrix - fully transposed        ohm/mile
#     r1::Float64                     #Positive/negative sequence series resistance Ohms/mile              ohm/mile
#     x1::Float64                     #Positive/negative sequence series reactance  Ohms/mile              ohm/mile
#     b1::Float64                     #Positive/negative sequence shunt suceptance  uS/mile              uS/mile
#     r0::Float64                     #Zero sequence series resistance
#     x0::Float64                     #Zero sequence series reactance
#     b0::Float64                     #Zero sequence shunt suceptance                             uS/mile
#     r0m::Float64                    #Zero sequence mutual resistance (Between circuits)
#     x0m::Float64                    #Zero sequence mutual reactance (Between circuits)
#     b0m::Float64                    #Zero sequence mutual suceptance (Between circuits)
#     Z_sil::Float64                  #Surge impedance in Ohms
#     sil::Float64                    # Surge Impedance Load in MW
#     #Zabcg_pu::Matrix{Float64}       #Primitive Matrix
#     #Z_kron_pu::Matrix{Float64}      #Kron reduced matrix
#     #Z012_pu::Matrix{Float64}        #Sequence Matrix
# end
Base.show(io::IO, parameter::ElectricalParameters) = print(io, 
                                                    "Transmission Conductor Data:",
                                                    "\n    Zabcg: ", typeof(parameter.Zabcg),
                                                    "\n    Z_kron_nt: ", typeof(parameter.Z_kron_nt),
                                                    "\n    Z012_nt: ", typeof(parameter.Z012_nt),
                                                    "\n    Z_kron_ft: ", typeof(parameter.Z_kron_ft),
                                                    "\n    Z012_ft: ", typeof(parameter.Z012_ft),
                                                    "\n    Y_kron_nt: ", typeof(parameter.Y_kron_nt),
                                                    "\n    Y012_nt: ", typeof(parameter.Y012_nt),
                                                    "\n    Y_kron_ft: ", typeof(parameter.Y_kron_ft),
                                                    "\n    Y012_ft: ", typeof(parameter.Y012_ft),
                                                    "\n    r1: ", parameter.r1,
                                                    "\n    x1: ", parameter.x1,
                                                    "\n    b1: ", parameter.b1,
                                                    "\n    r0: ", parameter.r0,
                                                    "\n    x0: ", parameter.x0,
                                                    "\n    b0: ", parameter.b0,
                                                    "\n    r0m: ", parameter.r0m,
                                                    "\n    x0m: ", parameter.x0m,
                                                    "\n    b0m: ", parameter.b0m,
                                                    "\n    Z_sil: ", parameter.Z_sil,
                                                    "\n    sil: ", parameter.sil,
                                                    "\n"
                                                     )
