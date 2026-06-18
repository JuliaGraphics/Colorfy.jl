# -----------------------------------------------------------------
# Licensed under the MIT License. See LICENSE in the project root.
# -----------------------------------------------------------------

function preprocess(values, alphas, colorscheme, colorrange)
  vs = asvalues(values)
  αs = asalphas(alphas, vs)
  cs = ascolorscheme(colorscheme)
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

ascolorscheme(colorscheme::Symbol) = colorschemes[colorscheme]
ascolorscheme(colorscheme::AbstractString) = ascolorscheme(Symbol(colorscheme))
ascolorscheme(colorscheme::AbstractVector) = ColorScheme([parse(Colorant, color) for color in colorscheme])
ascolorscheme(colorscheme::ColorScheme) = colorscheme

ascolorrange(colorrange::Symbol) = colorrange
function ascolorrange(colorrange::NTuple{2,Number})
  crange = promote(colorrange...)
  Tuple(nominal(collect(crange)))
end
