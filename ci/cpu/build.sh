#!/bin/bash
# Copyright (c) 2020, NVIDIA CORPORATION.
#######################################
# ucx-py conda build script for gpuCI #
#######################################
set -ex

# Set paths
export PATH=/opt/conda/bin:$PATH
export HOME=/home/conda

# Activate base conda env (this is run in docker condaforge/linux-anvil-cuda:CUDA_VER)
source activate base

# Print current env vars
env

# Install gpuCI tools
curl -s https://raw.githubusercontent.com/rapidsai/gpuci-tools/main/install.sh | bash
source ~/.bashrc
cd ~

# Copy workspace to home
gpuci_logger "Copy workspace from volume to home for work..."
cp -rT $WORKSPACE ~

# Install yum reqs
gpuci_logger "Install system libraries needed for build..."
xargs yum -y install < recipe/yum_requirements.txt

# Fetch pkgs for build
gpuci_logger "Install conda pkgs needed for build..."
if [ "$CUDA_VER" != "None" ] ; then
  conda install -y -k -c nvidia -c conda-forge -c defaults conda-verify cudatoolkit=$CUDA_VER
else
  conda install -y -k -c nvidia -c conda-forge -c defaults conda-verify
fi
conda install -y -k -c conda-forge conda-build anaconda-client ripgrep

# Print diagnostic information
gpuci_logger "Print conda info..."
conda info
conda config --show-sources
conda list --show-channel-urls

# Add settings for current CUDA version
cat .ci_support/linux_cuda_compiler_version${CUDA_VER}.yaml >> recipe/conda_build_config.yaml

# Allow insecure files to work with out conda mirror/proxy
echo "ssl_verify: false" >> /opt/conda/.condarc

# Print current env vars
gpuci_logger "Print current environment..."
env

# Start conda build
gpuci_logger "Starting conda build..."
conda build --override-channels -c conda-forge -c nvidia .

# Get conda build output
gpuci_logger "Getting conda build output..."
conda build --override-channels -c conda-forge -c nvidia . --output > conda.output

# Uploda files to anaconda
if [ ! -z "${MY_UPLOAD_KEY}" ] ; then
  gpuci_logger "Upload token present, uploading..."
  cat conda.output | xargs gpuci_retry anaconda -t ${MY_UPLOAD_KEY} upload -u ${CONDA_USERNAME:-rapidsai} --label main --skip-existing
else
  gpuci_logger "Upload token 'MY_UPLOAD_KEY' not present, skipping upload..."
fi
