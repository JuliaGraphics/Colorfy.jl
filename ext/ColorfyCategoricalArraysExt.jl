# -----------------------------------------------------------------
# Licensed under the MIT License. See LICENSE in the project root.
# -----------------------------------------------------------------

module ColorfyCategoricalArraysExt

using Colorfy
using Colorfy: Values
using CategoricalArrays: CategoricalValue, levelcode

function Colorfy.getcolors(colorfier::Colorfier{<:Values{CategoricalValue}})
  values = Colorfy.values(colorfier)
  colorscheme = Colorfy.colorscheme(colorfier)
  colorscheme[levelcode.(values)]
end

end
