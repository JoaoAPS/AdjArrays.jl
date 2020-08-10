"""
	EmptyNetwork <: AbstractNetwork

A network with no connections.

# Fields
- N              :: Integer -> Number of nodes
"""
struct EmptyNetwork <: AbstractNetwork
	N :: Integer
	_props :: NetworkProperties
end

"""
	EmptyNetwork(N::Integer)

Create an empty network with `N` nodes
"""
function EmptyNetwork(N::Integer)
	(N <= 0) && throw(ArgumentError("Number of nodes must be a positive integer!"))
	EmptyNetwork(N, NetworkProperties(N, false))
end

show(network::EmptyNetwork) = println("Empty Network\n- N = $(network.N)")