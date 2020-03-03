#!/bin/bash

set -xeuo pipefail

CUDA_CONFIG_ARG=""
if [ ${cuda_compiler_version} != "None" ]; then
    CUDA_CONFIG_ARG="--with-cuda=${CUDA_HOME}"
fi

cd "${SRC_DIR}/ucx"
# needed to clean out directory -- some patches will change
# Makefile.am
git clean -fdx
cat src/ucs/Makefile.am
./autogen.sh
mkdir -p build_ucx
cd build_ucx
../contrib/configure-release \
    --build="${BUILD}" \
    --host="${HOST}" \
    --prefix="${PREFIX}" \
    --with-sysroot \
    --enable-cma \
    --enable-mt \
    --enable-numa \
    --with-gnu-ld \
    --with-cm \
    --with-rdmacm \
    --with-verbs \
    ${CUDA_CONFIG_ARG} \
    CPPFLAGS="-I/$CUDA_HOME/include" \

make -j${CPU_COUNT}
make install
cd -
