struct ControlPoints
    cu::Vector{Float64}
    cl::Vector{Float64}
end


"""
    RBFGeometry

"""
struct RBFGeometry
    control_points::ControlPoints
    RBFfun::RBFFunction
end



struct RBFDesign<:AirfoilDesign
    rbfg::RBFGeometry
    cy::ControlPoints
    ap::AirfoilPoints
end


Base.vcat(c::ControlPoints) = [c.cu...;c.cl...]

Base.iterate(c::ControlPoints, state=(1, :upper)) = _next(c, state)

function Base.length(c::ControlPoints)
    cuL = length(c.cu)
    clL = length(c.cl)
    return Int(cuL+clL)
end

function _next(c::ControlPoints, (i, section))
    if section == :upper
        if i <= length(c.cu)
            return (("upper", c.cu[i]), (i + 1, :upper))
        else
            return _next(c, (1, :lower))  # move to lower
        end
    elseif section == :lower
        if i <= length(c.cl)
            return (("lower", c.cl[i]), (i + 1, :lower))
        else
            return nothing  # done
        end
    end
end


function Base.getindex(cp::ControlPoints, i::Int)
    if i <= length(cp.cu)
        return cp.cu[i]
    elseif i <= length(cp.cu) + length(cp.cl)
        return cp.cl[i - length(cp.cu)]
    else
        throw(BoundsError(cp, i))
    end
end

function Base.getindex(cp::ControlPoints, idx::AbstractVector{Int})
    return [cp[i] for i in idx]
end

function Base.setindex!(cp::ControlPoints, value, i::Int)
    if i <= length(cp.cu)
        cp.cu[i] = value
    elseif i <= length(cp.cu) + length(cp.cl)
        cp.cl[i - length(cp.cu)] = value
    else
        throw(BoundsError(cp, i))
    end
end
function Base.setindex!(cp::ControlPoints, vals::AbstractVector, idx::AbstractVector{Int})
    @assert length(vals) == length(idx)
    for (i, v) in zip(idx, vals)
        cp[i] = v
    end
end

function getsurface(cp::ControlPoints, i::Int)
    if i <= length(cp.cu)
        return "upper"
    elseif i <= length(cp.cu) + length(cp.cl)
        return "lower"
    else
        throw(BoundsError(cp, i))
    end
end


function find_cpoints_idx(xp::Float64, ::Val{:upper},  ap::AirfoilPoints)
    return find_cpoints_idx(ap.xu,xp)
end

function find_cpoints_idx(xp::Float64, ::Val{:lower},  ap::AirfoilPoints)
    return find_cpoints_idx(ap.xl,xp)
end


function find_cpoints_idx(xx::Vector{Float64},  xp::Float64)
 @assert maximum(xx)>=xp>= minimum(xx)
 distances = [norm(v - xp) for v in xx]
 min_index = argmin(distances)
 return min_index
end

function find_ap_y_idx(idx::Int64,::Val{:upper}, ap::AirfoilPoints)
    return ap.yu[idx]
end

function find_ap_y_idx(idx::Int64,::Val{:lower}, ap::AirfoilPoints)
    return ap.yl[idx]
end
    



function RBFDesign(rbfg::RBFGeometry, ap::AirfoilPoints)
    yu = Float64[]
    yl = Float64[]
    for c in rbfg.control_points
        surface,xp = c
        ss = Val(Symbol(surface))
        idx = find_cpoints_idx(xp, ss ,  ap)
        y_new = find_ap_y_idx(idx,ss, ap)
    
        if ss == Val(:upper)
            push!(yu,y_new)
        else
            push!(yl,y_new)
        end
    end
    cy = ControlPoints(yu,yl)
    RBFDesign(rbfg,cy, ap)

end
