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


setup(
    version=version(),
)
