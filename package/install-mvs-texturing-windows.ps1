Set-StrictMode -Version latest
$ErrorActionPreference = "Stop"

Write-Host "Downloading TBB..."
$tbbUri = "https://github.com/oneapi-src/oneTBB/releases/download/v2021.12.0/oneapi-tbb-2021.12.0-win.zip"
$tbbZip = "C:\tbb.zip"
Invoke-WebRequest -Uri $tbbUri -OutFile $tbbZip
Expand-Archive -Path $tbbZip -DestinationPath C:\tbb -Force
$tbbBin = "C:\tbb\oneapi-tbb-2021.12.0\bin\intel64\vc14"
$tbbLib = "C:\tbb\oneapi-tbb-2021.12.0\lib\intel64\vc14"
$tbbCMake = "C:\tbb\oneapi-tbb-2021.12.0\lib\cmake\TBB"
$env:PATH += ";$tbbBin"

Write-Host "Installing dependencies via vcpkg..."
vcpkg install tbb:x64-windows libpng:x64-windows zlib:x64-windows libjpeg-turbo:x64-windows tiff:x64-windows

$projRoot = Split-Path -Parent $PSScriptRoot
$ext = "$projRoot\external"
New-Item -ItemType Directory -Force -Path $ext
Set-Location $ext
git clone https://github.com/nmoehrle/mvs-texturing.git
Set-Location mvs-texturing
New-Item -ItemType Directory -Force -Path build
Set-Location build
cmake .. -G "Visual Studio 17 2022" -A x64 `
         -DCMAKE_BUILD_TYPE=Release `
         -DCMAKE_TOOLCHAIN_FILE=C:\vcpkg\scripts\buildsystems\vcpkg.cmake `
         -DTBB_DIR="$tbbCMake"
cmake --build . --config Release -v
