"""
	WattsStrogatzNetwork <: AbstractNetwork

A network contructed via the Watts-Strogatz method, possibly small-world.

# Fields
- N :: Integer -> Number of nodes
- k :: Integer -> Mean connectivity
- β :: Real -> Connection probability
- seed :: Integer -> Seed for the random creation
"""
mutable struct WattsStrogatzNetwork <: AbstractNetwork
	N :: Integer
	k :: Integer
	β :: Union{Real, Nothing}
	seed :: Integer
	
	_adjMat :: AbstractMatrix
	_props :: NetworkProperties
	_numShortcuts :: Integer
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
	
	_seed = seed < 0 ? rand(1:999999999) : seed
	isnothing(mat) && ((mat, numShortcuts) = generateWSAdjMat(N, k, β; directed=directed, seed=_seed))
	
	WattsStrogatzNetwork(N, k, β,_seed, mat, NetworkProperties(N, directed), numShortcuts)
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

	_seed = seed < 0 ? rand(1:999999999) : seed
	isnothing(mat) && (mat = generateWSAdjMat(N, k, numShortcuts; directed=directed, seed=_seed))
	
	WattsStrogatzNetwork(N, k, nothing, _seed, mat, NetworkProperties(N, directed), numShortcuts)
end


function show(network::WattsStrogatzNetwork)
	print(isdirected(network) ? "Directed " : "Undirected ")
	println("Watts-Strogatz Network")
	println("- N = $(network.N)")
	println("- k = $(network.k)")
	println("- β = $(network.β)")
	println("- seed = $(network.seed)")
end
