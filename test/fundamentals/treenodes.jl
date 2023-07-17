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

@testset "hasancestor / haschild" begin
    K = 3
    clr = SRG.Color{K}(1, 2)
    p = SRG.TreeNode{K}(; color = clr)
    c = SRG.TreeNode{K}(; color = clr)
    b = SRG.Branch{K}(p, c, clr, missing)

    SRG._add_ancestor!(c, b)
    SRG._add_child!(p, b)

    @test SRG.hasancestor(c, p)
    @test SRG.hasancestor(c, p, 1)
    @test SRG.hasancestor(c, p, 1, 2)
    @test !SRG.hasancestor(p, c)
    @test !SRG.hasancestor(p, c, 1, 2)
    @test_throws Exception SRG.hasancestor(c, p, 1, 3)

    @test SRG.haschild(p, c)
    @test !SRG.haschild(c, p)
end

# Testing hascolor, uncolor! and color!
@testset "Color 1" begin
    K = 8
    x = SRG.TreeNode{K}()
    SRG.check_node(x)
    @test SRG.hascolor(x, collect(1:K))
    for i in 1:K, j in (i+1):K
        clr = let
            c = zeros(Bool, K)
            c[i] = true
            c[j] = true
            c
        end

        # x has all colors
        @test SRG.hascolor(x, SRG.Color{K}(i, j))
        @test SRG.hascolor(x, i, j)
        @test SRG.hascolor(x, [i, j])
        @test SRG.hascolor(x, clr)
        @test !SRG.isofcolor(x, [i, j])

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






