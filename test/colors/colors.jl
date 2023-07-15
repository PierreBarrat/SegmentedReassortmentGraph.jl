using SegmentedReassortmentGraphs
using Test

@testset "Basic type operations" begin
    K = 5
    C1 = SRG.Color([true, true, true, false, false])
    Cfalse = SRG.Color(zeros(Bool, K))
    @test C1 == SRG.Color([1, 2, 3], K)
    @test Cfalse == SRG.Color{K}(Int[])
    @test C1 == SRG.Color{K}(1, 2, 3)
    @test C1 != SRG.Color{K}(1, 2, 4)
    @test Cfalse == SRG.Color{K}()

    @test C1[1] && C1[2] && C1[3] && !C1[4] && !C1[5]
    C1[4] = true
    @test C1 == !SRG.Color{K}(5)
    @test !Cfalse == SRG.Color{K}(1:5)

    @test !(SRG.Color([true, true]) == SRG.Color([true,]))
    @test !(SRG.Color{1}(1) == SRG.Color{2}(1))
end

@testset "Union" begin
    K = 4
    @test union(SRG.Color{K}(1,2), SRG.Color{K}(3,4)) == SRG.Color{K}(1,2,3,4)
    @test union(SRG.Color{K}(1,2), SRG.Color{K}(1,2,3)) == SRG.Color{K}(1,2,3)
    @test union(SRG.Color{K}(), SRG.Color{K}()) == SRG.Color{K}()
    @test union(SRG.Color{K}(), SRG.Color{K}(1,2,3)) == SRG.Color{K}(1,2,3)

    @test let
        c = SRG.Color{K}(1,2)
        union!(c, SRG.Color{K}(3,4))
        c == SRG.Color{K}(1,2,3,4)
    end
    @test let
        c = SRG.Color{K}(1,2)
        union!(c, SRG.Color{K}(1,2,3))
        c == SRG.Color{K}(1,2,3)
    end
    @test let
        c = SRG.Color{K}()
        union!(c, SRG.Color{K}())
        c == SRG.Color{K}()
    end
    @test let
        c = SRG.Color{K}()
        union!(c, SRG.Color{K}(1,2,3))
        c == SRG.Color{K}(1,2,3)
    end
end

@testset "Intersect" begin
    K = 4
    @test intersect(SRG.Color{K}(1,2), SRG.Color{K}(3,4)) == SRG.Color{K}()
    @test intersect(SRG.Color{K}(1,2), SRG.Color{K}(1,2,3)) == SRG.Color{K}(1,2)
    @test intersect(SRG.Color{K}(), SRG.Color{K}()) == SRG.Color{K}()
    @test intersect(SRG.Color{K}(), SRG.Color{K}(1,2,3)) == SRG.Color{K}()
end

@testset "issubset" begin
    K=5
    @test !issubset(SRG.Color{K}(1,2), SRG.Color{K}(3,4))
    @test issubset(SRG.Color{K}(1,2), SRG.Color{K}(1,2,3))
    @test issubset(SRG.Color{K}(), SRG.Color{K}())
    @test issubset(SRG.Color{K}(), SRG.Color{K}(1,2,3))
    @test !issubset(SRG.Color{K}(1,2), SRG.Color{K}(2,3))
end

@testset "setdiff" begin
    K=5
    @test setdiff(SRG.Color{K}(1,2), SRG.Color{K}(3,4)) == SRG.Color{K}(1,2)
    @test setdiff(SRG.Color{K}(1,2), SRG.Color{K}(1,2,3)) == SRG.Color{K}()
    @test setdiff(SRG.Color{K}(), SRG.Color{K}()) == SRG.Color{K}()
    @test setdiff(SRG.Color{K}(1,2,3), SRG.Color{K}()) == SRG.Color{K}(1,2,3)
    @test setdiff(SRG.Color{K}(1,2), SRG.Color{K}(2,3)) == SRG.Color{K}(1)

    @test let
        c = SRG.Color{K}(1,2)
        setdiff!(c, SRG.Color{K}(3,4))
        c ==  SRG.Color{K}(1,2)
    end
    @test let
        c = SRG.Color{K}(1,2)
        setdiff!(c, SRG.Color{K}(1,2,3))
        c ==  SRG.Color{K}()
    end
    @test let
        c = SRG.Color{K}()
        setdiff!(c, SRG.Color{K}())
        c ==  SRG.Color{K}()
    end
    @test let
        c = SRG.Color{K}(1,2,3)
        setdiff!(c, SRG.Color{K}())
        c ==  SRG.Color{K}(1,2,3)
    end
    @test let
        c = SRG.Color{K}(1,2)
        setdiff!(c, SRG.Color{K}(2,3))
        c ==  SRG.Color{K}(1)
    end
end

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
