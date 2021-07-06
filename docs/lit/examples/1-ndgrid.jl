#---------------------------------------------------------
# # [LazyGrids ndgrid](@id 1-ndgrid)
#---------------------------------------------------------

# This page explains the `ndgrid` methods in the Julia package
# [`LazyGrids`](https://github.com/JuliaArrays/LazyGrids.jl).

# ### Setup

# Packages needed here.

using LazyGrids
using BenchmarkTools


# ### Overview

# Numerous applications with multiple variables
# involve evaluating functions over a *grid* of values.

# As a simple example (for illustration),
# one can numerically approximate the area of the unit circle
# by sampling that circle over a grid of x,y values,
# corresponding to numerical evaluation of the double integral
# ``∫ ∫ 1_{\{x^2 + y^2 < 1\}} \, dx \, dy``
# There are many ways to implement this in Julia,
# given a vector of `x` and `y` values.

Δ = 1/2^10
x = range(-1, stop=1, step=Δ)
y = x

circle(x::Real,y::Real) = x^2 + y^2 < 1
circle(xy::NTuple{2}) = abs2(xy[1]) + abs2(xy[2]) < 1

# A basic double loop is the C/Fortan way.
# It uses minimal memory (only 48 bytes) but is somewhat slow.

function method0(x,y) # basic double loop
	sum = 0.0
	for x in x, y in y
		sum += circle(x,y)
	end
	return sum * Δ^2
end

area0 = method0(x,y)
#@btime method0($x,$y) # 10.5 ms (3 allocations: 48 bytes)

# Users coming from Matlab who are unfamiliar with its newer broadcast
# capabilities might write the following code using `ndgrid`
# that produces the same result, but is much slower and uses much more memory.

function method_ndgrid(x, y)
	(xg, yg) = ndgrid(x, y)
	sum(circle.(xg,yg)) * Δ^2
end
@assert method_ndgrid(x, y) ≈ area0
#@btime method_ndgrid($x, $y) # 35.9 ms (13 allocations: 64.57 MiB)


# To be fair, one might have multiple uses of the grids `xg,yg`
# so perhaps they should be excluded from the timing.
# This way looks faster, but still uses a lot of memory.

method_ndgrid2(xg, yg) = sum(circle.(xg,yg)) * Δ^2
(xg, yg) = ndgrid(x, y)
@assert method_ndgrid2(xg, yg) ≈ area0
#@btime method_ndgrid2($xg, $yg) # 5.3 ms (7 allocations: 516.92 KiB)


# Using `zip` can avoid the "extra" memory beyond the grids.
# (But the grids themselves use a lot of memory.)

method3(xg, yg) = sum(circle, zip(xg,yg)) * Δ^2
@assert method3(xg, yg) ≈ area0
#@btime method3($xg, $yg) # 5.4 ms (3 allocations: 48 bytes)


# Many Julia users would recommend using broadcast
# https://discourse.julialang.org/t/meshgrid-function-in-julia/48679/25
# In this case it is reasonably fast, but still uses a lot of memory
# in the simplest implementation.

method4(x,y) = sum(circle.(x,y')) * Δ^2
@assert method4(x,y) ≈ area0
#@btime method4($x,$y) # 5.3 ms (7 allocations: 516.92 KiB)


# One can ensure low memory by using a product iterators,
# but the code starts to look much like the math at this point
# and it is slower than broadcast here.

method5(x,y) = sum(xy -> circle(xy...), Iterators.product(x, y)) * Δ^2
@assert method5(x,y) ≈ area0
#@btime method5($x, $y) # 10.1 ms (3 allocations: 48 bytes)


# The splatting above can be avoided using the tuple version of `circle`,
# but that does not seem to help speed things up.

method6(x,y) = sum(circle, Iterators.product(x, y)) * Δ^2
@assert method6(x,y) ≈ area0
#@btime method6($x, $y) # 10.2 ms (3 allocations: 48 bytes)


# ### LazyGrids

# This package provides a lazy version of `ndgrid` that uses minimal memory.

(xl, yl) = ndgrid_lazy(x, y)
#@assert xl == xg
#@assert yl == yg
sizeof(xg), sizeof(xl)

method7(xl,yl) = sum(circle, zip(xl,yl)) * Δ^2
@assert method7(xl,yl) ≈ area0
#@btime method7(xl,yl) # 23.7 ms (3 allocations: 48 bytes)


# That last result is disappointingly slow,
# so let's move on to a 3D example: finding volume of a sphere.

sphere(x::Real,y::Real,z::Real) = x^2 + y^2 + z^2 < 1
sphere(r::NTuple{3}) = abs2(r[1]) + abs2(r[2]) + abs2(r[3]) < 1


# Storing three 3D arrays of size 2049^3 Float64 would take 192GB,
# so already we must greatly reduce the sampling to use either
# `broadcast` or `ndgrid`.
# Furthermore, the `broadcast` requires annoying `reshape` steps:

Δc = 1/2^8 # coarse grid
xc = range(-1, stop=1, step=Δc)
yc = xc
zc = xc
nc = length(zc)
3 * nc^3 * 8 / 1024^3 # GB prediction

# Here is broadcast in 3D:

sphere1(x,y,z,Δ) = sum(sphere.(
		repeat(x, 1, length(y), length(z)),
		repeat(reshape(y, (1, :, 1)), length(x), 1, length(z)),
		repeat(reshape(z, (1, 1, :)), length(x), length(y), 1),
	)) * Δ^3
#@time vol0 = sphere1(xc,yc,zc,Δc) # 3sec 3GiB, roughly (4/3)π


# `ndgrid` is surprisingly fast for the coarse grid
(xgc, ygc, zgc) = ndgrid(xc, yc, zc)
sphere3(xg, yg, zg, Δ) = sum(sphere, zip(xg,yg,zg)) * Δ^3
@time sphere3(xgc, ygc, zgc, Δc) # 0.23 sec, 2.6 MiB

# `ndgrid_lazy` todo
(xlc, ylc, zlc) = ndgrid_lazy(xc, yc, zc)
sizeof( (xlc, ylc, zlc) )
@time sphere3(xlc, ylc, zlc, Δc) # 1.59 sec, 38 MiB todo: why so much?

#=

[CartesianIndices](https://julialang.org/blog/2016/02/iteration)

# ### Methods

=#
