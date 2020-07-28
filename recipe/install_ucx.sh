#!/bin/bash

set -xeuo pipefail

CUDA_CONFIG_ARG=""
if [ ${cuda_compiler_version} != "None" ]; then
    CUDA_CONFIG_ARG="--with-cuda=${CUDA_HOME}"
fi

ldd librdmacm

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
    --with-rdmacm \
    --with-verbs \
    ${CUDA_CONFIG_ARG}

make -j${CPU_COUNT}
make install
