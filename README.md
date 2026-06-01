# AeroStack — Advanced Compile-Time Stack Depth & Frame Analyzer

AeroStack is an enterprise-grade static analysis tool built using the LLVM compiler pass infrastructure. It statically estimates **worst-case cumulative stack usage** across entire calling pathways, paired with an interactive, modern web-based diagnostic dashboard. It is engineered for embedded and RTOS systems development where stack overflows are the leading cause of silent memory corruptions and crashes.

---

## 🎥 Video Demonstration
* **Click here to watch the complete walkthrough:** [Watch AeroStack Walkthrough Video (Google Drive)](INSERT_YOUR_GOOGLE_DRIVE_LINK_HERE)

---

## 🚀  Getting Started

To make evaluating this project as seamless as possible, we have ensured complete path portability and cross-compiler toolchain compatibility (fully tested on WSL, Ubuntu, Debian, and Alpine Linux).

### Step 1: Install System Dependencies
Make sure you have LLVM, Clang, CMake, and Ninja installed. 

**For Debian/Ubuntu/WSL terminal (Recommended)**:
```bash
sudo apt-get update && sudo apt-get install -y cmake ninja-build clang llvm-dev zlib1g-dev libzstd-dev python3
```

**For Alpine Linux**:
```bash
apk add cmake ninja llvm17-dev llvm17-static clang17-dev python3
```

### Step 2: Build the static analyzer
Simply run the portable build script. It dynamically locates LLVM on your system path:
```bash
./build.sh
```

### Step 3: Run the Diagnostics Suite

We provide two modes to evaluate the correctness and usefulness of the tool:

#### Mode A: Interactive Web Dashboard (Highly Recommended)
Start the local server and load our premium visual diagnostics dashboard:
```bash
# 1. Start the analysis server
python3 server.py

# 2. Open http://localhost:8765/ in your browser!
# 3. Drop `test_simple.bc` (located in the project root) or `testcases/test_deep_chain.bc` into the browser and click RUN ANALYSIS!
```

#### Mode B: Command-Line Interface (CLI)
Run all 6 baseline compiler test cases locally on the console with one command:
```bash
./run.sh --all
```

---

## Key Features

* **LLVM Intermediate Pass** — Analyzes compiled LLVM bitcode (`.bc` files) at the IR level.
* **DataLayout Estimation** — Computes precise target-specific stack frame sizes from `alloca` instructions, incorporating compiler alignment padding and structures.
* **Whole-Program Call Graph** — Reconstructs static calling pathways using LLVM's `CallGraphWrapperPass`.
* **Worst-Case Search** — Traverses calling trees with recursive DFS to identify absolute worst-case stack depths.
* **Recursion & Cycle Warning** — Identifies recursive cycles statically and prints warning parameters without infinite looping.
* **Diagnostic Dashboard** — Interactive glassmorphic interface with optimization sandboxes, SVG flowpaths, search heatmaps, and syntax-highlighted IR viewers.

## Quick Start

```bash
# 1. Build the static analyzer pass (compiles in WSL Ubuntu/Linux)
./build.sh

# 2. Compile your C file to LLVM bitcode
clang -O0 -emit-llvm -c testcases/test_simple.c -o test_simple.bc

# 3. Start the analysis server
python3 server.py
```

## Requirements

* LLVM 18/17 (`llvm-dev`, `clang`, `libzstd-dev`, `zlib1g-dev`)
* CMake >= 3.20
* Ninja Build
* Python 3.10+
* C++17 Compiler

## Manual CLI Usage

```bash
# Run stack depth pass on test_simple.bc
./build/stack-analyzer test_simple.bc --threshold=256

# Analyze FreeRTOS tasks kernel
./testcases/test_freertos.sh
```

## Web Diagnostic Dashboard

AeroStack includes a premium, interactive web interface featuring:
* **Live Connection Sentinel** — Background polling checking WS/API status to show server status.
* **SVG Call Flow Timeline** — Horizontal flowchart showing exact module-to-module dependencies and sizes, with pulsing red warning pathways during overflows.
* **Optimization Sandbox** — Slide parameters to simulate relocating large stack buffers to the heap or splitting async tasks, showing instant before-after comparative metrics.
* **Heatmap & LLVM IR Viewer** — Filter and locate modules in a progress-heatmap, loading corresponding syntax-highlighted IR assembly views.
* **Portable Exporter** — Write findings into Markdown (`.md`) reports or Plain Text logs with one click.

To start the interface:
```bash
# 1. Start the server
python3 server.py

# 2. Open http://localhost:8765/ in your browser!
# 3. Select or drop `test_simple.bc` or `testcases/test_deep_chain.bc` and click RUN ANALYSIS.
```

## Output Format

```
=== Per-Function Stack Frame Sizes ===
  c_func: 512 bytes
  b_func: 256 bytes
  a_func: 128 bytes
  main:     4 bytes

[OVERFLOW RISK] main worst-case=900 bytes (threshold=512)
  Chain: main(4B) -> a_func(128B) -> b_func(256B) -> c_func(512B)

=== Top Call Chains by Stack Depth ===
#1 900 bytes: main(4B) -> a_func(128B) -> b_func(256B) -> c_func(512B)
```

## Project Structure

```
stack-analyzer/
├── build.sh                  # Build script
├── run.sh                    # Run script
├── CMakeLists.txt            # Build configuration
├── README.md                 # This file
├── DESIGN.md                 # Design decisions and alternatives
├── IMPLEMENTATION.md         # LLVM implementation details
├── EVALUATION.md             # Metrics, test cases, comparison
├── include/
│   └── StackAnalyzer.h       # Shared header
├── lib/
│   ├── StackFrameEstimator.cpp   # Per-function frame estimation
│   └── CallChainAnalyzer.cpp     # Call graph traversal + reporting
├── tools/
│   └── stack-analyzer.cpp        # CLI entry point
├── testcases/
│   ├── test_simple.c             # Basic call chain
│   ├── test_deep_chain.c         # Deep nesting
│   ├── test_recursion.c          # Recursion detection
│   ├── test_multiple_paths.c     # Multiple call paths
│   ├── test_large_buffers.c      # Large stack allocations
│   ├── test_no_overflow.c        # Baseline - no overflow
│   └── test_freertos.sh          # FreeRTOS evaluation script
├── server.py                 # Web frontend server
└── index.html                # Web frontend UI
```

## Assignment

Built as Assignment 39 — Compile-Time Stack Usage Analyzer using LLVM Pass Infrastructure.
