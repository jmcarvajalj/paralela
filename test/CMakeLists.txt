cmake_minimum_required(VERSION 2.8)
find_package(CUDA QUIET REQUIRED)

# Pass options to NVCC
set(
    CUDA_NVCC_FLAGS
    ${CUDA_NVCC_FLAGS};
    -O3 -gencode arch=compute_22,code=sm_22
    )
project(testing)
include_directories(${CMAKE_SOURCE_DIR}/sad)
#add_executable(f ${CMAKE_SOURCE_DIR}/sad/f.cpp)
cuda_add_executable(f ${CMAKE_SOURCE_DIR}/sad/f.cu)