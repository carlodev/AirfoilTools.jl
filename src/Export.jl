# Automatically re-export what they export
for mod in (AirfoilCore, AirfoilCST, AirfoilRBF)
    for name in names(mod, all = false, imported = false)
        @eval export $name
    end
end

# Bring submodules into scope
using .AirfoilCore
using .AirfoilCST
using .AirfoilRBF
