function MorphRBF(modelgrid0::Vector, movenodes::Vector, fixnodes::Vector, displacement::Vector, RBFfun::RBFFunction; use_affine::Bool=false)
    Shift = compute_morph_shift(modelgrid0, movenodes, fixnodes, displacement, RBFfun, use_affine)
    return modelgrid0 .+ Shift
end

function MorphRBF!(modelgrid0::Vector, movenodes::Vector, fixnodes::Vector, displacement::Vector, RBFfun::RBFFunction; use_affine::Bool=false)
    Shift = compute_morph_shift(modelgrid0, movenodes, fixnodes, displacement, RBFfun, use_affine)
    return modelgrid0 .= modelgrid0 .+ Shift
end


function compute_morph_shift(modelgrid0::Vector, movenodes::Vector, fixnodes::Vector, displacement::Vector, RBFfun::RBFFunction, use_affine::Bool)
    bnodes = [movenodes; fixnodes]
    D, ΦM, ND = allocate_RBF_matrix(modelgrid0, bnodes, RBFfun, use_affine)
    rhs = allocate_RBF_rhs(movenodes, bnodes, displacement, ND, use_affine)
    Shift = solveRBF(modelgrid0, D, rhs, ΦM, ND, use_affine)
    return Shift
end


function allocate_RBF_matrix(modelgrid0::Vector, bnodes::Vector, RBFfun::RBFFunction, use_affine::Bool)
    Nc = length(modelgrid0)
    Nb = length(bnodes)
    ND = length(bnodes[1])  # dimensionality (2D or 3D)

    ΦM = zeros(Nc, Nb)
    for (j, p) in enumerate(modelgrid0)
        dists = map(bn -> norm(p - bn), bnodes)
        ΦM[j, :] = fRBF(dists, RBFfun)
    end

    Mbb = zeros(Nb, Nb)
    for (i, bn) in enumerate(bnodes)
        dists = map(bnn -> norm(bn - bnn), bnodes)
        Mbb[i, :] = fRBF(dists, RBFfun)
    end

    if use_affine
        Pb = ones(Nb, ND + 1)
        for (i, bn) in enumerate(bnodes)
            Pb[i, :] = [1, bn...]
        end
        D = hcat(vcat(Mbb, Pb'), vcat(Pb, zeros(ND + 1, ND + 1)))
    else
        D = Mbb
    end

    return D, ΦM, ND
end

function allocate_RBF_rhs(movenodes::Vector, bnodes::Vector, displacement::Vector, ND::Int, use_affine::Bool)
    Nb = length(bnodes)
    Nmove = length(movenodes)
    rhs = [zeros(Nb + (use_affine ? ND + 1 : 0)) for _ in 1:ND]

    for direction in 1:ND
        rhs[direction][1:Nmove] .= getindex.(displacement, direction)
    end

    return rhs
end

function solveRBF(modelgrid0::Vector, D::Matrix{Float64}, rhs::Vector, ΦM::Matrix{Float64}, ND::Int, use_affine::Bool)
    Nc = length(modelgrid0)
    ss = zeros(Nc, ND)
    Nb = size(ΦM, 2)

    for (direction, d0) in enumerate(rhs)
        αβ = gmres(D, d0)

        if use_affine
            α = αβ[1:Nb]
            β = αβ[end - ND : end]
            β0 = β[1]
            βv = β[2:end]
        else
            α = αβ
            β0 = 0.0
            βv = zeros(ND)
        end

        for (j, p) in enumerate(modelgrid0)
            ss[j, direction] = sum(ΦM[j, :] .* α) + β0 + βv ⋅ p
        end
    end

    Shift = typeof(modelgrid0)(undef, Nc)
    for j in 1:Nc
        Shift[j] = ss[j, :]
    end

    return Shift
end
