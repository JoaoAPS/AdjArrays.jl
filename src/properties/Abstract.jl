"""
	numnodes(network::AbstractNetwork)

Return the number of nodes on the network.
"""
numnodes(network::AbstractNetwork) = network.N

"""
	numconnections(network::AbstractNetwork)

Return the number of connections present on the network.
"""
function numconnections(network::AbstractNetwork)
	isnothing(network._props.numConnections) && calcNumConnections!(network)
	return network._props.numConnections
end

"""
	maxconnections(network::AbstractNetwork)

Return the maximum amount of connections the network can support.
"""
maxconnections(network::AbstractNetwork) = 
	Int(network.N * (network.N - 1) / (isdirected(network) ? 1 : 2))

"""
	isdirected(network::AbstractNetwork)

Return wheter or not the network is directed.
"""
isdirected(network::AbstractNetwork) = network._props.directed

"""
	meanconnectivity(network::AbstractNetwork)

Return the mean connectivity of the network.
"""
function meanconnectivity(network::AbstractNetwork)
	isnothing(network._props.meanConnectivity) && calcMeanConnectivity!(network)
	return network._props.meanConnectivity
end



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




# ---------- Calculators ----------
function calcNumConnections!(network::AbstractNetwork)
	network._props.numConnections =
		Int( sum(adjMat(network, sparse=true)) / (isdirected(network) ? 1 : 2) )
end


function calcMeanConnectivity!(network::AbstractNetwork)
	network._props.meanConnectivity = sum(adjMat(network, sparse=true)) / network.N
end

"""
	calcAdjMat!(network::AbstractNetwork)

Calculate the adjacency matrix of a network, and stores it on the object.

To get the adjacency matrix use the function `adjMat`
"""
function calcAdjMat!(network::AbstractNetwork)
	error("No adjacency matrix calculators were found for a network of type $(typeof(network))")
end