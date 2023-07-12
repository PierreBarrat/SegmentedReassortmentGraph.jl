using SegmentedReassortmentGraphs
using Test

@testset "onehot_to_index" begin
    K = 8
    colors = zeros(Bool, K)
    @test SRG.onehot_to_index(colors) == []
    colors[1] = true
    @test SRG.onehot_to_index(colors) == [1]
    colors[[3,5,7]] .= true
    @test SRG.onehot_to_index(colors) == [1,3,5,7]
    colors = ones(Bool, K)
    @test SRG.onehot_to_index(colors) == collect(1:K)
end

@testset "index_to_onehot" begin
    K = 8
    colors = Int[]
    @test all(!, SRG.index_to_onehot(colors, K))
    colors = [1,4,5]
    @test SRG.index_to_onehot(colors, K) == [true, false, false, true, true, false, false, false]
    colors = collect(1:K)
    @test all(SRG.index_to_onehot(colors, K))
end

@testset "color_union" begin
    K = 5
    colors = [
        [1, 2],
        [2, 5],
        [1, 2, 5],
    ]
end
