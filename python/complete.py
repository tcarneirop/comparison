import numpy as np

N = 0
depth = 0
number_of_solutions = 0
tree_size = 0
visited = []
cycle = []
maximum_depth  = 20
#starting all elements with zero


def print_cycle(cycle,number_of_solutions):
	print("Solution number %s. \n" %(number_of_solutions))
	for city in range(0,N):
		print(" %s " % (cycle[city]))



def branch(city):
	global depth
	global tree_size
	global number_of_solutions
	# print("%s - \n" % (city))
	# print("%s - \n" % (depth))
	
	visited[city] = True
	depth += 1
	cycle.append(city)
	
	if depth == N :
		number_of_solutions+=1
		# tree_size+=1
		# print("\nAlor, meu patrao\n")
		# print_cycle(cycle, number_of_solutions)
	else :
		for it in range(1,N):
			if visited[it] == False:
				tree_size += 1
				branch(it)

	visited[city] = False
	cycle.pop()
	depth -= 1



def recdfs():
	global depth
	global tree_size

	for i in range(0,N):
		visited.append(False) 
	
	#fixing 0 as the first element of the permutation
	visited[depth] = True
	cycle.append(0)
	depth += 1

	for city in range(1,N):
		tree_size += 1
		branch(city)


def nonRecDFS(size):

	depth = 0
	tree_size = 0
	number_of_solutions = 0
	local_visited = []
	local_cycle = []
	__VOID__      = -1
	__VISITED__   = 1
	__N_VISITED__ = 0

	#Initialization#
	for i in range(0,size):
		local_visited.append(False)

	for i in range(0,size):
		local_cycle.append(__VOID__)	

    #
    # Fixing the starting city 
    #
	depth = 0
	local_visited[depth] = True
	local_cycle[depth] = 0
	depth += 1

	while True:

		local_cycle[depth] = local_cycle[depth]+1

		if local_cycle[depth] == size:
			local_cycle[depth] = __VOID__
		else:
			if not local_visited[local_cycle[depth]] :
				
				local_visited[local_cycle[depth]] = __VISITED__
				depth +=1
				tree_size+=1
				if depth == size:
					number_of_solutions+=1
					# print_cycle(local_cycle,number_of_solutions)
				else:
					continue
			else:
				continue

		depth -= 1
		local_visited[local_cycle[depth]] = __N_VISITED__
		
		if depth < 1  :
			break

	return number_of_solutions, tree_size 		


def BPNonRecDFS(size):

	depth = 0
	tree_size = 0
	number_of_solutions = 0
	local_visited = []
	local_cycle = []
	__VOID__      = -1
	__VISITED__   = 1
	__N_VISITED__ = 0

	#Initialization#
	for i in range(0,size):
		local_visited.append(False)

	for i in range(0,size):
		local_cycle.append(__VOID__)	

    #
    # Fixing the starting city 
    #
	depth = 0
	local_visited[depth] = True
	local_cycle[depth] = 0
	depth += 1

	while True:

		local_cycle[depth] = local_cycle[depth]+1

		if local_cycle[depth] == size:
			local_cycle[depth] = __VOID__
		else:
			if not (local_visited[local_board[depth]]) :
				
				local_visited[local_cycle[depth]] = __VISITED__
				depth +=1
				tree_size+=1

				if depth == size:
					number_of_solutions+=1
					# print_cycle(local_cycle,number_of_solutions)
				else:
					continue
			else:
				continue

		depth -= 1
		local_visited[local_cycle[depth]] = __N_VISITED__
		
		if depth < 1  :
			break

	return number_of_solutions, tree_size 		
#######################################################################################
#######################################################################################
#######################################################################################


def BP_numPY_NonRecDFS(size):

	depth = 0
	tree_size = 0
	number_of_solutions = 0
	local_visited = np.empty(N,dtype=np.int16)
	local_cycle = np.empty(N,dtype=np.int16)
	__VOID__      = -1
	__VISITED__   = 1
	__N_VISITED__ = 0

	#Initialization#
	for i in range(0,size):
		local_visited[i] = False 

	for i in range(0,size):
		local_cycle[i] = __VOID__

    #
    # Fixing the starting city 
    #
	depth = 0
	local_visited[depth] = True
	local_cycle[depth] = 0
	depth += 1

	while True:

		local_cycle[depth] = local_cycle[depth]+1

		if local_cycle[depth] == size:
			local_cycle[depth] = __VOID__
		else:
			if not local_visited[local_cycle[depth]] :
				
				local_visited[local_cycle[depth]] = __VISITED__
				depth +=1
				tree_size+=1

				if depth == size:
					number_of_solutions+=1
					# print_cycle(local_cycle,number_of_solutions)
				else:
					continue
			else:
				continue

		depth -= 1
		local_visited[local_cycle[depth]] = __N_VISITED__
		
		if depth < 1  :
			break

	return number_of_solutions, tree_size 		
