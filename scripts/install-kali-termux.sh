#!/data/data/com.termux/files/usr/bin/bash

# =========================================================
# Advanced Termux + Kali + NetHunter Installer
# Developer: ITZBINAR
# Version: 2.3
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
WHITE='\033[1;37m'
NC='\033[0m' # No Color

# Error handling
set -e
trap 'handle_error $? $LINENO $BASH_LINENO "$BASH_COMMAND" $(printf "::%s" ${FUNCNAME[@]:-})' ERR

# Function to handle errors
handle_error() {
    local exit_code=$1
    local line_no=$2
    local bash_lineno=$3
    local last_command=$4
    local func_trace=$5

    print_message "\n❌ Error occurred in script:" "$RED"
    print_message "Exit code: $exit_code" "$RED"
    print_message "Line number: $line_no" "$RED"
    print_message "Command: $last_command" "$RED"
    print_message "Function trace: $func_trace" "$RED"
    
    print_message "\n🔄 Attempting to fix..." "$YELLOW"
    fix_common_errors
}

# Function to fix common errors
fix_common_errors() {
    print_message "1. Killing hanging processes..." "$YELLOW"
    pkill -9 proot 2>/dev/null || true
    
    print_message "2. Fixing permissions..." "$YELLOW"
    termux-setup-storage 2>/dev/null || true
    
    print_message "3. Updating package lists..." "$YELLOW"
    pkg update -y 2>/dev/null || true
    
    print_message "4. Cleaning package cache..." "$YELLOW"
    pkg clean 2>/dev/null || true
    
    print_message "\n✔ Recovery attempted. Please try again." "$GREEN"
}

# Function to print colored messages
print_message() {
    echo -e "${2}${1}${NC}"
}

# Function to print menu
print_menu() {
    clear
    print_banner
    print_message "\n📋 Main Menu:" "$WHITE"
    print_message "1. Full Installation (Recommended)" "$CYAN"
    print_message "2. Custom Installation" "$CYAN"
    print_message "3. Update Existing Installation" "$CYAN"
    print_message "4. Fix & Troubleshoot" "$CYAN"
    print_message "5. Backup & Restore" "$CYAN"
    print_message "6. Uninstall" "$CYAN"
    print_message "7. About" "$CYAN"
    print_message "8. Exit\n" "$CYAN"
    
    read -p "Select an option (1-8): " menu_choice
    handle_menu_choice
}

# Function to handle menu choices
handle_menu_choice() {
    case $menu_choice in
        1) perform_full_installation ;;
        2) show_custom_installation_menu ;;
        3) perform_update ;;
        4) show_troubleshoot_menu ;;
        5) show_backup_menu ;;
        6) perform_uninstall ;;
        7) show_about ;;
        8) exit_script ;;
        *) print_message "Invalid option. Please try again." "$RED" && sleep 2 && print_menu ;;
    esac
}

# Function to show custom installation menu
show_custom_installation_menu() {
    clear
    print_message "\n🔧 Custom Installation Menu:" "$WHITE"
    print_message "1. Install Kali Linux Only" "$CYAN"
    print_message "2. Install NetHunter Only" "$CYAN"
    print_message "3. Install Arch Linux Only" "$CYAN"
    print_message "4. Install Basic Tools Only" "$CYAN"
    print_message "5. Back to Main Menu\n" "$CYAN"
    
    read -p "Select an option (1-5): " custom_choice
    case $custom_choice in
        1) install_kali_only ;;
        2) install_nethunter_only ;;
        3) install_arch_only ;;
        4) install_basic_tools ;;
        5) print_menu ;;
        *) print_message "Invalid option. Please try again." "$RED" && sleep 2 && show_custom_installation_menu ;;
    esac
}

# Function to show troubleshoot menu
show_troubleshoot_menu() {
    clear
    print_message "\n🔧 Troubleshooting Menu:" "$WHITE"
    print_message "1. Fix Common Issues" "$CYAN"
    print_message "2. Reset Environment" "$CYAN"
    print_message "3. Fix Permissions" "$CYAN"
    print_message "4. Fix NetHunter GUI" "$CYAN"
    print_message "5. Check System Status" "$CYAN"
    print_message "6. Back to Main Menu\n" "$CYAN"
    
    read -p "Select an option (1-6): " trouble_choice
    case $trouble_choice in
        1) fix_common_errors ;;
        2) reset_environment ;;
        3) fix_permissions ;;
        4) fix_nethunter_gui ;;
        5) check_system_status ;;
        6) print_menu ;;
        *) print_message "Invalid option. Please try again." "$RED" && sleep 2 && show_troubleshoot_menu ;;
    esac
}

# Function to show backup menu
show_backup_menu() {
    clear
    print_message "\n💾 Backup & Restore Menu:" "$WHITE"
    print_message "1. Backup Environment" "$CYAN"
    print_message "2. Restore from Backup" "$CYAN"
    print_message "3. Export Settings" "$CYAN"
    print_message "4. Import Settings" "$CYAN"
    print_message "5. Back to Main Menu\n" "$CYAN"
    
    read -p "Select an option (1-5): " backup_choice
    case $backup_choice in
        1) backup_environment ;;
        2) restore_environment ;;
        3) export_settings ;;
        4) import_settings ;;
        5) print_menu ;;
        *) print_message "Invalid option. Please try again." "$RED" && sleep 2 && show_backup_menu ;;
    esac
}

# Function to perform full installation
perform_full_installation() {
    print_message "\n🚀 Starting Full Installation..." "$WHITE"
    
    # Update system
    update_system
    
    # Install components
    install_basic_tools
    install_kali_linux
    install_nethunter
    install_arch_linux
    setup_gui_environment
    configure_aliases
    setup_scripts
    
    print_message "\n✨ Full Installation Complete!" "$GREEN"
    press_enter_to_continue
}

# Function to perform update
perform_update() {
    print_message "\n🔄 Updating System..." "$WHITE"
    
    # Update package lists
    pkg update -y
    
    # Upgrade packages
    pkg upgrade -y
    
    # Update Kali
    proot-distro login kali -- apt update
    proot-distro login kali -- apt upgrade -y
    
    # Update Arch
    proot-distro login archlinux -- pacman -Syu --noconfirm
    
    # Update NetHunter
    nethunter update
    
    print_message "\n✨ Update Complete!" "$GREEN"
    press_enter_to_continue
}

# Function to perform uninstall
perform_uninstall() {
    print_message "\n⚠️ Warning: This will remove all installed components." "$RED"
    read -p "Are you sure you want to continue? (y/N): " confirm
    
    if [[ $confirm == [yY] ]]; then
        print_message "\n🗑️ Uninstalling..." "$YELLOW"
        
        # Remove Kali
        proot-distro remove kali
        
        # Remove Arch
        proot-distro remove archlinux
        
        # Remove NetHunter
        rm -rf ~/nethunter
        
        # Remove scripts and configs
        rm -rf ~/.kali-setup.sh ~/.arch-setup.sh ~/.nethunter-setup.sh
        
        print_message "\n✨ Uninstallation Complete!" "$GREEN"
    fi
    press_enter_to_continue
}

# Function to show about
show_about() {
    clear
    print_message "\n📱 About:" "$WHITE"
    print_message "Developer: ITZBINAR" "$CYAN"
    print_message "Version: 2.3" "$CYAN"
    print_message "GitHub: https://github.com/itzbinar" "$CYAN"
    print_message "\nFeatures:" "$WHITE"
    print_message "- Full Kali Linux Environment" "$CYAN"
    print_message "- NetHunter with GUI Support" "$CYAN"
    print_message "- Arch Linux Development Environment" "$CYAN"
    print_message "- Professional Tool Suite" "$CYAN"
    print_message "- Root & Non-Root Support" "$CYAN"
    press_enter_to_continue
}

# Function to exit script
exit_script() {
    print_message "\n👋 Thank you for using ITZBINAR's Linux Tools!" "$GREEN"
    print_message "Visit https://github.com/itzbinar for updates.\n" "$CYAN"
    exit 0
}

# Function to press enter to continue
press_enter_to_continue() {
    echo
    read -p "Press Enter to continue..."
    print_menu
}

# Start the script
print_menu

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
    print_message "   → Version: 2.3" "$CYAN"
    print_message "   → GitHub: https://github.com/itzbinar" "$CYAN"
    print_message "   → Report issues or contribute on GitHub\n" "$CYAN"
}

# Show developer information at the end
show_developer_info

print_message "🚀 Happy Hacking! Enjoy your professional pentesting environment! 🚀\n" "$CYAN"
print_message "     Powered by ITZBINAR's Advanced Toolkit\n" "$PURPLE" 