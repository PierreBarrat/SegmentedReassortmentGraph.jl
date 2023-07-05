abstract type Node{K} end

struct RootNode{K} <: Node{K}
    color::SVector{K, Bool}
end

RootNode{K}() where K = RootNode{K}(ones(SVector{K,Bool}))

####################################################################
############################### Branch{K} ##########################
####################################################################

mutable struct Branch{K}
    parent::Node{K}
    child::Node{K}
    color::MVector{K, Bool}
    len::Union{Missing, Float64}

    function Branch{K}(parent, child, color, len) where K
        if length(color) != K
            throw(DimensionMismatch("Cannot create `Branch` of degree `K` with color vector of dimension $(size(color))"))
        end
        @assert parent != child "Cannot create branch with identical parent $parent and child $child"

        return new{K}(parent, child, color, len)
    end
end

Branch(parent, child, color, len) = Branch{length(color)}(parent, child, color, len)


####################################################################
############################## TreeNode{K} #########################
####################################################################

mutable struct TreeNode{K} <: Node{K}
    id::String
    label::String
    up_branch::Union{Nothing, Branch{K}}
    down_branches::Vector{Branch{K}}
    color::MVector{K, Bool}
end

"""
    TreeNode{K}(;
        label = "TreeNode",
        color = ones(MVector{K, Bool}),
    ) where K

Construct an unlinked `TreeNode`: connected upwards to a root and downwards to nothing.
"""
function TreeNode{K}(;
    id = randstring(id_length),
    label = "TreeNode",
    color = ones(MVector{K, Bool}),
) where K
    node = TreeNode{K}(id, label, nothing, [], color)
    node.up_branch = Branch(RootNode{K}(color), node, color, missing)
    return node
end

Base.:(==)(x::TreeNode{K}, y::TreeNode{K}) where K = (x.id == y.id)
Base.hash(x::TreeNode, h::UInt64) = hash(x.id, h)




