numconnections(network::GlobalNetwork) =
	Int(network.N * (network.N - 1) / (isdirected(network) ? 1 : 2))

connectivity(network::GlobalNetwork) = network.N - 1
shortestpath(network::GlobalNetwork) = 1

adjVet(network::GlobalNetwork) =
	[i for i in 0:network.N^2-1 if i % (network.N + 1) != 0]

adjMat(network::GlobalNetwork; sparse::Bool=false) = 
	BitArray([(i != j) for i in 1:network.N, j in 1:network.N ])


#---------- Calculators ----------
function calcConnectivity(network::GlobalNetwork, idx_node::Integer; dir_behaviour::Symbol)
	isdirected(network) || (return network.N - 1)
	
	(dir_behaviour == :total) && (return 2 * (network.N - 1))
	(dir_behaviour == :both) && (return (network.N - 1, network.N - 1))
	return network.N - 1
end
