#!/usr/bin/env bash
set -ex
REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
TBB_HOME="$REPO_ROOT"
mkdir -p "$TBB_HOME"
curl -L https://github.com/oneapi-src/oneTBB/releases/download/v2021.12.0/oneapi-tbb-2021.12.0-mac.tgz | tar -xz -C "$TBB_HOME"

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
         -DTBB_DIR="$TBB_HOME/oneapi-tbb-2021.12.0/lib/cmake/tbb"
make -j$(sysctl -n hw.ncpu)