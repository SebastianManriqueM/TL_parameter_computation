using Parameters
using XLSX
using DataFrames

using LinearAlgebra
using Combinatorics
using Statistics

include( "core/definitions.jl" )
#-----Structs-----------------------------------
include( "core/structs/Filters.jl" )
include( "core/structs/ParametersElectricalParameters.jl" )
include( "core/structs/PhysicalComponentBasicData.jl" )
include( "core/structs/PhysicalComponentTLConductor.jl" )
include( "core/structs/PhysicalComponentTLGroundWire.jl" )
include( "core/structs/TransmissionLines.jl" )

#-----Core-----------------------------------
include("core/io_prints.jl" )
include( "core/common_filters.jl" ) 
include( "core/utils_calcs.jl" )
include( "core/filtering_tl_data.jl" )
include( "core/filtering_conductor_data.jl" )
include( "core/filtering_ground_wire_data.jl" )
include( "core/load_data.jl" )
include( "core/tl_parameters_calculator.jl" )