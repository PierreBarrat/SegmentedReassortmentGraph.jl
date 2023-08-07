"""
    link!(parent, child, color[, length=missing])

Link `ancestor` to `child` with a branch of `color`, by creating a branch if necessary.
"""
function link!(
    parent::Node{K},
    child::Node{K},
    color::Color{K},
    length = missing,
) where K
    if !hascolor(parent, color)
        throw(ColorError("Cannot link $(parent) with color $(parent.color) to a branch of color $color"))
    elseif !hascolor(child, color)
        throw(ColorError("Cannot link $(child) with color $(child.color) to a branch of color $color"))
    end

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
    if !hasancestor(child, parent, color)
        throw(ErrorException("Cannot unlink nodes for $color: expected $child to be the child of $parent."))
    end

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
