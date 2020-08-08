#---------- Calculators ----------
function generateERAdjMat(
	N::Integer,
	p::Real;
	directed::Bool,
	seed::Integer
)
	(p >= 1) && (return adjMat(GlobalNetwork(N)))
	(p <= 0) && (return adjMat(EmptyNetwork(N)))
	
	rng = Random.MersenneTwister(seed)
	mat = adjMat(EmptyNetwork(N))
	
	if directed
		for i in 1:N, j in 1:N
			(i == j) && continue
			(rand(rng) < p) && (mat[i,j] = 1)
		end
	else
		for i in 1:N, j in i+1:N
			if rand(rng) < p
				mat[i,j] = 1
				mat[j,i] = 1
			end
		end
	end
	
	return mat
end

function generateERAdjMat(
	N::Integer,
	numConnections::Int;
	directed::Bool,
	seed::Integer
)
	maxConnections = Int(N * (N - 1) / 2)
	directed || (maxConnections /= 2)
	
	(numConnections >= maxConnections) && (return adjMat(GlobalNetwork(N)))
	(numConnections <= 0) && (return adjMat(EmptyNetwork(N)))
	
	rng = Random.MersenneTwister(seed)
	mat = adjMat(EmptyNetwork(N))
	nc = 0
	
	while nc < numConnections
		# Choose a random non-existing connection
		origin = rand(rng, 1:N)
		dest   = rand(rng, 1:N)

		(origin == dest) && continue
		(mat[dest, origin] == 1) && continue
		
		mat[dest, origin] = 1
		directed || (mat[origin, dest] = 1)
		nc += 1
	end
	
	return mat
end
 