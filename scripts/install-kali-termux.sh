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

# Create necessary directories
mkdir -p "${BACKUP_DIR}" "${CONFIG_DIR}" "$(dirname "${LOG_FILE}")"

# Logging function
log() {
    local level=$1
    shift
    local message="[$(date '+%Y-%m-%d %H:%M:%S')] [$level] $*"
    echo -e "$message" >> "${LOG_FILE}"
    if [[ $level == "ERROR" ]]; then
        print_message "$message" "$RED"
    elif [[ $level == "WARNING" ]]; then
        print_message "$message" "$YELLOW"
    elif [[ $level == "SUCCESS" ]]; then
        print_message "$message" "$GREEN"
    else
        print_message "$message" "$CYAN"
    fi
}

# Function to handle errors
handle_error() {
    local exit_code=$1
    local line_no=$2
    local bash_lineno=$3
    local last_command=$4
    local func_trace=$5

    ((ERROR_COUNT++))

    log "ERROR" "Error occurred in script:"
    log "ERROR" "Exit code: $exit_code"
    log "ERROR" "Line number: $line_no"
    log "ERROR" "Command: $last_command"
    log "ERROR" "Function trace: $func_trace"
    
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
trap 'handle_error $? $LINENO $BASH_LINENO "$BASH_COMMAND" $(printf "::%s" ${FUNCNAME[@]:-})' ERR

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
    print_message "   → Version: 2.4" "$CYAN"
    print_message "   → GitHub: https://github.com/itzbinar" "$CYAN"
    print_message "   → Report issues or contribute on GitHub\n" "$CYAN"
}

# Show developer information at the end
show_developer_info

print_message "🚀 Happy Hacking! Enjoy your professional pentesting environment! 🚀\n" "$CYAN"
print_message "     Powered by ITZBINAR's Advanced Toolkit\n" "$PURPLE" 
