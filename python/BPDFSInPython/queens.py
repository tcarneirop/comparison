
#import numpy as np

def handleSolution(board,size):

	print("\n Vetor: ")
	coluna = 0

	for i in range(0,size):
		print(board[i],)

	for i in range(0,size):
		coluna = board[i]

		for j in range(0,size):
			if(j==coluna):
				print(" %s " % ("Q"),)
			else:
				print(" %s " % ("-"),)
		print("\n")
  

def stillLegal(board, r):

	ret = False
	ret2 = False

	# Check vertical
	for i in range(0,r):
		if(board[i] == board[r]): 
			return False;

  # Check diagonals
	ld = board[r];  #left diagonal columns
	rd = board[r];  #right diagonal columns
	

	for a in range(r-1, -1, -1):
		ld = ld - 1
		rd = rd + 1
		ret = (board[a] == ld)

		ret2 = (board[a] == rd)

		if ret is True:
			return False;
		
		elif ret2 is True:
			return False;

	return True


def queensNonRecDFS(size):



	depth = 0
	tree_size = 0
	number_of_solutions = 0
	local_visited = []
	local_board = []
	__VOID__      = -1
	__VISITED__   = 1
	__N_VISITED__ = 0

	#Initialization#
	for i in range(0,size):
		local_visited.append(False)

	for i in range(0,size):
		local_board.append(__VOID__)	

	depth = 0

	while True:

		local_board[depth] = local_board[depth]+1

		if local_board[depth] == size:
			local_board[depth] = __VOID__


		else:
			if ( stillLegal(local_board,depth) and (local_visited[local_board[depth]] is False)):
				
		
				print(stillLegal(local_board,depth))

				local_visited[local_board[depth]] = __VISITED__
				depth = depth + 1
				tree_size=  tree_size + 1

				if depth == size:
					number_of_solutions= number_of_solutions + 1
					handleSolution(local_board,size)

				else:
					continue
			else:
				continue

		depth = depth - 1
		local_visited[local_board[depth]] = __N_VISITED__
		
		if depth < 0  :
			break

	return number_of_solutions, tree_size 		


