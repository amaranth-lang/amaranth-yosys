Amaranth Yosys distribution
###########################

`Amaranth <https://github.com/amaranth-lang/amaranth>`_ is a Python-based hardware description language that uses `Yosys <https://yosyshq.net/yosys>`_ as a backend to emit Verilog.

The Amaranth HDL Yosys wheels provide a specialized `WebAssembly <https://webassembly.org/>`_ based build of Yosys that runs via `wasmtime-py <https://github.com/bytecodealliance/wasmtime-py>`_ if there is no system-wide Yosys installation, or if that installation is too old. This build is aggressively optimized for binary size and startup latency, and only includes features required by Amaranth's Verilog and CXXRTL backends; it is not useful for any other purpose.

Although this package is platform-independent, it depends on wasmtime-py wheels, which are currently available only for x86_64 Windows, Linux, and macOS. This is expected to improve in the future.

Building
========

The primary build environment for this repository is the ``ubuntu-latest`` GitHub CI runner; packages are built on every push and automatically published from the ``release`` branch to PyPI.

To reduce maintenance overhead, the only development environment we will support for this repository is x86_64 Linux.

License
=======

This package is covered by the `ISC license <LICENSE.txt>`_, which is the same as the `Yosys license <https://github.com/YosysHQ/yosys/blob/master/COPYING>`_.
