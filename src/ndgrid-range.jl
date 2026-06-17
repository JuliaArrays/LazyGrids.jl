#=
ndgrid-range
ndgrid type for an AbstractRange input.
=#


"""
    GridAR{T,d,D,S,SZ} <: AbstractGrid{T,d,D}
The `d`th component of `D`-dimensional `ndgrid(v₁, v₂, ...)`
where `1 ≤ d ≤ D` and `v_d` is an `AbstractRange`.
"""
struct GridAR{T, d, D, S, SZ <: NTuple{D,Integer}} <: AbstractGrid{T,d,D}
    dims::SZ
    first0::T # first - step
    step::S

    function GridAR(dims::SZ, v::AbstractRange{T}, d::Int) where {D, T, SZ <: NTuple{D,Integer}}
        1 ≤ d ≤ D || throw(ArgumentError("$d for $dims"))
        S = typeof(step(v))
        new{T,d,D,S,SZ}(dims, first(v) - step(v), step(v))
    end
end


@inline Base.@propagate_inbounds function Base.getindex(
    a::GridAR{T,d,D,S},
    i::Vararg{Int,D},
) where {T,d,D,S}
     @boundscheck checkbounds(a, i...)
     return a.first0 + (@inbounds i[d]) * a.step
end
