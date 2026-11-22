#!/bin/sh -ex

export SOURCE_DATE_EPOCH=$(git log -1 --format=%ct)

WASI_VER=34
WASI_SDK=wasi-sdk-${WASI_VER}.0-x86_64-linux
WASI_SDK_URL=https://github.com/WebAssembly/wasi-sdk/releases/download/wasi-sdk-${WASI_VER}/${WASI_SDK}.tar.gz
if ! [ -d ${WASI_SDK} ]; then curl -L ${WASI_SDK_URL} | tar xzf -; fi
WASI_SDK_PATH=$(pwd)/${WASI_SDK}

cmake -B yosys-build -S yosys-src \
  -DCMAKE_TOOLCHAIN_FILE=${WASI_SDK_PATH}/share/cmake/wasi-sdk-p1.cmake \
  -DCMAKE_BUILD_TYPE=Release \
  -DYOSYS_COMPILER_LAUNCHER=ccache \
  -DYOSYS_WITHOUT_ABC=ON \
  -DYOSYS_WITHOUT_ZLIB=ON \
  -DYOSYS_WITHOUT_LIBFFI=ON \
  -DYOSYS_WITHOUT_READLINE=ON \
  -DYOSYS_WITHOUT_EDITLINE=ON \
  -DYOSYS_WITHOUT_SLANG=ON \
  -DYOSYS_WITHOUT_TCL=ON \
  -DYOSYS_ENABLE_UNIT_TESTS=OFF \
  -DYOSYS_COMPONENTS="read_rtlil;proc;memory_collect;attrmap;write_verilog;write_json"

cmake --build yosys-build --parallel $(nproc)
cp yosys-build/yosys amaranth_yosys/yosys.wasm
