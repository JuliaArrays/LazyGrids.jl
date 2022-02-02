# timer.jl

using LazyGrids: btime, @timeo
using BenchmarkTools: @benchmark
using Test: @test, @testset, @test_throws, @inferred

@testset "timer" begin
    t = @benchmark sum(1:7)
    @inferred btime(t)
    @test btime(t) isa String

    @test (@timeo sum(1:7)) isa String
end
