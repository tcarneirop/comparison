using CUDA
using StaticArrays

# Base -> Serial / (Parallel -> Multicore / CUDA)

include("queensBase.jl")    
include("queensSerial.jl")
include("queensParallel.jl") # common definitions or Multicore and GPU
include("queensMulticore.jl")
include("queensCUDA.jl")

macro serial(size)
	@time queens_serial(Val(size+1))
end

macro multicore(size, cutoff_depth, num_threads)
	@time queens_mcore_caller(Val(size+1), Val(cutoff_depth+1), Val(num_threads))
end

macro gpucuda(size, cutoff_depth, __BLOCK_SIZE_)
	@time queens_sgpu_caller(Val(size+1), Val(cutoff_depth+1), Val(__BLOCK_SIZE_))
end

macro setHeap()
	###setting up 1GB heap per device
	for gpus in  1:length(CUDA.devices())
		
		println("########################################################################");
		println("Setting heap on device ", gpus-1, " :");
		device!(gpus-1)
		synchronize()
		CUDA.@check @ccall CUDA.libcudart().cudaDeviceSetLimit(CUDA.cudaLimitMallocHeapSize::CUDA.cudaLimit, 1000000000::Csize_t)::CUDA.cudaError_t
		synchronize()
		println("########################################################################");			
	end		
end

macro deviceReset()
	for gpus in  1:length(CUDA.devices())
		println("########################################################################");
		println("Cleaning memory on device ", gpus-1, " :");
		device!(gpus-1)
		synchronize() 
		CUDA.@check @ccall CUDA.libcudart().cudaDeviceReset()::CUDA.cudaError_t
		synchronize()
		println("########################################################################");			
	end
end

macro mcoremgpucuda(size, cutoff_depth, __BLOCK_SIZE_, num_gpus, cpup, num_threads)
	@time queens_mgpu_mcore_caller(Val(size+1), Val(cutoff_depth+1), Val(__BLOCK_SIZE_), Val(num_gpus), Val(cpup), Val(num_threads))
end
