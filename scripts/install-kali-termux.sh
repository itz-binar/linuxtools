#!/data/data/com.termux/files/usr/bin/bash

# =========================================================
# Advanced Termux + Kali + Arch Linux Installer
# Developer: ITZBINAR
# Version: 2.1
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

# Function to print banner
print_banner() {
    print_message "
    ╔══════════════════════════════════════════════════════╗
    ║                     ITZBINAR                         ║
    ║            Advanced Pentesting Toolkit               ║
    ║        Kali + Arch Linux + Termux Installer         ║
    ║          Supports Root & Non-Root Devices           ║
    ╚══════════════════════════════════════════════════════╝
    " "$PURPLE"
    print_message "           Created by: ITZBINAR - 2024" "$CYAN"
    print_message "     Professional Penetration Testing Suite" "$CYAN"
    echo
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
print_message "[1/10] Performing full system update..." "$YELLOW"
pkg update -y && pkg upgrade -y
check_status "System update completed"

# Install essential Termux packages with non-root compatibility
print_message "\n[2/10] Installing essential Termux packages..." "$YELLOW"
essential_packages=(
    "proot-distro" "curl" "wget" "git" "python" "python-pip" "vim" "nano"
    "openssh" "tmux" "htop" "nmap" "hydra" "cmatrix" "ffmpeg" "nodejs" 
    "php" "ruby" "rust" "golang" "clang" "make" "postgresql" "mariadb"
    "termux-api" "termux-tools" "x11-repo"
)

for package in "${essential_packages[@]}"; do
    install_package "$package"
done

# Setup storage access with proper permissions
print_message "\n[3/10] Setting up storage access..." "$YELLOW"
termux-setup-storage
check_status "Storage access setup"

# Install Kali Linux with non-root optimizations
print_message "\n[4/10] Installing Kali Linux (this may take a while)..." "$YELLOW"
proot-distro install kali
check_status "Kali Linux installation"

# Install Arch Linux with non-root optimizations
print_message "\n[5/10] Installing Arch Linux (this may take a while)..." "$YELLOW"
proot-distro install archlinux
check_status "Arch Linux installation"

# Create convenient aliases with proper permissions
print_message "\n[6/10] Creating system aliases..." "$YELLOW"
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

# Create Kali Linux setup script with non-root compatibility
print_message "\n[7/10] Creating Kali Linux setup script..." "$YELLOW"
cat > ~/.kali-setup.sh << 'EOL'
#!/bin/bash
# Update system
apt update && apt upgrade -y

# Install essential tools (non-root compatible)
apt install -y kali-linux-default
apt install -y python3-pip git vim nano tmux
apt install -y nmap dirb nikto
apt install -y metasploit-framework

# Setup Python environment
pip3 install --upgrade pip
pip3 install requests beautifulsoup4 scapy
EOL
chmod +x ~/.kali-setup.sh

# Create Arch Linux setup script with non-root compatibility
print_message "\n[8/10] Creating Arch Linux setup script..." "$YELLOW"
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
print_message "\n[9/10] Installing Python packages..." "$YELLOW"
pip install --upgrade pip
pip install requests beautifulsoup4 colorama
pip install youtube-dl flask django
check_status "Python packages installed"

# Create troubleshooting script
print_message "\n[10/10] Creating troubleshooting tools..." "$YELLOW"
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
check_status "Troubleshooting tools created"

# Success message and instructions
print_message "\n✨ Advanced Installation Complete! ✨\n" "$GREEN"

print_message "📚 Non-Root Device Guide:" "$YELLOW"
print_message "1. Starting Linux Systems:" "$YELLOW"
print_message "   → Kali Linux: kali" "$GREEN"
print_message "   → Arch Linux: arch" "$GREEN"
print_message "   → Fix issues: fix-proot\n" "$GREEN"

print_message "2. Troubleshooting:" "$YELLOW"
print_message "   → Reset environment: ~/bin/fix-environment" "$GREEN"
print_message "   → Fix permissions: fix-permission" "$GREEN"
print_message "   → Reset Kali: kali-fix" "$GREEN"
print_message "   → Reset Arch: arch-fix\n" "$GREEN"

print_message "3. Common Commands:" "$YELLOW"
print_message "   → Update: update" "$GREEN"
print_message "   → Storage access: termux-setup-storage" "$GREEN"
print_message "   → Install tools: pkg install <package>\n" "$GREEN"

print_message "Note: Some tools may have limited functionality without root access." "$YELLOW"
print_message "      Use alternative tools when available.\n" "$YELLOW"

# Before exit, show developer info
show_developer_info() {
    print_message "\n📱 Developer Information:" "$PURPLE"
    print_message "   → Developer: ITZBINAR" "$CYAN"
    print_message "   → Version: 2.1" "$CYAN"
    print_message "   → GitHub: https://github.com/itzbinar" "$CYAN"
    print_message "   → Report issues or contribute on GitHub\n" "$CYAN"
}

# Show developer information at the end
show_developer_info

print_message "🚀 Happy Hacking! Enjoy your professional pentesting environment! 🚀\n" "$CYAN"
print_message "     Powered by ITZBINAR's Advanced Toolkit\n" "$PURPLE" 