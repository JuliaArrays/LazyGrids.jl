# ndgrid-repeat.jl
# test lazy and non-lazy version

#using LazyGrids: ndgrid, ndgrid_array
using LazyGrids: btime
include("../src/ndgrid-repeat.jl") # ndgrid_array_r, ndgrid_lazy, ndgrid_repeat

using Test: @test, @testset, @test_throws, @inferred

@testset "ndgrid_array_r" begin

    # easy test with vectors of the same type
    xg, yg, zg = @inferred ndgrid_array_r(1:4, 5:7, 8:9)
    @test xg == repeat(1:4, 1, 3, 2)
    @test yg == repeat((5:7)', 4, 1, 2)

    # harder test with vectors of different types
    x = 1:4
    y = [1//2, 3//4]
    z = [:a, :b, :c]

    @test_throws BoundsError ndgrid_repeat(x, (4,2,3), 0)
    @test_throws DimensionMismatch ndgrid_repeat(x, (4,2,3), 2)

    @inferred ndgrid_repeat(x, (4,2,3), 1)
    @inferred ndgrid_repeat(y, (4,2,3), 2)
    @inferred ndgrid_repeat(z, (4,2,3), 3)
    xg, yg, zg = @inferred ndgrid_array_r(x, y, z)
    @test zg == repeat(reshape(z, (1,1,3)), 4, 2, 1)
end


@testset "ndgrid_lazy" begin
    x = 1:4
    y = [1//2, 3//4]
    z = [:a, :b, :c]
    a = ndgrid_array_r(x, y)
    b = @inferred ndgrid_lazy(x, y)
    @test a == b
    a = ndgrid_array_r(x, y, z)
#   b = @inferred ndgrid_lazy(x, y, z) # @inferred fails here
    b = ndgrid_lazy(x, y, z)
    @test a == b

    # indexing
    (xn, _, _) = ndgrid_array_r(x, y, z)
    (xl, _, _) = ndgrid_lazy(x, y, z)

    @test xn == xl
    @test xn[3] == xl[3]
    @test xn[3] == xl[3]
    @test xn[:] == xl[:]
    @test size(xn) == size(xl)
    @test ndims(xn) == ndims(xl)
    @test xl isa AbstractArray

    @test sizeof(xl) < 100 # small!
end


# copyto! test using LazyArrays version for comparison
using BenchmarkTools: @benchmark

dims = (2^7,2^8,2^9)
x,y,z = map(rand, dims)
(xl, _, _) = ndgrid_lazy(map(Base.OneTo, dims)...)
xa = Array(xl)
out = zeros(eltype(x), dims)
sizeof.((xl, xa))

ta = @benchmark copyto!(out, xa) # 15.9ms
@show btime(ta)

tl = @benchmark copyto!(out, xl) # 179.9ms with lots of memory
@show btime(tl)

#=
@which getindex(xn, 3) # calls Base
@which getindex(xl, 1, 1, 1) # calls specialized getindex
=#

#=
# uncomment this block for timing comparisons (todo: move to literate)

    x = 1:2^8
    y = 1:2^9
    z = 1:2^4
    (xn, _, _) = ndgrid(x, y, z)
    (xl, _, _) = ndgrid_lazy(x, y, z)
    f = x -> sum(a -> a^2, x)
    g = x -> @inbounds sum(a -> a^2, x)
    @assert f(xl) ≈ f(xn) ≈ g(xl)

using BenchmarkTools
@btime f($xn) # 0.9 ms
@btime f($xl) # 4.3 ms (much slower, but less memory...)
@btime g($xn) # 0.9 ms
@btime g($xl) # 4.3 ms (so inbounds did not help)
=#
