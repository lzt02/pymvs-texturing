#!/usr/bin/env bash
set -e
mkdir -p "$(dirname "$0")/../external"
cd "$(dirname "$0")/../external/mvs-texturing"
mkdir -p build
cd build
cmake .. -DCMAKE_BUILD_TYPE=Release
make -j$(nproc)

