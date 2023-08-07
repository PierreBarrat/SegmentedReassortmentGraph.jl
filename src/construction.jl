
"""
    link!(parent, child, color[, length=missing])

Link `ancestor` to `child` by creating a branch if necessary.
"""
function link!(
    parent::Node{K},
    child::Node{K},
    color::Color{K},
    length = missing,
) where K
    @assert hascolor(parent, colors) "Cannot link node $(ancestors) with color $(ancestors.color) to a branch of color $colors"
    @assert hascolor(child, colors) "Cannot link node $(child) with color $(child.color) to a branch of color $colors"

    # If the two nodes are already linked, we just need to color the branch
    if hasancestor(child, parent)
        _, branch = find_ancestor(child, parent)
        color!(branch, color)
    else # else, we add a branch
        branch = Branch{K}(parent, child, color, length)
        _add_ancestor!(child, branch)
        _add_child!(parent, branch)
    end

    return nothing
end

function unlink!(parent::Node{K}, child::Node{K}, color) where K
    @assert hasancestor(child, parent, color) "Cannot unlink $parent and $child for $color"

    _, branch = find_ancestor(child, parent)
    if isofcolor(branch, color) # remove the branch entirely
        _remove_ancestor!(child, branch)
        _remove_child!(parent, branch)
    else # simply uncolor it
        uncolor!(branch, color)
    end

    return nothing
end
function unlink!(parent, child)
    _, branch = find_ancestor(child, parent)
    _remove_ancestor!(child, branch)
    _remove_child!(parent, branch)
    return nothing
end

# function prune!(node::TreeNode{K}, )
