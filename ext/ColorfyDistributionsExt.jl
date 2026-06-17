# -----------------------------------------------------------------
# Licensed under the MIT License. See LICENSE in the project root.
# -----------------------------------------------------------------

module ColorfyDistributionsExt

using Distributions
using Colors

import Colorfy

function Colorfy.repr(values::AbstractVector{<:Normal}, colorscheme, colorrange)
  # extract location and entropy
  ms = map(location, values)
  hs = map(entropy, values)

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
  map(coloralpha, cs, αs)
end

Colorfy.repr(values::AbstractVector{<:Dirac}, colorscheme, colorrange) =
  Colorfy.repr(mode.(values), colorscheme, colorrange)

function Colorfy.repr(values::AbstractVector{<:Bernoulli}, colorscheme, colorrange)
  # extract mode and entropy
  ms = map(mode, values)
  hs = map(entropy, values)

  # derive base colors from mode
  c = get(colorscheme, 0:1, colorrange)
  cs = c[ms .+ 1]

  # derive transparency from entropy
  a, b = 0.0, log(2)
  αs = @. 1.0 - (hs - a) / (b - a)

  # return final colors
  map(coloralpha, cs, αs)
end

function Colorfy.repr(values::AbstractVector{<:Categorical}, colorscheme, colorrange)
  # extract mode and entropy
  ms = map(mode, values)
  hs = map(entropy, values)

  # derive base colors from mode
  n = ncategories(first(values))
  c = get(colorscheme, 1:n, colorrange)
  cs = c[ms]

  # derive transparency from entropy
  a, b = 0.0, log(n)
  αs = if a == b
    fill(1.0, length(hs))
  else
    @. 1.0 - (hs - a) / (b - a)
  end

  # return final colors
  map(coloralpha, cs, αs)
end

Colorfy.nominal(values::AbstractVector{<:ContinuousUnivariateDistribution}) = Colorfy.nominal(map(location, values))

Colorfy.nominal(values::AbstractVector{<:DiscreteUnivariateDistribution}) = Colorfy.nominal(map(mode, values))

end
