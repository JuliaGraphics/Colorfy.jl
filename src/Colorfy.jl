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

* `alpha`       - scalar or vector of transparency values between 0.0 and 1.0
* `colorscheme` - color scheme from ColorSchemes.jl (e.g., "viridis", ["black", "white"])
* `colorrange`  - minimum and maximum color values or symbol (see `ColorSchemes.get`)
"""
function colorfy(values; alpha=1.0, colorscheme=:viridis, colorrange=:extrema)
  # handle input arguments
  vs, αs, cs, cr = preprocess(values, alpha, colorscheme, colorrange)

  # find invalid and valid indices
  iinds = findall(isinvalid, vs)
  vinds = setdiff(1:length(vs), iinds)

  # if all values are invalid, return transparent colors
  isempty(vinds) && return fill(colorant"transparent", length(values))

  # construct colors for valid values
  rcolors = repr(nonmissingvec(vs[vinds]), cs, cr)
  ralphas = map(Colors.alpha, rcolors)
  vcolors = coloralpha.(rcolors, αs[vinds] .* ralphas)

  # construct colors for all values
  if isempty(iinds) # all values are valid, return colors directly
    vcolors
  else # set "transparent" color for invalid values
    genvec(vinds, vcolors, iinds, colorant"transparent")
  end
end

function preprocess(values, alphas, colorscheme, colorrange)
  vs = asvalues(values)
  αs = asalphas(alphas, vs)
  cs = ascolorscheme(colorscheme, vs)
  cr = ascolorrange(colorrange)
  vs, αs, cs, cr
end

asvalues(values) = values
asvalues(values::AbstractVector{<:Colorant{Q0f7}}) = fixcolors(values)
asvalues(values::AbstractVector{<:Colorant{Q0f15}}) = fixcolors(values)
asvalues(values::AbstractVector{<:Colorant{Q0f31}}) = fixcolors(values)
asvalues(values::AbstractVector{<:Colorant{Q0f63}}) = fixcolors(values)

asalphas(alpha::Number, values) = fill(alpha, length(values))
function asalphas(alphas::AbstractVector, values)
  if length(alphas) ≠ length(values)
    throw(ArgumentError("the number of alphas must be equal to the number of values"))
  end
  alphas
end

function ascolorscheme(colorscheme, values)
  nl = nlevels(values)
  cs = ascolorscheme(colorscheme)
  iszero(nl) ? cs : discretescheme(cs, nl)
end

ascolorscheme(colorscheme::Symbol) = colorschemes[colorscheme]
ascolorscheme(colorscheme::AbstractString) = ascolorscheme(Symbol(colorscheme))
ascolorscheme(colorscheme::AbstractVector) = ColorScheme([parse(Colorant, color) for color in colorscheme])
ascolorscheme(colorscheme::ColorScheme) = colorscheme

ascolorrange(colorrange::Symbol) = colorrange
function ascolorrange(colorrange::NTuple{2,Number})
  crange = promote(colorrange...)
  Tuple(nominal(collect(crange)))
end

# ----------------
# IMPLEMENTATIONS
# ----------------

"""
    repr(values, colorscheme, colorrange)

Colorful representation of `values` based on `colorscheme` and `colorrange`.
"""
function repr(values::AbstractVector{T}, colorscheme, colorrange) where {T}
  throw(ArgumentError("""
    values of type `$T` do not have a colorful representation.

    Please make sure your vector has a concrete element type
    and that a `Colorfy.repr` method exists for it.
    """))
end

repr(values::AbstractVector{<:Colorant}, colorscheme, colorrange) = values

function repr(values::AbstractVector{<:Number}, colorscheme, colorrange)
  isna(v) = isnan(v) || isinf(v)
  if any(isna, values)
    iinds = findall(isna, values)
    vinds = setdiff(1:length(values), iinds)
    vvals = nonmissingvec(values[vinds])
    vcolor = get(colorscheme, vvals, colorrange)
    icolor = colorant"transparent"
    genvec(vinds, vcolor, iinds, icolor)
  else
    get(colorscheme, values, colorrange)
  end
end

repr(values::AbstractVector{<:Symbol}, colorscheme, colorrange) = repr(map(string, values), colorscheme, colorrange)

repr(values::AbstractVector{<:AbstractString}, colorscheme, colorrange) = map(v -> parse(Colorant, v), values)

repr(values::AbstractVector{<:Date}, colorscheme, colorrange) = repr(map(DateTime, values), colorscheme, colorrange)

repr(values::AbstractVector{<:DateTime}, colorscheme, colorrange) =
  repr(map(datetime2unix, values), colorscheme, colorrange)

"""
    nominal(values)

Nominal representation of `values` for color mapping.

This function is used to convert non-numeric values to
numeric values that can be used in ticks and color bars.
"""
function nominal(values)
  # find invalid and valid indices
  iinds = findall(isinvalid, values)
  vinds = setdiff(1:length(values), iinds)

  # if all values are invalid, return missing values
  isempty(vinds) && return fill(missing, length(values))

  # construct nominal values for valid values
  vvalues = nominal(nonmissingvec(values[vinds]))

  # construct nominal values for all values
  if isempty(iinds) # all values are valid, return nominal values directly
    vvalues
  else # set missing value for invalid values
    genvec(vinds, vvalues, iinds, missing)
  end
end

function nominal(values::AbstractVector{<:Number})
  isna(v) = isnan(v) || isinf(v)
  if any(isna, values)
    iinds = findall(isna, values)
    vinds = setdiff(1:length(values), iinds)
    vvals = nonmissingvec(values[vinds])
    genvec(vinds, vvals, iinds, missing)
  else
    values
  end
end

nominal(values::AbstractVector{<:Date}) = nominal(map(DateTime, values))

nominal(values::AbstractVector{<:DateTime}) = map(datetime2unix, values)

"""
    nlevels(values)

Number of levels in `values` for color mapping.

This function is used to determine the number of
colors needed for categorical data. By default,
it returns `0` to indicate that the number of
levels is infinite (i.e., continuous data).
"""
nlevels(values) = 0

# -----------------
# HELPER FUNCTIONS
# -----------------

fixcolors(colors) = convert.(floattype(eltype(colors)), colors)

discretescheme(colorscheme, n) = colorscheme # TODO

isinvalid(value) = ismissing(value) || (value isa Number && !isfinite(value))

nonmissingvec(values::AbstractVector{T}) where {T} = convert(AbstractVector{nonmissingtype(T)}, values)

function genvec(vecinds, vec, valinds, val)
  T = promote_type(eltype(vec), typeof(val))
  n = length(vecinds) + length(valinds)
  v = Vector{T}(undef, n)
  v[vecinds] .= vec
  v[valinds] .= val
  v
end

end
