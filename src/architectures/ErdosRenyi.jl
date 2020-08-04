using LightGraphs

"""
- `N :: Integer`: Number of nodes
- `p :: Float64`: Connection probability
- `numConnections :: Integer`: Number of connections
- `directed :: Bool`: Wheter the network is directed or not
- `seed :: Integer`: Seed for the random creation
"""
struct ErdosRenyiNetwork
	N :: Integer
	p :: Float64
	numConnections :: Integer
	directed :: Bool
	seed :: Integer
	_adjMat :: AbstractMatrix
	
	"""
		ErdosRenyiNetwork(N, p; directed=false, seed=-1)
	
	Creates a random network with `N` nodes and connection probability `p` via the Erdos-Renyi
	method.
	"""	
	function ErdosRenyiNetwork(N::Integer,
		p::Float64;
		directed::Bool=false,
		seed::Integer=-1
	)
		(N <= 0) && throw(ArgumentError("Number of nodes must be a positive integer!"))
		(0 < p < 1) || throw(ArgumentError("Connection probability must be between zero and one!"))
		
		_seed = seed < 0 ? rand(1:999999999) : seed
		graph = erdos_renyi(N, p, is_directed=directed, seed=_seed)
		mat = adjacency_matrix(graph)
		numConections = ne(graph)
		
		new(N, p, numConections, directed, _seed, mat)
	end
	
	"""
		ErdosRenyiNetwork(N, numConections; directed=false, seed=-1)
	
	Creates a random network with `N` nodes and `numConections` connections via the Erdos-Renyi
	method.
	"""
	function ErdosRenyiNetwork(
		N::Integer,
		numConections::Integer;
		directed::Bool=false,
		seed::Integer=-1
	)
		(N <= 0) && throw(ArgumentError("Number of nodes must be a positive integer!"))
		(numConections <= 0) &&
			throw(ArgumentError("Number of connections must be a positive integer!"))
		
		maxConnections = directed ? N * (N - 1) : N * (N - 1) / 2
		(numConections > maxConnections) &&
			throw(ArgumentError("Maximum number of connections for this network is $numConections"))
		
		_seed = seed < 0 ? rand(1:999999999) : seed
		graph = erdos_renyi(N, numConections, is_directed=directed, seed=_seed)
		mat = adjacency_matrix(graph)
		p = numConections / maxConnections
		
		new(N, p, numConections, directed, _seed, mat)
	end
end

function adjMat(network::ErdosRenyiNetwork; sparse::Bool=false)
	return sparse ? network._adjMat : BitArray(network._adjMat)
end

function adjVet(network::ErdosRenyiNetwork)
	return adjMatToVet(network._adjMat)
end