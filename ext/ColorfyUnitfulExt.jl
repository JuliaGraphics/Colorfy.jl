# -----------------------------------------------------------------
# Licensed under the MIT License. See LICENSE in the project root.
# -----------------------------------------------------------------

module ColorfyUnitfulExt

using Unitful: Quantity
using Unitful: ustrip

import Colorfy

Colorfy.repr(values::AbstractVector{<:Quantity}, colormap, colorrange) =
  Colorfy.repr(Colorfy.nominal(values), colormap, colorrange)

Colorfy.nominal(values::AbstractVector{<:Quantity}) = Colorfy.nominal(map(ustrip, values))

end
