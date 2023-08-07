abstract type Element{K} end

abstract type Node{K} <: Element{K} end

struct GlobalRoot{K} <: Node{K}
end

####################################################################
############################### Branch{K} ##########################
####################################################################

mutable struct Branch{K} <: Element{K}
    parent::Node{K}
    child::Node{K}
    color::Color{K}
    len::Union{Missing, Float64}

    function Branch{K}(parent::Node{K}, child::Node{K}, color::Color{K}, len) where K
        @assert parent != child "Cannot create branch with identical parent $parent and child $child"
        return new{K}(parent, child, color, len)
    end
end

Branch(parent, child, color::Color{K}, len) where K = Branch{K}(parent, child, color, len)
function Branch(parent, child, color::AbstractVector, len)
    K = length(color)
    return Branch{K}(parent, child, Color{K}(color), len)
end


"""
    _add_ancestor!(child::Element, branch)
    _add_child!(parent::Element, branch)
    _remove_ancestor!(child::Element, branch)
    _remove_child!(parent::Element, branch)

Not to use directly. Add a branch down/up an element. Perform basic checks.
"""
function _add_ancestor! end
function _add_child! end
function _remove_ancestor! end
function _remove_child! end
####################################################################
############################## TreeNode{K} #########################
####################################################################

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
    node.up_branch = nothing
    return node
end

Base.:(==)(x::TreeNode{K}, y::TreeNode{K}) where K = (x.id == y.id)
Base.hash(x::TreeNode, h::UInt64) = hash(x.id, h)

ancestor(x::TreeNode) = isnothing(x.up_branch) ? nothing : x.up_branch.parent
function ancestor(x::TreeNode, color)
    @assert hascolor(x, color) "ColorError" x color
    ancestor(x)
end

children(x::TreeNode) = Iterators.map(b -> b.child, x.down_branches)
child(x::TreeNode, i) = x.down_branches[i].child

isleaf(x::TreeNode) = isempty(x.down_branches)
issingleton(x::TreeNode) = (length(x.down_branches) == 1)
isroot(::TreeNode) = false


function check_node(x::TreeNode{K}) where K
    try
        @assert ancestor(x) != x "Node $x is its own ancestor"
        # x must have at least one color
        @assert sum(x.color) > 0 "Node must have at least one color"
        # tree node: all colors must go up
        @assert isofcolor(x, x.up_branch.color) "Mismatched colors with up branch"
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

