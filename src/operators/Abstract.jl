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
	adjVetToMat(vet::Vector, N::Integer)

Calculate the adjacency matrix based on the adjacency vector.
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