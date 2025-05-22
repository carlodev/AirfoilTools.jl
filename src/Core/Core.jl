module Core

export AirfoilDesign
export DesignParameters
export AirfoilPoints

export get_DesignParameters

abstract type AirfoilDesign end
abstract type DesignParameters end


function get_DesignParameters(x)
    error("No method defined for object of type $(typeof(x))")
end


struct AirfoilPoints
    xu::Vector{Float64}
    xl::Vector{Float64}
    yu::Vector{Float64}
    yl::Vector{Float64}
end


function AirfoilPoints(v::Vector)
    return AirfoilPoints(v,v,v,v)
end

function AirfoilPoints(xu::Vector,xl::Vector)
    return AirfoilPoints(xu,xl,xu,xl)
end



end