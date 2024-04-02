module Colorfy

using Colors
using ColorSchemes

export Colormap, colorfy

# type alias to reduce typing
const Values{T} = AbstractVector{<:T}

"""
    Colormap(values; [alphas, colorscheme, colorrange])

Maps each value in `values` to a color. Colors can be obtained using the `get` function.

## Options

* `alphas` - Scalar or a vector of color alphas (default to `fill(1, length(values))`);
* `colorscheme` - Scheme name or a `ColorSchemes.ColorScheme` object (default to `defaultscheme(values)`);
* `colorrange` - Tuple with minimum and maximum color values or a symbol that can be passed 
  to the `rangescale` argument of the `ColorSchemes.get` function (default to `:extrema`);
"""
struct Colormap{V,A,S,R}
  values::V
  alphas::A
  colorscheme::S
  colorrange::R
end

Colormap(values; alphas=fill(1, length(values)), colorscheme=defaultscheme(values), colorrange=:extrema) =
  Colormap(values, asalphas(alphas, values), ascolorscheme(colorscheme), colorrange)

"""
    colorfy(values; kwargs...)

Shortcut to `Colorfy.get(Colormap(values; kwargs...))` for convenience.

See also [`Colormap`](@ref), [`Colorfy.get`](@ref).
"""
colorfy(values; kwargs...) = get(Colormap(values; kwargs...))

# --------
# GETTERS
# --------

"""
    Colorfy.values(cmap)

Values of the `cmap` colormap.
"""
values(cmap::Colormap) = cmap.values

"""
    Colorfy.alphas(cmap)

Color alphas of the `cmap` colormap.
"""
alphas(cmap::Colormap) = cmap.alphas

"""
    Colorfy.colorscheme(cmap)

Color scheme of the `cmap` colormap.
"""
colorscheme(cmap::Colormap) = cmap.colorscheme

"""
    Colorfy.colorrange(cmap)

Color range of the `cmap` colormap.
"""
colorrange(cmap::Colormap) = cmap.colorrange

# ----
# API
# ----

"""
    Colorfy.defaultscheme(values)

Default color scheme for `values`.
"""
defaultscheme(values) = colorschemes[:viridis]

"""
    get(cmap)

Colors mapped from the `cmap` colormap.
"""
Base.get(cmap::Colormap) = coloralpha.(getcolors(cmap), alphas(cmap))

"""
    Colorfy.getcolors(cmap)

Function intended for developers that returns the mapped colors from the `cmap` colormap without the alphas. 
Alphas are applied in the `get` function.
"""
getcolors(cmap::Colormap{<:Values{Number}}) = get(colorscheme(cmap), values(cmap), colorrange(cmap))

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
