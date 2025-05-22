function get_DesignParameters(rbfd::RBFDesign)
    return vcat(rbfd.cy)
end

function  perturb_DesignParameter(rbfd::RBFDesign, i::Int, δ::Real)
    return perturb_DesignParameter(rbfd, [i], [δ])
end

function  perturb_DesignParameter(rbfd::RBFDesign, ix::Vector{Int}, δx::Vector{Float64})
    @assert length(ix) == length(δx)
    surfaces = Symbol.(map(i->getsurface(rbfd.rbfg.control_points, i),ix))
    model0 =  AirfoilPoints2vv(rbfd.ap)

    function oneside_morph(surfaces::Vector{Symbol}, surface::Symbol)
   
        i_idx = findall(==( surface ), surfaces)
        movenodes = [[rbfd.rbfg.control_points[i],rbfd.cy[i]] for i in ix[i_idx]]
        fixnodes = get_fixnodes(rbfd.ap, Val(surface))
    
        #Linear vertical displacement
        displacement = [[0.0,δ] for δ in δx[i_idx]]
        model1 = MorphRBF(model0, movenodes, fixnodes, displacement, rbfd.rbfg.RBFfun;use_affine=false)
        model_surface = get_surface_model(model1, Val(surface),rbfd.ap)
    
        return model_surface
    end
    model2 = vcat([oneside_morph(surfaces, ss) for ss in unique(surfaces)]...)

    @assert length(model0) == length(model2)

    ap1 =  vv2AirfoilPoints(model2,rbfd.ap)

    cy = deepcopy(rbfd.cy)
    cy[ix] = cy[ix] + δx
    
    return RBFDesign(rbfd.rbfg, cy, ap1)

end



function get_surface_model(model::Vector{Vector{Float64}}, ::Val{:upper}, ap::AirfoilPoints)
    n = length(ap.xu)    
    return model[1:n]
end

function get_surface_model(model::Vector{Vector{Float64}}, ::Val{:lower}, ap::AirfoilPoints)
    n = length(ap.xu)    
    return model[n+1:end]
end



function add_le_te_nodes(vv::Vector{Vector{Float64}})
    push!(vv,[0.0,0.0])
    push!(vv,[1.0,0.0])
    return vv
end

function get_fixnodes(ap::AirfoilPoints, ::Val{:upper})
    v= [[a,b] for (a,b) in zip(ap.xl,ap.yl)]
    return add_le_te_nodes(   v)
end


function get_fixnodes(ap::AirfoilPoints, ::Val{:lower})
    v= [[a,b] for (a,b) in zip(ap.xu,ap.yu)]
    return add_le_te_nodes(v)

end


function RBFDesign(rbfd::RBFDesign,w::Vector{Float64})
    w0 = get_DesignParameters(rbfd)
    @assert length(w) == length(w0) "updating RBFDesign possible only with same number of control points"
    
    ix = collect(eachindex(w))
    δw = Float64.(w-w0)
    rbfd_new = perturb_DesignParameter(rbfd, ix, δw)
    
    return rbfd_new
end