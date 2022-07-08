#=
ndgrid-oneto.jl
ndgrid for a set of "OneTo" ranges: probably the simplest possible ndgrid
=#

export ndgrid


"""
    GridOT{T,d,D} <: AbstractArray{T,D}
The `d`th component of `D`-dimensional `ndgrid(1:M, 1:N, ...)`
where `1 ≤ d ≤ D`.
"""
struct GridOT{T,d,D} <: AbstractGrid{T,d,D}
    dims::Dims{D}

    function GridOT(T::DataType, dims::Dims{D}, d::Int) where D
        1 ≤ d ≤ D || throw(ArgumentError("$d for $dims"))
        T <: Integer || throw(ArgumentError("T = $T"))
        new{T,d,D}(dims)
    end
end

#Base.size(a::GridOT) = a.dims
#Base.eltype(::GridOT) = Int # default

@inline Base.@propagate_inbounds function Base.getindex(
    a::GridOT{T,d,D},
    i::Vararg{Int,D},
) where {T,d,D}
    @boundscheck checkbounds(a, i...)
    return @inbounds i[d]
end


"""
    (xg, yg, ...) = ndgrid(M, N, ...)
Shorthand for `ndgrid(1:M, 1:N, ...)`.

# Example

```jldoctest
julia> ndgrid(2,3)
([1 1 1; 2 2 2], [1 2 3; 1 2 3])
```
"""
function ndgrid(n1::Int, ns::Vararg{Int})
    ns = (n1, ns...)
    all(>(0), ns) || throw(ArgumentError("$ns ≤ 0"))
    return ndgrid(Base.OneTo.(ns)...)
end
