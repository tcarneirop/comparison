
function complete_enumeration(size)

	__VOID__     = 0
	__VISITED__    = 1
	__N_VISITED__   = 0

	#obs: because the vector begins with 1 I need to use size+1 for N-Queens of size 'size'
	print("Complete enumeration of a permutation of size ")
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
			if (local_visited[local_permutation[depth]] == 0)

				local_visited[local_permutation[depth]] = __VISITED__
				depth +=1
				tree_size+=1

				if depth == size+1 ##complete solution -- full and valid permutation
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


println(ARGS)
size = parse(Int64,ARGS[1])
complete_enumeration(size+1)
