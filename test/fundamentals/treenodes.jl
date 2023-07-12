using SegmentedReassortmentGraphs
using Test

@testset "Equality" begin
    K = 8
    x = SRG.TreeNode{K}()
    y = SRG.TreeNode{K}()
    d = Dict(x => true) # to test hash
    @test x != y
    @test !haskey(d, y)

    y.id = x.id
    @test x == y
    @test haskey(d, y)
end

# Testing hascolor, uncolor! and color!
@testset "Color 1" begin
    K = 8
    x = SRG.TreeNode{K}()
    SRG.check_node(x)
    @test SRG.hascolor(x, collect(1:K))
    for i in 1:K, j in (i+1):K
        # x has all colors
        @test SRG.hascolor(x, i, j)
        @test !SRG.isofcolor(x, [i, j])

        clr = let
            c = zeros(Bool, K)
            c[i] = true
            c[j] = true
            c
        end
        # uncolor i and j
        SRG.uncolor!(x, clr)
        @test !SRG.hascolor(x, [i, j])
        @test !SRG.isofcolor(x, [i, j])
        @test !SRG.hascolor(x, clr)
        @test SRG.hascolor(x, .!clr)
        @test SRG.isofcolor(x, .!clr)
        @test SRG.isofcolor(x, findall(.!clr))

        SRG.color!(x, i)
        @test SRG.hascolor(x, i) && !SRG.hascolor(x, j)

        clr = let
            c = zeros(Bool, K)
            c[j] = true
            c
        end
        SRG.color!(x, clr)
        @test SRG.hascolor(x, collect(1:K))
    end
end






