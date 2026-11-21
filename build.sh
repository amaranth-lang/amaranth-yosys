#!/bin/sh -ex

WASI_SDK=wasi-sdk-33.0-x86_64-linux
WASI_SDK_URL=https://github.com/WebAssembly/wasi-sdk/releases/download/wasi-sdk-33/${WASI_SDK}.tar.gz
if ! [ -d "${WASI_SDK}" ]; then curl -fL "${WASI_SDK_URL}" | tar xzf -; fi

# Keep only the backends and passes used by Amaranth.
YOSYS_COMPONENTS='read_rtlil;write_rtlil;write_verilog;write_cxxrtl;write_json'
YOSYS_COMPONENTS="${YOSYS_COMPONENTS};proc;hierarchy;uniquify;submod;select;delete;plugin"
YOSYS_COMPONENTS="${YOSYS_COMPONENTS};flatten;attrmap;simplemap;memory_collect"
YOSYS_COMPONENTS="${YOSYS_COMPONENTS};opt;opt_mem;opt_mem_feedback;opt_mem_priority;opt_mem_widen"
YOSYS_COMPONENTS="${YOSYS_COMPONENTS};share;wreduce;opt_demorgan;rmports;opt_lut;opt_lut_ins;opt_ffinv;pmux2shiftx;muxpack"

# WASI SDK 33's LTO libunwind fails to link with WebAssembly exceptions.
cmake -S yosys-src -B build/yosys -G Ninja \
    -DCMAKE_TOOLCHAIN_FILE="$(pwd)/${WASI_SDK}/share/cmake/wasi-sdk-p1.cmake" \
    -DCMAKE_BUILD_TYPE=Release \
    -DCMAKE_INTERPROCEDURAL_OPTIMIZATION=OFF \
    -DCMAKE_EXE_LINKER_FLAGS=-Wl,--strip-all \
    -DYOSYS_COMPILER_LAUNCHER=ccache \
    -DBUILD_SHARED_LIBS=OFF \
    -DYOSYS_ENABLE_UNIT_TESTS=OFF \
    -DYOSYS_USE_BUNDLED_LIBS=ON \
    -DYOSYS_WITHOUT_ABC=ON \
    -DYOSYS_WITHOUT_ZLIB=ON \
    -DYOSYS_WITHOUT_LIBFFI=ON \
    -DYOSYS_WITHOUT_READLINE=ON \
    -DYOSYS_WITHOUT_EDITLINE=ON \
    -DYOSYS_WITHOUT_SLANG=ON \
    -DYOSYS_WITHOUT_TCL=ON \
    -DYOSYS_COMPONENTS="${YOSYS_COMPONENTS}"
cmake --build build/yosys --target yosys

cp build/yosys/yosys amaranth_yosys/yosys.wasm
rm -rf amaranth_yosys/share
mkdir -p amaranth_yosys/share/include/backends/cxxrtl
cp -r build/yosys/share/include/backends/cxxrtl/runtime amaranth_yosys/share/include/backends/cxxrtl/
