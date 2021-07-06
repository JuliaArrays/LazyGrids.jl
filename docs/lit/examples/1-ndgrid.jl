#---------------------------------------------------------
# # [LazyGrids ndgrid](@id 1-ndgrid)
#---------------------------------------------------------

# This page explains the `ndgrid` methods in the Julia package
# [`LazyGrids`](https://github.com/JuliaArrays/LazyGrids.jl).

# ### Setup

# Packages needed here.

using LazyGrids

# ### Overview

# Numerous applications with multiple variables
# involve evaluating functions over a *grid* of values.

# As a simple example (for illustration),
# one can numerically approximate the area of the unit circle
# by sampling that circle over a grid of x,y values,
# corresponding to numerical evaluation of the integral
# ``∫ ∫ 1_{\{x^2 + y^2 < 1\}} \, dx \, dy``

Δ = 1/2^10
x = range(-1, stop=1, step=Δ)
y = x
circle(x,y) = x^2 + y^2 < 1
sum(circle.(x,y')) * Δ^2

# The expression above uses Julia's broadcast ability.

sum(xy -> circle(xy...), Iterators.product(x, y)) * Δ^2
@btime sum(xy -> circle(xy...), Iterators.product(x, y))

circle(xy::NTuple{2}) = abs2(xy[1]) + abs2(xy[2]) < 1

sum(circle, Iterators.product(x, y)) * Δ^2
@btime sum(circle, Iterators.product(x, y))

# Users inexperienced with broadcast might write the following code
# that produces the same result:

(xg, yg) = ndgrid(x, y)
sum(circle.(xg,yg)) * Δ^2

# However, this `ndgrid` approach uses more memory and is less efficient.


using BenchmarkTools
@btime sum(circle.(x,y'))
@btime sum(circle.(xg,yg))


(xl, yl) = ndgrid_lazy(x, y)
sum(circle.(xl,yl)) * Δ^2
@btime sum(circle.(xl,yl))

sum(circle, zip(xg,yg)) * Δ^2
@btime sum(circle, zip(xg,yg))

#
sizeof(xg), sizeof(xl)

# ### Methods
