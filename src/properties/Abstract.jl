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

Return whether or not the network is directed.
"""
isdirected(network::AbstractNetwork) = network._props.directed


"""
	connectivity(network::AbstractNetwork, idx_node::Integer; degree::Symbol=:total)

Return the connectivity of the specified node.
If the network is directed, the `degree` parameter controls which connectivity is returned,
`:in` for in-degree, `out` for out-degree, `:total` for the sum of in- and out-degree,
`:mean` for the mean of in- and out-degree, and `:both` for both in- and out-degree.

See also: `connectivities`, `meanconnectivity`
"""
function connectivity(
		network::AbstractNetwork,
		idx_node::Integer;
		degree::Union{Symbol, String}=:total
	)
	hasnodeOrError(network, idx_node)
	
	degree = Symbol(degree)
	if isdirected(network) && ! (degree in [:total, :in, :out, :mean, :both])
		throw(ArgumentError(
			"degree parameter must be one of the follwing: :total, :in, :out, :mean, :both"
		))
	end
	
	return calcConnectivity(network, idx_node; degree)
end

"""
	connectivities(network::AbstractNetwork; degree::Symbol=:total)

Return the connectivities of the all node of the network.

If the network is directed, the `degree` parameter controls which connectivity is returned,
`:in` for in-degree, `out` for out-degree, `:total` for the sum of in- and out-degree,
`:mean` for the mean of in- and out-degree, and `:both` for both in- and out-degree.

See also: `connectivity`, `meanconnectivity`
"""
connectivities(network::AbstractNetwork; degree::Symbol=:total) = 
	[connectivity(network, i; degree) for i in 1:network.N]

"""
	meanconnectivity(network::AbstractNetwork)

Return the mean connectivity of the network.

If the network is directed, the `degree` parameter controls which connectivity is returned,
`:in` for in-degree, `out` for out-degree, `:total` for the sum of in- and out-degree,
`:mean` for the mean of in- and out-degree, and `:both` for both in- and out-degree.


See also: `connectivity`, `connectivities`
"""
function meanconnectivity(network::AbstractNetwork; degree::Symbol=:total)
	isnothing(network._props.meanConnectivity) && calcMeanConnectivity!(network)
	return network._props.meanConnectivity
end


"""
	clusteringcoefficient(network::AbstractNetwork, idx_node::Integer)

Return the clustering coefficient of the specified node.
"""
function clusteringcoefficient(network::AbstractNetwork, idx_node::Integer)
	hasnodeOrError(network, idx_node)

	return isnothing(network._props.clusteringCoefficients) ?
		calcClusteringCoefficient(network, idx_node) :
		network._props.clusteringCoefficients[idx_node]
end

"""
	clusteringcoefficient(network::AbstractNetwork)

Return the average clustering coefficient of the network.

See also: `clusteringcoefficients`
"""
function clusteringcoefficient(network::AbstractNetwork)
	isnothing(network._props.clusteringCoefficients) && calcClusteringCoefficients!(network)
	return mean(network._props.clusteringCoefficients)
end

"""
	clusteringcoefficients(network::AbstractNetwork)

Return the clustering coefficients of all nodes of the network.

See also: `clusteringcoefficient`
"""
function clusteringcoefficients(network::AbstractNetwork)
	isnothing(network._props.clusteringCoefficients) && calcClusteringCoefficients!(network)
	return network._props.clusteringCoefficients
end

function transitivity(network::AbstractNetwork)
	if isdirected(network)
		println("Transitivity not supported for directed networks")
		return
	end
	
	isnothing(network._props.transitivity) && calcTransitivity!(network)
	return network._props.transitivity
end

"""
	adjMat(network::AbstractNetwork, sparse::Bool=false)

Return the adjacency matrix of the network.
If `sparse` is true, return a sparse version of the matrix.

See also: `adjVet`
"""
function adjMat(network::AbstractNetwork; sparse::Bool=false)
	isnothing(network._adjMat) && calcAdjMat!(network)
	return sparse ? network._adjMat : BitArray(network._adjMat)
end

"""
	adjVet(network::AbstractNetwork)

Return the adjacency vector of the network

See also: `adjMat`
"""
function adjVet(network::AbstractNetwork)
	isnothing(network._adjMat) && calcAdjMat!(network)
	return adjMatToVet(network._adjMat)
end




#---------- Calculators ----------
function calcNumConnections!(network::AbstractNetwork)
	network._props.numConnections =
		Int( sum(adjMat(network, sparse=true)) / (isdirected(network) ? 1 : 2) )
end

function calcConnectivity(network::AbstractNetwork, idx_node::Integer; degree::Symbol)
	isdirected(network) || (return sum(adjMat(network, sparse=true)[:,idx_node]))
	
	mat = adjMat(network, sparse=true)
	inDegree = sum(mat[idx_node,:])
	outDegree = sum(mat[:,idx_node])
	
	(degree == :total) && (return inDegree + outDegree)
	(degree == :in)    && (return inDegree)
	(degree == :out)   && (return outDegree)
	(degree == :mean)  && (return (inDegree + outDegree) / 2)
	(degree == :both)  && (return (inDegree, outDegree))
end

function calcMeanConnectivity!(network::AbstractNetwork)
	network._props.meanConnectivity = sum(adjMat(network, sparse=true)) / network.N
end

function calcAdjMat!(network::AbstractNetwork)
	error("No adjacency matrix calculators were found for a network of type $(typeof(network))")
end


function calcClusteringCoefficient(network::AbstractNetwork, idx_node::Integer)
	if isdirected(network)
		println("Clustering Coefficient not supported for directed networks")
		return
	end

	nb = neighbors(network, idx_node)
	numNeighbors = length(nb)
	
	numPossibleTriangles = Int(numNeighbors * (numNeighbors - 1) / 2)
	numExistingTriangles = 0
	
	for i in 1:numNeighbors for j in i+1:numNeighbors
		hasconnection(network, nb[i], nb[j]) && (numExistingTriangles += 1)
	end end
	
	return numExistingTriangles == 0 ? 0 : numExistingTriangles / numPossibleTriangles
end

function calcClusteringCoefficients!(network::AbstractNetwork)
	if isdirected(network)
		println("Clustering Coefficient not supported for directed networks")
		return
	end

	network._props.clusteringCoefficients =
		[calcClusteringCoefficient(network, i) for i in 1:network.N]
end

function calcTransitivity!(network::AbstractNetwork)
	numExistingTriangles = 0
	numPossibleTriangles = 0 #Int(numNeighbors * (numNeighbors - 1) / 2)

	for idx_node in 1:network.N
		nb = neighbors(network, idx_node)
		numNeighbors = length(nb)
		
		numPossibleTriangles += numNeighbors * (numNeighbors - 1) / 2
		
		for i in 1:numNeighbors for j in i+1:numNeighbors
			hasconnection(network, nb[i], nb[j]) && (numExistingTriangles += 1)
		end end
	end
	
	network._props.transitivity =
		numExistingTriangles == 0 ? 0 : numExistingTriangles / numPossibleTriangles	
end