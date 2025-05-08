using AirfoilTools
using AirfoilTools.AirfoilCST
using AirfoilTools.RBF
using LinearAlgebra

"""
In this example we are going to move one point from the top side of the airfoil.
We are fixing the points on the bottom side of the airfoil.
"""

fname = "DU89.csv" #airfoil coordinates to load

ap0 = get_airfoil_coordinates(joinpath(@__DIR__, "..", fname))

model0 =  AirfoilPoints2vv(ap0)

movenodes= [model0[50]] #coordinates of the node to move. It does not have to live on the airfoil
fixnodes = model0[length(ap0.xu)+1:end] #fix node at the bottom side



R = 0.02 #support radius. If is bigger, the deformation radius increases, try increasing it
RBFfun = RBFFunctionLocalSupport(RBF_CP4, R)


#Linear vertical displacement
displacement = [[0.0,0.005]]

model1 = MorphRBF(model0, movenodes, fixnodes, displacement, RBFfun;use_affine=false)

ap1 =  vv2AirfoilPoints(model1,ap0)


using Plots
Plots.default(linewidth=2)
# plotly()
plot(ap0.xu, ap0.yu, label="original", linecolor=:black, aspect_ratio = 1)
plot!(ap0.xl, ap0.yl, label=false, linecolor=:black)

plot!(ap1.xu, ap1.yu, label="Morph Deformation",linecolor=:red)
plot!(ap1.xl, ap1.yl, label=false, linecolor=:red)




