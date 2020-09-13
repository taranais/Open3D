# MKL and TBB build scripts.
#
# This scripts exports: (both MKL and TBB)
# - STATIC_MKL_INCLUDE_DIR
# - STATIC_MKL_LIB_DIR
# - STATIC_MKL_LIBRARIES
# (Only TBB)
# - STATIC_TBB_INCLUDE_DIR
# - STATIC_TBB_LIB_DIR
# - STATIC_TBB_LIBRARIES
#
# The name "STATIC" is used to avoid naming collisions for other 3rdparty CMake
# files (e.g. PyTorch) that also depends on MKL.

include(ExternalProject)

set(MKL_INCLUDE_URL      "https://anaconda.org/intel/mkl-include/2020.1/download/win-64/mkl-include-2020.1-intel_216.tar.bz2")
set(MKL_URL              "https://anaconda.org/intel/mkl-static/2020.1/download/win-64/mkl-static-2020.1-intel_216.tar.bz2")

# Where MKL and TBB headers and libs will be installed.
set(MKL_INSTALL_PREFIX ${CMAKE_BINARY_DIR}/mkl_install)
set(STATIC_MKL_INCLUDE_DIR "${MKL_INSTALL_PREFIX}/include/")
set(STATIC_MKL_LIB_DIR "${MKL_INSTALL_PREFIX}/lib")

# TBB variables exported for PyTorch Ops and Tensorflow Ops
set(STATIC_TBB_INCLUDE_DIR "${STATIC_MKL_INCLUDE_DIR}")
set(STATIC_TBB_LIB_DIR "${STATIC_MKL_LIB_DIR}")
set(STATIC_TBB_LIBRARIES tbb_static tbbmalloc_static)

# Need to put TBB right next to MKL in the link flags. So instead of creating a
# new tbb.cmake, it is also put here.
ExternalProject_Add(
    ext_tbb
    PREFIX tbb
    GIT_REPOSITORY https://github.com/wjakob/tbb.git
    GIT_TAG 806df70ee69fc7b332fcf90a48651f6dbf0663ba # July 2020
    UPDATE_COMMAND ""
    CMAKE_ARGS
        -DCMAKE_INSTALL_PREFIX=${MKL_INSTALL_PREFIX}
        -DCMAKE_POSITION_INDEPENDENT_CODE=ON
        -DTBB_BUILD_TBBMALLOC=ON
        -DTBB_BUILD_TBBMALLOC_PROXYC=OFF
        -DTBB_BUILD_SHARED=OFF
        -DTBB_BUILD_TESTS=OFF
        -DCMAKE_BUILD_TYPE=${CMAKE_BUILD_TYPE}
)

# ExternalProject_Add(
#     ext_mkl_include
#     PREFIX mkl_include
#     URL ${MKL_INCLUDE_URL}
#     UPDATE_COMMAND ""
#     CONFIGURE_COMMAND ""
#     BUILD_COMMAND ""
#     INSTALL_COMMAND ${CMAKE_COMMAND} -E copy_directory <SOURCE_DIR>/Library/include ${MKL_INSTALL_PREFIX}/include
# )

# ExternalProject_Add(
#     ext_mkl
#     PREFIX mkl
#     URL ${MKL_URL}
#     UPDATE_COMMAND ""
#     CONFIGURE_COMMAND ""
#     BUILD_COMMAND ""
#     INSTALL_COMMAND ${CMAKE_COMMAND} -E copy_directory <SOURCE_DIR>/Library/lib ${MKL_INSTALL_PREFIX}/lib
# )
# # Generator expression can result in an empty string "", causing CMake to try to
# # locate ".lib". The workaround to first list all libs, and remove unneeded items
# # using generator expressions.
# set(STATIC_MKL_LIBRARIES
#     mkl_intel_ilp64
#     mkl_core
#     mkl_sequential
#     mkl_tbb_thread
#     tbb_static
# )
# list(REMOVE_ITEM STATIC_MKL_LIBRARIES "$<$<CONFIG:Debug>:mkl_tbb_thread>")
# list(REMOVE_ITEM STATIC_MKL_LIBRARIES "$<$<CONFIG:Debug>:tbb_static>")
# list(REMOVE_ITEM STATIC_MKL_LIBRARIES "$<$<CONFIG:Release>:mkl_sequential>")
