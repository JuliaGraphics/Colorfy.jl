# -----------------------------------------------------------------
# Licensed under the MIT License. See LICENSE in the project root.
# -----------------------------------------------------------------

module Colorfy

using Colors
using ColorSchemes
using FixedPointNumbers
using Dates

export colorfy

"""
    colorfy(values; alpha=1.0, colorscheme=:viridis, colorrange=:extrema)

Convert `values` to Colors.jl colors based on given options.

## Options

* `alpha` - Scalar or vector of transparency values
* `colorscheme` - Color scheme from ColorSchemes.jl
* `colorrange` - Minimum and maximum values or a symbol
"""
function colorfy(values; alpha=1.0, colorscheme=:viridis, colorrange=:extrema)
  # handle input arguments
  vs, αs, s, r = handleargs(values, alpha, colorscheme, colorrange)

  # find invalid and valid indices
  iinds = findall(isinvalid, vs)
  vinds = setdiff(1:length(vs), iinds)

  # construct colors for valid values
  rcolors = repr(nonmissingvec(vs[vinds]), s, r)
  ralphas = map(Colors.alpha, rcolors)
  vcolors = coloralpha.(rcolors, αs[vinds] .* ralphas)
  if isempty(iinds) # all values are valid, return colors directly
    vcolors
  else # set "transparent" color for invalid values
    genvec(vinds, vcolors, iinds, colorant"transparent", length(values))
  end
end

function handleargs(values, alphas, colorscheme, colorrange)
  vs = asvalues(values)
  αs = asalphas(alphas, vs)
  s = ascolorscheme(colorscheme)
  r = ascolorrange(colorrange)
  vs, αs, s, r
end

asvalues(value::Symbol) = [value]
asvalues(value::AbstractString) = [value]
asvalues(values::AbstractVector{<:Colorant{Q0f7}}) = fixcolors(values)
asvalues(values::AbstractVector{<:Colorant{Q0f15}}) = fixcolors(values)
asvalues(values::AbstractVector{<:Colorant{Q0f31}}) = fixcolors(values)
asvalues(values::AbstractVector{<:Colorant{Q0f63}}) = fixcolors(values)
asvalues(values) = values

asalphas(alpha::Number, values) = fill(alpha, length(values))
asalphas(alpha::Number, value::Symbol) = [alpha]
asalphas(alpha::Number, value::AbstractString) = [alpha]
function asalphas(alphas::AbstractVector, values)
  if length(alphas) ≠ length(values)
    throw(ArgumentError("the number of alphas must be equal to the number of values"))
  end
  alphas
end

ascolorscheme(colorscheme::Symbol) = colorschemes[colorscheme]
ascolorscheme(colorscheme::AbstractString) = ascolorscheme(Symbol(colorscheme))
ascolorscheme(colorscheme::AbstractVector) = ColorScheme([parse(Colorant, color) for color in colorscheme])
ascolorscheme(colorscheme::ColorScheme) = colorscheme

ascolorrange(colorrange::Symbol) = colorrange
ascolorrange(colorrange::NTuple{2,T}) where {T<:Real} = colorrange
ascolorrange(colorrange::NTuple{2,Real}) = promote(colorrange...)

# ----------------
# IMPLEMENTATIONS
# ----------------

"""
    repr(values::AbstractVector{T}, colorscheme, colorrange)

Colorful representation of `values` of type `T` based on `colorscheme` and `colorrange`.
"""
function repr end

repr(values::AbstractVector{<:Colorant}, colorscheme, colorrange) = values

repr(values::AbstractVector{<:Number}, colorscheme, colorrange) = get(colorscheme, values, colorrange)

repr(values::AbstractVector{<:Symbol}, colorscheme, colorrange) = repr(string.(values), colorscheme, colorrange)

repr(values::AbstractVector{<:AbstractString}, colorscheme, colorrange) = parse.(Ref(Colorant), values)

repr(values::AbstractVector{<:Date}, colorscheme, colorrange) = repr(DateTime.(values), colorscheme, colorrange)

repr(values::AbstractVector{<:DateTime}, colorscheme, colorrange) = repr(datetime2unix.(values), colorscheme, colorrange)

# -----------------
# HELPER FUNCTIONS
# -----------------

isinvalid(value) = ismissing(value) || (value isa Number && !isfinite(value))

fixcolors(colors) = convert.(floattype(eltype(colors)), colors)

nonmissingvec(values::AbstractVector{T}) where {T} = convert(AbstractVector{nonmissingtype(T)}, values)

function genvec(vecinds, vec, valinds, val, len)
  valdict = Dict(i => val for i in valinds)
  merge!(valdict, Dict(zip(vecinds, vec)))
  [valdict[i] for i in 1:len]
end

end
