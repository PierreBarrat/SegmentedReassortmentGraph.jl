using SegmentedReassortmentGraphs
using Test

@testset verbose=true "SegmentedReassortmentGraphs.jl" begin
    @testset "Reading" begin
        println("## Reading")
        include("$(dirname(pathof(SRG)))/../test/fundamentals/treenodes.jl")
    end
end
