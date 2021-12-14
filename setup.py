import subprocess
from setuptools import setup, find_packages
from setuptools_scm.git import parse as parse_git


def version():
    yosys_makefile_ver = subprocess.check_output([
        "make", "-s", "-C", "yosys-src", "echo-yosys-ver"
    ], encoding="utf-8").strip().split("+")
    if len(yosys_makefile_ver) == 1:
        yosys_version = yosys_makefile_ver[0]
    elif len(yosys_makefile_ver) == 2:
        yosys_version = f"{yosys_makefile_ver[0]}.post{yosys_makefile_ver[1]}"
    else:
        assert False

    package_git = parse_git(".")
    package_version = package_git.format_with(".dev{distance}")

    return yosys_version + package_version


def long_description():
    with open("README.rst") as f:
        return f.read()


setup(
    name="amaranth-yosys",
    version=version(),
    author="whitequark",
    author_email="whitequark@whitequark.org",
    description="Specialized WebAssembly build of Yosys used by Amaranth HDL",
    long_description=long_description(),
    license="ISC", # same as Yosys
    python_requires="~=3.5",
    install_requires=[
        "importlib_resources>=1.4; python_version<'3.9'",
        "wasmtime>=0.30,<0.33"
    ],
    packages=["amaranth_yosys"],
    package_data={"amaranth_yosys": ["yosys.wasm", "share/**/**/**/*"]},
    project_urls={
        "Source Code": "https://github.com/amaranth-lang/amaranth-yosys",
        "Bug Tracker": "https://github.com/amaranth-lang/amaranth-yosys/issues",
    },
    classifiers=[
        "License :: OSI Approved :: ISC License (ISCL)",
    ],
)
