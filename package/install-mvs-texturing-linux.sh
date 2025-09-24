#!/usr/bin/env bash
set -ex      
curl -L https://github.com/oneapi-src/oneTBB/releases/download/v2021.12.0/oneapi-tbb-2021.12.0-lin.tgz | tar -xz -C /opt
echo "/opt/oneapi-tbb-2021.12.0/lib/intel64/gcc4.8" >/etc/ld.so.conf.d/tbb.conf && ldconfig
dnf install -y libpng-devel zlib-devel libjpeg-devel libtiff-devel
export CMAKE_PREFIX_PATH=/opt/oneapi-tbb-2021.12.0:$CMAKE_PREFIX_PATH
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
         -DTBB_DIR=/opt/oneapi-tbb-2021.12.0/lib/cmake/tbb
make -j$(nproc)