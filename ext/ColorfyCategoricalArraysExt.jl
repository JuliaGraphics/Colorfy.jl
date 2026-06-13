# -----------------------------------------------------------------
# Licensed under the MIT License. See LICENSE in the project root.
# -----------------------------------------------------------------

module ColorfyCategoricalArraysExt

using CategoricalArrays: CategoricalValue
using CategoricalArrays: levels, levelcode

import Colorfy

function Colorfy.repr(values::AbstractVector{<:CategoricalValue}, colorscheme, colorrange)
  n = length(levels(values))
  c = colorscheme[range(n > 1 ? 0 : 1, 1, length=n)]
  c[levelcode.(values)]
end

end
