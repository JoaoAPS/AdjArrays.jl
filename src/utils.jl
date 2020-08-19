function i_plus_x(i, x, N)
	i = (i+N+x) % N
	(i == 0) && (i = N)
	return i
end

function mean(vet::AbstractVector)
	(length(vet) == 0) && (return 0)
	return sum(vet) / length(vet)
end

function issymmetric(mat::AbstractMatrix)
	(size(mat, 1) != size(mat, 2)) && (return false)
	for i in 1:size(mat, 1), j in i+1:size(mat, 2)
		(mat[i,j] != mat[j,i]) && (return false)
	end
	return true
end

function hasnodeOrError(network::AbstractNetwork, idx_node::Integer)
	hasnode(network, idx_node) ||
		throw(ArgumentError("Invalid node index! Node $idx_node doesn't exist in the network!"))
end