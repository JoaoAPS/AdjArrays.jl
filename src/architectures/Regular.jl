"""
	RegularNetwork <: AbstractNetwork

A regular (ring) network.

# Fields
- N              :: Integer -> Number of nodes
- k              :: Integer -> Node connectivity
"""
mutable struct RegularNetwork <: AbstractNetwork
	N :: Integer
	k :: Integer
	
	_adjMat :: Union{AbstractMatrix, Nothing}
	_props :: NetworkProperties
end

"""
	RegularNetwork(N::Integer, k::Integer; directed::Bool=false)

Create a regular network with `N` nodes and node connectivity `k`.
"""
function RegularNetwork(N::Integer, k::Integer; directed::Bool=false)
	(N <= 0) && throw(ArgumentError("Number of nodes must be a positive integer!"))
	
	(k % 2 == 1) && (k -= 1)
	(k < 0) && (k = 0)
	(k >= N-1) && (k = N-1)
	
	RegularNetwork(N, k, nothing, NetworkProperties(directed))
end


function show(network::RegularNetwork)
	print(isdirected(network) ? "Directed " : "Undirected ")
	println("Regular network")
	println("- N = $(network.N)")
	println("- k = $(network.k)")
end
