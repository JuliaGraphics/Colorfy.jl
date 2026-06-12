# -----------------------------------------------------------------
# Licensed under the MIT License. See LICENSE in the project root.
# -----------------------------------------------------------------

module Colorfy

using Colors
using ColorSchemes
using FixedPointNumbers
using Dates

export Colorfier, colorfy

# type alias to reduce typing
const Values{T} = AbstractVector{<:T}

"""
    Colorfier(values; [alphas, colorscheme, colorrange])

Maps each value in `values` to a color. Colors can be obtained using the [`Colorfy.colors`](@ref) function.

## Options

* `alphas` - Scalar or a vector of color alphas (default to `1.0`);
* `colorscheme` - Color scheme specification (default to `:viridis`);
* `colorrange` - Tuple with minimum and maximum color values or a symbol that can be passed 
  to the `rangescale` argument of the `ColorSchemes.get` function (default to `:extrema`);
"""
struct Colorfier{V,A,S,R}
  values::V
  alphas::A
  colorscheme::S
  colorrange::R
end

function Colorfier(values; alphas=1.0, colorscheme=:viridis, colorrange=:extrema)
  values′ = asvalues(values)
  alphas′ = asalphas(alphas, values′)
  colorscheme′ = ascolorscheme(colorscheme)
  colorrange′ = ascolorrange(colorrange)
  Colorfier(values′, alphas′, colorscheme′, colorrange′)
end

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
    Colorfy.asvalues(values)

Valid color values for a given `values`.
"""
asvalues(values) = values
asvalues(values::Values{Colorant}) = values
asvalues(values::Values{Colorant{Q0f7}}) = fixcolors(values)
asvalues(values::Values{Colorant{Q0f15}}) = fixcolors(values)
asvalues(values::Values{Colorant{Q0f31}}) = fixcolors(values)
asvalues(values::Values{Colorant{Q0f63}}) = fixcolors(values)

"""
    Colorfy.asalphas(alphas, values)

Valid color alphas for a given `alphas` and `values`.
"""
asalphas(alpha::Number, values) = fill(alpha, length(values))
function asalphas(alphas::AbstractVector, values)
  if length(alphas) ≠ length(values)
    throw(ArgumentError("the number of alphas must be equal to the number of values"))
  end
  alphas
end

"""
    Colorfy.ascolorscheme(colorscheme)

Valid `ColorScheme` object for a given `colorscheme` specification.
"""
ascolorscheme(colorscheme::Symbol) = colorschemes[colorscheme]
ascolorscheme(colorscheme::AbstractString) = ascolorscheme(Symbol(colorscheme))
ascolorscheme(colorscheme::AbstractVector) = ColorScheme([parse(Colorant, color) for color in colorscheme])
ascolorscheme(colorscheme::ColorScheme) = colorscheme

"""
    Colorfy.ascolorrange(colorrange)

Valid color range, accepted by the `ColorSchemes.get` function, for a given `colorrange`.
"""
ascolorrange(colorrange::Symbol) = colorrange
ascolorrange(colorrange::NTuple{2,T}) where {T<:Real} = colorrange
ascolorrange(colorrange::NTuple{2,Real}) = promote(colorrange...)

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

  # construct new colorfier with valid values only
  vvalues = nonmissingvec(vals[vinds])
  valphas = alphas(colorfier)[vinds]
  vcolorscheme = colorscheme(colorfier)
  vcolorrange = colorrange(colorfier)
  vcolorfier = Colorfier(vvalues; alphas=valphas, colorscheme=vcolorscheme, colorrange=vcolorrange)

  if isempty(iinds)
    # all values are valid, so we can directly dispatch methods
    getcolors(vcolorfier)
  else
    # get valid colors and set "transparent" for invalid values
    vcolors = colors(vcolorfier)
    icolor = colorant"transparent"
    genvec(vinds, vcolors, iinds, icolor, length(vals))
  end
end

"""
    Colorfy.getcolors(colorfier, values)

Function intended for developers that returns the mapped colors from the `colorfier`.
"""
function getcolors(colorfier::Colorfier)
  throw(ArgumentError("""
  Values of type `$(eltype(colorfier.values))` are not supported.
  Please make sure your vector of colors has a concrete type.
  """))
end

function getcolors(colorfier::Colorfier{<:Values{Number}})
  colors = get(colorscheme(colorfier), values(colorfier), colorrange(colorfier))
  coloralpha.(colors, alphas(colorfier))
end

getcolors(colorfier::Colorfier{<:Values{AbstractString}}) = parse.(Ref(Colorant), values(colorfier))

getcolors(colorfier::Colorfier{<:Values{Symbol}}) = parse.(Ref(Colorant), string.(values(colorfier)))

getcolors(colorfier::Colorfier{<:Values{Colorant}}) = values(colorfier)

function getcolors(colorfier::Colorfier{<:Values{DateTime}})
  dvalues = datetime2unix.(values(colorfier))
  dalphas = alphas(colorfier)
  dcolorscheme = colorscheme(colorfier)
  dcolorrange = colorrange(colorfier)
  dcolorfier = Colorfier(dvalues; alphas=dalphas, colorscheme=dcolorscheme, colorrange=dcolorrange)
  getcolors(dcolorfier)
end

function getcolors(colorfier::Colorfier{<:Values{Date}})
  dvalues = map(d -> datetime2unix(DateTime(d)), values(colorfier))
  dalphas = alphas(colorfier)
  dcolorscheme = colorscheme(colorfier)
  dcolorrange = colorrange(colorfier)
  dcolorfier = Colorfier(dvalues; alphas=dalphas, colorscheme=dcolorscheme, colorrange=dcolorrange)
  getcolors(dcolorfier)
end

# -----------------
# HELPER FUNCTIONS
# -----------------

fixcolors(colors) = convert.(floattype(eltype(colors)), colors)

nonmissingvec(x::AbstractVector{T}) where {T} = convert(AbstractVector{nonmissingtype(T)}, x)

function genvec(vecinds, vec, valinds, val, len)
  valdict = Dict(i => val for i in valinds)
  merge!(valdict, Dict(zip(vecinds, vec)))
  [valdict[i] for i in 1:len]
end

end
