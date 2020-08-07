"""
	ErdosRenyiNetwork <: AbstractNetwork

A random network contructed via the Erdos-Renyi method.

# Fields
- N              :: Integer -> Number of nodes
- p              :: Float64 -> Connection probability
- numConnections :: Integer -> Number of connections
- directed       :: Bool    -> Wheter the network is directed or not
- seed           :: Integer -> Seed for the random creation
"""
struct ErdosRenyiNetwork <: AbstractNetwork
	N :: Integer
	p :: Union{Float64, Nothing}
	numConnections :: Integer
	directed :: Bool
	seed :: Integer
	
	_adjMat :: AbstractMatrix
end

"""
	ErdosRenyiNetwork(N, p; directed=false, seed=-1)

Create an erdos-renyi random network with `N` nodes and connection probability `p`.
"""	
function ErdosRenyiNetwork(
	N::Integer,
	p::Float64;
	directed::Bool=false,
	seed::Integer=-1
)
	(N <= 0) && throw(ArgumentError("Number of nodes must be a positive integer!"))
	
	_seed = seed < 0 ? rand(1:999999999) : seed
	mat = generateERAdjMat(N, p; directed, seed=_seed)
	numConnections = sum(mat)
	directed || (numConnections /= 2)
	
	ErdosRenyiNetwork(N, p, Int(numConnections), directed, _seed, mat)
end

"""
	ErdosRenyiNetwork(N, numConnections; directed=false, seed=-1)

Create an erdos-renyi random network with `N` nodes and `numConnections` connections.
"""
function ErdosRenyiNetwork(
	N::Integer,
	numConnections::Integer;
	directed::Bool=false,
	seed::Integer=-1
)
	(N <= 0) && throw(ArgumentError("Number of nodes must be a positive integer!"))
	
	_seed = seed < 0 ? rand(1:999999999) : seed
	mat = generateERAdjMat(N, numConnections; directed, seed=_seed)

	ErdosRenyiNetwork(N, nothing, numConnections, directed, _seed, mat)
end


function generateERAdjMat(
	N::Integer,
	p::Float64;
	directed::Bool,
	seed::Integer
)
	(p >= 1) && (return adjMat(GlobalNetwork(N)))
	(p <= 0) && (return SparseArrays.spzeros(N,N))
	
	rng = Random.MersenneTwister(seed)
	mat = SparseArrays.spzeros(Bool, N, N)
	
	if directed
		for i in 1:N, j in 1:N
			(i == j) && continue
			(rand(rng) < p) && (mat[i,j] = 1)
		end
	else
		for i in 1:N, j in i+1:N
			if rand(rng) < p
				mat[i,j] = 1
				mat[j,i] = 1
			end
		end
	end
	
	return mat
end

function generateERAdjMat(
	N::Integer,
	numConnections::Int;
	directed::Bool,
	seed::Integer
)
	maxConnections = Int(N * (N - 1) / 2)
	directed || (maxConnections /= 2)
	
	(numConnections >= maxConnections) && (return adjMat(GlobalNetwork(N)))
	(numConnections <= 0) && (return SparseArrays.spzeros(Bool, N, N))
	
	rng = Random.MersenneTwister(seed)
	mat = SparseArrays.spzeros(Bool, N, N)
	nc = 0
	
	while nc < numConnections
		# Choose a random non-existing connection
		origin = rand(rng, 1:N)
		dest   = rand(rng, 1:N)

		(origin == dest) && continue
		(mat[dest, origin] == 1) && continue
		
		mat[dest, origin] = 1
		directed || (mat[origin, dest] = 1)
		nc += 1
	end
	
	return mat
end

function show(network::ErdosRenyiNetwork)
	println("Erdos-Renyi Random Network")
	println("- N = $(network.N)")
	println("- p = $(network.p)")
	println("- numConnections = $(network.numConnections)")
	println("- directed = $(network.directed)")
	println("- seed = $(network.seed)")
end
