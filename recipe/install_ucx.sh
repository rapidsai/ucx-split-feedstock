#!/bin/bash

set -xuo pipefail
set +e
CUDA_CONFIG_ARG=""
if [ ${cuda_compiler_version} != "None" ]; then
    CUDA_CONFIG_ARG="--with-cuda=${CUDA_HOME}"
fi

find /usr/ -iname "librdmacm*"
find /opt/conda/ -iname "librdmacm*"

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
    --with-rdmacm="${CONDA_BUILD_SYSROOT}" \
    --with-verbs="${CONDA_BUILD_SYSROOT}" \
    ${CUDA_CONFIG_ARG}
ls -la
cat config.log
exit 1
make -j${CPU_COUNT}
make install
