"""
	GlobalNetwork <: AbstractNetwork

A global (complete) network.

# Fields
- N              :: Integer -> Number of nodes
"""
struct GlobalNetwork <: AbstractNetwork
	N :: Integer
	_props :: NetworkProperties
end

"""
	GlobalNetwork(N::Integer; directed::Bool=false)

Create a global network with `N` nodes
"""
function GlobalNetwork(N::Integer; directed::Bool=false)
	(N <= 0) && throw(ArgumentError("Number of nodes must be a positive integer!"))
	GlobalNetwork(N, NetworkProperties(directed))
end


function show(network::GlobalNetwork)
	print(isdirected(network) ? "Directed " : "Undirected ")
	println("Global Network")
	println("- N = $(network.N)")
end