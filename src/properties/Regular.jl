meanconnectivity(network::RegularNetwork) = network.k


# ---------- Calculators ----------
calcNumConnections!(network::RegularNetwork) =
	network._props.numConnections = Int(network.k * network.N / (isdirected(network) ? 1 : 2))

calcConnectivity(network::RegularNetwork) = network.k

function calcAdjMat!(network::RegularNetwork)
	if network.k >= network.N-1
		network._adjMat = adjMat(GlobalNetwork(network.N))
		return
	end
	
	network._adjMat = adjMat(EmptyNetwork(network.N), sparse=true)
	(network.k <= 0) && (return)
	
	for i in 1:network.N
		c = 1
		while c <= floor(Int, network.k / 2)
			network._adjMat[i, i_plus_x(i,  c, network.N)] = 1
			network._adjMat[i, i_plus_x(i, -c, network.N)] = 1
			c += 1
		end
	end
end