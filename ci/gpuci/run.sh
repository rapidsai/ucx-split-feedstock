#!/bin/bash
# Copyright (c) 2020, NVIDIA CORPORATION.
#####################################
# ucx-py conda run script for gpuCI #
#####################################
set -ex

# Set paths
export HOME=$WORKSPACE

# Install gpuCI tools
curl -s https://raw.githubusercontent.com/rapidsai/gpuci-mgmt/master/gpuci-tools.sh | bash
source ~/.bashrc

# Get version info
gpuci_logger "Git clone ucx/ucx-py to get version info for build..."
git clone https://github.com/openucx/ucx.git git-ucx
cd git-ucx
git checkout $UCX_COMMIT
export UCX_VERSION=`git describe --abbrev=0 --tags`
export UCX_LONG_COMMIT=`git rev-parse HEAD`
export UCX_COMMIT=${UCX_LONG_COMMIT:0:7}
export UCX_BUILD_NUMBER=`git rev-list ${UCX_VERSION}..HEAD --count`
cd $WORKSPACE
git clone https://github.com/rapidsai/ucx-py.git git-ucxpy
cd git-ucxpy
git checkout $UCX_PY_COMMIT
export UCX_PY_VERSION=`git describe --abbrev=0 --tags`
UCX_PY_LONG_COMMIT=`git rev-parse HEAD`
export UCX_PY_COMMIT=${UCX_PY_LONG_COMMIT:0:7}
export UCX_PY_BUILD_NUMBER=`git rev-list ${UCX_PY_VERSION}..HEAD --count`
cd $WORKSPACE

# Set VERSION_SUFFIX if nightly job
if [[ "$JOB_NAME" == *"ucx-py-nightly"* ]] ; then
  gpuci_logger "nightly job detected, setting VERSION_SUFFIX..."
  export VERSION_SUFFIX=`date +%y%m%d`
fi

# Export env vars
gpuci_logger "Print current environment..."
env
env > env.list

# Get build container
gpuci_logger "Pull docker container for build..."
gpuci_retry docker pull ${FROM_IMAGE}:${CUDA_VERSION}

# Run conda build script
gpuci_logger "Run docker and kick off build script..."
docker run --rm --user root --env-file env.list -v $WORKSPACE:$WORKSPACE \
            --entrypoint "bash" ${FROM_IMAGE}:${CUDA_VERSION} $WORKSPACE/ci/cpu/build.sh
