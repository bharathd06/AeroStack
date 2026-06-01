#!/bin/sh
# build.sh — Build the Stack Depth Analyzer
set -e

echo "=== Stack Depth Analyzer — Build ==="

# Check dependencies
echo "Checking dependencies..."

# Determine package recommendation based on OS package manager
if command -v apt-get >/dev/null 2>&1; then
  PKG_REC="sudo apt-get install -y cmake ninja-build clang llvm-dev zlib1g-dev libzstd-dev"
else
  PKG_REC="apk add cmake ninja llvm17-dev llvm17-static clang17-dev"
fi

command -v cmake >/dev/null 2>&1 || { echo "ERROR: cmake not found. Install via: $PKG_REC"; exit 1; }
command -v ninja >/dev/null 2>&1 || { echo "ERROR: ninja not found. Install via: $PKG_REC"; exit 1; }

# Find LLVM Config directory dynamically
LLVM_CMAKE_DIR=""
if command -v llvm-config >/dev/null 2>&1; then
  LLVM_CMAKE_DIR="$(llvm-config --cmakedir 2>/dev/null)"
fi

if [ -z "$LLVM_CMAKE_DIR" ] || [ ! -d "$LLVM_CMAKE_DIR" ]; then
  # Fallbacks
  for dir in /usr/lib/llvm17/lib/cmake/llvm /usr/lib/llvm18/lib/cmake/llvm /usr/lib/llvm-18/lib/cmake/llvm /usr/lib/llvm-17/lib/cmake/llvm; do
    if [ -d "$dir" ]; then
      LLVM_CMAKE_DIR="$dir"
      break
    fi
  done
fi

if [ -z "$LLVM_CMAKE_DIR" ]; then
  echo "ERROR: LLVM development libraries not found. Install via: $PKG_REC"
  exit 1
fi

echo "Found LLVM CMake Configuration at: $LLVM_CMAKE_DIR"

# Create missing dummy libs if needed (Alpine LLVM17 package quirk)
if [ -d "/usr/lib/llvm17/lib" ]; then
  for lib in LLVMTestingAnnotations LLVMTestingSupport LLVMBenchmarkSupport llvm_gtest llvm_gtest_main; do
    [ ! -f "/usr/lib/llvm17/lib/lib${lib}.a" ] && ar rcs "/usr/lib/llvm17/lib/lib${lib}.a" 2>/dev/null || true
  done
fi

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
cd "$SCRIPT_DIR"

mkdir -p build
cd build

echo "Running CMake..."
cmake .. -G Ninja \
  -DCMAKE_BUILD_TYPE=Release \
  2>&1 | grep -E "Found LLVM|Error|error" || true

echo "Building..."
ninja

echo ""
echo "Build complete! Binary: $SCRIPT_DIR/build/stack-analyzer"
echo ""
echo "Usage:"
echo "  ./run.sh testcases/test_simple.c"
echo "  ./run.sh testcases/test_deep_chain.c --threshold=512"
echo "  ./run.sh --all"
