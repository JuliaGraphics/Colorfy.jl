# -----------------------------------------------------------------
# Licensed under the MIT License. See LICENSE in the project root.
# -----------------------------------------------------------------

module ColorfyDistributionsExt

using Distributions: Distribution
using Distributions: location, scale

import Colorfy

function Colorfy.repr(values::AbstractVector{<:Distribution}, colorscheme, colorrange)
  # extract location and scale parameters
  μs = location.(values)
  σs = scale.(values)
  a, b = extrema(σs)

  # compute alphas based on scale parameters
  αs = if a == b
    fill(1, length(μs))
  else
    @. 1 - (σs - a) / (b - a)
  end

  Colorfy.colorfy(μs; alpha=αs, colorscheme, colorrange)
end

end
