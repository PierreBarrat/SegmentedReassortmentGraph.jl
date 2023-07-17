"""
    hasancestor(child, parent)
    hasancestor(child, parent, color)

Does `child` has `parent` as an ancestor?
"""
hasancestor(child::TreeNode{K}, parent::Node{K}) where K = (ancestor(child) == parent)
function hasancestor(child::TreeNode{K}, parent::Node{K}, color) where K
    return ancestor(child, Color{K}(color)) == parent
end
function hasancestor(child, parent::Node{K}, color...) where K
    hasancestor(child, parent, Color{K}(color...))
end

"""
    haschild(parent, child)
"""
haschild(parent::TreeNode{K}, child::Node{K}) where K = in(child, children(parent))


function find_ancestor(child::TreeNode{K}, parent::Node{K}) where K
    hasancetor(child, parent) ? (nothing, child.up_branch) : (nothing, nothing)
end





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
    color!(x::Element, color)

Color `x` appropriately. The second argument can be an index, an array or a vararg.
See `?SRG.hascolor` for examples (same syntax).
"""
function color!(x::Element{K}, color::Color{K}) where K
    @debug hascolor(x, color) && @warn "$x already has color $color"
    return union!(x.color, color)
end
color!(x::Element{K}, color::AbstractVector) where K = color!(x, Color{K}(color))
color!(x::Element{K}, color::Vararg{<:Integer}) where K = color!(x, Color{K}(color...))

"""
    uncolor!(x::Element, color)

Uncolor `x` appropriately. The second argument can be:
- a `Color`
- a `Vector{Bool}` or equivalent, representing a specific color to undo
- any number of `Int` or a `Vector{Int}`, representing indices of colors to undo

See `?SRG.hascolor` for examples (same syntax).
"""
function uncolor!(x::Element{K}, color::Color{K}) where K
    @debug !hascolor(x, color) && @warn "$x does not have color $color"
    return setdiff!(x.color, color)
end
uncolor!(x::Element{K}, color::AbstractVector) where K = uncolor!(x, Color{K}(color))
uncolor!(x::Element{K}, color::Vararg{<:Integer}) where K = uncolor!(x, Color{K}(color...))
