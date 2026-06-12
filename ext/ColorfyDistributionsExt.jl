# -----------------------------------------------------------------
# Licensed under the MIT License. See LICENSE in the project root.
# -----------------------------------------------------------------

module ColorfyDistributionsExt

using Colorfy
using Colorfy: Values
using Distributions: Distribution, location, scale

function Colorfy.getcolors(colorfier::Colorfier{<:Values{Distribution}})
  # extract location and scale parameters
  v = Colorfy.values(colorfier)
  m = location.(v)
  s = scale.(v)
  a, b = extrema(s)

  # build new colorfier with location as values and alphas based on scale
  values = m
  alphas = if a == b
    fill(1, length(v))
  else
    @. 1 - (s - a) / (b - a)
  end
  colorscheme = Colorfy.colorscheme(colorfier)
  colorrange = Colorfy.colorrange(colorfier)
  colorfier′ = Colorfier(values; alphas, colorscheme, colorrange)
  Colorfy.getcolors(colorfier′)
end

end
