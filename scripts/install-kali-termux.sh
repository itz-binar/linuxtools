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