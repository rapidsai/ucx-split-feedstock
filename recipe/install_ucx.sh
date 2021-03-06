#!/bin/bash

set -xeuo pipefail

EXTRA_ARGS=""
if [ "${cuda_compiler_version}" != "None" ]; then
    EXTRA_ARGS="${EXTRA_ARGS} --with-cuda=${CUDA_HOME}"
fi

cd "${SRC_DIR}/ucx"
./autogen.sh
./configure \
    --build="${BUILD}" \
    --host="${HOST}" \
    --prefix="${PREFIX}" \
    --with-sysroot \
    --enable-cma \
    --enable-mt \
    --enable-numa \
    --with-gnu-ld \
    ${EXTRA_ARGS}

make -j${CPU_COUNT}
make install
