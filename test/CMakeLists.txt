cmake_minimum_required(VERSION 2.8)
find_package(OpenCV REQUIRED)
# Pass options to NVCC
set(
    CUDA_NVCC_FLAGS
    ${CUDA_NVCC_FLAGS};
    -O3 -gencode arch=compute_22,code=sm_22
    )
project(testing)
include_directories( ${CUDA_INCLUDE_DIRS} )
include_directories( ${OpenCV_INCLUDE_DIRS} )
include_directories(${CMAKE_SOURCE_DIR}/sad)
#add_executable(f ${CMAKE_SOURCE_DIR}/sad/f.cpp)
cuda_add_executable(f ${CMAKE_SOURCE_DIR}/sad/f.cu)
target_link_libraries(reduccion1080 ${OpenCV_LIBS})
target_link_libraries(reduccion1080 ${CUDA_LIBS})
