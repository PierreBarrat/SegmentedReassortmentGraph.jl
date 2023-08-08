abstract type Element{K} end

abstract type Node{K} <: Element{K} end

####################################################################
############################### Branch{K} ##########################
####################################################################

mutable struct Branch{K} <: Element{K}
    parent::Node{K}
    child::Node{K}
    color::Color{K}
    len::Union{Missing, Float64}

    function Branch{K}(parent::Node{K}, child::Node{K}, color::Color{K}, len) where K
        if parent == child
            throw(ErrorException(
                """
                Cannot create branch with identical parent $parent and child $child"""
            ))
        end
        return new{K}(parent, child, color, len)
    end
end

Branch(parent, child, color::Color{K}, len) where K = Branch{K}(parent, child, color, len)
function Branch(parent, child, color::AbstractVector, len)
    K = length(color)
    return Branch{K}(parent, child, Color{K}(color), len)
end


####################################################################
############################### Node{K} ##########################
####################################################################

#=
Docstrings of joint methods
=#

"""
    children(x::Node)

Return an iterator over the children of `x`.
Elements are tuples of the form `(child, branch_color)`.
"""
function children end

"""
    ancestor(x::Node, color)
Return the ancestor of `x` for `color`.
If `x` is a root (*i.e.* no ancestor) return `nothing` instead of the ancestor.
If there is no unambiguous ancestor for `color`, throw an error.
"""
function ancestor end

"""
    ancestors(x::Node)

Return an iterator over the ancestors of x.
Elements are tuples of the form `(ancestor, branch_color)`.
"""
function ancestors end

"""
    find_ancestor(child::Node, parent::Node)

Return the branch above `child` leading to `parent`, and an index if relevant.
Output format: `(idx, branch)` where both `idx` and `branch` can be `nothing`.
If `idx` is an integer, then `child.up_branch[i] == branch`.
"""
function find_ancestor end

"""
    isroot(x::Node[, color])

If the branch up from x does not have all colors of x, then x is a root.
"""
function isroot end

"""
    hasancestor(child::Node, parent::Node[, color])

Does `child` has `parent` as an ancestor?
"""
function hasancestor end

"""
    _add_ancestor!(child::Node, branch)
    _add_child!(parent::Node, branch)
    _remove_ancestor!(child::Node, branch)
    _remove_child!(parent::Node, branch)

Not to use directly. Add or remove a branch down/up an node.
Perform basic checks based on the node.
"""
function _add_ancestor! end
function _add_child! end
function _remove_ancestor! end
function _remove_child! end

#=
To implement
- ancestor(node, color) / ancestors(node)
- children(node)
- hasancestor(child::SpecNode, parent::Node)
- haschild(child::SpecNode, parent::Node)
- find_ancestor(child::SpecNode, parent::Node) --> (idx, branch_to_ancestor)
- _add_ancestor!(node::SpecNode, branch)
- _add_child!(node::, branch)
- _remove_ancestor!(node::, branch)
- _remove_child!(node::, branch)
- isleaf
- issingleton
- isroot
- isroot(node, color)
- branch_length
=#
####################################################################
############################## TreeNode{K} #########################
####################################################################
"""
    TreeNode{K} <: Node{K}

Node with one or no ancestor, and any number of children.
"""
mutable struct TreeNode{K} <: Node{K}
    id::String
    label::String
    up_branch::Union{Nothing, Branch{K}}
    down_branches::Vector{Branch{K}}
    color::Color{K}

    function TreeNode{K}(id, label, up_branch, down_branches, color::Color{K}) where K
        return new(id, label, up_branch, down_branches, color)
    end
end

function TreeNode{K}(id, label, up_branch, down_branches, color::AbstractVector) where K
    return TreeNode{K}(id, label, up_branch, down_branches, Color{K}(color))
end

"""
    TreeNode{K}(;
        label = "TreeNode",
        color = ones(MVector{K, Bool}),
        branch_length = missing,
    ) where K

Construct an unlinked `TreeNode`: connected upwards to a root and downwards to nothing.
`color` should be in the onehot format (see `SRG.index_to_onehot`).
"""
function TreeNode{K}(;
    id = randstring(id_length),
    label = "TreeNode",
    color = Color{K}(ones(Bool, K)),
    branch_length = missing,
) where K
    node = TreeNode{K}(id, label, nothing, [], color)
    return node
end

Base.:(==)(x::TreeNode{K}, y::TreeNode{K}) where K = (x.id == y.id)
Base.hash(x::TreeNode, h::UInt64) = hash(x.id, h)

"""
    child(x::TreeNode, i)

Return the ith child of x along with the branch color: `(child, color)`.
"""
child(x::TreeNode, i) = (x.down_branches[i].child, x.down_branches[i].color)
children(x::TreeNode) = Iterators.map(b -> (b.child, b.color), x.down_branches)

"""
    haschild(parent, child)
"""
haschild(parent::TreeNode{K}, child::Node{K}) where K = in(child, children(parent))

"""
    ancestor(x::TreeNode)

Return the ancestor of `x` along with the color of the branch leading to it, as
a tuple of the form `(ancestor, color)`.
If `x` is a root, return `(nothing, x.color)`.
"""
function ancestor(x::TreeNode)
    return if isnothing(x.up_branch)
        (nothing, x.color)
    else
        (x.up_branch.parent, x.up_branch.color)
    end
end
"""
    ancestor(x::TreeNode, color)

Always return an unambiguous ancestor, otherwise throws an error:
- return `nothing` if `x` is the root for `color`
- return `ancestor(x)` if the branch above `x` has color `color`.
- throws an error if the branch above `x` has some but not all of the colors in `color`, since
  in this case, both `nothing` and `ancestor(x)` could arguably be returned.
"""
function ancestor(x::TreeNode, color)
    return if !hascolor(x, color)
        throw(ColorError("Node $x (clr $(x.color)) does not have color $color"))
    elseif isnothing(x.up_branch) || isdisjoint(x.up_branch.color, color)
        nothing
    elseif hascolor(x.up_branch, color)
        ancestor(x)[1]
    else
        throw(ErrorException("""
            $x has no well defined ancestor for color $color.
            Node color $(x.color) - color of up branch $(x.up_branch.color)
        """))
    end
end
ancestor(x::TreeNode{K}, color::Vararg{<:Integer}) where K = ancestor(x, Color{K}(color...))
ancestors(x::TreeNode) = (ancestor(x),)

hasancestor(child::TreeNode{K}, parent::Node{K}) where K = (ancestor(child)[1] == parent)
function hasancestor(child::TreeNode{K}, parent::Node{K}, color) where K
    return ancestor(child, Color{K}(color)) == parent
end
function hasancestor(child, parent::Node{K}, color...) where K
    return hasancestor(child, parent, Color{K}(color...))
end

function find_ancestor(child::TreeNode{K}, parent::Node{K}) where K
    hasancestor(child, parent) ? (nothing, child.up_branch) : (nothing, nothing)
end


branch_length(x::TreeNode) = x.up_branch.len
function branch_length(x::TreeNode, color)
    @assert hascolor(x, color) "ColorError" x color
    return branch_length(x)
end
function branch_length(x::TreeNode, color::Vararg{<:Integer})
    @assert hascolor(x, color...) "ColorError" x color
    return branch_length(x)
end

isleaf(x::TreeNode) = isempty(x.down_branches)
issingleton(x::TreeNode) = (length(x.down_branches) == 1)


isroot(x::TreeNode) = isnothing(x.up_branch) || !hascolor(x.up_branch, x.color)
function isroot(x::TreeNode, color)
    return if !hascolor(x, color)
        false
    else
        isnothing(x.up_branch) || !hascolor(x.up_branch, color)
    end
end
isroot(x::TreeNode{K}, color::Vararg{<:Integer}) where K = isroot(x, Color{K}(color...))



function check_node(x::TreeNode{K}) where K
    try
        @assert ancestor(x)[1] != x "Node is its own ancestor"
        # x must have at least one color
        @assert sum(x.color) > 0 "Node must have at least one color"
        # tree node: all colors must go up
        @assert isnothing(x.up_branch) || hascolor(x, x.up_branch.color) "Mismatched colors with up branch"
        # Colors of branch going down must be included in x
        for (i, b) in enumerate(x.down_branches)
            @assert hascolor(x, b.color) "Mismatched color with down branch $i"
        end
        # All colors of x must go down somewhere

    catch err
        println("Check failed for node $x")
        throw(err)
        return false
    end
    return true
end


function _add_ancestor!(child::TreeNode, branch)
    isnothing(child.up_branch) || throw(ErrorException("Node $child already has an ancestor"))
    hascolor(child, branch.color) || throw(ColorError("Incompatible colors - $child $branch"))
    child.up_branch = branch
end
function _add_child!(parent::TreeNode, branch)
    hascolor(parent, branch.color) || throw(ColorError("Incompatible colors - $parent $branch"))
    push!(parent.down_branches, branch)
end
function _remove_ancestor!(child::TreeNode, branch)
    child.up_branch == branch || throw(ErrorException("Branch $branch is not ancestor of $child"))
    child.up_branch = nothing
end
function _remove_child!(parent::TreeNode, branch)
    i = findfirst(==(branch), parent.down_branches)
    !isnothing(i) || throw(ErrorException("Branch $branch is not a child of $parent"))
    deleteat!(parent.down_branches, i)
end


####################################################################
############################## HybridNode{K} #########################
####################################################################
"""
    HybridNode{K} <: Node{K}

Node with at least 2 and at most `K` ancestors, and exactly one child.

!!! note
For ease of implementation, a `HybridNode` can have no branch going down, *i.e.* can have no child. This should be an exceptional situation that only arises during initialization of the node. Such a node will throw an error when `check_node` is called.
!!!
"""
mutable struct HybridNode{K} <: Node{K}
    id::String
    label::String
    up_branches::Vector{Branch{K}}
    down_branch::Union{Nothing, Branch{K}}
    color::Color{K}

    function HybridNode{K}(id, label, up_branches, down_branch, color::Color{K}) where K
        return new(id, label, up_branches, down_branch, color)
    end
end
function HybridNode{K}(id, label, up_branches, down_branch, color::AbstractVector) where K
    return HybridNode{K}(id, label, up_branches, down_branch, Color{K}(color))
end
"""
    HybridNode{K}(;
        label = "TreeNode",
        color = ones(MVector{K, Bool}),
        branch_length = missing,
    ) where K

Construct an unlinked `HybridNode`: connected upwards to a root and downwards to nothing.
`color` should be in the onehot format (see `SRG.index_to_onehot`).
"""
function HybridNode{K}(;
    id = randstring(id_length),
    label = "HybridNode",
    color = Color{K}(ones(Bool, K)),
    branch_length = missing,
) where K
    return HybridNode{K}(id, label, [], nothing, color)
end


Base.:(==)(x::HybridNode{K}, y::HybridNode{K}) where K = (x.id == y.id)
Base.hash(x::HybridNode, h::UInt64) = hash(x.id, h)

function children(x::HybridNode)
end

function haschild(parent::HybridNode{K}, child::Node{K}) where K
end

function ancestors(x::HybridNode)
end

function ancestor(x::HybridNode, color)
end
ancestor(x::HybridNode{K}, color::Vararg{<:Integer}) where K = ancestor(x, Color{K}(color...))


function hasancestor(child::HybridNode{K}, parent::Node{K}) where K
end
function hasancestor(child::HybridNode{K}, parent::Node{K}, color) where K
end
function hasancestor(child::HybridNode{K}, parent::Node{K}, color...) where K
    return hasancestor(child, parent, Color{K}(color...))
end

function find_ancestor(child::HybridNode{K}, parent::Node{K}) where K
end

function branch_length(x::HybridNode, color)
end

isroot(x::HybridNode) = false
isleaf(x::HybridNode) = false
function issingleton(x::HybridNode)
end

function check_node(x::HybridNode{K}) where K
end


