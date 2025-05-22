using Revise
using AirfoilTools
using LinearAlgebra
using Plots

using AirfoilTools.RBF


"""
In this example we are going to move one point from the top side of the airfoil.
We are fixing the points on the bottom side of the airfoil.
"""

fname = "DU89.csv" #airfoil coordinates to load

ap0 = get_airfoil_coordinates(joinpath(@__DIR__, "..", fname))

control_px = collect(LinRange(0.01,0.99, 10))

control_points = ControlPoints(control_px,control_px)


R = 0.25 #support radius. If is bigger, the deformation radius increases, try increasing it
RBFfun = RBFFunctionLocalSupport(RBF_CP4, R)

rbfg = RBFGeometry(control_points,RBFfun)
rbfd = RBFDesign(rbfg, ap0)

w0 = get_DesignParameters(rbfd)

w1 = copy(w0)
idx_change = [2,3,4,6,15]
w1[idx_change] = w1[idx_change] .+ 0.05.*rand(length(idx_change))

rbfd2 = RBFDesign(rbfd, w1)

perturb_DesignParameter(rbfd, 1, 0.05)



using Plots
Plots.default(linewidth=2, aspect_ratio = 1)

plot(rbfd.ap.xu,rbfd.ap.yu,linecolor=:black)
plot!(rbfd.ap.xl,rbfd.ap.yl,linecolor=:black)
plot!(rbfd2.ap.xu,rbfd2.ap.yu,linecolor=:red)
plot!(rbfd2.ap.xl,rbfd2.ap.yl,linecolor=:red)