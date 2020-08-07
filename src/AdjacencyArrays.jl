module AdjacencyArrays

import SparseArrays, Random
import Base.show, Base.display

include("utils.jl")
include("operators.jl")

include("architectures/AbstractNetwork.jl")
include("architectures/Global.jl")
include("architectures/Regular.jl")
include("architectures/ErdosRenyi.jl")

export AbstractNetwork, GlobalNetwork, RegularNetwork, ErdosRenyiNetwork

export adjVet, adjMat
export adjVetToMat, adjMatToVet

end
