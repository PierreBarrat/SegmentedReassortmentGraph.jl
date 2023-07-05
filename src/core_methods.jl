####################################################################
################################ Colors ############################
####################################################################

"""
    hascolor(x::Node, c)

Determine whether `x` has all colors in `c`.
are passed.

## Example
```jldoctest
julia> x = TreeNode([true, false, true]);

julia> hascolor(x, 1, 3) # x has colors 1 and 3
true

julia> hascolor(x, 2) # but not 2
false

julia> hascolor(x, [1, 3]) # same as example
true

julia> hascolor(x, [true, false, false]) # x has color 1
true

julia> hascolor(x, [true, true, true]) # but not 1, 2 and 3
false
```
"""
function hascolor(x::Node{K}, colors::Vararg{<:Integer}) where K
    for c in colors
        !(0 < c <= K) && throw(DimensionMismatch("Cannot access degree $K `Node` at color $c"))
        if !x.color[c]
            return false
        end
    end
    return true
end
hascolor(x::Node, colors::AbstractVector{<:Integer}) = hascolor(x, colors...)
hascolor(x::Node, colors::AbstractVector{Bool}) = hascolor(x, findall(colors))

"""
    color!(x::Node, color)
    color!(x::Node, colors...)

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
color!(x::Node, colors::AbstractVector{<:Integer}) = color!(x, colors...)
color!(x::Node, colors::AbstractVector{Bool}) = color!(x, findall(colors))

"""
    uncolor!(x::Node, AbstractVector{Bool})
    uncolor!(x::Node, colors::Vararg{Int})

Uncolor `x` appropriately. The second argument can be:
- a `Vector{Bool}` or equivalent, representing a specific color to undo
- any number of `Int` or a `Vector{Int}`, representing indices of colors to undo

See `?SRG.hascolor` for examples (same syntax).
"""
function uncolor!(x::Node{K}, colors::Vararg{<:Integer}) where K
    for c in colors
        !(0 < c <= K) && throw(DimensionMismatch("Cannot uncolor degree $K Node at $c"))
        x.color[c] = false
    end
end
uncolor!(x::Node, colors::AbstractVector{<:Integer}) = uncolor!(x, colors...)

uncolor!(x::Node, color::AbstractVector{Bool}) = uncolor!(x, findall(color))
