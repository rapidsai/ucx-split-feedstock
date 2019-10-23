#!/bin/bash

set -xeuo pipefail

cd "${SRC_DIR}/ucx-py"
$PYTHON -m pip install . -vv
