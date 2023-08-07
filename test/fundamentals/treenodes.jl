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
    c = SRG.TreeNode{K}()
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



@testset "link / unlink - 1" begin
    K = 3
    a = SRG.TreeNode{K}()
    c = SRG.TreeNode{K}()
    clr = SRG.Color{K}(1,2,3)
    SRG.link!(a, c, clr, 1)
    @test SRG.ancestor(c) == (a, clr)
    @test SRG.ancestor(c, 1, 2) == a
    @test SRG.branch_length(c) == 1
    @test SRG.branch_length(c, 1, 2) == 1
    @test SRG.find_ancestor(c, a) == (nothing, c.up_branch)
    @test SRG.haschild(a, c)
    @test SRG.isroot(a)
    @test !SRG.isroot(c)

    a2 = SRG.TreeNode{K}()
    @test_throws ErrorException SRG.link!(a2, c, SRG.Color{K}(1,2,3), 1)
    @test_throws ErrorException SRG.link!(a2, c, SRG.Color{K}(), 1)
    @test_throws ErrorException SRG.link!(a2, a2, SRG.Color{K}(1,2,3), 1)

    ulnk_clr = SRG.Color{K}(1, 2)
    new_clr = setdiff(clr, ulnk_clr)
    SRG.unlink!(a, c, ulnk_clr)
    @test_throws Exception SRG.unlink!(a, c, SRG.Color{K}(1, 2))
    @test SRG.ancestor(c) == (a, new_clr)
    @test isnothing(SRG.ancestor(c, 1, 2))
    @test_throws ErrorException SRG.ancestor(c, 1, 3)
    @test SRG.ancestor(c, 3) == a
    @test SRG.isroot(c)
    @test SRG.isroot(c, 1, 2)
    @test !SRG.isroot(c, 3)
    @test SRG.haschild(a, c)
end

@testset "link / unlink - 2" begin
    K = 5
    a = SRG.TreeNode{K}()
    c = SRG.TreeNode{K}(; color=SRG.Color{K}(1,2,3,4))
    @test_throws SRG.ColorError SRG.link!(a, c, SRG.Color{K}(1,2,3,4,5), 1)
    clr = SRG.Color{K}(1,2)
    SRG.link!(a, c, clr, 1)

    @test SRG.ancestor(c) == (a, clr)
    @test SRG.ancestor(c, 1, 2) == a
    @test SRG.ancestor(c, 1) == a
    @test_throws ErrorException SRG.ancestor(c, 1, 2, 3)
    @test SRG.isroot(c)
    @test SRG.isroot(c, 3)
    @test !SRG.isroot(c, 1, 2)

    @test SRG.branch_length(c) == 1
    @test SRG.branch_length(c, 1) == 1
    @test SRG.find_ancestor(c, a) == (nothing, c.up_branch)
    @test SRG.haschild(a, c)

    a2 = SRG.TreeNode{K}(; color = SRG.Color{K}(3))
    @test_throws SRG.ColorError SRG.link!(a2, c, SRG.Color{K}(4), missing) # a2 has wrong colors
    @test_throws ErrorException SRG.link!(a2, c, SRG.Color{K}(3), missing) # c already has an ancestor

    SRG.unlink!(a, c)
    @test SRG.isroot(c, 1, 2)
    @test !SRG.haschild(a, c)
    @test !SRG.hasancestor(c, a)
    @test_throws SRG.ColorError SRG.link!(a2, c, SRG.Color{K}(1, 2), missing)
    SRG.link!(a2, c, SRG.Color{K}(3), missing)
end

