

##@TODO: Queens -- we receive the three one unity bigger than it should be. Lets see this problem afterwards.
###
struct Subproblem

	subproblem_is_visited::Array{Int64,1}
 	subproblem_partial_permutation::Array{Int64,1}


	setVisited(visited_::Array{Int64,1}) = ( subproblem_is_visited = visited_)
	setPermutation(permutation_::Array{Int64,1}) = (	subproblem_partial_permutation = permutation_)


end

struct Metrics

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

	@time begin
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
end

println("Number of solutions: ")
println(number_of_solutions)
println(tree_size)
end #queens serial


function queens_partial_search(size, cutoff_depth, subproblems_pool::AbstractArray{Subproblem})::Metrics

	__VOID__     = 0
	__VISITED__    = 1
	__N_VISITED__   = 0

	#obs: because the vector begins with 1 I need to use size+1 for N-Queens of size 'size'
	print("Starting N-Queens of size ")
	println(size-1)
	print("Partial search until cutoff ")
	println(cutoff_depth)


	depth = 1
	tree_size = 0
	number_of_subproblems = 0

	local_visited = zeros(Int64,size)
	local_permutation = zeros(Int64,size)

	println(local_visited)
	println(local_permutation)

	@time begin
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

				if depth == cutoff_depth ##complete solution -- full, feasible and valid solution
					number_of_subproblems+=1
					subproblems[number_of_subproblems].setPermutation(local_permutation)
					subproblems[number_of_subproblems].setVisited(local_visited)
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

		if depth < cutoff_depth
			break
		end #if depth<2
	end

	println(subproblems)
	metrics = Metrics(tree_size , number_of_subproblems)
	println(metrics)
	return metrics


end

println("Number of solutions: ")
println(number_of_solutions)
println(tree_size)
end #queens serial


println(ARGS)
size = parse(Int64,ARGS[1])
cutoff_depth = parse(Int64, ARGS[2])

subproblems = Array{Subproblem, 1}(undef, 99999)

queens_partial_search(size+1,cutoff_depth,subproblems)
