using AdjacencyArrays, Test, SparseArrays

function tests()
	@testset "Empty" begin
		net = EmptyNetwork(10)
	    @test net.N == 10
	    @test adjMat(net) == zeros(10, 10)
	    @test adjVet(net) == []
	end
	
	@testset "Global" begin
		net = GlobalNetwork(10)
		@test net.N == 10
		@test net.numConnections == 10 * 9 / 2
		
		net = GlobalNetwork(4)
		@test adjVet(net) == [1, 2, 3, 4, 6, 7, 8, 9, 11, 12, 13, 14]
		@test adjMat(net) == BitArray([
			0 1 1 1;
			1 0 1 1;
			1 1 0 1;
			1 1 1 0
		])
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
	    
	    @test adjMat(RegularNetwork(10, 2)) == adjMat(RegularNetwork(10, 2, directed=true))
	    
		# Argument manip
		net = RegularNetwork(10, 5)
		@test net.k == 4
		@test net.numConnections == 4 * 10 / 2
	    @test adjMat(net)  == adjMat(RegularNetwork(10, 4))
		net = RegularNetwork(10, -5)
		@test net.k == 0
		@test net.numConnections == 0
	    @test adjMat(net) == adjMat(EmptyNetwork(10))
	    net = RegularNetwork(10, 20)
		@test net.k == 9
		@test adjMat(net) == adjMat(GlobalNetwork(10))
		@test net.numConnections == sum(adjMat(net)) / 2
		net = RegularNetwork(11, 20)
		@test net.k == 10
		@test adjMat(net) == adjMat(GlobalNetwork(11))
		@test net.numConnections == sum(adjMat(net)) / 2
	end
	
	@testset "ErdosRenyi p-initialized" begin
		# Undirected Network
		net = ErdosRenyiNetwork(10, 0.5, seed=1234)
		@test net.N == 10
		@test net.p == 0.5
		@test !net.directed
		@test net.seed == 1234
		@test net.numConnections ≈ (net.p * net.N * (net.N - 1) / 2) atol=5
		
		@test issymmetric(adjMat(net))
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
		@test ErdosRenyiNetwork(10, -1.).p == 0.0
		@test ErdosRenyiNetwork(10, 1.2).p == 1.0
		@test adjMat(ErdosRenyiNetwork(10, -1.)) == adjMat(EmptyNetwork(10))
		@test adjMat(ErdosRenyiNetwork(10, 1.2)) == adjMat(GlobalNetwork(10))
	end
	
	@testset "ErdosRenyi numConnections-initialized" begin
		# Undirected Network
		net = ErdosRenyiNetwork(10, 20, seed=1234)
		@test net.N == 10
		@test net.numConnections == 20
		@test isnothing(net.p)
		@test !net.directed
		@test net.seed == 1234
		
		@test issymmetric(adjMat(net))
		@test sum(adjMat(net)) == 2 * net.numConnections
		@test length(adjVet(net)) == 2 * net.numConnections
		
		# Directed Network
		net = ErdosRenyiNetwork(10, 20, seed=1234, directed=true)
		@test net.numConnections == 20
		@test isnothing(net.p)
		@test net.directed
		@test sum(adjMat(net)) == net.numConnections
		@test length(adjVet(net)) == net.numConnections
		
		# Seed Behaviour
		net = ErdosRenyiNetwork(10, 30)
		@test adjMat(ErdosRenyiNetwork(10, 30, seed=net.seed)) == adjMat(net)
		
		# Argument manip
		@test ErdosRenyiNetwork(10, -1).numConnections == 0
		@test ErdosRenyiNetwork(10, 100).numConnections == 45
		@test adjMat(ErdosRenyiNetwork(10, -1))  == adjMat(EmptyNetwork(10))
		@test adjMat(ErdosRenyiNetwork(10, 100)) == adjMat(GlobalNetwork(10))
	end
	
	@testset "WattsStrogatz β-initialized" begin
	    # Undirected Network
		net = WattsStrogatzNetwork(500, 10, 0.2, seed=1234)
		@test net.N == 500
		@test net.k == 10
		@test net.β == 0.2
		@test net.numConnections == 10 * 500 / 2
		@test net.numShortcuts ≈ (net.β * net.numConnections) rtol=0.1
		@test !net.directed
		@test net.seed == 1234
		
		@test issymmetric(adjMat(net))
		@test sum(adjMat(net)) == 2 * net.numConnections
		@test length(adjVet(net)) == 2 * net.numConnections
		
		# Directed Network
		net = WattsStrogatzNetwork(500, 10, 0.2, seed=1234, directed=true)
		@test net.numConnections == 10 * 500
		@test net.numShortcuts ≈ (net.β * net.numConnections) rtol=0.1
		@test net.directed
		@test sum(adjMat(net)) == net.numConnections
		@test length(adjVet(net)) == net.numConnections
	    
	    # Seed Behaviour
		net = WattsStrogatzNetwork(20, 4, 0.2)
		@test adjMat(WattsStrogatzNetwork(20, 4, 0.2, seed=net.seed)) == adjMat(net)
		
		# Argument manip
		net = WattsStrogatzNetwork(10, -1, 0.2)
		@test net.k == 0
		@test net.numConnections == 0
		@test net.numShortcuts == 0
		@test isnothing(net.β)
		@test adjMat(net) == adjMat(EmptyNetwork(10))

		net = WattsStrogatzNetwork(10, 11, 0.2)
		@test net.k == 9
		@test net.numConnections == 90 / 2
		@test net.numShortcuts == 0
		@test isnothing(net.β)
		@test adjMat(net) == adjMat(GlobalNetwork(10))

		net = WattsStrogatzNetwork(10, 2, -0.5)
		@test net.β == 0.0
		@test net.numShortcuts == 0
		@test adjMat(net) == adjMat(RegularNetwork(10, 2))

		net = WattsStrogatzNetwork(10, 2, 1.5)
		@test net.β == 1.0
		@test net.numShortcuts == net.numConnections
	end
	
	@testset "WattsStrogatz numShortcuts-initialized" begin
	    # Undirected Network
		net = WattsStrogatzNetwork(500, 10, 100, seed=1234)
		@test net.N == 500
		@test net.k == 10
		@test isnothing(net.β)
		@test net.numConnections == 10 * 500 / 2
		@test net.numShortcuts == 100
		@test !net.directed
		@test net.seed == 1234
		
		@test issymmetric(adjMat(net))
		@test sum(adjMat(net)) == 2 * net.numConnections
		@test length(adjVet(net)) == 2 * net.numConnections
		
		# Directed Network
		net = WattsStrogatzNetwork(500, 10, 100, seed=1234, directed=true)
		@test net.numConnections == 10 * 500
		@test net.numShortcuts == 100
		@test net.directed
		@test sum(adjMat(net)) == net.numConnections
		@test length(adjVet(net)) == net.numConnections
	    
	    # Seed Behaviour
		net = WattsStrogatzNetwork(20, 4, 10)
		@test adjMat(WattsStrogatzNetwork(20, 4, 10, seed=net.seed)) == adjMat(net)
		
		# Argument manip
		net = WattsStrogatzNetwork(10, -1, 5)
		@test net.k == 0
		@test net.numConnections == 0
		@test net.numShortcuts == 0
		@test isnothing(net.β)
		@test adjMat(net) == adjMat(EmptyNetwork(10))

		net = WattsStrogatzNetwork(10, 11, 5)
		@test net.k == 9
		@test net.numConnections == 90 / 2
		@test net.numShortcuts == 0
		@test isnothing(net.β)
		@test adjMat(net) == adjMat(GlobalNetwork(10))

		net = WattsStrogatzNetwork(10, 2, -5)
		@test net.numShortcuts == 0
		@test adjMat(net) == adjMat(RegularNetwork(10, 2))

		net = WattsStrogatzNetwork(10, 2, 40)
		@test net.numShortcuts == net.numConnections
	end
	
	
	@testset "Trivial Networks" begin
		# N = 1
		trivialAdjMat = BitMatrix([0 for i in [1], j in [1]])
		
		@test adjMat(EmptyNetwork(1)) == trivialAdjMat
		@test adjMat(GlobalNetwork(1)) == trivialAdjMat
		@test adjMat(RegularNetwork(1, 2)) == trivialAdjMat
		@test adjMat(ErdosRenyiNetwork(1, 0.4)) == trivialAdjMat
		@test adjMat(ErdosRenyiNetwork(1, 4)) == trivialAdjMat
		@test adjMat(WattsStrogatzNetwork(1, 2, 0.4)) == trivialAdjMat
		@test adjMat(WattsStrogatzNetwork(1, 2, 4)) == trivialAdjMat
		
		@test adjVet(EmptyNetwork(1)) == []
		@test adjVet(GlobalNetwork(1)) == []
		@test adjVet(RegularNetwork(1, 2)) == []
		@test adjVet(ErdosRenyiNetwork(1, 0.4)) == []
		@test adjVet(ErdosRenyiNetwork(1, 4)) == []
		@test adjVet(WattsStrogatzNetwork(1, 2, 0.4)) == []
		@test adjVet(WattsStrogatzNetwork(1, 2, 4)) == []
		
		# N < 1
		@test_throws ArgumentError EmptyNetwork(0)
		@test_throws ArgumentError EmptyNetwork(-2)
		@test_throws ArgumentError GlobalNetwork(0)
		@test_throws ArgumentError GlobalNetwork(-2)
		@test_throws ArgumentError RegularNetwork(0, 2)
		@test_throws ArgumentError RegularNetwork(-2, 2)
		@test_throws ArgumentError ErdosRenyiNetwork(0, 0.4)
		@test_throws ArgumentError ErdosRenyiNetwork(-2, 0.4)
		@test_throws ArgumentError ErdosRenyiNetwork(0, 4)
		@test_throws ArgumentError ErdosRenyiNetwork(-2, 4)
		@test_throws ArgumentError WattsStrogatzNetwork(0, 2, 0.4)
		@test_throws ArgumentError WattsStrogatzNetwork(-2, 2, 0.4)
		@test_throws ArgumentError WattsStrogatzNetwork(0, 2, 4)
		@test_throws ArgumentError WattsStrogatzNetwork(-2, 2, 4)
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

function issymmetric(mat::AbstractMatrix)
	(size(mat, 1) != size(mat, 2)) && (return false)
	for i in 1:size(mat, 1), j in i+1:size(mat, 2)
		(mat[i,j] != mat[j,i]) && (return false)
	end
	return true
end
	
tests()
