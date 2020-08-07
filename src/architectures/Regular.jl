
mutable struct RegularNetwork <: AbstractNetwork
	N :: Integer
	k :: Integer
	numConnections :: Integer
	
	_adjMat :: Union{AbstractMatrix, Nothing}
	
	"""
		RegularNetwork(N, k)
	
	Creates a regular network with `N` nodes and node connectivity `k`.
	"""
	function RegularNetwork(N::Integer, k::Integer)
		(N <= 0) && throw(ArgumentError("Number of nodes must be a positive integer!"))
		
		(k % 2 == 1) && (k -= 1)
		(k < 0) && (k = 0)
		(k >= N) && (k = N)
		
		return new(N, k, Int(k * N / 2), nothing)
	end
end
	
function calcAdjMat!(network::RegularNetwork)
	network._adjMat = SparseArrays.spzeros(Bool, network.N, network.N)
	
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
