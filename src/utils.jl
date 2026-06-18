# -----------------------------------------------------------------
# Licensed under the MIT License. See LICENSE in the project root.
# -----------------------------------------------------------------

fixcolors(colors) = convert.(floattype(eltype(colors)), colors)

isinvalid(value) = ismissing(value) || (value isa Number && !isfinite(value))

nonmissingvec(values::AbstractVector{T}) where {T} = convert(AbstractVector{nonmissingtype(T)}, values)

function genvec(vecinds, vec, valinds, val)
  T = promote_type(eltype(vec), typeof(val))
  n = length(vecinds) + length(valinds)
  v = Vector{T}(undef, n)
  v[vecinds] .= vec
  v[valinds] .= val
  v
end
