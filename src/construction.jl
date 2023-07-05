"""
    link!(ancestor, child, colors[, length=missing])

Link `ancestor` to `child` by creating a branch. Return the branch.
"""
function link!(
    ancestor::TreeNode{K},
    child::TreeNode{K},
    colors::AbstractVector{Bool},
    length = missing,
) where K
    @assert hascolors(ancestor, colors) "Cannot link node $(ancestors) with color $(ancestors.color) to a branch of color $colors"
    @assert hascolors(child, colors) "Cannot link node $(child) with color $(child.color) to a branch of color $colors"

    b = Branch{K}(parent, child, colors, length)

end
