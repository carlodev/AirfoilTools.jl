using Revise
using AirfoilCST
using Plots, CSV, DataFrames
using Plotly

fname = "DU89.csv" #"n0012.csv"
NW0 = 20 #number of w0 to parametrize top and bottom
N1 = 0.5
N2 = 1.0
x0u, x0l, y0u, y0l = get_airfoil_coordinates(joinpath(@__DIR__, fname))
using LinearAlgebra

function offset_ribbon(x, y, δ)
    n = length(x)
    x = collect(x)
    y = collect(y)

    # Compute tangents using central differences
    dx = similar(x)
    dy = similar(y)

    dx[1]   = x[2] - x[1]
    dy[1]   = y[2] - y[1]
    dx[end] = x[end] - x[end-1]
    dy[end] = y[end] - y[end-1]

    for i in 2:n-1
        dx[i] = x[i+1] - x[i-1]
        dy[i] = y[i+1] - y[i-1]
    end

    # Compute normals (perpendicular to tangents)
    nx = -dy
    ny = dx

    # Normalize normals
    norms = sqrt.(nx.^2 + ny.^2)
    nx ./= norms
    ny ./= norms

    # Offset coordinates by ±δ along normals
    x_plus  = x .+ δ .* nx
    y_plus  = y .+ δ .* ny
    x_minus = x .- δ .* nx
    y_minus = y .- δ .* ny

    return (x_plus, y_plus, x_minus, y_minus)
end
# Concatenate upper and reversed lower coordinates (assuming airfoil is closed)
x_all = vcat(x0u, x0l)
y_all = vcat(y0u, y0l)

# Compute offset ribbon
δ = 0.005
x_plus, y_plus, x_minus, y_minus = offset_ribbon(x_all, y_all, δ)

function plot_airfoil_with_ribbon(x, y, x_plus, y_plus, x_minus, y_minus; δ=0.01)
    # Construct ribbon as a closed polygon (outer + reversed inner)
    xr = vcat(x_plus, reverse(x_minus))
    yr = vcat(y_plus, reverse(y_minus))
    
    # Plot ribbon as filled area
    ribbon_shape = Shape(xr, yr)
    plot(ribbon_shape, c=:lightblue, label="±δ = $δ",linecolor=:transparent, legend=:outertopright)

    # Plot original airfoil on top
    plot!(x, y, color=:black, linewidth=2, label="Airfoil")
    
    # Formatting
    plot!(aspect_ratio=:equal, xlabel="x", ylabel="y", title="Airfoil with ±δ Ribbon")
end

gr()
plot_airfoil_with_ribbon(x_all, y_all, x_plus, y_plus, x_minus, y_minus; δ=δ)
