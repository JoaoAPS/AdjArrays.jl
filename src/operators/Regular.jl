function equivalentLatticeNetwork(
	network::RegularNetwork;
	seed::Integer = -1,
	numReshuffle::Integer = 10,
	maxTentatives::Integer = (numconnections(network) * numReshuffle * 300)
)
	return network
end

