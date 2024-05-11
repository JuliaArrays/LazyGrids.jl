# ndgrid-avect.jl test AbstractVector types

using LazyGrids: ndgrid, ndgrid_array, GridAV, GridUR
using Test: @test, @testset, @test_throws, @inferred

@testset "avect" begin
    (x, y, z) = ([:a,:b,:c], range(0,1,4), 5:9)
    (xa, ya, za) = @inferred ndgrid_array(x, y, z)
    (xl, yl, zl) = @inferred ndgrid(x, y, z)

    @test eltype(xl) === eltype(x)
    @test eltype(yl) === eltype(y)
    @test eltype(zl) === eltype(z)
    @test size(xl) === (length(x), length(y), length(z))
    @test xl isa GridAV
    @test yl isa GridSL
    @test zl isa GridUR
    @test xl == xa
    @test yl ≈ ya
    @test zl == za
    @test xl[2,3,4] == xa[2,3,4] == x[2]
    @test yl[2,3,4] ≈ ya[2,3,4] ≈ y[3]
    @test zl[2,3,4] == za[2,3,4] == z[4]
end
