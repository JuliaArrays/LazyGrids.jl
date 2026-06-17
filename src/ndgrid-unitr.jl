#=
ndgrid-unitr.jl
ndgrid type a "UnitRange{Int}" input
=#


"""
    GridUR{T, d, Da, SZ} <: AbstractGrid{T,d,D}
The `d`th component of `D`-dimensional `ndgrid(a:b, c:d, ...)`
where `1 ≤ d ≤ D`.
"""
struct GridUR{T, d, D, SZ <: NTuple{D,Integer}} <: AbstractGrid{T,d,D}
    dims::SZ
    first0::T # first-1

    function GridUR(dims::SZ, v::AbstractRange{T}, d::Int) where {T, D, SZ <: NTuple{D,Integer}}
        1 ≤ d ≤ D || throw(ArgumentError("$d for $dims"))
        T <: Integer || throw(ArgumentError("only Integer supported"))
        new{T,d,D,SZ}(dims, first(v) - one(T))
    end
end


@inline Base.@propagate_inbounds function Base.getindex(
    a::GridUR{T,d,D},
    i::Vararg{Integer,D},
) where {T <: Integer, d, D}
    @boundscheck checkbounds(a, i...)
#   @boundscheck checkbounds(i, d)
    return a.first0 + @inbounds i[d] # i don't want to deal with one(T) here
end
