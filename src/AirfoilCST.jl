module AirfoilCST

#Inspired by the paper "Universal Parametric Geometry Representation Method", Brenda M. Kulfan, 10.2514/1.29958

using LinearAlgebra
using Optimization, OptimizationBBO
using XLSX, CSV, DataFrames,FileIO

export get_airfoil_coordinates
export get_CST_weights
export CST_airfoil

include("ClassShapes.jl")
include("ComputeCST.jl")

end
