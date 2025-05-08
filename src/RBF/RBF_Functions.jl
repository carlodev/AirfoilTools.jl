abstract type RBFFunction end

struct RBFFunctionGlobalSupport <: RBFFunction
    fun::Function
end

struct RBFFunctionLocalSupport <: RBFFunction
    fun::Function
    support_radius::Float64
end

function get_rbf_function(rbffun::RBFFunction)
    return rbffun.fun
end





function fRBF(x::Real, r::Real, fname::Function)
    x_norm = x / r
    if x_norm > 1
        return 0
    else
        return fname(x / r)
    end
end

function fRBF(x::AbstractVector, r::Real, fname::Function)
    map(v -> fRBF(v, r, fname), x)
end

function fRBF(x::AbstractVector, rbffun::RBFFunctionLocalSupport)
    fname = get_rbf_function(rbffun)
    r = rbffun.support_radius
    return fRBF(x, r, fname)
end

function fRBF(x::AbstractVector, rbffun::RBFFunctionGlobalSupport)
    fname = get_rbf_function(rbffun)
    return fRBF(x, fname)
end

function fRBF(x::Real, fname::Function)
    return fname(x)

end

function fRBF(x::AbstractVector, fname::Function)
    map(v -> fRBF(v, fname), x)
end




#Local Support
function RBF_CP0(x)
    return (1 - x)^2
end

function RBF_CP2(x)
    return (1 - x)^4 * (4 * x + 1)
end

function RBF_CP4(x)
    return (1 - x)^6 * (35 / 3 * x^2 + 6 * x + 1)
end

function RBF_CP6(x)
    return (1 - x)^8 * (32 * x^3 + 25 * x^2 + 8 * x + 1)
end

function RBF_CTPS0(x)
    return (1 - x)^5
end

function RBF_CTPS1(x)
    return 1 + 80 / 3 * x^2 - 40 * x^3 + 15 * x^4 - 8 / 3 * x^5 + 20 * x^2 * log(x)
end


#### Global Support
function RBF_IQB(x)
    return 1 / (1 + x^2)
end

function RBF_GAUSS(x)
    return exp(-x^2)
end