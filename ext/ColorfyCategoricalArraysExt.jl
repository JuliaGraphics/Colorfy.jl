# -----------------------------------------------------------------
# Licensed under the MIT License. See LICENSE in the project root.
# -----------------------------------------------------------------

module ColorfyCategoricalArraysExt

using CategoricalArrays: CategoricalValue
using CategoricalArrays: levels, levelcode

import Colorfy

function Colorfy.repr(values::AbstractVector{<:CategoricalValue}, colorscheme, colorrange)
  nlevels = length(levels(values))
  lcolors = colorscheme[range(0, nlevels > 1 ? 1 : 0, length=nlevels)]
  lcolors[levelcode.(values)]
end

end
