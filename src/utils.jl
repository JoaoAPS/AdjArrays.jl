function i_plus_x(i, x, N)
	i = (i+N+x) % N;
	(i == 0) && (i = N)
	return i
end

function mean(vet::AbstractVector)
	(length(vet) == 0) && (return 0)
	return sum(vet) / length(vet)
end

