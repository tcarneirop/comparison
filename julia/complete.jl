let

__VOID__     = 0 
__VISITED__    = 1
__N_VISITED__   = 0
size   = 13

#zeros(Int8,5)


depth = 1
tree_size = 0
number_of_solutions = 0
local_visited = zeros(Int64,size+2)
local_cycle = zeros(Int64,size+2)

#fill!(local_visited, 0)
#fill!(local_cycle, -1)


println(local_visited)
println(local_cycle)

println("Starting")

println(size-1)

@time begin
while true

	#println(local_cycle)
	
	local_cycle[depth] = local_cycle[depth]+1

	#println(local_cycle)

	if local_cycle[depth] == (size+1)
		local_cycle[depth] = __VOID__

	elseif (local_visited[local_cycle[depth]] == 0 ) 
			
			local_visited[local_cycle[depth]] = __VISITED__
			depth +=1
			tree_size+=1
			
			if depth == size+1
				number_of_solutions+=1
			else
				continue
			end 
		else
			continue
	end

	depth -= 1
	local_visited[local_cycle[depth]] = __N_VISITED__
	
	if depth < 2 
		break
	end
end
end

println("Number of solutions: ")
println(number_of_solutions)
println(tree_size)
end