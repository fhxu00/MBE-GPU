cmake_minimum_required(VERSION 3.18)

# Silence warnings about empty CUDA_ARCHITECTURES properties on example targets:
if(CMAKE_VERSION VERSION_GREATER_EQUAL 3.18)
	cmake_policy(SET CMP0104 OLD)
endif()
set(CMAKE_CXX_FLAGS "-O3")
set(CUDA_SEPARABLE_COMPILATION TRUE)
project(MBE_GPU)
find_package(CUDA QUIET REQUIRED)
add_subdirectory("third_party/cub" cub)

IF (GPU_TYPE STREQUAL A100)
  set(CUDA_NVCC_FLAGS -gencode arch=compute_80,code=sm_80;-O3;-w)
  add_definitions(-DMAX_SM=108)
ELSEIF (GPU_TYPE STREQUAL 2080TI)
  set(CUDA_NVCC_FLAGS -gencode arch=compute_75,code=sm_75;-O3;-w)
  add_definitions(-DMAX_SM=80)
ELSEIF (GPU_TYPE STREQUAL V100)
  set(CUDA_NVCC_FLAGS -gencode arch=compute_70,code=sm_70;-O3;-w)
  add_definitions(-DMAX_SM=68)
ELSEIF (GPU_TYPE STREQUAL 1080TI)
  set(CUDA_NVCC_FLAGS -gencode arch=compute_61,code=sm_61;-O3;-w)
  add_definitions(-DMAX_SM=28)
ELSE()
  message(FATAL_ERROR "Do not support the GPU_TYPE, you should revise the src/CMakeLists.txt to support the GPU_TYPE.")
ENDIF()


add_definitions(-DADV_UNION)
add_compile_options(-w)

# add_definitions(-DWARP_PER_BLOCK=16)

add_definitions(-DMAX_2_H_DEGREE_BOUND=0x40000)
add_definitions(-DMAX_DEGREE_BOUND=0x25000)
add_definitions(-DBLOCKS_PER_SM=1)
add_definitions(-D__CDPRT_SUPPRESS_SYNC_DEPRECATION_WARNING)

cuda_add_executable(
  MBE_GPU
  BicliqueFinder.cu BiGraph.cu main.cu Utility.cu IterFinderGpu.cu
)
target_compile_definitions(MBE_GPU PUBLIC -DPRUNE_EN)
target_link_libraries(MBE_GPU ${CUDA_cudadevrt_LIBRARY})
target_link_libraries(MBE_GPU CUB::CUB)

project(MBE_GPU_NOPRUNE)
cuda_add_executable(
  MBE_GPU_NOPRUNE
  BicliqueFinder.cu BiGraph.cu main.cu Utility.cu IterFinderGpu.cu
)
target_link_libraries(MBE_GPU_NOPRUNE ${CUDA_cudadevrt_LIBRARY})
target_link_libraries(MBE_GPU_NOPRUNE CUB::CUB)


project(MBE_GPU_8)
cuda_add_executable(
  MBE_GPU_8
  BicliqueFinder.cu BiGraph.cu main.cu Utility.cu IterFinderGpu.cu
)
target_compile_definitions(MBE_GPU_8 PUBLIC -DPRUNE_EN -DWARP_PER_BLOCK=8)
target_link_libraries(MBE_GPU_8 ${CUDA_cudadevrt_LIBRARY})
target_link_libraries(MBE_GPU_8 CUB::CUB)

project(MBE_GPU_24)
cuda_add_executable(
  MBE_GPU_24
  BicliqueFinder.cu BiGraph.cu main.cu Utility.cu IterFinderGpu.cu
)
target_compile_definitions(MBE_GPU_24 PUBLIC -DPRUNE_EN -DWARP_PER_BLOCK=24)
target_link_libraries(MBE_GPU_24 ${CUDA_cudadevrt_LIBRARY})
target_link_libraries(MBE_GPU_24 CUB::CUB)


project(MBE_GPU_32)
cuda_add_executable(
  MBE_GPU_32
  BicliqueFinder.cu BiGraph.cu main.cu Utility.cu IterFinderGpu.cu
)
target_compile_definitions(MBE_GPU_32 PUBLIC -DPRUNE_EN -DWARP_PER_BLOCK=32)
target_link_libraries(MBE_GPU_32 ${CUDA_cudadevrt_LIBRARY})
target_link_libraries(MBE_GPU_32 CUB::CUB)
