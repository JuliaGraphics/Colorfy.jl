# -----------------------------------------------------------------
# Licensed under the MIT License. See LICENSE in the project root.
# -----------------------------------------------------------------

module ColorfyCategoricalArraysExt

using Colorfy
using Colorfy: Values
using ColorSchemes: colorschemes
using CategoricalArrays: CategoricalValue, levels, levelcode

function Colorfy.getcolors(colorfier::Colorfier{<:Values{CategoricalValue}})
  values = Colorfy.values(colorfier)
  colorscheme = Colorfy.colorscheme(colorfier)
  nlevels = length(levels(values))
  categcolors = colorscheme[range(0, nlevels > 1 ? 1 : 0, length=nlevels)]
  categcolors[levelcode.(values)]
end

end
