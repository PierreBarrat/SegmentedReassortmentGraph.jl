using SegmentedReassortmentGraphs
using Test

@testset verbose=true "SegmentedReassortmentGraphs.jl" begin
    @testset "TreeNode" begin
        println("## TreeNode")
        include("$(dirname(pathof(SRG)))/../test/fundamentals/treenodes.jl")
    end

    @testset "Colors" begin
        println("Colors")
        include("$(dirname(pathof(SRG)))/../test/colors/colors.jl")
    end
end
