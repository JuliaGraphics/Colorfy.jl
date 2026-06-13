# -----------------------------------------------------------------
# Licensed under the MIT License. See LICENSE in the project root.
# -----------------------------------------------------------------

module ColorfyCoDaExt

using CoDa: Composition
using CoDa: components
using Colors: coloralpha

import Colorfy

function Colorfy.repr(values::AbstractVector{<:Composition}, colorscheme, colorrange)
  # compute probabilities
  ps = map(values) do v
    cs = components(v)
    cs ./ sum(cs)
  end

  # compute Shannon entropy
  hs = map(ps) do p
    -sum(pᵢ * log(pᵢ) for pᵢ in p if pᵢ > 0)
  end

  # derive base color from mode
  n = length(first(ps))
  c = colorscheme[range(0, n > 1 ? 1 : 0, length=n)]
  cs = c[argmax.(ps)]

  # derive transparency from entropy
  a, b = 0.0, log(n)
  αs = @. 1.0 - (hs - a) / (b - a)

  # return final color
  coloralpha.(cs, αs)
end

end
