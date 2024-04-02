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

function get(cmap::Colormap{<:Values{Number}})
  colors = Base.get(colorscheme(cmap), values(cmap), colorrange(cmap))
  setalpha(cmap, colors)
end

function get(cmap::Colormap{<:Values{AbstractString}})
  colors = parse.(Ref(Colorant), values(cmap))
  setalpha(cmap, colors)
end

function get(cmap::Colormap{<:Values{Symbol}})
  names = string.(values(cmap))
  colors = parse.(Ref(Colorant), names)
  setalpha(cmap, colors)
end

get(cmap::Colormap{<:Values{Colorant}}) = setalpha(cmap, values(cmap))

# -----------------
# HELPER FUNCTIONS
# -----------------

setalpha(cmap::Colormap, colors) = coloralpha.(colors, cmap.alphas)

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
