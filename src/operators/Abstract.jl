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
"""
function allEdges(mat::AbstractMatrix, directed::Bool; first_index::Integer=1)
	(first_index in [1,0]) || throw(ArgumentError("first_index must be 0 or 1"))
	@assert size(mat, 1) == size(mat, 2)
	
	N = size(mat, 1)
	
	if directed
		edges = [(i,j) for i in 1:N for j in 1:N if mat[j,i]]
	else
		edges = [(i,j) for i in 1:N for j in i+1:N if mat[j,i]]
	end
	
	(first_index == 0) && (edges = [(e[1]-1, e[2]-1) for e in edges])
	return edges
end

allEdges(network::AbstractNetwork; first_index::Integer=1) =
	allEdges(adjMat(network, sparse=true), isdirected(network); first_index)


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
		
		(directed_behaviour == :origin) && (return [i for i in 1:network.N if mat[idx_node, i]])
		(directed_behaviour == :destination) && (return [i for i in 1:network.N if mat[i, idx_node]])
		(directed_behaviour == :any) &&
			(return [i for i in 1:network.N if mat[i, idx_node] || mat[idx_node, i]])
	else
		return [i for i in 1:network.N if mat[i, idx_node]]
	end
end
		


"""
	adjVetToMat(vet::Vector, N::Integer)

Calculate the adjacency matrix based on the adjacency vector.

See also: `adjMatToVet`
"""
function adjVetToMat(vet::Vector{<:Integer}, N::Integer)
	mat = BitArray(0 for i in 1:N, j in 1:N)

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







#------------- Utils -----------------
function hasnodeOrError(network::AbstractNetwork, idx_node::Integer)
	hasnode(network, idx_node) ||
		throw(ArgumentError("Invalid node index! Node $idx_node doesn't exist in the network!"))
end