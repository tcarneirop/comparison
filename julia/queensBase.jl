

#verifies whether a given solution/incomplete solution is feasible
function queens_is_valid_configuration(board, roll)
    #heron: why can board be a Number ? In the code, it is always accessed as an array.
    
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

function queens_tree_explorer(size, cutoff_depth, d, local_visited, local_permutation)
	@inbounds begin
		__VOID__     = 0
		__VISITED__    = 1
		__N_VISITED__   = 0

		#obs: because the vector begins with 1 I need to use size+1 for N-Queens of size 'size'

		depth = cutoff_depth + d
		tree_size = 0
		number_of_solutions = 0

		while true
			#%println(local_cycle)

			local_permutation[depth] = local_permutation[depth] + 1

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

			if depth < cutoff_depth + 1
				break
			end #if depth<2
		end
	end
	return number_of_solutions, tree_size

end #queens tree explorer