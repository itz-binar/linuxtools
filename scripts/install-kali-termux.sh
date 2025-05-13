#!/data/data/com.termux/files/usr/bin/bash

# =========================================================
# Advanced Termux + Kali + NetHunter Installer
# Developer: ITZBINAR
# Version: 2.2
# GitHub: https://github.com/itzbinar
# Description: Professional Pentesting Environment Setup
# Support: Root and Non-Root Devices
# License: MIT
# =========================================================

# Colors for better readability
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Function to print colored messages
print_message() {
    echo -e "${2}${1}${NC}"
}

# Function to check if command executed successfully
check_status() {
    if [ $? -eq 0 ]; then
        print_message "✓ $1" "$GREEN"
    else
        print_message "✗ $1" "$RED"
        exit 1
    fi
}

# Function to install package if not installed
install_package() {
    if ! command -v $1 &> /dev/null; then
        print_message "Installing $1..." "$YELLOW"
        pkg install -y $1
        check_status "$1 installation"
    fi
}

# Function to check if device is rooted
check_root() {
    if su -c "whoami" >/dev/null 2>&1; then
        return 0
    else
        return 1
    fi
}

# Function to setup non-root environment
setup_nonroot() {
    print_message "\n🔧 Setting up non-root environment..." "$YELLOW"
    
    # Create necessary directories
    mkdir -p ~/.termux/boot
    mkdir -p ~/storage
    
    # Setup proot-distro for better compatibility
    pkg install -y proot-distro
    
    # Configure proot-distro for better performance
    cat > ~/.termux/proot-distro.override.conf << 'EOL'
PROOT_OPTIONS="-L -r /data/data/com.termux/files/usr"
MOUNT_SDCARD=true
TERMUX_ARCH="aarch64"
EOL
    
    print_message "✓ Non-root environment configured" "$GREEN"
}

# Function to install Kali NetHunter
install_nethunter() {
    print_message "\n🔰 Installing Kali NetHunter..." "$YELLOW"
    
    # Download NetHunter installer
    wget -O install-nethunter-termux https://offs.ec/2MceZWr
    chmod +x install-nethunter-termux
    
    # Run NetHunter installer
    ./install-nethunter-termux
    
    # Create NetHunter aliases
    cat >> ~/.bashrc << 'EOL'

# NetHunter aliases
alias nh='nethunter'
alias nh-kex='nethunter kex'
alias nh-kex-stop='nethunter kex stop'
alias nh-root='nethunter -r'
alias nh-update='nethunter update'
EOL
    
    # Create NetHunter setup script
    cat > ~/.nethunter-setup.sh << 'EOL'
#!/bin/bash
# Setup NetHunter GUI password
nethunter kex passwd

# Start NetHunter GUI
nethunter kex

# Instructions for GUI access
echo "NetHunter GUI is ready!"
echo "Use these commands:"
echo "- Start GUI: nh-kex"
echo "- Stop GUI: nh-kex-stop"
echo "- Root shell: nh-root"
EOL
    chmod +x ~/.nethunter-setup.sh
    
    print_message "✓ NetHunter installation complete" "$GREEN"
}

# Function to print banner
print_banner() {
    print_message "
    ╔══════════════════════════════════════════════════════╗
    ║                     ITZBINAR                         ║
    ║        Advanced Pentesting Toolkit + NetHunter       ║
    ║     Kali + NetHunter + Arch Linux + Termux          ║
    ║          Supports Root & Non-Root Devices           ║
    ╚══════════════════════════════════════════════════════╝
    " "$PURPLE"
    print_message "           Created by: ITZBINAR - 2024" "$CYAN"
    print_message "     Professional Penetration Testing Suite" "$CYAN"
    echo
}

# Welcome message
clear
print_banner

# Check if running in Termux
if [ ! -d "/data/data/com.termux" ]; then
    print_message "Error: This script must be run in Termux!" "$RED"
    exit 1
fi

# Check root status and setup accordingly
if check_root; then
    print_message "📱 Root access detected - enabling advanced features" "$GREEN"
else
    print_message "📱 Non-root device detected - setting up compatible environment" "$YELLOW"
    setup_nonroot
fi

# Update package repositories and upgrade system
print_message "[1/12] Performing full system update..." "$YELLOW"
pkg update -y && pkg upgrade -y
check_status "System update completed"

# Install essential Termux packages
print_message "\n[2/12] Installing essential Termux packages..." "$YELLOW"
essential_packages=(
    "proot-distro" "curl" "wget" "git" "python" "python-pip" "vim" "nano"
    "openssh" "tmux" "htop" "nmap" "hydra" "cmatrix" "ffmpeg" "nodejs" 
    "php" "ruby" "rust" "golang" "clang" "make" "postgresql" "mariadb"
    "termux-api" "termux-tools" "x11-repo"
)

for package in "${essential_packages[@]}"; do
    install_package "$package"
done

# Setup storage access
print_message "\n[3/12] Setting up storage access..." "$YELLOW"
termux-setup-storage
check_status "Storage access setup"

# Install Kali Linux
print_message "\n[4/12] Installing Kali Linux..." "$YELLOW"
proot-distro install kali
check_status "Kali Linux installation"

# Install NetHunter
print_message "\n[5/12] Installing Kali NetHunter..." "$YELLOW"
install_nethunter
check_status "NetHunter installation"

# Install Arch Linux
print_message "\n[6/12] Installing Arch Linux..." "$YELLOW"
proot-distro install archlinux
check_status "Arch Linux installation"

# Create convenient aliases
print_message "\n[7/12] Creating system aliases..." "$YELLOW"
cat >> ~/.bashrc << 'EOL'

# Kali Linux aliases
alias kali='proot-distro login kali'
alias kali-root='proot-distro login kali --user root'
alias kali-fix='proot-distro reset kali'

# Arch Linux aliases
alias arch='proot-distro login archlinux'
alias arch-root='proot-distro login archlinux --user root'
alias arch-fix='proot-distro reset archlinux'

# Useful aliases for non-root environment
alias update='pkg update && pkg upgrade'
alias ls='ls --color=auto'
alias ll='ls -la'
alias python='python3'
alias pip='pip3'
alias fix-proot='kill -9 $(pgrep proot)'
alias fix-permission='termux-setup-storage'
EOL
source ~/.bashrc
check_status "System aliases created"

# Create Kali Linux setup script
print_message "\n[8/12] Creating Kali Linux setup script..." "$YELLOW"
cat > ~/.kali-setup.sh << 'EOL'
#!/bin/bash
# Update system
apt update && apt upgrade -y

# Install essential tools
apt install -y kali-linux-default
apt install -y python3-pip git vim nano tmux
apt install -y nmap dirb nikto
apt install -y metasploit-framework

# Setup Python environment
pip3 install --upgrade pip
pip3 install requests beautifulsoup4 scapy
EOL
chmod +x ~/.kali-setup.sh

# Create Arch Linux setup script
print_message "\n[9/12] Creating Arch Linux setup script..." "$YELLOW"
cat > ~/.arch-setup.sh << 'EOL'
#!/bin/bash
# Update system
pacman -Syu --noconfirm

# Install base development tools
pacman -S --noconfirm base-devel git vim python python-pip
pacman -S --noconfirm nodejs npm go rust
EOL
chmod +x ~/.arch-setup.sh

# Install Python packages
print_message "\n[10/12] Installing Python packages..." "$YELLOW"
pip install --upgrade pip
pip install requests beautifulsoup4 colorama
pip install youtube-dl flask django
check_status "Python packages installed"

# Create troubleshooting script
print_message "\n[11/12] Creating troubleshooting tools..." "$YELLOW"
cat > ~/bin/fix-environment << 'EOL'
#!/data/data/com.termux/files/usr/bin/bash

# Kill hanging proot processes
pkill -9 proot

# Reset terminal
kill -9 -1

# Fix permissions
termux-setup-storage

# Update package lists
pkg update

echo "Environment fixed and reset"
EOL
chmod +x ~/bin/fix-environment

# Create NetHunter GUI setup script
print_message "\n[12/12] Creating NetHunter GUI setup..." "$YELLOW"
cat > ~/bin/setup-nethunter-gui << 'EOL'
#!/data/data/com.termux/files/usr/bin/bash

# Set up NetHunter GUI
nethunter kex passwd
nethunter kex

echo "NetHunter GUI is now ready!"
echo "Access with:"
echo "- VNC Viewer"
echo "- Port: 5901"
echo "- Password: (the one you set)"
EOL
chmod +x ~/bin/setup-nethunter-gui
check_status "NetHunter GUI setup created"

# Success message and instructions
print_message "\n✨ Advanced Installation Complete! ✨\n" "$GREEN"

print_message "📚 Quick Start Guide:" "$YELLOW"
print_message "1. NetHunter Commands:" "$YELLOW"
print_message "   → Start NetHunter: nh" "$GREEN"
print_message "   → Start GUI: nh-kex" "$GREEN"
print_message "   → Stop GUI: nh-kex-stop" "$GREEN"
print_message "   → Root shell: nh-root\n" "$GREEN"

print_message "2. Kali Linux:" "$YELLOW"
print_message "   → Start Kali: kali" "$GREEN"
print_message "   → Setup tools: ~/.kali-setup.sh\n" "$GREEN"

print_message "3. Troubleshooting:" "$YELLOW"
print_message "   → Fix environment: ~/bin/fix-environment" "$GREEN"
print_message "   → Setup NetHunter GUI: ~/bin/setup-nethunter-gui" "$GREEN"
print_message "   → Fix permissions: fix-permission\n" "$GREEN"

print_message "Note: Some features may require root access" "$YELLOW"
print_message "      Use alternative tools when available\n" "$YELLOW"

# Show developer information
show_developer_info() {
    print_message "\n📱 Developer Information:" "$PURPLE"
    print_message "   → Developer: ITZBINAR" "$CYAN"
    print_message "   → Version: 2.2" "$CYAN"
    print_message "   → GitHub: https://github.com/itzbinar" "$CYAN"
    print_message "   → Report issues or contribute on GitHub\n" "$CYAN"
}

# Show developer information at the end
show_developer_info

print_message "🚀 Happy Hacking! Enjoy your professional pentesting environment! 🚀\n" "$CYAN"
print_message "     Powered by ITZBINAR's Advanced Toolkit\n" "$PURPLE" 