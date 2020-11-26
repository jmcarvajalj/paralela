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
include_directories(/content/paralela/CUDA/reduccion4k)
add_executable(reduccion4k /content/paralela/CUDA/reduccion4k/reduccion4k.cu)
target_link_libraries(reduccion4k ${OpenCV_LIBS})
target_link_libraries(reduccion4k ${CUDA_LIBS})


