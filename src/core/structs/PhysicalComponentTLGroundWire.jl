mutable struct TLGroundWire <: AbstractTLCable
    type::String
    awg::String
    kcmil::Float64
    diameter::Float64 #inches
    gmr::Float64      #inches
    Rdc_20::Float64
    XLinternal::Float64
    XCinternal::Float64
end