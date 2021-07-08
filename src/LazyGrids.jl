"""
    LazyGrids
Module for representing grids in a lazy way.
"""
module LazyGrids

"""
    AbstractGrid{T,d,D} <: AbstractArray{T,D}
Abstract type for representing the `d`th component of
of a `D`-dimensional `ndgrid(x_1, x_2, ...)`
where `1 ≤ d ≤ D` and where `eltype(x_d) = T`.
"""
abstract type AbstractGrid{T,d,D} <: AbstractArray{T,D} end


include("ndgrid-oneto.jl")
include("ndgrid-unitr.jl")
include("ndgrid-range.jl")
include("ndgrid-avect.jl")
include("array.jl")
include("timer.jl")

end # module
