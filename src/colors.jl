####################################################################
############################## Type and constructors #########################
####################################################################

mutable struct Color{K}
    color::MVector{K, Bool}
end

Color(c::AbstractVector{Bool}) = Color{length(c)}(c)

function Color{K}(colors::AbstractVector{Int}) where K
    c = zeros(MVector{K, Bool})
    for i in colors
        c[i] = true
    end
    return Color{K}(c)
end
Color(colors::AbstractVector{Int}, K) = Color{K}(colors)

Color{K}(colors::Vararg{<:Integer}) where K = Color{K}(collect(Int, colors))

####################################################################
############################## Base functions #########################
####################################################################

Base.:(==)(x::Color{K}, y::Color{K}) where K = all(z -> z[1]==z[2], zip(x.color, y.color))
Base.:(==)(::Color, ::Color) = false
Base.hash(x::Color, h::UInt64) = hash(x.color, h)

Base.getindex(x::Color, val, i...) = getindex(x.color, val, i...)
Base.setindex!(x::Color, val, i...) = setindex!(x.color, val, i...)

Base.iterate(x::Color) = iterate(x.color)
Base.iterate(x::Color, state) = iterate(x.color, state)
Base.length(::Color{K}) where K = K
Base.eltype(::Color) = Bool

colors(x::Color{K}) where K = Iterators.filter(i -> x[i], 1:K)

Base.copy(x::Color) = Color(copy(x.color))

####################################################################
############################## Set-like functions #########################
####################################################################

Base.:(!)(x::Color) = Color(.!(x.color))
function Base.union(x::Color{K}, y::Color{K}) where K
    z = Color(zeros(Bool, K))
    for (i, (c1, c2)) in enumerate(zip(x, y))
        z[i] = c1 || c2
    end
    return z
end

function Base.intersect(x::Color{K}, y::Color{K}) where K
    z = Color(zeros(Bool, K))
    for (i, (c1, c2)) in enumerate(zip(x, y))
        z[i] = c1 && c2
    end
    return z
end

"""
    issubset(x::Color, y::Color)

Is every color in `x` also in `y`.
"""
Base.issubset(x::Color{K}, y::Color{K}) where K = all(i -> y[i], colors(x))


"""
    Base.setdiff(x::Color, y::Color)

Return a `Color` with all colors in `x` and not in `y`.
"""
function Base.setdiff(x::Color{K}, y::Color{K}) where K
    z = copy(x)
    for i in colors(y)
        z[i] = false
    end
    return z
end


####################################################################
############################## Other #########################
####################################################################


"""
    index_to_onehot(colors::AbstractVector{Int}, K::Int)

Converts colors specified by indices to a onehot like format.
The total number of colors is `K`.

## Examples
```jldoctest
julia> K = 4;

julia> SRG.index_to_onehot([1, 3], K)
[true, false, true, false]

julia> SRG.index_to_onehot(Int[], K)
[false, false, false, false]
"""
function index_to_onehot(colors::AbstractVector{Int}, K)
    c = zeros(MVector{K, Bool})
    for i in colors
        c[i] = true
    end
    return c
end
"""
    onehot_to_index(colors::AbstractVector{Bool})

Convert from onehot to indices. Simply does `collect(findall(colors))`.

## Examples
```jldoctest
julia> SRG.onehot_to_index([false, true, false])
[2]

julia>SRG.onehot_to_index(ones(Bool, 5))
[1,2,3,4,5]
```
"""
onehot_to_index(colors::AbstractVector{Bool}) = collect(findall(colors))

function color_union(colors::Vararg{AbstractVector{Bool}})
    color_union = zeros(Bool, length(colors))
    for clr in colors, c in clr
        if c
            color_union[c] = true
        end
    end
    return color_union
end
