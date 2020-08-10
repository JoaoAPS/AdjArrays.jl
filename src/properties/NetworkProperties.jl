mutable struct NetworkProperties
	directed :: Bool
	numConnections :: Union{Int, Nothing}
	meanConnectivity :: Union{Real, Nothing}
	
	clusteringCoefficients :: Union{Vector{<:Real}, Nothing}
	transitivity :: Union{Real, Nothing}
	shortestPaths :: Vector{Union{Vector{<:Real}, Nothing}}
end

NetworkProperties(N::Integer, directed::Bool) = NetworkProperties(
	directed,
	nothing,
	nothing,
	nothing,
	nothing,
	repeat([nothing], N)
)

NetworkProperties(N::Integer, directed::Bool, numConnections::Integer) = NetworkProperties(
	directed,
	numConnections,
	nothing,
	nothing,
	nothing,
	repeat([nothing], N)
)