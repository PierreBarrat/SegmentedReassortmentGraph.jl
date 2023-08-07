# for interactive / nice display
function Base.show(io::IO, ::MIME"text/plain", node::TreeNode)
    if !get(io, :compact, false)
        println(io, "SRG.TreeNode \"$(node.label)-$(node.id)\"")
        println(io, "Color $(node.color)")
    else
        print(io, "TreeNode $(node.label)-$(node.id)")
    end
    return nothing
end
# for use in something like `print(x)` or `[x]`
function Base.show(io::IO, node::TreeNode)
    print(io, "\"$(node.label)-$(node.id)\"")
    return nothing
end

function Base.show(io::IO, ::MIME"text/plain", branch::Branch)
    if !get(io, :compact, false)
        println(io, "Branch linking $(branch.parent) to $(branch.child)")
        println(io, "Color $(branch.color) - length $(branch.len)")
    end
    return nothing
end
function Base.show(io::IO, branch::Branch)
    println(io, "Branch $(branch.parent) --> $(branch.child)")
    return nothing
end

Base.show(io::IO, m::MIME"text/plain", color::Color) = show(io, m, color.color)
Base.show(io::IO, color::Color) = show(io, color.color)

Base.showerror(io::IO, e::ColorError) = print(io, "ColorError: ", e.msg)
