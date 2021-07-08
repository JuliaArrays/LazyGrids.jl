# array.jl

export ndgrid_array


"""
    (xg, yg, ...) = ndgrid_array(v1, v2, ...)

Method to construct a tuple of (dense) `Array`s from a set of vectors.

This tuple can use a lot of memory so should be avoided in general!
It is provided mainly for testing and timing comparisons.

Each input should be an `AbstractVector` of some type.
The corresponding output Array will have the same element type.

This method provides similar functionality as Matlab's `ndarray` function
but is more general because the vectors can be any type.

# Examples

```jldoctest
julia> ndgrid_array(1:3, 1:2)
([1 1; 2 2; 3 3], [1 2; 1 2; 1 2])

julia> ndgrid(1:3, [:a,:b])
([1 1; 2 2; 3 3], [:a :b; :a :b; :a :b])
```
"""
ndgrid_array(vs::AbstractVector...) = Array.(ndgrid(vs...))
