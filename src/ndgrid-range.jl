#=
ndgrid-range
ndgrid for a set of AbstractRange inputs.
=#

export ndgrid


"""
    GridAR{T,d,D} <: AbstractGrid{T,d,D}
The `d`th component of `D`-dimensional `ndgrid(x, y ...)`
where `1 ≤ d ≤ D` and `x, y, ...` are each an `AbstractRange`.
"""
struct GridAR{T,d,D} <: AbstractGrid{T,d,D}
    dims::Dims{D}
    first0::T # first - step
    step::T

    function GridAR(dims::Dims{D}, v::AbstractRange{T}, d::Int) where {D, T}
        1 ≤ d ≤ D || throw(ArgumentError("$d for $dims"))
        new{T,d,D}(dims, first(v) - step(v), step(v))
    end
end

Base.size(a::GridAR) = a.dims
Base.eltype(::GridAR{T}) where T = T

@inline Base.@propagate_inbounds function Base.getindex(
    a::GridAR{T,d,D},
    i::Vararg{Int,D},
) where {T,d,D}
     @boundscheck checkbounds(a, i...)
     return a.first0 + (@inbounds i[d]) * a.step
end


#=
"""
    (xg, yg, ...) = ndgrid(v1, v2,, ...)
Construct `ndgrid` tuple for `AbstractRange` inputs.

# Example

```jldoctest
julia> ndgrid(1:3, 5:2:7)
([1 1; 2 2; 3 3], [5 7; 5 7; 5 7])
```
"""
function ndgrid(vs::Vararg{AbstractRange})
    D = length(vs)
    dims = ntuple(i -> length(vs[i]), D)
    T = Tuple{ntuple(i -> GridAR{eltype(vs[i]), i, D}, D)...} # return type
    return ntuple(i -> GridAR(dims, vs[i], i), D)::T
end
=#
