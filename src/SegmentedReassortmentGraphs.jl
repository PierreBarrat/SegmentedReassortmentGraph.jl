module SegmentedReassortmentGraphs

import Base: ==, copy, hash, iterate, eltype, length
# functions for Color
import Base: !, getindex, setindex!, intersect, issubset, setdiff, union

using Random
using StaticArrays
using TreeTools

export SRG
const SRG = SegmentedReassortmentGraphs

include("const.jl")
include("colors.jl")
include("elements.jl")

include("core_methods.jl")

import Base: show
include("show.jl")

end
