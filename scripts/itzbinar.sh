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

# Ensure proper PATH and environment
export PATH="/data/data/com.termux/files/usr/bin:/data/data/com.termux/files/usr/bin/applets:$PATH"
export PREFIX="/data/data/com.termux/files/usr"
export HOME="/data/data/com.termux/files/home"
export LD_LIBRARY_PATH="/data/data/com.termux/files/usr/lib"
export TERMUX_VERSION="$(pkg -v)"

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
TOOLS_DIR="${HOME}/.termux/tools"
ERROR_COUNT=0
MAX_RETRIES=3
SCRIPT_VERSION="2.4"

# Dependency versions
declare -A DEPS_VERSIONS=(
    ["proot"]="3.0.0"
    ["wget"]="1.21.3"
    ["git"]="2.39.0"
    ["python"]="3.11.0"
    ["vim"]="9.0"
)

# Function to verify dependency versions
verify_dependency_version() {
    local dep=$1
    local required_version=${DEPS_VERSIONS[$dep]}
    local current_version
    
    case $dep in
        "proot")
            current_version=$(proot --version 2>&1 | grep -oP '(?<=proot version )[0-9.]+' || echo "0")
            ;;
        "python")
            current_version=$(python --version 2>&1 | grep -oP '(?<=Python )[0-9.]+' || echo "0")
            ;;
        *)
            current_version=$($dep --version 2>&1 | grep -oP '[0-9]+\.[0-9]+\.[0-9]+' || echo "0")
            ;;
    esac
    
    if ! command_exists "$dep"; then
        log "WARNING" "$dep is not installed"
        return 1
    fi
    
    if ! version_greater_equal "$current_version" "$required_version"; then
        log "WARNING" "$dep version $current_version is lower than required $required_version"
        return 1
    fi
    
    return 0
}

# Version comparison function
version_greater_equal() {
    printf '%s\n%s\n' "$2" "$1" | sort -V -C
}

# Create necessary directories
mkdir -p "${BACKUP_DIR}" "${CONFIG_DIR}" "${TOOLS_DIR}" "$(dirname "${LOG_FILE}")" "${HOME}/bin"

# Function to print banner
print_banner() {
    clear
    print_message "
+=================================================================+
|                                                                   |
|                                                                   |
|    ██╗████████╗███████╗██████╗ ██╗███╗   ██╗ █████╗ ██████╗     |
|    ██║╚══██╔══╝╚══███╔╝██╔══██╗██║████╗  ██║██╔══██╗██╔══██╗    |
|    ██║   ██║     ███╔╝ ██████╔╝██║██╔██╗ ██║███████║██████╔╝    |
|    ██║   ██║    ███╔╝  ██╔══██╗██║██║╚██╗██║██╔══██║██╔══██╗    |
|    ██║   ██║   ███████╗██████╔╝██║██║ ╚████║██║  ██║██║  ██║    |
|    ╚═╝   ╚═╝   ╚══════╝╚═════╝ ╚═╝╚═╝  ╚═══╝╚═╝  ╚═╝╚═╝  ╚═╝    |
|                                                                   |
|                Advanced Penetration Testing Suite                 |
|                                                                   |
+=================================================================+
    " "$PURPLE"
    print_message "           Created by: ITZBINAR - 2024" "$CYAN"
    print_message "     Professional Penetration Testing Suite v${SCRIPT_VERSION}" "$CYAN"
    echo
}

# Function to print colored messages
print_message() {
    echo -e "${2}${1}${NC}"
}

# Logging function with timestamp and rotation
log() {
    local level=$1
    shift
    local message="[$(date '+%Y-%m-%d %H:%M:%S')] [$level] $*"
    
    # Rotate log if it exceeds 1MB
    if [ -f "$LOG_FILE" ] && [ $(stat -f%z "$LOG_FILE" 2>/dev/null || stat -c%s "$LOG_FILE") -gt 1048576 ]; then
        mv "$LOG_FILE" "${LOG_FILE}.old"
    fi
    
    echo -e "$message" >> "${LOG_FILE}"
    case $level in
        "ERROR") print_message "$message" "$RED" ;;
        "WARNING") print_message "$message" "$YELLOW" ;;
        "SUCCESS") print_message "$message" "$GREEN" ;;
        *) print_message "$message" "$CYAN" ;;
    esac
}

# Function to check command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Function to install package with retry
install_package() {
    local package=$1
    local retries=0
    local max_retries=3
    
    if ! command_exists "$package"; then
        while [ $retries -lt $max_retries ]; do
            log "INFO" "Installing $package (attempt $((retries+1))/$max_retries)..."
            if pkg install -y "$package"; then
                log "SUCCESS" "$package installed successfully"
                return 0
            fi
            retries=$((retries+1))
            if [ $retries -lt $max_retries ]; then
                log "WARNING" "Failed to install $package, retrying..."
                pkg clean
                pkg update -y
            fi
        done
        log "ERROR" "Failed to install $package after $max_retries attempts"
        return 1
    fi
}

# Function to check system health
check_system_health() {
    log "INFO" "Performing system health check..."
    
    # Check disk space
    local disk_usage=$(df -h "${HOME}" | awk 'NR==2 {print $5}' | sed 's/%//')
    if [ "$disk_usage" -gt 90 ]; then
        log "WARNING" "Critical: Disk usage is at ${disk_usage}%"
    fi
    
    # Check memory
    local mem_free=$(free -m | awk 'NR==2 {print $4}')
    if [ "$mem_free" -lt 100 ]; then
        log "WARNING" "Low memory: ${mem_free}MB free"
    fi
    
    # Check running processes
    local proot_count=$(pgrep -c proot || echo "0")
    if [ "$proot_count" -gt 5 ]; then
        log "WARNING" "High number of proot processes: $proot_count"
    fi
    
    # Check network connectivity
    if ! ping -c 1 8.8.8.8 >/dev/null 2>&1; then
        log "WARNING" "Network connectivity issues detected"
    fi
    
    # Check package manager
    if ! pkg list-installed >/dev/null 2>&1; then
        log "ERROR" "Package manager is not functioning properly"
        return 1
    fi
    
    # Check storage permission
    if [ ! -d "${HOME}/storage" ]; then
        log "WARNING" "Storage permission not granted"
    fi
    
    log "SUCCESS" "System health check completed"
}

# Enhanced backup system
create_backup() {
    local backup_name="backup_$(date +%Y%m%d_%H%M%S)"
    local backup_path="${BACKUP_DIR}/${backup_name}"
    local manifest_file="${backup_path}/manifest.json"
    
    log "INFO" "Creating backup: $backup_name"
    
    # Create backup directory
    mkdir -p "$backup_path"
    
    # Create backup manifest
    cat > "$manifest_file" << EOF
{
    "backup_name": "$backup_name",
    "created_at": "$(date -u +"%Y-%m-%dT%H:%M:%SZ")",
    "script_version": "$SCRIPT_VERSION",
    "android_version": "$(getprop ro.build.version.release)",
    "termux_version": "$TERMUX_VERSION",
    "contents": []
}
EOF
    
    # Backup configuration files
    if [ -d "${HOME}/.termux" ]; then
        tar czf "${backup_path}/termux_config.tar.gz" -C "${HOME}" .termux/
        jq --arg path "termux_config.tar.gz" '.contents += ["termux_config"]' "$manifest_file" > "${manifest_file}.tmp"
        mv "${manifest_file}.tmp" "$manifest_file"
    fi
    
    # Backup installed packages list
    pkg list-installed > "${backup_path}/packages.list"
    jq --arg path "packages.list" '.contents += ["packages_list"]' "$manifest_file" > "${manifest_file}.tmp"
    mv "${manifest_file}.tmp" "$manifest_file"
    
    # Backup custom scripts
    if [ -d "${TOOLS_DIR}" ]; then
        tar czf "${backup_path}/custom_tools.tar.gz" -C "${HOME}/.termux" tools/
        jq --arg path "custom_tools.tar.gz" '.contents += ["custom_tools"]' "$manifest_file" > "${manifest_file}.tmp"
        mv "${manifest_file}.tmp" "$manifest_file"
    fi
    
    # Create checksum file
    find "$backup_path" -type f ! -name "checksums.sha256" -exec sha256sum {} \; > "${backup_path}/checksums.sha256"
    
    log "SUCCESS" "Backup created successfully at: $backup_path"
    return 0
}

# Enhanced restore system
restore_backup() {
    local backup_name=$1
    local backup_path="${BACKUP_DIR}/${backup_name}"
    local manifest_file="${backup_path}/manifest.json"
    
    if [ ! -f "$manifest_file" ]; then
        log "ERROR" "Invalid backup: manifest file not found"
        return 1
    fi
    
    log "INFO" "Verifying backup integrity..."
    
    # Verify checksums
    cd "$backup_path"
    if ! sha256sum -c checksums.sha256; then
        log "ERROR" "Backup integrity check failed"
        return 1
    fi
    
    # Read manifest
    local script_version=$(jq -r '.script_version' "$manifest_file")
    if ! version_greater_equal "$SCRIPT_VERSION" "$script_version"; then
        log "WARNING" "Backup was created with a newer script version ($script_version)"
        read -p "Continue anyway? [y/N] " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            return 1
        fi
    fi
    
    # Restore configuration files
    if [ -f "${backup_path}/termux_config.tar.gz" ]; then
        log "INFO" "Restoring Termux configuration..."
        tar xzf "${backup_path}/termux_config.tar.gz" -C "${HOME}"
    fi
    
    # Restore packages
    if [ -f "${backup_path}/packages.list" ]; then
        log "INFO" "Restoring packages..."
        while read -r pkg; do
            pkg install -y "$pkg" || log "WARNING" "Failed to install package: $pkg"
        done < "${backup_path}/packages.list"
    fi
    
    # Restore custom tools
    if [ -f "${backup_path}/custom_tools.tar.gz" ]; then
        log "INFO" "Restoring custom tools..."
        tar xzf "${backup_path}/custom_tools.tar.gz" -C "${HOME}/.termux"
    fi
    
    log "SUCCESS" "Backup restored successfully"
    return 0
}

# Function to list available backups
list_backups() {
    log "INFO" "Available backups:"
    for backup in "${BACKUP_DIR}"/*/; do
        if [ -f "${backup}/manifest.json" ]; then
            local name=$(basename "$backup")
            local created_at=$(jq -r '.created_at' "${backup}/manifest.json")
            local version=$(jq -r '.script_version' "${backup}/manifest.json")
            printf "%-30s %-25s %s\n" "$name" "$created_at" "v$version"
        fi
    done
}

# Enhanced system monitoring
monitor_system_resources() {
    local monitor_interval=${1:-5}  # Default to 5 second intervals
    local monitor_count=${2:-12}    # Default to 1 minute (12 x 5 seconds)
    local output_file="${HOME}/.termux/system_monitor.log"
    local count=0
    
    log "INFO" "Starting system monitoring (${monitor_interval}s intervals, ${monitor_count} samples)"
    
    # Header for the monitoring log
    printf "%-19s %10s %10s %10s %10s %10s\n" "TIMESTAMP" "CPU%" "MEM%" "DISK%" "PROCS" "TEMP" > "$output_file"
    
    while [ $count -lt $monitor_count ]; do
        # Get CPU usage (approximation in Termux)
        local cpu_usage=$(top -bn1 | grep "Cpu(s)" | awk '{print $2}')
        
        # Get memory usage
        local mem_total=$(free -m | awk 'NR==2 {print $2}')
        local mem_used=$(free -m | awk 'NR==2 {print $3}')
        local mem_percent=$((mem_used * 100 / mem_total))
        
        # Get disk usage
        local disk_usage=$(df -h "${HOME}" | awk 'NR==2 {print $5}' | sed 's/%//')
        
        # Get process count
        local proc_count=$(ps aux | wc -l)
        
        # Get device temperature (if available)
        local temp=$(cat /sys/class/thermal/thermal_zone0/temp 2>/dev/null || echo "N/A")
        if [ "$temp" != "N/A" ]; then
            temp=$(echo "scale=1; $temp/1000" | bc)
        fi
        
        # Log the data
        printf "%-19s %10.1f %10d %10d %10d %10s\n" \
            "$(date '+%Y-%m-%d %H:%M:%S')" \
            "${cpu_usage}" \
            "${mem_percent}" \
            "${disk_usage}" \
            "${proc_count}" \
            "${temp}" >> "$output_file"
        
        count=$((count + 1))
        sleep "$monitor_interval"
    done
    
    log "SUCCESS" "System monitoring completed. Results saved to: $output_file"
    
    # Analyze the results
    analyze_system_performance "$output_file"
}

# Function to analyze system performance
analyze_system_performance() {
    local monitor_file=$1
    local high_cpu=0
    local high_mem=0
    local high_disk=0
    
    log "INFO" "Analyzing system performance..."
    
    # Calculate averages and peaks
    local cpu_avg=$(awk 'NR>1 {sum+=$2} END {print sum/(NR-1)}' "$monitor_file")
    local mem_avg=$(awk 'NR>1 {sum+=$3} END {print sum/(NR-1)}' "$monitor_file")
    local disk_avg=$(awk 'NR>1 {sum+=$4} END {print sum/(NR-1)}' "$monitor_file")
    
    local cpu_peak=$(awk 'NR>1 {if($2>max)max=$2} END {print max}' "$monitor_file")
    local mem_peak=$(awk 'NR>1 {if($3>max)max=$3} END {print max}' "$monitor_file")
    local disk_peak=$(awk 'NR>1 {if($4>max)max=$4} END {print max}' "$monitor_file")
    
    # Performance analysis
    if (( $(echo "$cpu_avg > 80" | bc -l) )); then
        high_cpu=1
        log "WARNING" "High average CPU usage detected: ${cpu_avg}%"
    fi
    
    if (( $(echo "$mem_avg > 80" | bc -l) )); then
        high_mem=1
        log "WARNING" "High average memory usage detected: ${mem_avg}%"
    fi
    
    if (( $(echo "$disk_avg > 80" | bc -l) )); then
        high_disk=1
        log "WARNING" "High average disk usage detected: ${disk_avg}%"
    fi
    
    # Generate performance report
    cat << EOF > "${HOME}/.termux/performance_report.txt"
=== System Performance Report ===
Generated: $(date '+%Y-%m-%d %H:%M:%S')

Resource Utilization:
CPU:  Average: ${cpu_avg}%  Peak: ${cpu_peak}%
MEM:  Average: ${mem_avg}%  Peak: ${mem_peak}%
DISK: Average: ${disk_avg}% Peak: ${disk_peak}%

Recommendations:
EOF
    
    # Add recommendations based on analysis
    if [ $high_cpu -eq 1 ]; then
        echo "- Consider limiting concurrent processes" >> "${HOME}/.termux/performance_report.txt"
        echo "- Check for resource-intensive background tasks" >> "${HOME}/.termux/performance_report.txt"
    fi
    
    if [ $high_mem -eq 1 ]; then
        echo "- Clean package cache: pkg clean" >> "${HOME}/.termux/performance_report.txt"
        echo "- Remove unused packages" >> "${HOME}/.termux/performance_report.txt"
    fi
    
    if [ $high_disk -eq 1 ]; then
        echo "- Clear logs and temporary files" >> "${HOME}/.termux/performance_report.txt"
        echo "- Consider backing up and removing large files" >> "${HOME}/.termux/performance_report.txt"
    fi
    
    log "SUCCESS" "Performance analysis completed. Report saved to: ${HOME}/.termux/performance_report.txt"
}

# Function to optimize system performance
optimize_system() {
    log "INFO" "Starting system optimization..."
    
    # Clean package cache
    log "INFO" "Cleaning package cache..."
    pkg clean
    
    # Remove old logs
    log "INFO" "Cleaning old log files..."
    find "${HOME}/.termux" -name "*.log" -type f -mtime +7 -delete
    
    # Kill zombie processes
    log "INFO" "Checking for zombie processes..."
    zombies=$(ps aux | awk '$8=="Z" {print $2}')
    if [ ! -z "$zombies" ]; then
        echo "$zombies" | xargs kill -9
        log "INFO" "Terminated zombie processes"
    fi
    
    # Optimize Termux settings
    log "INFO" "Optimizing Termux settings..."
    mkdir -p "${HOME}/.termux"
    cat > "${HOME}/.termux/termux.properties" << EOF
terminal-margin-horizontal=2
terminal-margin-vertical=1
extra-keys=[['ESC','/','-','HOME','UP','END','PGUP'],['TAB','CTRL','ALT','LEFT','DOWN','RIGHT','PGDN']]
bell-character=ignore
terminal-transcript-rows=2000
EOF
    
    # Update all packages
    log "INFO" "Updating packages..."
    pkg update -y && pkg upgrade -y
    
    log "SUCCESS" "System optimization completed"
    
    # Run a final system health check
    check_system_health
}

# Function to handle errors with smart recovery
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
        log "WARNING" "Attempting smart recovery (Attempt $ERROR_COUNT of $MAX_RETRIES)..."
        
        case $exit_code in
            1) # General errors
                fix_common_errors
                ;;
            100) # Network errors
                log "INFO" "Detected network error, attempting to fix..."
                fix_network
                ;;
            126|127) # Command not found
                log "INFO" "Detected missing command, attempting to fix..."
                pkg update -y && pkg upgrade -y
                ;;
            137|139|141) # Memory/segmentation errors
                log "INFO" "Detected memory error, attempting to fix..."
                clean_system
                ;;
            *)
                fix_common_errors
                ;;
        esac
        
        return 0
    else
        log "ERROR" "Maximum retry attempts reached. Please check the log file: $LOG_FILE"
        exit 1
    fi
}

# Enhanced error handling
trap 'handle_error $? ${LINENO} "${BASH_COMMAND}"' ERR

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