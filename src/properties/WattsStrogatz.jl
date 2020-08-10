connectivity(network::WattsStrogatzNetwork) = network.k

"""
	numshortcuts(network::WattsStrogatzNetwork)

Return the number of connections that were rewired.
"""
numshortcuts(network::WattsStrogatzNetwork) = network._numShortcuts
		
	

#---------- Calculators ----------
calcNumConnections!(network::WattsStrogatzNetwork) =
	network._props.numConnections = Int(network.k * network.N / (isdirected(network) ? 1 : 2))

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
	edges = allEdges(mat, directed)
	
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
	edges = allEdges(mat, directed)
	
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
