#!/bin/bash

# Update and install dependencies
sudo apt-get update
sudo apt-get install -y software-properties-common

# Install NVIDIA driver
sudo apt-get install -y nvidia-driver-525

# Install CUDA 11.8
wget https://developer.download.nvidia.com/compute/cuda/11.8.0/local_installers/cuda_11.8.0_520.61.05_linux.run
sudo sh cuda_11.8.0_520.61.05_linux.run --silent --toolkit

# Set up CUDA environment variables
echo 'export PATH=/usr/local/cuda-11.8/bin${PATH:+:${PATH}}' >> ~/.bashrc
echo 'export LD_LIBRARY_PATH=/usr/local/cuda-11.8/lib64${LD_LIBRARY_PATH:+:${LD_LIBRARY_PATH}}' >> ~/.bashrc

# Install cuDNN 8.6
# Note: You need to manually download cuDNN from NVIDIA's website and upload it to a accessible location
# Replace 'URL_TO_CUDNN_TARBALL' with the actual URL where you've hosted the cuDNN tarball
wget URL_TO_CUDNN_TARBALL -O cudnn.tgz
tar -xzvf cudnn.tgz
sudo cp cuda/include/cudnn*.h /usr/local/cuda/include
sudo cp cuda/lib64/libcudnn* /usr/local/cuda/lib64
sudo chmod a+r /usr/local/cuda/include/cudnn*.h /usr/local/cuda/lib64/libcudnn*

# Install Python 3.12
sudo add-apt-repository ppa:deadsnakes/ppa -y
sudo apt-get update
sudo apt-get install -y python3.12 python3.12-venv python3.12-dev

# Create alternatives for python3 and python
sudo update-alternatives --install /usr/bin/python3 python3 /usr/bin/python3.10 1
sudo update-alternatives --install /usr/bin/python python /usr/bin/python3.12 1

# Set Python 3.12 as the default, but allow easy switching
sudo update-alternatives --set python3 /usr/bin/python3.12
sudo update-alternatives --set python /usr/bin/python3.12

# Install pip for Python 3.12
curl https://bootstrap.pypa.io/get-pip.py | sudo python3.12

# Install TensorFlow and other necessary packages
sudo python3.12 -m pip install tensorflow

# Verify installations
echo "Python version:"
python --version

echo "NVIDIA driver:"
nvidia-smi

echo "CUDA version:"
nvcc --version

echo "cuDNN version:"
python -c "import tensorflow as tf; print(tf.sysconfig.get_build_info()['cudnn_version'])"

echo "TensorFlow GPU support:"
python -c "import tensorflow as tf; print(tf.config.list_physical_devices('GPU'))"