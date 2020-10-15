cmake_minimum_required(VERSION 2.8)
project(reduccion720)
find_package(OpenCV REQUIRED)
find_package(OpenMP REQUIRED)
include_directories( ${OpenCV_INCLUDE_DIRS} )
add_executable(reduccion720 reduccion720.cpp)
target_link_libraries(reduccion720 ${OpenCV_LIBS})
target_link_libraries(reduccion720 PUBLIC OpenMP::OpenMP_CXX)

#[[SET(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -pg")
SET(CMAKE_EXE_LINKER_FLAGS "${CMAKE_EXE_LINKER_FLAGS} -pg")
SET(CMAKE_SHARED_LINKER_FLAGS "${CMAKE_SHARED_LINKER_FLAGS} -pg") 
]]