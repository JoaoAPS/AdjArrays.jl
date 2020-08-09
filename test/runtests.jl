using AdjacencyArrays, Test, SparseArrays

function tests()
	@testset "Empty" begin
		net = EmptyNetwork(10)
	    @test numnodes(net) == 10
	    @test numconnections(net) == 0
	    @test !isdirected(net)
	    @test connectivity(net, 1) == 0
		@test connectivities(net) == [0, 0, 0, 0, 0, 0, 0, 0, 0, 0]
	    @test meanconnectivity(net) == 0
	    @test adjMat(net) == zeros(10, 10)
	    @test adjVet(net) == []
	end
	
	@testset "Global" begin
		# Undirected
		net = GlobalNetwork(10)
		@test numnodes(net) == 10
		@test numconnections(net) == 10 * 9 / 2
		@test !isdirected(net)
		@test connectivity(net, 1) == 9
		@test connectivities(net) == [9, 9, 9, 9, 9, 9, 9, 9, 9, 9]
		@test meanconnectivity(net) == 9
		
		# Undirected
		net = GlobalNetwork(10, directed=true)
		@test numconnections(net) == 10 * 9
		@test isdirected(net)
		
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
		# Undirected
		net = RegularNetwork(10, 4)
	    @test numnodes(net) == 10
	    @test numconnections(net) == 20
	    @test !isdirected(net)
	    @test connectivity(net, 1) == 4
		@test connectivities(net) == [4, 4, 4, 4, 4, 4, 4, 4, 4, 4]
	    @test meanconnectivity(net) == 4
		
		# Directed
		net = RegularNetwork(10, 4, directed=true)
	    @test numconnections(net) == 40
	    @test isdirected(net)
	    
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
		@test meanconnectivity(net) == 4
		@test numconnections(net) == 4 * 10 / 2
	    @test adjMat(net)  == adjMat(RegularNetwork(10, 4))
		net = RegularNetwork(10, -5)
		@test meanconnectivity(net) == 0
		@test numconnections(net) == 0
	    @test adjMat(net) == adjMat(EmptyNetwork(10))
	    net = RegularNetwork(10, 20)
		@test meanconnectivity(net) == 9
		@test adjMat(net) == adjMat(GlobalNetwork(10))
		@test numconnections(net) == sum(adjMat(net)) / 2
		net = RegularNetwork(11, 20)
		@test meanconnectivity(net) == 10
		@test adjMat(net) == adjMat(GlobalNetwork(11))
		@test numconnections(net) == sum(adjMat(net)) / 2
	end
	
	@testset "ErdosRenyi p-initialized" begin
		# Undirected Network
		net = ErdosRenyiNetwork(500, 0.5, seed=1234)
		@test numnodes(net) == 500
		@test net.p == 0.5
		@test numconnections(net) ≈ (net.p * numnodes(net) * (numnodes(net) - 1) / 2) rtol=0.1
		@test !isdirected(net)
		@test net.seed == 1234
		
		@test issymmetric(adjMat(net))
		@test sum(adjMat(net)) == 2 * numconnections(net)
		@test length(adjVet(net)) == 2 * numconnections(net)
		
		# Directed Network
		net = ErdosRenyiNetwork(500, 0.5, seed=1234, directed=true)
		@test isdirected(net)
		@test numconnections(net) ≈ (net.p * numnodes(net) * (numnodes(net) - 1)) rtol=0.1
		@test sum(adjMat(net)) == numconnections(net)
		@test length(adjVet(net)) == numconnections(net)
		
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
		@test numnodes(net) == 10
		@test numconnections(net) == 20
		@test isnothing(net.p)
		@test !isdirected(net)
		@test net.seed == 1234
		
		@test issymmetric(adjMat(net))
		@test sum(adjMat(net)) == 2 * numconnections(net)
		@test length(adjVet(net)) == 2 * numconnections(net)
		
		# Directed Network
		net = ErdosRenyiNetwork(10, 20, seed=1234, directed=true)
		@test numconnections(net) == 20
		@test isnothing(net.p)
		@test isdirected(net)
		@test sum(adjMat(net)) == numconnections(net)
		@test length(adjVet(net)) == numconnections(net)
		
		# Seed Behaviour
		net = ErdosRenyiNetwork(10, 30)
		@test adjMat(ErdosRenyiNetwork(10, 30, seed=net.seed)) == adjMat(net)
		
		# Argument manip
		@test numconnections(ErdosRenyiNetwork(10, -1)) == 0
		@test numconnections(ErdosRenyiNetwork(10, 100)) == 45
		@test adjMat(ErdosRenyiNetwork(10, -1))  == adjMat(EmptyNetwork(10))
		@test adjMat(ErdosRenyiNetwork(10, 100)) == adjMat(GlobalNetwork(10))
	end
	
	@testset "WattsStrogatz β-initialized" begin
	    # Undirected Network
		net = WattsStrogatzNetwork(500, 10, 0.2, seed=1234)
		@test numnodes(net) == 500
		@test meanconnectivity(net) == 10
		@test net.β == 0.2
		@test numconnections(net) == 10 * 500 / 2
		@test numshortcuts(net) ≈ (net.β * numconnections(net)) rtol=0.1
		@test !isdirected(net)
		@test net.seed == 1234
		
		@test issymmetric(adjMat(net))
		@test sum(adjMat(net)) == 2 * numconnections(net)
		@test length(adjVet(net)) == 2 * numconnections(net)
		
		# Directed Network
		net = WattsStrogatzNetwork(500, 10, 0.2, seed=1234, directed=true)
		@test numconnections(net) == 10 * 500
		@test numshortcuts(net) ≈ (net.β * numconnections(net)) rtol=0.1
		@test isdirected(net)
		@test sum(adjMat(net)) == numconnections(net)
		@test length(adjVet(net)) == numconnections(net)
	    
	    # Seed Behaviour
		net = WattsStrogatzNetwork(20, 4, 0.2)
		@test adjMat(WattsStrogatzNetwork(20, 4, 0.2, seed=net.seed)) == adjMat(net)
		
		# Argument manip
		net = WattsStrogatzNetwork(10, -1, 0.2)
		@test meanconnectivity(net) == 0
		@test numconnections(net) == 0
		@test numshortcuts(net) == 0
		@test isnothing(net.β)
		@test adjMat(net) == adjMat(EmptyNetwork(10))

		net = WattsStrogatzNetwork(10, 11, 0.2)
		@test meanconnectivity(net) == 9
		@test numconnections(net) == 90 / 2
		@test numshortcuts(net) == 0
		@test isnothing(net.β)
		@test adjMat(net) == adjMat(GlobalNetwork(10))

		net = WattsStrogatzNetwork(10, 2, -0.5)
		@test net.β == 0.0
		@test numshortcuts(net) == 0
		@test adjMat(net) == adjMat(RegularNetwork(10, 2))

		net = WattsStrogatzNetwork(10, 2, 1.5)
		@test net.β == 1.0
		@test numshortcuts(net) == numconnections(net)
	end
	
	@testset "WattsStrogatz numShortcuts-initialized" begin
	    # Undirected Network
		net = WattsStrogatzNetwork(500, 10, 100, seed=1234)
		@test numnodes(net) == 500
		@test meanconnectivity(net) == 10
		@test isnothing(net.β)
		@test numconnections(net) == 10 * 500 / 2
		@test numshortcuts(net) == 100
		@test !isdirected(net)
		@test net.seed == 1234
		
		@test issymmetric(adjMat(net))
		@test sum(adjMat(net)) == 2 * numconnections(net)
		@test length(adjVet(net)) == 2 * numconnections(net)
		
		# Directed Network
		net = WattsStrogatzNetwork(500, 10, 100, seed=1234, directed=true)
		@test numconnections(net) == 10 * 500
		@test numshortcuts(net) == 100
		@test isdirected(net)
		@test sum(adjMat(net)) == numconnections(net)
		@test length(adjVet(net)) == numconnections(net)
	    
	    # Seed Behaviour
		net = WattsStrogatzNetwork(20, 4, 10)
		@test adjMat(WattsStrogatzNetwork(20, 4, 10, seed=net.seed)) == adjMat(net)
		
		# Argument manip
		net = WattsStrogatzNetwork(10, -1, 5)
		@test meanconnectivity(net) == 0
		@test numconnections(net) == 0
		@test numshortcuts(net) == 0
		@test isnothing(net.β)
		@test adjMat(net) == adjMat(EmptyNetwork(10))

		net = WattsStrogatzNetwork(10, 11, 5)
		@test meanconnectivity(net) == 9
		@test numconnections(net) == 90 / 2
		@test numshortcuts(net) == 0
		@test isnothing(net.β)
		@test adjMat(net) == adjMat(GlobalNetwork(10))

		net = WattsStrogatzNetwork(10, 2, -5)
		@test numshortcuts(net) == 0
		@test adjMat(net) == adjMat(RegularNetwork(10, 2))

		net = WattsStrogatzNetwork(10, 2, 40)
		@test numshortcuts(net) == numconnections(net)
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
	
	@testset "Properties" begin
		# Connectivity
		net = GlobalNetwork(10)
	    @test_throws ArgumentError connectivity(net, 0)
	    @test_throws ArgumentError connectivity(net, 11)
	    
	    net = RegularNetwork(10, 4, directed=true)
	    @test connectivity(net, 1, degree=:in) == 4
	    @test connectivity(net, 1, degree=:out) == 4
	    @test connectivity(net, 1, degree=:total) == 2 * 4
	    @test connectivity(net, 1, degree=:mean) == 4
	    @test connectivity(net, 1, degree=:both) == (4, 4)
	    
	    # Clustering Coefficient
		net = GlobalNetwork(10)
	    @test clusteringcoefficient(net, 1) == 1
	    @test clusteringcoefficient(net) == 1
	    @test clusteringcoefficients(net) == repeat([1], 10)
	    
		net = RegularNetwork(20, 4)
	    @test clusteringcoefficient(net, 1) == 0.5
	    @test clusteringcoefficient(net) == 0.5
	    @test clusteringcoefficients(net) == repeat([0.5], 20)
	    
		net = ErdosRenyiNetwork(1000, 0.2, seed=1234)
	    @test clusteringcoefficient(net) ≈ 0.2 rtol=0.1
	end
	
	@testset "Operators" begin
		# Undirected netowrks
		@test allEdges(EmptyNetwork(5)) == []
	    @test allEdges(GlobalNetwork(4)) == [
	    	(1, 2),
	    	(1, 3),
	    	(1, 4),
	    	(2, 3),
	    	(2, 4),
	    	(3, 4)
	    ]
	    @test allEdges(RegularNetwork(5, 2)) == [
	    	(1, 2),
	    	(1, 5),
	    	(2, 3),
	    	(3, 4),
	    	(4, 5)
	    ]
	    
	    # Directed netowrks
	    @test allEdges(GlobalNetwork(4, directed=true)) == [
	    	(1, 2),
	    	(1, 3),
	    	(1, 4),
	    	(2, 1),
	    	(2, 3),
	    	(2, 4),
	    	(3, 1),
	    	(3, 2),
	    	(3, 4),
	    	(4, 1),
	    	(4, 2),
	    	(4, 3)
	    ]
	    @test allEdges(RegularNetwork(5, 2, directed=true)) == [
	    	(1, 2),
	    	(1, 5),
	    	(2, 1),
	    	(2, 3),
	    	(3, 2),
	    	(3, 4),
	    	(4, 3),
	    	(4, 5),
	    	(5, 1),
	    	(5, 4)
	    ]
	    
	    # Different first_index
	    @test allEdges(RegularNetwork(5, 2), first_index=0) == [
	    	(0, 1),
	    	(0, 4),
	    	(1, 2),
	    	(2, 3),
	    	(3, 4)
	    ]
	    
	    @test_throws ArgumentError allEdges(GlobalNetwork(3), first_index=2)
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
