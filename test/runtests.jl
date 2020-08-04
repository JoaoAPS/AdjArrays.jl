using AdjArrays, Test

function tests()
	@testset "Global" begin
		@test GlobalNetwork(10).N == 10
		
		g = GlobalNetwork(4)
		vet = adjVet(g)
		mat = adjMat(g)
		
		@test vet == [1, 2, 3, 4, 6, 7, 8, 9, 11, 12, 13, 14]
		@test mat == BitArray([
			0 1 1 1;
			1 0 1 1;
			1 1 0 1;
			1 1 1 0
		])
		
		@test_throws ArgumentError GlobalNetwork(-2)
		@test_throws ArgumentError GlobalNetwork(0)
	end
	
	@testset "ErdosRenyi p-initialized" begin
		# Undirected Network
		net = ErdosRenyiNetwork(10, 0.5, seed=1234)
		@test net.N == 10
		@test net.p == 0.5
		@test ≈(net.numConnections, net.p * net.N * (net.N - 1) / 2, atol=5)
		@test !net.directed
		@test net.seed == 1234
		@test sum(adjMat(net)) == 2 * net.numConnections
		@test sum(adjMat(net)) == length(adjVet(net))
		
		# Directed Network
		net = ErdosRenyiNetwork(10, 0.5, seed=1234, directed=true)
		@test net.directed
		@test net.numConnections ≈ (net.p * net.N * (net.N - 1)) atol=5
		@test sum(adjMat(net)) == net.numConnections
		
		# Seed Behaviour
		seed = 1234
		net = ErdosRenyiNetwork(10, 0.5)
		@test adjMat(ErdosRenyiNetwork(10, 0.5, seed=seed)) == adjMat(ErdosRenyiNetwork(10, 0.5, seed=seed))
		@test adjMat(ErdosRenyiNetwork(10, 0.5, seed=net.seed)) == adjMat(net)
		
		# Argument errors
		@test_throws ArgumentError ErdosRenyiNetwork(-2, 0.5)
		@test_throws ArgumentError ErdosRenyiNetwork(0, 0.5)
		@test_throws ArgumentError ErdosRenyiNetwork(10, -0.5)
		@test_throws ArgumentError ErdosRenyiNetwork(10, 1.5)
	end
	
	@testset "ErdosRenyi numConnections-initialized" begin
		# Undirected Network
		net = ErdosRenyiNetwork(10, 20, seed=1234)
		@test net.N == 10
		@test net.numConnections == 20
		@test net.p == net.numConnections / (net.N * (net.N - 1) / 2)
		@test !net.directed
		@test net.seed == 1234
		@test sum(adjMat(net)) == 2 * net.numConnections
		@test sum(adjMat(net)) == length(adjVet(net))
		
		# Directed Network
		net = ErdosRenyiNetwork(10, 20, seed=1234, directed=true)
		@test net.numConnections == 20
		@test net.p == net.numConnections / (net.N * (net.N - 1))
		@test net.directed
		@test sum(adjMat(net)) == net.numConnections
		
		# Seed Behaviour
		seed = 1234
		net = ErdosRenyiNetwork(10, 30)
		@test adjMat(ErdosRenyiNetwork(10, 30, seed=seed)) == adjMat(ErdosRenyiNetwork(10, 30, seed=seed))
		@test adjMat(ErdosRenyiNetwork(10, 30, seed=net.seed)) == adjMat(net)
		
		# Argument errors
		@test_throws ArgumentError ErdosRenyiNetwork(-2, 1)
		@test_throws ArgumentError ErdosRenyiNetwork(0, 0)
		@test_throws ArgumentError ErdosRenyiNetwork(10, -5)
		@test_throws ArgumentError ErdosRenyiNetwork(5, 11)
		@test isa(ErdosRenyiNetwork(5, 11, directed=true), Any) # Tests for no exception
		@test_throws ArgumentError ErdosRenyiNetwork(5, 21, directed=true)
	end
	
	
	@testset "Converters" begin
		g = GlobalNetwork(4)
		vet = adjVet(g)
		mat = adjMat(g)
		
		@test adjVetToMat(vet, 4) == mat
		@test adjMatToVet(mat) == vet
		@test adjMatToVet(Int.(mat)) == vet
		@test adjMatToVet(Bool.(mat)) == vet
		
		@test_throws ArgumentError adjMatToVet([1 0; 3 2])
		@test_throws AssertionError adjMatToVet([1 0 1; 0 0 1])
	end
end
	
tests()
