# -----------------------------------------------------------------
# Licensed under the MIT License. See LICENSE in the project root.
# -----------------------------------------------------------------

"""
    nominal(values)

Nominal representation of `values` for color mapping.

This function is used to convert non-numeric values to
numeric values that can be used in ticks and color bars.
"""
function nominal(values)
  if any(isinvalid, values)
    # find invalid and valid indices
    iinds = findall(isinvalid, values)
    vinds = setdiff(1:length(values), iinds)

    # if all values are invalid, return missing values
    isempty(vinds) && return fill(missing, length(values))

    # construct nominal values for valid values
    vvalues = nominal(nonmissingvec(values[vinds]))

    # construct nominal values for all values
    genvec(vinds, vvalues, iinds, missing)
  else
    # use an identity map to get concrete element type
    nominal(map(identity, values))
  end
end

function nominal(values::AbstractVector{<:Number})
  isna(v) = isnan(v) || isinf(v)
  if any(isna, values)
    iinds = findall(isna, values)
    vinds = setdiff(1:length(values), iinds)
    genvec(vinds, values[vinds], iinds, missing)
  else
    values
  end
end

nominal(values::AbstractVector{<:Date}) = nominal(map(DateTime, values))

nominal(values::AbstractVector{<:DateTime}) = map(datetime2unix, values)
