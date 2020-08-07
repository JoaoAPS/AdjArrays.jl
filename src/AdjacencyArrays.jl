module AdjacencyArrays

import SparseArrays, Random
import Base.display

include("utils.jl")
include("operators.jl")

include("architectures/AbstractNetwork.jl")
include("architectures/Global.jl")
include("architectures/Regular.jl")

export GlobalNetwork, RegularNetwork

export adjVet, adjMat
export adjVetToMat, adjMatToVet

end
