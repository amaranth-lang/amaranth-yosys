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

engine = wasmtime.Engine(wasm_cfg)
linker = wasmtime.Linker(engine)
linker.define_wasi()
store = wasmtime.Store(engine)
store.set_wasi(wasi_cfg)
yosys = linker.instantiate(store, wasmtime.Module(engine,
    importlib_resources.read_binary(__package__, "yosys.wasm")))
try:
    yosys.exports(store)["_start"](store)
except wasmtime.ExitTrap as trap:
    sys.exit(trap.code)
