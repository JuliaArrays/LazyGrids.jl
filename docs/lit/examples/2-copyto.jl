#---------------------------------------------------------
# # [copyto! test](@id 2-copyto)
#---------------------------------------------------------

#=
This page examines `copyto!` speed of the lazy grids in the Julia package
[`LazyGrids`](https://github.com/JuliaArrays/LazyGrids.jl).

This page was generated from a single Julia file:
[2-copyto.jl](@__REPO_ROOT_URL__/2-copyto.jl).
=#

#md # In any such Julia documentation,
#md # you can access the source code
#md # using the "Edit on GitHub" link in the top right.

#md # The corresponding notebook can be viewed in
#md # [nbviewer](https://nbviewer.org/) here:
#md # [`2-copyto.ipynb`](@__NBVIEWER_ROOT_URL__/2-copyto.ipynb),
#md # and opened in [binder](https://mybinder.org/) here:
#md # [`2-copyto.ipynb`](@__BINDER_ROOT_URL__/2-copyto.ipynb).


# ### Setup

# Packages needed here.

using LazyGrids: ndgrid, ndgrid_array
using LazyGrids: btime, @timeo # not exported; just for timing tests here
using BenchmarkTools: @benchmark
using InteractiveUtils: versioninfo


#=
### Overview

There are several sub-types of `AbstractGrids`.
Here we focus on the simplest (using `OneTo`)
and the most general (`AbstractVector`).
=#


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


#=
These results suggest that `copyto!` is somewhat slower
for a lazy grid than for an `Array`.
This drawback could be reduced or possibly even eliminated
by adding a dedicated `copyto!` method
for lazy grids.
Submit an issue or PR if there is a use case
that needs faster `copyto!`.

See
[broadcasting](https://docs.julialang.org/en/v1/manual/interfaces/#man-interfaces-broadcasting).
=#


# ### Reproducibility

# This page was generated with the following version of Julia:

io = IOBuffer(); versioninfo(io); split(String(take!(io)), '\n')


# And with the following package versions

import Pkg; Pkg.status()
