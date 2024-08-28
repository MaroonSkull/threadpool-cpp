cmake_minimum_required(VERSION 3.14)
project(threadpool-cpp-add LANGUAGES CXX)

include("../../cmake/utils.cmake")
string(COMPARE EQUAL "${CMAKE_SOURCE_DIR}" "${CMAKE_CURRENT_SOURCE_DIR}" is_top_level)

if(is_top_level)
    find_package(threadpool-cpp REQUIRED)
endif()

set(sources main.cpp)
source_group(TREE "${CMAKE_CURRENT_SOURCE_DIR}" FILES ${sources})

add_executable(threadpool-cpp-add)
target_sources(threadpool-cpp-add PRIVATE ${sources})
target_link_libraries(threadpool-cpp-add PRIVATE threadpool-cpp::threadpool-cpp)

if(NOT is_top_level)
    win_copy_deps_to_target_dir(threadpool-cpp-add threadpool-cpp::threadpool-cpp)
endif()
