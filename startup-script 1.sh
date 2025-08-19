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

log "Starting setup script..."

# Update package lists and upgrade existing packages
log "Updating package lists..."
sudo apt-get update || true  # Continue even if there are apt_pkg errors
check_status "Package list update"

# Install build essentials and development tools
log "Installing build essentials and development tools..."
sudo apt-get install -y build-essential cmake gcc g++ pkg-config python3-dev
check_status "Build essentials installation"

# Install CUDA and cuDNN
log "Installing CUDA and cuDNN..."
wget https://developer.download.nvidia.com/compute/cuda/repos/ubuntu2404/x86_64/cuda-keyring_1.1-1_all.deb
sudo dpkg -i cuda-keyring_1.1-1_all.deb
check_status "CUDA keyring installation"

sudo apt-get update
check_status "Repository update after CUDA keyring"

sudo apt-get -y install cudnn
check_status "cuDNN installation"

# Install OpenBLAS and additional development packages
log "Installing OpenBLAS and additional dependencies..."
sudo apt-get install -y libopenblas-dev
check_status "OpenBLAS installation"

# Install software-properties-common for add-apt-repository
log "Installing software-properties-common..."
sudo apt-get install -y software-properties-common
check_status "software-properties-common installation"

# Clean up unnecessary packages
log "Cleaning up unnecessary packages..."
sudo apt autoremove -y
check_status "Package cleanup"

# Add Python 3.12 repository and install
log "Adding Python 3.12 repository..." 
sudo add-apt-repository -y ppa:deadsnakes/ppa
check_status "Repository addition"
sudo apt-get update
check_status "Repository update"

log "Installing Python 3.12 and related packages..."
sudo apt-get install -y python3.12 python3.12-venv python3.12-dev python3-lib2to3 python3-gdbm python-is-python3 python3.12-full
check_status "Python 3.12 installation"

# Fix Python apt issues by reinstalling python3-apt for system Python
log "Fixing Python apt integration..."
sudo apt-get install -y python3-apt
check_status "Python apt fix"

# Create virtual environment for Python 3.12
log "Creating Python 3.12 virtual environment..."
python3.12 -m venv ~/py312_env
check_status "Virtual environment creation"

# Add virtual environment activation to .bashrc and activate it
echo 'export PATH="$HOME/py312_env/bin:$PATH"' >> ~/.bashrc
source ~/.bashrc
source ~/py312_env/bin/activate
check_status "Environment activation"

# Install pip in the virtual environment
log "Installing pip in virtual environment..."
curl -sS https://bootstrap.pypa.io/get-pip.py -o get-pip.py
~/py312_env/bin/python get-pip.py
rm get-pip.py
check_status "Pip installation"

# Configure Python alternatives with Python 3.12 as default
log "Configuring Python alternatives..."
sudo update-alternatives --install /usr/bin/python3 python3 /usr/bin/python3.12 2
check_status "Python alternatives configuration"

# Set Python 3.12 as default
log "Setting Python 3.12 as system default..."
sudo update-alternatives --set python3 /usr/bin/python3.12
check_status "Python default version setting"

# Create symbolic links for python command
log "Creating python command symlinks..."
sudo ln -sf /usr/bin/python3 /usr/bin/python

check_status "Python symlink creation"

# Create a virtual environment for Python 3.12
log "Creating Python 3.12 virtual environment..."
python3.12 -m venv ~/py312_env
check_status "Virtual environment creation"

# Add virtual environment activation to .bashrc
echo 'export PATH="$HOME/py312_env/bin:$PATH"' >> ~/.bashrc
source ~/.bashrc
check_status "Environment path configuration"

# Install ngrok if needed
if [ "$INSTALL_NGROK" = "true" ]; then
    log "Installing ngrok..."
    curl -sSL https://ngrok-agent.s3.amazonaws.com/ngrok.asc | sudo tee /etc/apt/trusted.gpg.d/ngrok.asc >/dev/null
    echo "deb https://ngrok-agent.s3.amazonaws.com buster main" | sudo tee /etc/apt/sources.list.d/ngrok.list
    sudo apt-get update
    sudo apt-get install -y ngrok
    check_status "Ngrok installation"
    
    if [ ! -z "$NGROK_AUTH_TOKEN" ]; then
        log "Configuring ngrok..."
        ngrok config add-authtoken "$NGROK_AUTH_TOKEN"
        check_status "Ngrok configuration"
    else
        log "Skipping ngrok configuration - no auth token provided"
    fi
fi

# Verify installation
log "Verifying installation..."
log "System Python version:"
python --version
python3 --version

log "Virtual environment Python version:"
~/py312_env/bin/python --version
~/py312_env/bin/pip --version

log "Verifying build tools:"
gcc --version
g++ --version
cmake --version

log "Setup completed successfully!"
log "Python 3.12 is now the default Python version"
log "Build tools (gcc, g++, cmake) are installed"
log "CUDA and cuDNN are installed"
log "The virtual environment is also available at: ~/py312_env/"
log "To activate the virtual environment: source ~/py312_env/bin/activate"

# chmod +x startup-script.sh
# INSTALL_NGROK=true NGROK_AUTH_TOKEN="2lwGcF0OG7IuB4wDlItzaFRdNe7_5kDo8NKgoTfPdnYFJmgKX" ./startup-script.sh

# Add nvcc