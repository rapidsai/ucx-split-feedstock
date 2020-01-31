#!/bin/bash
# Copyright (c) 2020, NVIDIA CORPORATION.
####################################
# ucx-py conda build script for CI #
####################################
set -ex

# Set paths
export PATH=/opt/conda/bin:$PATH
export HOME=$WORKSPACE

# Activate base conda env (this is run in docker condaforge/linux-anvil-cuda:CUDA_VER)
source activate base

# Install gpuCI tools
curl -s https://raw.githubusercontent.com/rapidsai/gpuci-mgmt/master/gpuci-tools.sh | bash
source ~/.bashrc

# Print current env vars
env

# Install yum reqs
xargs yum -y install < recipe/yum_requirements.txt

# Fetch pkgs for build
gpuci_retry conda install -y -k -c nvidia -c conda-forge -c defaults conda-verify cudatoolkit=$CUDA_VER

# Print diagnostic information
conda info
conda config --show-sources
conda list --show-channel-urls

# Add settings for current CUDA version
cat .ci_support/linux_cuda_compiler_version${CUDA_VER}.yaml >> recipe/conda_build_config.yaml

# Allow insecure files to work with out conda mirror/proxy
echo "ssl_verify: false" >> /opt/conda/.condarc

# Print current env vars
env

# Create ucx-py build string
export UCX_PY_VERSION="${UCX_PY_VERSION}${VERSION_SUFFIX}+g${UCX_PY_COMMIT:0:7}"

# Start conda build
gpuci_retry conda build -c conda-forge -c defaults .

# Uploda files to anaconda
gpuci_retry anaconda -t ${MY_UPLOAD_KEY} upload -u ${CONDA_USERNAME:-rapidsai} --label main --force /opt/conda/conda-bld/linux-64/ucx*.bz2
