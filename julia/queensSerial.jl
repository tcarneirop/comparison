


##@TODO: Queens -- we receive the three one unity bigger than it should be. Lets see this problem afterwards.
###
mutable struct Subproblem

	subproblem_is_visited::Array{Int64}
 	subproblem_partial_permutation::Array{Int64}

end


mutable struct Metrics

  	number_of_solutions::Int64
	partial_tree_size::Int64

end

#verifies whether a given solution/incomplete solution is feasible
function queens_is_valid_configuration(board::Union{Number, AbstractArray{<:Number}}, roll)::Bool

	for i=2:roll-1
		if (board[i] == board[roll])
			return false
		end
	end

	ld = board[roll]
	rd = board[roll]

	for j=(roll-1):-1:2
		ld -= 1
		rd += 1
		if (board[j] == ld || board[j] == rd)
			return false
		end
	end

	return true
end ##queens_is_valid_conf



function queens_serial(size)

	__VOID__     = 0
	__VISITED__    = 1
	__N_VISITED__   = 0

	#obs: because the vector begins with 1 I need to use size+1 for N-Queens of size 'size'
	print("Starting N-Queens of size ")
	println(size-1)

	depth = 1
	tree_size = 0
	number_of_solutions = 0
	local_visited = zeros(Int64,size)
	local_permutation = zeros(Int64,size)

	println(local_visited)
	println(local_permutation)

	while true
		#%println(local_cycle)

		local_permutation[depth] = local_permutation[depth]+1

		if local_permutation[depth] == (size+1)
			local_permutation[depth] = __VOID__
		else
			if (local_visited[local_permutation[depth]] == 0 && queens_is_valid_configuration(local_permutation,depth))

				local_visited[local_permutation[depth]] = __VISITED__
				depth +=1
				tree_size+=1

				if depth == size+1 ##complete solution -- full, feasible and valid solution
					number_of_solutions+=1
					#my_print(local_cycle)
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

println("Number of solutions: ")
println(number_of_solutions)
println(tree_size)
end #queens serial

function queens_partial_search!(size, cutoff_depth)

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
                    push!(subproblems_pool, Subproblem(copy(local_visited), copy(local_permutation)))
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
	println(number_of_subproblems)

	metrics = Metrics(number_of_subproblems, tree_size)
	println(metrics)

	return (subproblems_pool, metrics)

end #queens partial


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
			if (local_visited[local_permutation[depth]] == 0 && queens_is_valid_configuration(local_permutation,depth))

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


function queens_caller(size,cutoff_depth,num_threads)

	print("Starting N-Queens of size ")
	println(size-1)
	#subproblems = [Subproblem(size) for i in 1:1000000]

	#partial search -- generate some feasible valid and incomplete solutions
	(subproblems, metrics) = @time queens_partial_search!(size,cutoff_depth)
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
	println("N-Queens size: ", size, "\nNumber of threads: ", num_threads ,"\n###########################\n" ,"\nNumber of sols: ",number_of_solutions, "\nTree size: " ,partial_tree_size,"\n\n")
end #caller



function main(ARGS)
	println(ARGS)
	mode = parse(Int64, ARGS[1])
	size = parse(Int64,ARGS[2])

	if mode == 1
		@time queens_serial(size+1)
	elseif mode == 2
		@time begin
			cutoff_depth = parse(Int64, ARGS[3])
			num_threads =  parse(Int64, ARGS[4])
			queens_caller(size+1,cutoff_depth+1, num_threads)
		end
	end

	#subproblems = Array{Subproblem, 1}(undef, 99999)
end

main(ARGS)
