"""
    LazyGrids
Module for representing grids in a lazy way.
"""
module LazyGrids


"""
    AbstractGrid{T,d,D} <: AbstractArray{T,D}
Abstract type for representing the `d`th component of
of a `D`-dimensional `ndgrid(v₁, v₂, ...)`
where `1 ≤ d ≤ D` and where `eltype(v_d) = T`.
"""
abstract type AbstractGrid{T,d,D} <: AbstractArray{T,D} end

Base.size(a::AbstractGrid) = a.dims
Base.eltype(::AbstractGrid{T}) where T = T


include("ndgrid-oneto.jl")
include("ndgrid-unitr.jl")
include("ndgrid-range.jl")
include("ndgrid-step-range-len.jl")
include("ndgrid-avect.jl")
include("array.jl")
include("timer.jl")

end # module
