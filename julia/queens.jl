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

macro mcoremgpucuda(size, cutoff_depth, __BLOCK_SIZE_, cpup)
	@time queens_mgpu_mcore_caller(Val(size+1), Val(cutoff_depth+1), Val(__BLOCK_SIZE_), Val(cpup))
end
