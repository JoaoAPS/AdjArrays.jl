struct GlobalNetwork
	N :: Integer
	
	"""
		GlobalNetwork(N::Integer)
	"""
	GlobalNetwork(N::Integer) = N > 0 ?
		new(N) :
		throw(ArgumentError("Number of nodes must be a positive integer!"))
end

"""
	adjVet(network::GlobalNetwork)

Returns the adjacency vector of the global network
"""
function adjVet(network::GlobalNetwork)
	return [i for i in 0:network.N^2-1 if i % (network.N + 1) != 0]
end

function adjMat(network::GlobalNetwork)
	return BitArray([(i != j) for i in 1:network.N, j in 1:network.N ])
end