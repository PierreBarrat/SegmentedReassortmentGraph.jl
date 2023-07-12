module SegmentedReassortmentGraphs

import Base: ==, hash

using Random
using StaticArrays
using TreeTools

export SRG
const SRG = SegmentedReassortmentGraphs

include("const.jl")
include("objects.jl")

include("colors.jl")

import Base: show
include("show.jl")

end
