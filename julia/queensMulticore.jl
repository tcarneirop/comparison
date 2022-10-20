function queens_tree_explorer(size,cutoff_depth, local_visited, local_permutation)
	@inbounds begin
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
	end
return (number_of_solutions, tree_size)

end #queens tree explorer

function queens_mcore_caller(::Val{size},::Val{cutoff_depth},::Val{num_threads}) where {size, cutoff_depth, num_threads}

	print("Starting MCORE N-Queens of size ")
	println(size-1)
	#subproblems = [Subproblem(size) for i in 1:1000000]

	#partial search -- generate some feasible valid and incomplete solutions
	(subproblems, number_of_subproblems, partial_tree_size) = @time queens_partial_search!(Val(size), Val(cutoff_depth))
	#end of the partial search

	println(number_of_subproblems)

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

			Threads.@spawn begin
				println("THREAD: " * string(local_thread_id) * " has " * string(local_load) * " iterations")
				for j in 1:local_load

					s = local_thread_id*stride + j

					(local_number_of_solutions, local_partial_tree_size) = queens_tree_explorer(size,cutoff_depth, subproblems[s][1]#=.subproblem_is_visited=#, subproblems[s][2]#=.subproblem_partial_permutation=#)
					thread_tree_size[local_thread_id+1] += local_partial_tree_size
					thread_num_sols[local_thread_id+1]  += local_number_of_solutions
				end
			end

		end
	end
	number_of_solutions = sum(thread_num_sols)
	partial_tree_size += sum(thread_tree_size)
	println("\n###########################")
	println("N-Queens size: ", size-1, "\nNumber of threads: ", num_threads ,"\n###########################\n" ,"\nNumber of sols: ",number_of_solutions, "\nTree size: " ,partial_tree_size,"\n\n")
end #caller

#function queens_mgpu_mcore_caller(::Val{size},::Val{cutoff_depth},::Val{num_threads}, ::Val{number_of_subproblems},subproblems) where {size, cutoff_depth, num_threads,number_of_subproblems}

function queens_mgpu_mcore_caller(size,cutoff_depth,num_threads, number_of_subproblems,subproblems) 

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

			Threads.@spawn begin
				println("THREAD: " * string(local_thread_id) * " has " * string(local_load) * " iterations")
				for j in 1:local_load

					s = local_thread_id*stride + j

					(local_number_of_solutions, local_partial_tree_size) = queens_tree_explorer(size, cutoff_depth, 1, subproblems[s][1]#=.subproblem_is_visited=#, subproblems[s][2]#=.subproblem_partial_permutation=#)
					thread_tree_size[local_thread_id+1] += local_partial_tree_size
					thread_num_sols[local_thread_id+1]  += local_number_of_solutions
				end
			end

		end
	end
	mcore_number_of_solutions = sum(thread_num_sols)
	mcore_tree_size = sum(thread_tree_size)
	#println(mcore_tree_size, mcore_number_of_solutions)
	return(mcore_number_of_solutions, mcore_tree_size)	
end #caller
