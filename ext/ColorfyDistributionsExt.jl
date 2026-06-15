# -----------------------------------------------------------------
# Licensed under the MIT License. See LICENSE in the project root.
# -----------------------------------------------------------------

module ColorfyDistributionsExt

using Distributions
using Colors

import Colorfy

Colorfy.repr(values::AbstractVector{<:Dirac}, colorscheme, colorrange) =
  Colorfy.repr(mode.(values), colorscheme, colorrange)

function Colorfy.repr(values::AbstractVector{<:Normal}, colorscheme, colorrange)
  # extract location and entropy
  ms = location.(values)
  hs = entropy.(values)

  # derive base colors from location
  cs = Colorfy.repr(ms, colorscheme, colorrange)

  # derive transparency from entropy
  a, b = extrema(hs)
  αs = if a == b
    fill(1.0, length(hs))
  else
    @. 1.0 - (hs - a) / (b - a)
  end

  # return final colors
  coloralpha.(cs, αs)
end

function Colorfy.repr(values::AbstractVector{<:Bernoulli}, colorscheme, colorrange)
  # extract mode and entropy
  ms = mode.(values) .+ 1
  hs = entropy.(values)

  # derive base colors from mode
  n = 2
  c = colorscheme[range(0, 1, length=n)]
  cs = c[ms]

  # derive transparency from entropy
  a, b = 0.0, log(n)
  αs = @. 1.0 - (hs - a) / (b - a)

  # return final colors
  coloralpha.(cs, αs)
end

function Colorfy.repr(values::AbstractVector{<:Categorical}, colorscheme, colorrange)
  # sanity check
  ns = ncategories.(values)
  allequal(ns) || throw(ArgumentError("all categorical distributions must have the same number of categories"))

  # extract mode and entropy
  ms = mode.(values)
  hs = entropy.(values)

  # derive base colors from mode
  n = first(ns)
  c = colorscheme[range(n > 1 ? 0 : 1, 1, length=n)]
  cs = c[ms]

  # derive transparency from entropy
  a, b = 0.0, log(n)
  αs = if a == b
    fill(1.0, length(hs))
  else
    @. 1.0 - (hs - a) / (b - a)
  end

  # return final colors
  coloralpha.(cs, αs)
end

end
