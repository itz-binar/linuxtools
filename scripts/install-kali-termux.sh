#!/data/data/com.termux/files/usr/bin/bash

# =========================================================
# Advanced Termux + Kali + NetHunter Installer
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

# Ensure proper PATH
export PATH="/data/data/com.termux/files/usr/bin:/data/data/com.termux/files/usr/bin/applets:$PATH"
export PREFIX="/data/data/com.termux/files/usr"
export HOME="/data/data/com.termux/files/home"
export LD_LIBRARY_PATH="/data/data/com.termux/files/usr/lib"

# Strict mode
set -euo pipefail
IFS=$'\n\t'

# Colors for better readability
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
WHITE='\033[1;37m'
NC='\033[0m' # No Color

# Global variables
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LOG_FILE="${HOME}/.termux/install_log.txt"
BACKUP_DIR="${HOME}/.termux/backups"
CONFIG_DIR="${HOME}/.termux/config"
ERROR_COUNT=0
MAX_RETRIES=3

# Function to print colored messages
print_message() {
    echo -e "${2}${1}${NC}"
}

# Function to check command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Function to install package
install_package() {
    if ! command_exists "$1"; then
        print_message "Installing $1..." "$YELLOW"
        pkg install -y "$1" || {
            print_message "Failed to install $1" "$RED"
            return 1
        }
    fi
}

# Create necessary directories
mkdir -p "${BACKUP_DIR}" "${CONFIG_DIR}" "$(dirname "${LOG_FILE}")" "${HOME}/bin"

# Logging function with timestamp
log() {
    local level=$1
    shift
    local message="[$(date '+%Y-%m-%d %H:%M:%S')] [$level] $*"
    echo -e "$message" >> "${LOG_FILE}"
    case $level in
        "ERROR") print_message "$message" "$RED" ;;
        "WARNING") print_message "$message" "$YELLOW" ;;
        "SUCCESS") print_message "$message" "$GREEN" ;;
        *) print_message "$message" "$CYAN" ;;
    esac
}

# Function to check and fix common errors
fix_common_errors() {
    log "INFO" "Attempting to fix common errors..."
    
    # Kill hanging proot processes
    if pgrep proot >/dev/null; then
        pkill -9 proot
        log "INFO" "Killed hanging proot processes"
    fi
    
    # Fix storage permissions
    if [ -d "${HOME}/storage" ]; then
        termux-setup-storage || true
        log "INFO" "Reset storage permissions"
    fi
    
    # Fix package manager
    pkg clean
    pkg update -y || {
        log "WARNING" "Package manager update failed, attempting fix..."
        rm -rf /data/data/com.termux/files/usr/var/lib/apt/lists/*
        pkg update -y
    }
    
    # Check and fix basic dependencies
    for pkg in proot-distro wget curl git python; do
        if ! command_exists "$pkg"; then
            install_package "$pkg"
        fi
    done
    
    log "SUCCESS" "Common errors fixed"
}

# Function to handle errors with retry
handle_error() {
    local exit_code=$1
    local line_no=$2
    local command=$3
    
    ((ERROR_COUNT++))
    
    log "ERROR" "Error occurred in script:"
    log "ERROR" "Exit code: $exit_code"
    log "ERROR" "Line number: $line_no"
    log "ERROR" "Command: $command"
    
    if [ $ERROR_COUNT -lt $MAX_RETRIES ]; then
        log "WARNING" "Attempting recovery (Attempt $ERROR_COUNT of $MAX_RETRIES)..."
        fix_common_errors
        return 0
    else
        log "ERROR" "Maximum retry attempts reached. Please check the log file: $LOG_FILE"
        exit 1
    fi
}

# Enhanced error handling
trap 'handle_error $? ${LINENO} "${BASH_COMMAND}"' ERR

# Function to check system requirements
check_system_requirements() {
    log "INFO" "Checking system requirements..."
    
    # Check Android version
    if ! command -v getprop >/dev/null; then
        log "ERROR" "This script must be run on Android in Termux"
        exit 1
    fi
    
    local android_version=$(getprop ro.build.version.release)
    if (( ${android_version%%.*} < 7 )); then
        log "ERROR" "Android 7.0 or higher is required (found: $android_version)"
        exit 1
    }
    
    # Check available storage
    local available_storage=$(df -h "${HOME}" | awk 'NR==2 {print $4}' | sed 's/G//')
    if (( ${available_storage%%.*} < 10 )); then
        log "WARNING" "Less than 10GB storage available ($available_storage GB)"
        read -p "Continue anyway? (y/N): " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            exit 1
        fi
    fi
    
    # Check internet connectivity
    if ! ping -c 1 8.8.8.8 >/dev/null 2>&1; then
        log "ERROR" "No internet connection detected"
        exit 1
    fi
    
    log "SUCCESS" "System requirements check passed"
}

# Function to backup environment
backup_environment() {
    local backup_name="backup_$(date +%Y%m%d_%H%M%S)"
    local backup_path="${BACKUP_DIR}/${backup_name}"
    
    log "INFO" "Creating backup at: $backup_path"
    
    # Create backup directory
    mkdir -p "$backup_path"
    
    # Backup Termux home
    tar -czf "${backup_path}/termux_home.tar.gz" -C "${HOME}" .termux .bash_history .bashrc
    
    # Backup Kali rootfs if exists
    if [ -d "${PREFIX}/var/lib/proot-distro/installed-rootfs/kali" ]; then
        tar -czf "${backup_path}/kali_rootfs.tar.gz" -C "${PREFIX}/var/lib/proot-distro/installed-rootfs" kali
    fi
    
    # Backup configuration
    cp -r "${CONFIG_DIR}" "${backup_path}/config"
    
    # Create backup info
    cat > "${backup_path}/backup_info.txt" << EOL
Backup created on: $(date)
Termux version: $(pkg -v)
Android version: $(getprop ro.build.version.release)
Device: $(getprop ro.product.model)
EOL
    
    log "SUCCESS" "Backup created successfully at: $backup_path"
}

# Function to restore environment
restore_environment() {
    local backups=($(ls -1 "${BACKUP_DIR}"))
    
    if [ ${#backups[@]} -eq 0 ]; then
        log "ERROR" "No backups found in ${BACKUP_DIR}"
        return 1
    fi
    
    log "INFO" "Available backups:"
    for i in "${!backups[@]}"; do
        echo "$((i+1)). ${backups[$i]}"
    done
    
    read -p "Select backup to restore (1-${#backups[@]}): " choice
    
    if ! [[ "$choice" =~ ^[0-9]+$ ]] || [ "$choice" -lt 1 ] || [ "$choice" -gt "${#backups[@]}" ]; then
        log "ERROR" "Invalid selection"
        return 1
    fi
    
    local selected_backup="${BACKUP_DIR}/${backups[$((choice-1))]}"
    
    log "WARNING" "Restoring from backup will overwrite current environment"
    read -p "Continue? (y/N): " -n 1 -r
    echo
    
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        return 1
    fi
    
    # Stop all services
    pkill -9 proot 2>/dev/null || true
    
    # Restore Termux home
    tar -xzf "${selected_backup}/termux_home.tar.gz" -C "${HOME}"
    
    # Restore Kali rootfs if exists
    if [ -f "${selected_backup}/kali_rootfs.tar.gz" ]; then
        rm -rf "${PREFIX}/var/lib/proot-distro/installed-rootfs/kali"
        tar -xzf "${selected_backup}/kali_rootfs.tar.gz" -C "${PREFIX}/var/lib/proot-distro/installed-rootfs"
    fi
    
    # Restore configuration
    rm -rf "${CONFIG_DIR}"
    cp -r "${selected_backup}/config" "${CONFIG_DIR}"
    
    log "SUCCESS" "Environment restored from: ${selected_backup}"
}

# Function to check and fix permissions
fix_permissions() {
    log "INFO" "Fixing permissions..."
    
    # Fix Termux home permissions
    chmod 700 -R "${HOME}/.termux"
    chmod 755 "${HOME}"
    
    # Fix storage permissions
    if [ -d "${HOME}/storage" ]; then
        chmod 700 -R "${HOME}/storage"
    fi
    
    # Fix executable permissions
    find "${HOME}/bin" -type f -exec chmod 755 {} \; 2>/dev/null || true
    
    log "SUCCESS" "Permissions fixed"
}

# Function to validate installation
validate_installation() {
    local component=$1
    log "INFO" "Validating $component installation..."
    
    case $component in
        "kali")
            if ! proot-distro list | grep -q "kali: installed"; then
                log "ERROR" "Kali Linux installation validation failed"
                return 1
            fi
            ;;
        "nethunter")
            if ! command -v nethunter >/dev/null; then
                log "ERROR" "NetHunter installation validation failed"
                return 1
            fi
            ;;
        "arch")
            if ! proot-distro list | grep -q "archlinux: installed"; then
                log "ERROR" "Arch Linux installation validation failed"
                return 1
            fi
            ;;
    esac
    
    log "SUCCESS" "$component installation validated"
    return 0
}

# Function to perform system health check
check_system_health() {
    log "INFO" "Performing system health check..."
    
    # Check disk space
    local disk_usage=$(df -h "${HOME}" | awk 'NR==2 {print $5}' | sed 's/%//')
    if [ "$disk_usage" -gt 90 ]; then
        log "WARNING" "Disk usage is high: ${disk_usage}%"
    fi
    
    # Check running processes
    local proot_count=$(pgrep -c proot || echo "0")
    if [ "$proot_count" -gt 5 ]; then
        log "WARNING" "High number of proot processes: $proot_count"
    fi
    
    # Check package manager
    if ! pkg list-installed >/dev/null 2>&1; then
        log "ERROR" "Package manager is not functioning properly"
        return 1
    fi
    
    # Check network connectivity
    if ! ping -c 1 8.8.8.8 >/dev/null 2>&1; then
        log "WARNING" "Network connectivity issues detected"
    fi
    
    log "SUCCESS" "System health check completed"
}

# Function to clean up system
clean_system() {
    log "INFO" "Cleaning system..."
    
    # Clean package cache
    pkg clean
    
    # Remove old backups (keep last 5)
    cd "${BACKUP_DIR}" && ls -t | tail -n +6 | xargs rm -rf 2>/dev/null || true
    
    # Clean logs (keep last 1000 lines)
    tail -n 1000 "${LOG_FILE}" > "${LOG_FILE}.tmp" && mv "${LOG_FILE}.tmp" "${LOG_FILE}"
    
    # Remove temporary files
    rm -rf "${HOME}/.termux/tmp"/* 2>/dev/null || true
    
    log "SUCCESS" "System cleaned"
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
    print_message "   → Version: 2.4" "$CYAN"
    print_message "   → GitHub: https://github.com/itzbinar" "$CYAN"
    print_message "   → Report issues or contribute on GitHub\n" "$CYAN"
}

# Show developer information at the end
show_developer_info

print_message "🚀 Happy Hacking! Enjoy your professional pentesting environment! 🚀\n" "$CYAN"
print_message "     Powered by ITZBINAR's Advanced Toolkit\n" "$PURPLE"

# Function to install Kali Linux
install_kali_linux() {
    log "INFO" "Installing Kali Linux..."
    
    # Install proot-distro if not present
    install_package proot-distro
    
    # Install Kali
    proot-distro install kali || {
        log "ERROR" "Failed to install Kali Linux"
        return 1
    }
    
    # Create Kali setup script
    cat > "${HOME}/.kali-setup.sh" << 'EOL'
#!/bin/bash
# Update system
apt update && apt upgrade -y

# Install essential tools
DEBIAN_FRONTEND=noninteractive apt install -y kali-linux-default
apt install -y python3-pip git vim nano tmux
apt install -y nmap dirb nikto
apt install -y metasploit-framework

# Setup Python environment
pip3 install --upgrade pip
pip3 install requests beautifulsoup4 scapy
EOL
    chmod +x "${HOME}/.kali-setup.sh"
    
    # Run setup script
    proot-distro login kali -- bash /root/.kali-setup.sh
    
    log "SUCCESS" "Kali Linux installed successfully"
}

# Function to install NetHunter
install_nethunter() {
    log "INFO" "Installing Kali NetHunter..."
    
    # Install dependencies
    for pkg in wget curl proot tar; do
        install_package "$pkg"
    done
    
    # Download and install NetHunter
    cd "${HOME}"
    wget -O install-nethunter-termux https://offs.ec/2MceZWr || {
        log "ERROR" "Failed to download NetHunter installer"
        return 1
    }
    chmod +x install-nethunter-termux
    ./install-nethunter-termux || {
        log "ERROR" "Failed to install NetHunter"
        return 1
    }
    
    log "SUCCESS" "NetHunter installed successfully"
}

# Function to install Arch Linux
install_arch_linux() {
    log "INFO" "Installing Arch Linux..."
    
    # Install proot-distro if not present
    install_package proot-distro
    
    # Install Arch
    proot-distro install archlinux || {
        log "ERROR" "Failed to install Arch Linux"
        return 1
    }
    
    # Create Arch setup script
    cat > "${HOME}/.arch-setup.sh" << 'EOL'
#!/bin/bash
# Update system
pacman -Syu --noconfirm

# Install base development tools
pacman -S --noconfirm base-devel git vim python python-pip
pacman -S --noconfirm nodejs npm go rust
EOL
    chmod +x "${HOME}/.arch-setup.sh"
    
    # Run setup script
    proot-distro login archlinux -- bash /root/.arch-setup.sh
    
    log "SUCCESS" "Arch Linux installed successfully"
}

# Function to setup GUI environment
setup_gui_environment() {
    log "INFO" "Setting up GUI environment..."
    
    # Install X11 packages
    pkg install -y x11-repo
    pkg install -y tigervnc
    
    # Create VNC setup script
    cat > "${HOME}/bin/setup-vnc" << 'EOL'
#!/data/data/com.termux/files/usr/bin/bash

# Kill existing VNC server
vncserver -kill :1 2>/dev/null || true

# Start VNC server
vncserver -localhost no :1
echo "VNC Server started on port 5901"
echo "Use a VNC viewer to connect"
EOL
    chmod +x "${HOME}/bin/setup-vnc"
    
    log "SUCCESS" "GUI environment setup complete"
}

# Function to configure aliases
configure_aliases() {
    log "INFO" "Configuring aliases..."
    
    # Add aliases to .bashrc
    cat >> "${HOME}/.bashrc" << 'EOL'

# Environment aliases
alias kali='proot-distro login kali'
alias kali-root='proot-distro login kali --user root'
alias arch='proot-distro login archlinux'
alias arch-root='proot-distro login archlinux --user root'
alias nh='nethunter'
alias nh-root='nethunter -r'

# Utility aliases
alias update='pkg update && pkg upgrade'
alias fix-proot='pkill -9 proot'
alias fix-storage='termux-setup-storage'

# GUI aliases
alias start-vnc='~/bin/setup-vnc'
alias stop-vnc='vncserver -kill :1'
EOL
    
    # Reload .bashrc
    source "${HOME}/.bashrc"
    
    log "SUCCESS" "Aliases configured"
}

# Function to setup additional scripts
setup_scripts() {
    log "INFO" "Setting up utility scripts..."
    
    # Create fix-environment script
    cat > "${HOME}/bin/fix-environment" << 'EOL'
#!/data/data/com.termux/files/usr/bin/bash

# Kill hanging processes
pkill -9 proot
killall -9 pulseaudio 2>/dev/null

# Fix permissions
termux-setup-storage

# Update packages
pkg update -y

echo "Environment fixed"
EOL
    chmod +x "${HOME}/bin/fix-environment"
    
    log "SUCCESS" "Utility scripts setup complete"
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

# Function to perform full installation
perform_full_installation() {
    print_message "\n🚀 Starting Full Installation..." "$WHITE"
    
    # Check system requirements
    check_system_requirements || {
        log "ERROR" "System requirements not met"
        press_enter_to_continue
        return 1
    }
    
    # Update system
    log "INFO" "Updating system packages..."
    pkg update -y && pkg upgrade -y
    
    # Install components
    install_basic_tools || return 1
    install_kali_linux || return 1
    install_nethunter || return 1
    install_arch_linux || return 1
    setup_gui_environment || return 1
    configure_aliases || return 1
    setup_scripts || return 1
    
    print_message "\n✨ Full Installation Complete!" "$GREEN"
    press_enter_to_continue
}

# Function to install basic tools
install_basic_tools() {
    log "INFO" "Installing basic tools..."
    
    local basic_packages=(
        "proot-distro" "curl" "wget" "git" "python" "python-pip"
        "vim" "nano" "openssh" "tmux" "htop" "nmap"
        "termux-api" "termux-tools"
    )
    
    for package in "${basic_packages[@]}"; do
        install_package "$package" || return 1
    done
    
    log "SUCCESS" "Basic tools installed"
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
        1) install_kali_linux && press_enter_to_continue ;;
        2) install_nethunter && press_enter_to_continue ;;
        3) install_arch_linux && press_enter_to_continue ;;
        4) install_basic_tools && press_enter_to_continue ;;
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
        1) fix_common_errors && press_enter_to_continue ;;
        2) reset_environment && press_enter_to_continue ;;
        3) fix_permissions && press_enter_to_continue ;;
        4) fix_nethunter_gui && press_enter_to_continue ;;
        5) check_system_health && press_enter_to_continue ;;
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
        1) backup_environment && press_enter_to_continue ;;
        2) restore_environment && press_enter_to_continue ;;
        3) export_settings && press_enter_to_continue ;;
        4) import_settings && press_enter_to_continue ;;
        5) print_menu ;;
        *) print_message "Invalid option. Please try again." "$RED" && sleep 2 && show_backup_menu ;;
    esac
}

# Function to perform update
perform_update() {
    print_message "\n🔄 Updating System..." "$WHITE"
    
    # Update package lists
    pkg update -y || {
        log "ERROR" "Failed to update package lists"
        press_enter_to_continue
        return 1
    }
    
    # Upgrade packages
    pkg upgrade -y || {
        log "ERROR" "Failed to upgrade packages"
        press_enter_to_continue
        return 1
    }
    
    # Update Kali if installed
    if proot-distro list | grep -q "kali: installed"; then
        log "INFO" "Updating Kali Linux..."
        proot-distro login kali -- apt update
        proot-distro login kali -- apt upgrade -y
    fi
    
    # Update Arch if installed
    if proot-distro list | grep -q "archlinux: installed"; then
        log "INFO" "Updating Arch Linux..."
        proot-distro login archlinux -- pacman -Syu --noconfirm
    fi
    
    # Update NetHunter if installed
    if [ -f "${HOME}/nethunter" ]; then
        log "INFO" "Updating NetHunter..."
        nethunter update
    fi
    
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
        if proot-distro list | grep -q "kali: installed"; then
            proot-distro remove kali
        fi
        
        # Remove Arch
        if proot-distro list | grep -q "archlinux: installed"; then
            proot-distro remove archlinux
        fi
        
        # Remove NetHunter
        if [ -d "${HOME}/nethunter" ]; then
            rm -rf "${HOME}/nethunter"
        fi
        
        # Remove scripts and configs
        rm -f "${HOME}/.kali-setup.sh" "${HOME}/.arch-setup.sh" "${HOME}/install-nethunter-termux"
        rm -rf "${HOME}/bin/fix-environment" "${HOME}/bin/setup-vnc"
        
        print_message "\n✨ Uninstallation Complete!" "$GREEN"
    fi
    press_enter_to_continue
}

# Function to show about
show_about() {
    clear
    print_message "\n📱 About:" "$WHITE"
    print_message "Developer: ITZBINAR" "$CYAN"
    print_message "Version: 2.4" "$CYAN"
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

# Function to export settings
export_settings() {
    local export_file="${HOME}/.termux/settings_export.tar.gz"
    log "INFO" "Exporting settings to: $export_file"
    
    tar -czf "$export_file" \
        -C "${HOME}" \
        .termux .bashrc .bash_history \
        bin/.kali-setup.sh bin/.arch-setup.sh bin/fix-environment bin/setup-vnc \
        2>/dev/null || true
        
    log "SUCCESS" "Settings exported to: $export_file"
}

# Function to import settings
import_settings() {
    local import_file="${HOME}/.termux/settings_export.tar.gz"
    
    if [ ! -f "$import_file" ]; then
        log "ERROR" "No settings export found at: $import_file"
        return 1
    fi
    
    log "INFO" "Importing settings from: $import_file"
    
    tar -xzf "$import_file" -C "${HOME}" || {
        log "ERROR" "Failed to import settings"
        return 1
    }
    
    log "SUCCESS" "Settings imported successfully"
}

# Function to fix NetHunter GUI
fix_nethunter_gui() {
    log "INFO" "Fixing NetHunter GUI..."
    
    # Kill existing VNC processes
    vncserver -kill :1 2>/dev/null || true
    
    # Reinstall VNC
    pkg reinstall -y tigervnc
    
    # Reset NetHunter GUI
    if [ -f "${HOME}/nethunter" ]; then
        nethunter kex kill
        nethunter kex &
        log "SUCCESS" "NetHunter GUI reset"
    else
        log "ERROR" "NetHunter not installed"
        return 1
    fi
}

# Function to reset environment
reset_environment() {
    log "INFO" "Resetting environment..."
    
    # Kill all proot processes
    pkill -9 proot
    
    # Reset package manager
    rm -rf /data/data/com.termux/files/usr/var/lib/apt/lists/*
    pkg update -y
    
    # Reset storage permissions
    termux-setup-storage
    
    # Recreate necessary directories
    mkdir -p "${HOME}/bin" "${HOME}/.termux"
    
    log "SUCCESS" "Environment reset complete"
}

# Start the script
if [ "${BASH_SOURCE[0]}" = "$0" ]; then
    # Ensure we're in Termux
    if [ ! -d "/data/data/com.termux" ]; then
        print_message "Error: This script must be run in Termux!" "$RED"
        exit 1
    fi
    
    # Create necessary directories
    mkdir -p "${HOME}/bin" "${HOME}/.termux" "${BACKUP_DIR}" "${CONFIG_DIR}"
    
    # Start the menu
    print_menu
fi 