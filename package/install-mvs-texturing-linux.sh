#!/usr/bin/env bash
set -e

cd "$(dirname "$0")/../external/mvs-texturing"
mkdir -p build
cd build
cmake .. -DCMAKE_BUILD_TYPE=Release
make -j$(nproc)

