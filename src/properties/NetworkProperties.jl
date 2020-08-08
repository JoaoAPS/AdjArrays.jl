mutable struct NetworkProperties
	directed :: Bool
	numConnections :: Union{Int, Nothing}
	meanConnectivity :: Union{Real, Nothing}
end

NetworkProperties(directed::Bool) = NetworkProperties(directed, nothing, nothing)
NetworkProperties(directed::Bool, numConnections::Integer) = 
	NetworkProperties(directed, numConnections, nothing)