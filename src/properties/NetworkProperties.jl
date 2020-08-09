mutable struct NetworkProperties
	directed :: Bool
	numConnections :: Union{Int, Nothing}
	meanConnectivity :: Union{Real, Nothing}
	
	clusteringCoefficients :: Union{Vector{<:Real}, Nothing}
	transitivity :: Union{Real, Nothing}
end

NetworkProperties(directed::Bool) = NetworkProperties(directed, nothing, nothing, nothing, nothing)
NetworkProperties(directed::Bool, numConnections::Integer) = 
	NetworkProperties(directed, numConnections, nothing, nothing, nothing)