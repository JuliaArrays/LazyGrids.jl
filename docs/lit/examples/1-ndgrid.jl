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
y = copy(x)

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


function method0g(xg,yg)
	sum = 0.0
	for i in 1:length(xg)
	#	sum += circle(xg[i],yg[i])
		tmp = (xg[i],yg[i])
		sum += circle(tmp...)
	end
	return sum * Δ^2
end
@assert method0g(xg, yg) ≈ area0
#@btime method0g($xg, $yg) # 5.960 ms (3 allocations: 48 bytes)


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
#sphere(r::NTuple{3}) = abs2(r[1]) + abs2(r[2]) + abs2(r[3]) < 1
sphere(r::NTuple) = sum(abs2, r) < 1


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
vol0 = sphere1(xc,yc,zc,Δc) # roughly (4/3)π
#@time sphere1(xc,yc,zc,Δc) # 2.6sec 3.0GiB


# The sum part of `ndgrid` is surprisingly fast for the coarse grid
# but creating the grid itself is quite slow.
(xgc, ygc, zgc) = ndgrid(xc, yc, zc) # warm-up
#@time (xgc, ygc, zgc) = ndgrid(xc, yc, zc) # 2.6 sec 3.0GiB

sphere3(xx, yy, zz, Δ) = sum(sphere, zip(xx,yy,zz)) * Δ^3
@assert sphere3(xgc, ygc, zgc, Δc) ≈ vol0
#@time sphere3(xgc, ygc, zgc, Δc) # 0.19 sec, 16 byte

# `ndgrid_lazy`
(xlc, ylc, zlc) = ndgrid_lazy(xc, yc, zc)
#@btime (xlc, ylc, zlc) = ndgrid_lazy($xc, $yc, $zc); # 0.03ns 0 bytes (!)

# uses almost no memory:
sizeof( (xlc, ylc, zlc) )

# and is faster than the combined time of `ndgrid` and the volume summation:
@assert sphere3(xlc, ylc, zlc, Δc) ≈ vol0
#@time sphere3(xlc, ylc, zlc, Δc) # 1.4 sec, 16 byte

# Importantly, with a lazy ndgrid now we can return to the fine scale;
# it takes a minute or two, but it is feasible because of the low memory.
z = copy(x)
#@btime ndgrid_lazy($x, $y, $z); # 0.03ns 0 bytes (!)
(xlf, ylf, zlf) = ndgrid_lazy(x, y, z)

@time sphere3(xlf, ylf, zlf, Δ) # 93 sec, 16 bytes
throw(78)


# todo
# With a lazy grid, now we can explore higher-dimensional spheres
# nope, too slow even with coarse grid :(
# π^2/2, sum(sphere, zip(ndgrid_lazy(xc,xc,xc,xc)...)) * Δ^4

#=

[CartesianIndices](https://julialang.org/blog/2016/02/iteration)

# ### Junk

# todo delete this
	(xg, yg) = ndgrid(x, y)
#mapreduce(abs2, +, xg; init=0.0)
method_map1(xg,yg) = mapreduce(circle, +, xg, yg; init=0.0) * Δ^2
@show method_map1(xg,yg)
#@btime method_map1($xg,$yg) # 8.8 ms (5 allocations: 4.00 MiB)

method7_map(xx,yy) = mapreduce(circle, +, xx, yy; init=0.0) * Δ^2
@assert method7_map(xl,yl) ≈ area0
@btime method7_map(xl,yl) # 27.9 ms (5 allocations: 4.00 MiB)

function method0l(xx,yy)
	sum = 0.0
	for i in 1:length(xx)
	 	sum += circle(xx[i],yy[i])
	end
	return sum * Δ^2
end
@assert method0l(xl, yl) ≈ area0
#@btime method0l($xl, $yl) # 48.000 ms (3 allocations: 48 bytes)
throw("0l")

function sphere0l(xx,yy,zz,Δ)
	sum = 0.0
	for i in 1:length(xx)
	 	sum += sphere(xx[i],yy[i],zz[i])
	end
	return sum * Δ^3
end
@time @assert sphere0l(xlc, ylc, zlc, Δc) ≈ vol0 # 3.3 sec, 16 bytes
#@btime sphere0l($xlc, $ylc, $zlc, Δc)

=#
