using AdjacencyArrays, Test, SparseArrays

function tests()
	@testset "Global" begin
		@test GlobalNetwork(10).N == 10
		
		net = GlobalNetwork(4)
		@test adjVet(net) == [1, 2, 3, 4, 6, 7, 8, 9, 11, 12, 13, 14]
		@test adjMat(net) == BitArray([
			0 1 1 1;
			1 0 1 1;
			1 1 0 1;
			1 1 1 0
		])
		
		@test_throws ArgumentError GlobalNetwork(-2)
		@test_throws ArgumentError GlobalNetwork(0)
	end
	
	@testset "Regular" begin
		net = RegularNetwork(10, 4)
	    @test net.N == 10
	    @test net.k == 4
	    @test net.numConnections == 20
	    
	    net = RegularNetwork(5, 2)
	    @test adjMat(net) == [
	    	0 1 0 0 1;
	    	1 0 1 0 0;
	    	0 1 0 1 0;
	    	0 0 1 0 1;
	    	1 0 0 1 0
	    ]
	    @test adjMat(net, sparse=true) == sparse(
	    	[2, 5, 1, 3, 2, 4, 3, 5, 1, 4],
	    	[1, 1, 2, 2, 3, 3, 4, 4, 5, 5],
	    	1,
	    )
	    @test adjVet(net) == [1, 4, 5, 7, 11, 13, 17, 19, 20, 23]
	    
		# Argument manip
	    @test adjMat(RegularNetwork(10, 4))  == adjMat(RegularNetwork(10, 5))
	    @test adjMat(RegularNetwork(10, 0))  == BitArray(zeros(10, 10))
	    @test adjMat(RegularNetwork(10, -5)) == BitArray(zeros(10, 10))
	    @test adjMat(RegularNetwork(10, 10)) == adjMat(GlobalNetwork(10))
	    @test adjMat(RegularNetwork(10, 20)) == adjMat(GlobalNetwork(10))
	    
		# Argument errors
	    @test_throws ArgumentError RegularNetwork(-2, 1)
	    @test_throws ArgumentError RegularNetwork(0, 1)
	end
	
	@testset "ErdosRenyi p-initialized" begin
		# Undirected Network
		net = ErdosRenyiNetwork(10, 0.5, seed=1234)
		@test net.N == 10
		@test net.p == 0.5
		@test !net.directed
		@test net.seed == 1234
		@test net.numConnections ≈ (net.p * net.N * (net.N - 1) / 2) atol=5
		@test sum(adjMat(net)) == 2 * net.numConnections
		@test sum(adjMat(net)) == length(adjVet(net))
		
		# Directed Network
		net = ErdosRenyiNetwork(10, 0.5, seed=1234, directed=true)
		@test net.directed
		@test net.numConnections ≈ (net.p * net.N * (net.N - 1)) atol=10
		@test sum(adjMat(net)) == net.numConnections
		
		# Seed Behaviour
		net = ErdosRenyiNetwork(10, 0.5)
		@test adjMat(ErdosRenyiNetwork(10, 0.5, seed=net.seed)) == adjMat(net)
		
		# Argument manip
		@test adjMat(ErdosRenyiNetwork(10, -1.)) == BitArray(zeros(10, 10))
		@test adjMat(ErdosRenyiNetwork(10, 1.2)) == adjMat(GlobalNetwork(10))
		
		# Argument errors
		@test_throws ArgumentError ErdosRenyiNetwork(-2, 0.5)
		@test_throws ArgumentError ErdosRenyiNetwork(0, 0.5)
	end
	
	@testset "ErdosRenyi numConnections-initialized" begin
		# Undirected Network
		net = ErdosRenyiNetwork(10, 20, seed=1234)
		@test net.N == 10
		@test net.numConnections == 20
		@test isnothing(net.p)
		@test !net.directed
		@test net.seed == 1234
		@test sum(adjMat(net)) == 2 * net.numConnections
		@test sum(adjMat(net)) == length(adjVet(net))
		
		# Directed Network
		net = ErdosRenyiNetwork(10, 20, seed=1234, directed=true)
		@test net.numConnections == 20
		@test isnothing(net.p)
		@test net.directed
		@test sum(adjMat(net)) == net.numConnections
		
		# Seed Behaviour
		net = ErdosRenyiNetwork(10, 30)
		@test adjMat(ErdosRenyiNetwork(10, 30, seed=net.seed)) == adjMat(net)
		
		# Argument manip
		@test adjMat(ErdosRenyiNetwork(10, -1))  == BitArray(zeros(10, 10))
		@test adjMat(ErdosRenyiNetwork(10, 100)) == adjMat(GlobalNetwork(10))
		
		# Argument errors
		@test_throws ArgumentError ErdosRenyiNetwork(-2, 1)
		@test_throws ArgumentError ErdosRenyiNetwork(0, 0)
	end
	
	
	@testset "Converters" begin
		net = RegularNetwork(10, 4)
		vet = adjVet(net)
		mat = adjMat(net)
		
		@test adjVetToMat(vet, 10) == mat
		@test adjMatToVet(mat) == vet
		@test adjMatToVet(Int.(mat)) == vet
		@test adjMatToVet(Bool.(mat)) == vet
		
		@test_throws ArgumentError adjMatToVet([1 0; 3 2])
		@test_throws AssertionError adjMatToVet([1 0 1; 0 0 1])
	end
end
	
tests()
