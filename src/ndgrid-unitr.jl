#=
ndgrid-unitr.jl
ndgrid for a set of "UnitRange{Int}" inputs.
=#

export ndgrid


"""
    GridUR{T,d,D} <: AbstractGrid{T,d,D}
The `d`th component of `D`-dimensional `ndgrid(a:b, c:d, ...)`
where `1 ≤ d ≤ D`.
"""
struct GridUR{T,d,D} <: AbstractGrid{T,d,D}
    dims::Dims{D}
    first0::T # first-1

    function GridUR(dims::Dims{D}, v::AbstractRange{T}, d::Int) where {T,D}
        1 ≤ d ≤ D || throw(ArgumentError("$d for $dims"))
        T == Int || throw(ArgumentError("only Int supported"))
        new{T,d,D}(dims, first(v) - one(T))
    end
end

Base.size(a::GridUR) = a.dims
Base.eltype(::GridUR{T}) where T = T

@inline Base.@propagate_inbounds function Base.getindex(
    a::GridUR{T,d,D},
    i::Vararg{Int,D},
) where {T <: Int, d, D}
    @boundscheck checkbounds(a, i...)
#   @boundscheck checkbounds(i, d)
    return a.first0 + @inbounds i[d] # i don't want to deal with one(T) here
end


#=
"""
    (xg, yg, ...) = ndgrid(a:b, c:d, ...)
Construct `ndgrid` tuple for `UnitRange{Int}` inputs.

# Example

```jldoctest
julia> ndgrid(1:2, 3:5)
([1 1 1; 2 2 2], [3 4 5; 3 4 5])
```
"""
function ndgrid(vs::Vararg{UnitRange{Int}})
    D = length(vs)
    dims = ntuple(i -> length(vs[i]), D)
    return ntuple(i -> GridUR(dims, vs[i], i), D)
end
=#
