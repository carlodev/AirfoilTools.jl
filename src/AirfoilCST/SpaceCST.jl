

"""
CSTweights

    It stores the weight for the upper and lower side of the airfoil
    wu = CST weight of upper surface
    wl = CST weight of lower surface
"""
struct CSTweights
    wu::Vector{Float64}
    wl::Vector{Float64}
end

function CSTweights(n::Int64, f::Float64)
    @assert f>0
    wu = f .* ones(n)
    wl = -1 .* wu
    return CSTweights(wu,wl)
end

Base.iterate(c::CSTweights, state=(1, :upper)) = _next(c, state)

function _next(c::CSTweights, (i, section))
    if section == :upper
        if i <= length(c.wu)
            return (("upper", c.wu[i]), (i + 1, :upper))
        else
            return _next(c, (1, :lower))  # move to lower
        end
    elseif section == :lower
        if i <= length(c.wl)
            return (("lower", c.wl[i]), (i + 1, :lower))
        else
            return nothing  # done
        end
    end
end

"""
CSTGeometry

    N1 = 0.5 and N2 = 1 for basic airfoil shape
    N1 = 0.5 and N2 = 0.5 for NACA-type airfoil
    N1 = 1.0 and N2 = 1.0 for an elliptic airfoil

"""
@with_kw struct CSTGeometry
    cstw::CSTweights
    dz::Float64 = 0.0
    N1::Real = 0.5
    N2::Real = 1.0
end

function CSTGeometry(cst::CSTGeometry,cstw::CSTweights)
    @unpack dz,N1,N2 = cst
    CSTGeometry(cstw, dz,N1,N2)
end

function CSTGeometry(cst::CSTGeometry,dz::Float64)
    @unpack cstw, N1,N2 = cst
    CSTGeometry(cstw, dz,N1,N2)
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


function Base.ones(v::Vector)
    N = length(v)
    return ones(N)
end

function Base.zeros(v::Vector)
    N = length(v)
    return zeros(N)
end

function Base.similar(ap::AirfoilPoints)
    nu=length(ap.xu)
    nl=length(ap.xl)
    AirfoilPoints(ap.xu,ap.xl,  Vector(undef, nu), Vector(undef, nl))
end


"""
    ClassFunction(x::Vector{Float64},N1::Real,N2::Real)

Compute the class function
    ``C = \\phi^N1 \\cdot(1-\\phi)^N2``
"""
function ClassFunction(x::Vector{Float64},N1::Real,N2::Real)
    @assert N1>0
    @assert N2>0 

    C = zeros(length(x))

    for (i,xi) in enumerate(x)
        C[i] = xi^N1*((1-xi)^N2)
    end

    return C    
end


"""
    ShapeFunction(w::Vector,x::Array{Float64})

Compute the shape function

"""
function ShapeFunction(w::Vector,x::Array{Float64})
 
    # Shape function; using Bernstein Polynomials
    n = length(w)-1 # Order of Bernstein polynomials
    
    K = zeros(n+1)
    
    for i = 1:n+1
         K[i] = factorial(n)/(factorial(i-1)*(factorial((n)-(i-1))))
    end
    
    S = zeros(length(x))
    
    for (i,xi) in enumerate(x)
        for j = 1:n+1
            S[i] = S[i] + w[j]*K[j]*xi^(j-1)*((1-xi)^(n-(j-1)))
        end
    end

    return S

end
    
"""
    compute_airfoil_y(w::Vector,x::Array{Float64},N1::Real,N2::Real,dz::Real)

Given the weights w, and the coordinates x, it gives the coordinates y
"""
function compute_airfoil_y(w::Vector,x::Array{Float64},N1::Real,N2::Real,dz::Real)

        #Compute Class Function
        C = ClassFunction(x,N1,N2)

        #Compute Shape Function
        S = ShapeFunction(w,x)
        #  Calculate y output
        y = zeros(length(x))
        for (i,xi) in enumerate(x)
           y[i] = C[i]*S[i] + xi*dz;
        end
                
        return y
end


"""
    generate_cst_airfoil(cst::CSTGeometry, N::Int) ->   AirfoilPoints


Generates a discretized airfoil shape from the given CST geometry definition.
- `cst::CSTGeometry`: A struct containing the CST upper and lower weights, trailing edge displacement `dz`, and the class function parameters `N1`, `N2`.
- `N::Int`: Number of intervals used for the surface discretization. The function will produce `N + 1` points spanning from the leading to the trailing edge.

"""
function airfoil_from_cst(cst::CSTGeometry, N::Int64)
    #  Create x coordinate
    x=ones(N+1)
    return airfoil_from_cst(cst, x)
    return  anew

end

function airfoil_from_cst(cst::CSTGeometry, x::Vector{Float64})

    #Zeta is used to have a better refinement close to trailing and leading edge
    zeta=zeros(N+1)
    for i=1:N+1
        zeta[i]=2*pi/N*(i-1)
        x[i]=0.5*(cos(zeta[i])+1)
    end

    zerind = findall(isapprox.(x,0.0))[1] # Used to separate upper and lower surfaces

    #Here is important to dectect the orientation
    xu= x[1:zerind-1] # Lower surface x-coordinates
    xl = x[zerind:end] # Upper surface x-coordinates

    anew = airfoil_from_cst(cst, xu, xl)

    return  anew

end



function airfoil_from_cst(airfoil_geometry::AirfoilPoints, cst::CSTGeometry)
    @unpack cstw,dz,N1,N2 = cst
    @unpack xu,xl = airfoil_geometry
    anew = airfoil_from_cst(cstw.wu,cstw.wl,dz,xu, xl, N1, N2)
    return anew
end

function airfoil_from_cst(cst::CSTGeometry, xu::Vector, xl::Vector)
    @unpack cstw,dz,N1,N2 = cst

    anew = airfoil_from_cst(cstw.wu,cstw.wl,dz,xu, xl, N1, N2)
    return anew
end

function airfoil_from_cst(wu::Vector,wl::Vector,dz::Real,xu::Vector, xl::Vector, N1::Real, N2::Real)

    yl = compute_airfoil_y(wl,xl,N1,N2,-dz) # Call ClassShape function to determine lower surface y-coordinates
    yu = compute_airfoil_y(wu,xu,N1,N2,dz)  # Call ClassShape function to determine upper surface y-coordinates
    anew = AirfoilPoints(xu,xl,yu,yl)
    return anew

end



