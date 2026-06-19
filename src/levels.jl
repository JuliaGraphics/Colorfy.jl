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
function levels(values)
  if any(isinvalid, values)
    # find invalid and valid indices
    iinds = findall(isinvalid, values)
    vinds = setdiff(1:length(values), iinds)

    # if all values are invalid, return an empty vector
    isempty(vinds) && return Int[]

    # construct levels for valid values
    levels(nonmissingvec(values[vinds]))
  else
    # use an identity map to get concrete element type
    levels(map(identity, values))
  end
end

levels(values::AbstractVector{<:AbstractFloat}) = []

levels(values::AbstractVector{<:Integer}) = sort(unique(values))

levels(values::AbstractVector{<:AbstractChar}) = sort(unique(values))

levels(values::AbstractVector{<:AbstractString}) = sort(unique(values))

levels(values::AbstractVector{<:Date}) = []

levels(values::AbstractVector{<:DateTime}) = []

"""
    nlevels(values)

Number of levels in `values` for color mapping.

See [`levels`](@ref) for more details.
"""
nlevels(values) = length(levels(values))
