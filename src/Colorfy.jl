# -----------------------------------------------------------------
# Licensed under the MIT License. See LICENSE in the project root.
# -----------------------------------------------------------------

module Colorfy

using Colors
using ColorSchemes
using FixedPointNumbers
using Dates

export colorfy

# utility functions
include("utils.jl")

# application interface
include("repr.jl")
include("nominal.jl")
include("levels.jl")

# preprocessing of inputs
include("preproc.jl")

"""
    colorfy(values; alpha=1.0, colorscheme=:viridis, colorrange=:extrema)

Convert `values` to Colors.jl colors based on given options.

## Options

* `alpha`       - scalar or vector of transparency values between 0.0 and 1.0
* `colorscheme` - color scheme from ColorSchemes.jl (e.g., "viridis", ["black", "white"])
* `colorrange`  - minimum and maximum color values or symbol (see `ColorSchemes.get`)
"""
function colorfy(values; alpha=1.0, colorscheme=:viridis, colorrange=:extrema)
  # preprocess input arguments
  vs, αs, cs, cr = preprocess(values, alpha, colorscheme, colorrange)

  # construct colorful representation
  colors = repr(vs, cs, cr)
  alphas = map(Colors.alpha, colors)

  # adjust transparency if necessary
  coloralpha.(colors, αs .* alphas)
end

end
