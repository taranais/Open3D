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
