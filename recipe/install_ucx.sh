#!/bin/bash

set -xeuo pipefail

echo "Compiler sysroot: $($CC -print-sysroot)"

EXTRA_ARGS=""
if [ "${cuda_compiler_version}" != "None" ]; then
    EXTRA_ARGS="${EXTRA_ARGS} --with-cuda=${CUDA_HOME}"
fi
if [ "${cdt_name}" == "cos6" ]; then
    EXTRA_ARGS="${EXTRA_ARGS} --with-cm"
fi

./autogen.sh
./configure \
    --build="${BUILD}" \
    --host="${HOST}" \
    --prefix="${PREFIX}" \
    --with-sysroot="$(${CC} -print-sysroot)" \
    --enable-cma \
    --enable-mt \
    --enable-numa \
    --with-gnu-ld \
    --with-rdmacm \
    --with-verbs \
    ${EXTRA_ARGS}

make -j${CPU_COUNT}
make install
