# set_if_undefined(<variable> [<value>]...)
#
# Set variable if it is not defined.
macro(set_if_undefined variable)
    if(NOT DEFINED "${variable}")
        set("${variable}" ${ARGN})
    endif()
endmacro()

# win_copy_deps_to_target_dir(<target> [<target-dep>]...)
#
# Creates custom command to copy runtime dependencies to target's directory after building the target.
# Function does nothing if platform is not Windows and ignores all dependencies except shared libraries.
# On CMake 3.21 or newer, function uses TARGET_RUNTIME_DLLS generator expression to obtain list of runtime
# dependencies. Specified dependencies (if any) are still used to find and copy PDB files for debug builds.
function(win_copy_deps_to_target_dir target)
    if(NOT WIN32)
        return()
    endif()

    set(has_runtime_dll_genex NO)

    if(CMAKE_MAJOR_VERSION GREATER 3 OR CMAKE_MINOR_VERSION GREATER_EQUAL 21)
        set(has_runtime_dll_genex YES)

        add_custom_command(TARGET ${target} POST_BUILD
            COMMAND ${CMAKE_COMMAND} -P "${threadpool-cpp_SOURCE_DIR}/cmake/silent_copy.cmake"
                "$<TARGET_RUNTIME_DLLS:${target}>" "$<TARGET_FILE_DIR:${target}>"
            COMMAND_EXPAND_LISTS)
    endif()

    foreach(dep ${ARGN})
        get_target_property(dep_type ${dep} TYPE)

        if(dep_type STREQUAL "SHARED_LIBRARY")
            if(NOT has_runtime_dll_genex)
                add_custom_command(TARGET ${target} POST_BUILD
                    COMMAND ${CMAKE_COMMAND} -P "${threadpool-cpp_SOURCE_DIR}/cmake/silent_copy.cmake" 
                        "$<TARGET_FILE:${dep}>" "$<TARGET_PDB_FILE:${dep}>" "$<TARGET_FILE_DIR:${target}>"
                    COMMAND_EXPAND_LISTS)
            else()
                add_custom_command(TARGET ${target} POST_BUILD
                    COMMAND ${CMAKE_COMMAND} -P "${threadpool-cpp_SOURCE_DIR}/cmake/silent_copy.cmake"
                        "$<TARGET_PDB_FILE:${dep}>" "$<TARGET_FILE_DIR:${target}>"
                    COMMAND_EXPAND_LISTS)
            endif()
        endif()
    endforeach()
endfunction()

# get_version(OUTPUT)
#
# Get project version.
# If VERSION file exists, read it. Otherwise, use `git describe` command.
# If version cannot be determined via git, set version to "v0.0.0"
#
# OUTPUT: project version
#
# Example:
# get_version(VERSION)
# message(STATUS "project version: ${VERSION}")
#
# Version format: vMAJOR.MINOR.PATCH
#
# Optional dependencies:
# - git
function(get_version OUTPUT)
    set(MESSAGE_ERROR_PREFIX "[get_version] could not determine project version:")
    set(VERSION_FILE_PATH "${CMAKE_CURRENT_SOURCE_DIR}/VERSION")
    if(EXISTS ${VERSION_FILE_PATH})
        message(STATUS "[get_version] reading version from VERSION file")
        file(READ ${VERSION_FILE_PATH} VERSION_STRING)
    else()
        message(STATUS "[get_version] no VERSION file found. getting version from `git describe`")
        find_package(Git)
        if(Git_FOUND)
            execute_process(COMMAND ${GIT_EXECUTABLE} describe --tags
                RESULT_VARIABLE GIT_DESCRIBE_RESULT
                OUTPUT_VARIABLE GIT_DESCRIBE_OUTPUT)
            if(${GIT_DESCRIBE_RESULT} EQUAL "0")
                string(STRIP ${GIT_DESCRIBE_OUTPUT} VERSION_STRING)
            else()
                message(SEND_ERROR "${MESSAGE_ERROR_PREFIX} an error occurred when executing `git describe`")
                set(VERSION_STRING "v0.0.0")
            endif()
        else()
            message(SEND_ERROR "${MESSAGE_ERROR_PREFIX} git is not available")
            set(VERSION_STRING "v0.0.0")
        endif()
    endif()
    
    set(VERSION_REGEX "^v[0-9]+\\.[0-9]+\\.[0-9]+.*")
    string(REGEX MATCH ${VERSION_REGEX} VERSION_REGEX_MATCH_RESULT ${VERSION_STRING})
    if(VERSION_REGEX_MATCH_RESULT STREQUAL ${VERSION_STRING})
        string(REGEX REPLACE "^v([0-9]+).*" "\\1" VERSION_MAJOR ${VERSION_STRING})
        string(REGEX REPLACE "^v[0-9]+\\.([0-9]+).*" "\\1" VERSION_MINOR ${VERSION_STRING})
        string(REGEX REPLACE "^v[0-9]+\\.[0-9]+\\.([0-9]+).*" "\\1" VERSION_PATCH ${VERSION_STRING})
        set(${OUTPUT} "${VERSION_MAJOR}.${VERSION_MINOR}.${VERSION_PATCH}" PARENT_SCOPE)
    else()
        message(SEND_ERROR "${MESSAGE_ERROR_PREFIX} `${VERSION_STRING}` is not a valid version. The version must match the regex `${VERSION_REGEX}`!")
        set(${OUTPUT} "0.0.0" PARENT_SCOPE)
    endif()
endfunction()