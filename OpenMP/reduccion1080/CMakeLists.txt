cmake_minimum_required(VERSION 2.8)
project(reduccion1080)
find_package(OpenCV REQUIRED)
find_package(OpenMP REQUIRED)
include_directories( ${OpenCV_INCLUDE_DIRS} )
add_executable(reduccion1080 reduccion1080.cpp)
target_link_libraries(reduccion1080 ${OpenCV_LIBS})
target_link_libraries(reduccion1080 PUBLIC OpenMP::OpenMP_CXX)

#[[SET(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -pg")
SET(CMAKE_EXE_LINKER_FLAGS "${CMAKE_EXE_LINKER_FLAGS} -pg")
SET(CMAKE_SHARED_LINKER_FLAGS "${CMAKE_SHARED_LINKER_FLAGS} -pg") 
]]