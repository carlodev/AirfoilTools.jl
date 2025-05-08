module AirfoilCST

#Inspired by the paper "Universal Parametric Geometry Representation Method", Brenda M. Kulfan, 10.2514/1.29958

using LinearAlgebra
using Optimization, OptimizationBBO
using XLSX, CSV, DataFrames,FileIO
using Parameters

export CSTweights
export CSTGeometry
export AirfoilPoints
export get_airfoil_coordinates
export airfoil_from_cst

include("ClassShapes.jl")
include("ComputeCST.jl")

end
