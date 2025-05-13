# Linux Tools Professional Suite

<div align="center">
  <h1>🛡️ Advanced Termux + Kali + NetHunter + Arch Linux Installer</h1>
  <p>Professional Penetration Testing Environment Setup</p>
  
  [![Developer](https://img.shields.io/badge/Developer-ITZBINAR-purple.svg)](https://github.com/itz-binar)
  [![Version](https://img.shields.io/badge/Version-2.4-blue.svg)]()
  [![License](https://img.shields.io/badge/License-MIT-green.svg)]()
  [![Root Status](https://img.shields.io/badge/Non--Root-Supported-orange.svg)]()
  [![GUI](https://img.shields.io/badge/GUI-Supported-brightgreen.svg)]()
  [![Menu](https://img.shields.io/badge/Menu-Interactive-yellow.svg)]()
</div>

## 🚀 Features

- **Enhanced Error Handling & Recovery**
  - Strict error handling with retry mechanism
  - Automatic error detection and recovery
  - Comprehensive logging system
  - System health monitoring
  - Cleanup utilities

- **Interactive Menu System**
  - Full Installation Option
  - Custom Installation Choices
  - Update & Maintenance Tools
  - Backup & Restore Features
  - Troubleshooting Utilities

- **Complete Linux Environments**
  - Kali Linux for penetration testing
  - Kali NetHunter with GUI support
  - Arch Linux for development
  - Full Termux integration
  - Non-root device support

- **Professional Tools**
  - Metasploit Framework
  - Network Analysis Tools
  - Web Testing Suite
  - Compatible with non-root devices
  - GUI Interface via VNC

- **Development Environment**
  - Multiple Programming Languages
  - Version Control Systems
  - Database Systems
  - Build Tools & Compilers

- **Error Handling & Recovery**
  - Automatic error detection
  - Self-healing capabilities
  - Troubleshooting guides
  - Recovery tools

## 📋 Prerequisites

- Android device (minimum Android 7.0)
- Termux app installed from F-Droid
- Minimum 10GB free storage
- Internet connection
- Works with or without root access
- VNC Viewer app (for GUI)

## 🔧 Installation

1. Clone the repository:
```bash
git clone https://github.com/itz-binar/linuxtools.git
cd linuxtools
```

2. Make the script executable:
```bash
chmod +x scripts/install-kali-termux.sh
```

3. Run the installer:
```bash
./scripts/install-kali-termux.sh
```

## 📚 Menu System

### Main Menu
```
1. Full Installation (Recommended)
2. Custom Installation
3. Update Existing Installation
4. Fix & Troubleshoot
5. Backup & Restore
6. Uninstall
7. About
8. Exit
```

### Custom Installation Menu
```
1. Install Kali Linux Only
2. Install NetHunter Only
3. Install Arch Linux Only
4. Install Basic Tools Only
5. Back to Main Menu
```

### Troubleshooting Menu
```
1. Fix Common Issues
2. Reset Environment
3. Fix Permissions
4. Fix NetHunter GUI
5. Check System Status
6. Back to Main Menu
```

### Backup & Restore Menu
```
1. Backup Environment
2. Restore from Backup
3. Export Settings
4. Import Settings
5. Back to Main Menu
```

## 🛠️ Available Environments

### Kali NetHunter
- Full NetHunter environment
- GUI support via VNC
- Pre-configured security tools
- Custom aliases and shortcuts
- Root and non-root compatible

### Kali Linux (Root & Non-Root)
- Full penetration testing suite
- Pre-configured security tools
- Non-root compatible tools
- Custom aliases and configurations

### Arch Linux (Root & Non-Root)
- Complete development environment
- Package management with pacman
- Development tools pre-installed
- Non-root optimizations

### Termux
- Enhanced terminal environment
- Professional tool suite
- Storage access configured
- Python development ready

## ⚡ Quick Commands

### Environment Management
```bash
# Start environments
kali                  # Start Kali Linux
nh                    # Start NetHunter
arch                  # Start Arch Linux

# GUI controls
nh-kex               # Start NetHunter GUI
nh-kex-stop          # Stop NetHunter GUI

# Updates
update               # Update Termux
nh-update            # Update NetHunter
```

### Troubleshooting
```bash
fix-proot            # Fix hanging sessions
fix-permission       # Fix storage access
~/bin/fix-environment # Fix environment issues
```

### Backup & Restore
```bash
backup-env           # Backup environment
restore-env          # Restore from backup
export-settings      # Export configurations
import-settings      # Import configurations
```

## 🔄 Error Recovery

The script includes automatic error recovery for:
- Hanging processes
- Permission issues
- Package conflicts
- Network problems
- Storage access errors

## 🤝 Contributing

1. Fork the repository
2. Create your feature branch
3. Commit your changes
4. Push to the branch
5. Open a Pull Request

## 📝 License

This project is licensed under the MIT License - see the LICENSE file for details.

## 👨‍💻 Developer

**ITZBINAR**
- GitHub: [@itz-binar](https://github.com/itz-binar)
- Version: 2.4
- Professional Penetration Testing Suite

## 📞 Support 

For support, issues, or contributions, please visit:
- GitHub Issues: [Report Issues](https://github.com/itz-binar/linuxtools/issues)
- Pull Requests: [Contribute](https://github.com/itz-binar/linuxtools/pulls)

### Common Issues & Solutions
1. **Hanging Sessions**: Use `fix-proot` command
2. **Storage Access**: Run `fix-permission`
3. **Environment Issues**: Execute `~/bin/fix-environment`
4. **Linux Problems**: Use `kali-fix` or `arch-fix`
5. **GUI Issues**: Restart with `nh-kex-stop` and `nh-kex`

---
<div align="center">
  <p>Created with ❤️ by ITZBINAR</p>
  <p>Professional Penetration Testing & Development Environment</p>
  <p>Interactive Menu System with Error Recovery</p>
</div> 
