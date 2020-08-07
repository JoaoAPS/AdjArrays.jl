"""
	RegularNetwork <: AbstractNetwork

A regular (ring) network.

# Fields
- N              :: Integer -> Number of nodes
- k              :: Integer -> Node connectivity
- numConnections :: Integer -> Number of connections
- directed       :: Bool    -> Wheter the network is directed or not
"""
mutable struct RegularNetwork <: AbstractNetwork
	N :: Integer
	k :: Integer
	numConnections :: Integer
	directed :: Bool
	
	_adjMat :: Union{AbstractMatrix, Nothing}
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
	
	numConnections = k * N
	directed || (numConnections = Int(numConnections / 2))
	
	RegularNetwork(N, k, numConnections, directed, nothing)
end

	
function calcAdjMat!(network::RegularNetwork)
	if network.k >= network.N-1
		network._adjMat = adjMat(GlobalNetwork(network.N))
		return
	end
	
	network._adjMat = adjMat(EmptyNetwork(network.N), sparse=true)
	(network.k <= 0) && (return)
	
	for i in 1:network.N
		c = 1
		while c <= floor(Int, network.k / 2)
			network._adjMat[i, i_plus_x(i,  c, network.N)] = 1
			network._adjMat[i, i_plus_x(i, -c, network.N)] = 1
			c += 1
		end
	end
end


function show(network::RegularNetwork)
	println("Regular network")
	println("- N = $(network.N)")
	println("- k = $(network.k)")
end
