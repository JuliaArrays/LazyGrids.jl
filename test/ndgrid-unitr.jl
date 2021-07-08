# ndgrid-unitr.jl

using LazyGrids: ndgrid, ndgrid_array, GridUR
using Test: @test, @testset, @test_throws, @inferred

@testset "unitr" begin
    (L, M, N) = (5, 6, 7)
    (xa, ya, za) = @inferred ndgrid_array(1:L, 1:M, 1:N)
    (xl, yl, zl) = @inferred ndgrid(1:L, 1:M, 1:N)

    @test eltype(xl) === Int
    @test size(xl) === (L, M, N)
    @test xl isa GridUR
    @test yl isa GridUR
    @test zl isa GridUR
    @test xl == xa
    @test yl == ya
    @test zl == za
    @test xl[2,3,4] == xa[2,3,4] == 2
    @test yl[2,3,4] == ya[2,3,4] == 3
    @test zl[2,3,4] == za[2,3,4] == 4

    x, y, z = (-1:2, -3:4, 5:9)
    (xa, ya, za) = @inferred ndgrid_array(x, y, z)
    (xl, yl, zl) = @inferred ndgrid(x, y, z)

    @test size(xl) === (length(x), length(y), length(z))
    @test xl isa GridUR
    @test yl isa GridUR
    @test zl isa GridUR
    @test xl == xa
    @test yl == ya
    @test zl == za
    @test xl[2,3,4] == xa[2,3,4] == x[2]
    @test yl[2,3,4] == ya[2,3,4] == y[3]
    @test zl[2,3,4] == za[2,3,4] == z[4]
end
