using Revise
using AirfoilCST
using Plots, CSV, DataFrames

fname = "DU89.csv" #"n0012.csv"
NW0 = 20 #number of w0 to parametrize top and bottom
N1 = 0.5
N2 = 1.0


w0 = w0=0.1.*[ones(NW0); -ones(NW0)]
x0u, x0l, y0u, y0l = get_airfoil_coordinates(joinpath(@__DIR__, fname))




wu,wl = get_CST_weights(x0u,x0l,y0u,y0l;w0=w0, maxiters=1000,maxtime=20, N1=N1,N2=N2)
dz = y0u[1] - y0l[end]

(xu,xl), (yu,yl) = CST_airfoil(wu,wl, dz,x0u,x0l; N1=N1,N2=N2)




Plots.default(linewidth=2)
plotly()
plot(x0u, y0u, label="original", linecolor=:black, aspect_ratio = 1)
plot!(x0l, y0l, label=false, linecolor=:black)

plot!(xu, yu, label="CST approximation",linecolor=:red)
plot!(xl, yl, label=false, linecolor=:red)

maximum(abs.(yu - y0u))
maximum(abs.(yl - y0l))

plot(abs.(yu - y0u))
plot!(abs.(yl - y0l))