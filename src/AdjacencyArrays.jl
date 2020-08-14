module AdjacencyArrays

import SparseArrays, Random
import Base.show, Base.display

export AbstractNetwork
export EmptyNetwork
export GlobalNetwork
export RegularNetwork
export ErdosRenyiNetwork
export WattsStrogatzNetwork
export CustomNetwork

export numnodes, numconnections, isdirected, numshortcuts
export hasnode, hasconnection
export connectivity, connectivities, meanconnectivity
export clusteringcoefficient, clusteringcoefficients, transitivity
export shortestpath, averagepathlength
export sigma, omega, smallworldness, equivalentRandomNetwork, equivalentLatticeNetork
export adjVet, adjMat
export adjVetToMat, adjMatToVet
export neighbors, allEdges

include("architectures/AbstractNetwork.jl")
include("utils.jl")
include("properties/NetworkProperties.jl")

include("architectures/Empty.jl")
include("architectures/Global.jl")
include("architectures/Regular.jl")
include("architectures/ErdosRenyi.jl")
include("architectures/WattsStrogatz.jl")
include("architectures/CustomNetwork.jl")

include("properties/Abstract.jl")
include("properties/Empty.jl")
include("properties/Global.jl")
include("properties/Regular.jl")
include("properties/ErdosRenyi.jl")
include("properties/WattsStrogatz.jl")

include("operators/Abstract.jl")



end
