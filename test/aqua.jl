using LazyGrids: LazyGrids
import Aqua
using Test: @testset

@testset "aqua" begin
    Aqua.test_all(LazyGrids)
end
