module AirfoilCST

#Inspired by the paper "Universal Parametric Geometry Representation Method", Brenda M. Kulfan, 10.2514/1.29958

using LinearAlgebra
using Optimization, OptimizationBBO
using XLSX, CSV, DataFrames,FileIO
using Parameters
using AirfoilTools.Core

export CSTweights
export CSTGeometry
export AirfoilPoints
export AirfoilCSTDesign
export get_airfoil_coordinates
export airfoil_from_cst

export circle
export NACA00
export CST_NACA0012

export perturb_DesignParameter
export get_DesignParameters

include("SpaceCST.jl")
include("ComputeCST.jl")
include("GeometryShapes.jl")
include("PerturbationCST.jl")

end
