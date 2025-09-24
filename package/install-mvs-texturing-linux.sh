#!/usr/bin/env bash
set -ex      
ROOT="$(dirname "$0")/.."
EXT="$ROOT/external"
mkdir -p "$EXT"
cd "$EXT"

#git submodule update --init --depth 1 || true
git clone https://github.com/nmoehrle/mvs-texturing.git
cd mvs-texturing
mkdir -p build && cd build
cmake .. -DCMAKE_BUILD_TYPE=Release
make -j$(nproc)