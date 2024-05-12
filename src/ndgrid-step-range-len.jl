#=
ndgrid-step-range-len
ndgrid type for an StepRangeLen input.
=#


"""
    GridSL{T,d,D} <: AbstractGrid{T,d,D}
The `d`th component of `D`-dimensional `ndgrid(v₁, v₂, ...)`
where `1 ≤ d ≤ D` and `v_d` is a `StepRangeLen`.
"""
struct GridSL{T,d,D, R, S} <: AbstractGrid{T,d,D}
    dims::Dims{D}
    ref::R
    step::S
    len::Int
    offset::Int

    function GridSL(dims::Dims{D}, v::StepRangeLen{T,R,S}, d::Int) where {D, T, R, S}
        1 ≤ d ≤ D || throw(ArgumentError("$d for $dims"))
        eltype(v.len) == Int || throw("non-Int v.len unsupported")
        eltype(v.offset) == Int || throw("non-Int v.offset unsupported")
        new{T,d,D,R,S}(dims, v.ref, v.step, v.len, v.offset)
    end
end


# note: Base range.jl uses unsafe_getindex for this
@inline Base.@propagate_inbounds function Base.getindex(
    a::GridSL{T,d,D},
    i::Vararg{Int,D},
) where {T,d,D}
     @boundscheck checkbounds(a, i...)
     u = (@inbounds i[d]) - a.offset
     return T(a.ref + u * a.step)
end
