module AdjArrays

include("operators.jl")
include("architectures/Global.jl")
include("architectures/Regular.jl")
include("architectures/ErdosRenyi.jl")

export GlobalNetwork, RegularNetwork, ErdosRenyiNetwork

export adjVet, adjMat
export adjVetToMat, adjMatToVet

end
