mutable struct NetworkProperties
	directed :: Bool
	numConnections :: Union{Int, Nothing}
	meanConnectivity :: Union{Real, Nothing}
	
	clusteringCoefficients :: Union{Vector{<:Real}, Nothing}
	transitivity :: Union{Real, Nothing}
	shortestPaths :: Vector{Union{Vector{<:Real}, Nothing}}
	
	σ :: Union{Float64, Nothing}
	ω :: Union{Float64, Nothing}
end

NetworkProperties(N::Integer, directed::Bool) = NetworkProperties(
	directed,
	nothing,
	nothing,
	nothing,
	nothing,
	repeat([nothing], N),
	nothing,
	nothing,
)

NetworkProperties(N::Integer, directed::Bool, numConnections::Integer) = NetworkProperties(
	directed,
	numConnections,
	nothing,
	nothing,
	nothing,
	repeat([nothing], N),
	nothing,
	nothing,
)