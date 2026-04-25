#=
ndgrid-avect.jl
ndgrid for a set of AbstractVector inputs.
=#

export ndgrid


"""
    GridAV{T,d,D} <: AbstractGrid{T,d,D}
The `d`th component of `D`-dimensional `ndgrid(v₁, v₂, ...)`
where `1 ≤ d ≤ D` and `v_d` is an `AbstractVector`.
"""
struct GridAV{T, d, D, V <: AbstractVector{T}, SZ <: NTuple{D,Integer}} <: AbstractGrid{T,d,D}
    dims::SZ
    v::V

    function GridAV(dims::SZ, v::V, d::Int) where {D, T, V <: AbstractVector{T}, SZ <: NTuple{D,Integer}}
        1 ≤ d ≤ D || throw(ArgumentError("$d for $dims"))
        new{T,d,D,V,SZ}(dims, v)
    end
end


@inline Base.@propagate_inbounds function Base.getindex(
    a::GridAV{T,d,D},
    i::Vararg{Int,D},
) where {T, d, D}
    @boundscheck checkbounds(a, i...)
#   @boundscheck checkbounds(i, d)
    @boundscheck checkbounds(a.v, i[d])
    return @inbounds a.v[ @inbounds i[d] ]
end


_grid(d::Int, dims::NTuple{D,Integer}, v::Base.OneTo{T})  where {D,T} = GridOT(T, dims, d)
_grid(d::Int, dims::NTuple{D,Integer}, v::UnitRange)      where D = GridUR(dims, v, d)
_grid(d::Int, dims::NTuple{D,Integer}, v::StepRangeLen)   where D = GridSL(dims, v, d)
_grid(d::Int, dims::NTuple{D,Integer}, v::AbstractRange)  where D = GridAR(dims, v, d)
_grid(d::Int, dims::NTuple{D,Integer}, v::AbstractVector) where D = GridAV(dims, v, d)

_grid_type(d::Int, D::Int, ::Base.OneTo{T}, sz::Type{SZ}) where {T, SZ} = GridOT{T, d, D, SZ}
_grid_type(d::Int, D::Int, ::UnitRange{T}, sz::Type{SZ})  where {T, SZ} = GridUR{T, d, D, SZ}
_grid_type(d::Int, D::Int, ::StepRangeLen{T,R,S}, sz::Type{SZ}) where {T, R, S, SZ} = GridSL{T, d, D, R, S, SZ}
_grid_type(d::Int, D::Int, v::AbstractRange{T}, sz::Type{SZ}) where {T, SZ} = GridAR{T, d, D, typeof(step(v)), SZ}
_grid_type(d::Int, D::Int, ::V, sz::Type{SZ}) where {T, V <: AbstractVector{T}, SZ} = GridAV{T, d, D, V, SZ}


"""
    (xg, yg, ...) = ndgrid(v1, v2, ...)
Construct `ndgrid` tuple for `AbstractVector` inputs.
Each output has a lazy grid type (subtype of `AbstractGrid`)
according to the corresponding input vector type.

# Examples

```jldoctest
julia> xg, yg = ndgrid(1:3, [:a, :b])
([1 1; 2 2; 3 3], [:a :b; :a :b; :a :b])

julia> xg
3×2 LazyGrids.GridUR{Int64, 1, 2}:
 1  1
 2  2
 3  3

julia> yg
3×2 LazyGrids.GridAV{Symbol, 2, 2, Vector{Symbol}}:
 :a  :b
 :a  :b
 :a  :b
```
"""
function ndgrid(vs::Vararg{AbstractVector})
    D = length(vs)
    dims = ntuple(d -> length(vs[d]), D)
    SZ = typeof(dims)
    T = Tuple{ntuple(d -> _grid_type(d, D, vs[d], SZ), D)...} # return type
    return ntuple(d -> _grid(d, dims, vs[d]), D)::T
end
