module AdjArrays

include("architectures/Global.jl")
include("architectures/ErdosRenyi.jl")
include("operators.jl")

export GlobalNetwork, ErdosRenyiNetwork
export adjVet
export adjMat

export adjVetToMat, adjMatToVet

end
