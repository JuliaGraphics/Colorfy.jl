# -----------------------------------------------------------------
# Licensed under the MIT License. See LICENSE in the project root.
# -----------------------------------------------------------------

"""
    repr(values, colorscheme, colorrange)

Colorful representation of `values` based on `colorscheme` and `colorrange`.
"""
function repr(values, colorscheme, colorrange)
  if any(isinvalid, values)
    # find invalid and valid indices
    iinds = findall(isinvalid, values)
    vinds = setdiff(1:length(values), iinds)

    # if all values are invalid, return transparent colors
    isempty(vinds) && return fill(colorant"transparent", length(values))

    # construct colors for valid values
    vcolors = repr(nonmissingvec(values[vinds]), colorscheme, colorrange)

    # construct colors for all values
    genvec(vinds, vcolors, iinds, colorant"transparent")
  else
    # use an identity map to get concrete element type
    repr(map(identity, values), colorscheme, colorrange)
  end
end

function repr(values::AbstractVector{<:Number}, colorscheme, colorrange)
  isna(v) = isnan(v) || isinf(v)
  if any(isna, values)
    iinds = findall(isna, values)
    vinds = setdiff(1:length(values), iinds)
    vcolors = get(colorscheme, values[vinds], colorrange)
    genvec(vinds, vcolors, iinds, colorant"transparent")
  else
    get(colorscheme, values, colorrange)
  end
end

repr(values::AbstractVector{<:Colorant}, colorscheme, colorrange) = values

repr(values::AbstractVector{<:Symbol}, colorscheme, colorrange) = repr(map(string, values), colorscheme, colorrange)

repr(values::AbstractVector{<:AbstractString}, colorscheme, colorrange) = map(v -> parse(Colorant, v), values)

repr(values::AbstractVector{<:Date}, colorscheme, colorrange) = repr(nominal(values), colorscheme, colorrange)

repr(values::AbstractVector{<:DateTime}, colorscheme, colorrange) = repr(nominal(values), colorscheme, colorrange)
