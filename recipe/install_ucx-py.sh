#!/bin/bash

set -xeuo pipefail

cd "${SRC_DIR}/ucx-py"
mkdir -p pip_cache
$PYTHON -m pip install --no-index --no-deps --ignore-installed --cache-dir ./pip_cache . -vv
