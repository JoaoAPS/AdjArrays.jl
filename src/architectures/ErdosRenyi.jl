"""
	ErdosRenyiNetwork <: AbstractNetwork

A random network contructed via the Erdos-Renyi method.

# Fields
- N              :: Integer -> Number of nodes
- p              :: Real -> Connection probability
- seed           :: Integer -> Seed for the random creation
"""
mutable struct ErdosRenyiNetwork <: AbstractNetwork
	N :: Integer
	p :: Union{Real, Nothing}
	seed :: Integer
	
	_adjMat :: AbstractMatrix
	_props :: NetworkProperties
end

"""
	ErdosRenyiNetwork(N, p; directed=false, seed=-1)

Create an Erdos-Renyi random network with `N` nodes and connection probability `p`.
"""	
function ErdosRenyiNetwork(
	N::Integer,
	p::Real;
	directed::Bool=false,
	seed::Integer=-1
)
	(N <= 0) && throw(ArgumentError("Number of nodes must be a positive integer!"))
	(p > 1) && (p = 1.0)
	(p < 0) && (p = 0.0)
	
	_seed = seed < 0 ? rand(1:999999999) : seed
	mat = generateERAdjMat(N, p; directed=directed, seed=_seed)
	
	ErdosRenyiNetwork(N, p, _seed, mat, NetworkProperties(N, directed))
end

"""
	ErdosRenyiNetwork(N, numConnections; directed=false, seed=-1)

Create an Erdos-Renyi random network with `N` nodes and `numConnections` connections.
"""
function ErdosRenyiNetwork(
	N::Integer,
	numConnections::Integer;
	directed::Bool=false,
	seed::Integer=-1
)
	(N <= 0) && throw(ArgumentError("Number of nodes must be a positive integer!"))
	
	maxConnections = Int(N * (N - 1) / (directed ? 1 : 2))
	(numConnections > maxConnections) && (numConnections = maxConnections)
	(numConnections < 0) && (numConnections = 0)
	
	_seed = seed < 0 ? rand(1:999999999) : seed
	mat = generateERAdjMat(N, numConnections; directed=directed, seed=_seed)

	ErdosRenyiNetwork(N, nothing, _seed, mat, NetworkProperties(N, directed, numConnections))
end


function show(network::ErdosRenyiNetwork)
	print(isdirected(network) ? "Directed " : "Undirected ")
	println("Erdos-Renyi Random Network")
	println("- N = $(network.N)")
	println("- p = $(network.p)")
	println("- seed = $(network.seed)")
end
