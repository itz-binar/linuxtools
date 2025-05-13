#!/data/data/com.termux/files/usr/bin/bash

# =========================================================
# Advanced Termux + Kali + Arch Linux Installer
# Developer: ITZBINAR
# Version: 2.0
# GitHub: https://github.com/itzbinar
# Description: Professional Pentesting Environment Setup
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

# Function to print banner
print_banner() {
    print_message "
    ╔══════════════════════════════════════════════════════╗
    ║                     ITZBINAR                         ║
    ║            Advanced Pentesting Toolkit               ║
    ║        Kali + Arch Linux + Termux Installer         ║
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

# Update package repositories and upgrade system
print_message "[1/10] Performing full system update..." "$YELLOW"
pkg update -y && pkg upgrade -y
check_status "System update completed"

# Install essential Termux packages
print_message "\n[2/10] Installing essential Termux packages..." "$YELLOW"
essential_packages=(
    "proot-distro" "curl" "wget" "git" "python" "python-pip" "vim" "nano"
    "openssh" "tmux" "htop" "nmap" "hydra" "cmatrix" "ffmpeg" "nodejs" 
    "php" "ruby" "rust" "golang" "clang" "make" "postgresql" "mariadb"
    "termux-api" "termux-tools" "root-repo" "x11-repo"
)

for package in "${essential_packages[@]}"; do
    install_package "$package"
done

# Setup storage access
print_message "\n[3/10] Setting up storage access..." "$YELLOW"
termux-setup-storage
check_status "Storage access setup"

# Install Kali Linux
print_message "\n[4/10] Installing Kali Linux (this may take a while)..." "$YELLOW"
proot-distro install kali
check_status "Kali Linux installation"

# Install Arch Linux
print_message "\n[5/10] Installing Arch Linux (this may take a while)..." "$YELLOW"
proot-distro install archlinux
check_status "Arch Linux installation"

# Create convenient aliases
print_message "\n[6/10] Creating system aliases..." "$YELLOW"
cat >> ~/.bashrc << 'EOL'

# Kali Linux alias
alias kali='proot-distro login kali'
alias kali-root='proot-distro login kali --user root'

# Arch Linux alias
alias arch='proot-distro login archlinux'
alias arch-root='proot-distro login archlinux --user root'

# Useful aliases
alias update='pkg update && pkg upgrade'
alias ls='ls --color=auto'
alias ll='ls -la'
alias python='python3'
alias pip='pip3'
EOL
source ~/.bashrc
check_status "System aliases created"

# Create Kali Linux setup script
print_message "\n[7/10] Creating Kali Linux setup script..." "$YELLOW"
cat > ~/.kali-setup.sh << 'EOL'
#!/bin/bash
# Update system
apt update && apt upgrade -y

# Install essential tools
apt install -y kali-linux-default metasploit-framework exploitdb
apt install -y wordlists dirb dirbuster nikto wpscan
apt install -y burpsuite wireshark nmap sqlmap
apt install -y python3-pip git vim nano tmux
apt install -y theharvester maltego beef-xss
apt install -y social-engineering-toolkit

# Setup Python environment
pip3 install --upgrade pip
pip3 install requests beautifulsoup4 scapy
EOL
chmod +x ~/.kali-setup.sh

# Create Arch Linux setup script
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

# Create desktop shortcuts
print_message "\n[10/10] Creating convenient scripts..." "$YELLOW"
mkdir -p ~/bin
cat > ~/bin/pentest-tools << 'EOL'
#!/data/data/com.termux/files/usr/bin/bash
echo "Starting Penetration Testing Tools..."
nmap -v
EOL
chmod +x ~/bin/pentest-tools
check_status "Convenient scripts created"

# Before exit, show developer info
show_developer_info() {
    print_message "\n📱 Developer Information:" "$PURPLE"
    print_message "   → Developer: ITZBINAR" "$CYAN"
    print_message "   → Version: 2.0" "$CYAN"
    print_message "   → GitHub: https://github.com/itzbinar" "$CYAN"
    print_message "   → Report issues or contribute on GitHub\n" "$CYAN"
}

# Add developer info at the end
print_message "\n✨ Advanced Installation Complete! ✨\n" "$GREEN"

print_message "📚 Quick Start Guide:" "$YELLOW"
print_message "1. Kali Linux Commands:" "$YELLOW"
print_message "   → Start Kali: kali" "$GREEN"
print_message "   → Start as root: kali-root" "$GREEN"
print_message "   → Setup Kali: bash ~/.kali-setup.sh\n" "$GREEN"

print_message "2. Arch Linux Commands:" "$YELLOW"
print_message "   → Start Arch: arch" "$GREEN"
print_message "   → Start as root: arch-root" "$GREEN"
print_message "   → Setup Arch: bash ~/.arch-setup.sh\n" "$GREEN"

print_message "3. Termux Commands:" "$YELLOW"
print_message "   → Update system: update" "$GREEN"
print_message "   → View processes: htop" "$GREEN"
print_message "   → Start SSH: sshd" "$GREEN"
print_message "   → Python tools: python/pip\n" "$GREEN"

print_message "4. Additional Features:" "$YELLOW"
print_message "   → All tools are in PATH" "$GREEN"
print_message "   → Storage access enabled" "$GREEN"
print_message "   → Development environments ready" "$GREEN"
print_message "   → Pentesting tools installed\n" "$GREEN"

print_message "5. Next Steps:" "$YELLOW"
print_message "   → Run Kali setup script for full tools" "$GREEN"
print_message "   → Run Arch setup script for development tools" "$GREEN"
print_message "   → Explore installed packages with 'pkg list-installed'" "$GREEN"
print_message "   → Check ~/bin for useful scripts\n" "$GREEN"

# Show developer information at the end
show_developer_info

print_message "🚀 Happy Hacking! Enjoy your professional pentesting environment! 🚀\n" "$CYAN"
print_message "     Powered by ITZBINAR's Advanced Toolkit\n" "$PURPLE" 