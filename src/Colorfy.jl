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
const ValuesWithMissing{T} = AbstractVector{Union{Missing,T}}

"""
    Colorfier(values; [alphas, colorscheme, colorrange])

Maps each value in `values` to a color. Colors can be obtained using the [`Colorfy.colors`](@ref) function.

## Options

* `alphas` - Scalar or a vector of color alphas (default to `Colorfy.defaultalphas(values)`);
* `colorscheme` - Scheme name or a `ColorSchemes.ColorScheme` object (default to `Colorfy.defaultcolorscheme(values)`);
* `colorrange` - Tuple with minimum and maximum color values or a symbol that can be passed 
  to the `rangescale` argument of the `ColorSchemes.get` function (default to `Colorfy.defaultcolorrange(values)`);
"""
struct Colorfier{V,A,S,R}
  values::V
  alphas::A
  colorscheme::S
  colorrange::R
end

Colorfier(
  values;
  alphas=defaultalphas(values),
  colorscheme=defaultcolorscheme(values),
  colorrange=defaultcolorrange(values)
) = Colorfier(values, asalphas(alphas, values), ascolorscheme(colorscheme), colorrange)

"""
    colorfy(values; kwargs...)

Shortcut to `Colorfy.colors(Colorfier(values; kwargs...))` for convenience.

See also [`Colorfier`](@ref), [`Colorfy.colors`](@ref).
"""
colorfy(values; kwargs...) = colors(Colorfier(values; kwargs...))

"""
    Colorfy.update(colorfier; [values, alphas, colorscheme, colorrange])

Constructs a new colorfier with `colorfier` fields and updated fields passed as keyword arguments.
"""
update(
  colorfier::Colorfier;
  values=values(colorfier),
  alphas=alphas(colorfier),
  colorscheme=colorscheme(colorfier),
  colorrange=colorrange(colorfier)
) = Colorfier(values; alphas, colorscheme, colorrange)

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
defaultalphas(values::Values) = fill(1, length(values))

function defaultalphas(values::ValuesWithMissing)
  minds = findall(ismissing, values)
  vinds = setdiff(1:length(values), minds)
  valphas = defaultalphas(nonmissingvec(values[vinds]))
  malpha = zero(eltype(valphas))
  genvec(vinds, valphas, minds, malpha, length(values))
end

defaultalphas(values::Values{Colorant}) = alpha.(values)

"""
    Colorfy.defaultcolorscheme(values)

Default color scheme for `values`.
"""
defaultcolorscheme(_) = colorschemes[:viridis]

"""
    Colorfy.defaultcolorrange(values)

Default color range for `values`.
"""
defaultcolorrange(_) = :extrema

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
    # required to handle Vector{Union{Missing,T}} without missing values
    vvals = nonmissingvec(vals)
    vcolorfier = update(colorfier, values=vvals)
    coloralpha.(getcolors(vcolorfier), alphas(vcolorfier))
  else
    # get valid colors and set "transparent" for invalid values
    vvals = nonmissingvec(vals[vinds])
    valphas = alphas(colorfier)[vinds]
    vcolorfier = update(colorfier, values=vvals, alphas=valphas)
    vcolors = colors(vcolorfier)
    icolor = colorant"transparent"
    genvec(vinds, vcolors, iinds, icolor, length(vals))
  end
end

"""
    Colorfy.getcolors(colorfier, values)

Function intended for developers that returns the mapped colors from the `colorfier` without the alphas. 
Alphas are applied in the `Colorfy.colors` function.
"""
function getcolors(colorfier::Colorfier)
  throw(ArgumentError("""
  Values of type `$(eltype(colorfier.values))` are not supported.
  Please make sure your vector of colors has the right type.
  """))
end

getcolors(colorfier::Colorfier{<:Values{Number}}) =
  get(colorscheme(colorfier), values(colorfier), colorrange(colorfier))

getcolors(colorfier::Colorfier{<:Values{AbstractString}}) = parse.(Ref(Colorant), values(colorfier))

getcolors(colorfier::Colorfier{<:Values{Symbol}}) = parse.(Ref(Colorant), string.(values(colorfier)))

getcolors(colorfier::Colorfier{<:Values{Colorant}}) = values(colorfier)

function getcolors(colorfier::Colorfier{<:Values{DateTime}})
  dvalues = datetime2unix.(values(colorfier))
  dcolorfier = update(colorfier, values=dvalues)
  getcolors(dcolorfier)
end

function getcolors(colorfier::Colorfier{<:Values{Date}})
  dvalues = map(d -> datetime2unix(DateTime(d)), values(colorfier))
  dcolorfier = update(colorfier, values=dvalues)
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

nonmissingvec(x::AbstractVector{T}) where {T} = convert(AbstractVector{nonmissingtype(T)}, x)

function genvec(vecinds, vec, valinds, val, len)
  valdict = Dict(i => val for i in valinds)
  merge!(valdict, Dict(zip(vecinds, vec)))
  [valdict[i] for i in 1:len]
end

end
