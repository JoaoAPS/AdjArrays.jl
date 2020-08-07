module AdjacencyArrays

import SparseArrays, Random
import Base.show, Base.display

include("utils.jl")
include("operators.jl")

include("architectures/AbstractNetwork.jl")
include("architectures/Empty.jl")
include("architectures/Global.jl")
include("architectures/Regular.jl")
include("architectures/ErdosRenyi.jl")
include("architectures/WattsStrogatz.jl")

export AbstractNetwork
export EmptyNetwork
export GlobalNetwork
export RegularNetwork
export ErdosRenyiNetwork
export WattsStrogatzNetwork

export adjVet, adjMat
export adjVetToMat, adjMatToVet

end
