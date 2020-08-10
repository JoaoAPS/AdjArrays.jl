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
"""
function connectivity(
		network::AbstractNetwork,
		idx_node::Integer;
		degree::Union{Symbol, String}=:total
	)
	hasnodeOrError(network, idx_node)
	
	degree = Symbol(degree)
	if isdirected(network) && ! (degree in [:total, :in, :out, :mean, :both, :bi])
		throw(ArgumentError(
			"degree parameter must be one of the follwing: :total, :in, :out, :mean, :both, :bi"
		))
	end
	
	return calcConnectivity(network, idx_node; degree)
end

"""
	connectivities(network::AbstractNetwork; degree::Symbol=:total)

Return the connectivities of the all node of the network.

If the network is directed, the `degree` parameter controls which connectivity is returned,
`:in` for in-degree, `out` for out-degree, `:total` for the sum of in- and out-degree,
`:mean` for the mean of in- and out-degree, `:both` for both in- and out-degree, and
`:bi` for the number of neighbors for which both in and out connections are present.

See also: `connectivity`
"""
connectivities(network::AbstractNetwork; degree::Symbol=:total) = 
	[connectivity(network, i; degree) for i in 1:network.N]

"""
	connectivity(network::AbstractNetwork)

Return the mean connectivity of the network.

If the network is directed, the `degree` parameter controls which connectivity is returned,
`:in` for in-degree, `out` for out-degree, `:total` for the sum of in- and out-degree,
`:mean` for the mean of in- and out-degree, `:both` for both in- and out-degree, and
`:bi` for the number of neighbors for which both in and out connections are present.

See also: `connectivities`
"""
function connectivity(network::AbstractNetwork; degree::Symbol=:total)
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

"""
	transitivity(network::AbstractNetwork)

Return the transitivity of the network.
"""
function transitivity(network::AbstractNetwork)
	if isdirected(network)
		println("Transitivity not supported for directed networks")
		return
	end
	
	isnothing(network._props.transitivity) && calcTransitivity!(network)
	return network._props.transitivity
end


"""
	shortestpath(network::AbstractNetwork, source::Integer,	target::Integer=nothing)

Return the length of the shortest paths from the source node the every other node.
If `target` is specified, only the path from the source to the target is returned.
"""
function shortestpath(
	network::AbstractNetwork,
	source::Integer,
	target::Union{Integer, Nothing}=nothing
)
	hasnodeOrError(network, source)
	isnothing(target) || hasnodeOrError(network, target)
	
	isnothing(network._props.shortestPaths[source]) && calcShortestPath!(network, source)
	return isnothing(target) ?
		network._props.shortestPaths[source] :
		network._props.shortestPaths[source][target]
end

"""
	shortestpath(network::AbstractNetwork)

Return the average shortest path length of the network.
"""
function shortestpath(network::AbstractNetwork)
	totalLength = 0
	
	for i in 1:network.N
		pathLenghts = shortestpath(network, i)
		for j in 1:network.N
			((i == j) || isinf(pathLenghts[j])) && continue
			totalLength += pathLenghts[j]
		end
	end
	
	return totalLength / (network.N * (network.N - 1))
end

"""
	averagepathlength(network::AbstractNetwork)

Return the average shortest path length of the network.
"""
averagepathlength(network::AbstractNetwork) = shortestpath(network)


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
	(degree == :bi)    &&
		(return sum(Bool.(mat[idx_node, :]) .& Bool.(mat[:, idx_node])))
end

calcMeanConnectivity!(network::AbstractNetwork) =
	network._props.meanConnectivity = sum(connectivities(network)) / network.N

function calcAdjMat!(network::AbstractNetwork)
	error("No adjacency matrix calculators were found for a network of type $(typeof(network))")
end

function calcClusteringCoefficient(network::AbstractNetwork, idx_node::Integer)
	# As in DOI: 10.1103/PhysRevE.76.026107
	if isdirected(network)
		nb = neighbors(network, idx_node; directed_behaviour=:any)
		totalDegree = connectivity(network, idx_node, degree=:total)
		biDegree = connectivity(network, idx_node, degree=:bi)
		
		numPossibleTriangles = totalDegree * (totalDegree - 1) - 2 * biDegree
		numExistingTriangles = 0		
		
		for n1 in nb, n2 in nb
			(n1 == n2) && continue
			
			hasconnection(network, idx_node, n1) && hasconnection(network, n1, n2) &&
				hasconnection(network, n2, idx_node) && (numExistingTriangles += 1)
			
			hasconnection(network, idx_node, n1) && hasconnection(network, n1, n2) &&
				hasconnection(network, idx_node, n2) && (numExistingTriangles += 1)
			
			hasconnection(network, idx_node, n1) && hasconnection(network, n2, n1) &&
				hasconnection(network, n2, idx_node) && (numExistingTriangles += 1)
						
			hasconnection(network, n1, idx_node) && hasconnection(network, n1, n2) &&
				hasconnection(network, n2, idx_node) && (numExistingTriangles += 1)
		end
	else
		nb = neighbors(network, idx_node)
		numNeighbors = length(nb)
		
		numPossibleTriangles = numNeighbors * (numNeighbors - 1) / 2
		numExistingTriangles = 0
		
		for i in 1:numNeighbors for j in i+1:numNeighbors
			hasconnection(network, nb[i], nb[j]) && (numExistingTriangles += 1)
		end end
	end
	
	return numExistingTriangles == 0 ? 0 : numExistingTriangles / numPossibleTriangles
end

function calcClusteringCoefficients!(network::AbstractNetwork)
	network._props.clusteringCoefficients =
		[calcClusteringCoefficient(network, i) for i in 1:network.N]
end

function calcTransitivity!(network::AbstractNetwork)
	numExistingTriangles = 0
	numPossibleTriangles = 0

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

function calcShortestPath!(
	network::AbstractNetwork,
	source::Integer,
	target::Union{Integer,Nothing}=nothing
)
	hasnodeOrError(network, source)
	isnothing(target) || hasnodeOrError(network, target)
		
	network._props.shortestPaths[source] = dijkstra(network, source, target)
end

function dijkstra(
	network::AbstractNetwork,
	source::Integer,
	target::Union{Integer,Nothing}=nothing
)
	unvisited = Vector(1:network.N)
	distance = repeat([Inf], network.N)
	distance[source] = 0
	
	while !isempty(unvisited) && !all(x -> isinf(x), unvisited)
		currentNode = unvisited[ findmin(distance[unvisited])[2] ]
		unvisited = filter(x -> x != currentNode, unvisited)
		
		if !isnothing(target) && currentNode == target
			return distance[currentNode]
		end
		
		for nb in neighbors(network, currentNode, directed_behaviour=:destination)
			testVal = distance[currentNode] + 1
			(testVal < distance[nb]) && (distance[nb] = testVal)
		end
	end
	
	return distance
end