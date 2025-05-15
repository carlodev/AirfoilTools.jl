using AirfoilTools
using AirfoilTools
using AirfoilTools.RBF
using LinearAlgebra

"""
In this example we are going to move translate the whole airfoil
"""

fname = "DU89.csv" #airfoil coordinates to load

ap0 = get_airfoil_coordinates(joinpath(@__DIR__, "..", fname))

model0 =  AirfoilPoints2vv(ap0)

movenodes= model0[1:length(ap0.xu)] #coordinates of the tops nodes
fixnodes = model0[length(ap0.xu)+1:end] #fix node at the bottom side



R = 0.05 #support radius. If is bigger, the deformation radius increases, try increasing it
RBFfun = RBFFunctionLocalSupport(RBF_CP4, R)


#Linear vertical displacement
displacement = [[0.0,0.05] for _ in movenodes]

model1 = MorphRBF(model0, movenodes, fixnodes, displacement, RBFfun; use_affine=true)
ap1 =  vv2AirfoilPoints(model1,ap0)



using Plots
Plots.default(linewidth=2)
# plotly()
plot(ap0.xu, ap0.yu, label="original", linecolor=:black, aspect_ratio = 1)
plot!(ap0.xl, ap0.yl, label=false, linecolor=:black)

plot!(ap1.xu, ap1.yu, label="Morph Deformation",linecolor=:red)
plot!(ap1.xl, ap1.yl, label=false, linecolor=:red)




