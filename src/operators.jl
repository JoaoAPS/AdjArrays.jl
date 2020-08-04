function adjVetToMat(vet::Vector{<:Integer}, N::Integer)
	mat = BitArray(0 for i in 1:N, j in 1:N)

	let i = 0
		for idx in vet
			j = idx - i*N

			while j >= N
				i += 1
				j -= N
			end

			mat[i+1, j+1] = 1
		end
	end

	return mat
end

function adjMatToVet(mat::BitArray{2})
	@assert size(mat,1) == size(mat,2)
	
	N = size(mat)[1]
	vetPos = 1
	vet = Vector{Int}(undef, sum(mat))

	for i in 1:N, j in 1:N
		if mat[i,j] != 0
			vet[vetPos] = (i-1)*N + (j-1)
			vetPos += 1
		end
	end

	return vet
end

adjMatToVet(mat::Array{Bool,2}) = adjMatToVet(BitArray(mat))
function adjMatToVet(mat::AbstractArray{<:Integer,2})
	try
		BitArray(mat)
	catch e
		throw(ArgumentError("Matrix must be composed only of ones and zeros!"))
	end
	
	return adjMatToVet(BitArray(mat))
end