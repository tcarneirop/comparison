import sys 
import time
import completeEnum
import queens

if __name__ == "__main__" :

	if(len(sys.argv)>1):
		
		if(sys.argv[1] == "cr"):
			completeEnum.N = int(sys.argv[2])+1
			print("\n Starting the recursive search.\n\tN = %s." % (completeEnum.N-1))
			start_time = time.time()
			completeEnum.recdfs()
			elapsed_time = time.time() - start_time

		else:
			if(sys.argv[1] == "cnr"):
				completeEnum.N = int(sys.argv[2])+1
				print("Non recursive complete enumeration.\n\t N = %s." % (completeEnum.N-1))
				start_time = time.time()
				l_number_of_solutions,l_tree_size = completeEnum.nonRecDFS(completeEnum.N)
				elapsed_time = time.time() - start_time
				completeEnum.N = completeEnum.N - 1
				print("\n\tNumber of solutions: %s.\n\tTree size: %s.\n\tElapsed time: %s.\n\tNodes per sec: %s\n" % (l_number_of_solutions,l_tree_size,elapsed_time,l_tree_size/elapsed_time))
				
			else:
				if(sys.argv[1] == "cnpy"):
					completeEnum.N = int(sys.argv[2])
					print("Non-Recursive with numPY variables.\n\t N = %s." % (completeEnum.N))
					start_time = time.time()
					l_number_of_solutions,l_tree_size = completeEnum.BP_numPY_NonRecDFS(completeEnum.N)
					elapsed_time = time.time() - start_time
					print("\n\tNumber of solutions: %s.\n\tTree size: %s.\n\tElapsed time: %s.\n\tNodes per sec: %s\n" % (l_number_of_solutions,l_tree_size,elapsed_time,l_tree_size/elapsed_time))
				else:
					if(sys.argv[1] == "q"):

						start_time = time.time()
						l_number_of_solutions,l_tree_size = queens.queensNonRecDFS(int(sys.argv[2]))
						elapsed_time = time.time() - start_time
						print("Non-recursive queens.\n\t N = %s." % (int(sys.argv[2])))
						print("\n\tNumber of solutions: %s.\n\tTree size: %s.\n\tElapsed time: %s.\n\tNodes per sec: %s\n" % (l_number_of_solutions,l_tree_size,elapsed_time,l_tree_size/elapsed_time))
	else:
		print("\nWrong parameters\n")


