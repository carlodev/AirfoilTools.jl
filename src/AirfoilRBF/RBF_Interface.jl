function AirfoilPoints2vv(ap0::AirfoilPoints)
    model0 = [collect(a) for a in eachrow(hcat( [ap0.xu;ap0.xl],[ap0.yu;ap0.yl])) ]
    return model0
end


function vv2AirfoilPoints(model1::Vector{Vector{Float64}}, ap0::AirfoilPoints)
    n = length(ap0.xu)    
    xu1,yu1 = getindex.(model1[1:n],1), getindex.(model1[1:n],2)
    xl1,yl1 = getindex.(model1[n+1:end],1), getindex.(model1[n+1:end],2)

    ap1 = AirfoilPoints(xu1,xl1,yu1,yl1)
    return ap1
end

