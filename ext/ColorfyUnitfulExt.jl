# -----------------------------------------------------------------
# Licensed under the MIT License. See LICENSE in the project root.
# -----------------------------------------------------------------

module ColorfyUnitfulExt

using Unitful: Quantity
using Unitful: ustrip

import Colorfy

Colorfy.repr(values::AbstractVector{<:Quantity}, colorscheme, colorrange) =
  Colorfy.repr(ustrip.(values), colorscheme, colorrange)

Colorfy.ascolorrange(colorrange::NTuple{2,Quantity}) = Colorfy.ascolorrange(ustrip.(colorrange))

end
