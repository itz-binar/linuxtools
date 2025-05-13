# Linux Tools Professional Suite

<div align="center">
  <h1>🛡️ Advanced Termux + Kali + NetHunter + Arch Linux Installer</h1>
  <p>Professional Penetration Testing Environment Setup</p>
  
  [![Developer](https://img.shields.io/badge/Developer-ITZBINAR-purple.svg)](https://github.com/itz-binar)
  [![Version](https://img.shields.io/badge/Version-2.2-blue.svg)]()
  [![License](https://img.shields.io/badge/License-MIT-green.svg)]()
  [![Root Status](https://img.shields.io/badge/Non--Root-Supported-orange.svg)]()
  [![GUI](https://img.shields.io/badge/GUI-Supported-brightgreen.svg)]()
</div>

## 🚀 Features

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

## 📚 Usage

### NetHunter Commands
```bash
# Start NetHunter
nh

# Start NetHunter GUI
nh-kex

# Stop NetHunter GUI
nh-kex-stop

# NetHunter root shell
nh-root

# Update NetHunter
nh-update
```

### GUI Setup
```bash
# Set up NetHunter GUI
~/bin/setup-nethunter-gui

# Access via VNC Viewer:
# Address: localhost:5901
# Password: (as set during setup)
```

### Starting Environments
```bash
# Start Kali Linux
kali

# Start Arch Linux
arch

# Fix common issues
fix-proot
fix-permission
```

### Troubleshooting Commands
```bash
# Fix environment issues
~/bin/fix-environment

# Reset Kali Linux
kali-fix

# Reset Arch Linux
arch-fix

# Fix storage permissions
fix-permission
```

## 🔄 Updates and Maintenance

- Regular updates via `update` command
- Automatic package management
- Easy tool installation
- Version control integration
- Non-root compatibility fixes
- GUI environment updates

## ⚡ Non-Root Features

### What Works Without Root
- Full Linux environments (Kali & Arch)
- NetHunter basic features
- Most networking tools
- Development environments
- Package management
- Storage access
- Python tools and frameworks
- GUI interface

### Limited Features Without Root
- Some system-level operations
- Certain network scanning features
- Hardware access
- Low-level system modifications

### Troubleshooting Non-Root Issues
1. Use `fix-proot` for hanging sessions
2. Run `fix-permission` for storage issues
3. Execute `~/bin/fix-environment` for general fixes
4. Use `kali-fix` or `arch-fix` to reset Linux environments

## 🖥️ GUI Access

1. **Setup**
   - Run `~/bin/setup-nethunter-gui`
   - Set your VNC password
   - Start the GUI server

2. **Connection**
   - Install VNC Viewer from Play Store
   - Connect to `localhost:5901`
   - Enter your password

3. **Usage**
   - Full graphical environment
   - GUI-based tools
   - Multiple workspaces
   - Easy tool access

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
- Version: 2.2
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
  <p>Supports Both Root and Non-Root Devices with GUI</p>
</div> 