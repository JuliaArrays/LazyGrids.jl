# runtests.jl

using LazyGrids: LazyGrids
using Test: @test, @testset, detect_ambiguities

include("aqua.jl")
include("ndgrid-oneto.jl")
include("ndgrid-unitr.jl")
include("ndgrid-range.jl")
include("ndgrid-avect.jl")
include("timer.jl")

@testset "ambiguities" begin
    @test isempty(detect_ambiguities(LazyGrids))
end
