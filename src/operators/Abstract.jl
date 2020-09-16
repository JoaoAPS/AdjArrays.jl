"""
	hasnode(network::AbstractNetwork, idx::Integer)

Check whether the node exists in the network
"""
hasnode(network::AbstractNetwork, idx::Integer) = (0 < idx <= network.N)

"""
	hasconnection(network::AbstractNetwork, idx_origin::Integer, idx_dest::Integer)

Check whether there exists a connections from node `idx_origin` to `idx_dest`
"""
hasconnection(network::AbstractNetwork, idx_origin::Integer, idx_dest::Integer) =
	Bool(adjMat(network, sparse=true)[idx_dest, idx_origin])

"""
	allEdges(network::AbstractNetwork; first_index::Integer=1)
	allEdges(adjacencyMatrix::AbstractMatrix, directed::Bool; first_index::Integer=1)

Return an array with all existing connections as a tuple (origin,destination).

# Arguments
- idx_origin: Which of 0 or 1 should be used as the first index.
- both_directions: (undirected only) if true will return both directions of an undirected
connections. i.e.: i -> j and j -> i.
"""
function allEdges(mat::AbstractMatrix, directed::Bool; first_index::Integer=1, both_directions::Bool=false)
	(first_index in [1,0]) || throw(ArgumentError("first_index must be 0 or 1"))
	@assert size(mat, 1) == size(mat, 2)
	
	N = size(mat, 1)
	
	if directed || both_directions
		edges = [(i,j) for i in 1:N for j in 1:N if mat[j,i] != 0]
	else
		edges = [(i,j) for i in 1:N for j in i+1:N if mat[j,i] != 0]
	end
	
	(first_index == 0) && (edges = [(e[1]-1, e[2]-1) for e in edges])
	return edges
end

allEdges(network::AbstractNetwork; first_index::Integer=1, both_directions::Bool=false) =
	allEdges(adjMat(network, sparse=true), isdirected(network); first_index=first_index, both_directions=both_directions)


"""
	neighbors(network::AbstractNetwork, idx_node::Integer; directed_behaviour::Symbol=:any)

Return a vector with the indices of the neighbors of the passed node.

If the network is directed the `directed_behaviour` can be used to specify
the considered neighbors.
`:origin` for nodes whose connections arive at the selected node,
`:destination` for nodes in which connections from the selected node arive,
and `:any` for the union of both previous groups.
"""
function neighbors(network::AbstractNetwork, idx_node::Integer; directed_behaviour::Symbol=:any)
	hasnodeOrError(network, idx_node)
	mat = adjMat(network, sparse=true)
	
	if isdirected(network)
		(directed_behaviour in [:origin, :destination, :any]) ||
			throw(ArgumentError("directed_behaviour must be one of: :origin, :destination, :any"))
		
		(directed_behaviour == :origin) && (return [i for i in 1:network.N if mat[idx_node, i] != 0])
		(directed_behaviour == :destination) && (return [i for i in 1:network.N if mat[i, idx_node] != 0])
		(directed_behaviour == :any) &&
			(return [i for i in 1:network.N if mat[i, idx_node] != 0 || mat[idx_node, i] != 0])
	else
		return [i for i in 1:network.N if mat[i, idx_node] != 0]
	end
end
		


"""
	adjVetToMat(vet::Vector, N::Integer)

Calculate the adjacency matrix based on the adjacency vector.

See also: `adjMatToVet`
"""
function adjVetToMat(vet::Vector{<:Integer}, N::Integer; sparse::Bool=false)
	mat = sparse ? SparseArrays.spzeros(Int, N, N) : BitArray(0 for i in 1:N, j in 1:N)

	let i = 0
		for idx in vet
			j = idx - i*N

			while j >= N
				i += 1
				j -= N
			end

			mat[i+1, j+1] = 1
		end
	end

	return mat
end


"""
	adjMatToVet(mat::AbstractMatrix)

Calculate the adjacency vector based on the adjacency matrix.

See also: `adjVetToMat`
"""
function adjMatToVet(mat::SparseArrays.AbstractSparseMatrix)
	vet = Array{Int}(undef, length(mat.rowval))
	idx_vet = 1
	colptr = mat.colptr
	rowval = mat.rowval
	
	for idx_col in eachindex(mat.colptr[1:end-1])
		idxs_row = @view rowval[colptr[idx_col] : colptr[idx_col+1]-1]
		
		for idx_row in idxs_row
			vet[idx_vet] = (idx_row-1) * size(mat,1) + (idx_col-1)
			idx_vet += 1
		end
	end
	
	return sort(vet)
end

function adjMatToVet(mat::BitArray{2})
	@assert size(mat,1) == size(mat,2)
	
	N = size(mat)[1]
	vetPos = 1
	vet = Vector{Int}(undef, sum(mat))

	for i in 1:N, j in 1:N
		if mat[i,j] != 0
			vet[vetPos] = (i-1)*N + (j-1)
			vetPos += 1
		end
	end

	return vet
end

adjMatToVet(mat::Array{Bool,2}) = adjMatToVet(BitArray(mat))
function adjMatToVet(mat::AbstractArray{<:Real,2})
	try
		BitArray(mat)
	catch e
		throw(ArgumentError("Matrix must be composed only of ones and zeros!"))
	end
	
	return adjMatToVet(BitArray(mat))
end


"""
	equivalentRandomNetwork(network::AbstractNetwork; seed, numReshuffle, maxTentatives)

Return a random network with the same degree distribution of the original.

# Keyworkd Arguments
- seed (Integer, default=-1): Seed for random creation
- numReshuffle (Integer, default=10): Number of reshuffling cycles.
Each cycle makes `numconnections(network)` rewires.
- maxTentatives (Integer, default=numconnections(network) * numReshuffle * 300) :
Maximum number of rewiring tentatives before ending the algorithm.
"""
function equivalentRandomNetwork(
	network::AbstractNetwork;
	seed::Integer = -1,
	numReshuffle::Integer = 10,
	maxTentatives::Integer = (numconnections(network) * numReshuffle * 300)
)
	(seed < 0) && (seed = rand(1:99999999))
	rng = Random.MersenneTwister(seed)
	numShuffle = numReshuffle * numconnections(network)
	
	edges = allEdges(network, both_directions=true)
	mat = adjMat(network, sparse=true)
	
	numRewires = 0
	numTentatives = 0
	
	while numRewires < numShuffle && numTentatives < maxTentatives
		numTentatives += 1
		
		# Choose random pair of edges
		edge1 = rand(rng, edges)
		edge2 = rand(rng, edges)
		while edge1 == edge2 || edge1[1] == edge2[2] || edge2[1] == edge1[2]
			edge2 = rand(rng, edges)
		end
		
		# Check if the rewiring is valid
		((edge1[1], edge2[2]) in edges) && continue
		((edge2[1], edge1[2]) in edges) && continue
		
		# Rewire
		mat[edge1[2], edge1[1]] = 0
		mat[edge2[2], edge2[1]] = 0
		mat[edge1[2], edge2[1]] = 1
		mat[edge2[2], edge1[1]] = 1
		
		edges = filter(x -> x != edge1 && x != edge2, edges)
		edges = vcat(edges, [(edge1[1], edge2[2]), (edge2[1], edge1[2])])
		
		numRewires += 1
	end
	
	return isa(mat, SparseArrays.AbstractSparseMatrix) ?
		CustomNetwork(SparseArrays.dropzeros(mat), directed=true) :
		CustomNetwork(mat, directed=true)
end

"""
	equivalentLatticeNetwork(network::AbstractNetwork; seed, numReshuffle, maxTentatives)

Return a network with the same degree distribution of the original but with higher 
clustering coefficient and connections closer to the diagonal.

# Keyworkd Arguments
- seed (Integer, default=-1): Seed for random creation
- numReshuffle (Integer, default=10): Number of reshuffling cycles.
Each cycle makes `numconnections(network)` rewires.
- maxTentatives (Integer, default=numconnections(network) * numReshuffle * 300) :
Maximum number of rewiring tentatives before ending the algorithm.
"""
function equivalentLatticeNetwork(
	network::AbstractNetwork;
	seed::Integer = -1,
	numReshuffle::Integer = 10,
	maxTentatives::Integer = (numconnections(network) * numReshuffle * 300)
)
	isregular(network) && (return network)
	
	function distToDiag(i::Int, j::Int)
		dist = abs(i - j)
		return min(dist, network.N - dist)
	end
	
	(seed < 0) && (seed = rand(1:99999999))
	rng = Random.MersenneTwister(seed)
	numShuffle = numReshuffle * numconnections(network)
	
	edges = allEdges(network, both_directions=true)
	mat = adjMat(network, sparse=true)
	newnet = CustomNetwork(mat)
	
	numTriedNets = 0
	
	while clusteringcoefficient(newnet) <= clusteringcoefficient(network) && numTriedNets < 10
		numRewires = 0
		numTentatives = 0
		numTriedNets += 1
		
		while numRewires < numShuffle && numTentatives < maxTentatives
			numTentatives += 1
			
			# Choose random pair of edges
			edge1 = rand(rng, edges)
			edge2 = rand(rng, edges)
			while edge1 == edge2 || edge1[1] == edge2[2] || edge2[1] == edge1[2]
				edge2 = rand(rng, edges)
			end
			
			# Check if the rewiring is valid
			((edge1[1], edge2[2]) in edges) && continue
			((edge2[1], edge1[2]) in edges) && continue
			
			# Check if the new matrix will be closer to diagonal
			dist_old = distToDiag(edge1[1], edge1[2]) + distToDiag(edge2[1], edge2[2])
			dist_new = distToDiag(edge1[1], edge2[2]) + distToDiag(edge2[1], edge1[2])
			(dist_new >= dist_old) && continue
			
			# Rewire
			mat[edge1[2], edge1[1]] = 0
			mat[edge2[2], edge2[1]] = 0
			mat[edge1[2], edge2[1]] = 1
			mat[edge2[2], edge1[1]] = 1
			
			edges = filter(x -> x != edge1 && x != edge2, edges)
			edges = vcat(edges, [(edge1[1], edge2[2]), (edge2[1], edge1[2])])
			
			numRewires += 1
		end
		
		newnet = isa(mat, SparseArrays.AbstractSparseMatrix) ?
			CustomNetwork(SparseArrays.dropzeros(mat), directed=true)
			CustomNetwork(mat, directed=true)
	end
	
	return newnet
end


"""
	saveAdjMat(network::AbstractNetwork, filepath::String)

Write the adjacency matrix of a network to the specified files.

See also: `saveAdjVet`
"""
saveAdjMat(network::AbstractNetwork, filepath::String) =
	DelimitedFiles.writedlm(filepath, Int.(adjMat(network)))

"""
	saveAdjVet(network::AbstractNetwork, filepath::String)

Write the adjacency vector of a network to the specified files.

See also: `saveAdjMat`
"""
saveAdjVet(network::AbstractNetwork, filepath::String) =
	DelimitedFiles.writedlm(filepath, adjVet(network))
