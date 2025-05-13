# 🛡️ ITZBINAR's Advanced Pentesting Toolkit

<div align="center">
  
```ascii
+=================================================================+
|                                                                 |
|                                                                 |
|    ██╗████████╗███████╗██████╗ ██╗███╗   ██╗ █████╗ ██████╗     |
|    ██║╚══██╔══╝╚══███╔╝██╔══██╗██║████╗  ██║██╔══██╗██╔══██╗    |
|    ██║   ██║     ███╔╝ ██████╔╝██║██╔██╗ ██║███████║██████╔╝    |
|    ██║   ██║    ███╔╝  ██╔══██╗██║██║╚██╗██║██╔══██║██╔══██╗    |
|    ██║   ██║   ███████╗██████╔╝██║██║ ╚████║██║  ██║██║  ██║    |
|    ╚═╝   ╚═╝   ╚══════╝╚═════╝ ╚═╝╚═╝  ╚═══╝╚═╝  ╚═╝╚═╝  ╚═╝    |
|                                                                 |
|                Advanced Penetration Testing Suite                 |
|                                                                 |
+=================================================================+
```

  <h2>🔐 Professional Penetration Testing Environment</h2>
  
  [![Developer](https://img.shields.io/badge/Developer-ITZBINAR-purple.svg?style=for-the-badge)](https://github.com/itz-binar)
  [![Version](https://img.shields.io/badge/Version-2.4-blue.svg?style=for-the-badge)]()
  [![License](https://img.shields.io/badge/License-MIT-green.svg?style=for-the-badge)]()
  [![Root Status](https://img.shields.io/badge/Non--Root-Supported-orange.svg?style=for-the-badge)]()
  [![GUI](https://img.shields.io/badge/GUI-Supported-brightgreen.svg?style=for-the-badge)]()
  [![Menu](https://img.shields.io/badge/Menu-Interactive-yellow.svg?style=for-the-badge)]()
</div>

## 🔧 Prerequisites
- Android device (7.0+)
- [Termux App](https://f-droid.org/en/packages/com.termux/) installed
- At least 10GB free storage
- Active internet connection

## ⚡ Quick Installation
```bash
# One-line installation command
curl -sSL https://raw.githubusercontent.com/itz-binar/linuxtools/main/scripts/itzbinar.sh -o itzbinar.sh && chmod +x itzbinar.sh && ./itzbinar.sh

# Or manual installation
git clone https://github.com/itz-binar/linuxtools.git
cd linuxtools/scripts
chmod +x itzbinar.sh
./itzbinar.sh
```

## 🚀 Running the Environment
```bash
# Start environments
kali                    # Start Kali Linux environment
kali-root              # Start Kali Linux with root access
nh                     # Start NetHunter environment
nh-root                # Start NetHunter with root access
arch                   # Start Arch Linux environment
arch-root              # Start Arch Linux with root access

# Start GUI interfaces
nh-kex                 # Start NetHunter GUI
nh-kex-stop           # Stop NetHunter GUI
start-vnc              # Start VNC server
stop-vnc               # Stop VNC server

# Quick utilities
update                 # Update all packages
fix-proot             # Fix hanging proot sessions
fix-permission        # Fix storage permissions
```

## �� Table of Contents
- [Features](#-features)
- [Prerequisites](#-prerequisites)
- [Installation](#-installation)
- [Command Reference](#-command-reference)
- [Troubleshooting](#-troubleshooting)
- [Support](#-support)

## 🚀 Features

### 🛡️ Core Features
```
├── Enhanced Error Handling & Recovery
│   ├── Strict error handling with retry mechanism
│   ├── Automatic error detection and recovery
│   ├── Comprehensive logging system
│   ├── System health monitoring
│   └── Cleanup utilities
│
├── Interactive Menu System
│   ├── Full Installation Option
│   ├── Custom Installation Choices
│   ├── Update & Maintenance Tools
│   ├── Backup & Restore Features
│   └── Troubleshooting Utilities
│
├── System Management
│   ├── Dependency Version Control
│   ├── Performance Monitoring
│   ├── Resource Optimization
│   ├── Health Diagnostics
│   └── Auto-recovery System
│
└── Multiple Linux Environments
    ├── Kali Linux (Pentesting)
    ├── NetHunter (Mobile Hacking)
    ├── Arch Linux (Development)
    └── Termux (Terminal Enhancement)
```

### 🔧 Technical Features
- **Advanced Error Recovery**
  - Automatic process recovery
  - Smart error detection
  - Self-healing capabilities
  - Comprehensive logging
  - System health checks

- **Security Features**
  - Root & Non-root compatibility
  - Secure environment setup
  - Permission management
  - Storage access control
  - Process isolation

- **Performance Management**
  - Real-time system monitoring
  - Resource usage analytics
  - Performance optimization
  - Automatic cleanup
  - Process management

- **Backup System**
  - Incremental backups
  - Version tracking
  - Integrity verification
  - Selective restoration
  - Configuration preservation

## 💻 Command Reference

### 🌐 Environment Management
```bash
# Core Environment Commands
kali                    # Launch Kali Linux environment
kali-root              # Launch Kali Linux with root access
arch                    # Launch Arch Linux environment
arch-root              # Launch Arch Linux with root access
nh                     # Launch NetHunter
nh-root                # Launch NetHunter with root access

# GUI Interface
start-vnc              # Start VNC server
stop-vnc               # Stop VNC server
nh-kex                 # Start NetHunter GUI
nh-kex-stop           # Stop NetHunter GUI

# System Updates
update                 # Update Termux packages
nh-update              # Update NetHunter
kali-update           # Update Kali Linux
arch-update           # Update Arch Linux
```

### 🔧 System Management
```bash
# Performance Monitoring
monitor-system         # Start system resource monitoring
analyze-performance   # Generate performance report
optimize-system      # Run system optimization

# Backup Management
create-backup         # Create system backup
restore-backup       # Restore from backup
list-backups         # List available backups

# Health Checks
check-health         # Run system health check
verify-deps          # Verify dependency versions
fix-environment     # Fix environment issues
```

### 🛠️ Development Tools
```bash
# Package Management
pkg                  # Termux package manager
pacman               # Arch Linux package manager
apt                  # Kali Linux package manager

# Development Environment
python              # Python interpreter
pip                 # Python package manager
git                 # Version control
vim                 # Text editor
nano                # Simple text editor
```

### 🔍 Pentesting Tools
```bash
# Network Tools
nmap                # Network scanner
dirb                # Web content scanner
nikto               # Web server scanner
metasploit         # Penetration testing framework

# Wireless Tools
aircrack-ng        # Wireless network security
wifite             # Automated wireless auditor
```

## 📚 Complete Command Reference

### 🌐 Environment Commands
```bash
# Kali Linux Commands
kali                    # Start Kali Linux environment
kali-root              # Start Kali Linux with root access
kali-update            # Update Kali Linux system
kali-fix               # Fix Kali Linux issues
kali-backup            # Backup Kali environment
kali-restore           # Restore Kali environment

# NetHunter Commands
nh                     # Start NetHunter environment
nh-root                # Start NetHunter with root access
nh-kex                 # Start NetHunter GUI (Kex)
nh-kex-stop           # Stop NetHunter GUI
nh-update             # Update NetHunter system
nh-fix                # Fix NetHunter issues
nh-backup             # Backup NetHunter settings
nh-restore            # Restore NetHunter settings

# Arch Linux Commands
arch                   # Start Arch Linux environment
arch-root              # Start Arch Linux with root access
arch-update           # Update Arch Linux system
arch-fix              # Fix Arch Linux issues
arch-backup           # Backup Arch environment
arch-restore          # Restore Arch environment

# GUI and Display
start-vnc             # Start VNC server
stop-vnc              # Stop VNC server
set-resolution        # Set display resolution
reset-display         # Reset display settings
```

### 🔧 System Management Commands
```bash
# Performance Monitoring
monitor-system        # Start system resource monitoring
analyze-performance   # Generate performance report
optimize-system       # Run system optimization
check-health         # Run system health check
verify-deps          # Verify dependency versions
show-processes       # Show running processes
kill-process         # Kill a specific process
clean-system         # Clean system and remove temp files

# Backup Management
create-backup        # Create full system backup
restore-backup       # Restore from backup
list-backups         # List available backups
verify-backup        # Verify backup integrity
export-settings      # Export system settings
import-settings      # Import system settings
rotate-logs          # Rotate system logs

# Storage Management
check-storage        # Check storage usage
clean-cache          # Clean package cache
fix-permission       # Fix storage permissions
manage-space         # Manage storage space
```

### 🛠️ Development Commands
```bash
# Package Management
pkg                  # Termux package manager
pkg update           # Update package lists
pkg upgrade          # Upgrade installed packages
pkg install         # Install a package
pkg remove          # Remove a package
pkg clean           # Clean package cache

# Python Development
python              # Python interpreter
pip                 # Python package manager
pip install         # Install Python package
pip list            # List installed packages
virtualenv          # Create virtual environment
activate            # Activate virtual environment

# Version Control
git                 # Git version control
git-setup           # Configure Git settings
git-credentials     # Manage Git credentials

# Build Tools
make                # Build automation tool
gcc                 # GNU Compiler Collection
clang               # LLVM Compiler
cmake               # Build system generator
```

### 🔒 Security Commands
```bash
# Network Security
nmap                # Network scanner
nmap-full           # Full port scan
dirb                # Web content scanner
nikto               # Web vulnerability scanner
sqlmap              # SQL injection tool
hydra               # Password cracker
wireshark           # Network protocol analyzer

# Wireless Security
aircrack-ng        # Wireless security suite
wifite             # Automated wireless auditor
reaver             # WPS security tool
wash               # WPS scanning tool

# Web Security
burpsuite          # Web security testing
zaproxy            # Web app scanner
gobuster           # Directory enumeration
wpscan             # WordPress scanner
```

### 🔨 Utility Commands
```bash
# System Utilities
fix-proot           # Fix hanging proot sessions
fix-environment     # Fix environment issues
fix-network         # Fix network issues
fix-dns             # Fix DNS issues
termux-setup        # Setup Termux environment
termux-reload       # Reload Termux configuration

# File Operations
extract             # Extract archives
compress            # Compress files/folders
encrypt             # Encrypt files
decrypt             # Decrypt files
secure-delete       # Securely delete files

# Network Utilities
check-connection    # Check network connection
test-speed         # Test network speed
fix-wifi           # Fix WiFi issues
setup-ssh          # Setup SSH access
start-ssh          # Start SSH server
stop-ssh           # Stop SSH server
```

### ⚙️ Configuration Commands
```bash
# Environment Configuration
set-env             # Set environment variables
get-env             # Get environment variables
reset-env           # Reset environment settings
edit-config         # Edit configuration files
show-config         # Show current configuration

# Terminal Configuration
set-font            # Set terminal font
set-colors          # Set terminal colors
set-keyboard        # Configure keyboard
set-shortcuts       # Set custom shortcuts
reset-terminal      # Reset terminal settings

# Tool Configuration
config-tools        # Configure tool settings
update-tools        # Update tool configurations
reset-tools         # Reset tool settings
customize-prompt    # Customize shell prompt
set-aliases         # Set custom aliases
```

### 🎯 Quick Reference
```bash
# Most Used Commands
update              # Update all packages
upgrade             # Upgrade all packages
fix                 # Fix common issues
backup              # Quick backup
restore             # Quick restore
status              # Show system status
help                # Show help message
version             # Show version info

# Emergency Commands
emergency-fix       # Emergency system fix
force-stop          # Force stop all processes
safe-mode           # Start in safe mode
recovery            # Enter recovery mode
reset-all           # Reset everything
```

## 🚨 Troubleshooting Guide

### Common Issues
| Issue | Solution | Command |
|-------|----------|---------|
| Hanging Sessions | Kill proot processes | `fix-proot` |
| Storage Access | Reset permissions | `fix-permission` |
| GUI Problems | Restart VNC/KEX | `fix-nethunter-gui` |
| Package Errors | Clean & update | `pkg clean && pkg update` |
| Environment Issues | Reset environment | `fix-environment` |
| Performance Issues | Run optimization | `optimize-system` |
| Backup Failures | Check integrity | `verify-backup` |

### Error Recovery Process
1. Check logs: `cat ~/.termux/install_log.txt`
2. Run system check: `check_system_health`
3. Fix common issues: `fix_common_errors`
4. Reset if needed: `reset_environment`
5. Monitor performance: `monitor-system`
6. Optimize if necessary: `optimize-system`

## 📱 Developer

<div align="center">
  <img src="https://img.shields.io/badge/Developer-ITZBINAR-purple.svg?style=for-the-badge&logo=github" alt="Developer"/>
  <br/>
  <img src="https://img.shields.io/badge/Version-2.4-blue.svg?style=for-the-badge&logo=v" alt="Version"/>
  <br/>
  <img src="https://img.shields.io/badge/License-MIT-green.svg?style=for-the-badge&logo=license" alt="License"/>
</div>

## 🤝 Support & Contribution

### Get Help
- 📢 [Report Issues](https://github.com/itz-binar/linuxtools/issues)
- 🔧 [Submit PRs](https://github.com/itz-binar/linuxtools/pulls)
- 📖 [Wiki](https://github.com/itz-binar/linuxtools/wiki)

### Quick Links
- 🌟 [Star this Project](https://github.com/itz-binar/linuxtools)
- 🍴 [Fork on GitHub](https://github.com/itz-binar/linuxtools/fork)
- 📥 [Download Latest Release](https://github.com/itz-binar/linuxtools/releases)

---

<div align="center">
  <p>
    <img src="https://img.shields.io/badge/Made%20with-❤️-red.svg?style=for-the-badge" alt="Made with Love"/>
    <br/>
    <strong>ITZBINAR's Professional Pentesting Environment</strong>
    <br/>
    <em>Hack the Planet - Stay Legal, Stay Ethical</em>
  </p>
</div> 
