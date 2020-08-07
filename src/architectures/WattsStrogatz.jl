"""
	WattsStrogatzNetwork <: AbstractNetwork

A network contructed via the Watts-Strogatz method, possibly small-world.

# Fields
- N :: Integer -> Number of nodes
- k :: Integer -> Mean connectivity
- β :: Real -> Connection probability
- numConnections :: Integer -> Number of connections
- numShortcuts :: Integer -> Number of shortcuts rewired
- directed :: Bool -> Wheter the network is directed or not
- seed :: Integer -> Seed for the random creation
"""
mutable struct WattsStrogatzNetwork <: AbstractNetwork
	N :: Integer
	k :: Integer
	β :: Union{Real, Nothing}
	numConnections :: Integer
	numShortcuts :: Integer
	directed :: Bool
	seed :: Integer
	
	_adjMat :: AbstractMatrix
end

"""
	WattsStrogatzNetwork(N, k, β; directed=false, seed=-1)

Create an Watts-Strogatz network with `N` nodes, mean connectivity `k` and rewiring probability `β`.
"""	
function WattsStrogatzNetwork(
	N::Integer,
	k::Integer,
	β::Real;
	directed::Bool=false,
	seed::Integer=-1
)
	(N <= 0) && throw(ArgumentError("Number of nodes must be a positive integer!"))
	
	mat = nothing
	numShortcuts = nothing
	(k % 2 == 1) && (k -= 1)
	
	# Deal with special cases
	if k < 0
		k = 0
		mat = adjMat(EmptyNetwork(N), sparse=true)
		numShortcuts = 0
		β = nothing
	elseif k >= N-1
		k = N-1
		mat = adjMat(GlobalNetwork(N))
		numShortcuts = 0
		β = nothing
	else
		(β < 0) && (β = 0.0)
		(β > 1) && (β = 1.0)
	end
	
	numConnections = k * N
	directed || (numConnections /= 2)
	_seed = seed < 0 ? rand(1:999999999) : seed
	isnothing(mat) && ((mat, numShortcuts) = generateWSAdjMat(N, k, β; directed, seed=_seed))
	
	WattsStrogatzNetwork(N, k, β, Int(numConnections), numShortcuts, directed, _seed, mat)
end

"""
	WattsStrogatzNetwork(N, k, numShortcuts; directed=false, seed=-1)

Create an Watts-Strogatz network with `N` nodes, mean connectivity `k` and `numShortcuts` rewired
shortcuts.
"""
function WattsStrogatzNetwork(
	N::Integer,
	k::Integer,
	numShortcuts::Integer;
	directed::Bool=false,
	seed::Integer=-1
)
	(N <= 0) && throw(ArgumentError("Number of nodes must be a positive integer!"))
	
	mat = nothing
	(k % 2 == 1) && (k -= 1)
	
	# Deal with special cases
	if k < 0
		k = 0
		mat = adjMat(EmptyNetwork(N))
		numShortcuts = 0
	elseif k >= N-1
		k = N-1
		mat = adjMat(GlobalNetwork(N))
		numShortcuts = 0
	else
		numConnections = k * N
		directed || (numConnections = Int(numConnections / 2))
		(numShortcuts < 0) && (numShortcuts = 0)
		(numShortcuts > numConnections) && (numShortcuts = numConnections)
	end

	numConnections = k * N
	directed || (numConnections = Int(numConnections / 2))

	_seed = seed < 0 ? rand(1:999999999) : seed
	isnothing(mat) && (mat = generateWSAdjMat(N, k, numShortcuts; directed, seed=_seed))
	
	WattsStrogatzNetwork(N, k, nothing, numConnections, numShortcuts, directed, _seed, mat)
end



function generateWSAdjMat(
	N::Integer,
	k::Integer,
	β::Real;
	directed::Bool,
	seed::Integer
)
	mat = adjMat(RegularNetwork(N, k), sparse=true)
	(β <= 0) && (return mat, 0)
	
	numShortcuts = 0
	rng = Random.MersenneTwister(seed)
	
	# All existing connections
	edges = directed ?
		[(i,j) for i in 1:N for j in 1:N   if mat[i,j]] :
		[(i,j) for i in 1:N for j in i+1:N if mat[i,j]]
	
	for edge in edges
		if rand(rng) < β
			# Find a valid reconnection
		    i = rand(rng, 1:N); j = rand(rng, 1:N)
			while mat[i,j] || i == j
				i = rand(rng, 1:N)
		    	j = rand(rng, 1:N)
			end
			
			mat[i,j] = 1
			mat[edge[1], edge[2]] = 0
			
			if !directed
				mat[j,i] = 1
				mat[edge[2], edge[1]] = 0
			end
			
			numShortcuts += 1
		end
	end
	
	return SparseArrays.dropzeros(mat), numShortcuts
end

function generateWSAdjMat(
	N::Integer,
	k::Integer,
	numShortcuts::Integer;
	directed::Bool,
	seed::Integer
)
	mat = adjMat(RegularNetwork(N, k), sparse=true)
	(numShortcuts <= 0) && (return mat)
	
	rng = Random.MersenneTwister(seed)
	
	# All existing connections
	edges = directed ?
		[(i,j) for i in 1:N for j in 1:N   if mat[i,j]] :
		[(i,j) for i in 1:N for j in i+1:N if mat[i,j]]
	
	# Connections that will be rewired
	rewiredEdges = Array{Tuple{Int,Int}}(undef, numShortcuts)
	for i in 1:numShortcuts
		rewiredEdges[i] = rand(rng, edges)
		edges = filter(x -> x != rewiredEdges[i], edges)
	end
	
	for edge in rewiredEdges
		# Find a valid reconnection
	    i = rand(rng, 1:N); j = rand(rng, 1:N)
		while mat[i,j] || i == j
			i = rand(rng, 1:N)
	    	j = rand(rng, 1:N)
		end
		
		mat[i,j] = 1
		mat[edge[1], edge[2]] = 0
		
		if !directed
			mat[j,i] = 1
			mat[edge[2], edge[1]] = 0
		end
	end	
	
	return SparseArrays.dropzeros(mat)
end

function show(network::WattsStrogatzNetwork)
	println("Watts-Strogatz Network")
	println("- N = $(network.N)")
	println("- k = $(network.k)")
	println("- β = $(network.β)")
	println("- numConnections = $(network.numConnections)")
	println("- numShortcuts = $(network.numShortcuts)")
	println("- directed = $(network.directed)")
	println("- seed = $(network.seed)")
end

display(network::WattsStrogatzNetwork) = show(network)