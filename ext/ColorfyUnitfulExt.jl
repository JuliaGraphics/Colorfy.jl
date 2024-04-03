# -----------------------------------------------------------------
# Licensed under the MIT License. See LICENSE in the project root.
# -----------------------------------------------------------------

module ColorfyUnitfulExt

using Colorfy
using Colorfy: Values
using Unitful: Quantity, ustrip

function Colorfy.getcolors(colorfier::Colorfier{<:Values{Quantity}})
  values = ustrip.(Colorfy.values(colorfier))
  ucolorfier = Colorfier(colorfier; values)
  Colorfy.getcolors(ucolorfier)
end

end
