# ndgrid-oneto.jl

using LazyGrids: ndgrid, ndgrid_array, GridOT
using Test: @test, @testset, @test_throws, @inferred

@testset "oneto" begin
    (L, M, N) = (5, 6, 7)
    (xa, ya, za) = @inferred ndgrid_array(1:L, 1:M, 1:N)
    (xl, yl, zl) = @inferred ndgrid(L, M, N)

    @test eltype(xl) === Int
    @test size(xl) === (L, M, N)
    @test xl isa GridOT
    @test yl isa GridOT
    @test zl isa GridOT
    @test xl == xa
    @test yl == ya
    @test zl == za
    @test xl[2,3,4] == xa[2,3,4] == 2
    @test yl[2,3,4] == ya[2,3,4] == 3
    @test zl[2,3,4] == za[2,3,4] == 4
end
