"""
	EmptyNetwork <: AbstractNetwork

A network with no connections.

# Fields
- N              :: Integer -> Number of nodes
"""
struct EmptyNetwork <: AbstractNetwork
	N :: Integer
	
	"""
		EmptyNetwork(N::Integer)

	Create an empty network with `N` nodes
	"""
	function EmptyNetwork(N::Integer)
		(N <= 0) && throw(ArgumentError("Number of nodes must be a positive integer!"))
		new(N)
	end
end

	

adjVet(network::EmptyNetwork) = []

function adjMat(network::EmptyNetwork; sparse::Bool=false)
	return sparse ?
		SparseArrays.spzeros(Bool, network.N, network.N) :
		BitArray(zeros(Bool, network.N, network.N))
end

show(network::EmptyNetwork) = println("Empty Network\n- N = $(network.N)")