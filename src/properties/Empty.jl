numconnections(network::EmptyNetwork) = 0
isdirected(network::EmptyNetwork) = false
meanconnectivity(network::EmptyNetwork) = 0
adjVet(network::EmptyNetwork) = Int[]

function adjMat(network::EmptyNetwork; sparse::Bool=false)
	return sparse ?
		SparseArrays.spzeros(Bool, network.N, network.N) :
		BitArray(zeros(Bool, network.N, network.N))
end

