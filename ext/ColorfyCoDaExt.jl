# -----------------------------------------------------------------
# Licensed under the MIT License. See LICENSE in the project root.
# -----------------------------------------------------------------

module ColorfyCoDaExt

using CoDa: Composition
using CoDa: components
using CoDa: parts
using Colors: coloralpha

import Colorfy

function Colorfy.repr(values::AbstractVector{<:Composition}, colorscheme, colorrange)
  # derive base color from mode
  n = Colorfy.nlevels(values)
  c = get(colorscheme, 1:n, colorrange)
  cs = c[Colorfy.nominal(values)]

  # compute Shannon entropy
  hs = map(values) do v
    c = components(v)
    p = c ./ sum(c)
    -sum(pᵢ * log(pᵢ) for pᵢ in p if pᵢ > 0)
  end

  # derive transparency from entropy
  a, b = 0.0, log(n)
  αs = @. 1.0 - (hs - a) / (b - a)

  # return final color
  map(coloralpha, cs, αs)
end

Colorfy.nominal(values::AbstractVector{<:Composition}) = map(argmax ∘ components, values)

Colorfy.levels(values::AbstractVector{<:Composition}) = collect(parts(first(values)))

end
