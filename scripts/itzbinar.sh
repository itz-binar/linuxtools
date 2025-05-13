#!/data/data/com.termux/files/usr/bin/bash

# =========================================================
#                    ITZBINAR TOOLKIT
#          Advanced Penetration Testing Environment
# =========================================================
# Developer: ITZBINAR
# Version: 2.4
# GitHub: https://github.com/itzbinar
# Description: Professional Pentesting Environment Setup
# Support: Root and Non-Root Devices
# License: MIT
# =========================================================

# Ensure running in Termux
if [ ! -d "/data/data/com.termux" ]; then
    echo "Error: This script must be run in Termux!"
    exit 1
fi

# Set up colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Print banner
echo -e "${BLUE}
+=================================================================+
|    ██╗████████╗███████╗██████╗ ██╗███╗   ██╗ █████╗ ██████╗     |
|    ██║╚══██╔══╝╚══███╔╝██╔══██╗██║████╗  ██║██╔══██╗██╔══██╗    |
|    ██║   ██║     ███╔╝ ██████╔╝██║██╔██╗ ██║███████║██████╔╝    |
|    ██║   ██║    ███╔╝  ██╔══██╗██║██║╚██╗██║██╔══██║██╔══██╗    |
|    ██║   ██║   ███████╗██████╔╝██║██║ ╚████║██║  ██║██║  ██║    |
|    ╚═╝   ╚═╝   ╚══════╝╚═════╝ ╚═╝╚═╝  ╚═══╝╚═╝  ╚═╝╚═╝  ╚═╝    |
+=================================================================+
${NC}"

echo -e "${GREEN}[*] Starting installation...${NC}"

# Update package lists
echo -e "${YELLOW}[*] Updating package lists...${NC}"
pkg update -y && pkg upgrade -y

# Install base packages
echo -e "${YELLOW}[*] Installing base packages...${NC}"
pkg install -y wget curl git python proot proot-distro openssh

# Install Kali Linux
echo -e "${YELLOW}[*] Installing Kali Linux...${NC}"
proot-distro install kali

# Install NetHunter
echo -e "${YELLOW}[*] Installing NetHunter...${NC}"
proot-distro install nethunter

# Install Arch Linux
echo -e "${YELLOW}[*] Installing Arch Linux...${NC}"
proot-distro install archlinux

# Set up aliases
echo -e "${YELLOW}[*] Setting up aliases...${NC}"
cat >> ~/.bashrc << 'EOF'

# Environment shortcuts
alias kali='proot-distro login kali'
alias kali-root='proot-distro login kali --user root'
alias nh='proot-distro login nethunter'
alias nh-root='proot-distro login nethunter --user root'
alias arch='proot-distro login archlinux'
alias arch-root='proot-distro login archlinux --user root'

# GUI shortcuts
alias nh-kex='nethunter kex passwd && nethunter kex &'
alias nh-kex-stop='nethunter kex stop'
alias start-vnc='vncserver -localhost no'
alias stop-vnc='vncserver -kill :1'

# Utility shortcuts
alias update='pkg update -y && pkg upgrade -y'
alias fix-proot='pkill -9 proot'
alias fix-permission='termux-setup-storage'
EOF

# Set up storage access
echo -e "${YELLOW}[*] Setting up storage access...${NC}"
termux-setup-storage

# Install additional tools
echo -e "${YELLOW}[*] Installing additional tools...${NC}"
pkg install -y vim nano tmux htop neofetch nmap

echo -e "${GREEN}[✓] Installation completed successfully!${NC}"
echo -e "${YELLOW}[*] Please restart Termux and run 'source ~/.bashrc'${NC}"
