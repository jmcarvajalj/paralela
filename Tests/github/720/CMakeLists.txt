cmake_minimum_required(VERSION 2.8)
project(testing)
find_package(CUDA QUIET REQUIRED)

# Pass options to NVCC
set(
    CUDA_NVCC_FLAGS
    ${CUDA_NVCC_FLAGS};
    -O3 -gencode arch=compute_22,code=sm_22
    )
find_package(OpenCV REQUIRED)
include_directories( ${OpenCV_INCLUDE_DIRS} )
include_directories( ${CUDA_INCLUDE_DIRS} )
include_directories(/content/paralela/CUDA/reduccion720)
add_executable(reduccion720 /content/paralela/CUDA/reduccion720/reduccion720.cu)
target_link_libraries(reduccion720 ${OpenCV_LIBS})
target_link_libraries(reduccion720 ${CUDA_LIBS})

