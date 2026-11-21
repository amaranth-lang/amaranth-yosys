import re
import subprocess
from pathlib import Path

from setuptools import setup
from setuptools_scm.git import parse as parse_git


def version():
    version_data = Path("yosys-src/cmake/YosysVersionData.cmake").read_text(encoding="utf-8")
    versions = dict(re.findall(r"set\(YOSYS_VERSION_(MAJOR|MINOR) (\d+)\)", version_data))
    yosys_major = versions["MAJOR"]
    yosys_minor = versions["MINOR"]
    # CI checks out the submodule at a detached HEAD. Preserve the snapshot
    # distance when the upstream release tag is available in the checkout.
    snapshot = subprocess.run(
        ["git", "-C", "yosys-src", "rev-list", "--count", f"v{yosys_major}.{yosys_minor}..HEAD"],
        encoding="utf-8", stdout=subprocess.PIPE, stderr=subprocess.DEVNULL,
    )
    yosys_node = snapshot.stdout.strip() if snapshot.returncode == 0 else "0"
    git_distance = parse_git(".").format_with("post{distance}")

    return ".".join([yosys_major, yosys_minor, "0", yosys_node, git_distance])


setup(
    version=version(),
)
