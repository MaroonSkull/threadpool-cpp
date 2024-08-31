cmake_minimum_required(VERSION 3.15)

include(cmake/utils.cmake)
include(GNUInstallDirs)

get_version(lib_version)

message(STATUS "project version: ${lib_version}")

project(threadpool-cpp
    VERSION ${lib_version}
    DESCRIPTION "Template for C++ library built with CMake"
    LANGUAGES CXX)

#----------------------------------------------------------------------------------------------------------------------
# general settings and options
#----------------------------------------------------------------------------------------------------------------------


string(COMPARE EQUAL "${CMAKE_SOURCE_DIR}" "${CMAKE_CURRENT_SOURCE_DIR}" is_top_level)

# THREADPOOL_CPP_SHARED_LIBS option (undefined by default) can be used to force shared/static build
option(THREADPOOL_CPP_BUILD_TESTS "Build threadpool-cpp tests" OFF)
option(THREADPOOL_CPP_BUILD_EXAMPLES "Build threadpool-cpp examples" OFF)
option(THREADPOOL_CPP_BUILD_DOCS "Build threadpool-cpp documentation" OFF)
option(THREADPOOL_CPP_INSTALL "Generate target for installing threadpool-cpp" ${is_top_level})
set_if_undefined(THREADPOOL_CPP_INSTALL_CMAKEDIR "${CMAKE_INSTALL_LIBDIR}/cmake/threadpool-cpp" CACHE STRING
    "Install path for threadpool-cpp package-related CMake files")

if(DEFINED THREADPOOL_CPP_SHARED_LIBS)
    set(BUILD_SHARED_LIBS ${THREADPOOL_CPP_SHARED_LIBS})
endif()

if(NOT DEFINED CMAKE_BUILD_TYPE AND NOT DEFINED CMAKE_CONFIGURATION_TYPES)
    set(CMAKE_BUILD_TYPE Release CACHE STRING "Build type" FORCE)
    set_property(CACHE CMAKE_BUILD_TYPE PROPERTY STRINGS "Debug" "Release" "MinSizeRel" "RelWithDebInfo")
endif()

set_if_undefined(CMAKE_CXX_VISIBILITY_PRESET hidden)
set_if_undefined(CMAKE_VISIBILITY_INLINES_HIDDEN ON)

add_library(threadpool-cpp) # initialized below
add_library(threadpool-cpp::threadpool-cpp ALIAS threadpool-cpp)

#----------------------------------------------------------------------------------------------------------------------
# threadpool-cpp dependencies
#----------------------------------------------------------------------------------------------------------------------

# Search for your dependencies here

#----------------------------------------------------------------------------------------------------------------------
# threadpool-cpp sources
#----------------------------------------------------------------------------------------------------------------------

include(GenerateExportHeader)
set(export_file_name "export_shared.h")

if(NOT BUILD_SHARED_LIBS)
    set(export_file_name "export_static.h")
endif()

generate_export_header(threadpool-cpp EXPORT_FILE_NAME include/threadpool-cpp/${export_file_name})

set(sources
    include/threadpool-cpp/export.h
    include/threadpool-cpp/threadpool-cpp.h
    src/threadpool-cpp.cpp)
source_group(TREE "${CMAKE_CURRENT_SOURCE_DIR}" FILES ${sources})

#----------------------------------------------------------------------------------------------------------------------
# threadpool-cpp target
#----------------------------------------------------------------------------------------------------------------------

include(CMakePackageConfigHelpers)

target_sources(threadpool-cpp PRIVATE ${sources})
target_compile_definitions(threadpool-cpp PUBLIC "$<$<NOT:$<BOOL:${BUILD_SHARED_LIBS}>>:THREADPOOL_CPP_STATIC_DEFINE>")

target_include_directories(threadpool-cpp
    PUBLIC
        "$<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}/include>"
        "$<BUILD_INTERFACE:${CMAKE_CURRENT_BINARY_DIR}/include>")

set_target_properties(threadpool-cpp PROPERTIES
    SOVERSION ${PROJECT_VERSION_MAJOR}
    VERSION ${PROJECT_VERSION})

if(THREADPOOL_CPP_INSTALL AND NOT CMAKE_SKIP_INSTALL_RULES)
    configure_package_config_file(cmake/threadpool-cpp-config.cmake.in threadpool-cpp-config.cmake
        INSTALL_DESTINATION "${THREADPOOL_CPP_INSTALL_CMAKEDIR}")

    write_basic_package_version_file(threadpool-cpp-config-version.cmake
        COMPATIBILITY SameMajorVersion)

    install(TARGETS threadpool-cpp EXPORT threadpool-cpp_export
        RUNTIME COMPONENT threadpool-cpp
        LIBRARY COMPONENT threadpool-cpp NAMELINK_COMPONENT threadpool-cpp-dev
        ARCHIVE COMPONENT threadpool-cpp-dev
        INCLUDES DESTINATION "${CMAKE_INSTALL_INCLUDEDIR}")
    install(DIRECTORY include/
        TYPE INCLUDE
        COMPONENT threadpool-cpp-dev)
    install(FILES "${CMAKE_CURRENT_BINARY_DIR}/include/threadpool-cpp/${export_file_name}"
        COMPONENT threadpool-cpp-dev
        DESTINATION "${CMAKE_INSTALL_INCLUDEDIR}/threadpool-cpp")

    set(targets_file "threadpool-cpp-shared-targets.cmake")

    if(NOT BUILD_SHARED_LIBS)
        set(targets_file "threadpool-cpp-static-targets.cmake")
    endif()

    install(EXPORT threadpool-cpp_export
        COMPONENT threadpool-cpp-dev
        FILE "${targets_file}"
        DESTINATION "${THREADPOOL_CPP_INSTALL_CMAKEDIR}"
        NAMESPACE threadpool-cpp::)

    install(FILES
        "${CMAKE_CURRENT_BINARY_DIR}/threadpool-cpp-config.cmake"
        "${CMAKE_CURRENT_BINARY_DIR}/threadpool-cpp-config-version.cmake"
        COMPONENT threadpool-cpp-dev
        DESTINATION "${THREADPOOL_CPP_INSTALL_CMAKEDIR}")

    if(MSVC)
        set(pdb_file "")
        set(pdb_file_destination "")

        if(BUILD_SHARED_LIBS)
            set(pdb_file "$<TARGET_PDB_FILE:threadpool-cpp>")
            set(pdb_file_destination "${CMAKE_INSTALL_BINDIR}")
        else()
            # TARGET_PDB_FILE does not work for pdb file generated for static library build, determining it manually
            set(pdb_file "$<TARGET_FILE_DIR:threadpool-cpp>/$<TARGET_FILE_PREFIX:threadpool-cpp>$<TARGET_FILE_BASE_NAME:threadpool-cpp>.pdb")
            set(pdb_file_destination "${CMAKE_INSTALL_LIBDIR}")
        endif()

        install(FILES "${pdb_file}"
            COMPONENT threadpool-cpp-dev
            CONFIGURATIONS Debug RelWithDebInfo
            DESTINATION "${pdb_file_destination}"
            OPTIONAL)
    endif()
endif()

#----------------------------------------------------------------------------------------------------------------------
# other targets
#----------------------------------------------------------------------------------------------------------------------

if(THREADPOOL_CPP_BUILD_TESTS)
    enable_testing()
    add_subdirectory(tests)
endif()

if(THREADPOOL_CPP_BUILD_EXAMPLES)
    add_subdirectory(examples)
endif()

if(THREADPOOL_CPP_BUILD_DOCS)
    find_package(Doxygen REQUIRED)
    doxygen_add_docs(docs include)
endif()
