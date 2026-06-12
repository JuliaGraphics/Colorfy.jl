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
  colorfier′ = Colorfier(values; alphas, colorscheme, colorrange)
  Colorfy.getcolors(colorfier′)
end

Colorfy.ascolorrange(colorrange::NTuple{2,Quantity}) = Colorfy.ascolorrange(ustrip.(colorrange))

end
