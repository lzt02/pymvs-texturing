cmake_minimum_required(VERSION 3.15)
project(pymvs_texturing LANGUAGES CXX)

find_package(pybind11 CONFIG REQUIRED)

# Python extension
pybind11_add_module(pymvs_texturing src/pymvs_texturing/bindings.cpp)
install(TARGETS pymvs_texturing
        LIBRARY DESTINATION .   # Linux/macOS .so
        RUNTIME DESTINATION .   # Windows .pyd
        ARCHIVE DESTINATION .)  # 静态库（若有）

# mvs-texturing 路径
set(MVS_ROOT ${CMAKE_CURRENT_SOURCE_DIR}/external/mvs-texturing)
set(MVS_BUILD ${MVS_ROOT}/build)

# 包含头文件
target_include_directories(pymvs_texturing PRIVATE
    ${MVS_ROOT}/libs
    ${MVS_ROOT}/src
    ${MVS_ROOT}/elibs/mve/libs
    ${MVS_ROOT}/elibs/eigen
    ${MVS_ROOT}/elibs/mapmap/include
    ${MVS_ROOT}/elibs/rayint
)

set(TBB_USE_STATIC_LIBS ON)
find_package(PNG REQUIRED)
find_package(JPEG REQUIRED)
find_package(TIFF REQUIRED)
find_package(TBB REQUIRED)
find_package(OpenMP)
# 链接已经编译好的静态库
target_link_libraries(pymvs_texturing PRIVATE
    ${MVS_BUILD}/libs/tex/libtex.a
    ${MVS_ROOT}/elibs/mve/libs/util/libmve_util.a
    ${MVS_ROOT}/elibs/mve/libs/mve/libmve.a
    # ${MVS_BUILD}/elibs/mapmap/libmapmap.a
    # ${MVS_BUILD}/elibs/rayint/librayint.a

    PNG::PNG
    JPEG::JPEG
    TIFF::TIFF
    TBB::tbb
    OpenMP::OpenMP_CXX
)

