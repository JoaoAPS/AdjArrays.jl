
mutable struct RegularNetwork <: AbstractNetwork
	N :: Integer
	k :: Integer
	numConnections :: Integer
	
	_adjMat :: Union{AbstractMatrix, Nothing}
	
	"""
		RegularNetwork(N, k; directed=false)
	
	Creates a regular network with `N` nodes and connectivity `k`.
	"""
	function RegularNetwork(N::Integer, k::Integer; directed::Bool=false)
		(N <= 0) && throw(ArgumentError("Number of nodes must be a positive integer!"))
		(k <= 0) && throw(ArgumentError("Nodes connectivity must be a positive integer!"))
		(k >= N) && throw(ArgumentError("Nodes connectivity must be less than N!"))
		
		# No odd connectivity allowed
		(k % 2 == 1) && (k -= 1)
		
		return new(N, k, Int(k * N / 2), nothing)
	end
end

display(network::RegularNetwork) = "Regular network - N=$(network.N); k=$(network.k)"
	
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
