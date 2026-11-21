import re
import subprocess
from setuptools import setup
from setuptools_scm.git import parse as parse_git


def version():
    yosys_version_raw = subprocess.check_output([
        "make", "-s", "-C", "yosys-src", "echo-yosys-ver"
    ], encoding="utf-8").strip()

    # Yosys can't figure out if it should have a patch version or not.
    # Match one, and add one below in our version just in case.
    yosys_version = re.match(r"^(\d+)\.(\d+)(?:\.(\d+))?(?:\+(\d+))?$", yosys_version_raw)

    yosys_major  = yosys_version[1]
    yosys_minor  = yosys_version[2]
    yosys_patch  = yosys_version[3] or "0"
    yosys_node   = yosys_version[4] or "0"
    git_distance = parse_git(".").format_with("post{distance}")

    return ".".join([yosys_major, yosys_minor, yosys_patch, yosys_node, git_distance])


setup(
    version=version(),
)
