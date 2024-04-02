module Colorfy

using Colors
using ColorSchemes

# type alias to reduce typing
const Values{T} = AbstractVector{<:T}

struct Colormap{V,A,S,R}
  values::V
  alphas::A
  colorscheme::S
  colorrange::R
end

Colormap(values; alphas=fill(1, length(values)), colorscheme=defaultscheme(values), colorrange=:extrema) =
  Colormap(values, asalphas(alphas, values), ascolorscheme(colorscheme), colorrange)

colorfy(values; kwargs...) = get(Colormap(values; kwargs...))

# --------
# GETTERS
# --------

values(cmap::Colormap) = cmap.values
alphas(cmap::Colormap) = cmap.alphas
colorscheme(cmap::Colormap) = cmap.colorscheme
colorrange(cmap::Colormap) = cmap.colorrange

# ----
# API
# ----

defaultscheme(values) = colorschemes[:viridis]

get(cmap::Colormap) = coloralpha.(getcolors(cmap), alphas(cmap))

getcolors(cmap::Colormap{<:Values{Number}}) = Base.get(colorscheme(cmap), values(cmap), colorrange(cmap))

getcolors(cmap::Colormap{<:Values{AbstractString}}) = parse.(Ref(Colorant), values(cmap))

getcolors(cmap::Colormap{<:Values{Symbol}}) = parse.(Ref(Colorant), string.(values(cmap)))

getcolors(cmap::Colormap{<:Values{Colorant}}) = values(cmap)

# -----------------
# HELPER FUNCTIONS
# -----------------

ascolorscheme(name::Symbol) = colorschemes[name]
ascolorscheme(name::AbstractString) = ascolorscheme(Symbol(name))
ascolorscheme(scheme::ColorScheme) = scheme

asalphas(alpha, values) = fill(alpha, length(values))
function asalphas(alphas::AbstractVector, values)
  if length(alphas) ≠ length(values)
    throw(ArgumentError("the number of alphas must be equal to the number of values"))
  end
  alphas
end

end
