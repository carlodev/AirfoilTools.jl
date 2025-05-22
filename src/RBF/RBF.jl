module RBF

using LinearAlgebra
using Parameters
using IterativeSolvers
using AirfoilTools.Core

export RBFFunction
export RBFFunctionGlobalSupport
export RBFFunctionLocalSupport
export MorphRBF
export MorphRBF!
export RBF_CP0
export RBF_CP2
export RBF_CP4
export RBF_CP6
export RBF_CTPS0
export RBF_CTPS1
export RBF_IQB
export RBF_GAUSS

export AirfoilPoints2vv
export vv2AirfoilPoints

export ControlPoints
export RBFGeometry
export RBFDesign

export perturb_DesignParameter
export get_DesignParameters

include("RBF_Functions.jl")
include("RBF_Morphing.jl")
include("RBF_Interface.jl")

include("AirfoilRBF.jl")
include("Perturbation.jl")
end