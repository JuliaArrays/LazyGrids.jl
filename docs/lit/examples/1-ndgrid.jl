#---------------------------------------------------------
# # [LazyGrids ndgrid](@id 1-ndgrid)
#---------------------------------------------------------

# This page explains the `ndgrid` method(s) in the Julia package
# [`LazyGrids`](https://github.com/JuliaArrays/LazyGrids.jl).

# ### Setup

# Packages needed here.

using LazyGrids: ndgrid, ndgrid_array
using LazyGrids: btime, @timeo # not exported; just for timing tests here
using BenchmarkTools: @benchmark
using InteractiveUtils: versioninfo


# ### Overview

# We begin with simple illustrations.

# The Julia method `ndgrid_array` in this package
# is comparable to Matlab's `ndgrid` function.
# It is given a long name here
# to discourage its use,
# because the lazy `ndgrid` version is preferable.
# The package provides `ndgrid_array`
# mainly for testing and timing comparisons.

(xa, ya) = ndgrid_array(1.0:3.0, 1:2)

#
xa

#
ya


# This package provides a "lazy" version of `ndgrid` that appears to the user
# to be the same, but under the hood it is not storing huge arrays.

(xl, yl) = ndgrid(1.0:3.0, 1:2)

#
xl

#
yl


# The following example illustrates the memory savings
# (thanks to Julia's powerful `AbstractArray` type):

(xl, yl) = ndgrid(1:100, 1:200)
(xa, ya) = ndgrid_array(1:100, 1:200)
sizeof(xl), sizeof(xa)


# One can do everything with a lazy array that one would expect
# from a "normal" array, e.g., multiplication and summation:

sum(xl * xl'), sum(xa * xa')


# ### Using lazy `ndgrid`

# Many applications with multiple variables
# involve evaluating functions over a *grid* of values.

# As a simple example (for illustration),
# one can numerically approximate the area of the unit circle
# by sampling that circle over a grid of x,y values,
# corresponding to numerical evaluation of the double integral
# ``∫ ∫ 1_{\{x^2 + y^2 < 1\}} \, dx \, dy``.
# There are many ways to implement this approximation in Julia,
# given a vector of `x` and `y` samples.

Δ = 1/2^10
x = range(-1, stop=1, step=Δ)
y = copy(x)

@inline circle(x::Real, y::Real) = abs2(x) + abs2(y) < 1
@inline circle(xy::NTuple{2}) = circle(xy...)

# The documentation below has many timing comparisons.
# The times in the Julia comments are on a 2017 iMac with Julia 1.6.1;
# the times printed out are whatever server GitHub actions uses.
# Using a trick to [capture output](https://fredrikekre.github.io/Literate.jl/v2/generated/example/#Output-Capturing),
# let's find out:

io = IOBuffer()
versioninfo(io)
String(take!(io))


# A basic double loop is the C/Fortran way.
# It uses minimal memory (only 48 bytes) but is somewhat slow.

function method0(x,y) # basic double loop
    sum = 0.0
    for x in x, y in y
        sum += circle(x,y)
    end
    return sum * Δ^2
end

area0 = method0(x,y)
t = @benchmark method0($x,$y) # 10.5 ms (3 allocations: 48 bytes)
btime(t)


# The loop version does not look much like the math.
# It often seems natural to think of a grid of x,y values
# and simply sum over that grid, accounting for the grid spacing,
# using a function like this:

area(xx,yy) = sum(circle.(xx,yy)) * Δ^2


# Users coming from Matlab who are unfamiliar with its newer broadcast
# capabilities might use an `ndgrid` of arrays, like in the following code,
# to compute the area.
# But this array approach is much slower and uses much more memory,
# so it does not scale well to higher dimensions.

function area_array(x, y)
    (xa, ya) = ndgrid_array(x, y)
    return area(xa, ya)
end
@assert area_array(x, y) ≈ area0
t = @benchmark area_array($x, $y) # 21.4 ms (11 allocations: 64.57 MiB)
btime(t)


# To be fair, one might have multiple uses of the grids `xa,ya`
# so perhaps they should be excluded from the timing.
# Separating that allocation makes the timing look faster,
# but it still uses a lot of memory,
# both for allocating the grids, and for the `circle.` broadcast
# in the `area` function above:

(xa, ya) = ndgrid_array(x, y)
@assert area(xa, ya) ≈ area0
t = @benchmark area($xa, $ya) # 5.2 ms (7 allocations: 516.92 KiB)
btime(t)


# The main point of this package is to provide
# a lazy version of `ndgrid` that uses minimal memory.

(xl, yl) = ndgrid(x, y)
@assert xl == xa
@assert yl == ya
sizeof(xa), sizeof(xl)


# Now there is essentially no memory overhead for the grids,
# but memory is still used for the `circle.` broadcast.

@assert area(xl,yl) ≈ area0
t = @benchmark area($xl,$yl) # 3.7 ms (7 allocations: 516.92 KiB)
btime(t)


# Furthermore, creating this lazy ndgrid is so efficient
# that we can include its construction time
# and still have performance comparable to the array version
# that had pre-allocated arrays.

function area_lazy(x, y)
    (xl, yl) = ndgrid(x, y)
    return area(xl, yl)
end
@assert area_lazy(x, y) ≈ area0
t = @benchmark area_lazy($x, $y) # 3.7 ms (7 allocations: 516.92 KiB)
btime(t)


# ### More details

# The comparisons below here might be more
# for the curiosity of the package developers
# than for most users...

# One can preallocate memory to store the `circle.` array,
# to avoid additional memory during the area calculation:

out = Array{Float64}(undef, length(x), length(y))
function area!(xx, yy)
    global out .= circle.(xx,yy)
    return sum(out) * Δ^2
end
@assert area!(xl,yl) ≈ area0
t = @benchmark area!(xl,yl) # 4.8 ms (4 allocations: 128 bytes)
btime(t)


# Interestingly, the lazy version is *faster* than the array version,
# presumably because of the overheard of moving data from RAM to CPU:

@assert area!(xa,ya) ≈ area0
t = @benchmark area!(xa,ya) # 6.2 ms (4 allocations: 80 bytes)
btime(t)


# One can avoid allocating the output array by using a loop
# with [CartesianIndices](https://julialang.org/blog/2016/02/iteration):

function area_ci(xx, yy)
    size(xx) == size(yy) || throw("size")
    sum = 0.0
    @inbounds for c in CartesianIndices(xx)
        sum += circle(xx[c], yy[c])
    end
    return sum * Δ^2
end


# With this approach the lazy version is a bit faster
# than the array version:

@assert area_ci(xl,yl) ≈ area0
t = @benchmark area_ci(xl,yl) # 5.2 ms (3 allocations: 48 bytes)
btime(t)

#
@assert area_ci(xa,ya) ≈ area0
t = @benchmark area_ci(xa,ya) # 5.9 ms (3 allocations: 48 bytes)
btime(t)


# Alternatively one can use a linear index for loop,
# that also avoids the extra memory of `circle.` above,
# but is slower, especially for the lazy arrays
# that are optimized for Cartesian indexing:

function area_for2(xx,yy)
    size(xx) == size(yy) || throw("size")
    sum = 0.0
    @inbounds for i in 1:length(xx)
        sum += circle(xx[i], yy[i])
    end
    return sum * Δ^2
end
@assert area_for2(xa, ya) ≈ area0
t = @benchmark area_for2($xa, $ya) # 5.9 ms (3 allocations: 48 bytes)
btime(t)

#
@assert area_for2(xl, yl) ≈ area0
t = @benchmark area_for2($xl, $yl) # 15.4 ms (3 allocations: 48 bytes)
btime(t)


# Some Julia users would
# [recommend using broadcast](https://discourse.julialang.org/t/meshgrid-function-in-julia/48679/25).
# In this case, broadcast is reasonably fast, but still uses a lot of memory
# for the `circle.` output in the simplest implementation.

areab(x,y) = sum(circle.(x,y')) * Δ^2
@assert areab(x,y) ≈ area0
t = @benchmark areab($x,$y) # 11.6 ms (7 allocations: 516.92 KiB)
btime(t)


# Using `zip` can avoid the "extra" memory beyond the grids,
# but seems to have some undesirable overhead,
# presumably because `zip` uses linear indexing:

areaz(xa, ya) = sum(circle, zip(xa,ya)) * Δ^2
@assert areaz(xa, ya) ≈ area0
t = @benchmark areaz($xa, $ya) # 3.9 ms (3 allocations: 48 bytes)
btime(t)

#
@assert areaz(xl, yl) ≈ area0
t = @benchmark areaz($xl, $yl) # 12.2 ms (3 allocations: 48 bytes)
btime(t)


# One can also ensure low memory by using a product iterator,
# but the code starts to look pretty different from the math at this point
# and it is not much faster than broadcast here.

areap(x,y) = sum(circle, Iterators.product(x, y)) * Δ^2
@assert areap(x,y) ≈ area0
t = @benchmark areap($x, $y) # 9.9 ms (3 allocations: 48 bytes)
btime(t)


# ### 3D case

# A 3D example is finding (verifying) the volume of a unit sphere.

sphere(x::Real,y::Real,z::Real) = abs2(x) + abs2(y) + abs2(z) < 1
sphere(r::NTuple) = sum(abs2, r) < 1


# Storing three 3D arrays of size 2049^3 Float64 would take 192GB,
# so already we must greatly reduce the sampling to use either
# `broadcast` or `ndgrid_array`.
# Furthermore, the `broadcast` requires annoying `reshape` steps:

Δc = 1/2^8 # coarse grid
xc = range(-1, stop=1, step=Δc)
yc = xc
zc = xc
nc = length(zc)
3 * nc^3 * 8 / 1024^3 # GB prediction

# Here is broadcast in 3D (yuch!):

vol_br(x,y,z,Δ) = sum(sphere.(
        repeat(x, 1, length(y), length(z)),
        repeat(reshape(y, (1, :, 1)), length(x), 1, length(z)),
        repeat(reshape(z, (1, 1, :)), length(x), length(y), 1),
    )) * Δ^3
vol_br([0.],[0.],[0.],Δc) # warm-up
@timeo vol0 = vol_br(xc,yc,zc,Δc) # 2.7 sec, 3.0 GiB, roughly (4/3)π

function vol_ci(xx, yy, zz, Δ)
    size(xx) == size(yy) == size(zz) || throw("size")
    sum = 0.0
    @inbounds for c in CartesianIndices(xx)
        sum += sphere(xx[c], yy[c], zz[c])
    end
    return sum * Δ^3
end

# Here is the lazy version:
(xlc, ylc, zlc) = ndgrid(xc, yc, zc) # warm-up
@timeo (xlc, ylc, zlc) = ndgrid(xc, yc, zc); # 0.000022 sec (1.8 KiB)

#
vol_ci([0.], [0.], [0.], Δc) # warm-up
@timeo vol_ci(xlc, ylc, zlc, Δc) # 0.2 sec, 1.4 MiB


# Creating the grid of arrays itself is quite slow, even for the coarse grid:
(xac, yac, zac) = ndgrid_array(xc, yc, zc) # warm-up
@timeo (xac, yac, zac) = ndgrid_array(xc, yc, zc) # 1.8 sec 3.0GiB

# Once created, the array version is no faster than the lazy version:
@timeo vol_ci(xac, yac, zac, Δc) # 0.2 seconds (1.1 MiB)

# Using `zip` is more concise (but slower):
vol_zip(xx, yy, zz, Δ) = sum(sphere, zip(xx,yy,zz)) * Δ^3

#
vol_zip([0.], [0.], [0.], Δc) # warm-up
@timeo vol_zip(xlc, ylc, zlc, Δc) # 1.0 sec, 26 MiB


# Using zip for the array version seems to have less overhead
# so that is a potential for future improvement:

@assert vol_zip(xac, yac, zac, Δc) ≈ vol0
@timeo vol_zip(xac, yac, zac, Δc) # 0.19 sec, 16 byte


# Importantly, with the lazy ndgrid now we can return to the fine scale;
# it takes a few seconds, but it is feasible because of the low memory.
z = copy(x)
@timeo (xlf, ylf, zlf) = ndgrid(x, y, z) # 0.000023 sec

#
@timeo vol_ci(xlf, ylf, zlf, Δ) # 12.7 sec, 16 bytes


# I was hoping that with a lazy grid, now we could explore
# higher-dimensional spheres.  But with the current `zip` overhead
# it was too slow, even with coarse grid.
# @timeo (π^2/2, sum(sphere, zip(ndgrid(xc,xc,xc,xc)...)) * Δc^4)

# Probably I need to learn more about stuff like `pairs(IndexCartesian(), A)`
# [e.g., this PR](https://github.com/JuliaLang/julia/pull/38150).
# Another day...
