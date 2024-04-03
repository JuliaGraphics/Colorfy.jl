# -----------------------------------------------------------------
# Licensed under the MIT License. See LICENSE in the project root.
# -----------------------------------------------------------------

module ColorfyDistributionsExt

using Colorfy
using Colorfy: Values
using Distributions: Distribution, location, scale

function Colorfy.getcolors(colorfier::Colorfier{<:Values{Distribution}})
  values = location.(Colorfy.values(colorfier))
  dcolorfier = Colorfy.update(colorfier; values)
  Colorfy.getcolors(dcolorfier)
end

function Colorfy.defaultalphas(values::Values{Distribution})
  s = scale.(values)
  a, b = extrema(s)
  if a == b
    fill(1, length(values))
  else
    @. 1 - (s - a) / (b - a)
  end
end

end
