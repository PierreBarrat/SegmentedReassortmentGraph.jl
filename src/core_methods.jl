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
hascolor(x::Element{K}, color::Color{K}) where K = issubset(color, x.color)
hascolor(x::Element{K}, color::AbstractVector) where K = hascolor(x, Color{K}(color))
hascolor(x::Element{K}, color::Vararg{<:Integer}) where K = hascolor(x, Color{K}(color...))


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
isofcolor(x::Element{K}, color::Color{K}) where K = (x.color == color)
isofcolor(x::Element{K}, color::AbstractVector) where K = isofcolor(x, Color{K}(color))
isofcolor(x::Element{K}, color::Vararg{<:Integer}) where K = isofcolor(x, Color{K}(color...))


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
