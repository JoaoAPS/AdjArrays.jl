"""
	CustomNetwork <: AbstractNetwork

A custom network created from an adjacency matrix ou vector.

# Fields
- N              :: Integer -> Number of nodes
"""
struct CustomNetwork <: AbstractNetwork
	N :: Integer
	
	seed :: Integer
	_adjMat :: AbstractMatrix
	_props :: NetworkProperties
end


"""
	CustomNetwork(adjMatrx::AbstractMatrix; directed=nothing)

Create a network with `N` nodes from the adjacency matrix.
"""
function CustomNetwork(mat::AbstractMatrix; directed::Union{Bool,Nothing}=nothing)
	(size(mat, 1) != size(mat, 2)) &&
		throw(ArgumentError("The adjacency matrix must be a square matrix!"))
	
	try
		BitArray(mat)
	catch
		throw(ArgumentError("Weighted matrices are not supported"))
	end
	
	if isnothing(directed)
		directed = !issymmetric(mat)
	else
		if !directed && !issymmetric(mat)
			throw(ArgumentError(
				"The adjacency matrix must be symmetric for a undirected network"
			))
		end
	end
	
	CustomNetwork(
		size(mat, 1),
		rand(1:99999999),
		SparseArrays.issparse(mat) ? copy(mat) : BitArray(mat),
		NetworkProperties(size(mat, 1), directed)
	)
end

"""
	CustomNetwork(adjVet::Vector{<:Integer}, N::Integer; directed=nothing)

Create a network with `N` nodes from the adjacency vector.

A keywork argument `directed` can be passed to ensure a (un)directed network.
If `nothing` this property will be derived from the network's symmetry.
"""
function CustomNetwork(vet::Vector{<:Integer}, N::Integer; directed::Union{Bool,Nothing}=nothing)
	(N <= 0) && throw(ArgumentError("Number of nodes must be a positive integer!"))
	CustomNetwork(adjVetToMat(vet, N, sparse=true))
end


function show(network::CustomNetwork)
	print(isdirected(network) ? "Directed " : "Undirected ")
	println("Custom Network")
	println("- N = $(network.N)")
end