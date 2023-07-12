####################################################################
################################ Colors ############################
####################################################################

"""
    hascolor(x::Node, c)
    hascolor(x::Branch, c)

Determine whether `x` has all colors in `c`.

## Example
```jldoctest
julia> x = TreeNode([true, false, true]);

julia> hascolor(x, 1, 3) # x has colors 1 and 3
true

julia> hascolor(x, 2) # but not 2
false

julia> hascolor(x, [1, 3])
true

julia> hascolor(x, [true, false, false]) # x has color 1
true

julia> hascolor(x, [true, true, true]) # but not 1, 2 and 3
false
```
"""
function hascolor(x::Element{K}, colors::Vararg{<:Integer}) where K
    for c in colors
        !(0 < c <= K) && throw(DimensionMismatch("Cannot access degree $K element $x at color $c"))
        if !x.color[c]
            return false
        end
    end
    return true
end
hascolor(x, colors::AbstractVector{<:Integer}) = hascolor(x, colors...)
hascolor(x, colors::AbstractVector{Bool}) = hascolor(x, findall(colors))

"""
    isofcolor(x, colors)

Check whether `x` is exactly of a given color.

```jldoctest
julia> x = TreeNode([true, false, true]);

julia> SRG.isofcolor(x, [true, false, true])
true


julia> SRG.isofcolor(x, [true, false, false])
false

julia> SRG.hascolor(x, [true, false, false])
true

julia>SRG.isofcolor(x, [1, 3])
true
"""
isofcolor(x::Element, colors::AbstractVector{Bool}) = (x.color == colors)
function isofcolor(x::Element{K}, colors::AbstractVector{Int}) where K
    return x.color == index_to_onehot(colors, K)
end

"""
    color!(x::Node, color)
    color!(x::Node, colors...)
    color!(x::Branch, color)

Color `x` appropriately. The second argument can be an index, an array or a vararg.
See `?SRG.hascolor` for examples (same syntax).
"""
function color!(x::Node{K}, colors::Vararg{<:Integer}) where K
    for c in colors
        !(0 < c <= K) && throw(DimensionMismatch("Cannot color degree $K `Node` with $c"))
        @debug x.color[c] && @warn "Node $x already had color $c"
        x.color[c] = true
    end
end
function color!(x::Branch{K}, colors::Vararg{<:Integer}) where K
    for c in colors
        !(0 < c <= K) && throw(DimensionMismatch("Cannot color degree $K `Branch` with $c"))
        @debug x.color[c] && @warn "Branch $x already had color $c"
        x.color[c] = true
    end
end
color!(x, colors::AbstractVector{<:Integer}) = color!(x, colors...)
color!(x, colors::AbstractVector{Bool}) = color!(x, findall(colors))

"""
    uncolor!(x::Node, AbstractVector{Bool})
    uncolor!(x::Node, colors::Vararg{Int})
    uncolor!(x::Branch, colors)

Uncolor `x` appropriately. The second argument can be:
- a `Vector{Bool}` or equivalent, representing a specific color to undo
- any number of `Int` or a `Vector{Int}`, representing indices of colors to undo

See `?SRG.hascolor` for examples (same syntax).
"""
function uncolor!(x::Node{K}, colors::Vararg{<:Integer}) where K
    for c in colors
        !(0 < c <= K) && throw(DimensionMismatch("Cannot uncolor degree $K `Node` at $c"))
        x.color[c] = false
    end
end
function uncolor!(x::Branch{K}, colors::Vararg{<:Integer}) where K
    for c in colors
        !(0 < c <= K) && throw(DimensionMismatch("Cannot uncolor degree $K `Branch` at $c"))
        x.color[c] = false
    end
end
uncolor!(x, colors::AbstractVector{<:Integer}) = uncolor!(x, colors...)
uncolor!(x, color::AbstractVector{Bool}) = uncolor!(x, findall(color))


"""
    index_to_onehot(colors::AbstractVector{Int}, K::Int)

Converts colors specified by indices to a onehot like format.
The total number of colors is `K`.

## Examples
```jldoctest
julia> K = 4;

julia> SRG.index_to_onehot([1, 3], K)
[true, false, true, false]

julia> SRG.index_to_onehot(Int[], K)
[false, false, false, false]
"""
function index_to_onehot(colors::AbstractVector{Int}, K)
    c = zeros(MVector{K, Bool})
    for i in colors
        c[i] = true
    end
    return c
end
"""
    onehot_to_index(colors::AbstractVector{Bool})

Convert from onehot to indices. Simply does `collect(findall(colors))`.

## Examples
```jldoctest
julia> SRG.onehot_to_index([false, true, false])
[2]

julia>SRG.onehot_to_index(ones(Bool, 5))
[1,2,3,4,5]
```
"""
onehot_to_index(colors::AbstractVector{Bool}) = collect(findall(colors))

function color_union(colors::Vararg{AbstractVector{Bool}})
    color_union = zeros(Bool, length(colors))
    for clr in colors, c in clr
        if c
            color_union[c] = true
        end
    end
    return color_union
end
