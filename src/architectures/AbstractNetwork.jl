abstract type AbstractNetwork end

display(network::AbstractNetwork) = "Network - N=$(network.N)"


"""
	adjMat(network::AbstractNetwork)

Returns the adjacency matrix of the network
"""
function adjMat(network::AbstractNetwork; sparse::Bool=false)
	isnothing(network._adjMat) && calcAdjMat!(network)
	return sparse ? network._adjMat : BitArray(network._adjMat)
end

"""
	adjVet(network::AbstractNetwork)

Returns the adjacency vector of the network
"""
function adjVet(network::AbstractNetwork)
	isnothing(network._adjMat) && calcAdjMat!(network)
	
	vet = Array{Int}(undef, length(network._adjMat.rowval))
	idx_vet = 1
	colptr = network._adjMat.colptr
	rowval = network._adjMat.rowval
	
	for idx_col in eachindex(network._adjMat.colptr[1:end-1])
		idxs_row = @view rowval[colptr[idx_col] : colptr[idx_col+1]-1]
		
		for idx_row in idxs_row
			vet[idx_vet] = (idx_row-1) * network.N + (idx_col-1)
			idx_vet += 1
		end
	end
	
	return sort(vet)
end

"""
	calcAdjMat!(network::AbstractNetwork)

Calculates the adjacency matrix of a network, and stores it on the object.

To get the adjacency matrix use the function `adjMat`
"""
function calcAdjMat!(network::AbstractNetwork)
	error("No adjacency matrix calculators were found for a network of type $(typeof(network))")
end