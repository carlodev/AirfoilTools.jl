# Bring submodules into scope
using .Core
using .AirfoilCST
using .RBF


# Automatically re-export what they export
for mod in (Core, AirfoilCST, RBF)
    for name in names(mod, all = false, imported = false)
        @eval export $name
    end
end