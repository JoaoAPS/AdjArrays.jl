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
