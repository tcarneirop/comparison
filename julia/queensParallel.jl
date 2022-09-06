function queens_partial_search!(::Val{size}, ::Val{cutoff_depth}) where {size, cutoff_depth}

	__VOID__     = 0
	__VISITED__    = 1
	__N_VISITED__   = 0

	#obs: because the vector begins with 1 I need to use size+1 for N-Queens of size 'size'
	print("Starting N-Queens of size ")
	println(size-1)
	print("Partial search until cutoff ")
	println(cutoff_depth)

	subproblems_pool = []

	depth = 1
	tree_size = 0
	#number_of_subproblems = 0

	local_visited = zeros(Int64,size)
	local_permutation = zeros(Int64,size)

	while true
		#%println(local_cycle
		local_permutation[depth] = local_permutation[depth]+1

		if local_permutation[depth] == (size+1)
			local_permutation[depth] = __VOID__
		else
			if (local_visited[local_permutation[depth]] == 0 && queens_is_valid_configuration(local_permutation,depth))

				local_visited[local_permutation[depth]] = __VISITED__
				depth +=1
				tree_size+=1

				if depth == cutoff_depth+1 ##complete solution -- full, feasible and valid solution
					#number_of_subproblems+=1
                    push!(subproblems_pool, (copy(local_visited), copy(local_permutation)))
				else
					continue
				end
			else
				continue
			end #elif
		end

		depth -= 1
		local_visited[local_permutation[depth]] = __N_VISITED__

		if depth < 2
			break
		end #if depth<2
	end

	number_of_subproblems = length(subproblems_pool)
	#println(number_of_subproblems)

	#metrics = Metrics(number_of_subproblems, tree_size)
	#println(metrics)

	return (subproblems_pool, number_of_subproblems, tree_size)

end #queens partial