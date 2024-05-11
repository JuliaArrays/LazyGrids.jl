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
struct GridAV{T,d,D} <: AbstractGrid{T,d,D}
    dims::Dims{D}
    v::AbstractVector{T}

    function GridAV(dims::Dims{D}, v::AbstractVector{T}, d::Int) where {D, T}
        1 ≤ d ≤ D || throw(ArgumentError("$d for $dims"))
        new{T,d,D}(dims, v)
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


_grid(d::Int, dims::Dims, v::Base.OneTo{T}) where T = GridOT(T, dims, d)
_grid(d::Int, dims::Dims, v::UnitRange)      = GridUR(dims, v, d)
_grid(d::Int, dims::Dims, v::StepRangeLen)   = GridSL(dims, v, d)
_grid(d::Int, dims::Dims, v::AbstractRange)  = GridAR(dims, v, d)
_grid(d::Int, dims::Dims, v::AbstractVector) = GridAV(dims, v, d)

_grid_type(d::Int, D::Int, ::Base.OneTo{T})     where T = GridOT{T, d, D}
_grid_type(d::Int, D::Int, ::UnitRange{T})      where T = GridUR{T, d, D}
_grid_type(d::Int, D::Int, ::StepRangeLen{T,R,S}) where {T,R,S} = GridSL{T, d, D, R, S}
_grid_type(d::Int, D::Int, v::AbstractRange{T})  where T = GridAR{T, d, D, typeof(step(v))}
_grid_type(d::Int, D::Int, ::AbstractVector{T}) where T = GridAV{T, d, D}


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
3×2 LazyGrids.GridAV{Symbol, 2, 2}:
 :a  :b
 :a  :b
 :a  :b
```
"""
function ndgrid(vs::Vararg{AbstractVector})
    D = length(vs)
    dims = ntuple(d -> length(vs[d]), D)
    T = Tuple{ntuple(d -> _grid_type(d, D, vs[d]), D)...} # return type
    return ntuple(d -> _grid(d, dims, vs[d]), D)::T
end
