# ndgrid-range.jl

using LazyGrids: ndgrid, ndgrid_array, GridAR, GridSL, GridUR
using Test: @test, @testset, @test_throws, @inferred


@testset "StepRangeLen" begin
    (x, y) = (1:3, (-3:4)/11)
    (xa, ya) = @inferred ndgrid_array(x, y)
    (xl, yl) = @inferred ndgrid(x, y)
    @test yl isa GridSL
    @test xl[:,1] == x
    @test xa[:,1] == x
    @test yl[1,:] == y
    @test ya[1,:] == y
end


@testset "range" begin
    (x, y, z) = (LinRange(0,1,4), 1:1//2:3, 6:9)
    (xa, ya, za) = @inferred ndgrid_array(x, y, z)
    (xl, yl, zl) = @inferred ndgrid(x, y, z)

    @test eltype(xl) === eltype(x)
    @test eltype(yl) === eltype(y)
    @test eltype(zl) === eltype(z)
    @test size(xl) === (length(x), length(y), length(z))
    @test xl isa GridAR
    @test yl isa GridAR
    @test zl isa GridUR
    @test xl ≈ xa
    @test yl == ya
    @test zl == za
    @test xl[2,3,4] ≈ xa[2,3,4] ≈ x[2]
    @test yl[2,3,4] == ya[2,3,4] == y[3]
    @test zl[2,3,4] == za[2,3,4] == z[4]
end
