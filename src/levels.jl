# -----------------------------------------------------------------
# Licensed under the MIT License. See LICENSE in the project root.
# -----------------------------------------------------------------

"""
    nlevels(values)

Number of levels in `values` for color mapping.

This function is used to determine the number of
colors needed for categorical data. By default,
it returns `0` to indicate that the number of
levels is infinite (i.e., continuous data).
"""
nlevels(values) = 0
