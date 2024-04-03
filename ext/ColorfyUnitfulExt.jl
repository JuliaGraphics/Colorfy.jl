# -----------------------------------------------------------------
# Licensed under the MIT License. See LICENSE in the project root.
# -----------------------------------------------------------------

module ColorfyUnitfulExt

using Colorfy
using Colorfy: Values
using Unitful: Quantity, ustrip

function Colorfy.getcolors(colorfier::Colorfier{<:Values{Quantity}})
  values = ustrip.(Colorfy.values(colorfier))
  alphas = Colorfy.alphas(colorfier)
  colorscheme = Colorfy.colorscheme(colorfier)
  colorrange = Colorfy.colorrange(colorfier)
  ucolorfier = Colorfier(values; alphas, colorscheme, colorrange)
  Colorfy.getcolors(ucolorfier)
end

end
