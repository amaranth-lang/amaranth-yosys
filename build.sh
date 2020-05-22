#!/bin/sh -ex

WASI_SDK=wasi-sdk-10.0
WASI_SDK_URL=https://github.com/WebAssembly/wasi-sdk/releases/download/wasi-sdk-10/wasi-sdk-10.0-linux.tar.gz
if ! [ -d ${WASI_SDK} ]; then curl -L ${WASI_SDK_URL} | tar xzf -; fi

# This script does a lot of really awful things to Yosys to make the WASM artifact smaller.
# That's necessary to reduce the startup latency, since currently wasmtime-py does not cache
# the compiled code.

cat >yosys-src/Makefile.conf <<END
WASI_SDK := ../${WASI_SDK}

CONFIG := wasi
PREFIX := /

ENABLE_TCL := 0
ENABLE_ABC := 0
ENABLE_GLOB := 0
ENABLE_PLUGINS := 0
ENABLE_READLINE := 0
ENABLE_EDITLINE := 0
ENABLE_VERIFIC := 0
ENABLE_COVER := 0
ENABLE_LIBYOSYS := 0
ENABLE_PROTOBUF := 0
ENABLE_ZLIB := 0

CXXFLAGS += -flto
LDFLAGS += -flto -Wl,--strip-all
END

cat >yosys-src/frontends/verilog/preproc_stub.cc <<END
#include "preproc.h"

YOSYS_NAMESPACE_BEGIN

struct define_body_t {};

define_map_t::define_map_t() {}
define_map_t::~define_map_t() {}
void define_map_t::clear() {}

YOSYS_NAMESPACE_END
END

cat >yosys-src/passes/cmds/design_stub.cc <<END
#include "kernel/yosys.h"

YOSYS_NAMESPACE_BEGIN

std::map<std::string, RTLIL::Design*> saved_designs;
std::vector<RTLIL::Design*> pushed_designs;

YOSYS_NAMESPACE_END
END

sed -e 's,new ezMiniSAT(),nullptr,' -i yosys-src/kernel/register.cc

YOSYS_VER=$(python3 setup.py --version)
YOSYS_GIT_REV=$(git -C yosys-src rev-parse --short HEAD | tr -d '\n')
YOSYS_VER_STR="nMigen Yosys ${YOSYS_VER} (git sha1 ${YOSYS_GIT_REV})"
YOSYS_OBJS="\
kernel/version_${YOSYS_GIT_REV}.cc \
kernel/driver.o \
kernel/register.o \
kernel/rtlil.o \
kernel/log.o \
kernel/calc.o \
kernel/yosys.o \
libs/bigint/BigInteger.o \
libs/bigint/BigUnsigned.o \
libs/sha1/sha1.o \
frontends/ast/ast.o \
frontends/ilang/ilang_parser.tab.o \
frontends/ilang/ilang_lexer.o \
frontends/ilang/ilang_frontend.o \
frontends/verilog/preproc_stub.o \
frontends/verilog/const2ast.o \
passes/proc/proc_prune.o \
passes/proc/proc_init.o \
passes/proc/proc_arst.o \
passes/proc/proc_dff.o \
passes/proc/proc_clean.o \
passes/cmds/plugin.o \
passes/cmds/design_stub.o \
passes/cmds/select.o \
passes/cmds/delete.o \
passes/memory/memory_collect.o \
passes/techmap/attrmap.o \
backends/ilang/ilang_backend.o \
backends/verilog/verilog_backend.o \
"
make -C yosys-src GIT_REV="${YOSYS_GIT_REV}" YOSYS_VER="${YOSYS_VER}" YOSYS_VER_STR="${YOSYS_VER_STR}" OBJS="${YOSYS_OBJS}" PRETTY=0
cp yosys-src/yosys.wasm nmigen_yosys/
