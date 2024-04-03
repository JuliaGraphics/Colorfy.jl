# -----------------------------------------------------------------
# Licensed under the MIT License. See LICENSE in the project root.
# -----------------------------------------------------------------

module Colorfy

using Colors
using ColorSchemes
using Dates

export Colorfier, colorfy

# type alias to reduce typing
const Values{T} = AbstractVector{<:T}

"""
    Colorfier(values; [alphas, colorscheme, colorrange])

Maps each value in `values` to a color. Colors can be obtained using the [`Colorfy.colors`](@ref) function.

## Options

* `alphas` - Scalar or a vector of color alphas (default to `Colorfy.defaultalphas(values)`);
* `colorscheme` - Scheme name or a `ColorSchemes.ColorScheme` object (default to `Colorfy.defaultscheme(values)`);
* `colorrange` - Tuple with minimum and maximum color values or a symbol that can be passed 
  to the `rangescale` argument of the `ColorSchemes.get` function (default to `:extrema`);
"""
struct Colorfier{V,A,S,R}
  values::V
  alphas::A
  colorscheme::S
  colorrange::R
end

Colorfier(values; alphas=defaultalphas(values), colorscheme=defaultscheme(values), colorrange=:extrema) =
  Colorfier(values, asalphas(alphas, values), ascolorscheme(colorscheme), colorrange)

"""
    Colorfier(colorfier; [values, alphas, colorscheme, colorrange])

Constructs a new colorfier with the `colorfier` fields,
optionally update the fields by passing them as keyword arguments.
"""
Colorfier(
  colorfier::Colorfier;
  values=values(colorfier),
  alphas=alphas(colorfier),
  colorscheme=colorscheme(colorfier),
  colorrange=colorrange(colorfier)
) = Colorfier(values; alphas, colorscheme, colorrange)

"""
    colorfy(values; kwargs...)

Shortcut to `Colorfy.colors(Colorfier(values; kwargs...))` for convenience.

See also [`Colorfier`](@ref), [`Colorfy.colors`](@ref).
"""
colorfy(values; kwargs...) = colors(Colorfier(values; kwargs...))

# --------
# GETTERS
# --------

"""
    Colorfy.values(colorfier)

Values of the `colorfier`.
"""
values(colorfier::Colorfier) = colorfier.values

"""
    Colorfy.alphas(colorfier)

Color alphas of the `colorfier`.
"""
alphas(colorfier::Colorfier) = colorfier.alphas

"""
    Colorfy.colorscheme(colorfier)

Color scheme of the `colorfier`.
"""
colorscheme(colorfier::Colorfier) = colorfier.colorscheme

"""
    Colorfy.colorrange(colorfier)

Color range of the `colorfier`.
"""
colorrange(colorfier::Colorfier) = colorfier.colorrange

# ----
# API
# ----

"""
    Colorfy.defaultalphas(values)

Default color alphas for `values`.
"""
defaultalphas(values) = fill(1, length(values))

"""
    Colorfy.defaultscheme(values)

Default color scheme for `values`.
"""
defaultscheme(_) = colorschemes[:viridis]

"""
    Colorfy.colors(colorfier)

Colors mapped from the `colorfier` .
"""
function colors(colorfier::Colorfier)
  # find invalid and valid indices
  isinvalid(v) = ismissing(v) || (v isa Number && !isfinite(v))
  vals = values(colorfier)
  iinds = findall(isinvalid, vals)
  vinds = setdiff(1:length(vals), iinds)

  if isempty(iinds)
    coloralpha.(getcolors(colorfier), alphas(colorfier))
  else
    # invalid values are assigned full transparency
    vcolors = Vector{Colorant}(undef, length(vals))
    vcolors[iinds] .= colorant"transparent"

    # set colors of valid values
    vvals = coalesce.(vals[vinds])
    valphas = alphas(colorfier)[vinds]
    vcolorfier = Colorfier(colorfier, values=vvals, alphas=valphas)
    vcolors[vinds] .= colors(vcolorfier)

    vcolors
  end
end

"""
    Colorfy.getcolors(colorfier, values)

Function intended for developers that returns the mapped colors from the `colorfier` without the alphas. 
Alphas are applied in the `Colorfy.colors` function.
"""
getcolors(colorfier::Colorfier{<:Values{Number}}) =
  get(colorscheme(colorfier), values(colorfier), colorrange(colorfier))

getcolors(colorfier::Colorfier{<:Values{AbstractString}}) = parse.(Ref(Colorant), values(colorfier))

getcolors(colorfier::Colorfier{<:Values{Symbol}}) = parse.(Ref(Colorant), string.(values(colorfier)))

getcolors(colorfier::Colorfier{<:Values{Colorant}}) = values(colorfier)

function getcolors(colorfier::Colorfier{<:Values{DateTime}})
  dvalues = datetime2unix.(values(colorfier))
  dcolorfier = Colorfier(colorfier, values=dvalues)
  getcolors(dcolorfier)
end

function getcolors(colorfier::Colorfier{<:Values{Date}})
  dvalues = map(d -> datetime2unix(DateTime(d)), values(colorfier))
  dcolorfier = Colorfier(colorfier, values=dvalues)
  getcolors(dcolorfier)
end

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
