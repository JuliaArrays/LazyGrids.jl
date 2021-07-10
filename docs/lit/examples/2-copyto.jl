#---------------------------------------------------------
# # [copyto! test](@id 2-copyto)
#---------------------------------------------------------

# This page examines `copyto!` speed of the lazy grids in the Julia package
# [`LazyGrids`](https://github.com/JuliaArrays/LazyGrids.jl).

# ### Setup

# Packages needed here.

using LazyGrids: ndgrid, ndgrid_array
using LazyGrids: btime, @timeo # not exported; just for timing tests here
using BenchmarkTools: @benchmark


# ### Overview

# There are 4 sub-types of `AbstractGrids`.
# Here we focus on the simplest (using `OneTo`)
# and most general (`AbstractVector`).


# #### `OneTo`

dims = (2^7,2^8,2^9)

(xl, _, _) = ndgrid(dims...) # lazy version
xa = Array(xl) # regular dense Array
out = zeros(Int, dims)
sizeof.((xl, xa))


#
ta = @benchmark copyto!(out, xa) # 12.6ms
btime(ta)

#
tl = @benchmark copyto!(out, xl) # 27.3ms
btime(tl)


# #### `AbstractVector`

x,y,z = map(rand, dims)

(xl, _, _) = ndgrid(dims...)
xa = Array(xl)
out = zeros(eltype(x), dims)
sizeof.((xl, xa))


#
ta = @benchmark copyto!(out, xa) # 15.7ms
btime(ta)

#
tl = @benchmark copyto!(out, xl) # 21.7ms
btime(tl)


# These results suggest that `copyto!` is somewhat slower
# for a lazy grid than for an `Array`.
# This drawback could be reduced or possibly even eliminated
# by adding a dedicated `copyto!` method
# for lazy grids.
# Submit an issue or PR if there is a use case
# that needs faster `copyto!`.
#
# See
# [broadcasting](https://docs.julialang.org/en/v1/manual/interfaces/#man-interfaces-broadcasting).
