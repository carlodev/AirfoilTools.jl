using Revise
using AirfoilTools
using AirfoilTools.AirfoilCST

using Plots, CSV, DataFrames

fname = "DU89.csv" #"n0012.csv"
NW0 = 15 #number of w0 to parametrize top and bottom
N1 = 0.5
N2 = 1.0

cst0 = CSTGeometry(cstw=CSTweights(NW0,0.1), dz=0.0, N1=N1,N2=N2)

ap0 = get_airfoil_coordinates(joinpath(@__DIR__, "..", fname))
cst1 = CSTGeometry(ap0, cst0)
ap1 = airfoil_from_cst(ap0, cst1)





Plots.default(linewidth=2)
# plotly()
plot(ap0.xu, ap0.yu, label="original", linecolor=:black, aspect_ratio = 1)
plot!(ap0.xl, ap0.yl, label=false, linecolor=:black)

plot!(ap1.xu, ap1.yu, label="CST approximation",linecolor=:red)
plot!(ap1.xl, ap1.yl, label=false, linecolor=:red)

maximum(abs.(ap1.yu - ap0.yu))
maximum(abs.(ap1.yl - ap0.yl))
