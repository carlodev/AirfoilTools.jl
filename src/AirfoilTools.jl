module AirfoilTools

include(joinpath("AirfoilCore","AirfoilCore.jl"))

include(joinpath("AirfoilCST","AirfoilCST.jl"))

include(joinpath("RBF","RBF.jl"))



# Re-export everything from submodules
include("Export.jl")

end
