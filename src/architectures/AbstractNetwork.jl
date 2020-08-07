abstract type AbstractNetwork end

"""
	adjMat(network::AbstractNetwork, sparse::Bool=false)

Return the adjacency matrix of the network.
If `sparse` is true, return a sparse version of the matrix.
"""
function adjMat(network::AbstractNetwork; sparse::Bool=false)
	isnothing(network._adjMat) && calcAdjMat!(network)
	return sparse ? network._adjMat : BitArray(network._adjMat)
end

"""
	adjVet(network::AbstractNetwork)

Return the adjacency vector of the network
"""
function adjVet(network::AbstractNetwork)
	isnothing(network._adjMat) && calcAdjMat!(network)
	return adjMatToVet(network._adjMat)
end

"""
	calcAdjMat!(network::AbstractNetwork)

Calculate the adjacency matrix of a network, and stores it on the object.

To get the adjacency matrix use the function `adjMat`
"""
function calcAdjMat!(network::AbstractNetwork)
	error("No adjacency matrix calculators were found for a network of type $(typeof(network))")
end


show(network::AbstractNetwork) = println("Network\n- N = $(network.N)")
display(network::AbstractNetwork) = show(network)
