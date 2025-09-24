#!/usr/bin/env bash
set -ex   
REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
TBB_HOME="$REPO_ROOT"
mkdir -p "$TBB_HOME"   
curl -L https://github.com/oneapi-src/oneTBB/releases/download/v2021.12.0/oneapi-tbb-2021.12.0-lin.tgz | tar -xz -C "$TBB_HOME"
dnf install -y libpng-devel zlib-devel libjpeg-devel libtiff-devel
export CMAKE_PREFIX_PATH="$TBB_HOME/oneapi-tbb-2021.12.0":$CMAKE_PREFIX_PATH
ROOT="$(dirname "$0")/.."
EXT="$ROOT/external"
mkdir -p "$EXT"
cd "$EXT"

#git submodule update --init --depth 1 || true
git clone https://github.com/nmoehrle/mvs-texturing.git
cd mvs-texturing
mkdir -p build && cd build
cmake .. -DCMAKE_BUILD_TYPE=Release \
         -DCMAKE_POSITION_INDEPENDENT_CODE=ON \
         -DTBB_DIR="$TBB_HOME/oneapi-tbb-2021.12.0/lib/cmake/tbb"
make -j$(nproc)