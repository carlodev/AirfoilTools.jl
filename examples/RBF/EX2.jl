using AirfoilTools
using AirfoilTools.AirfoilCST
using AirfoilTools.RBF
using LinearAlgebra

"""
In this example we provide a circular deformation of the airfoil
"""


fname = "DU89.csv" #"n0012.csv"

ap0 = get_airfoil_coordinates(joinpath(@__DIR__, "..", fname))

model0 =  AirfoilPoints2vv(ap0)

movenodes= model0[1:length(model0)] #coordinates of the node to move. It does not have to live on the airfoil
fixnodes = model0[[]] #fix node at the bottom side

RBFfun = RBFFunctionLocalSupport(RBF_CP4, 1.0)


## Circular displacement
chord = 1.0
r = chord/2
δ = 0.005

"""
Circular deformation
"""
function circ(p)
    x,y = p
    # y>0 ? s = 1 : s=-1 
    δy= δ/r .*  sqrt(r^2 - (x-r)^2)
    return [0,δy]
end
circ_displ = [circ(p) for p in movenodes]


model1 = MorphRBF(model0, movenodes, fixnodes, circ_displ, RBFfun;use_affine=false)

ap1 =  vv2AirfoilPoints(model1,ap0)



using Plots
Plots.default(linewidth=2)
# plotly()
plot(ap0.xu, ap0.yu, label="original", linecolor=:black, aspect_ratio = 1)
plot!(ap0.xl, ap0.yl, label=false, linecolor=:black)

plot!(ap1.xu, ap1.yu, label="Morph Deformation",linecolor=:red)
plot!(ap1.xl, ap1.yl, label=false, linecolor=:red)




