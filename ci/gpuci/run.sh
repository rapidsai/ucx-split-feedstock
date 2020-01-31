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

# Fetch docker container
gpuci_retry docker pull ${FROM_IMAGE}:${CUDA_VERSION}

# Run conda build script
gpuci_retry docker run ${FROM_IMAGE}:${CUDA_VERSION} -v $WORKSPACE:$WORKSPACE -w $WORKSPACE ci/cpu/build.sh
