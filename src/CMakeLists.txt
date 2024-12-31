cmake_minimum_required(VERSION 3.18)

if(POLICY CMP0146)
	cmake_policy(SET CMP0146 OLD)
endif()

set(CMAKE_CXX_FLAGS "-O3")
set(CUDA_SEPARABLE_COMPILATION TRUE)
project(MBE_GPU)
find_package(CUDA QUIET REQUIRED)

add_subdirectory("third_party/cub" cub)

execute_process(
  COMMAND ${CUDA_NVCC_EXECUTABLE} CudaInfo.cu -o CudaInfo
  OUTPUT_VARIABLE Return_val
  ERROR_VARIABLE Err
  RESULT_VARIABLE Res
  WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}
)

if(NOT ${Res} EQUAL 0)
  message(FATAL_ERROR "NVCC command output: ${CudaInfo_output} ${Err} ${Res}")
endif()


execute_process(
  COMMAND ./CudaInfo -a
  OUTPUT_VARIABLE CudaArch
  ERROR_VARIABLE Err
  RESULT_VARIABLE Res
  WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}
)

if(NOT ${Res} EQUAL 0)
  message(FATAL_ERROR "Device architecture set failed: ${CudaArch} ${Err} ${Res}")
endif()

execute_process(
  COMMAND ./CudaInfo -s
  OUTPUT_VARIABLE NumOfSM
  ERROR_VARIABLE Err
  RESULT_VARIABLE Res
  WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}
)

if(NOT ${Res} EQUAL 0)
  message(FATAL_ERROR "Number of SMs set failed: ${NumOfSM} ${Err} ${Res}")
endif()

execute_process(
  COMMAND rm CudaInfo
  OUTPUT_VARIABLE Out
  ERROR_VARIABLE Err
  RESULT_VARIABLE Res
  WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}
)

if(NOT ${Res} EQUAL 0)
  message(FATAL_ERROR "remove CudaInfo failed: ${Out} ${Err} ${Res}")
endif()


math(EXPR NumOfSM "${NumOfSM} + 0")


set(CUDA_NVCC_FLAGS -gencode arch=compute_80,code=sm_80;-O3;-w)
# set(CUDA_NVCC_FLAGS -gencode ${CudaArch};-O3;-w)
add_definitions(-DMAX_SM=${NumOfSM})

message(STATUS "CUDA_NVCC_FLAGS set to: ${CUDA_NVCC_FLAGS}")
message(STATUS "Number of SMs is detected as : ${NumOfSM} ")

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

project(GMBEv2)
cuda_add_executable(
  GMBEv2  
  BicliqueFinder.cu BiGraph.cu main.cu Utility.cu IterFinderGpu.cu
)
target_compile_definitions(GMBEv2 PUBLIC -DPRUNE_EN -DNN=64)
target_link_libraries(GMBEv2 ${CUDA_cudadevrt_LIBRARY})
target_link_libraries(GMBEv2 CUB::CUB)

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
