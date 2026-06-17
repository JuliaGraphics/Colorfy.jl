# -----------------------------------------------------------------
# Licensed under the MIT License. See LICENSE in the project root.
# -----------------------------------------------------------------

module ColorfyCategoricalArraysExt

using CategoricalArrays: CategoricalValue
using CategoricalArrays: levels, levelcode

import Colorfy

function Colorfy.repr(values::AbstractVector{<:CategoricalValue}, colorscheme, colorrange)
  # not all levels may be present in the input values,
  # so we need to get the number of levels from the type
  n = length(levels(values))
  c = get(colorscheme, 1:n, colorrange)
  c[map(levelcode, values)]
end

Colorfy.nominal(values::AbstractVector{<:CategoricalValue}) = map(levelcode, values)

end
