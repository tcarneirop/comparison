function gpu_queens_tree_explorer!(::Val{size}, ::Val{cutoff_depth}, ::Val{number_of_subproblems}, 
                                   permutation_d, 
                                   controls_d, 
                                   tree_size_d, 
                                   number_of_solutions_d, 
                                   indexes_d) where {size, cutoff_depth, number_of_subproblems}
	@inbounds begin
		__VOID__      = 0
		__VISITED__   = 1
		__N_VISITED__ = 0

		#obs: because the vector begins with 1 I need to use size+1 for N-Queens of size 'size'
		index =  (blockIdx().x - 1) * blockDim().x + threadIdx().x
		#index = threadIdx().x

		if index<=number_of_subproblems
			indexes_d[index] = index
			stride_c = (index-1)*cutoff_depth

			local_visited     = MArray{Tuple{size+1},Int64}(undef)
			local_permutation = MArray{Tuple{size+1},Int64}(undef)

			local_visited     .= 0
			local_permutation .= 0

		#@OBS> so... I allocate on CPU memory for the cuda kernel...
		### then I get the values on GPU.
			for j in 1:cutoff_depth
				local_visited[j] = controls_d[stride_c+j]
				local_permutation[j] = permutation_d[stride_c+j]	
			end

			depth = cutoff_depth + 1
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
						depth += 1
						tree_size += 1

						if depth == size + 1 ##complete solution -- full, feasible and valid solution
							number_of_solutions += 1
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
			number_of_solutions_d[index] = number_of_solutions
			tree_size_d[index] = tree_size
		end #if
	end
return

end #queens tree explorer


##@OBS> this method gets the information from the Subproblem and put them into two vectors.
#### it is easier to work on gpu like this...
function gpu_queens_subproblems_organizer!(cutoff_depth, num_subproblems, prefixes, controls,subproblems)

	for sub in 0:num_subproblems-1
		stride = sub*cutoff_depth
		for j in 1:cutoff_depth
			prefixes[stride+j] = subproblems[sub+1][2][j] # subproblem_partial_permutation
			controls[stride+j] = subproblems[sub+1][1][j] # subproblem_is_visited
		end
	end

end


function queens_sgpu_caller(::Val{size}, ::Val{cutoff_depth}, ::Val{__BLOCK_SIZE_}) where {size, cutoff_depth, __BLOCK_SIZE_}

	#__BLOCK_SIZE_ = 1024

	print("Starting single-GPU-based N-Queens of size ")
	println(size-1)

	for device in CUDA.devices()
		@show capability(device)
	end

	#subproblems = [Subproblem(size) for i in 1:1000000]

	#partial search -- generate some feasible valid and incomplete solutions
	(subproblems, number_of_subproblems, partial_tree_size) = @time queens_partial_search!(Val(size), Val(cutoff_depth))
	#end of the partial search

	number_of_solutions = 0
	#metrics.number_of_solutions = 0

	indexes_h = subpermutation_h = zeros(Int32, number_of_subproblems)
	subpermutation_h = zeros(Int64, cutoff_depth*number_of_subproblems)
	controls_h = zeros(Int64, cutoff_depth*number_of_subproblems)
	number_of_solutions_h = zeros(Int64, number_of_subproblems)
	tree_size_h = zeros(Int64, number_of_subproblems)

	gpu_queens_subproblems_organizer!(cutoff_depth, number_of_subproblems, subpermutation_h, controls_h, subproblems)

	#### the subpermutation_d is the memory allocated to keep all subpermutations and the control vectors...
	##### Maybe I could have done it in a smarter way...
	subpermutation_d      = CuArray{Int64}(undef,  cutoff_depth*number_of_subproblems)
	controls_d            = CuArray{Int64}(undef,  cutoff_depth*number_of_subproblems)

	#### Tree size and number of solutions is to get the metrics from the search.
	indexes_d = CUDA.zeros(Int32,number_of_subproblems)
	number_of_solutions_d = CUDA.zeros(Int64, number_of_subproblems)
	tree_size_d = CUDA.zeros(Int64,number_of_subproblems)

	# copy from the CPU to the GPU
	copyto!(subpermutation_d, subpermutation_h)
	# copy from the CPU to the GPU
	copyto!(controls_d, controls_h)

	num_blocks = ceil(Int, number_of_subproblems/__BLOCK_SIZE_)

	@info "Number of subproblems:", number_of_subproblems, " - Number of blocks:  ", num_blocks

    @cuda threads=__BLOCK_SIZE_ blocks=num_blocks gpu_queens_tree_explorer!(Val(size),Val(cutoff_depth), Val(number_of_subproblems), subpermutation_d, controls_d, tree_size_d, number_of_solutions_d, indexes_d)

    #from de gpu to the cpu
	copyto!(number_of_solutions_h, number_of_solutions_d)
	#from de gpu to the cpu
	copyto!(tree_size_h, tree_size_d)

	copyto!(indexes_h, indexes_d)
	number_of_solutions = sum(number_of_solutions_h)
	partial_tree_size += sum(tree_size_h)

	#print("\n\n")
	#print(indexes_h)

	println("\n###########################")
	println("N-Queens size: ", size-1, "\n###########################\n" ,"\nNumber of sols: ",number_of_solutions, "\nTree size: " ,partial_tree_size,"\n\n")
end #caller





function get_cpu_load(percent::Float64, num_subproblems::Int64)::Int64
    return floor(Int64,num_subproblems*percent)
end


function get_load_each_gpu(gpu_load::Int64, num_gpus::Int64, device_load )

	for device in 1:num_gpus
		device_load[device] = floor(Int64, gpu_load/num_gpus)
		if(device == num_gpus)
			device_load[device]+= gpu_load%num_gpus
		end
	end

end ###



function queens_mgpu_mcore_caller(::Val{size}, ::Val{cutoff_depth}, ::Val{__BLOCK_SIZE_}, ::Val{num_gpus}, ::Val{cpup}, ::Val{num_threads}) where {size, cutoff_depth, __BLOCK_SIZE_, num_gpus,cpup}
	
	println("Starting multi-GPU-mcore N-Queens of size ",size-1)
	
	for device in CUDA.devices()
		@show capability(device)
	end

	#subproblems = [Subproblem(size) for i in 1:1000000]

	#partial search -- generate some feasible valid and incomplete solutions
	(subproblems, number_of_subproblems, partial_tree_size) = @time queens_partial_search!(Val(size), Val(cutoff_depth))
	#end of the partial search

	number_of_solutions = 0
	#metrics.number_of_solutions = 0

	indexes_h = subpermutation_h = zeros(Int32, number_of_subproblems)
	subpermutation_h = zeros(Int64, cutoff_depth*number_of_subproblems)
	controls_h = zeros(Int64, cutoff_depth*number_of_subproblems)
	number_of_solutions_h = zeros(Int64, number_of_subproblems)
	tree_size_h = zeros(Int64, number_of_subproblems)

	gpu_queens_subproblems_organizer!(cutoff_depth, number_of_subproblems, subpermutation_h, controls_h, subproblems)


	cpu_load = get_cpu_load(cpup, number_of_subproblems)
    gpu_load = number_of_subproblems - cpu_load
    device_load = zeros(Int64, num_gpus)
    get_load_each_gpu(gpu_load, num_gpus, device_load)


    println("\nTotal load: ",number_of_subproblems , "\nTotal CPU load: ", cpu_load ,"  - CPU percent: ", cpup , " - GPU load: ", gpu_load);
    println("\nLoad of each GPU: ");
    for device in 1:num_gpus
    	println("Device - ", device, " - Load: ", device_load[device])
    end

	@sync begin
		for gpu_dev in 1:num_gpus
			@async begin
				device!(gpu_dev)
				# do work on GPU 0 here
			end
		end
		@async begin
			#problem size, cutoff, num threads for the mcore part, number of subproblems and the pool
			queens_mgpu_mcore_mcore_caller(size,cutoff_depth,num_threads,cpu_load,subproblems) 
		end
	end

end




#