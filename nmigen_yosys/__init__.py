try:
	from importlib import metadata as importlib_metadata # py3.8+ stdlib
except ImportError:
	import importlib_metadata # py3.7- shim
__version__ = importlib_metadata.version(__package__)
