numconnections(network::EmptyNetwork) = 0
isdirected(network::EmptyNetwork) = false
connectivity(network::EmptyNetwork) = 0
shortestpath(network::EmptyNetwork) = 0

adjVet(network::EmptyNetwork) = Int[]

function adjMat(network::EmptyNetwork; sparse::Bool=false)
	return sparse ?
		SparseArrays.spzeros(Bool, network.N, network.N) :
		BitArray(zeros(Bool, network.N, network.N))
end


#---------- Calculators ----------
calcConnectivity(network::EmptyNetwork, idx_node::Integer; dir_behaviour::Symbol) =
	dir_behaviour == :both ? (0,0) : 0
