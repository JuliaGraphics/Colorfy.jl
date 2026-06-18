# -----------------------------------------------------------------
# Licensed under the MIT License. See LICENSE in the project root.
# -----------------------------------------------------------------

"""
    levels(values)

Levels in `values` for color mapping.

This function is used to determine the number of
colors needed for scientific types with a finite
number of levels (e.g., categorical, compositional).

By default, it returns an empty vector to indicate
that there are no levels (i.e., continuous data).
"""
levels(values) = Int[]

"""
    nlevels(values)

Number of levels in `values` for color mapping.

See [`levels`](@ref) for more details.
"""
nlevels(values) = length(levels(values))
