cmake_minimum_required(VERSION 3.21 FATAL_ERROR)

# Set module paths
set(CPACK_MSIX_GENERATOR "${CMAKE_CURRENT_SOURCE_DIR}/msix-generator-module/MSIX.cmake" CACHE BOOL "Path to the External CPack generator file" FORCE)
set(CPACK_MSIX_GENERATOR_TOOLS "${CMAKE_CURRENT_SOURCE_DIR}/msix-generator-module/MSIXTools.cmake" CACHE BOOL "Path to the External CPack generator file" FORCE)

# If you wish to use the preset, you may do so.
macro(cpack_msix_preset)
    # 1. Determine the value of SHOULD_APPEND (Default to OFF if not provided)
    if(${ARGC} GREATER 0)
        set(__cpack_msix_preset_SHOULD_APPEND "${ARGV0}")
    else()
        set(__cpack_msix_preset_SHOULD_APPEND ON)
    endif()

    if(__cpack_msix_preset_SHOULD_APPEND)
        list(APPEND CPACK_GENERATOR "External")
    else()
        list(CPACK_GENERATOR "External")
    endif()
    set(CPACK_EXTERNAL_PACKAGE_SCRIPT ${CPACK_MSIX_GENERATOR})
    set(CPACK_EXTERNAL_ENABLE_STAGING ON)

    include(${CPACK_MSIX_GENERATOR_TOOLS})
endmacro()
