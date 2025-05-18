mutable struct OverHeadLine <: AbstractTransmissionLine
    basicdata::TLBasicData
    geometry::TLGeometry
    conductor::TLConductor
    groundwire::TLGroundWire
    parameters::ElectricalParameters
end