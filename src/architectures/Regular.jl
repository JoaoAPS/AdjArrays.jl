struct RegularNetwork
	N :: Integer
	k :: Integer
	numConnections :: Integer
	directed :: Bool
	
	"""
		RegularNetwork(N, k; directed=false)
	
	Creates a regular network with `N` nodes and connectivity `k`.
	"""
	function RegularNetwork(N::Integer, k::Integer; directed::Bool=false)
		(N <= 0) && throw(ArgumentError("Number of nodes must be a positive integer!"))
		(k <= 0) && throw(ArgumentError("Initial connectivity must be a positive integer!"))
		(k >= N) && throw(ArgumentError("Initial connectivity must be less than N!"))
		directed || (k % 2 != 0) &&
			throw(ArgumentError("Initial connectivity must be even for a undirected network!"))
		
		numConnections = directed ? k * N : Int(k * N / 2)
		new(N, k, numConnections, directed)
	end
end


function i_plus_x(i, x, N)
	i = (i+N+x) % N;
	(i == 0) && (i = N)
	return i
end
	
function adjMat(network::RegularNetwork)
	mat = BitArray(0 for i in 1:network.N, j in 1:network.N)
	
	for i in 1:network.N
		# Add symmetric connections
		c = 1
		while 2c <= network.k
			mat[i, i_plus_x(i, c, network.N)] = 1
			mat[i, i_plus_x(i,-c, network.N)] = 1
			c += 1
		end
		
		# Add extra connection if k in odd
		(network.k == 2c - 1) && (adjMat[i, i_plus_x(i, c, network.N)] = 1)
	end

	return mat
end

function adjVet(network::RegularNetwork)
	vetLength = (network.directed ? 1 : 2) * network.numConnections
	halfk = Int(floor(network.k/2))
	idxVet = 1

	vet = zeros(Int, vetLength)
	neighbors = zeros(Int, network.k)

	for i in 1:network.N
		# Records symmetric neighbors of node i
		c = 1
		while 2c <= network.k
			neighbors[c]         = i_plus_x(i, c, network.N) - 1
			neighbors[c + halfk] = i_plus_x(i,-c, network.N) - 1
			c += 1
		end

		# Add extra connection if k in odd
		(network.k == 2c - 1) && (neighbors[end] = i_plus_x(i, c, network.N) - 1)
		
		# Write connections of i on the vet
		sort!(neighbors)
		for j in neighbors
			vet[idxVet] = (i-1)*network.N + j
			idxVet += 1
		end
	end

	return vet
end