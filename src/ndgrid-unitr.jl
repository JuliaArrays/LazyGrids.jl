#=
ndgrid-unitr.jl
ndgrid type a "UnitRange{Int}" input
=#


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
