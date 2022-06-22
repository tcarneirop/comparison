

##@TODO: Queens -- we receive the three one unity bigger than it should be. Lets see this problem afterwards.
###
mutable struct Subproblem

	subproblem_is_visited::Array{Int64}
 	subproblem_partial_permutation::Array{Int64}

	Subproblem(size) = new(zeros(Int64,size), zeros(Int64,size))

end

function setVisited(s::Subproblem, visited_::Array{Int64,1})
	s.subproblem_is_visited = visited_;
end
function setPermutation(s::Subproblem, permutation_::Array{Int64,1})
	s.subproblem_partial_permutation = permutation_;
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

function queens_partial_search!(size, cutoff_depth, subproblems_pool::AbstractArray{Subproblem,N} where N)::Metrics

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

				if depth == cutoff_depth+1 ##complete solution -- full, feasible and valid solution
					number_of_subproblems+=1
					setPermutation(subproblems_pool[number_of_subproblems], local_permutation)
					setVisited(subproblems_pool[number_of_subproblems], local_visited)
					#println("Depth: ", depth, " Subproblem ", number_of_subproblems)
					println(subproblems_pool[number_of_subproblems]);
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

	println(subproblems_pool[4])
	metrics = Metrics(tree_size , number_of_subproblems)
	println(metrics)
	return metrics
end

println("Number of solutions: ")
println(number_of_solutions)
println(tree_size)
end #queens serial


function queens_tree_explorer(size,cutoff_depth, s::Subproblem)::Metrics

	__VOID__     = 0
	__VISITED__    = 1
	__N_VISITED__   = 0

	#obs: because the vector begins with 1 I need to use size+1 for N-Queens of size 'size'

	depth = cutoff_depth
	tree_size = 0
	number_of_solutions = 0
	local_visited = s.subproblem_is_visited
	local_permutation = s.subproblem_partial_permutation

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

		if depth < cutoff_depth
			break
		end #if depth<2


	end
end

println("Number of solutions: ")
println(number_of_solutions)
println(tree_size)
end #queens serial


function queens_caller(size,cutoff_depth)

	print("Starting N-Queens of size ")
	println(size-1)
	subproblems = [Subproblem(size) for i in 1:100]

	metrics = queens_partial_search!(size,cutoff_depth,subproblems)
	number_of_subproblems = metrics.number_of_solutions
	partial_tree_size = metrics.partial_tree_size

	#println(subproblems[1])
	metrics.number_of_solutions = 0

	#we parallelize it here
	#for subp in subproblems
	#	metrics+= queens_tree_explorer(size,cutoff_depth, subproblems[1])
	#end

	println(metrics)
end



println(ARGS)
size = parse(Int64,ARGS[1])
cutoff_depth = parse(Int64, ARGS[2])

queens_caller(size+1,cutoff_depth+1)
#subproblems = Array{Subproblem, 1}(undef, 99999)
