function queens_tree_explorer(size,cutoff_depth, local_visited, local_permutation #=s::Subproblem=#)::Metrics

	__VOID__     = 0
	__VISITED__    = 1
	__N_VISITED__   = 0

	#obs: because the vector begins with 1 I need to use size+1 for N-Queens of size 'size'

	depth = cutoff_depth+1
	tree_size = 0
	number_of_solutions = 0

	while true
		#%println(local_cycle)

		local_permutation[depth] = local_permutation[depth]+1

		if local_permutation[depth] == (size+1)
			local_permutation[depth] = __VOID__
		else
			if (local_visited[local_permutation[depth]] == 0 && queens_is_valid_configuration(local_permutation, depth))

				local_visited[local_permutation[depth]] = __VISITED__
				depth +=1
				tree_size+=1

				if depth == size+1 ##complete solution -- full, feasible and valid solution
					number_of_solutions+=1
					#println(local_visited, " ", local_permutation)
				else
					continue
				end
			else
				continue
			end #elif
		end

		depth -= 1
		local_visited[local_permutation[depth]] = __N_VISITED__

		if depth < cutoff_depth+1
			break
		end #if depth<2
	end

metrics = Metrics(number_of_solutions, tree_size)
#println(metrics)
return metrics

end #queens tree explorer

function queens_mcore_caller(::Val{size},::Val{cutoff_depth},::Val{num_threads}) where {size, cutoff_depth, num_threads}

	print("Starting MCORE N-Queens of size ")
	println(size-1)
	#subproblems = [Subproblem(size) for i in 1:1000000]

	#partial search -- generate some feasible valid and incomplete solutions
	(subproblems, metrics) = @time queens_partial_search!(Val(size), Val(cutoff_depth))
	#end of the partial search

	number_of_subproblems = metrics.number_of_solutions
	partial_tree_size = metrics.partial_tree_size
	number_of_solutions = 0
	metrics.number_of_solutions = 0
	println(number_of_subproblems)
	println(metrics)

	thread_tree_size = zeros(Int64, num_threads)
	thread_num_sols  = zeros(Int64, num_threads)
	thread_load = fill(div(number_of_subproblems, num_threads), num_threads)
	stride = div(number_of_subproblems, num_threads)
	println(thread_load)
	thread_load[num_threads] += mod(number_of_subproblems, num_threads)

	@sync begin
		for ii in 0:(num_threads-1)

			println("LOOP " * string(ii))
			local local_thread_id = ii
			local local_load = thread_load[local_thread_id+1]
			local local_metrics = Metrics(0,0)

			Threads.@spawn begin
				println("THREAD: " * string(local_thread_id) * " has " * string(local_load) * " iterations")
				for j in 1:local_load

					s = local_thread_id*stride + j

					local_metrics = queens_tree_explorer(size,cutoff_depth, subproblems[s].subproblem_is_visited, subproblems[s].subproblem_partial_permutation)
					thread_tree_size[local_thread_id+1] += local_metrics.partial_tree_size
					thread_num_sols[local_thread_id+1]  += local_metrics.number_of_solutions
				end
			end

		end
	end
	number_of_solutions = sum(thread_num_sols)
	partial_tree_size += sum(thread_tree_size)
	println("\n###########################")
	println("N-Queens size: ", size-1, "\nNumber of threads: ", num_threads ,"\n###########################\n" ,"\nNumber of sols: ",number_of_solutions, "\nTree size: " ,partial_tree_size,"\n\n")
end #caller
