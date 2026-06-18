# -----------------------------------------------------------------
# Licensed under the MIT License. See LICENSE in the project root.
# -----------------------------------------------------------------

module ColorfyDistributionsExt

using Distributions
using Colors

import Colorfy

function Colorfy.repr(values::AbstractVector{<:Normal}, colormap, colorrange)
  # derive base colors from location
  cs = Colorfy.repr(Colorfy.nominal(values), colormap, colorrange)

  # compute Shannon entropy
  hs = map(entropy, values)

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

Colorfy.repr(values::AbstractVector{<:Dirac}, colormap, colorrange) =
  Colorfy.repr(map(mode, values), colormap, colorrange)

function Colorfy.repr(values::AbstractVector{<:Bernoulli}, colormap, colorrange)
  # derive base colors from mode
  c = get(colormap, 0:1, colorrange)
  cs = c[Colorfy.nominal(values) .+ 1]

  # compute Shannon entropy
  hs = map(entropy, values)

  # derive transparency from entropy
  a, b = 0.0, log(2)
  αs = @. 1.0 - (hs - a) / (b - a)

  # return final colors
  map(coloralpha, cs, αs)
end

function Colorfy.repr(values::AbstractVector{<:Categorical}, colormap, colorrange)
  # derive base colors from mode
  n = Colorfy.nlevels(values)
  c = get(colormap, 1:n, colorrange)
  cs = c[Colorfy.nominal(values)]

  # compute Shannon entropy
  hs = map(entropy, values)

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

Colorfy.nlevels(values::AbstractVector{<:Dirac}) = 1

Colorfy.nlevels(values::AbstractVector{<:Bernoulli}) = 2

Colorfy.nlevels(values::AbstractVector{<:Categorical}) = ncategories(first(values))

end
