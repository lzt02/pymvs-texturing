#!/usr/bin/env bash
set -ex


curl -L https://github.com/oneapi-src/oneTBB/releases/download/v2021.12.0/oneapi-tbb-2021.12.0-mac.tgz | tar -xz -C /opt

sudo ln -sf /opt/oneapi-tbb-2021.12.0/lib/libtbb*.dylib /usr/local/lib/

brew install libpng zlib jpeg-turbo libtiff

ROOT="$(dirname "$0")/.."
EXT="$ROOT/external"
mkdir -p "$EXT"
cd "$EXT"
git clone https://github.com/nmoehrle/mvs-texturing.git
cd mvs-texturing
mkdir -p build && cd build
cmake .. -DCMAKE_BUILD_TYPE=Release \
         -DCMAKE_POSITION_INDEPENDENT_CODE=ON \
         -DCMAKE_OSX_ARCHITECTURES="arm64;x86_64" \
         -DTBB_ROOT=/opt/oneapi-tbb-2021.12.0
make -j$(sysctl -n hw.ncpu)