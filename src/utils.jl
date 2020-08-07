function i_plus_x(i, x, N)
	i = (i+N+x) % N;
	(i == 0) && (i = N)
	return i
end