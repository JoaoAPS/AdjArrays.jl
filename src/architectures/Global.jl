"""
	GlobalNetwork <: AbstractNetwork

A global (complete) network.

# Fields
- N              :: Integer -> Number of nodes
- numConnections :: Integer -> Number of connections
"""
struct GlobalNetwork <: AbstractNetwork
	N :: Integer
	numConnections :: Integer
end

"""
	GlobalNetwork(N::Integer)

Create a global network with `N` nodes
"""
function GlobalNetwork(N::Integer)
	(N <= 0) && throw(ArgumentError("Number of nodes must be a positive integer!"))
	GlobalNetwork(N, N * (N-1) / 2)
end
	

function adjVet(network::GlobalNetwork)
	return [i for i in 0:network.N^2-1 if i % (network.N + 1) != 0]
end

function adjMat(network::GlobalNetwork)
	return BitArray([(i != j) for i in 1:network.N, j in 1:network.N ])
end

show(network::GlobalNetwork) = println("Global Network\n- N = $(network.N)")