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

@testset "Color 1" begin
    K = 8
    x = SRG.TreeNode{K}()
    @test SRG.hascolor(x, collect(1:K))
    for i in 1:K, j in (i+1):K
        @test SRG.hascolor(x, i, j)

        clr = let
            c = zeros(Bool, K)
            c[i] = true
            c[j] = true
            c
        end
        SRG.uncolor!(x, clr)

        @test !SRG.hascolor(x, [i, j])
        @test !SRG.hascolor(x, clr)
        @test SRG.hascolor(x, .!clr)

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






