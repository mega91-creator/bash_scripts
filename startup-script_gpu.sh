#!/bin/bash
# Exit on any error
set -e

# Function to log messages
log() {
    echo "[$(date +'%Y-%m-%d %H:%M:%S')] $1"
}

# Function to check command status
check_status() {
    if [ $? -eq 0 ]; then
        log "✓ $1 successful"
    else
        log "✗ $1 failed"
        exit 1
    fi
}

log "Starting GPU setup script..."

# Update package lists and upgrade existing packages
log "Updating package lists..."
sudo apt-get update && sudo apt-get upgrade -y
check_status "Package list update"

# Install essential build tools and libraries
log "Installing build essentials and development tools..."
sudo apt-get install -y build-essential cmake gcc g++ pkg-config \
    autoconf automake libtool gdb libssl-dev software-properties-common
check_status "Build essentials installation"

# Install NVIDIA GPU drivers and CUDA toolkit following official instructions
log "Installing NVIDIA drivers and CUDA toolkit..."
wget https://developer.download.nvidia.com/compute/cuda/repos/ubuntu2404/x86_64/cuda-keyring_1.1-1_all.deb
sudo dpkg -i cuda-keyring_1.1-1_all.deb
check_status "CUDA keyring installation"

sudo apt-get update
check_status "Repository update after CUDA keyring"

# Install CUDA toolkit first (includes drivers)
log "Installing CUDA toolkit..."
sudo apt-get install -y cuda-toolkit-12-5
check_status "CUDA toolkit installation"

# Install open kernel module flavor
log "Installing NVIDIA open kernel module..."
sudo apt-get install -y nvidia-open
check_status "NVIDIA open driver installation"

# Install CUDA drivers
log "Installing CUDA drivers..."
sudo apt-get install -y cuda-drivers
check_status "CUDA drivers installation"

# Install GDS
log "Installing NVIDIA GDS..."
sudo apt-get install -y nvidia-gds
check_status "NVIDIA GDS installation"

# Install cuDNN
log "Installing cuDNN..." 
wget https://developer.download.nvidia.com/compute/cuda/repos/ubuntu2404/x86_64/cuda-ubuntu2404.pin
sudo mv cuda-ubuntu2404.pin /etc/apt/preferences.d/cuda-repository-pin-600
sudo apt-get update
check_status "CUDA repository update"

# Install cuDNN packages
log "Installing cuDNN packages..."
sudo apt-get install -y libcudnn9-cuda-12 libcudnn9-dev-cuda-12
check_status "cuDNN installation" 

# Add Python 3.12 repository and install
log "Adding Python 3.12 repository..."
sudo add-apt-repository -y ppa:deadsnakes/ppa
check_status "Repository addition"
sudo apt-get update
check_status "Repository update"

# Install Python 3.12 and related packages
log "Installing Python 3.12 and related packages..."
sudo apt-get install -y python3.12 python3.12-venv python3.12-dev python3-lib2to3 \
    python3-gdbm python-is-python3 python3.12-full
check_status "Python 3.12 installation"

# Fix Python apt issues
log "Fixing Python apt integration..."
sudo apt-get install -y python3-apt
check_status "Python apt fix"

# Create virtual environment for Python 3.12
log "Creating Python 3.12 virtual environment..."
python3.12 -m venv ~/py312_env
check_status "Virtual environment creation"

# Configure environment
log "Configuring environment..."
# Add CUDA paths to .bashrc
echo '# CUDA Paths' >> ~/.bashrc
echo 'export PATH=/usr/local/cuda-12.5/bin${PATH:+:${PATH}}' >> ~/.bashrc
echo 'export LD_LIBRARY_PATH=/usr/local/cuda-12.5/lib64${LD_LIBRARY_PATH:+:${LD_LIBRARY_PATH}}' >> ~/.bashrc
# Add virtual environment to path
echo 'export PATH="$HOME/py312_env/bin:$PATH"' >> ~/.bashrc
source ~/.bashrc
check_status "Environment configuration"

# Activate virtual environment and install pip
log "Setting up pip in virtual environment..."
source ~/py312_env/bin/activate
curl -sS https://bootstrap.pypa.io/get-pip.py -o get-pip.py
~/py312_env/bin/python get-pip.py
rm get-pip.py
check_status "Pip installation"

# Install ngrok if needed
if [ ! -z "$NGROK_AUTH_TOKEN" ]; then
    log "Installing ngrok..."
    curl -sSL https://ngrok-agent.s3.amazonaws.com/ngrok.asc | sudo tee /etc/apt/trusted.gpg.d/ngrok.asc >/dev/null
    echo "deb https://ngrok-agent.s3.amazonaws.com buster main" | sudo tee /etc/apt/sources.list.d/ngrok.list
    sudo apt-get update
    sudo apt-get install -y ngrok
    check_status "Ngrok installation"
    
    log "Configuring ngrok..."
    ngrok config add-authtoken "$NGROK_AUTH_TOKEN"
    check_status "Ngrok configuration"
fi

# Verify installation
log "Verifying installation..."

log "Loading CUDA environment..."
export PATH=/usr/local/cuda-12.5/bin${PATH:+:${PATH}}
export LD_LIBRARY_PATH=/usr/local/cuda-12.5/lib64${LD_LIBRARY_PATH:+:${LD_LIBRARY_PATH}}

# Run verification commands
nvidia-smi
check_status "nvidia-smi test"

# Test nvcc after loading CUDA paths
nvcc --version
check_status "nvcc test"

python3.12 --version
~/py312_env/bin/python --version
~/py312_env/bin/pip --version

log "Setup completed successfully!"
log "NVIDIA driver, CUDA toolkit, and cuDNN are installed"
log "Python 3.12 virtual environment is available at: ~/py312_env/"
log "To activate the virtual environment: source ~/py312_env/bin/activate"
log "Please reboot the system to complete the installation"

# Optional: Print CUDA paths for verification
log "CUDA paths:"
echo "PATH=$PATH"
echo "LD_LIBRARY_PATH=$LD_LIBRARY_PATH"

# Prompt for reboot
read -p "Would you like to reboot now? (y/n) " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]
then
    sudo reboot
fi