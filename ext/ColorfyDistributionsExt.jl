# -----------------------------------------------------------------
# Licensed under the MIT License. See LICENSE in the project root.
# -----------------------------------------------------------------

module ColorfyDistributionsExt

using Distributions: Distribution
using Distributions: location, scale
using Colors: coloralpha

import Colorfy

function Colorfy.repr(values::AbstractVector{<:Distribution}, colorscheme, colorrange)
  # extract location and scale parameters
  μs = location.(values)
  σs = scale.(values)

  # derive base colors from location
  cs = Colorfy.repr(μs, colorscheme, colorrange)

  # derive transparency from scale
  a, b = extrema(σs)
  αs = if a == b
    fill(1.0, length(μs))
  else
    @. 1.0 - (σs - a) / (b - a)
  end

  # return final colors
  coloralpha.(cs, αs)
end

end
