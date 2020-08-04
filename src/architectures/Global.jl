struct GlobalNetwork
	N :: Integer
end

function adjVet(network::GlobalNetwork)
	return [i for i in 0:network.N^2-1 if i % (network.N + 1) != 0]
end

function adjMat(network::GlobalNetwork)
	return BitArray([(i != j) for i in 1:network.N, j in 1:network.N ])
end