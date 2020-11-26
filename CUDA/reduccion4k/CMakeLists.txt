cmake_minimum_required(VERSION 2.8)
project(testing)
find_package(OpenCV REQUIRED)
include_directories( ${OpenCV_INCLUDE_DIRS} )
include_directories(/content/paralela/Tests)
add_executable(reduccion4k /content/paralela/Tests/reduccion4k.cpp)
target_link_libraries(reduccion4k ${OpenCV_LIBS})

