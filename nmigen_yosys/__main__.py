import os
import sys
import wasmtime
try:
	from importlib import resources as importlib_resources # py3.7+ stdlib
except ImportError:
	import importlib_resources # py3.6 shim


wasm_cfg = wasmtime.Config()
wasm_cfg.cache = True

wasi_cfg = wasmtime.WasiConfig()
wasi_cfg.argv = ("nmigen-yosys", *sys.argv[1:])
wasi_cfg.preopen_dir(".", ".")
wasi_cfg.inherit_stdin()
wasi_cfg.inherit_stdout()
wasi_cfg.inherit_stderr()

store = wasmtime.Store(wasmtime.Engine(wasm_cfg))
linker = wasmtime.Linker(store)
wasi = linker.define_wasi(wasmtime.WasiInstance(store,
    "wasi_snapshot_preview1", wasi_cfg))
yosys = linker.instantiate(wasmtime.Module(store.engine,
    importlib_resources.read_binary(__package__, "yosys.wasm")))
try:
    yosys.exports["_start"]()
except wasmtime.ExitTrap as trap:
    sys.exit(trap.code)
